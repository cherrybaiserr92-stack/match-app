#!/bin/bash
set -e
S="src/main/resources/static"
echo "🔧 СДВИГ hotfix — Phaser perf + clicks + auth"

# ════════════════════════════════════════════════════════════
# 1) phaser-bg.js — оптимизация: статичные текстуры, без перерисовки каждый кадр
# ════════════════════════════════════════════════════════════
echo "  ✦ $S/phaser-bg.js"
cat > "$S/phaser-bg.js" << 'SDVEOF'
/* СДВИГ · phaser-bg.js v6 — лёгкий параллакс (без перерисовки graphics) */
(function(){
  let game=null, scene=null, layers=[], rain=null, lamp=null, paused=false;
  let px=0.5, py=0.5, tx=0, ty=0;

  function boot(){
    if(game || !window.Phaser) return;
    game = new Phaser.Game({
      type:Phaser.AUTO, parent:'bg-fx',
      width:window.innerWidth, height:window.innerHeight,
      transparent:true, banner:false,
      fps:{ target:24, forceSetTimeOut:true },
      render:{ powerPreference:'low-power', antialias:false },
      scale:{ mode:Phaser.Scale.RESIZE },
      scene:{ create, update }
    });
    // КРИТИЧНО: canvas НЕ должен ловить клики
    setTimeout(()=>{ const c=document.querySelector('#bg-fx canvas');
      if(c){ c.style.pointerEvents='none'; c.style.touchAction='none'; } },50);
  }

  // создаём ТЕКСТУРЫ один раз, дальше двигаем спрайты (дёшево)
  function makeTex(scene){
    const W=scene.scale.width, H=scene.scale.height;
    // фон-окно
    let g=scene.add.graphics();
    g.fillStyle(0x0d1424,1).fillRect(0,0,W,H);
    g.fillStyle(0x16243f,0.5);
    for(let i=0;i<3;i++) g.fillRect(W*0.6,H*0.1+i*H*0.22,W*0.34,H*0.18);
    g.generateTexture('bgwin',W,H); g.destroy();
    // полки
    g=scene.add.graphics();
    for(let s=0;s<4;s++){ const y=H*0.2+s*H*0.18;
      g.fillStyle(0x0a0e16,0.7).fillRect(W*0.04,y,W*0.42,8);
      for(let b=0;b<7;b++){ g.fillStyle(0x1a2336,0.45)
        .fillRect(W*0.05+b*W*0.055,y-28-(b%3)*6,W*0.04,28+(b%3)*6);} }
    g.generateTexture('shelf',W,H); g.destroy();
  }

  function create(){
    scene=this; const W=scene.scale.width, H=scene.scale.height;
    makeTex(scene);
    const win=scene.add.image(W/2,H/2,'bgwin').setDepth(0);
    const shelf=scene.add.image(W/2,H/2,'shelf').setDepth(1);
    layers=[{o:win,d:0.02},{o:shelf,d:0.05}];

    // дождь — один TileSprite или пул из 30 линий, двигаем по Y (дёшево)
    rain=scene.add.graphics().setDepth(2);
    scene._rain=[]; for(let i=0;i<28;i++) scene._rain.push({
      x:Math.random()*W, y:Math.random()*H, l:8+Math.random()*8, s:5+Math.random()*5});
    drawRain(W,H);

    // лампа — статичная текстура свечения, дышит через alpha (без перерисовки)
    const lg=scene.add.graphics();
    for(let i=6;i>0;i--){ lg.fillStyle(0xf0a93a,0.04*i/6); lg.fillCircle(140,140,60*i); }
    lg.generateTexture('lamp',280,280); lg.destroy();
    lamp=scene.add.image(W*0.5,H*0.16,'lamp').setDepth(3).setAlpha(0.7);

    // ввод
    scene.input.on('pointermove',p=>{ px=p.x/W; py=p.y/H; });
    if(window.DeviceOrientationEvent){
      window.addEventListener('deviceorientation',e=>{
        if(e.gamma!=null) tx=Math.max(-1,Math.min(1,e.gamma/40));
        if(e.beta!=null)  ty=Math.max(-1,Math.min(1,(e.beta-45)/40));
      });
    }
    // плавное «дыхание» лампы через твин (GPU, не CPU)
    scene.tweens.add({targets:lamp,alpha:0.45,duration:2600,yoyo:true,repeat:-1,ease:'Sine.easeInOut'});
    scene._t=0; scene._rt=0;
  }

  function drawRain(W,H){
    rain.clear(); rain.lineStyle(1.3,0x5a7bb0,0.30);
    scene._rain.forEach(r=>{ rain.beginPath();
      rain.moveTo(r.x,r.y); rain.lineTo(r.x-2,r.y+r.l); rain.strokePath(); });
  }

  let frame=0;
  function update(_,dt){
    if(!scene||paused) return;
    const W=scene.scale.width, H=scene.scale.height;
    const ox=(px-0.5)+tx*0.5, oy=(py-0.5)+ty*0.5;
    layers.forEach(l=>{ l.o.x=W/2-ox*W*l.d; l.o.y=H/2-oy*H*l.d; });
    lamp.x=W*0.5+ox*30;
    // дождь обновляем через кадр (вдвое реже) — экономия
    frame++; if(frame%2===0){
      scene._rain.forEach(r=>{ r.y+=r.s*2; if(r.y>H){r.y=-r.l;r.x=Math.random()*W;} });
      drawRain(W,H);
    }
  }

  window.BgFx={
    init:boot,
    pause(){ paused=true; if(game) game.loop.sleep(); },
    resume(){ paused=false; if(game) game.loop.wake(); },
    setMood(){}
  };
  window.addEventListener('resize',()=>{ if(game) game.scale.resize(innerWidth,innerHeight); });
})();
SDVEOF

# ════════════════════════════════════════════════════════════
# 2) index.html — TG widget в браузере + правильный порядок слоёв
# ════════════════════════════════════════════════════════════
echo "  ✦ $S/index.html (login + bg-fx)"
# патчим только две зоны через python (надёжнее sed для многострочного)
python3 - << 'PYEOF'
import re
p="src/main/resources/static/index.html"
h=open(p,encoding="utf-8").read()

# (a) bg-fx переносим в начало body как фон, с жёстким pointer-events:none
h=h.replace(
'<div id="bg-fx" style="position:fixed;inset:0;z-index:-1;pointer-events:none"></div>','')
h=h.replace('<body>',
'<body>\n<div id="bg-fx" style="position:fixed;inset:0;z-index:0;pointer-events:none!important"></div>')

# (b) login: добавляем контейнер виджета + кнопку TG (если их нет)
login_block='''<div class="tg-widget-area" id="tg-widget-area">
        <div class="tg-tip" id="tg-status">Подключение…</div>
      </div>'''
new_login='''<div class="tg-widget-area" id="tg-widget-area"></div>
      <div class="tg-tip" id="tg-status">Загрузка способов входа…</div>
      <button class="btn btn-bronze" id="tg-browser-btn" type="button" style="display:none">Войти через Telegram</button>'''
h=h.replace(login_block,new_login)

open(p,"w",encoding="utf-8").write(h)
print("index.html patched")
PYEOF

# ════════════════════════════════════════════════════════════
# 3) style.css — аудит pointer-events (клики гарантированно проходят)
# ════════════════════════════════════════════════════════════
echo "  ✦ $S/style.css (+pointer-events audit)"
cat >> "$S/style.css" << 'SDVEOF'

/* ═══════════ HOTFIX: pointer-events audit ═══════════ */
#bg-fx, #bg-fx *{ pointer-events:none !important; }
.splash-flash{ pointer-events:none !important; }
.splash-photo,.login-photo{ pointer-events:none !important; }
#login-screen::after{ pointer-events:none !important; }
/* активный экран и его содержимое — кликабельны */
.screen{ pointer-events:none; }
.screen.active{ pointer-events:auto; }
.screen:not(.active){ pointer-events:none !important; }
/* кнопки/виджет всегда поверх и кликабельны */
.btn,.nb,.sound-btn,.up-btn,.shop-item,.game-row,.map-node,
.hm-close,.back-btn,#guest-btn,#tg-browser-btn,#tg-widget-area,#tg-widget-area *{
  pointer-events:auto !important; position:relative; z-index:5;
}
.login-wrap{ position:relative; z-index:5; }
/* tab-area не должна перекрывать nav */
.bottom-nav{ z-index:60 !important; }
SDVEOF

# ════════════════════════════════════════════════════════════
# 4) app.js — патчим auth: гость + TG widget(браузер) + Mini App
# ════════════════════════════════════════════════════════════
echo "  ✦ $S/app.js (auth fix)"
python3 - << 'PYEOF'
p="src/main/resources/static/app.js"
s=open(p,encoding="utf-8").read()

# заменяем функцию initLogin целиком на версию с TG-виджетом для браузера
import re
new_init='''function initLogin(){
  const status=$('#tg-status');
  const gb=$('#guest-btn');
  // ГОСТЬ — всегда рабочий
  if(gb){ gb.style.pointerEvents='auto'; gb.disabled=false;
    gb.onclick=()=>{ Sound.tap(); guestLogin(); }; }

  // Telegram Login Widget для обычного браузера
  const BOT = window.SDVIG_BOT_USERNAME || '';   // имя бота без @
  const area=$('#tg-widget-area');
  if(area && BOT){
    status.textContent='';
    const sc=document.createElement('script');
    sc.src='https://telegram.org/js/telegram-widget.js?22';
    sc.async=true;
    sc.setAttribute('data-telegram-login',BOT);
    sc.setAttribute('data-size','large');
    sc.setAttribute('data-radius','12');
    sc.setAttribute('data-request-access','write');
    sc.setAttribute('data-onauth','onTelegramAuth(user)');
    area.innerHTML=''; area.appendChild(sc);
  } else {
    status.textContent='Войдите через Telegram (в приложении) или как гость.';
  }
}

// callback от Telegram Login Widget (браузер)
window.onTelegramAuth=function(user){
  fetch('/api/auth/widget',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify(user)})
    .then(r=>{ if(!r.ok) throw 0; return r.json(); })
    .then(data=>{ App.user=data.user; App.token=data.token; App.guest=false;
      App.profile=normalizeProfile(data.profile); persistSession(); enterMain(); })
    .catch(()=>{ toast('Ошибка входа','Попробуйте как гость','✗'); });
};'''

# вырезаем старую initLogin(...) { ... } до следующей функции guestLogin
pat=re.compile(r"function initLogin\(\)\{.*?\n\}\n", re.S)
s=pat.sub(new_init+"\n", s, count=1)

# гарантируем pointer-events для guest в guestLogin (уже ок), плюс
# BgFx pause во время match3 (меньше лагов)
s=s.replace("if(window.Match3){\n    Match3.start",
            "if(window.BgFx) BgFx.pause();\n  if(window.Match3){\n    Match3.start")
s=s.replace("modal.classList.add('hidden'); unlockSwipe();",
            "modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); unlockSwipe();")
s=s.replace("modal.classList.add('hidden'); Match3&&Match3.stop();",
            "modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); Match3&&Match3.stop();")

open(p,"w",encoding="utf-8").write(s)
print("app.js patched")
PYEOF

echo ""
echo "✅ hotfix применён."
echo "ℹ️  ВАЖНО: укажи имя бота в index.html перед </head>:"
echo '    <script>window.SDVIG_BOT_USERNAME="ИМЯ_БОТА_БЕЗ_@";</script>'
