#!/usr/bin/env bash
# СДВИГ R100 — фикс _redirects (бесконечный цикл) → not_found_handling в конфиге
set -e
echo "══ штамп → R100 ══"
sed -i "s/SDVIG_BUILD='R99'/SDVIG_BUILD='R100'/" src/main/resources/static/app.js
sed -i 's/>R99</>R100</' src/main/resources/static/index.html

echo ""; echo "══ 1/2  удаляем проблемный _redirects ═════════════"
# _redirects с '/*  /index.html 200' вызывает бесконечный цикл в Workers.
# SPA-фоллбэк теперь через not_found_handling в wrangler.toml
if [ -f src/main/resources/static/_redirects ]; then
  rm -f src/main/resources/static/_redirects
  echo "  − _redirects удалён (заменён на not_found_handling)"
else
  echo "  (_redirects уже нет)"
fi

echo ""; echo "══ 2/2  wrangler.toml + not_found_handling=SPA ════"
cat > wrangler.toml << 'CONF'
name = "match-app"
compatibility_date = "2026-07-01"

[assets]
directory = "./src/main/resources/static"
not_found_handling = "single-page-application"
CONF
echo "  ✓ конфиг с SPA-фоллбэком:"
cat wrangler.toml | sed 's/^/    /'

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R100 — _redirects убран, SPA-фоллбэк через конфиг"
echo "   git add -A && git commit -m 'R100: fix redirects loop, SPA fallback via config' && git push"
echo "═══════════════════════════════════════════════════════"
