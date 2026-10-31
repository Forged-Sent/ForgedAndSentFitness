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
    ".vscode/settings.json", "mobile/pubspec.lock",
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

    def test_reviewer_without_tools_rejected(self):
        path = self.root / ".github/agents/architecture-reviewer.agent.md"
        path.write_text(path.read_text().replace("tools: ['read', 'search']", ""))
        self.assert_violation("reviewer must explicitly")

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
