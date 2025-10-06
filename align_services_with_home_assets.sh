#!/usr/bin/env bash
set -euo pipefail

npm run build >/dev/null

home_css="$(rg -No '/assets/index-[^"]+\.css' dist/index.html | head -n1 || true)"
home_js="$(rg -No '/assets/index-[^"]+\.js'  dist/index.html | head -n1 || true)"
[ -z "$home_css" ] && { echo "no home css"; exit 1; }
[ -z "$home_js" ] && { echo "no home js";  exit 1; }

bf="src/layouts/LovableLayout.astro"
[ -f "$bf" ] || { echo "missing $bf"; exit 1; }
cp -n "$bf" "${bf}.bak"

need_css="$(rg -n "$home_css" "$bf" || true)"
need_js="$(rg -n "$home_js" "$bf" || true)"

if [ -z "$need_css$need_js" ]; then
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

rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done

echo "== assets present? =="
curl -s http://localhost:4321/services              | rg -n "$home_css|$home_js" -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -n "$home_css|$home_js" -NI || true
