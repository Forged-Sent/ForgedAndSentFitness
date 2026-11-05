#!/usr/bin/env python3
"""Trusted Actions coordinator. PR blobs are diff data, never executable code."""
from __future__ import annotations

import argparse
import base64
from datetime import datetime
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import urllib.error
import urllib.parse
import urllib.request

import review
from flutter_scope import relevant_paths, reviewers_for

CONTEXT = "flutter-ai-review"
MAX_FILES = 3000
MAX_PATCH = 400_000
MAX_SLICES = 4
SHA = re.compile(r"[0-9a-f]{40}\Z")
CODEX_REVIEWER_ID = 199175422
CODEX_REVIEWER = "chatgpt-codex-connector[bot]"
# Deliberately narrow until a real no-finding connector payload is captured.
CODEX_CLEAN_BODY = "<!-- codex-review-receipt:v1 -->\nNo suggestions found"


class GateError(Exception):
    """A safe, user-visible failure without subprocess output or credentials."""


class NativeReviewPending(GateError):
    """Codex has not supplied an unambiguous exact-diff review yet."""


def digest(value: object) -> str:
    return hashlib.sha256(json.dumps(value, sort_keys=True).encode()).hexdigest()


def load(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=review._no_duplicate_keys)


def save(path: Path, value: object) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2) + "\n", encoding="utf-8")


def identity(pr: dict) -> dict:
    head, base = pr["head"]["sha"], pr["base"]["sha"]
    if not SHA.fullmatch(head) or not SHA.fullmatch(base):
        raise GateError("Invalid GitHub commit identity")
    return {"pr": pr["number"], "head": head, "base": base,
            "base_ref": pr["base"]["ref"], "draft": pr["draft"],
            "labels": sorted(x["name"] for x in pr["labels"]
                             if x["name"].startswith("authorship:"))}


class GitHub:
    def __init__(self):
        self.repo = os.environ["GITHUB_REPOSITORY"]
        if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", self.repo):
            raise GateError("Invalid repository")
        self.token = os.environ["GH_TOKEN"]
        run = os.environ["GITHUB_RUN_ID"]
        attempt = os.environ["GITHUB_RUN_ATTEMPT"]
        if not run.isdecimal() or not attempt.isdecimal():
            raise GateError("Invalid workflow run")
        self.run_url = f"https://github.com/{self.repo}/actions/runs/{run}/attempts/{attempt}"

    def api(self, path: str, body: dict | None = None):
        data = json.dumps(body).encode() if body is not None else None
        req = urllib.request.Request(
            f"https://api.github.com/repos/{self.repo}/{path}", data=data,
            headers={"Authorization": "Bearer " + self.token,
                     "Accept": "application/vnd.github+json",
                     "X-GitHub-Api-Version": "2022-11-28", "User-Agent": CONTEXT},
            method="POST" if body is not None else "GET")
        try:
            with urllib.request.urlopen(req, timeout=45) as response:
                return json.load(response)
        except urllib.error.HTTPError as error:
            raise GateError(f"GitHub API returned HTTP {error.code}") from None

    def status(self, head: str, state: str, description: str):
        self.api(f"statuses/{head}", {"state": state, "context": CONTEXT,
                 "description": description[:140], "target_url": self.run_url})

    def owns_status(self, head: str) -> bool:
        for page in range(1, 31):
            rows = self.api(f"commits/{head}/statuses?per_page=100&page={page}")
            for item in rows:
                if item["context"] == CONTEXT:
                    return item.get("target_url") == self.run_url
            if len(rows) < 100:
                break
        return False

    def assert_unique_open_pr(self, head: str, number: int) -> None:
        """A commit status is shared by every PR using this head SHA.

        GitHub branch rules cannot distinguish those PRs by base branch, so a
        success is safe only when this is the sole open PR for the commit.
        """
        open_numbers = []
        for page in range(1, 31):
            # Listing open PRs covers fork heads too. commits/{sha}/pulls can
            # also include stacked PRs that merely contain this commit.
            rows = self.api(f"pulls?state=open&per_page=100&page={page}")
            open_numbers.extend(row["number"] for row in rows
                                if row["state"] == "open" and row["head"]["sha"] == head)
            if len(rows) < 100:
                if open_numbers != [number]:
                    raise GateError("Commit is shared by multiple open PRs or current PR is unavailable")
                return
        raise GateError("Commit has too many associated PRs to verify unique review scope")

    def files(self, pr: dict) -> list[dict]:
        if pr["changed_files"] > MAX_FILES:
            raise GateError("PR exceeds the file limit; split the change")
        rows = []
        for page in range(1, 31):
            batch = self.api(f"pulls/{pr['number']}/files?per_page=100&page={page}")
            rows.extend(batch)
            if len(batch) < 100:
                break
        if len(rows) != pr["changed_files"]:
            raise GateError("Incomplete changed-file listing; retry against a stable head")
        return rows


def git(root: Path, *args: str, env: dict | None = None) -> str:
    proc = subprocess.run(["git", *args], cwd=root, capture_output=True,
                          encoding="utf-8", errors="strict", env=env, timeout=120)
    if proc.returncode:
        raise GateError("Git object/diff operation failed; no PR code was executed")
    return proc.stdout


def outputs(values: dict) -> None:
    with open(os.environ["GITHUB_OUTPUT"], "a", encoding="utf-8") as out:
        for key, value in values.items():
            text = str(value)
            if "\n" in text or "\r" in text:
                raise GateError("Invalid workflow output")
            out.write(f"{key}={text}\n")


def prepare(root: Path, work: Path, number: int, api: GitHub) -> None:
    pr = api.api(f"pulls/{number}")
    snapshot = identity(pr)
    api.status(snapshot["head"], "pending", "Classifying change and selecting reviewer")
    try:
        if pr["state"] != "open":
            raise GateError("PR is no longer open")
        api.assert_unique_open_pr(snapshot["head"], number)
        paths = relevant_paths(api.files(pr))
        providers = []
        if paths:
            if pr["draft"]:
                raise GateError("Mark this functional PR ready for review to run the AI gate")
            actor = os.environ.get("GITHUB_TRIGGERING_ACTOR") or os.environ["GITHUB_ACTOR"]
            providers = list(reviewers_for(snapshot["labels"]))
            trusted_reconcile = (actor == "github-actions[bot]" and
                                 os.environ.get("GITHUB_EVENT_NAME") == "workflow_dispatch" and
                                 bool(os.environ.get("GITHUB_DEFAULT_BRANCH")) and
                                 os.environ.get("GITHUB_REF") ==
                                 f"refs/heads/{os.environ['GITHUB_DEFAULT_BRANCH']}")
            principal = ((pr.get("user") or {}).get("login") if trusted_reconcile else actor)
            if not principal:
                raise GateError("Cannot establish a trusted review trigger")
            permission = api.api("collaborators/" + urllib.parse.quote(principal, safe="") + "/permission")
            if permission.get("permission") not in ("write", "maintain", "admin"):
                raise GateError("A maintainer must trigger this paid review using Run workflow")
        policy_sha = git(root, "rev-parse", "HEAD").strip()
        if not SHA.fullmatch(policy_sha):
            raise GateError("Invalid trusted policy SHA")
        payload = {"identity": snapshot, "paths": paths, "providers": providers,
                   "policy_sha": policy_sha, "run_url": api.run_url, "chunks": []}
        if paths:
            # Fetch objects only. Never check out, import, build or execute the PR.
            env = os.environ.copy()
            auth = base64.b64encode(("x-access-token:" + api.token).encode()).decode()
            env.update({"GIT_CONFIG_COUNT": "1", "GIT_CONFIG_KEY_0": "http.https://github.com/.extraheader",
                        "GIT_CONFIG_VALUE_0": "AUTHORIZATION: basic " + auth,
                        "GIT_TERMINAL_PROMPT": "0"})
            git(root, "fetch", "--no-tags", "--no-recurse-submodules", "origin", snapshot["base"], env=env)
            git(root, "fetch", "--no-tags", "--no-recurse-submodules", "origin", f"refs/pull/{number}/head", env=env)
            if git(root, "rev-parse", "FETCH_HEAD").strip() != snapshot["head"]:
                raise GateError("PR changed while fetching; rerun the new head")
            patch = git(root, "diff", "--no-ext-diff", "--no-textconv", "--unified=20",
                        f"{snapshot['base']}...{snapshot['head']}", "--",
                        *[":(literal)" + path for path in paths])
            if not patch.strip() or len(patch) > MAX_PATCH:
                raise GateError("Functional diff is empty or exceeds 400000 characters; split the change")
            if re.search(r"(?m)^Binary files .* differ$|^GIT binary patch$", patch):
                raise GateError("Binary functional changes need a reviewable text/source representation")
            if review.SENSITIVE.search(patch):
                raise GateError("Possible secret in diff; remove it before sending code to a reviewer")
            chunks = review.chunk_patch(patch, limit=100_000)
            if len(chunks) > MAX_SLICES:
                raise GateError("Review exceeds four slices; split the change")
            for i, chunk in enumerate(chunks, 1):
                prompt = review.build_prompt(root, chunk["text"], snapshot["base"], i,
                                             len(chunks), chunk.get("continues"))
                if review.SENSITIVE.search(prompt):
                    raise GateError("Possible secret in review context")
                payload["chunks"].append({"prompt": prompt, "sha256": digest(prompt)})
            payload["diff_sha256"] = hashlib.sha256(patch.encode()).hexdigest()
        if identity(api.api(f"pulls/{number}")) != snapshot:
            raise GateError("PR identity or authorship changed during preparation; rerun")
        payload["binding"] = digest(payload)
        save(work / "input.json", payload)
        outputs({"required": str(bool(paths)).lower(), "providers": json.dumps(providers),
                 "policy_sha": policy_sha})
    except (GateError, ValueError) as error:
        if api.owns_status(snapshot["head"]):
            api.status(snapshot["head"], "failure", str(error))
        raise


def check_payload(payload: dict) -> None:
    fields = {k: v for k, v in payload.items() if k != "binding"}
    if digest(fields) != payload["binding"]:
        raise GateError("Review input binding mismatch")
    if len(payload["chunks"]) > MAX_SLICES:
        raise GateError("Too many review slices")
    for chunk in payload["chunks"]:
        if digest(chunk["prompt"]) != chunk["sha256"]:
            raise GateError("Review prompt digest mismatch")


def provider_command(provider: str, output: Path) -> list[str]:
    if provider != "claude":
        raise GateError("Native Codex review has no CLI command")
    command = review.command_for(provider, output)
    command += ["--setting-sources", "", "--disable-slash-commands"]
    model = os.environ.get("AI_REVIEW_" + provider.upper() + "_MODEL", "")
    if model:
        command[2:2] = ["--model", model]
    return command


def model_env(provider: str, home: Path) -> dict:
    # No GitHub token, runner service tokens, personal config or passthrough override.
    keep = {"PATH", "PATHEXT", "SYSTEMROOT", "WINDIR", "COMSPEC", "LANG", "LC_ALL", "SSL_CERT_FILE"}
    env = {k: v for k, v in os.environ.items() if k.upper() in keep}
    env.update({"HOME": str(home), "USERPROFILE": str(home), "TMPDIR": str(home),
                "TEMP": str(home), "TMP": str(home),
                "CLAUDE_CONFIG_DIR": str(home / ".claude")})
    if provider == "claude":
        key = "ANTHROPIC_API_KEY" if os.environ.get("ANTHROPIC_API_KEY") else "CLAUDE_CODE_OAUTH_TOKEN"
        if not os.environ.get(key):
            raise GateError("Configure ANTHROPIC_API_KEY or CLAUDE_CODE_OAUTH_TOKEN")
        env[key] = os.environ[key]
        return env
    raise GateError("Codex uses native GitHub account reviews, not a hosted CLI credential")


def _review_time(value: str) -> datetime:
    try:
        return datetime.fromisoformat(value.replace("Z", "+00:00"))
    except (AttributeError, ValueError):
        raise GateError("Malformed review/timeline timestamp") from None


def codex_review(api: GitHub, number: int, head: str) -> dict:
    """Collect every native Codex receipt after the last base retargeting."""
    base_changed = None
    for page in range(1, 31):
        rows = api.api(f"issues/{number}/timeline?per_page=100&page={page}")
        for event in rows:
            if event.get("event") == "base_ref_changed":
                stamp = _review_time(event.get("created_at"))
                base_changed = max(base_changed, stamp) if base_changed else stamp
        if len(rows) < 100:
            break
    else:
        raise GateError("PR timeline exceeded limit; cannot bind base")
    matches = []
    for page in range(1, 31):
        rows = api.api(f"pulls/{number}/reviews?per_page=100&page={page}")
        for row in rows:
            user = row.get("user") or {}
            if (user.get("id") == CODEX_REVIEWER_ID and
                    user.get("login") == CODEX_REVIEWER and
                    user.get("type") == "Bot" and
                    row.get("commit_id") == head and
                    row.get("submitted_at") and
                    row.get("state") not in ("PENDING", "DISMISSED")):
                if base_changed is None or _review_time(row["submitted_at"]) > base_changed:
                    matches.append(row)
        if len(rows) < 100:
            break
    else:
        raise GateError("Codex review listing exceeded limit")
    if not matches:
        raise NativeReviewPending("Waiting for a native Codex review after the latest base change")
    comments = []
    for selected in matches:
        for page in range(1, 31):
            rows = api.api(f"pulls/{number}/reviews/{selected['id']}/comments?per_page=100&page={page}")
            comments.extend(rows)
            if len(rows) < 100:
                break
        else:
            raise GateError("Codex review comments exceeded limit")
    if comments or any(row["state"] == "CHANGES_REQUESTED" for row in matches):
        outcome = "changes_required"
    elif all(row.get("state") == "COMMENTED" and
             (row.get("body") or "").strip() == CODEX_CLEAN_BODY for row in matches):
        outcome = "clean"
    else:
        outcome = "ambiguous"
    return {"review_ids": sorted(row["id"] for row in matches),
            "review_urls": [row["html_url"] for row in matches],
            "latest_submitted_at": max(row["submitted_at"] for row in matches),
            "comment_count": len(comments), "outcome": outcome}


def run_provider(work: Path, provider: str) -> None:
    payload = load(work / "input.json")
    check_payload(payload)
    if provider not in payload["providers"] or provider not in ("codex", "claude"):
        raise GateError("Unselected provider")
    report = {"provider": provider, "binding": payload["binding"], "results": [],
              "configured_model": os.environ.get("AI_REVIEW_" + provider.upper() + "_MODEL") or "CLI default; exact model not reported"}
    try:
        if provider == "claude" and "codex" in payload["providers"]:
            native = codex_review(GitHub(), payload["identity"]["pr"],
                                  payload["identity"]["head"])
            if native["outcome"] != "clean":
                raise GateError("Codex findings or ambiguous evidence must be resolved before Claude runs")
        if provider == "codex":
            evidence = codex_review(GitHub(), payload["identity"]["pr"],
                                    payload["identity"]["head"])
            report["configured_model"] = "Native Codex GitHub review; model not reported"
            report["native_review"] = evidence
            save(work / "result-codex.json", report)
            return
        with tempfile.TemporaryDirectory(prefix="fs-hosted-review-") as directory:
            home = Path(directory)
            env = model_env(provider, home)
            for chunk in payload["chunks"]:
                out = home / "last.txt"
                out.unlink(missing_ok=True)
                proc = subprocess.run(provider_command(provider, out), input=chunk["prompt"],
                                      cwd=home, env=env, capture_output=True, text=True,
                                      encoding="utf-8", errors="strict", timeout=600)
                if proc.returncode:
                    raise GateError(f"{provider} CLI failed; raw output withheld to protect credentials")
                raw = proc.stdout
                if len(raw) > review.MAX_OUTPUT or review.SENSITIVE.search(raw):
                    raise GateError("Reviewer output exceeds limits or resembles a secret")
                parsed = review.parse_report(raw)
                report["results"].append({"sha256": chunk["sha256"], "review": parsed})
    except NativeReviewPending as pending:
        report["pending"] = str(pending)
        save(work / f"result-{provider}.json", report)
        return
    except (GateError, ValueError, OSError, subprocess.TimeoutExpired):
        report["error"] = "Provider invocation or strict response validation failed; review NOT VERIFIED"
        save(work / f"result-{provider}.json", report)
        raise GateError(report["error"]) from None
    save(work / f"result-{provider}.json", report)


def validate_results(payload: dict, results: list[dict], api: GitHub | None = None) -> bool:
    check_payload(payload)
    providers = payload["providers"]
    if sorted(x.get("provider", "") for x in results) != sorted(providers):
        raise GateError("Missing, duplicate or unexpected reviewer result")
    for result in results:
        if result.get("binding") != payload["binding"] or result.get("error"):
            raise GateError("Stale or failed reviewer result")
        if result["provider"] == "codex":
            if api is None:
                raise GateError("Native Codex evidence requires a live GitHub recheck")
            live = codex_review(api, payload["identity"]["pr"], payload["identity"]["head"])
            if live != result.get("native_review"):
                raise GateError("Codex review evidence changed; rerun against latest evidence")
            if live["outcome"] != "clean":
                return False
            continue
        if len(result.get("results", [])) != len(payload["chunks"]):
            raise GateError("Reviewer did not cover every slice")
        for actual, expected in zip(result["results"], payload["chunks"]):
            if actual.get("sha256") != expected["sha256"]:
                raise GateError("Reviewer slice does not match the supplied diff")
            parsed = review.parse_report(json.dumps(actual["review"]))
            if parsed["verdict"] != "PASS" or parsed["slice_complete"] is not True:
                return False
    return True


def publish(work: Path, api: GitHub, job_result: str) -> None:
    payload = load(work / "input.json")
    check_payload(payload)
    snapshot = payload["identity"]
    if not api.owns_status(snapshot["head"]):
        print("A newer run owns the status; leaving it untouched")
        return
    state, message = "failure", "AI review incomplete; inspect this workflow run"
    results = []
    codex_evidence = None
    try:
        current = api.api(f"pulls/{snapshot['pr']}")
        if current["state"] != "open" or identity(current) != snapshot:
            raise GateError("PR changed during review; rerun the current head/base/authorship")
        api.assert_unique_open_pr(snapshot["head"], snapshot["pr"])
        if payload["paths"]:
            waiting = False
            if "codex" in payload["providers"]:
                native_path = work / "result-codex.json"
                native_result = load(native_path) if native_path.exists() else {}
                recorded = native_result.get("native_review")
                if (native_result.get("binding") != payload["binding"] or
                        native_result.get("provider") != "codex" or
                        native_result.get("pending") or not isinstance(recorded, dict)):
                    state, message, waiting = "pending", "Waiting for native Codex review evidence", True
                else:
                    try:
                        live = codex_review(api, snapshot["pr"], snapshot["head"])
                    except NativeReviewPending:
                        live = None
                    if live != recorded:
                        state, message, waiting = "pending", "Codex review changed; retrying exact-head evidence", True
                    else:
                        codex_evidence = digest(live["review_ids"])[:16]
            if not waiting:
                if job_result != "success":
                    raise GateError("Reviewer job failed, timed out or was cancelled")
                results = [load(work / f"result-{p}.json") for p in payload["providers"]]
                if not validate_results(payload, results, api):
                    raise GateError("Reviewer requested changes; resolve findings and rerun")
                state, message = "success", "PASS: " + ", ".join(payload["providers"]) + " reviewed this exact diff"
        else:
            state, message = "success", "Not required: no functional Flutter/backend changes"
    except (GateError, ValueError, OSError) as error:
        message = str(error) if isinstance(error, GateError) else "Missing or malformed reviewer evidence"
    if state == "success":
        try:
            api.assert_unique_open_pr(snapshot["head"], snapshot["pr"])
        except GateError as error:
            state, message = "failure", str(error)
    summary = {"identity": snapshot, "policy_sha": payload["policy_sha"],
               "binding": payload["binding"], "state": state, "message": message,
               "providers": results}
    save(work / "summary.json", summary)
    with open(os.environ["GITHUB_STEP_SUMMARY"], "a", encoding="utf-8") as out:
        out.write(f"## Flutter AI review\n\n{message}\n\nHead: `{snapshot['head']}`\n\n")
        out.write("Full structured findings and model limitations are in the review-summary artifact.\n")
    # Recheck run ownership immediately before publication to avoid stale-run overwrite.
    if api.owns_status(snapshot["head"]):
        description = (f"codex-evidence={codex_evidence} " if codex_evidence else "") + message
        api.status(snapshot["head"], state, description)
    if state == "pending":
        return
    if state != "success":
        raise GateError(message)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("prepare", "review", "publish"))
    parser.add_argument("--work", type=Path, required=True)
    parser.add_argument("--pr", type=int)
    parser.add_argument("--provider", choices=("codex", "claude"))
    parser.add_argument("--job-result", default="failure")
    args = parser.parse_args()
    try:
        if args.mode == "prepare":
            if not args.pr or args.pr < 1:
                raise GateError("Positive PR number required")
            prepare(Path.cwd(), args.work, args.pr, GitHub())
        elif args.mode == "review":
            run_provider(args.work, args.provider)
        else:
            publish(args.work, GitHub(), args.job_result)
        return 0
    except (GateError, ValueError, KeyError, OSError, subprocess.TimeoutExpired) as error:
        print(str(error) if isinstance(error, GateError) else "Gate failed; evidence is NOT VERIFIED", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
