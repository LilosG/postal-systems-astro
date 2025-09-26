import { readFileSync, writeFileSync } from 'fs';

const files = readFileSync(0, 'utf8').split(/\r?\n/).filter(Boolean);

function pick(re, s) { const m = re.exec(s); return m ? m[1].trim() : ''; }
function collectJSONLD(s) {
  return Array.from(s.matchAll(/<script[^>]*type=["']application\/ld\+json["'][^>]*>[\s\S]*?<\/script>/gi))
              .map(x => x[0]).join('\n');
}
function extractBody(s) {
  const b = pick(/<body[^>]*>([\s\S]*?)<\/body>/i, s);
  if (b) return b;
  const afterHead = s.split(/<\/head>/i)[1] || s;
  return afterHead.replace(/<\/html>\s*$/i, '').trim();
}
function ensureFrontmatterWithImport(src) {
  if (src.startsWith('---')) {
    const end = src.indexOf('\n---', 3);
    if (end !== -1) {
      const fm = src.slice(0, end + 4);
      const rest = src.slice(end + 4);
      const hasImport = /import\s+Base\s+from\s+["'][^"']*Base\.astro["'];?/.test(fm);
      const newFm = hasImport ? fm.replace(/import\s+Base\s+from\s+["'][^"']*Base\.astro["'];?/g, 'import Base from "@/layouts/Base.astro";')
                              : fm.replace(/^---\s*\n?/, `---\nimport Base from "@/layouts/Base.astro";\n`);
      return newFm + rest;
    }
  }
  return `---\nimport Base from "@/layouts/Base.astro";\n---\n` + src;
}

for (const p of files) {
  let s = readFileSync(p, 'utf8');

  const hasBaseTag = /<Base\b/.test(s);
  const hasAnyImport = /import\s+Base\s+from\s+["'][^"']*Base\.astro["'];?/.test(s);

  if (hasBaseTag) {
    let out = s;
    if (hasAnyImport) {
      out = out.replace(/import\s+Base\s+from\s+["'][^"']*Base\.astro["'];?/g, 'import Base from "@/layouts/Base.astro";');
    } else {
      out = ensureFrontmatterWithImport(out);
    }
    writeFileSync(p, out, 'utf8');
    continue;
  }

  const title = pick(/<title>([\s\S]*?)<\/title>/i, s) ||
                pick(/<h1[^>]*>([\s\S]*?)<\/h1>/i, s) ||
                'San Diego Commercial Mailbox';

  const jsonld = collectJSONLD(s);
  let body = extractBody(s)
    .replace(/<!doctype html>/gi, '')
    .replace(/<html[^>]*>/gi, '')
    .replace(/<\/html>/gi, '')
    .replace(/<head>[\s\S]*?<\/head>/gi, '')
    .replace(/<link[^>]*rel=["']canonical["'][^>]*>\s*/gi, '')
    .trim();

  const headBlock = jsonld ? `\n  ${jsonld}\n` : '';

  const wrapped = `---
import Base from "@/layouts/Base.astro";
const title = ${JSON.stringify(title)};
---
<Base title={title}>
  <main class="mx-auto max-w-6xl px-6 py-12">
${headBlock}${body}
  </main>
</Base>
`;
  writeFileSync(p, wrapped, 'utf8');
}
