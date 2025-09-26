import { readFileSync } from 'fs';
const files = readFileSync(0,'utf8').split(/\r?\n/).filter(Boolean);
let bad=0;
for (const f of files){
  const s = readFileSync(f,'utf8');
  const reasons=[];
  if (!/<Base\b/.test(s)) reasons.push('no-Base');
  if (/import\s+Base\s+from\s+["']\.\.\//.test(s)) reasons.push('relative-import');
  if (/<link[^>]*rel=["']canonical["']/.test(s)) reasons.push('page-canonical');
  if (/(<!doctype html|<html\b|<head\b)/i.test(s)) reasons.push('inline-head');
  if (reasons.length){ console.log(f+' :: '+reasons.join(',')); bad=1; }
}
process.exit(bad);
