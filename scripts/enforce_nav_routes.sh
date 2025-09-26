set -euo pipefail
TS=$(date +%Y%m%d%H%M%S)
mkdir -p .backups/layouts
[ -f src/layouts/Base.astro ] && cp src/layouts/Base.astro ".backups/layouts/Base.astro.$TS.bak"
perl -0777 -pe 's/href=["'\'']\/?#services["'\'']/href="\/services"/gi; s/href=["'\'']\/?#industries["'\'']/href="\/industries"/gi; s/href=["'\'']\/?#contact["'\'']/href="\/contact"/gi' -i src/layouts/Base.astro
pnpm build
git add -A
git commit -m "nav: enforce real routes over section anchors" || true
git push origin main
