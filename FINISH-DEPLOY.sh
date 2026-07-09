#!/usr/bin/env bash
#
# Finish the Candid Captures site setup — move the 12 files that were downloaded
# to ~/Downloads into this repo, then git init and push.
#
# Run this from anywhere:
#   bash "$HOME/Library/CloudStorage/OneDrive-earthedhv.au/000 unearthed/_CandidCaptures/FINISH-DEPLOY.sh"

set -e

REPO="$HOME/Library/CloudStorage/OneDrive-earthedhv.au/000 unearthed/_CandidCaptures"
DL="$HOME/Downloads"

echo "==> Moving index.html into $REPO"
mv "$DL/candid-captures-index.html" "$REPO/index.html"

echo "==> Moving 11 image assets into $REPO/assets/"
mkdir -p "$REPO/assets"
for FILE in hero.jpg work-portrait.jpg work-branding.jpg work-fashion.jpg \
            work-event.jpg work-family.jpg work-product.jpg work-couple.jpg \
            work-bts.jpg work-beach.jpg about.jpg; do
  if [ -f "$DL/$FILE" ]; then
    mv "$DL/$FILE" "$REPO/assets/$FILE"
    echo "  · $FILE moved"
  else
    echo "  ! $FILE NOT FOUND in Downloads — check manually"
  fi
done

echo
echo "==> Repo contents:"
ls -la "$REPO"
echo
echo "==> Assets folder:"
ls -la "$REPO/assets"
echo
echo "==> Ready. Next: cd \"$REPO\" && git init -b main && git add -A && git commit -m \"Initial import\" && gh repo create calebvears-earthed/candid-captures --private --source=. --push --remote=origin"
