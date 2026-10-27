---
name: fs-proof-media
description: Implement or change challenge proof capture, local retention, upload, review playback or retention for Forged & Sent (ADR-0010). Use for app/lib/features/proof and functions/src/proof.
---
# Proof media

1. **Capture:**
   - Capture to the app-private documents dir.
   - Write the Drift `proof_items` record **before** the upload starts (TC-009).
   - Offer preview, replace and retry, plus an explicit "Save to Photos" with a privacy notice.
2. **Compress before upload:** ≤ 720p H.264, ≤ 3 min (configurable). Strip EXIF from images.
3. **Upload:**
   - Resumable upload to `proof/{gid}/{sid}/{cid}/{uid}/{attemptId}/{fileId}`.
   - Restart from the record after process death.
   - Attach `proofIds` to the attempt only while it is `submitted`.
4. **Playback:** reviewers call `getProofPlaybackUrl(attemptId)`, which checks the role, writes an audit entry and returns a V4 signed URL ≤ 15 min. **Never** use `getDownloadURL`.
5. **Privacy:** an overlay tells the user to film only himself. Missions never require family on camera.
6. **Retention:** the `purgeProof` scheduled job deletes media after the appeal window plus the retention period (OD-06), and keeps the hash and decision.
