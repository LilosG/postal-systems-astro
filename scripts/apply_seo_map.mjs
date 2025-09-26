import { readFileSync, writeFileSync, readdirSync, statSync } from 'fs';
import { join, relative, extname, basename } from 'path';

const ROOT = 'src/pages';
const SEO = JSON.parse(readFileSync('src/seo.json','utf8'));

function walk(dir){
  const out=[];
  for (const name of readdirSync(dir)) {
    const p=join(dir,name);
    const st=statSync(p);
    if (st.isDirectory()) out.push(...walk(p));
    else if (st.isFile() && extname(p)==='.astro') out.push(p);
  }
  return out;
}
function toRoute(p){
  let rel = relative(ROOT, p).replace(/\\/g,'/');
  if (rel === 'index.astro') return '/';
  if (rel.endsWith('/index.astro')) rel = rel.slice(0, -'index.astro'.length);
  else rel = rel.slice(0, -'.astro'.length);
  if (!rel.startsWith('/')) rel = '/'+rel;
  if (!rel.endsWith('/')) rel = rel + '/';
  return rel;
}

function ensureFrontmatter(src) {
  if (src.startsWith('---')) return src;
  return `---\nimport Base from "@/layouts/Base.astro";\n---\n` + src;
}

function setBaseTitle(html, title){
  // replace or insert title="…"
  if (/<Base\b[^>]*\btitle=/.test(html)) {
    return html.replace(/(<Base\b[^>]*\btitle=)["'][^"']*["']/, `$1"${title}"`);
  }
  return html.replace(/<Base\b/, `<Base title="${title}"`);
}

function upsertMetaDescription(html, description){
  const fragOpen = `<Fragment slot="head">`;
  const meta = `<meta name="description" content="${description}" />`;
  if (/<Fragment\s+slot=["']head["'][^>]*>[\s\S]*?<\/Fragment>/.test(html)) {
    // Replace existing description or append inside head fragment
    if (/<meta[^>]*name=["']description["'][^>]*>/.test(html)) {
      return html.replace(/<meta[^>]*name=["']description"[^>]*>/, meta);
    } else {
      return html.replace(/<Fragment\s+slot=["']head["'][^>]*>/, `${fragOpen}\n    ${meta}`);
    }
  }
  // Insert head fragment just after opening <Base ...>
  return html.replace(/<Base\b[^>]*>/, m => `${m}\n  ${fragOpen}\n    ${meta}\n  </Fragment>`);
}

const files = walk(ROOT).filter(p => basename(p) !== 'index.html');

for (const f of files) {
  const route = toRoute(f);
  const entry = SEO[route];
  if (!entry) continue;
  let src = readFileSync(f,'utf8');

  src = ensureFrontmatter(src);
  src = setBaseTitle(src, entry.title);
  src = upsertMetaDescription(src, entry.description);

  // Remove any page-level canonical tags
  src = src.replace(/<link[^>]*rel=["']canonical["'][^>]*>\s*/gi, '');

  writeFileSync(f, src, 'utf8');
}
