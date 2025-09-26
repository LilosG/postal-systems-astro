#!/usr/bin/env bash
set -euo pipefail
echo "Pages missing <Base> wrapper:"
found=0
while IFS= read -r f; do
  if ! grep -q "<Base" "$f"; then
    echo "$f"
    found=1
  fi
done <<FILES
$(find src/pages -type f -name '*.astro' | sort)
FILES
exit $found
