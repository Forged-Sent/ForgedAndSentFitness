---
id: ADR-0010
title: "Video proof capture, storage and review"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-PRF-001..012"
---
# ADR-0010: Video proof capture, storage and review

**Status:** Accepted

## Context
Approved: video proof supported in the first challenge release; proof optional/required per challenge; durable local copy; reviewer-only access; retention, deletion and appeal rules; protect children and private places; no guessed/reused URLs.

## Decision
Capture to app-private storage; explicit export to Photos/Gallery; local proof record with state machine and resumable upload to `proof/{gid}/{seasonId}/{challengeId}/{uid}/{attemptId}/{fileId}`; Storage rules allow owner write (size/type limits) and owner+reviewer read (cross-service membership check). `getDownloadURL` is not used for proof; playback uses rules-checked SDK downloads or a reviewer-only Function issuing short-lived signed URLs (audit-logged). Client-side compression to ≤ 720p. Scheduled deletion after finalization + appeal window (OD-06).

## Alternatives considered
Public or tokenized URLs; server-side transcoding in MVP.

## Consequences
+ Meets approved requirement with privacy controls. − Storage and egress are the dominant cost driver.

## Requirements and verification
Requirements: FS-PRF-001..012. Verification: Proof-saved-locally-before-upload test; unauthorized-read denied test; retention job test.
