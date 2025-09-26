import { readdirSync, statSync, writeFileSync } from 'fs';
import { join, relative, extname, basename } from 'path';

const ROOT = 'src/pages';
const SITE = 'San Diego Commercial Mailbox';

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

function humanize(seg){
  return seg.replace(/-/g,' ').replace(/\b\w/g, c => c.toUpperCase());
}

function titleFor(route){
  if (route === '/') return `${SITE}`;
  const parts = route.split('/').filter(Boolean);
  const end = humanize(parts[parts.length-1]);
  if (parts.length === 1) return `${humanize(parts[0])} — ${SITE}`;
  if (parts[0] === 'services') return `${end} — ${SITE}`;
  if (parts[0] === 'service-areas') return `Mailbox Services in ${end} — ${SITE}`;
  if (parts[0] === 'industries') return `${end} — ${SITE}`;
  return `${humanize(parts.join(' › '))} — ${SITE}`;
}

function descFor(route){
  if (route === '/') return 'Commercial mailbox installation, upgrades, repairs, re-keys and parcel lockers across San Diego County.';
  const parts = route.split('/').filter(Boolean);
  if (parts[0] === 'services') return 'Details, scope and process for this mailbox service. Request a quote today.';
  if (parts[0] === 'service-areas') return 'CBU and 4C installs, parcel lockers, repairs and maintenance in this area.';
  if (parts[0] === 'industries') return 'Solutions, programs and workflows tailored to this customer type.';
  if (parts[0] === 'contact') return 'Contact San Diego Commercial Mailbox for quotes and scheduling.';
  if (parts[0] === 'thank-you') return 'Thank you for contacting San Diego Commercial Mailbox.';
  return 'Commercial mailbox services, installs and maintenance.';
}

const files = walk(ROOT).filter(p => basename(p) !== 'index.html'); // ignore your static home
const map = {};
for (const f of files) {
  const route = toRoute(f);
  map[route] = {
    title: titleFor(route),
    description: descFor(route)
  };
}

writeFileSync('src/seo.json', JSON.stringify(map, null, 2));
