"""Fast contract tests for the beginner's Windows/Mac developer journey.

No network, cloud accounts, device emulators or paid AI CLIs are required.
"""
from __future__ import annotations

import json
import pathlib
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[2]


def read(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


class BeginnerContractTests(unittest.TestCase):
    def test_postmerge_quickstarts_clone_default_main(self):
        for path in ("docs/development/WINDOWS-QUICKSTART.md",
                     "docs/development/MACBOOK-QUICKSTART.md",
                     "docs/development/GIT-101.md"):
            with self.subTest(path=path):
                text = read(path)
                self.assertIn("git clone https://github.com/Forged-Sent/ForgedAndSentFitness.git", text)
                self.assertIn("git switch main", text)
                self.assertNotIn("git clone --branch feature/contributor-emulator-onboarding", text)
                self.assertIn("pull/4/head:pr4-workstation-test", text)

    def test_first_contribution_has_a_cross_platform_happy_path(self):
        text = read("docs/development/FIRST-CONTRIBUTION.md")
        for item in ("Windows or Mac", "Visual Studio Code", "Source Control",
                     "Create new branch", "flutter analyze", "flutter test",
                     "noreply", "Publish Branch", "Draft", "ci-gate"):
            with self.subTest(item=item):
                self.assertIn(item, text)

    def test_windows_developer_has_python_identity_and_safe_git(self):
        setup = read("tooling/windows/setup-developer.ps1")
        diag = read("tooling/windows/verify-developer.ps1")
        cli = read("tooling/shell/fs-tools.ps1")
        self.assertIn("Python.Python.3.12", setup)
        self.assertIn("New-FSCheck Python", diag)
        self.assertIn("New-FSCheck GitIdentity", diag)
        self.assertIn("Ensure-FSGitIdentity", cli)
        self.assertIn("git switch --no-track", cli)
        self.assertIn("git merge --no-edit origin/main", cli)
        self.assertIn("git merge --abort", cli)
        self.assertIn("detached HEAD", cli)

    def test_mac_setup_is_consent_based_and_has_secret_hooks(self):
        common = read("tooling/macos/common.sh")
        setup = read("tooling/macos/setup.sh")
        diag = read("tooling/macos/verify.sh")
        self.assertIn("~/.zprofile", common)
        self.assertIn("fs_question 'Add the project Flutter SDK path", common)
        self.assertIn("fs_brew_formula gitleaks", setup)
        self.assertIn("fs_enable_git_hooks", setup)
        self.assertIn("fs_ensure_python", setup)
        self.assertIn("GitIdentity", diag)
        self.assertIn("FlutterOnPath", diag)
        self.assertNotIn("fs_brew_cask codex '' codex\n  fs_brew_cask claude-code '' claude", setup)

    def test_default_mcp_only_has_beginner_servers(self):
        vs = json.loads(read(".vscode/mcp.json"))
        claude = json.loads(read(".mcp.json"))
        optional = json.loads(read(".vscode/mcp-optional.example.json"))
        self.assertEqual(set(vs["servers"]), {"dart", "playwright", "context7"})
        self.assertEqual(set(claude["mcpServers"]), {"dart", "playwright", "context7"})
        self.assertEqual(set(optional["servers"]),
                         {"github", "figma", "maestro", "google-developer-knowledge"})
        self.assertNotIn("firebase", json.dumps(vs).lower())
        self.assertNotIn("firebase", json.dumps(optional).lower())

    def test_emulator_launchers_exist_on_both_platforms(self):
        for file in ("START-EMULATORS-WINDOWS.cmd", "RUN-EMULATOR-APP-WINDOWS.cmd",
                     "START-EMULATORS-MAC.command", "RUN-EMULATOR-APP-MAC.command"):
            with self.subTest(file=file):
                self.assertTrue((ROOT / file).is_file())

    def test_default_branch_clone_survives_feature_branch_deletion(self):
        with tempfile.TemporaryDirectory() as directory:
            tmp = pathlib.Path(directory)
            remote = tmp / "remote.git"
            work = tmp / "seed"
            clone = tmp / "friend"
            subprocess.run(["git", "init", "--quiet", "--bare", str(remote)], check=True)
            subprocess.run(["git", "--git-dir", str(remote), "symbolic-ref", "HEAD", "refs/heads/main"], check=True)
            subprocess.run(["git", "init", "--quiet", "--initial-branch=main", str(work)], check=True)
            subprocess.run(["git", "-C", str(work), "-c", "user.name=Test",
                            "-c", "user.email=test@example.invalid", "commit",
                            "--quiet", "--allow-empty", "-m", "seed"], check=True)
            subprocess.run(["git", "-C", str(work), "remote", "add", "origin", str(remote)], check=True)
            subprocess.run(["git", "-C", str(work), "push", "--quiet", "origin", "main"], check=True)
            subprocess.run(["git", "clone", "--quiet", str(remote), str(clone)], check=True)
            branch = subprocess.check_output(["git", "-C", str(clone), "branch", "--show-current"], text=True)
            self.assertEqual(branch.strip(), "main")


if __name__ == "__main__":
    unittest.main()
