#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob

if [ -d src/pages/services/_orig ]; then
  cp -f src/pages/services/_orig/*.astro src/pages/services/ 2>/dev/null || true
fi

mkdir -p src/pages/services/_orig
for f in src/pages/services/*.astro; do
  [ -f "src/pages/services/_orig/$(basename "$f")" ] || cp "$f" "src/pages/services/_orig/$(basename "$f")"
done

extract_body () {
  local file="$1"
  local body
  body="$(awk 'BEGIN{f=0} /<body[^>]*>/{f=1;sub(/.*<body[^>]*>/,"");print;next} f && /<\/body>/{sub(/<\/body>.*/,"");print;f=0;next} f{print}' "$file")"
  if [ -z "${body//[[:space:]]/}" ]; then
    body="$(sed -E '
      s/\r$//;
      /^\s*<!DOCTYPE/Id; /^\s*<html[^>]*>/Id; /^\s*<\/html>/Id;
      /^\s*<head[^>]*>/, /^\s*<\/head>/ d;
      s/<body[^>]*>//Ig; s/<\/body>//Ig;
    ' "$file")"
  fi
  printf '%s' "$body"
}

for f in src/pages/services/*.astro; do
  body="$(extract_body "$f")"
  tmp="$(mktemp)"
  cat > "$tmp" <<'ASTRO'
---
import SiteLayout from '../../layouts/SiteLayout.astro';
---
<SiteLayout>
ASTRO
  printf "%s\n" "$body" >> "$tmp"
  printf "\n</SiteLayout>\n" >> "$tmp"
  mv "$tmp" "$f"
done

rm -rf dist .astro node_modules/.vite
if ! npm run build; then
  echo "Build failed. Showing contexts:" >&2
  for f in src/pages/services/*.astro; do
    echo "------- $f -------"
    nl -ba "$f" | sed -n '1,200p'
  done
  exit 1
fi

pkill -f "astro preview" 2>/dev/null || true
npm run preview & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT

for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.5; done

echo "== /services =="
curl -s http://localhost:4321/services | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true
echo "== /services/parcel-lockers =="
curl -s http://localhost:4321/services/parcel-lockers | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true
