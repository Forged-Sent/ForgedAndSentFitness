"""Negative fixture tests for the mandatory policy checker, no credentials or network."""
import copy
import json
import shutil
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from check import evaluate

ROOT = Path(__file__).resolve().parents[2]
PATHS = [
    ".vscode/mcp.json", ".mcp.json", ".codex/config.toml",
    ".github/CODEOWNERS", ".github/agents/architecture-reviewer.agent.md",
    ".github/agents/firebase-security.agent.md",
    ".claude/agents/architecture-reviewer.md", ".claude/agents/firebase-security.md",
    ".github/workflows/ci-gate.yml",
    "tooling/mcp/launch.mjs", "tooling/windows/install-maestro.ps1",
    "tooling/versions.json",
    "tooling/macos/common.sh", "tooling/windows/setup-developer.ps1",
    "tooling/windows/setup.ps1",
    ".vscode/settings.json", "mobile/pubspec.lock",
    "docs/development/REPOSITORY-SECURITY.md",
]

class PolicyTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        for path in PATHS:
            dest = self.root / path
            dest.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(ROOT / path, dest)

    def assert_violation(self, text):
        issues = evaluate(self.root)
        self.assertTrue(any(text in x for x in issues), issues)

    def test_clean_configuration(self):
        self.assertEqual(evaluate(self.root), [])

    def test_literal_google_api_key_is_rejected(self):
        path = self.root / ".vscode/mcp.json"
        obj = json.loads(path.read_text())
        obj["servers"]["google-developer-knowledge"]["headers"]["X-Goog-Api-Key"] = "FAKE_TEST_VALUE_ONLY"
        path.write_text(json.dumps(obj))
        self.assert_violation("Google API key must be the runtime")

    def test_firebase_codex_toml_rejected(self):
        path = self.root / ".codex/config.toml"
        with path.open("a") as out:
            out.write('\n[mcp_servers.firebase]\ncommand = "firebase"\nargs = ["mcp"]\n')
        self.assert_violation("MCP names differ")

    def test_renamed_firebase_executable_rejected(self):
        path = self.root / ".mcp.json"
        obj = json.loads(path.read_text())
        obj["mcpServers"]["maestro"] = {"command":"firebase-tools","args":["mcp"]}
        path.write_text(json.dumps(obj))
        self.assert_violation("Firebase cloud MCP")

    def test_remote_server_url_redirect_is_rejected(self):
        path = self.root / ".mcp.json"
        obj = json.loads(path.read_text())
        obj["mcpServers"]["context7"]["url"] = "https://example.invalid/mcp"
        path.write_text(json.dumps(obj))
        self.assert_violation("must use approved URL")

    def test_codex_remote_server_cannot_run_commands(self):
        path = self.root / ".codex/config.toml"
        with path.open("a") as out:
            out.write('\ncommand = "bash"\nargs = ["-c", "echo unsafe"]\n')
        self.assert_violation("remote MCP has unapproved fields")

    def test_vscode_local_server_must_use_stdio(self):
        path = self.root / ".vscode/mcp.json"
        obj = json.loads(path.read_text())
        obj["servers"]["dart"]["type"] = "http"
        path.write_text(json.dumps(obj))
        self.assert_violation("local MCP must use stdio")

    def test_local_server_cannot_inject_environment(self):
        path = self.root / ".mcp.json"
        obj = json.loads(path.read_text())
        obj["mcpServers"]["dart"]["env"] = {"NODE_OPTIONS": "--require ./unexpected.cjs"}
        path.write_text(json.dumps(obj))
        self.assert_violation("local MCP has unapproved fields")

    def test_second_flutter_workflow_pin_drift_is_rejected(self):
        path = self.root / ".github/workflows/ci-gate.yml"
        src = path.read_text()
        self.assertGreaterEqual(src.count("flutter-version: '3.47.8'"), 2)
        first = src.index("flutter-version: '3.47.8'")
        later = src.index("flutter-version: '3.47.8'", first + 1)
        path.write_text(src[:later] + src[later:].replace(
            "flutter-version: '3.47.8'", "flutter-version: '3.48.0'", 1))
        self.assert_violation("all pinned version/hash occurrences")

    def test_windows_flutter_checkout_pin_drift_is_rejected(self):
        path = self.root / "tooling/windows/setup.ps1"
        path.write_text(path.read_text().replace(
            "--branch 3.47.8", "--branch 3.48.0", 1))
        self.assert_violation("all pinned version/hash occurrences")

    def test_mac_flutter_pin_drift_is_rejected(self):
        path = self.root / "tooling/macos/common.sh"
        path.write_text(path.read_text().replace(
            "Flutter 3.47.8", "Flutter 3.48.0", 1))
        self.assert_violation("all pinned version/hash occurrences")

    def test_maestro_hash_drift_is_rejected(self):
        path = self.root / "tooling/windows/install-maestro.ps1"
        raw = path.read_text()
        manifest = json.loads((self.root / "tooling/versions.json").read_text())
        self.assertIn(manifest["maestroZipSha256"], raw)
        path.write_text(raw.replace(manifest["maestroZipSha256"], "b"*64, 1))
        self.assert_violation("all pinned version/hash occurrences")

    def test_reviewer_without_tools_rejected(self):
        path = self.root / ".github/agents/architecture-reviewer.agent.md"
        path.write_text(path.read_text().replace("tools: ['read', 'search']", ""))
        self.assert_violation("reviewer must explicitly")

    def test_ruleset_documentation_must_keep_default_protection(self):
        path = self.root / "docs/development/REPOSITORY-SECURITY.md"
        src = path.read_text()
        self.assertIn("**\n!index.html", src)
        path.write_text(src.replace("**\n!index.html", "mobile/**\n!index.html"))
        self.assert_violation("Required reviewers patterns must match")

    def test_ruleset_documentation_must_keep_specific_exceptions(self):
        path = self.root / "docs/development/REPOSITORY-SECURITY.md"
        path.write_text(path.read_text().replace("!dev/mock-claude.js", "!dev/**"))
        self.assert_violation("Required reviewers patterns must match")

    def test_claude_session_hook_is_rejected(self):
        path = self.root / ".claude/settings.json"
        path.write_text(json.dumps({"hooks": {"SessionStart": [{
            "hooks": [{"type": "command", "command": "firebase login --no-localhost"}]
        }]}}))
        self.assert_violation("Claude project hooks are forbidden")

    def test_claude_allow_permission_is_rejected(self):
        path = self.root / ".claude/settings.local.json"
        path.write_text(json.dumps({"permissions": {"allow": ["Bash(*)"]}}))
        self.assert_violation("Claude project permissions.allow is forbidden")

    def test_sensitive_mobile_path_cannot_lose_review_owners(self):
        path = self.root / ".github/CODEOWNERS"
        path.write_text(path.read_text().replace("/mobile/ @Chadillac12", "/mobile/ @someoneelse"))
        self.assert_violation("protected path is unowned: /mobile/")

    def test_proto_changes_must_not_be_owned_by_repository_wildcard(self):
        path = self.root / ".github/CODEOWNERS"
        path.write_text("* @Chadillac12 @sfcsmithc-afk\n" + path.read_text())
        self.assert_violation("prototype must not have a repository-wide mandatory owner")

    def test_sensitive_prototype_seed_rule_cannot_lose_review(self):
        path = self.root / ".github/CODEOWNERS"
        path.write_text(path.read_text().replace("/seed/db-rules.json @Chadillac12", "/seed/db-rules.json @someoneelse"))
        self.assert_violation("protected path is unowned: /seed/db-rules.json")

if __name__ == "__main__":
    unittest.main()
