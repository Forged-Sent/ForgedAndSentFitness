# HTML preview agent rules

Read the repository root `AGENTS.md` for the shared workflow. This directory is only a browser preview harness for the active root `index.html`.

- Keep the mock deterministic and do not contact real databases, use real credentials, or imply authorization testing.
- Run `python3 dev/make_preview.py` after changing the prototype or the mock.
- The generated `dev/preview.html` is ignored and must not be committed.
- The mock validates appearance and basic interactions, not the hosted Claude runtime's identity, storage or sharing.
- A prototype-only PR may merge after CI without required human approval; changes to protected files or sensitive product rules must be reviewed.
