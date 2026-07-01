#!/usr/bin/env bash
# СДВИГ R96 — подготовка к Cloudflare Pages (обход бэкенда, гость по умолчанию)
set -e
echo "══ штамп → R96 ══"
sed -i "s/SDVIG_BUILD='R95'/SDVIG_BUILD='R96'/" src/main/resources/static/app.js
sed -i 's/>R95</>R96</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/4  флаг статического режима (без бэкенда) ════"
python3 - << 'PYEOF'
path="app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if "window.SDVIG_STATIC" not in txt:
    # в начало — флаг статики (нет бэкенда)
    txt=txt.replace("window.SDVIG_BUILD='R96';",
                    "window.SDVIG_BUILD='R96';\nwindow.SDVIG_STATIC=true; // хостинг без бэкенда (Cloudflare Pages) — гость+localStorage",1)
    n+=1; print("  + флаг SDVIG_STATIC")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/4  обход /api/profile (сохранение только локально) ═"
python3 - << 'PYEOF'
path="app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''  persistSession();
  if(App.guest||!App.token) return;
  clearTimeout(saveTimer);
  saveTimer=setTimeout(()=>{
    fetch('/api/profile',{
      method:'PUT',
      headers:{'Content-Type':'application/json','Authorization':'Bearer '+App.token},
      body:JSON.stringify(App.profile)
    }).catch(()=>{});
  },800);
}'''
new='''  persistSession();
  // статический режим: сохраняем только в localStorage (без бэкенда)
  if(window.SDVIG_STATIC||App.guest||!App.token) return;
  clearTimeout(saveTimer);
  saveTimer=setTimeout(()=>{
    fetch('/api/profile',{
      method:'PUT',
      headers:{'Content-Type':'application/json','Authorization':'Bearer '+App.token},
      body:JSON.stringify(App.profile)
    }).catch(()=>{});
  },800);
}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + /api/profile обойдён в статике")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/4  вход: в статике сразу гость (без бэкенда) ═"
python3 - << 'PYEOF'
path="app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''function decideEntry(){
  // 1) Telegram Mini App
  const tg = window.Telegram && window.Telegram.WebApp;
  if(tg && tg.initData && tg.initData.length>0){
    tg.ready(); tg.expand();
    return tgWebAppLogin(tg);
  }'''
new='''function decideEntry(){
  // статический режим (Cloudflare Pages, без бэкенда): TG Mini App пропускаем,
  // т.к. проверять initData некому. Работаем на гостевом профиле + localStorage.
  const tg = window.Telegram && window.Telegram.WebApp;
  if(!window.SDVIG_STATIC && tg && tg.initData && tg.initData.length>0){
    tg.ready(); tg.expand();
    return tgWebAppLogin(tg);
  }
  if(tg){ try{ tg.ready(); tg.expand(); }catch(_){}
 }'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + TG Mini App пропущен в статике")

# initLogin: в статике не грузить Telegram widget, показать только гостя
old2='''  // Telegram Login Widget для обычного браузера
  const BOT = window.SDVIG_BOT_USERNAME || '';   // имя бота без @'''
new2='''  // в статическом режиме — только гостевой вход (бэкенд проверки отсутствует)
  if(window.SDVIG_STATIC){
    if(status) status.textContent='';
    return;
  }
  // Telegram Login Widget для обычного браузера
  const BOT = window.SDVIG_BOT_USERNAME || '';   // имя бота без @'''
if old2 in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + initLogin: только гость в статике")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 4/4  служебные файлы Cloudflare Pages ══════════"
# _redirects — SPA fallback (все пути → index.html)
cat > _redirects << 'REDIR'
/*    /index.html   200
REDIR
echo "  + _redirects (SPA fallback)"

# _headers — кэш и безопасность
cat > _headers << 'HEAD'
/*
  X-Frame-Options: SAMEORIGIN
  X-Content-Type-Options: nosniff
/img/*
  Cache-Control: public, max-age=31536000, immutable
/games/*
  Cache-Control: public, max-age=3600
HEAD
echo "  + _headers (кэш картинок, безопасность)"

cd - >/dev/null

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R96 — игра готова к статическому хостингу (Cloudflare Pages)"
echo "   git add -A && git commit -m 'R96: prepare for Cloudflare Pages static hosting' && git push"
echo "═══════════════════════════════════════════════════════"
