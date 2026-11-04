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
        self.assertIn("/bin/zsh -lc 'command -v flutter'", diag)
        self.assertNotIn('if fs_has flutter && [ "$(command -v flutter)"', diag)
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

    # One double-click start file per OS at the root; every other launcher lives in
    # launchers/<os>/ (numbered steps) or launchers/<os>/more/ (optional extras).
    WINDOWS_STEPS = ("1 - Set up this computer.cmd", "2 - Run the app.cmd",
                     "3 - Start practice Firebase.cmd", "4 - Run app with practice Firebase.cmd",
                     "5 - Check my setup.cmd")
    MAC_STEPS = tuple(name.replace(".cmd", ".command") for name in WINDOWS_STEPS)

    @staticmethod
    def launchers(suffix: str) -> list[pathlib.Path]:
        folder = "windows" if suffix == ".cmd" else "mac"
        return sorted([*ROOT.glob(f"*{suffix}"), *(ROOT / "launchers" / folder).rglob(f"*{suffix}")])

    def test_root_has_only_one_start_file_per_os(self):
        self.assertEqual([p.name for p in ROOT.glob("*.cmd")], ["START-WINDOWS.cmd"])
        self.assertEqual([p.name for p in ROOT.glob("*.command")], ["START-MAC.command"])
        for name in self.WINDOWS_STEPS:
            self.assertTrue((ROOT / "launchers/windows" / name).is_file(), name)
        for name in self.MAC_STEPS:
            self.assertTrue((ROOT / "launchers/mac" / name).is_file(), name)

    def test_every_launcher_resolves_the_repository_root_and_its_target(self):
        import re
        modes = set(re.findall(r"^\s+'?([a-z-]+)'?\s*=\s*@\{File=",
                               read("tooling/windows/bootstrap-pwsh.ps1"), re.M))
        self.assertTrue({"wizard", "contributor", "check", "preview"} <= modes, modes)
        for launcher in self.launchers(".cmd"):
            with self.subTest(launcher=str(launcher.relative_to(ROOT))):
                raw = launcher.read_bytes()
                self.assertNotIn(b"\n", raw.replace(b"\r\n", b""), "Windows launchers need CRLF")
                text = raw.decode("ascii")
                up = re.findall(r'^cd /d "%~dp0((?:\.\.\\?)*)"\r?$', text, re.M)
                self.assertEqual(len(up), 1, "exactly one cd /d %~dp0 line")
                self.assertEqual((launcher.parent / up[0].replace("\\", "/")).resolve(), ROOT)
                mode = re.search(r"bootstrap-pwsh\.ps1\" -Mode ([a-z-]+)", text)
                target = re.search(r"tooling\\[a-z]+\\[a-z_]+\.py", text)
                self.assertTrue(mode or target, "launcher must start a known tool")
                if mode:
                    self.assertIn(mode.group(1), modes)
                if target:
                    self.assertTrue((ROOT / target.group(0).replace("\\", "/")).is_file())
        for launcher in self.launchers(".command"):
            with self.subTest(launcher=str(launcher.relative_to(ROOT))):
                text = launcher.read_text(encoding="utf-8")
                self.assertTrue(text.startswith("#!/bin/bash\n"))
                up = re.findall(r'^cd "\$\(dirname "\$0"\)((?:/\.\.)*)"', text, re.M)
                self.assertEqual(len(up), 1, "exactly one cd to the launcher folder")
                self.assertEqual((launcher.parent / ("." + up[0])).resolve(), ROOT)
                for target in re.findall(r"tooling/[a-z]+/[a-z_-]+\.(?:sh|py)", text):
                    self.assertTrue((ROOT / target).is_file(), target)
                mode = subprocess.run(["git", "-C", str(ROOT), "ls-files", "-s", "--",
                                       str(launcher.relative_to(ROOT))],
                                      capture_output=True, text=True).stdout
                if mode:  # tracked: Finder needs the executable bit
                    self.assertTrue(mode.startswith("100755"), mode)

    def test_mac_launchers_run_from_any_folder(self):
        for rel in ("START-MAC.command", "launchers/mac/3 - Start practice Firebase.command",
                    "launchers/mac/4 - Run app with practice Firebase.command"):
            with self.subTest(launcher=rel), tempfile.TemporaryDirectory() as elsewhere:
                result = subprocess.run(["bash", str(ROOT / rel), "--self-test"], cwd=elsewhere,
                                        stdin=subprocess.DEVNULL, capture_output=True, text=True,
                                        env={**__import__("os").environ, "CI": "1"})
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                self.assertNotIn("missing", result.stdout.lower())

    def test_readme_start_here_links_every_numbered_step(self):
        from urllib.parse import unquote
        text = read("README.md")
        self.assertIn("## New here? Start here", text)
        links = {unquote(link) for link in __import__("re").findall(r"\]\(([^)#]+)\)", text)}
        for rel in ("START-WINDOWS.cmd", "START-MAC.command",
                    *(f"launchers/windows/{n}" for n in self.WINDOWS_STEPS),
                    *(f"launchers/mac/{n}" for n in self.MAC_STEPS)):
            with self.subTest(link=rel):
                self.assertIn(rel, links)
        for link in links:
            if not link.startswith(("http:", "https:", "mailto:")):
                with self.subTest(target=link):
                    self.assertTrue((ROOT / link).exists(), link)

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


def isolated_git_env(home: pathlib.Path) -> dict:
    """No global/system Git identity, like a brand-new computer."""
    import os
    env = {k: v for k, v in os.environ.items() if not k.startswith("GIT_")}
    env.update(HOME=str(home), GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=str(home / "none"))
    return env


class SetupRegressionTests(unittest.TestCase):
    """Regression tests for the 2026-11-03 nontechnical onboarding audit (F1-F5)."""

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.home = pathlib.Path(self.tmp.name) / "home"
        self.home.mkdir()
        self.repo = pathlib.Path(self.tmp.name) / "clone"
        self.env = isolated_git_env(self.home)
        subprocess.run(["git", "init", "-q", str(self.repo)], check=True, env=self.env)

    def mac(self, body: str, stdin: str = "") -> subprocess.CompletedProcess:
        """Run Mac common.sh helpers (portable Bash) against the temp clone."""
        script = (f'set -euo pipefail; . "{ROOT / "tooling/macos/common.sh"}"; '
                  f'FS_ROOT="{self.repo}"; {body}')
        return subprocess.run(["bash", "-c", script], input=stdin, text=True,
                              capture_output=True, env=self.env, check=False)

    def test_f1_mac_check_uses_remembered_profile(self):
        r = self.mac('fs_has(){ return 1; }; a="$(fs_installed_profile)"; '
                     'fs_remember_profile Contributor; b="$(fs_installed_profile)"; '
                     'printf "Administrator\\n" > "$(fs_profile_file)"; c="$(fs_installed_profile)"; '
                     'fs_has(){ [ "$1" = firebase ]; }; rm "$(fs_profile_file)"; d="$(fs_installed_profile)"; '
                     'echo "$a $b $c $d"')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.split(), ["Preview", "Contributor", "Preview", "Contributor"])
        status = subprocess.run(["git", "-C", str(self.repo), "status", "--porcelain",
                                 "--untracked-files=all"], capture_output=True, text=True, env=self.env)
        self.assertEqual(status.stdout, "", "profile memory must live inside .git")

    def test_f1_both_wizards_announce_and_save_the_checked_profile(self):
        win, mac = read("tooling/windows/first-run.ps1"), read("tooling/macos/first-run.sh")
        self.assertIn("Get-FSRememberedProfile", win)
        self.assertIn("Save-FSProfile $root $targetProfile", win)
        self.assertIn("Checking your setup as:", win)
        self.assertNotIn("$script:SelectedProfile='Preview'", win)
        self.assertIn('FS_SELECTED_PROFILE="$(fs_installed_profile)"', mac)
        self.assertIn("fs_remember_profile Contributor", mac)
        self.assertIn("Checking your setup as:", mac)

    def test_f2_mac_identity_typo_never_aborts_setup(self):
        r = self.mac("fs_ensure_git_identity || fs_warn 'later'; echo REACHED_FLUTTER_STEPS",
                     stdin="A Friend\nnot-an-email\n")
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("REACHED_FLUTTER_STEPS", r.stdout)
        email = subprocess.run(["git", "-C", str(self.repo), "config", "--local", "--get", "user.email"],
                               capture_output=True, text=True, env=self.env)
        self.assertEqual(email.stdout.strip(), "", "invalid email must not be saved")
        setup = read("tooling/macos/setup.sh")
        self.assertIn("fs_ensure_git_identity || fs_warn", setup)
        self.assertNotIn("then fs_ensure_git_identity; fi", setup)

    def test_f2_mac_identity_saved_locally_not_globally(self):
        r = self.mac("fs_ensure_git_identity",
                     stdin="A Friend\n12345+friend@users.noreply.github.com\n")
        self.assertEqual(r.returncode, 0, r.stderr)
        get = lambda *a: subprocess.run(["git", "-C", str(self.repo), "config", *a],
                                        capture_output=True, text=True, env=self.env).stdout.strip()
        self.assertEqual(get("--local", "--get", "user.email"), "12345+friend@users.noreply.github.com")
        self.assertFalse((self.home / "none").exists() and (self.home / "none").read_text().strip())

    def test_f4_identity_offered_after_contributor_even_with_warnings(self):
        win, mac = read("tooling/windows/first-run.ps1"), read("tooling/macos/first-run.sh")
        self.assertIn("try{SetGitIdentity}", win)
        self.assertNotIn("Ask 'Check your Git commit name/email now?'", win)
        self.assertIn("FS_FROM_WIZARD=1", mac)
        self.assertIn("fs_ensure_git_identity || fs_warn", mac)
        self.assertIn("users.noreply.github.com", read("tooling/shell/fs-tools.ps1"))

    def test_f3_winget_output_cannot_pollute_jdk_path(self):
        script = read("tooling/windows/ensure-java21.ps1")
        for line in script.splitlines():
            if "winget.exe" in line and not line.lstrip().startswith("#"):
                self.assertTrue(line.rstrip().endswith("| Out-Host"), line)
        self.assertNotIn("Write-Output", script)
        self.assertEqual(script.count("[Console]::Out.WriteLine"), 1)

    def test_f5_first_pr_and_emulator_readiness_are_explained(self):
        guide = read("docs/development/FIRST-CONTRIBUTION.md")
        for phrase in ("sign in to GitHub", "Create Fork", "Approve and run"):
            self.assertIn(phrase, guide)
        ready = "All emulators ready! It is now safe to connect your app."
        for doc in ("docs/development/WINDOWS-QUICKSTART.md", "docs/development/MACBOOK-QUICKSTART.md",
                    "docs/development/FIREBASE-EMULATOR.md"):
            self.assertIn(ready, read(doc), doc)
        self.assertIn("menu choices 5 and 6", read("docs/development/FIREBASE-EMULATOR.md"))
        for doc in ("docs/development/WINDOWS-QUICKSTART.md", "docs/development/MACBOOK-QUICKSTART.md"):
            self.assertIn("git pull --ff-only origin pull/4/head", read(doc))


if __name__ == "__main__":
    unittest.main()
