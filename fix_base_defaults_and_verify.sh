#!/usr/bin/env bash
set -euo pipefail

bf="src/layouts/Base.astro"
[ -f "$bf" ] || { echo "missing $bf"; exit 1; }

cp -n "$bf" "${bf}.bak" || true

perl -0777 -i -pe 's/const\s*\{\s*title[^}]*\}\s*=\s*Astro\.props\s*;/const { title = "Postal Systems", description = "", jsonLd } = Astro.props;/s' "$bf"

if ! rg -q 'title\s*=\s*"Postal Systems"' "$bf"; then
  sed -i '' '0,/^---\s*$/{/^---\s*$/a\
const { title = "Postal Systems", description = "", jsonLd } = Astro.props;
}' "$bf"
fi

npm run build >/dev/null

pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT

for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done

echo "== /services title tag =="
curl -s http://localhost:4321/services | rg -n '<title>.*</title>' -NI || true

echo "== /services/parcel-lockers title tag =="
curl -s http://localhost:4321/services/parcel-lockers | rg -n '<title>.*</title>' -NI || true
