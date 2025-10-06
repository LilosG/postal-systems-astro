#!/usr/bin/env bash
set -euo pipefail

shopt -s nullglob
for f in src/pages/services/*.astro; do
  [ -f "$f" ] || continue
  perl -0777 -i -pe '
    if (m{(<Base\b[^>]*>)(.*?)(</Base>)}s) {
      my ($pre,$mid,$post)=($1,$2,$3);
      $mid =~ s{<!DOCTYPE[^>]*>}{}igs;
      $mid =~ s{<head\b[^>]*>.*?</head>}{}igs;
      if ($mid =~ m{<body\b[^>]*>(.*?)</body>}is) { $mid = $1; }
      $mid =~ s{</?html\b[^>]*>}{}igs;
      $mid =~ s{</?body\b[^>]*>}{}igs;
      $_ = $pre . $mid . $post;
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
curl -s http://localhost:4321/services            | rg -n '<title>.*</title>' -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -n '<title>.*</title>' -NI || true
echo "== head assets =="
curl -s http://localhost:4321/services            | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css' -NI || true
curl -s http://localhost:4321/services/parcel-lockers | rg -n 'fonts\.googleapis|fonts\.gstatic|/styles/tokens\.css' -NI || true
