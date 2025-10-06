#!/usr/bin/env bash
set -euo pipefail
f="src/layouts/LovableLayout.astro"
[ -f "$f" ] || { echo "Missing $f"; exit 1; }

cp -n "$f" "$f.bak"
tmp="$(mktemp)"
# Strip any previously injected asset links/scripts that point to /assets/index-*.*
perl -0777 -pe 's{^\s*<link[^>]+/assets/index-[^"]+\.css"[^>]*>\s*\n}{}mg; s{^\s*<script[^>]+/assets/index-[^"]+\.js"[^>]*>\s*</script>\s*\n}{}mg' "$f" > "$tmp"
mv "$tmp" "$f"

rm -rf dist .astro node_modules/.vite
npm run build
