#!/usr/bin/env bash
# СДВИГ R99 — wrangler.toml в формате Workers-static-assets (новый Cloudflare 2026)
set -e
echo "══ штамп → R99 ══"
sed -i "s/SDVIG_BUILD='R98'/SDVIG_BUILD='R99'/" src/main/resources/static/app.js
sed -i 's/>R98</>R99</' src/main/resources/static/index.html

echo ""; echo "══ wrangler.toml → формат Worker+assets (не Pages) ═"
# Новый Cloudflare: static-assets Worker вместо Pages.
# Вместо pages_build_output_dir → [assets] directory
cat > wrangler.toml << 'CONF'
name = "match-app"
compatibility_date = "2026-07-01"

[assets]
directory = "./src/main/resources/static"
CONF
echo "  ✓ формат Workers-static-assets:"
cat wrangler.toml | sed 's/^/    /'
echo ""
echo "  ⚠ Deploy command в Cloudflare должна быть: npx wrangler deploy"
echo "    (НЕ 'wrangler pages deploy' — теперь это обычный wrangler deploy)"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R99 — конфиг под новый Cloudflare (Workers static assets)"
echo "   git add -A && git commit -m 'R99: wrangler config for Workers static assets' && git push"
echo "═══════════════════════════════════════════════════════"
