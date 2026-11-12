import contextlib
import importlib.util
import io
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest
from concurrent.futures import ThreadPoolExecutor
from unittest.mock import patch
import zipfile

ROOT = Path(__file__).resolve().parents[1]

def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module

forge = load("forge_mac_test", ROOT / "lib/forge.py")
installer = load("forge_installer_test", ROOT / "install.py")

class Fixture(unittest.TestCase):
    def setUp(self):
        self.base = ROOT / ".qa"
        self.base.mkdir(exist_ok=True)
        self.temp = tempfile.TemporaryDirectory(prefix="fixture-", dir=self.base)
        self.home = Path(self.temp.name).resolve()
        assert self.home.parent == self.base.resolve()
        self.cwd = Path.cwd()
        os.chdir(self.home)
        self.state = patch.object(forge, "STATE", self.home / "state")
        self.config = patch.object(forge, "CONFIG", self.home / "config")
        self.state.start()
        self.config.start()
        self.repo = patch.object(forge, "repo", return_value="")
        self.repo.start()

    def tearDown(self):
        self.repo.stop()
        self.config.stop()
        self.state.stop()
        os.chdir(self.cwd)
        assert self.home.parent == self.base.resolve()
        self.temp.cleanup()

    def call(self, *args):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            forge.main(list(args))
        return output.getvalue()

    def install(self, terminal="none"):
        writes, state = installer.installation(self.home, terminal)
        with contextlib.redirect_stdout(io.StringIO()):
            backup = installer.apply(writes, state, False)
        return backup

class CoreTests(Fixture):
    def test_capture_persists_unicode_and_completion(self):
        self.call("todo", "Résumé — test retry")
        self.assertIn("Résumé", self.call("todos"))
        self.call("tdone", "1")
        self.assertNotIn("Résumé", self.call("todos"))
        self.assertIn("DONE", self.call("todos", "--all"))

    def test_task_project_filter(self):
        self.call("todo", "first project")
        with patch.object(forge, "repo", return_value="/another/repository"):
            self.call("todo", "second project")
            self.assertIn("second", self.call("todos", "--project"))
            self.assertNotIn("first", self.call("todos", "--project"))

    def test_notes_search_and_limit(self):
        self.call("note", "reconnect one")
        self.call("note", "second observation")
        self.assertIn("reconnect", self.call("notes", "reconnect"))
        self.assertNotIn("reconnect", self.call("recent-notes", "1"))

    def test_capture_rejects_credentials(self):
        with self.assertRaises(ValueError):
            self.call("note", "api_key=example-secret")
        with forge.database() as db:
            self.assertEqual(db.execute("SELECT count(*) FROM notes").fetchone()[0], 0)

    def test_concurrent_capture_preserves_every_row(self):
        # Initialize schema once, then exercise independent concurrent writers.
        with forge.database():
            pass
        def save(i):
            with forge.database() as db:
                db.execute("INSERT INTO tasks(text,project,created) VALUES(?,?,?)", (str(i), "fixture", "today"))
        with ThreadPoolExecutor(max_workers=4) as pool:
            list(pool.map(save, range(20)))
        with forge.database() as db:
            self.assertEqual(db.execute("SELECT count(*) FROM tasks").fetchone()[0], 20)

    def test_bookmark_literal_path_with_spaces(self):
        target = self.home / "space and [brackets]"
        target.mkdir()
        self.call("mark", "example", str(target))
        self.assertEqual(self.call("_resolve", "jump", "example").strip(), str(target))

    def test_session_resume_navigates_without_branch_switch(self):
        self.call("session", "save", "next tiny step")
        with patch.object(forge, "pick", side_effect=lambda rows, *a, **k: rows[0][1]), \
             patch.object(forge, "run") as runner, contextlib.redirect_stderr(io.StringIO()):
            self.assertEqual(self.call("_resolve", "session", "resume").strip(), str(self.home))
            runner.assert_not_called()

    def test_noninteractive_picker_does_not_wait(self):
        with patch("sys.stdin.isatty", return_value=False):
            with self.assertRaisesRegex(ValueError, "interactive"):
                forge.pick([("A", "a"), ("B", "b")])

    def test_config_validation_preserves_invalid_file(self):
        forge.CONFIG.mkdir()
        config = forge.CONFIG / "settings.json"
        config.write_text("{broken")
        with self.assertRaises(json.JSONDecodeError):
            forge.settings()
        self.assertEqual(config.read_text(), "{broken")

    def test_settings_type_validation(self):
        for k, v in [("theme", "pink"), ("git_status", "yes"), ("git_cache_seconds", 0), ("unknown", 1)]:
            with self.subTest(key=k), self.assertRaises(ValueError):
                forge.validate_setting(k, v)

    def test_find_files_ignores_generated_trees(self):
        (self.home / "workout.swift").write_text("hello")
        (self.home / "node_modules").mkdir()
        (self.home / "node_modules/workout.js").write_text("ignored")
        result = self.call("ff", "workout", ".")
        self.assertIn("workout.swift", result)
        self.assertNotIn("workout.js", result)

    def test_text_search_fallback_and_secret_files(self):
        (self.home / "app.txt").write_text("TODO: retry\nother")
        (self.home / ".env.local").write_text("TODO: hidden")
        with patch.object(shutil, "which", return_value=None):
            result = self.call("ftext", "todo", ".")
        self.assertIn("app.txt:1", result)
        self.assertNotIn("hidden", result)

    def test_hash_and_json(self):
        (self.home / "a.json").write_text('{"ready":true}')
        (self.home / "b.json").write_text('{"ready":true}')
        self.assertIn("True", self.call("comparefile", "a.json", "b.json"))
        self.assertEqual(json.loads(self.call("jview", "a.json")), {"ready": True})

    def test_base64_unicode_roundtrip(self):
        encoded = self.call("b64", "café").strip()
        self.assertEqual(self.call("unb64", encoded).strip(), "café")

    def test_archive_roundtrip_and_overwrite_refusal(self):
        (self.home / "sample.txt").write_text("saved")
        self.call("zipto", "saved.zip", "sample.txt")
        with self.assertRaises(ValueError):
            self.call("zipto", "saved.zip", "sample.txt")
        self.call("unzipto", "saved.zip", "restored")
        self.assertEqual((self.home / "restored/sample.txt").read_text(), "saved")

    def test_archive_path_traversal_refused_before_extraction(self):
        with zipfile.ZipFile(self.home / "bad.zip", "w") as z:
            z.writestr("../escaped.txt", "bad")
        with self.assertRaisesRegex(ValueError, "Unsafe"):
            self.call("unzipto", "bad.zip", "restored")
        self.assertFalse((self.home / "restored").exists())

    def test_env_inventory_hides_values(self):
        with patch.dict(os.environ, {"FORGE_TEST_SECRET": "do-not-print"}):
            result = self.call("envshow", "FORGE_TEST_SECRET")
        self.assertIn("[hidden]", result)
        self.assertNotIn("do-not-print", result)

    def test_git_main_staging_refused(self):
        with patch.object(forge, "branch", return_value="main"), self.assertRaises(ValueError):
            self.call("gad", "example.py")

    def test_git_stage_preview_never_executes(self):
        with patch.object(forge, "branch", return_value="feature/test"), patch.object(forge, "run") as runner:
            self.assertIn("git add", self.call("gad", "file with spaces", "--dry-run"))
            runner.assert_not_called()

    def test_fs_dry_run_uses_macos_launcher(self):
        (self.home / "mobile").mkdir()
        (self.home / "mobile/pubspec.yaml").write_text("name: forged_and_sent\n")
        with patch.object(forge, "project", return_value=self.home):
            result = self.call("fs", "run", "--emulator", "--dry-run")
        self.assertIn("tooling", result)
        self.assertIn("macos", result)
        self.assertIn("run-emulator-app.sh", result)

    def test_catalog_has_unique_commands_and_examples(self):
        names = [r[0] for r in forge.CATALOG]
        self.assertEqual(len(names), len(set(names)))
        self.assertTrue(all(r[3] for r in forge.CATALOG))

class InstallerTests(Fixture):
    def test_repository_seed_is_portable_and_upgrades_preserve_preferences(self):
        project = self.home / "Projects/checkout with spaces"
        (project / "mobile").mkdir(parents=True)
        (project / "mobile/pubspec.yaml").write_text("name: forged_and_sent\n")
        writes, state = installer.installation(self.home, "none", project_root=project)
        with contextlib.redirect_stdout(io.StringIO()):
            installer.apply(writes, state, False)
        settings = self.home / ".config/forge-mac/settings.json"
        saved = json.loads(settings.read_text())
        self.assertEqual(saved["default_project"], str(project))
        self.assertEqual(saved["workspace_roots"], [str(project.parent)])
        saved["prompt"] = "minimal"
        settings.write_text(json.dumps(saved))
        before = settings.read_bytes()
        writes, state = installer.installation(self.home, "none", project_root=project)
        self.assertNotIn(settings, writes)
        with contextlib.redirect_stdout(io.StringIO()):
            installer.apply(writes, state, False)
        self.assertEqual(settings.read_bytes(), before)
        self.assertFalse((self.home / "Library").exists())

    def test_repository_seed_rejects_invalid_checkout_before_any_writes(self):
        with self.assertRaisesRegex(ValueError, "checkout"):
            installer.installation(self.home, "none", project_root=self.home / "missing")
        self.assertFalse((self.home / ".zshrc").exists())
        self.assertFalse((self.home / ".config").exists())

    def test_preview_writes_nothing(self):
        writes, state = installer.installation(self.home, "iterm2")
        with contextlib.redirect_stdout(io.StringIO()):
            installer.apply(writes, state, True)
        self.assertFalse((self.home / ".zshrc").exists())
        self.assertFalse(state.exists())

    def test_install_is_idempotent_and_preserves_existing_rc(self):
        rc = self.home / ".zshrc"
        rc.write_text("export EXISTING_VALUE=retained\n")
        self.install()
        first = rc.read_text()
        self.install()
        self.assertEqual(first, rc.read_text())
        self.assertIn("export EXISTING_VALUE=retained", first)
        self.assertEqual(first.count(installer.START), 1)

    def test_uninstall_preserves_later_edits(self):
        self.install()
        rc = self.home / ".zshrc"
        rc.write_text(rc.read_text() + "export LATER_VALUE=yes\n")
        writes, state = installer.installation(self.home, uninstall=True)
        with contextlib.redirect_stdout(io.StringIO()):
            installer.apply(writes, state, False)
        self.assertIn("export LATER_VALUE=yes", rc.read_text())
        self.assertNotIn(installer.START, rc.read_text())
        self.assertTrue((self.home / ".config/forge-mac/forge.zsh").exists())

    def test_exact_restore_refuses_later_edits(self):
        backup = self.install()
        rc = self.home / ".zshrc"
        rc.write_text(rc.read_text() + "# later edit\n")
        with self.assertRaisesRegex(ValueError, "Later edits"):
            installer.restore(backup, self.home, False)

    def test_exact_restore_recovers_previous_bytes(self):
        rc = self.home / ".zshrc"
        rc.write_bytes(b"# original\n")
        backup = self.install()
        with contextlib.redirect_stdout(io.StringIO()):
            installer.restore(backup, self.home, False)
        self.assertEqual(rc.read_bytes(), b"# original\n")

    def test_malformed_markers_refused(self):
        (self.home / ".zshrc").write_text(installer.START + "\nunfinished\n")
        with self.assertRaises(ValueError):
            installer.installation(self.home)

    def test_iterm_profiles_have_stable_unique_ids(self):
        profiles, _ = installer.terminal_assets()
        records = json.loads(profiles)["Profiles"]
        self.assertEqual(len({p["Guid"] for p in records}), 2)
        self.assertTrue(all(p["Command"] == "/bin/zsh -l" for p in records))

    def test_ghostty_preserves_user_settings_and_legacy_filename(self):
        config = self.home / "Library/Application Support/com.mitchellh.ghostty/config"
        config.parent.mkdir(parents=True)
        config.write_text("font-size = 17\n")
        self.install("ghostty")
        self.assertIn("font-size = 17", config.read_text())
        self.assertEqual(config.read_text().count(installer.GSTART), 1)
        self.assertFalse(config.with_name("config.ghostty").exists())

if __name__ == "__main__":
    unittest.main()
