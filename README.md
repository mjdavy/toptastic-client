# ⚠️ Repository Deprecated

This repository (`toptastic-client`) is no longer the canonical codebase.

## Active / Canonical App Repository

[TopTastic Videos (active repo)](https://github.com/mjdavy/toptastic_videos)

---

## Why it was deprecated

The functionality here (offline-first chart browsing, integrity-checked song database, playlist integration) was fully merged into `toptastic_videos`, which now:

* Hosts the authoritative data refresh and integrity logic
* Provides updated tests, CI (analyze / test / build), and Dependabot automation
* Contains the comprehensive README, roadmap, and migration notes

## What to do instead

Clone or fork `toptastic_videos` for any future development. Open issues and pull requests there.

## Historical reference

This repo remains public for transparency and commit history diffusion. No further updates, dependency bumps, or security fixes will be applied here.

## Minimizing accidental usage

If you have this remote configured locally, you can remove it:

```bash
git remote remove origin
```

Or point any old forks upstream to the canonical repo:

```bash
git remote set-url origin https://github.com/mjdavy/toptastic_videos.git
```

## CI / Automation

CI has intentionally not been extended here. If a workflow file still exists in historical commits, prefer adding `[skip ci]` to any exceptional maintenance commit messages to avoid wasted runs.

---

Thank you for using TopTastic. See you in `toptastic_videos` 👋
Upgrade process:



1. Merge Dependabot PRs if CI passes.
