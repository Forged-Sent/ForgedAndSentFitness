# Where the bundled assets come from

Checked on 2026-11-11. Every font file is unmodified and was verified against the blob id GitHub lists at the commit named below. To check a file again, run `sha256sum` on it and compare.

## Fonts

All four families are licensed under the **SIL Open Font License, Version 1.1**. The licence was read in the `OFL.txt` that sits in the same source folder at the same commit, and that file is bundled beside the fonts here. Source repository for all of them: `https://github.com/google/fonts`.

| File (under `fonts/`) | Source commit and path | SHA-256 |
|---|---|---|
| `saira_condensed/SairaCondensed-Medium.ttf` | `5bb28733cec313b63fbd415b574b5ae35c8aa8b8`, `ofl/sairacondensed/` | `a02d8fe45b8b7d952cb0dd341683b02ddc1b55dbd0ed89d9d438868be614b66f` |
| `saira_condensed/SairaCondensed-SemiBold.ttf` | same | `30f8ed4d078211003a9715c80c51ce031bab5c9a17e8771182e4c4599205634b` |
| `saira_condensed/SairaCondensed-Bold.ttf` | same | `560297e4bccfb8c6e643095e716b5ea2ea9d7289801ddd79ab901698ffb0dee6` |
| `saira_condensed/SairaCondensed-ExtraBold.ttf` | same | `8821cabbc8bb3b0727be0a82d192c96baadbaf608012aff557eaaced1897ae84` |
| `saira_stencil_one/SairaStencilOne-Regular.ttf` | `5bb28733cec313b63fbd415b574b5ae35c8aa8b8`, `ofl/sairastencilone/` | `781496fdaf8e04cf6741b31025f6b4ba84f66021b097a8e0d85cbea2180cf223` |
| `ibm_plex_sans/IBMPlexSans-Regular.ttf` | `66f91f10f8e8590367c541bcb5adbe66c933f15f`, `ofl/ibmplexsans/` | `52babd121ff827c4f6ebbb20844d51569795eee6373580fc8979afc540048596` |
| `ibm_plex_sans/IBMPlexSans-Medium.ttf` | same | `791716d014b493b533a4faee947b3bef6078f31ee9dacee719445357aa9c0e1b` |
| `ibm_plex_sans/IBMPlexSans-SemiBold.ttf` | same | `76bd04cf3b2321586e668ecae60b73ecb5b86b4dc68bbbcdc6715ac6605f7783` |
| `merriweather/Merriweather-Italic.ttf` | `6392e4f212bab750be373234f29966cb268e1cfd`, `ofl/merriweather/` | `fc80dbac0ca9da894ae1801df9abe58f6dcca179ec4f8f6f7ea80fd13a1d387d` |

Copyright lines, as written in each `OFL.txt`:

- **Saira Condensed:** Copyright 2016 The Saira Project Authors, with reserved font name "Saira".
- **Saira Stencil One:** Copyright 2019 The Saira Stencil Project Authors.
- **IBM Plex Sans:** Copyright © 2017 IBM Corp. with Reserved Font Name "Plex".
- **Merriweather:** Copyright 2016 The Merriweather Project Authors, with Reserved Font Name "Merriweather".

Two families are not the newest release, on purpose:

- **Merriweather** is the last static release in the Google Fonts repository. The current release is one variable file of 4.6 MB, over this repository's 2 MB limit for a binary asset. Only the italic is bundled, because scripture is the only place the prototype uses this family.
- **IBM Plex Sans** is the last static release. The current release is variable only.

## Hero photograph

| File (under `images/`) | Source | SHA-256 |
|---|---|---|
| `2.0x/hero_mountain.jpg` | The `--mtn-photo` data URI in the prototype (`versions/app-v254.html` at `3ff4a6f`; identical in `index.html` on `main`), decoded and written unchanged. JPEG, 750×1333 | `93d81490de4e713eab6fe6e0fffac844c3467be6b0e51b0cfee9432ffb6c5196` |
| `hero_mountain.jpg` | The same image scaled to 375×667 (Lanczos, JPEG quality 88) | `0de7ff8671e2c05c61970f1f1c07e52b98110e866064cc92e6121ff20f87bc65` |

There is no 3.0x file: the source is 750 pixels wide, and a 3.0x image for a 390-point screen needs 1170. The photograph's own origin and licence are not recorded in the prototype.
