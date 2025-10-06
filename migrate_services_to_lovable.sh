#!/usr/bin/env bash
set -euo pipefail

[ -f src/layouts/LovableLayout.astro ] || { echo "Missing src/layouts/LovableLayout.astro"; exit 1; }

python3 - <<'PY'
import os, re, glob, html

def humanize(name: str) -> str:
    name = name.replace("-", " ").strip()
    return " ".join(w[:1].upper()+w[1:] for w in name.split() if w)

files = sorted(glob.glob("src/pages/services/*.astro"))
for f in files:
    with open(f,"r",encoding="utf-8") as fh:
        src = fh.read()

    fm = ""
    body = src
    if src.startswith("---"):
        m = re.search(r"^---\s*$(.*?)^---\s*$", src, flags=re.S|re.M)
        if m:
            fm = m.group(1)
            body = src[m.end():]

    body = re.sub(r'^\s*import\s+(?:Base|SiteLayout|LovableLayout|Layout)\s+from\s+["\'][^"\']+["\'];?\s*', '', body, flags=re.M)
    for tag in ("Base","SiteLayout","LovableLayout","Layout"):
        body = re.sub(rf'<{tag}\b[^>]*>(.*?)</{tag}>', r'\1', body, flags=re.S|re.I)
    body = re.sub(r'<!DOCTYPE[^>]*>', '', body, flags=re.I)
    body = re.sub(r'<head\b[^>]*>.*?</head>', '', body, flags=re.S|re.I)
    mbody = re.search(r'<body\b[^>]*>(.*?)</body>', body, flags=re.S|re.I)
    if mbody: body = mbody.group(1)
    body = re.sub(r'</?\s*html\b[^>]*>', '', body, flags=re.I)
    body = re.sub(r'</?\s*body\b[^>]*>', '', body, flags=re.I)

    if os.path.basename(f) == "index.astro":
        title = "Services | Postal Systems"
    else:
        h1 = re.search(r'<h1\b[^>]*>(.*?)</h1>', body, flags=re.S|re.I)
        if h1:
            title = html.unescape(re.sub(r'<[^>]+>','',h1.group(1))).strip() or humanize(os.path.splitext(os.path.basename(f))[0])
        else:
            title = humanize(os.path.splitext(os.path.basename(f))[0])

    frontmatter = '---\nimport LovableLayout from "../../layouts/LovableLayout.astro";\n---\n'
    wrapped = frontmatter + f'<LovableLayout title="{title}">\n{body.strip()}\n</LovableLayout>\n'

    with open(f,"w",encoding="utf-8") as fh:
        fh.write(wrapped)
PY

rm -rf dist .astro node_modules/.vite
npm run build >/dev/null

pkill -f "astro preview" 2>/dev/null || true
npm run preview >/dev/null & PREVIEW_PID=$!
trap 'kill $PREVIEW_PID 2>/dev/null || true' EXIT
for i in {1..60}; do curl -sf http://localhost:4321/ >/dev/null && break; sleep 0.2; done

for p in services services/4c-mailboxes services/cluster-box-units services/maintenance services/parcel-lockers services/pedestal-wall-mounted services/repairs-lock-changes; do
  printf "%-35s -> " "/$p"
  curl -s "http://localhost:4321/$p" | rg -c '<title>.*</title>' -NI
done
