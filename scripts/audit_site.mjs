import { readFileSync, readdirSync, statSync } from 'fs';
import { join } from 'path';

const files=[];
function walk(d){for(const f of readdirSync(d)){const p=join(d,f);const s=statSync(p);if(s.isDirectory())walk(p);else files.push(p);}}
walk('src');

function grep(rx, exts){return files.filter(p=>!exts||exts.some(e=>p.endsWith(e))).map(p=>[p,readFileSync(p,'utf8')]).filter(([p,s])=>rx.test(s)).map(([p])=>p);}

const astroPages=files.filter(p=>p.startsWith('src/pages/')&&p.endsWith('.astro'));
const hashAnchors=grep(/href=["']#\w+/i);
const missingBase=astroPages.filter(p=>!/<Base\b/.test(readFileSync(p,'utf8')));
const relBase=grep(/import\s+Base\s+from\s+['"](\.\.\/)+layouts\/Base\.astro['"]/i,['.astro']);
const inlineNavs=grep(/<nav\b[^>]*>/i,['.astro']).filter(p=>p.startsWith('src/pages/'));
const base=readFileSync('src/layouts/Base.astro','utf8');
const forcedCanonical=/canonicalBase|canonicalHref|rel="canonical"/i.test(base);
const oldBrand=grep(/Postal Systems Pro|Postal Systems/i);
const oldDomain=grep(/postalsystemspro\.com/i);
const pageCanonicals=grep(/<link[^>]+rel=["']canonical["']/i,['.astro']).filter(p=>p.startsWith('src/pages/'));
const baseHasTailwind=/import\s+["']\.\.\/styles\/tailwind\.css["']/.test(base);

function out(label,arr){if(arr&&arr.length){console.log(label);console.log(arr.join('\n'));}}
out('HASH_ANCHORS',hashAnchors);
out('MISSING_BASE',missingBase);
out('RELATIVE_BASE_IMPORTS',relBase);
out('INLINE_PAGE_NAVS',inlineNavs);
if(forcedCanonical)out('BASE_FORCED_CANONICAL',['src/layouts/Base.astro']);
out('OLD_BRAND_STRINGS',oldBrand);
out('OLD_DOMAIN_STRINGS',oldDomain);
out('PAGE_CANONICAL_TAGS',pageCanonicals);
if(!baseHasTailwind)out('BASE_MISSING_TAILWIND',['src/layouts/Base.astro']);
