#!/usr/bin/env bash
set -euo pipefail

# 1) Ensure deps (safe to re-run). Comment these out if you already have Tailwind.
npm pkg get devDependencies.tailwindcss >/dev/null 2>&1 || npm i -D tailwindcss postcss autoprefixer >/dev/null
# If config files don’t exist, create them fresh.
[ -f tailwind.config.mjs ] || npx tailwindcss init -p >/dev/null

# 2) Replace Tailwind/PostCSS configs with safe, project-wide settings
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

cat > postcss.config.cjs <<'CFG'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
CFG

# 3) Global styles: tokens + Tailwind
mkdir -p src/styles
cat > src/styles/tokens.css <<'CSS'
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

cat > src/styles/app.css <<'CSS'
@import "./tokens.css";
@tailwind base;
@tailwind components;
@tailwind utilities;
CSS

# 4) Make the layout import the global stylesheet (single source of truth)
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

# 5) Ensure all Services pages use LovableLayout (idempotent)
python3 - <<'PY'
import os, re, glob, html
def humanize(s): return " ".join(w[:1].upper()+w[1:] for w in s.replace("-", " ").split() if w)
for f in sorted(glob.glob("src/pages/services/*.astro")):
    with open(f,"r",encoding="utf-8") as fh: src = fh.read()
    # strip frontmatter to keep only body
    if src.startswith("---"):
        m = re.search(r"^---\s*$(.*?)^---\s*$", src, flags=re.S|re.M)
        if m: src = src[m.end():]
    # drop old layout imports/wrappers/doctypes/heads/bodies
    src = re.sub(r'^\s*import\s+\w+\s+from\s+["\'][^"\']+["\'];?\s*', '', src, flags=re.M)
    for tag in ("Base","SiteLayout","LovableLayout","Layout"): src = re.sub(rf'<{tag}\b[^>]*>(.*?)</{tag}>', r'\1', src, flags=re.S|re.I)
    src = re.sub(r'<!DOCTYPE[^>]*>', '', src, flags=re.I)
    src = re.sub(r'<head\b[^>]*>.*?</head>', '', src, flags=re.S|re.I)
    b = re.search(r'<body\b[^>]*>(.*?)</body>', src, flags=re.S|re.I)
    if b: src = b.group(1)
    src = re.sub(r'</?\s*(?:html|body)\b[^>]*>', '', src, flags=re.I)
    # title
    if os.path.basename(f) == "index.astro":
        title = "Services | Postal Systems"
    else:
        h1 = re.search(r'<h1\b[^>]*>(.*?)</h1>', src, flags=re.S|re.I)
        if h1:
            t = re.sub(r'<[^>]+>', '', h1.group(1))
            title = html.unescape(t).strip() or humanize(os.path.splitext(os.path.basename(f))[0])
        else:
            title = humanize(os.path.splitext(os.path.basename(f))[0])
    wrapped = (
        '---\n'
        'import LovableLayout from "../../layouts/LovableLayout.astro";\n'
        '---\n'
        f'<LovableLayout title="{title}">\n'
        f'{src.strip()}\n'
        '</LovableLayout>\n'
    )
    with open(f,"w",encoding="utf-8") as fh: fh.write(wrapped)
PY

# 6) Clean build
rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

# 7) Preview and quick checks
pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.25; done

echo "== <title> count (should be 1) =="
for p in services services/parcel-lockers; do
  printf "/%s -> " "$p"
  curl -s "http://localhost:4321/$p" | rg -c '<title>.*</title>' -NI || true
done

echo "== Tailwind present on services? (look for --tw- tokens) =="
curl -s http://localhost:4321/services | rg -n -- '--tw-' -NI || echo "No --tw- tokens found"
