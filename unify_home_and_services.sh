#!/usr/bin/env bash
set -euo pipefail

pkill -f "astro preview" 2>/dev/null || true

# 1) Tailwind v3 config (CJS) so the warning goes away.
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

# 2) Ensure PostCSS config (still CJS)
cat > postcss.config.cjs <<'CFG'
module.exports = {
  plugins: { tailwindcss: {}, autoprefixer: {} },
};
CFG

# 3) Global CSS (tokens + Tailwind layers)
mkdir -p src/styles
cat > src/styles/app.css <<'CSS'
@import "./tokens.css";
@tailwind base;
@tailwind components;
@tailwind utilities;
CSS

# 4) Make sure LovableLayout imports the global CSS (single source of truth)
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

# 5) Convert homepage to use LovableLayout (move from index.html → index.astro)
#    We remove DOCTYPE/head/body and any hardcoded asset tags, keep the inner markup.
src_home="src/pages/index.html"
dst_home="src/pages/index.astro"
if [ -f "$src_home" ]; then
  body="$(perl -0777 -ne '
    $_ =~ s{<!DOCTYPE[^>]*>}{}igs;
    $_ =~ s{<head\b[^>]*>.*?</head>}{}igs;
    if (m{<body\b[^>]*>(.*?)</body>}is) { $_ = $1; }
    $_ =~ s{</?html\b[^>]*>}{}igs;
    $_ =~ s{</?body\b[^>]*>}{}igs;
    # strip any hardcoded /assets/ links/scripts
    $_ =~ s{<link[^>]+/assets/index-[^"]+\.css"[^>]*>\s*}{}igs;
    $_ =~ s{<script[^>]+/assets/index-[^"]+\.js"[^>]*>\s*</script>\s*}{}igs;
    print $_;
  ' "$src_home")"

  mkdir -p "$(dirname "$dst_home")"
  cat > "$dst_home" <<ASTRO
---
import LovableLayout from "../layouts/LovableLayout.astro";
---
<LovableLayout title="Postal Systems">
${body}
</LovableLayout>
ASTRO

  # Optionally keep a backup of the old HTML
  mv "$src_home" "${src_home}.bak"
fi

# 6) Ensure all Services pages already use LovableLayout (you ran this before, but idempotent check)
python3 - <<'PY'
import os, re, glob, html
def humanize(s): return " ".join(w[:1].upper()+w[1:] for w in s.replace("-", " ").split() if w)
for f in sorted(glob.glob("src/pages/services/*.astro")):
    with open(f,"r",encoding="utf-8") as fh: src = fh.read()
    if src.startswith("---"):
        m = re.search(r"^---\s*$(.*?)^---\s*$", src, flags=re.S|re.M)
        if m: body = src[m.end():]
        else: body = src
    else:
        body = src
    # already has LovableLayout?
    if re.search(r'^\s*import\s+LovableLayout\s+from\s+["\']\.\./\.\./layouts/LovableLayout\.astro["\'];?', src, flags=re.M):
        continue
    # drop other layouts if any
    body = re.sub(r'^\s*import\s+\w+\s+from\s+["\'][^"\']+["\'];?\s*', '', body, flags=re.M)
    for tag in ("Base","SiteLayout","LovableLayout","Layout"):
        body = re.sub(rf'<{tag}\b[^>]*>(.*?)</{tag}>', r'\1', body, flags=re.S|re.I)
    body = re.sub(r'<!DOCTYPE[^>]*>', '', body, flags=re.I)
    body = re.sub(r'<head\b[^>]*>.*?</head>', '', body, flags=re.S|re.I)
    b = re.search(r'<body\b[^>]*>(.*?)</body>', body, flags=re.S|re.I)
    if b: body = b.group(1)
    body = re.sub(r'</?\s*(?:html|body)\b[^>]*>', '', body, flags=re.I)

    if os.path.basename(f) == "index.astro":
        title = "Services | Postal Systems"
    else:
        h1 = re.search(r'<h1\b[^>]*>(.*?)</h1>', body, flags=re.S|re.I)
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
        f'{body.strip()}\n'
        '</LovableLayout>\n'
    )
    with open(f,"w",encoding="utf-8") as fh: fh.write(wrapped)
PY

# 7) Clean up any manual asset tags from the layout (just in case)
perl -0777 -i -pe 's{^\s*<link[^>]+/assets/index-[^"]+\.css"[^>]*>\s*\n}{}mg; s{^\s*<script[^>]+/assets/index-[^"]+\.js"[^>]*>\s*</script>\s*\n}{}mg' src/layouts/LovableLayout.astro

# 8) Clean build + preview + quick checks
rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.25; done

echo "== <title> counts (expect 1) =="
for p in '' services services/parcel-lockers; do
  path="/${p}"
  [ "$p" = '' ] && path='/'
  printf "%-28s -> " "$path"
  curl -s "http://localhost:4321${path}" | rg -c '<title>.*</title>' -NI || true
done

echo "== Tailwind tokens present? (look for --tw-) =="
printf "/ -> "; curl -s http://localhost:4321/ | rg -q -- '--tw-' && echo yes || echo no
printf "/services -> "; curl -s http://localhost:4321/services | rg -q -- '--tw-' && echo yes || echo no
