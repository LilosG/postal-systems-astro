set -euo pipefail
ROOT="$(pwd)"
TS="$(date +%Y%m%d-%H%M%S)"
REPORT="/tmp/theme_audit_$TS.txt"
mkdir -p /tmp
: > "$REPORT"
has() { command -v "$1" >/dev/null 2>&1; }
warn() { printf "\n[WARN] %s\n" "$*" | tee -a "$REPORT"; }
info() { printf "\n[INFO] %s\n" "$*" | tee -a "$REPORT"; }
ok()   { printf "\n[OK] %s\n" "$*"   | tee -a "$REPORT"; }
info "Checking tools"
need=(node npm)
for b in "${need[@]}"; do has "$b" || { warn "$b not found"; exit 1; }; done
RG=grep; has rg && RG=rg
info "Astro / Tailwind wiring"
[ -f astro.config.mjs ] || warn "astro.config.mjs missing"
if [ ! -f tailwind.config.js ] && [ ! -f tailwind.config.cjs ] && [ ! -f tailwind.config.mjs ]; then warn "Tailwind config missing"; else ok "Tailwind config present"; fi
$RG -n "import\\s+\\\".*tailwind\\.css\\\"" src/layouts/* 2>/dev/null | tee -a "$REPORT" || true
$RG -n "@tailwind\\s+(base|components|utilities)" src/styles/tailwind.css 2>/dev/null | tee -a "$REPORT" || true
info "Running quick build (captures first error only)"
if npm run -s build >/tmp/astro_build_$TS.log 2>&1; then ok "Build succeeded"; else warn "Build failed. Showing last 50 lines:"; tail -n 50 /tmp/astro_build_$TS.log | tee -a "$REPORT"; fi
info "Parsing Tailwind tokens"
TWCFG="$(ls tailwind.config.* 2>/dev/null | head -n1 || true)"
if [ -n "$TWCFG" ]; then
  COLORS=$($RG -No '(#(?:[0-9a-fA-F]{3}){1,2})' "$TWCFG" | sort -u || true)
  FONTS=$($RG -No "fontFamily:\\s*\\{[^}]*\\}" "$TWCFG" | sed 's/.*{//;s/}.*//' || true)
  printf "\nTailwind colors in config:\n%s\n" "${COLORS:-<none>}" | tee -a "$REPORT"
  printf "\nTailwind font families:\n%s\n" "${FONTS:-<none>}" | tee -a "$REPORT"
else
  warn "No tailwind.config.* found"
fi
info "Scanning source + public for hardcoded colors & fonts"
$RG -n "(#(?:[0-9a-fA-F]{3}){1,2})" src public | tee /tmp/hardcoded_colors_$TS.txt || true
$RG -n "font-family\\s*:\\s*[^;]+" src public | tee /tmp/hardcoded_fonts_$TS.txt || true
info "Inline styles (style=\\\"...\\\")"
$RG -n 'style="' src | tee /tmp/inline_styles_$TS.txt || true
info "Files missing Base.astro usage"
$RG -l --glob '!**/Base.astro' 'Base.astro' src/pages src/components >/tmp/has_base_$TS.txt 2>/dev/null || true
$RG -L -l --glob 'src/pages/**/*.astro' -e 'import\\s+.*Base\\.astro' -n | sed 's/:.*//' | sort -u >/tmp/pages_with_base_$TS.txt || true
ALL_PAGES=$(find src/pages -name "*.astro" 2>/dev/null | sort || true)
MISSING=()
while IFS= read -r p; do $RG -q 'import\\s+.*Base\\.astro' "$p" || MISSING+=("$p"); done <<< "$ALL_PAGES"
printf "%s\n" "${MISSING[@]:-}" | tee /tmp/pages_missing_base_$TS.txt >/dev/null
info "Data files and potential routes"
for f in src/content/data/services.json src/content/data/cities.json src/content/data/settings.json; do if [ -f "$f" ]; then ok "$f present"; else warn "$f missing"; fi; done
if [ -f src/content/data/services.json ] && [ -f src/content/data/cities.json ]; then SCOUNT=$(wc -c < src/content/data/services.json 2>/dev/null || echo 0); CCOUNT=$(wc -c < src/content/data/cities.json 2>/dev/null || echo 0); info "services.json bytes: $SCOUNT ; cities.json bytes: $CCOUNT"; fi
info "=== THEME DRIFT SUMMARY ===" | tee -a "$REPORT"
COL_USED=$(cut -d: -f3 /tmp/hardcoded_colors_$TS.txt 2>/dev/null | sort -u || true)
printf "\nHardcoded colors found (unique):\n%s\n" "${COL_USED:-<none>}" | tee -a "$REPORT"
printf "\nSample files with inline styles:\n" | tee -a "$REPORT"
head -n 20 /tmp/inline_styles_$TS.txt 2>/dev/null | tee -a "$REPORT" || true
printf "\nPages missing Base layout:\n" | tee -a "$REPORT"
printf "%s\n" "${MISSING[@]:-<none>}" | tee -a "$REPORT"
printf "\nSuggested next steps are printed below.\n" | tee -a "$REPORT"
echo -e "\nReport saved at: $REPORT"
