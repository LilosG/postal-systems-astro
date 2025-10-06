#!/usr/bin/env bash
set -e

for f in src/pages/services/*.astro; do
  [ -f "$f" ] || continue
  sed -E -i '' '/^[[:space:]]*import[[:space:]]+SiteLayout[[:space:]]+from[[:space:]]+"[^"]+";?[[:space:]]*$/d' "$f"
  sed -E -i '' "/^[[:space:]]*import[[:space:]]+SiteLayout[[:space:]]+from[[:space:]]+'[^']+';?[[:space:]]*$/d" "$f"
  sed -E -i '' 's/^[[:space:]]*<SiteLayout>[[:space:]]*$//g' "$f"
  sed -E -i '' 's/^[[:space:]]*<\/SiteLayout>[[:space:]]*$//g' "$f"
  sed -E -i '' 's/<SiteLayout>[[:space:]]*//g; s/[[:space:]]*<\/SiteLayout>//g' "$f"
done

npm run build
