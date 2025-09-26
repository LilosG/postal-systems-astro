import { readFileSync, writeFileSync } from 'fs';

function relImportToBase(p) {
  const after = p.replace(/^src\/pages\//, '');
  const depth = after.split('/').length - 1;
  return '../'.repeat(depth) + 'layouts/Base.astro';
}
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
function processFile(p) {
  const src = readFileSync(p, 'utf8');
  if (src.includes('<Base ')) return;

  const title = pick(/<title>([\s\S]*?)<\/title>/i, src) ||
                pick(/<h1[^>]*>([\s\S]*?)<\/h1>/i, src) ||
                'San Diego Commercial Mailbox';
  const jsonld = collectJSONLD(src);

  let body = extractBody(src)
    .replace(/<!doctype html>/gi, '')
    .replace(/<html[^>]*>/gi, '')
    .replace(/<\/html>/gi, '')
    .replace(/<head>[\s\S]*?<\/head>/gi, '')
    .replace(/<link[^>]*rel=["']canonical["'][^>]*>\s*/gi, '')
    .trim();

  const importPath = relImportToBase(p);
  const headBlock = jsonld ? `\n  ${jsonld}\n` : '';

  const out = `---
import Base from "${importPath}";
const title = ${JSON.stringify(title)};
---
<Base title={title}>
  <main class="mx-auto max-w-6xl px-6 py-12">
${headBlock}${body}
  </main>
</Base>
`;
  writeFileSync(p, out, 'utf8');
}

const args = process.argv.slice(2);
if (args.length > 0) {
  for (const p of args) processFile(p);
} else {
  const data = readFileSync(0, 'utf8');
  const files = data.split(/\r?\n/).filter(Boolean);
  for (const p of files) processFile(p);
}
