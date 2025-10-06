#!/usr/bin/env bash
set -euo pipefail

# 1) Build and capture home bundle paths
npm run build >/dev/null
home_css="$(rg -No '/assets/index-[^"]+\.css' dist/index.html | head -n1 || true)"
home_js="$(rg -No  '/assets/index-[^"]+\.js'  dist/index.html | head -n1 || true)"
[ -z "${home_css}${home_js}" ] && { echo "no home bundles"; exit 1; }

# 2) Ensure LovableLayout references those bundles
bf="src/layouts/LovableLayout.astro"
[ -f "$bf" ] || { echo "missing $bf"; exit 1; }
cp -n "$bf" "${bf}.bak"

if ! rg -q "$home_css|$home_js" "$bf"; then
  tmp="$(mktemp)"
  awk -v css="$home_css" -v js="$home_js" '
    BEGIN{done=0}
    /<\/head>/ && !done {
      print "    <link rel=\"stylesheet\" href=\"" css "\" />"
      print "    <script type=\"module\" src=\"" js "\"></script>"
      done=1
    }
    {print}
  ' "$bf" > "$tmp"
  mv "$tmp" "$bf"
fi

# 3) Rebuild
rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

# 4) Start preview and wait
pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT

ready=0
for i in {1..60}; do
  if curl -sf http://localhost:4321/ >/dev/null; then ready=1; break; fi
  sleep 0.3
done
[ "$ready" -eq 1 ] || { echo "Server did not start"; exit 1; }

# 5) Verify
echo "== /services <head> =="
sed -n '/<head>/,/<\/head>/p' <(curl -s http://localhost:4321/services)

echo
echo "== bundle presence counts (expect 2: CSS + JS) =="
printf "/services                 -> "
curl -s http://localhost:4321/services            | rg -c "$home_css|$home_js" -NI || true
printf "/services/parcel-lockers  -> "
curl -s http://localhost:4321/services/parcel-lockers | rg -c "$home_css|$home_js" -NI || true
