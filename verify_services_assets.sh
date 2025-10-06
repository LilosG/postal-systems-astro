#!/usr/bin/env bash
set -e
pkill -f "astro preview" 2>/dev/null || true
npm run preview & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.3; done

echo "== /services =="
curl -s http://localhost:4321/services \
  | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true

echo "== /services/parcel-lockers =="
curl -s http://localhost:4321/services/parcel-lockers \
  | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true
