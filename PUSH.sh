#!/usr/bin/env bash
# Commit and push the clean rebuild.
# Run once you're happy or immediately to ship it.

set -e
REPO="$HOME/Library/CloudStorage/OneDrive-earthedhv.au/000 unearthed/_CandidCaptures"
cd "$REPO"

# The old CSS/JS bundles from Higgsfield aren't referenced anymore.
# Remove them from git tracking (keep them on disk in case).
git rm --cached -f assets/styles.css assets/index.js 2>/dev/null || true

git add -A
git commit -m "Clean rebuild — standalone HTML + Tailwind, Monthly membership as hero offer"
git push origin main

echo
echo "Done. Vercel redeploys in ~60 sec."
echo "Hard refresh https://candidcaptures-eight.vercel.app with Cmd+Shift+R."
