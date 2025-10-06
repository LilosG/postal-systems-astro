#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

tail_after_frontmatter() {
  awk '
    BEGIN{c=0;emit=0}
    /^---[[:space:]]*$/ {c++; next}
    c>=2 {emit=1}
    emit {print}
  ' "$1"
}

extract_main_or_section() {
  awk '
    BEGIN{inm=0}
    /<main[[:space:]>]/ {inm=1; sub(/.*<main[^>]*>/,""); print; next}
    inm && /<\/main>/ {sub(/<\/main>.*/,""); print; exit}
    inm {print}
  ' | awk '
    BEGIN{print_it=0}
    NR==1 && length($0)==0 {next}
    {body=body $0 ORS}
    END {
      if (length(body)>0) {
        print body
      } else {
        exit 1
      }
    }
  ' 2>/dev/null || awk '
    BEGIN{ins=0}
    /<section[[:space:]>]/ && ins==0 {ins=1}
    ins {print}
  '
}

clean_wraps() {
  perl -0777 -pe '
    s{<!DOCTYPE[^>]*>}{}gi;
    s{</?\s*html[^>]*>}{}gi;
    s{</?\s*head[^>]*>}{}gi;
    s{</?\s*body[^>]*>}{}gi;
    s{</?\s*SiteLayout[^>]*>}{}gi;
    s{</?\s*LovableLayout[^>]*>}{}gi;
    s{</?\s*Layout[^>]*>}{}gi;
    s{</?\s*Base[^>]*>}{}gi;
  '
}

mkdir -p src/pages/services/_orig
for f in src/pages/services/*.astro; do
  bn="$(basename "$f")"
  [ -f "src/pages/services/_orig/$bn" ] || cp "$f" "src/pages/services/_orig/$bn"

  body="$(tail_after_frontmatter "$f" | extract_main_or_section | clean_wraps)"
  body_trimmed="$(printf '%s' "$body" | awk 'BEGIN{s=0}/[^[:space:]]/{s=1} s{print}')"
  if [ -z "${body_trimmed}" ]; then
    body="$(tail_after_frontmatter "$f" | clean_wraps)"
  fi

  tmp="$(mktemp)"
  cat > "$tmp" <<'ASTRO'
---
import SiteLayout from '../../layouts/SiteLayout.astro';
const pageTitle = "Postal Systems";
---
<SiteLayout>
ASTRO
  printf '%s\n' "$body" >> "$tmp"
  printf '%s\n' "</SiteLayout>" >> "$tmp"
  mv "$tmp" "$f"
done

rm -rf dist .astro node_modules/.vite
npm run build
