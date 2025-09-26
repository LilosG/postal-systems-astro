set -euo pipefail

echo "CHECK: Tailwind import path in Base.astro"
grep -nE 'import\s+"\.\./styles/tailwind\.css";' src/layouts/Base.astro || true
echo

echo "CHECK: Canonical logic in Base.astro"
grep -nE 'canonicalBase|Astro\.url|rel="canonical"' src/layouts/Base.astro || true
echo

echo "CHECK: Nav links in Base.astro"
grep -nE 'href="/services"|href="/industries"|href="/contact"|href="/#services"|href="/#industries"|href="/#contact"' src/layouts/Base.astro || true
echo

echo "CHECK: Pages not wrapping <Base> (list)"
tmpfile="$(mktemp)"
find src/pages -type f -name '*.astro' | sort > "$tmpfile"
while IFS= read -r f; do
  if ! grep -q "<Base" "$f"; then
    echo "$f"
  fi
done < "$tmpfile"
rm -f "$tmpfile"
echo

echo "CHECK: Local build"
rm -rf .astro dist
pnpm build
echo

echo "CHECK: Live canonical (services)"
for HOST in "https://sandiegocommercialmailbox.com" "https://postal-systems-astro.vercel.app"; do
  echo "$HOST"
  curl -s "$HOST/services" | grep -m1 -o '<link rel="canonical"[^>]*>' || true
done
echo

echo "CHECK: Live CSS presence (services)"
for HOST in "https://sandiegocommercialmailbox.com" "https://postal-systems-astro.vercel.app"; do
  echo "$HOST"
  css="$(curl -s "$HOST/services" | grep -o '/_astro/[^"]*\.css' | head -n1)"
  echo "$css"
  if [ -n "$css" ]; then
    curl -I "$HOST$css" | sed -n '1,1p'
  fi
done
