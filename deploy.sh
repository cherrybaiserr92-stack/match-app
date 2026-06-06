#!/bin/bash
# ═══════════════════════════════════════════════════════
#  СДВИГ · deploy.sh v2
#  Запускай из корня репозитория: bash deploy.sh
# ═══════════════════════════════════════════════════════
set -e
S="src/main/resources/static"
J="src/main/java/com/example/sdvig"
echo ""
echo "🚀 СДВИГ · Применяем обновление v2…"
echo ""
echo "  ✦ $S/index.html"
mkdir -p $(dirname "$S/index.html")
cat > "$S/index.html" << 'SDVIG_EOF'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="theme-color" content="#0e0e0e">
    <title>СДВИГ</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">

    <!--
      ВАЖНО: этот inline-скрипт должен быть ДО виджета Telegram.
      Он создаёт глобальную заглушку onTelegramAuth, чтобы виджет
      мог её найти ещё до загрузки app.js.
    -->
    <script>
        window.__tgAuthPending = null;
        function onTelegramAuth(user) {
            if (window.__tgAuthHandler) {
                window.__tgAuthHandler(user);
            } else {
                window.__tgAuthPending = user;
            }
        }
    </script>
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
</head>
<body>

<!-- ══ СПЛЭШ ══════════════════════════════════ -->
<div id="splash-screen" class="screen active">
    <div class="splash-center">
        <div class="splash-emblem">
            <div class="splash-ring"></div>
            <span class="splash-icon">⚡</span>
        </div>
        <h1 class="splash-title">СДВИГ</h1>
        <p class="splash-sub">АГЕНТУРА</p>
        <div class="splash-progress">
            <div class="splash-bar"><div id="splash-fill" class="splash-fill"></div></div>
            <p id="splash-text" class="splash-status">Инициализация…</p>
        </div>
    </div>
</div>

<!-- ══ ЛОГИН ═══════════════════════════════════ -->
<div id="login-screen" class="screen">
    <div class="login-bg"></div>
    <div class="login-layout">

        <div class="login-header">
            <span class="login-icon">⚡</span>
            <h1 class="login-title">СДВИГ</h1>
            <p class="login-tagline">Агентура · Оперативная система</p>
        </div>

        <div class="login-card">
            <p class="login-card-label">АВТОРИЗАЦИЯ</p>
            <p class="login-hint">Войдите через Telegram чтобы начать</p>

            <!-- Виджет с loading-состоянием -->
            <div id="tg-widget-area" class="tg-widget-area">
                <div id="tg-loading" class="tg-loading">
                    <div class="tg-spinner"></div>
                    <span>Загрузка виджета…</span>
                </div>
                <!-- Виджет вставляется сюда -->
                <script
                    src="https://telegram.org/js/telegram-widget.js?22"
                    data-telegram-login="sdvig_game_bot"
                    data-size="large"
                    data-radius="8"
                    data-onauth="onTelegramAuth"
                    data-request-access="write">
                </script>
            </div>

            <!-- Fallback: показывается если виджет не загрузился -->
            <div id="tg-fallback" class="tg-fallback hidden">
                <div class="fallback-icon">⚠️</div>
                <p class="fallback-title">Виджет не загрузился</p>
                <p class="fallback-text">
                    Возможные причины:<br>
                    — Домен не добавлен в @BotFather (<code>/setdomain</code>)<br>
                    — Telegram заблокирован в вашей сети
                </p>
                <a id="bot-link" href="https://t.me/sdvig_game_bot" target="_blank" class="btn btn-amber">
                    Открыть бота в Telegram
                </a>
            </div>

            <div class="login-divider"><span>скоро</span></div>
            <button class="btn btn-ghost" disabled>ВКонтакте</button>
            <button class="btn btn-ghost" disabled>Google</button>
        </div>

        <p class="login-footer">
            Нужна помощь? Напишите <a href="https://t.me/sdvig_game_bot" target="_blank">@sdvig_game_bot</a>
        </p>
    </div>
</div>

<!-- ══ ГЛАВНЫЙ ЭКРАН ════════════════════════════ -->
<div id="main-screen" class="screen">

    <!-- Шапка -->
    <header class="topbar">
        <div class="topbar-left">
            <span class="topbar-logo">⚡</span>
            <span class="topbar-name">СДВИГ</span>
        </div>
        <div class="topbar-stats">
            <div class="stat-chip" id="chip-energy">
                <span class="sc-icon">⚡</span>
                <span id="hud-energy">100</span>
            </div>
            <div class="stat-chip" id="chip-credits">
                <span class="sc-icon">💎</span>
                <span id="hud-credits">0</span>
            </div>
            <div class="stat-chip stat-chip-rank" id="chip-rank">
                <span class="sc-icon">★</span>
                <span>R<span id="hud-rank">1</span></span>
            </div>
        </div>
    </header>

    <!-- XP полоса -->
    <div class="xp-bar-wrap" id="xp-bar-wrap" title="">
        <div class="xp-bar"><div id="xp-fill" class="xp-fill" style="width:0%"></div></div>
        <span class="xp-text"><span id="hud-xp">0</span> / <span id="hud-xp-max">150</span> XP</span>
    </div>

    <!-- Контент табов -->
    <div class="tab-area">

        <!-- ─ ДЕЛА ─────────────────────────────── -->
        <div class="tab-pane active" id="tab-cases">
            <div class="swipe-zone">
                <!-- Фоновые карточки стопки -->
                <div class="stack-card sc3"></div>
                <div class="stack-card sc2"></div>
                <div class="stack-card sc1"></div>

                <!-- Основная карточка дела -->
                <div id="main-card" class="case-card">
                    <!-- Штамп: ОДОБРЕНО -->
                    <div class="stamp-wrap stamp-right" id="stamp-accept" style="opacity:0">
                        <div class="stamp stamp-green">ОДОБРЕНО</div>
                    </div>
                    <!-- Штамп: ОТКЛОНЕНО -->
                    <div class="stamp-wrap stamp-left" id="stamp-deny" style="opacity:0">
                        <div class="stamp stamp-red">ОТКЛОНЕНО</div>
                    </div>

                    <div class="card-head">
                        <span class="card-type" id="card-type">📁 ДЕЛО</span>
                        <span class="card-num" id="card-num">#—</span>
                    </div>
                    <div class="card-body">
                        <div class="card-emoji" id="card-icon">🔍</div>
                        <p class="card-text" id="case-description">ИИ сканирует архивы…</p>
                    </div>
                    <div class="card-foot">
                        <span class="foot-l" id="ca-left">✕ ОТКЛОНИТЬ</span>
                        <div class="foot-sep"></div>
                        <span class="foot-r" id="ca-right">ОДОБРИТЬ ✓</span>
                    </div>
                </div>

                <!-- Результат -->
                <div id="result-overlay" class="result-overlay hidden">
                    <div class="ro-stamp" id="ro-stamp">РЕЗУЛЬТАТ</div>
                    <p class="ro-text" id="result-text"></p>
                    <div class="ro-rewards">
                        <div class="ro-chip ro-xp">⭐ +<span id="rew-xp">0</span> XP</div>
                        <div class="ro-chip ro-cr">💎 +<span id="rew-credits">0</span></div>
                        <div class="ro-chip ro-en">⚡ −<span id="rew-energy">0</span></div>
                    </div>
                    <button class="btn btn-amber" onclick="nextCase()">Следующее дело →</button>
                </div>
            </div>
        </div>

        <!-- ─ ИГРЫ ──────────────────────────────── -->
        <div class="tab-pane" id="tab-games">
            <div class="pane-hd">
                <h2 class="pane-title">Игровой арсенал</h2>
                <p class="pane-sub">Прокачивай навыки в испытаниях</p>
            </div>
            <div class="game-list">
                <div class="game-row" onclick="launchGame('detective')">
                    <div class="gr-accent gr-violet"></div>
                    <div class="gr-icon">💎</div>
                    <div class="gr-info">
                        <div class="gr-name">Самоцветы</div>
                        <div class="gr-desc">Match-3 · 100 уровней</div>
                        <div class="gr-prog">
                            <div class="gr-bar"><div id="det-bar" class="gr-fill" style="width:1%"></div></div>
                            <span class="gr-lvl">Ур.&thinsp;<span id="det-lvl">1</span></span>
                        </div>
                    </div>
                    <span class="gr-arrow">›</span>
                </div>
                <div class="game-row" onclick="launchGame('doctor')">
                    <div class="gr-accent gr-blue"></div>
                    <div class="gr-icon">💓</div>
                    <div class="gr-info">
                        <div class="gr-name">Кардиограмма</div>
                        <div class="gr-desc">Прецизия · 100 уровней</div>
                        <div class="gr-prog">
                            <div class="gr-bar"><div id="doc-bar" class="gr-fill" style="width:1%"></div></div>
                            <span class="gr-lvl">Ур.&thinsp;<span id="doc-lvl">1</span></span>
                        </div>
                    </div>
                    <span class="gr-arrow">›</span>
                </div>
                <div class="game-row" onclick="launchGame('universal')">
                    <div class="gr-accent gr-amber"></div>
                    <div class="gr-icon">🧮</div>
                    <div class="gr-info">
                        <div class="gr-name">Экспертиза шифра</div>
                        <div class="gr-desc">Математика · 100 уровней</div>
                        <div class="gr-prog">
                            <div class="gr-bar"><div id="uni-bar" class="gr-fill" style="width:1%"></div></div>
                            <span class="gr-lvl">Ур.&thinsp;<span id="uni-lvl">1</span></span>
                        </div>
                    </div>
                    <span class="gr-arrow">›</span>
                </div>
            </div>

            <!-- Просмотр игры (полноэкранный) -->
            <div id="gvp-wrap" class="gvp-wrap hidden">
                <div class="gvp-bar">
                    <button class="back-btn" onclick="closeGame()">← Выход</button>
                    <span id="gvp-title" class="gvp-title"></span>
                    <div id="win-badge" class="win-badge hidden">WIN ✓</div>
                </div>
                <div id="game-vp" class="game-vp"></div>
            </div>
        </div>

        <!-- ─ АГЕНТ ──────────────────────────────── -->
        <div class="tab-pane" id="tab-profile">
            <div class="profile-hero">
                <div class="profile-av" id="profile-av">?</div>
                <div class="profile-info">
                    <div class="profile-name" id="profile-name">Агент</div>
                    <div class="profile-arch" id="profile-arch">🔍 Детектив</div>
                    <div class="profile-id" id="profile-id">ID —</div>
                </div>
            </div>

            <div class="stats-grid">
                <div class="sg-box">
                    <div class="sg-val" id="ps-rank">1</div>
                    <div class="sg-lbl">РАНГ</div>
                </div>
                <div class="sg-box">
                    <div class="sg-val" id="ps-credits">0</div>
                    <div class="sg-lbl">КРЕДИТЫ</div>
                </div>
                <div class="sg-box">
                    <div class="sg-val" id="ps-cases">0</div>
                    <div class="sg-lbl">ДЕЛ</div>
                </div>
                <div class="sg-box">
                    <div class="sg-val" id="ps-streak">0</div>
                    <div class="sg-lbl">СЕРИЯ 🔥</div>
                </div>
            </div>

            <div class="pane-hd" style="margin-top:16px">
                <h2 class="pane-title">Навыки</h2>
            </div>
            <div class="skill-list">
                <div class="skill-row">
                    <div class="sk-icon">🧠</div>
                    <div class="sk-body">
                        <div class="sk-name">Проницательность</div>
                        <div class="sk-desc">+XP за каждое дело</div>
                        <div class="sk-bar"><div id="sk1-fill" class="sk-fill"></div></div>
                    </div>
                    <div class="sk-side">
                        <div class="sk-lv" id="sk1-lv">Lv.1</div>
                        <button class="up-btn" onclick="upgradeSkill(1)"><span id="sk1-cost">50💎</span></button>
                    </div>
                </div>
                <div class="skill-row">
                    <div class="sk-icon">⚙️</div>
                    <div class="sk-body">
                        <div class="sk-name">Технологии</div>
                        <div class="sk-desc">−Энергия за дело</div>
                        <div class="sk-bar"><div id="sk2-fill" class="sk-fill"></div></div>
                    </div>
                    <div class="sk-side">
                        <div class="sk-lv" id="sk2-lv">Lv.1</div>
                        <button class="up-btn" onclick="upgradeSkill(2)"><span id="sk2-cost">50💎</span></button>
                    </div>
                </div>
            </div>

            <div class="pane-hd" style="margin-top:4px">
                <h2 class="pane-title">Достижения</h2>
            </div>
            <div id="achievements-grid" class="ach-grid"></div>
        </div>

        <!-- ─ МАГАЗИН ────────────────────────────── -->
        <div class="tab-pane" id="tab-shop">
            <div class="pane-hd">
                <h2 class="pane-title">Снаряжение</h2>
                <p class="pane-sub">Ресурсы для работы в поле</p>
            </div>
            <div class="shop-grid">
                <div class="shop-item" id="shop-coffee" onclick="buyCoffee()">
                    <div class="si-icon">☕</div>
                    <div class="si-name">Синт. кофе</div>
                    <div class="si-desc">+35 ⚡ энергии</div>
                    <div class="si-price" id="coffee-price">40 💎</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="si-icon">🔮</div>
                    <div class="si-name">Нейроусилитель</div>
                    <div class="si-desc">×2 XP · 5 дел</div>
                    <div class="si-price si-soon">Скоро</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="si-icon">🛡️</div>
                    <div class="si-name">Броня данных</div>
                    <div class="si-desc">−50% расход ⚡</div>
                    <div class="si-price si-soon">Скоро</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="si-icon">⚡</div>
                    <div class="si-name">Реактор</div>
                    <div class="si-desc">+100 макс. ⚡</div>
                    <div class="si-price si-soon">Скоро</div>
                </div>
            </div>
        </div>

    </div><!-- /tab-area -->

    <!-- Нижняя навигация -->
    <nav class="bottom-nav">
        <button class="nb active" data-tab="cases" onclick="switchTab('cases')">
            <span class="nb-icon">📂</span>
            <span class="nb-lbl">ДЕЛА</span>
        </button>
        <button class="nb" data-tab="games" onclick="switchTab('games')">
            <span class="nb-icon">🎮</span>
            <span class="nb-lbl">ИГРЫ</span>
        </button>
        <button class="nb" data-tab="profile" onclick="switchTab('profile')">
            <span class="nb-icon">👤</span>
            <span class="nb-lbl">АГЕНТ</span>
            <span id="ach-badge" class="nb-badge hidden">!</span>
        </button>
        <button class="nb" data-tab="shop" onclick="switchTab('shop')">
            <span class="nb-icon">🛒</span>
            <span class="nb-lbl">МАГАЗИН</span>
        </button>
    </nav>

</div><!-- /main-screen -->

<!-- ══ ТОСТ ════════════════════════════════════ -->
<div id="toast" class="toast hidden">
    <span class="toast-icon" id="toast-icon">🏆</span>
    <div class="toast-body">
        <div class="toast-title" id="toast-title">УВЕДОМЛЕНИЕ</div>
        <div class="toast-desc" id="toast-desc"></div>
    </div>
</div>

<!-- ══ ЕЖЕДНЕВНЫЙ БОНУС ═════════════════════════ -->
<div id="daily-modal" class="modal-bg hidden">
    <div class="daily-card">
        <div class="daily-icon">🎁</div>
        <h2 class="daily-h">Ежедневный бонус</h2>
        <p class="daily-streak">Серия: <span id="daily-days">1</span> дн. 🔥</p>
        <div class="daily-week" id="daily-week"></div>
        <div class="daily-chips">
            <div class="dc-chip">+50 💎</div>
            <div class="dc-chip">+30 ⚡</div>
        </div>
        <button class="btn btn-amber" onclick="claimDaily()">Забрать бонус</button>
    </div>
</div>

<!-- ══ ОШИБКА ════════════════════════════════════ -->
<div id="error-screen" class="screen">
    <div class="err-center">
        <div class="err-icon">⚠️</div>
        <h2 class="err-title">Ошибка системы</h2>
        <p class="err-msg" id="error-msg">Что-то пошло не так</p>
        <button class="btn btn-amber" onclick="location.reload()">Перезагрузить</button>
    </div>
</div>

<script src="app.js"></script>
</body>
</html>

SDVIG_EOF

echo "  ✦ $S/style.css"
mkdir -p $(dirname "$S/style.css")
cat > "$S/style.css" << 'SDVIG_EOF'
/* ═══════════════════════════════════════
   СДВИГ · Style · Warm Intelligence Dark
═══════════════════════════════════════ */

:root {
    --bg:       #0e0e0e;
    --s1:       #181818;
    --s2:       #202020;
    --s3:       #2a2a2a;
    --card:     #1c1b18;   /* чуть тёплый */

    --b:        rgba(255,255,255,0.07);
    --b2:       rgba(255,255,255,0.13);

    --amber:    #d4971a;
    --amber-l:  #f0b030;
    --amber-d:  rgba(212,151,26,0.14);

    --blue:     #4a8cdb;
    --blue-d:   rgba(74,140,219,0.14);

    --green:    #3eb077;
    --green-d:  rgba(62,176,119,0.14);

    --red:      #d95454;
    --red-d:    rgba(217,84,84,0.14);

    --purple:   #8b72d4;
    --purple-d: rgba(139,114,212,0.16);

    --tx:       #f0eeea;
    --tx2:      #888;
    --tx3:      #444;

    --r:        12px;
    --r-lg:     16px;
    --r-xl:     22px;

    --nav-h:    64px;
    --top-h:    50px;
    --safe-b:   env(safe-area-inset-bottom,0px);
    --safe-t:   env(safe-area-inset-top,0px);
}

/* ── Reset ──────────────────────────────── */
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent}
html,body{height:100%;overflow:hidden;overscroll-behavior:none}
body{
    font-family:'Inter',-apple-system,BlinkMacSystemFont,sans-serif;
    background:var(--bg);color:var(--tx);font-size:14px;line-height:1.55;
    user-select:none;-webkit-user-select:none;
}
a{color:var(--amber);text-decoration:none}
a:hover{text-decoration:underline}
code{font-size:12px;background:var(--s3);padding:1px 5px;border-radius:4px;color:var(--amber-l)}

.hidden{display:none!important}

/* ── Screens ────────────────────────────── */
.screen{
    position:fixed;inset:0;
    display:flex;flex-direction:column;
    opacity:0;pointer-events:none;
    transition:opacity .35s ease;
    padding-top:var(--safe-t);
}
.screen.active{opacity:1;pointer-events:all}

/* ── SPLASH ─────────────────────────────── */
#splash-screen{
    background:var(--bg);
    justify-content:center;align-items:center;
    z-index:9999;
}
.splash-center{
    display:flex;flex-direction:column;align-items:center;
    gap:12px;text-align:center;padding:32px;
}
.splash-emblem{
    position:relative;width:80px;height:80px;
    display:flex;align-items:center;justify-content:center;
    margin-bottom:8px;
}
.splash-ring{
    position:absolute;inset:0;border-radius:50%;
    border:2px solid var(--amber);
    animation:ringPulse 2s ease-in-out infinite;
}
@keyframes ringPulse{
    0%,100%{transform:scale(1);opacity:.6}
    50%{transform:scale(1.1);opacity:1}
}
.splash-icon{font-size:40px;filter:drop-shadow(0 0 12px var(--amber))}
.splash-title{
    font-size:40px;font-weight:800;letter-spacing:10px;
    background:linear-gradient(135deg,#fff 0%,var(--amber-l) 100%);
    -webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text;
    animation:fadeUp .7s ease .2s both;
}
.splash-sub{
    font-size:11px;letter-spacing:5px;color:var(--tx3);
    text-transform:uppercase;animation:fadeUp .7s ease .4s both;
}
@keyframes fadeUp{from{opacity:0;transform:translateY(12px)}to{opacity:1;transform:none}}
.splash-progress{
    width:200px;display:flex;flex-direction:column;
    align-items:center;gap:10px;margin-top:24px;
    animation:fadeUp .7s ease .6s both;
}
.splash-bar{
    width:100%;height:2px;background:var(--s3);
    border-radius:99px;overflow:hidden;
}
.splash-fill{
    height:100%;background:var(--amber);width:0%;
    transition:width .5s ease;border-radius:99px;
}
.splash-status{font-size:11px;color:var(--tx3);letter-spacing:1px;text-transform:uppercase}

/* ── LOGIN ──────────────────────────────── */
#login-screen{background:var(--bg);justify-content:center;align-items:center;overflow-y:auto}
.login-bg{
    position:absolute;inset:0;
    background-image:
        linear-gradient(rgba(212,151,26,.04) 1px,transparent 1px),
        linear-gradient(90deg,rgba(212,151,26,.04) 1px,transparent 1px);
    background-size:48px 48px;
    pointer-events:none;
}
.login-layout{
    position:relative;z-index:1;
    width:100%;max-width:360px;
    padding:24px 20px 32px;
    display:flex;flex-direction:column;align-items:center;gap:28px;
}
.login-header{text-align:center;display:flex;flex-direction:column;align-items:center;gap:6px}
.login-icon{font-size:36px;filter:drop-shadow(0 0 12px var(--amber))}
.login-title{font-size:28px;font-weight:800;letter-spacing:6px;color:var(--tx)}
.login-tagline{font-size:11px;letter-spacing:2px;color:var(--tx3);text-transform:uppercase}

.login-card{
    width:100%;
    background:var(--s1);border:1px solid var(--b2);border-radius:var(--r-xl);
    padding:22px 20px;
    display:flex;flex-direction:column;gap:14px;
    box-shadow:0 16px 48px rgba(0,0,0,.4),0 0 32px rgba(212,151,26,.05);
}
.login-card-label{
    font-size:10px;letter-spacing:3px;color:var(--amber);
    font-weight:700;text-transform:uppercase;text-align:center;
}
.login-hint{font-size:13px;color:var(--tx2);text-align:center}

.tg-widget-area{min-height:52px;position:relative;display:flex;flex-direction:column;align-items:center;gap:12px}
.tg-loading{
    display:flex;align-items:center;gap:10px;
    font-size:13px;color:var(--tx3);padding:12px 0;
}
.tg-spinner{
    width:18px;height:18px;border-radius:50%;
    border:2px solid var(--s3);border-top-color:var(--amber);
    animation:spin .8s linear infinite;flex-shrink:0;
}
@keyframes spin{to{transform:rotate(360deg)}}

.tg-fallback{
    background:var(--s2);border:1px solid var(--b2);
    border-radius:var(--r);padding:16px;
    display:flex;flex-direction:column;align-items:center;
    gap:10px;text-align:center;width:100%;
}
.fallback-icon{font-size:28px}
.fallback-title{font-size:14px;font-weight:700;color:var(--amber)}
.fallback-text{font-size:12px;color:var(--tx2);line-height:1.6;text-align:left;width:100%}

.login-divider{
    display:flex;align-items:center;gap:12px;
    font-size:10px;letter-spacing:2px;color:var(--tx3);text-transform:uppercase;
}
.login-divider::before,.login-divider::after{content:'';flex:1;height:1px;background:var(--b)}

.login-footer{font-size:12px;color:var(--tx3);text-align:center}

/* ── BUTTONS ────────────────────────────── */
.btn{
    display:block;width:100%;padding:13px;
    border:none;border-radius:var(--r);cursor:pointer;
    font-family:inherit;font-size:13px;font-weight:700;
    letter-spacing:.5px;text-align:center;
    transition:transform .1s,opacity .15s,box-shadow .15s;
    position:relative;overflow:hidden;text-transform:none;
}
.btn::after{
    content:'';position:absolute;inset:0;
    background:rgba(255,255,255,.1);opacity:0;transition:opacity .15s;
}
.btn:active{transform:scale(.97)}
.btn:active::after{opacity:1}

.btn-amber{
    background:var(--amber);color:#000;font-weight:800;
    box-shadow:0 4px 16px rgba(212,151,26,.3);
}
.btn-amber:hover{background:var(--amber-l)}
.btn-ghost{
    background:transparent;border:1px solid var(--b2);
    color:var(--tx3);cursor:not-allowed;
}

/* ── TOPBAR ─────────────────────────────── */
.topbar{
    height:var(--top-h);min-height:var(--top-h);
    display:flex;align-items:center;justify-content:space-between;
    padding:0 14px;
    background:var(--s1);border-bottom:1px solid var(--b);
    flex-shrink:0;
}
.topbar-left{display:flex;align-items:center;gap:6px}
.topbar-logo{font-size:18px;filter:drop-shadow(0 0 6px var(--amber))}
.topbar-name{font-size:15px;font-weight:800;letter-spacing:3px;color:var(--tx)}
.topbar-stats{display:flex;gap:6px;align-items:center}
.stat-chip{
    display:flex;align-items:center;gap:4px;
    padding:4px 9px;border-radius:99px;
    background:var(--s2);border:1px solid var(--b);
    font-size:12px;font-weight:600;color:var(--tx2);
    transition:border-color .2s;
}
.stat-chip:active{border-color:var(--b2)}
.sc-icon{font-size:13px;line-height:1}
.stat-chip-rank{color:var(--amber);border-color:rgba(212,151,26,.25)}

/* ── XP BAR ─────────────────────────────── */
.xp-bar-wrap{
    height:28px;display:flex;align-items:center;
    padding:0 14px;gap:8px;
    background:var(--s1);border-bottom:1px solid var(--b);
    flex-shrink:0;cursor:default;
}
.xp-bar{
    flex:1;height:4px;background:var(--s3);
    border-radius:99px;overflow:hidden;
}
.xp-fill{
    height:100%;background:var(--amber);
    transition:width .6s cubic-bezier(.34,1.56,.64,1);
    border-radius:99px;
}
.xp-text{font-size:11px;color:var(--tx3);white-space:nowrap;font-weight:500}

/* ── TAB AREA ───────────────────────────── */
.tab-area{flex:1;position:relative;overflow:hidden}
.tab-pane{
    position:absolute;inset:0;
    overflow-y:auto;overflow-x:hidden;
    -webkit-overflow-scrolling:touch;
    overscroll-behavior:contain;
    opacity:0;pointer-events:none;
    transform:translateY(6px);
    transition:opacity .25s ease,transform .25s ease;
    padding-bottom:calc(var(--nav-h) + var(--safe-b) + 8px);
}
.tab-pane.active{opacity:1;pointer-events:all;transform:none}

/* ── CASES TAB ──────────────────────────── */
.swipe-zone{
    position:absolute;inset:0;
    display:flex;justify-content:center;align-items:center;
    overflow:hidden;
}

/* Stack cards */
.stack-card{
    position:absolute;
    width:calc(100% - 40px);max-width:330px;
    background:var(--s2);border:1px solid var(--b);
    border-radius:var(--r-xl);pointer-events:none;
}
.sc3{height:170px;transform:translateY(16px) scale(.86);opacity:.25}
.sc2{height:190px;transform:translateY(8px) scale(.93);opacity:.45}
.sc1{height:210px;transform:translateY(4px) scale(.97);opacity:.65}

/* Main case card */
.case-card{
    position:absolute;
    width:calc(100% - 28px);max-width:340px;
    min-height:370px;
    background:var(--card);
    border:1px solid rgba(212,151,26,.18);
    border-radius:var(--r-xl);
    box-shadow:0 20px 60px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.04);
    display:flex;flex-direction:column;
    padding:18px;cursor:grab;
    touch-action:none;
    transform-origin:50% 100%;
    will-change:transform;
    z-index:10;
    transition:box-shadow .2s;
}
.case-card:active{cursor:grabbing}
.case-card.tilt-left {border-color:rgba(217,84,84,.4);box-shadow:0 20px 60px rgba(0,0,0,.5),-6px 0 30px rgba(217,84,84,.15)}
.case-card.tilt-right{border-color:rgba(62,176,119,.4);box-shadow:0 20px 60px rgba(0,0,0,.5), 6px 0 30px rgba(62,176,119,.15)}

/* Stamp overlays */
.stamp-wrap{
    position:absolute;inset:0;
    display:flex;align-items:center;justify-content:center;
    pointer-events:none;border-radius:inherit;
    z-index:20;transition:opacity .12s;
}
.stamp-left{padding-right:40px}
.stamp-right{padding-left:40px}
.stamp{
    font-size:22px;font-weight:800;letter-spacing:3px;
    padding:8px 16px;border:3px solid;border-radius:6px;
    transform:rotate(-12deg);text-transform:uppercase;
}
.stamp-green{color:var(--green);border-color:var(--green);background:var(--green-d)}
.stamp-red{color:var(--red);border-color:var(--red);background:var(--red-d)}

.card-head{
    display:flex;justify-content:space-between;align-items:center;
    margin-bottom:10px;
}
.card-type{font-size:12px;font-weight:700;color:var(--amber);letter-spacing:.5px}
.card-num{font-size:11px;color:var(--tx3);font-weight:600}

.card-body{
    flex:1;display:flex;flex-direction:column;
    align-items:center;justify-content:center;gap:14px;
    padding:6px 0;
}
.card-emoji{
    font-size:52px;
    animation:float 3s ease-in-out infinite;
}
@keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-4px)}}
.card-text{
    font-size:15px;line-height:1.65;text-align:center;
    color:var(--tx);font-weight:500;
}
.card-foot{
    display:flex;align-items:center;justify-content:space-between;
    padding-top:12px;border-top:1px solid var(--b);
    gap:10px;
}
.foot-l,.foot-r{font-size:11px;font-weight:700;letter-spacing:1px;text-transform:uppercase}
.foot-l{color:var(--red)}
.foot-r{color:var(--green)}
.foot-sep{flex:1;height:1px;background:var(--b)}

/* ── RESULT OVERLAY ─────────────────────── */
.result-overlay{
    position:absolute;
    inset:12px;border-radius:var(--r-xl);
    background:var(--s1);border:1px solid var(--b2);
    box-shadow:0 24px 60px rgba(0,0,0,.6);
    display:flex;flex-direction:column;
    align-items:center;justify-content:center;
    gap:18px;padding:28px 24px;text-align:center;
    z-index:50;
    animation:popIn .3s cubic-bezier(.34,1.56,.64,1);
}
@keyframes popIn{from{opacity:0;transform:scale(.88)}to{opacity:1;transform:none}}
.ro-stamp{
    font-size:18px;font-weight:800;letter-spacing:3px;
    text-transform:uppercase;
    padding:6px 18px;border:2px solid;border-radius:6px;
    transform:rotate(-6deg);
}
.ro-stamp.accept{color:var(--green);border-color:var(--green)}
.ro-stamp.deny{color:var(--red);border-color:var(--red)}
.ro-text{font-size:14px;line-height:1.65;color:var(--tx);font-weight:500}
.ro-rewards{display:flex;gap:8px;flex-wrap:wrap;justify-content:center}
.ro-chip{
    padding:6px 13px;border-radius:99px;
    font-size:13px;font-weight:700;
}
.ro-xp{background:rgba(212,151,26,.14);border:1px solid rgba(212,151,26,.3);color:var(--amber-l)}
.ro-cr{background:rgba(74,140,219,.14);border:1px solid rgba(74,140,219,.3);color:var(--blue)}
.ro-en{background:rgba(217,84,84,.14);border:1px solid rgba(217,84,84,.3);color:var(--red)}

/* ── GAMES TAB ──────────────────────────── */
.pane-hd{padding:14px 14px 8px}
.pane-title{font-size:15px;font-weight:800;color:var(--tx);letter-spacing:.3px}
.pane-sub{font-size:12px;color:var(--tx3);margin-top:3px}

.game-list{display:flex;flex-direction:column;gap:10px;padding:4px 14px 14px}
.game-row{
    display:flex;align-items:center;gap:14px;
    background:var(--s1);border:1px solid var(--b);
    border-radius:var(--r);padding:14px 12px;
    cursor:pointer;position:relative;overflow:hidden;
    transition:transform .12s,border-color .15s;
}
.game-row:active{transform:scale(.97)}
.gr-accent{
    position:absolute;left:0;top:0;bottom:0;width:3px;
}
.gr-violet{background:var(--purple)}
.gr-blue{background:var(--blue)}
.gr-amber{background:var(--amber)}

.gr-icon{font-size:34px;flex-shrink:0;filter:drop-shadow(0 2px 6px rgba(0,0,0,.4))}
.gr-info{flex:1;min-width:0}
.gr-name{font-size:15px;font-weight:700;color:var(--tx)}
.gr-desc{font-size:11px;color:var(--tx3);margin-top:2px;letter-spacing:.3px}
.gr-prog{display:flex;align-items:center;gap:8px;margin-top:8px}
.gr-bar{flex:1;height:3px;background:var(--s3);border-radius:99px;overflow:hidden}
.gr-fill{height:100%;background:var(--amber);border-radius:99px;transition:width .5s ease}
.gr-lvl{font-size:11px;color:var(--tx3);font-weight:600;white-space:nowrap}
.gr-arrow{font-size:20px;color:var(--tx3);flex-shrink:0;line-height:1}

/* ── GAME VIEWPORT ──────────────────────── */
.gvp-wrap{
    position:absolute;inset:0;
    background:var(--bg);z-index:100;
    display:flex;flex-direction:column;
    animation:fadeUp .2s ease;
}
.gvp-bar{
    height:var(--top-h);display:flex;align-items:center;
    padding:0 14px;gap:10px;
    background:var(--s1);border-bottom:1px solid var(--b);flex-shrink:0;
}
.back-btn{
    background:transparent;border:1px solid var(--b2);
    color:var(--tx2);padding:6px 12px;border-radius:var(--r);
    font-family:inherit;font-size:12px;font-weight:600;cursor:pointer;
    transition:all .15s;letter-spacing:.5px;
}
.back-btn:active{background:var(--s2);transform:scale(.96)}
.gvp-title{font-size:13px;font-weight:700;color:var(--tx);flex:1;text-align:center}
.win-badge{
    padding:4px 10px;background:var(--green-d);border:1px solid var(--green);
    border-radius:99px;font-size:11px;font-weight:700;color:var(--green);
    animation:popIn .35s cubic-bezier(.34,1.56,.64,1);
}
.game-vp{
    flex:1;overflow-y:auto;overflow-x:hidden;
    display:flex;flex-direction:column;align-items:center;
    padding:14px;-webkit-overflow-scrolling:touch;
    overscroll-behavior:contain;
}

/* ── PROFILE TAB ────────────────────────── */
.profile-hero{
    display:flex;align-items:center;gap:14px;
    padding:18px 14px;
    background:linear-gradient(135deg,var(--s1),var(--s2));
    border-bottom:1px solid var(--b);
}
.profile-av{
    width:60px;height:60px;border-radius:50%;flex-shrink:0;
    background:linear-gradient(135deg,#7a5000,var(--amber));
    display:flex;align-items:center;justify-content:center;
    font-size:26px;font-weight:800;color:#fff;
    border:2px solid rgba(212,151,26,.4);
    box-shadow:0 4px 16px rgba(212,151,26,.2);
}
.profile-info{flex:1;min-width:0}
.profile-name{font-size:20px;font-weight:800;color:var(--tx);overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.profile-arch{font-size:13px;color:var(--amber);font-weight:600;margin-top:2px}
.profile-id{font-size:11px;color:var(--tx3);margin-top:2px}

.stats-grid{
    display:grid;grid-template-columns:repeat(4,1fr);
    gap:1px;background:var(--b);
    margin:14px;border-radius:var(--r);overflow:hidden;
}
.sg-box{
    background:var(--s1);padding:12px 8px;
    display:flex;flex-direction:column;align-items:center;gap:4px;
}
.sg-val{font-size:20px;font-weight:800;color:var(--tx);line-height:1}
.sg-lbl{font-size:9px;letter-spacing:1px;color:var(--tx3);text-transform:uppercase;font-weight:600}

/* ── SKILLS ─────────────────────────────── */
.skill-list{display:flex;flex-direction:column;gap:10px;padding:4px 14px 14px}
.skill-row{
    display:flex;align-items:center;gap:12px;
    background:var(--s1);border:1px solid var(--b);
    border-radius:var(--r);padding:13px;
}
.sk-icon{font-size:28px;flex-shrink:0}
.sk-body{flex:1;min-width:0}
.sk-name{font-size:14px;font-weight:700;color:var(--tx)}
.sk-desc{font-size:11px;color:var(--tx3);margin-top:2px}
.sk-bar{height:3px;background:var(--s3);border-radius:99px;overflow:hidden;margin-top:8px}
.sk-fill{height:100%;background:var(--amber);border-radius:99px;transition:width .5s ease}
.sk-side{display:flex;flex-direction:column;align-items:flex-end;gap:6px;flex-shrink:0}
.sk-lv{font-size:12px;font-weight:700;color:var(--amber)}
.up-btn{
    background:var(--amber);border:none;border-radius:var(--r);
    padding:7px 11px;font-family:inherit;font-size:12px;font-weight:700;
    color:#000;cursor:pointer;transition:transform .1s,background .15s;
    white-space:nowrap;
}
.up-btn:active{transform:scale(.93);background:var(--amber-l)}

/* ── ACHIEVEMENTS ───────────────────────── */
.ach-grid{
    display:grid;grid-template-columns:repeat(4,1fr);
    gap:8px;padding:4px 14px 14px;
}
.ach-badge{
    display:flex;flex-direction:column;align-items:center;
    gap:4px;background:var(--s2);border:1px solid var(--b);
    border-radius:var(--r);padding:10px 4px;
    text-align:center;transition:border-color .2s;
}
.ach-badge.earned{border-color:rgba(212,151,26,.35)}
.ach-badge.locked{opacity:.35}
.ach-icon{font-size:24px;line-height:1}
.ach-lbl{font-size:9px;color:var(--tx3);font-weight:600;letter-spacing:.3px;line-height:1.3}

/* ── SHOP ───────────────────────────────── */
.shop-grid{
    display:grid;grid-template-columns:repeat(2,1fr);
    gap:10px;padding:4px 14px 14px;
}
.shop-item{
    background:var(--s1);border:1px solid var(--b);
    border-radius:var(--r-lg);padding:16px 12px;
    display:flex;flex-direction:column;align-items:center;
    gap:7px;cursor:pointer;text-align:center;
    transition:transform .12s,border-color .15s,box-shadow .15s;
    position:relative;overflow:hidden;
}
.shop-item:not(.shop-locked):active{
    transform:scale(.95);
    border-color:rgba(212,151,26,.5);
    box-shadow:0 0 20px rgba(212,151,26,.12);
}
.shop-locked{opacity:.4;cursor:not-allowed}
.si-icon{font-size:34px}
.si-name{font-size:13px;font-weight:700;color:var(--tx)}
.si-desc{font-size:11px;color:var(--tx3);line-height:1.4}
.si-price{
    padding:5px 12px;border-radius:99px;
    font-size:12px;font-weight:700;
    background:var(--amber-d);border:1px solid rgba(212,151,26,.3);
    color:var(--amber-l);margin-top:2px;
}
.si-soon{background:var(--s3);border-color:var(--b);color:var(--tx3);font-size:10px;letter-spacing:1px}
.shop-item.cant-afford .si-price{background:var(--red-d);border-color:rgba(217,84,84,.3);color:var(--red)}

/* ── BOTTOM NAV ─────────────────────────── */
.bottom-nav{
    height:calc(var(--nav-h) + var(--safe-b));
    padding-bottom:var(--safe-b);
    display:flex;
    background:rgba(14,14,14,.95);
    border-top:1px solid var(--b);
    backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);
    flex-shrink:0;position:relative;z-index:20;
}
.nb{
    flex:1;display:flex;flex-direction:column;align-items:center;
    justify-content:center;gap:4px;
    background:transparent;border:none;cursor:pointer;
    padding:8px 4px;position:relative;
    transition:transform .1s;
}
.nb:active{transform:scale(.9)}
.nb-icon{font-size:22px;transition:filter .2s,transform .2s;line-height:1}
.nb-lbl{font-size:9px;letter-spacing:1px;color:var(--tx3);font-weight:700;transition:color .2s;text-transform:uppercase}
.nb::after{
    content:'';position:absolute;bottom:calc(var(--safe-b) + 6px);
    width:20px;height:2px;border-radius:99px;
    background:var(--amber);opacity:0;
    transition:opacity .2s,width .2s;
}
.nb.active .nb-icon{filter:drop-shadow(0 0 6px rgba(212,151,26,.6));transform:translateY(-1px)}
.nb.active .nb-lbl{color:var(--amber)}
.nb.active::after{opacity:1}
.nb-badge{
    position:absolute;top:6px;right:calc(50% - 18px);
    width:16px;height:16px;border-radius:50%;
    background:var(--red);color:#fff;
    font-size:10px;font-weight:800;
    display:flex;align-items:center;justify-content:center;
    border:2px solid var(--bg);
}

/* ── TOAST ──────────────────────────────── */
.toast{
    position:fixed;
    bottom:calc(var(--nav-h) + var(--safe-b) + 12px);
    left:12px;right:12px;
    background:var(--s1);border:1px solid var(--b2);
    border-radius:var(--r-lg);padding:13px 15px;
    display:flex;align-items:center;gap:12px;
    z-index:800;
    box-shadow:0 8px 30px rgba(0,0,0,.5);
    animation:toastIn .3s cubic-bezier(.34,1.56,.64,1);
}
.toast.out{animation:toastOut .3s ease forwards}
@keyframes toastIn{from{transform:translateY(16px);opacity:0}to{opacity:1;transform:none}}
@keyframes toastOut{from{opacity:1;transform:none}to{transform:translateY(16px);opacity:0}}
.toast-icon{font-size:26px;flex-shrink:0}
.toast-title{font-size:11px;letter-spacing:1.5px;font-weight:800;color:var(--amber);text-transform:uppercase}
.toast-desc{font-size:13px;color:var(--tx);margin-top:2px;font-weight:500}

/* ── DAILY MODAL ────────────────────────── */
.modal-bg{
    position:fixed;inset:0;
    background:rgba(0,0,0,.7);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);
    display:flex;align-items:center;justify-content:center;
    z-index:700;padding:20px;animation:fadeIn .2s ease;
}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
.daily-card{
    background:var(--s1);border:1px solid var(--b2);
    border-radius:var(--r-xl);padding:28px 22px;
    display:flex;flex-direction:column;align-items:center;
    gap:14px;text-align:center;
    width:100%;max-width:320px;
    box-shadow:0 24px 60px rgba(0,0,0,.6);
    animation:popIn .4s cubic-bezier(.34,1.56,.64,1);
}
.daily-icon{font-size:56px;animation:float 2s ease-in-out infinite}
.daily-h{font-size:16px;font-weight:800;color:var(--tx);letter-spacing:.5px}
.daily-streak{font-size:13px;color:var(--tx2)}
.daily-week{display:flex;gap:6px;justify-content:center}
.dw-dot{
    width:28px;height:28px;border-radius:50%;
    display:flex;align-items:center;justify-content:center;
    font-size:11px;font-weight:700;border:1.5px solid var(--b2);
    color:var(--tx3);background:var(--s2);
}
.dw-dot.done{background:var(--amber-d);border-color:var(--amber);color:var(--amber-l)}
.dw-dot.today{background:var(--amber);border-color:var(--amber-l);color:#000}
.daily-chips{display:flex;gap:10px}
.dc-chip{
    padding:8px 18px;border-radius:99px;font-size:14px;font-weight:700;
    background:var(--s2);border:1px solid var(--b2);color:var(--tx);
}

/* ── ERROR ──────────────────────────────── */
#error-screen{justify-content:center;align-items:center;z-index:9998}
.err-center{display:flex;flex-direction:column;align-items:center;gap:14px;padding:32px;text-align:center;max-width:290px}
.err-icon{font-size:44px}
.err-title{font-size:16px;font-weight:800;color:var(--red)}
.err-msg{font-size:14px;color:var(--tx2);line-height:1.6}

/* ── GAME-SPECIFIC ──────────────────────── */

/* Doctor */
.doc-track{
    width:100%;max-width:340px;height:76px;
    background:var(--s1);border:1px solid var(--b2);
    border-radius:var(--r);position:relative;overflow:hidden;cursor:pointer;
}
.doc-target{
    position:absolute;top:0;bottom:0;
    background:var(--green-d);
    border-left:2px solid var(--green);border-right:2px solid var(--green);
}
.doc-pin{
    position:absolute;top:8px;bottom:8px;width:3px;
    background:var(--red);border-radius:99px;
    box-shadow:0 0 8px var(--red);transform:translateX(-50%);
}
.doc-shake{animation:docShake .25s ease}
@keyframes docShake{0%,100%{transform:translateX(0)}25%{transform:translateX(-5px)}75%{transform:translateX(5px)}}

/* Cipher */
.cipher-cell{
    width:62px;height:62px;
    background:var(--s2);border:1.5px solid var(--b2);
    border-radius:var(--r);display:flex;align-items:center;
    justify-content:center;font-size:22px;font-weight:800;
    color:var(--tx);cursor:pointer;
    transition:transform .1s,border-color .15s,background .15s;
}
.cipher-cell:active{transform:scale(.92)}
.cipher-cell.sel{
    background:var(--amber-d);border-color:var(--amber);
    color:var(--amber-l);transform:scale(1.06);
}
.cipher-cell.over{animation:docShake .22s ease;border-color:var(--red);background:var(--red-d)}

/* ── SCROLL ─────────────────────────────── */
::-webkit-scrollbar{width:3px}
::-webkit-scrollbar-track{background:transparent}
::-webkit-scrollbar-thumb{background:var(--s3);border-radius:99px}

SDVIG_EOF

echo "  ✦ $S/app.js"
mkdir -p $(dirname "$S/app.js")
cat > "$S/app.js" << 'SDVIG_EOF'
// ═══════════════════════════════════════════════
//  СДВИГ · app.js
//  Обычный скрипт (не модуль) — избегает timing
//  проблем с Telegram виджетом
// ═══════════════════════════════════════════════

'use strict';

const tg = window.Telegram?.WebApp ?? null;

let currentUser        = null;
let currentCase        = null;
let activeTab          = 'cases';
let currentGameDestroy = null;
let dailyClaimed       = false;
let newAchCount        = 0;
let caseCounter        = 0;

const $ = id => document.getElementById(id);

// ── Достижения ──────────────────────────────────
const ACH_DEFS = [
    {id:'rank5',   check:p=>p.rank>=5,            icon:'🏅', title:'АГЕНТ В ДЕЛЕ',  desc:'Ранг 5'},
    {id:'rank10',  check:p=>p.rank>=10,           icon:'🏆', title:'ЭЛИТА',         desc:'Ранг 10'},
    {id:'cases10', check:p=>(p.totalCases||0)>=10,icon:'📂', title:'ДЕТЕКТИВ',      desc:'10 дел'},
    {id:'cases50', check:p=>(p.totalCases||0)>=50,icon:'🗃️', title:'АРХИВАРИУС',    desc:'50 дел'},
    {id:'streak3', check:p=>(p.streak||0)>=3,     icon:'🔥', title:'НА СЕРИИ',      desc:'3 дня подряд'},
    {id:'streak7', check:p=>(p.streak||0)>=7,     icon:'💥', title:'НЕСГИБАЕМЫЙ',   desc:'7 дней подряд'},
    {id:'sk1max',  check:p=>p.skill1>=5,          icon:'🧠', title:'ПРОНИЦАТЕЛЬ',   desc:'Проницательность Lv.5'},
    {id:'sk2max',  check:p=>p.skill2>=5,          icon:'⚙️', title:'ТЕХНАРЬ',       desc:'Технологии Lv.5'},
];

const earnedAch = new Set(
    JSON.parse(localStorage.getItem('sdvig_ach') || '[]')
);

// ── Init ────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    if (tg) { try { tg.expand(); tg.ready(); } catch(e){} }
    runSplash();
    detectWidget();

    // Подключаем реальный обработчик виджета
    window.__tgAuthHandler = function(user) {
        showScreen('splash-screen');
        setSplashText('Проверка подписи…');
        widgetLogin(user);
    };
    // Обрабатываем auth, который мог прийти до загрузки app.js
    if (window.__tgAuthPending) {
        window.__tgAuthHandler(window.__tgAuthPending);
        window.__tgAuthPending = null;
    }
});

// ── Splash ──────────────────────────────────────
function runSplash() {
    const fill  = $('splash-fill');
    const texts = ['Загрузка данных…','Подключение к архиву…','Проверка доступа…'];
    let step = 0;
    const steps  = [25, 55, 80, 95];
    const delays = [200, 600, 1000, 1300];
    delays.forEach((d,i) => {
        setTimeout(() => {
            fill.style.width = steps[i] + '%';
            setSplashText(texts[i] || texts[texts.length-1]);
        }, d);
    });

    setTimeout(() => {
        fill.style.width = '100%';
        if (tg?.initData?.length > 0) {
            setSplashText('Авторизация Telegram…');
            webappLogin();
        } else {
            showScreen('login-screen');
        }
    }, 1600);
}
function setSplashText(t) { const el=$('splash-text'); if(el) el.textContent=t; }

// ── Screens ─────────────────────────────────────
function showScreen(id) {
    document.querySelectorAll('.screen').forEach(s=>s.classList.remove('active'));
    $(id).classList.add('active');
}

// ── Widget detection ─────────────────────────────
function detectWidget() {
    const area    = $('tg-widget-area');
    const loading = $('tg-loading');
    const fallback= $('tg-fallback');
    if (!area) return;

    // Наблюдатель: как только виджет добавил iframe или ссылку — убираем spinner
    const obs = new MutationObserver(() => {
        if (area.querySelector('iframe, a.tgme_widget_login')) {
            loading && loading.remove();
            obs.disconnect();
        }
    });
    obs.observe(area, {childList:true, subtree:true});

    // Таймаут: если через 8с виджет не появился — показываем fallback
    setTimeout(() => {
        if (!area.querySelector('iframe, a.tgme_widget_login')) {
            loading && loading.remove();
            fallback && fallback.classList.remove('hidden');
            obs.disconnect();
        }
    }, 8000);
}

// ── Auth ─────────────────────────────────────────
function webappLogin() {
    fetch('/api/game/auth/webapp', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify({initData:tg.initData, initDataUnsafe:tg.initDataUnsafe})
    })
    .then(r=>{ if(!r.ok) throw 0; return r.json(); })
    .then(onLogin)
    .catch(()=>showError('Ошибка WebApp-авторизации.\nПроверьте токен бота в переменных Railway.'));
}

function widgetLogin(user) {
    const payload = {};
    for (const [k,v] of Object.entries(user)) payload[k] = String(v);
    fetch('/api/game/auth/widget', {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body:JSON.stringify(payload)
    })
    .then(r=>{ if(!r.ok) return r.text().then(t=>{throw t;}); return r.json(); })
    .then(onLogin)
    .catch(err=>{
        const msg = typeof err==='string' ? err : 'Ошибка виджет-авторизации';
        showError(msg + '\n\nУбедитесь что домен добавлен в @BotFather через /setdomain');
    });
}

function showError(msg) {
    $('error-msg').textContent = msg;
    showScreen('error-screen');
}

function onLogin(profile) {
    currentUser = profile;
    updateHUD(profile);
    updateProfile(profile);
    renderAchievements();
    showScreen('main-screen');
    initSwipe();
    loadCase();
    checkDailyBonus();
    updateShopAffordability();
    vib(30);
}

// ── HUD ──────────────────────────────────────────
function updateHUD(p) {
    $('hud-energy').textContent  = p.energy;
    $('hud-credits').textContent = p.credits;
    $('hud-rank').textContent    = p.rank;
    $('hud-xp').textContent      = p.xp;
    const xpMax = p.rank * 150;
    $('hud-xp-max').textContent  = xpMax;
    $('xp-fill').style.width     = Math.min(100,(p.xp/xpMax)*100) + '%';
    $('xp-bar-wrap').title       = `XP: ${p.xp} / ${xpMax}`;

    const dl = p.detectiveLvl  || 1;
    const dc = p.doctorLvl     || 1;
    const ul = p.universalLvl  || 1;
    $('det-lvl').textContent = dl;  $('det-bar').style.width = Math.min(100,dl) + '%';
    $('doc-lvl').textContent = dc;  $('doc-bar').style.width = Math.min(100,dc) + '%';
    $('uni-lvl').textContent = ul;  $('uni-bar').style.width = Math.min(100,ul) + '%';
}

// ── Profile ──────────────────────────────────────
function updateProfile(p) {
    const name = p.firstName || p.username || 'Агент';
    $('profile-av').textContent    = name.charAt(0).toUpperCase();
    $('profile-name').textContent  = name;
    $('profile-id').textContent    = 'ID ' + (p.providerId||'—').replace('tg:','');
    const archs = {detective:'🔍 Детектив', doctor:'⚕️ Медик', hacker:'💻 Хакер'};
    $('profile-arch').textContent  = archs[p.archetype] || '🔍 Детектив';

    $('ps-rank').textContent    = p.rank;
    $('ps-credits').textContent = p.credits;
    $('ps-cases').textContent   = p.totalCases || 0;
    $('ps-streak').textContent  = p.streak || 0;

    const s1 = p.skill1||1, s2 = p.skill2||1;
    $('sk1-lv').textContent  = 'Lv.'+s1;
    $('sk2-lv').textContent  = 'Lv.'+s2;
    $('sk1-cost').textContent= (s1*50)+'💎';
    $('sk2-cost').textContent= (s2*50)+'💎';
    $('sk1-fill').style.width= Math.min(100,s1*10)+'%';
    $('sk2-fill').style.width= Math.min(100,s2*10)+'%';
}

function renderAchievements() {
    const grid = $('achievements-grid');
    if (!grid) return;
    grid.innerHTML = ACH_DEFS.map(d=>{
        const ok = earnedAch.has(d.id);
        return `<div class="ach-badge ${ok?'earned':'locked'}" title="${d.desc}">
            <div class="ach-icon">${ok ? d.icon : '❓'}</div>
            <div class="ach-lbl">${ok ? d.title : '???'}</div>
        </div>`;
    }).join('');
}

// ── Tab navigation ───────────────────────────────
function switchTab(name) {
    if (activeTab === name) return;
    if (activeTab === 'games') closeGame();
    document.querySelectorAll('.tab-pane').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.nb').forEach(b=>b.classList.remove('active'));
    $('tab-'+name).classList.add('active');
    document.querySelector(`[data-tab="${name}"]`).classList.add('active');
    activeTab = name;
    vib(10);
    if (name === 'profile') {
        updateProfile(currentUser);
        renderAchievements();
        // Clear badge
        newAchCount = 0;
        const badge = $('ach-badge');
        if (badge) badge.classList.add('hidden');
    }
    if (name === 'shop') updateShopAffordability();
}
window.switchTab = switchTab;

// ── Case loading ─────────────────────────────────
function loadCase() {
    const card = $('main-card');
    $('case-description').textContent = 'Архив обрабатывает запрос…';
    $('card-type').textContent = '📁 ДЕЛО';
    caseCounter++;
    $('card-num').textContent = '#' + String(caseCounter).padStart(3,'0');
    $('result-overlay').classList.add('hidden');
    $('stamp-accept').style.opacity = '0';
    $('stamp-deny').style.opacity   = '0';

    card.style.transition = 'none';
    card.style.transform  = 'none';
    card.style.opacity    = '1';
    card.classList.remove('tilt-left','tilt-right');

    fetch('/api/game/case?providerId='+enc(currentUser.providerId))
    .then(r=>r.text())
    .then(raw=>{
        let d;
        try {
            d = JSON.parse(raw);
            if (typeof d==='string') d = JSON.parse(d);
        } catch {
            d = {text:raw, leftOption:'ОТКЛОНИТЬ', rightOption:'ОДОБРИТЬ',
                 leftResult:'Вы отклонили дело.', rightResult:'Вы одобрили дело.'};
        }
        currentCase = d;
        $('case-description').textContent = d.text;
        $('card-type').textContent = d.type ? caseTypeLabel(d.type) : '📁 ДЕЛО';
        $('ca-left').textContent   = '✕ ' + (d.leftOption  || 'ОТКЛОНИТЬ');
        $('ca-right').textContent  = (d.rightOption || 'ОДОБРИТЬ') + ' ✓';
    })
    .catch(()=>{ $('case-description').textContent='⚠️ Архив недоступен'; });
}

function caseTypeLabel(t) {
    const m = {detective:'🔍 РАССЛЕДОВАНИЕ', medical:'⚕️ МЕДИЦИНА', tech:'💻 ТЕХНОЛОГИИ',
               social:'👥 СОЦИУМ', criminal:'⚖️ УГОЛОВНОЕ', emergency:'🚨 СРОЧНО'};
    return m[t] || '📁 ДЕЛО';
}

// ── Swipe ────────────────────────────────────────
function initSwipe() {
    const card = $('main-card');
    let sx=0, sy=0, cx=0, dragging=false;
    let lx=0, vel=0, lt=0;

    const start = e=>{
        if (!$('result-overlay').classList.contains('hidden')) return;
        if (!currentCase) return;
        dragging=true; sx=gx(e); sy=gy(e); lx=sx; lt=Date.now();
        card.style.transition='none';
    };
    const move = e=>{
        if (!dragging) return; e.preventDefault();
        cx=gx(e);
        const now=Date.now(); vel=(cx-lx)/Math.max(1,now-lt); lx=cx; lt=now;
        const dx=cx-sx, rot=dx/18;
        card.style.transform=`translateX(${dx}px) rotate(${rot}deg)`;
        const r=Math.min(1,Math.abs(dx)/70);
        if (dx<-25){
            card.classList.add('tilt-left'); card.classList.remove('tilt-right');
            $('stamp-deny').style.opacity   = r;
            $('stamp-accept').style.opacity = '0';
        } else if (dx>25){
            card.classList.add('tilt-right'); card.classList.remove('tilt-left');
            $('stamp-accept').style.opacity = r;
            $('stamp-deny').style.opacity   = '0';
        } else {
            card.classList.remove('tilt-left','tilt-right');
            $('stamp-accept').style.opacity='0';
            $('stamp-deny').style.opacity='0';
        }
    };
    const end = ()=>{
        if (!dragging) return; dragging=false;
        const dx=cx-sx, THRESH=85, VTHRESH=0.38;
        card.style.transition='transform .32s cubic-bezier(.25,.46,.45,.94)';
        if (dx<-THRESH || vel<-VTHRESH)      fly('left');
        else if (dx>THRESH || vel>VTHRESH)   fly('right');
        else {
            card.style.transform='none';
            card.classList.remove('tilt-left','tilt-right');
            $('stamp-accept').style.opacity='0';
            $('stamp-deny').style.opacity='0';
        }
    };

    card.addEventListener('touchstart', start, {passive:true});
    card.addEventListener('mousedown',  start);
    window.addEventListener('touchmove',  move, {passive:false});
    window.addEventListener('mousemove',  move);
    window.addEventListener('touchend',   end);
    window.addEventListener('mouseup',    end);
}

function gx(e){return e.touches?e.touches[0].clientX:e.clientX}
function gy(e){return e.touches?e.touches[0].clientY:e.clientY}

function fly(dir) {
    const card=$('main-card');
    card.style.transition='transform .38s cubic-bezier(.55,0,1,.45),opacity .38s ease';
    card.style.transform =`translateX(${dir==='left'?'-160vw':'160vw'}) rotate(${dir==='left'?'-28deg':'28deg'})`;
    card.style.opacity='0';
    vib(25);
    sendChoice(dir);
}

function sendChoice(dir) {
    if (!currentUser||!currentCase) return;
    fetch(`/api/game/choice?providerId=${enc(currentUser.providerId)}&direction=${dir}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('⚡','Нет энергии',t);throw 0;}); return r.json(); })
    .then(data=>{
        currentUser=data.profile;
        updateHUD(currentUser);
        const ok=dir==='right';
        const stamp=$('ro-stamp');
        stamp.textContent = ok?'ОДОБРЕНО':'ОТКЛОНЕНО';
        stamp.className   = 'ro-stamp '+(ok?'accept':'deny');
        $('result-text').textContent   = ok?currentCase.rightResult:currentCase.leftResult;
        $('rew-xp').textContent        = data.xpGained;
        $('rew-credits').textContent   = data.creditsGained;
        $('rew-energy').textContent    = data.energyLost;
        setTimeout(()=>{ $('result-overlay').classList.remove('hidden'); checkAch(data.profile); }, 300);
        vib([30,20,60]);
    })
    .catch(()=>{
        const card=$('main-card');
        card.style.transition='transform .35s cubic-bezier(.34,1.56,.64,1)';
        card.style.transform='none'; card.style.opacity='1';
        card.classList.remove('tilt-left','tilt-right');
        $('stamp-accept').style.opacity='0'; $('stamp-deny').style.opacity='0';
    });
}

function nextCase() {
    $('result-overlay').classList.add('hidden');
    const card=$('main-card');
    card.style.transition='none';
    card.style.opacity='0'; card.style.transform='translateX(30px)';
    loadCase();
    requestAnimationFrame(()=>requestAnimationFrame(()=>{
        card.style.transition='transform .38s cubic-bezier(.34,1.56,.64,1),opacity .28s ease';
        card.style.transform='none'; card.style.opacity='1';
    }));
}
window.nextCase = nextCase;

// ── Skills ────────────────────────────────────────
function upgradeSkill(n) {
    if (!currentUser) return;
    fetch(`/api/game/upgrade-skill?providerId=${enc(currentUser.providerId)}&skillNum=${n}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('💎','Мало кредитов',t);throw 0;}); return r.json(); })
    .then(p=>{ currentUser=p; updateHUD(p); updateProfile(p); vib([20,20,40]);
        toast('🧠','НАВЫК ПРОКАЧАН', n===1?'Проницательность Lv.'+p.skill1:'Технологии Lv.'+p.skill2); })
    .catch(()=>{});
}
window.upgradeSkill = upgradeSkill;

// ── Shop ─────────────────────────────────────────
function buyCoffee() {
    if (!currentUser) return;
    fetch(`/api/game/buy-coffee?providerId=${enc(currentUser.providerId)}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('☕','Мало кредитов',t);throw 0;}); return r.json(); })
    .then(p=>{ currentUser=p; updateHUD(p); updateProfile(p); updateShopAffordability();
        toast('☕','КОФЕ ВЫПИТ','+35 ⚡ энергии'); vib(30); })
    .catch(()=>{});
}
window.buyCoffee = buyCoffee;

function updateShopAffordability() {
    if (!currentUser) return;
    const coffee = $('shop-coffee');
    if (coffee) {
        const can = currentUser.credits >= 40;
        coffee.classList.toggle('cant-afford', !can);
        const price = $('coffee-price');
        if (price) price.textContent = can ? '40 💎' : '40 💎 (не хватает)';
    }
}

// ── Daily bonus ──────────────────────────────────
function checkDailyBonus() {
    if (!currentUser) return;
    fetch('/api/game/daily-bonus?providerId='+enc(currentUser.providerId))
    .then(r=>r.ok?r.json():null)
    .then(data=>{
        if (!data||!data.available) return;
        buildWeekCalendar(data.streak||1);
        $('daily-days').textContent = data.streak||1;
        $('daily-modal').classList.remove('hidden');
    })
    .catch(()=>{});
}

function buildWeekCalendar(streak) {
    const wrap = $('daily-week');
    if (!wrap) return;
    wrap.innerHTML = '';
    for (let i=1;i<=7;i++){
        const d = document.createElement('div');
        d.className = 'dw-dot';
        if (i < streak % 7 || (streak >= 7 && i <= 7)) d.classList.add('done');
        if (i === (streak % 7 || 7)) d.classList.add('today');
        d.textContent = i;
        wrap.appendChild(d);
    }
}

function claimDaily() {
    if (!currentUser||dailyClaimed) return;
    dailyClaimed = true;
    $('daily-modal').classList.add('hidden');
    fetch('/api/game/daily-bonus/claim?providerId='+enc(currentUser.providerId),{method:'POST'})
    .then(r=>r.ok?r.json():null)
    .then(data=>{
        if (!data) return;
        currentUser=data.profile; updateHUD(currentUser); updateProfile(currentUser);
        toast('🎁','БОНУС ПОЛУЧЕН',`+50💎 · +30⚡ · Серия: ${data.profile.streak} дн.`);
        vib([30,20,30,20,80]);
    })
    .catch(()=>{});
}
window.claimDaily = claimDaily;

// ── Achievements ─────────────────────────────────
function checkAch(profile) {
    let found=false;
    for (const d of ACH_DEFS) {
        if (!earnedAch.has(d.id) && d.check(profile)) {
            earnedAch.add(d.id);
            localStorage.setItem('sdvig_ach', JSON.stringify([...earnedAch]));
            if (!found) { setTimeout(()=>toast(d.icon, d.title, d.desc), 500); found=true; }
            newAchCount++;
            const badge=$('ach-badge');
            if (badge) { badge.textContent='!'; badge.classList.remove('hidden'); }
        }
    }
}

// ── Toast ────────────────────────────────────────
let _toastTimer=null;
function toast(icon,title,desc){
    const el=$('toast');
    $('toast-icon').textContent  = icon;
    $('toast-title').textContent = title;
    $('toast-desc').textContent  = desc;
    el.classList.remove('hidden','out');
    clearTimeout(_toastTimer);
    _toastTimer=setTimeout(()=>{
        el.classList.add('out');
        setTimeout(()=>el.classList.add('hidden'),320);
    },3200);
    vib(20);
}

// ── Games ─────────────────────────────────────────
const GTITLES = {detective:'💎 Самоцветы', doctor:'💓 Кардиограмма', universal:'🧮 Экспертиза шифра'};

function launchGame(type) {
    $('gvp-wrap').classList.remove('hidden');
    $('gvp-title').textContent = GTITLES[type]||'Игра';
    $('win-badge').classList.add('hidden');
    const vp = $('game-vp');
    vp.innerHTML='';
    if (currentGameDestroy){try{currentGameDestroy();}catch(e){} currentGameDestroy=null;}
    const level = gameLevel(type);

    import('./games/'+type+'.js')
    .then(mod=>{
        currentGameDestroy = mod.destroy;
        mod.initGame(vp, level, ()=>onWin(type));
    })
    .catch(()=>{ vp.innerHTML='<div style="color:var(--red);text-align:center;padding:24px">⚠️ Ошибка загрузки игры</div>'; });
}
window.launchGame = launchGame;

function gameLevel(t){
    if (!currentUser) return 1;
    return currentUser[{detective:'detectiveLvl',doctor:'doctorLvl',universal:'universalLvl'}[t]] || 1;
}

function onWin(type) {
    $('win-badge').classList.remove('hidden');
    vib([30,20,30,20,100]);
    toast('🎮','УРОВЕНЬ ПРОЙДЕН','+50 XP');
    fetch(`/api/game/advance-level?providerId=${enc(currentUser.providerId)}&gameType=${type}`,{method:'POST'})
    .then(r=>r.ok?r.json():null)
    .then(p=>{ if(p){currentUser=p;updateHUD(p);updateProfile(p);} })
    .catch(()=>{});
}

function closeGame() {
    if (currentGameDestroy){try{currentGameDestroy();}catch(e){} currentGameDestroy=null;}
    $('gvp-wrap').classList.add('hidden');
    $('game-vp').innerHTML='';
    $('win-badge').classList.add('hidden');
}
window.closeGame = closeGame;

// ── Utils ─────────────────────────────────────────
function enc(s){ return encodeURIComponent(s); }
function vib(p){ try{if(navigator.vibrate)navigator.vibrate(p);}catch(e){} }

SDVIG_EOF

echo "  ✦ $S/games/detective.js"
mkdir -p $(dirname "$S/games/detective.js")
cat > "$S/games/detective.js" << 'SDVIG_EOF'
// ─── САМОЦВЕТЫ · Match-3 ──────────────────────────

const GEMS = ['🔴','🔵','🟢','🟡','🟣','🟠'];
const COLORS = ['red','blue','green','yellow','purple','orange'];
const GEM_CSS = {
    red:'#d95454', blue:'#4a8cdb', green:'#3eb077',
    yellow:'#d4971a', purple:'#8b72d4', orange:'#d4691a'
};

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'12px', width:'100%'
    });

    const ROWS=9, COLS=9;
    const mission = getMission(level);
    let collected=0, iceCleared=0, combo=0;
    let board    = mk2d(ROWS, COLS, null);
    let ice      = mk2d(ROWS, COLS, 0);
    let selR=null, selC=null;
    let active=true, busy=false;

    // Cell size — responsive
    const vw   = Math.min(viewport.offsetWidth || window.innerWidth, 400);
    const GAP  = 3, PAD = 10;
    const CELL = Math.floor((vw - PAD*2 - GAP*(COLS-1)) / COLS);

    // ── Header ───────────────────────────────────
    const hdr = div({
        background:'var(--s1)', border:'1px solid var(--b2)',
        borderRadius:'var(--r)', padding:'10px 14px',
        width:'100%', textAlign:'center',
        fontFamily:'inherit', color:'var(--tx)', fontSize:'13px'
    });
    const lvlEl = div({fontSize:'10px',letterSpacing:'2px',color:'var(--tx3)',
        fontWeight:'700',textTransform:'uppercase',marginBottom:'4px'});
    lvlEl.textContent = 'УРОВЕНЬ ' + level;
    const msnEl = div({fontWeight:'600'});
    const cmbEl = div({fontSize:'11px',color:'var(--amber)',fontWeight:'700',
        letterSpacing:'1px',minHeight:'16px',marginTop:'4px'});
    hdr.append(lvlEl, msnEl, cmbEl);
    viewport.appendChild(hdr);
    refreshMission();

    // ── Grid ─────────────────────────────────────
    const grid = div({
        display:'grid',
        gridTemplateColumns:`repeat(${COLS}, ${CELL}px)`,
        gap: GAP+'px',
        background:'var(--s1)',
        padding: PAD+'px',
        borderRadius:'var(--r-xl)',
        border:'1px solid var(--b2)',
        boxShadow:'0 12px 40px rgba(0,0,0,.4)'
    });
    viewport.appendChild(grid);

    const cells = mk2d(ROWS, COLS, null);

    for (let r=0;r<ROWS;r++) {
        for (let c=0;c<COLS;c++) {
            const cell = div({
                width: CELL+'px', height: CELL+'px',
                borderRadius:'6px',
                display:'flex', alignItems:'center', justifyContent:'center',
                fontSize: Math.max(16, CELL-12)+'px',
                cursor:'pointer',
                border:'1.5px solid transparent',
                transition:'transform .1s, border-color .1s, background .1s',
                lineHeight:'1', userSelect:'none', WebkitUserSelect:'none',
                flexShrink:'0'
            });
            cell.addEventListener('click', ((r,c)=>()=>onCell(r,c))(r,c));
            grid.appendChild(cell);
            cells[r][c] = cell;
        }
    }

    // ── Render ───────────────────────────────────
    function render() {
        for (let r=0;r<ROWS;r++) {
            for (let c=0;c<COLS;c++) {
                const el    = cells[r][c];
                const color = board[r][c];
                const isIce = ice[r][c] > 0;
                const isSel = selR===r && selC===c;
                const gemIdx= COLORS.indexOf(color);
                el.textContent = GEMS[gemIdx] ?? '';
                el.style.background    = isIce ? 'rgba(74,140,219,.18)' : 'var(--s2)';
                el.style.borderColor   = isSel  ? 'var(--amber)'
                                       : isIce  ? 'rgba(74,140,219,.5)'
                                       : 'transparent';
                el.style.boxShadow     = isSel ? '0 0 0 2px var(--amber)' : 'none';
                el.style.transform     = isSel ? 'scale(1.1)' : 'scale(1)';
                el.style.filter        = isIce && ice[r][c]===2
                    ? 'brightness(.55) saturate(.4)'
                    : isIce ? 'brightness(.75) saturate(.6)' : 'none';
            }
        }
    }

    // ── Match logic ──────────────────────────────
    function matches() {
        const m = new Set();
        for (let r=0;r<ROWS;r++){
            let l=1;
            for (let c=1;c<=COLS;c++){
                if (c<COLS && board[r][c]===board[r][c-1]) l++;
                else { if(l>=3) for(let i=c-l;i<c;i++) m.add(r+','+i); l=1; }
            }
        }
        for (let c=0;c<COLS;c++){
            let l=1;
            for (let r=1;r<=ROWS;r++){
                if (r<ROWS && board[r][c]===board[r-1][c]) l++;
                else { if(l>=3) for(let i=r-l;i<r;i++) m.add(i+','+c); l=1; }
            }
        }
        return m;
    }

    function processMatches(m) {
        let gcol=0, gice=0;
        for (const k of m) {
            const [r,c] = k.split(',').map(Number);
            if (ice[r][c]>0) { ice[r][c]--; if (ice[r][c]===0) gice++; }
        }
        for (const k of m) {
            const [r,c] = k.split(',').map(Number);
            if (ice[r][c]===0 && mission.color && board[r][c]===mission.color) gcol++;
        }
        for (const k of m) {
            const [r,c] = k.split(',').map(Number);
            board[r][c] = null; ice[r][c] = 0;
        }
        collected  += gcol; iceCleared += gice; combo++;
        if (combo > 1) {
            cmbEl.textContent = '✨ COMBO ×'+combo+'!';
            setTimeout(()=>{cmbEl.textContent='';}, 1100);
        }
        refreshMission(); checkWin();
    }

    function gravity() {
        for (let c=0;c<COLS;c++) {
            const g=[], ic=[];
            for (let r=ROWS-1;r>=0;r--)
                if (board[r][c]!==null) { g.push(board[r][c]); ic.push(ice[r][c]); }
            while (g.length<ROWS){ g.push(COLORS[rnd(COLORS.length)]); ic.push(0); }
            g.reverse(); ic.reverse();
            for (let r=0;r<ROWS;r++) { board[r][c]=g[r]; ice[r][c]=ic[r]; }
        }
    }

    async function resolve() {
        if (busy) return; busy=true;
        let any=true;
        while (any && active) {
            const m = matches();
            if (!m.size) { any=false; break; }
            processMatches(m);
            if (!active) break;
            gravity(); render();
            await wait(75);
        }
        busy=false;
        if (active && !hasMoves()) shuffle();
        render();
    }

    function hasMoves() {
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) {
            if (c+1<COLS) { sw(r,c,r,c+1); if(matches().size){sw(r,c,r,c+1);return true;} sw(r,c,r,c+1); }
            if (r+1<ROWS) { sw(r,c,r+1,c); if(matches().size){sw(r,c,r+1,c);return true;} sw(r,c,r+1,c); }
        }
        return false;
    }

    function shuffle() {
        const flat = board.flat();
        for (let i=flat.length-1;i>0;i--){ const j=rnd(i+1); [flat[i],flat[j]]=[flat[j],flat[i]]; }
        let idx=0;
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) board[r][c]=flat[idx++];
        resolve();
    }

    function sw(r1,c1,r2,c2){
        [board[r1][c1],board[r2][c2]]=[board[r2][c2],board[r1][c1]];
        [ice[r1][c1],ice[r2][c2]]=[ice[r2][c2],ice[r1][c1]];
    }

    async function trySwap(r1,c1,r2,c2) {
        if (busy||!active) return;
        sw(r1,c1,r2,c2);
        if (matches().size) { combo=0; render(); await resolve(); }
        else { sw(r1,c1,r2,c2); render(); }
    }

    function onCell(r,c) {
        if (busy||!active) return;
        if (selR===null) { selR=r; selC=c; render(); return; }
        if (selR===r&&selC===c) { selR=null; selC=null; render(); return; }
        const adj = Math.abs(selR-r)+Math.abs(selC-c)===1;
        if (!adj) { selR=r; selC=c; render(); return; }
        const [r1,c1]=[selR,selC]; selR=null; selC=null;
        trySwap(r1,c1,r,c);
    }

    // ── Board init ───────────────────────────────
    function initBoard() {
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) {
            const no=new Set();
            if (c>=2&&board[r][c-1]===board[r][c-2]) no.add(board[r][c-1]);
            if (r>=2&&board[r-1][c]===board[r-2][c]) no.add(board[r-1][c]);
            const ok=COLORS.filter(x=>!no.has(x));
            board[r][c]=ok[rnd(ok.length)]||COLORS[0];
        }
    }

    function placeIce() {
        const n = mission.type==='clear_ice' ? mission.target
                : mission.targetIce || 0;
        if (!n) return;
        const pos=[];
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) pos.push([r,c]);
        pos.sort(()=>Math.random()-.5);
        for (let i=0;i<Math.min(n,pos.length);i++) {
            const [r,c]=pos[i]; ice[r][c]= level>25?2:1;
        }
    }

    function checkWin() {
        const done =
            mission.type==='collect'   ? collected>=mission.target :
            mission.type==='clear_ice' ? iceCleared>=mission.target :
            collected>=mission.targetCollect && iceCleared>=mission.targetIce;
        if (done&&active) { active=false; onWin(); }
    }

    function refreshMission() {
        const gem = GEMS[COLORS.indexOf(mission.color)] || '';
        if (mission.type==='collect')
            msnEl.textContent=`${gem} Собери: ${collected} / ${mission.target}`;
        else if (mission.type==='clear_ice')
            msnEl.textContent=`❄️ Разморозь: ${iceCleared} / ${mission.target}`;
        else
            msnEl.textContent=`${gem} ${collected}/${mission.targetCollect}  ❄️ ${iceCleared}/${mission.targetIce}`;
    }

    initBoard(); placeIce(); render();
    if (!hasMoves()) shuffle();
}

// ── Helpers ───────────────────────────────────────
function getMission(l) {
    if (l<=5)  return {type:'collect', color:'blue',   target:10+l};
    if (l<=10) return {type:'collect', color:'green',  target:15+(l-5)*2};
    if (l<=15) return {type:'collect', color:'purple', target:20+(l-10)*3};
    if (l<=20) return {type:'clear_ice', target:5+(l-15)};
    return {type:'mixed',color:'blue',targetCollect:20+(l-20)*2,targetIce:8+Math.floor((l-20)/2)};
}
function mk2d(r,c,v){return Array.from({length:r},()=>Array(c).fill(v))}
function rnd(n){return Math.floor(Math.random()*n)}
function wait(ms){return new Promise(r=>setTimeout(r,ms))}
function div(styles){ const d=document.createElement('div'); Object.assign(d.style,styles); return d; }

export function destroy() {}

SDVIG_EOF

echo "  ✦ $S/games/doctor.js"
mkdir -p $(dirname "$S/games/doctor.js")
cat > "$S/games/doctor.js" << 'SDVIG_EOF'
// ─── КАРДИОГРАММА · Precision tap ────────────────

let _raf = null;
let _tapped = false;

export function initGame(viewport, level, onWin) {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;

    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'20px',
        padding:'8px 4px', width:'100%'
    });

    const speed = 2 + level * 0.13;
    const zoneW = Math.max(7, 32 - level * 0.24); // % ширина зоны
    const zoneL = 12 + Math.random() * (72 - zoneW);

    // ── Шапка ────────────────────────────────────
    const hdr = el('div', {
        textAlign:'center', width:'100%',
        fontFamily:'inherit'
    });
    hdr.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--tx3);font-weight:700;text-transform:uppercase;">УРОВЕНЬ ${level}</div>
        <div style="font-size:44px;margin:8px 0;line-height:1;" id="doc-heart">💓</div>
        <div style="font-size:14px;color:var(--tx2);font-weight:600;">Поймай импульс в зелёной зоне</div>
    `;
    viewport.appendChild(hdr);

    // Мини-ЭКГ декоративная
    const ekgSvg = `<svg width="100%" height="36" viewBox="0 0 340 36"
        style="opacity:.2;display:block;margin:0 auto;max-width:340px;">
        <polyline fill="none" stroke="var(--red)" stroke-width="1.5"
            points="0,18 28,18 36,4 42,32 48,18 58,18 86,18 94,4 100,32 106,18
                    116,18 144,18 152,4 158,32 164,18 174,18 202,18 210,4 216,32
                    222,18 232,18 260,18 268,4 274,32 280,18 290,18 318,18 326,4 332,32 340,18"/>
    </svg>`;
    const ekgWrap = el('div', {width:'100%'});
    ekgWrap.innerHTML = ekgSvg;
    viewport.appendChild(ekgWrap);

    // ── Трек ─────────────────────────────────────
    const trackWrap = el('div', {width:'100%', maxWidth:'340px'});

    const track = el('div', {
        width:'100%', height:'72px',
        background:'var(--s1)', border:'1px solid var(--b2)',
        borderRadius:'var(--r)', position:'relative',
        overflow:'hidden', cursor:'pointer',
        userSelect:'none', WebkitUserSelect:'none'
    });

    // Зелёная зона
    const zone = el('div', {
        position:'absolute', top:'0', bottom:'0',
        left: zoneL+'%', width: zoneW+'%',
        background:'var(--green-d)',
        borderLeft:'2px solid var(--green)',
        borderRight:'2px solid var(--green)',
        transition:'background .1s'
    });
    track.appendChild(zone);

    // Пин
    const pin = el('div', {
        position:'absolute', top:'10px', bottom:'10px', width:'3px',
        background:'var(--red)', borderRadius:'99px',
        transform:'translateX(-50%)',
        boxShadow:'0 0 8px var(--red)',
        transition:'background .15s, box-shadow .15s'
    });
    track.appendChild(pin);
    trackWrap.appendChild(track);
    viewport.appendChild(trackWrap);

    // ── Подсказка ─────────────────────────────────
    const hint = el('div', {
        fontSize:'14px', color:'var(--tx2)',
        fontWeight:'600', textAlign:'center',
        minHeight:'22px', letterSpacing:'.3px'
    });
    hint.textContent = '↓ Нажмите в любом месте ↓';
    viewport.appendChild(hint);

    // ── Параметры уровня ──────────────────────────
    const info = el('div', {
        display:'flex', gap:'20px', justifyContent:'center',
        background:'var(--s2)', border:'1px solid var(--b)',
        borderRadius:'var(--r)', padding:'10px 24px',
        width:'100%', maxWidth:'280px'
    });
    info.innerHTML = `
        <div style="text-align:center">
            <div style="font-size:9px;letter-spacing:1.5px;color:var(--tx3);font-weight:700;text-transform:uppercase;">СКОРОСТЬ</div>
            <div style="font-size:20px;font-weight:800;color:var(--red);margin-top:2px;">${speed.toFixed(1)}×</div>
        </div>
        <div style="width:1px;background:var(--b)"></div>
        <div style="text-align:center">
            <div style="font-size:9px;letter-spacing:1.5px;color:var(--tx3);font-weight:700;text-transform:uppercase;">ЗОНА</div>
            <div style="font-size:20px;font-weight:800;color:var(--green);margin-top:2px;">${Math.round(zoneW)}%</div>
        </div>
    `;
    viewport.appendChild(info);

    // ── Анимация ─────────────────────────────────
    let pos = 0, dir = 1;
    let lastTime = performance.now();

    function frame(ts) {
        const dt = Math.min(ts - lastTime, 50); lastTime = ts;
        pos += speed * dir * dt / 16;
        if (pos >= 100) { pos = 100; dir = -1; }
        if (pos <= 0)   { pos = 0;   dir = 1;  }
        // chaos at high levels
        if (level > 60 && Math.random() > .994) dir *= -1;
        pin.style.left = pos + '%';
        _raf = requestAnimationFrame(frame);
    }
    _raf = requestAnimationFrame(frame);

    // ── Тап ──────────────────────────────────────
    viewport.addEventListener('click', () => {
        if (_tapped) return;
        const inZone = pos >= zoneL && pos <= zoneL + zoneW;

        if (inZone) {
            _tapped = true;
            cancelAnimationFrame(_raf); _raf = null;
            hint.textContent = '✓ ПОПАДАНИЕ!';
            hint.style.color = 'var(--green)';
            hint.style.fontWeight = '800';
            pin.style.background  = 'var(--green)';
            pin.style.boxShadow   = '0 0 10px var(--green)';
            zone.style.background = 'rgba(62,176,119,.35)';
            if (navigator.vibrate) navigator.vibrate([30, 20, 60]);
            setTimeout(() => onWin(), 380);
        } else {
            if (navigator.vibrate) navigator.vibrate(80);
            track.classList.add('doc-shake');
            hint.textContent = '✗ Мимо — попробуйте ещё';
            hint.style.color = 'var(--red)';
            pin.style.boxShadow = '0 0 14px var(--red)';
            setTimeout(() => {
                track.classList.remove('doc-shake');
                if (!_tapped) {
                    hint.textContent = '↓ Нажмите ещё раз ↓';
                    hint.style.color = 'var(--tx2)';
                    pin.style.boxShadow = '0 0 8px var(--red)';
                }
            }, 450);
        }
    });
}

function el(tag, styles) {
    const d = document.createElement(tag);
    Object.assign(d.style, styles);
    return d;
}

export function destroy() {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;
}

SDVIG_EOF

echo "  ✦ $S/games/universal.js"
mkdir -p $(dirname "$S/games/universal.js")
cat > "$S/games/universal.js" << 'SDVIG_EOF'
// ─── ЭКСПЕРТИЗА ШИФРА · Math cipher ──────────────

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'16px', width:'100%'
    });

    const target   = 10 + level * 4 + Math.floor(Math.random() * 6);
    const count    = level <= 10 ? 6 : level <= 40 ? 9 : 12;
    const maxVal   = 4 + Math.floor(level / 2);
    let   sumNow   = 0;
    const picked   = new Set();

    // Генерируем числа с гарантированным решением
    const nums = Array.from({length: count}, () => Math.floor(Math.random() * maxVal) + 2);
    let acc = 0;
    for (let i = 0; i < nums.length; i++) {
        if (acc + nums[i] <= target) acc += nums[i];
    }
    if (acc !== target) nums[nums.length - 1] = target - acc + (acc > 0 ? 0 : nums[0]);

    // ── Шапка ────────────────────────────────────
    const hdr = document.createElement('div');
    hdr.style.cssText = 'text-align:center;width:100%;';
    hdr.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--tx3);font-weight:700;
            text-transform:uppercase;margin-bottom:4px;">УРОВЕНЬ ${level} · ШИФР</div>
        <div style="font-size:13px;color:var(--tx2);font-weight:600;">Выбери числа в сумме:</div>
    `;
    viewport.appendChild(hdr);

    // ── Цель ─────────────────────────────────────
    const targetBox = document.createElement('div');
    targetBox.style.cssText = `
        background:var(--s1);border:1px solid var(--b2);
        border-radius:var(--r);padding:14px 36px;text-align:center;
        box-shadow:0 4px 20px rgba(212,151,26,.08);
    `;
    targetBox.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:var(--amber);
            font-weight:700;text-transform:uppercase;">ЦЕЛЬ</div>
        <div id="cipher-target" style="font-size:52px;font-weight:800;
            color:var(--tx);line-height:1.1;">${target}</div>
    `;
    viewport.appendChild(targetBox);

    // ── Прогресс ─────────────────────────────────
    const progWrap = document.createElement('div');
    progWrap.style.cssText = 'width:100%;max-width:300px;';
    progWrap.innerHTML = `
        <div style="display:flex;justify-content:space-between;
            font-size:11px;color:var(--tx3);font-weight:600;
            margin-bottom:6px;letter-spacing:.3px;">
            <span>ТЕКУЩАЯ СУММА</span>
            <span id="cs-lbl">0 / ${target}</span>
        </div>
        <div style="height:4px;background:var(--s3);border-radius:99px;overflow:hidden;">
            <div id="cs-bar" style="height:100%;width:0%;
                background:var(--amber);border-radius:99px;
                transition:width .2s ease,background .15s;"></div>
        </div>
    `;
    viewport.appendChild(progWrap);

    // ── Сетка числе ──────────────────────────────
    const grid = document.createElement('div');
    grid.style.cssText = `
        display:flex;flex-wrap:wrap;gap:8px;
        justify-content:center;max-width:320px;
    `;
    viewport.appendChild(grid);

    // ── Статус ────────────────────────────────────
    const status = document.createElement('div');
    status.style.cssText = `
        font-size:12px;color:var(--tx3);min-height:18px;
        text-align:center;font-weight:500;letter-spacing:.3px;
    `;
    viewport.appendChild(status);

    // Строим ячейки
    for (let i = 0; i < count; i++) {
        const val  = nums[i];
        const cell = document.createElement('div');
        cell.className  = 'cipher-cell';
        cell.textContent = val;
        cell.dataset.idx = i;

        cell.addEventListener('click', () => {
            if (picked.has(i)) {
                // Снимаем
                picked.delete(i);
                sumNow -= val;
                cell.classList.remove('sel');
            } else {
                picked.add(i);
                sumNow += val;
                cell.classList.add('sel');

                if (sumNow === target) {
                    // WIN
                    grid.querySelectorAll('.cipher-cell').forEach(c => {
                        c.style.pointerEvents = 'none';
                        if (c.classList.contains('sel')) {
                            c.style.borderColor = 'var(--green)';
                            c.style.background  = 'var(--green-d)';
                            c.style.color       = 'var(--green)';
                            c.style.boxShadow   = '0 0 10px rgba(62,176,119,.3)';
                        }
                    });
                    status.textContent = '✓ ШИФР ВЗЛОМАН!';
                    status.style.color = 'var(--green)';
                    status.style.fontWeight = '700';
                    setProgress(target, target);
                    if (navigator.vibrate) navigator.vibrate([30,20,60]);
                    setTimeout(() => onWin(), 450);
                    return;
                }

                if (sumNow > target) {
                    // Перебор — сброс
                    cell.classList.add('over');
                    setTimeout(() => cell.classList.remove('over'), 280);
                    if (navigator.vibrate) navigator.vibrate(70);
                    status.textContent = '⚠ Сумма превышена — сброс';
                    status.style.color = 'var(--red)';
                    setTimeout(() => {
                        if (status.style.color !== 'var(--green)') {
                            status.textContent = '';
                            status.style.color = 'var(--tx3)';
                        }
                    }, 1100);
                    grid.querySelectorAll('.cipher-cell').forEach(c => c.classList.remove('sel'));
                    picked.clear();
                    sumNow = 0;
                    setProgress(0, target);
                    return;
                }
            }
            setProgress(sumNow, target);
        });

        grid.appendChild(cell);
    }

    function setProgress(cur, max) {
        const pct = Math.min(100, Math.round(cur / max * 100));
        const bar = document.getElementById('cs-bar');
        const lbl = document.getElementById('cs-lbl');
        if (bar) {
            bar.style.width = pct + '%';
            bar.style.background =
                cur > max   ? 'var(--red)' :
                cur === max ? 'var(--green)' : 'var(--amber)';
        }
        if (lbl) lbl.textContent = `${cur} / ${max}`;
    }
}

export function destroy() {}

SDVIG_EOF

echo "  ✦ $J/model/PlayerProfile.java"
mkdir -p $(dirname "$J/model/PlayerProfile.java")
cat > "$J/model/PlayerProfile.java" << 'SDVIG_EOF'
package com.example.sdvig.model;

import jakarta.persistence.*;

@Entity
@Table(name = "player_profiles")
public class PlayerProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(unique = true, nullable = false)
    private String providerId;

    private String username;
    private String firstName;
    private String archetype = "detective";

    private int energy      = 100;
    private int credits     = 150;
    private int rank        = 1;
    private int xp          = 0;

    // Skills
    private int skill1      = 1; // Проницательность → XP boost
    private int skill2      = 1; // Технологии → energy reduction

    // Game levels
    private int detectiveLvl  = 1;
    private int doctorLvl     = 1;
    private int universalLvl  = 1;

    // Stats
    private int totalCases    = 0;
    private int streak        = 0;

    // Daily bonus: stored as "YYYY-MM-DD"
    @Column(name = "last_daily_bonus")
    private String lastDailyBonus = "";

    public PlayerProfile() {}

    // ── Getters / Setters ─────────────────────

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getProviderId() { return providerId; }
    public void setProviderId(String providerId) { this.providerId = providerId; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getArchetype() { return archetype; }
    public void setArchetype(String archetype) { this.archetype = archetype; }

    public int getEnergy() { return energy; }
    public void setEnergy(int energy) { this.energy = energy; }

    public int getCredits() { return credits; }
    public void setCredits(int credits) { this.credits = credits; }

    public int getRank() { return rank; }
    public void setRank(int rank) { this.rank = rank; }

    public int getXp() { return xp; }
    public void setXp(int xp) { this.xp = xp; }

    public int getSkill1() { return skill1; }
    public void setSkill1(int skill1) { this.skill1 = skill1; }

    public int getSkill2() { return skill2; }
    public void setSkill2(int skill2) { this.skill2 = skill2; }

    public int getDetectiveLvl() { return detectiveLvl; }
    public void setDetectiveLvl(int detectiveLvl) { this.detectiveLvl = detectiveLvl; }

    public int getDoctorLvl() { return doctorLvl; }
    public void setDoctorLvl(int doctorLvl) { this.doctorLvl = doctorLvl; }

    public int getUniversalLvl() { return universalLvl; }
    public void setUniversalLvl(int universalLvl) { this.universalLvl = universalLvl; }

    public int getTotalCases() { return totalCases; }
    public void setTotalCases(int totalCases) { this.totalCases = totalCases; }

    public int getStreak() { return streak; }
    public void setStreak(int streak) { this.streak = streak; }

    public String getLastDailyBonus() { return lastDailyBonus; }
    public void setLastDailyBonus(String lastDailyBonus) { this.lastDailyBonus = lastDailyBonus; }

    // Legacy field kept for Hibernate compatibility
    private int currentGameLevel = 1;
    public int getCurrentGameLevel() { return currentGameLevel; }
    public void setCurrentGameLevel(int currentGameLevel) { this.currentGameLevel = currentGameLevel; }
}

SDVIG_EOF

echo "  ✦ $J/controller/GameApiController.java"
mkdir -p $(dirname "$J/controller/GameApiController.java")
cat > "$J/controller/GameApiController.java" << 'SDVIG_EOF'
package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.AiQuestService;
import com.example.sdvig.service.TelegramAuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;
import java.util.Random;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    private final TelegramAuthService    authService;
    private final PlayerProfileRepository profileRepo;
    private final AiQuestService         aiQuestService;
    private final Random                 random = new Random();

    public GameApiController(TelegramAuthService authService,
                             PlayerProfileRepository profileRepo,
                             AiQuestService aiQuestService) {
        this.authService    = authService;
        this.profileRepo    = profileRepo;
        this.aiQuestService = aiQuestService;
    }

    // ── Auth ──────────────────────────────────

    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody java.util.Map<String, Object> payload) {
        try {
            String initData = (String) payload.get("initData");
            if (!authService.validateWebAppInitData(initData)) {
                return ResponseEntity.status(401).body("Invalid WebApp signature.");
            }
            @SuppressWarnings("unchecked")
            Map<String, Object> initDataUnsafe = (Map<String, Object>) payload.get("initDataUnsafe");
            if (initDataUnsafe == null || !initDataUnsafe.containsKey("user")) {
                return ResponseEntity.status(400).body("User data missing");
            }
            @SuppressWarnings("unchecked")
            Map<String, Object> user = (Map<String, Object>) initDataUnsafe.get("user");
            return processUser(String.valueOf(user.get("id")),
                               (String) user.get("username"),
                               (String) user.get("first_name"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, String> payload) {
        try {
            if (!authService.validateWidgetAuth(payload)) {
                return ResponseEntity.status(401).body("Invalid widget signature");
            }
            return processUser(payload.get("id"), payload.get("username"), payload.get("first_name"));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    private ResponseEntity<?> processUser(String tgId, String username, String firstName) {
        String providerId = "tg:" + tgId;
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElseGet(() -> {
            PlayerProfile np = new PlayerProfile();
            np.setProviderId(providerId);
            return np;
        });
        if (username  != null) p.setUsername(username);
        if (firstName != null) p.setFirstName(firstName);
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Case ──────────────────────────────────

    @GetMapping("/case")
    public ResponseEntity<?> getCase(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        String json = aiQuestService.generateCaseJson(p.getArchetype(), p.getRank());
        return ResponseEntity.ok(json);
    }

    // ── Choice ────────────────────────────────

    @PostMapping("/choice")
    public ResponseEntity<?> makeChoice(@RequestParam String providerId,
                                        @RequestParam String direction) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        if (p.getEnergy() < 10) {
            return ResponseEntity.badRequest().body("Недостаточно энергии! Нужен кофе.");
        }

        int energyCost    = Math.max(3, 12 - p.getSkill2());
        int baseXp        = 15 + random.nextInt(10);
        int xpGained      = baseXp + (p.getSkill1() * 4);
        int creditsGained = 10 + random.nextInt(15);

        p.setEnergy(Math.max(0, p.getEnergy() - energyCost));
        p.setXp(p.getXp() + xpGained);
        p.setCredits(p.getCredits() + creditsGained);
        p.setTotalCases(p.getTotalCases() + 1);

        int xpRequired = p.getRank() * 150;
        if (p.getXp() >= xpRequired) {
            p.setXp(p.getXp() - xpRequired);
            p.setRank(p.getRank() + 1);
        }

        profileRepo.save(p);
        return ResponseEntity.ok(Map.of(
            "profile",        p,
            "xpGained",       xpGained,
            "creditsGained",  creditsGained,
            "energyLost",     energyCost
        ));
    }

    // ── Skill upgrade ─────────────────────────

    @PostMapping("/upgrade-skill")
    public ResponseEntity<?> upgradeSkill(@RequestParam String providerId,
                                          @RequestParam int skillNum) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        int curLevel = skillNum == 1 ? p.getSkill1() : p.getSkill2();
        int cost     = 50 * curLevel;
        if (p.getCredits() < cost) {
            return ResponseEntity.badRequest().body("Недостаточно кредитов.");
        }
        p.setCredits(p.getCredits() - cost);
        if (skillNum == 1) p.setSkill1(p.getSkill1() + 1);
        else               p.setSkill2(p.getSkill2() + 1);

        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Buy coffee ────────────────────────────

    @PostMapping("/buy-coffee")
    public ResponseEntity<?> buyCoffee(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        if (p.getCredits() < 40) return ResponseEntity.badRequest().body("Нужно 40 кредитов.");
        p.setCredits(p.getCredits() - 40);
        p.setEnergy(Math.min(100, p.getEnergy() + 35));
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Daily bonus ───────────────────────────

    @GetMapping("/daily-bonus")
    public ResponseEntity<?> checkDailyBonus(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        String today  = LocalDate.now().toString(); // "YYYY-MM-DD"
        String last   = p.getLastDailyBonus() == null ? "" : p.getLastDailyBonus();
        boolean avail = !today.equals(last);

        return ResponseEntity.ok(Map.of(
            "available", avail,
            "streak",    p.getStreak()
        ));
    }

    @PostMapping("/daily-bonus/claim")
    public ResponseEntity<?> claimDailyBonus(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        String today = LocalDate.now().toString();
        String last  = p.getLastDailyBonus() == null ? "" : p.getLastDailyBonus();

        if (today.equals(last)) {
            return ResponseEntity.badRequest().body("Бонус уже получен сегодня.");
        }

        // Check streak continuity (yesterday)
        String yesterday = LocalDate.now().minusDays(1).toString();
        int newStreak = yesterday.equals(last) ? p.getStreak() + 1 : 1;

        p.setCredits(p.getCredits() + 50);
        p.setEnergy(Math.min(100, p.getEnergy() + 30));
        p.setStreak(newStreak);
        p.setLastDailyBonus(today);

        profileRepo.save(p);
        return ResponseEntity.ok(Map.of("profile", p));
    }

    // ── Advance game level ────────────────────

    @PostMapping("/advance-level")
    public ResponseEntity<?> advanceLevel(@RequestParam String providerId,
                                          @RequestParam String gameType) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        switch (gameType) {
            case "detective" -> p.setDetectiveLvl(Math.min(100, p.getDetectiveLvl() + 1));
            case "doctor"    -> p.setDoctorLvl(Math.min(100, p.getDoctorLvl() + 1));
            case "universal" -> p.setUniversalLvl(Math.min(100, p.getUniversalLvl() + 1));
            default          -> { return ResponseEntity.badRequest().body("Unknown game type"); }
        }

        // Reward for completing a game level
        p.setXp(p.getXp() + 50);
        int xpRequired = p.getRank() * 150;
        if (p.getXp() >= xpRequired) {
            p.setXp(p.getXp() - xpRequired);
            p.setRank(p.getRank() + 1);
        }

        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }
}

SDVIG_EOF

echo "✅ Файлы обновлены!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Шаги для Railway:"
echo ""
echo "  git add -A"
echo "  git commit -m \"fix: widget auth + redesign v2\""
echo "  git push"
echo ""
echo "  ⚠️  Если виджет Telegram не работает в браузере:"
echo "  Откройте @BotFather → /mybots → Ваш бот → Bot Settings"
echo "  → Domain → добавьте домен Railway"
echo "  (например: your-app.railway.app)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
