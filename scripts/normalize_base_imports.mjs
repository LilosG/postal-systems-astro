import { readFileSync, writeFileSync } from 'fs';

function insertImportInFrontmatter(src) {
  if (!src.startsWith('---')) {
    return `---\nimport Base from "@/layouts/Base.astro";\n---\n` + src;
  }
  const parts = src.split(/(^---\s*[\r\n]|[\r\n]---\s*[\r\n]?)/m);
  const start = src.indexOf('---');
  if (start !== 0) return `---\nimport Base from "@/layouts/Base.astro";\n---\n` + src;
  const end = src.indexOf('\n---', 3);
  if (end === -1) {
    return `---\nimport Base from "@/layouts/Base.astro";\n---\n` + src;
  }
  const fm = src.slice(0, end + 4);
  const rest = src.slice(end + 4);
  const injected = fm.replace(/^---\s*\n?/, `---\nimport Base from "@/layouts/Base.astro";\n`);
  return injected + rest;
}

const files = readFileSync(0, 'utf8').split(/\r?\n/).filter(Boolean);

for (const f of files) {
  let s = readFileSync(f, 'utf8');

  const hadBaseImport = /import\s+Base\s+from\s+["'][^"']*Base\.astro["'];?/.test(s);
  s = s.replace(/import\s+Base\s+from\s+["'](?:\.\.\/)+layouts\/Base\.astro["'];?/g, 'import Base from "@/layouts/Base.astro";');

  if (!hadBaseImport && /<Base\b/.test(s)) {
    s = insertImportInFrontmatter(s);
  }

  writeFileSync(f, s, 'utf8');
}
