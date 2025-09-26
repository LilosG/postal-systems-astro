import { readFileSync, writeFileSync } from 'fs';

function pick(rx,s){const m=rx.exec(s);return m?m[1].trim():''}
function jsonlds(s){return Array.from(s.matchAll(/<script[^>]*type=["']application\/ld\+json["'][^>]*>[\s\S]*?<\/script>/gi)).map(m=>m[0]).join('\n')}
function bodyOf(s){
  const b=pick(/<body[^>]*>([\s\S]*?)<\/body>/i,s);
  if(b) return b;
  const afterHead=s.split(/<\/head>/i)[1]||s;
  return afterHead.replace(/<\/html>\s*$/i,'').trim();
}
function ensureAliasImport(s){
  if(s.startsWith('---')){
    const end=s.indexOf('\n---',3);
    if(end!==-1){
      let fm=s.slice(0,end+4);
      const rest=s.slice(end+4);
      fm=fm.replace(/import\s+Base\s+from\s+["'][^"']*Base\.astro["'];?/g,'');
      if(!/import\s+Base\s+from\s+["'][^"']*Base\.astro/.test(fm)) fm=fm.replace(/^---\s*\n?/,'---\nimport Base from "@/layouts/Base.astro";\n');
      return fm+rest;
    }
  }
  return `---\nimport Base from "@/layouts/Base.astro";\n---\n`+s;
}

const files = readFileSync(0,'utf8').split(/\r?\n/).filter(Boolean);
for (const f of files){
  let s = readFileSync(f,'utf8');

  s=s.replace(/import\s+Base\s+from\s+["'](?:\.\.\/)+layouts\/Base\.astro["'];?/g,'import Base from "@/layouts/Base.astro";');
  s=s.replace(/<link[^>]*rel=["']canonical["'][^>]*>\s*/gi,'');
  if (/(<!doctype html|<html\b|<head\b)/i.test(s) || !/<Base\b/.test(s)){
    const title=pick(/<title>([\s\S]*?)<\/title>/i,s)||pick(/<h1[^>]*>([\s\S]*?)<\/h1>/i,s)||'San Diego Commercial Mailbox';
    const j=jsonlds(s);
    let b=bodyOf(s).replace(/<!doctype html>/gi,'').replace(/<html[^>]*>/gi,'').replace(/<\/html>/gi,'').replace(/<head>[\s\S]*?<\/head>/gi,'').trim();
    const head=j?`\n  ${j}\n`:'';
    s=`---
import Base from "@/layouts/Base.astro";
const title = ${JSON.stringify(title)};
---
<Base title={title}>
  <main class="mx-auto max-w-6xl px-6 py-12">
${head}${b}
  </main>
</Base>
`;
  }else{
    if(!/import\s+Base\s+from\s+["'][^"']*Base\.astro/.test(s)) s=ensureAliasImport(s);
  }
  writeFileSync(f,s,'utf8');
}
