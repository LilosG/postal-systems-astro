const fs = require('fs'), path = require('path');

const ROOT = 'src/pages';
const HOME = path.resolve('src/pages/index.astro');
const LAYOUT = path.resolve('src/layouts/LovableLayout.astro');

if (!fs.existsSync(LAYOUT)) { console.error('Missing layout: '+LAYOUT); process.exit(1); }
if (!fs.existsSync(HOME))   { console.error('Missing homepage: '+HOME); process.exit(1); }

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap(d => {
    const p = path.join(dir, d.name);
    return d.isDirectory() ? walk(p) : (d.isFile() && p.endsWith('.astro') ? [p] : []);
  });
}

function titleFor(file, body) {
  const h1 = body.match(/<h1\b[^>]*>([\s\S]*?)<\/h1>/i);
  if (h1) return h1[1].replace(/<[^>]+>/g,'').trim().replace(/"/g,'&quot;');
  const base = path.basename(file, '.astro').replace(/[-_]+/g,' ').replace(/\b\w/g,m=>m.toUpperCase()).trim();
  return base || 'Postal Systems';
}

function stripShell(html) {
  // drop doctype/head/body/html and any old layout shells
  html = html.replace(/<!DOCTYPE[^>]*>/ig,'')
             .replace(/<head\b[^>]*>[\s\S]*?<\/head>/ig,'');
  const b = html.match(/<body\b[^>]*>([\s\S]*?)<\/body>/i);
  if (b) html = b[1];
  html = html.replace(/<\/?\s*(?:html|body)\b[^>]*>/ig,'')
             .replace(/<\s*(?:LovableLayout|Base|SiteLayout|Layout)\b[^>]*>([\s\S]*?)<\/\s*(?:LovableLayout|Base|SiteLayout|Layout)\s*>/ig,'$1')
             .replace(/^\s*import\s+\w+\s+from\s+['"][^'"]+['"]\s*;?\s*$/mg,'')
             .trim();
  return html;
}

function relImport(fromFile, toFileAbs) {
  return path.relative(path.dirname(fromFile), toFileAbs).replace(/\\/g,'/');
}

const files = walk(ROOT);
for (const file of files) {
  const abs = path.resolve(file);
  if (abs === HOME) continue;
  let src = fs.readFileSync(file, 'utf8');

  if (/^\s*import\s+LovableLayout\s+from\s+['"].*LovableLayout\.astro['"]/m.test(src)) {
    continue; // already wrapped
  }

  const body = stripShell(src);
  const t = titleFor(file, body);
  const importPath = relImport(file, LAYOUT);

  const out = `---\nimport LovableLayout from "${importPath}";\n---\n<LovableLayout title="${t}">\n${body}\n</LovableLayout>\n`;

  if (!fs.existsSync(file + '.bak')) fs.writeFileSync(file + '.bak', src);
  fs.writeFileSync(file, out);
  console.log('updated', file);
}
