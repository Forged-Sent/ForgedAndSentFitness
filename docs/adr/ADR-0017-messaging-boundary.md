---
id: ADR-0017
title: "Messaging boundary"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-COM-006"
---
# ADR-0017: Messaging boundary

**Status:** Accepted

## Context
DMs and youth messaging carry the highest harassment and safety risk.

## Decision
No direct messages, group chat or youth messaging. Channels are group feed, comments and prayer requests. Adding any messaging requires a new ADR with moderation, reporting, blocking, retention and escalation design.

## Alternatives considered
DMs in v1.

## Consequences
+ Small safety surface. − Men use other apps for chat.

## Requirements and verification
Requirements: FS-COM-006. Verification: Rules deny reserved `conversations` paths.
