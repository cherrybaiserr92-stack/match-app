#!/bin/bash
# ═══════════════════════════════════════════════
#  СДВИГ · deploy.sh — полное обновление проекта
#  Запускай из корня репозитория: bash deploy.sh
# ═══════════════════════════════════════════════
set -e
echo ""
echo "🚀 СДВИГ · Применяем обновление 2026..."
echo ""

STATIC="src/main/resources/static"
JAVA="src/main/java/com/example/sdvig"

echo "  ✦ $STATIC/index.html"
mkdir -p $(dirname "$STATIC/index.html")
cat > "$STATIC/index.html" << 'EOF_SDVIG'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="theme-color" content="#07070f">
    <title>СДВИГ</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
</head>
<body>

<!-- ══════════ SPLASH ══════════ -->
<div id="splash-screen" class="screen active">
    <div class="splash-particles" id="splash-particles"></div>
    <div class="splash-content">
        <div class="splash-logo-wrap">
            <div class="splash-glyph">⚡</div>
            <h1 class="splash-title">СДВИГ</h1>
            <p class="splash-sub">АГЕНТУРА БУДУЩЕГО</p>
        </div>
        <div class="splash-loader-wrap">
            <div class="splash-bar"><div class="splash-bar-fill" id="splash-bar-fill"></div></div>
            <p class="splash-status" id="splash-text">Инициализация системы…</p>
        </div>
    </div>
</div>

<!-- ══════════ LOGIN ══════════ -->
<div id="login-screen" class="screen">
    <div class="login-bg-grid"></div>
    <div class="login-wrap">
        <div class="login-logo">
            <span class="login-glyph">⚡</span>
            <h1>СДВИГ</h1>
            <p>АГЕНТУРА БУДУЩЕГО</p>
        </div>
        <div class="login-card">
            <div class="login-card-label">ДОСТУП К СИСТЕМЕ</div>
            <p class="login-desc">Авторизуйтесь для доступа к базе дел</p>
            <div class="tg-widget-wrap">
                <script async src="https://telegram.org/js/telegram-widget.js?22"
                        data-telegram-login="sdvig_game_bot"
                        data-size="large"
                        data-onauth="onTelegramAuth(user)"
                        data-request-access="write"></script>
            </div>
            <div class="login-divider"><span>СКОРО</span></div>
            <button class="btn btn-ghost" disabled>V&nbsp;&nbsp;ВКонтакте</button>
            <button class="btn btn-ghost" disabled>G&nbsp;&nbsp;Google</button>
        </div>
    </div>
</div>

<!-- ══════════ MAIN ══════════ -->
<div id="main-screen" class="screen">

    <!-- Top bar -->
    <header class="topbar">
        <div class="topbar-brand">⚡ <span>СДВИГ</span></div>
        <div class="topbar-chips">
            <div class="chip chip-energy">
                <span>⚡</span>
                <span id="hud-energy">100</span>
            </div>
            <div class="chip chip-credits">
                <span>💎</span>
                <span id="hud-credits">0</span>
            </div>
            <div class="chip chip-rank">
                <span>🏅</span>
                <span>R<span id="hud-rank">1</span></span>
            </div>
        </div>
    </header>

    <!-- XP track -->
    <div class="xp-track">
        <div class="xp-fill" id="xp-fill" style="width:0%"></div>
        <span class="xp-label">XP <span id="hud-xp">0</span>/<span id="hud-xp-max">150</span></span>
    </div>

    <!-- Tab content -->
    <div class="tab-content">

        <!-- ── ДЕЛА ── -->
        <div class="tab-panel active" id="tab-cases">
            <div class="swipe-zone">
                <div class="card-shadow-3"></div>
                <div class="card-shadow-2"></div>
                <div class="card-shadow-1"></div>

                <div id="main-card" class="case-card">
                    <div class="card-badge" id="card-badge">📁 ДЕЛО</div>
                    <div class="swipe-hint sh-left" id="sh-left">
                        <div class="sh-icon sh-icon-left">✕</div>
                        <div class="sh-text" id="sh-left-text">ОТКАЗАТЬ</div>
                    </div>
                    <div class="swipe-hint sh-right" id="sh-right">
                        <div class="sh-text" id="sh-right-text">ПРИНЯТЬ</div>
                        <div class="sh-icon sh-icon-right">✓</div>
                    </div>
                    <div class="card-body">
                        <div class="card-case-icon" id="card-icon">🔍</div>
                        <p class="card-text" id="case-description">ИИ сканирует архивы…</p>
                    </div>
                    <div class="card-actions">
                        <span class="ca-left" id="ca-left">◀ ОТКАЗАТЬ</span>
                        <span class="ca-right" id="ca-right">ПРИНЯТЬ ▶</span>
                    </div>
                </div>

                <!-- Result overlay -->
                <div id="result-overlay" class="result-overlay hidden">
                    <div class="result-badge" id="result-badge">РЕЗУЛЬТАТ</div>
                    <p class="result-text" id="result-text"></p>
                    <div class="reward-row">
                        <div class="reward-chip r-xp">⭐ +<span id="rew-xp">0</span> XP</div>
                        <div class="reward-chip r-credits">💎 +<span id="rew-credits">0</span></div>
                        <div class="reward-chip r-energy">⚡ -<span id="rew-energy">0</span></div>
                    </div>
                    <button class="btn btn-primary full-w" onclick="nextCase()">СЛЕДУЮЩЕЕ ДЕЛО →</button>
                </div>
            </div>
        </div>

        <!-- ── ИГРЫ ── -->
        <div class="tab-panel" id="tab-games">
            <div class="section-hd">
                <h2 class="section-title">АРСЕНАЛ АГЕНТА</h2>
                <p class="section-sub">Прокачивай навыки через испытания</p>
            </div>
            <div class="games-list">
                <div class="game-card" onclick="launchGame('detective')">
                    <div class="gc-glow gc-violet"></div>
                    <div class="gc-icon">💎</div>
                    <div class="gc-info">
                        <div class="gc-name">Самоцветы</div>
                        <div class="gc-desc">Match-3 · 100 уровней</div>
                        <div class="gc-progress">
                            <div class="gc-progress-bar">
                                <div class="gc-progress-fill" id="det-progress" style="width:1%"></div>
                            </div>
                            <span class="gc-lvl">Ур.<span id="det-lvl">1</span></span>
                        </div>
                    </div>
                    <div class="gc-arrow">▶</div>
                </div>
                <div class="game-card" onclick="launchGame('doctor')">
                    <div class="gc-glow gc-cyan"></div>
                    <div class="gc-icon">💓</div>
                    <div class="gc-info">
                        <div class="gc-name">Кардиограмма</div>
                        <div class="gc-desc">Прецизия · 100 уровней</div>
                        <div class="gc-progress">
                            <div class="gc-progress-bar">
                                <div class="gc-progress-fill" id="doc-progress" style="width:1%"></div>
                            </div>
                            <span class="gc-lvl">Ур.<span id="doc-lvl">1</span></span>
                        </div>
                    </div>
                    <div class="gc-arrow">▶</div>
                </div>
                <div class="game-card" onclick="launchGame('universal')">
                    <div class="gc-glow gc-gold"></div>
                    <div class="gc-icon">🧮</div>
                    <div class="gc-info">
                        <div class="gc-name">Экспертиза Шифра</div>
                        <div class="gc-desc">Математика · 100 уровней</div>
                        <div class="gc-progress">
                            <div class="gc-progress-bar">
                                <div class="gc-progress-fill" id="uni-progress" style="width:1%"></div>
                            </div>
                            <span class="gc-lvl">Ур.<span id="uni-lvl">1</span></span>
                        </div>
                    </div>
                    <div class="gc-arrow">▶</div>
                </div>
            </div>

            <!-- Game viewport (full panel) -->
            <div id="game-vp-wrap" class="game-vp-wrap hidden">
                <div class="game-vp-header">
                    <button class="back-btn" onclick="closeGame()">← ВЫХОД</button>
                    <span class="game-vp-title" id="game-vp-title">ИГРА</span>
                    <div class="win-badge hidden" id="win-badge">WIN ✓</div>
                </div>
                <div id="game-viewport" class="game-viewport"></div>
            </div>
        </div>

        <!-- ── АГЕНТ ── -->
        <div class="tab-panel" id="tab-profile">
            <div class="profile-hero">
                <div class="profile-avatar" id="profile-avatar">?</div>
                <div class="profile-meta">
                    <div class="profile-name" id="profile-name">Агент</div>
                    <div class="profile-archetype" id="profile-archetype">🔍 Детектив</div>
                    <div class="profile-id" id="profile-id">ID: —</div>
                </div>
            </div>
            <div class="stats-row">
                <div class="stat-box">
                    <div class="stat-num" id="pstat-rank">1</div>
                    <div class="stat-lbl">РАНГ</div>
                </div>
                <div class="stat-box">
                    <div class="stat-num" id="pstat-credits">0</div>
                    <div class="stat-lbl">КРЕДИТЫ</div>
                </div>
                <div class="stat-box">
                    <div class="stat-num" id="pstat-cases">0</div>
                    <div class="stat-lbl">ДЕЛ</div>
                </div>
                <div class="stat-box">
                    <div class="stat-num" id="pstat-streak">0</div>
                    <div class="stat-lbl">СЕРИЯ 🔥</div>
                </div>
            </div>
            <div class="section-hd" style="margin-top:20px">
                <h2 class="section-title">НАВЫКИ</h2>
            </div>
            <div class="skill-list">
                <div class="skill-item">
                    <div class="skill-icon-wrap">🧠</div>
                    <div class="skill-body">
                        <div class="skill-name">Проницательность</div>
                        <div class="skill-desc">+XP за каждое дело</div>
                        <div class="skill-bar"><div class="skill-bar-fill" id="sk1-bar"></div></div>
                    </div>
                    <div class="skill-side">
                        <div class="skill-lvl" id="sk1-lvl">Lv.1</div>
                        <button class="upgrade-btn" id="sk1-btn" onclick="upgradeSkill(1)">
                            <span id="sk1-cost">50💎</span>
                        </button>
                    </div>
                </div>
                <div class="skill-item">
                    <div class="skill-icon-wrap">⚙️</div>
                    <div class="skill-body">
                        <div class="skill-name">Технологии</div>
                        <div class="skill-desc">−Энергия за дело</div>
                        <div class="skill-bar"><div class="skill-bar-fill" id="sk2-bar"></div></div>
                    </div>
                    <div class="skill-side">
                        <div class="skill-lvl" id="sk2-lvl">Lv.1</div>
                        <button class="upgrade-btn" id="sk2-btn" onclick="upgradeSkill(2)">
                            <span id="sk2-cost">50💎</span>
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── МАГАЗИН ── -->
        <div class="tab-panel" id="tab-shop">
            <div class="section-hd">
                <h2 class="section-title">СНАРЯЖЕНИЕ АГЕНТА</h2>
                <p class="section-sub">Ресурсы для выживания в поле</p>
            </div>
            <div class="shop-grid">
                <div class="shop-item" onclick="buyCoffee()">
                    <div class="shop-item-icon">☕</div>
                    <div class="shop-item-name">Синт. Кофе</div>
                    <div class="shop-item-desc">+35 ⚡ энергии</div>
                    <div class="shop-item-price">40 💎</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="shop-item-icon">🔮</div>
                    <div class="shop-item-name">Нейроусилитель</div>
                    <div class="shop-item-desc">×2 XP на 5 дел</div>
                    <div class="shop-item-price shop-soon">СКОРО</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="shop-item-icon">🛡️</div>
                    <div class="shop-item-name">Броня данных</div>
                    <div class="shop-item-desc">−50% энергии за дело</div>
                    <div class="shop-item-price shop-soon">СКОРО</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="shop-item-icon">⚡</div>
                    <div class="shop-item-name">Реактор</div>
                    <div class="shop-item-desc">+100 макс. энергии</div>
                    <div class="shop-item-price shop-soon">СКОРО</div>
                </div>
            </div>
        </div>

    </div><!-- /tab-content -->

    <!-- Bottom nav -->
    <nav class="bottom-nav">
        <button class="nav-btn active" data-tab="cases" onclick="switchTab('cases')">
            <span class="nav-icon">📂</span>
            <span class="nav-lbl">ДЕЛА</span>
            <div class="nav-dot"></div>
        </button>
        <button class="nav-btn" data-tab="games" onclick="switchTab('games')">
            <span class="nav-icon">🎮</span>
            <span class="nav-lbl">ИГРЫ</span>
            <div class="nav-dot"></div>
        </button>
        <button class="nav-btn" data-tab="profile" onclick="switchTab('profile')">
            <span class="nav-icon">👤</span>
            <span class="nav-lbl">АГЕНТ</span>
            <div class="nav-dot"></div>
        </button>
        <button class="nav-btn" data-tab="shop" onclick="switchTab('shop')">
            <span class="nav-icon">🛒</span>
            <span class="nav-lbl">МАГАЗИН</span>
            <div class="nav-dot"></div>
        </button>
    </nav>
</div><!-- /main-screen -->

<!-- ══════════ ACHIEVEMENT TOAST ══════════ -->
<div id="toast" class="toast hidden">
    <span class="toast-icon" id="toast-icon">🏆</span>
    <div class="toast-body">
        <div class="toast-title" id="toast-title">ДОСТИЖЕНИЕ</div>
        <div class="toast-desc" id="toast-desc"></div>
    </div>
</div>

<!-- ══════════ DAILY MODAL ══════════ -->
<div id="daily-modal" class="modal-overlay hidden">
    <div class="daily-card">
        <div class="daily-icon">🎁</div>
        <h2 class="daily-title">ЕЖЕДНЕВНЫЙ БОНУС</h2>
        <p class="daily-streak">Серия: <span id="daily-streak">1</span> д. 🔥</p>
        <div class="daily-rewards">
            <div class="daily-rchip">+50 💎</div>
            <div class="daily-rchip">+30 ⚡</div>
        </div>
        <button class="btn btn-primary full-w" onclick="claimDaily()">ЗАБРАТЬ БОНУС</button>
    </div>
</div>

<!-- ══════════ ERROR SCREEN ══════════ -->
<div id="error-screen" class="screen">
    <div class="error-content">
        <div class="error-icon">⚠️</div>
        <h2 class="error-title">СИСТЕМНАЯ ОШИБКА</h2>
        <p class="error-msg" id="error-msg">Что-то пошло не так</p>
        <button class="btn btn-primary" onclick="location.reload()">ПЕРЕЗАГРУЗИТЬ</button>
    </div>
</div>

<script type="module" src="app.js"></script>
</body>
</html>

EOF_SDVIG

echo "  ✦ $STATIC/style.css"
mkdir -p $(dirname "$STATIC/style.css")
cat > "$STATIC/style.css" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · Design System 2026
   Cyberpunk Noir · Space Grotesk
═══════════════════════════════════════════════ */

@import url('https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700;800&display=swap');

:root {
    --bg:         #07070f;
    --surface:    #0d0d1e;
    --surface-2:  #141428;
    --surface-3:  #1a1a33;
    --border:     rgba(148, 163, 184, 0.10);
    --border-hi:  rgba(139, 92, 246, 0.35);

    --primary:    #8b5cf6;
    --primary-dim:#6d28d9;
    --primary-glow: rgba(139, 92, 246, 0.30);

    --cyan:       #22d3ee;
    --cyan-glow:  rgba(34, 211, 238, 0.25);

    --gold:       #f59e0b;
    --gold-glow:  rgba(245, 158, 11, 0.25);

    --red:        #f87171;
    --red-glow:   rgba(248, 113, 113, 0.25);
    --red-dim:    rgba(248, 113, 113, 0.15);

    --green:      #34d399;
    --green-glow: rgba(52, 211, 153, 0.25);
    --green-dim:  rgba(52, 211, 153, 0.15);

    --text:       #f1f5f9;
    --text-2:     #94a3b8;
    --text-3:     #475569;

    --radius-sm:  8px;
    --radius:     16px;
    --radius-lg:  24px;
    --radius-xl:  32px;

    --nav-h:      68px;
    --top-h:      52px;
    --xp-h:       6px;

    --safe-b:     env(safe-area-inset-bottom, 0px);
    --safe-t:     env(safe-area-inset-top, 0px);
}

/* ─── Reset ─────────────────────────────────── */
*, *::before, *::after {
    box-sizing: border-box;
    margin: 0; padding: 0;
    -webkit-tap-highlight-color: transparent;
}

html, body {
    height: 100%;
    overflow: hidden;
    overscroll-behavior: none;
}

body {
    font-family: 'Space Grotesk', -apple-system, BlinkMacSystemFont, sans-serif;
    background: var(--bg);
    color: var(--text);
    font-size: 14px;
    line-height: 1.5;
    user-select: none;
    -webkit-user-select: none;
}

/* ─── Screen system ──────────────────────────── */
.screen {
    position: fixed;
    inset: 0;
    display: flex;
    flex-direction: column;
    opacity: 0;
    pointer-events: none;
    transition: opacity 0.4s ease;
    padding-top: var(--safe-t);
}

.screen.active {
    opacity: 1;
    pointer-events: all;
}

.hidden { display: none !important; }

/* ─── SPLASH ─────────────────────────────────── */
#splash-screen {
    background: var(--bg);
    justify-content: center;
    align-items: center;
    z-index: 9999;
}

.splash-particles {
    position: absolute;
    inset: 0;
    overflow: hidden;
}

.splash-particle {
    position: absolute;
    width: 2px;
    height: 2px;
    background: var(--primary);
    border-radius: 50%;
    animation: particleFloat linear infinite;
    opacity: 0;
}

@keyframes particleFloat {
    0%   { transform: translateY(100vh) scale(0); opacity: 0; }
    10%  { opacity: 1; }
    90%  { opacity: 1; }
    100% { transform: translateY(-20vh) scale(1); opacity: 0; }
}

.splash-content {
    position: relative;
    z-index: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 48px;
    padding: 32px;
    text-align: center;
}

.splash-logo-wrap {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
}

.splash-glyph {
    font-size: 64px;
    animation: glyphPulse 2s ease-in-out infinite;
    filter: drop-shadow(0 0 20px var(--primary));
}

@keyframes glyphPulse {
    0%, 100% { transform: scale(1); filter: drop-shadow(0 0 20px var(--primary)); }
    50%       { transform: scale(1.08); filter: drop-shadow(0 0 40px var(--primary)) drop-shadow(0 0 60px var(--primary-glow)); }
}

.splash-title {
    font-size: 48px;
    font-weight: 800;
    letter-spacing: 12px;
    color: var(--text);
    background: linear-gradient(135deg, #fff 0%, var(--primary) 50%, var(--cyan) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: fadeSlideUp 0.8s ease 0.2s both;
}

@keyframes fadeSlideUp {
    from { opacity: 0; transform: translateY(20px); }
    to   { opacity: 1; transform: none; }
}

.splash-sub {
    font-size: 11px;
    letter-spacing: 4px;
    color: var(--text-3);
    text-transform: uppercase;
    animation: fadeSlideUp 0.8s ease 0.4s both;
}

.splash-loader-wrap {
    width: 240px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 12px;
    animation: fadeSlideUp 0.8s ease 0.6s both;
}

.splash-bar {
    width: 100%;
    height: 3px;
    background: var(--surface-3);
    border-radius: 99px;
    overflow: hidden;
}

.splash-bar-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--primary), var(--cyan));
    border-radius: 99px;
    width: 0%;
    transition: width 0.5s ease;
    box-shadow: 0 0 8px var(--primary-glow);
}

.splash-status {
    font-size: 12px;
    color: var(--text-3);
    letter-spacing: 1px;
    text-transform: uppercase;
}

/* ─── LOGIN ──────────────────────────────────── */
#login-screen {
    background: var(--bg);
    justify-content: center;
    align-items: center;
}

.login-bg-grid {
    position: absolute;
    inset: 0;
    background-image:
        linear-gradient(rgba(139,92,246,0.05) 1px, transparent 1px),
        linear-gradient(90deg, rgba(139,92,246,0.05) 1px, transparent 1px);
    background-size: 40px 40px;
    pointer-events: none;
}

.login-wrap {
    position: relative;
    z-index: 1;
    width: 100%;
    max-width: 360px;
    padding: 24px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 32px;
}

.login-logo {
    text-align: center;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
}

.login-glyph {
    font-size: 40px;
    filter: drop-shadow(0 0 16px var(--primary));
}

.login-logo h1 {
    font-size: 32px;
    font-weight: 800;
    letter-spacing: 8px;
    background: linear-gradient(135deg, #fff, var(--primary));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.login-logo p {
    font-size: 10px;
    letter-spacing: 3px;
    color: var(--text-3);
    text-transform: uppercase;
}

.login-card {
    width: 100%;
    background: var(--surface);
    border: 1px solid var(--border-hi);
    border-radius: var(--radius-lg);
    padding: 24px;
    display: flex;
    flex-direction: column;
    gap: 14px;
    box-shadow: 0 0 40px rgba(139,92,246,0.1), 0 16px 48px rgba(0,0,0,0.5);
}

.login-card-label {
    font-size: 11px;
    letter-spacing: 3px;
    color: var(--primary);
    font-weight: 700;
    text-transform: uppercase;
    text-align: center;
}

.login-desc {
    font-size: 13px;
    color: var(--text-2);
    text-align: center;
}

.tg-widget-wrap {
    display: flex;
    justify-content: center;
    min-height: 48px;
}

.login-divider {
    display: flex;
    align-items: center;
    gap: 12px;
    color: var(--text-3);
    font-size: 11px;
    letter-spacing: 2px;
}

.login-divider::before,
.login-divider::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--border);
}

/* ─── BUTTONS ────────────────────────────────── */
.btn {
    width: 100%;
    padding: 14px;
    border: none;
    border-radius: var(--radius);
    font-family: inherit;
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 1.5px;
    text-transform: uppercase;
    cursor: pointer;
    transition: transform 0.1s, opacity 0.2s, box-shadow 0.2s;
    position: relative;
    overflow: hidden;
}

.btn::after {
    content: '';
    position: absolute;
    inset: 0;
    background: radial-gradient(circle, rgba(255,255,255,0.2) 0%, transparent 70%);
    opacity: 0;
    transition: opacity 0.2s;
}

.btn:active { transform: scale(0.97); }
.btn:active::after { opacity: 1; }

.btn-primary {
    background: linear-gradient(135deg, var(--primary), var(--primary-dim));
    color: #fff;
    box-shadow: 0 4px 20px var(--primary-glow);
}

.btn-primary:hover {
    box-shadow: 0 4px 30px var(--primary-glow);
}

.btn-ghost {
    background: transparent;
    border: 1px solid var(--border);
    color: var(--text-3);
    cursor: not-allowed;
}

.full-w { width: 100%; }

/* ─── TOPBAR ─────────────────────────────────── */
.topbar {
    height: var(--top-h);
    min-height: var(--top-h);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    flex-shrink: 0;
}

.topbar-brand {
    font-size: 16px;
    font-weight: 800;
    letter-spacing: 3px;
    color: var(--text);
}

.topbar-brand span {
    background: linear-gradient(90deg, var(--primary), var(--cyan));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
}

.topbar-chips {
    display: flex;
    gap: 8px;
    align-items: center;
}

.chip {
    display: flex;
    align-items: center;
    gap: 4px;
    padding: 4px 10px;
    border-radius: 99px;
    font-size: 12px;
    font-weight: 700;
    border: 1px solid var(--border);
    background: var(--surface-2);
}

.chip-energy { color: var(--cyan); border-color: var(--cyan-glow); }
.chip-credits { color: var(--primary); border-color: var(--primary-glow); }
.chip-rank    { color: var(--gold);   border-color: var(--gold-glow); }

/* ─── XP TRACK ───────────────────────────────── */
.xp-track {
    height: var(--xp-h);
    background: var(--surface-2);
    position: relative;
    flex-shrink: 0;
    overflow: hidden;
}

.xp-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--primary), var(--cyan));
    transition: width 0.6s cubic-bezier(0.34, 1.56, 0.64, 1);
    box-shadow: 0 0 10px var(--primary-glow);
    position: relative;
}

.xp-fill::after {
    content: '';
    position: absolute;
    right: 0; top: 0; bottom: 0;
    width: 20px;
    background: linear-gradient(90deg, transparent, rgba(255,255,255,0.4));
    animation: shimmer 1.5s ease-in-out infinite;
}

@keyframes shimmer {
    0%,100% { opacity: 0; }
    50%      { opacity: 1; }
}

.xp-label {
    position: absolute;
    right: 8px;
    top: 50%;
    transform: translateY(-50%);
    font-size: 9px;
    letter-spacing: 1px;
    color: var(--text-3);
    line-height: 1;
    pointer-events: none;
}

/* ─── TAB CONTENT ────────────────────────────── */
.tab-content {
    flex: 1;
    position: relative;
    overflow: hidden;
}

.tab-panel {
    position: absolute;
    inset: 0;
    overflow-y: auto;
    overflow-x: hidden;
    opacity: 0;
    pointer-events: none;
    transform: translateY(8px);
    transition: opacity 0.3s ease, transform 0.3s ease;
    -webkit-overflow-scrolling: touch;
    overscroll-behavior: contain;
    padding-bottom: calc(var(--nav-h) + 8px);
}

.tab-panel.active {
    opacity: 1;
    pointer-events: all;
    transform: none;
}

/* ─── CASES TAB ──────────────────────────────── */
.swipe-zone {
    position: absolute;
    inset: 0;
    display: flex;
    justify-content: center;
    align-items: center;
    overflow: hidden;
}

/* Card stack shadows */
.card-shadow-3, .card-shadow-2, .card-shadow-1 {
    position: absolute;
    width: calc(100% - 48px);
    max-width: 320px;
    background: var(--surface-2);
    border: 1px solid var(--border);
    border-radius: var(--radius-lg);
    pointer-events: none;
}

.card-shadow-3 {
    height: 200px;
    bottom: calc(50% - 120px);
    transform: translateY(16px) scale(0.86);
    opacity: 0.3;
}

.card-shadow-2 {
    height: 220px;
    bottom: calc(50% - 130px);
    transform: translateY(8px) scale(0.93);
    opacity: 0.5;
}

.card-shadow-1 {
    height: 240px;
    bottom: calc(50% - 140px);
    transform: translateY(4px) scale(0.97);
    opacity: 0.7;
}

/* Main case card */
.case-card {
    position: absolute;
    width: calc(100% - 32px);
    max-width: 340px;
    min-height: 380px;
    background: var(--surface);
    border: 1px solid var(--border-hi);
    border-radius: var(--radius-lg);
    box-shadow:
        0 0 0 0 transparent,
        0 20px 60px rgba(0,0,0,0.5),
        inset 0 1px 0 rgba(255,255,255,0.06);
    display: flex;
    flex-direction: column;
    padding: 20px;
    cursor: grab;
    touch-action: none;
    transform-origin: 50% 100%;
    transition: box-shadow 0.2s ease;
    will-change: transform;
    z-index: 10;
}

.case-card:active { cursor: grabbing; }

.case-card.drag-left {
    border-color: rgba(248, 113, 113, 0.5);
    box-shadow: 0 0 30px var(--red-glow), 0 20px 60px rgba(0,0,0,0.5);
}

.case-card.drag-right {
    border-color: rgba(52, 211, 153, 0.5);
    box-shadow: 0 0 30px var(--green-glow), 0 20px 60px rgba(0,0,0,0.5);
}

.card-badge {
    font-size: 10px;
    letter-spacing: 2px;
    color: var(--primary);
    font-weight: 700;
    text-transform: uppercase;
    text-align: center;
    margin-bottom: 8px;
}

/* Swipe hints */
.swipe-hint {
    position: absolute;
    top: 50%;
    transform: translateY(-50%);
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    opacity: 0;
    transition: opacity 0.15s ease;
    pointer-events: none;
    z-index: 20;
}

.sh-left  { left: 16px; }
.sh-right { right: 16px; }

.sh-icon {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    font-weight: 800;
}

.sh-icon-left  { background: var(--red-dim);   color: var(--red);   border: 1.5px solid var(--red); }
.sh-icon-right { background: var(--green-dim);  color: var(--green); border: 1.5px solid var(--green); }

.sh-text {
    font-size: 9px;
    letter-spacing: 1.5px;
    font-weight: 700;
    text-transform: uppercase;
}

.sh-left .sh-text  { color: var(--red); }
.sh-right .sh-text { color: var(--green); }

.card-body {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 16px;
    padding: 12px 0;
}

.card-case-icon {
    font-size: 48px;
    filter: drop-shadow(0 0 12px rgba(139,92,246,0.3));
    animation: iconFloat 3s ease-in-out infinite;
}

@keyframes iconFloat {
    0%, 100% { transform: translateY(0); }
    50%       { transform: translateY(-4px); }
}

.card-text {
    font-size: 15px;
    line-height: 1.65;
    text-align: center;
    color: var(--text);
    font-weight: 500;
}

.card-actions {
    display: flex;
    justify-content: space-between;
    padding-top: 12px;
    border-top: 1px solid var(--border);
}

.ca-left, .ca-right {
    font-size: 10px;
    letter-spacing: 1.5px;
    font-weight: 700;
    text-transform: uppercase;
    color: var(--text-3);
}

/* ─── RESULT OVERLAY ─────────────────────────── */
.result-overlay {
    position: absolute;
    inset: 16px;
    border-radius: var(--radius-lg);
    background: var(--surface);
    border: 1px solid var(--border-hi);
    box-shadow: 0 0 40px var(--primary-glow), 0 20px 60px rgba(0,0,0,0.6);
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 20px;
    padding: 28px;
    text-align: center;
    z-index: 50;
    animation: resultAppear 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
}

@keyframes resultAppear {
    from { opacity: 0; transform: scale(0.85); }
    to   { opacity: 1; transform: none; }
}

.result-badge {
    font-size: 11px;
    letter-spacing: 3px;
    font-weight: 700;
    color: var(--primary);
    text-transform: uppercase;
}

.result-text {
    font-size: 15px;
    line-height: 1.65;
    color: var(--text);
    font-weight: 500;
}

.reward-row {
    display: flex;
    gap: 10px;
    justify-content: center;
}

.reward-chip {
    padding: 6px 14px;
    border-radius: 99px;
    font-size: 13px;
    font-weight: 700;
}

.r-xp      { background: rgba(139,92,246,0.15); border: 1px solid var(--primary-glow); color: var(--primary); }
.r-credits { background: rgba(245,158,11,0.12); border: 1px solid var(--gold-glow);    color: var(--gold); }
.r-energy  { background: rgba(248,113,113,0.12); border: 1px solid var(--red-glow);    color: var(--red); }

/* ─── GAMES TAB ──────────────────────────────── */
.section-hd {
    padding: 16px 16px 8px;
}

.section-title {
    font-size: 13px;
    font-weight: 800;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: var(--text);
}

.section-sub {
    font-size: 12px;
    color: var(--text-3);
    margin-top: 4px;
}

.games-list {
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 8px 16px 16px;
}

.game-card {
    position: relative;
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 16px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    cursor: pointer;
    transition: transform 0.15s, border-color 0.2s, box-shadow 0.2s;
    overflow: hidden;
}

.game-card:active {
    transform: scale(0.97);
}

.gc-glow {
    position: absolute;
    inset: 0;
    opacity: 0;
    transition: opacity 0.2s;
    pointer-events: none;
}

.gc-violet { background: radial-gradient(circle at 20% 50%, rgba(139,92,246,0.15) 0%, transparent 60%); }
.gc-cyan   { background: radial-gradient(circle at 20% 50%, rgba(34,211,238,0.12) 0%, transparent 60%); }
.gc-gold   { background: radial-gradient(circle at 20% 50%, rgba(245,158,11,0.12) 0%, transparent 60%); }

.game-card:active .gc-glow { opacity: 1; }

.gc-icon {
    font-size: 36px;
    flex-shrink: 0;
    filter: drop-shadow(0 0 8px rgba(139,92,246,0.3));
}

.gc-info { flex: 1; min-width: 0; }

.gc-name {
    font-size: 15px;
    font-weight: 700;
    color: var(--text);
}

.gc-desc {
    font-size: 11px;
    color: var(--text-3);
    margin-top: 2px;
    letter-spacing: 0.5px;
}

.gc-progress {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 8px;
}

.gc-progress-bar {
    flex: 1;
    height: 3px;
    background: var(--surface-3);
    border-radius: 99px;
    overflow: hidden;
}

.gc-progress-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--primary), var(--cyan));
    border-radius: 99px;
    transition: width 0.6s ease;
}

.gc-lvl {
    font-size: 10px;
    color: var(--text-3);
    font-weight: 600;
    white-space: nowrap;
    letter-spacing: 0.5px;
}

.gc-arrow {
    font-size: 12px;
    color: var(--text-3);
    flex-shrink: 0;
}

/* ─── GAME VIEWPORT ──────────────────────────── */
.game-vp-wrap {
    position: absolute;
    inset: 0;
    background: var(--bg);
    z-index: 100;
    display: flex;
    flex-direction: column;
    animation: fadeSlideUp 0.25s ease;
}

.game-vp-header {
    height: var(--top-h);
    display: flex;
    align-items: center;
    padding: 0 16px;
    gap: 12px;
    background: var(--surface);
    border-bottom: 1px solid var(--border);
    flex-shrink: 0;
}

.back-btn {
    background: transparent;
    border: 1px solid var(--border);
    color: var(--text-2);
    padding: 6px 14px;
    border-radius: var(--radius-sm);
    font-family: inherit;
    font-size: 12px;
    font-weight: 600;
    cursor: pointer;
    letter-spacing: 1px;
    transition: all 0.2s;
}

.back-btn:active {
    background: var(--surface-2);
    transform: scale(0.96);
}

.game-vp-title {
    font-size: 13px;
    font-weight: 700;
    letter-spacing: 2px;
    color: var(--text);
    flex: 1;
    text-align: center;
    text-transform: uppercase;
}

.win-badge {
    padding: 4px 12px;
    background: rgba(52,211,153,0.15);
    border: 1px solid var(--green);
    border-radius: 99px;
    font-size: 11px;
    font-weight: 700;
    color: var(--green);
    letter-spacing: 1px;
    animation: rewardPop 0.4s cubic-bezier(0.34,1.56,0.64,1);
}

@keyframes rewardPop {
    from { transform: scale(0.3); opacity: 0; }
    to   { transform: none; opacity: 1; }
}

.game-viewport {
    flex: 1;
    overflow-y: auto;
    overflow-x: hidden;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: flex-start;
    padding: 16px;
    -webkit-overflow-scrolling: touch;
    overscroll-behavior: contain;
}

/* ─── PROFILE TAB ────────────────────────────── */
.profile-hero {
    display: flex;
    align-items: center;
    gap: 16px;
    padding: 20px 16px;
    background: linear-gradient(135deg, var(--surface), var(--surface-2));
    border-bottom: 1px solid var(--border);
}

.profile-avatar {
    width: 64px;
    height: 64px;
    background: linear-gradient(135deg, var(--primary-dim), var(--primary));
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    font-weight: 800;
    color: #fff;
    box-shadow: 0 0 20px var(--primary-glow);
    flex-shrink: 0;
    border: 2px solid rgba(139,92,246,0.4);
}

.profile-meta { flex: 1; min-width: 0; }

.profile-name {
    font-size: 20px;
    font-weight: 800;
    color: var(--text);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}

.profile-archetype {
    font-size: 13px;
    color: var(--primary);
    font-weight: 600;
    margin-top: 2px;
}

.profile-id {
    font-size: 11px;
    color: var(--text-3);
    margin-top: 2px;
    letter-spacing: 0.5px;
}

.stats-row {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 1px;
    background: var(--border);
    margin: 16px;
    border-radius: var(--radius);
    overflow: hidden;
}

.stat-box {
    background: var(--surface);
    padding: 14px 8px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 4px;
}

.stat-num {
    font-size: 22px;
    font-weight: 800;
    color: var(--text);
    line-height: 1;
}

.stat-lbl {
    font-size: 9px;
    letter-spacing: 1.5px;
    color: var(--text-3);
    text-transform: uppercase;
    font-weight: 600;
}

/* ─── SKILLS ─────────────────────────────────── */
.skill-list {
    display: flex;
    flex-direction: column;
    gap: 10px;
    padding: 0 16px 16px;
}

.skill-item {
    display: flex;
    align-items: center;
    gap: 14px;
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 14px;
}

.skill-icon-wrap {
    font-size: 28px;
    flex-shrink: 0;
    filter: drop-shadow(0 0 6px rgba(139,92,246,0.25));
}

.skill-body { flex: 1; min-width: 0; }

.skill-name {
    font-size: 14px;
    font-weight: 700;
    color: var(--text);
}

.skill-desc {
    font-size: 11px;
    color: var(--text-3);
    margin-top: 2px;
}

.skill-bar {
    height: 3px;
    background: var(--surface-3);
    border-radius: 99px;
    overflow: hidden;
    margin-top: 8px;
}

.skill-bar-fill {
    height: 100%;
    background: linear-gradient(90deg, var(--primary), var(--cyan));
    border-radius: 99px;
    transition: width 0.6s ease;
}

.skill-side {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 6px;
    flex-shrink: 0;
}

.skill-lvl {
    font-size: 12px;
    font-weight: 700;
    color: var(--primary);
    letter-spacing: 0.5px;
}

.upgrade-btn {
    background: linear-gradient(135deg, var(--primary), var(--primary-dim));
    border: none;
    border-radius: var(--radius-sm);
    padding: 7px 12px;
    font-family: inherit;
    font-size: 12px;
    font-weight: 700;
    color: #fff;
    cursor: pointer;
    transition: transform 0.1s, box-shadow 0.2s;
    box-shadow: 0 2px 10px var(--primary-glow);
    white-space: nowrap;
    letter-spacing: 0.5px;
}

.upgrade-btn:active {
    transform: scale(0.94);
}

/* ─── SHOP TAB ───────────────────────────────── */
.shop-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
    padding: 0 16px 16px;
}

.shop-item {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: var(--radius);
    padding: 18px 14px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    cursor: pointer;
    transition: transform 0.15s, border-color 0.2s, box-shadow 0.2s;
    text-align: center;
    position: relative;
    overflow: hidden;
}

.shop-item:not(.shop-locked):active {
    transform: scale(0.95);
    border-color: var(--primary);
    box-shadow: 0 0 20px var(--primary-glow);
}

.shop-locked {
    opacity: 0.45;
    cursor: not-allowed;
}

.shop-item-icon { font-size: 36px; }

.shop-item-name {
    font-size: 13px;
    font-weight: 700;
    color: var(--text);
}

.shop-item-desc {
    font-size: 11px;
    color: var(--text-3);
    line-height: 1.4;
}

.shop-item-price {
    padding: 5px 12px;
    background: rgba(245,158,11,0.12);
    border: 1px solid var(--gold-glow);
    border-radius: 99px;
    font-size: 12px;
    font-weight: 700;
    color: var(--gold);
    margin-top: 2px;
}

.shop-soon {
    background: var(--surface-3);
    border-color: var(--border);
    color: var(--text-3);
    letter-spacing: 1.5px;
    font-size: 10px;
}

/* ─── BOTTOM NAV ─────────────────────────────── */
.bottom-nav {
    height: calc(var(--nav-h) + var(--safe-b));
    padding-bottom: var(--safe-b);
    display: flex;
    background: rgba(7, 7, 15, 0.92);
    border-top: 1px solid var(--border);
    backdrop-filter: blur(20px);
    -webkit-backdrop-filter: blur(20px);
    flex-shrink: 0;
    position: relative;
    z-index: 10;
}

.nav-btn {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: 4px;
    background: transparent;
    border: none;
    cursor: pointer;
    padding: 8px 4px;
    position: relative;
    transition: transform 0.1s;
}

.nav-btn:active { transform: scale(0.9); }

.nav-icon {
    font-size: 22px;
    transition: filter 0.2s, transform 0.2s;
    line-height: 1;
}

.nav-lbl {
    font-size: 9px;
    letter-spacing: 1.5px;
    color: var(--text-3);
    font-weight: 700;
    transition: color 0.2s;
}

.nav-dot {
    position: absolute;
    bottom: 6px;
    width: 4px;
    height: 4px;
    border-radius: 50%;
    background: var(--primary);
    opacity: 0;
    transition: opacity 0.2s;
    box-shadow: 0 0 6px var(--primary);
}

.nav-btn.active .nav-icon {
    filter: drop-shadow(0 0 8px var(--primary));
    transform: translateY(-2px);
}

.nav-btn.active .nav-lbl { color: var(--primary); }
.nav-btn.active .nav-dot { opacity: 1; }

/* ─── TOAST ──────────────────────────────────── */
.toast {
    position: fixed;
    bottom: calc(var(--nav-h) + var(--safe-b) + 16px);
    left: 16px;
    right: 16px;
    background: var(--surface);
    border: 1px solid var(--border-hi);
    border-radius: var(--radius);
    padding: 14px 16px;
    display: flex;
    align-items: center;
    gap: 14px;
    z-index: 1000;
    box-shadow: 0 8px 30px rgba(0,0,0,0.5), 0 0 30px var(--primary-glow);
    animation: toastIn 0.3s cubic-bezier(0.34,1.56,0.64,1);
}

@keyframes toastIn {
    from { transform: translateY(20px); opacity: 0; }
    to   { transform: none; opacity: 1; }
}

.toast.hide-out {
    animation: toastOut 0.3s ease forwards;
}

@keyframes toastOut {
    from { transform: none; opacity: 1; }
    to   { transform: translateY(20px); opacity: 0; }
}

.toast-icon { font-size: 28px; flex-shrink: 0; }

.toast-title {
    font-size: 11px;
    letter-spacing: 2px;
    font-weight: 800;
    color: var(--primary);
    text-transform: uppercase;
}

.toast-desc {
    font-size: 13px;
    color: var(--text);
    margin-top: 2px;
    font-weight: 500;
}

/* ─── DAILY MODAL ────────────────────────────── */
.modal-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.75);
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    display: flex;
    align-items: center;
    justify-content: center;
    z-index: 900;
    padding: 24px;
    animation: fadeIn 0.2s ease;
}

@keyframes fadeIn {
    from { opacity: 0; }
    to   { opacity: 1; }
}

.daily-card {
    background: var(--surface);
    border: 1px solid var(--border-hi);
    border-radius: var(--radius-xl);
    padding: 32px 24px;
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
    text-align: center;
    width: 100%;
    max-width: 320px;
    box-shadow: 0 0 60px var(--primary-glow), 0 24px 60px rgba(0,0,0,0.6);
    animation: rewardPop 0.4s cubic-bezier(0.34,1.56,0.64,1);
}

.daily-icon { font-size: 64px; animation: glyphPulse 2s ease-in-out infinite; }

.daily-title {
    font-size: 16px;
    font-weight: 800;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: var(--text);
}

.daily-streak {
    font-size: 13px;
    color: var(--text-2);
    font-weight: 500;
}

.daily-rewards {
    display: flex;
    gap: 12px;
}

.daily-rchip {
    padding: 8px 18px;
    border-radius: 99px;
    font-size: 14px;
    font-weight: 700;
    background: var(--surface-2);
    border: 1px solid var(--border-hi);
    color: var(--text);
}

/* ─── ERROR SCREEN ───────────────────────────── */
#error-screen {
    justify-content: center;
    align-items: center;
    z-index: 9998;
}

.error-content {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 16px;
    padding: 32px;
    text-align: center;
    max-width: 300px;
}

.error-icon { font-size: 48px; }

.error-title {
    font-size: 16px;
    font-weight: 800;
    letter-spacing: 2px;
    color: var(--red);
}

.error-msg {
    font-size: 14px;
    color: var(--text-2);
    line-height: 1.6;
}

/* ─── GAME-SPECIFIC STYLES ───────────────────── */

/* Doctor game */
.doctor-track {
    width: 100%;
    max-width: 340px;
    height: 80px;
    background: var(--surface);
    border: 1px solid var(--border-hi);
    border-radius: var(--radius);
    position: relative;
    overflow: hidden;
    cursor: pointer;
    margin: 0 auto;
}

.doctor-ekg {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    height: 100%;
    opacity: 0.2;
}

.doctor-target {
    position: absolute;
    top: 0;
    bottom: 0;
    background: rgba(52, 211, 153, 0.20);
    border-left: 2px solid var(--green);
    border-right: 2px solid var(--green);
    transition: box-shadow 0.1s;
}

.doctor-pin {
    position: absolute;
    top: 8px;
    bottom: 8px;
    width: 3px;
    background: var(--red);
    border-radius: 99px;
    transform: translateX(-50%);
    box-shadow: 0 0 10px var(--red), 0 0 20px var(--red-glow);
}

.doctor-tap-hint {
    text-align: center;
    font-size: 20px;
    color: var(--text-2);
    margin-top: 20px;
    letter-spacing: 1px;
}

.doctor-miss {
    animation: doctorMiss 0.3s ease;
}

@keyframes doctorMiss {
    0%,100% { transform: none; }
    25%      { transform: translateX(-6px); }
    75%      { transform: translateX(6px); }
}

/* Universal game */
.cipher-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    justify-content: center;
    max-width: 320px;
    margin: 0 auto;
}

.cipher-cell {
    width: 64px;
    height: 64px;
    background: var(--surface);
    border: 1.5px solid var(--border);
    border-radius: var(--radius);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    font-weight: 800;
    color: var(--text);
    cursor: pointer;
    transition: transform 0.1s, border-color 0.2s, background 0.2s, box-shadow 0.2s;
}

.cipher-cell:active { transform: scale(0.93); }

.cipher-cell.selected {
    background: rgba(139,92,246,0.2);
    border-color: var(--primary);
    color: var(--primary);
    box-shadow: 0 0 15px var(--primary-glow);
    transform: scale(1.05);
}

.cipher-cell.over-target {
    animation: cellShake 0.25s ease;
    border-color: var(--red);
    background: rgba(248,113,113,0.1);
}

@keyframes cellShake {
    0%,100% { transform: scale(1); }
    25%      { transform: translateX(-4px) scale(0.97); }
    75%      { transform: translateX(4px) scale(0.97); }
}

/* ─── UTILITIES ──────────────────────────────── */
.text-muted { color: var(--text-3); }
.text-primary { color: var(--primary); }

/* scrollbar */
::-webkit-scrollbar { width: 3px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--surface-3); border-radius: 99px; }

EOF_SDVIG

echo "  ✦ $STATIC/app.js"
mkdir -p $(dirname "$STATIC/app.js")
cat > "$STATIC/app.js" << 'EOF_SDVIG'
// ═══════════════════════════════════════════════
//  СДВИГ · app.js  2026
// ═══════════════════════════════════════════════

const tg = window.Telegram?.WebApp ?? null;

// ── State ────────────────────────────────────
let currentUser   = null;
let currentCase   = null;
let activeTab     = 'cases';
let currentGameDestroy = null;
let dailyClaimed  = false;

// ── DOM refs ─────────────────────────────────
const $ = id => document.getElementById(id);

// ── Init ─────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    if (tg) { try { tg.expand(); tg.ready(); } catch(e){} }
    spawnParticles();
    animateSplashBar();

    setTimeout(() => {
        if (tg?.initData?.length > 0) {
            setSplashText('Авторизация Telegram WebApp…');
            authWebApp();
        } else {
            showScreen('login-screen');
        }
    }, 1400);
});

// ── Particles ────────────────────────────────
function spawnParticles() {
    const wrap = $('splash-particles');
    for (let i = 0; i < 25; i++) {
        const p = document.createElement('div');
        p.className = 'splash-particle';
        p.style.left      = Math.random() * 100 + '%';
        p.style.width     = (Math.random() * 3 + 1) + 'px';
        p.style.height    = p.style.width;
        p.style.animationDuration  = (Math.random() * 6 + 4) + 's';
        p.style.animationDelay     = (Math.random() * 4) + 's';
        const hue = Math.random() > 0.5 ? '263' : '189';
        p.style.background = `hsl(${hue}, 80%, 70%)`;
        wrap.appendChild(p);
    }
}

function animateSplashBar() {
    const bar = $('splash-bar-fill');
    let w = 0;
    const steps = [20, 45, 70, 90];
    const delays = [200, 500, 900, 1200];
    delays.forEach((d, i) => {
        setTimeout(() => { bar.style.width = steps[i] + '%'; }, d);
    });
}

function setSplashText(txt) {
    const el = $('splash-text');
    if (el) el.textContent = txt;
}

// ── Screen management ─────────────────────────
function showScreen(id) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    $(id).classList.add('active');
}

// ── Auth ──────────────────────────────────────
function authWebApp() {
    fetch('/api/game/auth/webapp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ initData: tg.initData, initDataUnsafe: tg.initDataUnsafe })
    })
    .then(r => { if (!r.ok) throw new Error('auth'); return r.json(); })
    .then(profile => loginSuccess(profile))
    .catch(() => showError('Ошибка авторизации WebApp.\nПроверьте токен бота.'));
}

function onTelegramAuth(user) {
    showScreen('splash-screen');
    setSplashText('Проверка данных…');

    fetch('/api/game/auth/widget', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    })
    .then(r => { if (!r.ok) throw new Error('auth'); return r.json(); })
    .then(profile => loginSuccess(profile))
    .catch(() => showError('Ошибка входа через виджет.'));
}
window.onTelegramAuth = onTelegramAuth;

function showError(msg) {
    $('error-msg').textContent = msg;
    showScreen('error-screen');
}

// ── Login success ─────────────────────────────
function loginSuccess(profile) {
    currentUser = profile;
    updateHUD(profile);
    updateProfileTab(profile);
    showScreen('main-screen');
    loadCase();
    initSwipe();
    checkDailyBonus();
    vibrate(30);
}

// ── HUD update ────────────────────────────────
function updateHUD(p) {
    $('hud-energy').textContent   = p.energy;
    $('hud-credits').textContent  = p.credits;
    $('hud-rank').textContent     = p.rank;
    $('hud-xp').textContent       = p.xp;
    const xpMax = p.rank * 150;
    $('hud-xp-max').textContent   = xpMax;
    $('xp-fill').style.width      = Math.min(100, (p.xp / xpMax) * 100) + '%';

    // Update game levels in Games tab
    const dl = p.detectiveLvl  || 1;
    const dcl = p.doctorLvl    || 1;
    const ul = p.universalLvl  || 1;
    $('det-lvl').textContent  = dl;
    $('doc-lvl').textContent  = dcl;
    $('uni-lvl').textContent  = ul;
    $('det-progress').style.width = Math.min(100, dl) + '%';
    $('doc-progress').style.width = Math.min(100, dcl) + '%';
    $('uni-progress').style.width = Math.min(100, ul) + '%';
}

function updateProfileTab(p) {
    const name = p.firstName || p.username || 'Агент';
    $('profile-avatar').textContent = name.charAt(0).toUpperCase();
    $('profile-name').textContent   = name;
    $('profile-id').textContent     = 'ID: ' + (p.providerId || '—');

    const archetypeNames = {
        detective: '🔍 Детектив',
        doctor:    '⚕️ Медик',
        hacker:    '💻 Хакер'
    };
    $('profile-archetype').textContent = archetypeNames[p.archetype] || '🔍 Детектив';

    $('pstat-rank').textContent    = p.rank;
    $('pstat-credits').textContent = p.credits;
    $('pstat-cases').textContent   = p.totalCases || 0;
    $('pstat-streak').textContent  = p.streak || 0;

    const s1 = p.skill1 || 1;
    const s2 = p.skill2 || 1;
    $('sk1-lvl').textContent  = 'Lv.' + s1;
    $('sk2-lvl').textContent  = 'Lv.' + s2;
    $('sk1-cost').textContent = (s1 * 50) + '💎';
    $('sk2-cost').textContent = (s2 * 50) + '💎';
    $('sk1-bar').style.width  = Math.min(100, s1 * 10) + '%';
    $('sk2-bar').style.width  = Math.min(100, s2 * 10) + '%';
}

// ── Tab navigation ────────────────────────────
function switchTab(name) {
    if (activeTab === name) return;

    // Hide game viewport if switching away from games
    if (activeTab === 'games') closeGame();

    document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
    document.querySelectorAll('.nav-btn').forEach(b => b.classList.remove('active'));

    $('tab-' + name).classList.add('active');
    document.querySelector(`[data-tab="${name}"]`).classList.add('active');

    activeTab = name;
    vibrate(10);

    if (name === 'profile') updateProfileTab(currentUser);
}
window.switchTab = switchTab;

// ── Case loading ──────────────────────────────
function loadCase() {
    $('case-description').textContent = 'ИИ сканирует архивы…';
    $('card-badge').textContent = '📁 ДЕЛО';
    $('card-icon').textContent  = '🔍';
    $('result-overlay').classList.add('hidden');

    const card = $('main-card');
    card.style.transition = 'none';
    card.style.transform  = 'none';
    card.classList.remove('drag-left', 'drag-right');
    $('sh-left').style.opacity  = '0';
    $('sh-right').style.opacity = '0';

    fetch('/api/game/case?providerId=' + encodeURIComponent(currentUser.providerId))
    .then(r => r.text())
    .then(text => {
        try {
            let data = JSON.parse(text);
            if (typeof data === 'string') data = JSON.parse(data);
            currentCase = data;
            $('case-description').textContent = data.text;
            $('sh-left-text').textContent     = data.leftOption  || 'ОТКАЗАТЬ';
            $('sh-right-text').textContent    = data.rightOption || 'ПРИНЯТЬ';
            $('ca-left').textContent          = '◀ ' + (data.leftOption  || 'ОТКАЗАТЬ');
            $('ca-right').textContent         = (data.rightOption || 'ПРИНЯТЬ') + ' ▶';
        } catch {
            currentCase = {
                text: text,
                leftOption:   'ОТКАЗАТЬ',
                rightOption:  'ПРИНЯТЬ',
                leftResult:   'Вы отказались.',
                rightResult:  'Вы приняли дело.'
            };
            $('case-description').textContent = text;
        }
    })
    .catch(() => {
        $('case-description').textContent = '⚠️ Ошибка связи с архивом.';
    });
}

// ── Swipe physics ─────────────────────────────
function initSwipe() {
    const card = $('main-card');
    let startX = 0, startY = 0, currentX = 0;
    let dragging = false;
    let lastX = 0, velocity = 0, lastTime = 0;

    const onStart = (e) => {
        if (!$('result-overlay').classList.contains('hidden')) return;
        if (!currentCase) return;
        dragging  = true;
        startX    = getX(e);
        startY    = getY(e);
        lastX     = startX;
        lastTime  = Date.now();
        card.style.transition = 'none';
    };

    const onMove = (e) => {
        if (!dragging) return;
        e.preventDefault();
        currentX  = getX(e);
        const now = Date.now();
        velocity  = (currentX - lastX) / Math.max(1, now - lastTime);
        lastX     = currentX;
        lastTime  = now;

        const diffX = currentX - startX;
        const rot   = diffX / 16;
        const scaleY = 1 - Math.min(0.04, Math.abs(diffX) / 3000);
        card.style.transform = `translateX(${diffX}px) rotate(${rot}deg) scaleY(${scaleY})`;

        const ratio = Math.min(1, Math.abs(diffX) / 80);
        if (diffX < -30) {
            card.classList.add('drag-left');
            card.classList.remove('drag-right');
            $('sh-left').style.opacity  = ratio;
            $('sh-right').style.opacity = '0';
        } else if (diffX > 30) {
            card.classList.add('drag-right');
            card.classList.remove('drag-left');
            $('sh-right').style.opacity = ratio;
            $('sh-left').style.opacity  = '0';
        } else {
            card.classList.remove('drag-left', 'drag-right');
            $('sh-left').style.opacity  = '0';
            $('sh-right').style.opacity = '0';
        }
    };

    const onEnd = () => {
        if (!dragging) return;
        dragging = false;
        const diffX = currentX - startX;
        const threshold = 90;
        const velThreshold = 0.4;

        card.style.transition = 'transform 0.35s cubic-bezier(0.25,0.46,0.45,0.94)';

        if (diffX < -threshold || velocity < -velThreshold) {
            flyCard('left');
        } else if (diffX > threshold || velocity > velThreshold) {
            flyCard('right');
        } else {
            card.style.transform = 'none';
            card.classList.remove('drag-left', 'drag-right');
            $('sh-left').style.opacity  = '0';
            $('sh-right').style.opacity = '0';
        }
    };

    card.addEventListener('touchstart', onStart, { passive: true });
    card.addEventListener('mousedown',  onStart);
    window.addEventListener('touchmove',  onMove, { passive: false });
    window.addEventListener('mousemove',  onMove);
    window.addEventListener('touchend',   onEnd);
    window.addEventListener('mouseup',    onEnd);
}

function getX(e) { return e.touches ? e.touches[0].clientX : e.clientX; }
function getY(e) { return e.touches ? e.touches[0].clientY : e.clientY; }

function flyCard(direction) {
    const card = $('main-card');
    const tx   = direction === 'left' ? '-150vw' : '150vw';
    const rot  = direction === 'left' ? '-30deg'  : '30deg';
    card.style.transition = 'transform 0.4s cubic-bezier(0.55,0,1,0.45), opacity 0.4s ease';
    card.style.transform  = `translateX(${tx}) rotate(${rot})`;
    card.style.opacity    = '0';
    vibrate(25);
    submitChoice(direction);
}

// ── Submit choice ─────────────────────────────
function submitChoice(direction) {
    if (!currentUser || !currentCase) return;

    fetch(`/api/game/choice?providerId=${encodeURIComponent(currentUser.providerId)}&direction=${direction}`, { method: 'POST' })
    .then(r => {
        if (!r.ok) return r.text().then(t => { showToast('⚡', 'Нет энергии', t); throw new Error(); });
        return r.json();
    })
    .then(data => {
        currentUser = data.profile;
        updateHUD(currentUser);

        const isRight = direction === 'right';
        $('result-badge').textContent  = isRight ? '✓ ПРИНЯТО' : '✕ ОТКАЗАНО';
        $('result-badge').style.color  = isRight ? 'var(--green)' : 'var(--red)';
        $('result-text').textContent   = isRight ? currentCase.rightResult : currentCase.leftResult;
        $('rew-xp').textContent        = data.xpGained;
        $('rew-credits').textContent   = data.creditsGained;
        $('rew-energy').textContent    = data.energyLost;

        setTimeout(() => {
            $('result-overlay').classList.remove('hidden');
            checkAchievements(data.profile);
        }, 320);

        vibrate([30, 20, 60]);
    })
    .catch(() => {
        const card = $('main-card');
        card.style.transition = 'transform 0.4s cubic-bezier(0.34,1.56,0.64,1)';
        card.style.transform  = 'none';
        card.style.opacity    = '1';
        card.classList.remove('drag-left', 'drag-right');
        $('sh-left').style.opacity  = '0';
        $('sh-right').style.opacity = '0';
    });
}

function nextCase() {
    $('result-overlay').classList.add('hidden');
    const card = $('main-card');
    card.style.transition = 'none';
    card.style.opacity    = '0';
    card.style.transform  = 'translateX(40px)';
    loadCase();
    requestAnimationFrame(() => {
        requestAnimationFrame(() => {
            card.style.transition = 'transform 0.4s cubic-bezier(0.34,1.56,0.64,1), opacity 0.3s ease';
            card.style.transform  = 'none';
            card.style.opacity    = '1';
        });
    });
}
window.nextCase = nextCase;

// ── Skills & Shop ─────────────────────────────
function upgradeSkill(num) {
    if (!currentUser) return;
    fetch(`/api/game/upgrade-skill?providerId=${encodeURIComponent(currentUser.providerId)}&skillNum=${num}`, { method: 'POST' })
    .then(r => {
        if (!r.ok) return r.text().then(t => { showToast('💎', 'Недостаточно кредитов', t); throw new Error(); });
        return r.json();
    })
    .then(p => {
        currentUser = p;
        updateHUD(p);
        updateProfileTab(p);
        showToast('🧠', 'НАВЫК УЛУЧШЕН', num === 1 ? 'Проницательность Lv.' + p.skill1 : 'Технологии Lv.' + p.skill2);
        vibrate([20, 20, 40]);
    })
    .catch(() => {});
}
window.upgradeSkill = upgradeSkill;

function buyCoffee() {
    if (!currentUser) return;
    fetch(`/api/game/buy-coffee?providerId=${encodeURIComponent(currentUser.providerId)}`, { method: 'POST' })
    .then(r => {
        if (!r.ok) return r.text().then(t => { showToast('☕', 'Нет кредитов', t); throw new Error(); });
        return r.json();
    })
    .then(p => {
        currentUser = p;
        updateHUD(p);
        updateProfileTab(p);
        showToast('☕', 'КОФЕ ВЫПИТ', '+35 ⚡ энергии');
        vibrate(30);
    })
    .catch(() => {});
}
window.buyCoffee = buyCoffee;

// ── Daily bonus ───────────────────────────────
function checkDailyBonus() {
    if (!currentUser) return;
    fetch(`/api/game/daily-bonus?providerId=${encodeURIComponent(currentUser.providerId)}`)
    .then(r => r.ok ? r.json() : null)
    .then(data => {
        if (!data || !data.available) return;
        $('daily-streak').textContent = data.streak || 1;
        $('daily-modal').classList.remove('hidden');
    })
    .catch(() => {});
}

function claimDaily() {
    if (!currentUser || dailyClaimed) return;
    $('daily-modal').classList.add('hidden');
    dailyClaimed = true;

    fetch(`/api/game/daily-bonus/claim?providerId=${encodeURIComponent(currentUser.providerId)}`, { method: 'POST' })
    .then(r => r.ok ? r.json() : null)
    .then(data => {
        if (!data) return;
        currentUser = data.profile;
        updateHUD(currentUser);
        updateProfileTab(currentUser);
        showToast('🎁', 'БОНУС ПОЛУЧЕН', `+50💎 · +30⚡ · Серия: ${data.profile.streak}д.`);
        vibrate([30, 20, 30, 20, 80]);
    })
    .catch(() => {});
}
window.claimDaily = claimDaily;

// ── Achievements ──────────────────────────────
const achievementDefs = [
    { id: 'rank5',    check: p => p.rank >= 5,   icon: '🏅', title: 'АГЕНТ В ДЕЛЕ',    desc: 'Достигнут 5-й ранг' },
    { id: 'rank10',   check: p => p.rank >= 10,  icon: '🏆', title: 'ЭЛИТА',           desc: 'Достигнут 10-й ранг' },
    { id: 'cases10',  check: p => (p.totalCases||0) >= 10, icon: '📂', title: 'ДЕТЕКТИВ',  desc: '10 дел закрыто' },
    { id: 'cases50',  check: p => (p.totalCases||0) >= 50, icon: '🗃️', title: 'АРХИВАРИУС', desc: '50 дел закрыто' },
    { id: 'streak3',  check: p => (p.streak||0) >= 3,  icon: '🔥', title: 'НА СЕРИИ',      desc: 'Серия 3 дня подряд' },
    { id: 'streak7',  check: p => (p.streak||0) >= 7,  icon: '💥', title: 'НЕСГИБАЕМЫЙ',   desc: 'Серия 7 дней' },
    { id: 'sk1max',   check: p => p.skill1 >= 5, icon: '🧠', title: 'ПРОНИЦАТЕЛЬ',   desc: 'Проницательность Lv.5' },
    { id: 'sk2max',   check: p => p.skill2 >= 5, icon: '⚙️', title: 'ТЕХНАРЬ',        desc: 'Технологии Lv.5' },
];

const shownAchievements = new Set(
    JSON.parse(localStorage.getItem('sdvig_ach') || '[]')
);

function checkAchievements(profile) {
    for (const def of achievementDefs) {
        if (!shownAchievements.has(def.id) && def.check(profile)) {
            shownAchievements.add(def.id);
            localStorage.setItem('sdvig_ach', JSON.stringify([...shownAchievements]));
            setTimeout(() => showToast(def.icon, def.title, def.desc), 600);
            break;
        }
    }
}

// ── Toast ─────────────────────────────────────
let toastTimer = null;
function showToast(icon, title, desc) {
    const toast = $('toast');
    $('toast-icon').textContent  = icon;
    $('toast-title').textContent = title;
    $('toast-desc').textContent  = desc;
    toast.classList.remove('hidden', 'hide-out');
    if (toastTimer) clearTimeout(toastTimer);
    toastTimer = setTimeout(() => {
        toast.classList.add('hide-out');
        setTimeout(() => toast.classList.add('hidden'), 350);
    }, 3000);
    vibrate(20);
}

// ── Mini-games launcher ───────────────────────
const GAME_TITLES = {
    detective: '💎 САМОЦВЕТЫ',
    doctor:    '💓 КАРДИОГРАММА',
    universal: '🧮 ЭКСПЕРТИЗА ШИФРА'
};

async function launchGame(type) {
    $('game-vp-wrap').classList.remove('hidden');
    $('game-vp-title').textContent = GAME_TITLES[type] || 'ИГРА';
    $('win-badge').classList.add('hidden');

    const viewport = $('game-viewport');
    viewport.innerHTML = '';

    if (currentGameDestroy) { try { currentGameDestroy(); } catch(e){} currentGameDestroy = null; }

    const level = getGameLevel(type);

    try {
        const mod = await import(`./games/${type}.js`);
        currentGameDestroy = mod.destroy;
        mod.initGame(viewport, level, () => onGameWin(type));
    } catch(err) {
        viewport.innerHTML = `<div style="color:var(--red);text-align:center;padding:32px">⚠️ Ошибка загрузки игры</div>`;
    }
}
window.launchGame = launchGame;

function getGameLevel(type) {
    if (!currentUser) return 1;
    const map = { detective: 'detectiveLvl', doctor: 'doctorLvl', universal: 'universalLvl' };
    return currentUser[map[type]] || 1;
}

function onGameWin(type) {
    const badge = $('win-badge');
    badge.classList.remove('hidden');
    vibrate([30, 20, 30, 20, 100]);
    showToast('🎮', 'УРОВЕНЬ ПРОЙДЕН', 'Получено +50 XP');

    // Advance level on server
    fetch(`/api/game/advance-level?providerId=${encodeURIComponent(currentUser.providerId)}&gameType=${type}`, { method: 'POST' })
    .then(r => r.ok ? r.json() : null)
    .then(p => {
        if (p) {
            currentUser = p;
            updateHUD(p);
            updateProfileTab(p);
        }
    })
    .catch(() => {});
}

function closeGame() {
    if (currentGameDestroy) { try { currentGameDestroy(); } catch(e){} currentGameDestroy = null; }
    $('game-vp-wrap').classList.add('hidden');
    $('game-viewport').innerHTML = '';
    $('win-badge').classList.add('hidden');
}
window.closeGame = closeGame;

// ── Haptics ───────────────────────────────────
function vibrate(pattern) {
    try { if (navigator.vibrate) navigator.vibrate(pattern); } catch(e) {}
}

EOF_SDVIG

echo "  ✦ $STATIC/games/detective.js"
mkdir -p $(dirname "$STATIC/games/detective.js")
cat > "$STATIC/games/detective.js" << 'EOF_SDVIG'
// ─── САМОЦВЕТЫ · Match-3 ──────────────────────

const GEM_EMOJI = {
    red:    '🔴', blue:   '🔵', green:  '🟢',
    yellow: '🟡', purple: '🟣', orange: '🟠'
};

const GEM_COLORS_CSS = {
    red:    '#f87171', blue:   '#60a5fa', green:  '#34d399',
    yellow: '#fbbf24', purple: '#a78bfa', orange: '#fb923c'
};

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    viewport.style.display        = 'flex';
    viewport.style.flexDirection  = 'column';
    viewport.style.alignItems     = 'center';
    viewport.style.gap            = '12px';
    viewport.style.width          = '100%';

    const ROWS   = 9;
    const COLS   = 9;
    const COLORS = Object.keys(GEM_EMOJI);

    // ── Mission ──────────────────────────────
    const mission = getMission(level);
    let collected  = 0;
    let iceCleared = 0;
    let combo      = 0;

    // ── Board state ──────────────────────────
    let board    = Array.from({ length: ROWS }, () => Array(COLS).fill(null));
    let iceLayer = Array.from({ length: ROWS }, () => Array(COLS).fill(0));
    let selR = null, selC = null;
    let gameActive = true, processing = false;

    // ── Cell size (responsive) ───────────────
    const vw      = Math.min(viewport.offsetWidth || window.innerWidth, 400);
    const GAP     = 3;
    const PAD     = 12;
    const CELL    = Math.floor((vw - PAD * 2 - GAP * (COLS - 1)) / COLS);

    // ── Mission panel ────────────────────────
    const panel = mkDiv({
        width: '100%',
        background: 'var(--surface)',
        border: '1px solid var(--border)',
        borderRadius: 'var(--radius)',
        padding: '10px 14px',
        fontFamily: 'inherit',
        color: 'var(--text)',
        textAlign: 'center',
        fontSize: '13px',
        fontWeight: '600',
    });

    const lvlLabel = document.createElement('div');
    lvlLabel.style.cssText = 'font-size:11px;letter-spacing:2px;color:var(--text-3);margin-bottom:4px;';
    lvlLabel.textContent = 'УРОВЕНЬ ' + level;
    panel.appendChild(lvlLabel);

    const missionLabel = document.createElement('div');
    missionLabel.id = 'gem-mission';
    panel.appendChild(missionLabel);

    const comboLabel = document.createElement('div');
    comboLabel.style.cssText = 'font-size:11px;color:var(--primary);margin-top:4px;font-weight:700;letter-spacing:1px;min-height:16px;';
    panel.appendChild(comboLabel);

    viewport.appendChild(panel);
    refreshMission();

    // ── Grid ─────────────────────────────────
    const grid = document.createElement('div');
    grid.style.cssText = `
        display: grid;
        grid-template-columns: repeat(${COLS}, ${CELL}px);
        gap: ${GAP}px;
        background: var(--surface);
        padding: ${PAD}px;
        border-radius: var(--radius-lg);
        border: 1px solid var(--border-hi);
        box-shadow: 0 0 40px var(--primary-glow);
    `;
    viewport.appendChild(grid);

    const cells = Array.from({ length: ROWS }, () => Array(COLS).fill(null));

    // ── Render ───────────────────────────────
    function renderBoard() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                const cell  = cells[r][c];
                const color = board[r][c];

                cell.textContent = GEM_EMOJI[color] || '';

                const isIce = iceLayer[r][c] > 0;
                const isSel = selR === r && selC === c;

                cell.style.background   = isIce ? 'rgba(34,211,238,0.15)' : 'var(--surface-2)';
                cell.style.borderColor  = isSel ? 'var(--gold)' :
                                          isIce ? 'rgba(34,211,238,0.5)' :
                                          'transparent';
                cell.style.boxShadow    = isSel
                    ? `0 0 0 2px var(--gold), 0 0 16px var(--gold-glow)`
                    : isIce
                    ? `inset 0 0 8px rgba(34,211,238,0.2)`
                    : 'none';
                cell.style.transform    = isSel ? 'scale(1.1)' : 'scale(1)';
                cell.style.opacity      = '1';
                cell.style.filter       = isIce ? 'brightness(0.7) saturate(0.5)' : 'none';

                if (isIce && iceLayer[r][c] === 2) {
                    cell.style.background = 'rgba(34,211,238,0.3)';
                }
            }
        }
    }

    function createGrid() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                const cell = mkDiv({
                    width:          CELL + 'px',
                    height:         CELL + 'px',
                    borderRadius:   '8px',
                    display:        'flex',
                    alignItems:     'center',
                    justifyContent: 'center',
                    fontSize:       Math.max(16, CELL - 12) + 'px',
                    cursor:         'pointer',
                    border:         '1.5px solid transparent',
                    transition:     'transform 0.12s, border-color 0.12s, box-shadow 0.12s, background 0.12s',
                    lineHeight:     '1',
                    userSelect:     'none',
                    WebkitUserSelect: 'none',
                });
                cell.addEventListener('click', ((_r, _c) => () => onCellClick(_r, _c))(r, c));
                grid.appendChild(cell);
                cells[r][c] = cell;
            }
        }
    }

    // ── Match logic ───────────────────────────
    function getAllMatches() {
        const m = new Set();
        for (let r = 0; r < ROWS; r++) {
            let len = 1;
            for (let c = 1; c <= COLS; c++) {
                if (c < COLS && board[r][c] === board[r][c-1]) { len++; }
                else { if (len >= 3) for (let i = c-len; i < c; i++) m.add(`${r},${i}`); len = 1; }
            }
        }
        for (let c = 0; c < COLS; c++) {
            let len = 1;
            for (let r = 1; r <= ROWS; r++) {
                if (r < ROWS && board[r][c] === board[r-1][c]) { len++; }
                else { if (len >= 3) for (let i = r-len; i < r; i++) m.add(`${i},${c}`); len = 1; }
            }
        }
        return m;
    }

    function processMatches(matchSet) {
        let gainColor = 0, gainIce = 0;
        for (const coord of matchSet) {
            const [r, c] = coord.split(',').map(Number);
            if (iceLayer[r][c] > 0) {
                iceLayer[r][c]--;
                if (iceLayer[r][c] === 0) gainIce++;
            }
        }
        for (const coord of matchSet) {
            const [r, c] = coord.split(',').map(Number);
            if (iceLayer[r][c] === 0 && mission.color && board[r][c] === mission.color) gainColor++;
        }
        for (const coord of matchSet) {
            const [r, c] = coord.split(',').map(Number);
            board[r][c]    = null;
            iceLayer[r][c] = 0;
        }
        collected  += gainColor;
        iceCleared += gainIce;
        combo++;
        if (combo > 1) {
            comboLabel.textContent = `✨ COMBO x${combo}!`;
            setTimeout(() => { comboLabel.textContent = ''; }, 1200);
        }
        refreshMission();
        checkVictory();
    }

    function applyGravityAndRefill() {
        for (let c = 0; c < COLS; c++) {
            const gems = [], ice = [];
            for (let r = ROWS - 1; r >= 0; r--) {
                if (board[r][c] !== null) { gems.push(board[r][c]); ice.push(iceLayer[r][c]); }
            }
            while (gems.length < ROWS) { gems.push(COLORS[Math.floor(Math.random() * COLORS.length)]); ice.push(0); }
            gems.reverse(); ice.reverse();
            for (let r = 0; r < ROWS; r++) { board[r][c] = gems[r]; iceLayer[r][c] = ice[r]; }
        }
    }

    async function resolveLoop() {
        if (processing) return;
        processing = true;
        let any = true;
        while (any && gameActive) {
            const m = getAllMatches();
            if (m.size === 0) { any = false; break; }
            processMatches(m);
            if (!gameActive) break;
            applyGravityAndRefill();
            renderBoard();
            await delay(80);
        }
        processing = false;
        if (gameActive && !hasValidMove()) shuffleBoard();
        renderBoard();
    }

    function hasValidMove() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                if (c + 1 < COLS) { swap(r,c,r,c+1); if (getAllMatches().size > 0) { swap(r,c,r,c+1); return true; } swap(r,c,r,c+1); }
                if (r + 1 < ROWS) { swap(r,c,r+1,c); if (getAllMatches().size > 0) { swap(r,c,r+1,c); return true; } swap(r,c,r+1,c); }
            }
        }
        return false;
    }

    function shuffleBoard() {
        const flat = board.flat();
        for (let i = flat.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [flat[i], flat[j]] = [flat[j], flat[i]];
        }
        let idx = 0;
        for (let r = 0; r < ROWS; r++) for (let c = 0; c < COLS; c++) board[r][c] = flat[idx++];
        resolveLoop();
    }

    function swap(r1,c1,r2,c2) {
        [board[r1][c1], board[r2][c2]] = [board[r2][c2], board[r1][c1]];
        [iceLayer[r1][c1], iceLayer[r2][c2]] = [iceLayer[r2][c2], iceLayer[r1][c1]];
    }

    async function trySwap(r1,c1,r2,c2) {
        if (processing || !gameActive) return;
        swap(r1,c1,r2,c2);
        if (getAllMatches().size > 0) { combo = 0; renderBoard(); await resolveLoop(); }
        else { swap(r1,c1,r2,c2); renderBoard(); }
    }

    function onCellClick(r, c) {
        if (processing || !gameActive) return;
        if (selR === null) { selR = r; selC = c; renderBoard(); return; }
        if (selR === r && selC === c) { selR = null; selC = null; renderBoard(); return; }
        const isAdj = Math.abs(selR - r) + Math.abs(selC - c) === 1;
        if (!isAdj) { selR = r; selC = c; renderBoard(); return; }
        const [r1,c1] = [selR, selC]; selR = null; selC = null;
        trySwap(r1,c1,r,c).catch(console.error);
    }

    // ── Init board ────────────────────────────
    function initBoard() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                const forbidden = new Set();
                if (c >= 2 && board[r][c-1] === board[r][c-2]) forbidden.add(board[r][c-1]);
                if (r >= 2 && board[r-1][c] === board[r-2][c]) forbidden.add(board[r-1][c]);
                const avail = COLORS.filter(x => !forbidden.has(x));
                board[r][c] = avail[Math.floor(Math.random() * avail.length)] || COLORS[0];
            }
        }
    }

    function placeIce() {
        if (mission.type === 'collect') return;
        const count = mission.type === 'clear_ice' ? mission.target : (mission.targetIce || 0);
        if (count === 0) return;
        const positions = [];
        for (let r = 0; r < ROWS; r++) for (let c = 0; c < COLS; c++) positions.push([r,c]);
        positions.sort(() => Math.random() - 0.5);
        let placed = 0;
        for (const [r,c] of positions) {
            if (placed >= count) break;
            iceLayer[r][c] = level > 25 ? 2 : 1;
            placed++;
        }
    }

    // ── Victory ───────────────────────────────
    function checkVictory() {
        const done =
            mission.type === 'collect'   ? collected  >= mission.target :
            mission.type === 'clear_ice' ? iceCleared >= mission.target :
            /* mixed */ collected >= mission.targetCollect && iceCleared >= mission.targetIce;

        if (done && gameActive) {
            gameActive = false;
            onWin();
        }
    }

    // ── Mission text ──────────────────────────
    function refreshMission() {
        const el = document.getElementById('gem-mission');
        if (!el) return;
        const gem = GEM_EMOJI[mission.color] || '';
        if (mission.type === 'collect') {
            el.innerHTML = `${gem} Собери: ${collected} / ${mission.target}`;
        } else if (mission.type === 'clear_ice') {
            el.innerHTML = `❄️ Разморозь: ${iceCleared} / ${mission.target}`;
        } else {
            el.innerHTML = `${gem} ${collected}/${mission.targetCollect} &nbsp; ❄️ ${iceCleared}/${mission.targetIce}`;
        }
    }

    // ── Start ─────────────────────────────────
    initBoard();
    placeIce();
    createGrid();
    renderBoard();
    if (!hasValidMove()) shuffleBoard();
}

// ── Helpers ───────────────────────────────────
function getMission(lvl) {
    if (lvl <= 5)  return { type: 'collect', color: 'blue',   target: 10 + lvl };
    if (lvl <= 10) return { type: 'collect', color: 'green',  target: 15 + (lvl-5)*2 };
    if (lvl <= 15) return { type: 'collect', color: 'purple', target: 20 + (lvl-10)*3 };
    if (lvl <= 20) return { type: 'clear_ice', target: 5 + (lvl-15) };
    return { type: 'mixed', color: 'blue', targetCollect: 20+(lvl-20)*2, targetIce: 8+Math.floor((lvl-20)/2) };
}

function mkDiv(styles) {
    const d = document.createElement('div');
    Object.assign(d.style, styles);
    return d;
}

function delay(ms) { return new Promise(r => setTimeout(r, ms)); }

export function destroy() {}

EOF_SDVIG

echo "  ✦ $STATIC/games/doctor.js"
mkdir -p $(dirname "$STATIC/games/doctor.js")
cat > "$STATIC/games/doctor.js" << 'EOF_SDVIG'
// ─── КАРДИОГРАММА · Precision tap ────────────

let _loop = null;

export function initGame(viewport, level, onWin) {
    if (_loop) { clearInterval(_loop); _loop = null; }

    viewport.innerHTML = '';
    viewport.style.display        = 'flex';
    viewport.style.flexDirection  = 'column';
    viewport.style.alignItems     = 'center';
    viewport.style.gap            = '20px';
    viewport.style.padding        = '12px';

    // ── Header ─────────────────────────────
    const header = document.createElement('div');
    header.style.cssText = `
        text-align: center;
        width: 100%;
    `;
    header.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--text-3);font-weight:700;text-transform:uppercase;">УРОВЕНЬ ${level}</div>
        <div style="font-size:36px;margin:8px 0;filter:drop-shadow(0 0 12px rgba(248,113,113,0.5));">💓</div>
        <div style="font-size:13px;color:var(--text-2);font-weight:600;">Поймай импульс в зелёной зоне</div>
    `;
    viewport.appendChild(header);

    // ── EKG Decoration ─────────────────────
    const ekgWrap = document.createElement('div');
    ekgWrap.style.cssText = 'width:100%;max-width:340px;height:40px;position:relative;overflow:hidden;opacity:0.35;';
    const ekgSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    ekgSvg.setAttribute('viewBox', '0 0 340 40');
    ekgSvg.setAttribute('width', '100%');
    ekgSvg.setAttribute('height', '40');
    ekgSvg.innerHTML = `
        <polyline
          fill="none"
          stroke="var(--red)"
          stroke-width="1.5"
          points="0,20 30,20 38,5 44,35 50,20 60,20 90,20 98,5 104,35 110,20 120,20 150,20 158,5 164,35 170,20 180,20 210,20 218,5 224,35 230,20 240,20 270,20 278,5 284,35 290,20 300,20 330,20 338,5 340,35"
        />
    `;
    ekgWrap.appendChild(ekgSvg);
    viewport.appendChild(ekgWrap);

    // ── Track ──────────────────────────────
    const trackWrap = document.createElement('div');
    trackWrap.style.cssText = `
        width: 100%;
        max-width: 340px;
        padding: 0 4px;
    `;

    const track = document.createElement('div');
    track.className = 'doctor-track';
    trackWrap.appendChild(track);
    viewport.appendChild(trackWrap);

    // Target zone
    const targetWidth = Math.max(6, 30 - level * 0.25);
    const targetLeft  = Math.floor(Math.random() * (70 - targetWidth)) + 15;

    const targetEl = document.createElement('div');
    targetEl.className = 'doctor-target';
    targetEl.style.left  = targetLeft + '%';
    targetEl.style.width = targetWidth + '%';
    track.appendChild(targetEl);

    // Pulse pin
    const pin = document.createElement('div');
    pin.className = 'doctor-pin';
    track.appendChild(pin);

    // ── Hint ───────────────────────────────
    const hint = document.createElement('div');
    hint.className = 'doctor-tap-hint';
    hint.textContent = '↓ Нажми в любом месте ↓';
    viewport.appendChild(hint);

    // ── Stats ──────────────────────────────
    const stats = document.createElement('div');
    stats.style.cssText = 'display:flex;gap:16px;justify-content:center;';
    stats.innerHTML = `
        <div style="text-align:center;">
            <div style="font-size:10px;letter-spacing:1.5px;color:var(--text-3);font-weight:700;">СКОРОСТЬ</div>
            <div style="font-size:18px;font-weight:800;color:var(--red);">${(2 + level * 0.12).toFixed(1)}×</div>
        </div>
        <div style="text-align:center;">
            <div style="font-size:10px;letter-spacing:1.5px;color:var(--text-3);font-weight:700;">ЗОНА</div>
            <div style="font-size:18px;font-weight:800;color:var(--green);">${Math.round(targetWidth)}%</div>
        </div>
    `;
    viewport.appendChild(stats);

    // ── Animation ──────────────────────────
    let pos = 0, dir = 1;
    const speed = 2 + level * 0.12;

    _loop = setInterval(() => {
        pos += speed * dir;
        if (pos >= 100 || pos <= 0) {
            dir *= -1;
            // Chaos mode on high levels
            if (level > 65 && Math.random() > 0.88) dir *= -1;
        }
        pin.style.left = pos + '%';
    }, 16);

    // ── Click handler ──────────────────────
    let tapped = false;
    const tapHandler = (e) => {
        if (tapped) return;
        const inZone = pos >= targetLeft && pos <= targetLeft + targetWidth;
        if (inZone) {
            tapped = true;
            clearInterval(_loop);
            _loop = null;
            hint.textContent = '✓ ПОПАДАНИЕ!';
            hint.style.color = 'var(--green)';
            pin.style.background     = 'var(--green)';
            pin.style.boxShadow      = '0 0 10px var(--green), 0 0 20px var(--green-glow)';
            targetEl.style.background = 'rgba(52,211,153,0.35)';
            targetEl.style.borderColor = 'var(--green)';
            setTimeout(() => onWin(), 400);
        } else {
            if (navigator.vibrate) navigator.vibrate([80, 40, 80]);
            track.classList.add('doctor-miss');
            hint.textContent = '✗ МИМО — попробуй ещё';
            hint.style.color = 'var(--red)';
            pin.style.boxShadow = '0 0 16px var(--red), 0 0 30px var(--red-glow)';
            setTimeout(() => {
                track.classList.remove('doctor-miss');
                pin.style.boxShadow = '0 0 10px var(--red), 0 0 20px var(--red-glow)';
                hint.textContent = '↓ Нажми ещё раз ↓';
                hint.style.color = 'var(--text-2)';
            }, 500);
        }
    };

    viewport.addEventListener('click', tapHandler);
    viewport._tapHandler = tapHandler;
}

export function destroy() {
    if (_loop) { clearInterval(_loop); _loop = null; }
}

EOF_SDVIG

echo "  ✦ $STATIC/games/universal.js"
mkdir -p $(dirname "$STATIC/games/universal.js")
cat > "$STATIC/games/universal.js" << 'EOF_SDVIG'
// ─── ЭКСПЕРТИЗА ШИФРА · Math cipher ──────────

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    viewport.style.display        = 'flex';
    viewport.style.flexDirection  = 'column';
    viewport.style.alignItems     = 'center';
    viewport.style.gap            = '16px';
    viewport.style.width          = '100%';

    const targetSum   = 10 + level * 4 + Math.floor(Math.random() * 5);
    const cellsCount  = level <= 10 ? 6 : level <= 40 ? 8 : 12;
    let currentSum    = 0;
    const selected    = new Set();

    // ── Header ─────────────────────────────
    const header = document.createElement('div');
    header.style.cssText = 'text-align:center;width:100%;';
    header.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--text-3);font-weight:700;text-transform:uppercase;margin-bottom:4px;">УРОВЕНЬ ${level} · ЭКСПЕРТИЗА ШИФРА</div>
        <div style="font-size:13px;color:var(--text-2);font-weight:600;">Выбери числа в сумме:</div>
    `;
    viewport.appendChild(header);

    // ── Target display ─────────────────────
    const targetBox = document.createElement('div');
    targetBox.style.cssText = `
        background: var(--surface);
        border: 1px solid var(--border-hi);
        border-radius: var(--radius);
        padding: 14px 32px;
        text-align: center;
        box-shadow: 0 0 20px var(--primary-glow);
    `;
    targetBox.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:var(--primary);font-weight:700;text-transform:uppercase;">ЦЕЛЬ</div>
        <div style="font-size:48px;font-weight:800;color:var(--text);line-height:1.1;">${targetSum}</div>
    `;
    viewport.appendChild(targetBox);

    // ── Progress bar ───────────────────────
    const progressWrap = document.createElement('div');
    progressWrap.style.cssText = 'width:100%;max-width:300px;';
    progressWrap.innerHTML = `
        <div style="display:flex;justify-content:space-between;font-size:11px;color:var(--text-3);font-weight:600;margin-bottom:6px;letter-spacing:0.5px;">
            <span>ТЕКУЩАЯ СУММА</span>
            <span id="cipher-sum-label">0 / ${targetSum}</span>
        </div>
        <div style="height:4px;background:var(--surface-3);border-radius:99px;overflow:hidden;">
            <div id="cipher-progress" style="height:100%;width:0%;background:linear-gradient(90deg,var(--primary),var(--cyan));border-radius:99px;transition:width 0.25s ease,background 0.2s;"></div>
        </div>
    `;
    viewport.appendChild(progressWrap);

    // ── Number grid ────────────────────────
    const grid = document.createElement('div');
    grid.className = 'cipher-grid';
    viewport.appendChild(grid);

    // ── Reset hint ─────────────────────────
    const hint = document.createElement('div');
    hint.style.cssText = 'font-size:11px;color:var(--text-3);letter-spacing:0.5px;min-height:16px;text-align:center;font-weight:500;';
    viewport.appendChild(hint);

    // ── Generate values ────────────────────
    const maxVal  = 5 + Math.floor(level / 2);
    const values  = Array.from({ length: cellsCount }, () => Math.floor(Math.random() * maxVal) + 2);

    // Guarantee solution exists: replace last value if needed
    let testSum = 0;
    const soln = [];
    for (const v of values) {
        if (testSum + v <= targetSum) { testSum += v; soln.push(v); }
    }
    if (testSum !== targetSum) {
        values[values.length - 1] = targetSum - testSum + (soln.length > 0 ? 0 : values[0]);
    }

    // Build cells
    for (let i = 0; i < cellsCount; i++) {
        const val  = values[i];
        const cell = document.createElement('div');
        cell.className = 'cipher-cell';
        cell.textContent = val;
        cell.dataset.val = val;
        cell.dataset.idx = i;

        cell.addEventListener('click', () => {
            if (selected.has(i)) {
                selected.delete(i);
                currentSum -= val;
                cell.classList.remove('selected');
            } else {
                selected.add(i);
                currentSum += val;
                cell.classList.add('selected');

                if (currentSum === targetSum) {
                    // Win!
                    grid.querySelectorAll('.cipher-cell').forEach(c => {
                        c.style.pointerEvents = 'none';
                        if (c.classList.contains('selected')) {
                            c.style.borderColor = 'var(--green)';
                            c.style.background  = 'rgba(52,211,153,0.2)';
                            c.style.color       = 'var(--green)';
                            c.style.boxShadow   = '0 0 12px var(--green-glow)';
                        }
                    });
                    hint.textContent = '✓ ШИФР ВЗЛОМАН';
                    hint.style.color = 'var(--green)';
                    updateProgress(currentSum, targetSum);
                    setTimeout(() => onWin(), 500);
                    return;
                }

                if (currentSum > targetSum) {
                    // Overshoot — reset
                    cell.classList.add('over-target');
                    setTimeout(() => cell.classList.remove('over-target'), 300);
                    if (navigator.vibrate) navigator.vibrate(60);
                    hint.textContent = '⚠️ Сумма превышена — сброс';
                    hint.style.color = 'var(--red)';
                    setTimeout(() => { hint.textContent = ''; hint.style.color = 'var(--text-3)'; }, 1200);
                    // deselect all
                    grid.querySelectorAll('.cipher-cell').forEach(c => c.classList.remove('selected'));
                    selected.clear();
                    currentSum = 0;
                    updateProgress(0, targetSum);
                    return;
                }
            }
            updateProgress(currentSum, targetSum);
        });

        grid.appendChild(cell);
    }

    function updateProgress(cur, target) {
        const pct = Math.min(100, Math.round((cur / target) * 100));
        const bar = document.getElementById('cipher-progress');
        const lbl = document.getElementById('cipher-sum-label');
        if (bar) {
            bar.style.width = pct + '%';
            bar.style.background = cur > target
                ? 'linear-gradient(90deg,var(--red),var(--red))'
                : cur === target
                ? 'linear-gradient(90deg,var(--green),var(--green))'
                : 'linear-gradient(90deg,var(--primary),var(--cyan))';
        }
        if (lbl) lbl.textContent = `${cur} / ${target}`;
    }
}

export function destroy() {}

EOF_SDVIG

echo "  ✦ $JAVA/model/PlayerProfile.java"
mkdir -p $(dirname "$JAVA/model/PlayerProfile.java")
cat > "$JAVA/model/PlayerProfile.java" << 'EOF_SDVIG'
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

EOF_SDVIG

echo "  ✦ $JAVA/controller/GameApiController.java"
mkdir -p $(dirname "$JAVA/controller/GameApiController.java")
cat > "$JAVA/controller/GameApiController.java" << 'EOF_SDVIG'
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

EOF_SDVIG


echo ""
echo "✅ Все файлы обновлены!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Теперь выполни:"
echo ""
echo "  git add -A"
echo "  git commit -m \"feat: modern UI/UX redesign 2026\""
echo "  git push"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
