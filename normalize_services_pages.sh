#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob

mkdir -p src/pages/services/_orig
for f in src/pages/services/*.astro; do
  cp "$f" "src/pages/services/_orig/$(basename "$f")"
  BODY="$(awk 'BEGIN{f=0} /<body[^>]*>/{f=1;sub(/.*<body[^>]*>/,"");print;next} f && /<\/body>/{sub(/<\/body>.*/,"");print;f=0;next} f{print}' "$f")"
  if [ -z "$BODY" ]; then
    BODY="$(sed 's/\r$//' "$f")"
  fi
  cat > "$f" <<'ASTRO'
---
import SiteLayout from '../../layouts/SiteLayout.astro';
---
<SiteLayout>
ASTRO
  printf "%s\n" "$BODY" >> "$f"
  printf "\n</SiteLayout>\n" >> "$f"
done

rm -rf dist .astro node_modules/.vite
npm run build

pkill -f "astro preview" 2>/dev/null || true
npm run preview & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT

for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.5; done

echo "== /services =="
curl -s http://localhost:4321/services \
  | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true

echo "== /services/parcel-lockers =="
curl -s http://localhost:4321/services/parcel-lockers \
  | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true
