"""Code-map generator regression tests."""
import tempfile
import unittest
from pathlib import Path

from generate import inventory


class InventoryTests(unittest.TestCase):
    def test_import_graph_and_symbols(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            loc = root / "mobile/lib"
            (loc / "src").mkdir(parents=True)
            (loc / "main.dart").write_text(
                "import 'src/widget.dart';\nFuture<void> main() async {}\n", encoding="utf-8")
            (loc / "src/widget.dart").write_text(
                "class MyWidget {\n Widget build() => throw StateError('not implemented');\n}\n",
                encoding="utf-8")
            doc = inventory(root)
            self.assertIn("N0 --> N1", doc)
            self.assertIn("class MyWidget", doc)
            self.assertIn("fn build()", doc)
            self.assertEqual(doc, inventory(root))


if __name__ == "__main__":
    unittest.main()
