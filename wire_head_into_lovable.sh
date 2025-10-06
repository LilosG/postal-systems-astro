#!/usr/bin/env bash
set -euo pipefail

npm run build >/dev/null

home_css="$(rg -No '/assets/index-[^"]+\.css' dist/index.html | head -n1 || true)"
home_js="$(rg -No '/assets/index-[^"]+\.js' dist/index.html | head -n1 || true)"

[ -z "${home_css}" ] && { echo "Could not find homepage CSS in dist/index.html"; exit 1; }
[ -z "${home_js}" ] && { echo "Could not find homepage JS in dist/index.html"; exit 1; }

lf="src/layouts/LovableLayout.astro"
[ -f "$lf" ] || { echo "Missing $lf"; exit 1; }
cp -n "$lf" "${lf}.bak"

need_fonts="$(rg -n 'fonts\.googleapis|fonts\.gstatic' "$lf" || true)"
need_tokens="$(rg -n '/styles/tokens\.css' "$lf" || true)"
need_css="$(rg -n "$home_css" "$lf" || true)"
need_js_guard="$(rg -n "$home_js" "$lf" || true)"

tmp="$(mktemp)"
awk -v css="$home_css" -v js="$home_js" -v add_fonts="$([ -z "$need_fonts" ] && echo 1 || echo 0)" \
    -v add_tokens="$([ -z "$need_tokens" ] && echo 1 || echo 0)" \
    -v add_css="$([ -z "$need_css" ] && echo 1 || echo 0)" \
    -v add_js="$([ -z "$need_js_guard" ] && echo 1 || echo 0)" '
  BEGIN{inserted=0}
  /<\/head>/ && !inserted {
    if(add_fonts=="1"){
      print "    <link rel=\"preconnect\" href=\"https://fonts.googleapis.com\" />";
      print "    <link rel=\"preconnect\" href=\"https://fonts.gstatic.com\" crossorigin />";
      print "    <link href=\"https://fonts.googleapis.com/css2?family=Poppins:wght@600;700;800&family=Inter:wght@400;500;600&display=swap\" rel=\"stylesheet\" />";
    }
    if(add_tokens=="1"){
      print "    <link rel=\"stylesheet\" href=\"/styles/tokens.css\" />";
    }
    if(add_css=="1"){
      print "    <link rel=\"stylesheet\" href=\"" css "\" />";
    }
    if(add_js=="1"){
      print "    <script type=\"module\">";
      print "      if (document.getElementById(\"root\")) {";
      print "        import(\"" js "\");";
      print "      }";
      print "    </script>";
    }
    inserted=1
  }
  {print}
' "$lf" > "$tmp"
mv "$tmp" "$lf"

mkdir -p public/styles
[ -f public/styles/tokens.css ] || cat > public/styles/tokens.css <<'CSS'
:root{
  --postal-navy: 217 79% 24%;
  --postal-red: 356 80% 52%;
  --postal-slate: 215 16% 47%;
  --secondary: 210 16% 96%;
  --border: 214 32% 91%;
  --radius: 12px;
  --shadow-card: 0 2px 10px rgba(0,0,0,.06);
  --shadow-hero: 0 10px 25px rgba(0,0,0,.15)
}
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

echo "== /services =="
curl -s http://localhost:4321/services | rg -n "fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|$home_css|$home_js" -NI || true
echo "== /services/parcel-lockers =="
curl -s http://localhost:4321/services/parcel-lockers | rg -n "fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css|$home_css|$home_js" -NI || true
