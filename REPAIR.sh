#!/usr/bin/env bash
#
# Repair the Candid Captures deploy — the CSS/JS from the first pass had
# metadata bytes stripped that shouldn't have been. Re-fetch fresh from
# higgsfield.app and remove the Higgsfield inline SDK from the HTML.
#
# Usage:
#   bash "$HOME/Library/CloudStorage/OneDrive-earthedhv.au/000 unearthed/_CandidCaptures/REPAIR.sh"

set -e

REPO="$HOME/Library/CloudStorage/OneDrive-earthedhv.au/000 unearthed/_CandidCaptures"
SRC="https://candid-captures.higgsfield.app"
cd "$REPO"

echo "==> Deleting old CSS + JS to force fresh downloads ..."
rm -f assets/styles.css assets/index.js index.html

echo "==> Fetching fresh CSS from higgsfield ..."
curl -sSL "$SRC/assets/styles-IClyCxNx.css" -o assets/styles.css
echo "    styles.css: $(wc -c < assets/styles.css) bytes"

echo "==> Fetching fresh JS from higgsfield ..."
curl -sSL "$SRC/assets/index-CmWFbXBn.js" -o assets/index.js
echo "    index.js:   $(wc -c < assets/index.js) bytes"

echo "==> Fetching fresh HTML ..."
curl -sSL "$SRC/" -o index.html.raw

echo "==> Rewriting hashed asset URLs to clean local paths ..."
sed -E \
  -e 's|https://candid-captures\.higgsfield\.app/assets/|assets/|g' \
  -e 's|assets/styles-[A-Za-z0-9]+\.css|assets/styles.css|g' \
  -e 's|assets/index-[A-Za-z0-9]+\.js|assets/index.js|g' \
  index.html.raw > index.html

echo "==> Stripping the Higgsfield inline SDK script from <head> ..."
python3 << 'PYEOF'
import re

with open('index.html', 'r', encoding='utf-8') as f:
    html = f.read()

original_len = len(html)

# The Higgsfield SDK is an inline <script> block that starts with the approval SDK comment
# Remove all inline <script> tags in <head> that contain 'Approval client SDK' or 'hf-fetch' or 'window.hf'
pattern = re.compile(
    r'<script[^>]*>(?:(?!</script>)[\s\S])*?(?:Approval client SDK|hf-fetch|window\.hf|window\.__hfPatched)(?:(?!</script>)[\s\S])*?</script>',
    re.IGNORECASE
)
html_clean = pattern.sub('', html)

# Also remove any preload/prefetch links pointing to hashed higgsfield asset names
html_clean = re.sub(
    r'<link[^>]+href="[^"]*(?:styles-[A-Za-z0-9]+\.css|index-[A-Za-z0-9]+\.js)[^"]*"[^>]*>',
    '',
    html_clean
)

with open('index.html', 'w', encoding='utf-8') as f:
    f.write(html_clean)

print(f"    HTML cleaned: {original_len} -> {len(html_clean)} bytes")
PYEOF

rm index.html.raw

echo
echo "==> Repo state:"
ls -la "$REPO"
echo
echo "==> assets/:"
ls -la "$REPO/assets"

echo
echo "==> Committing and pushing ..."
git add -A
git commit -m "Fix: re-fetch fresh CSS/JS + strip Higgsfield SDK from HTML"
git push origin main

echo
echo "==> Done. Vercel should redeploy within ~60 seconds."
echo "    Check https://candidcaptures-eight.vercel.app — hard refresh (Cmd+Shift+R) to bypass cache."
