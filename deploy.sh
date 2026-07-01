#!/usr/bin/env bash
# СДВИГ R97 — фикс сборки Cloudflare Pages (wrangler.toml с pages_build_output_dir)
set -e
echo "══ штамп → R97 ══"
sed -i "s/SDVIG_BUILD='R96'/SDVIG_BUILD='R97'/" src/main/resources/static/app.js
sed -i 's/>R96</>R97</' src/main/resources/static/index.html

echo ""; echo "══ 1/2  wrangler.toml в КОРЕНЬ репо ═══════════════"
# Кладём в корень репо (там, где build.gradle) — не в static!
cat > wrangler.toml << 'CONF'
name = "sdvig"
pages_build_output_dir = "src/main/resources/static"
compatibility_date = "2024-01-01"
CONF
echo "  + wrangler.toml (pages_build_output_dir → static)"
echo "    содержимое:"
cat wrangler.toml | sed 's/^/      /'

echo ""; echo "══ 2/2  .gitignore — не мешать сборке Java-артефактами ═"
python3 - << 'PYEOF'
import os
path=".gitignore"
add=['','# Cloudflare Pages','.wrangler/','node_modules/']
cur=''
if os.path.exists(path):
    with open(path,encoding="utf-8") as f: cur=f.read()
lines=[l for l in add if l not in cur]
if lines:
    with open(path,"a",encoding="utf-8") as f: f.write('\n'.join(lines)+'\n')
    print("  + .gitignore дополнен (.wrangler, node_modules)")
else:
    print("  .gitignore уже содержит нужное")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R97 — Cloudflare Pages: wrangler.toml настроен"
echo ""
echo "   ⚠ ВАЖНО: после git push в панели Cloudflare убедись, что:"
echo "     • Build command — ПУСТО"
echo "     • либо Deploy command — 'npx wrangler pages deploy' (не 'wrangler deploy')"
echo "     • wrangler.toml подхватится автоматически"
echo ""
echo "   git add -A && git commit -m 'R97: fix Cloudflare Pages build config' && git push"
echo "═══════════════════════════════════════════════════════"
