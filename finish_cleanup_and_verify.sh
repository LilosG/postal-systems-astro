#!/usr/bin/env bash
set -euo pipefail

# Stop preview if running
pkill -f "astro preview" 2>/dev/null || true

# Silence Astro warning: rename the backup file if it exists
if [ -f src/pages/index.html.bak ]; then
  mv src/pages/index.html.bak src/pages/_index.html.bak
fi

# Remove v4 helper packages (not needed on Tailwind v3)
npm pkg delete "devDependencies.@tailwindcss/postcss" "devDependencies.@tailwindcss/vite" >/dev/null || true

# Ensure Tailwind v3 + PostCSS 8 + Autoprefixer 10
npm i -D tailwindcss@^3 postcss@^8 autoprefixer@^10

# Quick sanity: show versions we care about
echo "== versions =="
npm pkg get devDependencies.tailwindcss devDependencies.postcss devDependencies.autoprefixer

# Clean build
rm -rf dist .astro node_modules/.vite
npm run build

# Preview (background)
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.25; done

# Verify exactly one <title> on key pages
echo "== <title> counts (expect 1) =="
for p in '' services services/parcel-lockers; do
  path="/${p}"; [ "$p" = '' ] && path='/'
  printf "%-26s -> " "$path"
  curl -s "http://localhost:4321${path}" | rg -c '<title>.*</title>' -NI || true
done

# Verify linked stylesheet and Tailwind preflight (box-sizing reset)
echo
echo "== Linked stylesheet on /services and Tailwind preflight present? =="
css_url="$(curl -s http://localhost:4321/services \
  | rg -No '<link[^>]+rel="stylesheet"[^>]+href="([^"]+)"' -r '$1' -NI \
  | rg -v 'fonts\.googleapis' \
  | head -n1 || true)"
echo "CSS HREF: ${css_url:-<none>}"
if [ -n "${css_url:-}" ]; then
  curl -s "http://localhost:4321${css_url}" | rg -q 'box-sizing:\s*border-box' && echo "preflight: yes" || echo "preflight: no"
else
  echo "preflight: no (no emitted CSS link found)"
fi
