#!/usr/bin/env bash
set -euo pipefail

BASE="src/layouts/Base.astro"
mkdir -p "$(dirname "$BASE")"
cat > "$BASE" <<'ASTRO'
---
type Json = Record<string, any>;
interface Props { title?: string; description?: string; jsonLd?: Json; }
const { title = "Postal Systems", description = "", jsonLd } = Astro.props as Props;
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
    <link rel="stylesheet" href="/styles/tokens.css" />
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

shopt -s nullglob
for f in src/pages/services/*.astro; do
  [ -f "$f" ] || continue

  fm="$(awk 'NR==1&&$0=="---"{fm=1;next} fm&&$0=="---"{fm=0;exit} fm{print}' "$f")"
  body="$(awk 'NR==1&&$0=="---"{fm=1;next} fm&&$0=="---"{fm=0;next} !fm{print}' "$f")"

  body="$(perl -0777 -pe '
    s{<!DOCTYPE[^>]*>}{}igs;
    s{<head\b[^>]*>.*?</head>}{}igs;
    if (m{<body\b[^>]*>(.*?)</body>}is) { $_ = $1 }
    s{</?html\b[^>]*>}{}igs;
    s{</?body\b[^>]*>}{}igs;
  ' <<<"$body")"

  h1_text="$(printf '%s\n' "$body" | sed -n 's/.*<h1[^>]*>\(.*\)<\/h1>.*/\1/p' | sed 's/<[^>]*>//g' | head -n1)"
  base="$(basename "$f")"
  if [ "$base" = "index.astro" ]; then
    title_txt="Services | Postal Systems"
  elif [ -n "${h1_text//[[:space:]]/}" ]; then
    title_txt="$(printf '%s' "$h1_text" | sed 's/^[[:space:]]\+//;s/[[:space:]]\+$//')"
  else
    name="$(basename "$f" .astro | tr '-' ' ')"
    title_txt="$(printf '%s\n' "$name" | awk '{for(i=1;i<=NF;i++){ $i=toupper(substr($i,1,1)) substr($i,2)}; print}')"
  fi

  case "$fm" in
    *'import Base from '*) : ;;
    *) fm="$(printf '%s\nimport Base from \"../../layouts/Base.astro\";' "$fm")" ;;
  esac

  if ! printf '%s' "$body" | rg -q '<Base[^>]*>'; then
    body="<Base title=\"${title_txt}\">
${body}
</Base>"
  else
    if ! printf '%s' "$body" | rg -q '<Base[^>]*\btitle='; then
      body="$(perl -0777 -pe '
        s{<Base\b(?![^>]*\btitle=)}{<Base title="REPLACEME" }s;
      ' <<<"$body")"
      body="${body//REPLACEME/${title_txt}}"
    fi
  fi

  tmp="$(mktemp)"
  {
    echo '---'
    [ -n "${fm//[[:space:]]/}" ] && printf '%s\n' "$fm"
    echo '---'
    printf '%s\n' "$body"
  } > "$tmp"
  mv "$tmp" "$f"
done

rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done

echo "== titles =="
curl -s http://localhost:4321/services | rg -n '<title>.*</title>' -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -n '<title>.*</title>' -NI || true
echo "== head assets =="
curl -s http://localhost:4321/services | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css' -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css' -NI || true
