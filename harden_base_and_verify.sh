#!/usr/bin/env bash
set -euo pipefail

npm run build >/dev/null

home_css="$(rg -No '/assets/index-[^"]+\.css' dist/index.html | head -n1 || true)"
home_js="$(rg -No '/assets/index-[^"]+\.js' dist/index.html | head -n1 || true)"
[ -z "$home_css" ] && { echo "no home css"; exit 1; }
[ -z "$home_js" ] && { echo "no home js"; exit 1; }

bf="src/layouts/Base.astro"
[ -f "$bf" ] || { echo "missing $bf"; exit 1; }
cp -n "$bf" "${bf}.pre-hardening.bak" || true

cat > "$bf" <<ASTRO
---
const title = Astro.props?.title ?? "Postal Systems";
const description = Astro.props?.description ?? "";
const jsonLd = Astro.props?.jsonLd;
---
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>{title}</title>
    {description && <meta name="description" content={description} />}
    {jsonLd && <script type="application/ld+json">{JSON.stringify(jsonLd)}</script>}
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="/styles/tokens.css" />
    <link rel="stylesheet" href="${home_css}" />
    <script type="module">
      if (document.getElementById('root')) {
        import('${home_js}');
      }
    </script>
  </head>
  <body class="theme-postal">
    <slot />
  </body>
</html>
ASTRO

mkdir -p public/styles
[ -f public/styles/tokens.css ] || cat > public/styles/tokens.css <<'CSS'
:root{--postal-navy:217 79% 24%;--postal-red:356 80% 52%;--postal-slate:215 16% 47%;--secondary:210 16% 96%;--border:214 32% 91%;--radius:12px;--shadow-card:0 2px 10px rgba(0,0,0,.06);--shadow-hero:0 10px 25px rgba(0,0,0,.15)}
.container{width:100%;margin:0 auto;padding:0 2rem}
@media (min-width:1400px){.container{max-width:1400px}}
.section-muted{padding:5rem 0;background:hsl(var(--secondary))}
.card{border:1px solid hsl(var(--border));background:#fff;border-radius:var(--radius);padding:1.5rem;box-shadow:var(--shadow-card)}
.trust-badge{display:inline-flex;align-items:center;gap:.5rem;border-radius:9999px;background:hsl(var(--secondary));padding:.5rem .75rem;font-size:.875rem;font-weight:500;color:hsl(var(--postal-slate))}
.btn-hero-primary{display:inline-flex;align-items:center;justify-content:center;gap:.5rem;border-radius:var(--radius);padding:1rem 2rem;font-weight:600;color:#fff;background-image:linear-gradient(to right,hsl(var(--postal-navy)),hsl(var(--postal-navy)));box-shadow:var(--shadow-hero);transition:all .2s}
.btn-hero-primary:hover{transform:scale(1.05)}
.btn-hero-secondary{display:inline-flex;align-items:center;justify-content:center;gap:.5rem;border-radius:var(--radius);padding:1rem 2rem;font-weight:600;color:hsl(var(--postal-navy));background:#fff;border:2px solid hsl(var(--postal-navy));transition:all .2s}
.btn-hero-secondary:hover{background:hsl(var(--postal-navy));color:#fff}
CSS

npm run build >/dev/null

pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done

echo "== titles =="
curl -s http://localhost:4321/services | rg -n '<title>.*</title>' -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -n '<title>.*</title>' -NI || true

echo "== head assets =="
curl -s http://localhost:4321/services | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|${home_css}|${home_js}' -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|${home_css}|${home_js}' -NI || true
