#!/usr/bin/env bash
set -euo pipefail

mkdir -p public/styles src/layouts

cat > public/styles/tokens.css <<'CSS'
:root{--background:0 0% 100%;--foreground:215 25% 27%;--card:0 0% 100%;--card-foreground:215 25% 27%;--popover:0 0% 100%;--popover-foreground:215 25% 27%;--primary:215 85% 31%;--primary-foreground:0 0% 100%;--secondary:210 40% 97%;--secondary-foreground:215 25% 27%;--muted:210 40% 97%;--muted-foreground:215 16% 47%;--accent:351 78% 52%;--accent-foreground:0 0% 100%;--destructive:0 84.2% 60.2%;--destructive-foreground:0 0% 100%;--border:214.3 31.8% 91.4%;--input:214.3 31.8% 91.4%;--ring:215 85% 31%;--radius:.75rem;--postal-navy:215 85% 31%;--postal-red:351 78% 52%;--postal-slate:215 25% 27%;--postal-light:210 40% 97%;--gradient-primary:linear-gradient(135deg,hsl(215 85% 31%),hsl(215 85% 41%));--gradient-accent:linear-gradient(135deg,hsl(351 78% 52%),hsl(351 78% 62%));--gradient-hero:linear-gradient(180deg,#fff,hsl(210 40% 97%));--shadow-soft:0 1px 3px 0 rgb(0 0 0 / .1),0 1px 2px -1px rgb(0 0 0 / .1);--shadow-card:0 4px 6px -1px rgb(0 0 0 / .1),0 2px 4px -2px rgb(0 0 0 / .1);--shadow-hero:0 20px 25px -5px rgb(0 0 0 / .1),0 8px 10px -6px rgb(0 0 0 / .1)}
.theme-postal{background-color:hsl(var(--background));color:hsl(var(--foreground));font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,"Helvetica Neue",Arial,"Noto Sans","Apple Color Emoji","Segoe UI Emoji","Segoe UI Symbol","Noto Color Emoji",sans-serif}
.theme-postal h1,.theme-postal h2,.theme-postal h3,.theme-postal h4,.theme-postal h5,.theme-postal h6{font-family:Poppins,system-ui,-apple-system,Segoe UI,Roboto,"Helvetica Neue",Arial,sans-serif;font-weight:700;line-height:1.25}
.container{width:100%;margin:0 auto;padding:0 2rem}
@media (min-width:1400px){.container{max-width:1400px}}
.section{padding:5rem 0;background:#fff}
.section-muted{padding:5rem 0;background:hsl(var(--secondary))}
.card{border:1px solid hsl(var(--border));background:#fff;border-radius:var(--radius);padding:1.5rem;box-shadow:var(--shadow-card)}
.chip,.trust-badge,.badge{display:inline-flex;align-items:center;gap:.5rem;border-radius:9999px;background:hsl(var(--postal-light));padding:.5rem .75rem;font-size:.875rem;font-weight:500;color:hsl(var(--postal-slate));line-height:1.25rem}
.btn-hero-primary{display:inline-flex;align-items:center;justify-content:center;gap:.5rem;border-radius:var(--radius);padding:1rem 2rem;font-weight:600;color:#fff;background-image:linear-gradient(to right,hsl(var(--postal-navy)),hsl(var(--postal-navy)));box-shadow:var(--shadow-hero);transition:all .2s}
.btn-hero-primary:hover{transform:scale(1.05);box-shadow:0 10px 15px -3px rgb(0 0 0 / .1),0 4px 6px -4px rgb(0 0 0 / .1)}
.btn-hero-secondary{display:inline-flex;align-items:center;justify-content:center;gap:.5rem;border-radius:var(--radius);padding:1rem 2rem;font-weight:600;color:hsl(var(--postal-navy));background:#fff;border:2px solid hsl(var(--postal-navy));transition:all .2s}
.btn-hero-secondary:hover{background:hsl(var(--postal-navy));color:#fff}
.grid-3{display:grid;gap:1.5rem}
@media (min-width:768px){.grid-3{grid-template-columns:repeat(2,minmax(0,1fr))}}
@media (min-width:1024px){.grid-3{grid-template-columns:repeat(3,minmax(0,1fr))}}
.eyebrow{font-size:.875rem;letter-spacing:.1em;text-transform:uppercase;color:hsl(var(--muted-foreground));margin-bottom:.5rem}
.text-navy{color:hsl(var(--postal-navy))}.text-red{color:hsl(var(--postal-red))}.text-slate{color:hsl(var(--postal-slate))}.bg-muted{background:hsl(var(--secondary))}
CSS

cat > src/layouts/LovableLayout.astro <<'ASTRO'
---
interface Props { title?: string; description?: string; bodyClass?: string; }
const { title = 'Postal Systems', description = '', bodyClass = '' } = Astro.props;
const HOME_CSS = '/assets/index-N3m_CGat.css';
const HOME_JS  = '/assets/index-RJ4U58x-.js';
---
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    {title && <title>{title}</title>}
    {description && <meta name="description" content={description} />}
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="/styles/tokens.css" />
    <link rel="stylesheet" href={HOME_CSS} />
    <script type="module" is:inline>
      if (document.getElementById('root')) { import(/** @vite-ignore */ HOME_JS); }
    </script>
  </head>
  <body class={`theme-postal ${bodyClass}`.trim()}>
    <slot />
  </body>
</html>
ASTRO

wrap_page () {
  f="$1"
  [[ -f "$f" ]] || return 0
  if rg -q "from ['\"]/\\.\\.\\/layouts\\/LovableLayout\\.astro['\"]" "$f"; then
    return 0
  fi
  cp -n "$f" "$f.bak" || true
  if head -n1 "$f" | rg -q '^---$'; then
    awk 'BEGIN{done=0} /^---$/ && NR>1 && done==0 { print "import Layout from \"../../layouts/LovableLayout.astro\""; done=1 } { print }' "$f" > "$f.tmp1"
    awk 'BEGIN{inFM=0; injected=0} NR==1 && $0 ~ /^---$/ { inFM=1 } inFM && $0 ~ /^---$/ && NR>1 { inFM=0; print; next } !inFM && injected==0 { print "<Layout>"; injected=1 } { print } END{ if(injected==1) print "</Layout>" }' "$f.tmp1" > "$f"
    rm -f "$f.tmp1"
  else
    { echo "---"; echo "import Layout from \"../../layouts/LovableLayout.astro\""; echo "---"; echo "<Layout>"; cat "$f"; echo "</Layout>"; } > "$f.tmp"
    mv "$f.tmp" "$f"
  fi
}

shopt -s nullglob
for f in src/pages/services/*.astro; do
  wrap_page "$f"
done

rm -rf dist .astro node_modules/.vite
npm run build
npm run preview & PREVIEW_PID=$!
sleep 1

curl -s http://localhost:4321/services | rg -n '/fonts|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true

if [ -f src/pages/services/parcel-lockers.astro ]; then
  curl -s http://localhost:4321/services/parcel-lockers | rg -n '/fonts|fonts\.gstatic|/styles/tokens\.css|/assets/index-.*\.(css|js)' -NI || true
fi

kill $PREVIEW_PID 2>/dev/null || true
wait $PREVIEW_PID 2>/dev/null || true
