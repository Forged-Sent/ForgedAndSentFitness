# Media retention (for the Firebase move)

Decided by Curtis on 2026-10-30. Photos and videos in Rally and challenge proof are purged after 30 days, to keep storage down. Everything else is kept.

| Upload | Folder in Cloud Storage | Kept |
|---|---|---|
| Profile photo and banner | `media/profile/{uid}/` | Forever (until replaced) |
| Progress photos (front/side/back) | `media/progress/{uid}/` | Forever |
| Meal idea photos and recipe PDFs | `media/meals/{uid}/` | Forever |
| Rally posts and replies | `media/rally/{uid}/` | 30 days |
| Challenge proof | `media/proof/{uid}/` | 30 days |
| Photo upload test (Settings diagnostics) | `media/test/{uid}/` | 30 days |

The purge itself is a Cloud Storage lifecycle rule, not code: `storage-lifecycle.json` deletes files in the three 30-day folders once they are 30 days old.

```
gcloud storage buckets update gs://<project>.firebasestorage.app --lifecycle-file=dev/firebase/storage-lifecycle.json
gcloud storage buckets update gs://<project>.firebasestorage.app --clear-soft-delete
```

The second line turns off soft delete, so purged files stop counting against storage right away. Without it, they are kept and billed for 7 more days.

## What the app must do

- Each upload type goes in its own folder (above). A file shared from challenge proof into a Rally post keeps its proof path, so it still expires at 30 days.
- Text, workout and challenge cards, scores and standings stay. Only the photo or video file goes away.
- Where a file is gone, show "Photo expired after 30 days" (or "Video expired") instead of a broken image. The proof viewer in Standings shows the same.

Lifecycle rules run in the background; Google does not promise exact timing, and rule changes can take up to 24 hours to apply. https://docs.cloud.google.com/storage/docs/lifecycle
