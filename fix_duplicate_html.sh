#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob
for f in src/pages/services/*.astro; do
  [ -f "$f" ] || continue
  perl -0777 -i -pe '
    # Keep only the inner content between <Base ...> and </Base> if present
    if (m{(<Base\b[^>]*>)(.*?)(</Base>)}s) {
      my ($pre,$mid,$post)=($1,$2,$3);

      # Drop any full HTML documents still embedded
      $mid =~ s{<!DOCTYPE[^>]*>}{}igs;
      $mid =~ s{<head\b[^>]*>.*?</head>}{}igs;
      $mid =~ s{<html\b[^>]*>.*?</html>}{}igs;
      if ($mid =~ m{<body\b[^>]*>(.*?)</body>}is) { $mid = $1; }

      # Extra safety: remove any stray tags
      $mid =~ s{</?html\b[^>]*>}{}igs;
      $mid =~ s{</?body\b[^>]*>}{}igs;

      # Remove any nested Base wrappers
      while ($mid =~ s{<Base\b[^>]*>((?:(?!<Base\b).)*?)</Base>}{$1}igs) {}

      $_ = $pre . $mid . $post;
    }

    # Also handle files not wrapped yet: remove any full HTML doc in whole file body
    s{<!DOCTYPE[^>]*>}{}igs;
    s{<html\b[^>]*>.*?</html>}{}igs;

    # Ensure we import Base exactly once
    my $has_import = ($_ =~ m{^\s*import\s+Base\s+from\s+["\']\.\./\.\./layouts/Base\.astro["\'];?}m);
    unless ($has_import) {
      s/\A---\s*\n(.*?)\n---\s*\n/sprintf("---\n%s\nimport Base from \"..\/..\/layouts\/Base.astro\";\n---\n",$1)/es
        or $_ = "import Base from \"../../layouts/Base.astro\";\n---\n".$_;
    }

    # Ensure outer Base wrapper exists; if missing, wrap the whole content
    unless ($_ =~ m{<Base\b[^>]*>}s) {
      $_ = "---\nimport Base from \"../../layouts/Base.astro\";\n---\n<Base title=\"Postal Systems\">\n$_\n</Base>\n";
    }
  ' "$f"
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

echo "== title counts (should be 1 each) =="
curl -s http://localhost:4321/services            | rg -c '<title>.*</title>' -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -c '<title>.*</title>' -NI || true
