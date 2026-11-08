#!/usr/bin/env python3
"""Trusted default-branch poller for completed account-backed Codex reviews.

Native Codex reviews are GitHub events, not secrets for a CI runner. Polling
avoids running a write-token workflow from PR-controlled review event code.
"""
from __future__ import annotations

import json
import os
import re
import urllib.error
import urllib.request

import github_gate as gate

CODEX_REVIEWER_ID = 199175422
CONTEXT = "flutter-ai-review"
ROUTED_LABELS = {"authorship:claude", "authorship:human", "authorship:automation", "authorship:mixed"}


class GitHub:
    def __init__(self, repo: str, token: str):
        if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repo):
            raise ValueError("Invalid repository")
        self.root = f"https://api.github.com/repos/{repo}/"
        self.token = token

    def request(self, path: str, body: dict | None = None):
        data = json.dumps(body).encode() if body is not None else None
        request = urllib.request.Request(
            self.root + path, data=data,
            method="POST" if body is not None else "GET",
            headers={"Authorization": "Bearer " + self.token,
                     "Accept": "application/vnd.github+json",
                     "X-GitHub-Api-Version": "2022-11-28",
                     "User-Agent": "flutter-ai-review-reconcile"})
        try:
            with urllib.request.urlopen(request, timeout=45) as response:
                raw = response.read()
                return json.loads(raw) if raw else None
        except urllib.error.HTTPError as error:
            raise RuntimeError(f"GitHub API returned HTTP {error.code}") from None

    def pages(self, path: str):
        for page in range(1, 31):
            rows = self.request(f"{path}{'&' if '?' in path else '?'}per_page=100&page={page}")
            if not isinstance(rows, list):
                raise RuntimeError("Expected a GitHub API list")
            yield from rows
            if len(rows) < 100:
                return
        raise RuntimeError("GitHub listing exceeds pagination limit")

    api = request  # Same read interface used by the trusted gate's Codex parser.


def latest_context_status(api: GitHub, head: str) -> dict | None:
    for row in api.pages(f"commits/{head}/statuses"):
        if row["context"] == CONTEXT:
            return row
    return None


def current_pr_is_docs_only(api: GitHub, number: int, head: str) -> bool:
    details = api.request(f"pulls/{number}")
    if details["head"]["sha"] != head:
        raise RuntimeError("PR head changed during reconciliation")
    files = list(api.pages(f"pulls/{number}/files"))
    if len(files) != details["changed_files"]:
        raise RuntimeError("Incomplete PR file listing")
    return not gate.relevant_paths(files)


def active_run(api: GitHub, number: int) -> bool:
    title = f"Flutter AI review PR #{number}"
    active = {"queued", "in_progress", "requested", "pending", "waiting"}
    for status in active:
        for page in range(1, 31):
            result = api.request(
                f"actions/workflows/flutter-ai-review.yml/runs?status={status}&per_page=100&page={page}")
            rows = result["workflow_runs"]
            if any(row.get("display_title") == title for row in rows):
                return True
            if len(rows) < 100:
                break
        else:
            raise RuntimeError("Active workflow run listing exceeds pagination limit")
    return False


def failed_run_after_review(api: GitHub, status: dict | None, number: int,
                            review_submitted_at: str) -> bool:
    """A terminal run begun after the review already attempted this evidence.

    This prevents a persistent prepare/publish failure from redispatching every
    quarter hour. A review arriving during the failed run remains retryable.
    """
    if not status or status.get("state") not in ("failure", "error"):
        return False
    target = status.get("target_url") or ""
    match = re.fullmatch(
        r"https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/actions/runs/([0-9]+)(?:/attempts/[0-9]+)?",
        target)
    if not match:
        return False
    run = api.request(f"actions/runs/{match.group(1)}")
    return (run.get("display_title") == f"Flutter AI review PR #{number}"
            and run.get("event") in ("workflow_dispatch", "pull_request_target")
            and run.get("created_at", "") > review_submitted_at)


def reconcile(api: GitHub, default_ref: str) -> list[int]:
    """Dispatch unprocessed native review evidence from trusted default branch."""
    dispatched = []
    errors = []
    for pr in api.pages("pulls?state=open"):
        try:
            labels = [x["name"] for x in pr["labels"]]
            if pr["draft"] or len(set(labels) & ROUTED_LABELS) != 1:
                continue
            try:
                gate.reviewers_for(labels)
            except ValueError:
                continue
            head = pr["head"]["sha"]
            status = latest_context_status(api, head)
            automation = any(x["name"] == "authorship:automation" for x in pr["labels"])
            if automation and not gate.is_dependabot_pr(pr):
                continue
            # Dependabot pull_request_target runs may have no write token. A
            # trusted default-branch schedule starts the first review instead.
            if automation and status is None:
                if not active_run(api, pr["number"]):
                    api.request("actions/workflows/flutter-ai-review.yml/dispatches",
                                {"ref": default_ref, "inputs": {"pr": str(pr["number"])}})
                    dispatched.append(pr["number"])
                continue
            try:
                evidence = gate.codex_review(api, pr["number"], head)
            except gate.NativeReviewPending:
                continue
            current = gate.digest(evidence["evidence_ids"])[:16]
            description = (status or {}).get("description") or ""
            if description.startswith("Not required:") and current_pr_is_docs_only(api, pr["number"], head):
                continue
            marker = re.match(r"^codex-evidence=([0-9a-f]{16})\b", description)
            if marker and marker.group(1) == current:
                continue
            if active_run(api, pr["number"]):
                continue
            if failed_run_after_review(api, status, pr["number"], evidence["latest_submitted_at"]):
                continue
            api.request("actions/workflows/flutter-ai-review.yml/dispatches",
                        {"ref": default_ref, "inputs": {"pr": str(pr["number"])}})
            dispatched.append(pr["number"])
        except Exception as error:
            errors.append(f"PR #{pr.get('number', '?')}: {type(error).__name__}")
    if errors:
        raise RuntimeError("Reconciliation failed for " + ", ".join(errors))
    return dispatched


def main() -> None:
    api = GitHub(os.environ["GITHUB_REPOSITORY"], os.environ["GH_TOKEN"])
    ref = os.environ["DEFAULT_REF"]
    if not re.fullmatch(r"[A-Za-z0-9_.-]+", ref):
        raise ValueError("Invalid default branch")
    dispatched = reconcile(api, ref)
    print(f"Dispatched {len(dispatched)} completed Codex review(s) for gate reconciliation")


if __name__ == "__main__":
    main()
