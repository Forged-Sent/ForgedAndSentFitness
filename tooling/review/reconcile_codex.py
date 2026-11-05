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
ROUTED_LABELS = {"authorship:claude", "authorship:human", "authorship:mixed"}


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
    for page in range(1, 31):
        result = api.request(f"actions/workflows/flutter-ai-review.yml/runs?per_page=100&page={page}")
        rows = result["workflow_runs"]
        if any(row.get("display_title") == title and row.get("status") in active for row in rows):
            return True
        if len(rows) < 100:
            return False
    raise RuntimeError("Workflow run listing exceeds pagination limit")


def reconcile(api: GitHub, default_ref: str) -> list[int]:
    """Dispatch unprocessed native review evidence from trusted default branch."""
    dispatched = []
    errors = []
    for pr in api.pages("pulls?state=open"):
        try:
            if pr["draft"] or len({x["name"] for x in pr["labels"]} & ROUTED_LABELS) != 1:
                continue
            head = pr["head"]["sha"]
            try:
                evidence = gate.codex_review(api, pr["number"], head)
            except gate.NativeReviewPending:
                continue
            current = gate.digest(sorted(evidence["review_ids"]))[:16]
            status = latest_context_status(api, head)
            description = (status or {}).get("description") or ""
            if description.startswith("Not required:") and current_pr_is_docs_only(api, pr["number"], head):
                continue
            marker = re.match(r"^codex-evidence=([0-9a-f]{16})\b", description)
            if marker and marker.group(1) == current:
                continue
            if active_run(api, pr["number"]):
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
