"""Regression tests for a complete, offline and safe Architecture Atlas."""
import tempfile
import unittest
from pathlib import Path

from build_explorer import build_catalog, produce_data_js, symbols_for, dependencies


class ExplorerTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.root = Path(self.tmp.name)
        (self.root/"mobile/lib/src").mkdir(parents=True)
        (self.root/"docs").mkdir()
        (self.root/"versions").mkdir()
        (self.root/"mobile/lib/main.dart").write_text(
            "import 'src/widget.dart';\nFuture<void> main() async {}\n", encoding="utf-8")
        (self.root/"mobile/lib/src/widget.dart").write_text(
            "class Home {\n  Widget build() => Container();\n}\n", encoding="utf-8")
        (self.root/"docs/readme.md").write_text(
            "# Guide\n[Flutter](../mobile/lib/main.dart)\n", encoding="utf-8")
        (self.root/"versions/app-v1.html").write_text(
            "<div>" + "z"*180001 + "</div>", encoding="utf-8")
        self.paths = ["mobile/lib/main.dart","mobile/lib/src/widget.dart","docs/readme.md","versions/app-v1.html"]
        self.model = {"systems":[{"stage":"current","id":"client","purpose":"Tiny app",
                                   "files":["mobile/lib/main.dart"]}],
                      "symbolNotes":{"mobile/lib/main.dart::main":"Initializes this test app."}}

    def tearDown(self):
        self.tmp.cleanup()

    def test_all_tracked_paths_and_reverse_dependency(self):
        doc = build_catalog(self.root,self.paths,self.model,"abc123")
        self.assertEqual(doc["stats"]["files"],4)
        files={f["path"]:f for f in doc["files"]}
        self.assertEqual(files["mobile/lib/main.dart"]["deps"][0]["target"],
                         "mobile/lib/src/widget.dart")
        self.assertIn("mobile/lib/main.dart",files["mobile/lib/src/widget.dart"]["usedBy"])
        self.assertEqual(files["mobile/lib/main.dart"]["symbols"][0]["description"],
                         "Initializes this test app.")
        self.assertTrue(files["versions/app-v1.html"]["largeOrBinary"])
        self.assertEqual(files["versions/app-v1.html"]["symbols"],[])
        self.assertEqual(doc["stats"]["archived"],1)

    def test_invalid_model_owned_file_is_rejected(self):
        self.model["systems"][0]["files"]=["mobile/lib/never-existed.dart"]
        with self.assertRaisesRegex(ValueError,"absent file"):
            build_catalog(self.root,self.paths,self.model,"abc123")

    def test_safe_embedded_data_encoding(self):
        data={"label":"</script><script>alert('x')</script>","files":[]}
        script=produce_data_js(data)
        self.assertNotIn("</script>",script)
        self.assertIn("\\u003c",script)
        self.assertIn("window.FS_ATLAS_DATA",script)

    def test_python_classes_functions_and_docstrings(self):
        lines=["class Repo:","    '''Repository interface.'''",
               "    def load(self):","        '''Load data.'''","        pass",
               "def run():","    pass"]
        results=symbols_for("tooling/x.py",lines,{})
        self.assertIn("Repo.load",[x["name"] for x in results])
        self.assertIn("run",[x["name"] for x in results])
        self.assertEqual(next(x for x in results if x["name"]=="Repo")["description"],
                         "Repository interface.")

    def test_explicit_import_is_not_mislabeled_dynamic_call(self):
        edges,_=dependencies("mobile/lib/main.dart",
            ["import 'src/widget.dart';","final result=dispatchViaReflection();"],
            set(self.paths),{})
        self.assertEqual(len(edges),1)
        self.assertEqual(edges[0]["kind"],"import")
        self.assertEqual(edges[0]["confidence"],"explicit")


if __name__=="__main__":
    unittest.main()
