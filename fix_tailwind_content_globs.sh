#!/usr/bin/env bash
set -euo pipefail

# Stop preview if running
pkill -f "astro preview" 2>/dev/null || true

# Tailwind v3 content globs
cat > tailwind.config.mjs <<'CFG'
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./src/**/*.{astro,html,js,jsx,ts,tsx,md,mdx}",
    "./public/**/*.html"
  ],
  theme: { extend: {} },
  plugins: [],
};
CFG

rm -rf dist .astro node_modules/.vite
npm run build

# Smoke test
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done

echo "== <title> counts (expect 1) =="
for p in services services/parcel-lockers; do
  printf "/%s -> " "$p"
  curl -s "http://localhost:4321/$p" | rg -c '<title>.*</title>' -NI || true
done

echo "== Tailwind tokens on /services (should find --tw-) =="
curl -s http://localhost:4321/services | rg -n -- '--tw-' -NI || echo "No --tw- tokens found"
