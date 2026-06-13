#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  СДВИГ · deploy.sh — фон-кабинет, карта-путь, тулбар, книги-match3
#  Запускай из корня репозитория:  bash deploy.sh
# ═══════════════════════════════════════════════════════════════
set -e
S="src/main/resources/static"
echo ""
echo "📚  СДВИГ — новый фон, карта, инструменты, книги…"
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

  <div class="tools-bar" id="tools-bar">
    <button class="tool-btn" data-tool="magnify" title="Лупа — подсветит важную улику">
      <span class="tool-ico" data-tico="magnify"></span>
      <span class="tool-badge" id="tool-magnify-n">2</span>
    </button>
    <button class="tool-btn" data-tool="lamp" title="Лампа — +ход в Самоцветах">
      <span class="tool-ico" data-tico="lamp"></span>
      <span class="tool-badge" id="tool-lamp-n">3</span>
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

  <div class="tab-area">

    <div class="tab-pane active" id="tab-cases">
      <div class="swipe-zone" id="swipe-zone">
        <div class="stack-card sc3"></div>
        <div class="stack-card sc2"></div>
        <div class="stack-card sc1"></div>
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

/* премиум-панель инструментов вместо старого topbar */
.tools-bar{
  flex:0 0 auto;
  display:flex; align-items:center; justify-content:center; gap:10px;
  padding:calc(8px + var(--safet)) 14px 8px;
  background:linear-gradient(180deg, rgba(8,10,16,.7), transparent);
  position:relative; z-index:20;
}
.tool-btn{
  position:relative; width:50px; height:50px; border-radius:16px;
  display:flex; align-items:center; justify-content:center;
  background:var(--glass-2); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border:1px solid rgba(255,207,107,.22); cursor:pointer; color:var(--acc-2);
  box-shadow:0 6px 18px -6px rgba(0,0,0,.6), inset 0 1px 0 rgba(255,255,255,.1);
  transition:transform .12s ease, border-color .2s ease;
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
  App.profile.tools = App.profile.tools || {magnify:2,lamp:3,file:1,hourglass:1};
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
  ['magnify','lamp','file','hourglass'].forEach(k=>{
    const el=$('#tool-'+k+'-n'); if(el){ const n=T[k]||0; el.textContent=n; el.style.display=n>0?'':'none'; }
  });
}
function useTool(t){
  const T=App.profile.tools||(App.profile.tools={});
  if((T[t]||0)<=0){ toast('Инструменты','Нет в наличии — загляни в Лавку','🛠️'); return; }
  if(t==='hourglass'){ T[t]--; addEnergy(20); toast('Песочные часы','+20 энергии','⏳'); }
  else if(t==='magnify'){ T[t]--; App.flags.hintNext=true; toast('Лупа','Подсказка активна','🔍'); }
  else if(t==='lamp'){ T[t]--; App.flags.extraMove=true; toast('Лампа','+1 ход в Самоцветах','💡'); }
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
function renderCard(){
  const zone=$('#swipe-zone');
  zone.querySelector('.case-card')?.remove();
  if(!App.deck.length){ return; }

  const c=App.deck[App.cardIndex];
  App.currentCard=c; App.swipeUnlocked=false;

  const type=c.type||'evidence';
  const card=el('div','case-card card-enter ct-'+type);
  card.innerHTML=`
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
    plus:'<path d="M12 6v12M6 12h12" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>'
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

echo "  ✦ $S/phaser-bg.js"
mkdir -p $(dirname "$S/phaser-bg.js")
cat > "$S/phaser-bg.js" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · phaser-bg.js v10 — фон кабинета (вкладка Дела)
   ✓ Фото-фон bg-cases.jpg (детективный стол)
   ✓ ОЧЕНЬ плавный параллакс (сглаживание + ease)
   ✓ Лёгкое свечение лампы (дышит)
   ✓ Пылинки
   ✓ input:false
═══════════════════════════════════════════════ */
(function(){
  let game=null, scene=null, paused=false;
  let tx=0, ty=0;            // целевое смещение
  let cx=0, cy=0;            // текущее (сглаженное)
  let vx=0, vy=0;            // скорость (для пружинного сглаживания)
  let frame=0;

  function boot(){
    if(game || !window.Phaser) return;
    game = new Phaser.Game({
      type:Phaser.AUTO, parent:'bg-fx',
      width:window.innerWidth, height:window.innerHeight,
      transparent:true, banner:false,
      input:false,
      fps:{ target:60, forceSetTimeOut:false },   // выше fps = плавнее параллакс
      render:{ powerPreference:'high-performance', antialias:true },
      scale:{ mode:Phaser.Scale.RESIZE },
      scene:{ preload, create, update }
    });
    const kill=()=>document.querySelectorAll('#bg-fx canvas,#bg-fx *')
      .forEach(c=>{ c.style.pointerEvents='none'; c.style.touchAction='none'; });
    [40,200,600].forEach(t=>setTimeout(kill,t));
    if(window.DeviceOrientationEvent){
      window.addEventListener('deviceorientation',e=>{
        if(e.gamma!=null) tx=Math.max(-1,Math.min(1,e.gamma/40));
        if(e.beta!=null)  ty=Math.max(-1,Math.min(1,(e.beta-45)/40));
      },{passive:true});
    }
  }

  function preload(){ this.load.image('cases','/img/bg-cases.jpg'); }

  function create(){
    scene=this;
    const W=scene.scale.width, H=scene.scale.height;

    const photo=scene.add.image(W/2,H/2,'cases').setDepth(0);
    const scl=Math.max(W/photo.width,H/photo.height)*1.14;
    photo.setScale(scl);
    scene._photo=photo;

    // мягкая виньетка для глубины
    const vig=scene.add.graphics().setDepth(1);
    vig.fillStyle(0x000000,0.32); vig.fillRect(0,0,W,H*0.16);
    vig.fillStyle(0x000000,0.42); vig.fillRect(0,H*0.82,W,H*0.18);
    const steps=12;
    for(let i=0;i<steps;i++){ const a=0.4*(1-i/steps)*0.5;
      vig.fillStyle(0x000000,a);
      vig.fillRect(i*(W*0.04),0,W*0.04,H);
      vig.fillRect(W-(i+1)*(W*0.04),0,W*0.04,H); }

    // свечение лампы (правый край, как на фото)
    makeLamp(scene,W);
    const glow=scene.add.image(W*0.82,H*0.42,'lampG').setDepth(2)
      .setBlendMode(Phaser.BlendModes.ADD).setAlpha(0.4);
    scene._glow=glow;
    scene.tweens.add({targets:glow,alpha:0.24,duration:3400,yoyo:true,repeat:-1,ease:'Sine.easeInOut'});

    // пылинки
    scene._dust=[];
    for(let i=0;i<20;i++) scene._dust.push({
      x:W*(0.4+Math.random()*0.5), y:H*(0.25+Math.random()*0.5),
      r:0.6+Math.random()*1.6, vx:(Math.random()-0.5)*0.08, vy:-0.04-Math.random()*0.08,
      a:0.08+Math.random()*0.3, ph:Math.random()*6.28 });
    scene._dustG=scene.add.graphics().setDepth(3).setBlendMode(Phaser.BlendModes.ADD);

    scene._W=W; scene._H=H;
  }

  window.BgFxDrag=function(nx,ny){ tx=Math.max(-1,Math.min(1,nx)); ty=Math.max(-1,Math.min(1,ny)); };

  function makeLamp(scene,W){
    if(scene.textures.exists('lampG')) return;
    const s=Math.round(W*0.9), g=scene.make.graphics({x:0,y:0,add:false}), c=s/2;
    for(let i=22;i>0;i--){ const r=(s/2)*(i/22); g.fillStyle(0x6bd47a,0.03*(1-i/22)+0.003); g.fillCircle(c,c,r); }
    for(let i=12;i>0;i--){ const r=(s/4)*(i/12); g.fillStyle(0xfff0c0,0.05*(1-i/12)+0.004); g.fillCircle(c,c,r); }
    g.generateTexture('lampG',s,s); g.destroy();
  }

  function update(_,dt){
    if(!scene||paused) return;
    const W=scene._W, H=scene._H;
    const f=Math.min(dt/16.67,2);   // нормализация к 60fps

    // ── Пружинное сглаживание (критотерий плавности) ──
    // вместо линейного lerp используем spring-damper: очень мягко и без рывков
    const stiff=0.012, damp=0.82;
    vx += (tx-cx)*stiff*f; vy += (ty-cy)*stiff*f;
    vx *= Math.pow(damp,f); vy *= Math.pow(damp,f);
    cx += vx*f; cy += vy*f;

    if(scene._photo){ scene._photo.x=W/2-cx*22; scene._photo.y=H/2-cy*16; }
    if(scene._glow){ scene._glow.x=W*0.82-cx*30; scene._glow.y=H*0.42-cy*20; }

    frame++;
    if(scene._dustG){
      const g=scene._dustG; g.clear(); const t=frame*0.018;
      for(const d of scene._dust){
        d.x+=d.vx; d.y+=d.vy;
        if(d.y<H*0.18){ d.y=H*0.7; d.x=W*(0.4+Math.random()*0.5); }
        const tw=d.a*(0.55+0.45*Math.sin(t+d.ph));
        g.fillStyle(0xffe6b0,tw);
        g.fillCircle(d.x-cx*26, d.y-cy*18, d.r);
      }
    }
  }

  window.BgFx={
    init:boot,
    pause(){ paused=true; if(game){ try{game.loop.sleep();}catch(e){}
      const c=document.querySelector('#bg-fx canvas'); if(c)c.style.visibility='hidden'; } },
    resume(){ paused=false; if(game){ try{game.loop.wake();}catch(e){}
      const c=document.querySelector('#bg-fx canvas'); if(c)c.style.visibility='visible'; } },
    setMood(){}
  };
  window.addEventListener('resize',()=>{ if(game) game.scale.resize(innerWidth,innerHeight); });
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
  let booster=0, boosterMode=null;
  let running=false;
  let particles=[];
  let last=0;

  /* ── публичный API ─────────────────────────── */
  window.Match3={
    start(container,o){
      opts=o||{}; const m=opts.mission||{type:'score',target:600,moves:14};
      moves=m.moves||14; score=0; progress=0; combo=0; comboMax=0;
      booster=opts.boosters||0; boosterMode=null; particles=[];
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
      <div style="display:flex;gap:14px;align-items:center">
        <div style="text-align:center"><div style="font-family:Unbounded;font-weight:700;font-size:18px;color:#ffcf6b">${moves}</div>
          <div style="font-size:9px;color:#7d8699">ХОДЫ</div></div>
        <div style="text-align:center"><div style="font-family:Unbounded;font-weight:700;font-size:18px">${score}</div>
          <div style="font-size:9px;color:#7d8699">ОЧКИ</div></div>
        <button class="m3-boost" style="pointer-events:auto;border:none;cursor:pointer;
          background:${boosterMode?'#ffcf6b':'rgba(255,255,255,.06)'};color:${boosterMode?'#1a1206':'#ffcf6b'};
          border:1px solid rgba(240,169,58,.4);border-radius:10px;padding:6px 9px;font-weight:800;font-size:13px">
          💥 ${booster}</button>
      </div>`;
    const bb=bar.querySelector('.m3-boost');
    if(bb) bb.onclick=()=>{ if(booster<=0){Sound.error();return;}
      boosterMode=boosterMode?null:'bomb'; Sound.tap(); hud(); };
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

echo "  ✦ $S/img/bg-cases.jpg (img)"
mkdir -p $(dirname "$S/img/bg-cases.jpg")
base64 -d << 'B64_SDVIG' > "$S/img/bg-cases.jpg"
/9j/4AAQSkZJRgABAQAAAAAAAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcU
FhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgo
KCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAZOA4QDASIA
AhEBAxEB/8QAHQAAAQUBAQEBAAAAAAAAAAAAAgABAwQFBgcICf/EAEwQAAEDAgQEBAMFBgQFAwMB
CQEAAhEDIQQSMUEFUWFxBhMigTKRoRQjQrHBBxUzUtHwJGLh8RYlNENyU4KSNURFYxeDc6ImVFWy
wv/EABkBAQEBAQEBAAAAAAAAAAAAAAABAgMEBf/EAC4RAQEAAgICAgIDAQACAgICAwABAhEDEiEx
E0EEURQiMmFCUiNxM4EFFUNikf/aAAwDAQACEQMRAD8A+YgTe+qQm9yCmm/NOJIi0KqcOi47wmm8
79kwtfnzTgSI5IFPfmikiZv2TWtc2skL6TKBwYEG4RAmbROl0xtMRMSnB35WlUJpHIkRonDhCCbm
TbnuibcjRFE4zv8AIJwANbwhHU33SkidI22QFa8wTzTi+tx0TDTYkfknacpjSOmiocaySkNY5jVM
HXI5IhEai3PRAgTuTrsnEDr1SaOcH+ykBcbdf7/u6KcGQRaO6UxbURqmMRtG6LSdT+gQOHW3I1gp
xuDa+g/NDz0trfRO2JP9hUOIEgn0omuJB0g7oQbHS8CeSQsZv2QSSY1kfJKZIDpB5zog0Bn++qKO
oJjRAiZOo+STC2TBtHJOCIgtjrojDQLxrzKCPTTX6FEXXgXIuTsmAuRAJTtEkjU6xsgcdYIi8W+S
QNrn5pGCLmx5pxB0mf1QG0xblqEQLCDeChaLmCRPP9U7BAJ6aopaWiYNhCQ3O5sQk1pAjQa3SEiB
BVAib/MomkTYiZ1TtgSTCRAYDeSPqiFsLmN7IpcCGgyAmixmx6iyTQQDm17oowS24KeZ6O6FDLbZ
THNIC2iIWxO5hE2zrn5aQnIkEkQevNM0AiSdLIGBJkSf75ogLEuEx9QnADRr0PVOGzIAPzVDNcS2
NPzSBLgeR0kpw2L2/VIS5xj8kAGZg3vsnDjBmR9U4BkwQdyCk3a0zaEQ4ILhryQmcsAkog2REAnS
eSa7iA09RBVDZS0XieY2TB3qEkHvZE9py3AjmlYWsCbwEBB2sWtyQgSTe8fNFERe8wSOaJov9EQL
NZkQdU5NmgwB0UgAnQBu/RM5lhOvMIBJgmATfZDrJBIEWlGINt90YDdwJ36oBF5tfoiboL21J6JN
ptLiTrExGikaJbFxNh0QRZho0knqERJvp3CIADMDbrzTgRGWI5qgAw7mSDqNkg4BxzWG0KQNgEzc
XhE5oBm3JAAcxreu8phViBmGnunyAg2ANyUwYA0nnoRsiAFQ6RaEiX2DY5IwAHEaDt+SkDRMjsJQ
RtpuO4990zg6wk3+iuta0H1EgInZDciBqZV0M3K4EQTfmrNGWg5nSTrZTeWwOunmm0SddE0HHrad
IAQOpAxJ3un+1MFhz1T+fSiRf9VRH5TQ0n9VA3zAdYEqyKjKgN4Gk8kzWsJkOA3hALBUsS+eyNr3
xc/6o2ZbloB3lO/KHXseiorvc9wibJqdJu4vMyQrDajZhrTfaEZJAktiOSgjbSgX25oXQHEQByQP
qPBOVp/p1UQp1HEbICdlvsJuoSWxqNZsi8h+bWATr0Q1MO/mJ5hQC8iNS4wLBQF4LtTpyVn7LBu7
5IHUGiPzUEE9TE6xYJ5IBttKkawSQSQeQKDyw0EkyDsoAJlpI3G+qGYAuYO52RuBIM7iyFwtobWs
UAGLkjQpauN+0pGwIJFuSR9R1uUAyNo90g+QSZt0iUUNy6DRCbC4GYz7oGzCRoPaZTNIBsL85SAB
yzF9UmxmkkRyQMHdfnomLtO50TtBG1406oT6YJInogbMTMkknnomzAA2GbdEbOufc7prBpIA1t1R
Qkk6wPdNJaTYk90gTOWdNLJT6r9tdSoFMzKYekkCJiJCIiRA1PW6E5WgwdBIsgTgbydr9E0xci/L
RPtG5vBTbAc9woAM63PRMSI0uEUjQajVNJg3HtugE7XtynRIE9dU+4j2TdLW2KB2kR8Ud5STBxAu
6/QpKCp7JbGyW5smnLt1CwCi5kJCZjfSUwMnqnjYfPmgQAvp7IpB1nSAgv1uiB115IFe26LuZ2Qd
BfZPO/sgebEC4T8gAhjWTA2RCwIMf0QIECO+6dpjSPZNBPffdI2JAN+aKOMpTg63GvNBbMbIoERH
1VBCSbAogLwLILi8apwQ1p/uUBAXixJ0hPq23ayAvgDVFoLQqpxBB5hKW7WhMDnEfkNE+WASTdAT
XdCE8Cw90DAdpHXmiFpt7kIDLR009k7GwZNkNyTPaUhJBGaOaoIiBECeqI3jKRGqjIPbbVEPwyIB
QE0wSNeyWwA07XCE3MzeUYbNO2vLcIE2bmT2BRgHrz6IWgdoMGyUGdYEwgI2aRE/qh+G4+qfMTMG
QkDrIcJiCAgJp1MQSNxonm25QhpiJSAMelw/JAWYyDqOQSgBsEG6GSHWgAG10/8AMZgoJJAJywew
0TD4ZBAkboQBNotulGX1GQqHk3kzdEHC5sT00QNvMH6JxSlkwYKAgZkkQU9sxMieqctIkTMoSIbM
e/6ICB1AiDzTiBBMHNZBaCRoBp0RAEyJueqCSDJuLp7t0P8AfRRkZZDgARqna0kTrKoIkkGbjmk0
AtsZI16pMbBMkpRmf2tyQG0HS4v2uheCYGpnbmnIc2+koQJcD8iiHaTcQZFrpgbuiSiYCSYIifkU
QYWgDna/5KiIgxcR+ScCdLgb9VJ5ZM9dbJskatuP7lAgAIIIKQsbzBCYTabDmlzAPcIh8xaCCIIu
jBJcOvTVRuBBkmDzTsLrDbqUBtaWk6e5TZiZbGiMXm/dC2BvbkUDtMCSNdCQpW1M02g7yoXToemt
09N1gDodVRI8vO0gciiY4kF245pMEza9hCM0zHPX2QRZjJygybXUjQconRA0QEbLjmiHBh0GOhQA
k68lK+Zix5IXuAJAgIqMtMC2t0waQCRA903mCDGp35Ig45gXaoClwgAn/REwm4JsLWQMu4bnmp2t
9IPYyiIKtR5100joozJGWCTz5K55YsYQ5QYygAToggZSHpLtQpYbBDWXlSsboTG9uSLM3KZa2yop
Oa4mwI520TQ/UlWXu+ICD+iic4tJBBuoBFZzQIad7EaoZqOEmPdM06TYzGqLN6enIoJqVU0yWhtw
LyE78UXCLgKu1vSYvEaJyA8ANZJ5q7CNZwdYX1hSU8SS0gkjqoRSduY+qlbSaCJsBtKByM7pL7RI
ugLIkB3Q3RwGEXty5IHnUCY1sFAJY6NdFGQTJJEE9kTnHUBATcaG2uqBgwXkwOaF5MRr/VPmyjMC
Z2ICEmIOn6oBe43kyU0amBHMJrZosBZI/CRzO35qAXAtixFrIRygT8kbgTYwdgEBPxR8oQJ17DRM
WEs/PmlM3IlM4WGo2hAhEajqJQEibC0+yOJgn66Ji2DrEXQASSDcT8kxm5JARFu57yUzh6YJ35op
t7DsmDoNx7piLJC4PJQK0QL90x02ThpJJ23ITD4hfb6IEbOsR8t0J237XT/MiT7JhaINlEMd47pA
ySXEyQmLbEJ4Mnc7oGg5evVMNJFrp22Pp5f2EzbA6AczugETuNNLJoB2mTzTmIAG6YkzcGYQPm/z
FJJrnR+Ie0pKKqTtJTTfeeae+loSG8WXMPvcXTQIPLqlc31TzGbX2QLb6WTfRKdYPySBlAVyLmyQ
B0TAOHMFPeL6dUCBAN9ZsnBPshAnYBOb7W0RTzmMmx7pa320TbR9U4FvdAY1tslFv7CEmT+qQMzr
CAhANuyIEE6G+gBQjeUgRHqufqVZVGNTzT/FP6IARNkWYAkR+qocGBBPyRSINhKjMnUotTv3VBFx
j1adEgfZMCGk6aJSTqQNkBFzjqYT3tr8kMwPpCKeZt3QEHSYj67JwSbTpZNpMwmYbXF9EBtcZ2PL
+qNtQO2gbwoyRABaEwcZsY6c1RONg3MJKaQCZmdj1Qhx3E9+acP10QEW2BBTMdE390w5GIOsJiQd
45jkgkEg39wE+UaRBmELHGbulF8REoHDtgJHON0pJBsD7IQ7YAAnXdO0wCSNrbKg2zEnbeLp3zEO
dYWQhwkiBeyfKDP9ygJwtGxskD/LsZTW235BIENnTogJxBJJkjmhbJvaNUIfc6T1RMPpN9LoHIAk
m0DVE0A2H9UAdE+kSNCiExAAgndATDf1FFLnDWEAECw2HVIuH4dVQTNDEImuiCTogaIGl+aTNbTP
UoJWeq5mU5hpkGb6aKNhgTbXdN8RAt/REGJN0TSYGYAhR7mPnsjsBAOuoP6qgy/cD5INR/d02jTA
PsE4naeRsgYueDfQcwnMmSDFk0fFc3+idp1zAn2uiEGybEjYogYkGCEues9T+aYugzv0QO0wdTY6
JzBbqYGqEkGQB+qdsAGxQICIEA/VSs1ixI10lA0AE66ap6ZIvAHSEEwzCYgQiDwJOvdRh1tATt2T
uGszPMqhjUbMQT7JNLpsOycR/L9IRXvP+iAX1I0sD0QZp9TjZSvh1zIPNBAmRMhAzS7MQWgwkc7j
bnPZSsMOGbTXVJxuRNjYxugZjTmnfdTfANigDrmxHJK7h6gYjQIBL3c9LWQgvBEuubJEEGQbDkEI
GsR/RETU3OmZ/vmnNQlsmAoWk3yx7iUzHQNzf5IJA4xl0J5ICDczHTohccxM3I6ppNjvqgcQRlPZ
O0Xvfl2UZEyLgjdMTc2ugm8wxYX/ACTGo8kiAk2CI3B1/TqkHDuJ3QDmO+myEvI5d05fO2n1TZw1
9xbogIvIOkFM8ElxKaQ6QRAQhtvfRAsvplxAiyFwAFtNNUWaDsDogc4+oumRYKBiZPq06JiQHSbQ
LBJxGQDX2goQ5wkQCNEULjIPXkkJuL8xAUg6EDUcoUZAjcR1uiAfaJ1lMdxP9EQDo125JvhMSdZl
AMA3i2yRzZQZAk68050g3OiGIEzfQuCBtb3O1ynBvBBkcglIBBjTZNo6eSKAxFrzcISZJE97SiIg
HSdkxJ3j5KBmwTIJHvumMkkJxrYa7JSRYGNzA0QNJgQYQkuImendO2xsnBF9O6iAvHq/JLQEiyd0
7adLoDEzli95QO4z7CLlDEN7bopicrmwmnUzM6wgTjB023QmdvZOJvBQWDbfJAiedoHyTAxMJTHe
ZCYyBbTmoDExaflKSYAARAMb3CSCrNyCleJ1HdMUtrfNc1PF7/RLUkzZIEapDKRJMj6opxA1Tggg
wLlCNwPmnBtPZQIaxoU4OkfJNqYlODoBbqgYG19+iR1EnZIxv3S3seqBSIN+miV7zpzSAEcuSfco
GH0RixGs9E1j/olpOoCA2HXl2SLpmG+3JB8uSeYFp6Io5EyJhNMzI/1QWDbCesp+/wA1QYAO590Q
gzqdyUE3m3YJBx3N02DkamSEV7EyoQ4KQE5TGvOFdggZOhsdkTYAIuN+SjBt3KfMT/WFRJJaI20T
SdOWyBpN+RSkxM25BUSAncT9UmE7/khzSbiZ2RE2JtKA2vIuCImNICRNyXR/XoowbIgbSDHe6olD
rbbRITjUmLDoo2kQdD2Th0kj6oJGwGmQG7X2Cb1EmHXQj0kCRIiyefTdwnkgcAA6n+iLNBh1x15I
RDTf5apyYuDY+8oDBggXmU7RLXACJFoGqBrm7zfbdPyAII3PNAdiNUIgOPqMiyQs4SZH6p56ztCo
TBmBlokndEBoRcIQQJkaieyQBMiSNEBgusDv0/NFNgYETPugZBN49kYcADOvSyAg90xA6GNU95AJ
B3gbJiQTJiNUvTl5HrogJpAa72ETqiaQTGpF1CBc6e6IvJi0QqCLrGwnmEbS2ACLHkJUYcATmkjZ
OajLHUk9kQ8tl0TI6pBvpJACDNfQSDdJpAHqMlBIC6SRBTkGSDEdEFjJBmdhqkI5zb9UDjcZhG55
omkCS4QO6dpBmbSNx/cJMLYMka25qoa+XnbVKL+o/IqSGhtvmmaBMTbmgZtri955lOwENM+o8k0a
21sJSNwCdYsgkGWTmgnnKaB1G5QMi8mO6cOvYC2xQO0uB3kc9lKCbzJ5qIOGXqJvuj1HIaiyApzN
Ma6Ig7KLX2uojd0E2nWEJkkiIKolLthtblCQIA3+ajEEGCDAT5Wg2kjYaIDD3aem30REmBNvoomg
nkYR04Ji0/kgNoMiBZEMxjMR8lFOsEjmnEXBPcmyA8w2MxZA28xedyk7YyTa0BBqbEgBBJECLj9U
JMO0uLwmkwdPkhDnXMT1RD6kCAI6XCYjlcHrqnGkZSY6pB1gCNeaKRiATMDmUqg1Jtok0zz9/wCq
cGXTq3ogAB3MCTskbb3NplJxH83qQHY/MoHcTBB/JO4mZDjbmg1FyQDsiAGgNt+aIcz0QkkG09Oi
ftr2TMub3AUDWN5hAZvMEIzl2MbC6GBeNuiBhFpMfoEtCdhogfLfa4Th3IXCKUZXCJJOiZwBLrm3
1KY8hp9UwA1mEBObMS4/NAQASGu03lML6xPdHLTp7AoAym4HKdbKMuBzSDryRyATpohka7RZA8zZ
2u0FR2m5MncIuen9/qmMTfQoGIhpBkjVDAJ3ElHNjve0ICbG11A02Ibzsd0pkXAhOBMjZCYvJ+aB
jqefW4KVomTISaQBsfzTRAnQxZRDSbQB+SA2tcSjMTMwE2g2KAZuTFwnE6nnpolGh1KZ0TO/0RSn
WSeaZznQbgx13RNs0mb8ioyNeagYmDtz6JrW+dkp1IsLHsU2a9vZAYJ5kdEkLYixSUFUdk4MHTW6
Q3MJrCeiwHaPdLa/uZSkWnRKQZKiniBf6pTJSPVOG62OiBrSdSiEidYnVDv03TgBA8SbhNIj6po5
n5JbR9EDjTSE5MGd+iEaWv2TgoH3JskPcptE4v0EIEIhOIg2m9kOhiUhcRb2RYNM0WtMJtIP5pC5
21QPAnp1TjTfRMAP70SBRRDSZnskNTHJNJN7gzunseSBwDBMf0TggAoMwi+iMEjS3dWArduaI77O
OqCd+STyJMwrsOI5o26zqBclRWCKSTz3tsrsHMm2qTI6TKjnW5lPmibxuO6bRMQNNE/OFC0yB8UI
xBFlVSRpLu1kUge+6hJIjWBzSJvEElUTsIynUdE1gVEDymJRcy4EduSImaRuLASU7TtAJH92UIcL
mbp80nURpYILAHWJ35og0ZTJtNgoBLScp90mmbSZhBOL+onfVKIA3OluahJg2JvsbJwfVN/bRUSt
a0yCQSiAbMRdREkjU3JAhOCRY66oDBzGZ/qlaQPw/wB3UYdEzr1RNdcGdtkEhjXW2pTNIDdfpogD
ideydombG14QSWh1rJSSHGJJQBwAOmiEnLlLfa+qCVrg6dQYmE7RAMiNvdCHEuDbxzhM2bkGQLmS
qD7uyz0/VFYWEz+SHQ8+YCLLcj1WjZEEwiTtGpm3ZM3eLckwOUXTZjmaOZlBK1wzDLMzrzTXF/ne
EAJGg6jZPLgdI9lUGSHNsRY2TNM6EA9SgBOaYk9kUENBdfoNUBNGXkd+yIQ28zO6CWj/AMuSIenk
IsJ0QE31AgdrpCWyJzW00TAyYJlLKHc+6A5naXfkhLTOxGt0gWzcxKeIEB1jrBuqGAIbI1nXknyS
65ggaTohfcgNkxrdOIk668kBWygEosoy3N1HI03hMCIAO42QSgtOpvyRtO/9lRCS4ZRrrCEG5uBG
yCVzgQBMaC6EPytk681HMAk2vBlM0jSZ5IJgTJMZRznVIBpIFoKjBAF+eycQQBuEBZJbcxa8pOaG
ke22iTXQNLj5IS+AZ15woCv8OkbIHEc7AappJM3GmtpTjSARaVQ1uY5i8owIAuNbCUAOQa67lDJe
ZjQ8kBmdLHum0vYfmhDTzt3Q6H0wf1QSiLkkjc20SlrbRYjZRyWi82QOdYjlzQSES2IHJMIEgXB3
lRAgCxlyImDrc3soEGybgyhdGW2u/ZC58usNDebJsxibnsJQOLzJtO6EaGb30lC42GsckRJBMRA1
kboGfY215oCCBzHPknOm0JgB16oE4kjYEbfqmBgB0WP0TubBi3uhdBEmRF+ygcCZgfJNlJnpqmu5
pIBsE0GBogcDUCQOyYkhptbryTGxIMoSbHZAREkyIm8pzebxvBKHT4svKEtNIP6qBpaLb6dk29gZ
OwSaQGk2gbIJsSgIi8ct0B+I6+yUnnbkmOtu6gcm0C0aJCLgb/VNBDyBr1TEi5tI1RDztqCEJAdE
QZSj0yNAkToSCAdkDEAk8pQExunOsOGgTGwnZFH6r2nqEkIEWyj3KSIrgAki0wmuZSmEu265qcR3
TjvrvyQgcinB10RTjqfmn5QLwmTtJHZQKbjfsn27Jve6YG0xdAotsUhPMpa3uU8EaIF0M33KWklI
3KedTZAwGspAA9E8prnTUbIHi2uqY3JkylMJCdtdrIpx2JS00Onsm+SeIGo6IFzTi5IJ6pCZt9Qn
uJ522QMQ7c9LpWiTdOOpkEpRM/ogaR/U804hoM32TCwsn7gSii57phr6e8hI6xadSkBHt9FQ4tG3
6pwdYvG6EA790pJ301QPfX9dUpItp+aUjldMI2QECSNZ7IribnumBtISsNYhUEJym8xaE92u11UZ
Nz6razunG5kxrdUE2TqTdEHG8xfdRzy7Ip5Em26A5JNzCfMLibCwQZsuhM9kJdYxY9Nk2JrwLm6k
Y6BrfRVmgzI11lEHEfp3V2LDSLzB6FJrnEEiOygDiCCOSIE6jQ8wrtE4OwNxomJmBeVCHWt80bHz
8OqCTMTuByhPmDhe8WhRtd6IbpHJNMg3jsgmDoMAgiI5ow4QAQP6qAmeh5ImOdsBFpKokgFpNx+S
eIN/i/VRCwN7HrumaBMC/PqgkJIJOx0RsBI9RMHmoQb2Omqdptc/6oJ5A0k/REHSZkjndVnGATMg
R2TtJ02i6bRO06QR0sntBkmLG6jk5DMS3pqkHkyAASNeiomphwuJsPkl6tTprJQNcYHITfVMXGdY
OiCQk5yCcxA5IpMzMc1FNjB7FO0nKLC/T++SCRuZ2n4fyRZgRYC31UbHAMOknVDoY0vsLwEBh1iJ
1EQjBOhP991CX2hum/dGDqCC6AqiUuM3NzogJEaROyjLo7HY3TxE7eyCQOg2iAkDI0vzCBpuTcnc
p5kWce0oDudUzDJJAIsEBdHXlKFps7LdBO1xDgZgfJMCBYkEbKPPBgTzunzFxkbhARl7tDdIQDA0
0hRtfLRrrqnzR0B5hAR0EC0bJF0utvshDsoM2GspXv305ICaTDidEJMs6a6qM5ogxewhODF5M7oJ
cwBMm5nWybMNCZ2sVFJI1vulc63H5oJXwGxmsmZY/EbKMH0CRYBPDgLWIHPZBKHQ3kgDoFiBN781
G52U2N40TmDPMoCmx5ae6QtY/VR5j+HTWeiRcJMie5QES25n2CEls/ELIScw9OosmL5jsIKByZJi
40TTa95IshLhZwIHZIv6XEXU2H2toNEwJIkGOoKBxA9UGEzi6bC2qbBGYukHQyQL80BkDr1TfhzW
jogMkA7aTCYEzBHuSo5NwdRqkCb2m3JNiTPe3aUxda5UZzEENEApmnYT0UByTcGekwmnWTNt0MwS
Bqdk8E79oQIEZjIB3SkDbLumNpymehGqCWkGUDk2aJulILjqREWQ6NB2B3unzeygcgkmL8yE2gEu
mU0zobapuYvrqgXPqnB3A6ygmNSYSBBHT9EQ4kyNUnEm5Gu6Yi15HZD7mT1RTzcgj2TToYHuhO8f
7JgYUEzRa2b2lJRsflbE/mkgg7pTre6EGE/NYDnW2qVih10SBi6aBzrCcGZn80AKUpo2O239E07/
AJIQfdNOqaNjBOkpxAB1QTtzSB6po2OZCQ5oQROyQMCyaNjneUw2vPuhBSBTRtIDrKQmDoOiinWU
4J6gppdpQQBbSJTbKMFPNrJo2kBkQDCV9AbKPNrz5pB155po2kjSZ9k4jmog602Snv3TRtId5j2C
dpG8gdFFN908/LZXRtI0g7pe/wAgo55Jw75qaNpJMi6QJkTH9EAfAhPn7zumjYud0gTzvzlR5xpt
uln/ADV0bS62dZPPpIBi6hFS3MovMN/6ppdpJtY90h/d9FHmGkJZx2PRNG0l7iQTzStc/QKIPTh0
i+gshtM3mUpAtH1UJfN0g8z1+aaNpc3KAnaYNiomvsICWcdPdU2nkRcfJIvN5MCVAHyeRFu6drrG
PaUNpp0JMlO1xGkEqDOATeydro67XVFptQncR+Sed3H6Ks14teOUbog8Ab3ugnaQJ9N9jKJz87RA
AtAUIdLbdzKJpmSTbWVRMNDJBKdpEQJFouo2uG5mUYIzCTG4HugIGHkgkbFC0wPTZJx9Tom+3RBm
DmjSOcIDzGTI2RiBByweQUYd/KTB3KIOB00PIICa4xdo/vknDi38NuyYmzrmYjuVGHAi2/NBN5kz
aNwTqk1wIvJQhw1kO3TDUwrsShw2ABPJI1C34YJ/mKjpuFpgAXglIP5iDO2ybRITO+nNIloaI+Q2
UQeC0xbTVMCBckjlfRNiYVDp6QNynD8rYAn3sq8+ogAkHkE7HxY6nmJTZpNIDiXA84CcPBMEWCha
+JJJ5dQiDszYGWI2TYla/YD09SnFRsAAAbW3UJdNpgjaEmusTB7hNiXOI20jmhz+mAI6/wBFG1xy
QSkXhzSDNk2aSteN+aIVJGul73UM2GaTJ35pi/fNHtMJs0sB4uIgG+uqHPygW9+6g8zUG/SNE4qR
Imb3CbNJ81oaCCiGUwLyQq4qmAWmItCMVI0t21TZoRcIIAEzqTqmBneZ3lRuqQTBtE6aFMagaTA1
iybNJg8wemsJSJMgEaKBr/WCDbnOydzwWkTadZ+ibNJi4FhuB2Sz2BvreFVkaTba6c1CCL9oTYmz
QSXAHkhc8SdDJUWdxt72TAxB2PJNosMeJIPzQmq43gdARCga6LTB0tyRBz4y2OybVKXxMgkoCYm+
8zCAEmZGkSmfUJMO1PJEEHfyiDqSkSCJ9jfZA0uuJ/VMHGJtogkJMnQnqUwvN491HnFoty6JyRmE
k8uqgOQJnL7IHG0kz7IMxEz9Us0tGgi6BB1xy/LujDwLNEb2UTibg9kg6JMXOt0EgvBBtumBMWiO
qHPaLd5QkmdbjedUEgJcLzP92Taz6oQh1xrZDmN49pQSOggkk32TTc8uqjA0mx3CeTB5Tz1QKYED
X80gRvJm8Jj8zKAmAbIJC4mbTCGeYSDrydUxIAk3jlZA4d8tEiY90EwEznf7Toogp+aaRGiAuSzT
P6IHJ157IUxcOkJpRUgcQILklEDFpPsUlBHKeUKW3NRBSkDZCkCgKUgUKSAgeaUoQkqCBsnQSkoC
BTyhlLmqClKUMpTsgeU4KGUggOUhugBTygKUpQgpSgKU89kAOuqSApSmJQpT0QFOoSm5QpT9EByn
B5ygnVJAU6pAxuhmElQROyQIQzZOgKbc9k8oAY1SbKAp2tySGiFIFAWbknDrGdFHKcFAcwCbJ5vY
qMFOCgMHsnmTy9kA7pgbFBJPy6IRb5Jg6e5TjogNp2RB2vOyiHQIxqZGqKladbhGC4aXO/VRCAip
/CTHZUTNdfbvKJptLRHKTZRAkXmOSf1RE25hRUhd8XO21khMSCIKHQOmfZMRYIDzXgGInTVFNraq
KZgHbaNE5Gswb6yijDgZBvNtbJz8Lp35lRhxkEgQOXJG0SIg3P8AZQE7ILAab7hDJmxkaJnH08mp
naSRMICkSbyNyExdrBACYi9oI0CEOaND9EBZjMEewRyY19RMaKMtAJg6pEh2k87hAZMASQEQO31U
Q15/kiZA1cLSipAf5zbnCbNrBm6jcfTpb9E5jOSRaboiUP6gneEs/p02Q2MSbHRCCRYiyKkLh6om
/wAkMmD6+iEC3SYICR2iDKAs5E2v0KWaRmG6EkgwEIMQM1xuiJGeqJkcynsfhs3qo9jtunJAEXgW
ugLPe8JTLZBmDeyAG8GRysija99d0DZo12vPNOHATM+6EX0vPNNP9wgIm19tYSDgTp8kO97e6e86
X0QGXgWj31TAzcGSo5ibwPzTXJkjVBJmHP3hODpmcOwEqPW9+6bQWuCdOaCTNlnQlR5ss6kwmcRu
Y2THkLbayiDzEk3gpi7UE9ZQAC4TnrrNkDtdygHS95TyDeQh1JkSdUMzJkFAZPOx5TZDmAnmUwcb
Rc80gTvYQiEDH5JpifVrqmHq0SgA66anZA8mOXRImQLjbomERMdkxFthPNAcybi3QoQbSCICcQAe
eyEkCdLICBAEXkc07iDMGJPJADpcJXG/1QOSZ/RMTY89ZTTI3CRIQKeyeboNo3S53+aApH9hDIA5
piYNxdCTcxoiCJHNCTdDKGeyAp+SYnVDKXNQPKU3umSnVA49/ZJNrv8ARJACSeE0KBJJ4KUFUMkl
BTwVAyfZKCkAgZIJ4SAKBJBKClBQIFIJQkAVQkkoT3ugSZKCnAKBJSlBungoGSShPBQMEkgCnAPJ
Aw0S/RPBSym6BJJZTySDSgZOnylLKUDCyWqfKUoPdAgmTgHZIA8lQpS+qcNN0sp6oGlJOGn2Synu
gbbmkE+U8kspugQMJJBruSeCUDTZONU2U9U+UnZAgibbdNlMpwYRUjTrHzKMEc7bwogduSNrr3hB
JI357otbC8qIdynEgOk/NBJIvvPJOTcxzugJ5j5FMOWnvoijuCeZMwNUh7g/mhEEm4RSTINyPogP
4RpYckgTB0n6qOTEjlsk3lMBBIJgiI/RN+EXvyCAX9+aNpjU7IpFrgCCIjbomgCbCycm1iJTC8wN
LWQPcWEe6QDrCyZpgRNuyV9IJPRA4BOomUUwNIugE/qCnm9iL7IHba+kdEgBJ+Q3TZjEkJAwDIgA
woHIBbtHLonBJkW10hMDM31/qkZMC5VBxcib9EwHpgmZ+gQ6tnLPXRDBOgIRRiTIbeyewmI01QyS
dJ6oA6I2REkRJEphqbDNyn+/7KEEjcn6p51knTTRQIzAt7hOTEXE9NExMmACUgbRFu1lQpJkaEbB
PaCLd9E03EGAOqYODomTNgge4m4AG6ZpBJudUjoALjUBMXazpEQoHjNfXukGj1RtuE5cCIjRAYyb
RyQFp0EjVNHqib8wm5yY7WTGZkbc9EBDp+SEnYBI2NtdbJC2h5XVDaHqiIn5ISTzSdrpqiHIjSIS
tuQChzEdN7pF09kBFuUkiBE6FCQm00/PRMLOMbHuiCJTDcWTDkOyQ01QPcDaEwBm/dL5nsmNgOqA
osbFLnp3QzY/O6R15e6BXEJv90pka/IpXPXsgbnuOqeZE8k0E7/NMNO6BTuZlNOqQn/VMdD8kQ4P
KYQSkT0QhA8ppslB5JoMXUCSSg8khKBkk8FIBA3ySTwkgSSSUKKcJjunTIFz5J9jdMEkDpJJIpc0
kp904QNCQHJEITWhA0JxolNkge6BJQkCnlQJOOqYG5S5hUOJhMlaSlPVAJRbFCbowNeyJDNRC8IG
lFPsiw6fmUwi5StHL3QMnG6U/PukDfZFLWU41sl+adAw+aeDCQ76J9LzdQNrtqn2TQL6FPAQhh0+
aQHyT6i8JAdVVMAnAOg1RAc0wAFuSBZSmA7J4sSkALwgUQnHt80Nk8i/RAr62TaJzuAQlN+SIV4T
bHcFIGClNtpVDCxRZ8qBtyU79EQQqDrCcVY/0UKeTdVE3meqeslLzLGJUQJPUJ7xF4RRh/dOagIv
qo4MJCZKCQPM5puU4qRtfRR+o3OqUH/ZQS+ZA09kvMtcCOShE/NOJHJBN5nIGZQh97ygl3PeE17y
AVVTB8TIuELXAC10EkE3SEwdkEvm7ECORS8wDQQohMRE7pDNBGyglFS9p9kvMkyovV0SBI7oJfMB
1al5pi2ijBJ6JhI7FBKKsWb80hUEG2yi9V5KUm8IJfN5yln79VFdNJ/3QSmtI0+qc1R3BUXq1gDq
lLtwgk83a4TirylQ+rWbpXlVEoqG/Llsm8wzugE3ix5prqCQPi8EDkl5nTp3UfqSvJQSCrbQd0vN
IEEKL1T1SE9Cgk8z56JCpyHZR3Kb1IJfN2hMag1gqOSbDdMJjSyol8zmD2SFTuorndPJQHnEGwHd
LzOhUcnmkSbqIMVBBEbJvMvI1QGeYSkwqDDxF/klntcWUYJj3TgnooJM/wBEwqAGRKAymugkzgQm
zxsf6oJKZBJnt7Js8k2hBcJtigkzDef1TZ0F0roCzC6bMhkpIggZKIWCYCE40sUWF0Tc09pTAz7o
pgnH0T25JgoGS2TjfklsgYi6Scx1SQRDQpTqkkoycJJpSVDp590KSgIFIFCnCodJMkileE82TJDd
EPskCmSRRJT/ALoUkQQslNroZ1SQOkmlJA4Uu2yhGymAsiwGhTApO1QqoOUgUISlAQ0TzrdBKdFE
DqnB10QTZIFAc9Up6oOacFNApSBn8kMpgU0DBtcpTY80MxZPKaNi95SlCCkCml2KU4MbhD7hKe3Z
NGzz8k47oJTTyTRsc2TShlKUTYpsmmRuhlJBJS31RPPp0MBBR3RuEtKLPQAU8iCmEXTwIVBT1vzS
mUwA5pAaa3UBZt57JSmhNCKLNYCRGiWbXmhhKEBE7/2UgTqSUIHyS6W90BA9Eswk2HJNHySAtsqC
Bt1OqeYsDog2myQB2UBAjaU4IHdDl1JKcN1i8IHnb2lInumgzoJSA580CJETr1ThwnomA03TAWPN
AQdJiPmkHWsfomywSEspg9kB5hJMGyabd/dDlPRLKUDh3T5pZonpYoW2sQLJrICza8+qQcENt/on
AMHRUPm15FLNfQd0MJR7qAg62klLNfqEEJw2UD5u0Js08+WqaOfNLsgcEJAgpgOaUWgXQODbmEpv
Nk0apRHdA86ppnkmA57p47IhE/VNKft9UkUJPSyQ7Jzp+qUc0QMJBPZKAgUpvZPHP800IEmlK3sl
aEQpSSTf3qgWySSSBvzTt11SATjVEOiTJI0Bxumnuk74tkwRkQSlCE6B0h3TJDuoH9wkmkbz80kA
JJJIEkkkgdJMnQJJNsnQPzSTJBA6ZLZOgSSZOgSWxSSQJJJJAkgkkgQUzdFCFMPh0RYB/eUCkqal
BBVDJbJQkiHSTJwLaIEEgkkgfZIJJIEl1STKqcckgmShEOkCl1SQPM7JJkkDpDmmlKdUUkk2106I
SSSSCSiLlSVG+kyo6IklSuEMM7hG56RCUQ6f7IAOqICxv3RnZ0gICa8i/wBUgNbyi7Ft0SH9lDpq
luZJQ2IE6/okhAuIKcCRM6obPfWE9xdDB53TRO/1Q2MWmR9UgInoh7E2TAWMFDaTQmIjTVLWT+aA
d0hrqbIbSC57JEETe/RBFiZOiVzumjY7xcW5JxY6CVHNz6tEogTMIbHseiVo0QXnVOASeqGxC23c
JxpAsow0gawOae4GqGx69PdMR/lQTASEjfTlshtJcE803M/RBe9+qUdUNiE7BMLbJgDpvCaNsyGx
7JD4oG/VBGt/mlc7kobEN4/JK8kQhi/NIDqUNinWGppkzCHY3TAcjAQ2k0OiaL9EEddU+oN0Ni3K
YDbdDl1uEoj4TtqhsUm902/5oYslHWUNi6290hPJCNJlId9UNi9vZMm7lNHVDYgbbJa6oPdOB1UT
YglzQQl7obPE6BMkkFQoShNCUWUCSA90uaQCBBOBCZOEIIC+xTgaJktEaRu1TJ3alMLIwQSCQSQJ
IJJBAkk/ySQMBZICCiGibcKByLdUICM/CUh80XQALlFlCb8SkEoSIiLpAWTnVIaKxChCi5whO6BJ
JJKBJJJIHSTJIH5pJk/NUJJLVJAu6nb8KgU7DYKLAP1SYk+UqczZWBy2E8WScIbKcfCRKm1iKFI0
W1QRco6d9NtFWTEXSLbGE708SEWIQkncIJATBVDpkvySQJPzTJwgSSSUIEkkle6BJJJBAhokkNEk
CCQ0KWySCTD6lSu+A7qLD/EeymPpa66jc9Ig0wnywLg/0SB7ohMWv0VZNlk6SllgXRACf6JoACBg
BePkkG2sdUoGuiKRodEQMSCeiRbqjFpLtDryTdBcKgMo/wBEQbG0JC/w/wCycX/PS6KENGw+aeAn
Gu5S5k6690QwEmICfIOknZFJE7ymtfMTruimyyNLaBMGjVENU4d/lHfkgENiLQUwZ35SnEk63T3A
sgbKIIgkSmgbfRFrISEqBstrahLKLxbdFaBOuswmmxvsgHLv+SfKP9k4vyCUk7XGyoENnsOqfKIO
sj6op1mBe/JIEzfXmgHKN7JQATPLRODZNfSbqBstjEiE0HcI41JOmqa95FkAAW3ThsmIT3vGs6pb
G+pQMGEm6Rb8u6KTcEJhYGJkqgcsfNLLz/2RbSYCQjYqIGBzgpiBGiMC+ltUgb3E80AZUwbrJujN
yT+SYd7IBDbFLKiFhsOqQmCEDZf7KbLdFGukpueiAYslF0VyeqY9UDEWShPOuoSBN/zQNH9lNlRS
UhKAcvO6RaiHukgA2lIJ3dUw/JQJOO6HZELgosOPyT7JkUHZGkbhYpNCczBSZp+qMgi6fZOdUhoi
GATOGqduvRO4WKLoCSRSRBDRMbEJxokVA4HpKYaJx8JSGmijRh8Sk3Nyo/xI0AH4kw0RO+JMFYha
oSiQnVVDJJbJKBJJJbKhJ0ydAkkkoQLmkkkgSmb8KhUzScoi39VFhn6hMzWE9SUw10VgkcfSUmGf
9k2x3TMNjPzU0spnfH3SbqZSqfEClyJ0ViHfcJ6d2pGIufdNTMEi6ENVG91Gp3tkHcqFIUwRSUyW
yqFOspJIgDugZMiym6RabygHqknynknynl7IBSCfKdYSynkUDDdJPB2BSg7AoG7JJQUjZBJh7uVh
1287Kvh/iO6nMZSP7CN4+kbeo+qRMiABdJt557IhBmR3KMFbX5BPpql9UtEDN+E2SHIJ9oISkajc
IGNhqkI3+ifnz3TCJiLKhXIdoLbJW9k43NgO2ia4F5ugaxjlyRN0m0JAiIF+aXM6dEDyc0mISsO+
nMIb3tdP1ggcpQKYNtk9jOnPRDa6cH3CKQibwnBtqI5JrG5Ft4SbNrfRA4AmNOZlPG4FimEAnfSS
EgNYJA1QIwIjkmJgykSSJAEQlucwsUQ4vYn5pE7R7hNv0SGgMEjsgfqDcpgRlsL90400PcJDSAbF
ApJkfmlr3H1SMmJgp5gaqKYRB2CYgeyeYMiT9E02P5qhDW231S0kW2ukBmnNPXqkCeXVEMRB0S26
p55xzlNa9gbbIELOTD++qcRcm+yfYxdANtNE+xNkxkG4nskASdgAoEmJ5R3TxdMRz5oFJEJTvHdM
O0pxrYTOyBA+yYaJCL8kjEIG6XS/u6eeuyUkjlCARulzn6Jdkw/uyB/zTJ9uqXVAufVJLt+SQ/uF
AxQj/RORCWuyKZONE36oghDj80+xiI6pwLG6Y681GgnQ6JmXT8zsmZYKsmOqQTv13TNRCHxQiNwg
0KkGnRRYhSTu1SVQ7dAkdkmpHRQEND2TN0CdmhTN0UahfiCMe6D8QRjtZALviCHnKJ2oQ81YlLsh
KPRCqhkkklAkkkoVCS7Jw0kaIhTJQAkFOKM6lP5QhTZpXCQUrqZ2+qAg8lQKmb8IUIU1P4UWGqoQ
iqaJmpCj2Qs1IRCY6IR8R0RIVQW7JtgjddiBplt0ijGnRDo7XVE0WIKB4tIREwuoDYlSs+HuhqiD
KRqo9kvknSCrJDVSgW3hRBTUwCCUDsbLo+akDBEyVLRw5fDgbIxhnkjSeSzW4r5Re8pw3XluVYOG
fsLBN5L7+m2qKgDPUICWS5sFN5bwbtQvDw0nKnk8IssTy3Sy/olmtaNLJB0dgqm4FzRbsqpFyrTi
SoCwyUjNPhwMxVmJabaa3VfD/EVZAGUwdlWsfSAWCMX1QttKcbToPojAgCe3RCZ6X0hO3laU8Ago
GvE2PRMBqZ2TkCNpKbbogQjL+chLvzTjc/JA7tfqqCB1gyEp52SYPTv0SFyOXLmoFNjyTHUz/WEQ
Fu6XQfOFQ2m8zdKRztzT7Sk0HkgYe3uEnTtoEQ0Ii6QgzcBALZNt9kojXVFEf6JDS0IBnYRI+ScC
Cf0RQNTP9E0a90DfhGwPJI6GYv0T3g7lNGs6GLIE0G4/sJfhtcp40IKQ1/NAwt0PZLUaGI2TiTAF
jKQmCAY2hAwHcQnggGbfqni3OybnIKBrgmQLa3TTpzT7pdCgbqDZOdCNB8k8RqfkkABpdA0HZCBp
F1ICb6BCbgkzzQI2G/NNeHC899E533S7f7IBj5JbHTun1lDcmf7KB9p3lNr27p7g2mErTGpjUKBt
rH5Jrxb++ifsI6pX5dEDcjNuqbnYIrXJm6aD37IGsOfZNOspbEJxJKAec2SjZOBqlzQMnF00G+0J
TdA/9E202hOCl8igE8ykOv0SKWyEMEQ5oQjao1BgSbJjNynATczeFFAN4TN32TjUpm6lVgna9Ew1
RP0sh3RTO5qRpsgcLJ2aKUhiL20SRHXdJF0BuiTtCk1I6FGRt0PZM3S6dmiZtpUahvxBSc1GfwqX
ZAD9Qh3RPtCHcqxKbYpk/NMVUMkNEkkBtaCFIGx0QscAOaQf06qKMAXRC2qizu5panVNCWRAlLO3
/VRhS0W5qZmbqLDEgzB6qNwlG6nyBUbmuburEAR0MqSn8KjM7qSl8KpPZquiFmiKpp1QsuEhUjRI
Qkeu6dul0ztReURJHpPIKFmpCm1BUOjykWpGm/JJ41lMLGZRECNVUBSMSFI8S0wFGLP7qYXBUanm
K8WPJJObEgGyb3VZMFYoAFpHNQKegQBJiOqEamC/hXGqm0MCSPlKoUcRkaQBI1KmGMvJE9NVNOks
0tlpFpSDJv8Ai5Kt9rGY6QdkTcXTAN56obibL6nBx/ooMXlFAwJ68khimH9VHXrtdSLWm+vVEtil
EiZPdE1oDA467CEE2O8KRhaWkGT2VZDUYItpyUZAUtUybExzUcQNVUR0fjMqyNCInoq9C1Qq0B6S
L2WW8fSvp85RAECZgbFMDFtbpC03vuqwca3jnokTz/3REZQeYiYQXBIKoUCIPy5JGAd9E4NtpSnW
JjsgQs0nlvKAgG/sjmNB0QP37SgJtmROp0Txe08lHMHdIGBCCS0/Fbkmy2P5ICTvqm7IJO2/VMDJ
12QAGPdPfcmUBi83JTga3+qi+fuiHugkAGgM9OaUAboJMXmyWkASgk3jeUwGv9yhOsodt+iCQHS8
po135oZ1uU0TO6CS3frzSDdL+5QdD80/zQHl1IKaOUITyMymI6lBIOU6bpogGDbuo9d089Sgk0vr
A2KaRBUcnYmSiJOl/dAQEbkQni5j+ygiDef6pp1QGJix7JRcXvqgF9CUpneyAojsmmJF7oN7lKTz
KA00jSYHNB84SFzaUBwNJASi1kAj2T+90BRBjQJabwg21THsoDvJ1ndNYnZD7puSAkuqC10kBad0
o2B+SFN80BR1Si8H5IZTxqgcW/ROmCfkgEpAWSPcwnRYYao26XQC6kaLwosE35FCRIKNpOxUZFrq
KAbphZxhIJfiKrAnaShROBgoRogc7oWalF+FCPiQSRO0pJDT/VJZbRN0RHQoWp9iqwOmmbaUmawm
G6jUI7KUGyiP6owbe6BqkWhDuUT4gIJurEKEyebISqhKQUztCjVtk5R2UvhZEPluT+W7lZT3i/ZO
AdgptdK4YUsjuWisXKQtJCbNK4aRsjpvLBEFSEE7ajVCAI/ogfzNTcdUDjOlrKTQaJiNbboqu4dE
dPSyJw6Jm6FVJPJqmijZupKnVRNseisTL2kaAmeIA2KYG9k7jIKIkZooalnWCkYbIKms7JF+hatK
IXHJRsMhE3kqhniIMXUrDbUqJ2iembDpsospVRfWUEKR9wTsolSnRBxiEAR0xJ/JEE0mdfZE0PmI
vuf1UuHbNUDQLRFIE3G6LIyw12uhCcMqWEdgtUUxqALf0ReUBsLWV0umT5b4mNOSD1CRMwts0/QY
tNllvbE/7KJpBLpubJAuiVKW2MtgaaqV7YpaXkIaVQ4hN5l76hGQI0sq5NyqiTD/ABmNCrTAC1xu
RCq0P4nNW2XDj+SjePpXGp0TtHpnkmHxH+qIXEExzRgpnWYmdUiRFzMJaHbRIXaQVVMNIdACW0kp
4N4TDQ8kQ4BknXeeSjdrAUk2IFhNlG6LwgHLbW2iUdbJQdUhMaAoEJCcWAumyxKUG+vzQIE80pNr
pAIo566IEJF04n2QxuEUQJ6IEGkW3TkH2TReEiDugQmOaUHknLbm6WUmTuEDXhP6p2ITRbX/AFTg
H5IGAO51TgO90gHBOGkbmUDXE7JgDEoiOsHkE0GTzQCAbwJSGYogDOtzaEwadjcoEJjT3SuNAnDT
fS6eDESeyAYO401TQYMQjynnI/NKDzECyAY6QmggEc0QDgUiDGyAIdySgwe2iLKZmyUETOul0AwU
wDkcEmLSmgxdAw+vNNHROAZP9UoQNB1N0gCNeycDqhIIUCOnNNuY+idNqgb8oTRqnhIeyBgkOiXN
K6BQlASTt7lA40T7JC90v1QASiGiY6wiGiLDDropGiZ/RAOZ+ilYFFh2tsbqN0weSmbofzUD/hKK
jam0KcanVMdUYGfh7oBoi2Qt0RRAoTqnG6Z2iIMaX/NJM021PySUa2ENhPFilISlDRAJXkp5CUjm
ho0HmnFpSBCQIQ0RuI5IYMopF0pCGghtkg0opHNPITZoAYpQ8gbIJCeQi6GKjhvdOKjuQQAjmkCF
BJ5h5J/MN7KPMIuUpHNAfmHldIPIKCQnBHNAfmGOR5ps8aIQW80pHRFIuPNJm5Qy3Yp2RBVSHcCR
CDIZ1RkwE4c2ELIjyHmiDCRqEQc0DW6UgA30V2dYFrCBqk6mTqR3UkidUg5u6m16xGKZG904pnYy
jDmp84FgmzrAZbnfsmbTI0KkD2/RNI5ps6wOU3veEPl2spQWwUsw3KuzrEXknc2RMYWybIg4bREJ
Zh0TZ1iSi7JUDo03VsYlpJEW0lUcwPJLODy7ps1F84lsaEHVE3FAHQxF1n5xKWYXhNrpo/a25dIm
VUe+8idZ00UWYc+ybMOabNQWYzOtro31DkAi2uqjLmndIluYQfdNpoomRqdLqI0jczupszRvdM5z
bwbBVOsRUWkP1uVbpAw6Dsq9MAv1+as0CMro0RZ6VtzrCdomYGtx0TxLokCCmaCQbi/LVVghESQL
7JA3uYE6JxuE0nWQOyBpAkGeYRWvz6BIGSec23TuNgb9SgaLmQYj3UfWEcDQnW2iB28jdEACf90w
PVH85CQFpHLZALXHmizG/ZKBMJgQJQHnHIwiDu190AgAzB5BFaNbTugKReyIPaBB1hR2mxTkToRC
AxVA/CCnFVv8onmo8p2MlIAmxKqphVBsGiEwqiZyj+9lGBuSNpSDba6fRBKKo/kGqbzmzOUW+iDY
Sf6JogmDbnoglFVt5aCUhVaLBotzUeUcwOSbQwCDG8aoJPMbA9P1TCqALgIIhs5rJBnI+6CQVWi+
VpTCsLy0d5QBom7hfolFrOGqCUVm70xpdI1BEZROkoMliZH+qYNH8wQSmo0k+ka6pCowi7R7qIAF
urQllN7iOaCY1GZridjZD5zT+G3TZRhh6JshkiZH5IJfObcZI9k3msgjKI6KOLGSNeSaNb7eyCTz
W/yhNnBAGUSgLTsZTFtjexUBeYP5U3mDkEMWuflolEDVEP5jYIy2TFwIiB8kxBmE0W1QLNrayYus
dEi3USmIsgbMT3SFyZslvqnYNSFAG9k3NPzuNU3dAgnSATga6IHbO1ynHZMG9U4FjogAi6MCw1Qk
Hcoz8Isiwm9bqRgGsqNo57clNSGp16I1B/h5SqxHpsrRH3RPfRVT8BlRUYbCRYUQI5pAjsjOoENs
UgwiUeYc00hQ1A5YKWWRqikQlIvKGoFrDCSPMOh7pIaiBJJJGThJMkinSTJIHSSSQJJJJAvmlzSC
VkDhKUwSQOlKZJDZ0kyfVU2fmmSnVKUCnVSUdColLR0KGPsT7hRhSOHpUJSLTzZEo5TyqmxjSyQP
VBsn/JQ2ObFIFBJjVPKGxAwJSQzbklJ5KrsQ7iUgmn5pA9UNiGm3skdD0Q6JT1Q2MWKQjeEGuifs
VDY5BJSndBm1SzTKLsW3dNruhBTzoqbP8kkIPLRKUTZwdUibpgTqm2REtA+v2V3DwQ7Y9VQofHGq
0cKT6xcGNEbx9KpnM6E2Ukui5NrlOfiItPZMIidNlWCbpaRdISRrA/NEBHIhNaSCZhAtoA7wnIcB
c9DKTWiba7DmEwGbSCgUS3Q6Rqo3dFIJiI6d0BHqO5hAOUCd0wbeN0jvO6TQb2RCy7BOG7bpAGI5
lI3JkTP1QE1vXXojFPm4XQszXEXIhPcCQNUBBkNPq5W/VE2lP4oJ2QA6yLFEdbCfoqoxhwRAekMP
IgvGqCbWCftqglGHEz5g13SGGkyHg8yo59RJEnkU7Sb2tP1VEgwokesWASOGAj1gnZRTtYwNU/qj
SAoJBhQCfWPzTDCi3rEIAY2SBJtl5yAgL7MBJDxCQwgH4wI3Q6gylmmTGqAvsv8AnEBP9lF/UAgB
1+l0g45Yi3fRUGMKP5wDMIhhWn/uDmos3pIITg6KAzhW6l7bc0hhWlkh4k7FR5hAtICcOsLTa0Kg
/sgj4xKYYTX1tlMSLxN0M20gfmgP7KJ+MEndCcKBfOCmJsGxvqmloabG6AnYdv8AODsmOHbPxhDv
yt80IPIHooJBh2j8cclH5ABs8JjaRF0jMmxmEDeSIs4HshLIJE3S10HsEoOWY13UQGQaylksSnvE
RaEhOUgDdAGUA6p2t+SR5aomOIJMXQBB12Q7aotjdCBsoEBrdOBJsmb+aIXmPdAgDr+SWXnZFGqX
YoAi+0KTVqDe91J+EBGoTRKlp/Cf0UdMEm0H2UzGiJIHJFgnyaZ1hUn/AAlXqg+7O9tVRefQi/SM
dUkyU6qOZ0tk0pIHCUpkggeeqSb2+iSihTpk6ISSSSBBLZJJUJJLmkgSSUpIEnTJc0DpbJgnQMkE
/dMEBNEyEnCE9PVO/oi/QEkkkQlJS3UakojVFnsbj6fdQ3PNTOHpt8kDLg6JFqODCINcRYKQxlUl
I+nqVUk2gFN2sGEOkrQb8NhZUqo+8cpKtmgBOkAY0RtaFUR7J4RwMqmptaWaBCTatfr8k8lWHgZN
IKrDskq2aOBbdL8vzTQnRCSCWxS3QKUuiWyXZAht80wFjCUp9AgYdE40SMyf6JBEIfNKCkmQSUPj
WhhJ9Z12uqGHvUHNaWDAPmaTHVHTH0qGQ8390w3tdE43cIBk8kIuIi6rJyd2pAWsLJCN79E8xePf
miBjUST2RXgg66lK/wA9bbpbIFpbTsoual9LWmL9VG6J2KAHXJSnvZPbonDoRDC2v1TjuY+SeOnR
HVaGnY29kULdDftKQdcGSpGAEOtG6YCIIEIEACCZ0REAG52V7AU6LqVU1RcWF1q4NvDfKaKrCXxe
FqY7VzupIzGE4HI/6rqm0+Ff+k5OKPCiCPLM6K9Kbcq2B6ibHknEARN11YpcJJP3bv1TilwmDFMn
sr0p2jlReBNuaQi0HRdWKfCf/TJul5fCAD92SnSnaOUOt3FIC4vfeF1hZwjemUQp8Ii9M63KdKdo
5ERBmJnWUx5Sbahdd5fB7zTchdS4QZimfmnSnZyV5F+qYXGtluY/D4MUicOACOaqcJpUHVnHEzlF
oWevnRv7UNNXQnAGh2K6ltLhOUAsMwCj8vhFvuytdKdo5NpzTLrnSEzYBu6wXWeXwgXLDOndD5fC
Mp9DoTodnLQCZnaITACLER1XVNpcI3pmLIjT4PaWHqnSnZyI6OvonGxJtGq6vy+E/wAjk/l8Ij4D
P6qdDs5ICAQEJM39l1pp8I/kMIfL4Tf0H++adE25Jwg6yOaAG2o1XXlnCbzTKhdS4VPwOTobcmde
l4T2530W/Vw+BqQ2iCHHVZOLoijWc0CyzZoVNtb/AJJwQaeuqY9gpA0eQCNZ7qCF1+qkox5ZJ10C
B4gCApqNNppOc6PmhFebFB+ikcLSQgBjZEMOmicTJSkTdOI/1UDt3SOiQTnfkgETOqkAhoIUbdbD
spBoEagmgmBf33VhgtbfoomDprrKs02+mw6o0Cv/AAj2GyoVJLP9Fo4m1FZ7vhCUvpAE4BOyM/Cn
pDlFlGIAMdeya4kK1S300VZ/xHuhYFJEBzTwEQPySRED+ykgjTpJlA6SQSVCS2SSCBJ4SSQMiDCR
MJokqZggTughiNU4byUj4iyQHOyiyAawmU+QgAo6WpRu+C8Sm114AAI0QRd0BSt+E/JRn4zHsqhm
i6IiSJTCzuqK0jcSos9D8lt9QoS3XkrgHptHRVTqY5pKugAXR0xrOiEfEjZvCqQbpyqNl9NUbtDc
KOnvskMhn4SjoCRv1KH8NkeH+G/ulMfazTu0k9lVDbm26tNaADcSq4ABNjqpGqbL2/oo9zsp7QSo
mtukqWB1BR0DLSOqUCNfomwxh5Gyt9GPip3AFpMD5Km4XI3V78JBOtlSq2eVMVzCNE/0SCX1WmCG
u4TbJ4hLmgbZLmn5pdkQ0dilGqXPVOgXOdEgL/RIdNOaeNvogYJoRe2yRvMfRUFh/wCItLAmPM2g
LNofH0Wnw4E+aJFwFPt0x9Kb9XSNLSk0RqAY5nVJwhzrwQiZYmQfZVkm37kWk7JhYXTnKZMp28rT
pdEB0PzT89ZG/ROdAT9EU7FAE+j4bHqhdA1Up1GsC53UL9TbQIBAG8jmkALQmj1cgkB1F0QTQNgV
LVp5XCXG/NRNkEEHspn5swmAYRSpsJabm2yQaNSYJPyT08waZA5XTidbEIsWMNScab3BxaG9NVNT
pVJYQ7e0KPDOe2lUaGSN4VljzDPTpGy3ilLy6suGaLwE4ZVEnN3CkD7kZb32T54A9J11/Rb1GUQp
1cxh57p/KqEXeZA5qQVAPwmR0Sz6gNMdk8CMUqkfxLdQm8urf1f0UucG+U/JOHtgyDB6JqIgDKv8
xhEaVSYD5iBpKkzt0DXack5eLw0n2TUVF5dS5DjEpCjULCC8xKmLx/IZ7JhUApkBjiJ5JqCD7O80
XnORGqhw1F7i8h5gHorT6r/JeGsOU6qHDPeHOGQkTcrH21PQzTq2OaDFkOSpPx/RT+ZuGnS1k3mR
PpJHZb1GUIZViM3SIsE3lVAPjjrCm8zmwpZ7fCc3KE1BFkqX9YNtYTGlUH47deSlzjQNJTZ98h0u
E1AHlVYIc60XSyVp+Id4+qlz6nI5C58zDHdk1BEKVS3rOn0TClVIHrMlSl9pyulCXn+QqagiNOpp
mJQeVUMy43F1OXkm7HTpCEvP8h9t01A2Ew1StiGtbUg81W4lRdRxD2PeSeZ3V7A1azcW00mEuGyq
cUe9+Je6owtcSFm+ljOcBM7HdSlh8gOJMaID7HqpPUKABbbusKrvEbyAp6NNxpOc11tSoXzKssL/
ALO4ZbboKpHpuTGiA7X90RNogR0Q3/3RDQE433Tt7FIbwoELc+SR0unHzCZAm36qUXAttFlE28qV
omDGyNYpaYiLW6KyACyb8lDSBi/+6tsHpG91Y0ixjYoaX5LMcLROq1eItAoDX81lVO47qX2l9BPw
oqWm6E6IqXw9FGYlp6E/SFEBcqZkFriodJgBItM4WshlSPjKR1QgaohvdJPbmR7pIIE6nFEJ/JGi
mzVV0grAoBAadrJuGkSSIsITKoQSH0SSQO3UXUo5HRBSEkqWNVBE4y7WUQ1ugbdxRmwRqCoXDiid
AYhw92nRG/4VPtqejDSyjcPWRAUrUDxDuy1GACzkSYC6Ii11Gp6WRMcv0VYxLuUq00ekRqqr4zOj
mpFR7nQqRu6jHxI2681Ug3aHr9FHTHqNrqUzlM9lEz4rfVWJkkHwFHhwSCN1GNDoVJhxIgeyUx9r
DADMe6rSAXDZW6IF55Sqbh94b7rMayHJykayo2n1HkpCBG0lRNEVIWolSaDkY1ChpHLW7qUAx/YU
Xw1RZEXJ1v2VbEC9hAVhgBBsdFFiWjLIWY3l6Vk+x36pbJ+esLbkbVIJaJbWRS0lPFuiQ5JwP7CA
R9U9pTjr9UhpBlENueSXzTi8p41KAYTf2UREd03PpZUFR+PmtfhMmpUkXjmsmlZ/NavCJ85+9lPt
vH0pVGgvf0P6pgSBGoOkWRvH3rxeZMphJmN7yd1UL4eY2TwZsR/X+7JnDSI21KQuNwiE0weUbhK5
k69TsiMk6zzQAXNxzQPmj1B2lvZROsSp7ybA31UJFzM6wUAE63kdUpi5n5IrXG6Qge26IVM5XNsY
lWKrw5wgnrbVRUwMwuNbq1iAM8gWIGiLEeHdDHgkA6J2GAOmqOi0eW+Y+acCBcbd1Wos4Oo1tCq1
1p6KzTLR5dyo8Cxpw9WQJ2lSU6Yllmrpixkk9OYkOG5F0gG7u/2TmmA4nL1T+UNAOt91tnwYBt5e
AU+Vs6gRZMKdycluqM0YdGXREAGg3ziEQa0fivySFGBOWCIlLyyD8Ft4RSDGx8Q/0RFrbkuv0Kby
7mBfsnNKxBb3CAS1sGHDknhnlO9YsnNMQbbpCiPLNtNiERE57W0nDNqgwlRmSq2d1ZZQYKDy4AGb
ShoUB5VckAumyx/5Nz/JsoymHCY9kJYDuLbIvJA/CJvaLlMaREwJC2yHKCfiF0iwTGYRpZI09fSR
7J/LsSGz0QDkAEy3S8FOGjXMIT5JvASNLbKiGAbGtkoAJcXAxcp/K/yym8obtMdkAuDdJCY5TMOB
n6qTyh/KLahMKIIMN7IqJxb/ADIH5bwR0U3ltJIDbwgNISfTbXRTyJOF4inQxge+CIVDjNZlbFve
yA0n+wtjgVGl9t+9aIAWVxprRjKoYBGohYy9NYsp7hMg3/JSOqD7O1sCe6TwL2UtTL9mpx8W6wqk
8yZB3VxlRgwZbaSqtQ2gBXmtb9gn8ShGadOaDnvyUpFuqA6m6IQgapCNJSAsSnAvciygax3lNqiA
10hMRA0KBmjWDZTtAkqBvS8KwBofzRvFYpMdA2V2k37sHbmqtJtmzqOav07MbJC1itVeK2pCbFY7
9QLrb4yAaTQJmwWK+C6yl9s/QH6I6Rt0QvHpRsAymIWUiRgIYT9FDKmECntOygbqVItJxn2SGm6Z
2qcC6qHLo3KSUW+JJBJnbJkpZmXVcFOPmp1XssB7eaDMOf8AoopSlNJsZIIKGBcqZhHkkKu6xVAm
xIS6pJBES0hbVG6Q0zpCTLCAhqWaoAZzO6d+hTMFkqmiN/SXDCWFSVB6P9UGGEsUlUfdwp9r9Abo
gf8AGQVIw+lA747clpgOjgnNgmPxe/JGZIUrWPpOz4BFrKs/43RKtsgsEawq1UQ93KeSkaQ/iEqR
mplBfN3UjNVWZ7ERY6KJnxnmpSomXeVYZJBpqjw8Gb7oGGxRUTYgpUx9rdEEzeeQlU3/AMV1xBKu
0BrNiqlQTVPe6zG8ocC2ihb8Yupw20TqFGAfMKsZsSBs235KtVEO91ZaJA/qq9fUlWJVumZaPmhr
CWW+XVNhpdTHMKaoyW/kseq6e4z0gRdO6xPeyJlMubMro5AG6U7qXyiE5on2Q0inklPTZH5Lo66J
CmeSGgTaE8+3VSCk8wI1MJCk6bD6Imke6e+qPynxIERvCcUXA3b9FV0jPX3QqXynRoZ7JjSdF9UQ
1L+JqtfhE+bUBG0rJpjLUWrwiPMqTpl3Cn23j6U6xPm1IP4trIGmNQPfZSVWzVebwHGyETIGoO/N
VDsgiSiN3EAoB6SZBjonEmZjvCIcSRDjb5SnyzebpifVMa/klOsHe21kU7ZiNOmyivJGt9ByRwIn
XuLoCJkDnzRDQIMDbmmgbe6ICTaSfzSbcmLKoJjWkiYMn5KfEUwwtykkRZQtmGgEETZTV2vzAOgw
EWHoM+7ec2nWyQAiRPLXulh8xY+ACE7SYAERNr3RqLmEpB1Cq6SCPqpmNd6L9VFhPM8mqWkFo1U7
HEZAWtW8WMkhDwSc3VL15R6+miPzDN2D+qcVCQPQ1dGQgvk+uAnaX29aQqb+WI2Tip/kE90AkvAE
PTnP/NY7pw42ApgSeaLzLE+WCO6APvP5zY6wicXw4ZpndLzDoGC+qJ1SC8lgBEIIwXZfiNrQnbnN
MnPpfRF5kX8sBIVAGE+UPnZECGOfScS8iE1Gi4Uarg91iiFRxpkMYA3e6enUeKdSWNib33WPtuf5
RAPuc5nWU0vuCYB5hSCsACPL6Qm8wOMCneLLbIMz3XDiO6cZ93dNE5qCCAwAI85ufLHzQAc1/WmD
ner1RAspBVGU/diNUHmDZguiGJfb1fRN6ySM3ZH5gOlIAofMN4pwTCBgHHV3zTOzal6LzLT5YOwQ
uqTpSRQHMSfUhcHfzFGHmT6IItqmLnC2QTuoJ+FYU4jFEF7tNisjiVM08Q9sugHe61+Hee6q80Q0
EDQlY+PdUdWeXgZpusZNYqThcAG6lfSHl0zJvqo3yHAQBdS1S8UmSABqIWFVajQHEahW3UIwecuI
O6qvJc68SrbhUGCggZOm6EUXC037octoAujdMSo4joohRF0hEFPf2SF+nRAtRcymPQyiOscuiYgx
coGYLzeFYpi1lXbrb2VqmLW0UbxW6QimzutAWgSqlIWY0X/VXWfE23a+q3iVS4yT6JnVYrrEWvtK
2OOH1t3WO4y4x3Wb7S+gP6KSnZvso32aApKfwnRZqYpQB5R0ndVxrMKzpRIP5KsB8lI1TFENLm6E
iSiCrJ4jQCPZJC6AdY90kQMJRrzSDtouln6IGITJ56JDoEDje6eo2IKYaaJ3uDmi5RUaTfiS3RU9
ZREwlR1XTAKkPaBOihcZce6kBssED0Y0Ub9Ujd9LWFP3e3upK5PlGYhRYUgU7iVJXcDT/KVPtd+A
0ycqjrTnCdhEJqh9fVaYDcEXRH4dkBKMn0qVrFboH7saxCr1/wCIbhTUXxSHS5UFf+IfzUjSExKk
b8SjOoRtMwqzEjr3+ahb8ZU56T0UI+NWGQwTJn6IqBILht80IMHRFRuXd7hL6TH2t4eTaLbAqB4+
9cSJurNORFrkKLIalR2Xb6Lm7SGixEKCPWbK95JFJxI0VJ4LahB1VxTOCA5HtCixGtr7KVhvpvoo
q9zK3HKiwZ9LhsrcemwAVPBGKsc+e6uBxOt/ZZvtvD0z6tqhkQpaPwWgbaIMSPUbo6Ilvey39Mfa
ZoBBMJmtDuXbZGw3MnVMyGkwCZtBUaCdJhT8OYHYgAwbKLcmGqfhrw3ESYFrfNCe2p5Lcp9InsoX
Um52gN35KwK9OJLxrEwozVZ5rbix2WfLfhOKTb+kTE6aphTac3pb2hSMqMLjDhJGqYPp/wA4G8Iv
hB5LXO+ERaeao8VYGZYA9lp+YzNdwm35rN4u8OLcpm1wrGctaZTv4o5rS4SJrPt+HZZriPOF5Wpw
kxXcSfw7rU9sRTrkiq8QBeNUAJIOgJ3Ulb+PU1Jk6oYuQZM+yqHF9fkmMFpAGl5SBLtzPTdIAQdx
sgcC1wOSUQCLHSI0Sk3MwDGqIuixAFosgaTrO++yj3MxPNHHQ845IHEbADrN1UNJEEC6eTawITgw
SY9koMNEX5Ih2mCDy3U1SsKjgYiAoQZdoeQ3hKxFw7qip6NUBhad9E4qC9rcuirnpME/MpxYAAmB
eQqbaOGxjadJ7S3XdSfa2Swhpssy8bz87Ii8kGJjnKsukapxlMOJujGLpEGNfmsadP5Qna4gkydf
qtdqmmx9rpSYMRvFk4xVE6k26LHBiMxIITyRaeqdqabLcXREdEhiaIj1lY5LhAE8j/fySa5wBiRH
RXvTUbIxVEG3+iRxdKTJN4tCx2uLSDMjvqmDyTckz9VO1NNcYuiGQEQxVENIJuseSBrEQfmmlwn8
gdE7U01/t1NrSGzdPRx9IUXtIILisbN1v1SEgnWYvdTfna/Wmv8AaaIBvaeSc4mjN3CeyyCXBtgY
iY5ISSPytb3Wu1TTYGJpEAZo7DROcVRIu62pWOXESbzqJRAltw72TtTUav2mlAv7QmGIpeqTYrKL
jsA0ckJe7fXpZTtTTYOIpTrdN9pogn1WWQXuBj5ShD9Pw9tle9NNg4mjBJi/JM7FUd3WlY5eQ6x+
qYuJbb6qd6abH2qle9+0oDi6eknfRZRLpj5dEs03Ghsnammzg+KjC1XODS4EdFmYuv51Zz41kqDM
TfXeAULjmj5LNu1ngi6DIFkdWtnpNZBgdVBOoOsfNOJ0+vPqoEXSbqw/EzhvKy6KsPiCYEwIUUzu
WwQ/11RdkPK11ECTrzCJpN4j2S2KTbajTaUC/D16IXSiG0fUoXaIHZ1VmnaTEnZV2D1RrCtUvhB9
rbqOmK9ScIEiB0V6lcgXWeyxbNjz5lX6Jh4npqt4lUOOEms2brHcTm2/Ra3GnHzgDc9lku+KJmFm
+2b6DUUlO4hRP2hWKDZFhb8lmmPsbz6NlXAU7wcsXlMKRHustq7/AIrpx2T1mlrt0wP981qMX2Zx
MpJnETc/MpIyCblIHknypZdVGjJIsqWVAdOMhQPHzTiWhIiZuhpEpKcAJZJTgQFU0eYBKjb8Sky7
FCGQhoU+kqJ1yVJlsmyTN0W7qSgYaiqn7v3QMENROEtum00ZpgJqh9YTgRukWzCGgHmj/CdEi0Qn
yyYlGpNJaB9EbqKqfvD2RNs0gpntk6youvCEwjp6hOadtk4bBPJVJKkF2lQ28w6qcGQbKA2qX/NI
ZJG6kT8kVD4yDA/RC2J1RUBDpn5q30mPtoNjJO0TKgY7yqjzsOSlZUGQjt7qCwfe4Nphcnbaf7UN
wfmqtQZ3yLfVWWinB0PdG3y+QSeC+fam0ROnysgqUi4rQaKe0HtsiillNptJKdqnSMynSyODtf1V
jNzVv7vYADmmDaVpIF+WqbqzGRn1GeYbCEqbC0Ea+y0QKQ1j+icNpm4v0CvanWKQbsleNvkr4ZTn
UJ8lI7iSp2p0jPgyQkJGg25LRZTpnQiE/lUxIkQNJTudGbmdy+iUmZV99NgIuEOWlMAJ3qdFPO4T
qnD3bbK5kp5rSkGU/bayvZeilmPOfZCQT/srzgwMECD+SGGbfknap0il5ZL5Ji2i0OFNIrkyPh/V
DLIMA/JaPA6fnMrCmxxqCMpAVxy8nXUYmILW16oII9V0Agcx1VjiNGpQxlSnUBzakcpVdl/iuujm
R300RCJOpSAuZBtpCdogRp2VQx+E/wBlI3dNvyR2nQDnKEgl1htEygaJ0IkoHekzMqbWZkztooiI
cbX1RAm3PVOCM1vlqmDbczNrap4MjtzQEI7j9EtPbUC8JC9uX1SywTcNPKVQrmLjW0JC9ydkgB15
JwNSCLFAw0NwPdGAIknfUIRqeXfdPBmduaqFq7QxvCdt+xRZRJmBfUpECCZvzPJAzb6EGSlbLex6
hO2dxBPVOWxOo5BAzRJtzSgRMhKABmboEWQyZBEIFYEGDEzzTO3vfWUYbv7JidI15AoGJDTuC0pA
CIuJtokRBEcu6Ya+lpg80DAWNrItzp0tumzEHQpAC9pAVD3InffmmkkNAgbog0xqNOtkmtBIB56I
GA3gdZGn9EnaXF9dEzRMxF/dEWgTpHdQByG3RNA0mPbVFEa26JBoNiYPzVAxYRY7ykAJiJPRKJGs
jnGqYjXc8lAw1G+8ApWix+e6eInSe6WX1QSPfbugAztlKE6mDYqQixgGTuhjsOyAec7nkhMGb69U
V5PzB1SDZJi8BQDBgm0akofewR5dd0MEjTTUygHclKQbmY6JzE62TRrAUDbwm62hFCH30UDHQwkL
7xY7JTAO8pN1ugY9YSciiJv8kB35Io6Qk/0V2mBzEm+iqUhBI1jkrtMQeWyjpisNHqaNVbpj1Dnb
VV2H1ASLWVumfUIj+9lvFKy+Lf8AUALLdGay0+LSMQQsx3xH/dZvtMvQHxKtUnBtPYqq74ukqdhO
S4WamKeqZyzr0Qh3sEFZ0gEbKPzPdTTexV7uH9Ewp31UbnnNPJF5pOyrFoHTJuEkLzLiSCkjJ5SD
tUAKbmou0mZIEIEpQ2MQkglKVTY5GieRBUadF2PNZJr52QSlqhtJmBTZhuglIEobSSE4cLbd1FKU
po2lzDVLML3CinX+if8AJNG0gdpKWcQo0tk0bSB4hPn1UUm6QBCaXslzi/JIOk/qowbW+SdnxSmj
snO867qH8UxZWMpg2NgmDR781JdNXHaMExojZZztjKlDb8zonDbGAeydiYHpkayNFO2hVxLSyg0v
cDPp1UIYRIn6rQ4RjqnDcU2vQDXHTKdwueVuvDrjJvVQt4VjjI+zVDtopBwjHm4wtQ+y66l47xTW
weHYc81apeP8Q0D/AJdhD7rz/Jy/+r0Ti4f/AGcWODcQEgYSpPb8k/7k4if/ALOoRpp1Xdt/aFiW
/wD43CH3Uo/aNiARPDcKZWfk5v8A1a+Lh/8AZ5+OB8TMH7HVnXROOBcTP/2VU+y9DZ+0nEwf+V4S
Y5om/tKxQuOGYP5p8vN/6nxcP/s87bwPiYEfYasdkv3HxMT/AIGsNhZeit/aTiiT/wAswYHdA/8A
aPiySRwzCSeqfLzf+p8XD/7PPf3NxIG+Cq/LZOODcTOuCrE9l3VT9o2M24dhUA/aNjL/APL8NGyv
yc3/AKp8fD/7OKHBuIxP2Kt8tlKzhXEGgzg63LRdzR8d4/EOcKfD8NbX1QosR47x9N7w7AYaW2MF
Z+Tl9ab+Li1vbizwzHxAwdX5KP8AdfEM0/Y6sDaF1h8eYx3/ANjhhATHx9jJP+Bw/wA1rvy/+rPT
h/8AZzB4bxCI+x1OWijdw7Hg2wlQR0+q6l/j3GEn/A4bqov+OsYTP2PDghJly/8AqdOH/wBnN/uz
Hz/0jx0ATDh+NH/2r9OS6c+OcZoMJhrFRu8aYx5/6TD2V78v6Tpw/wDs5w8PxuV04V5k7jRaHB2Y
/A4Wu9rRTa5wacwk+yvu8aYyP+lw/K6z/wB74jieJc2qGsYBJazQrpxXO5f2nhz5MeOY/wBb5c5j
6jquKqvqOLnl0kndRAtjSf1UmKaftFSBoeSjDeZt9PZet5DyZ9M94TX3Ik3TxEW66p4sRIPUKoQM
t2I/JPzuL7Tqllg6R3MJN0OqIQAbNxEqIzncB3UxmNxHVRgTWuf0QIge36JwB7DdGG2kAzzFkiDe
JU21omMDtBKlOHc0EOBAtqmw/wDEZvcfmr/EwPOZIAEKmlAUMxmJgbI/s4M6Qd1ZpT9lfrPRRNcJ
tETbkmzQsNw99Zji0DKNTyU7eGPyEncq7hnD921QNZ0lRsLvs41udV1xxljnbqohwaru0RpCX7mq
kaDVXczzpmPuml51mB1W+kZ7Ko4PVI0ueeiccHqmLAjZWW5/Vrz7J3F8E3HO6fHDsrN4LUgwE54N
V3gx+Sn+8n8XzTt8y93QnSHaoG8GqyRAum/ctWLe3VXaRePimT7J5dvIHdPjh2UDwWqJsB1hJ3Bq
+WYseStFzyTd3W6kL3nCRLpB5p0htmO4ZVpiZyg2lKlwqo9rnNgt0VzEPjBPE3nco8M8HhggjNm0
WOs3pr62qM4TVIILdTyTjg1R0GL6KzTz523cROiJ/mZz8UFb6Rnsp/uWqIsD2Gib9y1ZjKL3Vtpq
WuTGqOHA6ujunSG1L9y1Z0J9kv3PV1LPkFZqOeXnUC0XSa6p/m15p0htUdwSruPkEP7mrfDlV4ue
R+K26D7yDBMfmnSHZUHBq0GRYpfuetEEK5meZuSecpS8ak95TpDtVD9y1rwIi9kLuDVho3r0Wjmf
BIceeqZxdcyRfmp0h2rKdwqsAYbMCbKq6iWTJAsup4PVbGJzOBOSy5rFx5hvadj1XPKa9OmPlW8s
iRE7CU5pEQIjnKakAazBMXCtYsgVRJGiwskUfLMkASifQcwDMCJ0tqpMPP2hv/lpqtHjzcjKIEaI
uoxMt7wP1QmNJkI3gSmuRI12CjOkZECfmkI2KNzSATf5oQ2Z5/mho2ukFC/6IwN/zQu7FES4cEut
HJX2NlwIP1VHDD1cyFo05z3tylR1x9LFOl96La8gr9Gn6xbqq+GZ95pF1pYdsvH0XTGM1zXGQBjC
DyWUdTqtfjg/xzgbW5rMFzcf6rF9lm0LpJ0UjDYxrzRxsmgLO0mOiefQACVFe2qlAAJTWiwQ0ii5
slHNSzAKWxKbOqGElNMWBEJJtNKspJJIySUpwkgQSCSSBJSU45pRZA02SBT6z1SVDTZJOn3UDSkC
nShAwSTx1TgfVVTSUhJTgdAngIBuDdKLIwNdE4HXbshoA0KJnxCdE8ROkmycCHdFCLIHpQEkEFsB
TU9kGWCQBIWHfXhHmIm90Qe4WHJN0i3JCBe31KumdpA7lMo2kgakDmgHYRpdSNkdeqjUEwk2knYh
ShxB9Uz1UYn5dUQcS6fqsrEoe7nCMOIJFzuo4Nuc80QlwvCjQxUIJue6Qe6TczZMWQLAb6JAETYG
efyQTCofikjmmdUeS7We6CCZMa6pwzWRqYMFFBUqOzAyb2uo8xuDcHnv1UxaZMQUIYAYAF9AqyJj
yAbnWBdE+ocrspOslG+kWVHiJNjY6Im0XVG1CbRcdFncb1fSnnLpBkhAajiL35qXIY0m25Qlhmzb
c1pjyh8x2kmeu6YPM3J5wpMh0AJEe6Hy3GYHXVaTybzHC0kQkKjwbEhPkN7a804Y6D+qJ5Jjy9zZ
56rX4VT/AMS4gScvzWTQYTVaSAt3hLZxLhb4TvZJ4rUm4wsSPv6h19W6BrTaPrdWcSz/ABVXY5ry
gDAG3yjsV0c9Ih6RptEpNE3dubqQsaHWI6mJTkakHvKqaQgSOg06IvaOYAUhEzOv0SgchGiJpGSX
CC0TOnNRtEVDYxspiIOsRuBqhaPvrgkoaISMwMkblIiREHTdEGjNN+6QaGmCZtzRoWHtUpzcZle4
oIrssLNVWgAKjMpi4GqucVg4hkz8N91Z6RFTn7JUF/8AVQ03CATppaVK3/p6hi2llWpl2W8zIQXZ
qOoOFMENvJCijFCnRaA6Dey0sG0Dg+IfAzaWTU3uLaEG3ZdMcdxzuWqYMxJOjo7J/LxRHwvVsVqg
0cDH1TOxFQN+IQbLfxp3VmUsSCQWujpyTto4oN/GpvtdST6p9tbp/tT/AOefZTod1bJiryHA9Aia
zExobbxp0Uv2iqRZ0d7qXDVnl7sxkZeSdP8Ap2V6dLFE6O5FF5eKt6XDsrHm1W03PzWn+ykMS+Pi
HOCr0/6d1PysVeQ61lHUpYvLMOV84h4m4Uvnv8giQb6p0OznqzqjY82Y0unwgrPc4UpvsLLQ4gM2
CDz8WbVHw9vlcO8xsAkwYWOvnTW/GwUqWKaZLXc5TlmJ0yu7eysU8TVEXTfaqhdc22WurHZA2lib
Q10RGiBzMTJlp/qrTcVVEy7S+iY16hB9UyJur1XsphmKkzmvbunDcSBdphW313gWj9UHn1RuI5Rd
TqdkBp4kmS13yTCnitcrp3VkYipHxT7J/tFQEnMPkr1OyqaWJOzojdC6nigfhPvsrtGs8uYM0iRt
dPjar21wAYACdDszjSxM6GeYQeXiQdDKuurvbHq1F1DSxD31rusOnVZ6nZSaKrKjpkSL6qlWe71E
3HMrqsFhG4rCY2q+CWiOy5XEQHOmZlYymm8btFS/jMEb2VjGO+8JvsoKEGswamdipsQ4faI20Kz9
LEWGE4lmutwtTxEP4I2yhZmCviqenxLX8SfFR005yEnpWA/Uxp+Sji9lI8jlfmgaBeb9llCOh5bI
JMyDc/VSO3hDzlVKbLAjn9UJN9UQt25JieqMp8MPUQdFoUWw8z7yqOFmSQAtLDzm19pUdZ6W6Fn3
uAdwtTDCXzy91Qw7B5ludpWrhGw4z9F2wYychxs/8wqDkslxIcVq8XP/ADGtGkrJd8R5rlfZfRZi
lmMmUPdJRnYg4jTVLMhTIbFmKYOTJBQFm5lJD8kkApI8vVCRFkQgn2RBnVPkCLoGyXOERbEjdCiF
zSS11RBvJAKQlFlsbpRCKYaJfkja2dwnya3QPRYHXP0UgoC15UmFZBIMdVaGHmnni0xYrFy1XbDD
cURQHNG3DtMyrTWQbieXZTBoPwsKz2bnHFEYVp3t1RfZW8phXhSJ/CfyReVrIsVO7XxxQGFBFro2
4NpsO+q0G0DFwQFKymAPhN+iz3qzijMbgQRH5om4BpJkxutNrDIJYewMqanT/wAjpU+StzhjPp4N
okTrqphw1lTcytFtJpP8J4U7KN5FNxG6xeSus4YyP3PTIkEo2cEpunU2W6xh3ov/AL3U9NmUH7h/
SFi82TpPx8b9MFnAGE2LlNQ8P0SYcXcplb9MmRFF86WVzDMm5w7+i53nybn4+H6YdPw1hXXDnT3U
7PCmHjVy32Ah5jD1BvortMVCbUHgc1yvPl+3afj4fpzFLwhQcQJcNtVapeC8ORJzR3XRh76ZINCp
7K2MVUFI5cNUkWuFm/kZ/tufjcf6c2zwRhn5hL53upW+AsLF88a6rqMFiqwbmfhqkdlcGPeRAwtQ
+yx/Iz/bX8fD9OPb4Bwk6vHurdP9nGCeSMz55Sui/elQVY+y1J7KWnxPEip6cLV15KfyM/2n8fD9
MEfsvweuepPdB/8AszwQeBmeRNrrqxxrGZQPstUeydnFsWBJwlQ+yfyM/wBp/Hw/TkMV4BworuMP
M9VHT8B4cuIAeARlN12juMYgi+AfPNPS4vXD78PeYU+fL9tfDj+nFj9m+EJjNVv1UjP2ZYJ34q3z
XYVOO4kV/wD6e8BW8Nx2uB/0T/kr/Iz/AGz8GP6cZT/ZPgqjrPrAzzQVv2T4OkJz1ZH+Zd07j+KB
OXCvHss7G8dxrxl8ioPZX+Rn+0/j4/pxQ/ZlhnWpuqHl6lHV/ZewAx5vS66kcTx7HS2hUCkqca4i
0XpVI7K/yM/2fx8P04R/7PG0niPMtpdFT8IHDVC9maY33XXO43jJJOHe7/2pzxquWw/Cujsr/Iz/
AGT8fD9OCr+DgXvd65OqpVvCbWFxl69HdxGrUmcI7Tks3HY6rmIGEcPZbx/J5P2zfxeP9OAd4dY3
dyj/AHCzST/Vdr573Tmwjvkoa1WGnLhXSuk/Jzc7+Lg4x/BA03Lo5qF/C2AkyZJXUPrVXPIOFdEq
J7XgScMZW5+RkxfxsHNO4Y3LYm+yg/dwY4uE/NdGH1CSBhiAOYlV6xqXjDkFbnPk538fFhuwcGQT
m5qMYMCZ+LqLLaDqsH7gwdFXd5jifuD+i3ObJi8OLOZQhwI26KTEg1nNc6Q4CyuONRtvJNxqo3Go
XEeTeVqcuTPxRTb6KbmAS13JA2mGiPiA0Vhwqb0pBQeU42LCDHKy18lZ+KDpYs08HUoQMr97p2Yi
A3/LcXUQovBlwOnJOaRGvLmtzny/bHw4/pY+1y2LfOJUwOejmVHE4Z1FtNzoIeJEFX8OB9lExGvd
ejg5Ms75efm45jPAAI5j2TgAGAO8I3CHGSAY9kIiTa3Zeh5zTbcDS6louh53kIBpe/UXRUozyTbT
RBbqtnBh1r3GypstOoOi0nAHhYdb5dVmnUgaWg7qhC0HbopGn7p4NySEPpDQ42nmjgCmYkhBDiz/
AICJg5tVJgx/yoT/AD2too8UP8CO+kqahA4Sz/yXP/yb/wDEInI7UwELD94S7bopbNpO1uFELHZb
jBqbcz/VbupGNz06nMfVDTAziLyeanoNAFbt7KimZIMGf1SkkwZJiE7rtkQfzQtA3Jj6qB4MaiAl
HqLYHaNkY6TKGPWMplAdCTUbMEl26scTZ5eIbmsY1UFEhtWnv6hvG6k8S1CMQwNi7YtspfAzMVVE
WBPZQ4RxNUgm52QxIMm6Cg/JUDotuFm1XV8EtwbiBOvZcZi/jI/2XZcFqB/AMdVsJ2C43EAmo4Ae
8LPJ6jeH2hw0eewTYmxhTYoA1qglR4UA4qkBOu+6kxAmvU0XP6bgOH3xbLnULW8TQ00gCR6YMWWZ
wxs4ynB30K0vE38Wi2TIHsk9DCNiRv20QDXUiPopahGY6aTqo+UfUrIRiJFtpQtETuidprbmhE3G
6JSfFougOoGyJwix/qmNzsqyt4MxOaSBstTCgZhv7LMwgmYieS1sHlLjb/RSO09LmHE1rHeQtTDC
7vyWdhB6ybTyWthx6Xdjcrvi55OE4sZx1eSTdZkeoxzWnxODjq//AJFZh1JXG+zL0UWSKWmqSjBk
k8JuaBtrJ4SCcRsgb6JJx3hJFShhuoXiCth2HYGmAZWTWHqKzLtbNJqIJFgUeU6cla4dTa+jcAx9
FaNBkGGieim2pj4YdXUqNT4kAVXAWgqutRinU1MZhIUAK0+H0g+m7NzEJVx81W8t0c+gUVQRYrY+
ytg+ohZWKblqOE6HdSXZZoVCSLCVMGHdpnsi4Yw1JaDBV/7M7mD/AH/upa1jPClh/jIMjpC1MM3N
gni5yu2WZGXEuFjZbXC2h2ErD+U36LlyXT0cM2rtZcyFNTphsWm8aKbyxEGSOSOkAXAajruuPZ6J
ij8uwMabKRjGkQYA+atChMG3eUdOgQ0gQsdm5igp0xGUxbop6NKYBEQp2UYYTudVZpYcFuolYuTc
xVaeHEQW7xCufZBlAAEmNVNSo5W6X58lYZRD2yA6Qd1yuTtjigZhbzb3VijQuIaD1R0qRqVA0C0K
9TwxAhkclzubrMUNLDZriLK1h8JnBgho0hTYaiSxzbWO6v4XC5Gi0E6Llc3SYqAwZa70iRyV6jh3
Am1uy6zwpw2nWwr3Vmhzs0yujp8KoNH8Nq53NyvJJdaee0MKXHQk9tVoUcDUDbDtZdS/E8Ow3EqW
CflFZ9wAujo4GjAIYD7LFyPm19PN8ThqoZDaDnH/AMUqGHeR94MsD4SF6pTwFIkegH2XE8bwwp8W
rtj0h2inZ04uXvdMuAGQxsnstTgvB6vEfM8pzWlhEyFXpMLqkMAN1v8AhPhVTG47F024qpRa0AkM
3K3x4zLLVXlz6Y7hv+CsSbipSnsmPg/HtdZ9IgI8Nj8d5zqX2mocrnNnsVs4Z2McAXYh8L0/Bi8f
8jNjM8J46bupqwzwnjMpE04XSYY4j8VV0nmr1M1YvUPyVnBin8nNxFTwhxC+U0/mqo8JcTYSZpn3
XodR9VrCQ/6LkeM+Lm8PxIouqF1Q6Na2SpeDFcfyc6zh4U4g/VtP5qRvhDH6zT+arYj9obcNiqVD
ECpSdUs0upwCtgeIa76TagqHI7fKp8GK/wAjNQf4T4hldHlm3Nc/jMFUpOexw9TTC9L4IzEYt5xB
xJdTj4YXE8UaTxHEtm+c6Lly4TCbjtw8tztlc5RwlQk5j+qjxdOo30hpXofAuB0MRgm1nQXHVaTe
A4VpJyA9VyjWX5GMunktPDVn2FJ1+isDg+KqH00nAbyvS6tLB4fHUsJ5cVKgkWsrTsK0GzR7JvTF
/I/UeWjgeLaxxcAIus19Bjrm7hrZes18KDTeI1BXmzsK1mJrB0g5iE26cXJc/bFrYcN0hZ78I45j
vExC6PyGljzluOYVOvS9ByyHRNlqZO2nNtwtQmcpnnCGrhqhEAHTku1wbW4DwvjMc9gd5YJEhcXw
/wDafRdRy1ODFxbbNmAzdV6+PjufmPLycswm6z34Z7QZBJ6BQfZSTJA05LqcP43wmJaJ4RE/5grt
Hj/D6mvC49wuvxZRx/kY1wWIwb5OWw5Ku3COb8Z+QXomI4xwxszw36hZ+I4vwotJPDnQORC1OPJm
82Lz2swuqHToULqJJJBFtDC6vF8Y4K0u/wCX1Aedln1eO8FYDmwVUcrBdJx5Od5sXPPpkH/L2TeW
GAQAY16LUqeI+BuMfZKvyCt4XEcLx1F4oYd4OW0hW4ZYzdXDPHO6jniySAQLjdRVaOhN1O/F0XV3
UcpD2J3gFk3M/VSWxqyVV4sCcPhQAYy/3dKgXHDsAJJ1UnFWD7PhoIPp3TUWDyKYBPsvd+JXg/Lm
iIsTPugvJ2jmpnUvvHNOgPLZRlp68yIXueEiPb9E4kaSTOqbexHOUY9I66hUaDvTwoZQRMfms1sm
paZ1ur75PDGCFRcBNySVAiIsNkUEM0OsHdMGzbY3UhYRSZO+yCtip+yCby5WqU/uqn1dzVTHCMIA
bX1hXaA/5RTnXNqsf+Tf/iBs5CIi0XKANh4Bt7bKxhKfmS2xtaVG9uWvl3jlqujCKn8QNpU1IE+f
YxGyhZYnbZS0SQ2oBGmigr5ZESmY0BxkGRunFoJn8lJ5Y9XIdEETQYEX6Jz+E/qniZknrZA8wwwb
c51QBUrAYinGx5o+OObUqMLDJDdgs43fmdczIUmKf6wTJgRPJY3tUbgALm8c9FC5gANx2UlMF1UA
ctQo67Sx5bHtCg6fgZLPCuMgyMxuuRrAlx10mIXV8K9PhPE2Al2i5Oo0lzt41nZZ5PUbw+zYQTim
CSY6IsYPvnd9EuHgnGMGpHVLFtnEPmNYWPpqexcJbPEGiDr9Ff8AFB/xdME3y6QqfBW5uINkiZ1V
vxTfHMv+Ha6T0rFcPUeQ9kAFzyG03Rv+ImI6odDe17LKmdpr7JmRe8wicLaXKEgzp9EZpjc6j+ia
L6HRPFukIcsEi6rK/gxe5jnZauCF49rrMwTYaZHtzC1MFqZF/wA0jt9L+F+ODPW606chrzb4Vm4Z
oz20B/v9VqUgPLqHbLyXbFzycBj74uuTrmNlnneJV3GwcVW5ZyoqrAKdhcdFxvsquATokWluojdT
UxG1uqdzJcQRdRNeFf8ARMparIEjRRInouicXTJBAV+qSaEkG6BAOswsXEiHlbRFnC3dY2KHrcue
LeTS4VekbzCt7aqjwl0MdMK7F7az9VL7ax9MfG/x3QqavY8HznD30VErc9OV9nGuq1+Ej7t6yBqF
r8KEUnam6X0uHtfbN/i0jssTHj79291ttaQ09onksXHj751rLOPtrP0tcF9T3STotRzOvzWZwU+p
wIWq6BMBL7aw9Mt4/wAcZINl0HBmzhcQJvuVg1DOOJHLddHwNo8jEaD0rjzXw9P488oi3UbKeg28
MBJja8qF9TK8gMLjC0vDoqVcc+m1mR3lnKSN1x1t33odHC1n2ZSd8lbHDcTUaPuium4RSrjDDzXg
ujUNVt+dv4zpopcEnI5ahwjGA/w7aC2it0eF4hjTmABPNT8V4wzh9HPVqPJiwB1XMUMbxPjWJMF+
Hww0jUp8W1nPq6dXheFVqhF2ha1Dw+8sAdVYCVgcHwtazDXqOLTFyulw2DgXJPcrF4p9t/Pd+B/8
N0qd342m0ETqpaHDeG0gDU4lTPYhVOM4UHh1eB+AwQo+BcDpP4K1hb6ni5Wfix15PnzNia2FOPp0
OEPdjKn/AHA2+UdVp0qfMEdtlf8A2fcDZwrHYpuUHzRIMKtV9GOrUzs8iPdeXnxmPp6/x+S5zVdP
4MthKg0Ad+pXR1G56LgwgE2lc/4Tph+DqgRcn81v4fAOywX2XlutuOf+qzMHwDDU8YcXX9dYaOOy
6nCuYW2KrDBAtIc4wrGEwtKmIDvqpti3bRogGCuK8RsDeM15Agxqu3o5QA1pC5DxV6OLvMWLQo7f
j/7ZVFrmPzCIJt0XUeAXZuKYzX4B+a5ugfSIOi6PwAI4niza7Bf3XXgv947fkz/46DA4MHEVXRrU
d+a3KGGgQFDw2mM9SIjO781uUKdtF9CR8y1SZTLTopWmNdFaxLRTw738gsLjnEqfD+D1sa/4WNmy
t8JPLXEOaRsvMcdSwVD9oDnY9zW0zTEZllcO/amKvEHUPLeGDQwrGM4bV8U8RdxECKLWimRus5f9
bwjW/aDhuG8b4VRZw0062Jp1GkZNQJWzw/gpfw6lSyn4RsqGGwWA8JnDHENIZiTGY3g9V6Dwyths
Thm1MM5rmEWISTaZXrGN4TwlbAYivh3yaeWWrk+LNy8UxP8A5len0aQFUuAvC83416eKYgx+MhcP
yZrGO/4mXbOt/wAIvD+HOafwuWySzmFzvgx2ZmIpm03W6MK0auNl5J6Tlms6Coyln80hpcLByrPr
MOglXHU6bGmbjqqT8TTa4tYwnbRRiIpDgdQvP+J0smOxLY3kL0Jhc+XObAOi4vxDTFPilWN2ypHp
/Hv9mBmaGvBac5t0VepRLqckS8clbqny6wO3VM+HNcSZO4WpXtLjjTT/AGXY58XcD+a8QweHpvBi
ARz5L3jxbTDP2SYgtPxf1Xzs6u/DVpaIG4lfY/Gn9HxfyL/eukwVAMOUQIK1qD/LN9OqocHJxmHF
VnxCzgtxvB8TVwT8WynNNmpXW39ucjD8Q4k0qOcFBwp5xODa4uEqr4hqDEYYU6ZGYnRS+G6T8Phy
yodbwtT/ACx9ocRgy97gAT7KtieFPdRloJt811mEwvmPBIOui2qPC2PY4OaLhT5NL028Yr4HK8gt
iCbaELrfANDPiakgECmTpdaniDgBpuc5jbfkpfB2DGEfjnOgRRJC3ln2xTDCzJyz6bX1K9UNEl7v
zUT6ZI3I3U/D3h2ELjcFxP1RlkNBsNl47fL34zwo8ZBFPDdG3Van6qVMGeWqv8cADMNbRpKoUgBS
Z+a9/wCE8H5ifLNeAZTVh96Q60I6dP75pbqmrWrvjSdYX0XzwRBg3gXUlZuXKOmijJIfItMWCtYs
QGGQDl5Kh3weGNA266KmAHHb3OquC/DnWAuqcQPVYzyQGxo1tdFUnKGgiBZCBeze6kqsDWsjTaNk
RRx5IwzY1lXsIT+66QmxdoqXEZ+ztgnXktDDUy/hVDLrPzsuU/26f+KfhY+8fp3VWof8cQACJVvh
GYVqsXjZVKRccabyS4rqwhI+8dqBN+qdo9J0Puk7+K+RaU7TYkmQoAOxOiKbPIMjVIgEm/ayFsin
UvI3QJ06X7kyqmJgZtOkK442EKpjNQAAlFOA0k/kjeM8bd0FNpa7STsiJJaAbrmsT8NpgYkToPol
xekwVnQUOFo1XPzNBN9kXEKVVzszw7Lrom4umvhhk8I1Q3TNvdcjUvO9912LWZfBxmLu0XGPMkmZ
9lnk+muP1UnDr4xs6AIMUJrPu3VHw8kY3XQG8IKpBfU76rH03PaXgrZxrdYBVnxGD9tA0t1UXh5v
/MGTcSpvEd+ImBtqn/iRj1JzaC3LZCABJP5onXPPdDMZtO5WQnGG2TC/MdNE7tEwMSAdUZpzOovy
3UY+LmpLxp3sg33B/RUaGB+EyTFt1p4Nut4vKzcHoSQDbXRauDbIOtr6JHX6aeDEG3LXZaFO1CsR
M5SqGCEOEAytEWwmIOltV2x9OeTzjEScRVJ1zGU1X+FG/NKqJqO5Zj+aOo2aR10uFxKgpDMLc1IW
kO5jeFHh3QYmFM9sDMCec81GsfSOswhhBVTmr9Rv3ZOllQNjCRnKEkN0gnCMHGn+qSUTt9EkVv8A
pJNjA0WLjPjctNuIp8plZ2MIc5xGn1XPFvL0tcJdqFoQ3aeix8BVFN0mD3V4Ysax/VL7ax9KnEv4
xWedVoY1/mPmdlnu1K1PTnl7ILY4UQabt7/VY4Wpwyq2mx2YxMJfRj7atMdvdYnEgBXcBa/NbNPE
UyfisLaLG4iQ6u4t02ss4+28vS1wM+s6xHJargIuQRyWRwqoym6X6EQtB2KpRJ1KX2uPpVqx9uEc
l0nh5strjT07LmXOa/GNdTHpjVdd4c+KprJZ81w5/T1/jewFgGvbqr/ASKfGGRo5jh3VOofWRYbK
xwgxxvCgiA6RHsvPj7ejL00sN4uwdEmlUbUDwYsFNiOOV8VTP2OnlaRq43XH1uE16nEMS1rSG+aY
+a2OH+HcS8Amq6mF6bMfbxS5UXB8JU4lxN/2n1hgkknddjhuFMYAGtAjopOB8MZgqJayS91y46lb
LKfptPZc8snXHHwwuAUP8XXtMPhanHuIN4UMOXNltR2U23WPwTGMp8cxuFd8QfmAVnx83Pg8Ibki
oIhZ93ys9eG0xrMbQt8Lgjr4OqKDaeEq+WWiAqPg2o+vhfLcDmabFdfSwBdE35rnfFbnnyr+GjWo
4rDU8Q8PebE81lcaYaPGsU0fzTC6UYcYfF4RxP8A3ANFj+LGBnHK1rOgwvN+R6er8X/TZ8DnNh6w
B/EV1WHw9j94664rwXjKFE4htWoxnq3K6tvG+H0WzUxdNsc3Lw5b34a5Mb2vhpNwTSLvefdT0sDS
BmD81zuI8bcCwoPmY+j2zhVh+0XhLpGHd5nUGysxyc5x5X6dvQw9NkFoMrlvFjA7ig/8FQHjoVQf
J8lnUuXO8e4nxbH45r8KadRuX4mmwU616fx+GzLdrWdFNx9S6PwDXpjiWIBeL0xuvNXcP41WBNSs
xkjmuq/ZvwV/72rnG1nVD5dgDC6cM1nHf8jHD475dLhePcPwlWsK+IYCKjt+q1MJ4pwle2EpVq5/
yNlea4bgGHq8QxJa0mrTrujO4kG69H8LVsRhg2jUw1Py/wCZkCF9GPlZdJPEPxziuPPCsQ6nw+ox
oaTmcYsuE8Yccp439n+IawkVssFq9Y40BV4Timzqwr5Z49xmpgca6i+XUS4tc0nZS43e46/j5cec
65zTH8Nva+qXPMlxXvf7OuI4ajhnYaoQXvqNABK8m8P+G247G0zw6s0UazpEXhetcM8C4rAmnXpY
smqwh4BaADAVyymXpnk4rw3rkw/22cXY7iVDCU3WoMl0cysr9nfjOpwyoKOIeThi7LE/CuP8eYvF
s8QY5uPJGIz/AE2hSeBuAY3j7MdWw1QUqWFZmc92h1MLXXxtxn6fU3DcXTxdFtWi4Oa5syF5zxOK
vEsWSdKhUH7DsXi6+ExlPE1XOpMAyNOyHEuA4niA4mPMP5ryflX+sj0fiY6zum54TinjXsB1C6v7
OLy5x3XGeHT5XFGXsbXXaVK9OmDnqNb3K8cvg/Jl7+EL8OyIMn3ULmNBJACixHGMDSnPiWexWbiP
EvD2TFQv7BS+WMca0KkDsuK8YDJxGi7XMIKv4rxbh2/w6NR657inFncTq0z5DqeQ/EUk09HDhlMt
s6sYMPbLSqzy6lOXTkrlVrWy5ziTyWdXdmpuiR0Vj3N3x22P2TU2tBOfLYDqvCMNwynXrPbiQ5om
xXvnjqo6j+zXBHLmIyGOa8rwOLONcWuwpaJ3C+xxXWL4vJj2yrHwtahwtxFDM4j8PNdTw/xRjamD
qYc4enRw2UgkrnePYNmFxLatIjW4WLxXi2Iq0fKoelsQt+MvTeHDf/LxFd5Axdeq533YJIBKDA8b
qnGZKbTUbPLRY1avUrPFCm8un4nLvfCPCKFKi19RoLyNSumteavLlx4T4+OefutjgGMpVS0O9JXc
UKbcojcLlDw+iCC1mU9F0XDamSkGF0wLyuOfn044p8fhWVaMuAJhcqYpU+LObZtOgdu66rGVR5Di
YsPmuOxWI/5F4grybUyAfYqYFcLwAh/C6bum6vPAAMCFm+EiXcHpGdOi1S0hh1g3nmuefjKvVx+c
IzOOwadDnlKpUwPLp9Vf4+300BJiN1TYAKDLc19H8J8/804dlcDew+aEnNUzblJzhpEwk0+thMWM
r6MfOSVKeR7SQI5SreJ+GlYAEFBiKeam1xIklS49jWsokuJDhPZXSIG1gKD6ZBM6FViYgxARkeuN
epsnyg0i4ajdAIcZ0B5KXEkEMgQgMbH2KPEuALSZ0HdBm8QvQbIOq1ML6eGYYn+bms3iA+6YQT7L
RpW4ZhhP4rW0XKf7df8AwWOFvy4itMGyqUn5MWXDmVLgnBuJq+oWCr4dzftRzOgLq5hc8l7zAkn2
Ty0W5pVS3zHQRrqUgGx8Vr6KAc4GYDTTVDP3bjvKd0AkEpZwbAxFwUDA3ubSoK7Ze25EKwCALnsA
oKhzEXEDUyoI8RTAykD3GihqfxDfoVZqvJy+kdVVcCew0OsLNWPRvAtLhr8KPtJaHjWVqeLMLwcY
B5olheAvKaVSpT+Bzx2cpDXrOJZUqPMDcrxXgyufbb2Y/kYzDrpu4wZfCJj+Y22XCvsSdey7zFjL
4PognUrha8BxGml16uT6efD1RcNBOM6wZKCreo6CZmJUnC/+pPpHw6qKq6HuOpBtfqsfS4+13w5H
7wbY6qTxIf8AmrtLCyHw0Zxok73kpvELs3FKl+Sv/is9sp0Zvh/1TNOsex1R2JJMzy90zZGYze19
lhQugJNIIvcdU7zpyFtUwgNNj0ukYvsJN7C2kFDJzKQ6b6fJRAepUamCFhMdgtjBNApk9AsjCD0E
AkrZwZGQ7zpCR2+mhg26WEjqrzyG4DEG/wAJ0VLCHTcRorOMgcMrnfKu2Ppyyec13SHHrqVYa2aY
AA0hVqsZLEk7qxh70QYBtF1xL7VcOctSDeCrT5cDz3lVBatHVXQMwkn2UrWHrQAQ6mJVCqIeeSuN
1MQY5qtiPjukTL0iHVO1MnCOZwBzSS9x7pIqXMdUNS4dKRMOypj8LllT0SQ2ykaTb9VFSPpKkJgh
pG6lWeiN2m6rO1KsOkZgRoq7tTorEoVYpmGCFXCnpSQABcmyqRI2oYi6CoZBJ/JSOaWvLD8SidME
crKRUtA+kWRgQLmFHhvgUgeXSINtksaxvhNhINYG0C3Ndj4dBGJc3WWnVcZhTNUdd12Ph50Yxulx
yXm5/T2/jex1QfOcOununwtby+L8NdAk1YU9YRiagIOqysY/JxDh7swtXb+a4Yea78niV6UcOxtd
5yCSZlXsPSEgfooqtZlMGYkxbdBQxTpgggd1txjYoMAA5q1kAYTFlmU8SHMJOyt1sbSo4Oo5zmm2
yw08oqcVbg/H1Z75FNxDZK6/xbxnBupYRrqjY+KBqqnh3geF4zTxjsVSkuqkh0XUvHPAdA4GWVqh
qM+GSt5WWpx/182bjV8N8ceKIOCwFSqzmF1eE45xR5AbwyOeZy8v8L4vG8GreRUksafiGi9Q4Pxi
jXYzzIY6Ndlxyx1fL19scpvCFxevxvFNw4p0aNEioDJdK5vxtT44zioNUscXMBlq7uu6GU3A2DgV
S8bD/GYZ4EgtXHluo6fjclmfh5qeD8QxdI58W6kTrkMKTA+DsO+DjcTXrO1OZ5grqKJDgTFxZTsg
RIheb5L9PZl/a7rNwfhPg9ECMOHGPxLZocG4e0QzDtjsjpU8zS4abq3hnBjjm9JIXO5WpqI2cIwT
AC7DtFuS0MM1rGhtNoawaAWSfVc0CULawmxAtdYqxdMERv8Amuj8FBo4vUyj/t3XLsP3QvvErofA
ryeMPEW8v9Vvgn945c//AOOsOk6tQ4xjppVINdxBDTe66TBcSdTgZX//ABK7ZtCl/wCmy/REKNL/
ANNvyX0+r5PeOdHETXoPZld6hGi8O8V/s843xDiVV+GofcucSCeq+l20qY0a35KTIyPhC1jjZ5Y+
Sfp85eGPCfGvDRZiaxORpnJGhXq/hzxZQxjPKrHLUbYg2I9lv8Ra3FcToYVrAWM9dT9Fk+IPDuHp
YkcTwtFvmM/iNA+ILlZZbY9uPLjyYzDk/wD0539oHgHA+K6lPG0Khp4htnOYfiHIqHhnhXEcH8F4
nhHDR5eJrkipWIuQdfpZdRhcJUr4cYrhFeJ1pOO/JBS8Q1MDW8nimHNM8yLHsVqZOfx/WKj+znhX
7o+0UMpaQ0C6yMZw/Ev4hXeyk7KXkgxrdek8PxeDxjC/DuYTF4WTXxLA9zQBrqufLxzOTdOLlvHl
fDlsPgsWajSxpY4fi5LTHhp1cZsTjKjids0K8cQ3SVPQe1y548GMbz58smQfCmBp3e7N/wCRlA7h
XDqYMZbdF0FdrSyLLNrNpgH0ha+LH9MTly/bKq8NwlVrxSiQNlylajkqVGk3BiNl2L6jKZJENVV/
DsLii6q9pBcZXLPhl/y78XPcf9ONrMveLD6KhWaWtImRzXVcX4Th6GHqVBVykDQrgOI8Xo0GugiB
+LZcfjyl093HZyTcdx48fSb4K4fSqvyt9M36Lyl2OdWf9n4cyJ/Euy8Y8K4hxbw3wpuCFSvUdDiJ
iAs3hXhDiWEAcMIWmLle/D/Pl4e2PHbrzXNcR4FjBhnVqjsztbriONPq0aLqdNhdVdaYsOa9P8S1
sbRb9kpUqr6mhDWyuJ4vw3iBZNLAYk2kkU124rtjlyuM7Xza5zglBragGrhcmdyV6PwmoG0mjcBe
b8NNehi303UKnmtPqbkMj2XV8PxdWmRNGsD1YV6M/LwYbnt2zXyJEKzQrmm6Rr3XMUuIVQ1sUKh/
9pV8411Q+im4dSuHV120+OY/JRLWiSRtssOuwt8E8Ze6TmafyU96hJcCTG6m45S8vwJxC3xAp68G
tvPPB0DhLReAVvTlb8Njz2WB4RaRw5wvqt/NlpiCO648n+q9nD/iM3xC0/cCAbbrHdVDaTRbXXmt
vj0FtKZAy6QuaxZ9bAW6H9V7vw7p4fzYlOIaXTIvopKeaCTFoKo0nAvEAx1utBoDQBfqvpY18zTR
xUtwtI+m6LFsl1ECJLfkoK782EpCTY6q/j4/wxkGG81tGc9h8wACxUmVrcM5s+oakIqrR5gOg1no
onCA/SQLIiI7aQo+I1YLYI0CkcIdA0VHiTocGgW1FlL6WHxDs+EYYEAKziK3l8Owgtr81VxLYwVJ
0ajZHj2/4DCRft2XKX+zrf8ACOlinufUcCAYk2UIxJziZ12R4Wm7ya07DkqzKYm/5XV256S/aS6I
MFOcS4Gxv0UbWSXHZItgTv8A39U2JHYnNcHqShbiDmnNuoi2SOSfIQJjXSU2J/PkC+6Z7gTdx5KN
jJEm/WVPkziBqNAmxGHARcnkhqPFrEcwERaTYGyje05so0Gl1NgqVXK4ZovzKnbUaXuEXjkqzRE2
5/JTUgPMuRb80HS8TdHhPC6wTzXC1LkhoLj12Xcca9PhTCi/VcO6865u6nL7dOP0l4W3/EVNIy87
Ku8es2Gtla4VatUMg+mBZVKmrtddJWL6an20/DX/AFogyZ5qLjcHilWdlP4YBOM0kTsq3Gf/AKnV
kfLZX/xWe1LKGyDE7IB8Gg1+aIklziSespNBhwdp8lgRvEC955JDR0X7pPJLoS1mbHkqxfYXQDAj
/VM0eoIjmmL9ELPitog1cEIbe4G618LZlmiVlYT4ZBPSy1MMfSOSR2aeFBEAwrPEbcIxJ0troq+H
kAz7wpOKuI4LXjkV2npyrzqtZm11Pgxnphp9+agrfBobqbAEFsGAOq4l9oKoDa5iw7q5TDQ0F5v+
Sq4sRWF7wrFADLoJ5qVcPZjGcxprCrYkWH1lWqnxg+2qgxDZpk6Qi5KgTj+7oQiajkU8re8JIgY3
SQE67gRom1zco+SYadZTt37brLRqNwb3UrhLgdI16KGkSJUgPyQnoTxqVWfqbR0VgGAVBU+IpCgG
inpHLlcdiFCNFKw+kbqsxPVeH4nzBYdFFUvmIhMDblKWxRoeHMAmUTBlc502Kjw8X+SlvfdSrPSb
CfxWxYaWXXcEkYukTBXIYcnzgPy0XW8KtXoxdefn9PZ+N7auJb99WOgJ1XPcdJp1cI4j4arSN910
FcnznAwsHxN/AYXG+YEx3Xn4vcerm/zXpdXCtxLaVRzzOUFWaWGaW5QSQNypOFND+GYZ5IvTardN
rdJWnHSuzB1JhtQAJDg4qz51RzhyGiuAPzGPZWWvfEBluilXSHhNEYV4pYSlFObmFqcSE0FBhKpz
BoaYnkr1Sl5zQCAsVpzHk06dQvcwHfKQtGrwkjCMxnDRNMiXUjt2VnFDCYI0RiRDajsoJ5roqDKW
HogB7Wti17KXJrHG4+XG4XitSmRTc4uYD6mu1bdb/ijFUsVhsHUpuzem4Vbj/C8Fiz51KvTo4gXD
g4X7rIxdWn5dKkazPtFMQQ12q4cvnHw9nBrLKb9jd6TLIA3UjSQBBEG881Sp1b5XiDMyrtMRBabb
LxvblhcWngjmpubuQk6qWzAzTYqr5stgnS9lJUdGUgmDdRhcbV2gxFwVKG5gCFn0HuL2gkSOquUn
BojMOSir9ETRLXC4utTgfGcBwPGnFcSqmlRLMuYNLr+yyMO4hjvWIOgCI1ZbDgHX3CuF6XbGePeX
F2Lv2oeFWkg8RuP/ANJ39Ew/an4VmDxKO9N39FxzsPSy5zRZf/KoXUKIeJo0/doXp/l39PL/AAsf
276n+07wof8A8rTHdjv6Kdv7SvCpbbi9H3B/ouCo4bDOBmjStf4Qs/xC3D0OHgU6NMVahytholWf
l39Jj+BjldbejeHPGfAcbjKjmcQpOxWIqZW075oGi7N1WmQWvc2DsSvGPCeDoUOIYECmwPDhJi8r
oP2inE08fhXYepUa0suGldePluUcfyOCY56lb+MczgWL+1UKjfstQw9gOhWtUqcO4phB5rqNWm8S
JIXlFChUxoNPEPqPa7UFxurvDcNU4Bi2iuHVsDU0J/D/AKqzLX/018cznv8As6PH8GPCKVXE8Hxv
pALjRc78lylPxLUoPH2g5mldli8Ph6+FD6TWvY4SCN1gY3w3hsdRLSzKRyS+TDPXjLyPB8Xp4sTS
qAu5HVbOFrVBHRcUzwjjMG7PgcRnAuGuV3C8bxPDnijxOi5oBjNFvmp6W4Y5f4rssRjHNZzPJZGK
xtUWLVG/iFCtTbVp1Q5msysnifHqTGxTLZ/mV2xjxW1bFSX58S8NYLwSmxnHKVOmfLIaANXLmWfv
Dir/APCUiWk/xH2AW/w3w5SokVcc84itrf4R7Karp/TD/tYOKHEuNio3CMcKZB+9qWA7Lh+E+F/t
FapV4riHVm06hAYBAsd17nTaA1zWhrWhpiNl5fRqZKuLGkVnLny244+HXhzud1UmMxvE6ZptwOOO
HpMbla0NmyzMZ4k49hmkHi2b/wDdhT46sGtLyR0lcLjcRV4rxIYPDn0zNRw2HJc+O5X7er48JO2U
X+BcQ8QYviNfEMxrBRn4nMmV0NTjPHaZgYug634qSHCUG4TBNp0mw0DktPw5gqXEce+lXEgNkJea
/Tjlhjq3JyuEo8Qw3GsRxNrsNVrVh6muZZbB4/xdsxw/Avj2/Rdt/wAP4NkjypQP4PhQ1wbTGaIB
T+Rk89+O/ThqviXjjQY4NgyByd/oqv8AxfxVktq+H6Lo/lcFf4b9s4Zj8ThuM0w6k+qTRqDYclvj
B0ngOY0EHSFv57Pbnccfpyv/ABZUcPv/AA3VHVpBWV4l8VsxvAsVgafC8TQc9tiRYLvzhGhvwDSV
yXiVjaOOLQ1sObK1hz7vpMeOXxtwnhei+nh6jXtIJPYlbNdmVo6fRWHtbkJY0A8lBiGEtbbbZdLl
2u3fHHrNM/jcRSBtDdYXN4oQ4R1sui4zIdSHp+FYGKMx7r3/AIj5/wCb6DSaPNJNh+XVX6YzRziZ
VFroMtJuYV1hJkgzsvp4vmVMWf4a0wDy0VpwNUU5MjLAlA22CaCSZcpaQBySdOS3GDYpoa2nlM81
Un4jHVTuAJBOxKibqJEDZUA5vqE69oVDiLPvJ1tF91puADh8jdZ3EAM979VL6WBxMNwVEaGFZxUH
A4TlBvysqeKH+GojoeytYtv+DwkTMHdcJ/qu1/yDDlowlYmIi3VUM9iQbdlZax/2WtYxHLRUcrr/
ACELTkntkExH1TvcAB+YURa4B104GYQBvrugdpDiTvqOikyCLj3hAxvoHIpqhcBqQI3RRbADWbFS
AkudbT8PJQsac8bjYKzQZmL9dIUDQXaiLRMIHDQka81KxsWIThkuA33KCqREgCCTKKiSSSRcBXKl
IaW0QtpZQYsORQ02OPOjw3ghMCNQVxTxBOUmey7XxCCeDYBjbuI09lxdZpa5wM2KnJ7dOP0m4Rd9
Yifh2VJwkuvsYAMq9wgx55Mj0qk+IcDf3WL6WNnwoAcVI0PRUuLX4pWuRe260PCP/VGNFncVvxPE
TJGaFf8AxX7UgJJ2iyZokXMjS5TgmTP9lMLsOgWAD5B9vonG+YlA+5gFO0+kzKsYvsTriRA66IWt
h0W1TGJvM6ck7ROgPZBr4Ocl9euxWrQ/htudFmYMQzpp1WtQM0wEjsuYfQf2Qi42f+SVdTYp8ODl
6qPxAcvBH9dl1npzrga/w3107o8AfUgr2aNEGGMOt9VyZvtNjwA9pnUKTCkZb6qLFHM0a2TYZ2Q2
gp9LjdZLFaQBYHdROEsPMBSVHFwM7KKTlv7yo3famnGiTxDik1HEXq6pJgByPzSRRZOqcNIOyIVB
ySziTY/NY8t6gGMIJujDSNAnzg7J21B9VPJJAwYN1G6mXGSpg8QZF0vMEnVXdNRB5RhGymYR5xED
5pw8XTdOsBkcJvCc0zEaIvMF7BIPEFN01AU2kCCpBqZTZ9jKQd6TcFFmolw4PnCYldfwwf4ija08
lyGGdNVo5ldfwr+NR11XDm9PX+N7auKB+1uN1j8dw1TF0w1glx/NbWNgYk6GYT0Wjy8zhO3deTHL
r5e3LHtuVJwvxHxOhgKVAYNhFNobJcp3eJ+LAn/CUW7XKpsIBJbaDspIDmWHNLnUnFFr/iLjTjAG
HpydVKzjHHIviabegaVRpFpYRv12Vljg9sixA+azc61OLFu8DxHEOKUazjxDIaZymAtQYDGuEni9
Rc94V9XCOMFpMh8zyUuAFRzYNSo7e7luY7jhctXS9j+FYt7WuqcSLg0yMxWUziTX44YPF4ySDGYv
ssTxxxSthmU8LharxWrHKLwp+FeCKNbhvn18RUGNLZz5rytXimt2rx/kay1rbu8PwXDV6X8drpEA
ys+r4AdiMT5uFx7qdURlvMLzil4hxfB+IPwmIqkhjomTdeieD+POxmNotNQkmJErneO4O3btN4nr
1KvB8aeH8VIdUA9NQCzgr1GqQM1B4fTOy0/HWBo4vGt85gJdTHdcM/DYzhTy/DONWgNWnULyZY42
3T3cXLlMZvzHY0KrXkzY8irDHTT8smI0WBw7ieHx7Ms5Ku4NitNlR9MjP628wuFlniu0mOfnFp4U
HODpzVh8F+igwVRrj6HX0hSg5iZWWda9pyadNozAglSsq5KcOEgmRKhbVY6mA4FxbrZNUqitVAaI
AUReFfNSEzl2Cas/M0QLoGtJpRayVEOzHMBCCSjYmbrEx9cY/jrKQjy8OJMc1tY7ENwuFq1nxDWy
ue4LRf8AZX4uqBnqvzGTeFZ4jph4lydZwRw/e2DNxDwux8VUhWr4cm8NXC8Dqf8ANMJB0eu/44Zd
RPRen8e/1r535X+4yMJhabTMAFbBw1HEYd9Cs0OY4RfZc+3EvGJLQYg/NdDgnZWAnXuu8eW7nlzW
CxVbgXE34TGFz8HUOZjyNFs42oKZa+m4ZDyU3FMJSx2GfSqbixGxXI4fG1eG4h3DuIH7v/tVCnp2
1OWb+3UNqywElZ/F6lE4aocQGupgXzBQ0sYG03Bxgs17LnauId4k4mcJh3EYGgfvnjR3+UFS1OPj
3d31HEcTwXHq2KqYngILMDUdlYxx16rtvDvh9mHw9OrxR/2jExLp+EFbNQsFRlGgAGU22AVc13sJ
Dlqel5OS53/jXZiG02hrGhrRsEbMRmJPzWKMRqN+6tYJ+eY0COWmvQcJeT/KV5Uz+PjXbCs4yvTK
dUN8ybQ02Xj3FuJ08MzGEuhvmOJPPouXLNzUer8PHeVZvifiLm0wykPvahysCl8PcLGAw8vvXqep
7jrKr+HsFUx+Idj8W0AH+G06ALo3wA0NMdFyyvWdY9mWXe7nr6C3M1pDviC2fBjg3jbQYhzSsSq+
XmQSRyWn4WeGcbwxB1MFYc8/ONdria9VtWo0USQNOqp1K9cAxh9Oa0+IfaBWIovpsb/mWfVL2tir
iGz0WHgYPGKFTHsdSqUoEa8iouEUK2Ewxp4ioCBoVo1qbHE/4hxVF1Cm97hnqOj6rW/GkWXAESII
XGeMmluOokmzmELrmkMAYNBbXdcX+0Wr5DcDWuBnyk95W+Kby01jdXbCqSGkCx6Ia50zA6ap3uBo
jX5p8QM0HS2y9Ud2Rxp33lLc5Vi4gUhRZmJDp2C1+NEeZTkkelYddzBZwJkTrovofiPnfma+wudR
DIDiBPLRS08VTBMkkwoSKZBOQiHaI6TKLtGknUr3zs+d/VdOOomk1sEEa9E1HiNNj5BPeEIwdN1M
P0DlLh+GUqlibfmtTuz/AFB9vokk3nXsU37xoCSBptFlI/hjGvIkWQjAUiL+1lf7n9CqcQoOMwf1
VXF16VQhzSb9NVZdw6mS0HdVcRh6dIFrgT+SXv8AZOqDE1W1GMpskAb9VafiqdbD0abswdTCq1Kf
lZSL5haVfbgWMdQL9KgXKb263XVE3EU2U3NE5TcqEsombnmJVnF0aVJtT06GDdVyaURlJWvLn/UB
FEakj9EwNAA+p0pF1E/hIB+ikpU6T3H0lXyf1MHUQDd17X5IJokyHOB/u6s1aNJurSNlA5tEasdp
ZPJ4KmaAm5Nyjp1qLZlziCLjmlTZRe4yDYJMo0YuHAKeTwPzaBkFxnsm86jrLoG26c0qAEwdZRU6
FB7somdpTyeETsTTjUyUJxlNrYBMHorLsAwCx72UGIwVJrROs2TyvhZr8YZinYdkENpNgXuSudxV
QvqvNhJm61+J8Lfw2lQquIIqiQNFiVPj3nQSs57+2prXhb4V/Dr5RbLyVV8AGw21VvhgmjiCQdL7
Kq4ekkWI5qX0Ytvwc2MVzhZnE5PEsSZPxkLY8JiHEnQCw1WNjDmx9cxbOZEWVv8AlZ7VLBxCYfw9
JJRHTT3TMJAIgAarAhdd3P2RBxbMf6oXG8x8kbRI5DWVWAOdPqga3SpAh19OZSda5v3Sp3fedUJ7
bODEMuPZa2FFptyWbgxDRsOi1sML84H0VjsvU/ggDv1VTxOY4MQIV+m0Zbjbms/xXA4U1vMhdfpz
rh6oJESUFOmQ7/RSvME2KHPJNguJqHfJYQShaC0ztHzTh4E5RdIVAbkfJRPAi8kRIQ3jS6WfqSZT
B4Q8I3MJJJPdMGQSjz3smLxCGoEMtq33SR+Z1PySRPCCU8mEw0TxzUZL5pDqdUk/yRTSlPNId0tB
siH6FNNk4HP6JAIptynSjmnhAh3S909o5JaiEB4e1dl912fCj99QIgaLjKBAqtN9V2PCj66B2C4c
/p7PxPbexroxNzaFo8GwdLF0qheNNI0WbxIffNO55rb8LCMLUc4QCd187O6x2+jndLDeBUTOVzgU
FTgTGiBWidJW2ajKNMve6GgSsShSxXFceMSXupYemfQOa4zK1z7UJ8PVIltQe+yAcBxUENcDN7rr
YhsdNVYpMAaZsYlT5aveuR8KUXUsDxmlU+Jr1bwlLLTkzzjqg8NkPxHHR/n59FbcAykQNTsvbhfD
jl7eZ+Omv+3U8SwjNTMgHTVdv4VxzOLcH81peHMbBhY3iHhVTG1WNaPS4xK7TB8KocG4CzD0GBvp
uV2zynWRywl7WvOvHHAxWwzsZh2/eMuQN1j+DuOfZMVh3NLhWa8AgCZ9l6BhatHHUalKzoJa4SvO
uF4D7H49o4Z1medPsrNZY2ZEzy48pcft7PxHjJx1am6qWWYBZRNLHs9JBCh8b8JP2rD1sCfKqmkJ
A0K5mnxLFYKpkx1JzY/GNCvmZce7er7XFy43GTKabuP4TSrTUok0a/8AM20qpR4ni+G1fKxzC6nt
UAVvA8Wp1WyS17eYV53k4lpa+HArnuzxlHT477xqzg8RQxTc+GqBrjyK0KeJLTlxDNfxBcdX4VXw
jzV4bUynensrfDuP5XeRj6ZpVBaDoVm8e/OLU5frN6B4dpUsRjiyo7NTyzK23UOE035XEgrlvCZd
Uxz6mEfOVk5Tut81MNiK2TEMyVZ33W+PGa8vNz77bxrpMHwXh9ei19OS3urI8PYEDQ/NR8Iy0aAa
z4QtF1WGF02XeYY/p4ryZ/txXi7g+FqYjCcPw+bPWdL4OjQt6h4Z4ezDNpQcrRELB4bXxWP8TYrG
sptfRpfdUyfquhc/iBcQKbAD1WZhj+nTPlzkmOyo+HsFQrsq0pDmuzBXOL3bTA1SwTcRc4jL0hLi
VwxamMnpxuVyvmsgYKZdm9esq/QcadOHRIUQcGgjUoHVbHoqJziRzhZHiDD0OI4Q03w2oLsfuCgx
NQkzmIOywPEPFPsmFeA6Xxc8kb48bvw43GeIMY3GHgod/invFMPnQc13uBZR4LwujgsOfvXD1O3J
3JXFYTws3iGHfxKs5zMe45qRnRWOBcSr4jiRw2MkYilDT16pp6uXLvjrH/8AbsaVbLjHgHRgWfjs
U5j5k31U3/5CpG7Aq9fDvqv+G07qvIlw9Q1m+ghbWEZ5VMgm5+iy8BhRROYn/VWuIY2nhKDnTc/C
FNrJb4ir4g4i6hh30qDvvXgiR+ELxjC06nHOKVKQObDUnnMdczpXfcQrVsfVfgsM4/aq7fvH/wAj
VieFeH0uGUsRRALoqEE7lZyvXHf29PHdXpj/APtq06Yw1BjKYhgGg2VeqQ71T6gVO6pmJuJ5EqrV
G+kiJXlj0CzA03ZBYDU7qbglXLxbCuB/7gVJ7oOQkxE90eEqGnjcP0qD81rSZeq9P4piMmMpAUHV
S4XI0Cr13uDjlwkqSscQ+qxzagbTy3G6pGlXNQufiTl5Lk8CKu6q6f8ADtZvJWViZa9pNem0DYLT
rUMwIqVXuVKpgsNBlma26ssRRq8RoMeAak5rWC5H9qNRr+AUntcCWvBB21XW43B0qlJzGtDDsQLr
hvH3D3UfDVYuqvflOZejgmNyjGVsjM4dVFXh7XxIIv1UmJfmy5eWkLE8KYrzME6iT8OgW04CDJOY
L05Y9crHpwy7Yys3jX8VkEaarnsX6XMde14jqt3i0is3kAsas3M5ubcGLr3fiPn/AJoasOoNm5nR
PSLQBmNo5bocQA1rWTf6/wC6EluWw7iF9CPmtl1QN4fSiBLtY7p8NVY0gkiDYqli3kcJpOaR8W26
qeaQymQQPda7aTTcrVqbnkTNlGKrYcM0j5LG88h+sA9UDcQ6Z/W6vdNN8VGz8Q1hZuOOYuIgidgq
4rOAnN87XTkl1NxmQDPZLlskLiB+6pXIOXQrWewPqYFu2XksjiVqdKSfh15LVrvNJ2DdFwzdc57r
pfUV+InK+o0ERm/RU8ksENNtLqXGONSrmeIJvCei+AS6LbqsqzmXJuDzU+HABA2nTqpK+UHl23Qt
BD2lv0QDiXQ4gblV3vGcK08AyS6Sqr2jzBcD8yEBU3RUJVik6GkuF1WaB9VO2QHXA31UUb3Aja3M
IKTvLqg6W/Mp2AOBvohyNzXdA3HJBafi2kHQkfNV8TWzua1skm5CEs8yoKdLQDdNSpg1m3NzbfdJ
DbY8cOy4Lhw/yTHsuKLhsCDabLtPHo+44eNww2K4xxsbaDVTk/03h/la4bAwmI0I0VWoQWut7yrf
Dx/gsTsVUqwGE7E6rFXF0PhP+HVMxaSsKuP8ZWuYzHa63/CgjCVSJ0N5WBWgYmsTaSf7CX0s9oSf
S4315ICQehnRE4iLfKUNNssmBGvdZVGDc62Rgwf9UAgEyjBEEX1tKrmBxgEx/olSHr6pVIuQbdEd
CM4B5os9tvBBopiNRdamFBN53WZgwMjdRJ0C1cLYD81cXRpURYRF7rO8Y+nhzBNpFlq4ZtmxcTos
vxtAwFIaeoaarr/4sfbhKx9Qt8lFM7KSv8UR/VRtF+pXFi+y52SHuAn21S58kQP93Tf7J7QeSYoF
2CbYwnI/3TBQOY5wklfYlJFCkPZIaJDdRD7lOEwTgTYIGSlPumQONE4TCU40KKYf2U+yXM/2U4+a
CSlTdVeGt1POytjhtdzsoAklQ8PP+JZC6WlHnM7jZcuTO4+no4eKZzy5vFYSrgsSGVmwdQul4O4H
yechUvGLf8fRcP5e6n4NI8sCwka2C553tht34sZhyXGOr4m0S3kQtLhDZ4Y8OdlE6iyzeKH0UyeS
2eC0W1OGsa6wJmF8/K6xe3laRosrYZlN1W0QIOqenh8RSAFOoMoUIwrZABPsrNKgWggPfGnNct6c
NHa7GB0B7StPDVaow1Tzg2QCRCxTweo+pnbingnUKR2DxGHovcaxIDbydUsli472qeDzmr8cN/iH
5Kw6uw4oMLgYGkrM8H1cp444jQgz7LnOL47EUsV59E68l7+PHccuTLVeiUadJ1RryNL6K1xCsx2G
zVHBrQN153wPxX5ji2pYDZN4p8Qk4A06NT1OsI5K/Hd6T5JraXjTafCMbQx+Ff8AdV3w9o/NRY/A
k+MOE49g9FQgGNisnjDq1Xh3DKZJc3NJ2XZspA4LBPLZNN7TrotX+sZx/tXYeJ35X4QnQ01i1qdG
rSEgOnURstfxNU/6Mn/091jU2ZiXNJjdfMz/ANPr8X+IyOIcEyt87hr/ACqguWg2Kbhp4mKeetga
zqenmUxIXR0WQ1+YaDcr0HwhwxruCUXtMF2x0Wfk8avkzyvH5xeZUMQS069jYocZRo4tmSuy+k7h
eo8W8P0azCX0GBw/E0LjuJ+G+I0ZfhafmsGw1WMbN+Gp+TjlP7RgeGmcU4Pj6lXB5sThw24F3Qu1
4dxrB8WIbW+7rCxDrEFZ/hR3k4xwqk0asQWvELX4xwLDYqKr6Pl1dRVp2XaZz1k5ZY7u8K38EcTg
6U0XefR5TdWOK8bpUuEV3NcW1i3KGnWTyXGcPxfE+CvjMcXhR/8AIBQ8c41hOPcVwGCwzvLeHeZU
OkQta8biYSZZazj0Twzg24LhVIPgOcMzjzKt1+JUachhlclVx+OpsFKvL6IsHtV3CMZXpS12YH6L
Uycs+Oy7dTh8Q2rTDgZlV+I1RYEwsii51L0te6EVSrn+I5u6rlo76jATDxKidVBmHCFBiXsDfhEr
FxWNbQY55EAaAbo1MbfEWeKYwYdhAP3h06dVxFYv4rxEUW5jSY6ajtieSs8QxtXEYgUqZnE1jAH8
o5rc4dw6lg8M2m2J/E7clWfuulvX+sWeGFz7EQxtgOizfEfDnec3iGEEYmiZcB+ILYwbWte1jDrq
UfH6NTB4M4ikx1Ro+IDVRnC2ZeGRw7itLF1G1m2OWHNOoK1nYum2nmsRy5rzXiNfE4XFnGcMoVDS
cMz2QpsJx7HY9gOFwr3EWNtCq73hmXmXw7epxHJJJiyxMbjjXNXFViRQogkDmdll0quOqOnF4eqG
iLBNxqji+I4anhsJQdToTNQpJusZa454u6veAnedjcRiKkl9QSSVSp1ctTGak+c4WWp4Pw78Ni6r
XtIhsLFouLsdiPVb7QfzWef0n4/tcpMq5ZFN3SyB9Ouf+06Oy7+nQaKTCGico0CixdCMNVdTa0uD
SQvH2dfmefVMPVNVp8t0RdDSpVGYpjnMdDXAyt/w3iDxLBPdVYWVGPLXNcL6rQfhgDotdteEvKPi
Hi3h2CpjzHVDDRo0rlMX+1HhVF7mtpV3HT4Va8U0DS4e5wFwQvFvEgy4pzpiTsNF2/H4cOT28/J4
m49OrftVwha4U8DXPKYCzav7VCScmAd3c4BeXU2vebA6q1R4diqrgWtdPZe3+LxY+3CZ5X07bE/t
Nxbh6MEwcpesDj/jbG8WwVTC1aNNlN24MlV2eHsQ9oc+WhTYfw0CYqG/I7q448OHmQuHJkzvDOK8
rE5djZdk854O8BZdHgdHCuJA9WoWix0NAmYWeXKZXcejhxuE1VDi7ZqixFvdZ2Hwr8UXGnAFMS6b
QtDjFSa4Olr3UXh2HN4gCY9PJej8fLrLXn/Jx7WRQrYfPDWvbc81QrNdSeWu1bqtEiKtPv8ANVuI
tc3FVBGpmxXt48+82+fy8fS6iZ4H7uDQR1CpOJ8tojS6sl/+Dyje0KvfM2fzXRyKncFqBsHRttb7
KWk1wcQBzTAEHUSd40QCCBIgyrbGj7MSJBBgSqkEyPe+y2G0mjgYcRfN+qRFDiQAZTG0c1tYtjfK
wxcJin+qxeI/9v1XWrxIzQwzW7sv80nut30pYsS5g0nRV8pbYEFW8RScKtMCQ4hC/CVicwaY00+i
bSSqzXEnvAhSgemSdYKd2GqMpyWm41AhMP4cg9DCS7NaINGiic0EzqArVNuYQb21TUqbs5DJ1SkQ
sYSDO/Mo2C41jlOl1KaTg2R+SjpiXXIB1t/RTZoouRMyEIaXDSDCMj1C0pqVTywbCd5CAsOwsqOM
OgAoaDCa9M5SL6+6sMxI8twc0SRZHgKU1aXeFrFE3j+32NpFhTK4yqLGdNDGy7b9okjFYMNBkMXF
VCY+UHVY5P8ATph/lewMjA1yIE6SqFWIMzrEK7hY/dtWwEnQKhUuZN/1WauLp/C4jBVtJgrn8RHn
1TOrtyt/w7bhtYzMBc9UhznmBGY3S+o1EAIiSROiYCRbTQWRaDS2mlpSE5RJiPosojixv7IwIa4S
PZD6TO2xmyNk5oN4v/qqwB0EG8nZFhwM4vqhcdJsNNU+H+ICbk36IuPtuYMRTHM/RauFHzWbhWjI
ORGy1cO2Tb5Sri6NXCXDYNgsfx07/DUG/wCYLZwo+BwPusLxyZbQbtK63/LH24qq0ucbEqMggwrT
L1b9io8V8d7rizYgF+aW6QEypBYco2RlEk1pOgRv1F0NP4kU5pkAkqPn0Vk/C5slVoupKtmiCScT
GhPskiBS5pJc1EOB7JN1Tdk4QOJhJIXkJe6BDun97JtUQRSFtZS1SG8C6R0iyIsYA/4hlp9l0jTD
29wuawn/AFDCuhn1D+q4csez8b1UfjATWoO1si4S4k0+4TeLR/0xjZNws2YSBeFif/jdv/8ALXX8
Rvh6J6Lc4PWZTwVNpqCQLglYWM9WGpWmyqMIymC4R1uvFce0evObdr5zT8LwdhdTUn9pjmuFaXQY
e8aCx0UrXVo+7xNRpnQrHxf9c+tejUHjLb3RY8j7DVjUtXnrcVxWiW+VigRyI2WlhOK4+rRczFPY
WkRIlYvFZ5axxu0fAA6nQ46bTr9FwuC4g7G4gU6zoYHQb7L0TwnSGIrcXovMB8A/JQ0/APD2VC5g
qCb6r38ecxnl5eXC3LwqVuBcOxXD5whyVosRuVxXG+H43DZXYhhyAwCvVMJ4RwzB6KtYdnK9W8G4
TE0fKrvqvZyJVx5ZizlxXKPGqmLqilRJu1pt1C6Hw/xjG1KcPqNdSzgBpEEXXeM/Z1wmMrm1IA0l
XcH+z3hVOoX0/MBkHXqrly4WM48WUqz4jJfTwJEEGnus9xJc0GLara8U0m0PsjRIysIBK5wPcDMk
9V83P/T7HD/heNQNp1HT+GV6n4SeGeH8HJAloN14zjq+XD1Du6Gg9zC9h4awUeE4KmaZcBTGmy5W
aY57vw2qjnOBylsJ8MxwBzgDoFnsyuORtN7TzV9r8jRlBIFll5kGN4Xg8U0ur0mk8wLrE4hw/E4C
l5mAqmrTaJNJ957LoxWDnZRM9k7mMDHOIm103pZbHBYPi+ExLnNc4Ua7ZDmO5riPEPDCzjn2vCVf
Kr1vhLTYqt4v4ZincUxuKw5eGueYy6rl2DihxdFzq9SsKJkNXt4+Hx2xrrPyevjKbekcJ8TY/hmW
lxSialLQvAXX8N4lgcewVeH12sqfyg/ouW4HxfAcRw7aOOaGVwIIeEWP8KscfP4XXdRqC4yHVYs1
fLpLjl/mus/eDm1yzEsLDMB2xVt1UES0y0jYrz2lxzivCnihxjC/aaGnmNFwtfh/GcLihn4biQRv
SebhWMZYN3F4gNY4vOVo1K5nE1/OFXEVbUafwgnVRcW4uK7i1vposu48yqOGr/bKrXVyKOCp3DSY
nqUmO/Jf/jmvtp+HcG7NUxtcTWqaA/hC6FtMlpL3ZWjdcpifF+BwzxRwLHYmqDADBICo4jiWP4nb
E1DRpG/lUzB9yrllr2xjx3L07TB8Tw9TiLMJgW+c/wDG9ujO5XV12U/srs17brj/AAXh6eHwL6jQ
G3gQLLpcZUnh745Jjd+Wc5q6Y+I8lkhrGw60RqubxuDdwzE/vHh7fuzarTA+quuNVzwXuESrbKrW
tyGC0i4VMMrEnD8ZR4hhm1aOUg6g7LN8VcZq8EpUPsuF+0OqOgtBVGtTqcFxxxeEBOEqH7ymNlX8
TY1uKxeAdSMtdJEJvXlu4bss9KtHxliwXk8He156hZnDMRVdmq4ikaT6lXNl5XV4ugkiCVXxL82W
f5hZccs+00748cw8x6f54bRpyDBYLoHYthboSFCXBuEovPqhgsFAcRUiWU4ELy6edAMrMe51GkWB
3xwNVK+qCCfayhfWq1WEBsHcocOC2kWkmQdTyVRncfpvxXD3U2CXOIjkvPsb4TxNaqXPpg3XpeKJ
lh6i6At3Xr/HnjcZt+nmtHw3Vom2H06K9SwFSmI8gggcl3JFtbqvUgExfZd7jv3Vx5Ov05A0nt1Y
Y6hVMQIeC1psOS7J8EwRP6KpiqGejU8tjS+LW3UmDfzf8cVVf6jP1UZaWvDmmztpQ8Rx1T7Oylia
Yp4hlSHWiQkTORw03Wrj1THPso8XB+0NIjRB4ZIaceSfw80fFTNcSNuah8PO+64hb8MQF6OP/NcO
T/cQgtOIpwNXWVPGuzY2rGmbZTU58+lImXKriP8Aqq0W9RXr/H/y8P5Psqt6YEX3CAOEtFzHNIxA
1joFHMGW6813eZZpAeadYiUMzbY8xqnpR5t9IUbmgOcAfSbaKiallLDYE8yrTcUDgPIDY9Uye6oN
mDEwOmqNotEa8lYi1xGD5XbsVocRP/T6QGfqsriEzSkXgbLV4kIbQ9P4eSzPddL6g8MRVxdL0m3R
dp9mpPwJPlwey4vglVlLH0zU+ERYr0qjj8E7AuZLJXk/Jtlmns/Eksu3NcfwdJnCZDfUQuJAIaRz
sF3PibEUv3e5jHTI0lcPUccmpAC3+Lvr5c/ytdvAqZAOgtdafCmscxxc0krOow4czGvVa/BHUgx3
mRquvL/lw4v9JK/ljCvAYAT0XPmw97dl0WOq0jh3hsT1WJENBE32WOH03zewNZLtQVA4bDnZXMPe
oZ5aKtXaBVdaBO67OKEOhpAJCu8LcRiKItd4AVT8MGfYaq5w4DzaER/EHsrPaLf7QzONw8fhpri3
2AO/Rdf48cXY+nB+FmoXI1HWAbYDWyxyf6rpj/lcw1uGvnn81TrkkEmZ6hX6AI4UTH4trbrOrO9J
/lUq4+nS8DMcIrOFrb2XO6Zj1K6PhJP7krEkzH0XPU/gcRMe6X1GogIN5ukf4WpgFEZy3F+yRJ8o
AC2kBZEQNrgR3RciBEFBpJjdPJuJ9gq5mMESEeHnOL9rqIzfeVNhTDweSLj7dDhDNNpEWWnQibLM
wjzA35ErVw82N4WsXRqYaQQub8bn73Dt16LpaGok3XL+N3f4mjpot5f5Y+3N4eM7iQTF1HWPqd1U
lAQXWvoLqOtGcgad1xRC/TrpZJvwSNEn6a6JNuzmiX2Th6o3UejxttopOXJRvEEd1UTuud1WeIcV
ZF26GFBWEOvCzG8vSNJL5JKuZJkk/NQMnCSQ63QP/vqkEh0SB1QIJ0w7pwJ5IHB5wi3IQDuniAgm
wv8AHZ3XQtMlu/uuco2rMmDddG3QErjyvX+N9j8WNnD4dwn5Kvwv4WaxZWfE8OwNHpFlDw0D7OD2
XLH/AA9F/wDyOsxH/SUd7KrSs0zppdWqnqwdESFVyljjBBAPyXmj1ZCZd95kaKw3LZwN+gsqjZdt
lB3P5q3w51IY2mK59JMRzTSb0lpt9JIurTS0M9Nuam4/xHBcG8s1cI+ox+7bwi4VxXhePpB7MJUa
3qpePLWyc2MulHgnGMLwbiOM+2PLRUiLardHjPhJuKptbRZ3F8R4foBn2qi4POibCU/DdekKlMEA
810mPj05Wy3216HjXhDXQa/zC1MJ414I5pzYto7ricXW4HRxNCnTw9Sq15guAnKugpcD4JUph4zA
Hos2f8Jr9t53jPgbZnGM5qfD+NuBWH26ne0krnmeHeBvdHmgTzCjx3gvglZoLa4adrKan2up9Vt+
I+J4biTMPWwdVtRkESFgl0AA7WF1o8K4Hg6eHNDC4tr8gmAFnVBdwB0JHdefOeXs4rOuorVh5uOw
NAf9zENBv1/0XulOnUbSoik4ANaAQV890uIUMJ4q4Y/FvDKDKmYk7WXtOC8XcGxAaKWPpEdwufJj
Zpx5LvJ0NXz5+7g80DK9YOh1MBs3MqtT4xgn/BiqTv8A3JDEU6r5NVjm7AOXHbmuVMbTp1Q3KXOP
JSVnudQqOqWGU2VVj2B0saJ5qTG18mCqGdoTe/A5cYRlVlUEA5p1Cg8O8Co4OhVOIptNR7iSSNlc
afSMm14UrHVKhOd0NXsx8TSVk8a8P4HFUy5rRTqDRzbXXL+fxXgbyadQ4ig3QE3Xf4g020zuTZct
jXtzkagrcv7P/pHw7xVw7iLjRxYFOobFrgqXGeBcPr4umeH1PKrESTTOgXNeKcHhQfNHoq/hgqj4
VxnE8PjTVAdiaDfila+Oe8XXHkuM3k7vhfhyapPFTUOEHwFu/UrC4xwrCHGVmU6tSpSabNLzHyXp
XAvEGD4lhjTcWsfEGm7ZcJxjD0347EGg7L6zpouWdsjpxdeTLeShhWUqDQKdJrY5K6wsiZAKz/Nf
RqRVZImJVqnVY9gLTN9lwr1ddenW+EsVNOrQJuDIC6HG1D9hebwAuD4DiTQ4nTJsH+krvcUA7COA
vK7YXw8PNjrJyDsVNr22VnBlzozEjl0Uv7vGYuiJVmlhDkOX/ddHImtY+mWVAC11iCuB8SsHBuM4
fzHk4Z8lt9CvQ/KLQRdcb+0HDNxX2dlQCRcHSCp4+3Tjy1VCjiQ4uykOB0QOI1AXPYPFVMHV8iuf
SPhK2qThUyxqVyuHV6//AKen0KmbC0dD6BZDUqRdZuA4hSqtZQpvzVGNGYC8KWrWA2M9l5uleS+E
j6u0XNrqLzN+dlRq4trZs75Ksce28NdPZanHl+mdxexLswZt6kNVtUH0ub0BCpGq+sGtpscL6kaK
xU88j0ubC9fDjcZ5YtR1HYgA2YVTqVcQXAGk0joVZqnExq0nVU6jsSBdjSN4K7xk4fWLgSyBuZVx
gBaJiVnNqV5jyj/qrmHqVHNGdhASkch41wFCtxDDlwynLNrLJyZQBMidey2PGFRv7yY0mD5Z3WMX
nKze8qXbphIpcW9NWZIsqfAT93jrmCFPxcnzRpMKvwJ2WlipN3aXXfj/AM1yz/3BsZ99QB3IKq46
kW4upLTJJ30VljycVRn+bsmxLmVnve3XMV6/x/8ALx/kzypPENEj/VQBkAn20Wo+mBhpDbbkKLC4
R1cHINNCvTrbyqjREyQXRYJg2XRcDYLRdw2tSl7m26BVqVM57D5BLjZ7SeUDRcxNrqVvq0nWZlKq
2Kjpn3V3AsBwtV5ILuikVV4hAq09h9FpcRBzUgRYsA1/vos7GknEM9gJ1Wpiw59ZjGn8AUnut31F
Ey15gkGNUX2qq3R7h7oagcyo6RfvuhbAE6nW3JXUqS2eklWtUqnLUeSDYKMtkbwneNOupA0RvHqM
3kqSSekttEz0hkj5qNji11jupalgy4NrwqxBJcRAVEzHEtmT1Vl4+4BgyTqq1JkUiYvP0U7JbSDd
ZBuoCwgDqrjeAFVxoIrOi0/mreEBc9wAGl1FxBg84A7t2QZ0GT315q/wv+PREkHzAq4pmXWBHIKx
wykftmHuD6xYqz2g/G5/5hfZoC5R5iRFx+a6fxn6uJPBJiBvdc28Rp0m+qxn7dcfTQYI4MDe7pzL
Kqgjffutd9uEMPN09Vk1JaNZkwpVx9Ol4eMvh+oYOm5XPUx/hySYuuhw3p8OO7bLn6dsPJI1SrER
H3e3S+qd/wAETI1TgkCP7hRvgtBFxssiIm51JCPTpfRMJDpB6aaIoMZjGirmD4T/AFUuFIzxJHZR
1BBjMO5UuDgVWkgQDsUXH23sLdxgEnlzWvh7NESdllYKJMg2WvhuRP0WsXVo0RdsTC5XxmZx1Jo2
b7rrKIbmg2Gy5DxgZ4i0bBvZby/y5/bCob/moqxJqGCOkqXDXzKKqMznawuIiqWFvmk0y23dKreD
qhYfRcEpGb7GbRN9goqmgKJ0ZRYaoavwjmqiWmZaCJQYkck9G7fonxAlh+ax9uvvFV9/okl/eqS0
4lHRIbptCkNVAQSGiIsjdO2mTvCbXQI+qdH5R6JhTPRNnWhCdu4EIhTKfIefVNrqgHOTCeZlEKR6
JeWeYhNmqekfvWxzELo2yaY3C5xjIe0nSV0dL+C0ztuuXK9P432k47fhtKTEQoeGGcNpIspuM34U
wSfdQcJE4cgahcZ/h6L/APkdSan/AC+mSZIUDDM5jA5bIqUfu9l5uoGuBOWLC+i88j02pc8j0gDk
FB5bv3xw2Z9VYWUjawaBAnqoKVQu8S8MkmBWGq1hPLnnf6u549Qo1fRWaDDdCLBcq7i+B4a003uA
g/CN1J4+4y/C8RqUKQIeW2hebuZWxOIcS1z6hMmO69OGG55ePk5NXw2uL8WPEsQ5zRLWAwFFwiat
fNVqFtFuoB1WnwHgpoUXVcS31OERrAWbxbBnCvc6i4mmTpOi6TXqOV3/AKrq8JxTBUnNEA7aLs8N
Wa/CNc0gTz2XlHBXYbzAax9VrkrucNi2upNa14DYtdcc8XbjzbDmub6rWNyrdCr5tIzF7dQsn7U1
lBzQdBuqmE4lla4GzfyXPq6b06fwphRR4li357FhWc8jNUtoTE91f8I4nz62KLSDDCsDFVnCnUDS
ZzH9V5+Wbr2fj3UrkfFtXNjGwJNzZYlN7G3HzFltcR4dWxlXzDpGioO4ViGuhoBBXp47j104cna5
W6DRx9ZhmlWrMd/lebK7R8QcVoCafEa43AzTt1VH93Ykfhnoq9TC1m/E111rphXP+0dVhvHPH8O4
ZMfn5Zm6rvPCXjPinGMOW451MsNpbaV4plfJAZUjqF6b4Apup4AEi3ULlycOEm5Fxytr1nAvz5Qb
W+Slq1PLc4TE7rO4I8ik97uyj4hiyXFrNV59OwsZinOdlaTfksjibvIpOqOmfwhWW1Q2alRwhupK
wsfxEV6pq5cwHpp0+Z5qyfpvGT3fTkuOGvWxbPMkFxkxsF2Xhp9KlhmUaVIA2mQsUUq/nOFRgqVq
l3k/h6LpuEYcsAkAQNl1yusdOVyuWW2lV4VhsRh3vE0qwE5xZedPrcQwWJrF4NelnNxqV3vGsWcN
hRTafXUtbkuZa4GoWkWj3XDLLXh6OLDflVwvFqGIOV5yknRyndTY71UX5XHraFUx3D6GJu0ZHncW
WYyjj8ESaZNakNt1mY4307zPLD236eKqUMhqj4TYr0/h+KZisJTcx4cC0WleQUOK0KzPLrfd1P5T
zXUeG8fhKzG0W4g0q4Ea6q44WMc2WGU8vQRSBujDA2wF/wC7rHZisRh2fezUpj8TVZoYgVmzTqz0
Oq089xsSYiNpXGeMoNfDyZsdd1t+JeI1uG8Mq4hgD3ggBvNcRiOLYjilZrsVQFLILXmUs8Lxzyye
IYMYhjgRDgfSYVXheMdh63kV7EGAStYuDiRYCYVLHYQVmF7Ble3T+imN3NV6pdOw8Hj/ABOLqwMx
AutvFV8oN7LjfA3E2s86jiCA+wkre4lVvFlvHHXh5eWaqDE1yS/1tjks8Yl+b4rfmU76jdmAtTMr
MgzRGui6yacLU9PF1dM8W3U7cTW3MhQUnsNT+FtsrAq0st2XV0gn4l5Bk7aqB2JeBqE1XynbOHQK
AtpAkFxskgnZWeXWA6hadIzTBdrCzsKKTnZlptDQ0clK1HAeLC1/H4m7afJZzzAbIgbq5x9wqeJM
TB+FoH5qjVIsN+ildcPSjxY/fDXTkszhJPmVuUElX+KXrX5QouD0muwmJduJXfjn9a4Z/wCoel6s
VQAEidFToNcMVVFozEfVWKB/xNEiCAVLUDRUe5sAzyXq/Hnh5fyL5TViPshZlAI2VjgRyjndV6wB
wrp1HNQ4TEGiwkbcl7Mbq7eOzcdBj3g4ciB/osKmBPbWRonr48vZlJVMVHe45lOTPtUwmjVvjtN9
1bwLpw7m5rn6qk6S7Wx6q3gxDJ33WI0g4g0DFU4FpGgWwTOIkahgssniNsZSHUDmtGqf8QTecoWc
fdby9RTxBms9wGpQU2gh07JVTd0kc0YdT8u3PTRVkxMhhbJA02TudYOnbUJpaRIk90+WCA2QI5IF
UPwzyQDeCByROvA5JU4uCQUErR6A0ATMqdrS3KMpFvkoTDWMjvdSVJzWNiN9UVJQlmZ3MREqHiIm
owzPpurTWFtDO0zMT0UeIHmPb/4jRQUw0ted+ys8OA+3UNPi0TspZuSnwDf+YUdYDoSeyxk+L3f8
3rAkfD2WC6DbQHcLb8WR+96+tisRxlp7rGXt0x9NOof+U0oMnNssqtAEiJ6rYq//AEqjYHdZFbrI
v2TJZ6dKAB4csB8K5yzcK3UGdOS6XEjL4eaLD0rmn/8ATtAmyZERkW207IXusDcxc9ERMgGNkBls
mJ3vqslMy5MkH3SDjc6+6TLSPc9kI1POJsq5mMH4wQpcIIri51UREiynwY+99IIujWPtv4SJcTGi
18NZwkkHqsnAjUuELXwxyui8rUbaeH2gey4rxeZ4odzl0912eHfDZcYAFyVzvHuDVcVXdjCCygRY
ndM85J5SYW3w5fCwW77qCr8bp1nVaDMOGVDSDr6id1QqNLXO7rnLKnWxDVu3oUh8Jsk8GAA02tol
t21stRi+zPs0AxqmqTkP6JP+AJP+AIh6HwuH5qWoJpxHt0UGHNzdTbfkud9uuPnFTP8Adkk51P8A
VJbcjO+N0JmmDKKqD5ju6AdFEXAWObqJCFhAFyoqJF5vZSDKLQs2OkonFqCd8yeRySkIWma6J0IT
5+RTEhNN0TY2vi09kWYbm6iBvzTAlNEqYEW6Gy36BmiJP9/3+a5wOiL7roMM6aP6rHJ6ejgvmrPF
/wD6Q3Ud1T4U77gtJ9pV7id+D6DRZvCXfdOGvdcsf8u+X+3V0z/yxkalVmzE6qfCmeGAWOyhbAMa
7Lzz7em/RFpbBsG9kFFn/wDUPC43rC3spCCZnndV8LUL/E3CulT+q3h7c8/TR8Z4D7T4hqukZA0S
NFRptwuAbJDcwGyseOMc6h4gxDGEXaLlcnVxgc4uc/M4r0Yy2PFlZLWziuMvqZm0rN37LOAr4ys2
mwy5/wBFTpHEVzlo08oO8LWwfC6zbuqlpdyWtaY3ascQ4MMJhqTqTg4xDo2UFDEVcO34iB+a1sC0
UqppVHl/mCJdeFnY+kKbjAgKS79tWa9JWY2u4QXfVSOxdakIfadVnUg7NZ2/zT1nS68kjSU0beif
s2qGoca7X0Ks+9Wpm+GSJ2T/ALMHTT4gWxZsIQBneTb1X6Lxc/8Ap9H8X/KRrG5IgAaoTRph0Fvs
iL3RDLN/RKQwxBLhuVweoxw9NzYLRyM7KCrw+m6SR0/0VxjnOPIckb8rhaQSElsTUrHPC6QIsDO8
aLoeFV2YDDBlRhLNZbdVWNdlc14E7EDZO3OKTg6bcgtdqz0jo+H8cwzahY2uA12rXaraFM1aZqgy
0iZleehzHMPmsBbHK60KPH3YXg9TBtmToSZyhWeWLxfoXH+J5q32XDGQPijc8le4Vw51Ch52IbOI
cPSP5Qh8IUeFVvv6uKpOrHQE7rsvs1OoJY5pHRbt6+I5W7c5QwGRpN/MfclaWDo+W2Hdyr5wxFgP
mFheLuIO4dwuozCEOxVQZWibhY9pIxOKYz7TxCq4O9DDlaVTZUzVYDp7qpg6Jbhwyo4l0XPM80Yz
Nqw0kXssWbr2YeIu1KZG5g6XUdN/rIPZJtZzgczjzlQ1XEOkEgg7LMjW0fFeG4fGNJs2p/M1bPBf
DeHxHC6cuLa7dKgsVFgMBiKzA9jZbuZUeJo+IcLUjAPApbtcF148sp4cOXGXyvs4hxPw/NPFh2Jw
s2eLkDqtTDcUwWOYKlGoGVOhj6LlH1/FFUZH06FQEaFc3i8Jxf8AeZpUhTo4l18rDC7dZl7cMe09
O78WYzEGnQoPd5lMuzZm9FjPqtrNGR0HqsU0PEdDE06mNoeYxnK60aTm4n46NSnU7QuWfHZ6eri5
Mcpq+Kla05xPzReZmJAG0aqKKrJEh7J90DazQdYdp6lzdbj+mnguGitwypVpemuHEtI3SwXFjUBw
+KYPOYYvutbgUfusaSSsjxFw7N/isNaqzUC0rvh5eTLLzcb6XabqNaMzcpHJTsw1LYke+iyeCYmn
i6cOdlrNsQVt06YIhtQQtuFmqelTY0kyYQHyZMOcphSOUkVG6fJQPom/rb3SIEikG2c4bXULqTXE
+tTeS/mDHVJ9HduXoqJMPRYBOeZVxgDIAMRzVTDtyXJHdWKlQNYXHYGd4Waseb8QeK/iHiDi8QHA
ICBmEGRzjRVaFRtfiXEHugzVjurVZuUem3TZMvbrx/5Z3E3fem403TcFP/L8QAYsg4hJqOI36IeE
T9ixBmV6OOf1rjn/AKhYeftlK9+ymaRmNhHVQYa+Mo6DXZS0T6jGvZer8f08n5HsWJefs+VgtGio
N06c1oVwTRmTbRUIOYX3vK715juElCGguETB3KuVWZKIjXtChptzVgCNVDRnMtIsreAYPLkRbkr7
sGzyHOzAkCFVwA+7cNptZTG7WzTP4gf8bTAH4hK1nyKxA0DRssfGX4hT3hwW1iPTUJAvATH7XL0y
sTPq/NVb7C/JWqwgnoo304pgxfRVk1E5vp7K7UBBkCFDhx6xuCVYrSHyDAAQQ1AQ0TbuqjyYj8IV
2oCWkzKpuBtMEHZBYOY0qRIuVce24iwAuqbXTSpNFy0xKtZjAJ5Iqy2fJGvKVc4ZgH47G0qDQc1R
wbqqbiSyk0W7Lo/BtWnR43gqlU+kVNSuedsxtjpxyWzb0Th37LKD8Jmql2ZwmOq4DxF4cfwLxGyj
csJkEr6SwnE8K7CNyPabLxj9qmJpV/EGFLHAxO68H4/LleSS17OXjnS+HifikZuLVwCddt1ivs0n
Q9rrZ8SkO4riCTINtbLEq/CT13C999vJJ4a+Kcf3bQGttysp5LiCL32V/Ek/Y6AETGiotA8xkz8S
Ux9Or4iCPD4j+WVyjh9y0fSF1fFnAcDaBpHKy5d8eU3NzumSxA/WwHsgcCTAmR9VI4WHTWUzgDTM
TP0WUqIDW0BMRrGqNt2md7C2iU2MSOcBVhGW5QdT9FYwdqmtwdVDEA6/1U/D582++8aouLewNs0G
86xqtTDXd6QsrB3Y6I9lrYYRActRuq3H8f8AZKNFjfxGSDyWNjfEeIxjRTe85AIgaLouPcIp4zhN
TGMqDzqGtI/iadwuNw9LDMJNWrHQBefks7eWt3GeA1KrnuzTN7FJrg/M113Eq3UqYUemmQSOaoVC
WHNTMbgrEu1i7R4XiamlMga35K23gJe311qIdrBKyK3EMU6BVrPIiIHJPScagltRxP1XW2yMSTK6
XMd4fxdGmXsHmNF/SZssOoCyWuBBGoOy3MJxLF4JwLahLdTOnZW69LDcdpF9ECjjQPh0Dkme0y47
HK0j94NlZb8RvqFWqU3UazqdRpa9pggjRWaZuNlcmcP0r1GnMbH5Skp3sGY6jsUldp1V6/8AFcol
NiQBUMGQoQjKalEQUVh36phliw905yhNLDy0jZNLQE3pk2sl6drqaNlIsnBYAhsBZPaLgBXRs+Zv
IJi5sGAJTRfREA0jaSmjYZut3DfwQbGyw7aj6rcwpmh+i58np34L5XsUZ4K4RcLL4UJY6AFr4oA8
EcR81j8JuCBM7Ljj/mvRn/uOqwBP7vNovyQRHwkj9VJw++AqaiOShzOuHCdd4XD7r0/UTMALbm6o
YMn/AIq4eCTAqf1V1jiPiBv11Wfhzl8U4E7Zx7LfH7Y5PTa8ZcF/eHGKtRry18AdFi4fwyKZDqpD
l1/GMHjKvEalXDtzMICgrYXHFo+4JPUrrMvGnkuEt3pkeTRwlOGNiAqNTGu+Gi0veeS3DwXGYgA1
qbgOUq5S4R9nZahJ7J2h1rl8JRxP2tlev6Q02BRcRBc6pB3stjGYermhtJ4H5LPxmHrZiRTeZGwW
pU1pz7ajmVDYEzqpiK1QEUmOPUha/BcO1vHMM2rRJY6QcwtK3RxKpTxdWjSwdJoY4tkhW5JMdtT9
mWDq0sFjjVY5pc2wPZSDhuIc533Z1Oqq0fEGOpB7aIpgxcgWC5XE+IeLV8Q9v2pzL+kALy5cd5Lu
Pbx5zimsnc0uFV5ykhp5Ss2u11Cs+nJkWK5zh3FOKs4lhw/EOeHOAJJstLjfE34TilSniqYbU1nm
sZcVjvhy45fbVa12aQ4EczsjYxxPxALFZxqlAGV0G3sjHGaBMEvB6hc+mX6dZZ+2297mQCA7aQmb
Ve6A6GtGyzaXEsO4GKt9yVZ+108oc17dNZWetjWg8RqtpMcT005rFoOqYqtDRDB8bv0CWLdV4hiQ
2kfu9ytTDUW4Si1jG316yuk/rP8ArFn0lbToBrWmiLaEWI6qRtXH4Qk8OxlVo2a85giOVrQLZuRC
TH5aUkEiLjmsS1LjKiq+JvFAYWtdSI0zAXVbhYxlSs/E8TrurVnWudOyvVHucAQIso84h0bXg/mt
dtzWmZxyXawCBVzNchqvIfJNgRYKJohmcuibwgGVzxnJIWdOm1wmKgeXW/NQuq5nuy6BGXsyH8QG
0IAQ5rrdJAU0bdBhMRVw/AHVqZMtM2XKVvFWPzuaHLqaDf8A+mKgi5subp8KlmYjVerik15eDm32
8KeI8RY6mw1KlYtAXKVOOYnEcYbi31nBwMB07Kx4wqGliG4dp+ES6CuaiJIJgbgr14YTW3ky5Mpd
bemU+PYyph2FmIJbG90fCsfxHEY9jGPa7Nzauf8ADU1cIZn0nuuu8K0geM05HPZcspMduuNt0y+J
8TxGB4hUbiaZAmCW6ImcRw2KaZIzdbFafH6bH8SxDXAEgzBXO4zhlJzS6lLXbELy2Y2vfjlnjNx0
/C8U+lhA2jiAQCfQ5XDxRjvTiAaZ06FVeA8LoVeB0PPbL4+KbqDH8IxFNpFCr5jP5X/1W8ZHPLPd
/tEOLwrqVcYzAm4uQN1tcNxjcVSzMF5hzTsuVo4rE4B+Wq1wBt6tFIOIijiRiMN6SfjaNCt2UmMy
mpXauny7AwoHZtCJHRRYPH1MRRa+m6Wn6Kw2tUII0PZZc7NeA1GuYJuCQonVQZmb9VZfVqZJIBvy
Vd1Y70236aKslSc41AZNv70VrFvLMDVJEegqHDVQ9+UsalxuoKXCsU6TAYdFn7X6eX8GOZtdxPxV
HGfdaL3Z3Mjblv2WVwJ3+GfO7pn3WmTFQEXAVz/06cf+Yz+IwHGREqPhdYfYa7OQ23T8Sdme6So8
A0jBVCYuF34/81xz/wBJcAS7GUd9dolJ+PaHvBoiWmE3Cx/i6AJNpU3lMe50AEyfzXo4d68PNz63
5RU+JTTh9KxN0IxtMGRRNlZNFsEZRbSFnvhug315dF28uG4su4gCwt8m+uiEY5rX+mjcGB1RPDPs
3wiY1T4GiKlVhygiynlfCV/GHFhBpa2ULOJljCGU8oI0W5xLBUqNAvFMWHZZuEwlKtTLsojQdEm1
umT57n4gVSNHWWl+9c130p27KnXoCjjAwCG5onurVbDtY9wAECFJsujHH0hJNBOMdSg/cTso6zB5
mVrbQhLWiW5dRNt1ryz4Ttx9ME/c62mE9TiLHC9BQUmNdrrylSGkyBAHvzTyeB/vCmG5TR6oftlI
60JlDUpwNLqOBIsRtKeTwnZjqQ0oW5IzxSmYmhEBQ0Q0EegXtdTMotLScmmyeTwOlxSmKjZpWlWa
XGhScHtpQQ6bKrSoMziwMKSk2kyqC9oy5rqX01jdOjp/tAx1GkGtabDWVznEPEmKxuKFat8QJi66
Sli+FHDBrqDS+OSwMNg8NieKtbkApkz2XHjwm9yO2ed15rncdWfXrVKjrOcqFY6d7raxuBq1uI16
OAo1q2R2UCkwu/JT4fwV4hxIBHDX0mnetUaz81061xueM+2VipFCkCNtOarMs9gG0aLs6ngjiLqb
POxfDaBaN6+Y/QI8J4GPmNc/ilBxbtSpOP1JWc8scfdY+fCfbP41bhFNtjYbrnKjfumW23XqFbwm
MXRZRfXeGAahoCMfs+wTwA+viDHIgLy5/ncM+3P+Xxx5NUBMQPl+SZ8uZFtfZexU/wBnHCZHmfaX
DT+JCuUf2dcADRnwr3xu6q7+q43/APkuKM38zB4e0RzmLbJGZ7Xuve6fgDw43/8AF0z3c7+qkHgX
w23/APD4b3BP6rP/APacf6rH8ufp8+uExpPdWMAAal+e698Hgvw4P/w+D/8AgmPhDw8244RgwejF
P/7TD9VJ+ZJ9PIcGJbbWOS1sMDNpvzlej/8ADXBKc5OGYZvZqjdwPhbfhwdJtotK1j//ACeH6rf8
7H9OKr1KLOE4p1dhdLcrY26lcBWFJ8wNLSvbK/CeHuoOpfZ2hjhcAlYWJ8LcIvlw5byhxWL+bjll
vy3/ADsLNaeZ8Ow2GfRxbq78tVtOaY5lU3EeU4HUr0Sr4U4aJLW1G/8AuWdX8KYIO9FSq2DzXTH8
nC1rH8zDWnA1tQmY9wILTDuYXX1/CtHau/5Kk/w2Wj01p7hemfkYVmc2Nu9smhVz8swsQN1IWPoP
GIw5cGgzI2Vh/BsRSIcx7THdaXDqNNrhTxfpp1LOBHwnmueecnnF7eHlw5Z1tUuKUW8X4ecfQbGL
ogCu0fiH8ywqURP6reGfgnFyARUpD0ujR7CqfFsG3CY1womcPUHmUnc2nb2XbDLtGcsdVUjMJIaT
1STgtAA9J6kJLaK1WmC6bySo/LGxTip0S8y0J5c/Bw1NG6XmdNUs9rBPKeD5eZSy31TZ9bJBwTye
BFtpBCbL1TB/+iWb5K+TwfLCcN6oc3Mpw9DweLaj+q2cG6KIEi+6xMwha+CM0eaxn6duH/TWcc3B
qtjHdY3CjlJNtbrYotP7orWKx+F3c79Vxx9V6c/9R1XDyPsNSLdyhAIMgSe35KPhxjDVWyZ7aJBw
B0B6rjrzXo+onBOWDFrLnOJVHs4jnpvyvbGUjZdC+Q0deqpu4dTqVS6pqTutYWY3yxnO01FBnHOK
M+HG1Y20UlLxHxhpgYyofYLTocPoCRk0sp2YKi0Q1rf72WryY/pznFf2z6fifjTWyK2YbS1Ss8Tc
bdPqBPVvVXiynT/ADeAYQuLGicrYgWCz8k/TU4v+oB4h4yZmmw23am/4k4vOV2HpH2Vxjm2J0PRS
06bXGXCAd4U+T/jU4v8Aqth+P4p2LwxxeEptZ5rfUB1V3xLihhsfV8mPvHSI6qlxqm37FYAeoEEK
HxDhatHE4M1CX52ByuF7UyxnHO1amHZTo4MVKpcZuQNVR4hw/B+QK+DeTULpIJRU8awuFN0EaG6t
Yulh6GF84ABzhZq6a081vbzWS0+VVou/leCF0fjPhzMXWw1ci5pi4XJYjFMqU8zHAwbid13XEXfa
OB8Pr6nKNVnk3JuN8GrdOPpcJqtfDKxaNLrT/dVVrLlrrAmFdpNBYBAkjRb/AAzB08ThMxJBmLLh
M8sq9Vxxxm3F/ZmUyBWowqeOqMD208NnneCu04zgGRSpZHuLzcjkosJ4fw7JOR4m5suuOP3WJyzH
05Gm3FYdjXUamYRMEXU1Pjlan/1FKe4XWv4FSLbNeFRxnCadIXAPcWCdJfZOexUw3E6GIAGfKeoh
XW4gQCxwc3Tut7gfDsBUwbfNw1Jz4jRUn/YKPE8ThhQgZJB5FcrxefDpPyJ9qVJ7XN9Jk9lG9hDz
eBvZbfBzh6FEU30WOI0Llpk4R0B2GZHQKfFV+fFybQATmNu0pi+n5sCwPPSV1jsBhKtMxQcIBuNl
yeJotbUcGHf6LFx17axzmXoMhtU5fhiVPTc3SRKhw7A3MahERZM0DORAiedlG3V4YA+G3Axc6IG0
g2k3S4Q0qzafAmtLspJUdXF0g0DMNNV2w9PLnjblXlXjZ0+Iq8aAALCdp/VdJ4pwYq8XrVzUa1rt
CsqlRwtM+t5deTZe7HKdXlv4+dt34dP4Rw8YAuO5nRdf4WZHF2TuCuM4ZxFlGi2jSAEc1v8Ah7Fv
dxMOdWbSEa6rz52+XfDikntY46T+9q/KVmVcxEXn6KxxWq12OrHzi71ahUKj2g3O+xXl87eyTGT2
7fhFWlT4bQbUe0GLiUGJxdATDp+qx8MMaaFMUMHTyR8Tjcp3UOKnVlJlrWXSYvPcsVmpicPUnPSL
x1bKx+KYbAuaXsa+i7oYV1uA4hUEPqtaN4Ct4XglJrs+Ic6q6fxFbnj7Z7T6jmsHxbEcNqMyNdUp
vIaTC7rDvqVKTXyYI0hVa+BwtdrGOa0BpkBa+FollNoaJgW7LOWU+i25XdQZ6m4+iie+AC5rY7K+
WLM47VGFwTahj4xdSXaWJWQw2AmNYWb4oqZeBYvUekhWPt9FxEVBfqqHi17W+H8QQQZEarUnln6c
JwRgZhhyV9xa4iFV4T/0wEwdFO4Fp/orl7dcfGLOxzh5j506KTBADh5MjRQY0EvqCCVPhf8A6ZcH
TVd8P8158v8AQeHgjG07DQq5TOXMQZk8lU4YR9tZAvB/JXqLCczpjZeng9PNz+yeRlMxosir6ajr
2GllsVwBTcdYEWWVUa103g812rhBOrh1DyxeI0Cv8JrUw5jX6ggzyWUGjKRJAJ5KxhgQQSCDqFlW
/wAex9KpRyU3TG6o8PJFAEETN1m1QXEmZ7rR4d/BIhJNLbtnYtxdxBmnxDutDFQa9TpCz8W2OIM5
ZhdalVoNR8nlAUi1TqtioSRcBAGyLxPJW3gdJ0PRAGeqBHJVnSGk3KIIPyUoABgSjA9ExpuhiJP0
RdI6sFphRBokQPnspnt9CBrbiZFj7Ih2AX6q0xs0RFr6qFgsIPRXGQ3DOIEEH2CCJp9Q/ooajvz7
KQm97DqrmFwdJlBuL4jmbQP8Og0w+t25N6pv9pbo3CeHYriTi3C0/Qz46jzDGDqVuYfDcL4a6abD
xLFAXe/00h2Gp91n1eJVsUxlFuWjhm/BRpDKxvtuepVrDUwdNI5Lw835nXxg8/JyWtIcTx1RuSlV
bhqWzMOwMCAYY1nTVe+o4xdziZR4ekLSOnZaNCmCdl83k/J5Mvdea1BhcA0CzBHZauEwgaRZPSZB
t7q7S1G68eWdrmmpUI2VtlEKGm6yna4LjUkG1gGiK2/JR5raoXOA1KglLm80JqCFA53+6ie4c1dC
R9Xsq1SvrdR1KnIlValTW61MTSWpXtbVVatfXkon1R8lVq1bHZdJisxHVxGslUq9f0nRR1amqpVq
ljeF1xwamJ69cE6lUqtWxn6FBVeJsqdWoIM7rvjg3MBvqyTdValSWkygqVLnsq9V/Pnou2OLpMSq
P1sPmqjzJMInvki2migJ5Cy6yNSBq02PacwkC3UKtj2urYClh2a0SchOwOoVgu+SicfloumNsbxz
ynqsF3nMJa5pB7JLeFxcXSXX5G/krmRqlNjKX9UguzoSQ6JBKUD80+/VMEgikNN04GyY9U8oG2Tx
ePyS5p/kqhtQtfh5HlDqsjZavDyfKkaDosZ+nbh/02MP/wDTa4ELF4actV0wtnBAPwFeeR2WLw0f
fvgjVccfVerP3i6Xhv8ACrTujBHqjlog4b/CqQdUJYZObXrsuP27/ScXA5/mjEZTBvGyrtILS0fN
WaVN5u1pLVCU7DnmJkKQgiPVoLKSnQqw4hjjedFKMBXe7MKToCy0rvPpI15zqozlgjWfotA8LxBe
T5bh7pHh2JaIyRHMobiiQDAG17qVtQU2kudA1RYzCVaFN1V5aGtvqqPCcK7iQc91VvlAwATqr18b
XHKbU+L1KuJwzntBbSZpG63fEQFfh/C8QJ/hi8dFBxjDGhhalAi+U+6u4HC1+KeF8AMO3NUp2udF
vCuXNe1cVVrPGLDGkgl0kdFp1MS7EakANERtayt1fBfE6mINTOxkqxhfA2LY0iri4nWAu/bF45jl
+nJVsOXh9SmXB/TQr0TgVT7T4Kw83dTsVFhPBNJoiriKjgfZbtLhFPhfBq1CiXFvxCTK5cmUymo6
8OFxy3XOUXEEhsxz5Ls/BX3vDqoIEh5BsuJa8tqyCJldr4GqxgcT/wDxFww9vXy+mhiMO8Ysu9Ja
BZNiGuYwOFUMCmxNao8uDWtB2JKqmjUqloqvZC7beZNhhkZmfVBB3KmFPDYgRDXGEsPh6LWFmYOE
Xup8NSoMk0wBsYU2qo6myiCGiGxMBc0zDNq8drPfUEZYXS46C1wBFhMFcXxRuPpPL8NQaQdxqtYo
1eJ0WUsOfszi6rqBzU+C4saNCm3EYJ7qtgVjcGfjMODVxID3kyByV/EcbztIbSOeOSda1M5JpsV+
MY04Zxo4BzGRqVxT8RWc9xORpJk/NdTgsfianD6jKwPwkSVwdfh731Xk4h4EzZcs8Z9u/FyWeo0T
Vt6q7G22VatjaFK7sWI5BVf3MxzXZnvMa3QU+C0WlznCd7rMxx/bp8mf1GyzHVamDpNbhnupk2ed
1IX4tzCRTY0FarmCnwGhAytACzMTjadFhmo2dl2x1rw8meWW/Ncl4sNR9amx2UuaJMLBouDSADp8
101fF4d1aoa8Pc/poFg4jBPzF9Bs0Tp0Xpw9aeXP9pGYwhmW63fBVNmP4z5dR78uWRdcpUw9WmDn
BG66b9mp/wCfuN48v5qZz+tsXDL+2mhxHBVGcRxDaVU5AbXVWlgaxrNDq5IkbrXxj2HiFfMYlyDD
sb9qp5TMuFpXjuVj6GOM07/C0/LwlJokkNGieHBskHspmT5TImQ211JREsv8ljbCvSp5xcFM0AVQ
0tseiuCA2By0VV9BzyfVDU2Jm0aRMgDojDspy2uq9PCDeqSp3UQMrmmY5rKmqOMm2y5XxvUJwNOn
HxOnTVdY4XN7LjPHPxUGgjVdOKf2Yz/y5ik5zw2M0i3uoeO4mu/CU6LnvyONwr/AzT+2O8yIcd1e
8WUKflURSF4JtqvTldOOEtc/ggfJYIN+ime5pIkgbaIMOZpDbomqPzFvcW3XH7emelDFTnqE2EbK
xhv/AKYeyqYkxWeJuVco+nhe9xzXox/zXny/0j4cB9taJOh/Ja9O7CQRqsnh5P25kTEGFqYczRk7
Fejg9PPz+yxDR5eoElUvswM36q7iBDJnTroqQJeDBIXauEMcO3NA56widQyjKCCTa6lZReXQZjvu
q5Lg+STY7n81NroT6Am5VrCgNaAflsVRe9wdck91fwwJAuUGbXE8Sp6A5+y2HtBzEC2miy8v/NWD
/MtgtOZ4dMysT7bQ02W3I6I24dw2M9VocMw7sViWUaY9b3AAL0zC/svx1TCNql4BIBiFzz5Zh7dc
OK5R5E6iRIhV3CHRuLLuPE3hXF8IDjVZLR+IBcdWZFQztZaw5Jn5jOfHcPapUHp67wgaIc3WCFPX
MmBZRk5HMmxi66OQgNZiVNT/AIJB2KgbUaOU6LQ4ThDjXeU12VvxOfrkaNSptNFhKFOnTdi8UM1F
phlMmPNfy/8AEbqpicRWxWJdUrnM82MCwHIdFe40/wC+8tjTTp0xlpsmMrf6nUrPpgyb6rwc/N28
T048njxVzBNMzcLbwwAGizcK2IhamHEbr5+d28+S/Qbe35K7R11CpUDIi3VW6B62leeuNjQpeynY
6FTaYAEqVjuq5aZ00KT9LqVlSTqs4PtqpmP3nVZ0ul/OCoi/W6g83UyonVeSmjSw6qI1VarWtsoa
tYQb7qnUqzMkLUxXSepXEOkqvUqDdV3Pjuq73zrGq6TFZikqVfTIN1TqV9bhDWqTOwA1VKrU1IK6
44tzEVave6qVKusmOqiq1Nh/uq1WpbVdscW5iKtWkSJ9gqNatAJE+yVapzPuqjnlxgHXZd8cXSYn
fVMkKF1Qwecq3Twj3CXSOigx1LygJJErt8dk2ulYukWlRl0ybIc8SdUBd+akhoTiBMmEBN0BNtf9
EMytGkodbUpKMOPVJF0wEkkgvW7EPqkUkrbKhwlzSS+SikE6YbpKofndKLJh/cogoGIhamA/g9rL
LWjw4zT6LOfp14v9Nnhp/wAJXbE6wFkcN/6h9pkrX4ZBp145dljYI/4uppquOP29Wf8A4uj4e4ht
UW01PJODmJmYTcKu+qDuE9P0kg/Rcr7d56S0wMpBIgDdaNPHfZuCitTaHObIKx3lzqDxO1ij4a01
PD+Mpu+JhK1hN+3LkysngmeLsTlIZTYLaqB3jHiIOUZAQVy1OoWPJHJIOk/1XonHj+nk+XL9ujb4
k4rWq521NdRCo4zjvE85Y7EuBPJD9qGGwgAaDVI+SoU6T67y5wJlJjP0XK/tOcfjMTLK1d7mu2JW
hw+u+jXota5wAcLT1VFjfKbdjgeyGnWd59OdnDVLJpZlY9L8TUZoUnfzU0vAWNoYfhFRleq1pY9w
uYS46RV4fhHajKuDfhKzqzwxpgmxGi8uM3uV7LbqWPVq/iHhlI3xTNL3VGt4x4XSmKhcei87HCKh
uSATdSUuDkAZnX6LWsf2msv07Kr46wTSMlJ7vZCzxieIh9BmHLQ5upXNUeF0mm8k9d1co0WUQBTa
As5XH6bxxvurrCTII9oXXeBX/c4toI+KZXEh7i4ZoiedlZ4b4nbwGrXa+i6r5kERoFzxx8t8l8PT
K9EVnBziR2QMwlNpkuJ6Erz937RpPowZHv8A6qN37Q60Q3CmbakWXXrXn3HpZw9EgWI7KWjSbTAD
BrqvLD+0DGwMmGGk3Khf464xUtTaxluUp1qvROLtBJDgSNbG6wzXptblayqBzVng2Mr43h9GrijN
Vwl0K2X06QmoIWozWY9j2sDhSeRCLCMFZ3wRzla7cTTfRJymBaI1VBjDWqzTY5o5q7Z00alDysBU
JDbNK4Os4HcWuu0xtJ9PBVjncRl3K4Vr82ZpmNbrjyR6eGpmhwAcSYPJJpIdBkJUXHLldEAdkzHF
r/VMLk7urxFLzeBU6dOAco9lxOP8OY2tVLqb808yuup46g3BUg6sGuaNCUzOI4eDFdneV348rJ4e
XkxlvlzvDOAPZw+vRxFBrqr9H8lT/wCHOI4dpyODmciuyGMoGQK7PmpGYikBPnsPutd6x8cef4rg
+Pe0h9Nv5K/4L4XWwXEnvqsEZYFl1j30nEjzGkbwlRfSZULnPbMaynyWzSTjku3M4q+LrT/PzSw1
VtHE035QcpB7qKq8VMTWc3QvJlDnEEG9tlxr1z06jG+MqFCifuqgIESBosjDeOKdOocxdldzCwOL
kDDAgeobrnRMRzN1148JY4clsvh6thfGWEqRmrMH9VrYLjuDrj/qKbeztV4owenZEy2g0vZW8UZm
de8NxuHMZKrSBfVGcU1zYDmkHaV4YzFVGWbUe2NIcVYZxPFNiMTVG+v0WPhXu9odiB/MI2XHeNMT
TOLpAvAytXFt45j2/wD3TiBfmqmOxlbFP8yu/wAx4b/dlvDj63bOWW5pv4Gsw4pmV7SZjVa/HXGp
XpsaZApxYrhsKcuIad5Om66KlW+6BcSTHOVrkq8U+1ZpNKs5hsDomcfU2NNClWlzpi/PRRZ8zm5t
Qd1zddoMV/Ffa6u0mzwxovpOiz8TBqP/AD2/0WlSgcMbP8s8l3x/zXnv+kPDGB3EGDbKYMdFrUI8
ojkbLK4Y6OINOnpP5LVw7QWPdvOq9HB6cOf2DGH7pwiIuoOHtLnENBJMRZS4w/dwBcc1p+DRSdxB
nngZJuunJdTbnxzd0J1Oqyg57qLhbWFz9QkkyJHVe4+JWYEeG6jqeXNkXi+Np5HAiJO8Lz8Offbv
zYdGdi9Qf0WjgCXMBvr81QxtnafNXuHEFpMfNeiPMqM/+qs0+KxWzXtWeNzErFZ/9Ubf8XJajycz
iTeVI02fDGKbheM4Wq7RrwTZfTvDvEOFqcOYWubdq+SmvLH5haOWy6jC+JsRQwwYHuECNV4/yeHL
O7xevgzx1rJ6T+07iNGvw+qG5SYXiBANYrT4lxqvjswe8uAG6y2OgkmY1gLf43FeOarP5HJM/StV
Bk7XUvDcMzEcRp06hAZF1BXMNM81Dh6r2YgPYS1wsIvPZejL082Pt0PF+F4TDMLmuEjYbrZ8LYbD
8PwOIxWNh1LDgPqj+ep+GmO2pXNMdVptq4vF5poRlY4WLzp/VQ4jidSvh6OFDz5FOXkExnedXFeD
nzy6dJfb0dscb2sLiGKqYrF1a1SM1Rxce5QURBAO1pUTbkndWqDSP0K83qPnZ25XdX6AIaNiFfoO
1vsqTBbqrNI/3uuGTjcWjSNiPZWqRss+kfSRyVpj4HuuNjHVfa/qjD+VlSpunUwFLmssaTqtCpAC
kZU6wqGYxAv7qWm476KWLMVw1CRayhfUtySDp/0ULnb81JF6Gc68kqCoYBgonO1lV3kEGSSVuRqY
I6hnnHRV6zjBE7wnqOy6adFBUfJJ0K6SNzBFVfAnTqqlR+pIm8Kao8gKpVcbzddcY1MEFV0QOtlV
qv2Uz9wL23VOqbmF2xjpMENV/VSYGnLgTqVBlL3gfVX8M0C+gXp4cfO16rgADOiweLVJr5W6j6LY
xFUU6LidAFzOIqF9QuPNd+W+NJ1C50afNRF0boufPqoXG/TmuETROdOp21QB1uZQudJ2lBm05BU0
mbUgfEkomuMau9kldGmUnTJxC9TocJdhom31S2lQOkmCUoHG6XskDqkNDCBRrNgiQqWg0OLgRsgj
O6v8PP3brBZ5sYV3h+jlMvTpxf6bXCz93VFjZZOGMYt+4lanDXXqdQsugP8AGvHU+644/b1Z/Tou
GOiu7QemNE7XwXZp/qg4aM2JGkZYUrW/xCSIBgLjfbvPR2GHNA0t1laHDaYy46mNHtnTos6q8ANI
ItyCv8IqA4yq0GzqesK4+2c/TgKgiq8awSEzDH9FJjBlxVdtrPP5qECT/ReyenzkzAatZo20A1Xe
8F4X5OHHmUZtqAuO4ZhgarXPdBBGi9Op1H4elRbSgtIuCufJXbjx+6o1MDg6gIfTaCbGQsPjHBsL
Sp+bRhrheJXRYnEOdU9VMRyXOeJnPNBppMIMrOO2spNN/F1M/CMMSZyxfks2mxoBzAE/mreGf5vh
+m52wCzjVDXWd1Erz5zy9XFd4rLGOq12sFp0kq+3hDhdzzJ1hUsAP8XhjmB9ekrvmYEFo3mNF5+T
Pq6VyTOGFurj3hHT4Z5jni5y3d2XWHh7Rc6dVkUsIX8Uq1KbnCmPTE2K5zk2m6yTwxgOrt7rC47w
prq7cpIgL0E4QkWA7FYXiTAvoAVolrrSt8fJds637cdT4RSAAeTe3ZWqWAw9JwzN13KsB33d9Lap
NfnpaCOZXo7WtTGQjRw4ALWCRYW0SYxofZgjaE4eYkN157JEkgw1o6lRfDseCVqTeH0xnaI2JhX/
ADqDviex3chedPwurvNqCLmHJMwua/n1p0nMV0mUcrx2vSqdajFnM+aNlSmDYtt1C81FJzQctetz
+JR1BXj7nGVm9S5O0T469K4pUaeG1yCPh2XAtDHMggyN1jnE8Up1gypiaj6RN+y1GDJd9trLOcb4
vCWkCYh197ovLcPU43ULjLoY6ALf7KRxZpmPyXN22jx1GnWolh+YVOlw2le7ie+hWgxrHH8UE/JB
Ia8ie3JWWzxEslu6h+w0G6A/NH9lpiDBI5yje8yIidwnbJa4kgEi3RN1NQmUmNpyASNrqvVwrXyX
vcJ3Dj7qQ5spaDaOeiYt1JJA1ubqy1NQqLW0g1o+H5o2ho1IPIAboT/Di0hOynLefWboqLGsNell
Y2GjUlYL8FUY8nUarpX2putoYtqoS0uOoJ7LWGVxZyxmTnDRePw35R9FLTw1UiQw/JbT6ABA12Jh
beBwgdg2mNei1ly6cbhpxZw1SQS1w68lJV4dXp0qdVzYp1NCu0dw4HVsALOx+AdTh2Yln8uoCk5d
1hyYwlSBA0v2TVMPUptJJ30C6cYB0SdDyCpcVwjmYRz4EA7LpM9ssSkcruxmy3sM0Op5iTpZYGg2
+a1cNVIpwTaNvqmcduO6WSJ0mSYUT8PfM1x91I53okHRR54s6J2XON1TxIAe42j81fqHLwxgmfTo
qWJ+J0aRudVarHLgaW/o01XfH/NcMv8AUR4E/wCOZe0Fa2FBFN0DdY/Dj/iWGW/CTK3ML6qBI2Oi
9HB6efm9oMVene3dPwio+nV9JII5fmnxX8IiR0QcOABzEj6rrlHPG6rsOIYqo7gbg57jNlxeJqz5
bSV0OMf/AMtLXObHdcvWMvOkahc8MdN55bRYsh79NQBormB1Ko4gjNqNFoYMFtMGQZstxzUQ7/mb
b3k2WrXs5+xmFkMvxQaala1QFznn8gpi1QtMvEjLeyu06cMMk9t1ntIBBuBoVeNQNgSJIVRA1hBq
6yBZA10jeIkKzSaC94GhGs3UDQJgyLaIqvWu0zeeihxbX4Olhq1EzUeZDeoNlYfuNVNhWNq4ii54
llNsn2XHmtmLfHPIuOYh/lUMPWfNY/eVj/mO3sFnUhJtJsgxLn4nGVazifW6edpVjDUrL53qM8lu
WSajTGaYuFeoDQygo0txPIq7Ro6brjlk5XAdNpiwVim0DrI1RMpEaXUzad7grjafGVIRf4bqdgid
ShYzlryKnYy2y52s/ETZNo12UjQnayf70UrKZO4+SxafEjY2d/mp2NOUhM2nr+qlyGFm5NTiCLDY
3QQSDJt1OqmDNZ/NC6kbgGI1UlanCp1twPnCgeyZke4WgaUzOiE0Jmx/NbmTpOFmOp20Mqu+nc2+
i1nYY7fJV6uGMFamTc4WPVpkAjkqdRhE79IWy/Du1hVauHM6j5Lrjm1OFj1WC9tlQqtuZW1Vw5AM
/wCqo16JAJjfmu+OR8alh6cydedldYwAiD2Q0Kes/kpKg8um42svVx5yRzuDM4pVn0NMDUhYz2mS
tTENJcSdSqj6cSpc93adFQiBeYKru13lW3ssRN5ULGS5x2AlalZ6KzhqY/1URtzVktimTzMCVA5v
ZWVjqYGLFoSSA6D5pKnVm80vzUgouT+SZvaV6dxdIwlCkFF2oS8l2ybNVEnCk8ogExbdDFkNG5pB
KE29wiHBU+E+J29lWtCsYQw908kWe0O8K5w7e491WFFx0srODa6m6eamXpvjlmTY4aPvXiDostls
Y8XAk9Vo8PMYgjWyzv8A798wBJXLH7erP1HQ8KcftQkbKQv++eL6qrwx2XGNF5IU72gvJn0gz2XG
zy7T0NwAab7zCtcK9GOpkggFpElUyC5pynffZT4OpGKoHMZn5JPaZenKcVplvFMU3k8qKk2Cdfda
PiOn5fGcRFpvZZ02n0r1z08Nmq6nw7SwlKj5tZjnVQbdFsfvOpia8Yen6AMq4ejjKlOiWtMZlvcG
xtRlIiqddhqsXH7bmX06UVzl9YHRU8diqXlEPYIChdiM5jQbLF4ziHsEOnWCszFbk6jAubV4M8NB
y62WY3y3AwIO0hS+Fq4rcKqsMSJCqiAXgghpXLkmq9HDfC1h35MZhiAR96F6U5plrnVS0EaLy2s7
JicMdD5jfzXp7aj/AC6WSmX+kGV4+eenZNVFMAF9Vx7KCk9lMFtKm43vIVmq6q6k006LQTqhbTxJ
Nw0CF5hZoslgJAnlGiq+KqIfwGtYGFawzK4d94QQdUPH25uB4kHXKUx/1CPJjMz2Q5n5IvBOqLPB
AER13TgyBB9l9GB2Tk9Ui/1T0s0uG3fVC0hjQQRE6qQuy8r80IJ/ww2De/ZMXyyGyHAfJRlrmvlp
Mm0aqXyg6To43EaqKakXNkEQngyfTBj5KNjnNtbkCpJc6ZsEA1HAaabxsUbSX0y0gCOZUbGgOM6d
QnGYlwkxF7JoFSEkh/pPUossyMyjY0nnIi5VhtFsQXCf0RYAhzGgje8JBupPyQkZn5c0uCTgC6HO
sb6oHZd5MA+6RMvcSQLIHNDLZtUeXMwdUDN0tcnqjYZJbETzQCm6LHW6IsLWS8jpH6IHLW/zSEmw
DDXBRthzrbJVQWD0D5K6TZwPvSJJ6o2CSQJEe6iZLrSQdYhG0FrTEHshKH4nPBBO5vddNwZnncND
Zg84XL0wQ1znQCV0nhx/+CPMGFy5PTN9LbqdKk7KXEnSFFWbTqNLWsJnmp6vml5LA0DnuhDHSMz7
awucc2MxzqFTynNlhMByl4tQbU4VVIi3IK/VwrHi47FVce3Lw6sw/wAtpW5fM0kmnCYjDlgDh8KK
hmZrczFlfbD6LZ3EzGqi8kNeNmndert+2uv6SUzmpcjMIw0OdPTRC2nliIgmUnjI8Eb2sVlpUxNy
bE2uFYxN8HQBtLPmq+J1IM36KxiSBhaNhGTZd8P81xy/1AcMpk4oWM5TbmuiwGCrupOHllc9w/En
D4g1WAOcG2CsP4zxOpBY4UhrEQvRw5SY+Xn5pu+GnjcBXbSJfTIA5LLzmmLHTlqpqPFOJNH3n3jN
SI+aZ1WjjWE02mnVGrdCV27TL046sDXxL3Umtk66Toqj3EO5lG6WkCDIN+yNxa6oSG2WRXdJdLtI
1Wlw95LCCLHqqrmgCB2nmVZwxAp9IiIQig0f80Bvqea1i6KtTmR81k0f/qbZ/mWnJ85wOtxdTFuo
bkSJkDkrJFxcj6qtmgAT16onVSXDa3KJVZaGEblcDHQ30QOGSo4C3VR4Z5yOM2HXVS1TLnHnyRVf
KIcdL8lca1tPh1Z5N3+hv6qu0Sx1uoMLT8OcWx3BsZTx2A8vzaUhoq0hUYQReQVx5sbljqOnHqXy
xKVEPgCTAEWK08Lg3ZTOu8gr1vw9+2RtKGcd8PYZ971MHDT/APF39V3vCP2k+COJPDH4ijg6h/Bj
KPl/U2PzXzM+Lkn07THB87UMHA1HK5VzDYaLS35hfV+Eo8D4hTFTCtwGIYdHMDXD6KU+HuE1DJ4f
hT/+7C89wypZhPb5cp4T0xY9ipm4UxEBfTT/AAnwV/xcNwp//dhVqngvgLv/AMZh/ZsLneHImWD5
xGEv8Mom4Yja08l9B1fAvAXf/j2Ds4j9VRrfs+4E4kjDVG/+NZw/Vc7xZxqTCvDW0TyCkFH+9V7B
W/Z1wUzl+1sP+WuVUf8As94eCAzE4sQLS4O/RYuFanHHlraKNtGNrL0v/wDZ7h5OTH4gd2NKYfs7
A+HilS381Fqz0qzjjzcUjGidtCQbQF6If2dYj8HFGH/yof0KZv7Pce0+nGYVw0u1wlPjrUxxjgW4
WY3UrcFOy7yl4C4oDepg3f8AucP0Wlh/APETdxwsdHn+i64cGWXpblhj7rzE8PkGG25KF/DSTcL1
z/gPGAaUT2eon+BcaBakw9nhdv4uc+icvH+3j9XhpAvZUK/D4Oi9ixHgfiABjC5uzgsPG+DuJtJ/
5fXPOGgrGXFnh7jeOWF9V5PiMF8Vj8ln18DawXpeL8K8SaTPDsVPSkSsfF+HcfTBJwGJH/7p39FJ
lY11xrg2YTK7p0VfE0M1houvr8IxLPjw1Zvem4fos2tgspJcMp6iF1nJ4ZvFHJVcNewVSphrRH+i
6upg2kGCzlqqOIwRE6G3PVbnIxeFy1WhY2lRNw8YSu+J0aFs4jDkA2MIH0D9ga2PiqarrM3K8Tna
lIhrWgHmoXUffstiphjOkEDRV3UTaAukzcrxszyif90lpsouIkCfdJa7s/EwczTySzNg3VaBeEsu
vLdevTl5Wc46JCo3Wyq5eaWXmmjysktLTfVVp1SgpFvVanhLKYnVCSijshIVZ0ZHTcWmyDrqiH1R
E7HPi0FT4YuNS4A9lAx4yjdTUHA1OazfTrhfLUwY/wAV0hZj4GMdfc7rUwJJxF+91l1x/jn7+pc8
fdejP1G3w4/4qmbRCsvltV/p31VXAyKlH8+qvVZzkRvMe65X274+kYe1rhIg807KmWrTcCCQ8CVC
fjl0xsmqwGAgWDgdOqRPpa43wWtjcea1MgNc0KBnhWu4CarSusw1Wk+hTLqjWy0b3Cm+1YRgM4im
NvZdO1cOkrlKHhJ0jNU0utvBeHWMMmobDVW38XwNMf8AUNJJULvEfD2AxUBUuWVJjjBO4EwO9NQ+
yixHhyjWjzXkmZuVG7xTggTLieoQnxVg8phjpCbyXWK9w/hNPBUXtoTEGywnjLXeDoCtjDeI6Nek
7LScNo5LJxD/ADKr6jbFxkLnld+3bjx0rVn5sVh22/iN/Nev4Vv+Hp2/CF4rxCtkr03Mu5hBFltH
x9xEU2saxgDQAFx5eLLOTTXaS+Xq4I0KIGNl4zV8acXqG1RoJ5BRu8VcVe0g4kjlC5fxM0+SPbWu
BI/qouLOY/hddmdt2m0rw9/HuJuJnF1B7q/hMbiK9EmriKr7aZjon8W4+bVxylG4Q5wnQoRkj+ij
HqLpaSNCVNTIEekW0XpaLMS3KAf1SZctBJB+SkYczAbdOZQFw1LQWhBI2GnNOlgn+OS4kDnKCGkH
I0ybp6TyGeruopOAb6mkSeaNocZJdH97KM/wpj/dEC40xmBzc0QT2mQbxffVMAQ3MTHUp2vY1xDT
N90NUuNgOSKZpcRLSABuNlYY+BABnRQNJhrRE6RCZ1zLbOFiEEnqe4kfFzTgFgJdzSouD5P4gmc4
FuWJOxQO5rC4Ean6pEOLXFpPID3TMjy7wTt2Tl/oBLYMadEEe3qeZ0jmjdBtJ+aEZWkEg5tJR5hl
kDsYQC1gMkOdGsA6pnvbl+MmN0bIDTtI/sKNga90Hn3QBnAN5jojzNA1sNRKTstOQ0AH6oGw5lmw
QqgmuJmDPut7w64DDVADusIty0QIn2j2Q08diMLh3mgWje+6zlj2mkrtjUEGfoonBrnZovsuAPiD
iBmHNA0sPoo/33jiPVWtopPx659nojtCZMFQY0B+FqjMJiLrhBxPHuFqrztYKKri+IOcWmrVj81Z
wX9m1wSKIE7x9UcyPV/uoMKKnlRUBkWMqw4F0QL6rbc9E4wBBEpoJMneyIANbJdrolmE2ABjkgoY
l0EkRcKes4VMPSyn8MaqtXBa51rqPBScPUubGCu2N1i5X/S1g/419MumikbLqhAIj6hQYUzVmSBH
xDfqr9BoDZie4XXD048nsRe6gPR6r+qSs/Evh3n0vS9pvB2WmAHCNJGkKjUw7mh+mU7Qtuaw7LXo
NqsFzrCdjAJJvBkqtwWpRFB9PEkhgcYK1BV4YP8AuXGhkrrPLnpX8puWdtLFSMZ6HerRTOxPDQLV
DP6KOpicDkIpuJt6VfBpl0v+vYNs2y1nN+/PPmseg9gxjXmcgcfZbjcVw4ukPMkaLOLVguF06bsY
wVQI16LX4xhKPkyxoEDWFl0cVw1lTNmIgq5W4rgKrMrnGDYjmsZY7y3tvHKSasZmHbDHAbqTK3yz
+SsfaOGRcmRvuEQrcN5kbrp4/bGqgo/Fexywuu4VRw7uFtloJOq5oVuHN3cIFwtDB8UwVKlkY4kL
jy49p4rrxXrfMH4ho02Cn5bQDvCyGtgR8TeUWWni8fgsVGYkxf2VcPwB1JkrOOMk1tu3d3IbA1au
EqeZhKtXDVP5qLzTP0K7jgf7RPEnDcrWcVfXYLZcS0P+tiuNBwWxcN0bDgxEOPS6454Y10xte0cM
/bHjGgDiPDqNURd1CrB+R/quq4d+1LguKH3zcThjvnpkj5iV87sfQgw83vqr2GxVOix+R5JcI1Xm
y45Ptvpjfp9KYTxlwLG/9PxTCuOkGoAVpMxtCu3NRrU3jm1wK+UmnMSHAGY1AKsYeo+m77p1Rh19
Dy38ivPduk4cX1I9wKhMEr52oca4lQqEUuI41oGwrOP5rTwPinjgqADieJI5OId+i5WVv4tfb3ho
CNoHJeKs8ZcdpvgY7MBs6m0rQw/jjjIaJrUHz/NSifqp6T4q9fYApmgLyvDeO+J2z08K7/2uH6rS
w/jjGEerC4c9nEJMoxeHJ6OyFapVMtl5/Q8Z1T8eDZ7VP9FfoeLmn4sI8dngrthzTHy4Z/j5V3LX
tO6eQuTpeKsPHqoVh8irLfE+CPxCs3uxeuflT7ee/j5z6dESE0ArCHiXh0XqubPNpRt8ScLP/wB5
THeyl5scvtPhzn02C0ckBpNOwWc3j/DXC2Nof/MKZnFsE74cVQPZ4WO2FOmc+k78NTIuwH2VWrw7
CvnPh6Tu7AVOMdQdpVpns4J/tVM/iHzUswrU7xjYrw3wmuD53DMG/vRb/RcnxbwFwDE8ZwtM8Cw/
kOpVC+pT9ABtAge69CdWYd1j1atE+IaLfMq+aMO4hg+CMwueq4Z44/T0ceebh8b+xvwviGny6GKw
5/8A0q7vyMrnsd+wnCmlGA4viaZEkCvSa8fSCvbGvaEYc07hJhP2vzZx8v8AGP2K+I8IHOwgweOY
P5Hmm4+zrfVcFxrwjxjhLnfvLhWNw4H4nUiW/MSF9uw0zogfQY8EESOSvXKeqvzS/wCo+CW4Zl4e
PmkvtjGeEeBYmuatfhGAqVDq52HaSfoknbJrtg/OrNOyWcXsnhOB0X13z/IS6eyaR1hOIAThvZDy
GeiQKOEovorEoZN9UCkOh2QG0qsmN04ATf33TjvIVBNYXbaqxhmllRRtqAbSpqLw+oNoWb6aw9tb
Au/xbbnSFm4wf8wfP8yv4S2IZznkqOPEcQfAm/Jcsfb1Z/5jWwboNGSYnurlb+K62qo4azaUc5kK
7VP3pg23XO+3bH0BjhmMiRKTwarIgAIWOh2XLJ1nSFMHQAXbXuFFQHBkgA1XADqoncP5knvyVxtU
l9oA16IwcznW0O6drE6xnfu9oB177pm4C7p/2Wk8mA1kxKaIJvuPqnep0jPPDwHWJlGOHODfuyrr
v4mkzupaUmwN071ZhFbCUqlAEEW0VhlQkOk63iFMXRIJzboHtAJLZA1jqs723Jpj8QdNWC2SqYP4
dxcTzVjHEGqbfNQNn0gybwu2Ppwy9mJJnpzKVxpboiyzJy207JNaSwi9lULpGul1s8NcMpBmI2WU
2mTcthp2WtgGloAdYrGfpvD2stplpF7d0QFO8/Ebd0nvcJAM8uqBrXF3p7rk7DBLaRIuQbomvL2G
wuYISbDWxryEaJyA2XECJggC4QFSBbIAgd4lA8w2wNvdSCpmHpbfoo3vzZg4R1i6gdri9hEQT1Rj
LlA1H6KN1N1Mem7eiQcSJcHQBYFUStcGj0NgD/VM53qINggZVJaZtCbMM0mQJ0hDZnuIqAhttETY
e6Wyow4vflDANLnZS0xkcLX1EoCY/wBZO+6fKMxkiCmaQKpAA7wiN3mPmQoogWBunqUIe4gZQNVK
Q1gibkoHS6A0QYiY0SIYujVs8kvMcH5WwROsJ7taQZA1QUy4jTTchUE4l7gBa2pOgQiW/NHTmLt0
3KEAkOBN9wgKpcEwI5CyFrswIywpA3NTGaRaIKB0ARJ99wgB8wGiSdydlE5noLeY0UzQHfiJJT02
Av8A1ARGfT4a2ZeZB2CsjBU2xAbpyVr4nH1SNYUTGSS9xy9Fe1pMZEbWNp5sottdOz+GSYvrsiI+
KSf9ELpYOYHNAg6RJGsJwSIcbneTZROJbAgxzhGbi46ICAYQSSgf6XSIhG1wYDAk6oXuzAd5SJVC
tBc4aKPB2o1NdbKapYuEEEWUFE/c1BABLl2npyvtLhrlxOsclawtbIfX8PJUg/I1zh6bWtohp4tt
80/NdcPTjn7arqhquJGgsFHi8SGYd7Zkkqh9taARTtPJV3uc8km+0c1pzS0M3kmwJJmyQjlY3gDZ
WeH0mPonM7LdWPs1EZvvQd+61q0lUZ5fklMGwHZXhhaP/r/VOMJR9U1hOqdau1GxkkX2RtMTN/ZX
G4Shf70aqQYOhBisPZTrV3FJh2BFualBvpryCsHCUWkFtaDHyRtwtGP4yz1q7iuw3vP9OylZZ3Xu
pm4WkIAre3JE3DUv/VH9FnrWpUNiNv72TsJ3bCstoUib1bAo24elp5gj81nrWpUTCJ0ClboYA6BG
2jSEnzLwpmUWNFnysXGtyrOEwFatQdUptkC6hbLbEQRqCp8JWqUDlpViARptCfI1zsz3erUrOWM1
4axp6ByusFbpPsAANFBTpM/mIVmmwXOb/Veex1xWKb5OYyLKxTIzaaKtTA2JPZT0rEQbArnY6xaa
/wC9OitYL+IJ1+SpUfjO3QKzhT6wsaXa453r91YovluipBwL5j5qyx33dxCxY0v0TI1VylUy6arJ
ZVAM6nqp2VRa8brGlbNLExv8yrtHGRuVzja0b3U1PEW1U0OmbjuqkGPMarmm4k/zI24k7FWRnToH
Y43AcoKmOP8AMsY4mZv7qGpiJaQCrMRdxeN9I0MnksevjBJkNv0UONxHpF5lZlavJiblLisq1Vxk
aWPQkKnU4pXYTkr1mdqrh+qqVa1+SzqtbWSmOBa03eIOI0/4fEMawdMQ7+q2uJeJOM4fwxwaszjD
m1ahqXpvmsGz+MmZ/wBlwj6suN4i0yt7xAypS8McALuH0MNTdTcW1Q8F9S+ruU6rVxm4ku5T/wD7
QvE9IHJxzF/+5rD+idv7U/FlGY4uHQJ9eHYVxdZ5kbieSho0zVxFKkBJc8NPZduk049vL2HAftH8
VPouJxGEe5lIPcXYffXYqk79tfiTDNc6ph+G1BMfA9v6rIoAYbgXEsWbZ/u2LzziVX0NbIlc+Gdr
WuXWL1P/APb34i//AMbww9cz0l4yXgklwv7pL1fFHn7uPhyV0+cRrdMHiDe69zw+Cg6J2gnbZLON
ksw9kPB76JhJSzA7pZgqeDEGCmyFFmEWSzi95Taagch03Ttae6fON9EbSfdNkkCWmD0UuFvVAIQO
IA5I8M/1iDop9LjJK2KAisyQfZUMcCccdJVukYrNg2jkq2PAGIzGIXPH29Of+WhQs1gO3VXXOpkl
xdB6LGZi2Buu8oji6eU+oEQs3G1uZyRrONKCQ75WROdRIkPBHVY4xVMaOEpfaqcRIjkp0q/JGy3y
iLPBGmiNr6OQZX73WKMVT/mH9UvtdIGxI9lOlPkjaz0pJziOaXmUc3xDvKxRjKcQSBFk/wBspayC
eydKfJG5NEwQ4R1TtFMN+MR01WAMXSB125dUf2ymZEp8dX5I3i+lHxg7QgqPplpDalxzWMMbSvz5
lRuxlMyQQJ5p8dPki6/Bte8nzQO6mpcOpb1tFljGUgdeqnp46kBr0stayZmWK67BUQSPO+SnpYOg
2CagndZ322jcgiZ0RDHUgLEBTWSzLFqDCUTH3gvy2U9OnRbpUHdYYx9IWkDbVM3HUf5hCz0tameM
bwpUrTVHKyQFIGBWAWMeI0dnARdRDG0STLgnSr8kdGGUSB96OU803lUzrVaRy2XPnHUZ+IaohjqV
yHAn81OlPkjom06TdKrboW0KZMms0iNVgDHUZs76ynbjqECHC/8AVOlPkjoPJYBes2D/AHCRoUyJ
NZi512OpRY9roPttP+ZPjp8kdJSw1PLeuwI/sdKw85nfmuYGNp6Zo2RN4hSv6rap8dPkjpThaVwK
7EVPCU5BNdsjneVzX22kQPVdP9tpxYnknx0+SOnqYWi0f9QwEIBhqRNq7VzLsbTOpmUIxtMmxjcQ
k46fJHVNwlI6V2TCIYRjRIrsBXK/bmXMnmibjmndPjp8kdLUoMaCPPbzUAFPN/GbGo6rCrYnJcix
0KgGKbnncaKzjqfJHTtFOP4w13T+XSIgVROndc59qaRaRtdO3FtzTfWdU+Onyx0BFMf98RdQEUok
1Wx2lY78S2CSLKMYlu9/1VnHU+WN6mKMn7xs8lKBRi1VoPOFzhxjNyeSMYpsE/onxVZyRu5KcmKg
/RLJSv8Aet91ijEgTb25pHEjMnx0+SNhzaZE+YAeiHLSOtRo7LHbiPV117JxXbGkhPjp8kbD20ib
PAi0Ji2kJOYcohZn2hkSRM31S+009AP9U6U7xo5aW1Qa3QkUzq9sC6zhXaTETa8BRnEMB5H/AHSY
VO8WcQ31HQg3/oq1ERRqExrMJnV2kEabdlO14q0Tk91uTUY3uoK3ppvJNwqQIESeoI1haFUZm1Bc
2klVGUacam94XTD05ck8gBEgAo2wR1m9lIyhRadZHJXcKcNTPrbMRotxjVLDYatVojy2EkHkkeH4
oEfdG3cSuj4Pxvh+BpubUol5NtFpHxVwwH/pzY/yrrMcdeazbl+nF/u/FECKR5aIxw/FQPu3acvq
uwHivhgn/DG/+VSN8WcMH/2x75U64fs3l+nHjh+JaZFMz2Rt4diZ/hmO2q7AeK+FmxwzvkpG+LeF
X/wzueinXD9nbL9OP/duJI/hu9hqiZw3Ezek7VdefFvDBP8AhjF49KNvi3hh/wDtnXt8KnXD9r2y
/Tjxw7E6ikQeydvDsTc+W75XXYf8W8MmThnc/hRN8WcMm2Fd/wDFZ6YftZll+nJU+HYof9o8tCph
w/En/tHTRdU3xXw3X7M75Im+KuG6/Zna8lm4YftuZZfpy37uxIMmmYUzMFiA3+GfkulPirh2X/p3
fJOPFPDySBh3T2WemH7WZZfpz1HBV21AfLsOiM4StM5NV0DfEmAOlB3yQu49g3AxRdfosXDD9tzL
L9Manh6g/CrLaLxHp94V48YwrvhpH5JfvOg7SmdOS5ZYYft2xyv6V6bXDVvcqdkjZOMbTOjeuiJu
KpkRlPyXG44/t0loqRsfi7qxROV4mw7KFuIZNmlStrM/lXKyNypWv9V+cb3U4ecgghVm1GGdVK17
SDY6rOmpU9N4G99wpBUgaqqHCdO0J84A100WOq7WRVvupG1Ybr7qgX6+ycVSN9RqppdtDzoEAhEK
/In5rN82bEp/MBC1MWdr768TcKPz+ZVM1CZh19kHmCAMwWpE2PG1Oyy6tUz35qfFvuNhtKzqjjMD
/dLF2erUvE9bKnVdJNo6SiqOIEa+6rPdcf0VkZtQucSO95IWv4hNJvCuBGlhcbRJwxLqmIJLX31a
Dt+ix3NtEg9FseK69F+F4NTw/EcRjPLwbQRUZlDDybb230S+4T1XMVnWBt7q94comrj3VCCW0GF1
+ZsP1VEibCDA6Lu/BnBXHhdKo4evGVc4t+Bth87py59MGeLHtkDxjWGD4BgsAyz3DO/mvMsbULqp
mYAhdz48rh/E6oFw0ZRtYLz6o4ue47m+q1+LjrDbP5F/toHmRY2PV0JJNNt/b/ZJep5nHgpJJL1v
CcJDRME4QLZLmkkgSWyW6SoQvO6sUxbdRU9CpWaLNbxhqwsITYf+KEVbRBQ/iCOafR/5NcTmFlHx
MX9ouUZJAHQjUp+JtJaIk2uuU9vVf81jTcpA6o/JqT8LvkkKNT+U8tF228mqGfdKepRCi/8AlPWy
IUKn8jvkmzVRgzOqV4UgoVP5XdE/kVL+k68k3DVRg8kpt+qkFCpf0OS+z1f5HfJXZqop5qdskDa2
qH7PUH4HfJSso1B+B0rNrWMqJ0glAeSsPovzGGO+SA0Kh0Y7srLEsqLfmkNlL9nqbsd8kvs9Qn+G
/wCSvhOtRjZPJEz2Ugw9U/gckcPV0yO5aJuHWotjItzTzZGcPUucjueiduGq6ljvkm4uqjM9inBv
f6KQYatEeW7loi+z1b/dut0TcOtQT1Kdv6KYYersx3yTjDVbxTdHONE3DrUI0voiEzJ1Uowtb/03
8tEvs1X/ANN3sE3DrUIGoESkP0U32WsRam+eyX2WrNmP+W6bi9ah0GyQN491P9lrwfu3ackwwtaT
FN3uE3DrUYJAJvfdL6WUowtbXy39E/2WsLeU+AeSm4dagOu/9ErmYFtFM7CVv/Td8k32StaaT/lo
ruJ1qIH1Wv8Aqr1MWAG2ghVxha0/w3d4VunRqf8ApuJGx2U8N4ypcaZZT00EKqIJPIq9i6NU02Q0
k84UAw1XQMcJK14NVEIbfluiZrBttZH9mqz8B+SJlCoNGO+SiapoIIGYX20QuAm9iOalFCpIOU89
E/kVLww/K6GlQznMQOV9CpaYIYYsLkFSHC1XMjIZ10TDCYi3od7hFkpiYkE97/VJhBqAHtCIYKvF
qbuQsnGCxA0puB7Jo8hERAATtyk20MWRNwWI2Y6eyX2PE2ApvjWCnVdmBsQN9R+qQd6fREnkiGBx
Rn7p0g2RswGLn+C75J1ptXgEb2smF3T29/7urg4djJJFBx7hI8Mx+1B91elTatewj5/kruEvSfEX
5qF3C8cG/wAB0RuFJSp1KVMsqtLSea58mNk8unHfJVLsdIi3PRVWFsWspsQIouE3CqNmLQB9VnH0
Z3ysMMxlify/u6LMZ2tpdQBxnVMCZEkHpC1pnssZ4kaSLos1yRFjcmyqjNmEG2yL1AD1Tv3U0vZY
Ek27SiaZjqdFWBMa3lE0uygTv9E0bW8xgbgWt/fdE0mHD5KtSLrwRY3lG2bwfmVldrAAuZidTKIG
/XVQNJNPU8uqIEkxIQ2sBxcSb+6lBid/ZVGFzhzOylBc28qaalWgd52gJ2ug63H93UADgCSehsnY
Tb1EXv0WGpVsG1rAbqRpGmxVdshsAkKWmCRqcpWa1KtU5O2ilBP4SZJuFXpi3xGCJUg01I5SsVqV
Ypk67HqrNN1pBB3VRlvxWUrDB9oKxY3KusdaSbbkqZjvzjRUmEgE217wp2uNr2+qxpuVca4zEyCp
2HmVRpz1U7XEayAs2NSrTX63nqVM122pVIPJAF56I2ugSYCmllXA/tZGHnKYsqQf1sEYfsTqppdr
GfUAjsmzmPayrF5MmTZPm5wmjawHwJ27pw/bUqq18zaTMpB3pVkRZc+GkRsmDwBrdQF5AgRb3Skx
BIWpEDiXGWgG8aLPqO9RiArWIfcG5Kz6ziTO3ZNGwuNjF1We6CTPvyR1HXmPloq5dffqrIzaT6ln
CNtF0XjzEVqtfhlOti8JiPLwTGgYdsBltPyXLPdZ0j+4XQeNSf3rRpvwuEwuTDU25cO6QbbrN/1G
p/msfhGAqcV4nh8FQs+s/KTHwt/EfYL2R5o8M4fVrtaG0qTBSojoBC539mXBTh+HVuLYhuWpih5d
CdqY1d7n6BQ+PeLgUPstJ3pbay83J/8AJn1jrxzpjuvPPEmKOIrVXalxgbrnHbiNFdx1XzKpEggW
VBwB1C+jx49Zp4c8u12EOO5PzhJIAxqfYpLo5uRSTkWsmXreIkVNs2QyjpiQb2UWHe2AgGqlcJCj
a0g+6RbBimCmc3LKs4ZszdR4rVSVbj42jpyQ5SNnQqKnEGVLTNuqlMTVribJqH8VqJ4hv9ENH+J7
pPR9tVl2jTUKXFVHNe0DSLCFAyS308720VqphalRwMDQLl9vXPXhXFV0GwtyRCs4zAB/VTt4e8gz
HOUvsFQE2Gmn9E3DVRtrON7QOiXnO0gdlO3AVDy+aIYGoYu1TcXVQtrvE2HyTee+AbfLZWm4B5bM
DshGAqifS0gpuLqqzazr6W0AGikbiHCbDlopfsFbcT7/AJJ2cPqg3AIBTcJKruxL+Qnt/fJO3FvB
uBCsnhtUWtAHNCOGVS4WHLVO0NZIjiH7BsdkLcS8mDlA00Vr911totunHC6uYwGwNOqm4aqv5zwN
R/8AGLp/MfyjcQNVa/dlUm0fNSfu6ocpIAG8FO0WY1VZWqERb5JfaHyZInTRXG8OqguIsNNUm8Mq
iTPyKnaNdapee8gWbziEm160aD5K8OGVINx2Rfu2q0giNRvzTtE61SbiKgPpy9LWRsxD5EAW6aKx
+7ahJJIPNGzh1Tpbqm4aqn5lSJEfLVEytWbJIbA6K2OGVSLkA8pUg4XVgiQbac1O0XrVRuKqf5Zj
ldL7Y8aZSBvCt/uirrY7i6B3C61t+V03F61WGOqkCA2InRP9rrSYa3lop28JrARAnukOE1rgQTzl
NxNVB9uqxIDbdEP2ysAfSD7K43hVfLo0Qn/c9ZoiBrzTtDVUzjawBcQ35aoTjas6NsI0Vt/CKwBA
yzvdWeCYPDYXEPPEqJqsj0gK7iWWM0Y2o4fh1nROMTVi8X1MLtKDvDxPqwDtOS0m0/DDqd8E8eyz
3I8zfjarTHptfRHTx1Tm3bZd/iaPhYhx+xPB0C4XiH2VuNqfZsPUFEH0rUy2xll1R/bKxbaDFzZO
MZWgzGmsJ6b6M/wnj2U9NtBzQcrmjqrtmckqucZW2ieyA4ysDFu0K05tBrZvPKFWo4N+IaXsaQ2e
asyWZb8QhjqgBnL1UrcbUOgHyRt4XVnQCOqkHDKtoF07RuY1Xdi6w0iBfTRJuNrjca/yqw3hlUOn
8MRcpm8NqAGw2mSneL1qFvEax1gTpZOcfWtcKR3C6ueGj3lI8OrAgiPlqkzTrUQ4hX0EFL951ydR
fZS/YK2UyEx4bVgiIG6s5P8AqdEZ4niB+MIm8UxLTZwncphw6sLNGmyQ4XVvbsr8n/U6f8SDi2LG
j46wi/fGME/ebclF+7qsEEC/0Uo4bUIMjUAyE+Wz7Pj/AOAfxnGEO+816Kqa9TElzqhzGf7Knr8O
qtBOWY+qosa6iSHDdW53Ke069b6LFGabtInVU25jfUK5X+CDGXsq+Qw0t5aLeHpyz9hDhAsPknnO
PVaLIWtlwzfNWDTGSQDmC0wjDo3kwmzNI6dQlBnUj2UlFoI5DoooIAJJtOv9EUn8Q94U9SnFxbsh
Db+oGZkyoBaSBoJ101SYLi5MG8DRWKbGmJAJvKBzC1ZULTc8uymY6Zm/dCynbKdTqVYNMOHsosBT
9Jkgkg2KkaQZnnMHRA1hO5OymZTEXvz5KNETDSGmx25p2SRcFE6nAJbodf8AVKm295idVmqNtTW9
j9FIHCTI13O6TaYLTPMJXGbMFlqLDHWgyPZSU3AwCfdR02gfFN1IZbIEws2NxK1wJGk9lMx3q0gK
Bl41hWWNEEzdZsalSs+EgRClbpcwFXpuvpBmymYZBuOSxY1KsMJBAJvpdSC9yJAtZQNdeJ7o82vL
os6alTtzXlSBxiYlQtdqiB9Jm3O6zpZUszflunaYnSfyUQcJMfmkTsAbpprY8yfzB0UWc3Fo7oTU
AFtSmk2lD+RuizkC9tlXD9ZiNETX3J90htOHiZJ5JwbHWVCH5htGmmiIGRdakTaLEEy6/q0NlnVn
+6vVz6nC2izqnxXO6FR1JIIUT3buA6qQgSNddVGScth+qRlA6HODXZiC6C0am+3XZd7ivDNPjPjc
YHCYGtgMJSpU34oVDJDY5ybmI+a5DhOBr8Q4ph8PhmPc9zg4lgksAN3e35r2TB4ingMJifKFcGpW
cXVcT/EeBYTy6Ljy5db4duLHtKPj2Oo4HBllENZSptDGtGgAFgvF/EuPdXrPcSSTIC6PxZxv7Q9z
GP8ASJvOvVcDiqpq1C4x0HRX8fi1/anPnqdYqkEg/SygdN/1GisO0PS3JV6hE2m69keKowOkdI0S
SBA0kDuktMOSOiZO5MPqvW8Zbm6kpaKNHTjKosGTBE3TAy8aJH4kzfjCi/a3QEzv0UeIm0qSjZpj
dQ17OCzHS+kbJEypGWB7KMW7I2G+6rMPV+DRR0vjHJSP+C8W2UVP4wk9F9tZlQMYJ16Kb7bEXAMK
n+DQeygq+3KVjW3ftZPDR/eJg+swh+3GZz3WWN0TDa50TpGfltaY4g6RLypBjSdTKxqm1z8lPTuy
U6QnLWoeIHK4l0mFGeJGbvVIiZCpPsVZhC8uUbY4j/m+qMcSi/mfNc+NlOdO90vHDHmyrbPEsxJD
9ELeIubBNQnosencEaIxIG3NTpFnLa2HcSt/EPzQjiZzfxD81i1NdfdRm24VnHGbz5R0A4nf+Lrz
Ts4sdTVJnqudF7KTIdrlPiiTnydD+9dYqmJ5pxxW8irfuucLTGxTQeafFivz5Oj/AHvp96Z7oXcW
mR5ro7rnwCf9U4YU+LE+fJunihNvNJ6ynHFCf+6Y7rBDDzCcNJlPihOfJvDix3rE35p28WMk+afm
sHKQSLJiI3M62T4sT58nQnizo/jHTYp28Vi3nuP/ALlzm8fknbvpAsr8WK/yMnSni8tP3xjumHFi
P+8dOa50C+nul+Gf1U+LE+fJ0g4w+x80xylL97Ov9849ZXO6C4v3S2+gKfDifPk6E8VJJ++IHfRQ
1OJ3H3x+awjYnSExuYvPVWcUifPlXQs4k6AW1SVM3jNQEN80gnqsENsIJQUhNXmdVn45WvlsdBU4
rUd/3XX6qD7cTc1Ss6Nb7wmA0Ow3lJhC8laX2twM+YZ0UrccfwvJI0WdWiGifqgaQBr/AFWvjifJ
Wo7Gkgg1DG6anjzTsKhHRZwJMaD6e6RbJgH1H+7J8cX5a1RxF1wapBPVO3iTtPMMbrJa0yQRE/VO
AdZuFPiizmya37zd/wCqekFMOIumfMcdQsuCIIIkm07omwXQfknxQ+bJqniLrxUPzS/eJ18wnuZW
YxuYiCUzvigG+khPiifNWmOIkOu+QEJ4kYPrMfos8ATB16IHCJiYHt7dE+KL82TSHECf+501T/vF
xBioRKyy0h0H59FKASI33vre6fFD5sl394uyuh5sjbxFxNnnnZZdQXLRv+aJmh1B7/NPjhOXJpVc
c5zDLzdVhW8w6mzlG9v3RuU2BZmzGN90uExhM7ldJa49BmJnYXURIBEibeys4i9ORud+arVJFPNu
Arh6ZzmqDR0jXfmrLCBT3hU2EZhcnbVXmNJZF5P1WtsxCRaCUVKZB+oOqirOhxgnsCioEE5cxlQi
7VkAWkFQkg6OIAvzUlUk0yZ5anVU8x0MhyirlEy31NnsmkZgSQWjRSUTFMRE7mdFDiAWkZbiVFS0
3EuIB6WCsD0tEn4hpGio0XEVMskCN1dJblBMqLDWBgARNr6qSiZ0i/NVBAJ3A1VzD3aMpBMrNWDf
dsSCRqna8T6QBbXVDXAiW78lDSdJs6SNlBepuJZII1t/RPJkEEnkkwDLlFyLydIVd59Tsp+XJZai
1SJzWiDYX1CsFzZHIQqmHIM89rqxq3Q9JUbg2P8AforLHS2LER3WeHXN52VukTlgkT1WVlSg2E32
7qZtxzUE3JFzylGw5mgTMbLOmonaQXX/AC1U1J0/F9FVGs5p/VG1/wDLryWdNRaqO0vPVIOt+qgD
5NwiDgeUHmppdps8kmx3Th1tAfoocwn4vkUQdeDBKml2kBiTNp+qbPPtfVRlwm+yFzsrY3lNJtKH
XsSSna6wuq5dOicOB0IPZF2thw6AckTD6TCrMe3mCOqmaQGmdRorAFYS4ix59VE2g55hrZJsANSr
ODoVMXi6VCgJqVXBrQdJ5r6K/Zz4L4ZgsAHZG1a/46zhLnH9AuWeerqLbMce1fOFXheLDZdhcRGs
+U7+iLg/AcZxjGtw+BpZnz63n4WDm47dl9XeIOBYNuDc9kMcBIMryvF8Xw+BbiaLvLpmcxc0AB/f
qud5bjetb45jyTtipcO4ZgfDeCGHwlQea+PPxZF3HpyAXG+IeLhj8TRpYs4imajiapsX31VjGeIK
mL4nh6WFdTaTVaAaphgM6nouG8VYnEVeM45lerSqO812Z1GzD26LXHx3LLeTeecwx8M/iGNdXqOF
ywHnqqDndEZbI/ogyi1hdeyTTxW2o3OjSekFQOmTBiLqVzY1jlqonN9xrey1GKEX2f7FJINPfqEl
WXIuSYJPNJ2qKi2ZXqeSeaOAdUwgCw+aMsgEzZAL6rLeiJlyZv8AES/GUmj7wwqyu0gPKJuoMQPV
CsUgBSsfkq1f4hYBZjpfSNjZJRsF90FPX9VILcvdVITzLFEz4vdSu+E8uyiZqUiX2utM09vkgqNE
CPmjZ8N5ulUAhuwWXX6V4l8akomNkmPyQuF566p2H1GbyFpzPWb6LSjwx9NuyVQEtKHBmH3T6PtY
ymTOnOLKpiBBV25JI1VbECQUxXKeFTkrAu0R8lBpEKy34I9yrWMA09+ykYLCZshpfi07o2fDAv0U
reKJ7bnZREaqapbZQ8lqenPL2mFK0yjYMwDTzjunDxlB6KNhBqW0RYmNH1ZQJn6om0A8kX+SJ9T7
wOv8kVGpBdHyWdumoX2URzTNw433vqpDWuMotuEvOi3+im6agBhm3ujGFDW5o15IvNMzy0CE1M03
0+nRTdNQm4Zsmfom8pgMQDpfmifVs64HMAqPNa+95KvldRBiQBUgbKHqrNZuYzBAKRpBrQXHbkt7
c7juq4MSni1oScACQLDVNrJ2VYFeZCaTBLinnly2OqY6XIQLSwv1TsE1ABz0SAnSYAR0B95qJHui
xLFiefMQosOAakW91PUMUSRaRuosMJqKT03fayYuDfaYQMp5jYj8k5/F1SpwYvy91PppJXALWkn/
AEQAR+kKTEXytmSNZUYYR099FqMiYC0xm0PZO0HkkBI0JB2RNBP4tomNUBTIgTt+qYti5+LmlmJB
No+STRDB10QO0DN6nCE7fii/tzTNk7k72RNJ/sIDguYSDpdDldB1nS5RNIAJO/1QEg2IHTRFMRE6
6/NNBHwg20lIEnMSCBp3ScbnKB3CBAach81ISJJAJi8RdRCJmLxClBdH1B0lBE8BwMkTySpSbX6Q
nqWBJ16aoaIkgczpH9/2FBYe2KcTJR8PbOYSENQEUje2qPBsAF99FnP03x/6WMUM1I631JKo1T6B
N55K7iZNMmA6+qz65+7AAAtNuSzh6a5PaNvxTJJtbmtCkJY7rzVBg9ZzW68lfpuGQgweQWnOKtYE
vm4hHQAdIMxoUFeA65gzuEWH19JvsBsoLT2xT+H1KoLE8tOysvs3oOSqgyYABFrclFX6BimL3GnZ
R4ixn2R0G5mCDZR4gZni56IoaIIeYgjlzV2AW3tb8lTw4mYM30V0E5DmEX15qLFeBl5Ec9lbwpGS
QRZU3RcQDtCs4YgNsZd1KixNVu062MKGmyXCxjRHUdDdnb2OiGm4l41JWRcon0nLr8lDUEOLpFrh
S0hY6AKu533hAM31UaT4Zw0IJCsmcvOdSFVw4lpBsVO93p2IUrULL6eu3JWaYECTLiNjZU5ubA6K
zTNp531WasWGi+h62uia0gl0SoGu9QygKUEk3uAAsrEobDXBGIDtzCgBFr22vqizSSQbjqo0nYRa
bdCkHEdD0GiiDg1oAKJrgDY3Cml2maY0J0TteAY2iVWa68nWOaJr5gZu6mjaUu1v7IXOvYxKDNNp
vpCjeZbmkx+aaEpNpknunDuZCrydvZG1wEmyaWVbY+RpHKymYfTzmypsMssfbRS0njYosavAMU3B
8WpVn/hmO8L1jwx45GFwL2ySWmy8TBJuCbLuPDnCMc7BtqP4diajXCczBK8X5GPns9XFrKdcnQ+K
f2iYjE0zTpkhvdeaV+LnE1qnmEkEEmSt3xBgGYbN52ExFE6+thC4LiL8gdkDmgnLe0K/j4y3Zy6w
x/r6anhpz+IeIOH0G4ZuIBrNig52UPi9zy3VDj9AUuNY9r6LKBbXdNJhlrb6Aqbwa1h8ScPFahiM
RT8y9LDuIqOsbDkqfFHtOOxORr6TfNdDKhlzbmxPNeyf6eXe8PKm9gG47qN1MQic8XH1QOeANrro
5o6lMRooXU2gqZzrWgbqFxF1UCKTYv8AkkkHW59UlU8OHdqpKUgKM6qVmwXrrw4+xvcS36JAWHND
UGgUoBlZb+0QFyUzP4pRM1daU1Mes6KsrrATS0gqrifjCt0wTSIbN+iqYmPM02WI3fQG2KO9tEDd
dlI62kKkJ3wKBnxSrD/hmFA34tlYl9r1FvpJNgiqN9LST9UqA9BtpoiqSGCLdFh114U3i5nWya8g
oqgueyAfDP0Wo5X2nj0n5qGl6aw2upmzlGnuoH2qA/qrFrQALucC3ZQ12+ghSUT6YBExZKoPSSYl
SNXzGWeWqss/hqCoIcfzVil/D6QtVyw9npD4uyNkblDSMON7R7J2kQZhStwFURpzUHPWFYqkk9FA
7danpjL2UnSVJQkvE9rqPbRT4EA1YMQUvpMfaYuiL2jZBN4+oV19FuYbgi4Q+Wwv2hY266Vm3hSM
aMpBVinTZN2jsiLWybRtdTayKzgNWzZC2YMyfqrmVv4QJ2MJ8mhy/T6ptdKgYBsf9EOW3pFhorpD
QLtaNkIi5j6aJs0pAi4uByUoe3KA46aqq4et3fTkkSd9SumnLsevBMNvsg2ScZOtuaVzJO9lWStJ
5FKYGkdUxkdRySg20FtUQgbWmY1U2Gvm7KCCLjVWaIgN5C/spWsfYsUIaOqDDAGpfSE9c+sTqPqi
wwHmGx7pPS+6lqCxJga2T0XX3baQUVW7XbkbhBSEtMN11vELP039jxAkNy66oGtIO/JHUNhIBI6p
2gk2c0fotxmmAsZ01siIcDc3RNblNiAJ0hItgekAopgOljeEm5jIImOika0iQSRfTZOL7z7IADQY
P9kJmjUmIHzRwQDNgd4KdsG8gcpRAwBd31/omMyBqSZtdSgAGJAPNCAM02+f1RQCWmwBj3Q1HGTt
N5RZYm5Fk0STIGu+6ARMkWHQKQNETeABclIDX0zJUgBJJkgz8lBC8TzEJUgbjWbDmjqAyCBPUpUy
4mXWPKEEzpNI6TzUmGjIdpNkJaDQO2nsjwUGmT36rGfp04/Z8TPk/CZVB92AhX8RApAWBB5zCo1Z
bBn/AFTD0vJ7BSHrGkrQpAFp5DQ7hZzLPg6aX2WlRAg66b7q1iKVUSTHOEVHSWjUIa053Tf2UlA3
BsDOqiJngFu8xzVVpmYDo/vVWqgkPtHIqrqSTA9lFXaJhoF+SGvZ4iY3RUSRpOm2oQ4k3B090U2H
N5Am2hVpupLrAaqnhnfeH52uVcBytMBRYrwcxBJva1lawwHl33VQOm0iFcw8eVMZjzG6hCriIQUv
iIPsjxI9NoBlBRJc8EyY+qjS7TJIEAdVXqZvMdOm5U7DExoVWJOYkGw0UVYw5IZO4VhwzNExKgo/
CQTmR1Hw283UWBAGa0kK1RgtkKkHNiLdSrNOQJJ7rNWJmyLbX21KmaDKgpkaTFrXUgudb/kstDbN
7exCMSbm0KIWtJjp9U9wAADyAQSzNzayckhkQYUQc4DtsjkRMHqNVFECR/sk10ONhKDMAZzbQhBF
xFjv0Q2kmxkiNEzj3vZIv9MW67qNx5R/VNBwTNkQ0vdQtdBvA7pTm0lNLtbZUBbzHJWKEkR+aotc
Z66hdL4O4F+/cTUY7Esw9Km0S43JJ2CxldTdbwm7pseEvB2I40w4jFPOGwZ+F0eqp2HLqvd/BHhv
E8PwQFPH12MizHAOj5rmuA0MdhPKYyg3EMYAGlvJehYHi5o4YefgMQwjk2V87vOTP+3p05u2GOsX
H/tFwHFqmEcwYnDVqXJ1C6+eOOcFxxfUY4NnNmDQ2M0fqvo/xd4ow5puptwmIn/MwheR8cx7aznu
bh3t3+HRTj5Ljnevp14+O5ceso858JubQ8RYR2Ir4jCNY45n0WzUBg2AWXi3Z69ZweXhz3EPdqb6
nqu2wrKzeP0eJUa1LhwDHtfiKwkZspgRzXB1ajn1HOccxLiS4aHqvo4XtdvNnj1mkbp5wgd8MSUR
NjYXQPMtjT2XaOCN0mTKjcRJ111ROJOkDqonk3stJRAgiQ0+10lHm1sfkkqztyP4oUoPS+yiYJcp
2ATZeivNiFx9bVIT6SRpFlD/AN0wpDIae1lFhUzY/mmp/EduyTBFMlNTNyiReY8CmNhvCp4kzUIV
pvpZAN+qq4kfeHe0qRu+gNMFSu0jdRfopLIQR+EmVAz4yrDj6fy6KsPiPNWJk0qF6Z3RVD90CRcd
U2Fg007xNEXCw6/Ss6zio2gkkHujebf1QTDjC1HOpGfANO0So6+k3kFHSgkglNWb6LbJC+Ynw7j5
dijuWkSLKvhXDKQVdcQTGllPtqeYyqwh3XqpqBHl6psU2DrumoH0rd9Oc8ZJGEZjvZONf6aoaR+8
EmwRUyZMXUrUBV0i2iia0udZS1fkeyipkB1+ULU9M5e0nlG5CKi0035r2UlNwh2YoXPEu1IWdtdY
nOLMaJhiXfyj2UMtIMCZTS3lbuou0/2moIidbp6dWq82IKriLG0jmrOBcPMM2smiDb55mJ05J3Cv
IjZX8zAQC4QLqT0ZNQIUaYpfViJ3Sa6oRaed1Nma2q4GMqNjmBm099FUVS2JmJUYAMxcfmpqhL3Q
dDrZRkQDN4Gq3GLER6RbdNfkPZLWTedU+txp1VczC3+6UQEhfUiU7RIAmI6IEGyTBPzV2lThjYN4
VSlyOpVwENYZGgWa6YftVe7702t1upsHZ59lVPqJkq1hCM7tbK/TMvlarzlcSEGGeRMRc2lFVcSH
SRIsoqUmIJAvY6FZ+nWexVBLhFgN1M1oADSPnedVG+BDiLfVStIixMDotRDgXjLI5SiaA9xMzyTT
Bm8aHe6dhiQJI1RCknNJ/p3TgzBI6JA3ggQOqWg1JQFckWE3jnKbNH8pH97JnOHqidbzoizAC5gd
4QNMAAASbW/NAB8uZKInk4fmnMyYI6ckUDRY7DYEofhvAMbiUUmJ+ijeQIAt/wCSIJtpm5lSsAtm
ccsb7qFriGwW/NSNdzuInkhCqEAEggncKNk54tCT/hcZ3+Sak+ZNgeQ5oLLz9y7NoLTop8EPQSBv
Nyq5IdTMCYjorODM0oad5jVYz9OvH7Bic2S0weaqVyA0NgE7kK/i2BtIl1+yz65Ba0iLe6mHo5PF
RsJDzNr6zK0aTpaRF+crPp+l+yvAwzmIklarEVKpBeYsL7qShcti91FUID3QLzfdS4WAQALciVEi
ZxzNJkzzhVG2l0C3JXKhGUgidoVMEZjNzbdRVyjYADvqmrul8ASAP7Keg8NpxBMfL+7pVpNS+iL9
FhAJcSSBFuitPs0yAOxuquEMvMAg81bfApROg2UWKbYAER0tqreGtSkbc1TJ1/QK7QP3epmPl/oo
QquwmR2Q0JLh/MnxAAaL6i4KhpOh1iNZUaX7Bovc6KqTdxJgTfkrOYFst+vRVAbkgabclBaoXAk2
lHXnLJv+qiw7hs4TO4RVHbaXsFFMww6BJVyleSqAcM4F+tleY7UHTmFFg2u9RAAMW/3UrZJN9BMw
q7HiXDNHLoia5oPWVGosAAA6DVDm+IE22P5IAZ0gOnVENTHPVRRNcQCb/mjBJBP02UWrgN+acOiY
02ACmgYIOu2nUpg8ydhKDNIO/NC1waJkTppvzQSzIde8W6IXOkEXvvzTNdBvP5qN5DWmbmECDtIM
HrdECQDz/RAw6xfYWTl1v6oJqbiDEAOXpHhPDcJPDaIwuO8rHug1RVMAnovMQ4AWgtG6s4TFOpPA
uW9Fy5cbljqO3DlJl5fRvAcPxjDuDsJVbVbza8FdPU4t4io4cxhmvI/yr5/4Dxgsy5cXVoH/ACvI
XZUeOcV8gfZeN1zbTzJ/NfLsuF9vZlxfJ51K2vEPirxE3M2pgWAf/wAIlefcU41xXEE+Zhw2dYpq
bjfHvEjZLuI4h7fZchjOPcVqPPn4qoTbWF14uPflbrCa1po4XFcQZiqrnswrmuoPaRih6NNuq4GJ
m8DeNl6twrgPCuIeFRxDiPHcP59ZhmhVqQGbaayvM+JYduD4jXw7KrarWOyteNHDZe7hs8x4+eb1
VMg89Omqhc0zBKtS2JtHVDLYH9V6NvNpULSATO6jcwmbzurhLRuFA9zZ/wBVU0hFMkWMdkkYcw3J
+QSRnTkKep5KZpgHspqeEDR6nX6I20abZmXdF6NuOON0p0hLzNlK8Es5n5q9TaxpAawTFpGqJ9Rx
FgAOtlNrMGc1rvL0KanTcAZaQeyvQSSJm6MtEyOXJNkwQNHpaLjoFBiGONSzSey1G0szbNKlFD0m
VNt9NsHI4DQ/JHr7LY8vY6ncKWjh2PALgy/NOxOOsQi/5QoB8ZK6HinC/LwJxdMBrM2WDv2WDluY
VxrGeNl0vYV0MIE/PRG8g0SBGpsocL8H+qlLSaTucrLc9KrtYjS881G6xFhyUjh6rHZCacamVqOd
KkPVsOqkqCGEKMNgyNUiC43O6BsKQKlzAC0C+mRNp01VAMuYt2ThpgX25pfJPE0fEua4GDJKjpfw
zp7oskgCydrIBghXaa87KnapdHT1I0QZeo6Qipkj4pjVKuPg1VsCTr+igaJfdWqgzQLjdCKYgafJ
WXwlx3TsaIPTkkGy0m0BIM0vI5JBmwMqKdrNeaIUxH9UhSsDN9E+Vw0M9lNrozqcagfNE1lpF/7/
ALsmiQZJEJNZAIlCQRzc+mv9yiadeRCjyGYBlGxvpi3c+6NByAyZtOpKLIInYC6EMMk5kWQtFiZ7
ImhegCxM8lGSTTJtPOUTWXMd0hTgkSSNwrPCWK+QpNb2jorPljmOyJtMFttdIIWtxnoqhpFwL90x
bHsVcbSBNhPsmNETE2EJuHSq1Bv3g3CneZa4nTQSUQoAF0bCURpAzClsWY6iiGkdxorOEOWo43tp
BRCiMusiP1SNKCSDB/JXcZmNiSqZDrmEVKAJIBjdQOYS31ak7qfDyIBg7c4KldMQ1IzAE31vZTtb
kAmT78lHUjMBe/LmpAYcNLHRWIWUDWLCyIjNMDrJ1TNjNcbxoibcAX5ohahwAv8A3ZELTqITFsfE
IJ2TAmLz7oH09Ib6o21KIAEZYnfVCAAb695unZJvsLIpzAaNj12QkxrzhE3KNT3MbJiQLwbckDPG
WYAA7KP0kZjtpZG4ZGuuLIQRJEg3RDN+Igj/AOSNmhzTPObpGJHpuiB2m4+qCF+hg2B2KGk0EkCS
RtCkqt9MuPq0AQ0/TETHJBMYyQ0SdFawIhkHTbqq1UAMMWJi/L5K3gCMhBH0WM/TrxezYwt8sGLE
6bwqFb4QNhz7rQxzj5c3BPP+7LOrvJyiSRyKzh6OT2CnLnxbsrbZAcYFoJMqrTbNQeo9PnzV1xOQ
ZjsY7LbnFJ49RPUzKmw0CJEnWBuoSIJlT4USPTI77KES1fhcRBvzVUNN5aCYurNYw3XQW/qqxs7L
dRpboSW6xuUNcy7Um0I6J9IsewQVbvHOJ5ICoFoeRMk8lO8nIcukTyUFIeo6HspnkhhvNu6ixAOo
jkJ35K5h4NLoNe6pBoGjhEXlW6Qlg36bwiwFf1ERYIaJAcZ5cpR19tYFxFkNEgVBM+2ygsatNhI5
qBupv7RsrEy2Cqu5LR2ndRVugQdI5oqsQZgEXQYcw2QTruEqkiRMDqoBFiJsFba6GAx0uqc3005i
ystiDGh+aiw7XguJmO6la9s6kdyoGHLreCpGmdvkN1FiRpJF7jadE5cSLkga9kDYcNNtEh0BRR5i
AI+QKdpJBMkbqNxLb6EfJM085J6KaNppFpd2tKa1wAI5FDKUw38M/kml2OZB6H5qOo6QdY58v7hI
EA897Xuo3nKwyQL6EXU0bG24FiISk9e6BkdkwkmATGiG0tIkQNJNoVnA1XNxLfLDSLyDoVSBnftO
6s8OI+1Cx0KlnhrG+W5hOKYcPArUntM3MSF0WF4jw7yZD6Un+dpC4xjA551jmrwp5cOf7K8PJxY5
PocfNlI2OJ8RwrgRTGHO0h5C5avUZUe9zAC0fE5hJUGONzyT8OM8Lxzl24OGRx5+e2IqOIw7qWJY
fiF6Yc3XsoqgBkn4jc85Wc2o4OdBRea4/i1XomGvTyXk3NVagaADnqgN9goDUMC9o2OiA1DzdfXo
taZ2sObzEqFwkzZROqHfcqJz5kzMqyM7WGgxofYpKsDa6SukZrS2Cb8tU5dEgNGkLJBjRE17m6F0
bwuunKZtVwcXZoJQgFxBJzW+ipMq2gl2nNSsrNI/FCjUylWw2Nb9FKXWIgayoWVJBVik5pEkiCeS
zt1k2koMc6A2nM6Dmr+G4XjcQ4wGNG8uiygovazT4pkBaOF4pUoD7upljcclzyzv07YYY/ael4bq
sYXYh5LYk5W2+ZUbaFKi/wBDA4jc33RVeJ18R8VSpUGhmSFA41Q1z3Qxg1J2XOZZfbrccZ6V/EmJ
c7BOa8gyQGgLkHP9R1KvcSxRxWILh8As0LPcJJXr45qeXzufPtdxdwRDmkKy4A0nCxVbAggFWAfQ
7b81L7aw/wAqNV+V6A1TJkdSixAl30UELpI45WypRU6JCrbRAGlPkN01E3RCrvH0T+aT8uSjyxv7
pZU1E7VJ5pTeb81HslKujtUnmqWh6hOWVVGpVjDH0kbdlLPDWN8je6OvugNaeoR1SYsq5/spJsyu
kvmzt9E3m6IGidO6IUzurqM9qkFcxcH2S8+5kSoww8rfRINMmJhNRe1SNrkXICfzzBt8wg8vWJsl
kM6JqHaj87lunbWImwUJEa6BIC8Jo7VOKro5JeeZNlCAf9wng3TUO1Siq6DIRee5vQnQqDQp22PV
NL2qU1jruETaxAMadVXcfiiIKcHVNJ2qc1jEnsi+0TeGiCqsyDGvZPcgibapo71ZbiTIi1rFN55J
kbfmoNTY+x3TGef6WTR2qwMRyiExrzMQoRBH9EjJ9+SaO1SeadYH9Fcw5GQTZ2s8lnn4balXMI6G
Ax7KWeG8L5Svs4QeikbBMSCTvCiqTnB6xcKZpAGkDkkWnbBk7a91KPwmZco2wIBHsETQQPSAIP8A
f99UQpPqlwJBTiQ0WPLVNJEj5J/wWNhz6IpjAaBEg63SaSJOnY9U5cWH+b+qL05QbyTCoTRJP4hz
TZQZ2/ona0G5JIOmyRMiDJ2UEToMNGyBwGgABFoRVHuJsBA2QtJyzYjp+SqDawxFz/REA7M0kmeY
QiHOMTa6eZvl+XJQgKpAk6GNUqZkGSUNUmCY02SoOAFw4wip3kOZFr7yrmDEUzMySqjnS02tIkFX
sFBpHdYz9OnH7DixmblnU36rNxBlzctpF4WhjRlYYFp91m1dRGhF0w9HJ7NTANSIAMz2VsODWmbm
LAqpT9NQZgYlXKZkOIsDsFqucVnzFtTyUmHdFwXO0vqoni5mTHIqSiTYi5hRYmrtmntJVQi5nX6h
WarnZBMdN1XYc0eokKKu0iSzW8azKhq/xCSdNArFAS2enuoqp+9gi0IHw/xu+R6d1PUBNMmSYCrU
Lj0uIVioPuzM9RyUWKxJkXuOQVyi30QTpaVT7yDurjIygkFRYCuQSO0JqXx20000SrGT6RB32Sog
lwgm2oQWJhn5XVYOvYH2vCtGQ30jXeVSJMkgn+igu4c+iOXVKvEDY2nohwxIbN4/RKv8WkX1lRSY
4mBEQOSnvEGbeyqMP3hEnpzVth9J5dUWHp+mLT0IRakWOqBpsSZN4vz/ALCOnHO+kqKNo2IBHNJ8
/wC9kNwTYGAn+LlItCgItMDqmZYXJKRmTm1IlIk7XjUaXQKwIgkW0TWMgkTPzTmQ2Msae6YWzAOv
ESgU7BA+19I+nVOXWNo5bqN5OkDkin2j6kIpgG47FRgyBG/9/okHXsJneFBI0kGZ1PPVWuGCcRtY
EyFQnKCC6yvcJtWqE2IYbKZemsPbRpN9cz7q3UltASd+ahw4Lqjuit12RSZzndePK+Xuxnhz3EbT
sVJg/TwDFmdXAIeKg5jFk9D0+Hq2gl+y9XF6ePmc898PIT55JsAdYhR1P4scuqAOnQCOWy6uG0oq
S0xdBnBbaP6KPUzsmBkxeDsQqmxF4MwfZCXmL8teaG8ujsEPaP8AVEGH8xfqkgYBlEAeySoxYBP9
ExbyTn4lLhmh1UZpgeoro4oSCNQAiaDuDBU7mh5Maq6MIRRPpmBvum2pioMJtLrK3Sd/mOnzVZoi
pfRTOBBBv+SzY3jlpeotDm6jsSrXD21cVjDh8NSomrlLgXnWB+aueHMN4fqYHijuP4rF0MSMPmwB
oiWuqXs76dNVgNqvwtSlVplzarYdM7rOOMt8umWdk8LOJ4jivLcA/wAoixDWwpOIYp7eFUwDIq2J
OqqcYPqL5/iAPspMcAeDYdxJs4XS4yXwTPKysme3smpjM+Ehp1Gyek0mqANV1jz1bpU/LJGtpU9O
crjpPJRim9l3ixR04JMkjtssV2xU8QNeYVeiJfBKtYjWPoqtIfeRHsFvH04Z/wCl+nhJbMi6Gthz
TbJdbVTUsPWyzJgpq2HqBhc+Y72U23rwoMbJ1TuaItrzSYYc5pUhbab6R3WnOTwrJijIuddbIXaL
TIQrGGmNVXU+F3vCl9Lh7S1rtOk6Ks4XsrTxLAAPqqz4/qpj6XNPgmeY6JHurwwVrPVDBAlxDTda
Qw9aIMyNIOilax9K+JoGi0mZnWFFgm+Y8g/NWcTSqNZNSY5zdVcFPmEN1/1Vno1/Zpjh8Eev5EKG
vhBTYXZgbqyKVeNyO+qDEUqwpuJk+6xLXS4xjOs4231SBm5uU7yJNolMAOU910cDt0vrKaNv7KIA
SmjqJ5oGF5SAgEpDpppqngC/uqFHIlICeifck/VELuudUDBo0/MJrDlrzROkc45802XrEqFhha23
dMNEZaA36dkTfivNx80TSInS1khcawnLbzN9+iLKJsbSqoTcae6u4Y+kR0uFWLSDorFEQAs1rBIS
4EWHyU7DqSSZEWUBHrEkAmNBoFYBicwvvKRumgau2MXCP/uAjSbglCGgGTp03RGJgWg2HJEOGknL
IIOoCcy4iRJgXKaSHG3JHYPcdyEULd7/AF0UcwZ1vsjYDDg245c07ZuC2xG5QO0lxGYtIOttUx+K
JjnKOBPpIH5oS0ZZE3/v3QQuM7n35oWmBMgc/wDZSOgXiTuo4MTDf0VQYuAYMi0SiNpmZ6boWnRv
STdG7Q3MNMqVYr1eVhzKCieYIupq5JYO1lHSAN8up+SgnJBbDrhaOBHosRNr7LOLh5ZziwWrwsTS
0ANj1WM/Trx+0fEsuRpHe11k1dRpGtlq8WsQINjPdZNVwygCAI7Jh6Z5PZ6dngho6K22crif91Vp
GHNsTFoOytH4SJIC1WYquAznkpMNMw4TCjqSGmApaNzz5bqCWsAWyFVmHC09z9FZqOApGwN1ATLw
BCC4wjyxGuuqiqznNoHdG0jJfSL9VHWnPe6inoXLpFjrurD4yGCRfSVXoSCToAYjSFLUkAga8tEW
IWaC7ZGitsBjSfZVKWa3pk8tJVymfTeIEEFRYhrfxCBvH+6KiRmAmeqGuYfcai101B01CIPQf0QW
3EZTIsqRJkmZdM+6tHKaZkWmwBVUH0uP0UFrDzktPdPiDa4E6GEsNBbpIgJsRIsCSZgdEVHTiYOn
ZWxZsCICq0nS82/VWJlsaReFCCZOwb3ujEbv+eiCmbm99LnUp5hpgabzCijOxudtdEhJdDY5BIBo
aZmITSZOUGdboDJ11I6pp2A2jVDpulmgHnuQbKKPcw+yEudFgANTCGdRcHW26RPpganlsgROvT6K
OqbQYPdSaaEDaVGYm5J5Ihp3g802YkxvzSkEnefzTT3vrdFEHSNY5clf4S4g1SNMvNZzbOI9Wx7r
R4RpXO1gs5+m+P228ACT72/0V7FjKxsAE69lS4ddw1gaK7jZDAGkzEzK+fl/p9LGf1c1xQ6ktv1T
Zsvh86iX2vdNxR1j+SbEHLwCleJcSCvbw+ng5/bnKhl7jv8AmmcbmAJ2unMFxt+KNU0jLc973C7v
MEnnBTHUn80+ki+g33SnS8790QJtoBO6E3EHTsnLtrwQmJ9R1P6qhhe8D3SSBt8UJIMdo+8MxyVv
hlIPr1GH+UpqGHNPHOo1W+ppggFS4dzcPxcZrNcYJ7re/OmJjqbHVw/2el64zE2HMK/jaeJwmCwz
cVh3UxiKfm0y78bOa0uLYEYjw+2vTaDWwzsr43B3VPifiB3EeDcC4fVweHpfuym+k3EtJz1WuMjN
2WuTC42GN9sRrc1YiynqMDSLDQSVDUAZiCROxCnxrpdTib7clmtRcwzKJpjzQXcoEKljmNmAbdFb
qODKIDQJ2uoaTTicfTpxImXQdgsYt5foHGpApNOopibKStDuAA6kEFVeI1vtOIxTxcAxryVyn6vD
9URoJVv0mHm1i7FFQtWahRUT981bcWvih92w79FBRN3QRorWJE0Gnfsq1OcxgWAnVYd4pYjU91Xp
iKwGndWsSLmeargRV1XTH04Zzy6PCkeSJ2GyWNAOFcTySw/8BsctJSxMHDui4jnosOn05onLUnbe
FaGVwkXVWsIcYU2HeHNg6iy6Vxx96DUFzcFRka/0Vh8GYlQOCsLEfNT4Y68lDEafPmpsNqVL6TH2
lq3adyqrokq1U0toqrtbpiua3ww/fhdM0DIeYAvK5jh1q7NNdF1TYIEnbVZz9unH6UeKAHCk8jdY
WEMV9tVv8UH+FcAsDDCK4+aY+ky9urpzkER/VQ8QthX2Cmpn7oZb2jTRVuInPhnA7brEdb6cy8jM
6Ercp7InfEdevRC2+112eb7OBOgsnm40j5ps06Gyf+50VUwF5kW5JCO/6pH4kw22KiCj/aEhcROh
TTc7I6bZJmwCC9Ta0s9Q+SLy2zaJVZpI3R06hAN7f3dc3VIaDSSG6aASgOHAa4g6pw9xcYjXn+aI
POuwvf8ANXdXURfZiLkCfoo30SCforAqxOaeRlD5wuTqDZWWpcYqutYgT8lbw0GkSSVWqOlxO2l1
awpdks26uXpnD2KoIdY3+ambybBi07hQuAzaW5qVm1s0RCka+x63P0SkNEAX0Tm7oMHudknSHWF9
NfzVQploEWv8k7JEiQAPmU85babkhMzQkafKCiieQBp0MFCCdgCEoMZi2RuAiAimTEdRvyQM0i8A
6SntlcTCb4TBiNJnZMDAMEjpCiGflgQZE2/1UJNpkwNQjcQH+qw6KMwSYIlUO0Q4b30lTaMFxG1l
GxuhJOnLRSnVoN+alWIK4PpjTT/VDRiToB+qKtIcIBlDRg6Hr7IJHEAQIMaX2Wvwx8YewJ6Qsl8Z
CWmDvIWpw6Dh5EdQuefp14vZcUA8sEc7E81kVDyIAjSFp8UdLWzLe6zKpmIvbXorh6Tk9mpGXgcu
VirjTDL6fWFSpR5jRaLdirhNiAJG8c1piKzr5gb/AE7KWiZn56fn1UL9TJkFS0SQ0kZlCJapAYGw
ZUHxOYJAEc1YrNAZcn5dNAoIHmC/JQWwfTI5bBV6plxBBB5Qp2tJZM3jmoK5BfEgBFHhpLra7WU1
a9O3w9lBhoh17k6KxU/hHmixXm4uCT0VulAaZB231VIw0ibAq3SmCdT3UIjrGXEWmNEqBuToeRKV
XTrqbpsO4ZpG2t0Fh5BaZBN4CqggkjKSDvKtVZygb81TmZ37oq9hbs1mBshxRCPDn02Nuf6KLEXM
EEchyUUNK7z9CrILQMpBt1VWhGeZU5+En+wNlBJTIkSHAInOGaxvEqGm42l1rbaKRnxXFlBICZJA
6J7b35wo5jcgap5GUgkdkUVhNyUxdaNRr1TA5jrE6pjAs7dA9rzCYtgHkE7b3gW66IWj05tBsgKA
OYkbKJ+hi/spYtYjlqoqpEm0d0AwA4wJ+iYWkW7805BiI20lIkEkzJ/NA0tJ537LU4SPuqxjUjdZ
kCZAk841WpwiRh6trFwEjdYz9OvF/p0HC6ZsZv2VrHsIBBge6DhLZDb/AN81NxYQDaDHzXzLf7vq
Yz+rkuJzldMeyDHHLwPDi0yVLxO45cgVBxMxwrDCOwX0OH0+bzzywYM2BKbKRbVvPdTtaQLwnIuT
z3Xbbz6VQ0m8XjsmDSLFvdWSExFvrKuzSplIMRY3umy8yArdheBHPkoXtt+qbTSNrXEbDoknE7tM
7wkqjO4e4nGBziS4umTum4z6cY8g8j1WhxXD/u/jzsGJDKENb1Gsqhxsf4gGfwrX/kmXjjsdP4a4
i3EYd1OqRlezy6oP0KwsdhHYbE1KLtGm0clBwCq+liPRN9R0XVYrh1TH4X7XhPvPLHrpi7gOfULt
vc6sYzc25MuzOvEjZE92aqwnQDdTVsPmJcznYBR/Zy8enRcttap31fMdaLcgrDagwPDqtVwHn1vS
ztzUVLDinUJqGKbdevRUOIYh1etnd8I+Ecgkm0yups1GfJqTyWzgr8Eri/wHZY1H+BUsNFucJvwu
s2Y9BUzb4WENtU1P+IIjVOLAIR8Y6LUcq3a98K2FBSABknUbI3OzYQXGgUdOZBCw7xXxFp3Kr1BD
xbTorWIaADob6qu6LRst4uWcbmFaPIE7CU+IafLfHLdDgzOHbf5lSV3fdOjWNystfTm6gGY6Xugo
uyvE7qSt8ZmP6qHey6xwvteN28lBUESIv2RUHZma3CTxAJ9wsxu+YrqXDan80BME/qioRmhavpjH
2mqXYVWOqsvMAzKrON+imK5LXDiBWaTrMhdTTLQ0AHl7LksG7LVHddTTAdRA91nJ04vSLin/AEr9
NFz1H/qNRA5roMeCcK+xsL9Fz7f4s/qmPoz9uopuhkbW2UWPl1B8jpZFSBNNl/VGvJBjDGHfyhZj
f05oggmR9E3siqEl5JMnmmB1XVwMJmYKeZiAlNoSza6oFbr8kzelwnm8ymEReOvVEICSRZTU6bm6
ghRgw+dTOy0Kb2uZexjmpbprGbQE8/ohBkkR9FaPlmTIEWTAU8pnmsbb61GS3yzpfnyQh0NgH2gK
x5dPQ6aKM06YNjdF1UdoE87lBUNoESDCsCi3UOMCyEUQQYf3VhZVMgbR7q/g3fdxaRa6r1aUEnNc
dFNhQIu7QK30zjNUVS5INwpWNdG/JRVdNLypGGG/CYAnqQk9LRj4oEz2RMsSWuiPyQMIjXuZRg2B
PWVQ7AJh0QOadrGAOvLkxblBk+yFs9TB5oDEgEtJg3nbunaHF1jYCCmp+8HmVI2wkATqoGcYADss
aWugdBOmnTT+7I/xSQR0KZr9zIDtJ2QRZYdpbTW6iNyY7219lM50kkSByKizfENSdCP76pAgY79e
SkMiCRbQc1Fm9Ab76onnMGCQlICtmAJulQdc9U1XXWNwRZNQNnX79UE75yaR9FoYB33N/dZ9U+kH
W0K/gzOHg3C55+nXi9lxAmGxBIKzagsN9Vf4gfSBLQe1ws8jM2Z9hsrh6Tk9hpgB4EiO6uR92Zty
VMSHRKsNIggRcSqxEbg71chtZS0AHXMnuoXOvcwZnkpKPqbDh7lCJqzjHOFBJzDWIt/eylqixgxv
CiJ+83sIlRVsTlMkxCrVgM7tD/VWGnK0321Vd8yYnLKKPCAAmdFYqkZYBPVVsPmB9MzOnVT5vR6j
M7nZCIA0hrYgX2V2gJaSDJ67KncOGfsrlOWsmeiixXqWc4RNpSoH1aiDrdPUPrOs8k1AEEgkRogt
OALSSdRsVQiHdVec4BhNuWiqFhEmbbAILdC7BBgRImyjxLfVffkjoDK2LRp7qPF329pUU1GA/qrD
x93adVVoOg2BMqxmg2KgTQDzOkyioNNav5YMWlALtBAiTAEpmy2s3K6HXuEIsvYaVYsJkx80IcQQ
Qe0KPzC57szpJtJRNPMQ5RRg6DnYpCZdEymAO97c0+a50zEygL1EElCW2g69EweTqB804NiCAOaB
nSZnSyiq/FEzfRSElrdN9eSgqGX+17oCmJ19wkyw2ugFyNz0TyBMa8uSKMi8tuDotbhMDCkHd0LH
ESfzK2OF/wDSDq7Rc+T/AC6cX+nWcGpn0232T8atnH6KXgTBNPsofEDpe+99uy+Xv+768n9HLcVE
saY+ip8WMYPDt3yixV7iX8Nv9yqHGSPIoDYNC+jwenzPyJ5Ztzck8pT3Iv8ARLYyPYiEjcTeF2ec
xMATysAhMkduSIzJBBnlomF5g257KoAjUEjsoX6GB/VTnQ7lQVZLeU2ud0iIJ5eX/wC7VJCJi2b2
KS0y0vGwafEjKtJwcHsbmI5rE47PmUif5VpuNWrQBxAZRoSLuHqPKBqs7jrWjyS0EWMyVre8jKf0
qhhnmmczdea2eF8cxGBxNOrTdly8hKw6RspWtLjAGq2443Udt4iFHiHDW8V4fSbTqNtiqbNL6PA5
LBw9Q1crabTmdJCbgXEn4Cu9jhno1GljmbEHZadLBllFzMIxznVPS1wEkA7LN8u08+WBj64c7ymf
w26mNSs+pr0VuvRNKq9h1aSLhVao5dlqOWfk9I+gjmF0PAhmwNUQPhN4XPUSYN9l0/hl1MUKznMB
LWGznQCVjk9Ov4/mub0HZBPqHRHUIzvgRf8AVRH4r6dFuOWTQp4hxaGbKald4DSddJVKjr0V2nZw
Bj5rFdcKHE/A7Tuq9yAR7QrGKPpcd1WYQW3N9lcfTOXtYp4p7G5QAGjZH9ueWkGNFXIhszcaKOTv
cK6Z3QVzJJ5qBw1vdT1InUAqE9luOdHQdld0UzpMkKqNdfdWWOlsqVcb9IXiCeaLDn1SlVG4CWG1
MGE+knipn/CQqrtAeit1Pgm+l1VNv6pi1kkwxLak+61mY+qBlgGFkUD6gNu6tM0J/JKuF1Fqpiql
RrmOIgqiDFUwB2UpFwD2uoNaoCki2r7MfUygWy9kz8fVc0hxCrtvO99CmvaeiaNoX3JTNsDsjfqT
qdwgBm11pg5Tc/qkPb2TgfRAp7/NM3pCeNACQlsP6IEAZ/JXMNTdUZOwHzVRoLjHNXmSGiBFlnL0
1hBikQb6c4TCkRPpvOidpqDb5ps7zcCOyw66LI8SQLGJCAB0/Dfmnz1Z2sUxc+d55bwqCDCBDm25
HZDBymJieSIOcSCYm/aUxfYgabKCCs6XazeFZwhJaBcjTsqlUnMbzdWcGSQQ4X5rd9MY3yVVpAJb
funplxk9Bqmrkgkm6TKh020tdTbWpsTS4fPcIvMeYOW+1tUAM3HbmnD7yb9k2uokzPuJvzRfeXtP
96KMPuR6QD9EQe6CIPNTdNDzVbwNEmuqG0dP6pg9+4sT2TZ3AmAb67Js0IvqEzAjadUxFUbQSN03
mVDPPrunD3ECxjdNmoHPUImZEJiKhaBm1T+Y4CACegGyBz3hpGv5FWVNQIDi4NGusBXalEim1zTp
qs8OcHEided1o1y8YdhzG+l0tSKlRlQmelrpmTGmmkIHVHE3FuqJn4rmdURM4jLOu5ELSwgJw949
1lueck3toIWrw+fKHtusZ+nXi81DxOAADzOoVFu/8wGkbK/xGwblE20N5WcSCR6RbkmHo5PZEwTE
xaZVhkZds0WMKuxwET9Tup2kZXRAPVaczOba/wA5T04a2RPVBngkctlJTcTMwSixMxrnmTBHXZQ1
WZH2sCUbqmQk2/RQl5Lj+ZRU7dALgb9OqPKxrdJJKDODBAAkQVFnh5vfrdBOwCbH9fcooI1+HnKi
pvzOBJFhbojdUJP0gBRRu06qV0hreoVem8Bthfqpn1MzBJl3NQFTaCJjVC0ZahtIQmrlgb8glTdm
eeXWyCdwBI57BRVGtDSBYg2ITvOUEgqE1c0wddiirFKcvpttHJR1BlkQIGpUlJ4I1DR0UNV8G9yE
AUpzGJvsrDQYdER0UFN0u1EcpVh1QAGBr9FCAqNIygAEackVFpdVLrQBqoy9xOsGdNuifDOcXu9W
yiwzi4PcBsl6txbmVG57s07g7nqk17pEE62MoJQ515ImEXrOaD0sosxLY+nVFJg/3KijaXiTASBf
eeuyAEztfkNE+d0WMGLHmgXr29kBc6TpHySLzItb8kOb1GYMmbIgyTBN46Jp0BGhQtOWZFkQcZOy
KMOERM+y2+FCcKwQJzclhjfftaV0XBac4eiLayuXLdYu3BN5Ow4SAHU9LNmFQ45PmuMT0WhgyG1J
PJZ3GDLiLXhfJl/u+xZ/Vz3EwMrLfRZnGb+WBEADULY4m2WMhY+O9TmTytbovo8F8Pnc+PlRAtI+
oTQcpsB0CeRBJ5JnRe4HZel4zbEn5phIaetkhpfTl/omOh0kqoF0x7xKhraCD2spjuCbRCgrmW+6
Rmq0XMj25JJrRo33kJLbLQ8WtZQxOCpUxDW08zjuSTrKzON+Q5lA0C6IvmM3XRUn1qeHbV4nSDmC
AXeTmLRI32WT4n+xveauCEMdUJYRpl7KYeNN5+ZXPU97Kapo0tHyUTRDosrOEpea8ZrNFyYXV5cZ
9LGHYA3zKlyRAC6vgOMqYWo7EsEik1rrbHYrlHuz1YFgLDkAuh4WJeabiIfTgrFuvL0YT6aHi3BU
+N0KnHeG0W0zb7XQZ+F38wHIrz+tvEruOB8Sq8Jx72D1gCHM2e3cLK8Z8Jo4aszHcNObh+JOZv8A
+m7dpXosmc7YuGUs8VzdA3jZdJ4XrYak2sMVRFSWmMxXO0WHNst3gFFlR785tGi8/J6dvx97YtUg
1XZYy5jCgdrop67clV7RoHEKJwv1WsXLNPRMHVXmCCBN5VCjrI2V5oAcM30UydOMOJ+FwVWmRuJ9
tVcrN17KlEHWAmPpM/aRzj5duUXUdNxymSYTzsfolli1pWowCodzChMyZurD2GBoonN3WozZUY72
Klou1BQRb+idtjbZGYleJBtCChZx7KZoBFj7JqbIPUqN68jf8JsqjtVde2WHTuqz23m0d0xXOBpH
1Kd7yGiJEXlRUx6vzUwEgmQiT0JryWROijIy1JkgFSNEDWELmy4aeyQ1R3LCGH3CWY+X8RjunbYG
YQuBggG5UVG8nMbBMJiRr0RG5PKEg2efzWk0EEgdtbpSZ5HZPHZOG9RHVDRgJ905G43RBvb5ooGp
IhNmqHDx5oJ0m612ZGiBfrzWQGQ7W8q1RzEerlz0WMnTDwvZ2wRFzcDonY+nNwCDYEKuGSDcTy/v
smcxw0IjUXWXVae6kJInSygzNk+nQzKjDCG3cNNEIY4AXEjW+qIsOykWAubKM0gT1TtaRe0dP6JG
RItbRDSlXAkwDdS4Q2JJIOiHENl8ySnoU4FoJ6rW/DnJ5KqZi5iVIxsZZieaWQzOvZPlJHpBtfup
tuQickAN0uEgWgwfZLyiSBv2TeWYNjpzUD2k3APPZSBwEzYbADVAKROljt1RlgPMRyQ8izfDBi1k
EgRckTon8pw0TeS4g9baICDvQSAfbdO1xI0nqU3lu9VtYlPkcAfTPTRF0AvgOB1mO6iqOJbN4Fuy
mdTcQQZ05KPynZYIuN4VjNlRU5ce2kLRxgy4SkQI59FSbSIJJDhyWjiG5qFKRcjYqWkl0yXAz12t
sjY/YADlZSvo29IvCAUCTbTtdaZ607nS0ETl1utvh4AwonTrZZgoOyjmOi1sCw/Z4IG22q58np34
Z5VeKEBgEz1O46rNHqBv7StTiVMuY0Tra4WcKZ6f6K4emeSf2Q3mYvKlZUgQZzTz0T+XN2zB6qRl
ECZOh5LTnIryASQbI2VADc6bgKR2HcSbJeQQfe9o5ouqCoS8TeBso/h6iNeYVjy47hN5WYREdkNE
yrA2LotKA3edzFx0U9PDnWxPZEaBmbx1CLqoKL4Jg21tsjc8/haO+ykbQIJsZ58kQpmCbfJQ1Vam
4tIIBvpCnpVWx6tdE7qTpPMk7JxQ1JHyTRJUWY1CXHXTRFTqQbjKRaVL5MWul5Djtc89v7hF1QPq
ZwRGvRQ2BEk2m3NWRSMXlMaJJG31UNULKga3UTpChcS6+x0/qpPKdI+aRpm8jbZDQsOS5+WJvcyp
iRnIBsFFSpua6wMC11K4GfZRZAPIBiMxPP8ANFg3S956XQeU47QeWxR4RpD6lvmoaqI3zTMzyTtM
WBMpZHSbWG2qdrDBsffdF0JlhBnkiaZbAnZLy3Tp9NUsjuVt7KLotRpt9OSEOkCTBReW4C4MaJhT
cQ4E6/JNmgOI0E3vYIdHCBfrspBTN+f0T+WeQ7QhoAN/T+eiUg/380QYRY79EnNmYG+yGhUiMwBB
IJGgiV3eFwuGLqR4aXOpFo9D7Oaf1XI8K4ecTVzOltFupi5XXYahUoNaCMzYs5tzC835GWsdR6/x
MN5brbo4au31GjVAIkegrI4oIquD7XuHWK3eG8cx3DzOE4hVokfhdDh8in434p4pxMBuMqYLEAc8
O0H5hfLxt2+rca4fiBltz9dVkYwzUF/VG1zouhxz3PcS6hh5P8rIWHUkFxZlBOtphe/irxcuLIBt
J/qmEW6bIwCQTYyUg3lMddV7XzNB3H1TE2Jt/VHlt+hQ5SZMomgmDI9lXxF22BurMG86blV67bRH
XVWJYrAA/ihJOAYsAfZJaYLGcZx+JomlWxD/ACnXLQIBSwzRUwd2hwa/fda/jjxBX8RU+CVsVRw1
J2HwYoDyaeTNB1PVZmBAGBef/wBQCfZSXxtvGf20r1qVOm0nyxIsBzUQaadLIPiNzGyuOZnrAO+F
t780mUCSXu+R5LcvhLju+FSlScTIB5ytnC52Opuv6WjfRR06TAA23WytsYAGnm3RYuTeOGgYmg51
ZmIa3Q3urOFqscytg8TBwmIu0H8LuYXVfsq/d7/2ieH6HGaFLEYCvXdRfTrCWEuY4NJG/qhQ/tS8
Ns8NeNOKcMwoLcNTq+Zh2/y03eoD2mPZMOW41MsJXDOwbGOcMjS5pINrhR8AJFZ41E6LQe2SHg2e
L91m8EMY941vsrl6rWHixbq4Wkar5pCZNoSp4OidaQI3MK1VaPOcL68lI2I0vyhc+1dukVhgqP4a
Tbcx9VL9mpW9AFtwpgYFgOSINqEA7/mp2qzGIRhaZ/AD/RL7HhbzTaOisZXN1CYDMSpunWKpwVDQ
MEco6om4CjMGk2FbFN02gkHmiaCLC8c1e1JhFX930Lg0280v3fh4H3QmPqrjc5cSAZR5SBLuUKd6
vXH9M9uAw3/pNibyEQ4dh7/dsnlF1fbTkHKI9lIymCdLi1vqp3p0x/Sizh2H0FJo9rwi/dmHcRFM
NOwWiAC3S21kVMCQTy1i6nerMMVIcLw+T4GTvul+6sPJiiwk8gtRtIHYTp1RCkATEiDss/JWumP6
ZTOEYaf4LYO0KVvB8MRPktE300Wo1sAAC0ckTRNtRzU+TJZx4/pns4RhGkE0W/JS/unBET5LRrst
GnTbeAJ5qRoYNMveVn5Mmpx4/pmDhOAIBNFgI6aJv3RgYMUm8zbRbDBTMWHuiADhZrY5qfJkvx4f
pjN4Ngy700GdBClp8FwboHkMnotcMJvkEp6YvoLqfJks48P0yjwDBEf9OznKJnAsEP8AsMjda4mD
bqnaxxZME9FPky/a/Hh+mWOB8PsPJZOnwo3cFwAEtwrPfZaBbBFkhpaDOk7p8mX7Tpj+mb+5OHkx
9mZ8kQ4NghMUqYI6arRymSbI20nEbfNT5Mv21OPH9Mv904IaU2TtZO3g+Dv/AIdn9FpCkeWqNlIi
TbSFPky/azDH9Mr9y4XajTjsmPCMIP8AsMJ7LVFN0lE2mROsdlO+X7Xpj+mO3hWFkzSYBPLZGeEY
ST9yzlotRrJAH1TPa7MQDYW6J3y/Z0x/TJdwfBGwosnskzg2F9QbQZYctVrNpEidTCYU3STDv6J8
mX7OmP6ZY4ThwZFKmBppqphwvCAGaDAQO60chAMg/mnbTu45T6U+TL9rMMf0y/3Xhp/gM+SP90YS
YNBgOq0G8xIukMsXknqnyZL0x/Sh+6MIGx5FO2phE3g2DI9VKmPZX2CSYDrcwlEbGeyd8v2TDH9M
39zYNutNkDol+6MLeKbNpELSAJEBpnsnbTfMBpk7J3y/azDD9M390UBfymEc4+qAcMoEiKDSZ5Lb
8qo2ZY7qYQupv0DSfZJyZNfHj+mK3hWGgzTZ8h8kbeFYW5FJhGsALVFJ8GGfROGuAPoW5nf2z0x/
Sg3hOE/FRYdrhTN4Pg3NAFBgHUK6A8z6DyThrvxMIlbxyrNxx/So3g2D3oU+8KWlwXAlwH2enccl
dpMBtlIMyrIY9oksMLvjWOmKrS4HhItQpW6KxT8P4fKYo0o7K3RcQAS0kR81doVSPwFd8ZjfbFmv
TNb4cwj/AI8PR+WimZ4VwEf9NQ+S2aNZkDNQlWGPonWgfmu2PWOVm/pgjwxw9uuFof8AxUjPDnDQ
b4WiRv6V0FMUHf8Aad/8lL5FAg+mOd1rwmp+nO/8P8LP/wBtQHXKhPhvhrjBoUOvp1XSjDUoPwhA
/C0hckDndTwSRzw8J8MdM0KN/wDKi/4U4Y24w1A/+3RdB5NIfi+qdopj8QhNxdRiUPD/AA1kA4Oj
PRisHw1w1zTlw1G3+Ra7X0R+P2lEK2H2cPmm4mnP/wDDmBD74SjH/hupG+GeGHXC0bf5FvefQ1Dg
pGV6QPxNPyVnX9mv+MKl4a4WCCcNSPP0BXf3BwrKA3BUT/7Fq08QyBGUqX7SQDFJalx/bGr+mK3w
9w7/APs6P/wCL/h7h5FsHQJH+QLW+2OJJ8oqJ+Nyg5mFvUqbx/a6v6Zf/DWBJj7LQ/8AgE//AA1w
4C+FoX5NFlofvBpGyhfjad07YrMKzqvhzhbbjD0J/wDAKtU4Fw0ExhaAj/ItcYqm6fu3FOa9I/8A
ZPJZuUWY/uMI8F4c03wtD/4C6rVeCcOJvhaU/wDiF0Tn0r+iO6rVBSdoFyyyjrjjP05x/AcDFsKz
nZqp1OA4Fs5aFOey6ZzmNF9OqiqOpEXhebPKO2OMcq7gmE2w1OOyhfwbCMdbCst0XWeXSJtHy0TH
DN1BEdl5ss3WYY/pyH7pww0wzfkgPCsPecK2YuYXVPw7RoCfZV3UWgiQZ2XK51uYYuXdwzDnTDAX
5IP3XQg/4ZlrkQundhgRNtPmnwnCauLccjSIueQUx75XWJZx4zdcl+7aMmMOyOyR4ZSMxQZ8tl39
Dwy46iVqYXwsXagAdV6sPxuS+682X5HFPUeWjhFNwI8ln/x0T/uSiJLqTQe2q9axPA8Hg6BLyHPF
oXN4gYcV82SWjRsapy4Thm7WcOScnqOQdwOpTw5qNpinRNgNJWjwbhVatWAiQFvVGVuI1WhzS2k3
4Wiy73wr4fbDXFguvlZ82WbvrHjm2DgfDGeiHVKLKk6h7Vi+JPC+HY0luCp0zzaIXvGE4S1tIDKN
Fmcc4JTq0XS3ZZ+PPGdnnx/Lxyy6vlXinB20nuAa8f8AuK5jGYUU6mdgMTK9v8XcEFBzyG7leZ8T
wAAcYsei9X4/P+3Xk4+03GHhKFKlXFOoxuSr6mEjQ7hXzgWTPlNQ08O2tQfRf8TTLDyUdDH1MOfL
xQJy2DhqvbyS5f2wceDLHH+mcSnAM3pCOyjPD2XHltncq1Tx1J/wuudlL57bz2hcO2cemY8dZbsC
yYDG+ygqYBpkCmzstHEYqnTBLnR0WfU4o0k+Ux7xGwW8bnWMvinigbw9sfA0hJN9uxJu3D1CP/FJ
b/u5f/F+nD1K/mYXD0jM0pE9CrNB5GAIkhxqhUIvG36q4yRhBA/7k6dF7tPk43y16jQzCskXdc7K
Om9gpwAS6LKWzsMwuJgi0XQYfDVKpgDIw/VZ1JPLe7vwLC0g5wDrkbBb+FbgjTy16JAAuQ5Dw3AM
ZqJJ5rUdw/PTIB9lwz5JvTthhfY8FwKnUqUMZwfHOp4ig9tWnnvDmmRdN4xx/iLF+IX8b4rQbVxG
UMzU2ZmZQI0VLDtxvDHl1LM+nIlsrcwHieBkxVJwkXBErG7LueW9SzV8OHwTDiBiA7UAuEWgrE4X
bijxO69a4hR4XX4bi+I4Wmxj2U3AltpK8l4cf+bHabwfzXfG9sbXKzrnIt4iuRiH3tOyBmIdEZrQ
gxAmvUItc3HdIU80yYJ1stSTTOWV2lbiocYqEc1LTxbwPTVLeSqHK0w2B1TtGaNwmonbJcdi6hBP
mOPKEmYl7pl59uaqtZIOw3jQog0bnrPJNQ3kuDEuy3qSVI2uST63QDNiqbWyexRxIuRO6movbJZF
d+uZzY+YTtrVGiS5wnmbKFrXRr7omsdBkm3RNQ3klbVfI9TgI3OqdtVwdOZxm2sSowwm2gNpRCk4
2Ec4TwbyTioST63SeqNlRwEh7ri5nVQim4OkmdtN1MwEmxh2xCnhqWpGveBZ7heJTte95PrfG91F
l0E3i/VTMsQDop4XdGCbzVdm5SmaHEWe75p22B6wJUlNxzRop4PJ6VQtBBqO+eyRcSP4j+wOifJO
5R02hoI94U8L5JgAsarp76Jy/KTFVxPeyJoEgi5F7pmsGUyJUXyWd5B+9qC3NM0kvtVeT0JUoYZ1
Mm0I2ggmBG6eDyjBOX+JUEXmUTKjwI8542+JO4GCAJCJlJxHqsD+ang8lmc8/wAapGvxImBs3rVA
JG6lY1o39oRNLZB57qeGptG6G/8AdqT3QB+wq1Y7lTkN0gzpKWUQYB7qeF8omzM+bUnuih1stWp/
8kQY7kLcwnDHAugd08G6Zpc0XqVJ76IvvNqj+wKQztF7dU/e3SEPIA93qy1Hk90LqjxP3j5nmpms
MRvomgAGf91fB5Rtru2qPjupWVqmvmv5xKBtOd7QpMkA7mE8LLf2X2h4H8R/KCU/2qpcea4A9UFp
2mdUrEEQDbkmova/s4xD9qh56omYqpqKjuxKiuI5dk9oNo37J1idsv2nGPrAgeYnbjq21U7WVYAu
kkDungxOgiFeuP6O2X7XG8TrA5BVuAkOI1nH+MZHJVHCW3Hv0TBgmStTHH9HfL9tBnEcRN6rrao/
3niT/wBwrOZTgQNtxujYwiC2VemP6O+f7aAx1cyDVdHRH9qqEn7x08iqIbvqT9UYBAIH5KzDE7Zf
tbGKqDV7p7qRmILic1V1+qpwdtETabpvzutzCM3PJdFWCCKj7dVPTruLTNV6pUs7TIcQJ5Kduazi
SV1xwjFzqb7Q5t/MfZOMS4aPeUDLkgypRoRpuu048XO55LNDGG2Z9S191cZWzAfeP+ZVClUcJJH+
iuMe6FqceLPyZLNJzTP3tQbalTGMtqz9OZVAZp3Cla902sr8eP6T5Mv2kfUcB/Ff81D5j3Onzql+
qmFUkeoBMXBx3B2snx4rOTL9kyqQPVVfGmqmFV0El7yiweHq4p0UKZcRsAtdnAXtaHYmsynOwuVL
hjD5Mv2wX1Tu5wv1QtrDm6V0TcJw+kdHVHDdxRU6WGDpd9mot/zkLz8mfFh/p0wnJl6YNP1Cwefm
rLKVQxlZV02BXT4erwmnTHmY+m48qbQU7+McIoiGuxVT/wAQAvPfzuCOs4uWucbQrNMxW+RTuqua
CDUqA7AkrQxXinhVIEGni4jdzbrHfVHEq5x3D6jnYaMrmuu5p6hJ+dw31D4OT7p3Yh7TDar/AJqJ
+KquGUveR1KqYvidPA16fmw5mb1QNuSvU/FHBakCrSLCebV6Pn4fTHXkKnVdEBzuxRFzo+NwU1LG
8HxZ+4rtE/5oVh2DY9pNKrbqt43jy9M25xnGvVA/iP02UQxVXeq+/NaFTh2IDZaA5vQys6rSc0nM
I6RotdME75FVxAIBfWf89FSq4hwMsrPjupiwkGRIVZ9FokZTJ3WLhi3M8ld+KquIy1XnomNZ2X1V
HIn0BJkEfooyxwtrHRYvHi1M8v2JuIe2D5ro5qWpjqr6eXzCBzCgDSfbUcld4Pw6pxLFigw5WgZn
O/lC5Xixv06TkynuqdPFV7sa5ziT3WjwHg+M4riz5tZzaYN4Uni11HgVBmFwrYqVB6nnVXfBHFqd
FjM0BY6ceOXWtTLO47jaxXC6OApVGsaXGmwuJNyYWb4L4rSxWCrF5HmF5zCV0nEnsxGapTIc14hw
XluJ4dj/AA/xOpicEHVMK4yWDa63yck4vMnhOPG8mNmVerU8XTZysgxPFgxha0x7rhuHeIKOMaB5
gZUOrHG60ZdV1dbmuOX5014an4vnykx2Kfi3EZrSocPhhnu0kqejhC1wc3TktnCU2hwIaAvk8/Ne
SvZhjMJqLfA+EGo4PczrdejcGwjaLAMoBXNcJqFouBZdJhsVDdYXLi1LuvH+TcspqN5kBqr41jX0
iqrcXbVQ4nFgMN178+fG4ddPm4cWUycD42wAfTcQJXjnF8IWPcNF7hx7FNe1wJC8049h6bnktsTs
vmzPWXh9/h311XmVeiWPJFiCqGLph93AZgJhdVxbCZHkgDS65+vTI67d19Hi5fDlyccY5pm8Ag9E
DqlVkgPOnOVououykjcqpVpOixNtxuvRjnt5rhYpgMzeZWJcdfVcBTtxbh8DgI5DRKnQc9xBBPNV
q9N1F0P30nZdsbMvFccpcfMW2458fxfmkqYg6zP/AIykt9cWO+Tlm4luYeTh2DaXeoq3iK9WpgAy
s74KggAARZYlGqQ4Hf8AJaeHJqYbGAGXgNqCByN/zXfTyY5biTD451CGvpiowdVrYPj+EaB5lOoN
NpXMPeTvvqgY+9zdTLCVceTTvKXiXAtBtUNv5Vbo+J8O4w1lQ9xqvPqbheSCrtB5aQc1tNNVxvDi
748uT0bDcTbiQABbqrXFcRQwvDatQsb5kQ2264bA8S8hoL3BghNX4ycbWBc4+WzQcyuc4fP/AB2+
Xxr7beIxIpcCp8Pabv8AXVvz2XJUGinxgtaBFoEq/wDaA4y54JO5KoUIdxwR0Mrr9Vi63F7E4R4c
94Ga8wAqZBLheDEXXYYHDZn+ZVB8lp337LB4xg3UMdU9Ba2p62tGyuN2cnHrzGZeTF+aJupzSed1
IxjWjToCnAEnYHrqtOWjtPP5bIwTJO56ap2NBkEaXBTtALiSIj3KiiZMAg/6BSaAH9LoKdjrdSOI
EEXA25KKIPEbyfopWOuq7HNknUFStuOX6osT2GpHtoEmvGYgmFCCYMwHDknaQHa/SVFTsIzRsdET
QAYbMd1FTFpIN+llJS9MTM7mbhQSiTfbZSC4FjJ1lBSeNwR+qka6fVqNhz5qNHDDbSI0KOmINtdP
ZIH02AP1R0yBDrydyoQ+UCTpz7omw4G3ZO24mBY7pNOsgztdRSIA9N+U9FI0CNCmMC4Fh7qRgGWD
HYBRTAul2nzupWCREf1QNaBo/QalSMkaAk6SosEabg1wZKTMO985jY3KIGpAECEdOoWzmGnVZ2oW
4YWn3ui+ztMxJlP5hdEAC+oKJlSHCRbnKbp4CcPE/OZQhhzH9VaD23i6Zr2nNI7W1U3VBShggif1
UksyzIKZj2P0iyFwzOIJt2QDnYbgSRsmIMwBHNG5rWkwPkhNQaA2QDljp2TtAg3kKJ1yBmk7iEVM
mD6Y7KgxSAbY/VMRAO5CIC5zSDsjaw7aa2RVfeCCnAzOkmykdJBEWQtiT+Q2V2hG2mndNlEjb3RH
e2n9yk0jNFusps0bQHYCISZBFwi3hw6p8w0DYWpTQMogQdDvuibunkWtbmia2ZiFZQOYxoPlqjYO
iDR1xboFIwGOS1EGBAmBb805vItZEwDKATINuyJzBnImy1DRM0k/RSMF7WlM2mdLxOhVhrSxuYxP
NalNBAEgEfJTEgmBKGnBc2QjgF5P1XXGudgmCeR/VTtGoOk7KFrJJ3Cssp9b9V1mTncRtHIdt1Zp
UyRNh3TU25bATGnRTsBg2K3M2epgxwFoQhzmvNr80UOF5seRTsZ6iS7W/ZO6zA4BMyUOJLqVB9Sm
w1HgEho3PJSgQNfaVWxHFafB8Tg6+Kbmw7n+W86wCNVnLLUWYo+GeNuKYBvlu8P1QyPUWkytvhni
6hxrEjA1sJWweLqD0CqIDiOq6rAvwFagyrS8t9N4kOBkFVfEBZRwzcRhcJRrVaRzC1+4Xi5py44X
LC7dOO4XLVjiuMYutSe6mXhsWMLmsRWqVHOyOc7qVPxGpXxrnVcrnS4yOV1u+GfCtbHB1TE1Dh6e
7niZXwrlfeXt9Ka+nIudXaDeCBoCreCFR5mrUqC2mbdep4LwbwIQcTia1V3QZQtvDcI4DgaRZQwN
N+YXNS5U7bZ7aeIYzDalpLhG5uoKeJxWEoh9EupuAuWmJ7r2urwbw9ihldgKA/8AAx+S5nxn4e4L
wzguKxlFtRhptzBueQTyW8b9Ja8zo8Q86tOLe7M4Wzj8lPXbRLM0a3EWW0zxzwnHcKwuAx2Aw1Uu
IY3Owegc5XbUfA3hHimEacFiKtCoR8VGtInsZC63HXtju8dqOY1/pJstLhnGcXgHTRxJDR+FxmV2
nEv2P40y7hXGMPiBs3EU8p+Y/ouU4r+zvxRw/ManCamIZvUwrxUHeLFbxuvVZ3HW+HvGVHGVG0MW
0UahsHs0JXYV+C4vEU8/2UuBEhwsvn+ua/DK0YhlbDVQQYrMLCPmvYfAvGuJcT4E+ti61Uta7LTe
TGYDl/Vevj5eXLxK55Y4zyj4jw2vg/49F7GncrLBa4636rf4nVqVAW1Huc2dC6VhVKcVDe3JenHL
L1lSSAqQBEiJVc02681ZyZjBBJnTdJ9MCZIBW9mlOo0XFlv+BsVRpYnG4ZxArOph7eoBusCuQNSO
i5zivEa/D+K4bF4V2WpT5bjkVm59PKde3h3H7ROHvxjWY3DgugQQFx3BccMLWLaxImy7HhHHqPFs
KCwhtUj10Xfp0WTxjgNPFZqmE+7q/wAq8X5FmX9sa9PFjcZqtjCY2oymKlB+emRotVtejjKXq9JK
8yp18dwqpkfnA5EWWnw/xA/zvvAMpMFeacueM1fMdeuNu23xfw3QxJc9gLHbPprMo4XjXDSThqgx
FMaNNyt/BcSY90tqQOTl0GEw+FxY9Tg153C8meX6dZde3KYHxUKBDOK8Pq0yLZmD9F13B+LcExwA
o8SpU3kxkrekq8zgFR7PR5VdkaPAKiqeEOHVR/ieGOpkn4qJj6Lkzlng6fB4KoGh1B1Oq3YsdKvt
oYkC9N/yXFYXwVhKZB4fxTFYN2wMiPlC6DA8N8S4GmG4XjLMS0aCo7N+YW8ZP08nJf1lP/226biw
Q6QQqPEcScjgDdC7GeKKLfvcFh6/Zo/QrJ4hx3jTGONXw9Tf2zD9CrlrTPHLb9f/APWPxGsXF/q+
a5Hij5JklbXEvE2IBPm+FyP/AHkfouZ4h4mpkOnw9Ub2qf6LlMX0Mdz6ZmOIebwLQsGtQzOeeZWh
jPEbDmjgrhf+dZdbj1dzj5XCg2+5JXq45l9M5WIvspcYjsYTvwbGMJeQCVBV4lxWqIZhG0x0aqFS
jxGuT9pq5B3Xoxl+64ZWT1F6kMNhw6pVqNAGgWVjZxtR1QMLKTbNBtKsUcHRpOzVHGpU+iKsHPgW
a0aNAXpxyxxnh58scr7ZbcOALAkd0lpDDF1zTMpLXas9Y8qLRTxL2C4Di0fNbfBKQDK9R/wEZD1B
WZxCiyi6iWl2ZwJdPOdVabVaMEWsDvMDgZG4Xuvp8zDxbsDsAcxbnEg8oUf2A/za9FY4y7O+jiqJ
LW1mw4fyvGqqUauIgQ63dPLU6260nZgjPxON1PTwsRdx2mUFN+Ii5arLPPcZL2grFtdsccfqCZh2
/iYCNb8lcw/DzUPpp9Oyio0qhjNVsOi2MBhA4xUe6NxmhcsstR3wwl+h4fgNLLmxmIw9Fo2nM4+w
V2nwvBUnzhaNSq7/ANWo3KPYLX4bR4dhWl+JxFGlHIZnFQ8T4zg2gswNOo7/AD1DA9gvP3yyunom
GOJ6NPy4dWcC5mgOg6LB8R12130zI3ghQ4jiZqvMOLzPsFRqvc5xdUkum0L04SuHJnL4RRIsJ2td
IMb8MgRG6RqaBunOUmubGkkcltw8DaABbSLpNySSdhMG6ACTcfVTsaG6jte5UCa0PMNiAb2TxmBi
IGgRNgjuI1TsbaDYoFTDWhwJgiNRZStGWb9LJoBgkCCBujgDTRTayEGAugQiLcu0+6Y/ETo7qjaP
SSDP9VFO3WYt2U7ADqJCgaTmMT36KcVGgCZP0KjUMac6clMxgMAHTmYUbSMmo0QebqDJIUFsMAJv
oiblBcNSOarU3kEZpmFPnafUW35bqLEkzIEzspKcRoCdlVa4l7QBaFYaXgRIRYkDWgxm05fmjb6v
hAhDTYPxESeqmyhoABBB1hZUIEag6fJSNPKJN0E+q5PQxCPzGNHpBLoUEwY6L+6LKxsl5Kg8yo93
pbZI06jngOc0TqopF4DoESikOAUDqOX8YITZKgJg9VdIvsAIEkR3UhaMl7CNVRpnJZ1UC6ncSxkt
qNN9AFnSiMtEU2kk8kbKVXL6ru3jRQUq7pkFo7q3TdVc34gQb/6osROpOJOk6kpDDczcIqpeJHT6
JmOdyJQEzDtF5PchE9kMMaJNcS20jlKB4Ma27qKcxAkQTyQiQdgO6eLXlMbgiZ5qhoJ3EIcpntr0
TxA3TOIk8+6AYg3+iLL6Z0/VMal4g/0QNdIESqJHG9r2CQIn5IRobiO6JgvqCVqAg2ZiPZPmgQhF
nX03KRrMaDEk8lQQIIuDKJpOjQe6h80OMNb19lNTqAXIstREt9LHsi0mduaVIjOCdudlYqg1XlwL
RawWpTSJhcb5gp2EuaZOijZQcSSCFaZQIElwk6DdalNBp3FomVaY1sCTdVaTwHEExspmvk2k+y1K
lWBDQY05BG1wm5Mawog+0EGyKnf8l0xc6tUnibGwHO6tMqEASAVSaz0zOnRSsDtc0SukYTl1jMWO
yE1G3ymTyVarLjcmFE5hTtvw1rU2nrYkUx6jdYHirFfaeHMAAgOkSli6z31SI+G0LP8AEFUs4e4z
oZteV3z4Z8d/byTnvyT9KXBfFHEeAOy4d/mYaZNF+nsdl6DwH9oPC+ItDMTW+x4gj4K1h7HReOVM
QypI1vOqqVAHCIkddF8nDPLB9DKTJ9K4XC4TFEvGQ5jIcwi61sV57cC5uDax9QD0hxgL5i4TxLHc
NqZuH42vhzazXyPkbLteH/tK41h6TWYinhsY1urjNNx9xZYz4+Hku8p5XG54zxXfux/FeHU82Nwl
Zz5JJpNzAD2WJxzx0W4SoyiPKe0EuNQFsR0UGD/atgi4DH4DFYcEwXscKjR1teFd8R4nD+IKjMJh
XUa3Dq1MP87JdwI2PRefP8fix8x1xzzvtxOF8aYs5KgrxeQJ+i7eg3EeJaGG+34mmKIIdUoUzmqP
buFwmI8FYXC13PocQLqdNwLmlu0816rwrwrw2lQoYnBtdTqABwfTqGZ+a3eDG/58MTkyntzGO/Z3
wWtxVh4ZjsTSBH8BzZI+aDH+DeL8IrTwzGCqwcnZHD9F2OI8Ptq8RbjS/EnEtsH+YdOSvUuDvzOc
fNe95kuc4lTLiv3Vmc+o8/wfiXxXwh4bXbWLQY9TJ+oXW8J/ali6Qa3H4QzpIt+a13cNdTb95Vos
b/8AqVAPzWVxT9xsa8Y/ivDm82h4cfkF5sv6+nSSZe3U4bxzwDizAziFKiZtFemCPqtc/wDDuKw+
ai+nTaBAFJ2UewXhnGsX4aw1Go7hVbE4jFR6QGkUz3lctjuO1a9Jv2FtXDV2On0u1Vw5M/8AxX4c
L9voTF8Bw7peMSMp/A4arlncC4jTNV9TDh4c8kGkc0DZeWUPGXiDDeWalc1WNEw8Lp+D/tTq0WtG
LwzgBqWOWZyc+F7e3eceNmtuhq4apSMVGOYeTgQqlX0sn2W1w79pHCeItFItNSqRam5kkrMxNd2K
c+q7Dtw8n4Gi0L28H5N5LqzTjnxXFi4kWP8AcLiOLVM+JqMcfgO3JegV6NrG3Jcb4p4XVbGLwzS9
zR6mgaheq2WWV59XGyqGBrupO9JIeNwYPzXV8L8SPnLi2ms0WzNs8f1XC4TEMqiWWINwdQtag4OF
jDhuvl5y419HCzKPRqNXA8VYRTqMqGNCIcPZUa3hyk580neW46Aiy5BjwACSWvBgOBgrXwviLG4R
uVz2Yin/AC1RcDuFxsv0txalfg+Nwzc1NvmNtdt5TYHiuIwrw12dpB0MpYTxpgXOy4kV8G6dWjOz
6Lp+GYvh/FACyrgsYP8AK4B3yXHLc9xFngvix1PKKjgLLveD+JcNiA0Pc0z1XLUfDvCcRlFShUok
jUaK9S8EUHXweNLTyJWJv6ceTpf9O/w9bAYgXLbqy3A4OpdhA7FcDT8K8Yw16GKDx3Uow/iLDC7C
+Nwu+OdnvF48uHG/5zdweGNj7us9vZypYrhuIAOTFP8AdcseK8ZoTnwtW3QqriPFOPpt9eGrT2Uy
5ML9GHByS+MpWrjuHY68V57gLnOIcNx0Ol9MjqAqPEPGWJEg06gK5jiHi7Eu0LxPMrz9d3w93HMp
7X+JYCq2c7qfyC5vF0qbXEOqjMOSoY3xDWqfE56wMbxR751J3Xbj4q6XORu1Ps2hqOCzMWcK0Eh3
ssV2Oe4QcxCzsS+s8y0OM62Xrw4f+uOXL+mpVxVEWbdUH4xuaNtTsqVSlWcBDTMRqlTwFZ/xmB81
6sMMY8uWeV+mo3iDMo+H5JKtT4WA2HPuO6S69sHLWbzji72u4hVyE5RAE7WT4WoPLIO1lGcHiXS7
yXjuIQ0g+k+KjXBrrL2fT5vne2m2l5uHqUv5hLP/ACH9Qs+nVLdfeVcp1DTMn5hHiKTSRVAGV9+x
3Cjpr9K9PExpZWWYsjeFCGNg2GqJrABsCFmyOuOWUWmYwC5JPZWWY4wRD7dVRptl1hIU9Jk7Hp3W
esbnJkt/bK7pDGBve6Z1OrUEVHuPIGwUlBgBmdI2RVD6olJJPRcrfdBTblFoH6JqhJBcTYaJw4mC
TpyQ5pFtVUCBEi9joEMuPU6jqpQYnXqiptkkm6bTQBAab7AKUDTLvYIi0NGkk7J7GIAB5RZZ2ujM
ETf3BUjTtN9DfVHTpgESYnW+iduXN6Lib9VGpCY11xBiRYlG0RI1PNNlMkk9CJSiQNzKijaMoEH+
+qkbJImB76qMNMXv0KNjjmMWMSoqQj+VohJrDa1jHukAJmZjnsjaARcHsooXSJvB37IMu5Jty5qb
ICNffkibTEeo21TaaJjC7SSdyiMmLjVHTYYtKnpsgmG/NTbUiBg9YAU+Rxtoe6ci8x0PUqZjBEEl
qm1kCJpj05bDRLMXGHf2E5pHZ5g7omUyTqTF7qBU6ebRx+aTz5YuRp9FO2g7UTbS6A0S53qBCm10
jbXIMAjXbZWKFSSSbn8k1LDkmzTBsrFHDlrrG3KVLYslM1rnkZYugfRe1mbZW2AN76qQRVbESFnb
WmNUwr3vLnSY0lSMwj3ATJ3hajaTWunL9FMSCLNk7xyTsnVm06PlQ0gz2V2kw7tABESNlZpsaIOQ
TzJQvD3RBDW/VTbUmkVRjcs6qJzdY0AlWCCxjoddw5qFxAN3CUhpGGOANvnunDTedAia+QSDZJwb
q6Sd5KoEZQYnbknewObI30Qtc1shuo1JTOeTOa56oI4BsZMaIdwRdO5wmxnuhMdhorEMZD9VHkcS
SEb3HpyTB24mFqBgw6WnkiYDfmOqcPPLdNmJkHYLUEjdAI6JsoMkKMEC2gRWcdSiH8uBoETB7nZI
AXkyE8hltFqCaiwhwExfmrbmZSARNtt1Qp1ZME7qy2rO6sJpMMwJkH3RZyDrfqozULgASTGidt4m
Atw2I315qzTLToTP5qBpGpknZS0jf0ytxi1apvA5C0SpmHlMmyqiS6T/AKqemdL6LpixUxcSLeyk
YXE31O/NRB4y3vCkZUA0EDsujIsjo3IG6QZrZJzyXenZS0yYPJIWsTiGFLHF7BbQwuS8W1S3AvY0
20Mf0XolQgi4i2i5TxTw2liaDsstf00XbLmkwsry/BvPceTnEOY/K4m1grlHFk/iR8R4TiKLyHUn
ObMgtCyXUn03ekn31XztTJ6N5YNylVa7vv8A38lOx8jUQOqwaOJeyZ22ViljQNVzvHXXHljYeA8R
Oy1uEeIuJcHw/wBnoVWVKA+BlZs5AeR1XMMx4M+rX81ZZXa8Tmb7LncL9uszl9NnG8dxuLw76L/K
pMJl2QG/uq7alUNtiK42kVXD9VRa8RYqZjxt31WbG5Vjz8TBjGYq17V3/wBUYxOJIbmxeLM86zz+
qhzNdPbkigBoieayo4DvjLnbepxP5qWjVDXHKAOwhRNJzWB7AIKweG5sroAlZ1F3pomrLPilBRaB
W99SFivx7aZio9sK1heK06lUU8NTfXqnYCw91fishOXHfl1+FDIZnNnEAA7rr38E4dXogVcLTJiJ
AgrkeA8Nqio3F48jOLsYNGLu8PUDqYkyVvgk3Y3nbfLHwHhzD8O4pRxuCc5r6RkscJBHJbuNxDq9
V1R2UE7N0ATPcCNDyUD3CSd11+PGXcZ7W+ET53vGyhq021WEEHS6sRrHZKNgJUym41i4vi3h1lWq
auGPk1tZGh7hZP8AicE+MXSc2bZ2iWnqu/r0ZmAqlSiHNLXBpHIrx5WzxXbGfccq2uypTBaQRzG6
jdUt6dBsLK9xHgVF7jUwr3YeoZ+E2PssOvh+IYY+ukK7B+KnrHZZmMvpbyWexVBmeSHXQM9Nwed9
1CMZTmKk03cniFYY5jtHA9ldajMylbfDPEHF8AW/YuJ4umORfLR7OXY8G/abxzDFoxH2TFtGuemW
O+YXnIaCCZkdFJTqAEX3XLLCV08X2974X+1mhkAxvDa1MjU0awcPkYXR4P8AafwOqBnrYuif/wBS
gTHylfNTMQYubDkrNLFPGhPO0rGso5Zfi8WT6gpeOvD9YW4tg55VJZ+ad/iThNcHy8Vw2qOldq+Z
BjXFvxSOSp16wdq1hHUBT+1Yn4mGPqvpTF4vAVgS3CYWqNi2qwrDxlDBVZnhTPZzV88VsjtWDlay
rOpsuAXCOVRw/VT4N/brjjMfT3PGcLwLgT+7Y21CwMbwrAhxAw7B3IsvJqlOLB1XX/1Xf1Vd1Igw
7PA5vdP5reP4/wD/ALLcv+PSa/D8DTN2Uh/7gszEnA0gfXQEf5guHNBrhcSOpJhC2g2CRTHeF2x4
f3We3/HSYjHYFsjz6ci1rrPq8WwwMUm1altmwFl+SZMemdETGCfihdZjI53dWzxGrJy4a3V90kDa
QAifm5JXwzquMo8QwocKhpue9pkCp6mnlKtYfHYJnDOJV34dlXE1QWNlvpp5v5Rz6rnhhq+UHyak
HSREq5hqFYcOxTXU3gktItrdfS1HxpnlfcBhagewtcfhBurmHe1zHUnEZX3B/ldsVjtcab53Cu03
5mgtiFqxMMlprDLg4EOFuqJrSRAFuimpt+0Yc1hJqU7VANxs7+qdgtp7lYdoamwRf5qy2LxcTyQ0
gAZtM6qxTA9lGoAOkHe2uyZ5zOJII68lO4Nm4nmoXBuYnrHZFDPpsQD0Sk3ggid0LpOYHXYp7RMg
BEEHEgiQRskyoWzG2iZoBgCIF0QYwwIPVRR5pHMmxhSMBLtZ2PJA2k0T6hFie6NjmM+ElxUUbg4E
Bot9UQs64CjbUOzjO8WUgAiTMd5UVYp5ACXZSduqRzEyBACClTbBJJLTcndPlOeQSBylZbHTBJII
gHVStptMkOmOagLW5oJLlPTeG6sBQhZmg5TdSMIEEtNzdC5wdJI/1R0o3A91AgczgACApWuygwDt
dKnBJMog0ZiSdBrCik17otPPsiDnOJncj3Q5mybJUnjMf1/NBapt3MkI2VDmiMqhDjJAAhSsYb3W
Wk9MyddOSnptA1HuqrWuyxPZE0EEAEwsrFymQ3URGgTGoHSAzTdQZnsPpyuGk80mGq4knKAVNLtY
FQmRBmbf0RtqC9hbZQg5ZLoOmir4ivUcCGENbpPRJNm9Lz39Rfcqejh69Zr6lKk+o1l3OaNFz2A4
tTw+NputiofBYdF3Gerh+HGnTeKX21xe4NsAwXKxnevh0wx7zbHYyq6MrCXG9uSkqU61FgdUaGCf
xEBURxU1amLrMMUaI8ulFpdOqpU6dTEkmq5z3cyU/wDtev6a9OpnMCoyT1UoaXQPMttCr4LAhsa/
NbWFwjWtmJMbrNykbx49qrcGwj7zEEE3gBH+66DxDa5I7KxiKQD9IaPmpqEhklxE6rHe/TpOPFSb
wqmwXrOG+iR4dTH/AHiRqLKepWBc4tuOadpBJuDzU75Hx4qx4UDMVuvwoTwgwCKwPdq0qDgILm36
FE6uTB0E/RPkyX4sWNU4TUaYD2n2KFnBqzmktqUxl5yt0VgDeUD65ym7YCvy5J8WLBfwmvEZ6PK5
UTuF1wNKZJ2DltvrNcTIEdAnpOaXDKIPVX5cj4cWHT4ZinmG0g4Dk5O/hmLGlAf/ACC6OlUaxhIc
Q7W2yiDszjIHcqzmyT4MXOHA4sT/AIc8hcFP9jxABzUX/JdO2m0jSCbIxREGCr89Z+COUdhaoaYp
VP8A4ofIqA3Y7uQV1poum1wUzaTsplpnutTn/wCJ8DkvKcD8DvZqkpU6xAy03/8AxK6xtDmI6KTy
3h8NcRy6LX8n/h/H/wCuWbQrk/wqht/KVIMPVk/dvH/tK6qmC3/uPlSiu8NgElP5V/R/Hn7cqzD1
jby6l7n0lTMw9dpl1GqOuUwunGJqDczsAdVFWqV63pc45RfVWflX9J/Gn7YjKdcgRTfbfKpaeGrn
/sPk9Fr02EATpynVOWXt+a6T8m/UT+PPtQZg8W4f9M8mEX2TE04mk4DutKjJtJPO6tNa2JIXSfkZ
M/Bix2Yasf8AtX7qdmFxG1LawkLWbTY4WIEdEX2cQSCCtzmrPwRj1OHYx49GHJ7ELK4hwPi1W9LA
OI2gj+q7Km3JrPspWYhrQBcfquXJyZ5TTWHDjPLzZ3hrjLyZ4XXLdLQocR4Jx1afM4NXJ6MC9TGM
cRYn2VrD4p7RJcfcry9eT6dbjj9vD6/7OcW+QOGY1p2hkrHxv7P8XSkmjiWD/NSOi+jncQdEB5Ci
+01XuM1nQtd+XFj4ePJ8u1/DpoU30jQLnj8c3+SpVOBY9gzCjUI5gbr6rxXBuHcUoup42lTe4/DU
a3K5vuF51xrhdbguPqYStDg27XxGdvNSflZerGb+Lj9V4ocFj6Tf4dUAdE7GY9pjynm+mTVeslwc
TZsHohaxuzWkcoV/kf8AE/jfqvL6dXiLSQKL/wD4K3h3cXqQGYd5/wDbovRjSuDDfkrNDDmC4+lZ
vPP01OC/+zzulw7jtYn7rLPNXG+F+J4hv+JxGUcgdl3LwAfUb8whboYcPdZ+a/Ub+GfdcJW8EODC
W1pdreyrYTB8Q4PUnD0mubzaNV6BVzOb6jIPRBTo9NFZz5a1WfgxnmMDA+JKjSGYug5p0kLtOG8S
w9WkyH5bCx2Wa7A0ao9dJh02UrOE0CBkJYSV6OC8d9+HPknJPXlvCo1/wkEc0hBB3UGB4PWw9POQ
WUxq+qcoj3SxPEeCYGp5fEeOYWm+A7LRBqmOVlc+XGXUrphjdbq2AClA5rP/AOK/B1Nv/XcZxLuV
HBEA+5SHjHwrbJw7xJUH/ixv6rPyRvwuObqPeFWrU7SLbpf8WeFDObhviZttYpn/AP6T/wDEvgyo
1+ep4hwx/wD1MKHflK456yamUjOrU5mZtZUH0CJiY/NadfjXhSpPk8arsM2+0YZzY+iamMHXI+wc
VwOImwAqQfquHp03KyH4KlVBFakx9txqqFbw7hHuJpZqLubCuqfgcS0SaJc3cs9Q+irCmQ4tvPVO
1idY5o8AxlMAYfEh/IPaqFfCcTw/xYYVAN2OXcDMGkGPZDGYE9ZupM79nX9V58ceaborUa1I9WKd
vEqBAHmwf81l2bqTC4y0GOYlQ4jh2ErNOfD0iT/lWu2N+k1lHKjF03D01Gn3+ifz834wYWtV8PcP
cTNANPNpVY+FsC4+l1Vu1nqzozvNQdDiLx1QkAxMWV13hSl+DGYhvuq9TwrUB9HEKvSVqdf2vbL9
ItvUbxBlActxPz3Ru8K4kiBxJ2m7UDvCOKv/AMxcfZakx/bPfL9IiWtzZojnuo/OptLpcIlSP8I1
h8ePd8lGPCDfx42odrLc6fti5Z/pVqYynN3gDuqNfidNjjDiSOS2meEsI0/eVKr41vCsUfDvD6Wt
HMQNytTLjjFnJk5P97ukw0kc5SXcU+G4VrYbQpAdQkr8uH6Y+LP9vPMNxPCOM4ulUeTqRVI/RTUq
3D62PpWrU8KDDmseC8juua31VnhzXvxtJlJuao45WjqV7ek9vmTlt8VPx+th6/FsQ/BNLcPmhgdr
AsqmHqZHQ74DqtKpwhzKzmVK7HPkgikC6DvdRYnhb8PTa+oKrGu+EvpwCrLPTNxy3tbwD3Ua7Xta
HN3vZw3HutTFYZlAtqUTOHqiaZ5c2nqFgUXvwxbTr2a5ocx07FatHGjyvKqgmm43Eb7OHVSx1wym
krBDYBJPNTU7dJUTXRYEEDSNxsVM0i2l91l1hPdYwNVBUEgEwCbWupnnWIkeyjAm5iEgja15AEfo
nygNGYnp0UjnzoABqN0ECCYtpMICgZeu6dkhsaHlyQhwIAAOu+qW9m+obFQOSBMzyMKQnUtsDvqg
gQN9kcESAe19UDN+OT3UrX+mSZ35IGkCZsfojItE6KNRabV8unDYnWUAuTJMqJsZRFuv+isNIDe4
2us601vYgTAmbG6JjwDeEDZt12PNE03Ei35oJMwzfkVK10CSBl3v/cKASdGi6cBs+o/IrKpBUGYE
EHmj85xBiZPTRAYLbI6YETqRpBQJjXPkuMARHZT0sjc0662Q5i4nI0AaIabZIcXAnkoq2yqAPRCk
LgInWdlAwnQEWG+imGok6m06rKxMyA2QMx35IaT3vJc4w3QRZFleacAgZknltNrRY2UaH5jTE6qZ
gYSL/wBFTZUBI0IFlZpGHQdxspYsSs8uS0fENQVyvjLiTmvbgcK4tc4Zqrm7DYLqWNaHHLBJjZcF
imnE8axLjcmqZMyYFgFvik3uscm9ajY8K4YmrSYwEl0CF2XiviOThdZ2HJADRh6POB8RHc/ks/w7
hDQwlXFMBzx5dIH+Y2n2QeJgx1PBYZrjkaRodQ3U+5XG2Z57eiTphpTNB9DB4XDN+OPMeRzWxw9k
ABxg/OFnYIPeZqSXamTdbmFpAOAaT2/RZyrphi0KNNjGySDylWC8imBTNyeapva0vZL4yjUp2Mpg
iX+wXCu8izLsmWpmJI0BRtYMhDqjoNoCTDRa2dTyN1HOYmS2eUKKOnh872sY3NNswRVsOxmKqMY7
7tpgTqhbWLNCQOhgoD6pIcQeieUFVGV5yXGmqAPqH35CyZlQgkFohTMrA3DQDtZAINSNCETaPmMi
DOim8y0BvuUsz3QAYKKjGEG7b94TjDgQRz1UjaRcfid8lMygWjUzumxCKJ0m/ZOMPckCB9VdEG42
UrGCTpCm00ptpQNlI2nfYzuphlzZbzyCZ7ZBjQc1dgCyLNLeqTKcawossCzpgTdJhJH9EVYc0Bty
SVCMxNwNPkjzdPdEHi8AdFYGaHSZBlG0kH1XGpRtqE9tLJrxMH5ohPytbOWeyGm8EGGZSN0bSdAJ
BR5aUSbnkrAFGmXGSb/RWHUZbYiZ5Qo6biPhHsrDQ4iXCLrrizQNpuB9TSeamps5WvzRMdHxCeam
aaZF7FdpWDNpyIMjpCJrMuoKlph34BI5qX1j4mlamTGlUhxNjl7lJtJxMOI63Uzi6JyA7aIJMk5R
ZNrIhLXUnGJ52S85xEErSbUY9gzUwCbSq9XCXMH5LOHJ51VuKqKknUAm6sMqx1E+6hdQLOeuhTtp
O9jzW8spUk01cDWolpD4D9Q7dUPG+BHEuBHE04NfBnNI1LDqP1U2FpCk8PqNLm6Hot/A0aEVKQGa
nUblI6FeDPUu43fTwp7HC17Kei2nH3gdP8zVtcX4YcDjsRhnA/duIHUbH5KkaGpaF2+Pc3GO2lR1
Jsny6xjk5F9oqFgY42A5KZtA90YoAxLY+qnxVe6oBmN7lFkAE6Ky3DXUooGJG/JPjqdlMzEaoqeU
uuDEyrP2edLoRSIJ0U6L2XMBgPtIqVnVG4fCURmq1nfCwdOvRYvGPFJoHyPD9JuGpafa67c1V/UN
Nmrb4kHYnwlToUajWMZiXOxM7QPSqnh7w43FPbUI8tp/7lQZnnqBst44XK9YxllqbrjXYTH8TIdi
6mLxYk3rVDl+S2OF+DsZXIFKk0D/APSZK9UwPBuEYMNdWxeGY4Cc1U53fLRaB47hMHUp06HGwKO5
o0Iyr1Y/jSf6rzXn3/mOE4d+y3HVnAvpYiD/AJYWti/2eYThdBr+I/aKTXEDM5wAldc3xJwoSanG
uKVDp6acLF8ScU4Jj8G4UsZxOriG/B5o9PurnwcfXxWcObPfmMseDvD72+niMn/+IFVr+BOGPcRQ
4l//ADArDqWcgAzOtr+a8Fxv7evazxHwD5VJzqGKbVF9WgrkcZ4Wq05zUaNTt6SV1Dc7fhqOHuVI
2tVDY80kHQOv+aYzKfZdPPKuGxfDjNCtjsFl3Y92WfyVih4s41QnzauH4hSAiKrBm+YXZVaQqTzO
sD9Fg8S4FQrgu8sNdrnpel3+q6yS+4xuz1T4LxhwvEejH0q2Aq6TGdn9V0tBlOvQFfD1qdegf+5S
dmC83xXAsWyTRjFMH4SMrx7bqjwzGYvhOLNXAVamGrg+tpFndHNKxlwy/wCWseez/T1dtFs3M/km
fhTHVQ+FeOYfj1FzX0m4fiNJuapRn0vG729OYW8aYLRp3Xmylxuq9Mss3HO1MOY0APZR+TmkXEjZ
blelI6c+agw9Oj5w+0moKO5piSORhSU0ymUfUL3UdWkA31SL6BaWL8mg3zBVpvZJHJw7hLi2AxPD
zTGNwtWgagzsziMwO4W8Zb5iWye2OYaZnqFC6oQDLupCkqkAmWkKuS1xNiL81vqnYZqNcCHGf0Uc
MuYM9UNm/C0knfVP7e0q9U7G9PQWQOYwG9z0RVILHDLBChAM6kGdCrInZJDW25dJSUYBbYkjpKS1
pns81oYTA4zHtptxRZhxd1SqwEnoAsPGmlTx9b7GXCi15yE6wlQzukNLvZRnD1BOZsd19aTT4WV3
6i/gOL1sJiG1qbi145aHuN1pM8QPxHEKeMx1IYmnTMuploDSOy577PW8t9QUnmmyMzsphs6SdlGC
QDBMJ1hOTKL/AB3iTuLcUr4x9NtLzDZjdGjYKGhiC1uV2mx5Kqkrpjtd7buExFsj5jYzor7HBzAW
wQTqsPh2OFBppV6YqUj8wteniqppOp0srKLiHObzOx6LFj0YZ+Fhjha45X2UrRLf6qBlKocK+sAQ
xhDH3+EnT5p2NBbcwJ31WbHWU5aA7t7ojDhAiNgk70gOnTdBOsgWuijDPSRuOaWUgkQD3Q39uaYO
dJgzJNyYURI0AzElydwgkgWKjYTmkmQLIwCTBER7kIpxtE+wRtiPbRA0kkjKSTaCUdy4SRAtKiik
mwkckdJx7BC1pkzpujywY5ctlFSZzcPDpSvJi0c0tQBcnY804abGdTuop2iSMzrmylYBFtUGQTEC
RoNVK0AXJuCoSCY6BEHkpMpAIi3Mboadp9SmY1xaCSJHJZagcuQOgkgm6Ok306HkUbWSCbROk7om
sgEAm1gm10kpNAvyARsbIm+qjYDBiOt0dNrr7zyKysSgODbESFG7fO8HeETaZMXGUITTYCZvFpIU
UIZlvrz5qYOEXBBHVRGvTo2c+UH2yiBJgkfRNVNyLdSszDYSrWcIFNpcQuR4HQdiK5cQTnOc9yd1
b8R8QD8O3C0yRndLv/ELU8G4YOxDHZM15Vv9MLVw/vm6GtmwzaGEaWh1NgMR+I7rnuI1XP4jUdTj
y6LQyI58vkupxYLnPrkDM6ahdrbRv6rkstzTZd1R5e5/OLBceO/b0ZytHh9Tkw+63sK+WTlMDmYl
YeBoENiZC28LTeBJF9SsZabw2eoHVHiNdAmc19JxDjJ6KYU76DsSpKNKSc3+6xt00DDguaZ9407o
3PcCQR6Z0VmmCBDYaNUVWmY9RbHZTaoKUEXBy90+YE2BB6FO8HUkCLQEAZtpugJrXEjPPIf6KdrQ
CMpk7KJjHCJ3vqpgGxt0UUmCSJIA6qYEAQCDFx1UDAA6ZUlPWQYGoMLKp6dWNQY5wjOImw2UdNsx
BsnFAgXFlPAnpuDjYwdFM11tdrKs2nl/mgKam5ob8F+aBzUaHc/ZH5mYEEd1HBJkc07XWmRAtqgF
wk2I90AZH+6kIaJtshiNCtRDFmt+6JjHRpcfVE1hNj9VPTpyCZHsqIWUnAdERY5u+nJSloHUoSed
rRKCJp1nWVLpqQe26FzBsRPJCGk6D3Vgmp1LzoFKHwqwaQdbdFLTgC4XSIssqRE6nZE2pooARGiQ
Ive/RblZaFGqREzZWmPa5s5v1WQ1zribcpRU8Q+mDJgHdVNNXJJ9F+kqu5hDiJ01UVOuXXHZS+Zm
nQzySbNJaZFKCXCVdFVrhIIvvKzc4Ov1RU4Gn+6lx35FqoGvfZ490VOgAASAeyriOVlLRdTa4EF1
uQS70i4cOQ45bNGqfC4g068WspGVmuBIkbKrVpkVMw/srz3f21FDx5gi6pQx9Meiq3y3xzGi48DU
OXpeIwxx3BMRh3D1ZczCeY0XnRYGkzI6dV6/xcu2Oq83JNUDKea8hSil1HVRscZ5ypQZm916erns
xpkb2SDZkfVLXS/VC4arPVZRZBrKgqhoIkgAc1IC6Y3VDjRf9hrFkh2XULMw3dLctTam/jNPBcUx
HkRXwzwGVKRMZxzHJw2KmoVqgbVxGBxFTE4X8bh/EpdHt276Fea1cc6hjH03ugTIHMLQwfEa1Kq2
vhK76Ndvw1GGHD+o6FceTDLjyrpx5Y8mLvsOyvi69INxBcKhhrjcTyIGi2cdwfGcPwzK1YB1MmC5
uy4zhPivyq7H8UweWq1wIxOEbZx/zU9J6hddxHxU7jGCOH4RiKGJa4DO1ph//wADBUx1Zd1MpZfC
tTrM0Mi3zUw8pw+Ijtdc7iMU6kIr0ntedQRlI9ilSqeZ/BrQTeHWKmrU3G6adMmA9I0BBhwKwhWx
dN8H1Cecq3TxtQGHC4U6U7RoCkTo4J/sz4NlUo8QqNeCaJeI0XZYDDV8VhGPbwmqMwmYsV24+C5u
eXNji5N1B4mxjooTTfJnXqu3PBMW4OJwbmR/lJWBxmk/hbm/a6ZptOmZsLWX4+WM2mPNjl4YrqDX
Cctxp0RcQ8MYXi/Dm4l72DEsJaS0xUHUc0T+KYLLLXewvKsYWtTljRJq1DZgEnsuMzmPt169vTk8
JgsXwTiuGrRL6dQGlUbo8TBB7jZejYtrGYmq1gIaDpy3hZfEuJYLglOcdlrYo+qlhhBIds53IKDg
uJq4nACvXcTVqvc9x5klebk8+Y7YTS/VeQHTKpVXFskCRrZSkFzjso6jSBI1hctOm2N4gZ9s4fUb
Ta2o8C0FczgfGvGuGUauDrYiu/Dub5flYtvmtaB/KTcexXT8TwvmMLqb3Uawu17OfXmuOx3E+IYV
5ZxLCU61Jts+XXsdF6uC2enHmky9ulHijw5X4ERjKGLw3FmTlfRh9Kt3n4YCjwdejjGl2Dr03O1y
OsV534iqYWu+jU4d6R+KkbGdlnYLiNXD1BD3MdOh2K9lw747eLv8eWnqtRrqbi2qxzDO9kxIcLER
O657hHi6qxjaeMDa1Pk+/wAiuiwdbhnEh/hsR9nrH8FTT5rz5cdj0Y820NR0TIMdE2dul7e6v1eF
46iRFN1Rp0LPUD2hQV+H4uizNWw1ZjeZYYK5+nSXfpC2oI+KeySDy2nYHrCSo8cNQNFnR0CA4gza
Te0qP0HoUTKbyR5Tcx5gL62nw91LTqV3UatNr3inUADmgwDB3UNSg5oJ3GoV5mArNa11aq2m3lNw
icaNJsebnI2F4U2vXftmUqL6hOUe5MKZmEP4nf8AxCN1ZsnI2e6RxFQgDMRbayJJFjDspUXfAC7b
MtDD43C4duYu81xOg1CwrnW8/VOxoJlSzbeOWvTq6nEaGNpV6WAwrsJh2hrix1TM5xnUlVw8Bsba
2GyHBAF9YjR1ASD0TjUx8lh3mzvdmsAYOlkMm8k/oEnSBcwNoQnQ3tzhAeZ3w79NFKAWxBHNQtkx
udZRkw6x1uoDF4Gh6BPTJkQAdjKEGGQ0X6IxDRDYJ5lGkrHAEkEEcyia8tcfqohmF4bBRzawE6So
qdj4JcdtLynYARcmRPsoxDgSIvsjaZIEzosqlBGwgb3RN7gBC5p7zyUjKOptJUWExhJMvHYIpAM3
Ij5oGCHEctlKwkA7foosCC7XK43U1Em5MhKDHYQnDMpzbHkoqZr4bGp1hGHQ0zoDCqtOpyI8znRb
/dDaQVoM3EbpfaHA635qBzsoPp9UaqtVruAs0abDQ81ZEuWl2tjHEZS6+8FVH13un19NVRLy4xz2
Rta52pjteeq1MdOdy2epUmA4k3i2qdznkEgwTdJrWtAvraRsoMfX8rDPLSSQIAI0K1GdqNPNiseY
u1pytXpXAcKMNw7zAB5lQhjdtd1wfhmhmqBwF+y9KwNM1K+FpxNOiw1XW3K835OX09v4uOptH4jq
ihhTTpTNgAOlgubw9OKzgHAiQLrQ45i3VcYS2ctO8c40VThzC+o3MQQLRzXLGaxdcrutbCjI3dam
EcYseh5KHDsOQEBvLTVTMa8Os6ItYLnfLpPC0w5TLwMp9JCJpY1pcJJNhKannyQ6HDUI2svADfqs
N7A0iN5jnopATAB6BO6nLoA/1U3lidBGsbqG1fLIEImUhzIAKnIvLfysgeXmJi20IAOUE+omyTCb
xJ3hM6LggAdk4ET6ssaIuxNEtgiL7bo2ACQDcjRA1pkkEqXMLzqouzNLrgQYsrDXED1lRUg11wSD
tCkIkCTfsoJGQRIujEgHVVzUiZNtgmzEzJQS5i5xbNki0C51KjY7L8UfNG6o24B7qqcVGA3CMVG6
259FGILbQOnJMA6YzQOiC3TqNI3upW5SOqpgHn9UQeQJIJPNVFiBzGnNBUFpEqIPItBjpsjaZ1d3
QIGZlMT6rzCB4l4g2CXwnYrUFhhAaZA+aPMMsz0UDTbS/JSTPVbjIi6RfnaE4JP5QhEDT/ZOHLcR
I2co/XdKzpzQgLhufdIG5O61ETsIZOnsj8yR0Vds7AqTK4GSwz2WpE2nD5Bsja+DKqg5dXATzMIw
603jSdk0bWw8X69U7K3z6Ks1zd/9kQdIMlNIv0cQdFYFUuiDCzKTtY1VukTrBkFcsosa2BxD6dRp
JJb81yHiXCDCcXrsghjz5jfddPh7OGyp+OMP5mFwuKa2Sw+W6OR0U4L1zY5JuOPLRIsjabGBMIR7
EJWK+k8mxNNo2KlgGYHZRBt+UqSm31QT0gLKyhc3koK9MVKbmuAg2NtlZcf0UVQn+91zrceSeM+C
VcPXdUY0upzILdlzvDsc/DuIdLqY15juvbsZhW1mk1ACCLiNVxXHPBTazn1uHHyatzk2UvPjl/XN
znFlhe2DIwuOpVWgsIIi5Q4gU6rg5wuNDoR7rCxuBxvDK2XGUKlN2z2/3BTUsXiMv3dVlYcnely5
/D9412nP9ZR1OF43xjBty4fiNV9If9vEAVmdodP0WthPGVNjh+8uA4Ks7/1MJUdQcfa7VwTOJtZA
rsfSP+YWVtmKpviHgjnKlws9nyY31XpDfEvhvFfx8NxXCHrTZVHzaQVM3G+GKt6XiJlA/wAuIw1V
n6FebsryPiSfXMGPzSbheteoUxwlwml4u4KP/KuW/m1dNhPGuI4fgm0GeKvDFRrGwHOrZnD5BeCO
qg29J7j6KBz2fygewXXHkznquWXHhfce2cQ8cVq7XCr484ZSbuMPTcT9GrKo0vD/ABb/ABGP8bCu
46zThw/+Zt8l5N5h9gq5qDyy60z87plc85rZjMMfp7pwnh3gl2NpYfCcQxfFMbUMMo03kl3s0BSe
PcU7w7gjg8HwivwyvXENxDoBgawb3heJ+HuLV+FcSGJwtTJWHwvaYI916z4e/aTXxNCrhfEFHC8V
Y8Xp4oQQ3k0814+Xiyxy37ejj5JZ4cNTLnVTVqOzOcZc5xkkrvvDtVruGU23lsg/NbFLwb4d4/wC
ti+B4gYTHwXtw7qkgH+W+yweAcK4jw3Bihj8O9lYuLoO/VYtmUbm9tfzLKN7+STmuafU0gpibEjW
J7rnptVqwP8AVZuIoCo12UTOoNwtN5bMls9Coi6kfwQVueE9vPfEXh1lYPfgqbaWInTRrlxGKp4n
CPNLF0i0i3qGvYr2rFZHSC06rKxeDo4hjm1WMq0yNHD8l6+Lnsmq8fLwdruPJmVIEUnlv+U6Kzhs
bWwzhmkXjWy6PivhCm4OfgH+Wf5H3B91y+MwuL4dULMRTc0dpBXrxzxz9PLlhlh7exfsm8UVMKzE
18RiJYXBlNrzYcyF7ZwzxDw7iFMMxdOm4HcQvkPguPZTotYSWEOLraLrOF+IcVhYLKnmNFrGDC+b
+RwW5Wx9Dg5MbhqvpKv4V8NYyoa/l0PVzakvFsL49d5IzucHdZSXn+Pkdf6/t4YH06ZOWmJG5S+1
VSID8oj8NlDIi3NNJBgD5r774Ox5yTMknrdAb66pAixN9EtlU2YbzonBtO6Ykf6pmknRuYoiTQT+
SlpNL3QR6d0DKNR3IK5hsNFyZA5qV0xlrWpPbTaPKBJyZTOyFrrDcx2lBRBbRcDYdBopGgGSYK5u
5rRLjNkg4WhoBj5JzBgNMkRshbkvpGqAtWzEnqmBOsuH5oQ4ZdAO6lBAAIEg+yEM0mTz3KlZJP6A
oQYNzPKykn1CBbWFGktMGLGDBsU7mEgXsgY8fPSBMo8xJEC3ZZURMOvvtCIOggDlqUJHpkQB1TNc
YMDpdRVgOOWXai0D+qka+QbwdNVXbm9+UIwOTiDE2UaiZhuTe/5JiTF/SgBNwCOaNptc27KCQExA
aPfZHc2zXQtLA4G+u6Jrg6dgLAqKNggAWKIHm6/IIBG7jpuJQ5pFtOqICoYcDyKp13Bx0ETzVyoP
TsDFis2u65Mz1O63ixkkYA0XMe6MPkENvfZVWFpnM6Qdgpw8BpgiBdViJRTzMAc4X2WNxQ5q1KkJ
sMx6cgtTzTcuj3GiycKPtOLfUcCczoFtlZ48nvw6rwnhSDmcBAErtcEBR4LVxVT+JX0jkLBc/wAI
w5p4AspgirVc2m23NaHjGucJhRhaLgPJphotv2Xiz/vnp9HD+mDmatY16nIveTr+EW/NbfDaOUNP
9lc3gyXYuCZa2G6aka/VdZw8AhsN7XWs/Hhnju/LXotpinJP0U4NLMfUTz6pqLQW3APYomU239Dp
G68zud1dsCIiY0Uja+gMA6glZmLx+Ew9VzH1QarTDmt9Rb32CrUuM0XGGUKx5+plu8E91eu07RvC
qAQXCZuYKFtRxdLB9Vjnih8vNTwr3DYF4E8tlV/feMf/AAuGPgED1F/6N0SYU7Olpuc4GQQk59w0
knZZWHxmMqFk4TIZh8tcBfkT+oUNbFcUL6ow+Bc1oEMc9rTJH/uFj9E6r2bUTJEawo5I5rDJ8RZn
NH2aIgOaxgB+bpTeX4hJcHVsM0RDXjJPeIKdf+nb/jeDzN/zQF/qgujndc99k48Sc3EGNAiweL/J
iZnCuMPI8/jBAiPQ9xP5D+/mr1n7O9/TqKbxEgutzUzH6DXlO65ahwziVB+f96gu0Oek9/eAXRda
lCnig8ZsXRc20gYfX/8Amt/upcZ+1mV/TXLgSduijdVY2S97BA3cBHJZzcFUzVHPx+IdnYWANY1u
UGb6a31Ver4ew9duWvXxdaG5MznNmO+XZSYz9r2rSOPwtMgVcVhm9HVm/wBULeK4B5OXHYV0SbVQ
dFnt8NcN9eZld+Y3JqxB5iAIsrFHw/w1lQvNGo9xtLqzzblqrrE3kn/ffDabsv26g4wfgl35Ap6f
iDhr6gp08Q99QyAG0X3MTyRs4Lw0mX4Sm4wblzjPPdWxwjhrmgnBYUgAD1NmANNVP6m8ma3xVwzP
AOL2/wDt3D8+yOp4t4VSAh9Z/wD4sAjnqRpv3WszBYJxJOFw0zN6TT+inbQos+CnSBi0U2j9E/qf
2czX8WYcU6b24HFFlQwxxewAxvYm3VPW8RU/s9WrhsPVqhhhoOYFx1t6TtuujremQCewVJ7nCSXm
3Mqyz9Gsv2waXibGOIjgmJeN8heY5j4I3Uv72466fL4MDe3oqXGt5iNvdatPFUhU9dekD/mqj+qu
4d7Hsa+m5r2OEhzSHA9it+J9M6v7YNPG+JHsdHDKFMxYuZodrF6tYDE+Im1j9swOGqUiLCm9lMt+
bjK2t+/RUa3G+H0h6sU03cPQxzrgwQIGs7LUu/USzXutJ5qNyhjPMiJeXBod7QqJdxJ+dvlYWmC0
RlrvzN98vdR4nxFwujUpU34qXVCGjKwwJMAk7AndXmul2WYvBla1pN7+2JicDx6tS8uhxSnRJcCX
XJygC0hu51R0+BcRcycRxrEFxB+CpUy5ie49PTXW6pVfF+FYa3+Exmak8teHGm2HAxF3dD8k3/Gr
Idl4dU5+vENbfrYwV1kyc94/teqcBx7y6OOVqbX/ABBlMmeYu826KvR8G4Y1ab8Ti69drY9BbAMW
/mJ7qk7xvUvl4Y2Bv9oJvy+HVG7xdjBnAwOEa5rMwHml5LtxY7QbarWsk7YN+n4ewXnMqul/lyWA
02Q2dPw6jmsji/BcRwzEVMbw7HVqNOpLjkADw/WDADS031HTtteGeK/vXAGrUYyniKb3UqzGTDXC
4ibwRBv1WljqdSvhKjaLg2tZ9MnQPBls9JAB6ErO7L5a1LNxR8NcSfxHB1PtLWNxdB/lVg2wJiQ4
DaRtsQVt5YnquUwWMdguI4XzKJwtPFHLWFUU5DzOUBzXTY2gi87Lq6e0gLOXtcbuJaT8hEgBWxUN
QRmVINnQK1hqcwZAOuq5ZNpmZjBD3fmpMdRfieEYukTJDQ9vcJ6bXTa6uYQO80tMBrhELlvV2X9P
PLnQCEPIqzjqX2bG1qRBGR5EdELTmbsJ+q+lLubeOzVRHQwFLTM3iZ6oXiBbVHTGUW3SpDHVNA11
TuyuN0m0zzCxW4Bz9gAoHtaDYeyslhvfdC6lAO/tovPnjK6Y5KNehQrAsr0mvB2cLLmOKeCeGYzM
+lTdQeRYsNh7LratKLDXcIW+Y1uUU7LlO2H+a1ZMvby3GeBuI4ck4Su2q3+VyxcZwXiWD/6jhocB
+Kn/AKL2h7KtawpuB5lI4N2SKhEbgLpPycp7cbwY308K81jJFRmIpHe8/mE5r0iwxiqgto5gK9y/
dmCqH72nSP8A5MCiqeGOD1b1MDh3c/TC3PycfuM/Dl9V4f5pMgYpkdWFIOqnTEUT7FexV/BvAnA/
4CnysSqp8F8E2wY1/nOq1PyMP0z8Of7eTF7mtOevRHaVXxFcgZWVGv5wCvYqfgjgsT9iBHVxUn/B
nB2i2Ap231V/k4fpPhzv28RZVEyfSRy3VxvEnPLQ8B0Feq43wbwipTcPsTWnmwkFec+JvDGJ4RXc
6kx9XCzZ4Hw910w5cOS6Yyw5OONDh3HsRhKjThsRWp5QC4GfTHVdfw7xdiziTiX4t9eu+Mz3ukuX
mmF4hnwVShiJNRrYY4a9io6GKc12ai8g8iuefBK9PD+R19+X0VwvxPw3ibG08c3yqlvvB+q0cVwb
zKJrYRwrU9nU7/ML5/wHH3sc1tbXnzXZeHfGGIwVUPwuKLf8rjLSvLnxZY+3smWOf+a6rF03Unlt
RpbH1VCqS08/e66vh3iTgvHWCjxakMJiHC1ZnwuPUKvxvwjiqFI4jh7m4rCm4dTuPfksT/rGU05S
p95pE6FR5IBiCiqMe15a8ZSNZso8jp1/0XSOdA+mDeFVrYRlWmW1Gsew2hwlXS3XMfc3TA5XZpMg
6Ky6TTjuLeEqL81TAu8l+uQ3aVymKZjuF1stZrmEaHYr1yq6mWv+7mdb6rIxuFpYim6nWo5mHY3C
74c19ZOGfD94+HBM449rYewEjchJbtTwxg3PJY6rTB/Ckuvbjcv/AJf24TZMXD/ZSCgbZjKlp0gJ
gSQvVt4ZjarDM74WwpG0HEep1uitBsm3bRO1pAiFNtTD9oW0GtJkfNTMYB05hGxl7EKRrIa4CSo3
MdHaBt+SsUqdtN9VGxpyiQSp2zm/ostxMQAyAb6RshYZda/dPd0wRfmmiCRrsYUaPmEWaP6JhY3A
t10TGbkkTvF04Ii39UBMaXEwAP71VhtHMA23y0VdpggXVinVE/hJ0vos3bU0kfh8zYbdw1TGg50w
J7pOrOjW0bJg8kiC6Fny34S08PcBzdrX0QD0PIgdRomFZzRIJA0hO5+c3EO+aeU8fSzRouryT6QN
bqJjSfhhSUmVi3003GNLQCpWNc0ONRzROgF1nbUm0MOa6Ikn5BJoOYglokW6oms1PqaQOSLITBlo
jQK7NFTI/FEfkiALQIPyOpQ02kEwRcaI4MTN+ygNhiZjkpAQIBgFQh0NgaxEaKWm2xzHcWUDlw0l
Ql8AXB+akMNBk2JUFc5mktMgHn+SsSo61V0RI6KjUbMkzIRVHakmBoqwJDjJ+dl0kcrdpGgycsTP
dGASyLTPP6qIEE8uu6INyzcD2lVk2MeaVAj8TvTB2Wh4ewzQ5hJAMalYtV7q2IYwR6RJtqV1/h8C
m5sszEjWFz5brF24Md5bdhwCkDi6GZoyUWuqkddAuZ8WYh9fFudlBDnyZMWF/wBF13D2OpcOxeII
H3kBtvwj/VcBxdvnmp64uGgbkkyfoPqvLxTeW3t5brHRuFiTmdAc4zHJdVgG2AAIPdc9w3KIbNoX
ScNIEEiQAryVOOaalItgxoNkPEHVW4CsMKXirlgFurJMF3sJPsl5gFO4IM6hVeL0vM4dUYHOAL2A
31Ga41EzyXCTy6X0o8Fw5pEMyj7O0ZqZ/mOl513PKSttpLSYDQDaBZYnDKTm4+rUeHuimGCoXTHq
+DpYA+61w4NadJHJXL2mHpI6o+dTM2ugc5xmJNptdVeJ41mBwjq1QOqGQ2nTabvcdAOXfZcLxDiW
Lx9WcRWLqY9QpMGWm32/F3K1hh2ZzzmLuavEsLQq+VVxVFlafgLpdfSwuo6fH+FzDuIUGzpmJH5h
c3whvE+INL2ZXDOQa9RwaQfxZTqTEDS11dqcDxWEoCtkoYtrDnqUy/RgvYEbC9vkrcMZ4pM8r5jr
aNenWafJqsqZbOLHB0dwNFIScsi64qo3DB4reU9tWMwrUqkkHYy2LRubHqtvw/xV2OZiKVUHPQc0
Zw4EVGmYdbexmLLFw15jpjnvxWuWzMX91R4tjm8Mw4rVmVagc9tMNpxMmefZXMxE3v2WJ4zh/DKI
dF64JbNzDXaDc9FMZu+VyupdK58UUvTlwNczpmqNF9+aF/imqzLHDXAkWzVr67w3suZDjlNIOa1p
dNwYkdRyXT8N4JgcTgMJWxFKrUq1KLHPLqzxqL2nnsu2sZ7cJllbqIqnizEtYHOwNJgJIOao50Xg
aC9/kib4rxpIDMPgxPpA9bpPzEqHxJwrC4LhtKpg6OQiuGvh7nZgWnWTzAWE0gVDDvMAtJbA3gwb
gyr1xs8Re2UurXqHC65xfD8LiHNDX1qbXuDdAYvCk4l59PhWKfggPtLaZdTloMkdD0lZvhJ7T4ew
zQ7MKbqlOR0ef0K2KjBWo1aLhIqsNOOhEfqvP6yeje8XFVuL8co1WsqYo0w85WkUGNmBe5F46aK1
T4lxSpw9zWY6pWxFZ0MyATTDZn4RvHLcXC5rD4vEOwzWVq5qW9WaqX6CLg/mL7LpfA+ILOL1KRJi
tQIJm5c0h3ygmF2ymnDG7QYnF8Rw0ur4riTXRLoe7I0G4lwGv0Gl01HjvE8MKc4jFPqXinUIfmaD
rdsknm0wPZd5We4M+I/NeaeKsMzBcWrNoUslCvTFaBYA6Oy3sZE+5Uw1l40ue8fLrvD3iD95VDQx
VIUMVq3LOSqP8pOhi8clo8XwTeIcNxWGfEVqZYDrB2t3heV0MTUwuIp4jDhvnUntqAgXluo94Ihe
vMhxkTrPss549buN8efaarhm8Oo+Ux/2KjVoVaYcHkARYnIQYgWmRe11v+CQW8Or4Mkk4eqS0OgH
I8ZhpbXMsfjmI+z4zFYTEA1KYrZjMBxaSHMgkHnBtCl8HY1lLizMNTf93XpuYGZAIe2XC41/EPyW
75xYnjJ2OMrDBYDE4p4tQpuqQTrAMD5wuFfja+IYGMosokUwXkPNgBdhmYbc/XVdJ4yr5ODCiASc
TVYwwbZR6nT09IHuuTp0KrMVSouwwYC5sFrJ1MTmkiJvE9TorxzwcntT4iwPo5GtFNuT0vIyl1oI
MWzA8vdegeG8d+9OEYbFVD949kVAL+sSHfUH5rz3Fvr06tSkSWgPIexzyzI/c66ggiW7WXQ+AsdU
NbGYWs/OXAYlhzF3+V4vv8MhdspvFywustK3jLh4w3F6lds+XiG+eWyBlcPS8idTOUx1KyKLyXug
mo9xMOEl2xgGJvz1Huu78W0fM4O+symypUwrhWbnkhomHGBrAv7LksNWOSrTD6jqTh6jQBB1Jb6D
peYAnYK4ZbxMpqusw3hrg2IpU61NuIqUqjA5pOJfdpFtCNlZZ4X4Kxojh7CBpme82/8Ako/CWIjC
V8FUM1MI6BJmWOvrpZ2YfJbcXsDZYuV26SSq/DeHYLh/mfYsLSw/mRmyA+qJiZPUrQaQC63aVXG4
APJE0mSp7WTSnj+DYHGiqatIsfUkmrTdlcCdemoBgzJWlhnVPKYa5a6rHrc0QHHoqmLYX0g9tQ03
0pqNcASNDMtB9QibHouZ8NcTr/vl1PG1jVbjAAxzswOcSWgNIES21hGk3V1uJuSu6p1A5xBKs06k
WB+ZVBpFpBP9FYpkTBXLJ0jYouAaC25VsOIyuGrSszB1JkASFfL5boZ3XBK5fxTSjilSpAaXwTHN
ZDdRYmy7LxHh6dbh32hol7MoMLkZkkDQ6r28GW8dPPyTzshBH9EzRMm5RtIOxlPBiYt0XW1iALCd
LlO1rhHqAB6os/z5ImkG6xapBnKoOaZ1N2ocCpLAWKEOPRc61CoULlz4d0R1KgaYyhJrnX2HZE6k
XahcrGpVfzCRBagc2dbTe4Vh2HgTZAJBIcHH2lY6tSoW4IOMvPyUzqdBgM2HOUeR7vhbHdBUoPeD
JCzo2haMO5xDTc9U/wBmbPTqVC7CUyYc5wMzZW6TabWBsO900u0Xltb8JsiFPMImPyUji1ux+SAv
Fo76KaNoH0huJ5KnisI14Ic0Gee4WgXTuJUNSYuLSkHFce8HYDiGGe6hSZQxgu0sESeRXk/E+H4j
h1c0cVSdSqA7jVfQ9Vs3gkbrK4rwnDcUoGnjMOyqzrqOxXp4ue4+MvThycMy8x4C3EubZ1x1Vmhi
i0k0nROoXXeIfAFehmqcKd51PU0nfEO3NcLicPWwtV1OtTfTeNWuEFe3G45zw8tufHfLpuH8bfSc
GueWD5hd54W8e43hDmGliCGHYnMwrx2niC2zhmCt0cS4GaTiOkrjn+PK9PH+Vuavl9NYXjvhrxXT
DcexuAxjtK1P4HHqqPHPCWO4aw4igBisIbtq0jmELwjAcVNFwJc6mdZBt7r0Xwj+0LiXBYFOr5mH
OtN/qpu/ovLlxZYPTjlM54WngzBmeyCJ3Ec5XeYXF+GvGTfuXN4VxQ6sf/DeehWDx/w9juDVS3FU
SaR+Gq27SO6zMksYQYHTPum8oXkH5aIjAPpdGyjD9TMjmFpDmgyfw/JJMHwPi+iSvlnceNxoN04a
eXsnDTylO1kC5idF9N8wTReCR+aQGYSbp2gAgnTkikbTARYdrb7KYN16jQqNlyeqNjSBcqNQbBaC
TaxspGutvPJM2npropSBAF1FkBYGJn9UTDG2o1QwADBjkTyTxUOhHeVAibwSJ580wBJgWvqmN7AX
tMWuiafnzhATbG+gRtAIIJho5zCHcjn1+aJoiZAtqo1BBzmzBGm4SBzTlE7dkoN9UhrpcaWhQSME
Tm1jmpqVVzDAMX1UAJiw68kbYJEm2/ZRqLLauZ0lzj0lWKRaAWy0HWBdVsNTpZhJJkwLQEdap984
BrARy1hY+3SeIkqOdJF2AqNvU2HXZR5szY1g7lO0321+iuk2kaBeCf6qUW0udOqhkxNiE4J/90WG
xUTadoESIKRdcgmItCjIJGu2yWe0DawgoGL40OuyrVHDK6/QdUb3uMgER3VSo+xAsf0WpGLTOBLS
4HQc0zWHNtISpuB1mOymY49N781phWqurMectIOi8hR5nwczAJGvRXswkDlpKo8SdkoxoXGNdArP
KXwj4eDUquqaOJ3uu74LSFKg6sbGAB3XI8HwxfkDQI6Bd3w2lnrYLCsg5nZj0AXn/Iy+ns/GxdLx
mq3CcCaw+mWgWOwXm2IouqPovcC4Oaalupt9Auo8ZY/zD5FM6nymwfqufa4uqOMjKRDeQaLBcuKX
HHbtyXtlpLgwdB/utzDSAOex5LKwtMyMv5LRpkupzcn8+6mRi0KL5bJ1UXGmNxWAZSOTLnzFrnRm
gHS2slNRJaBYd91k+I8XVw7cG2m5oD3PzWBJEAb91iTdat1PK/wml9n85rS4AZYbENGunXSey0W1
Mgg2grF8PYmriG4p1d+cio0D0wRYm/NapuOp3SwxvhkeIj59bB0cgLCKhzEkZT6QDb3110XODBVq
mIq06NCq4AEQ9gkAH4ptHRdHxfFVcLiqbKbWvzUoALQfXntrfa2ywsZjK1TVtetTa/MS4EtAj4bA
W1JEbQu2DjyOl8MQzgWCsP4c2teSVtB5dSqM1LmEAHqCFi+HXRwXAAHWi06e61WvABvPdcc/bvh6
cbR4BxJvlkYRwOVrXF1Rggj3uF0PAOHYrBYrGVcU1kVmsDYcCSQXTp3C1g+dhpslUfMAT2Uudvgn
HJ5Inn+aw/GRH2TANJOTznExyDD/AF1WuMwJdNuix/ErG1HYQViYYKryAQLAN3P01TCeVy/zXPF9
EjJUYXAS5s1ACJECWiJ2Os2XZ8Ch/BcAQNMOzTsuPrOoBxe3C4eqA3MRIAJMaxYi4mIMi4XX8EdH
CsIIAmiyzRAFgumf+XPj/wBK/i2i6rwOsxlNz3h9Nwa0SfiA091xtKJAAcKjSQ+TMkW0GhPchd5x
5pr8HxzQ2SaDiOpF/wBFyOJwxcw1/sTqOZoIe8EDLoIaNCd8xKuH+U5J/Z0/gqsG4HFUZnJXDok6
OaOfVpXTB8AODlx3gt3+JxjQWva6mxwcCDmgkX9nBdZTdIJM91xznl2wvh55i8M6jxLG0qYY2MRU
DATc3JsNybbqfhld3DcbhsWWscaZkgOtDmxlMTlJzddFP4rouZxvGPkjzWU3fF/kiY/9pWHWrGjQ
eTFruBvf/buu08uP+XV1PF+IqVfLdgaTZMANe+o7NsIACweJ1sdisWcViXU/tLYY2mweqlyaGEzM
mdzzXQUPDuCIe41sVVZUZ+JzdDF/h1iLqrxHw21lB7+G1X+Yxstp1d4GzhEGBF5Vx6z0ZTK+0Hh3
AfbeINGLxlFoYfVhiYqVf/Jh2IAE6kAL0Wm+8RebheRNYKrGeh/lF2ZuemWkyNDf2HNdn4O4liH1
KmBxr3Oc1uei6ofXA1aZuYBBBPULPJjteLLXgvGHmYTiWHxVN2UVqeR4tdzTAtN7OWDRr1qeIZjQ
9jqmHqMeCXRmy6gAmTZpHvuul8YtD+FsrPJAw9ZrnEX9LpYdxzG65GlVc1ktJbaXZWywT7QJ5pj6
XLxXUeN8YDjMMyi5xp0qJecsic9xfT4WiR1WN4foOqcfwTXUXNoMe6sASI9IkbTqWx0VLFY02J8p
j2tY0PbIDmtEAE3sGkCRGvRbvgplKpjcZWosIpUaTKTHOBBuZcImPwi41W5NYsb7ZKvi7DjDcYxL
3YYVKFZrcS6DlifS+YuZI5/iWfwnH0sDxfA4gPcWNf5dQutDHek7mbEHXZdR44oNfwunismaph35
RDos+0GASRMfNcdlpnMx2XI4fjAeSYiZjS5jqLreHmM5TWT15lJr6b6dVuam4Fr26gg2P0XnZwJw
mIrYY05q4d5psayz7GAQJ9Xpyum2q7nw7i/tvCMNWM5y3y35iJDm+k9JtNua57xqz7JiW42n6fNp
im9w1D2aHlOUnY/DssY3V065eZtDwjGM4XxKi2p5rMNUc2j5rgRT9TQBsIOYSSdtOZ7U5tO9l5zw
2l9qoHIadSmG5ajqjxBhvqIJgzeBeBA1Xd8KxTsVgKVWoIq/BUEzD22MHfnPVXNnCrvmEN6bQkHg
6ackB3sPYJ26W1Kw2np2IM9dFynEcHUwDcTlwNGrhWlz6VZjgH08xkZhEgNdJBHuV04e47xCyPFD
an7u+00Xim/DEuc8uLSKZEOgiehuDotY1L6a3CsV9swGGxLhBqsDjGk7x0mVepuk2dF7iVw/grGu
pY2rg31mVKVYeZRfJlzha94ki8Dku6wjGG5iVjOaXG7jQwRY2Nzyha1JuYZiIWNQcG1A1jYI3WrQ
eYNtFwsKlx1HzsDXpAj1MIheekEEhwhwMFehuc4sfk+LKYB57Li+JUXNqNqwPvhmcBs7ddeHLrdM
ZTcUGtkzKNtv9UbJnWylDZlem1yiIttYQdlIwAm/1U1NoOsI20mAkz9VzuTWgeSIg6KPI1utwrhc
wNiQR8ygy5rikO8rGxWaCfhsp6bwxvqPYIahc23lge6gBJPqBJUVYJ8yw0UfppuEynY42AaZT+U8
kuyuI5LKpqRpuAg9pTuptveyhY4t1pOKlbiG3lhb7LNixH5DRMR8kwpkHdTOfsG2O6EsOzgeiyIH
MN9lA+mdZVp8jUGeZQOJykNBPJRVMtI1FjdCbTsdVI8OdYiD1CjNNwFz8iqEG5mdVVqsI1Ha6tAx
Im+/VQVRsUVRqCY1jmsnjHBcFxSkWYygx5izohw7FbD6V9SmdSlugJWscrPMZsl9vI+P+A8Thc1X
hrjXpC+Q2cP6rjK1Gph6hZUa6m9uoIghfRDmDR4IWNxngOD4lSLcVQDiPxts4e69fH+TZ4yeXP8A
Gl84vEWVyLPE7K9hcW+mSaNQidQd1vcd8EYrCZqmBP2mkL5fxD+q5GrSqUXlr2lrxqCIhemdc54c
N58d8unwPG6lB/xZDPOy9K8LftQxmDpNwmODcbgnek0q3qEdDsvDmVyLOuFcwuKdSvSf7E2XLPgl
ejD8nfivpM8N4H4opOr8AxAw2MIk4Sq4NJP+U6FclxLheM4dXdTxVFzHN19MLy7DeIcXQc00agpP
aZvv/ReqeFf2kOxOEp4XxDQbjsPEDMfvGdWu/RebLjz4/L0TPHO6jObMWv2SXcDhPhriA+04TitG
lSf+CuCHNPIxqksdz4/+vnQE807eZ+REJswabSk0w/1G6+o+aNsTdrY6qWmwGJblj+qMGmy+YEzo
Ao31CQYhqjRzAdoCfyRtcAPhHdQgtGrj7BEIkCbRMlBMKwsBbeQkaxINhZRhsPH4raxqiALjDeWv
5qKIVXSTYmdEWcwTEDf+qFreQieSICLbfNA7dBLu6Jrbn8IKFoPwyINhKNpBBkSO30UWEIkfWCjk
ERlkdSmaQ7YAQmBsJvzUUQNrNGXeN0s5JNonWUwBvptoPmitfr9VATLu+E9ynLCAC13sN1NQp03M
JfXDRPKSrLcRhqUhlI1HR8TrKWtyfs2EpPc17i1xa1pMRuqzQ0fhHdWH46u/MA/KNMrRCr5v8oj5
qTf21bPodHK0306bJw7UdY6IWkETbTXfundZtmwdjyRlJYSc8kdNUhM+qANZhDltcDMpWXAGVp7q
Kdhnc3MFA4m9zEbmyN8ZTaygmGOgzeCZSCGsWwYB15KmS46EzOs6dVPUdMwYjldQSQOultl0jjRt
dlHMjkiDjFzc80FMxM6zaE5c0C066hNIKrJaQHdt7KjUPnYoCSWt9JVmo7K2SIi4EapcOpg1BmaH
EnUaq+psk7XTe4Qyp5QLQWsOp5rrOBOFKjjuIPgik0UaffmsPCU3soOfUMQNAtXFu+x+G8LSc4tf
Ums7nfReLL+10+jhOsc7jsQcRjnQJy213cY/qroc1xDWiMvMLKwoqOxDX52uoyXQDvoP1WpSAzaS
Z0W8vHhnHz5X8NANxtZWqZDHXEQqmHbuJPUqwXMcGhszzXKukT57mwJXPeJ5fXw0HJ5dJzgSDclw
EToDbfZbtMy0zf2XP8cw76uNq1y5op0qTGXcbkkmIFtOauE8sZ+mzwINGDcaTw4OeJ9IaQQ1tjG6
0DUymNh1WVwGk6lw5oLmuLnud6TPtKv+Y6OusrNnlvH0xeK06tfjbW0WMfVp0GlpqvygXdqN/wBF
TxjMZTxbfMFdjw0Nz+aTlFyA4ntpyWpj6mCbVxLsXTbVtTBaaedxbrzgfQ9VWq1Hvo1qeDwLmPqD
I17XeXodL67/AFhdJWLI0uEhzeFYMGx8lm0bK86plpviSAC4ibmBKr4Bo/duFGX/ALLBfaBH5ynx
tanh8FXrViAwMIJJ3ggATqSVj3W54jKw/io1MsYNrc0GXVpAnnDVo8J4tUx+LrUnUqTWsYHgseST
6ovK42hXpBjIY9joAytmG2vBJm/I2XR+FWtdxDFPp53s8hgzOtJLp09lrLGRjDO26dJN41PQrnvF
tQMxGBbmECm9xAAJIzDSe2q3cRiaOHk4jEUqUCfXUDbdtVynF8ZhcbjXvNWmKNKn5TXfjbuX5dSO
XTZY455dM7JGTiK0seX5SCSYBBjlE2j+i73hNQt4VgjIzfZ6en/iFxGIp4eriDSFZtGiW5n1S4kN
1BIjUm0e/VdHh+M8ObRDaeIJZSaIDabzDRYbdF0yx8OWF1W/UaKlN7CA5tRpaQTa4Ihc7wytgRTw
1bAllB8RVpecSCBuW6ET7lWqfiLh4Y54fWLWEE/dEb9YlZGEYyizI+nTdTqOztl5Bpgkw4wfTrod
TOoWZLJpu2X06bh+LqV+KNyswzWOa8VPLuXOLQ4G8O20I91sh2V2+i5DD/4SphsTh3vqYai+cjXN
yZLt9JJGszB5bLbwfEBica6k2jVY0Mzio42MRI05OCxlj5axy8aZ/i0OqY3BB9VjGvY9t2TeQJBk
RY/Jc1WY15YxrDVqAZAMoLqlzNgO1rm8Sut8VMpnBUH1oaxjyHS3NAc0iRvNtVyzg2q8NqOrPJGZ
tQUy05RHMTy053XTD058nt1/A8R53CcG8i/lhpEnVvpPXbdaAfLhE5idFxGCx+Kw9PyqWIysY7zS
wMa45SZLZO5vCkHEMdWNYNxtQ0C74n5aWVpuJIiJ0iZVuCzPwiq0adKvX8qlSdT+0OY18kmA82kx
a30hXeGGvT4tgaz25nNrU2lxNiHem19IPXZZ1CmxrYogOOfLAYcwg6xGk+5XVeHeFVvNp4jG0HUK
VMh1Ok5xu4fC7LsO9yYUtMZ+nQ42g6rg8RRpOLalSm5rXDZ0WPzheWtqufSGYvdYPhwgkmcwtb3O
wXqr3gNOWZFx3XmvG2Mw3E8XRYxoy1S9rmEMLQ6CJ5j1Ov8A0U4/0vL+1J1V0ue10Zn5iR6ZOu1h
C7LwOxzOE1arjJrVnOBM6NAaPyK5R1A1C59CnX9V2w177C1jlvoLkbruuAUPsnB8FSczI4UxmadQ
4+o67yVvL1pjjnlfxmHGNwWIwjrCtTNOdLkWPsYK4DAUXVWjI8sf6iWk5fVoQXDcXHIr0Sld0jWV
zHFeCY9/FMS7B4ZzqNRxe17XsaPVct1B1zfNTC68N5+9rfgLGFj8bg3gtzRXYDrIhrx//r9Vucep
1K/Da4w7iKzG+YyADcSSLiLiR7rnOE8G4lhOJ4fFmjSY1ryHNNZshhs4W7z3C6wPEEmxB+fVS+9m
PrTh8BVp4ptOo6rUqUBUa7yWsh7m/gkg5rCIGhgrqOD4yiMdVoUYNOvT85rg8H1DUFsAtMEG/LZV
qHBG0vOb5jPJqOIgZs3l3hp+cW26qWhwfya9CtSxNfzWPDnGoS/ORbmJkSJM/RatlZksdBJsA6RE
J2gNDgL/AKqJrpFrJAzueaw6JWSQZ20gJqkOzNeA5hEEHcGxCanIdzSBgZh2lQec4+nX4dxOuGVa
ZxlF4eys4AEgj0OJjUwBYhemcFxtLH4HD4ykIbWZmj+U7g9jIXLeL+HefSp4unm9A8qtlHxUzofY
/mn8D451HF1OHYnOx1cGtQFS8uA9UHeR6rclvL+025z+t076h8Uz9Vr4d4yAwFk4ewlw7q3Sdnda
R0XnrbXpRmkRCxvEOCjDPyg5M2dhGgPIrTpyASDN1DjSX4d7J+IRB0WPXlJ7cQ15Itf2UrS7eCB0
TYml9mxLmxDT6m/qEbYIEz0C9mOXabYyx1RAmDO6cG+xSazebKVrYGlgpUM0A6AIwCGyY+aNsNP5
CE7RfrzWBFlk635psjjbbopmibbowwRIKyqrlImXEwnaCdCZ7qzB3uDySDROgnkptVfyTGh+aIUt
ZLp5qwLiDA7Jw1ZtVEKRaPTPuEBc8NhwBHQKyG9bkIY1iL2WRXh0+k25FCMu7QCpy3p8kJY4aT2U
VBUZINpUDmZdIhW2tcRYSge0gaIKrmiLAeygqMkREK1lDrTBUNRhA6KjPfSc3clBFiLg9Fdqi2hM
aFVnATeNN0FV+4I+qq1G8pgK7Uy3tdQOe24sCtRFN7RJImFi8Y4FgeKNd9pog1Is9tnLcrPIOgCg
zg667mV0xtnmM2S+3lfG/BuKweepgz9opcgIcPZcrUpvpPc1zS1wMEGxXvTy0LE4twTA8TYTiKTc
+1RlnL04fkX1k8uf40vnF5CKzhZwnurOFxTqRmk8tO4Oi2uN+E8Vgc1TDf4ij0HqHsubLS0kERGs
r0y45zw839+O+XSYbjtenSDSXfMpLnW1CBBcQksfFj+nafk5ftpEMbO5t2QzI5DomFxPzTgi8gmb
Cea6OZQdiIROGp+pKEDsna3QSJ3BsgJoudd9EbQc02teyZtyYNuQUracklpEjnsosgmtO4sUQgX1
dyCFsDVwnSB/f9yky/8AMSo0IvNwAY2KdhmZICTg4fzFJrZJ5CUDtFpn6I2xJJuOl0DjAA5fVEIG
lo0UWJA6RMCOm6ID0TqNQUzBIsdpJTloNiQo0QgNEGVJLS89d+SjItubo6bLiZgaFQhyQ28aHXkg
BLhsIupgCSRlJhM9oaYOmtkXRmgZZ1CkAIvlPsow4zLWkxopWFzgfQ61lFgohokidOnukwHXrqmy
kSDPyRAEm8iOagkB9JFr6pekISIGqTampInoCop6hOpjVVajhF7lSVHHISRbmqtU5GzN+2q1Izai
dM6SeSYFhA27lRk5jF/bZKkRmIjNFyF0cUhbb0FsciP7lRsaMxzHMdi0lWJJBkRbUaqJwItDmgpB
FiSLNEgHU6rS4K2HNAsFlUx5leYJg7rq+HYGKTXhxmJXPkykmnbgx7XbZFA1W0MKwy6q8N/qqvjv
EgVhh6dwwBghbHhsNGKqYl5Bbh6Zg7SVy+OcMbxSpWcRlpzUI5xp9YXm4/8AW79PZyf50bBM8tgE
Dkb8rLTw7RqRayzcIA2m0fPutKkBDsxmPqVckxXqbwDBaMo+adjmGSVDTdlDjEdCjYIbJ3uSuemt
rOZkmBpvyWFxQf8ANPNptr5mNDXFrhAEE2ESO61Wkg2tHVc3xLG1GcWxUVvLa14YewA6aan2W8Ix
nfDoeDEfu6lD3PkudLvi+I6q0b6//wAqzuER+7sPDvSWSCJMyZ7q6CYOkTzWbPLePpBjMJVNWni8
HkdiGNyFjxIe0aR1EmO6xsQ4OxL6mPdWbXPph48uBc6G3y17rpWPIbfQDREXyCHQ5v8AK4WHsUmS
3HblMNizhqTqLcXUoXOU0icsncidO3uqnE31DV++xL6zgSPXUD4O8GY3Oi7Hy6IbIw+Hk6/dN/oj
Y4NnJTpsPQAfktTLTncN+HFYDhmNxYZ5bPLpG3mVQWgDa2rjf/VdvwTCUuH4YUaYcROZ73fFUdzP
6ckIIOpuR3VilDbgmymWXbwuGHXy53xRTLuNEgsb/h2EFxAkhzoAKyMQ6sKFF7qBYGF2U9TqCN27
R2XTcXwOIxOPFTD0W1AKDZzggEhztCNDBCyX8Ex2YZsJRAFgJzdImRM3+quNkM8bdosFgMfiGNq0
8KPKqAO9dcAkG4g6t/MK9huAY172uxNKgRMuaKwBdOpkCxj+q2+FUnYfhuEpVm5XspNa5ogwR1V/
MRF7bqXO/S48c+3MUPDmLZWzGpgyCZbLnktGliBrGp3VyjwbF5vvMbSBLcocxrpBmxmRO+tzuVtZ
tST80wfJmYjmVntWukjm8DiDR8zK51Orly+a1kU2OBJMtOom9zv0V/gtF1LiOGxAqsLKrKlNzZgy
ZMga/hv3COlwplN9U08Tk8x7nemmLSZi5i3ZXW4Onmw7i4vdRc1zC2m1pEbW2KWxMZYn4jhqWOw5
o182QkO9BykEG0Kr+6cIS81Kbnh0S1z7GN459VdeDBIafkbqEVIjNDR/mMJN68LdfaKlwTh0guwr
XGSZc9x1uYvzV5vDMBLCcHh3ObYEszH6oKeLotMOr0A6YvUbP5pO4ngqQDqmMwzWmYcao21S7WSL
+EbSw8eRTbSEzDGho+isOq5m6Bp0hZVDimCrMPk4uk8Ahpyk2J9kNTi2FZiGYcuqVajiIFGk59z1
Fv6Kdau403Od5br91A4kGQTPNVXcSl7qTcJjnPgmBSF43nNHbmqlTjDYxDzhcQzymyS8sbI+dhbU
wFcZWbY1g8yMxPW5upKRDiBJE62WE3jbK/lswtF9So4gAFwAzEEwSJ2+eygwniU/aWsr0KVAXDy6
qXObqBIDZiRqtdanaR1jWZWFzZB2KmpVJEGJ0XIUvFGNfSc8YPDhoEkNNR5MdtLxBU1Pi/Ea1DNS
pZa5aCKf2OoWk7+om3vqr1p3jq3u/DBFrlRAgTBg9N1y5x3Gxig6nhsRXpAGR9lbSzGNZJkCYIn+
qt4GlxfENxBx9XF0JBFJtI0hBO5PQ9L6lOqTJul/I/JT0gSDAPyXNcPwPEC//mJxtQHVzeIeWB/7
W+28norp4TjWVHfZOIuNLJkaMQS8nSDIGove87qa0u9t7K8C7THUITUZTgufTaNszwPzKwX8Aq1w
0Va2HIzZnehzpO/IDRPU8OYVzAIphwJ9Ypy4tkkTJiZOsc+aeDdbBx2GYwvOJoZAMxcaggXj5KM8
a4cyS7G0LGLGbzEWGshUaPBD5dRzcbXbTf8AE2m0AF3Pcp/+H8K8BjquJAEnKx4aCTztunhd1aq8
a4e+jWFOsaxc0tDKbHDNMiJIAHf3WVi6NVlHB1cJRZ9vBpPY8OLi1+7Roee0QtWlwDAB4eWVXuBk
l9Zxk8z1sruEwGFwdUvwuGo0XuEFzW+qNxOsJLJ6Zstb7HwbQLqzReQbc1jU6ztBr3VqnXtErlY1
ptCvDDFyfoozWF84dM8lUpOMkzBOl1KHVS0tztM89liwkZPFKTnPeSwAN9TTOo3VNkhvst91IVW5
X5XOjVY+IoGjWdTIgA2HMLfFdeDPzNgBcCCLKVuaxgnuULATYyp2s9IsbLra5EyLy1SETeB/RHTa
djdTNzb5eXNYtFa2kDuiblupgJMw2BumNKR/Ck9CsrELJvaQpIkfD8kwoPkT6QOuilbSDbvJ7rNq
om0xFyZSNMRbNfYqw0N0Bb80TWjfKPfRTaqvluFo+RSykW3Vosm8hBIFoFgoK8HaVGAd7K0SDcgR
oq5l1gAUAyANYPdRuAO8oiHtPwsMnnCEw4XYR/4lFRODZIg2UFSL3spzOa0EDnySfJFmtkbTdBnP
1N/mIUVQNIuDPNXalIObmAlu8aqq+iWCW+umb9Ugqegkgj5oKlNjb5fYqaqxjvhJmULPhAsSNlUV
MVQa90tsDyWVXw7g6WmecLeqxkb6ROltx/VUa1KabnRputypYy3MIHqlQPBExIWm7LlnaLQqtWmH
NgR2WpWVR4kaCYWFxbw9guItc7J5VX+dgv7rovLhvq11UZoSZYQJuVrHK4+mbjMvbzav4P4gyq4U
clRmzs0JL0vyCJEj5JLr/Iycv4+Lx4Am9o7o2tE3OpiAggdDNkQJPQmy9jzQTY3mTqE8CNydEMjY
abhMCNBA/VFT04abRbdEDczMxN1GHT/miyPnmjT5KKcEi9hdSNDR8Rv0UbT6TEmTsi9PQ31vZAZI
DSQTP93T5o01hRgggiQLIhYxOlx/fNRRtJEwe6Njbz+l0DTrqL2RZvTr+qiidoQNr8kw19U940Ta
kEpyY01PLdAdgNkbK5AuZ7aKG4BgyJnVKTsQFFlXKWLcy4MRaQhfi6jpio+PzVYC/McyU7Q2xJ+a
movap21ahHre/MTzThzpMOdYXuomsAkmOg2hG2xgmd0Npqbnj8TgOqcSLkz3Q5jENn2T5xESouxl
8tMctYQTkgE/rZCMxN5JQVmkTc90kNlUcYm0qpVeS7LmBiymqEgEz0lUjMkTLVvGOeVHmcQSSABu
UsztPSO11E0OABBAAG6QqltribiLrTG1sGGepxlQ4h2SiXTfqbpNc4giCGxvuoK5L3BgEb6pIbWe
EUDVe0gXOi7PBnycPG8aLA4JSDII3utyoTVqUqVOSXOAXl5bu6e7gx6xuv8A8F4aeZLalc7rjcOX
A12uHpeQ0HeBc/WF0PjDFZBh8K2wptAyzqVh5MlgZDPT77/VZwmsf/tvO7yT0miTMFXaLhAaRpeS
VRpcxMaSreHPrIIuBdSkXQ0x6XNI5bpOc5npJgHRA029IBJ3TvJphucB06wstpBVBdBInouYx1R9
erijXpucW1HNplwJygHlNl0Dr1SW6HlsquKwJqVfMpObTqEjNmbma89d5stY+HPKbi7w4BuBoNpn
O0U2gOFwbc1YaCLjMD8liM4ViHSHDDDO8udle8TPSOyJvBq8kmvh4JJu1ztbEX7JqftZb+m4+oKU
53sbJ1c4D81XdxDCNPrxmGnS9Vv9VnDgeZjmPrUjmIkCjOmwkp6PhuhTfLqzyDqAxon3U1Ptd5fS
/wDvTAZAXY2gQTaHTf2TO4tw9szWJcNm0n3+ihPBMG4AZ68D+V8SflrrfqpxwbB1ILxXqHbNWdPZ
T+q/2QN41hX1RTpMxT3EgWoka9ytmlVaKBqjN5bWF5c2CAB2N52iVVp8AwTiT9lzZrHPUcZHzWh+
7KBwgwzqNJ1FmlM3as3LH6axxy+2Uzj2HZg/tFdj6YcT5dPM01KgG8bCearYTxIMTWcHU8JSY2C4
vxN46DLf+5WqeE4Ok05MJhgZ0FJvz0RspMpl2Wmxo3ysAt8lreKaz+6xa3iCt51RtDD0fKa6AXlz
nR/7bfVC3i3EnOFOlRo1H2kMouIvyJMEG1+8wuhBIbYkSdjCJhcTEk++qbn6NX9st5423Dvc9tGW
2y0Wtc49tdDfsFTeOOvpBwOJY8ghzRTpt31BjUro27WMCyky7EDupMtFx25f7Nx14EvxDToZxLWj
vASHDOL1aRbWrkbScY4wNbx/cLpwb7RKY3brNxor2To5h/A8fWbFbEUC68lz6jjrt9Uh4ULiAcRQ
DQAI8ku001IsumAiZsTzRg6XTvSccY1Dw7TZTew4oZS0tluHaDqDrOshWhwDDmnldiMVYyMpa39D
e2q0mMEkfqpcpaNLKdmpjGS7gOCe4Gq/EVCNJqaD2Flo4DhWGwz6Zo+e3JZo89xEciJg+6K4Fm76
Qj80taNCPzTzSSRcZhKTH+ZSEVMuWSSYEzGqr4nC0XAmrRovmxDmAyLf0CajicrTzNtUNRz2fFIU
kq3R6VCgxoNCjQpg65WNbf2Cs0R94dBOpiFQY4EEC/K6nbVLmek36WstaSLhLw4guNuRMIKWYm89
e6rB7i8NY+T+as0SZAmSNUErm3BaBE7hSMdD4iR05pgQ+DNggpvac0u7HkgtNyl0gjopWuyi0Tv1
WeCRlyxG11LUNRgZIkbwpoajQCwkEWO6F2R+ZgcC4dFTeaT2gOeYHJR0XZKp8s+iwuppfS1TL6Iy
fEwnVS0y1zjI6hRseHiNQRZE1lrabK9U2s03NDyI15hG7IL8lWaDIk/JO45HgHfSSs6Bsdmccskd
1YoXBkX5FV6Zi4F1apw2T152UF3DMaPiN1byg2B1VPDlz3g8loOyFpH4uixRG1jufuszibg8tqtL
TkOV8ddFrjCAtBLy2bqpisG2agDYFQZTAWd68rNXwymOAEQSeSsUyYl5m2g2VXD+pgzRmFj33Vpn
WxBuu29udmhz6TJgbDmpGnJ8Wp2GyTcsCYkBMHEiZEC09VnaaTNd0I3hOS2bkAxylAy4579yjYLa
x2UUwfDiGl59k1QOe4NIj2Me6eo+nTM1KoaNiTuk9pLYY6OoKgkpgtsCCOqMh5EDKqtLzZjzWxpq
rjGOj1VB+iyKhdXpOLgc43VfE46KZ9IbAkk2Wq2naQ9qgxVDD1aWSq0PzCDA1QZVPFeawFpa5joh
zTqtCiJZdo7i6zqLKOEqeRRpmws0tIAHdX6dQ5sryGtO4V0ocRRBBMKu1jNAT7q46m5kgmZ0KjdT
AFxbmoKzrGCL6KF1jEzvYqy+iQCZzMPJRPpncSoqAzOZpAP5qu5xDjAgbqxaSDr2UbmTJFxpA3QU
q7A4ZmyDyVIvJBDtRqtJ4sW/K+qqFgeS0mDq0/otQVXucZH4lHUdmpF7JH8wj6KxUZ6bNykf/wAp
/oq5OVxe1tnWI681YipWHlgACXO2KqlzszgZNwFaqNIcIuSA0KCo2ziJANhfVbjISBaLk6ICIJvp
p1UriBSZuRTBKhrOu4A7WRABwEiR8pSUbXOi4SWkeO5oF7omnLYnT6BAOyRvMC/yC+k+ek3i6cGL
6bz7pmyB6QJ5lFlOguTsEUrwCCeR7omu1M9VNSw1aoT6MpO53Vk8IxApGoS3KLy6ym41MapNdIFy
QnDs2/q6JUKLqhLbHrOi0sHgDUdoYUt01jjap0WlxkWtrCuUMA6q8AO63C12cJyuBGh56LRo8P8A
LAcGy/Yc1ne3Wcf7Y9Dw9XqNLqdRp521Sd4cx2UlgY8LqsO91CoKdNofW/kb+HuUdXEMpuJxNYyd
W07Ae6dpPbXxxw+I4di8LPn4d7RzglU55mLQYXb4jjlGMlJhqGdJlZtSnTxsl+DYwm2YGE3Gbx/p
zGY6T/oiA10gLpKXh6liG+io9p5FBX8J4lrSaL2Otuk8s/HlGFAgE3HUp53BnZaX7h4lTnLhy6Ds
ZVOvgsVQvVw9Rom8goaqEEj4T2KJrpJO10B5j3hG0/hOnNGTtcADOpF7KQbag7KEAgwCTfXqiB9M
Aif0UEhygxv/AHCiLoJBtyjmk4jNeI6KGo7KHQCCVZC0NWYMExCg13OusJPtmcXG+06FA117Eaey
3HK0QgQTeDIsma4HKW5gBbVM3QiSCSjbEHnElEOHtgwJ7/0Q4YzVku1Kjf6jHSLq5w6nLgYhS+I1
jN10HDWQBGkTotngTQ/iT6j4LMOzNfmsqjUbSwxMQYtbRaOCd9i4BVrv/iYkyOy8eXl9DHwzuI4k
4jiFbFOAc2leNidgq9O3pJnfT6ocMHhtZjiQ179DvGv1KsU6TmtBgjtut3x4Yh2EZ9I7LQw9qQFr
7wgw9Bj2tJdBHRWX0WAXNui52tyIs8Gc3smZVzmTfdDUYwG7ibzdA4gVAMsD5JIbXWEPbI1RNjST
J5Kq2prAjsU4qXOU2HJNLtakNN3G2sI2VLkA9bKpSMmR9VLEdeiml2mD3ESIF0g5wkHRQNmbbXRt
qGx30TRtbp3ANyFdwTKbxLyZGyy6dct+Gw/vVWaOPAEVWAiNW6rNlbxsa7arWxETECFG2uX4kUxA
pjU81RmlWH3VbIf5alvqo30q1MS9ro2c02PusTCN9mviADDgbDos1ziHETZS0sQ8sggXsZVeSXTr
A0Vxmkyu02cFuklFRJJFpG2yiDgNApWVQ28FVlNlFrEJXE7bWS84GdSTyTktuI06qKIkGnTPMRYJ
gJAv1hNRb5jXsEgm47pmuIEXiZ7KgwzNoeqAh3lQ+PMBnujzEa+8bqN8uiyC1gmlwDnGdwrpDZJJ
11sqmCa4tI2nspHPNNzsxLiNFi+a3PELENAZAHuqVQljZJ1tKsVK0y1jT3Kp1nSLW5LphHPIVNzY
Ob2srTKh/FGTRUGPbvrqpBJaRP0W9MwbjkqW1H1TF8kwYYTMBQRLi2dd02kjQrUibWKb36Ux6hcd
FZw1ctcSDM691nCoRJFrc0wqkCbk81dbTbcbWGfNm9JGifDPa5r5GqzsO8gB5EmLAqYPIaQ0y528
6LOl2ughp9Og+ikzuAdYhVsO4gGSSd4VguDmG3qiLfmopy6RmLoGp3Rh4c3K0fNVmAeWWtOnNTU6
cayGiPdBNQJcSDpEaq/RMUxETv1VOmG6sjurDXXm0qypVkQQLXFlG8Fxcd+10mPkRcHropGuzBxA
jLqploivTcfMsCWnVXGZjZog7oKcEZrDmrVJ7bzp31XJpbwZaxsj3WnhagcD6HCbyRqsrDOFCmLk
33WhRqvrU3QSBoCspU1bH0aZ8vIXk6AIMY1z6Ac0ZX2MSocLSc4uIayoBqN1YYwNBFF7o/FSfr7L
NTxHK0iaeMq03WDjmb3C0W2JMXE2lQ8fa2jWpV2tgNf6hzUrYeCGnYR+aY3w1l58ngzUbcEAOB5d
EswqVCRoOiMNAc+rkDXOgTJvH5KQOsSQNOV1rbJqcRMzzsrGHa0Ak6n3VeS4xFuQClZRy53NaG1H
C5N9uSyJalMQCWsjqE7I0LeybCio1gGIc2o8aua3KD7K00t0iOqiKlXDgiYg8jzQ0gWiC+w6yrTq
bXaSR3QDCMI9WvMGEDZCT17apNpxoRPZG2jlsHEIqjGhjjUeA0XkmEABjT8REaKvXwsAnkqeJ4vw
/D5icS18bNMrDxPjfDtJGFpF+0uMBWY2rps1TWa+n5dUtaDLmlmYOHLop6b3FpkRdYOC479qfneW
CbwBYLbw2LY9tiNN1q8eQc5mEtGh1Chq1hRaXVXNazeTHuq3G38ROHLuGeRnAmHrx/xJxzitHGGj
xTO1/wDK8w09kw47ldHry9Zp8RwdarUFGp5g3gWB7qcFuXNnaCeS8X4TxWvRc6rw2u/PqaDzM/8A
itjhfiV+KrOdiHkEGMp1Xb4IzM49GqU3k7Ed1Tq+iWvt30VDA+IKcDO4ZOa22Ow+PpWLXArGXFcW
5ZWZUdmnNGaLncjn7Ks6AXAyGnWNiruM4XWpevDkuA/CbrLfVcCWVWljtYP6LGjQ6gBIkaX7SquJ
pwwt9pU+cZSXXvqBZFUoVHUWuAB1FjNlZGdM5zpBeRDSIcBsVBU3Np/u6tPw76fqcxwaRePzVV4y
mHXjQ6+y1GbEeUmcoB76pJoGwBHc2SWkeOi0xM6qxRwz6hgD3Ttphty72AUtLFeSCGAk7L6G/wBP
FJJ7WqPC36vMDcBXsNhqNFpBLbKhTxVV4yl0A7KekwSM13d1zv8A11x19NBtVgMUWBxFpOgUGJpY
jEums85dmjRS4YMBkkdEdbFsaIbCzu/Tpqa8lg8ExjZInlC3eFYalVHoAF1zuG4qKZd5glgHJXaP
HWU3ZcNTvzWpP2Sx1v2RtRsAANGp0ACq4vEegsw5FOk0Q6u7U9lk0+KV8V6C/LT3A/VSYvDPxQaH
1TlAsBoE1v01tWrcYZQYaODaYOp3cepWXGIxlQl7nRPwgrYHCQ0EtCehhHU6gI5rMx0e0GG4fUYA
A2xv3W1wzAGSXSXG0LUw2Ga6m1zt9leo02UxAggq6k8rFFuEa2co9WxViQ2mS6xGs7KOviA2sYPp
b9VjcQxL62ZpMN3K5Xk0644tVmKpOcDTP+qvMfTc2KgBB5iVxTOKYXCk06QfWqDZl1Ph/FOBIDa2
ek4H8QKTkyLMWrxXgWAxZJFPynH8bLfNcdxTg+IwDiXjzKR0e3buujr+IuHupHy8S23S6bCcZpVm
QXNe07cwk5LPcYy48cvTi5OoOb9U4dIOcDuuq4rwXD18JUxeAIZUYMzqc+l3Zcm4iAbCNl1xymXp
5ssLh7OS0GXD2CrYhwBdczNr3TvdBNx2Kr1H+gyAT3XSRytA5xJOU2TNvaCTshcZB/Pqja9pN7rT
mQBHK6cGC4A2BuSEs+YCxv0UbpjSNuigJpa4w6TstnhtPMLA31Kx8MzM4Xi+66bhtJrGyNuaxyXU
d+Gbu1ipRz+XRBMucGlWPFGJbQ8qiwxTpANgDVFwKgcVxhoqkBlIZ1U4+0YvjVOlmGQOL3Efyhef
H/T1X/KFtX7w0iwh4aJPU3P5qxTqm4JkqjmNR9SqNXOLrqSg8uIFp3V0zK0qTxI/l25K2ajMtnQS
NAqtEegZhfmmfHlksnudFjW29+DvMmQRANuqB1UulzjJixCFjC6g4tvy5qSjRDvieG9zKviJNib8
IvYcuaKmZceUJ6lJjHQx5e3+YBSYbDvqxLmsbzdZTbUiZlF7WMcRDXaFPcODT3Vh9XD0aApuqGqW
3gKtWxHmuBDYAtELM3WvEDUcQ+AdJvuo3OLSSJ0j/RHma7uRNkJbt+q1GaNkESCfnopmNzWtH1VY
WNtIU1AxF7osXqOGLrTAF7ojU+zVIo1HEbqRz6jaQEATyWfVY4usAJK5zz7dL4nhdbWZWE2Y/eNC
iDJHxtNrCdFR8l2xkJ/VlIbP6hXr+me37WnPyuh4i/PXqjBOovzCqU3+rL9TsrDAeYA6K6SXadph
0Qe3NOXGdZAQTA5+1ymDsx1EaKaa2moVslScxLhturlSoM2YNGR9x3WfkDg0iQrYrsNDyna6gjYr
NiynDw5r9gBIT0gHP1Mi6ggtkb7BG1wAHM9VdErQ81rGANEOBlQ1Xh4DgDI1EqEVAdExqABwAMT7
rMxLkcvLA6N1WMhku3uiqPaRIABVZzybSJ+i64xm08xJabqVjszYJ03QMBn6aKRtOYi0c1pkVQgA
ObM/khMudz6pyzLlJj9EwsZbrrfRIIq4LKjaRb6okzsFPTpAk+YTOwKlaGVJqPjMBDjF4UrWtyEN
NyJTt40aC1uVsNuBoUVH3nugYHkODjYaDkmZnALQOuqirLq7WMgC5G26mw+IDmGRe2uyz35nEAoq
JNLUQORTQ1mANLgYRh1iXWAtEqph6oqOgb6SmxL3UxFswvA3WFWTXbRdOfbRSU8W2bmJt7rHfUDz
6iZaJQGrBc55ECIW5izcnR+aKjQ3OWyLOGyu4cxBzZmxB69VytDEnzQAbE7rYwuLGcNn1aRCzliu
Na9OkHAguOXoFOxrAYGoQ4Iw24gamd0NVpNQlp9J0XJpO1jqhDJBaeWy1sG/05GCXCxCzsC1tMF2
Yk6XWjhPL851Vomo6xlRK0aeDbZzHOpnX07o34IVHHzKhJG8QQkx+I1a1pba0q2x1vV6TEKOe65/
j/DHvwbzm8xoG9iFicIqF9ABxOamcpXa417fsz25gTBsd151gav2fiLmOJHmfmp6rpjd4uhmdgY1
sjZAABmRzUDDM3Aj6KxSpNOr7i6IlpXHpAB3tKkDHm2dhAvdQ0SCSKbXEDdWCDrOijIAROUkgxYK
zTAj+ZZ1V1f7Q0DyvI3DgQ4dtlbY8OiJQWPTBtB5KUU2uZIjT3QUsrtM0ciuR/aN4xZ4dwwwuCvj
6jcxJv5Tf5u/JMZcrqI1PEviPhnh+gftTg/En4KLDLj35LyXj3jDE8SrmpiKhFEXbRpn0gdea4ji
XiDzsS+pinve913OJlzjzKzH8XYTFNjnR02Xrw4Kny44/bs8Vxp/2R1R3oabNCxKHFjUq53OJHKb
LErcVqVHBlemMkaAqNtRrSHSYmR16LtOLUYvNu+Hf4DiL25TTf2kwuk4VxurIDi4ibQfovM+EVat
V0ufDJ0XSYfGtoQGuDnbpPHhuXtNvVsBxIOaA4nkq/iLg2B41hHU8TTY+RYxcHouFocWrlnoe1pC
0sHxx7GxUq5uhWbxS+YsrgfEHhPH8FxLq2Bc6vRaZEH1NVV/FqOKofetOH4gy2aID+69XwlfC405
aroJ91er+EOG4+j66NN8jWFO/Xxkzcf08l4ZxJ5BZUJa8D1h2nddbwDEYltUOZULaNok6rTxv7Oq
IIdhnPZl0v8ARPV8O1aFNv3pbSG4F0+XGrJY6CjxkCnlLw5U8XiKWJc7NSsVXw3DadEhgJkjUrTZ
gXxAauV6Ny1jii+mHigZpu1YRMrPqVcZgoNEF1MG7TsOi6unhAzVrgeykxGHo1aMGnHcKTKRr2z8
FxXCcQwopVKeWo20ixSxXh41KLq1JzS0X6rJ4jhBg3mpROUgagqjQ8S42g8tLs7YghTrvzES1MC9
riMjTG+iSmZ4gw7mzUonPvZJXVTw8bouoNDnVZe82AUTGjO4mIJvdVCCL2UlPNNh2svfp8/svNcB
yhSeblIyu+io5HWJNkmPc10D4hsVOq9l77S6NCJQGqXanVVySXBls2pjZHiKlLO0UthdNLtNd0Nb
cK9hsNABNraclQpVAHslbGEyveM3wrOVsbx1VrD0y1w6/RdRwvCmtQGYkELnKYzvGU2G+66/gbSa
YbGu8Ln307SbWKOFa0AH6KDFYLM8FsCDutV/l0rEy5RVatO59JIWPltbmKKo7ymNteBdVH4wAwSO
t1V4lxE5HAG+i5upihhWmpWe4l2jRcn2U81rxGvicU6vWJaYYNXErLx1QYlt6ho4eYlurz0VY4pz
2ebjZp0TdlAau6uWbisY6rULn2A2G0JMKlz8JMTxBuEZ5eDYKTTYn8Tu5UAx1Q/xC1x5OAKxMVi2
1MQYMhuiD7XkALnSQdJXecbzXljpW8UbTYGGhh3F2xYFDV+zYh2cB2Frfz09PkuaZiyXuc4kklXW
Ytpk5jGqfHonNMnV8N4hjKGGqUi2liGFpHmMeBAjUg3WBUeDNzOqHB1pNjaNU1UawTBVwx0znnsD
nkiC4k6WUNjIMydknOAaeRtKTb/Da0ro4UzmAG4BPS1kgYMtb9Uswklt/wBUxAAcLqoMOdGo6XQG
NCffmmbH83SE7PU/W2klBawYki51W1h3ZKbiHaKngqEtENtotSsGU6IY0S49Fwzy+nr4sdRf4E6p
Rw9fEGQHN1WQMQH1MZWDsznRRbHzK2uKvGE4IxuhIk2XJYIPGRrjJP3jt4J0+i54Te66Z3VkalMh
gcB7Ebd0VJhDszdJvfVQ0RuRb81s8GpiHFxbrabwmV6wxm6dlOrUaCyS7eyuYbh9epTIcQ1p97q1
5foubH2UtANwzC7MXMidZ+S4XO/TvMP2os4Z5TSDUcZ1gKHyRhSTlFSOey0cY91Zo+y1mjmN1RDH
0mltYX1JN5VxtvtLJ9EK9fEegBoAOwTVaLgRmeCYnVTmi6nSFQjKCFGyjUrGQ3NP17q7NImUiHQd
76qc4N7T+GInVSigWkMdAdHNCWuDyLlXaaNTouDvVznVS+SHXF+kJ2NI+KYUrRBkc9FNrEBpSwRc
D6JmtvlHuVZe0O91G45dIt0SVdCNR0XAtbsgZ6yCQRaE2URvb80zTcEXA5qyJtNFiTprySYLSbW0
/RC0jLEb8rJ8oAibIheXDiVNTZm0IMbFC0kERMpnFzDE33uipnNIGl+qbKRqewTFxsNCBdSVHTEA
aKKAHlJgSTKkZDp0nukwNOsawnYzI/MNQb9lNiYDNSDhPpsRySLIgi4N1LRe2nXc1wBpu5KRtINz
CZYRLSs701rauGX3RhoAvHW+iGrYel3yUJe4WBl2i1PKeiqOAMEennKiyREA7WROl7fVAi0oWBx3
0gLcZGHWgkGTojYT8V5UYOUxG97KZkPEaFNkHeYgGboDTGYGZCJjxUEZr84TVHw0CRyUgICDYm1r
7KSkCDGs9VHSLXATqdD+qMOBqANFtEEjm+q/y5JiCDO3JGagJzWiU+ZrxrpJU2qKo4OIMAydUDZL
4Jv1Uz2QC9smFHlOYOAI/RWIkptyPaZj9VrYfEYSnTq1arRVrlsNBCy2TUjNAva6eo0kwD8tFizb
UukFRoLyRedQOaqV2ua+HTE+xWi5tgJHfqpH02AAQS7lquky0xZtnYbDVM2dozDktvBUyBmd8X6q
vhi71AjLutHC05YXZgCDoplkSaXcLUqZQ02arbKwMhptzVMSxgAA5FTU8I2nR+5Loc7MZO641uLb
XnKGAyZWpw+mW3cBHNU8HkzaQeq0KbKjquWIpxZ3NYStShiWyGgy7krjXuOotvKxqOGq0A57Ie86
SVl8a8Q1uD0fNxLqRFgabbuV2x1dY7y6gLXBs9VwXibAmjiTVaIc05hA1UWM4y2tiGVsBUDm1m5n
teS0sPRDjOIVHUKf2hwex2jpmD1Wa6YY6X8M8PYx4FnAFXHF5aRTgk9YWJwjEHy30vxMNo5LZwbg
6/6q7SzSdpDaX3ktLRMA6J6D3HDtc4ZSbkIcawV6DmMhr+Z5LOpvrmqacgOCMtB75vM8keHdmMAT
GyajgKjmgucAeijfgsTSfNMtI7ojTYyWgjML6Qvnv9tjKg8ZYxjMU8h1KlUeC2MljAHMW+q+gME6
q1sVYK85/bb4UfxGgzjvDAHYrDUjTxNG0vpC4cOZbe3JduC6yc8/T5+cWAelgkD4jckqLMS6Z1Pz
SqvaBIcC0qA1QCTuvox47ZErfU4iZKOmCHR+ElQGrDhUb2KnaQ4SDbXuhK3GV/Jota0+o8jdWPtb
cNh5e6Xm4BWDSrBr5dENEosz8TiATcE2WOrr8njw6Dh+Mq1Q6u6Qz8InVTjHvzk3I3/qsPEYny2i
jSgRyUlDFikAD6nR3U01MnWcPx7mPD7iLrsOB+KXuf5VyIuV5hh3Va5l1TIzktLAY4Yd7g11ua55
Y9m5np7NQ4v5lAkEF0XHRZOL4pT8l7C+ATdcrw7jBDCHEHndRYviVFkl4lu683S7dJlHRVsaKQpn
zG5I9JBXU4PidGrhaZY4Zm6lePHG4QYsGvWcaNQQAdGrruDYllKi1h+A6GdVMsbIsy27t3FW06RI
a1x6jRcLxvxJWFdwIytB0CuYqo8VA2nJa4Wuqf7vdiZLmNJKmOp7W/8AGNU427FUzla9x6BZVY1j
WD20ngjmF22H4ZXwrHFlJkG91RxDyyoRWYG+y6TKfTOr9osGeHVMO11ZpbU3CSYUWG4c2OySLt40
al4siD4BiVA3lsUjbt+a+g+dtM6tAEb7BWMO0tDXQXPIsFUoszkl1gNua1cJVbSwry9s1TYAhZvh
rHz7PizRZhiGkGufiKy2MOokqckuJLryUdNokbweSel1ujo0ycsrTEgsbIsqtEZQNj2Vyg1xIdFv
0XO11xmmpw74gDML0DgrGtwgkiYXAYL0PEkgjTqu94Z6+HZwdBYLz8rvxpsUxnll037rAxb3szQS
AdFZOMd5hbUdYc1Q4jjGvcYgMasY7dFHG1coLqlgbDqVjVsW3BHO+mHYh1mtcZyj+qtY/E+U0Van
qqkfdtOjRz7rkeJYkvqjMZcbld8MduWeel7H4x1StneSTvdY+PxLiPLZf+YhBicRNgZdsq4IAJMy
vRjg8fJy78RFB3lCZm6Mu1UeugXR5iVvC0S71VD6OXNBRw5IzVLDVXabXVBDBYGJOyza6YY/dWsK
/wDl+EJ6pBMxp1TYdgbBadBrzUdUOk63UjrTTBubfmggaDTeUGYzt/co2k/y3Vczh1teycjMLEwe
aUg63smIkkkmNL/qilYAmLqbDN0N4nfdVwLwtDA0jmZn0PTVTK6jWE3WlhS8NBZYAclo4Cm7F46n
mMtbdAaYbh4aLk6ha3DWtwODdWfq4WJC8mWT3446Zfieu6tVbh2kkucGC/zWeaRbVL3GZ0O0aBS4
2ux78TiADnpMgTu91h9FXo5hSYHTIaAVuTUc7d1osp0n0iS7LZFTaaZhjjJ3Ciw7c5kz3Vh+RrPS
DmO6w2lp16jyGOqHLvfQLQoYttV4w4hrYgOCy6QkEDQ7lTYdmQGo+wGnUrNkaxtbAohznea0CBro
mfhH/ZxWpkujZVPtBdUaagJm3stHEY5gw4o0REiNFz8x1mqzKlV7zBdN90Tar2g5JbI5pmNEy72U
7cpAEX3MLbAA7MdTfqpmtLgCJ5oW0xHTQhTU6hpfCYJtKm1kINcWxNkYp6QSfyT5xkOaSd4SDj/Z
3UUsk6TGxQhozbBIEkEi3JEAZB6ckDCn6nf3Cc0/5nWSaQSZbqVJSaO/JXYi9Q0J9kwJgyDOpVgM
BBESehTCm2LDbQ6JtNIw4z6CRF9UwBc7nKki8SR+idkG8z7IAcTmdB3R2y3Shpc6ANUzpLryQOqK
QqZTBIjkp2PLwW6SZkqrcO5kaoTVJIBMDYBNJK0KrhTpUyD6iNE9CsaLhTqO9Dtb6HmqNeqSWHXK
0CSoDUdmMkwTupMdxe2mni21GktNxseY5qt5pBvBKsYXGA0TTq6x6XfoVXFI1MzuV0x8eKX/AIlZ
LmzOsWUtIOdECVWonYWVkPcGjrrCosjBl0Oq1GMHU3hRFlCk4ZXl6j82HS71d1DUJJ9N2j6JIL7q
lNzTAAteFTew5plKhJ3MjRSGS2HJPCeyaA1gdNzeCma4gWNu+qTQxrDmJB3BTtIAMSN+aokYAaQN
9VNSaGvERYT3ULActtApWnLnJ3EafVQGHRoR2Sa0kSLRoog4wAAcquUQMrcwJtOqimDIM3hE1rZt
eOqek9z2uLhvspHsy05bpz6KbEDRDnH0gSjb6SDBvcIRTqlhIkAIaBuWuFgYEq7FhtTzPw2VzDEN
1u4KoGtpuMX6aKzQdEN/ETKzaL4eKTMtQXcLSpsG57m5XMynNAUTagqPAOostDBhodLhOwXKtBqm
oxsUhLt1fwuLq1aHl0mS8G7jYLn+P8ZpYCrTp0WZnP8AiI26KHhnFxisTTw9ap5VEu+Fo191PJp0
FfEYyvWdh8A4vqx6qk2YsGr4WfjcQXY/GVJBzHKdegXccPpYcOyYIgU4uBqSq/EcGzBsNZ7i5gkm
LEe61j48uXbzp5n4z4U/AV8FU4aKrcK4QcxJh3UqThQdVwlRtSr94RZp0legB+H4hw80xTFak8aO
F2rz2pg8fhHV6jqbTTpO9Ym+XYrXbc03j49tHgr3NxIbUIv6V1RpOaAWAALjaVem5+ekYm4XdYOq
3FYSjVsczfkVyaz/AGVIktGZogj5pzhGVXZmmHdFPTY0mDHZTsFNoOsnkq5HoFzGFrwLC15lSwHg
gBQ0nAvdJkR2VhjWzeYURWqjK0uabL5+/a34ixo46cLTxL6dBrCcrSQCvorEgeUb/RfMP7YqDmeI
XVIM5i0nvdez8T3XHmv9Xm9R/qMaG6jzIqoh7gPZRr3x8627E1xG60+FYPGY0vGDwteuGDM7ymF2
UczCywuq8A+IsRwLi4fRqFtOqMlRs2cFMt68Ncd/t5ZJAObXMNkVCt5FM6ZtF1PjfgIfm45wlpfh
apzVqbR/DduY5LkPjYCNzZYxsyjtdyp6BJmoZJ5KRggl9QmdgmpEEaacgoa9Ql2UStHqLmGxMuyt
u3YclepuIdJtKxKPpiQZnmtD7VkpzqpYS/tqtrVAAc8CYJ5qxhT9rIph2c6Lnm4t1U5HOhp2C1uF
VHYYtyAOOxCxljqNY5eW5U4XSFE08RuLWU+A4hSw9MYMOeXsHoDt1LhcS9zJqtDieaHibTTpmthq
INQXXm3vxXpnjzG1huK+dhmyILStPC45oMudfXVcThcc99AVTSyu0ew/mpzxOqfTlbk2MqfG13d1
iOPURh3BpzOauW4lxim9zm1BAO6xa+MNMF1O5iSsPiGLrVSc3xbWWsOKOeXK6D95BhLWVfSElyQq
VDtPWUl2+OOfyViEp6bcxM2YNSUmtLiQNOav4WiwOmpamN+a77eeTYMMDTqNqubFMaN5pVKvmVCS
Bf6KfEVBVf6fhFhAUDqRnlzWXTX6Be0X9lNTfoSmptGUFykY2XX03lQkXKVSnkECDYWWngBmLdOs
LKphtiJjRaWCqtYRe/Rc7HXGuifwzzMKalIy9uqvcGx76eGNB1osi8P1Q9habgi/VFxLCCjV82jI
G681v1Xoxn3GfxWqSXGSDrYrFGIDMtauZpz6Gn8R5lXOIVM9dtAGJu89Fz/F8SKleGWY30tAXXDH
wzlT8SxHmOfWqGVydesalVztZWhxjEmBRaTzcskL08eOo8XPybuoIaklPmsmaC42Cs0sPBl91ven
DHG30hZSc/QW5q3SoNYNJPNS0mwcoBO1gtThuAa9484iDosZZaejj4tqVDCVKzjlY51/ZbvDfC9f
EtDq1UU6Y2AXQ8PwuHZTsAfZb4YG0WNaPiuYC5zLK+Xq+LGOaPgmMOX4XFODhs9tiuR4xw/E4Crk
xbC07OF2uXtOEq0hQLHkAAclx/iptHHUa1Gxy3Y7cFYnN/bS5cG8dx5qLDknm5i3tKZzSyoWuBBb
ZJkkQTPML0x4NDJGphLMA8zz0CYyWbH3TOMi/wA+SKcGTYT3Wtg6VTK2pUDg1VeGsptcH1bnYFdJ
Tr03YUtBEjmFy5MteHp4cN+aLA0jjMVSoU9HarV8RtbRmkPhptvCh8J5aT8TjKgEMENlVcVUfj8U
yjJzVn+roN/ovN/5f/T1f+LLr0cmDwtMj11nGu/tsEAcJgAD3VjiNQP4lXc0+hn3bY2CqMdckSby
Cus8xx9NPA1HucJA5EFW8Wym0g0zc6g3WdRqHaAeuoVllVzIkAysWeXSXwemXl0AkTyVjEVicrGA
w0R3KBuLAbDWNuNQomvzOMA3MyToo0mY5znSbdrKyw5iIkm2qph1rkSpMPX8txeRLht1UsJV9tN3
8h+SINLR6g6IVc8TqOPxb7H6JjjHPnM8u2WdVrcWmOkkAD5ojYxad1RpVvvBexvbdS+Y5zi4khNG
1k1Q1xtcck7agJhxPJVy4AydRzH1QvqAEEcpKaNrweHDQX1T+ZFMgRYqkx0CJBnlopGVBmEwQfom
l2sNqAumNOqssrDKJHXkqZZkPLSLWKJgytzOdpsFCLXmck7ny0wqQqgPvJRmoHF0X6Jo2kzQ47hS
UXydo5KJrx0PsiomSREDTRUTPaA5waBl2uiDAGX+Sjc+DMTCdtTMI0i4WVBUZl+E9FXqPyzFzvIU
7ovy2OyhcAZNz0WozYvYHAnF0HOpHM5ouzdUq9Py3mRpYhWOHYypgcUyoPhn1DmrniAU31vPogZK
gDxl66rMtl0uvDJbUgGHX5HZTYet/EzE3Z9VRqkNdIILdUqbyHOjlaF014ZlXKLoIO6teYCCPkqF
F4ENIHNWGusNdLKKla5uUhwmOaVNxg2tzUeb8JAg3BRtcQwhupHzUB06hLi2QB9An80Eu0shc2Ly
R3UbQBM780ExcC21o5qQXAvMWUTHtJPLaQiFZpeWEwdAir7GZmXcAeR3SfT9UTE3Kq06k18p/hs1
TjEFzaj80SbLPlUlUmmQGy6NTKPC1pG8adlUe58RpOwRU3lrpeBbXqr9I16TgxlolO1xaMpu130V
KpWEw1w5qxSrjK2QAFhYt0HZhDtIhN5QZXJMRqoS51jS0J5q1mFWkItUAvzKm1NVHmy5oGdiag2X
h/4QJCgoVslXNYxY9VNXxlPD03ESc2jQLyglZV+8JeQMt8yvUcZVxlE0sHLWGxqD9FzdTzMY/wC9
PljZjf1XRcFr0mUmsY0N/CSCs5QXXcDw7MEPNpPrE/EQbhB+6cC2gyrhZL2uAAYbk9VpU8Q51cU2
v9Ag35LHPDX4Xi9WvSqPLHeprAYCzGfLu6WGo0sNRrMbDmgWarktxGFqNq0g63wndYPDcbVxGDc1
p9UwROiVXEY3A+a5+ID2uHpafwnutzKacrjdsinV4pV4jVwmHwf2KlBDZFh1lUeNNr4V5o1KzC5z
Ye47rSw/GagdWqYyq+l5YggixSZj+FeIGy14eKRuY/NZ/wCuk8VwNemcPWdkB8omW/6LsfB2MD6V
XCuN2nO2eW6g8SspVKLaNNjcv4XN2WXwWo7B46k8yAPS49Cs9tuutx3VXEMpN2nlCgbiajgSKbtd
UqeFOJuC4jcqzRp+QfLcPSfxJHFTbXrvdmps+E7o38Zp4QOqYwtpU26kmyl4niaHB+FYrGYhwbTp
tLj15BeA8a8TV+NY+pXxNQimD93SB9LR/VdMOO5JuPcz4s4dWa5lOsHnYALyX9qnCavEy6vhqReS
3QXuN1gYTihDxlcSNl2fCONipSFHEMFRugnUL04S8fmM5YTKaeBV6TmVMr2lrxYg2IUJGy928WeC
sJxPD/aKLfLc74agEEHkV49xzhGI4ViHUsQ0wNHDQr0cfNM/Dxcv49w8sk2CZrsrgW2Iuk47IF3e
WvSf2dcccfMwWIOenUn0nRY3jLhLeFcZe2kwNoVRnYNgsXw1ifs3E6TxsV6V44wreJ+H6WNpialG
8rz5f0z/APt6+P8Avh/9PM6NswJumAzPJMTYpqUnMQJjUo5DGTudl1c0byWzqeV0VMF2tukwEVJu
Yy4CNlIHNpGXCZ0jZEkWcPRa+xuddNFpYaMMRH+yo4SqXOkCCOS1KOGe5oe5wPORZc8r+3XGfprc
MxMHPUcCRaHKxiuKh4JpiBoQFj4akXOFzl3WhTwVOYk+65WTe3aW605/FVa37wbU81zKBPqA2Wrg
qlKu/wAumS6NCFLxHh7TTLADJEws3hJ+xVBQZRea8yHQtWyzwzJZfLpmcNc+m7KyDoojwZxJ9Erc
4bixiPLAGV4EPkK5Vr0aLjpy915+9jt0jmW8DeRPlN+iS6ZuLYRYgDskr3yTpi8Wo0nPdDZDRqSr
lZzalIUmiALWGqLGBuHYKTDPNRU2nKSbiF7f+vLJrwjDS0wIRio4agXUppkgWSa0ZoIuVNrJpFoJ
PNTUsjhrE7Sk6nMgEW2hRvYGt9NiVD0tUm6wWkSp6NE55CqYZ0QHXI1WpgwA4KVrHy6Tw/UNMw+P
6Lc4nWp08I+o+YhZPCqQ8k1XGGNG/JUOK41+OrChStSGp6Lzde2T1Y3rixqlYk1sQ8kOd6W9lh45
+R+YkQLrX4nWDqraVP4W2C5zihNSuaYkAa3XqmOnnzy1GfUca1VzrkkqWnQ0zfJSUqYY3kfzRtBO
osum3lmH3QhgAtCmaDJEidL7ImUyTIBPKyu4fBEDNUiNrrO3XHG30HCsDTMA9dFq4cuIbDbTsmwN
Kg5+VwXSYXhQeBlbY3suds+3oxx0HhJLnBnytqulqkURmdExZDwThLW1c7h6ReUXicNDfMp/CNVn
5prq6TG+2Pi8fIfkcAPksDiGNIYRIAOpSx9fKJF52XO8WxBDMqxjhumWeoqYyqK2Ic4Dp0UbDvE9
rKLDkuDnEEkmFI4AARPNeuTT59u7si7e/YqTDUX1iGtAJcodY+q0MFifs2jPV+SUx9+Wr+6amHwo
e/1EckNHD1Pszqub0kxlNiVp8Mxwr03txBFxurVKjTqPYJim0zE6ry5Z2eK9+GONm40sNhBhOAgO
IzOGYgrF8MHz+I4is5w+6aQ3uVd4/wATYMGWMcA0jKFncBrUcJQq5XBzn9Vzxl6237bys7SKmJDW
mo0ul0m43UAaQdDKvVKdEEkvF7kI21cNlILhay6y+HPXlHg8ky+couparmvectgNFHUq0RZrhA0T
PxOHbSaS8F0xHRTVJYc1IkFp7K7w7DvxkxDWbuKo18VhH02uDwHb3UtDjFGjTyNI+eqlxys8RZlj
L5rQ4rToYVrRS9R0cVnVa7Q2dAfyUWJ4vRqakHrKqVeJUHiJA5K48eUnlMuTH6XGVwSQI5qSk54f
kiZ2CyKmLpOObONlYocVpU3Zi4SFq4Vmck/bXBc2PQQFP5gcGWLSSsd/iJhEW56JVPEFN4EgfNZ+
PL9Nzkx/bcqVGG0EBROcwgkzysVifvxhkzB580LeOU3tcHDTmVJxZL8uLo6Lm5QBNxuLKxSAp3fc
Fcxh+NU2tgx81ebx6iW69Fm8eS48uN+3TNxDXMykBztFC6oZNtrCFi0OOYZh1U377wjqgd5mU6no
sfHlPp0+TG/bTex5aTkNlXNQiSbHuox4hwzXRn9O91Ur8Tw1asSKgB5rWOOX3EuWP1WrRrt8oi+b
ZT4eqC20ysSlxLDMrNmoMrjdWKHEcNeHj8kuFJnGs90jTqbI6Z9It7wqLeIYc03feAFHhuIYcMyu
eCVnrWu0WK5AEtiFWpVg15LhLZiEVfHUXt9LhGuqrCpSd6g4KyXXlm2baFWqypTkNAI5K/hGNxdG
jRJMkOaJ+YXOtrtDgARyhbfCMTTp4nDOeYDam/ZTKaWXbFqnK4g7GE2fKSBtaSrGLNJ9au9rwQHn
3uon+VVOam8TGnJalTR6NUF0GOhVg1QCS1wJ5Gyo08pgzbknquZlIzSTumk2u1MRlYC8KSnWYRIJ
tdYgqFuYZ5aR8irOHfMAOaB3V6pMmvTrZiXuPpHRSDGSIa0AdQsehimOqup5oyqSviqeTKwj5rPV
qZRqw4sLiWiQqdKs7zctYAQbOnRU3cRpta0F46XQvxdJ7QAW2VmNO8bdGoHVMjHDL+J6emzMHsaR
AMidFhUsbSYL1ABopKvGKNISarbC/VZ6X6O8azHFrwHQL7pq9RwAmAPzWK/jOHJDw8EbXTO8RYMs
DnPHXmtTDL9M98f23vNDhIMGIurNCtDADcxquLr+JsIwEMdJ1VGv4rqZ4oU5FoJV+LKp82Men4fE
ssAbDWUTsSWPluWR1XljvFNZtNoqA31DSo2+JmsfnDK7nA2DnWU+DI+fF6hTrE1XvdsJhTta2oQ8
GXjReU1PGWMNUFjG02DUalaFLxkW1muaHBsXnnul4Mj58Xob6hpPzPbYawjwWKAeXNMNlcU/xewv
p5gTScNYuFP+/wChTecpkG8hZ+HL9L8uP7dzV40cJUDql2aSEsR4jZDazHF1MHkvPMV4kpGzWuPd
Vf3nUqCaVUN5Awr8F+0+WPTaPiShVPprPo1Nc7RZaTOONxVMsxdRr8plrxuvJjxg+WRVfTncjdPw
/ibsxAe05t5WbwVZySvVcFjsLi8TXZig5zRoSbQnxdfAYAOdgstFp2bae64XDcTbTkOdI7p6/EGY
ikWOcuV466TKNvF8QqYuoG4aoBluSpX1Cyi1wdmO5XOUcVTothjmjmpn8VotiX2I1ndT479NTOPa
PD1cYjh1CoL5mjTmrGJpl5AaRK57wTiw7w/hXk6tn6roBiGuaDaQdeimnG+3lf7beMuoYTA8Na6B
VzV6g5hth9V4dTruJgEc16b+3sn/AIlwjiDkdhIEf+RleWUBmeBvPde/hxkxcM7d6dDwpxJaXac1
2fBYlpESOa4qgRRLWjUrpeGVH1KYIcGjcrVs+3XHb1fhz6OJ4ccPWcCHtgwfqvOfGPAamKo1aVZm
erRu1w/7jOfcLa4VVpsAHmEnmSujwFNnEaFSlUHqF2vm4Xls6XcdLNzVfMXFMBVwFfLUByn4SqK9
e8a8FDa1XDVqQEkkGN+a8t4hgKmCqllQGPwu5r38fJ2j5fNw3C7npDhnmnWa8agr0jgPGW4jhT8H
WIOZsLzVoV/huKNCqBJAlXPCZROLPpSjyMTWpyIDi36qVlLzBImAoMa/zMdUc2+YytGix9CiyoR9
2+09UvhvHyoVc4OWIQtBLvXt0WvSp0qomxPJQ4in94Q0ZeqzMluH2iwjiHAAgXWzSe4AAussdrHB
8gGR9Fdp1KhZF4i8hTKbax8NpmIFKILIK0KI85stcJ0XO0zTcSCR1PNX8LXNIZRewXO4umOTXfSq
th1NwJHurbsNjKeGNSj5IqRqRdZmHxopeqpMHdWG8RdVbDBbuuVxrpLB8Mxjs7jVyis21QD81cxW
IpC5vK53iXnYV5xlIZibPbGoT8Nq1axYarHCjU+E8len2kz+mx9pAtb3STDh38rnx0SU8LqvOW+a
52Z0kk6q5Qd6fWLaqRmHLnG6Z9B7WkjZere3nmNiUVMukQheWm4i4Vc1i0G0FRtrjMJNlNL2W2mJ
QubJMAaJ2Pbk5n5oSLy0TbQKKCkQx5vDdJWxgml+UtG89uqzGUDUeCNTey2aTjg8N5Y/iOTJcY2h
ifNw/k0zDG/ERurNHBilhZIAfU/JYnBSatcD8Dbk8yurxVRn2JrzaNFx/wA13l7Rg4jhdMHzGt9X
NcZxzBuw+MLsvoevRDXa6maj4DGiVz/EMEeINNZ7YbPpC9WN7RxzxcYxhJIEmfdaGB4Y6sQXOAut
GjhMM55omzhupn4WrgagIBNJZu2ccZ7qN2CFFuWnJKOjQcJDt10GBoDFUs0CVZZwvZo0+qddTddJ
/wAY2Ew0lpySNyvReGYBlLBUi6C4hc9wrD+S5we0Qea1sfxMUKeVrhIGi8vLl28R2wmva/WxdLDt
cGwD0XJcY4qypnZIPRZ+O4nUL3uL5B2XM4vFufX1uT/cqY8X7W8kixj6nodsBouY4jVz1IBNlsYy
plw5JPzWA0+ZVLjtderjjx8+X1FmkMjIA21RDk0DkhbE3KQEiLrq4DpgZxYG2qmDqdJ+Z15vCrvq
ZACJBhU31ZcXOkhRd6atTiMOinYDkFNh+MvY0Nc50Lni6SYlJpM2TrKk5rG5xLibsSwMBMaqph8b
VoghjjBEKFjTAsUQGpAPVJjPS3O3ylOOrkn1ETqFEa9UmS53zTwd5TSR09ldJumNSq7dx90vvDzT
33mwtZFF4v7BXRtGA+NddLpBr9jfmjAsbuhONCTPJNJsGV0H1WT5Hk6nujykmADP5pZRpl10hNG0
eQpg1wBBNuSkAH8mlk5YCLNTSbReWZjonLHRKPKCDDTsnLRJBkHZNLtFkO2p0SDXbKXLecxATZbT
JTRuowx2iRa4TraymAhupJSh17lNG0MP2KWV43MqUtdudeaWXUA26po3UJz8z80QNTYmeYKkAP8A
ME8O/mHuml7VHnqm5LrdU4qVRo93zRiRo4J4cTEhNHahGIrAWqO+aNuMxLbiq7kmLXEE+mNksrjq
p1O1F9uxMR5h7c1I3iuLaI8z33UIZaAJITFmunsnVe1Tt4pitc90f76xhbl8wgKtk6AwkGXIgk7w
nSLM6ss4viWtIz2OydnGcRTnK63dVCBF4TAA6j5aJ0h8lX/37iIsWgqP984kj44CqZBonySND2U6
w+SrJ4viT+L3Qt4tiQbVDHJQCn/l+iZrJncwr1TvUw4niAZFR080hxPECfW7koch3BI3hMWug2hX
qdqd+NrOcSXuMjmi+3YiRL3IC030SFM30TSdqMY6vzPJC/EV3ghznEa3SbTcRYiQnDHXuJ5Jo7Uz
K9ZgIBkHZAX1Km87qQBxmCEwa699/kmjaKHblOA4bxG/JSZT/qkAYFx8k0bRw4mZJ7ogDcgyOaO4
3BCUQ3aZTRtGASPiunaNydLIo1E7QniNxKmjZg98Q1x+aIV6jQYdA7obaFwgaJb6iE0bE6vUcTmk
9Em13A2JtvKAC3xCQnF/xDrZF2P7Q+BOaeco2Yyo2S17huoQ0yTmi+6a9ideiaNrbeI4hsw93W6l
pcQxj3AMdUc7YC5VFjHA3B/0WnwnEOwOOZXEHKVmzUaxy3fKdlbin/o4k8/QVscI8O8e4ziKbDhq
tCgSC6rUsI3XoPhni2G4owAFha4ZXAbSF2HC2OfhmtHxUjkNuWi8OX5FnjT248M97Fw3AVcNw6lh
8ORFNgaAFYwtfF08R5NfDuNPLPnZhE8oWjQa4NaXASBropMrKjSbELzbdXln7b+GmvwTC8RpCXYW
plef8jv9V4zhLVC4xAK+nvFNPBP4VicPjS0YeswscCV8zYnDOwWOrYfMHtYSGuH4m7Fe38fLeOnm
5ZrLaariS2oXT7yrOC4m4G7jH93WLWcXHK2bocOSKwv0XfpLHP5bL4eicN4sGNAkrsfB3HqLsbVp
1H63uvH/ALQ5pEHZW+FVMUK3mMJGX6rjlxbjvjy78PcvEFHDcVYBTLPMGhK4bxN4WOMw72votZUG
hAseoVHhuNxGcZ3me67DhvEHPAZXOZp5rGPHlj6dLZZ5eCcV4XieGYg08Qwjk7mqLrX0XvPiPhmD
xmHfnaDTJgWXB1/DGBdXLGu10I0C9WHJueXiz/H8/wBXNcH4c+tTOIqD0dVbwrxVOIwbxAd8BOxV
6nXFGi7DkAOouLSstzS3Gio2RF5Gym93y11mOMkUWValCu5jyQ4GCFqiK7QWGHc1NxTBtx+EGLoD
79tqjRusahVNOWzf8ldbYxvW6q5UYGGATKVF7muM7HZFSeIzOHqKiqaEwCkWrD6gIkgAfqjo4ktM
gAW3WdUqlxjQDkp8MWtcMxk6XTXhns6DDUa2IAe4Ag6Ba2Bo1M4YKUrDweMNPKA+Bst/h/EjSipM
nZcctu+Omq/hVWtRcHtDW6X2WKKeKwtc4Z7GuofhePwlXj4hzPIquIB1lZvEcTTxAc1tbKDuNlyx
mXqt2z3HR4Svh/IaK5BqCxSXH061OiwMfi5cNyUk+M7sug8ioYEA7K1UYCHErMwlYHbRadOu19OD
tZeizTljltlYqmGONuqzCcrpjQrfxNPM2dteaxcTTDTBW8a5ZxJRqS23zVyhTc4gtEO5LNw7XB8i
wldBw+rTpUy5zbwmXhcPPsqTvss1Kg9Y0EJqtY13jL/EfbsquLreYXPPP0hTcKAp1Q92s7LOvtvf
nTo8FRGFwsN7kqenifPHll3pasvF48Noug3mFXoYzysI6o83ItK5dbfNdZlrw3P+sxDMLRswfEVs
/ZGinkAgAQ1YvhtvkYV9ep/EddalDFCoWuJsXQkzuN8NSbjlOO8PfhMWKrBY8l0PC6LMfw9ocAXb
FaviLAMxGDzAXiVjeGKvlVXUapiDZavLv+0YmGrpp8LwDsNiSy+TValN1Kjig18dkOJxTaLSRGbm
udxuOPmF036Lnc7n4dZjI0+P4ylRrE0NOi5TF4x9ZxIcfmnxmLNZpBcZFrrHdWipqdfkrhjpMsk9
YuuXEzGvJYmJqFtYxoTJV/G4jKJtyWFicRmdmOy7YxwzykScSxRdTDAZm56KlhTDpiVE5xe4klT0
BC7SajyXLtltap9I7pPI2i3Pkhki/wDRM4kCwPWUaRVDc6qq65KnqHVVzqUjGRkVP42xzTJBVhpi
wuDawTkgmLIKcBl3AqUuE2hHUOYaRZI6CR7FIPgW01lOHG+ioEG5i8hFmABsQNU2aJhrTZIO6AFA
REn4Lc+SQIbMt6ymzDQCE5Im432KB2uvJCZzh6oEp8zb2F08tAsDbrdAAM3ygbJy866d0swAmJJH
NEH2Fu9kQzjMQBzTeqNZRZzMQExqEAC3YBAMQfV89kUAX37JBxIsRp7IgREkC40lA0CDf6JHKJMm
LJw/NaxCWaNG35/qgGQJANo1hMQ0aAidU/w2deUxdlAgHugJoYJJ/JM4Nva3NC59hbdEHjNJs38k
Umt5C/KE2VsWhHmHOfzTOIg6E7IgSGA8oRZRGwKYOa24AnkimmCbIGgFpl1ufNMIv6oi6clt25ZA
0TEs0iVVKPVJd3TECPiS9OWYKY5dMpUDkA3Bv3SaAJgzvbdKWciLxKRy39J7yiEIOpJjcJoO2u6d
paTcH+qf0gnLPcoGEaSZ07pE+kgGfZPLMrrEHonDmkfAEACI+Kw1slobmB2RSNANLJZhNhsihAGj
pI1E7pDLliOsgJw4SfT2T5mlt2mRayIGW7tjokC0zDPZFmA27Jg6RGXoilIOxJ1SkHRsT0Szy6XX
/qlnkXHIaoGcRAIaAd0gWxOQ9U7n8h+iRcA6dT1RTAtAJLO6Rc2CMoRCpewCYOBExEKAS74iGAdU
i4DVlxYKQOAmDHNNmAAsNUAkjen/AKJBwEwyUjU3t2iyYVI2BhA+YaGmJ6pAjZgTCoeQ5Roi8wmx
j5aIECCCMoTl2pygHtom80xoLpGpIOsboELnYRyC7r9kXCuDca8R1MD4gpeZTfSJojOWw4HT5Lhg
4n5/RafA8e/h3E8NjGFw8l4fa0ibrGctlkawuq968TeF+F+FcNhqvBaBpUaroeJm+xV3w5im1cQ4
B0Cs2ekhVOE+MuDeJcN9lo1vMxAbm8tzTZV6jX4KsKtMQ6k7NbkvkZ7mXl9Xj1cNO6ZTkZYkQllZ
RpEkBrG/hCrYbGCrRYQfiEhBj6/+Eq22UjLyL9pniYitVpNk5duS8g899Sq9z3EuccxJXV/tDn94
VCZ+L9Vx15P6r63FjJjJHzubO3NK8w8Eyma7Kd7KIOkQiBuTK2xva/hKhqPOYz+i6Dh2KZSzDXqu
SpVC2Y1Wjwuu1rxItvO6xlHXjy14dvgagjNEkq9+88tRrQYG56LlG8VLLNAjko2491Z7nGwAusTb
0dpHUca475+WnSMU2W91zX748vENDifiVCpiCWPuRJ3WRVdNbMZ1Vwwc+Tl/TY4g9v7yfW1ZV+pV
etim5S0alWHUhicNVa0xVp+psLK0Ic6R2W5HK5VocKxho13sqEllTWd1W4nhhh67ntuw3BVTEP8A
vM7LKZuMfWomk8zykK6Y7fQG13Nb6TbnKcYp8ZSFUktdB7QpqbQBmMEcldJMqM1JJnc7Kak4E3uP
yVY+tyvYbDZhdsBCbqWjVcxwPxCdFP8AacQQAGwDaArdHC0jTECHBa2AwDarGtLbrlco6441ztSr
WA00F+qp1cXWFvZeiUfDorQMoJ5KRvgk1T8AhYnLj9tXiyeWPr1HOJcwE9QkvXKf7PWFolo+SSvz
4M/Bk82bh3UX75VcwwzOAJIaVK97SDuU9L4RYTtZat21MdJiAZa6VjYuiTUIFx2W+KRrssYcqdXD
ZJ8wXUxuluO2dQpNLg06aytB7aVRobTsG6lR16dNlIvbcgKq15FERF72C17ZngFRrc5OjW6BXuG5
arHBpAPRZFetmIAAv01V/hhbSbnk3Vs8My+Q45zhWDHGAbFOHGtiKVAOOUXKfEt+0Z685cunVVcG
805qk3duk9F8V01bHeVhxTYZACaljHUqTL3lYT6jyTeSnbVc9wB9gsdHSZvSK/FGVOH0y594iFz3
2lja3mUyBeVjVMe40skyB1VWniXF40ynqsY8emryOor8T8xpJdBWZiKz3mx+WizzU8ypAOltVae9
racX7lOvVuXau55DCBJ5lVar2sMyCZ1U2ZhzXWTja4B1t3W8YxldTaLGV5B9U6rMccxRVH5yeWwQ
hd8Zp4s8+1JgVmmIHuo2C6lbEQqzikaSDN02axB00MpuZuUhEeqLi6jaA+6hIU9QQbGVGWzokZsR
wnCLKkGmFWdLWELMmUyTrorMNF7j2WawuY6W2Kk86qfxlFlXRlETaLyAnBZzv2VHzqm7p9k4r1Bu
FV2vfdxYi/RIZQ05pibKl59ToiGJfuG/JQ2tgU/5xKfLTvLrHVUziHbAJvPdNgOUKm10ClF3EwmJ
pExeNlU+0OnQJfaHwZDe8ILpLAQ3bknz09IJ5FUTXe47H2SFd0crckXa4Xth3PeBomFRoJzAmNFU
GId0S89xiwRFsvYZsR1iyYvbvmHsqoxDi2IEJ/tDtw2yC0HsizSQdRCRqN2zOVQ13RB3TjEuuMoj
kgtGo0xLdd4TF7DPogKv9ocZsIOyHz3ZYgSm1WhUAJLmXThwAgNExZVPOf0PdP5776T2TYsgtvDb
6JFwE5WG6q+c+Te/ZIVqk66JsWSXXAZ7Sm9VwGiOiredUv6j80xqPMy4qbFwF38thySEwfQAZVLN
UGrimJcTcnkm1XXE7NEC4kobmRb/AFVQZr3PdMA52hKbRczHkJ5pTqIGipgHmU8OvfTqmxbl1/SE
vVplEKnLhuU4LhoT802LoD9o1RAPDYDY9rqi11TZxRedVFs5TYuAPn1RG9kwDpO45gKkKtT+ZSDE
1Rv9E2LRzkSIJ3TZXD4deyg+2VryR8k/2utzHyTYlh2USANtEvVcACdNFCcXW5j5Jfa60aj5JsTh
ri4SLaJDMCbDN1softdXSWj2SOLqgEENka2RUsGLtEW1TtDjq0bKP7dVvZvyS+3VLnKz5IbS5XbA
TpyQjPoWyOqAY6oPwtS+3VNms0RNjBP/AKf9U4AmAxROxlUzZo9kP2yttHyQ2lItOQwEwzSfQSOS
hOIrFvxW7IDWqyZeUNrJLgYA7XTSekbqoXPJMuKVzqTKhurgdeBCIObE5hIFiqQHunDHXgIsXHvG
jSOcqF1RxcYzQeV0DWumR2WnwTDOfiA9hYSwzkdupbqNYztdNTweK+Hxvmipi8MCINWmyR7r07C+
ZXpZxxd1cAXDhBVDh/iDh9Kg2lWDKVUCCxwVHjHEsCxhqUKoDiY9JXzuS5cmXp9PimPHj7ep+E6r
MVwlnql9IlhjktXFUi/DvAuY2XG/smrDE8HxT83pNaAR2Xc1KRaJzWNoXCzrdLvfp4L+0bhTw6o+
D06rzKoOQPKF9HeO+FeZhXuyzbmvn/jGGOFxb2wMpuOi+j+NydsdPD+Rhq7ZBMGQpWGb80FQCbXQ
Ndl7L015MbpYHxXVilUyiG2lVmm/dHpod1l1l0tOrQ0wTfVHQq5aTiTJVIunf5p3PhsCyml7Lnnj
y7j5KnUdJB07JMfbSQhedZVkZt2s4fGVKVZrgYAEETsmxTwXuAgAmVTJUj3F4a6Qmk2d3qEnRBTJ
a4FEy9rR1QuF7a6qpU9Zoc3M2AeiiY6TDrbQhbUNxNknNtmAQ20sLTY4eq7tlpYVwY7KT6VhYepl
gk3F1cOIAgnX8lix1xyjqMMGATMdlp4LF0aB1FzzXFO4iRpHRQVOJPBsRIOi5/Ha6zkkeo0uPU6N
Vpa63JalDxXTaNQN14y/ilSx5bpxxeo0QP8ARYv48q/PHuDPGFDLeEl4Z+9qv+U9wkp/Fh/Iieji
XFvq2KkGOJkCxVOrh6lB5kQN1C+bnlqvTqVw7WOnwGJBZmL4hRYrGOrOIbr2WPhqzicoJutPCUyI
AkzvzWLjJ5dcct+EVNrnOcCTG6hr1WU2ljbxZbGLFNtPKwDNF7LncbTILjJ1THyZeIFxFQtDbbqx
UqZGAaR0VHD2qgxAWhUIeYIi0rdc8aVSsTTFIG7tSjcQxgYCJCp0nEVKjyBYoi8ud9VNLtZeQBZ2
nNR03h0kBVy4ltkWHf6jPyTSb8ro9bY3F7qFzhSuTM21QmrllV678xAnTopGrdRep1fVmMqzUrtc
2Ce4nRZfmgNZDukI3VgQIOl1LjtvHPUT1auVrjJyjdYeIqGrUJ2VjFVi4ZQqa3hi4cue/EMEbUw0
ujC6OAm6mDZSN03JQsENvaUcQL/ko3DXvGiWa0jZPAg2umA5d1FRvk6oGugqR3soTqVWdpA4EEEJ
Wso5KaSml7J4aZg2SytKgkpw5yL2ibK0/i16JZGxYhRBzrpZih2iUMGx7J8oGpUOZyQc4SonaJgw
E6psolRZnJZnQZVO0TFgj4pKQa219FDmclLtEXtE+Qc0gwFuunNQS5IOddDtExYCdfkmyiblRAul
KTrKaTtEwYDqnygugFQ5nJgXIdonyMjX2SyNG6gzOATS6900vaLAa2DJSDW7k6KuCeacT1TR2iwQ
2NbpEM1myryY1T31umjvE/pn3S9Eaqv7pXTSdlgZL2CXogyFXgwl3J7Jpey3LAwgAEdEPpnT2VaD
pJSjqmjssZmzoiDmgGIVbqSUo6lNJ3T5hGkIcw6SoiE0HqmjsnzDoEi4W0soI90o7wmjsmztm8ap
xUEXaLKvl7ynA6lNHZYzjYDRJxbH+irgck4B5po7JrCRYJxHTuoIICUnmppeyeB07I25AOfNVJI0
KeTGqaOyx6e3umcGjoQoJPNK86q6O0TZWg3KcGnyLioASd0rwmk7LGZmzPZE17JiGjqqsu2KXq1U
0vdZJJJIDT2QzBNvooJcE4c7ZyujslzH67IRO83UZc6TJSl2kpo7D2iE7f8AxUcuM3KYAncppOyy
HiBcBIuadX/JV4Ol0vmpo7pw8A+kqRuILSHAwehVS5ulkKaWZrVbGVKjgajpIESg897zGYoaOFqV
nZabHPJ2Ald54J8D4nGYynX4jRczDNuQdSsZZY4TdbwmWd1Hp37I8FXwPg+i+o1wdUcXweRXctL6
lGXNOZp9llcP4lg8OxuEa9tMsAAZot3B4ii9gNNwIm/RfKzva2voyammbxhrMTgnse2DFpXzx49w
Qo4iq4NPpdK+m+K0qT8K/KAHAWXz/wDtEoRUrZhb5rt+NdZOXL5xeXvFpURHyUx7XCjIX1HzaVJ1
4Klmb/mqxCnpulvVZsbwv0KboXXmE8lDKijpTKT7nugBgWTz9FUDKJhEZfdAdEhqiJZ0dKF5kJuY
TgaooR1UrIywgA7JpiUSeBvBY4i+qYOJsfaVJIeyD8ShMtmdUB1HERCimZTzIM3SAkoezN16c0Qa
T2UjKcbSVoYTCZntLphS3TWOFqkzBVntzNYSCkuspmhTpta7KDG4SXP5K7fDDV8OKrSDA+ixcdgf
LGYX7Lax9ScSG0NTyTPw3lUDUxEueRopjdN5YysvhVOmB64DuqsjEspzlgQsavVNPEOLZA5BCMQT
rut9ducy14bH2qXgzI0soMa/MwkCOgVFlTQzfmpK1X0xoPopryvbwrUjLzsrFMjy3OJE85VYQAZk
zy3Ur7UWN3cZlac4ncxraVjeOagLi0wJ5pzI1JEaSVE90DWEW1KSIvoFDnuY2QtdaNUExKqWpqbv
SboCYJugDrlIunqdFDfgea2qF1SBIUZMzcoHGVrTNy0VybpwEwjojaIVciARgWP6Jr3go28kakIW
EzZG3/VAZafTqETTY8+SLC+F3XRODeNt0hrYjRK0QgjqHZQkKV5k3QkDSUZRxylICyPLzTwIMm6o
jAShSBrb7FOG+ojVBEGynDZUgYEQbJF0NIgClClLLahCRfmgADdPFlIGAgmbJsogxEoI4vqlspLb
FLKImRZBHGoShSZQOXZINbzCCODHJKDO6mbTEEkxySawEm8Dmghy7pR0MqUsGk6bpFokX6oIYT5V
KAI+KSnyDmFREG2TQdlPkaJM3TQMsA25oIgEg0xKlAEG/RPkBNjdQQxrdO0HZShovcW6p8oAklDS
Ai/VKFLlknbsllEbEqiJrU5EKYho5EQhiZg6KAMp0lPlPP8ARSZWiCDonkT8XtCKja2+ndIsNzOy
lBb9URsQAfkgrFsf0Qx7qcsE26yk2nOp1Q0gA/onAUppgEnkkBrJQ0ijdNlspALi/snLbkaWREWW
JSAhSZOvumFPqgjhOEYFkhF9+6AYSy6zopMo5jsmhvSOSALwlfdShvMjtCYtEwHWQRZSkpMo0kQn
LJaDMoIoulG2+ykygpwwEIIuyQGqlDRacqRZqhpDHyTgd1Jlv+qfJEQfmhpGGlMASpsoAnqmiTqi
6HhqPnPgmy6rhHBcJUALxmnmVy+HJY8kFdBwziHllrpn3XLPf078XX7eneHuEYDC0WOpUacxrC7L
B+WGgCLDZeXYPjowtNrS4EG4IK16Xiyixshw05rwZ8eVe3HKR2mKwOHrYhuIMCozcLQw/wBnNAta
/LUmZBXDYTxQ3FNebZG9dVHX8SYejVD6ZDubQVz+PJrtHYO4jjMPXcyq9tWiRryXnnj+pTrsc5hB
cbwr7PEtLEV3sc0ZSOa5Pj+NoFtUkZnTaCu3FhZk555TTz/EMyVXgSoSD/eiuYoB1TNpOirkCdZP
RfRj51nlXcJ5pmnKe6leBtyUThdGfQ5myWqjB2KOVGt7P7pFIG2qSKXPkE2iXySIRDtuByTi0wUL
TYjZFqdEDg22TDUaz0TuN9UCAw6AkDLTKBIW0QIgjsrODoOrOsEsJSNbMPkpmvqYJ9lLf01jj91p
0OHHRwK0GsZhmQSNNFn4HiDqzTNiOShxOJJJBMjkuWrb5emXGTcNi8V97aIi0pLMxFUl+sWSW5i5
/I7Th+HbSYatQS/reFUxxfVLo0IlDiMV5dapTn4XQo6eJaTNo3uuWr7dvHpl4vCkMDgPossy21l1
FYtcyCAbLn8ZShzomF1xy248mOvMR0qkEmN1I95ePhuoGWPJSl4APZac56CXTAhTuGeo0NMhoVUG
X9uSlpPMuOyEFVJDjmHcKFxMJ6zsxJQA21QpA9Up5oUpsiHJsk0FxgJh6jAVukxrGyYlPS4zaIUA
AZQuptBVh7rOuoDqYGnNIuUgRTG/0RsaIvKQtrHUo2RF9+irOoTabSNCiyMzWB0R5Wnr2RWAk2Jv
EKba6xGGMa7QwCnyt68oTB3KQNrJw7kDOyGocMZOhQvpgCQEbXCbD5IKjyXQCm01ERaE2UW3RAf3
CIgAGJKu06wGUCbJgGxBF0duSa28ymzrAQINvqiA0tZOBPQpwDdNmoENB1lEGCJhExvqvEJ4gSY+
SbOoQIBBBt9EsoM2+qeOmg1CcQPnJTa9YfM0Nyhsbyha1r/hseSe14BCcWba51hNnWIyADpdMQLj
LcKRombBInkfYhNnWAyybNTsYDo05eakaALmAdEi6AZBkqbp1iMtbeG3+icNA1bZO02kSnnWZv8A
VXdOsA4N9XpKHM0n4TqpWw4HbsmLWsmTPRNnWIwW5ZyaJW1DEYIiBY6SVI1s2+qdjpELcu7DKRaw
2aCDClc2Lafqmytnn9E7HSIWsBmbDZINEXBhTQ02tM6pZQBreOWqbTpEYa3qEbC0NPpnZOQByOyQ
63Ta9YaoGWyN+aDK3lfopctjJED6p4af6Js6xEGAfGCihp0hGQ1v4ZOyGeQEhTdOsNDYIyw7dBkb
NgVOCwXulLYjLMK7q9IiaGA6FyN7muNmf1RS0AkgHlZIutcDVN06QLfL0c0jdHFETrKDNYgjXkUh
lnKYueSmzrAuFO+pCHKwbOKd0AmAEQiTbUcldp1hppbMcOSQyGSGElMPhMo2kX0mdU2dYBwZf7s2
1TAM3Yfmpg47j2iIQGdU2dYA5DJDJHNM3KfwG45ogDlJlM0EyJFwm06lDTJyJg1umUowDe4EbAJE
W2+SbXrAgNi490sg0i3dGCNNuiQMjQEJs6xFlFjH1RANInIUQBA5eyVgDa6bOsBAj4U4yiZHvKMN
kwYHVNOsgps6wJAv6UobGl0RAvaPdMNQmzUDlE7pw1o2M90QAJOw1SF3WOibp1gYsLW5pNZfQ25K
RvO1kzdXdE3TrEuGoscfUCB33XQcP4bhazBNS2ywKbvVpdbPDHOzNJN/zXLPbtxyOy4J4XwVeQ90
911WG/Zzw2oB62iVkeF2ZwyQSV6jwbAsdTaS0ujmvn8meUvt7cZNOSb+y/h+b0VwCeRUlH9kuAqA
mpV+S7NzKBxUVabmNGhUDKR/eWYYlzaDR8Oay5/Jl+11HIVf2U4BlS2Jg90HEP2UYFuELm1gTG69
LpU8I85nVAfdFiaTWU3GkfMaRGUlPky/aaj5h8UeEqXDnPFMggcua4fEUTScWuBhfSHjDhrMTTef
szA7XVeJcf4YaNd4dTiLETovdwc1ymq83NxT3HMFonpHzUT2f7Ky9hY8tdPuozp0C9UryXGKxama
YUrgonBVizQgnBiVGDzTgoSiSlMCnRSbqi03QD2RBA+spgn2/omB6oHMhNzTymPVBNSq+X8KsCv5
oLXjNKoTdWcCB5zSdAVK1jfojnovgS0FS+ZI9MybK5xOmKzQ+i0k6KrhYw9TPV+Sm9xvWrpDWwdS
WkwCWykreN4kx9YZGgACEklprD9r/HAGcQxBaJBdKzaeILTlvB5LU4k3zZqfNYjjE2Ux9NZVpMqu
yyd+aixLB5c7oKD8wvtzRV3gjpzU+2t7jPdAJSIBabpPNzBsgcdVtxM2xcb2UlO1OeaiGikd6aYG
6JAm+qFMXWshLidEibOXQkxrn2AT06TnFX6VAtbYa6FLdNY4XJHQpNZrqpCQQP8AdTeW1jL/ABd1
CRsDus72666zSF39hBAE3+akIA1NkMQdlqOdNE8iUTY1mydgtcwlEhA4OoNuiJsc+yE8/kkJ+SAy
RlmQesJ2Nk23TMPPubJXuLhFO8hvwm/VREHqOyOCTsQmDDMiEShiBeU7WmbSeR5pxZ0fVPN5myGj
ARrEpQSYGqcuzGbDpCW0WnmihAtBuU8EiAL8+Sbp0RN3kjsiFJB0/wBE8bnsimNPdImbAXRUUkkm
fadEgbXRBrSNLQnFMCbz0BQ0EEe/IpTqd+6LI0RG6djO0IaDJExtokLG0ow3KToQmyhwEactENGs
AdLJxGk/NOBc3ATEbxbsoHaG7RvqmIBAM76pZdQZ1CYAhp0lUG2NBz9kDxzN9gjAEbEJtYsYRUbR
Ghn9UbXSQBHdJrTIFhG8ospEut8lENOoJ66pwADJAM6JBsCQEjYw0SihzCOSQIixN9EoJOluYT5M
zW89xCAZB78ikYkXspMhm5/0TiibWICbNI/xEEpwW3kmY3UhYdTMJOpH4iDATa6RQ28OsN0so5xK
k8qCJE7wE/k/nsmzSECw3TxDtfcqXydrJGmQG7lNp1QmBvfTROGjSSSdIUnlSNCl5R2+oTZoDW5g
Y2sYTZW2ggdeakNKNBIPIJeTOhJtdNmgFogw6TsmGUddkXlZRoQfkkKet4PJDQbdgfdIEEC/sl5X
W2tkQpxqY2shoJBuD8imHcgIxSMROtk7aZ0m+yppFlaNToNeaUCDz1UraUXmf0TimbxN+SiaRwNz
yTBs6Ek/mpBR3LdQbhJ1GJgGyGqC0W7JAEx13ndGKRnSZTeU4mb35qgRMTIgJ2tIN4nnKXluEiDr
tuna0mZBgdEDRsCJO6YiNEmsdmLXNI2upGUHE6E8ighIkd0UWAvKtNwhMxF0ZwRg6DlKm4vWqQA2
jqkYEA3Ma7K2cEeX9U4wLiJAkck7Q61Q3iw0RMaSYF52V9nDySRB1nRaOE4S5ztBptupc5FmFrPw
mGLoiP6rc4dhHNc2W2B+a1MFwkNyyLLoMBw1vpJA+S8+fLHpw4k3AS6k1pp6zcL0vhvGaVDDNDiC
YEwua4Twim90mBC6FnDqGUQ0ArxZ2WvRJ401K+NZjMLNBpJO6rYbB+cIqt+SgZh6uGdLCcsXCt/b
PKBLnztquYTeD06bpNR4/wDcjr4GKf8AGqhulnbKrVrDHtyio9o5hU6WDr0cS0txlV7D+E3UUOM8
P08W0luLra81wvjfwozC0fNoOqPnUm69TGArFh8usQeypcQ4RisRTLH1czY0IWsc7jdpZK+WeL4J
9F56FZexvvC9b8deHH4Wo8tgtPReW4zDPo1i2DqvqcXJM48HLx9apuH9ygcFLHUIS0+y7OGkBCHR
TlltQoy1ViwAKMFAQkCqmxhPohBT7KKe90gkmCKJNdKNUkCAupqbsunzUTdEuaE8NHAY4UHk1Bma
eaj4ji24l5LGhoVFJolwCmvtrvbNI3apKzi6PlVGti+UEpLTHV0GFqCrQcwmSPosTF/d1nA6/kru
EqFlU5rTZV+LtitmGhWJPLtb4VqdQgwCnqPLhzVeU8krWmOw51QkpibapkTY2fEAU1Z9zCDNGiZo
JKJv6K5UtKkZ0R0aM6zCt5Q2w0iVLW8MPulTyhkRHNSBxJGUGAmA5hSC829wsO8OW7k63UTmtMQe
kqWDki/uowHAmNBa4SFCKYN7yhbROmWSpmNdJKsYZpJggjsrvSTHapTouuMtz1TmmWiHK+0ZC4W6
KJzCZGt5UmTXRQe3Uj5SnYwuvb+qseU43MZuRTFvqgxCu2OqIMI5TzCJtKRr9VMGAj+hTQdrpteq
I076g/qoXCBN+itNYAfVKFtGXQJIlNp1QRNnanmmc24mOyteWUgwyZE9FdnVVNNCGmb69lbdSi8d
UhSvyKbTortZcgyiyHZWQyG205pFl4ufop2XorZbSdNQnbTGW9jurPlyTMwlafhlNr0QinDbWj6J
vLc42kq7TYHUxa4j3R+SYktgc1OzXxs8UrW136JeURNyNwtDye89UVPDlz4bdyndfjZvlRN9N04p
QYH+/ZaDqGUlrteXVOzCucbAmU7p8bNFM5SYA3SbSMEaq+6kGuLXiD1QinpBMHqr2PjVBSdBBsdk
IpSNewWg6kHF0D6JhSEmNe6dj41PyDBMwE4pEOsDG8K6aWUAAX0Cko0mueM1x0U7rONQOGc1shtj
vzTup/h7Lfq0abaRy/FE6LObSJJJnXZZme2rxaUjTJ205hM2kIsFomkT8tkTKJgwYn23TuTjZwom
/PtqpGYeC6dloCiQDGnJO6mbi0kqd2ujMNKQRt+SdtInY9FeDbiY/wBEm0rEmNVeydFQUY2gJzQz
HrrqruS2uvROGiDe5Ngp2Xoo+QZ0uNZ2R/Z7i1ldpzYck+WYI7KdjpFWlhGz67Hrupq+CZ9nhj78
phTeUS51j7pi0NED/RTtWpjGc2iYhTNot/HEHaZWpR4e59AvOvJQPoQSI05hO+z49KT6DHMAbAIK
jGFINojpsFoMo+qbKxh2A1Gy2b3ACdtJ02xamGbkLgQTuChGGJi0WlbnE8IxtaaYiRKpikeasz3G
bhpRbhTMx/ql9jItErSbTcAAAJTmm/QQr2p0jMGDMEZbaQjbhTOpjmtBtCpBupG0qguYU706M77H
sRHJIYQyYHfotVlB5Fz9EYoOAgASU7r0ZQweabE/kl9iNhBkLZp0LSj+zxqCPZTufGxhgZvGh3Kj
PDz6jp2XRMobkdk1SlPI9VPkX4450cOJOhP0lO3hpzTEXGi6EUWgbR1CdlMTbnunyU+OMWlwsPIz
AydFOzhwY6HN1t3W2yn6gdgeSvUMGaouJKzeSrOOOe/d7WPa3LMq0OFtc3kN7LcOEayAYzDdWBhj
9nMBZ+RqYOYZwjzXwz4Bor9LhAFMhzQeq0KMUhfQK7gSKmeCTO26lzqzCManwpoPw/1Vujw9ouAJ
5rcbROoHaERyUyQ85SeYWLnWpjFTD4UAeoK/hgKbxylHSpBzSZi1kP2R7fxXPXVc97ab3DDTOhhd
BTZSyATBXKcOa4QHTAstTz3tqtaDaFiwa32lmHJbWktOiqmpgqtT0kdkqbxUBD7xrZRDB0WPzAX5
KC9TZS/BIn5KV1NrCHEHqqYxPlAhoBTfb6jhBACmkbuHezKPWPdWXVGZTmINtAsKhXpOpEOs9Hha
5pzmcCOpU0ac747w1DE4Wplu7qF8/wDiPCPZWqHLqV9M8ZNLEUnAtbEQvEvG3DnUq9QxbUEL0/jZ
aunPlx3HmDhDiDqkRzVvG0srydyqggyvpx8+zQDYSgO6li5hCWqsoiEJEKWEBCMWI9ETTZIhCLKp
EkpIQbJ5Rdn90rppSlQEDqlzTNTk2QMd1e4XRDnmo+wboqLQXOAC1SfIw4Y030StY/tR4jUzYlxB
tASUOJP3nskqxb5aVW1bMJ1T8Vh+HY6Lp6o1Im2l0NX14EzssuzLS0CGYTarTjsRcmlICVPSokqL
JajYwkqzRo2uCpGU2ja6mYBOpKza7YYaLLaJASDQDMDsic5uaIJGidpb1lZdTtE7nqjAEmx9907M
sjSOaMBuUwVNtSFSp+jNHSULQ7MNJ15qUnMMrTAQtDmmCBP5qNaORDblHQcWucbmQmaRN4EaKcNA
M6g7KLEBJmZi94UbneogC2h6Ky8nNGUXCjyguzZeysELQ4jUgJwwA3JnW+qmdGWwsboRTj4QTv2T
aaM3LuJ5nonaWtduU7QPMAbJOoUnlerUG8lDSEtBOnZCWbXhTFuQnc80zRAk6x2lNmkBZAu7QpZS
CYcVO5lzZE1ogtyps0rAO3Mc7o2tdGvsphTLrCR1RsbBIbJnfVTayImNJMEbckRzAxlhSwGSYuIR
UnABxdMnRTayIWMc8+kWCOjTmplI3UjarWAkT7I8MRnc8NkqWrIKtRLXDK0EJq731IBaAG8lcY9z
BLxaJhVq7w42bdYlbsV20yHEwZ6jVEHOBJaIJClaQQRdExsN3utbTSANObM7Wd1O3FPAEAW6aoiB
J2/okwC9r9FDSvifviHOBBUQomQdyrrwCDYFS4bCmt8BPz1TtqHXbObSLSbGEvJz6X91uVeHNZRc
Q4FypUqFRxOUEc5Umcq9NKflgAggkkKSgwNJJMQdOq0H0gyic7IcLBVchqOys1hO2166NTpuqVhB
d/RDVpGnUI6/JWgyo2nmYAMuqqS5xzEzO6Slh2g5SboMo0g8rqXoQIA05oQ8GpZpI5KoNtIQdrIT
RkmCb7qVlQC++kyhe/1WmVPK+EPk5YuZTtZ6YB+aPzJHQ/RG10OjLbYbongzqPpA+aYU2hxsOh5q
Rzi9xhvsEL81Mw5spF8GDACNwOSNrQ1uyAVCIsegRh5JiD0TyeEwDPL1AtaFFla6oN7KSnTqObdp
EayoxVDKpBbZSC1hq5pOAn06Ky6pRf8Ahvssx9cTIbIm0IhibXETsp0WZ/S5RNM1DmYMqaiGCs5z
QOhVRlUgyBG0KRtZ1/RGydTtE9Ymo+TqdpUHltuIGifz3AfDdN5+/wA+qSWJuCFMASbDcFPA1Map
NrjTL/qiNZuXf87q+TwDUQBARsaQbQBuhFYN+EW2hG3FDtOkJ5Twlawxp3UjW2PpCi+0l1gNNkji
I1j++amqu4tMjNAAAN0cD8IjlKqNxO11KKpgmTI3Kmqu0/4bATqhc0W5ddkwrBtr9lI0hwEKGweX
6ZJvsiw1Frs2ZwEb81IYJYI6WR02tdUhgIB581A2Gc3OQ5ttFqVXNZSHkuE8lUpCC5uQGdk7WPEw
2Qs1pLlJJMAjorVAO0MxyVIVKgkACytYSs7MQ+TfUKUFiaTTTuLqPC4V7HeZQJsPh5qxiHmp8U2U
tOq1tGGTnmCpurDtx7WHLUGU6KeoadWmXnKWjkq+LpCvR+8AzcxZTYDD4f7K6nUc6dpWboBhcbBL
A2I0U+IxrWPpA6kqOnSFKocgt+av0qFKsGl4baynhSZjWsfawHNWKfEqT33d8yhr4UOpuLWtJCCj
gqZaM1C/dTwjTpYynl+KR+SB3EAXFouNbKClQY3SkQ1WGGm0xkvrooK78c5hmDPVWMJWqVh8BvdV
cPjKdTEPo1qRD27xYrZwleg0BseraEDU6b3ESIurH2Z7rBzhKI4ui0fA4W5JhxGlNqdSOyiIK+Dc
xt3nsuH8WYLPQeBeN13eJ4jh3GalN4tCxOJVcDVpOGR0xuFcLZdrrceAcaoFlU2m6wy0tJlen+Ke
D0zmqUmmNYK89xdDIXAA+6+pxZ9o8HLhqqE89k0T80e8Sm23XVwARzQx0UnPYQhdMHWVUREISNVJ
+qaNdUY0i0ToiEKqFKdCkEQYSlCCnRVrAtmoXHZSVX56pJkgIaI8uiTuVHPf5KN+ppBWu+/JJKtG
f2SVc2xVi/dM4AYKpHP5oap9RO2iaZwj/osu7I3RsaSUbKRJOynZSjU6K7c8cNlRoi0q01jW6X6g
qMMgBG1jo0GnNYr0YzQ2ATLjojDACRMfoha1xFp9inLHNF9NVG4cUhe4jQhH5QDbECN0wDuvZPDv
n/cqNSC8sxYH8k+QjUX/ACQZyLafopRWFxysoE2la/0RspHY6aJmSX25b6qanOaIPZGoXlEuAn5o
zSIc7KRpeUYqwII+iY1RB2Oiz5XwrEvvYkfKUTS+bi/6KQHcxGvJOKgdJnqqiI5jbL/qiE/ylStc
DcxJ6JOeHOGUBRUUQJDIKdroMHXqjALjFp1lSVcOWMzGOkbJtZEOYTM6+yja+8mw7bqSrkgBg0SZ
lEggmeiIfOw9tE4Ii9h2TNay8EDspxTYKZdEgqKAOYGkTf6IJAaYmyn+zsc2Q4hRvw8SA6ySg8LS
86R+LoUT6Ia8NBPVNhKJY8kvAJUlZuV3fVT7anpHUot9MQesTKkpNDTMXUbWyPi91J6Wi59kImqP
zxIEkKF5gxEQie4FoJnNCjFsxG2llJF2ZzO3siY6AdBa3+qFlNz2l0R0lOyi83Eg/qqhj6Xa3SzA
nXXol5T8wkelTCjDBNnD81CIw2SLx3UzHOpzlqa2U+GDTIfTJO3VBWoFjyYME8lN/TWvshVeRIeZ
iYTjEVGzBt+aPC4Y1HjXmpsRgHhhcPks+PS+VGrWq1hB7FBSe+lUDgA2En03ss8OhSik4gE681rw
zu0s7i10uudQoQRAG6lDLGdNuqcNaASQJ5IqIRJ0CdrWmfTtsUYaBYNGn6pBjDpFjZEA2mIMAFOG
NMCykpQA4azzSLWAmTKKZrG5v6IrXNoOlkJDSdeicMYG3KgTSAT/AHKsUqYr3c4NPUaqBoaREkby
rFCiKbC8vvsFKsSPwdNjRlcOqrVHU6Vm3Kkr1HCmGgaibaKmaRubklWT9pb+k5xDiC0aaRuonMEz
EqSmJaPTdSCMsZSD0V9J7QRl0Epi0mSQYKla2DeSpsoeDDYP5JtNKzKfLuVOGQDYidJRAFh0Ok9k
bZfcXi8wptZEX2cuE6X1KIYa+hnTRTsIcIJgcgFNmbktEKdqsxin9n2M/JSDD7ESVI0ybGBtCmLY
AsZ7Kbq6isaDYIc0whOGv6Y9leyW0lCQNADOgskyTURYSgKb5EZYTfZwXvseyvYfD7k2KVSmadQt
FwTE9VNrpUZQa0iACFI2nb4JVk0IM2KOmwNEAmdLJs0qikY+EoqdPKOU81bsD/olEkbKbNAwuH81
5GkDdOG5KrxFwY7qzRblJIEHQwEVBgeTmv1U2aQsqEG6kbVvf6bJ30AHnklRDZOYX1UUxE3AtyOy
npMDIMaqNhMlpAhXKcuGoUUsrXjkeSegMhNrcwrFGgMx5KU0IBge4U2qN0lqKiBMEIsO7UQSpWNL
XkkW5qAgGjT5K9hnU/xEEqm6owMuDbZUjiznApgkqaG95jZt7BT0qrYkOHusenVqR8MqVmIcNuqn
UbbK1OJcd7lA7F4caEErNGLa+kW1G35lS0W4Z9P1AgyppF1tbC1nCWtB5oX0KQrMfTfoqrMNhs3p
fG2qmbh6U/xraRKmhdqnd1VoCJmIptZBqt7qn5dGJzg+6gq4alUbDXwe6aVNXxFJ7ozBxjkqFaia
glrDB0lS06PkmQWuVxlWi6n69UHL8W4eatFzXNgrznj3BSzM5rbTK9dx9Om5jsmYk3hclxXBue11
zHZd+LO4sZ49o8gxNA0yYgEKqABrddRxjAOZVcYJk7LnsRSykiF9DHLcfPzx1UJ0NwgI/JPf33SW
mAEBAbKWOyE9lURwhhSQhhGNI4SRkIYVTRkVMS4IYRUvjCEW6xgATZRC5MoqjszuyZu/6o1UNa9Q
7pJq/wDEPZJGGpXbBN+yTWxh3ZoRVbbQoMZUy0Q0W6LLv6NTaAdQpIblHbdZ2d3Mpw93Mp1SckaI
a3n3RNgCzlnZ3cykHu5lTq18jTDuRmPqpJcRJcOyyg90RNkhUd/MU6r8rXDTFnAqyH02UpPxLBFR
95cU4qPj4iVOi/N/xq+ZTgy28J2upaRHdZGd/M3Szvvc906J8zfouYHSSAFO2rSDhcEnWFzLaj4M
OPzRebU0kwp0anN/x1gr0PLOmZVc1IGQRHRc6KtT+Yn3S8yodzdPj0vzN6tVphpCh85gaJPRZGd5
3+qbO/mYV6M/M2m16c8uSOm+mHCXLCzui5PzSD3cz806E5nTPa05TTeL3UjL04fUBjRcv51UD4nJ
hWqH8RWfjbnP/wAdFWpjN6TZAKY0DlhCvVH4ynbXqxq6FeifN/xu+XlbIcNJRAOfIkX5lYIrVTEE
j3RefVE+ojdTofM6IBjBr9UqbA8+p9j1uudGJrT8RlE2vW0zH5p8a/M6XDUmCuCXegdVaq06b6xI
NtguTZia4BIcf6JOxddv4ze2qnx/9anPP06Z9CmXQ18bWKX2dovmEhc0MbWa7NmRHH1yIDinx0+a
fp1NalTfTGVwDo+aqGgcpAPsufGPr39ZFkxxtf8A9QlScdn2fPG8wPYC2QnHmAQXA/ksBuLrHV5S
+11Sbvd0V+NPmjpaTc5vUAESjqUoqRTeCN7rlvtFYT6zpzSZi64cAHlPiWc8/TtqWJdRp3AJG6Z2
KfUeZygLjTja5Hxk9JSbi6u73QFj4Wv5LvMPSY0B5qtG+ql+2Uqfpc4FcC7GVgP4h5IftVZwMvNk
+Dfun8nX07bEYii8Q0RyUL6jHNytIlcYMZW/mKcYyuBqYVnDpP5H/HY0AxtQEm2t0OIaypUc5rgF
yDsdXBILz1QjG14+Jyvw/wDT+RP06oUDoHBGzDCxdUC5E47EB3xuS+3V7+smAnxX9p88/Ttjh6RY
MtQZlAMJBPrHS65NuPr7vPfRSjHYkyM5lPiv7P5E/TqxRgH1t907qYDYzjlquP8At+I/9QpnY/EG
xqGO6fFf2fPP07GhQaA41HAjXuo2AvryXQ2bXXJHHYiDNV0aJhjsQHWe4FPiX+RP09CrUaJotOYa
Kp5THCA8WNlxP7xxU3quHumOOxEH71w6KfD/ANP5E/T0BlBjWEy2FC2pRcCJA2XEs4limgjzXGVG
cbiCSc5U+E/kT9O8DqbAJIhJ9Wh5chzSQP7hcEcXXuDVd80wxde5FR0BX4T+R/x3tB1KsM1QhpVu
k7DsDgCLrzj7diR/3XfNJuOxFvvXDZPh/wCk/I/47rFuaxpc06BFRrNfhs4ItsuE+3YmCPMcQULc
diAIbUdHRPhT+Q9Aw1amQQ7RTGqws10v7LzoYzEb1XAFEzH4kAgVXp8J/Id1TxzHVixt8uqR4jTZ
UyuGh1XBjGVwSW1DO0JjjK+Yy8z1T4YfyHprcbRfTDswCgr8Tbl8trZ2mV503H4kWFR3NOOIYkz9
4bp8C/yXoIxbA0ZqgBndF9uptBl8nqvOn4ys6Mz3WQ/bcRH8RwlPhT+Q9Ip8ToyRnvfVJ3F6VJxD
RmXnAxVbXO4AxO6MYysASHmd0+A/kPQhxpzh6WDorOF4qx1nSCL6rzQcQxQs2o72SHEcR/6rlPgX
+Q9X+1sqtlrhbTojbXplshwnVeTjimKj+M4FPT4rjBfzXR3U/jr/ACI9PfxKlSdDjpupGcapH8Ue
68rdxLFVHZnVCUBx+JgjzHck/jn8mPXqfHKTHGXeytM8Q0Aw+oXC8XGOxIEGq8JHG4iCRWd3lP40
T+S9obxvD58wIKsN4/QLYkaQvEBxDEgx5rwdeSJnEsU0kiq4FT+MT8h7gzi1DzPvYLCqmK4lhqVT
NScANjzXj/75xpEea6O6iqcTxdX46ryD1Sfjr/Ij2RnH6Mep4sozx2iR/EaPdeNDG4ibVXohjsR/
6r4V/jp/Iew/v2kP+4L8ijb4kw1PWo35rxr7bXI/iOjZMMZW/wDUPX+ifx4fyI9sb4nwd5cJQ1fF
ODa0w+V4r9urkfGYSGMr7Pcn8aH8iPXK3jKmH5GMcZ0IUv8AxM9ozFtui8eOOxMyXuKk/euLykea
6E/jrPyY9eZ4vpgQ5rp0UlHxVQc4F0iLiV47+8sRu/ZC7iNf+ZT+OfyI9wZ4qwzmmHgKni+L4asD
6x2leMnH1zo8zsUJx9c2zkdE/jJ/Jj0PjFXDVGvhwnsuLx+TM7KQsz7XXdY1HH3UZqOMyZK7YcfV
xz5ZklewSYQeXzsgznY2TZnc1105biTIQLyhNPogDnRqlmdeZCG4fImLYEpZncymE68kTYS1MR7I
pP8AqhRkJCVMesJymbOZVEz9U4kaoT1RAXRUFX4/ZJKt8Z7JIy06kucY0VPFvBfA0Cs1XZZMXWc4
5iSpHTKnEJwQhATgKsDkJwQgDbJwxFSB4nVLO1AGjdLKFF3Uge3REKjfoowwZuiQai7oy9sWskHD
/dBksnyi8IeR5280g9thqgyif1Thn0KHkWdt0+dtyfyQBgCQYIPRDyMObH1SzNIIQ5AEsgQ8jzj2
T52DnCjyC9jZINA0Q3Rh7OZSztMwgFPlKLI3fdF8iFRvJOHsQBgTCnaJAQ3UgexOKjYIsY6IPKG2
3JLyLIboxWZysjbUYQIj5KPyBJS8i957oTaUVmSIAhF5zCL7qAUYmLFIUYMSou6mD6cXCbzKelvZ
R+RYXTDD9FTdSZ6YJPzR+Yw6iVCKO0pvJ0PVRPKdtWm1x07omvpG5ANlXFCx5aJvJgjkeaLup/Np
ybWRsq0o0A7KAUG3Ich8huzuyHlZFanBB0Rsr0t2gQqhoifSf0lIULaobq351HMZCH7UwOgDZRsw
kiZuk3CiDLjH6oeUja1Em7dPopqb8OPiAFlFTwzBOYg9kX2RjvxW190XyhfUpPLjbomY6kJkDsnq
YKNCI2UJoXIzCVU8pnOp5jpGqI+RAm6gbhie6N2DLWEk6bIbqZjqAOl4sj86gA0wLXVJtCepTnDn
QlTRurFV9F0QAbJ8+HMc1AMMP5pHJM7DgCQVTdWC/DidihL6Nrf6qv5G0ynGGMXm9xZQ3UhfTBhu
pRB9CNB3lRtwwjWZ5IXYaNSqbqbzKOaLEdkhVpC4A+SiGHvr8kxw/uhuphVo3tdEK9IDSwUH2b0m
5KYUACb/AFU0bqcvpEqPzKRvH+iiNGOuybyJJG4V0bqYVKUjkpGvpbx1VbyOf0T+TB1ESmjdWPMo
g6C2gTOqUss2lQ+QIs7sm8ixUTdGXsBMx7pB1PoD0UQoDmL2SFHSTeFTdTF7CSd0LXsggRHNAaEb
yQmNHqOyG6kDmRt0hIvZeNT1UXk8jtKfyhl9PumjdSh9O+nJNnp7EdZUTqQ2uE3l6ze2yaN1NmZO
sFDmZJQCiJhOaQi39EN0WZoBj/ZE1zARB9gofLI0TilAJ+SaN1IHMA6ppYDIgclGKNrhP5VuRQ3R
52abhJzqdpAlB5cN5lN5NhG6G6LM28EFE1zYuBCj8rqkKcgySLXQ3UmZpiYsmzMBmZUfllN5Vihu
pQ5sXKWZvRR+VE6p/KvE7IboswnmkXNhRmnpJTFmsobqSW9P6pZxpaFHkjS6WQf6IbqUvbflsmzi
dlHkN7pFg/spo3UmYRcpi9vO35oAzrsmDPmibo8zbppbfRDk902TqhseYQUi5sa6oQwJZLIeSlsn
9E+YX2Q5NTokWCETdPIGn1SEXQ5BulksUDyDJKRITZQllF0DWTEjmnLbIS1VCMIQbpyOqEaoiXdE
03CAfVE1FRVvj9kkqvxlJGVnEuzEgSoQxGTJKNuhso662iy9E4ZOsqUxP9E4AI07qbOqJrL9eqcN
5hTAAdk4j/UJtZiiyHSJTZb7wrAcIMC/VMIiXfOE2ukOUieaJrTsFMMt50CIQNuibOqCI2j2TZTy
urBDcttd0g1pkpteqBreV/ZEWWEA6KZuUzA6WTveP5Smzqq5eenJE1p1En2UoEk2A2RsgEjbZNkx
Vywz15Jsp5GPyVs05HpCZoEGY9wps6qwF04jS/dT5LmII/JLJOwtZXZ1RAEkagpZL/kp6bRmggX1
HJEW2mLDopteqsGz76ovLO0qzTaNR9boiA0W25ps6qzKTtQN9lM2kQC4lEQZ+PdSU6ciS4m0FTaz
EHlAgxM/JD5QEWg8wrTKVviKc0iDBPe+qm2uqsKVoE80BpRpMK75YAMusgyEbwDzTZ1VTTnUG6cs
MXnnqrlJrJ9UKZjaRBFhfWU7ExZYpHMIkwjbS0BBnutA0YM2I5pnAATIjeQnY6KJp300QGkbxqFr
Mo03gQ65O6OpSpUi0G83JCnZfjY4pibB2iY0gRN2jdbbqdDVsGQFE9rCyYA/VOx8bL+zwCRMRKlp
4ckXFuq0GGnlAgFMACCPSO26dl6RSdQyfC4X2ULmuGuvNaBYz+ZR5G3AIlWZJ0Ui102nonFF94m/
OyuMpgGYBIE9lYpUS7UWTsTjZeWo6wk90PklpnQ8xotoYaLtAnlKjdRjUieXJOx8bMynbX80xp1H
gAzHJaYotc6RrylF5IDTnsU7HRlU6BmPxHRWW4Sb8+SuUabSeUFSuq02tjbaydiYRluw8SNuiY4e
bXAGivlzZJANjoQnGQmIOsJ2OjOFC5gBEKHTbZX3tpgASY5Qnp5JmD/ROx0Z/kHUA9ZQGi4zO3Ra
z3Ma2zSZ3UbC17TFgE7HSMwUXaFsz0Ugw8/hi0WWo2mz+a42RFjdS8WHJTsfGxn0nQGwe6E0SL3j
XqtUht77pOYw62HNXsfHGUMPOk3TnDkTAgrU8sAyU5yZSANfonY+NlCi/rbon+yucbj5K8arQ8gg
mDsFJTeJBLT2KdjpGd9k3g5U7sK4gATE6LYc6mNoGmiAGmDYe/6Kdj44yDhDFgZ+UoWYe8WlbVR9
ENIHJRNawwTYxJCvY+OMz7KfMI1HPRCcK6TaRvK1AWyTaeinp5NSDbWynY+OMtmDtLgZ2Vd2FdMZ
ZAW66vSiMp7KE1GyPuyY6ap2p8cZDMI4jT3/AETOwxEmNdytl9Wm0kCZ7JQ0umO6dj44x6eHcdtd
kRwjgPUO0LWaKbbwISqVKYAi6dj44xhhXAmRPdTfYXWJGvRWqlTNZpAPZO2obSQBqr2p0imcGRMt
HWVH9lcSYH9QtPzYYSSCOiWawM/IaKdqdIzfsbg3Q8kQwbi4CJMdoV11QiDNuiMVxrIiE7U6RQbg
XEmQe6JvDtczojX+ivfaGkfEI0UFR2YyXEWTtV6Q9PhBdJB13Ts4Q1wHqiNAEdHEOpg5XSIT+e5z
jDtNZCm8mpjijZwYumHCOab9zPBiWnf2UorPBJa8jROKz4k1CYU3kdMVOrwx7Mx19lSOGcNoK2hX
du6Z57qM1KZnNeStTKs3jjJbhiQSLFM3Ckmwk/RabssDKJKHOBoe9le1T44pNwLtgYCb7C+Yv8lo
Nrlsxe3ui+19ASE7U+OMw4F4vltyTfZH8jEX6rXbiA5t2319kvPaDYC2qnanxxinCPk+nZAcO4at
MLYOJEXaCd4EhA6uHH4Lbq9qz8cZPkmJi+0qM0yNuq03uDhoFBVIjRalZuEUXCJOqDYTPJWHN1Bk
FRObsqxYHX2Qk/JSRz05JouqgATy0SHUogmjSd0QOyY77Itk0c7oiMoSjiyYhVCBtqiBQDVG1CI6
vxlJKp8Z2SRlMHXRh9lAEQ3hTTpKmzdU+YKBOD3hTSypswMyU+b5qIEQiEdUXY8/tCWaRzCARAlM
fyQ2MVPkiD7lRBvVKAEN1IKhMj5og8iZ0UA0RDeyG0gebAbIvMidFDmjQpB1kNp/NgddCl5snT2K
hB52TgxMbapo2tMrBrbG+wUZrW2O6hFtJhMBITS9qnbWMSNOqJtWT+SgDTEC6WU/rKaN1YL/AFiD
1UnmmMsWVRrSJgpgSNCml7LTXlu9+QR+cIkm/NUw7aUMncpo7LwqCDql5pgkOtzVHMeaIOMwLqaO
y+ytA1I2RiuACCRa0ys4O+acOtJnVNL3rVpVGvd6iNOaNz27d1lMqkTE33CPznE6EmFNL3XXPEek
aqzTawMBzX5LFdUc4xe/JJtZ7D6SRdNJ3bNTEZHQDIKFxDvxBZD6peRBtshbVeNJAlOq92u3Mxwg
iBuje7NOZxJH1WVTfVdYT80i6pI1nYJ1WZtSCD8SQqh8mZ6LLNV7bEmdITeZULZvCdU7tdhbBdM8
k3mB0xeOdlneY7KLjsojWc0Tmv0KdTu1KMGzzdEXAOsZtCyPPeZJNxCX2h+hJ7ynU7thr3EmHX5K
UVSAQDfSxWGMQ693TujFdxtPsnVZm2DisoMG6j86xLiDvA2WX5rh8ZiUxrEzBlNHdqtrXtoiFUG5
zd1jis6xBI7Jy9w3OloTSd27SrMvoB3R+ZREyZhc75ruR5WSFd1zJtonVfkbX2kSfSI5IximAkui
JWF9odOuiYVHc7G6dTu3XVmuMmADombWZrpaFiee4SMxhLz3Sbp1O7fOKbOVwkQkcRTykiFzxqvE
ib90jVcRJJunU+R0JxDI6xYckwxDReNLrBFd0w4lGa5jePqnVZyNx+JpxYfNB9qZPPqsXz3E3mVG
+qTpOinU+RvfamgQAIQGu0mfeYWIKhmSURqm/qvor1T5GuKzM14EnfdTiu0xEf0XPl5fAJsFKK5a
CASQnUnI2atcvs34kqVRgPrdbRYZqvJmb90JqPJ+L6p1PkbVV7c5LXekaIBiAREg7xKyDWdJuhzk
GQRz1TqfI1nVgDEohiLWd36rIa8tE5gCUwqGCSfrqnVPkbTa7b3tdAcSJMER+ay21DMEmExqQP6p
1X5Gn9oaSZdEJ3YiNHGyy2vAbJO8IRVda56J1O7TFed7d0/mtI1WV5h1BS8wnU/JOqd2pnbkJJmP
yQOq8jKzxUdlOs89Ug8jf63V0d2gK8NtYFL7RNmnTms8OMajskXwDBKaTuv+eDprzRCoDtZZpfex
+qdrzBE26lNL3XjWFzrZO2uJ3O6oZ9b/AOqHO4g3TR3aYqNI1gReN03mSQ06rNzmNb7J85uZPPup
1PkaLqwP4u6cVbanoOSzsxvt0SDjeU6ndpMr72+aT8Q1wsbDZZufaNUBqmICdT5GgawNg62iQqgX
k6Qs/MbkkpZzzPK6vU7tBlbUE+3JF5oncLNzH6pZtSTYppO7RFYDc6JvO1vrsFn+YdpG1kgSefzT
R3XzVGligFa991Tk6zomBN/zTSd1t9Qc9ULnN/3KqyZn80hyV0dkpdMzafogLr+yC40lI90ZPm7y
NUxvNwm5pTrdVDkwbJTY3MoNkw5og0PONUKcFEI2mJhCiKEoBKdiXOEzdVWQ1PjSSqfEkiHlECgT
7IsovokCRoUKSLsYKfN1UacKEo8xSzHmhSRdnzJTqhSCGx5jKcOPNAEghsYKfv8AVADqkTzRdjDy
NClmQapc0TaTNbokHZSoweqQKLtMKmsJZusqLmlPMou0wcY3hIkkKLc3SmN1DaWY3TzreVCCTN0r
obSzF0s3uorpR1MKm0od1Tl5i5N1CNLpaRe6htMHXRCpAMFV5J3ThDac1J3lLNreVX2SJ6lDayXD
TZIvjTsq4J7JSYi6LtYZVy3HNT+c0tmPWDfmqDXEJZjGqaOyy+sCZk90QrQ0i3sqgclPSyJtOHnX
RNnkQfZRBxAhLMhtI10XOqU5p/uVDJSBMobTkib6Jw43g6qAEk904E66IbTE26HmmkyZKiBiblPJ
21RdpM0fJLzDsb81HqI/JIaaobSEnmEOaCd/0TCIQ6G2iAw66QdpcXUc6hIGI7qptKL6G6IH0zMl
QZjc6JBxChtNt2SkQVFmJ0skD1uhtLNuicnuogTe6QOl9kVJcDmEgTF9ByUettEpiwPZBIZum/RA
NIJMd0hMICzbHfqiJkaoALGw1TAnQ3RBtM2v2SnXdIAHVN0CKcEm0+yZs3uhkx1KUkCEBZiYuSU4
G5KDQc00nRETtAHU9ENu6izHVIybbobHvZPcaqIEzIT5u6Gx3BSA1QmohDjCG0kawfqng+yjznlZ
IOKGxgJQMsH6KOTGqUmEBkATdKYQAmLpA9UEgI6BMTrJQTqmzfRUStI5pTvKia7YpTbqhtIHHYpZ
jGqjlKTCG0mvdNOt1HdIm2qGxzaCnzFR3hIEgQibSA6XTnnzUYPJIG8lDaQJ5G/sopPNNJKG0pfr
dMXWMqKblIdyhtMHAalIVBpChSQ2kz6fomDraoOcJXCGxT/YTShSBhEECmnkmSQPKUoZ1S2VTYpu
m7JkyBymCZOEQL/iSSdqkiHSSSQKUkkvdA/NPOt0KdFPKUoU6BwUt0OndOgcFKUySKfdJN3SRCTh
MnUU6Upk/NA4S3TJDdFPPIpJJuaB90u6QSCBA2SuOSSZA4MWS1TfJPzsgRTyh6JwUCm+iUmEhp0S
5oEDqkDZIfNLogeeaQ7pktkDgpbJt0p5FAQOqWbW8oUhvuhsUpp5Jhp/VIIpwUpTbGyeyApGyIOG
4UfNL3CG0uYbIXEWUcpfmhsSYyTumlIkiUDgJ0w90m+0IFzgpApQL3Si5QKfklKUf2UohA4OnJOD
CBPPKUNpAYshnUIZ1SkobECnzXUY90403Q2PMIKWZR/1TzdDY510TtMyJ9lGCQkOqGxkm4QzpdKR
shlDYp1TgxpzQTbsnF9ENin5pi69hCZMhs82unJsQh9k/wDRAgYTz0QpIgpEaJSEI90VkWU2xSmy
VkyIfmlKaEgPkgeUySQ6oEEtkhz6pbIFslsl7JIEkDCX+6SBBJJIaIElz5Jb6pfVAvdJMCnlA06h
KSkUuaBT80pTJbIh5SlMkgdNKZOqFPJKUyQ01RCSSCSBJbpJkDpgkEggZ2qSTtUkQk6SSBJJJDRA
kkkkCSSSQJJKEt0C2SSSQKUgleUkCSSSCB5Tg2Q7pQi7FKcFCkiilKUKUImxDVIFDdOAouzylKa6
aFTYgUgUN0robFKU8kMJXUNinVKeaEAp79kNnn5JAob6J45IbOCnBsh+qV7obFISkQhEpXQ2dLZN
HRK5Q2IG6UoYSvCGxSmBShIAobPMJTyTAJXhDZ00pk8IF+afn1Q80rhDYpSB7IYMpQdkNikXSsmv
dJDZ7RKUobwkAeSGzg/NKU10robEClKGCldDZwU8oYPIpQb2Q2KUp1Q3SvdDYgbJTCG6V0NinWUp
QiUrobFKU7IbwldDYpTT2TCYSvyQ2KUgUIlK8aIbFPRMDomSv1Q2cJSmTXQ2IHnKU6phMJKmzykC
hSUNiSTXTIbESlKa6ZDYglOqG/VK91TYpSlClzQ2KdU0/NMlCJs8pSmA6JIHBSlCnGiGynqnBQ3S
QPKUpkkNilNKYJIbPKUpkkCSSTBEOkkkECSSCQQIJBJJAztUkztUkBJApAJ4QMknA6pRZAyQTxql
CBkgnAskAimSTgbJQiGCSeEoQMlsnAsmAQJOClCSKdKU0JC6BxukE0apwLSgcFMCEoSjdA8wkCmD
ZTgIpSlMJQlCBJJQlFp5qBApxqmi6UaoFNk83TEQlGqBApJQkBsgSSUJRqgXskDyShICb80CTg8k
0JQgeUgfmmjVOAgXslOqQCUIpApSmhPCISU3TRZKLFA82SCaNeieNeiBdEpSjVLUIFMlJMAkAgSe
bJRZNGqBTZPNkxCQElA9gmtdOBolzQLdLZIDXknQClonjVKJnogXNJKEoQLZIJQkNECS5pQlH0QI
HVNKeE0SqHB+iZPCaNVA/JIJo0SjXoqHmyX96JC8poQKUpTwlHzUDJA2SAShAvzSSjXokOSBJJRf
qlESgSSUJAKhJSm0SCB0kgExCB5SnklGqbdA9k0pbSlCISXZIaJRdAgltCYhPFygZJKNUgECSCQC
UaoEEgkBKX6oEkCkloUCSSSRDJBJPCAXapJO1SQf/9k=
B64_SDVIG

echo ""
echo "✅  Готово!"
echo "  git add -A && git commit -m \"feat: office bg, map path, tools bar, book gems\" && git push"
