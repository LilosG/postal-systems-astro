#!/usr/bin/env bash
set -euo pipefail
npm run build >/dev/null
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done
routes=(services services/4c-mailboxes services/cluster-box-units services/maintenance services/parcel-lockers services/pedestal-wall-mounted services/repairs-lock-changes)
for r in "${routes[@]}"; do
  c=$(curl -s "http://localhost:4321/$r" | rg -c '<title>.*</title>' -NI)
  if [ "$c" -ne 1 ]; then
    echo "/$r has $c <title> tags"; exit 1
  fi
done
echo "ok"
