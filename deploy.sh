#!/usr/bin/env bash
# СДВИГ R98 — wrangler.toml: имя проекта match-app (совпадение с Cloudflare)
set -e
echo "══ штамп → R98 ══"
sed -i "s/SDVIG_BUILD='R97'/SDVIG_BUILD='R98'/" src/main/resources/static/app.js
sed -i 's/>R97</>R98</' src/main/resources/static/index.html

echo ""; echo "══ wrangler.toml — имя проекта = match-app ════════"
cat > wrangler.toml << 'CONF'
name = "match-app"
pages_build_output_dir = "src/main/resources/static"
compatibility_date = "2024-01-01"
CONF
echo "  ✓ name = match-app (совпадает с проектом Cloudflare)"
cat wrangler.toml | sed 's/^/    /'

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R98 — имя проекта исправлено на match-app"
echo "   git add -A && git commit -m 'R98: fix wrangler project name to match-app' && git push"
echo "═══════════════════════════════════════════════════════"
