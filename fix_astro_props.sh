#!/usr/bin/env bash
set -e

for f in src/pages/services/*.astro; do
  perl -0777 -i -pe '
    s/<Base\s+\{title\}\s+\{description\}\s+jsonLd=\{([^}]*)\}>/<Base title={title} description={description} jsonLd={$1}>/g;
    s/<Base\s+\{title\}\s+\{description\}\s*>/<Base title={title} description={description}>/g;
    s/<Base\s+\{title\}\s*>/<Base title={title}>/g;
    s/<Base\s+\{title\}\s+([^>]*?)>/<Base title={title} $1>/g;
  ' "$f"
done

npm run build
