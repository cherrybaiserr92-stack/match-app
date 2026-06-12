#!/bin/bash
set -e
S="src/main/resources/static"
echo "🚀 upgrade — layout fix + arcade (3 games)"

mkdir -p "$S/games"

# ── 1) экспорт классов в window (если не сделан) ──
for f in detective-mahjong:DetectiveMahjong torn-letter:TornLetterScene crime-board:CrimeBoardScene; do
  file="${f%%:*}"; cls="${f##*:}"
  path="$S/games/$file.js"
  if [ -f "$path" ] && ! grep -q "window.$cls" "$path"; then
    printf "\nwindow.%s = %s;\n" "$cls" "$cls" >> "$path"
    echo "  + export $cls"
  fi
done

# ── 2) arcade.js — самодостаточный лаунчер ──
cat > "$S/games/arcade.js" << 'SDVEOF'
/* СДВИГ · arcade.js — независимый модуль аркад */
(function(){
  const GAMES = [
    { key:'DetectiveMahjong', name:'Детективный маджонг', desc:'Соединяй связанные улики', icon:'🀄', evt:'detective-mahjong-complete', opts:{ maxTime:140, maxErrors:5 } },
    { key:'TornLetterScene',  name:'Разорванное письмо',  desc:'Собери письмо из кусков',  icon:'✉️', evt:'torn-letter-complete',      opts:{} },
    { key:'CrimeBoardScene',  name:'Доска улик',          desc:'Построй цепочку связей',   icon:'🧩', evt:'crime-board-complete',     opts:{ maxTime:80 } }
  ];

  let game=null;

  function cardHTML(g){
    return `<div class="game-row arcade-card" data-key="${g.key}">
      <div class="gr-stripe gr-s-v"></div>
      <div class="gr-icon">${g.icon}</div>
      <div class="gr-info">
        <div class="gr-name">${g.name}</div>
        <div class="gr-desc">${g.desc}</div>
        <div class="gr-prog"><div class="gr-bar"><div class="gr-fill" style="width:40%"></div></div><div class="gr-lvl">PLAY</div></div>
      </div>
      <div class="gr-arrow">›</div>
    </div>`;
  }

  function renderInto(list){
    if(!list) return;
    if(list.getAttribute('data-arcade')==='1') return;
    list.setAttribute('data-arcade','1');
    list.innerHTML = GAMES.map(cardHTML).join('');
    list.querySelectorAll('.arcade-card').forEach(c=>{
      c.addEventListener('click',()=>launch(c.getAttribute('data-key')));
    });
  }

  function ensure(){
    const list=document.getElementById('game-list');
    if(list) renderInto(list);
  }

  function launch(key){
    const g = GAMES.find(x=>x.key===key);
    if(!g) return;
    if(!window.Phaser){ alert('Phaser не загружен'); return; }
    if(!window[key]){ alert('Игра не найдена: '+key); return; }
    try{ window.Sound && Sound.tap && Sound.tap(); }catch(e){}
    if(window.BgFx && BgFx.pause) BgFx.pause();

    const ov=document.createElement('div');
    ov.id='arcade-overlay';
    ov.innerHTML=`
      <div class="arc-bar">
        <button class="arc-close" id="arc-close">‹ Выход</button>
        <div class="arc-title">${g.name}</div>
        <div style="width:72px"></div>
      </div>
      <div class="arc-stage" id="arc-stage"></div>`;
    document.body.appendChild(ov);

    const stage=ov.querySelector('#arc-stage');
    game=new Phaser.Game({
      type:Phaser.AUTO,
      parent:stage,
      width:800, height:600,
      backgroundColor:'#0f1117',
      scale:{ mode:Phaser.Scale.FIT, autoCenter:Phaser.Scale.CENTER_BOTH },
      render:{ antialias:true }
    });
    game.scene.add(key, window[key], true, g.opts);

    game.events.once(g.evt,(payload)=>{
      reward(payload);
      setTimeout(close,400);
    });

    ov.querySelector('#arc-close').onclick=close;
  }

  function reward(p){
    try{
      if(!p) return;
      if(window.App && App.profile){
        if(typeof addXP==='function' && p.rewardXP) addXP(p.rewardXP);
        if(typeof addCredits==='function') addCredits(p.deductionSuccess?20:5);
        if(typeof unlockSwipe==='function' && p.deductionSuccess) unlockSwipe();
      }
      if(window.Sound){ p.deductionSuccess?(Sound.win&&Sound.win()):(Sound.deny&&Sound.deny()); }
    }catch(e){}
  }

  function close(){
    try{ if(game){ game.destroy(true); game=null; } }catch(e){}
    const ov=document.getElementById('arcade-overlay');
    if(ov) ov.remove();
    if(window.BgFx && BgFx.resume) BgFx.resume();
  }

  // следим, чтобы карточки всегда были на месте
  function boot(){
    ensure();
    const mo=new MutationObserver(()=>{
      const list=document.getElementById('game-list');
      if(list && list.getAttribute('data-arcade')!=='1') renderInto(list);
    });
    mo.observe(document.body,{childList:true,subtree:true});
    setInterval(ensure,1500);
  }

  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',boot);
  else boot();

  window.Arcade={ launch, close };
})();
SDVEOF
echo "  ✦ arcade.js"

# ── 3) CSS — layout fix + arcade overlay ──
cat >> "$S/style.css" << 'SDVEOF'

/* ========== UPGRADE: layout + arcade ========== */
html,body{width:100%;height:100%;overflow:hidden}
body{position:fixed;inset:0}

#bg-fx{position:fixed!important;inset:0!important;z-index:0!important;pointer-events:none!important}
#bg-fx canvas{pointer-events:none!important;touch-action:none!important}

.screen{position:fixed!important;inset:0!important;padding-top:0!important}
.screen:not(.active){pointer-events:none!important}
.screen.active{pointer-events:auto!important}

.topbar{position:fixed!important;top:0;left:0;right:0;z-index:70!important}
.xp-band{position:fixed!important;top:54px;left:0;right:0;z-index:69!important}
.tab-area{position:fixed!important;top:86px!important;left:0;right:0;
  bottom:calc(var(--navh) + var(--safeb))!important;z-index:30!important;overflow:hidden!important}
.tab-pane{position:absolute!important;inset:0!important;overflow-y:auto!important;
  padding:16px 14px 24px!important;-webkit-overflow-scrolling:touch}
.bottom-nav{position:fixed!important;left:0;right:0;bottom:0;z-index:120!important;pointer-events:auto!important}
.bottom-nav *{pointer-events:auto!important}
.nb{min-height:60px}

#login-screen{z-index:40!important}
.login-wrap,.login-card,#guest-btn,#tg-browser-btn,#tg-widget-area,#tg-widget-area *{
  position:relative!important;z-index:80!important;pointer-events:auto!important}
.login-photo,.splash-photo,#login-screen::after,.splash-flash{pointer-events:none!important}

/* arcade overlay */
#arcade-overlay{
  position:fixed;inset:0;z-index:9999;
  display:flex;flex-direction:column;
  background:radial-gradient(800px 600px at 50% 0%, #11161f, #06080c);
  padding-top:var(--safet);padding-bottom:var(--safeb);
}
.arc-bar{
  flex:0 0 auto;height:52px;display:flex;align-items:center;justify-content:space-between;
  padding:0 12px;background:rgba(16,20,28,.85);
  -webkit-backdrop-filter:blur(14px);backdrop-filter:blur(14px);
  border-bottom:1px solid rgba(255,255,255,.08);
}
.arc-close{
  border:none;cursor:pointer;font-family:inherit;font-weight:700;font-size:14px;
  color:#ffcf6b;background:rgba(255,255,255,.06);
  border:1px solid rgba(240,169,58,.35);border-radius:10px;padding:8px 14px;
}
.arc-title{font-weight:700;font-size:15px;color:#f2f5fb}
.arc-stage{flex:1 1 auto;position:relative;overflow:hidden;display:flex;align-items:center;justify-content:center}
.arc-stage canvas{max-width:100%!important;max-height:100%!important}
SDVEOF
echo "  ✦ style.css (fix)"

# ── 4) index.html — подключение скриптов + phaser ──
python3 - << 'PYEOF'
p="src/main/resources/static/index.html"
s=open(p,encoding="utf-8").read()

if 'phaser' not in s:
    s=s.replace('</head>','<script src="https://cdn.jsdelivr.net/npm/phaser@3.80.1/dist/phaser.min.js"></script>\n</head>')

if 'window.SDVIG_BOT_USERNAME=' not in s:
    s=s.replace('</head>','<script>window.SDVIG_BOT_USERNAME="sdvig_game_bot";</script>\n</head>')

for f in ['detective-mahjong','torn-letter','crime-board','arcade']:
    tag=f'<script src="/games/{f}.js"></script>'
    if tag not in s:
        s=s.replace('</body>', tag+'\n</body>')

open(p,'w',encoding='utf-8').write(s)
print("index.html updated")
PYEOF
echo "  ✦ index.html"

echo "✅ upgrade applied"
