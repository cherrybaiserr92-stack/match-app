#!/usr/bin/env bash
# СДВИГ R18 — монетизация: Баксы + двухвалютная Лавка + дырокол + анимированные SVG
set -e

echo ""; echo "══ 1/4  index.html — Баксы в HUD + SVG-defs ════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/index.html"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# Баксы рядом с кредитами
old_money = ('    <div class="th-money">\n'
             '      <span class="th-coin" data-tico="coin"></span>\n'
             '      <span id="hud-credits">0</span>\n'
             '    </div>')
new_money = ('    <div class="th-money">\n'
             '      <span class="th-coin" data-tico="coin"></span>\n'
             '      <span id="hud-credits">0</span>\n'
             '    </div>\n'
             '    <div class="th-money th-bucks" id="th-bucks">\n'
             '      <span class="gem-ico" data-gem="bucks"></span>\n'
             '      <span id="hud-bucks">0</span>\n'
             '    </div>')
if old_money in txt and 'hud-bucks' not in txt:
    txt = txt.replace(old_money, new_money, 1); n+=1; print("  + Баксы в HUD")

# глобальные SVG-defs с анимированным градиентом-переливом (вставляем сразу после <body>)
if 'id="gem-defs"' not in txt:
    defs = '''
<!-- ══ АНИМИРОВАННЫЕ SVG-ГРАДИЕНТЫ (перелив самоцвета) ══ -->
<svg id="gem-defs" width="0" height="0" style="position:absolute" aria-hidden="true">
  <defs>
    <linearGradient id="gemShine" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#fff3c0"/>
      <stop offset="35%" stop-color="#f3d27a"/>
      <stop offset="55%" stop-color="#caa033"/>
      <stop offset="78%" stop-color="#f8e9b8"/>
      <stop offset="100%" stop-color="#8a6410"/>
      <animateTransform attributeName="gradientTransform" type="translate"
        values="-1 0; 1 0; -1 0" dur="3.4s" repeatCount="indefinite"/>
    </linearGradient>
    <linearGradient id="gemCyan" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#d6f4ff"/>
      <stop offset="50%" stop-color="#5cd0ff"/>
      <stop offset="100%" stop-color="#1b6fa8"/>
      <animateTransform attributeName="gradientTransform" type="translate"
        values="-1 0; 1 0; -1 0" dur="2.8s" repeatCount="indefinite"/>
    </linearGradient>
    <linearGradient id="gemRose" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#ffe0e6"/>
      <stop offset="50%" stop-color="#ff6f86"/>
      <stop offset="100%" stop-color="#a8324a"/>
      <animateTransform attributeName="gradientTransform" type="translate"
        values="-1 0; 1 0; -1 0" dur="3.1s" repeatCount="indefinite"/>
    </linearGradient>
    <radialGradient id="gemSpark" cx="50%" cy="40%" r="60%">
      <stop offset="0%" stop-color="#ffffff" stop-opacity="0.95"/>
      <stop offset="40%" stop-color="#fff3c0" stop-opacity="0.5"/>
      <stop offset="100%" stop-color="#fff" stop-opacity="0"/>
    </radialGradient>
    <filter id="gemGlow"><feGaussianBlur stdDeviation="0.6" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge></filter>
  </defs>
</svg>

'''
    txt = txt.replace('<body>', '<body>\n'+defs, 1) if '<body>' in txt else defs+txt
    n+=1; print("  + SVG-defs с анимированными градиентами")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d" % n)
PYEOF


echo ""; echo "══ 2/4  app.js — Баксы + двухвалютная Лавка + дырокол"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# профиль: bucks + поля инструментов
old_prof = "  level:1, xp:0, energy:5, maxEnergy:5, credits:0,"
new_prof = "  level:1, xp:0, energy:5, maxEnergy:5, credits:0, bucks:0,"
if old_prof in txt and "bucks:0" not in txt:
    txt = txt.replace(old_prof, new_prof, 1); n+=1; print("  + профиль: bucks")

# renderHUD: показывать баксы
old_hud = "  const cr=$('#hud-credits'); if(cr) cr.textContent=p.credits;"
new_hud = ("  const cr=$('#hud-credits'); if(cr) cr.textContent=p.credits;\n"
           "  const bk=$('#hud-bucks'); if(bk) bk.textContent=p.bucks||0;")
if old_hud in txt and "hud-bucks" not in txt:
    txt = txt.replace(old_hud, new_hud, 1); n+=1; print("  + renderHUD показывает баксы")

# addBucks
if "function addBucks" not in txt:
    anchor = "function addEnergy(n){"
    txt = txt.replace(anchor, "function addBucks(n){ const p=App.profile; p.bucks=Math.max(0,(p.bucks||0)+n); renderHUD(); saveProfile(); }\n"+anchor, 1)
    n+=1; print("  + addBucks")

# ── SVG-иконки товаров (анимированные, перелив) ──
if "var GEM_SVG" not in txt:
    icons = r'''
/* ═══ Анимированные SVG-иконки товаров (R18) ═══ */
var GEM_SVG={
  bucks:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M20 3l9 6v14l-9 6-9-6V9z" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><path d="M20 3v34M11 9l9 5 9-5M11 23l9-5 9 5" fill="none" stroke="#8a6410" stroke-width=".7" opacity=".55"/><ellipse cx="16" cy="12" rx="3" ry="5" fill="url(#gemSpark)"/></svg>',
  energy:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M12 14h16v8a8 8 0 0 1-16 0z" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><path d="M28 16h3a4 4 0 0 1 0 8h-3" fill="none" stroke="#8a6410" stroke-width="1.4"/><path d="M16 6c-1 2 1 3 0 5M20 5c-1 2 1 3 0 5M24 6c-1 2 1 3 0 5" fill="none" stroke="url(#gemShine)" stroke-width="1.6" stroke-linecap="round"><animate attributeName="opacity" values=".4;1;.4" dur="1.5s" repeatCount="indefinite"/></path><ellipse cx="17" cy="17" rx="2.5" ry="4" fill="url(#gemSpark)"/></svg>',
  magnify:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><circle cx="17" cy="17" r="10" fill="url(#gemCyan)" stroke="#1b6fa8" stroke-width="1.2" opacity=".92"/><circle cx="17" cy="17" r="6" fill="none" stroke="#d6f4ff" stroke-width="1" opacity=".6"/><path d="M25 25l9 9" stroke="url(#gemShine)" stroke-width="2.6" stroke-linecap="round"/><ellipse cx="14" cy="13" rx="2.5" ry="4" fill="url(#gemSpark)"/></svg>',
  file:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M11 6h12l6 6v22H11z" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><path d="M23 6v6h6" fill="none" stroke="#6a4810" stroke-width="1"/><path d="M15 19h11M15 24h11M15 29h7" stroke="#6a4810" stroke-width="1.2" opacity=".5"/><ellipse cx="16" cy="11" rx="2" ry="3.5" fill="url(#gemSpark)"/></svg>',
  hourglass:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M12 6h16M12 34h16M14 6c0 7 12 9 12 14s-12 7-12 14M26 6c0 7-12 9-12 14s12 7 12 14" fill="none" stroke="url(#gemShine)" stroke-width="2" stroke-linecap="round"/><path d="M20 18l-4 4h8z" fill="url(#gemShine)"><animateTransform attributeName="transform" type="translate" values="0 0;0 6;0 0" dur="2s" repeatCount="indefinite"/></path><ellipse cx="17" cy="10" rx="2" ry="3" fill="url(#gemSpark)"/></svg>',
  ashtray:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><ellipse cx="20" cy="26" rx="13" ry="6" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><ellipse cx="20" cy="24" rx="9" ry="4" fill="#1a1206" opacity=".6"/><path d="M22 20l8-8" stroke="#caa033" stroke-width="2" stroke-linecap="round"/><path d="M29 13c1-2 3-1 2-3" stroke="#aaa" stroke-width="1" fill="none" opacity=".5"><animate attributeName="opacity" values=".2;.6;.2" dur="2s" repeatCount="indefinite"/></path></svg>',
  siren:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><rect x="12" y="18" width="16" height="10" rx="3" fill="url(#gemRose)" stroke="#a8324a" stroke-width="1"/><path d="M16 18a4 4 0 0 1 8 0" fill="url(#gemCyan)" stroke="#1b6fa8" stroke-width="1"/><circle cx="20" cy="11" r="2" fill="url(#gemShine)"><animate attributeName="opacity" values="1;.3;1" dur=".7s" repeatCount="indefinite"/></circle><path d="M8 22h3M29 22h3" stroke="url(#gemShine)" stroke-width="1.6" stroke-linecap="round"/></svg>',
  tape:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><rect x="6" y="12" width="28" height="16" rx="2" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><circle cx="15" cy="20" r="3.5" fill="#1a1206"/><circle cx="25" cy="20" r="3.5" fill="#1a1206"/><circle cx="15" cy="20" r="1.4" fill="url(#gemShine)"><animateTransform attributeName="transform" type="rotate" from="0 15 20" to="360 15 20" dur="2s" repeatCount="indefinite"/></circle><circle cx="25" cy="20" r="1.4" fill="url(#gemShine)"><animateTransform attributeName="transform" type="rotate" from="0 25 20" to="360 25 20" dur="2s" repeatCount="indefinite"/></circle></svg>',
  phone:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M10 8c0 2 1 4 3 4l3-1 2 4-3 2c2 5 6 9 11 11l2-3 4 2-1 3c0 2 2 3 4 3" fill="none" stroke="url(#gemShine)" stroke-width="2.4" stroke-linecap="round"/><circle cx="30" cy="11" r="2.5" fill="url(#gemRose)"><animate attributeName="r" values="2.5;3.2;2.5" dur="1s" repeatCount="indefinite"/></circle></svg>'
};
function gemIcon(k){ return GEM_SVG[k]||GEM_SVG.bucks; }
'''
    anchor = "const SHOP=["
    txt = txt.replace(anchor, icons+"\n"+anchor, 1); n+=1; print("  + анимированные SVG-иконки товаров")

# ── новый двухвалютный SHOP ──
old_shop_start = "const SHOP=["
shop_end_marker = "function renderShop(){"
si = txt.index(old_shop_start)
ei = txt.index(shop_end_marker)
new_shop = '''const SHOP=[
  /* ── За 📁 Зацепки (credits) — бесплатный контур ── */
  {k:'energy',   svg:'energy',   name:'Чёрный кофе', desc:'+3 энергии', cur:'credits', price:30,
    buy(){ addEnergy(3); }},
  {k:'magnify',  svg:'magnify',  name:'Лупа',        desc:'Подсветит улику', cur:'credits', price:40,
    buy(){ App.profile.tMagnify=(App.profile.tMagnify||0)+1; saveProfile(); }},
  {k:'file',     svg:'file',     name:'Досье',       desc:'Пропустить мини-игру', cur:'credits', price:60,
    buy(){ App.profile.tFile=(App.profile.tFile||0)+1; saveProfile(); }},
  {k:'hourglass',svg:'hourglass',name:'Песочные часы',desc:'+20 энергии', cur:'credits', price:30,
    buy(){ addEnergy(20); }},
  /* ── За 💵 Баксы (премиум-валюта) — бустеры match-3 ── */
  {k:'ashtray',  svg:'ashtray',  name:'Тяжёлая пепельница', desc:'Разбить 1 камень', cur:'bucks', price:100,
    buy(){ App.profile.boosters=(App.profile.boosters||0)+1; saveProfile(); }},
  {k:'siren',    svg:'siren',    name:'Полицейская мигалка', desc:'Очистить ряд+столбец', cur:'bucks', price:150,
    buy(){ App.profile.bSiren=(App.profile.bSiren||0)+1; saveProfile(); }},
  {k:'tape',     svg:'tape',     name:'Плёнка диктофона', desc:'Перемешать поле', cur:'bucks', price:150,
    buy(){ App.profile.bShuffle=(App.profile.bShuffle||0)+1; saveProfile(); }},
  {k:'phone',    svg:'phone',    name:'Звонок информатору', desc:'Подсветит безопасный выбор', cur:'bucks', price:50,
    buy(){ App.profile.tHint=(App.profile.tHint||0)+1; saveProfile(); }}
];

/* пакеты Баксов за реальные деньги (заглушка под платёж Telegram Stars / Wallet) */
const BUCK_PACKS=[
  {amount:500,  price:'$1.99'},
  {amount:1400, price:'$4.99'},
  {amount:6500, price:'$19.99'},
  {amount:50000,price:'$99.99', label:'Чемодан с наличностью'}
];

'''
txt = txt[:si] + new_shop + txt[ei:]
n+=1; print("  + двухвалютный SHOP (зацепки + баксы)")

# ── renderShop под новый формат + SVG + валюта ──
old_render = txt[txt.index("function renderShop(){"):txt.index("/* ═══════════════════════════════════════════════\n   ЕЖЕДНЕВНЫЙ")]
new_render = '''function renderShop(){
  const g=$('#shop-grid'); if(!g) return; g.innerHTML='';
  SHOP.forEach(it=>{
    const isBucks=it.cur==='bucks';
    const curIco=isBucks?'<span class="gem-ico mini" data-gem="bucks"></span>':'◈';
    const item=el('div','shop-item'+(isBucks?' premium':''),`
      <div class="si-gem">${gemIcon(it.svg)}</div>
      <div class="si-name">${it.name}</div>
      <div class="si-desc">${it.desc}</div>
      <div class="si-price ${isBucks?'pr-bucks':'pr-credits'}">${it.price} ${curIco}</div>`);
    item.onclick=()=>{
      const bal=isBucks?(App.profile.bucks||0):App.profile.credits;
      if(bal<it.price){
        Sound.error();
        if(isBucks){ openBuckShop(); }
        else toast('Мало зацепок','Нужно '+it.price+' ◈','✗');
        return;
      }
      if(isBucks){ App.profile.bucks-=it.price; } else { addCredits(-it.price); }
      it.buy(); Sound.coin(); vibrate(10);
      toast('Куплено',it.name,'🛍'); renderHUD(); renderShop();
    };
    g.appendChild(item);
  });
}

/* окно покупки Баксов (заглушка платежа) */
function openBuckShop(){
  let html='<div class="buckshop-back" id="buckshop"><div class="buckshop-card">'
    +'<div class="bs-title"><span class="gem-ico" data-gem="bucks"></span> Служебный бюджет</div>'
    +'<div class="bs-sub">Баксы ускоряют расследование. Игра проходится и без них.</div>'
    +'<div class="bs-list">';
  BUCK_PACKS.forEach((p,i)=>{
    html+='<button class="bs-pack" data-i="'+i+'"><span class="bs-amt"><span class="gem-ico mini" data-gem="bucks"></span> '+p.amount.toLocaleString('ru')+'</span>'
      +(p.label?'<span class="bs-label">'+p.label+'</span>':'')
      +'<span class="bs-price">'+p.price+'</span></button>';
  });
  html+='</div><button class="bs-close" id="bs-close">Закрыть</button></div></div>';
  const wrap=document.createElement('div'); wrap.innerHTML=html; document.body.appendChild(wrap.firstChild);
  const back=document.getElementById('buckshop');
  back.querySelectorAll('.bs-pack').forEach(b=>b.onclick=()=>{
    const p=BUCK_PACKS[+b.dataset.i];
    /* TODO: реальный платёж (Telegram Stars / Wallet). Пока — выдаём для теста. */
    addBucks(p.amount); Sound.coin(); vibrate([10,30,10]);
    toast('Бюджет пополнен','+'+p.amount.toLocaleString('ru')+' баксов','💵');
    back.remove(); renderShop();
  });
  back.querySelector('#bs-close').onclick=()=>{ Sound.tap(); back.remove(); };
  back.onclick=(e)=>{ if(e.target===back){ back.remove(); } };
}

'''
txt = txt.replace(old_render, new_render, 1); n+=1; print("  + renderShop + окно покупки Баксов")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d" % n)
PYEOF


echo ""; echo "══ 3/4  app.js — раскраска data-gem иконок ══════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()

# при renderHUD проставляем SVG в data-gem элементы (баксы в HUD и пр.)
if "function paintGems" not in txt:
    fn = ('function paintGems(){\n'
          '  try{ document.querySelectorAll("[data-gem]").forEach(function(elx){\n'
          '    if(elx._painted) return; var k=elx.getAttribute("data-gem");\n'
          '    if(window.GEM_SVG&&GEM_SVG[k]){ elx.innerHTML=GEM_SVG[k]; elx._painted=true; }\n'
          '  }); }catch(e){}\n'
          '}\n')
    anchor = "function renderHUD(){"
    txt = txt.replace(anchor, fn+anchor, 1)
    # вызвать в конце renderHUD
    txt = txt.replace("function renderHUD(){", "function renderHUD(){\n  setTimeout(paintGems,0);", 1)
    print("  + paintGems (раскраска data-gem)")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js")
PYEOF


echo ""; echo "══ 4/4  CSS — Лавка, баксы, окно покупки ═══════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f: txt = f.read()
if "/* R18 */" in txt:
    print("  · уже применено")
else:
    css = r'''
/* ════════ R18 — Монетизация / Лавка / Баксы ════════ */

/* HUD: баксы */
.th-bucks{ margin-left:6px; }
.gem-ico{ display:inline-flex; width:22px; height:22px; vertical-align:middle; }
.gem-ico.mini{ width:15px; height:15px; }
.gem-ico svg{ width:100%; height:100%; }

/* карточка товара */
.shop-item .si-gem{ width:54px; height:54px; margin:0 auto 6px; }
.shop-item .si-gem svg{ width:100%; height:100%; display:block; }
.si-name{ font-weight:800; font-size:13.5px; margin-top:2px; }
.si-desc{ font-size:11px; color:var(--ink3); margin-top:3px; min-height:28px; line-height:1.35; }
.si-price{ margin-top:9px; padding:7px; border-radius:10px; font-weight:800; font-size:13px;
  display:flex; align-items:center; justify-content:center; gap:5px; }
.pr-credits{ background:var(--acc-dim,rgba(200,134,10,.14)); color:var(--acc-2,#ffcf6b);
  border:1px solid rgba(240,169,58,.3); }
.pr-bucks{ background:linear-gradient(135deg,rgba(92,208,255,.14),rgba(92,208,255,.05));
  color:#9fe0ff; border:1px solid rgba(92,208,255,.32); }
.shop-item.premium{ border-color:rgba(92,208,255,.25); }
.shop-item.premium::before{ content:'PREMIUM'; position:absolute; top:8px; right:8px;
  font-size:7px; letter-spacing:.12em; color:#9fe0ff; opacity:.7; font-weight:700; }
.shop-item{ position:relative; }

/* окно покупки баксов */
.buckshop-back{ position:fixed; inset:0; z-index:320; display:flex; align-items:center; justify-content:center;
  padding:22px; background:rgba(4,7,12,.82); backdrop-filter:blur(4px); animation:bsFade .25s ease; }
@keyframes bsFade{ from{opacity:0} to{opacity:1} }
.buckshop-card{ width:100%; max-width:360px; border-radius:20px; padding:22px 18px 16px;
  background:linear-gradient(160deg,rgba(20,28,40,.99),rgba(8,12,19,.99));
  border:1px solid rgba(92,208,255,.3); box-shadow:0 20px 60px rgba(0,0,0,.6); }
.bs-title{ font-family:'Unbounded',sans-serif; font-weight:800; font-size:16px; color:#9fe0ff;
  display:flex; align-items:center; gap:8px; margin-bottom:6px; }
.bs-sub{ font-size:12px; color:var(--ink3); line-height:1.45; margin-bottom:16px; }
.bs-list{ display:flex; flex-direction:column; gap:9px; }
.bs-pack{ display:flex; align-items:center; gap:10px; padding:13px 15px; border-radius:13px; cursor:pointer;
  background:rgba(255,255,255,.04); border:1px solid var(--glass-line); color:#e7eef6;
  font-size:14px; font-weight:700; transition:border-color .15s,background .15s; }
.bs-pack:active{ background:rgba(92,208,255,.12); border-color:rgba(92,208,255,.5); }
.bs-amt{ display:flex; align-items:center; gap:6px; }
.bs-label{ font-size:9px; color:#f3d27a; letter-spacing:.06em; margin-left:auto; margin-right:8px; }
.bs-price{ margin-left:auto; padding:5px 11px; border-radius:8px;
  background:linear-gradient(180deg,#ffdf95,var(--acc,#c8860a)); color:#241701; font-weight:800; font-size:13px; }
.bs-pack .bs-label + .bs-price{ margin-left:0; }
.bs-close{ width:100%; margin-top:14px; padding:12px; border:none; border-radius:11px;
  background:rgba(255,255,255,.06); color:var(--ink); font-weight:600; font-size:14px; cursor:pointer; }
'''
    txt += "\n/* R18 */\n" + css
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + R18 CSS")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R18 готов — монетизация + анимированные SVG"
echo "   git add -A && git commit -m 'R18: monetization shop + bucks + animated SVG icons' && git push"
echo "═══════════════════════════════════════════════════════"
