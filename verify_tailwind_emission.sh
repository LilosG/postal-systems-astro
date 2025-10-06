#!/usr/bin/env bash
set -euo pipefail

# Restart preview cleanly
pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.25; done

# Find the first non-Google stylesheet on /services
css_href="$(curl -s http://localhost:4321/services \
  | rg -No '<link[^>]+rel="stylesheet"[^>]+href="([^"]+)"' -r '$1' -NI \
  | rg -v 'fonts\.googleapis' \
  | head -n1 || true)"

echo "CSS HREF: ${css_href:-<none>}"
[ -z "${css_href:-}" ] && { echo "No site CSS link found"; exit 1; }

echo
echo "== Tailwind preflight markers in linked CSS? =="
curl -s "http://localhost:4321${css_href}" \
  | rg -n 'box-sizing:\s*border-box|::before|::after' -NI \
  || echo "No obvious preflight markers found"

echo
echo "== First 50 non-empty lines of linked CSS =="
curl -s "http://localhost:4321${css_href}" \
  | sed -e 's/^[[:space:]]\+//' | awk 'length($0)>0' | head -n 50

echo
echo "== Config snapshot =="
node -p "require('./package.json').devDependencies" 2>/dev/null || true
[ -f tailwind.config.cjs ] && echo "--- tailwind.config.cjs ---" && cat tailwind.config.cjs
[ -f postcss.config.cjs ]  && echo "--- postcss.config.cjs  ---" && cat postcss.config.cjs
