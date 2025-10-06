#!/usr/bin/env bash
set -euo pipefail

# 1) Ensure a fresh build and preview
rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT

# 2) Wait for server
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done

# 3) Grab current home bundle paths
home_css="$(rg -No '/assets/index-[^"]+\.css' dist/index.html | head -n1 || true)"
home_js="$(rg -No '/assets/index-[^"]+\.js'  dist/index.html | head -n1 || true)"

echo "HOME CSS: ${home_css:-<none>}"
echo "HOME JS : ${home_js:-<none>}"
if [ -z "${home_css}${home_js}" ]; then
  echo "Could not detect home bundles. Aborting."
  exit 1
fi

# 4) Show the <head> from a Services page
echo
echo "== /services <head> =="
curl -s http://localhost:4321/services | sed -n '/<head>/,/<\/head>/p'

# 5) Verify the exact bundle URLs are referenced on Services pages
echo
echo "== bundle presence checks =="
echo -n "/services           -> "
curl -s http://localhost:4321/services            | rg -c "$home_css|$home_js" -NI || true
echo -n "/services/parcel..  -> "
curl -s http://localhost:4321/services/parcel-lockers | rg -c "$home_css|$home_js" -NI || true
