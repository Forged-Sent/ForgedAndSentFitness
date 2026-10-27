---
id: ADR-0001
title: "Rebuild in Flutter; keep the prototype as an executable behavioral reference"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-PAR-001..003"
---
# ADR-0001: Rebuild in Flutter; keep the prototype as an executable behavioral reference

**Status:** Accepted

## Context
The prototype (`index.html`, v162) is a single 7,152-line page whose scoring, deadlines and authorization run on the client and depend on claude.ai `window.claude` capabilities. It also carries the product's best content and ~160 iterations of UX learning.

## Decision
Build the production app from scratch in Flutter. Do not port or wrap the JavaScript. Freeze the prototype at tag `prototype-v162`; keep `index.html`, `seed/`, `versions/` unchanged as the behavioral reference. Extract intended behaviors as golden fixtures (`contracts/golden/legacy/`), each tagged `keep` or `changed-by:<ADR|OD>`.

## Alternatives considered
Wrap with Capacitor (keeps client-authoritative scoring; App Store 4.2 risk). Port JS piece by piece (logic entangled with DOM).

## Consequences
+ Clean authority and privacy model. − Parity takes several slices; prototype continues to serve the pilot group meanwhile.

## Requirements and verification
Requirements: FS-PAR-001..003. Verification: Legacy fixture suite runs in CI against `fs_domain`.
