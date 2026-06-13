#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  СДВИГ · deploy.sh — уровень+деньги вверху, инструменты вниз,
#  лампа в match3, премиум-фоны карточек
# ═══════════════════════════════════════════════════════════════
set -e
S="src/main/resources/static"
echo ""
echo "✨  СДВИГ — HUD, инструменты, фоны карточек…"
echo ""
echo "  ✦ $S/index.html"
mkdir -p $(dirname "$S/index.html")
cat > "$S/index.html" << 'EOF_SDVIG'
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">
<meta name="theme-color" content="#07090d">
<title>СДВИГ</title>
<link rel="stylesheet" href="/style.css">
<link rel="stylesheet" href="/card-design.css">
<script src="https://telegram.org/js/telegram-web-app.js"></script>
<script src="https://cdn.jsdelivr.net/npm/phaser@3.80.1/dist/phaser.min.js"></script>
<script>window.SDVIG_BOT_USERNAME="sdvig_game_bot";</script>
</head>
<body>

<!-- фон Phaser (никогда не ловит клики) -->
<div id="bg-fx"></div>

<!-- ══ SPLASH ══ -->
<div id="splash-screen" class="screen active">
  <div class="splash-scene">
    <div class="splash-emblem" id="splash-emblem">
      <div class="emblem-inner"><span class="emblem-letter">С</span></div>
    </div>
    <div class="splash-title-row" id="splash-title"></div>
    <div class="splash-progress-wrap">
      <div class="splash-track"><div class="splash-fill" id="splash-fill"></div></div>
      <div class="splash-status" id="splash-status">Инициализация</div>
    </div>
  </div>
  <div class="splash-flash" id="splash-flash"></div>
</div>

<!-- ══ LOGIN ══ -->
<div id="login-screen" class="screen">
  <div class="login-wrap">
    <div class="login-header">
      <div class="login-badge">С</div>
      <div class="login-h1">СДВИГ</div>
      <div class="login-tagline">Детективное агентство</div>
    </div>
    <div class="login-card">
      <div class="login-card-label">Вход</div>
      <div class="tg-widget-area" id="tg-widget-area"></div>
      <div class="tg-tip" id="tg-status">Загрузка способов входа…</div>
      <div class="divider">или</div>
      <button class="btn btn-outline" id="guest-btn" type="button">Войти как гость</button>
      <div class="login-hint">Гостевой прогресс хранится на этом устройстве.</div>
    </div>
  </div>
</div>

<!-- ══ ERROR ══ -->
<div id="error-screen" class="screen">
  <div class="err-center">
    <div class="err-icon">⚠️</div>
    <div class="err-title">Что-то пошло не так</div>
    <div class="err-msg" id="error-msg">Не удалось загрузить данные.</div>
    <button class="btn btn-bronze" onclick="location.reload()" style="max-width:200px">Перезапустить</button>
  </div>
</div>

<!-- ══ MAIN ══ -->
<div id="main-screen" class="screen">

  <div class="top-hud">
    <div class="th-level">
      <div class="th-lvl-badge"><span id="hud-level">1</span></div>
      <div class="th-xp">
        <div class="th-xp-track"><div class="th-xp-fill" id="xp-fill" style="width:0%"></div></div>
        <div class="th-xp-info" id="xp-info">0 / 100 XP</div>
      </div>
    </div>
    <div class="th-money">
      <span class="th-coin" data-tico="coin"></span>
      <span id="hud-credits">0</span>
    </div>
    <button class="snd-btn" id="sound-btn" type="button">🔊</button>
  </div>

  <div class="tab-area">

    <div class="tab-pane active" id="tab-cases">
      <div class="swipe-zone" id="swipe-zone">
        <div class="stack-card sc3"></div>
        <div class="stack-card sc2"></div>
        <div class="stack-card sc1"></div>
      </div>
      <div class="tools-bar" id="tools-bar">
        <button class="tool-btn" data-tool="magnify" title="Лупа — подсветит важную улику">
          <span class="tool-ico" data-tico="magnify"></span>
          <span class="tool-badge" id="tool-magnify-n">2</span>
        </button>
        <button class="tool-btn" data-tool="file" title="Досье — пропустить мини-игру">
          <span class="tool-ico" data-tico="file"></span>
          <span class="tool-badge" id="tool-file-n">1</span>
        </button>
        <button class="tool-btn" data-tool="hourglass" title="Песочные часы — +20 энергии">
          <span class="tool-ico" data-tico="hourglass"></span>
          <span class="tool-badge" id="tool-hourglass-n">1</span>
        </button>
        <button class="tool-btn tool-shop" data-tool="shop" title="Купить инструменты">
          <span class="tool-ico" data-tico="plus"></span>
        </button>
      </div>
    </div>

    <div class="tab-pane" id="tab-map">
      <div class="map-scroll" id="map-scroll">
        <div class="map-inner" id="map-inner">
          <svg class="map-path-svg" id="map-path"></svg>
        </div>
      </div>
    </div>

    <div class="tab-pane" id="tab-games">
      <div class="pane-hd">
        <div class="pane-title">Аркады</div>
        <div class="pane-sub">Тренируй навыки — открывай свайпы дел</div>
      </div>
      <div class="game-list" id="game-list"></div>
    </div>

    <div class="tab-pane" id="tab-profile">
      <div class="profile-hero">
        <div class="profile-av" id="prof-av">С</div>
        <div>
          <div class="profile-name" id="prof-name">Агент</div>
          <div class="profile-arch" id="prof-arch">Новичок</div>
          <div class="profile-id" id="prof-id">#000000</div>
        </div>
      </div>
      <div class="stats-row">
        <div class="sg"><div class="sg-val" id="st-cases">0</div><div class="sg-lbl">Дел</div></div>
        <div class="sg"><div class="sg-val" id="st-streak">0</div><div class="sg-lbl">Серия</div></div>
        <div class="sg"><div class="sg-val" id="st-prestige">0</div><div class="sg-lbl">Престиж</div></div>
        <div class="sg"><div class="sg-val" id="st-lvl">1</div><div class="sg-lbl">Уровень</div></div>
      </div>
      <div class="pane-hd" style="margin-top:6px"><div class="pane-title" style="font-size:16px">Навыки</div></div>
      <div class="skill-list" id="skill-list"></div>
      <div class="pane-hd" style="margin-top:18px"><div class="pane-title" style="font-size:16px">Достижения</div></div>
      <div class="ach-grid" id="ach-grid"></div>
    </div>

    <div class="tab-pane" id="tab-shop">
      <div class="pane-hd">
        <div class="pane-title">Лавка</div>
        <div class="pane-sub">Трать кредиты с умом</div>
      </div>
      <div class="shop-grid" id="shop-grid"></div>
    </div>

  </div>

  <nav class="bottom-nav">
    <button class="nb active" data-tab="cases"><span data-ico="cards"></span><span class="nb-lbl">Дела</span></button>
    <button class="nb" data-tab="map"><span data-ico="map"></span><span class="nb-lbl">Карта</span></button>
    <button class="nb" data-tab="games"><span data-ico="gem"></span><span class="nb-lbl">Аркады</span></button>
    <button class="nb" data-tab="profile"><span data-ico="agent"></span><span class="nb-lbl">Агент</span></button>
    <button class="nb" data-tab="shop"><span data-ico="bag"></span><span class="nb-lbl">Лавка</span></button>
  </nav>
</div>

<!-- ══ HINT GAME SHEET ══ -->
<div class="hint-modal hidden" id="hint-modal">
  <div class="hm-header">
    <div class="hm-title"><span data-ico="gem"></span><span>Найди улики</span></div>
    <button class="hm-close" id="hint-close" type="button">✕</button>
  </div>
  <div class="hm-vp" id="hint-vp"></div>
  <div class="hm-footer"><div class="hm-footer-text" id="hint-footer">Собери комбинацию, чтобы разблокировать свайп</div></div>
</div>

<!-- ══ TOAST / OVERLAYS ══ -->
<div class="toast" id="toast">
  <div class="toast-icon" id="toast-icon">✦</div>
  <div><div class="toast-title" id="toast-title">Уведомление</div><div class="toast-desc" id="toast-desc"></div></div>
</div>
<div class="modal-bg hidden" id="daily-modal"></div>

<script src="/icons.js"></script>
<script src="/sound.js"></script>
<script src="/phaser-bg.js"></script>
<script src="/games/match3.js"></script>
<script src="/app.js"></script>
<script src="/games/detective-mahjong.js"></script>
<script src="/games/torn-letter.js"></script>
<script src="/games/crime-board.js"></script>
<script src="/games/arcade.js"></script>
</body>
</html>

EOF_SDVIG

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
  bottom:calc(var(--navh) + var(--safeb) + 8px);
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
.stack-card{
  position:absolute; top:50%; left:50%;
  width:min(86%,360px); height:62%;
  border-radius:var(--r2xl);
  background:var(--glass); border:1px solid var(--glass-line-2);
  pointer-events:none;
}
.sc1{ transform:translate(-50%,-50%) translateY(10px) scale(.965); opacity:.7; }
.sc2{ transform:translate(-50%,-50%) translateY(20px) scale(.93);  opacity:.45; }
.sc3{ transform:translate(-50%,-50%) translateY(30px) scale(.895); opacity:.25; }

/* ── активная карточка ── */
.case-card{
  position:absolute; top:50%; left:50%;
  transform:translate(-50%,-50%) rotate(-.4deg);
  width:min(86%,360px); min-height:62%;
  display:flex; flex-direction:column;
  padding:22px 20px 18px;
  border-radius:var(--r2xl);
  /* многослойное тёмное стекло с тёплым отливом */
  background:
    linear-gradient(155deg, rgba(38,34,28,.30), transparent 40%),
    linear-gradient(160deg, rgba(26,30,42,.88), rgba(10,12,18,.94));
  -webkit-backdrop-filter:blur(calc(var(--glass-blur) + 6px)) saturate(1.2);
  backdrop-filter:blur(calc(var(--glass-blur) + 6px)) saturate(1.2);
  border:1px solid rgba(255,255,255,.10);
  /* объёмная тень + золотой ободок + внутренний блик */
  box-shadow:
    0 30px 70px -12px rgba(0,0,0,.75),
    0 8px 24px -6px rgba(0,0,0,.5),
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
.card-bg{ position:absolute; inset:0; border-radius:inherit; overflow:hidden; z-index:0; opacity:.92; }
.card-bg svg{ display:block; width:100%; height:100%; }
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
  try{ buildDeck(); renderCard(); }catch(e){ console.error('renderCard',e); }
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
/* премиум SVG-фоны для карточек по типу дела */
function cardBackground(type){
  const A={
    crime:    {c1:'#3a0e12',c2:'#1a0508',ac:'#ff5d6c'},
    evidence: {c1:'#0e2a33',c2:'#06141a',ac:'#6be0ff'},
    suspect:  {c1:'#241040',c2:'#0e0620',ac:'#a98bff'},
    witness:  {c1:'#0e3325',c2:'#061a12',ac:'#35d49b'},
    revelation:{c1:'#3a2c0a',c2:'#1a1404',ac:'#ffcf6b'},
    ending:   {c1:'#2a2410',c2:'#141005',ac:'#ffcf6b'}
  }[type] || {c1:'#1a1e2a',c2:'#0a0d14',ac:'#c8860a'};

  // тематический паттерн
  let pattern='';
  if(type==='crime'){
    // силуэт мелового контура тела + брызги
    pattern=`<path d="M120 230 q-30 -10 -20 -50 q5 -25 30 -20 q10 -40 35 -25 q25 -50 50 -15 q30 -5 20 35 q25 15 5 45 q10 35 -30 30 q-20 25 -50 5 q-30 20 -40 -20 z" fill="none" stroke="${A.ac}" stroke-width="2" opacity=".12"/>
      <circle cx="80" cy="120" r="3" fill="${A.ac}" opacity=".25"/><circle cx="250" cy="90" r="4" fill="${A.ac}" opacity=".2"/><circle cx="270" cy="280" r="2.5" fill="${A.ac}" opacity=".22"/>`;
  } else if(type==='evidence'){
    // отпечаток пальца
    pattern=`<g fill="none" stroke="${A.ac}" stroke-width="1.6" opacity=".14">
      ${[...Array(7)].map((_,i)=>`<ellipse cx="200" cy="200" rx="${30+i*16}" ry="${40+i*18}" transform="rotate(${i*4} 200 200)"/>`).join('')}
    </g>`;
  } else if(type==='suspect'){
    // силуэт головы в профиль
    pattern=`<path d="M150 90 q60 -10 70 50 q5 40 -10 70 q-5 30 -40 35 l5 40 -60 0 q5 -50 -10 -70 q-25 -30 -15 -85 q10 -45 60 -40z" fill="none" stroke="${A.ac}" stroke-width="2" opacity=".13"/>`;
  } else if(type==='witness'){
    // глаз
    pattern=`<g fill="none" stroke="${A.ac}" stroke-width="2" opacity=".14">
      <path d="M90 200 q110 -90 220 0 q-110 90 -220 0z"/><circle cx="200" cy="200" r="42"/><circle cx="200" cy="200" r="18" fill="${A.ac}" opacity=".3"/></g>`;
  } else if(type==='revelation'||type==='ending'){
    // лучи-вспышка
    pattern=`<g stroke="${A.ac}" stroke-width="2" opacity=".12">
      ${[...Array(12)].map((_,i)=>{const a=i*30*Math.PI/180;return `<line x1="200" y1="200" x2="${200+Math.cos(a)*180}" y2="${200+Math.sin(a)*180}"/>`;}).join('')}</g>
      <circle cx="200" cy="200" r="30" fill="${A.ac}" opacity=".15"/>`;
  } else {
    // папка/документы по умолчанию
    pattern=`<g fill="none" stroke="${A.ac}" stroke-width="1.6" opacity=".12">
      <rect x="120" y="120" width="160" height="200" rx="8" transform="rotate(-8 200 220)"/>
      <rect x="130" y="100" width="160" height="200" rx="8" transform="rotate(4 200 200)"/>
      <line x1="150" y1="160" x2="260" y2="160"/><line x1="150" y1="190" x2="260" y2="190"/><line x1="150" y1="220" x2="230" y2="220"/></g>`;
  }

  return `<svg viewBox="0 0 400 480" preserveAspectRatio="xMidYMid slice" width="100%" height="100%">
    <defs>
      <radialGradient id="cbg-${type}" cx="50%" cy="35%" r="80%">
        <stop offset="0" stop-color="${A.c1}"/><stop offset="1" stop-color="${A.c2}"/>
      </radialGradient>
      <filter id="cgrain"><feTurbulence type="fractalNoise" baseFrequency="0.9" numOctaves="2" result="n"/>
        <feColorMatrix in="n" type="saturate" values="0"/>
        <feComponentTransfer><feFuncA type="linear" slope="0.04"/></feComponentTransfer>
        <feComposite operator="over" in2="SourceGraphic"/></filter>
    </defs>
    <rect width="400" height="480" fill="url(#cbg-${type})"/>
    ${pattern}
    <rect width="400" height="480" filter="url(#cgrain)" opacity=".5"/>
    <rect width="400" height="480" fill="url(#cbg-${type})" opacity="0"/>
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
  let sx=0,sy=0,dx=0,dy=0,drag=false;
  const TH=90, UPTH=110;

  const start=(x,y)=>{ if(!App.swipeUnlocked){ return; } drag=true; sx=x; sy=y; dx=dy=0; card.style.transition='none'; };
  const move=(x,y)=>{
    if(!drag) return;
    dx=x-sx; dy=y-sy;
    const rot=dx/18;
    card.style.transform=`translate(-50%,-50%) translate(${dx}px,${dy*0.4}px) rotate(${rot}deg)`;
    card.classList.toggle('tilt-left',dx<-30);
    card.classList.toggle('tilt-right',dx>30);
    card.classList.toggle('tilt-up',c.special&&dy<-40&&Math.abs(dx)<60);
    setStampOpacity(card,dx,dy,c);
    // параллакс фона следует за свайпом
    if(window.BgFxDrag) BgFxDrag(-dx/180, -dy/180);
    if(Math.abs(dx)>TH||(c.special&&dy<-UPTH)) vibrate(6);
  };
  const end=()=>{
    if(!drag) return; drag=false;
    card.style.transition='transform .35s cubic-bezier(.4,0,.2,1), opacity .35s ease';
    if(c.special && dy<-UPTH && Math.abs(dx)<70){ flySpecial(card,c); return; }
    if(dx>TH){ flyOut(card,'right',c); return; }
    if(dx<-TH){ flyOut(card,'left',c); return; }
    // вернуть на место
    card.style.transform=`translate(-50%,-50%) rotate(-.4deg)`;
    card.className='case-card ct-'+(c.type||'evidence');
    resetStamps(card);
    if(window.BgFxDrag) BgFxDrag(0,0);
  };

  card.addEventListener('pointerdown',e=>{
    // не начинать свайп если жмём кнопку «Найти улики»
    if(e.target.closest('#play-gems')) return;
    start(e.clientX,e.clientY); card.setPointerCapture?.(e.pointerId);
  });
  card.addEventListener('pointermove',e=>move(e.clientX,e.clientY));
  card.addEventListener('pointerup',end);
  card.addEventListener('pointercancel',end);
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

echo "  ✦ $S/icons.js"
mkdir -p $(dirname "$S/icons.js")
cat > "$S/icons.js" << 'EOF_SDVIG'
/* СДВИГ · icons.js v5 — inline SVG icons */
(function(){
  const I = {
    bolt:'<path d="M13 2L4.5 13.5H11l-1 8.5L19.5 10H13l0-8z" fill="currentColor"/>',
    gem:'<path d="M6 3h12l3 6-9 12L3 9l3-6zm.8 2L5 9h4L7.5 5H6.8zm5.2 0L10 9h4l-2-4zm4.5 0H16.5L18 9h2l-1.5-4zM5.3 11l4.4 6-1.4-6H5.3zm5.2 0l1.5 7 1.5-7h-3zm5 0l-1.4 6 4.4-6h-3z" fill="currentColor"/>',
    cards:'<rect x="3" y="5" width="13" height="16" rx="2.5" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M17 7l3 .8a2 2 0 011.4 2.4l-2.6 9.6" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
    map:'<path d="M9 4L3 6.5v13L9 17l6 2.5 6-2.5v-13L15 6.5 9 4zm0 0v13m6-10.5v13" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linejoin="round"/>',
    agent:'<circle cx="12" cy="8.5" r="3.8" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M4.5 20a7.5 7.5 0 0115 0" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round"/>',
    bag:'<path d="M5 8h14l-1 12H6L5 8zm3 0a4 4 0 018 0" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linejoin="round"/>',
    lock:'<rect x="5" y="10.5" width="14" height="10" rx="2.5" stroke="currentColor" stroke-width="1.8" fill="none"/><path d="M8 10.5V8a4 4 0 018 0v2.5" stroke="currentColor" stroke-width="1.8" fill="none"/>',
    arrows:'<path d="M9 6l-4 6 4 6m6-12l4 6-4 6" stroke="currentColor" stroke-width="1.8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
    back:'<path d="M14 6l-6 6 6 6" stroke="currentColor" stroke-width="2.2" fill="none" stroke-linecap="round" stroke-linejoin="round"/>',
    star:'<path d="M12 3l2.6 5.6 6.1.8-4.5 4.2 1.2 6L12 16.9 6.6 19.6l1.2-6L3.3 9.4l6.1-.8L12 3z" fill="currentColor"/>',
    // ── премиум-инструменты ──
    magnify:'<circle cx="10.5" cy="10.5" r="6" fill="none" stroke="currentColor" stroke-width="1.8"/><path d="M15 15l5 5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/><circle cx="10.5" cy="10.5" r="3" fill="currentColor" opacity=".25"/>',
    lamp:'<path d="M9 18h6M10 21h4" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"/><path d="M12 3a6 6 0 00-3.5 10.9c.3.2.5.6.5 1V16h6v-1.1c0-.4.2-.8.5-1A6 6 0 0012 3z" fill="currentColor" opacity=".22" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/>',
    file:'<path d="M6 3h8l4 4v14a0 0 0 01 0 0H6a1 1 0 01-1-1V4a1 1 0 011-1z" fill="currentColor" opacity=".18" stroke="currentColor" stroke-width="1.8" stroke-linejoin="round"/><path d="M14 3v4h4M8.5 12h7M8.5 15.5h7M8.5 9h3" stroke="currentColor" stroke-width="1.6" stroke-linecap="round"/>',
    hourglass:'<path d="M7 3h10M7 21h10M8 3c0 4 8 5 8 9s-8 5-8 9M16 3c0 4-8 5-8 9s8 5 8 9" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/><path d="M9.5 18.5h5L12 15z" fill="currentColor"/>',
    plus:'<path d="M12 6v12M6 12h12" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>',
    coin:'<circle cx="12" cy="12" r="9" fill="currentColor" opacity=".18" stroke="currentColor" stroke-width="1.8"/><path d="M12 7v10M9.5 9.5h4a1.8 1.8 0 010 3.5h-3a1.8 1.8 0 000 3.5h4" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" fill="none"/>'
  };
  function paint(){
    document.querySelectorAll('[data-ico]').forEach(el=>{
      const k=el.getAttribute('data-ico'); if(!I[k]||el.dataset.painted)return;
      el.innerHTML='<svg viewBox="0 0 24 24" width="22" height="22">'+I[k]+'</svg>';
      el.dataset.painted='1';
    });
    document.querySelectorAll('[data-tico]').forEach(el=>{
      const k=el.getAttribute('data-tico'); if(!I[k]||el.dataset.painted)return;
      el.innerHTML='<svg viewBox="0 0 24 24" width="26" height="26">'+I[k]+'</svg>';
      el.dataset.painted='1';
    });
  }
  window.Icons={ get:k=>'<svg viewBox="0 0 24 24" width="22" height="22">'+(I[k]||'')+'</svg>', paint };
  document.addEventListener('DOMContentLoaded',paint);
})();

EOF_SDVIG

echo "  ✦ $S/games/match3.js"
mkdir -p $(dirname "$S/games/match3.js")
cat > "$S/games/match3.js" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · match3.js v5 — Canvas «Улики»
   На весь контейнер · тапы + свайпы · ходы · бустеры
═══════════════════════════════════════════════ */
(function(){
  const COLORS=[
    {a:'#ff5d6c',b:'#b3202d',pg:'#ffe8ea'}, // 0 красная книга
    {a:'#6be0ff',b:'#1f7da8',pg:'#e6f9ff'}, // 1 голубая
    {a:'#35d49b',b:'#127a52',pg:'#e3fff4'}, // 2 зелёная
    {a:'#ffcf6b',b:'#b3741c',pg:'#fff6e0'}, // 3 золотая
    {a:'#a98bff',b:'#5b3fb0',pg:'#f1ebff'}, // 4 фиолетовая
    {a:'#2b2f3a',b:'#0e1016',pg:'#f4f6fb'}  // 5 чёрная (как в референсе)
  ];
  // тематический эмблема на обложке каждой книги
  const EMBLEM=['star','sparkle','triangle','bigstar','pentagon','question'];
  const N=8; // 8×8

  let cvs,ctx,W,H,DPR,cell,ox,oy;
  let grid=[];                 // [{c,scale,dy,glow}]
  let sel=null;                // выбранная ячейка
  let anim=false, raf=null;
  let opts=null, moves=0, score=0, progress=0, combo=0, comboMax=0;
  let booster=0, boosterMode=null, lamp=2;
  let running=false;
  let particles=[];
  let last=0;

  /* ── публичный API ─────────────────────────── */
  window.Match3={
    start(container,o){
      opts=o||{}; const m=opts.mission||{type:'score',target:600,moves:14};
      moves=m.moves||14; score=0; progress=0; combo=0; comboMax=0;
      booster=opts.boosters||0; boosterMode=null; lamp=2; particles=[];
      running=true;
      try{ if(window.BgFx&&BgFx.pause) BgFx.pause(); }catch(e){}
      buildCanvas(container);
      initGrid();
      bindInput();
      loop();
      hud();
    },
    stop(){ running=false; if(raf)cancelAnimationFrame(raf);
      try{ window.removeEventListener('resize',window._m3resize); }catch(e){}
      if(cvs&&cvs.parentNode) cvs.parentNode.innerHTML='';
      try{ if(window.BgFx&&BgFx.resume) BgFx.resume(); }catch(e){} }
  };

  /* ── canvas ────────────────────────────────── */
  function buildCanvas(container){
    container.innerHTML='';
    DPR=Math.min(window.devicePixelRatio||1,2);
    cvs=document.createElement('canvas');
    cvs.style.cssText='display:block;width:100%;height:100%;touch-action:none;'+
      'pointer-events:auto;position:relative;z-index:1';
    container.appendChild(cvs);
    ctx=cvs.getContext('2d');
    resize(container);
    window._m3resize=()=>resize(container);
    window.addEventListener('resize',window._m3resize);
  }
  function resize(container){
    const r=container.getBoundingClientRect();
    W=r.width; H=r.height;
    cvs.width=W*DPR; cvs.height=H*DPR; ctx.setTransform(DPR,0,0,DPR,0,0);
    const pad=14, hudH=64;
    const avail=Math.min(W-pad*2, H-hudH-pad*2);
    cell=Math.floor(avail/N);
    ox=(W-cell*N)/2; oy=hudH+(H-hudH-cell*N)/2;
  }

  /* ── grid ──────────────────────────────────── */
  function initGrid(){
    grid=[];
    for(let i=0;i<N*N;i++) grid.push({c:rnd(),scale:1,dy:0,glow:0});
    // убрать стартовые матчи
    let guard=0;
    while(findMatches().length && guard++<60){
      findMatches().forEach(idx=>grid[idx].c=rnd());
    }
  }
  function rnd(){ return Math.floor(Math.random()*COLORS.length); }
  const idx=(x,y)=>y*N+x;
  const inb=(x,y)=>x>=0&&y>=0&&x<N&&y<N;

  /* ── поиск совпадений ──────────────────────── */
  function findMatches(){
    const set=new Set();
    // горизонталь
    for(let y=0;y<N;y++) for(let x=0;x<N-2;x++){
      const c=grid[idx(x,y)].c;
      if(c===grid[idx(x+1,y)].c && c===grid[idx(x+2,y)].c){
        set.add(idx(x,y)); set.add(idx(x+1,y)); set.add(idx(x+2,y));
        let k=x+3; while(k<N&&grid[idx(k,y)].c===c){ set.add(idx(k,y)); k++; }
      }
    }
    // вертикаль
    for(let x=0;x<N;x++) for(let y=0;y<N-2;y++){
      const c=grid[idx(x,y)].c;
      if(c===grid[idx(x,y+1)].c && c===grid[idx(x,y+2)].c){
        set.add(idx(x,y)); set.add(idx(x,y+1)); set.add(idx(x,y+2));
        let k=y+3; while(k<N&&grid[idx(x,k)].c===c){ set.add(idx(x,k)); k++; }
      }
    }
    return [...set];
  }

  /* ── ход игрока ────────────────────────────── */
  function trySwap(a,b){
    if(anim||moves<=0) return;
    const ax=a%N,ay=(a/N|0),bx=b%N,by=(b/N|0);
    if(Math.abs(ax-bx)+Math.abs(ay-by)!==1) return;
    swap(a,b);
    const m=findMatches();
    if(!m.length){ // откат
      Sound.error();
      swap(a,b);
      shakeCells([a,b]);
      return;
    }
    Sound.gemSwap(); vibrate(8);
    moves--; combo=0;
    resolveCascade();
    hud();
  }
  function swap(a,b){ const t=grid[a].c; grid[a].c=grid[b].c; grid[b].c=t; }

  /* ── каскад ────────────────────────────────── */
  function resolveCascade(){
    const m=findMatches();
    if(!m.length){ checkEnd(); return; }
    combo++; comboMax=Math.max(comboMax,combo);
    Sound.gemMatch(m.length); if(combo>1) Sound.gemCascade(combo);
    vibrate(combo>1?[6,20,6]:6);

    // очки + миссия
    const gain=m.length*30*combo; score+=gain;
    m.forEach(i=>{
      const x=i%N,y=(i/N|0);
      spawnBurst(ox+x*cell+cell/2, oy+y*cell+cell/2, grid[i].c);
      grid[i].glow=1;
      // миссии color/clear
      if(opts.mission){
        const mi=opts.mission;
        if(mi.type==='color'&&grid[i].c===mi.color) progress++;
        if(mi.type==='clear') progress++;
      }
    });
    if(opts.mission){
      const mi=opts.mission;
      if(mi.type==='score') progress=score;
      if(mi.type==='combo') progress=comboMax;
    }

    // удалить и обрушить
    anim=true;
    setTimeout(()=>{
      m.forEach(i=>grid[i].c=-1);
      collapse();
      anim=false;
      hud();
      setTimeout(()=>resolveCascade(),120);
    },140);
  }

  function collapse(){
    for(let x=0;x<N;x++){
      let write=N-1;
      for(let y=N-1;y>=0;y--){
        if(grid[idx(x,y)].c!==-1){
          if(write!==y){ grid[idx(x,write)].c=grid[idx(x,y)].c;
            grid[idx(x,write)].dy=(write-y)*cell; }
          write--;
        }
      }
      for(let y=write;y>=0;y--){ grid[idx(x,y)].c=rnd(); grid[idx(x,y)].dy=(write+2)*cell; }
    }
    Sound.gemFall();
  }

  /* ── бустер: разбить ячейку и соседей ──────── */
  function useBooster(i){
    if(booster<=0){ Sound.error(); return; }
    booster--; boosterMode=null; Sound.booster(); vibrate([10,30,10]);
    const x=i%N,y=(i/N|0); const hit=[];
    for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++){
      if(inb(x+dx,y+dy)) hit.push(idx(x+dx,y+dy)); }
    hit.forEach(k=>{ const xx=k%N,yy=(k/N|0);
      spawnBurst(ox+xx*cell+cell/2,oy+yy*cell+cell/2,grid[k].c);
      grid[k].c=-1; });
    score+=hit.length*40;
    if(opts.mission&&opts.mission.type==='clear') progress+=hit.length;
    anim=true; setTimeout(()=>{ collapse(); anim=false; resolveCascade(); hud(); },140);
  }

  /* ── конец ─────────────────────────────────── */
  function checkEnd(){
    const mi=opts.mission||{type:'score',target:600};
    const target=mi.target||600;
    if(progress>=target){ win(); return; }
    if(moves<=0){ lose(); }
  }
  function win(){ running=false; Sound.win(); vibrate([10,40,10,40]);
    overlay(true); setTimeout(()=>{ opts.onWin&&opts.onWin(); },900); }
  function lose(){ running=false; Sound.deny(); overlay(false);
    setTimeout(()=>{ opts.onLose&&opts.onLose(); },1400); }

  function overlay(ok){
    const o=document.createElement('div');
    o.style.cssText='position:absolute;inset:0;display:flex;flex-direction:column;'+
      'align-items:center;justify-content:center;gap:14px;text-align:center;'+
      'background:rgba(7,9,13,.82);backdrop-filter:blur(6px);z-index:5;'+
      'font-family:Unbounded,sans-serif;color:#f2f5fb';
    o.innerHTML=ok
      ? `<div style="font-size:54px">🔍</div><div style="font-size:22px;color:#35d49b">УЛИКИ НАЙДЕНЫ</div>
         <div style="font-size:13px;color:#b7c0d4">Очки: ${score} · Каскад x${comboMax}</div>`
      : `<div style="font-size:54px">🚫</div><div style="font-size:22px;color:#ff5d6c">ХОДЫ ЗАКОНЧИЛИСЬ</div>
         <div style="font-size:13px;color:#b7c0d4">Попробуйте ещё раз</div>`;
    cvs.parentNode.appendChild(o);
  }

  /* ── input: тап + свайп ───────────────────── */
  let down=null;
  function bindInput(){
    cvs.onpointerdown=e=>{ if(!running||anim)return;
      const c=hitCell(e); if(!c)return; down={...c,sx:e.clientX,sy:e.clientY}; };
    cvs.onpointerup=e=>{ handleUp(e.clientX,e.clientY); };
    cvs.oncontextmenu=e=>e.preventDefault();

    // ── Touch fallback (некоторые мобильные браузеры глушат pointer-события) ──
    cvs.addEventListener('touchstart',e=>{
      if(!running||anim)return;
      const t=e.changedTouches[0]; const c=hitCell(t);
      if(c) down={...c,sx:t.clientX,sy:t.clientY};
    },{passive:true});
    cvs.addEventListener('touchend',e=>{
      const t=e.changedTouches[0];
      handleUp(t.clientX,t.clientY);
      e.preventDefault();
    },{passive:false});
  }

  function handleUp(cx,cy){
    if(!running||anim||!down){ down=null; return; }
    const c=hitCell({clientX:cx,clientY:cy});
    const dx=cx-down.sx, dy=cy-down.sy;
    const dist=Math.hypot(dx,dy);
    if(boosterMode){ if(c) useBooster(c.i); down=null; return; }
    if(dist<14){ // ТАП
      if(sel==null){ sel=down.i; grid[sel].glow=.6; Sound.gemSelect(); }
      else if(sel===down.i){ grid[sel].glow=0; sel=null; }
      else { grid[sel].glow=0; const a=sel; sel=null; trySwap(a,down.i); }
    }else{ // СВАЙП
      let nx=down.x,ny=down.y;
      if(Math.abs(dx)>Math.abs(dy)) nx+=dx>0?1:-1; else ny+=dy>0?1:-1;
      if(inb(nx,ny)){ if(sel!=null){grid[sel].glow=0;sel=null;} trySwap(down.i,idx(nx,ny)); }
    }
    down=null;
  }
  function hitCell(e){
    const r=cvs.getBoundingClientRect();
    const px=e.clientX-r.left, py=e.clientY-r.top;
    const x=Math.floor((px-ox)/cell), y=Math.floor((py-oy)/cell);
    if(!inb(x,y)) return null; return {x,y,i:idx(x,y)};
  }

  /* ── частицы ───────────────────────────────── */
  function spawnBurst(x,y,c){
    const col=COLORS[c]?COLORS[c].a:'#fff';
    for(let i=0;i<6;i++){ const a=Math.random()*Math.PI*2,s=1+Math.random()*3;
      particles.push({x,y,vx:Math.cos(a)*s,vy:Math.sin(a)*s-1,life:1,col,r:2+Math.random()*3}); }
  }
  function shakeCells(arr){ arr.forEach(i=>grid[i].glow=.4); setTimeout(()=>arr.forEach(i=>grid[i].glow=0),200); }

  /* ── HUD (поверх canvas, лёгкий DOM) ───────── */
  function hud(){
    let bar=cvs.parentNode.querySelector('.m3-hud');
    const mi=opts.mission||{type:'score',target:600}; const target=mi.target||600;
    if(!bar){ bar=document.createElement('div'); bar.className='m3-hud';
      bar.style.cssText='position:absolute;top:0;left:0;right:0;height:60px;display:flex;'+
        'align-items:center;justify-content:space-between;padding:0 16px;'+
        'font-family:Manrope,sans-serif;color:#f2f5fb;z-index:4;pointer-events:none';
      cvs.parentNode.appendChild(bar); }
    const pct=Math.min(100,progress/target*100);
    bar.innerHTML=`
      <div style="text-align:left">
        <div style="font-size:10px;letter-spacing:1px;color:#7d8699;text-transform:uppercase">${mi.label||'Цель'}</div>
        <div style="width:130px;height:6px;background:rgba(255,255,255,.08);border-radius:6px;margin-top:5px;overflow:hidden">
          <div style="width:${pct}%;height:100%;background:linear-gradient(90deg,#b3741c,#ffcf6b);border-radius:6px"></div></div>
      </div>
      <div style="display:flex;gap:10px;align-items:center">
        <div style="text-align:center"><div style="font-family:Unbounded;font-weight:700;font-size:18px;color:#ffcf6b">${moves}</div>
          <div style="font-size:9px;color:#7d8699">ХОДЫ</div></div>
        <div style="text-align:center"><div style="font-family:Unbounded;font-weight:700;font-size:18px">${score}</div>
          <div style="font-size:9px;color:#7d8699">ОЧКИ</div></div>
        <button class="m3-lamp" style="pointer-events:auto;border:none;cursor:pointer;
          background:rgba(255,255,255,.06);color:#ffcf6b;
          border:1px solid rgba(240,169,58,.4);border-radius:10px;padding:6px 9px;font-weight:800;font-size:13px"
          title="Лампа: +3 хода">💡 ${lamp}</button>
        <button class="m3-boost" style="pointer-events:auto;border:none;cursor:pointer;
          background:${boosterMode?'#ffcf6b':'rgba(255,255,255,.06)'};color:${boosterMode?'#1a1206':'#ffcf6b'};
          border:1px solid rgba(240,169,58,.4);border-radius:10px;padding:6px 9px;font-weight:800;font-size:13px"
          title="Бомба: убрать книгу">💥 ${booster}</button>
      </div>`;
    const bb=bar.querySelector('.m3-boost');
    if(bb) bb.onclick=()=>{ if(booster<=0){Sound.error();return;}
      boosterMode=boosterMode?null:'bomb'; Sound.tap(); hud(); };
    const lb=bar.querySelector('.m3-lamp');
    if(lb) lb.onclick=()=>{ if(lamp<=0){Sound.error();return;}
      lamp--; moves+=3; Sound.booster&&Sound.booster(); vibrate([10,20]); hud(); };
  }

  /* ── render loop ───────────────────────────── */
  function loop(t){
    if(!running && particles.length===0){ draw(); return; }
    raf=requestAnimationFrame(loop);
    const dt=Math.min(40,(t||0)-last); last=t||0;
    // плавное падение
    for(const g of grid){ if(g.dy>0){ g.dy=Math.max(0,g.dy-cell*0.04*(dt/16)*4); }
      if(g.glow>0) g.glow=Math.max(0,g.glow-0.04); g.scale+=(1-g.scale)*0.2; }
    // частицы
    particles=particles.filter(p=>{ p.x+=p.vx; p.y+=p.vy; p.vy+=0.25; p.life-=0.03; return p.life>0; });
    draw();
  }

  function draw(){
    ctx.clearRect(0,0,W,H);
    // фон поля
    roundRect(ox-8,oy-8,cell*N+16,cell*N+16,18);
    ctx.fillStyle='rgba(18,22,32,.55)'; ctx.fill();
    ctx.strokeStyle='rgba(255,255,255,.07)'; ctx.lineWidth=1; ctx.stroke();

    for(let y=0;y<N;y++)for(let x=0;x<N;x++){
      const g=grid[idx(x,y)]; if(g.c<0) continue;
      const cx=ox+x*cell+cell/2, cy=oy+y*cell+cell/2 - g.dy;
      drawGem(cx,cy,g,(sel===idx(x,y)));
    }
    // частицы
    for(const p of particles){ ctx.globalAlpha=Math.max(0,p.life);
      ctx.fillStyle=p.col; ctx.beginPath(); ctx.arc(p.x,p.y,p.r,0,7); ctx.fill(); }
    ctx.globalAlpha=1;

    if(boosterMode){ ctx.fillStyle='rgba(240,169,58,.06)'; ctx.fillRect(0,0,W,H); }
  }

  function drawGem(cx,cy,g,selected){
    const col=COLORS[g.c];
    const s=cell*0.42*g.scale;          // полу-высота книги
    const w=s*1.55, h=s*2;              // ширина/высота обложки
    const x=cx-w/2, y=cy-h/2;
    const sp=w*0.16;                    // ширина корешка

    // glow при матче/выборе
    if(g.glow>0||selected){
      ctx.save(); ctx.globalAlpha=(selected?0.55:g.glow);
      ctx.fillStyle=col.a;
      ctx.beginPath(); ctx.arc(cx,cy,s*1.7,0,7); ctx.fill(); ctx.restore();
    }

    ctx.save();
    // тень книги
    ctx.fillStyle='rgba(0,0,0,.35)';
    bookPath(x+2,y+3,w,h,w*0.12); ctx.fill();

    // страницы (низ, белые полоски справа)
    ctx.fillStyle=col.pg;
    roundRectC(x+w*0.5,y+h*0.1,w*0.52,h*0.84,w*0.06); ctx.fill();
    ctx.strokeStyle='rgba(0,0,0,.12)'; ctx.lineWidth=1;
    for(let i=1;i<=3;i++){ const yy=y+h*0.1+ (h*0.84)*(i/4);
      ctx.beginPath(); ctx.moveTo(x+w*0.55,yy); ctx.lineTo(x+w*0.98,yy); ctx.stroke(); }

    // обложка (градиент)
    const grd=ctx.createLinearGradient(x,y,x+w,y+h);
    grd.addColorStop(0,col.a); grd.addColorStop(1,col.b);
    bookPath(x,y,w,h,w*0.12); ctx.fillStyle=grd; ctx.fill();

    // корешок (темнее) + золотые перетяжки
    ctx.fillStyle=col.b;
    roundRectC(x,y,sp,h,w*0.08); ctx.fill();
    ctx.strokeStyle='rgba(255,255,255,.18)'; ctx.lineWidth=1.2;
    ctx.beginPath(); ctx.moveTo(x+sp*1.4,y+h*0.04); ctx.lineTo(x+sp*1.4,y+h*0.96); ctx.stroke();
    ctx.fillStyle='#ffcf6b';
    for(let i=1;i<=3;i++){ const yy=y+h*(0.22*i);
      roundRectC(x-w*0.02,yy,sp*1.5,h*0.06,2); ctx.fill(); }

    // блик на обложке
    ctx.fillStyle='rgba(255,255,255,.16)';
    ctx.beginPath(); ctx.ellipse(cx+w*0.05,y+h*0.2,w*0.28,h*0.1,-0.4,0,7); ctx.fill();

    // эмблема по центру обложки
    drawEmblem(cx+w*0.12, cy, s*0.7, EMBLEM[g.c], col);

    ctx.restore();

    if(selected){
      ctx.strokeStyle='#fff'; ctx.lineWidth=2.5;
      bookPath(x,y,w,h,w*0.12); ctx.stroke();
    }
  }

  function bookPath(x,y,w,h,r){
    ctx.beginPath();
    ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r);
    ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath();
  }

  function drawEmblem(cx,cy,r,kind,col){
    ctx.save();
    ctx.fillStyle='#ffcf6b';
    ctx.strokeStyle='rgba(0,0,0,.25)'; ctx.lineWidth=1;
    if(kind==='star'||kind==='bigstar'){
      // белый овал + звезда (как в референсе)
      if(kind==='star'){ ctx.fillStyle='#fff';
        ctx.beginPath(); ctx.ellipse(cx,cy-r*0.5,r*0.6,r*0.42,0,0,7); ctx.fill(); }
      drawStar(cx,cy-(kind==='star'?r*0.5:0),(kind==='star'?r*0.28:r*0.6),5,'#ffcf6b');
    } else if(kind==='sparkle'){
      drawSpark(cx,cy,r*0.7);
    } else if(kind==='triangle'){
      ctx.beginPath(); ctx.moveTo(cx,cy-r*0.6); ctx.lineTo(cx+r*0.55,cy+r*0.45);
      ctx.lineTo(cx-r*0.55,cy+r*0.45); ctx.closePath(); ctx.fill();
    } else if(kind==='pentagon'){
      ctx.beginPath();
      for(let i=0;i<5;i++){ const a=-Math.PI/2+i*2*Math.PI/5;
        const px=cx+Math.cos(a)*r*0.6, py=cy+Math.sin(a)*r*0.6;
        i?ctx.lineTo(px,py):ctx.moveTo(px,py); }
      ctx.closePath(); ctx.fill();
    } else if(kind==='question'){
      // белый овал + звезда сверху + знак вопроса (чёрная книга)
      ctx.fillStyle='#fff';
      ctx.beginPath(); ctx.ellipse(cx,cy-r*0.7,r*0.45,r*0.32,0,0,7); ctx.fill();
      drawStar(cx,cy-r*0.7,r*0.2,5,'#ffcf6b');
      ctx.fillStyle='#ffcf6b'; ctx.font=`bold ${Math.floor(r*1.1)}px sans-serif`;
      ctx.textAlign='center'; ctx.textBaseline='middle';
      ctx.fillText('?',cx,cy+r*0.25);
    }
    ctx.restore();
  }

  function drawStar(cx,cy,r,n,fill){
    ctx.fillStyle=fill; ctx.beginPath();
    for(let i=0;i<n*2;i++){ const rr=i%2?r*0.45:r;
      const a=-Math.PI/2+i*Math.PI/n;
      const px=cx+Math.cos(a)*rr, py=cy+Math.sin(a)*rr;
      i?ctx.lineTo(px,py):ctx.moveTo(px,py); }
    ctx.closePath(); ctx.fill();
  }

  function drawSpark(cx,cy,r){
    // четырёхлучевой бриллиант-блеск
    ctx.fillStyle='#ffcf6b'; ctx.beginPath();
    ctx.moveTo(cx,cy-r); ctx.quadraticCurveTo(cx+r*0.18,cy-r*0.18,cx+r,cy);
    ctx.quadraticCurveTo(cx+r*0.18,cy+r*0.18,cx,cy+r);
    ctx.quadraticCurveTo(cx-r*0.18,cy+r*0.18,cx-r,cy);
    ctx.quadraticCurveTo(cx-r*0.18,cy-r*0.18,cx,cy-r);
    ctx.closePath(); ctx.fill();
  }

  function roundRect(x,y,w,h,r){ ctx.beginPath();
    ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r);
    ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }
  function roundRectC(x,y,w,h,r){ ctx.beginPath();
    ctx.moveTo(x+r,y); ctx.arcTo(x+w,y,x+w,y+h,r); ctx.arcTo(x+w,y+h,x,y+h,r);
    ctx.arcTo(x,y+h,x,y,r); ctx.arcTo(x,y,x+w,y,r); ctx.closePath(); }

  function vibrate(ms){ try{ navigator.vibrate&&navigator.vibrate(ms);}catch(e){} }
})();

EOF_SDVIG

echo ""
echo "✅  Готово!"
echo "  git add -A && git commit -m \"feat: level+money HUD, bottom tools, lamp in match3, premium card bg\" && git push"
