#!/usr/bin/env bash
set -euo pipefail

npm run build >/dev/null
home_css="$(rg -No '/assets/index-[^"]+\.css' dist/index.html | head -n1 || true)"
home_js="$(rg -No  '/assets/index-[^"]+\.js'  dist/index.html | head -n1 || true)"
[ -z "$home_css$home_js" ] && { echo "no home bundles"; exit 1; }

bf="src/layouts/LovableLayout.astro"
[ -f "$bf" ] || { echo "missing $bf"; exit 1; }
cp -n "$bf" "${bf}.bak"

if rg -q "$home_css|$home_js" "$bf"; then
  :
else
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

echo "== head =="
sed -n '/<head>/,/<\/head>/p' <(curl -s http://localhost:4321/services)

echo
echo "== bundle presence counts =="
echo -n "/services           -> "
curl -s http://localhost:4321/services            | rg -c "$home_css|$home_js" -NI || true
echo -n "/services/parcel..  -> "
curl -s http://localhost:4321/services/parcel-lockers | rg -c "$home_css|$home_js" -NI || true
