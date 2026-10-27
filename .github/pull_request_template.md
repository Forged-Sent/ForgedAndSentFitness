## Requirement
FS id(s): <!-- e.g. FS-OFF-001 -->  ·  ADR(s): <!-- ADR-#### (required for protected zones) -->

## Change
<!-- What and why, 3–6 lines -->

## Checklist
- [ ] One FS id; ≤ ~400 changed lines excluding generated files
- [ ] Data classification of new fields (private / partner / leaders / group)
- [ ] Offline behavior described (what works without signal; pending states)
- [ ] Privacy impact (journal/prayer/health/nutrition/proof untouched or reviewed)
- [ ] Tests added and named with FS/TC ids; `python3 tools/validate_architecture.py` green
- [ ] Rules tests green (if rules changed)
- [ ] Reviewers: architecture / security / test as required by AGENTS.md
- [ ] No agent merged or approved this PR
