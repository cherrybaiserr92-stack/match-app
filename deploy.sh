#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  СДВИГ · deploy.sh — фикс свайпа, толстая рамка, колода,
#  глубокие фоны карточек, инструменты ниже
# ═══════════════════════════════════════════════════════════════
set -e
S="src/main/resources/static"
echo ""
echo "🎴  СДВИГ — карточки, колода, глубокие фоны…"
echo ""
echo "  ✦ $S/style.css"
mkdir -p $(dirname "$S/style.css")
cat > "$S/style.css" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · style.css — чистая версия
   Тёмное стекло · янтарь · единый стиль
═══════════════════════════════════════════════ */
@import url('https://fonts.googleapis.com/css2?family=Unbounded:wght@600;700;800&family=Manrope:wght@400;500;600;700&family=JetBrains+Mono:wght@400;600&display=swap');

:root{
  --bg0:#06080c; --bg1:#0a0e14;
  --glass:rgba(18,22,32,.62);
  --glass-2:rgba(22,27,38,.78);
  --glass-line:rgba(255,255,255,.10);
  --glass-line-2:rgba(255,255,255,.06);
  --glass-blur:18px;

  --ink:#f2f5fb; --ink2:#c2cbda; --ink3:#7d8699; --ink4:#4a5364;

  --acc:#c8860a; --acc-2:#ffcf6b; --acc-d:#b3741c;
  --acc-dim:rgba(200,134,10,.14); --acc-glow:rgba(255,207,107,.4);

  --gem:#6be0ff; --info:#4d8ef7;
  --ok:#35d49b; --ok-dim:rgba(53,212,155,.14);
  --no:#ff5d6c; --no-dim:rgba(255,93,108,.14);

  --r:10px; --rl:14px; --rxl:18px; --r2xl:24px; --rfull:999px;
  --sh-1:0 8px 30px rgba(0,0,0,.4);
  --sh-2:0 16px 50px rgba(0,0,0,.55);

  --navh:64px;
  --safet:env(safe-area-inset-top,0px);
  --safeb:env(safe-area-inset-bottom,0px);
}

*{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent}
html,body{width:100%;height:100%;overflow:hidden}
body{
  font-family:'Manrope',system-ui,sans-serif;
  background:var(--bg0); color:var(--ink);
  position:fixed; inset:0;
  -webkit-user-select:none; user-select:none;
}

/* фон Phaser — НИКОГДА не ловит клики */
#bg-fx{
  position:fixed; inset:0; z-index:0;
  pointer-events:none;
}
#bg-fx canvas{ pointer-events:none !important; touch-action:none; }

/* ── базовый фон (фолбэк, если Phaser не загрузился) ── */
body::before{
  content:''; position:fixed; inset:0; z-index:-1;
  background:
    radial-gradient(900px 500px at 50% -10%, rgba(200,134,10,.08), transparent 60%),
    linear-gradient(180deg,#0a0e14,#06080c);
}

.hidden{ display:none !important; }

/* ═══ ЭКРАНЫ ═══ */
.screen{
  position:fixed; inset:0; z-index:10;
  display:flex; flex-direction:column;
  opacity:0; pointer-events:none;
  transition:opacity .35s ease;
}
.screen.active{ opacity:1; pointer-events:auto; }
/* неактивные экраны полностью убираем из потока — не перехватывают клики */
.screen:not(.active){ display:none; }

/* ═══ SPLASH ═══ */
#splash-screen{
  z-index:200; align-items:center; justify-content:center;
  background:
    linear-gradient(180deg,rgba(6,8,12,.55),rgba(6,8,12,.85)),
    var(--splash-img,none) center/cover no-repeat, #06080c;
}
.splash-scene{ position:relative; z-index:2; display:flex; flex-direction:column; align-items:center; gap:18px; }
.splash-emblem{
  width:96px; height:96px; border-radius:50%;
  display:flex; align-items:center; justify-content:center;
  background:var(--glass-2); border:2px solid var(--acc);
  box-shadow:0 0 40px var(--acc-dim);
  opacity:0; transform:scale(.7);
  transition:opacity .5s ease, transform .5s cubic-bezier(.22,1.1,.36,1);
}
.splash-emblem.visible{ opacity:1; transform:scale(1); }
.splash-emblem.pulse{ animation:emPulse .22s ease; }
@keyframes emPulse{ 50%{ transform:scale(1.08); box-shadow:0 0 60px var(--acc-glow);} }
.emblem-letter{ font-family:'Unbounded',sans-serif; font-weight:800; font-size:46px; color:var(--acc-2); }
.splash-title-row{ display:flex; gap:4px; }
.title-letter{
  font-family:'Unbounded',sans-serif; font-weight:800; font-size:34px; letter-spacing:4px; color:var(--ink);
  opacity:0; transform:translateY(14px);
  transition:opacity .35s ease, transform .35s cubic-bezier(.22,1.1,.36,1);
}
.title-letter.in{ opacity:1; transform:none; }
.splash-progress-wrap{ width:200px; display:flex; flex-direction:column; align-items:center; gap:10px; }
.splash-track{ width:100%; height:4px; border-radius:4px; background:rgba(255,255,255,.08); overflow:hidden; }
.splash-fill{ height:100%; width:0; border-radius:4px; background:linear-gradient(90deg,var(--acc-d),var(--acc-2)); transition:width .35s ease; }
.splash-status{ font-size:11px; letter-spacing:2px; color:var(--ink3); text-transform:uppercase; font-family:'JetBrains Mono',monospace; }
.splash-flash{ position:absolute; inset:0; z-index:5; background:#fff; opacity:0; pointer-events:none; }

/* ═══ LOGIN ═══ */
#login-screen{
  z-index:100; align-items:center; justify-content:center;
  background:
    linear-gradient(180deg,rgba(6,8,12,.6),rgba(6,8,12,.9)),
    var(--login-img,none) center/cover no-repeat, #06080c;
}
.login-wrap{ position:relative; z-index:2; width:min(92%,400px); display:flex; flex-direction:column; gap:22px; }
.login-header{ text-align:center; display:flex; flex-direction:column; align-items:center; gap:8px; }
.login-badge{
  width:64px; height:64px; border-radius:50%;
  display:flex; align-items:center; justify-content:center;
  background:var(--glass-2); border:2px solid var(--acc);
  font-family:'Unbounded',sans-serif; font-weight:800; font-size:30px; color:var(--acc-2);
  box-shadow:0 0 30px var(--acc-dim);
}
.login-h1{ font-family:'Unbounded',sans-serif; font-weight:800; font-size:30px; letter-spacing:5px; }
.login-tagline{ font-size:13px; color:var(--ink3); letter-spacing:1px; }
.login-card{
  background:var(--glass); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border:1px solid var(--glass-line); border-radius:var(--r2xl);
  padding:24px 22px; display:flex; flex-direction:column; gap:14px;
  box-shadow:var(--sh-2);
}
.login-card-label{ font-size:12px; letter-spacing:2px; color:var(--ink3); text-transform:uppercase; text-align:center; }
.tg-widget-area{ display:flex; justify-content:center; min-height:10px; }
.tg-tip{ font-size:12px; color:var(--ink3); text-align:center; line-height:1.5; }
.divider{ display:flex; align-items:center; gap:12px; color:var(--ink4); font-size:12px; }
.divider::before,.divider::after{ content:''; flex:1; height:1px; background:var(--glass-line); }
.login-hint{ font-size:11px; color:var(--ink4); text-align:center; line-height:1.5; }

/* ═══ КНОПКИ ═══ */
.btn{
  border:none; cursor:pointer; font-family:inherit; font-weight:700; font-size:15px;
  padding:14px 18px; border-radius:var(--rl); width:100%;
  transition:transform .12s ease, filter .2s ease;
}
.btn:active{ transform:scale(.97); }
.btn-bronze{ background:linear-gradient(135deg,var(--acc),var(--acc-d)); color:#1a1206; box-shadow:0 6px 20px var(--acc-dim); }
.btn-outline{ background:rgba(255,255,255,.04); color:var(--ink); border:1px solid var(--glass-line); }

/* ═══ ERROR ═══ */
#error-screen{ z-index:150; align-items:center; justify-content:center; }
.err-center{ display:flex; flex-direction:column; align-items:center; gap:14px; text-align:center; padding:24px; }
.err-icon{ font-size:54px; }
.err-title{ font-family:'Unbounded',sans-serif; font-weight:700; font-size:20px; }
.err-msg{ font-size:14px; color:var(--ink3); }

/* ═══ MAIN ═══ */
#main-screen{ z-index:10; }

/* верхний HUD: уровень + деньги */
.top-hud{
  flex:0 0 auto;
  display:flex; align-items:center; gap:12px;
  padding:calc(8px + var(--safet)) 16px 8px;
  background:linear-gradient(180deg, rgba(8,10,16,.78), transparent);
  position:relative; z-index:20;
}
.th-level{ flex:1; display:flex; align-items:center; gap:10px; min-width:0; }
.th-lvl-badge{
  width:38px; height:38px; flex:0 0 auto; border-radius:50%;
  display:flex; align-items:center; justify-content:center;
  background:linear-gradient(135deg,var(--acc),var(--acc-d)); color:#1a1206;
  font-family:'Unbounded',sans-serif; font-weight:800; font-size:16px;
  box-shadow:0 4px 14px rgba(200,134,10,.35), inset 0 1px 0 rgba(255,255,255,.3);
}
.th-xp{ flex:1; min-width:0; }
.th-xp-track{ height:8px; border-radius:8px; background:rgba(255,255,255,.08);
  overflow:hidden; box-shadow:inset 0 1px 2px rgba(0,0,0,.4); }
.th-xp-fill{ height:100%; border-radius:8px;
  background:linear-gradient(90deg,var(--acc-d),var(--acc-2));
  box-shadow:0 0 8px rgba(255,207,107,.5); transition:width .5s ease; }
.th-xp-info{ font-size:10px; color:var(--ink3); margin-top:3px; font-family:'JetBrains Mono',monospace; }
.th-money{
  flex:0 0 auto; display:flex; align-items:center; gap:6px;
  padding:7px 13px; border-radius:var(--rfull);
  background:var(--glass-2); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border:1px solid rgba(255,207,107,.3); color:var(--acc-2);
  font-weight:800; font-size:15px; font-family:'Unbounded',sans-serif;
  box-shadow:inset 0 1px 0 rgba(255,255,255,.1);
}
.th-coin{ display:inline-flex; width:18px; height:18px; }
.snd-btn{ flex:0 0 auto; width:38px; height:38px; border-radius:50%;
  border:1px solid var(--glass-line); background:var(--glass-2); cursor:pointer; font-size:16px; }

/* панель инструментов — ВНИЗУ вкладки Дела, над меню, под карточкой */
.tools-bar{
  position:absolute; left:0; right:0;
  bottom:calc(var(--navh) + var(--safeb) - 4px);
  display:flex; align-items:center; justify-content:center; gap:12px;
  padding:0 16px; z-index:8; pointer-events:none;
}
.tools-bar .tool-btn{ pointer-events:auto; }
.tool-btn{
  position:relative; width:48px; height:48px; border-radius:15px;
  display:flex; align-items:center; justify-content:center;
  background:var(--glass-2); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border:1px solid rgba(255,207,107,.22); cursor:pointer; color:var(--acc-2);
  box-shadow:0 6px 18px -6px rgba(0,0,0,.6), inset 0 1px 0 rgba(255,255,255,.1);
  transition:transform .12s ease;
}
.tool-btn:active{ transform:scale(.9); }
.tool-shop{ color:var(--ink2); border-color:var(--glass-line); width:44px; height:44px; }
.tool-badge{
  position:absolute; top:-5px; right:-5px;
  min-width:18px; height:18px; padding:0 4px; border-radius:9px;
  background:linear-gradient(135deg,var(--acc),var(--acc-d)); color:#1a1206;
  font-size:11px; font-weight:800; line-height:18px; text-align:center;
  border:1.5px solid #0a0e14; box-shadow:0 2px 6px rgba(0,0,0,.4);
}

.topbar{
  flex:0 0 auto; height:54px;
  display:flex; align-items:center; justify-content:space-between;
  padding:calc(6px + var(--safet)) 14px 6px;
  background:var(--glass-2); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border-bottom:1px solid var(--glass-line-2);
}
.topbar-left{ display:flex; align-items:center; gap:10px; }
.topbar-emblem{ width:34px; height:34px; border-radius:50%; display:flex; align-items:center; justify-content:center;
  background:var(--glass); border:1.5px solid var(--acc); color:var(--acc-2); font-family:'Unbounded',sans-serif; font-weight:800; }
.topbar-brand{ font-family:'Unbounded',sans-serif; font-weight:700; font-size:18px; letter-spacing:3px; }
.topbar-right{ display:flex; align-items:center; gap:8px; }
.topbar-stats{ display:flex; gap:8px; }
.stat-pill{ display:flex; align-items:center; gap:5px; padding:6px 11px; border-radius:var(--rfull);
  background:var(--glass); border:1px solid var(--glass-line-2); font-weight:700; font-size:13px; }
.stat-pill [data-ico]{ width:15px; height:15px; display:inline-flex; }
.sound-btn{ width:38px; height:38px; border-radius:50%; border:1px solid var(--glass-line-2);
  background:var(--glass); cursor:pointer; font-size:16px; }

.xp-band{ flex:0 0 auto; display:flex; align-items:center; gap:10px; padding:8px 14px;
  background:var(--glass-2); border-bottom:1px solid var(--glass-line-2); }
.xp-track{ flex:1; height:6px; border-radius:6px; background:rgba(255,255,255,.07); overflow:hidden; }
.xp-fill{ height:100%; border-radius:6px; background:linear-gradient(90deg,var(--acc-d),var(--acc-2)); }
.xp-info{ font-size:11px; color:var(--ink3); font-family:'JetBrains Mono',monospace; white-space:nowrap; }

/* tab area занимает оставшееся место между topbar/xp и nav */
.tab-area{
  flex:1 1 auto; position:relative; overflow:hidden;
  /* резервируем место под фиксированную навигацию, чтобы зона не накрывала меню */
  margin-bottom:calc(var(--navh) + var(--safeb));
}
.tab-pane{
  position:absolute; inset:0;
  overflow-y:auto; -webkit-overflow-scrolling:touch;
  padding:16px 14px 24px;
  opacity:0; pointer-events:none; transform:translateY(6px);
  transition:opacity .25s ease, transform .25s ease;
}
.tab-pane.active{ opacity:1; pointer-events:auto; transform:none; }
.tab-pane::-webkit-scrollbar,.map-scroll::-webkit-scrollbar{ width:0; height:0; }

/* свайп-зона (вкладка Дела) — НЕ скроллится */
#tab-cases{ overflow:hidden; padding:0; }
.swipe-zone{
  position:absolute; inset:0; display:flex; align-items:center; justify-content:center;
  /* атмосферный слой поверх Phaser-фона: фокус-свет в центре, тень по краям */
  background:
    radial-gradient(120% 90% at 50% 38%, transparent 0%, transparent 30%, rgba(4,6,12,.45) 75%, rgba(2,3,8,.75) 100%),
    radial-gradient(60% 45% at 50% 40%, rgba(255,179,71,.10), transparent 60%);
}
/* мягкое световое пятно под карточкой — будто свет лампы падает на стол */
.swipe-zone::before{
  content:''; position:absolute; left:50%; top:50%;
  width:min(94%,420px); height:74%;
  transform:translate(-50%,-50%);
  background:radial-gradient(ellipse 70% 60% at 50% 45%, rgba(255,200,120,.07), transparent 70%);
  pointer-events:none; z-index:0;
}

.pane-hd{ margin-bottom:14px; }
.pane-title{ font-family:'Unbounded',sans-serif; font-weight:600; font-size:20px; }
.pane-sub{ font-size:12px; color:var(--ink3); margin-top:3px; }

/* ═══ BOTTOM NAV ═══ */
.bottom-nav{
  flex:0 0 auto;
  position:fixed; left:0; right:0; bottom:0; z-index:120;
  display:flex; align-items:stretch;
  height:calc(var(--navh) + var(--safeb));
  padding-bottom:var(--safeb);
  background:var(--glass-2); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border-top:1px solid var(--glass-line);
  pointer-events:auto;
}
.nb{
  flex:1; display:flex; flex-direction:column; align-items:center; justify-content:center; gap:4px;
  background:none; border:none; cursor:pointer; color:var(--ink4);
  font-family:inherit; transition:color .2s ease;
  pointer-events:auto;
}
/* иконка и подпись не перехватывают клик — он уходит на кнопку */
.nb *{ pointer-events:none; }
.nb [data-ico]{ width:24px; height:24px; display:inline-flex; }
.nb-lbl{ font-size:10px; font-weight:600; letter-spacing:.5px; }
.nb.active{ color:var(--acc-2); }

/* ═══ PROFILE ═══ */
.profile-hero{ display:flex; align-items:center; gap:14px; padding:16px; border-radius:var(--rxl);
  background:var(--glass); border:1px solid var(--glass-line); margin-bottom:16px; }
.profile-av{ width:60px; height:60px; border-radius:50%; display:flex; align-items:center; justify-content:center;
  background:var(--glass-2); border:2px solid var(--acc); color:var(--acc-2); font-family:'Unbounded',sans-serif; font-weight:800; font-size:26px; }
.profile-name{ font-family:'Unbounded',sans-serif; font-weight:600; font-size:18px; }
.profile-arch{ font-size:13px; color:var(--acc-2); margin-top:2px; }
.profile-id{ font-size:11px; color:var(--ink4); font-family:'JetBrains Mono',monospace; margin-top:2px; }
.stats-row{ display:grid; grid-template-columns:repeat(4,1fr); gap:10px; }
.sg{ background:var(--glass); border:1px solid var(--glass-line-2); border-radius:var(--rl); padding:14px 8px; text-align:center; }
.sg-val{ font-family:'Unbounded',sans-serif; font-weight:700; font-size:22px; color:var(--acc-2); }
.sg-lbl{ font-size:10px; color:var(--ink3); margin-top:4px; }
.skill-list{ display:flex; flex-direction:column; gap:10px; }
.skill-row{ display:flex; align-items:center; gap:12px; padding:14px; border-radius:var(--rl);
  background:var(--glass); border:1px solid var(--glass-line-2); }
.sk-info{ flex:1; }
.sk-name{ font-weight:700; font-size:14px; }
.sk-bar{ height:5px; border-radius:5px; background:rgba(255,255,255,.07); overflow:hidden; margin-top:6px; }
.sk-fill{ height:100%; background:linear-gradient(90deg,var(--acc-d),var(--acc-2)); }
.sk-lvl{ font-size:12px; color:var(--ink3); font-family:'JetBrains Mono',monospace; }
.up-btn{ border:none; cursor:pointer; background:var(--acc-dim); color:var(--acc-2);
  border:1px solid rgba(240,169,58,.3); border-radius:var(--r); padding:8px 12px; font-weight:700; font-family:inherit; }
.ach-grid{ display:grid; grid-template-columns:repeat(4,1fr); gap:10px; }
.ach-cell{ aspect-ratio:1; border-radius:var(--rl); background:var(--glass); border:1px solid var(--glass-line-2);
  display:flex; flex-direction:column; align-items:center; justify-content:center; gap:4px; text-align:center; padding:6px; }
.ach-cell.locked{ opacity:.35; }
.ach-ico{ font-size:24px; }
.ach-name{ font-size:9px; color:var(--ink3); line-height:1.2; }

/* ═══ SHOP ═══ */
.shop-grid{ display:grid; grid-template-columns:repeat(2,1fr); gap:12px; }
.shop-item{ background:var(--glass); border:1px solid var(--glass-line); border-radius:var(--rxl);
  padding:18px 14px; text-align:center; cursor:pointer; transition:transform .15s ease; }
.shop-item:active{ transform:scale(.97); }
.shop-ico{ font-size:38px; }
.shop-name{ font-weight:700; font-size:14px; margin-top:8px; }
.shop-desc{ font-size:11px; color:var(--ink3); margin-top:4px; min-height:28px; }
.shop-price{ margin-top:10px; padding:8px; border-radius:var(--r); background:var(--acc-dim);
  color:var(--acc-2); font-weight:800; font-size:13px; border:1px solid rgba(240,169,58,.3); }

/* ═══ MAP ═══ */
.map-scroll{ position:absolute; inset:0; overflow-y:auto; -webkit-overflow-scrolling:touch;
  background:
    radial-gradient(circle at 20% 10%, rgba(200,134,10,.06), transparent 40%),
    radial-gradient(circle at 80% 80%, rgba(107,224,255,.05), transparent 40%),
    repeating-linear-gradient(0deg, transparent, transparent 38px, rgba(255,255,255,.018) 38px, rgba(255,255,255,.018) 39px),
    repeating-linear-gradient(90deg, transparent, transparent 38px, rgba(255,255,255,.018) 38px, rgba(255,255,255,.018) 39px),
    linear-gradient(180deg, #0c1016, #070a0e);
}
.map-inner{ position:relative; width:100%; }
.map-path-svg{ position:absolute; inset:0; width:100%; height:100%; pointer-events:none; z-index:1; }
.map-chapter{ position:absolute; transform:translate(-50%,-50%); z-index:2; text-align:center; white-space:nowrap; }
.mc-title{ font-family:'Unbounded',sans-serif; font-weight:700; font-size:15px; color:var(--acc-2); }
.mc-sub{ font-size:11px; color:var(--ink3); }
.mc-locked .mc-title{ color:var(--ink4); }
.map-node{ position:absolute; transform:translate(-50%,-50%); z-index:2;
  width:54px; height:54px; border-radius:50%; cursor:pointer;
  display:flex; align-items:center; justify-content:center;
  font-family:'Unbounded',sans-serif; font-weight:700; font-size:18px;
  background:var(--glass-2); border:2px solid var(--glass-line); color:var(--ink3);
  transition:transform .15s ease; }
.map-node:active{ transform:translate(-50%,-50%) scale(.92); }
.map-node.done{ border-color:var(--acc); color:var(--acc-2); background:var(--acc-dim); }
.map-node.current{ border-color:var(--acc-2); color:var(--acc-2); box-shadow:0 0 24px var(--acc-glow);
  animation:nodePulse 1.8s ease-in-out infinite; }
@keyframes nodePulse{ 50%{ box-shadow:0 0 36px var(--acc-glow); } }
.map-node.locked [data-ico]{ width:20px; height:20px; color:var(--ink4); }

/* ═══ TOAST ═══ */
.toast{
  position:fixed; left:50%; bottom:calc(var(--navh) + var(--safeb) + 16px); transform:translateX(-50%) translateY(20px);
  z-index:500; display:flex; align-items:center; gap:12px;
  padding:12px 18px; border-radius:var(--rfull); max-width:90%;
  background:var(--glass-2); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border:1px solid var(--glass-line); box-shadow:var(--sh-2);
  opacity:0; pointer-events:none; transition:opacity .3s ease, transform .3s ease;
}
.toast.show{ opacity:1; transform:translateX(-50%) translateY(0); }
.toast-icon{ font-size:22px; }
.toast-title{ font-weight:700; font-size:13px; }
.toast-desc{ font-size:12px; color:var(--ink3); }

/* ═══ DAILY MODAL ═══ */
.modal-bg{ position:fixed; inset:0; z-index:450; display:flex; align-items:center; justify-content:center;
  background:rgba(4,6,10,.7); -webkit-backdrop-filter:blur(8px); backdrop-filter:blur(8px); padding:20px; }
.modal-bg.hidden{ display:none; }

/* ═══ ARCADE OVERLAY ═══ */
#arcade-overlay{
  position:fixed; inset:0; z-index:9000;
  display:flex; flex-direction:column;
  background:radial-gradient(800px 600px at 50% 0%, #11161f, #06080c);
  padding-top:var(--safet); padding-bottom:var(--safeb);
}
.arc-bar{ flex:0 0 auto; height:52px; display:flex; align-items:center; justify-content:space-between;
  padding:0 12px; background:var(--glass-2); -webkit-backdrop-filter:blur(14px); backdrop-filter:blur(14px);
  border-bottom:1px solid var(--glass-line); }
.arc-close{ border:none; cursor:pointer; font-family:inherit; font-weight:700; font-size:14px;
  color:var(--acc-2); background:rgba(255,255,255,.06); border:1px solid rgba(240,169,58,.35); border-radius:10px; padding:8px 14px; }
.arc-title{ font-weight:700; font-size:15px; }
.arc-stage{ flex:1 1 auto; position:relative; overflow:hidden; display:flex; align-items:center; justify-content:center; }
.arc-stage canvas{ max-width:100% !important; max-height:100% !important; }

EOF_SDVIG

echo "  ✦ $S/card-design.css"
mkdir -p $(dirname "$S/card-design.css")
cat > "$S/card-design.css" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · card-design.css — карточки дел
   Тёмное стекло · штампы скрыты до свайпа
═══════════════════════════════════════════════ */

/* ── стопка-подложка ── */
/* ── колода-подложка (набирается анимацией при входе) ── */
.stack-card{
  position:absolute; top:46%; left:50%;
  width:min(86%,360px); height:58%;
  border-radius:var(--r2xl);
  background:linear-gradient(160deg, #161a26, #0c0f16);
  border:2px solid rgba(255,255,255,.06);
  box-shadow:0 16px 40px -12px rgba(0,0,0,.7);
  pointer-events:none;
  opacity:0;
}
.sc1{ transform:translate(-50%,-50%) translateY(10px) scale(.965) rotate(1deg); }
.sc2{ transform:translate(-50%,-50%) translateY(20px) scale(.93)  rotate(-1.5deg); }
.sc3{ transform:translate(-50%,-50%) translateY(30px) scale(.895) rotate(2deg); }
/* анимация набора колоды */
.stack-card.deal{ animation:dealIn .45s cubic-bezier(.22,1.1,.36,1) both; }
.sc3.deal{ animation-delay:.0s; }
.sc2.deal{ animation-delay:.1s; }
.sc1.deal{ animation-delay:.2s; }
@keyframes dealIn{
  from{ opacity:0; transform:translate(-50%,-180%) rotate(-12deg) scale(.8); }
}
.sc1.dealt{ opacity:.72; }
.sc2.dealt{ opacity:.46; }
.sc3.dealt{ opacity:.26; }

/* ── активная карточка ── */
.case-card{
  position:absolute; top:46%; left:50%;
  transform:translate(-50%,-50%) rotate(-.4deg);
  width:min(86%,360px); min-height:58%; max-height:64%;
  display:flex; flex-direction:column;
  padding:22px 20px 18px;
  border-radius:var(--r2xl);
  /* плотная подложка снизу (убирает чёрный просвет при свайпе) + стекло сверху */
  background:
    linear-gradient(155deg, rgba(38,34,28,.22), transparent 40%),
    linear-gradient(160deg, #14182260, #0a0d12d0),
    #0c1016;
  -webkit-backdrop-filter:blur(calc(var(--glass-blur) + 6px)) saturate(1.2);
  backdrop-filter:blur(calc(var(--glass-blur) + 6px)) saturate(1.2);
  /* толстая рамка */
  border:2.5px solid rgba(255,207,107,.32);
  box-shadow:
    0 30px 70px -12px rgba(0,0,0,.8),
    0 8px 24px -6px rgba(0,0,0,.55),
    inset 0 1px 0 rgba(255,255,255,.14),
    inset 0 -1px 0 rgba(0,0,0,.4);
  touch-action:none;
  z-index:6;
}
/* все дочерние элементы карточки передают свайп родителю */
.case-card *{ touch-action:none; }
/* тонкая золотая кайма поверх стекла */
.case-card::after{
  content:''; position:absolute; inset:0; border-radius:inherit; pointer-events:none;
  padding:1px;
  background:linear-gradient(150deg, rgba(255,207,107,.45), transparent 30%, transparent 70%, rgba(255,207,107,.25));
  -webkit-mask:linear-gradient(#000 0 0) content-box, linear-gradient(#000 0 0);
  -webkit-mask-composite:xor; mask-composite:exclude;
  opacity:.6;
}
/* все дочерние элементы карточки передают свайп родителю */
.case-card *{ touch-action:none; }
/* премиум-фон карточки (SVG-текстура по типу дела) */
.card-bg{ position:absolute; inset:0; border-radius:inherit; overflow:hidden; z-index:0; }
.card-bg svg{ display:block; width:100%; height:100%; }
/* лёгкий скрим для читабельности текста поверх фона */
.card-bg::after{ content:''; position:absolute; inset:0;
  background:linear-gradient(180deg, rgba(6,8,12,.25), rgba(6,8,12,.55)); }
.case-card>.card-head,
.case-card>.card-divider,
.case-card>.card-body,
.case-card>.card-actions-area{ position:relative; z-index:2; }
.case-card.card-enter{ animation:cardIn .5s cubic-bezier(.22,1.1,.36,1) both; }
@keyframes cardIn{
  from{ opacity:0; transform:translate(-50%,-50%) translateY(40px) scale(.92) rotate(2deg); }
  to{ opacity:1; transform:translate(-50%,-50%) rotate(-.4deg); }
}

/* акцентная рамка по типу */
.case-card::before{
  content:''; position:absolute; inset:0; border-radius:inherit; pointer-events:none;
  border:1px solid transparent;
}
.ct-crime::before{ box-shadow:inset 0 0 0 1px rgba(255,93,108,.3); }
.ct-suspect::before{ box-shadow:inset 0 0 0 1px rgba(168,139,255,.3); }
.ct-evidence::before{ box-shadow:inset 0 0 0 1px rgba(107,224,255,.3); }
.ct-witness::before{ box-shadow:inset 0 0 0 1px rgba(53,212,155,.3); }
.ct-revelation::before{ box-shadow:inset 0 0 0 1px rgba(255,207,107,.35); }

/* tilt-подсветка при свайпе */
.case-card.tilt-left{ box-shadow:0 30px 70px -12px rgba(0,0,0,.75),-24px 0 70px -22px var(--no); }
.case-card.tilt-right{ box-shadow:0 30px 70px -12px rgba(0,0,0,.75),24px 0 70px -22px var(--ok); }
.case-card.tilt-up{ box-shadow:0 30px 70px -12px rgba(0,0,0,.75),0 -24px 70px -22px var(--acc-2); }

/* ── шапка ── */
.card-head{ display:flex; align-items:center; justify-content:space-between; gap:8px; position:relative; z-index:2; }
.card-act{ font-family:'JetBrains Mono',monospace; font-size:11px; letter-spacing:1px; color:var(--ink3);
  text-transform:uppercase; }
.card-type-badge{ font-size:10px; font-weight:800; letter-spacing:1.2px; text-transform:uppercase;
  padding:5px 12px; border-radius:var(--rfull);
  background:linear-gradient(135deg, rgba(255,207,107,.22), rgba(200,134,10,.12));
  color:var(--acc-2); border:1px solid rgba(255,207,107,.4);
  box-shadow:0 2px 8px rgba(200,134,10,.15), inset 0 1px 0 rgba(255,255,255,.15); }
.card-divider{ height:1px; margin:16px 0; position:relative; z-index:2;
  background:linear-gradient(90deg, transparent, rgba(255,207,107,.4), transparent); }

/* ── тело ── */
.card-body{ flex:1; display:flex; flex-direction:column; align-items:center; text-align:center; gap:16px;
  position:relative; z-index:2; overflow:hidden; }
.card-icon-box{
  font-size:46px; line-height:1; margin-top:10px;
  width:92px; height:92px; display:flex; align-items:center; justify-content:center;
  border-radius:50%;
  background:radial-gradient(circle at 38% 32%, rgba(255,207,107,.14), rgba(20,24,34,.6) 70%);
  border:1px solid rgba(255,207,107,.22);
  box-shadow:
    0 8px 24px -6px rgba(0,0,0,.6),
    inset 0 2px 8px rgba(255,255,255,.08),
    inset 0 -4px 12px rgba(0,0,0,.4),
    0 0 30px -8px rgba(255,207,107,.3);
}
.card-case-title{ font-family:'Unbounded',sans-serif; font-weight:700; font-size:21px; letter-spacing:.3px;
  background:linear-gradient(180deg, #fff, #d8dde8);
  -webkit-background-clip:text; background-clip:text; -webkit-text-fill-color:transparent;
  text-shadow:0 2px 12px rgba(0,0,0,.3); }
.card-text{ font-size:14.5px; color:var(--ink2); line-height:1.65; max-width:92%; }

/* ── ШТАМПЫ: скрыты по умолчанию (opacity:0!) ── */
.stamp-wrap{
  position:absolute; top:54px; z-index:5;
  pointer-events:none;
  opacity:0;                              /* ← ключевой фикс залипших надписей */
  transition:opacity .1s ease;
}
.stamp-right{ right:24px; transform:rotate(14deg); }
.stamp-left{ left:24px; transform:rotate(-14deg); }
.stamp-up{ left:50%; top:30px; transform:translateX(-50%) rotate(-3deg); }
.stamp{
  font-family:'Unbounded',sans-serif; font-weight:800; font-size:22px; letter-spacing:2px;
  padding:8px 16px; border-radius:10px; border:3px solid; text-transform:uppercase;
}
.stamp-approve-text{ color:var(--ok); border-color:var(--ok); text-shadow:0 0 14px var(--ok-dim); }
.stamp-deny-text{ color:var(--no); border-color:var(--no); text-shadow:0 0 14px var(--no-dim); }
.stamp-special-text{ color:var(--acc-2); border-color:var(--acc-2); text-shadow:0 0 14px var(--acc-glow); }

/* ── действия ── */
.card-actions-area{ position:relative; z-index:2; margin-top:12px; display:flex; flex-direction:column; gap:10px; }
.btn-play-gems{
  display:flex; align-items:center; justify-content:center; gap:8px;
  border:none; cursor:pointer; font-family:inherit; font-weight:700; font-size:15px;
  padding:14px; border-radius:var(--rl); width:100%;
  background:linear-gradient(135deg,var(--gem),var(--info)); color:#04121a;
  box-shadow:0 6px 20px rgba(107,224,255,.2);
}
.btn-play-gems [data-ico]{ width:18px; height:18px; }
.swipe-indicator{ display:flex; align-items:center; justify-content:space-between; gap:8px;
  font-size:12px; color:var(--ink3); padding:4px 2px; }
.swipe-indicator .si-center [data-ico]{ width:20px; height:20px; }
.si-deny{ color:var(--no); font-weight:700; }
.si-approve{ color:var(--ok); font-weight:700; }
.si-locked{ display:flex; align-items:center; gap:6px; justify-content:center; width:100%; color:var(--ink4); }
.si-locked [data-ico]{ width:15px; height:15px; }
.si-special{ display:block; text-align:center; font-size:11px; color:var(--acc-2); margin-top:4px; }

/* ── подсказка после мини-игры ── */
.hint-revealed-panel{ display:flex; gap:10px; align-items:flex-start; margin-top:6px;
  padding:11px 13px; border-radius:var(--rl); background:var(--acc-dim); border:1px solid rgba(240,169,58,.25); }
.hrp-icon{ font-size:16px; }
.hrp-text{ font-size:12.5px; color:var(--ink2); line-height:1.5; }

/* ── оверлей результата ── */
.result-overlay{ position:absolute; inset:0; z-index:8; border-radius:var(--r2xl);
  background:linear-gradient(160deg, rgba(20,24,34,.96), rgba(8,10,16,.98));
  -webkit-backdrop-filter:blur(8px); backdrop-filter:blur(8px);
  display:flex; flex-direction:column; align-items:center; justify-content:center; gap:18px;
  padding:30px 24px; text-align:center; animation:roIn .4s cubic-bezier(.22,1.1,.36,1) both; }
@keyframes roIn{ from{ opacity:0; transform:scale(.94); } to{ opacity:1; transform:none; } }
.ro-stamp-text{ font-family:'Unbounded',sans-serif; font-weight:800; font-size:24px; letter-spacing:2px;
  color:var(--acc-2); text-shadow:0 0 20px var(--acc-glow); }
.ro-text{ font-size:15px; color:var(--ink2); line-height:1.6; }
.ro-rewards{ display:flex; gap:10px; flex-wrap:wrap; justify-content:center; }
.ro-chip{ padding:8px 14px; border-radius:var(--rfull); font-size:13px; font-weight:800; border:1px solid var(--glass-line); }
.ro-xp{ color:var(--acc-2); background:var(--acc-dim); }
.ro-cr{ color:var(--gem); background:rgba(107,224,255,.1); }
.ro-en{ color:var(--no); background:var(--no-dim); }
.ro-next{ margin-top:6px; }

/* ── GAME LIST (Аркады) ── */
.game-list{ display:flex; flex-direction:column; gap:12px; }
.game-row{ display:flex; align-items:center; gap:14px; cursor:pointer; padding:16px; border-radius:var(--rxl);
  background:var(--glass); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border:1px solid var(--glass-line); box-shadow:var(--sh-1); position:relative; overflow:hidden;
  transition:transform .15s ease; }
.game-row:active{ transform:scale(.985); }
.gr-stripe{ position:absolute; left:0; top:0; bottom:0; width:4px; }
.gr-s-v{ background:linear-gradient(180deg,var(--gem),var(--info)); }
.gr-icon{ font-size:34px; width:52px; text-align:center; flex:0 0 auto; }
.gr-info{ flex:1; min-width:0; }
.gr-name{ font-family:'Unbounded',sans-serif; font-weight:600; font-size:16px; }
.gr-desc{ font-size:11.5px; color:var(--ink3); margin:2px 0 8px; }
.gr-prog{ display:flex; align-items:center; gap:8px; }
.gr-bar{ flex:1; height:5px; border-radius:5px; background:rgba(255,255,255,.07); overflow:hidden; }
.gr-fill{ height:100%; border-radius:5px; background:linear-gradient(90deg,var(--gem),var(--info)); }
.gr-lvl{ font-size:11px; color:var(--ink3); font-family:'JetBrains Mono',monospace; white-space:nowrap; }
.gr-arrow{ font-size:22px; color:var(--ink4); }

/* ── HINT GAME bottom-sheet ── */
.hint-modal{
  position:fixed; left:0; right:0; bottom:0; z-index:300;
  height:92vh; border-radius:var(--r2xl) var(--r2xl) 0 0;
  background:linear-gradient(180deg,#0c0f16,#070910);
  border:1px solid var(--glass-line); box-shadow:0 -10px 50px rgba(0,0,0,.6);
  display:flex; flex-direction:column;
  transform:translateY(100%); transition:transform .4s cubic-bezier(.4,0,.2,1);
}
.hint-modal:not(.hidden){ transform:translateY(0); }
.hint-modal.hidden{ pointer-events:none; }
.hm-header{ display:flex; align-items:center; justify-content:space-between; padding:16px 18px;
  border-bottom:1px solid var(--glass-line-2); }
.hm-title{ display:flex; align-items:center; gap:8px; font-family:'Unbounded',sans-serif; font-weight:600; font-size:16px; }
.hm-title [data-ico]{ width:18px; height:18px; }
.hm-close{ border:none; cursor:pointer; background:rgba(255,255,255,.04); border:1px solid var(--glass-line-2);
  color:var(--ink2); font-family:inherit; font-weight:700; font-size:16px; padding:6px 14px; border-radius:var(--rl); }
.hm-vp{ flex:1; position:relative; overflow:hidden; }
.hm-footer{ padding:12px 18px calc(12px + var(--safeb)); border-top:1px solid var(--glass-line-2); }
.hm-footer-text{ font-size:12px; color:var(--ink3); text-align:center; }

/* ── DAILY ── */
.daily-card{ width:min(92%,360px); border-radius:var(--r2xl); padding:26px 22px; text-align:center;
  background:linear-gradient(160deg,rgba(28,33,46,.92),rgba(12,15,22,.96));
  border:1px solid var(--glass-line); box-shadow:var(--sh-2);
  display:flex; flex-direction:column; align-items:center; gap:12px; animation:roIn .4s cubic-bezier(.22,1.1,.36,1) both; }
.daily-icon{ font-size:48px; }
.daily-h{ font-family:'Unbounded',sans-serif; font-weight:700; font-size:20px; }
.daily-streak{ font-size:13px; color:var(--ink3); }
.daily-week{ display:flex; gap:6px; flex-wrap:wrap; justify-content:center; }
.dw-day{ width:34px; height:34px; border-radius:10px; display:flex; align-items:center; justify-content:center;
  font-size:12px; font-weight:700; background:rgba(255,255,255,.04); border:1px solid var(--glass-line-2); color:var(--ink3); }
.dw-day.done{ background:var(--acc-dim); border-color:rgba(240,169,58,.4); color:var(--acc-2); }
.daily-chips{ display:flex; gap:10px; }
.dc-chip{ padding:8px 14px; border-radius:var(--rfull); font-size:13px; font-weight:800; color:var(--acc-2);
  background:var(--acc-dim); border:1px solid rgba(240,169,58,.3); }

/* ── частицы / след / конфетти ── */
.swipe-trail{ position:absolute; border-radius:50%; pointer-events:none; z-index:7; }
.confetti{ position:fixed; width:9px; height:14px; z-index:400; pointer-events:none; border-radius:2px; }

EOF_SDVIG

echo "  ✦ $S/app.js"
mkdir -p $(dirname "$S/app.js")
cat > "$S/app.js" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · app.js  v5 · Dark Glass
═══════════════════════════════════════════════ */
'use strict';

/* ── глобальное состояние ──────────────────────── */
const App = {
  user:null,
  guest:false,
  token:null,
  profile:null,
  scenario:null,
  deck:[],
  cardIndex:0,
  swipeUnlocked:false,
  currentCard:null,
  pendingSwipe:null,
  flags:{},
  tab:'cases'
};

const DEFAULT_PROFILE = {
  level:1, xp:0, energy:5, maxEnergy:5, credits:0,
  casesSolved:0, streak:0, prestige:0, mapNode:0,
  skills:{ insight:1, tech:1, charisma:1, nerve:1 },
  achievements:[], dailyStreak:0, lastDaily:null, sound:true
};

/* ── DOM helpers ───────────────────────────────── */
const $  = s=>document.querySelector(s);
const $$ = s=>Array.from(document.querySelectorAll(s));
const el = (tag,cls,html)=>{ const e=document.createElement(tag); if(cls)e.className=cls; if(html!=null)e.innerHTML=html; return e; };
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const vibrate=ms=>{ try{ navigator.vibrate&&navigator.vibrate(ms);}catch(e){} };

function lsGet(k,d){ try{ const v=localStorage.getItem(k); return v==null?d:JSON.parse(v);}catch(e){return d;} }
function lsSet(k,v){ try{ localStorage.setItem(k,JSON.stringify(v)); }catch(e){} }

/* ── экраны ────────────────────────────────────── */
function showScreen(id){
  $$('.screen').forEach(s=>s.classList.remove('active'));
  const t=$('#'+id); if(t) t.classList.add('active');
}

/* ── toast ─────────────────────────────────────── */
let toastTimer=null;
function toast(title,desc,icon){
  const t=$('#toast');
  $('#toast-icon').textContent=icon||'✦';
  $('#toast-title').textContent=title||'';
  $('#toast-desc').textContent=desc||'';
  t.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer=setTimeout(()=>t.classList.remove('show'),2600);
}

function fatal(msg){
  $('#error-msg').textContent=msg||'Не удалось загрузить данные.';
  showScreen('error-screen');
}

/* ═══════════════════════════════════════════════
   SPLASH → кинематографичный переход → LOGIN
═══════════════════════════════════════════════ */
const SPLASH_BG = '/img/bg-splash.jpg';   // фон №1 (экран загрузки)
const LOGIN_BG  = '/img/bg-login.jpg';    // фон №2 (экран входа)

const wait = ms=>new Promise(r=>setTimeout(r,ms));

async function runSplash(){
  // фоны (если файлов нет — просто не покажутся, без ошибок)
  document.documentElement.style.setProperty('--splash-img',`url('${SPLASH_BG}')`);
  document.documentElement.style.setProperty('--login-img',`url('${LOGIN_BG}')`);

  const emblem=$('#splash-emblem');
  const titleRow=$('#splash-title');
  const fill=$('#splash-fill');
  const status=$('#splash-status');

  // буквы СДВИГ
  'СДВИГ'.split('').forEach(ch=>{ const s=el('span','title-letter',ch); titleRow.appendChild(s); });

  await wait(120);
  emblem.classList.add('visible');
  Sound.splashImpact();

  await wait(380);
  $$('.title-letter').forEach((l,i)=>setTimeout(()=>l.classList.add('in'),i*90));

  // прогресс загрузки — плавный, без «лагов»
  const steps=[
    [22,'Загрузка дел'],
    [48,'Сбор улик'],
    [74,'Калибровка'],
    [100,'Готово']
  ];
  for(const [w,txt] of steps){
    await wait(360);
    fill.style.width=w+'%';
    status.textContent=txt;
    if(w<100){ emblem.classList.add('pulse'); setTimeout(()=>emblem.classList.remove('pulse'),220); }
  }

  await wait(300);

  // параллельно грузим всё нужное, пока идёт переход
  const ready = preload();

  // кинематографичная вспышка + уход эмблемы (без explode)
  Sound.transition();
  const flash=$('#splash-flash');
  flash.style.transition='opacity .35s ease';
  flash.style.opacity='0.9';
  await wait(180);

  await ready.catch(()=>{});           // дождались данных
  decideEntry();                        // показываем login/main под вспышкой
  flash.style.opacity='0';
  await wait(380);
}

/* предзагрузка: профиль из кэша, сценарий */
async function preload(){
  await loadScenario().catch(()=>{});
}

/* куда заходим после сплэша */
function decideEntry(){
  // 1) Telegram Mini App
  const tg = window.Telegram && window.Telegram.WebApp;
  if(tg && tg.initData && tg.initData.length>0){
    tg.ready(); tg.expand();
    return tgWebAppLogin(tg);
  }
  // 2) сохранённая сессия
  const saved=lsGet('sdvig_session',null);
  if(saved && saved.profile){
    App.user=saved.user||null; App.guest=!!saved.guest; App.token=saved.token||null;
    App.profile=normalizeProfile(saved.profile);
    enterMain(); return;
  }
  // 3) экран входа
  showScreen('login-screen');
  initLogin();
}

/* ═══════════════════════════════════════════════
   AUTH (Вариант A: Telegram Mini App + гость)
═══════════════════════════════════════════════ */
async function tgWebAppLogin(tg){
  showScreen('login-screen');
  $('#tg-status').textContent='Вход через Telegram…';
  try{
    const res=await fetch('/api/auth/webapp',{
      method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({ initData: tg.initData })
    });
    if(!res.ok) throw new Error('auth '+res.status);
    const data=await res.json();
    App.user=data.user; App.token=data.token; App.guest=false;
    App.profile=normalizeProfile(data.profile);
    persistSession();
    enterMain();
  }catch(e){
    // не вышло — даём гостя, чтобы не блокировать
    $('#tg-status').textContent='Telegram недоступен — используйте гостевой вход';
    initLogin();
  }
}

function initLogin(){
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
};

function guestLogin(){
  App.guest=true; App.user={ id:'guest', name:'Гость', firstName:'Гость' };
  App.token=null;
  // профиль из кэша или новый
  const cached=lsGet('sdvig_guest_profile',null);
  App.profile=normalizeProfile(cached||{...DEFAULT_PROFILE});
  persistSession();
  enterMain();
}

function normalizeProfile(p){
  const n={...DEFAULT_PROFILE,...(p||{})};
  n.skills={...DEFAULT_PROFILE.skills,...(p&&p.skills||{})};
  n.achievements=Array.isArray(p&&p.achievements)?p.achievements:[];
  return n;
}

function persistSession(){
  const sess={ user:App.user, guest:App.guest, token:App.token, profile:App.profile };
  lsSet('sdvig_session',sess);
  if(App.guest) lsSet('sdvig_guest_profile',App.profile);
}

/* сохранение профиля (сервер для авторизованных, локально для гостя) */
let saveTimer=null;
function saveProfile(){
  persistSession();
  if(App.guest||!App.token) return;
  clearTimeout(saveTimer);
  saveTimer=setTimeout(()=>{
    fetch('/api/profile',{
      method:'PUT',
      headers:{'Content-Type':'application/json','Authorization':'Bearer '+App.token},
      body:JSON.stringify(App.profile)
    }).catch(()=>{});
  },800);
}

/* ═══════════════════════════════════════════════
   ВХОД В ИГРУ
═══════════════════════════════════════════════ */
function enterMain(){
  showScreen('main-screen');
  // навигацию и звук вешаем ПЕРВЫМИ — чтобы ошибка в рендере не убила меню
  bindNav();
  bindSoundBtn();
  bindTools();
  if(window.BgFx) BgFx.init();
  Icons.paint();
  try{ buildDeck(); renderCard(); dealDeck(); }catch(e){ console.error('renderCard',e); }
  try{ renderHUD(); }catch(e){ console.error('renderHUD',e); }
  try{ renderGameList(); }catch(e){ console.error('renderGameList',e); }
  try{ renderProfile(); }catch(e){ console.error('renderProfile',e); }
  try{ renderShop(); }catch(e){ console.error('renderShop',e); }
  try{ checkDaily(); }catch(e){ console.error('checkDaily',e); }
}

/* ── навигация ─────────────────────────────────── */
function bindNav(){
  const nav=document.querySelector('.bottom-nav');
  if(!nav || nav.dataset.bound) return;
  nav.dataset.bound='1';
  nav.addEventListener('click',e=>{
    const b=e.target.closest('.nb'); if(!b) return;
    const tab=b.dataset.tab; if(!tab || tab===App.tab) return;
    try{ Sound.nav(); }catch(_){}
    vibrate(8);
    App.tab=tab;
    document.querySelectorAll('.nb').forEach(x=>x.classList.toggle('active',x===b));
    document.querySelectorAll('.tab-pane').forEach(p=>p.classList.toggle('active',p.id==='tab-'+tab));
    if(tab==='map') requestAnimationFrame(()=>{ try{renderMap();}catch(_){} });
    if(tab==='profile') try{renderProfile();}catch(_){}
  });
}

function bindSoundBtn(){
  const btn=$('#sound-btn');
  if(!btn) return;
  btn.textContent=Sound.isOn()?'🔊':'🔇';
  btn.onclick=()=>{ const on=Sound.toggle(); btn.textContent=on?'🔊':'🔇'; if(on)Sound.tap(); };
}

function bindTools(){
  const bar=document.querySelector('.tools-bar');
  if(!bar || bar.dataset.bound) return;
  bar.dataset.bound='1';
  App.profile.tools = App.profile.tools || {magnify:2,file:1,hourglass:1};
  refreshTools();
  bar.addEventListener('click',e=>{
    const b=e.target.closest('.tool-btn'); if(!b) return;
    const t=b.dataset.tool;
    vibrate(8); try{Sound.tap();}catch(_){}
    if(t==='shop'){ App.tab='shop';
      document.querySelectorAll('.nb').forEach(x=>x.classList.toggle('active',x.dataset.tab==='shop'));
      document.querySelectorAll('.tab-pane').forEach(p=>p.classList.toggle('active',p.id==='tab-shop'));
      return; }
    useTool(t);
  });
}
function refreshTools(){
  const T=(App.profile&&App.profile.tools)||{};
  ['magnify','file','hourglass'].forEach(k=>{
    const el=$('#tool-'+k+'-n'); if(el){ const n=T[k]||0; el.textContent=n; el.style.display=n>0?'':'none'; }
  });
}
function useTool(t){
  const T=App.profile.tools||(App.profile.tools={});
  if((T[t]||0)<=0){ toast('Инструменты','Нет в наличии — загляни в Лавку','🛠️'); return; }
  if(t==='hourglass'){ T[t]--; addEnergy(20); toast('Песочные часы','+20 энергии','⏳'); }
  else if(t==='magnify'){ T[t]--; App.flags.hintNext=true; toast('Лупа','Подсказка активна','🔍'); }
  else if(t==='file'){ T[t]--; App.swipeUnlocked=true;
    const c=App.deck[App.cardIndex]; const card=document.querySelector('.case-card');
    if(card&&c) renderCardActions(card,c);
    toast('Досье','Свайп разблокирован','📁'); }
  refreshTools(); saveProfile();
}

/* ── HUD ───────────────────────────────────────── */
function renderHUD(){
  const p=App.profile;
  const en=$('#hud-energy'); if(en) en.textContent=p.energy;
  const cr=$('#hud-credits'); if(cr) cr.textContent=p.credits;
  const need=xpNeeded(p.level);
  const xf=$('#xp-fill'); if(xf) xf.style.width=clamp(p.xp/need*100,0,100)+'%';
  const xi=$('#xp-info'); if(xi) xi.textContent=`УР ${p.level} · ${p.xp}/${need}`;
}
function xpNeeded(lvl){ return 100+(lvl-1)*60; }

function addXP(n){
  const p=App.profile; p.xp+=n;
  let need=xpNeeded(p.level), leveled=false;
  while(p.xp>=need){ p.xp-=need; p.level++; leveled=true; need=xpNeeded(p.level); }
  if(leveled){ Sound.levelUp(); vibrate([10,40,10]);
    toast('Новый уровень','Уровень '+p.level,'⬆️');
    p.maxEnergy=5+Math.floor((p.level-1)/3); p.energy=p.maxEnergy; }
  renderHUD(); saveProfile();
}
function addCredits(n){ App.profile.credits=Math.max(0,App.profile.credits+n); if(n>0)Sound.coin(); renderHUD(); saveProfile(); }
function addEnergy(n){ const p=App.profile; p.energy=clamp(p.energy+n,0,p.maxEnergy); renderHUD(); saveProfile(); }

/* ═══════════════════════════════════════════════
   BOOT
═══════════════════════════════════════════════ */
window.addEventListener('DOMContentLoaded',()=>{
  $('#sound-btn'); // noop
  runSplash().catch(err=>{ console.error(err); decideEntry(); });
});

/* ═══════════════════════════════════════════════
   СЦЕНАРИЙ + КОЛОДА
═══════════════════════════════════════════════ */
async function loadScenario(){
  if(App.scenario) return App.scenario;
  const res=await fetch('/scenarios/detective.json');
  if(!res.ok) throw new Error('scenario '+res.status);
  App.scenario=await res.json();
  return App.scenario;
}

function buildDeck(){
  const sc=App.scenario;
  if(!sc||!sc.cards){ App.deck=[]; return; }
  App.deck=sc.cards.slice();
  App.cardIndex=App.profile.mapNode % App.deck.length;
}

/* ═══════════════════════════════════════════════
   РЕНДЕР КАРТОЧКИ ДЕЛА
═══════════════════════════════════════════════ */
/* анимация набора колоды-подложки при входе */
function dealDeck(){
  const cards=document.querySelectorAll('.stack-card');
  cards.forEach(el=>{ el.classList.remove('deal','dealt'); void el.offsetWidth; });
  cards.forEach(el=>{
    el.classList.add('deal');
    el.addEventListener('animationend',()=>{ el.classList.remove('deal'); el.classList.add('dealt'); },{once:true});
  });
}

/* премиум SVG-фоны для карточек по типу дела */
function cardBackground(type){
  // Глубокие атмосферные фоны (вдохновлено Reigns / Cultist Simulator):
  // несколько слоёв радиальных градиентов, мягкие пятна света, дымка, виньетка.
  const P={
    crime:     {base:'#1a0608',glow:'#ff5d6c',glow2:'#7a1020',spot:'#ff8a95'},
    evidence:  {base:'#04141a',glow:'#6be0ff',glow2:'#0a4a63',spot:'#9af0ff'},
    suspect:   {base:'#0e0620',glow:'#a98bff',glow2:'#3d2470',spot:'#c4aaff'},
    witness:   {base:'#04160f',glow:'#35d49b',glow2:'#0c4a32',spot:'#7af0c0'},
    revelation:{base:'#1a1404',glow:'#ffcf6b',glow2:'#7a5410',spot:'#ffe6a0'},
    ending:    {base:'#140f04',glow:'#ffcf6b',glow2:'#6a4a10',spot:'#ffe6a0'}
  }[type] || {base:'#0a0d14',glow:'#c8860a',glow2:'#5a3d08',spot:'#ffcf6b'};

  return `<svg viewBox="0 0 400 520" preserveAspectRatio="xMidYMid slice" width="100%" height="100%">
    <defs>
      <radialGradient id="bg-base-${type}" cx="50%" cy="30%" r="95%">
        <stop offset="0" stop-color="${P.glow2}" stop-opacity=".55"/>
        <stop offset="45%" stop-color="${P.base}"/>
        <stop offset="100%" stop-color="#04060a"/>
      </radialGradient>
      <radialGradient id="bg-spot-${type}" cx="50%" cy="22%" r="42%">
        <stop offset="0" stop-color="${P.spot}" stop-opacity=".5"/>
        <stop offset="100%" stop-color="${P.spot}" stop-opacity="0"/>
      </radialGradient>
      <radialGradient id="bg-glow2-${type}" cx="78%" cy="68%" r="55%">
        <stop offset="0" stop-color="${P.glow}" stop-opacity=".28"/>
        <stop offset="100%" stop-color="${P.glow}" stop-opacity="0"/>
      </radialGradient>
      <radialGradient id="bg-vig-${type}" cx="50%" cy="50%" r="75%">
        <stop offset="55%" stop-color="#000" stop-opacity="0"/>
        <stop offset="100%" stop-color="#000" stop-opacity=".6"/>
      </radialGradient>
      <filter id="bg-soft-${type}"><feGaussianBlur stdDeviation="22"/></filter>
      <filter id="bg-grain-${type}">
        <feTurbulence type="fractalNoise" baseFrequency="0.85" numOctaves="2" result="n"/>
        <feColorMatrix in="n" type="saturate" values="0"/>
        <feComponentTransfer><feFuncA type="linear" slope="0.05"/></feComponentTransfer>
        <feComposite operator="over" in2="SourceGraphic"/>
      </filter>
    </defs>
    <!-- базовый глубокий градиент -->
    <rect width="400" height="520" fill="url(#bg-base-${type})"/>
    <!-- большие мягкие световые пятна (глубина) -->
    <g filter="url(#bg-soft-${type})">
      <ellipse cx="120" cy="90" rx="130" ry="110" fill="${P.glow}" opacity=".14"/>
      <ellipse cx="320" cy="380" rx="150" ry="140" fill="${P.glow2}" opacity=".5"/>
      <ellipse cx="200" cy="250" rx="180" ry="160" fill="${P.base}" opacity=".4"/>
    </g>
    <!-- верхний прожектор -->
    <rect width="400" height="520" fill="url(#bg-spot-${type})"/>
    <!-- нижнее цветное свечение -->
    <rect width="400" height="520" fill="url(#bg-glow2-${type})"/>
    <!-- тонкая дымка-полосы для атмосферы -->
    <g opacity=".06" fill="none" stroke="${P.spot}" stroke-width="1">
      <path d="M-20 150 Q200 100 420 170"/>
      <path d="M-20 300 Q200 250 420 320"/>
    </g>
    <!-- зерно плёнки -->
    <rect width="400" height="520" filter="url(#bg-grain-${type})" opacity=".6"/>
    <!-- виньетка для глубины -->
    <rect width="400" height="520" fill="url(#bg-vig-${type})"/>
  </svg>`;
}

function renderCard(){
  const zone=$('#swipe-zone');
  zone.querySelector('.case-card')?.remove();
  if(!App.deck.length){ return; }

  const c=App.deck[App.cardIndex];
  App.currentCard=c; App.swipeUnlocked=false;

  const type=c.type||'evidence';
  const card=el('div','case-card card-enter ct-'+type);
  card.innerHTML=`
    <div class="card-bg">${cardBackground(type)}</div>
    <div class="stamp-wrap stamp-left"><div class="stamp stamp-deny-text">${c.leftStamp||'ОТКАЗ'}</div></div>
    <div class="stamp-wrap stamp-right"><div class="stamp stamp-approve-text">${c.rightStamp||'ПРИНЯТЬ'}</div></div>
    <div class="stamp-wrap stamp-up"><div class="stamp stamp-special-text">СПЕЦ</div></div>
    <div class="card-head">
      <span class="card-act">Дело №${(App.cardIndex+1).toString().padStart(3,'0')}</span>
      <span class="card-type-badge">${typeLabel(type)}</span>
    </div>
    <div class="card-divider"></div>
    <div class="card-body">
      <div class="card-icon-box">${c.icon||'🗂'}</div>
      <div class="card-case-title">${c.title||'Без названия'}</div>
      <div class="card-text">${c.text||''}</div>
    </div>
    <div class="card-actions-area" id="card-actions"></div>
  `;
  zone.appendChild(card);
  resetStamps(card);
  renderCardActions(card,c);
  bindSwipe(card,c);
  Sound.tap();
}

function typeLabel(t){
  return ({crime:'Преступление',suspect:'Подозреваемый',evidence:'Улика',
           witness:'Свидетель',revelation:'Озарение',ending:'Финал'})[t]||'Улика';
}

function renderCardActions(card,c){
  const a=card.querySelector('#card-actions');
  if(App.swipeUnlocked){
    a.innerHTML=`
      <div class="swipe-indicator swipe-unlocked">
        <span class="si-deny">◄ ${c.leftLabel||'Отказать'}</span>
        <span class="si-approve">${c.rightLabel||'Принять'} ►</span>
      </div>
      ${c.special?`<span class="si-special">▲ Свайп вверх — спецприём</span>`:''}`;
  }else{
    a.innerHTML=`
      <button class="btn-play-gems" id="play-gems">${Icons.get('gem')}<span>Найти улики</span></button>
      <div class="swipe-indicator"><span class="si-locked">${Icons.get('lock')} Свайп заблокирован</span></div>`;
    a.querySelector('#play-gems').onclick=()=>{ Sound.tap(); openHintGame(c); };
  }
}

/* разблокировка свайпа после мини-игры */
function unlockSwipe(){
  App.swipeUnlocked=true;
  vibrate(20); Sound.booster();
  const card=$('#swipe-zone .case-card');
  if(card){ renderCardActions(card,App.currentCard);
    const hint=App.currentCard.hint;
    if(hint){ const hp=el('div','hint-revealed-panel',
      `<span class="hrp-icon">🔍</span><span class="hrp-text">${hint}</span>`);
      card.querySelector('.card-body').appendChild(hp); } }
}

/* ═══════════════════════════════════════════════
   СВАЙПЫ (left / right / up = спецприём)
═══════════════════════════════════════════════ */
function bindSwipe(card,c){
  let sx=0,sy=0,dx=0,dy=0,drag=false,pid=null;
  const TH=90, UPTH=110;

  const start=(x,y)=>{
    if(!App.swipeUnlocked) return;
    drag=true; sx=x; sy=y; dx=dy=0;
    card.style.transition='none';
  };
  const move=(x,y)=>{
    if(!drag) return;
    dx=x-sx; dy=y-sy;
    const rot=dx/18;
    card.style.transform=`translate(-50%,-50%) translate(${dx}px,${dy*0.4}px) rotate(${rot}deg)`;
    card.classList.toggle('tilt-left',dx<-30);
    card.classList.toggle('tilt-right',dx>30);
    card.classList.toggle('tilt-up',c.special&&dy<-40&&Math.abs(dx)<60);
    setStampOpacity(card,dx,dy,c);
    if(window.BgFxDrag) BgFxDrag(-dx/180, -dy/180);
  };
  const end=()=>{
    if(!drag) return; drag=false;
    card.style.transition='transform .35s cubic-bezier(.4,0,.2,1), opacity .35s ease';
    if(c.special && dy<-UPTH && Math.abs(dx)<70){ flySpecial(card,c); return; }
    if(dx>TH){ flyOut(card,'right',c); return; }
    if(dx<-TH){ flyOut(card,'left',c); return; }
    card.style.transform=`translate(-50%,-50%) rotate(-.4deg)`;
    card.className='case-card ct-'+(c.type||'evidence');
    resetStamps(card);
    if(window.BgFxDrag) BgFxDrag(0,0);
  };

  // pointerdown на карточке, move/up на window — не зависим от pointer-capture
  const onDown=e=>{
    if(e.target.closest('#play-gems')) return;
    if(!App.swipeUnlocked) return;
    pid=e.pointerId;
    start(e.clientX,e.clientY);
    window.addEventListener('pointermove',onMove);
    window.addEventListener('pointerup',onUp);
    window.addEventListener('pointercancel',onUp);
  };
  const onMove=e=>{ if(pid!=null&&e.pointerId!==pid) return; move(e.clientX,e.clientY); };
  const onUp=e=>{
    if(pid!=null&&e.pointerId!==pid) return;
    end(); pid=null;
    window.removeEventListener('pointermove',onMove);
    window.removeEventListener('pointerup',onUp);
    window.removeEventListener('pointercancel',onUp);
  };
  card.addEventListener('pointerdown',onDown);
}

function setStampOpacity(card,dx,dy,c){
  const l=card.querySelector('.stamp-left'), r=card.querySelector('.stamp-right'), u=card.querySelector('.stamp-up');
  l.style.opacity=clamp(-dx/90,0,1); r.style.opacity=clamp(dx/90,0,1);
  u.style.opacity=c.special?clamp(-dy/110,0,1):0;
}
function resetStamps(card){ card.querySelectorAll('.stamp-wrap').forEach(s=>s.style.opacity=0); }

function flyOut(card,dir,c){
  const off=dir==='right'?window.innerWidth:-window.innerWidth;
  card.style.transform=`translate(-50%,-50%) translate(${off}px,40px) rotate(${dir==='right'?22:-22}deg)`;
  card.style.opacity='0';
  Sound.swipe(dir); vibrate(12);
  spawnTrail(dir);
  setTimeout(()=>resolveChoice(c,dir==='right'?'right':'left'),320);
}
function flySpecial(card,c){
  card.style.transform=`translate(-50%,-50%) translateY(-${window.innerHeight}px) rotate(-3deg)`;
  card.style.opacity='0';
  Sound.special(); vibrate([10,30,10]);
  setTimeout(()=>resolveChoice(c,'special'),320);
}

/* ═══════════════════════════════════════════════
   РЕЗУЛЬТАТ ВЫБОРА + каскад улик
═══════════════════════════════════════════════ */
function resolveChoice(c,dir){
  const branch = dir==='special' ? (c.special||c.right) : (dir==='right'?c.right:c.left);
  if(!branch){ nextCard(); return; }

  // каскад: промежуточная карточка-вопрос
  if(branch.followup){
    const fc=branch.followup; fc.type=fc.type||'revelation'; fc._followOf=c;
    App.deck.splice(App.cardIndex+1,0,fc);
  }

  applyOutcome(branch);
  showResultOverlay(branch,dir);
}

function applyOutcome(b){
  const o=b.outcome||b; const p=App.profile;
  if(o.xp) addXP(o.xp);
  if(o.credits) addCredits(o.credits);
  if(o.energy) addEnergy(o.energy);
  if(o.prestige){ p.prestige+=o.prestige; }
  if(o.skill && p.skills[o.skill]!=null) p.skills[o.skill]+=(o.skillUp||1);
  if(o.solved){ p.casesSolved++; p.streak++; advanceMap(); }
  saveProfile();
}

function showResultOverlay(b,dir){
  const card=el('div','case-card ct-revelation');
  const o=b.outcome||b;
  const ok=dir!=='left';
  card.innerHTML=`<div class="result-overlay">
      <div class="ro-stamp-text">${ok?'УЛИКА ПОЛУЧЕНА':'ВЕРСИЯ ОТКЛОНЕНА'}</div>
      <div class="ro-text">${b.result||b.text||''}</div>
      <div class="ro-rewards">
        ${o.xp?`<span class="ro-chip ro-xp">+${o.xp} XP</span>`:''}
        ${o.credits?`<span class="ro-chip ro-cr">+${o.credits} ◈</span>`:''}
        ${o.prestige?`<span class="ro-chip ro-xp">+${o.prestige} престиж</span>`:''}
      </div>
      <button class="btn btn-bronze" id="ro-next" style="max-width:200px">Дальше</button>
    </div>`;
  $('#swipe-zone').appendChild(card);
  if(ok){ Sound.approve(); if(o.solved) confetti(); } else Sound.deny();
  card.querySelector('#ro-next').onclick=()=>{ Sound.tap(); card.remove(); nextCard(); };
}

function nextCard(){
  App.cardIndex=(App.cardIndex+1)%App.deck.length;
  App.profile.mapNode=App.cardIndex;
  saveProfile();
  renderCard();
}

/* ═══════════════════════════════════════════════
   КОНФЕТТИ (золотые улики)
═══════════════════════════════════════════════ */
function confetti(){
  const colors=['#ffcf6b','#f0a93a','#6be0ff','#35d49b'];
  for(let i=0;i<28;i++){
    const c=el('div','confetti');
    c.style.left=(40+Math.random()*20)+'vw';
    c.style.top='40vh';
    c.style.background=colors[i%colors.length];
    document.body.appendChild(c);
    const ang=Math.random()*Math.PI*2, dist=120+Math.random()*200;
    const ax=Math.cos(ang)*dist, ay=Math.sin(ang)*dist-200;
    c.animate([
      {transform:'translate(0,0) rotate(0)',opacity:1},
      {transform:`translate(${ax}px,${ay+window.innerHeight*0.5}px) rotate(${720*Math.random()}deg)`,opacity:0}
    ],{duration:1100+Math.random()*600,easing:'cubic-bezier(.2,.7,.3,1)'}).onfinish=()=>c.remove();
  }
}
function spawnTrail(dir){
  const zone=$('#swipe-zone'); const r=zone.getBoundingClientRect();
  for(let i=0;i<8;i++){ const t=el('div','swipe-trail');
    const sz=4+Math.random()*8; t.style.width=t.style.height=sz+'px';
    t.style.background='rgba(240,169,58,'+(0.3+Math.random()*0.3)+')';
    t.style.left=(r.width/2+(dir==='right'?40:-40)+Math.random()*30-15)+'px';
    t.style.top=(r.height/2+Math.random()*60-30)+'px';
    zone.appendChild(t);
    t.animate([{opacity:.8,transform:'scale(1)'},{opacity:0,transform:'scale(0) translateY(20px)'}],
      {duration:500+Math.random()*300}).onfinish=()=>t.remove(); }
}

/* ═══════════════════════════════════════════════
   КАРТА ПРОГРЕССА
═══════════════════════════════════════════════ */
const CHAPTERS=[
  {title:'Глава I · Пропавший экспонат', levels:5},
  {title:'Глава II · Тень музея',        levels:6},
  {title:'Глава III · Ночной свидетель', levels:6},
  {title:'Глава IV · Двойная игра',      levels:7},
  {title:'Глава V · Финал',              levels:6}
];

function totalLevels(){ return CHAPTERS.reduce((s,c)=>s+c.levels,0); }

function renderMap(){
  const inner=$('#map-inner'); const svg=$('#map-path');
  inner.querySelectorAll('.map-node,.map-chapter').forEach(e=>e.remove());

  const total=totalLevels();
  const scroll=$('#map-scroll');
  const W=inner.clientWidth || (scroll&&scroll.clientWidth) || window.innerWidth || 360;
  const rowH=104, padTop=70;
  const H=padTop+total*rowH+100;
  inner.style.height=H+'px';
  svg.setAttribute('viewBox',`0 0 ${W} ${H}`);

  const cur=App.profile.mapNode||0;
  // три колонки: змейка идёт лево→центр→право→центр→лево…
  const cols=[W*0.26, W*0.5, W*0.74];
  const colPattern=[0,1,2,1];     // плавный зигзаг без пересечений
  let idx=0, pts=[];

  CHAPTERS.forEach((ch,ci)=>{
    const unlocked = idx<=cur;
    // заголовок главы — по центру, со своим отступом
    const chTopY = padTop + idx*rowH - 46;
    const head=el('div','map-chapter'+(unlocked?'':' mc-locked'),
      `<div class="mc-title">${ch.title}</div><div class="mc-sub">${ch.levels} уровней</div>`);
    head.style.left='50%'; head.style.top=chTopY+'px';
    inner.appendChild(head);

    for(let l=0;l<ch.levels;l++){
      const y=padTop+idx*rowH;
      const x=cols[colPattern[idx%colPattern.length]];
      pts.push({x,y,idx});
      const state = idx<cur?'done':idx===cur?'current':'locked';
      const node=el('div','map-node '+state);
      if(state==='locked') node.innerHTML=Icons.get('lock');
      else node.textContent=(idx+1);
      node.style.left=x+'px'; node.style.top=y+'px';
      const myIdx=idx;
      if(state!=='locked'){
        node.onclick=()=>{ Sound.tap(); vibrate(8);
          if(state==='current') goToTab('cases');
          else toast('Пройдено','Уровень '+(myIdx+1)+' завершён','✓'); };
      }else{
        node.onclick=()=>{ try{Sound.error();}catch(_){} vibrate(15); toast('Закрыто','Пройдите предыдущие','🔒'); };
      }
      inner.appendChild(node);
      idx++;
    }
  });

  // плавный путь через все точки (Catmull-Rom → кривые Безье, без пересечений)
  let pathD = pts.length ? `M ${pts[0].x} ${pts[0].y}` : '';
  for(let i=0;i<pts.length-1;i++){
    const p0=pts[i-1]||pts[i], p1=pts[i], p2=pts[i+1], p3=pts[i+2]||p2;
    const c1x=p1.x+(p2.x-p0.x)/6, c1y=p1.y+(p2.y-p0.y)/6;
    const c2x=p2.x-(p3.x-p1.x)/6, c2y=p2.y-(p3.y-p1.y)/6;
    pathD+=` C ${c1x} ${c1y}, ${c2x} ${c2y}, ${p2.x} ${p2.y}`;
  }
  const prog = total>1 ? cur/(total-1) : 0;
  svg.innerHTML=`
    <defs>
      <linearGradient id="mg" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0" stop-color="#ffcf6b"/><stop offset="1" stop-color="#b3741c"/>
      </linearGradient>
    </defs>
    <path d="${pathD}" fill="none" stroke="rgba(255,255,255,.08)" stroke-width="7" stroke-linecap="round"/>
    <path d="${pathD}" fill="none" stroke="url(#mg)" stroke-width="4.5" stroke-linecap="round"
          stroke-dasharray="100000" stroke-dashoffset="${100000*(1-prog)}" pathLength="100000"
          style="transition:stroke-dashoffset .6s ease"/>`;
}

function advanceMap(){ App.profile.mapNode=Math.min(totalLevels()-1,(App.profile.mapNode||0)+1); }
function goToTab(t){ $('.nb[data-tab="'+t+'"]')?.click(); }

/* ═══════════════════════════════════════════════
   ПРОФИЛЬ
═══════════════════════════════════════════════ */
const SKILLS=[
  {k:'insight', icon:'🧠', name:'Проницательность', desc:'Видеть скрытое'},
  {k:'tech',    icon:'🔬', name:'Технологии',       desc:'Анализ улик'},
  {k:'charisma',icon:'🎭', name:'Харизма',          desc:'Разговорить свидетеля'},
  {k:'nerve',   icon:'🔥', name:'Хладнокровие',     desc:'Спецприёмы'}
];
const ACHIEVEMENTS=[
  {k:'first',  icon:'🎖', title:'Первое дело'},
  {k:'streak5',icon:'🔥', title:'Серия 5'},
  {k:'gem500', icon:'💎', title:'Магнат'},
  {k:'lvl10',  icon:'⭐', title:'Ветеран'},
  {k:'special',icon:'⚡', title:'Спецагент'},
  {k:'map1',   icon:'🗺', title:'Глава I'}
];

function renderProfile(){
  const p=App.profile, u=App.user||{};
  const name=u.firstName||u.name||'Агент';
  $('#prof-av').textContent=(name[0]||'С').toUpperCase();
  $('#prof-name').textContent=name;
  $('#prof-arch').textContent=archetype(p);
  $('#prof-id').textContent='#'+String(u.id||'000000').slice(-6).padStart(6,'0');
  $('#st-cases').textContent=p.casesSolved;
  $('#st-streak').textContent=p.streak;
  $('#st-prestige').textContent=p.prestige;
  $('#st-lvl').textContent=p.level;

  const sl=$('#skill-list'); sl.innerHTML='';
  SKILLS.forEach(s=>{
    const lv=p.skills[s.k]||1; const cost=lv*40;
    const row=el('div','skill-row',`
      <div class="sk-icon">${s.icon}</div>
      <div class="sk-body"><div class="sk-name">${s.name}</div><div class="sk-desc">${s.desc}</div>
        <div class="sk-bar"><div class="sk-fill" style="width:${clamp(lv/10*100,5,100)}%"></div></div></div>
      <div class="sk-side"><div class="sk-lv">ур ${lv}</div>
        <button class="up-btn" ${p.credits<cost?'disabled':''}>+${cost}◈</button></div>`);
    row.querySelector('.up-btn').onclick=()=>{
      if(App.profile.credits<cost) return;
      addCredits(-cost); App.profile.skills[s.k]=lv+1;
      Sound.booster(); vibrate(10); toast('Навык повышен',s.name+' ур '+(lv+1),'⬆️');
      renderProfile();
    };
    sl.appendChild(row);
  });

  const ag=$('#ach-grid'); ag.innerHTML='';
  ACHIEVEMENTS.forEach(a=>{
    const earned=p.achievements.includes(a.k);
    ag.appendChild(el('div','ach-cell'+(earned?' earned':''),
      `<div class="ach-ico">${a.icon}</div><div class="ach-title">${a.title}</div>`));
  });
}
function archetype(p){
  const m=Math.max(...Object.values(p.skills));
  const k=Object.keys(p.skills).find(x=>p.skills[x]===m);
  return ({insight:'Аналитик',tech:'Криминалист',charisma:'Переговорщик',nerve:'Силовик'})[k]||'Новичок';
}
function unlockAch(k){ if(!App.profile.achievements.includes(k)){ App.profile.achievements.push(k);
  Sound.win(); toast('Достижение',ACHIEVEMENTS.find(a=>a.k===k)?.title||'','🏆'); saveProfile(); } }

/* ═══════════════════════════════════════════════
   МАГАЗИН
═══════════════════════════════════════════════ */
const SHOP=[
  {k:'energy', icon:'⚡', name:'Энергия', desc:'+3 энергии', price:30,
    buy(){ addEnergy(3); }},
  {k:'hint',   icon:'🔍', name:'Подсказка', desc:'Открыть свайп', price:50,
    buy(){ if(!App.swipeUnlocked) unlockSwipe(); }},
  {k:'shuffle',icon:'🔀', name:'Перетасовка', desc:'Сменить дело', price:20,
    buy(){ nextCard(); }},
  {k:'booster',icon:'💥', name:'Бустер-бомба', desc:'Для аркады', price:40,
    buy(){ App.profile.boosters=(App.profile.boosters||0)+1; saveProfile(); }}
];
function renderShop(){
  const g=$('#shop-grid'); g.innerHTML='';
  SHOP.forEach(it=>{
    const item=el('div','shop-item',`
      <div class="si-icon">${it.icon}</div>
      <div class="si-name">${it.name}</div>
      <div class="si-desc">${it.desc}</div>
      <div class="si-price">${it.price} ◈</div>`);
    item.onclick=()=>{
      if(App.profile.credits<it.price){ Sound.error(); toast('Мало кредитов','Нужно '+it.price+' ◈','✗'); return; }
      addCredits(-it.price); it.buy(); Sound.coin(); vibrate(10);
      toast('Куплено',it.name,'🛍'); renderShop();
    };
    g.appendChild(item);
  });
}

/* ═══════════════════════════════════════════════
   ЕЖЕДНЕВНЫЙ БОНУС
═══════════════════════════════════════════════ */
function checkDaily(){
  const p=App.profile; const today=new Date().toDateString();
  if(p.lastDaily===today) return;
  const yest=new Date(Date.now()-864e5).toDateString();
  p.dailyStreak = (p.lastDaily===yest)?(p.dailyStreak+1):1;
  p.lastDaily=today;
  const reward=20+Math.min(p.dailyStreak,7)*10;
  setTimeout(()=>showDaily(p.dailyStreak,reward),700);
  addCredits(reward); saveProfile();
}
function showDaily(streak,reward){
  const bg=$('#daily-modal');
  const days=Array.from({length:7},(_,i)=>`<div class="dw-day${i<streak?' done':''}">${i+1}</div>`).join('');
  bg.innerHTML=`<div class="daily-card">
    <div class="daily-icon">🎁</div>
    <div class="daily-h">Ежедневный бонус</div>
    <div class="daily-streak">Серия входов: ${streak} ${streak>=7?'🔥':''}</div>
    <div class="daily-week">${days}</div>
    <div class="daily-chips"><span class="dc-chip">+${reward} ◈</span></div>
    <button class="btn btn-bronze" id="daily-ok" style="max-width:220px">Забрать</button>
  </div>`;
  bg.classList.remove('hidden'); Sound.daily();
  bg.querySelector('#daily-ok').onclick=()=>{ Sound.coin(); vibrate(10); bg.classList.add('hidden'); };
  bg.onclick=e=>{ if(e.target===bg) bg.classList.add('hidden'); };
}

/* ═══════════════════════════════════════════════
   HINT GAME (match-3) — мост к match3.js
═══════════════════════════════════════════════ */
function openHintGame(card){
  const modal=$('#hint-modal');
  modal.classList.remove('hidden');
  const mission = card.mission || pickMission();
  $('#hint-footer').textContent=mission.label;
  if(window.BgFx) BgFx.pause();
  if(window.Match3){
    Match3.start($('#hint-vp'), {
      mission,
      boosters:App.profile.boosters||0,
      onWin:()=>{ modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); unlockSwipe(); },
      onLose:()=>{ /* остаётся закрытым */ }
    });
  }
  $('#hint-close').onclick=()=>{ Sound.tap(); modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); Match3&&Match3.stop(); };
}
function pickMission(){
  const M=[
    {type:'score', target:600, moves:14, label:'Набери 600 очков за 14 ходов'},
    {type:'color', color:0, target:12, moves:16, label:'Собери 12 красных улик'},
    {type:'clear', target:20, moves:18, label:'Очисти 20 ячеек'},
    {type:'combo', target:3,  moves:15, label:'Сделай 3 каскада подряд'}
  ];
  return M[Math.floor(Math.random()*M.length)];
}

/* ── главная вкладка-переход для кнопки карты ── */
window.goToTab=goToTab;

EOF_SDVIG

echo ""
echo "✅  Готово!"
echo "  git add -A && git commit -m \"fix: swipe first-touch, thick border, deck anim, deep card bg, tools lower\" && git push"
