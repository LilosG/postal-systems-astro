set -euo pipefail

mkdir -p .backups/wrap
list=$(find src/pages -type f -name '*.astro' | sort)

for f in $list; do
  if grep -q "<Base" "$f"; then
    continue
  fi

  cp "$f" ".backups/wrap/$(basename "$f").bak"

  perl -0777 - "$f" > "$f.tmp" <<'PERL'
my $s = do { local $/; <> };

if ($s =~ /\A---\n(.*?)\n---\n(.*)\z/s) {
  my ($fm, $body) = ($1, $2);

  if ($fm !~ /import\s+Base\s+from\s+["']@\/layouts\/Base\.astro["']/s) {
    $fm = "import Base from \"@/layouts/Base.astro\";\n$fm";
  }

  if ($body !~ /<Base\b/s) {
    $body = "<Base>\n$body\n</Base>\n";
  }

  print "---\n$fm\n---\n$body";
} else {
  if ($s !~ /<Base\b/s) {
    print "---\nimport Base from \"@/layouts/Base.astro\";\n---\n<Base>\n$s\n</Base>\n";
  } else {
    print $s;
  }
}
PERL

  mv "$f.tmp" "$f"
done

rm -rf .astro dist
pnpm build

git add -A
git commit -m "wrap: ensure all pages use Base layout for site-wide theme" || true
git push origin main
