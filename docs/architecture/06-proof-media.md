# 06 · Challenge proof and media

Status: **Accepted (ADR-0010)**. Retention period: OD-06. Lifecycle diagram: `diagrams/12-video-proof-lifecycle.mmd`.

## Requirements recap

Video proof ships in the **first challenge-capable release**. Whether proof is `none`, `optional` or `required` is set **per challenge** by admins.

## Local capture and retention (FS-PRF-001..003)

1. **Capture.** The in-app camera, via the `camera` plugin (or `image_picker` with `ImageSource.camera`), records to the **app-private documents directory** (`<appDocs>/proof/<attemptId>/<fileId>.mp4`). App-private storage:
   - is not visible in Photos or Gallery,
   - is deleted when the app is uninstalled,
   - is included in OS device backups according to platform rules.
2. **Local record.** A Drift `proof_items` row is written **before** any upload starts: path, size, duration, sha256, createdAt and state (FS-PRF-002, TC-009).
3. **Preview, replace, retry.** The user previews the clip, can replace it, and can retry a failed upload. The file is kept until the user deletes it, or until the attempt is finalized and the retention period has passed.
4. **Save to Photos/Gallery.** This is an explicit action with a privacy notice ("This copy leaves the app and may sync to your cloud photo library"). It is never automatic.
5. **Compression.** Before upload, clips are re-encoded to ≤ 720p H.264/AAC and limited to 3 minutes (configurable). Photos are re-encoded with **EXIF stripped** (FS-PRF-007).

## Upload

- **Path:** `proof/{gid}/{seasonId}/{challengeId}/{uid}/{attemptId}/{fileId}.{ext}`.
- **Resumable uploads:** the Firebase Storage `putFile` task. If the app is killed mid-upload, the next launch restarts the upload from the persisted record, because a resumable session may not survive process death.
- **Upload-time Storage rules:**
  - `request.auth.uid == uid` in the path.
  - `request.resource.size` < 200 MB for video and < 15 MB for images.
  - `contentType` matches `video/(mp4|quicktime)` or `image/(jpeg|png|heic)`.
  - The caller is an active member of the group (cross-service `firestore.exists`, at most 2 Firestore reads per evaluation).
- **Attach:** after the upload completes, the outbox updates the attempt's `proofIds` (allowed only while the attempt is `submitted` and owned by the caller).

## Access (FS-PRF-004)

| Who | Access |
|---|---|
| Owner | Read own proof (SDK download, rules-checked) |
| Group reviewers and leaders | Read via the `getProofPlaybackUrl(attemptId)` callable. It checks the reviewer role, writes an `auditLog` entry, and returns a **V4 signed URL valid ≤ 15 minutes** |
| Other members | **No access** to media. They see "Proof reviewed ✓" only |
| Anyone with a copied URL | Expires within 15 minutes; tokens are never persisted in Firestore |

**`getDownloadURL()` is prohibited for proof.** Firebase download URLs embed a long-lived access token that works for anyone holding the link until it is revoked. That would defeat reviewer-only access and allow URL reuse. A static check in `tools/validate_architecture.py` fails if `getDownloadURL` appears under `app/lib/features/proof/` or `functions/src/proof/`.

## Privacy protections

- **Capture overlay guidance:** "Film only yourself. Keep children, family members, house numbers and screens out of frame."
- **Missions never require proof showing family members** (FS-CMP-009). Mission proof is an optional photo of a non-person artifact, or a note.
- **Reviewers are briefed:** proof is used only for scoring; no downloads or screenshots; report concerns through moderation.
- **Future (not v1):** on-device face blur for bystanders.

## Retention, deletion, appeal

| Event | Action |
|---|---|
| Attempt rejected or withdrawn | Media deleted 7 days later, unless appealed |
| Challenge finalized | Media retained through the appeal window, then for the retention period (OD-06, proposed 30 days), then deleted by the scheduled `purgeProof` job. The hash, reviewer decision and duration metadata are kept |
| Account deletion | All the user's proof objects deleted immediately; finalized snapshots keep anonymized rows |
| User deletes before review | Upload deleted; the attempt reverts to `submitted` without proof (and may fail a `required` policy) |

## Cost

Video storage and egress are the dominant variable cost (see `09-operations.md`). Controls:

- Compression.
- Reviewer-only playback; no feed autoplay.
- Retention deletion.
- Per-challenge proof policy.
