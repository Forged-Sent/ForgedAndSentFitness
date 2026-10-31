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

    def test_reviewer_without_tools_rejected(self):
        path = self.root / ".github/agents/architecture-reviewer.agent.md"
        path.write_text(path.read_text().replace("tools: ['read', 'search']", ""))
        self.assert_violation("reviewer must explicitly")

    def test_unowned_nested_files_rejected(self):
        path = self.root / ".github/CODEOWNERS"
        path.write_text(path.read_text().replace("* @Chadillac12", "/* @Chadillac12"))
        self.assert_violation("entire repository")

if __name__ == "__main__":
    unittest.main()
