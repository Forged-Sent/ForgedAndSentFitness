#!/usr/bin/env python3
"""Post one GitHub PR handoff after a hosted review reaches a final result."""
from __future__ import annotations

import os
from pathlib import Path
import re
import sys

from github_gate import GitHub, GateError, identity, load

GITHUB_ACTIONS_BOT_ID = 41898282
FINDINGS_HEAD = re.compile(r"<!-- flutter-ai-review-findings-head:([0-9a-f]{40}) -->")


def notify(work: Path, api: GitHub) -> None:
    summary_path = work / "summary.json"
    if not summary_path.exists():
        return
    summary = load(summary_path)
    if summary.get("state") == "pending":
        return
    snapshot = summary["identity"]
    if not api.owns_status(snapshot["head"]):
        return  # A later run owns the current PR status and handoff.
    providers = summary.get("providers", [])
    if not providers and summary.get("state") == "success":
        return  # Documentation-only change: no review agent ran.
    pr = api.api(f"pulls/{snapshot['pr']}")
    if pr["state"] != "open" or identity(pr) != snapshot:
        return  # A new head, base, or authorship declaration superseded this run.
    author = pr["user"]["login"]
    mention = f"@{author}" if re.fullmatch(r"[A-Za-z0-9-]{1,39}", author) else "PR author"
    marker = f"<!-- flutter-ai-review-handoff:{summary['binding']} -->"
    prior_findings = set()
    for page in range(1, 11):
        comments = api.api(f"issues/{snapshot['pr']}/comments?per_page=100&page={page}")
        for row in comments:
            author = row.get("user") or {}
            if (author.get("id") != GITHUB_ACTIONS_BOT_ID or
                    author.get("login") != "github-actions[bot]"):
                continue
            body = row.get("body", "")
            if marker in body:
                return
            prior_findings.update(FINDINGS_HEAD.findall(body))
        if len(comments) < 100:
            break
    else:
        raise GateError("Too many PR comments to deduplicate the review handoff")

    label = snapshot["labels"][0] if len(snapshot["labels"]) == 1 else "authorship:unknown"
    status = summary.get("message", "Review finished; inspect the workflow result")
    outcome = "Review completed" if summary.get("state") == "success" else "Review needs attention"
    findings = []
    for provider in providers:
        for item in provider.get("results", []):
            for finding in item.get("review", {}).get("findings", []):
                severity = finding.get("severity", "")
                path = finding.get("path", "")
                line = finding.get("line", 0)
                if severity in ("critical", "high", "medium", "low") and isinstance(path, str):
                    safe_path = re.sub(r"[^A-Za-z0-9_./-]", "?", path)[:120]
                    findings.append(f"- {severity.upper()} `{safe_path}:{line if isinstance(line, int) else '?'}`")
    finding_text = "\n".join(findings[:6])
    if len(findings) > 6:
        finding_text += f"\n- … and {len(findings) - 6} more in the review artifact"
    if not finding_text and summary.get("state") != "success":
        finding_text = "- Inspect the linked workflow and any inline Codex review comments."
    has_findings = bool(findings) or "Codex review has findings" in status or \
        "Reviewer requested changes" in status
    repeated_findings = has_findings and any(head != snapshot["head"] for head in prior_findings)
    body = (
        f"{marker}\n"
        + (f"<!-- flutter-ai-review-findings-head:{snapshot['head']} -->\n" if has_findings else "")
        + f"{mention} — {outcome} for `{snapshot['head'][:12]}`. {status}\n\n"
    )
    if finding_text:
        body += finding_text + "\n\n"
    next_action = ("Pause implementation and wait for the maintainer to review the remaining comments. "
                   "Do not start another automatic fix cycle."
                   if repeated_findings else
                   "Investigate the Codex review receipt before changing code."
                   if "receipt unrecognized" in status else
                   "Non-blocking findings were reported; assess them before merging."
                   if summary.get("state") == "success" and findings else
                   "Review complete; no code changes were requested."
                   if summary.get("state") == "success" else
                   "Address the review findings, then push a new commit or rerun the review as appropriate.")
    body += (
        f"Declared implementor: `{label}`. Return to the implementing Codex or Claude session. "
        f"{next_action} Agent sessions do not wake from GitHub comments automatically.\n\n"
        f"[Review run]({api.run_url}) · This is advisory AI feedback, not an approval."
    )
    api.api(f"issues/{snapshot['pr']}/comments", {"body": body})


if __name__ == "__main__":
    try:
        notify(Path(os.environ["RUNNER_TEMP"]) / "gate", GitHub())
    except (GateError, KeyError, OSError, ValueError) as error:
        print(str(error) if isinstance(error, GateError) else "Review handoff could not be posted", file=sys.stderr)
        raise SystemExit(1)
