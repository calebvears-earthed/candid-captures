#!/usr/bin/env bash
#
# Full deploy: pull the Candid Captures site directly from higgsfield.app,
# stage it, commit it, push it. Runs end to end.
#
# Usage:
#   bash "$HOME/Library/CloudStorage/OneDrive-earthedhv.au/000 unearthed/_CandidCaptures/FULL-DEPLOY.sh"

set -e

REPO="$HOME/Library/CloudStorage/OneDrive-earthedhv.au/000 unearthed/_CandidCaptures"
SRC="https://candid-captures.higgsfield.app"

cd "$REPO"

echo "==> Fetching index.html from $SRC ..."
curl -sSL "$SRC/" -o index.html.raw
# Rewrite hashed asset URLs to clean local paths
sed -E \
  -e 's|https://candid-captures\.higgsfield\.app/assets/|assets/|g' \
  -e 's|assets/styles-[A-Za-z0-9]+\.css|assets/styles.css|g' \
  -e 's|assets/index-[A-Za-z0-9]+\.js|assets/index.js|g' \
  index.html.raw > index.html
rm index.html.raw
echo "    index.html: $(wc -c < index.html) bytes"

echo "==> Ensuring assets/ exists ..."
mkdir -p assets

# CSS + JS were already saved by Arc — skip if present
if [ ! -s "assets/styles.css" ]; then
  echo "==> Fetching styles.css ..."
  curl -sSL "$SRC/assets/styles-IClyCxNx.css" -o assets/styles.css
fi
echo "    styles.css: $(wc -c < assets/styles.css) bytes"

if [ ! -s "assets/index.js" ]; then
  echo "==> Fetching index.js ..."
  curl -sSL "$SRC/assets/index-CmWFbXBn.js" -o assets/index.js
fi
echo "    index.js:   $(wc -c < assets/index.js) bytes"

echo "==> Fetching 11 images ..."
for FILE in hero.jpg work-portrait.jpg work-branding.jpg work-fashion.jpg \
            work-event.jpg work-family.jpg work-product.jpg work-couple.jpg \
            work-bts.jpg work-beach.jpg about.jpg; do
  if [ ! -s "assets/$FILE" ]; then
    curl -sSL "$SRC/assets/$FILE" -o "assets/$FILE"
  fi
  echo "    $FILE: $(wc -c < "assets/$FILE") bytes"
done

echo
echo "==> Repo state:"
ls -la "$REPO"
echo
echo "==> assets/:"
ls -la "$REPO/assets"

# git dance
if [ ! -d ".git" ]; then
  echo "==> Initialising git ..."
  git init -b main
  git config user.email "calebvears@earthedhv.au"
  git config user.name "Caleb Vears"
fi

# Set remote if not set
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "==> Setting origin remote ..."
  git remote add origin https://github.com/calebvears-earthed/candid-captures.git
fi

echo "==> Staging all files ..."
git add -A
git status --short

echo "==> Committing ..."
git commit -m "Deploy Candid Captures site — HTML + CSS + JS + 11 image assets" || echo "(no changes to commit)"

echo "==> Pushing to origin/main ..."
git push -u origin main

echo
echo "==> Done. Vercel will auto-deploy within ~60 seconds."
echo "    Check https://candidcaptures-eight.vercel.app in a minute — it should be live."
