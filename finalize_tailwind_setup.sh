#!/usr/bin/env bash
set -euo pipefail

# Stop any running preview to avoid port lockups.
pkill -f "astro preview" 2>/dev/null || true

# 0) Remove stray Tailwind configs so Tailwind loads the one we expect.
rm -f tailwind.config.js tailwind.config.mjs

# 1) Tailwind v3 (CJS) + PostCSS config — project-wide.
cat > tailwind.config.cjs <<'CFG'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./src/**/*.{astro,html,js,jsx,ts,tsx,md,mdx}",
    "./public/**/*.html"
  ],
  theme: { extend: {} },
  plugins: [],
};
CFG

cat > postcss.config.cjs <<'CFG'
module.exports = {
  plugins: { tailwindcss: {}, autoprefixer: {} },
};
CFG

# 2) Ensure global app.css is the single source of truth that Tailwind processes.
mkdir -p src/styles
cat > src/styles/app.css <<'CSS'
@import "./tokens.css";
@tailwind base;
@tailwind components;
@tailwind utilities;
CSS

# 3) Ensure LovableLayout imports the global CSS (no per-page bundles).
mkdir -p src/layouts
cat > src/layouts/LovableLayout.astro <<'ASTRO'
---
import "../styles/app.css";
interface Props { title?: string; description?: string; jsonLd?: any; bodyClass?: string }
const { title = "Postal Systems", description = "", jsonLd = undefined, bodyClass = "" } = Astro.props as Props;
---
<html lang="en">
  <head>
    <meta charset="utf-8" /><meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{title}</title>
    {description && <meta name="description" content={description} />}
    {jsonLd && <script type="application/ld+json">{JSON.stringify(jsonLd)}</script>}
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet" />
  </head>
  <body class={`theme-postal ${bodyClass}`.trim()}>
    <slot />
  </body>
</html>
ASTRO

# 4) Clean build.
rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

# 5) Preview.
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.25; done

# 6) Verify: exactly one <title> on key pages.
echo "== <title> counts (expect 1) =="
for p in '' services services/parcel-lockers; do
  path="/${p}"; [ "$p" = '' ] && path='/'
  printf "%-28s -> " "$path"
  curl -s "http://localhost:4321${path}" | rg -c '<title>.*</title>' -NI || true
done

# 7) Verify Tailwind is actually being compiled by fetching the CSS file in <head>.
#    We extract the 1st <link rel="stylesheet" href="..."> on /services and grep for Preflight signatures.
echo
echo "== Tailwind preflight present in linked CSS? =="
css_url="$(curl -s http://localhost:4321/services | rg -No '<link[^>]+rel="stylesheet"[^>]+href="([^"]+)"' -r '$1' -NI | head -n1 || true)"
if [ -z "$css_url" ]; then
  echo "No stylesheet link found on /services"
  exit 1
fi
# Fetch CSS and look for known preflight markers (box-sizing reset & border-color token).
curl -s "http://localhost:4321${css_url}" | rg -q '::before|box-sizing: border-box' && echo "yes" || echo "no"

