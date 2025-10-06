#!/usr/bin/env bash
set -euo pipefail
pkill -f "astro preview" 2>/dev/null || true
npm i -D tailwindcss@3 postcss@latest autoprefixer@latest >/dev/null
cat > postcss.config.cjs <<'CFG'
module.exports = {
  plugins: {
    tailwindcss: {},
    autoprefixer: {},
  },
};
CFG
rm -rf dist .astro node_modules/.vite
npm run build
