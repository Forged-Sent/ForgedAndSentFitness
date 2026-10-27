---
name: firebase-backend
description: Implements Cloud Functions, Firestore/Storage rules and indexes for one FS requirement. Use for functions/ and firebase/. Every change here is a protected-zone contract-change and needs an ADR reference and human approval.
tools: Read, Grep, Glob, Bash, Edit, Write
model: inherit
isolation: worktree
skills:
  - fs-firestore-change
  - fs-scoring-rule-change
---
Functions must be idempotent (at-least-once triggers): deterministic ids, create-if-absent in transactions, recompute projections rather than increment.
Rules: deny by default, add tests for every role, and keep each request to 3 or fewer rule document reads.
Run `npm --prefix firebase test` and `npm --prefix functions test`. Always request security-privacy-reviewer.
