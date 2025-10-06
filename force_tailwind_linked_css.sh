#!/usr/bin/env bash
set -euo pipefail

# Stop any running preview
pkill -f "astro preview" 2>/dev/null || true

# 1) Overwrite the layout to LINK the compiled Tailwind bundle explicitly.
#    (No partial edits — full file content below.)
mkdir -p src/layouts
cat > src/layouts/LovableLayout.astro <<'ASTRO'
---
import type { APIContext } from 'astro';
// IMPORTANT: we link CSS using Astro.resolve so Vite/Astro emits a file (not only inline).
const appCssHref = Astro.resolve('../styles/app.css');

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
    <link rel="stylesheet" href={appCssHref} />
  </head>
  <body class={`theme-postal ${bodyClass}`.trim()}>
    <slot />
  </body>
</html>
ASTRO

# 2) Clean build
rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

# 3) Preview
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.25; done

# 4) Verify: single <title>
echo "== <title> counts (expect 1) =="
for p in '' services services/parcel-lockers; do
  path="/${p}"; [ "$p" = '' ] && path='/'
  printf "%-26s -> " "$path"
  curl -s "http://localhost:4321${path}" | rg -c '<title>.*</title>' -NI || true
done

# 5) Verify Tailwind preflight inside the HTML (covers inline case)
echo
echo "== Tailwind preflight present in HTML? (box-sizing reset) =="
curl -s http://localhost:4321/services | rg -q 'box-sizing:\s*border-box' && echo "yes" || echo "no"

# 6) Also fetch the linked CSS file and check there (covers linked case)
echo
echo "== Tailwind preflight present in LINKED CSS? =="
css_url="$(curl -s http://localhost:4321/services \
  | rg -No '<link[^>]+rel="stylesheet"[^>]+href="([^"]+)"' -r '$1' -NI \
  | rg -v 'fonts\.googleapis' \
  | head -n1 || true)"
echo "CSS HREF: ${css_url:-<none>}"
if [ -n "${css_url:-}" ]; then
  curl -s "http://localhost:4321${css_url}" | rg -q 'box-sizing:\s*border-box' && echo "yes" || echo "no"
else
  echo "no (no emitted CSS link found)"
fi
