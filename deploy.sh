#!/bin/bash
# ═══════════════════════════════════════════════════════════
#  СДВИГ · deploy.sh v3  — Кабинет Аналитика
#  Запускай из корня репозитория: bash deploy.sh
# ═══════════════════════════════════════════════════════════
set -e
S="src/main/resources/static"
J="src/main/java/com/example/sdvig"
echo ""
echo "📂 СДВИГ · Кабинет Аналитика — Применяем обновление v3…"
echo ""
echo "  ✦ $S/style.css"
mkdir -p $(dirname "$S/style.css")
cat > "$S/style.css" << 'SDVIG_EOF'
/* ═══════════════════════════════════════════════
   СДВИГ · Кабинет Аналитика
   Warm Linen · Bronze · Cormorant + DM Sans
═══════════════════════════════════════════════ */

@import url('https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&family=DM+Sans:ital,opsz,wght@0,9..40,400;0,9..40,500;0,9..600;0,9..40,700;1,9..40,400&family=Courier+Prime:wght@400;700&display=swap');

:root {
    /* ── Desk & Paper ── */
    --bg:       #e8e2d8;
    --bg-2:     #f0ebe1;
    --paper:    #fdfaf5;
    --paper-2:  #f8f4ed;
    --paper-3:  #f2ede4;

    /* ── Ink ── */
    --ink:      #1c1710;
    --ink-2:    #4a3f32;
    --ink-3:    #8a7d6a;
    --ink-4:    #c8bfb0;
    --ink-5:    #e0d9ce;

    /* ── Bronze accent ── */
    --br:       #a87030;
    --br-l:     #c49050;
    --br-d:     #7a5020;
    --br-dim:   rgba(168,112,48,.12);
    --br-glow:  rgba(168,112,48,.20);

    /* ── Semantic ── */
    --approve:  #2a6040;
    --approve-d: rgba(42,96,64,.12);
    --deny:     #8b2020;
    --deny-d:   rgba(139,32,32,.12);
    --blue:     #1e3a6a;
    --blue-d:   rgba(30,58,106,.10);

    /* ── Radius ── */
    --r-xs:     2px;
    --r-sm:     4px;
    --r:        8px;
    --r-lg:     12px;
    --r-xl:     16px;
    --r-2xl:    20px;

    /* ── Layout ── */
    --nav-h:    60px;
    --top-h:    52px;
    --xp-h:     4px;
    --safe-b:   env(safe-area-inset-bottom, 0px);
    --safe-t:   env(safe-area-inset-top, 0px);
}

/* ── Reset ────────────────────────────────────── */
*, *::before, *::after {
    box-sizing: border-box; margin: 0; padding: 0;
    -webkit-tap-highlight-color: transparent;
}
html, body { height: 100%; overflow: hidden; overscroll-behavior: none; }
body {
    font-family: 'DM Sans', -apple-system, sans-serif;
    background: var(--bg);
    color: var(--ink);
    font-size: 14px;
    line-height: 1.55;
    user-select: none;
    -webkit-user-select: none;
}
.hidden { display: none !important; }

/* ── Desk background texture ──────────────────── */
body::before {
    content: '';
    position: fixed; inset: 0; z-index: -1;
    background:
        radial-gradient(ellipse 80% 60% at 30% 20%, rgba(200,160,90,.06) 0%, transparent 70%),
        radial-gradient(ellipse 60% 80% at 75% 85%, rgba(160,120,60,.05) 0%, transparent 60%);
    pointer-events: none;
}

/* ── Screen system ───────────────────────────── */
.screen {
    position: fixed; inset: 0;
    display: flex; flex-direction: column;
    opacity: 0; pointer-events: none;
    transition: opacity .35s ease;
    padding-top: var(--safe-t);
}
.screen.active { opacity: 1; pointer-events: all; }

/* ── SPLASH ───────────────────────────────────── */
#splash-screen {
    background: var(--paper);
    justify-content: center; align-items: center; z-index: 9999;
}
.splash-wrap {
    display: flex; flex-direction: column; align-items: center;
    gap: 10px; padding: 32px; text-align: center;
}
.splash-mark {
    width: 72px; height: 72px; border-radius: 50%;
    border: 2px solid var(--br); display: flex;
    align-items: center; justify-content: center;
    margin-bottom: 8px;
    animation: markPulse 2s ease-in-out infinite;
}
@keyframes markPulse {
    0%,100% { box-shadow: 0 0 0 0 var(--br-dim); }
    50%      { box-shadow: 0 0 0 8px transparent; }
}
.splash-mark-inner {
    font-family: 'Cormorant Garamond', serif;
    font-size: 30px; font-weight: 600;
    color: var(--br); letter-spacing: 1px;
}
.splash-title {
    font-family: 'DM Sans', sans-serif;
    font-size: 28px; font-weight: 700;
    letter-spacing: 8px; color: var(--ink);
    animation: fadeUp .6s ease .2s both;
}
.splash-sub {
    font-size: 10px; letter-spacing: 4px;
    color: var(--ink-3); text-transform: uppercase;
    animation: fadeUp .6s ease .35s both;
}
@keyframes fadeUp {
    from { opacity: 0; transform: translateY(10px); }
    to   { opacity: 1; transform: none; }
}
.splash-progress-wrap {
    width: 180px; margin-top: 20px;
    display: flex; flex-direction: column; align-items: center; gap: 10px;
    animation: fadeUp .6s ease .5s both;
}
.splash-track {
    width: 100%; height: 2px;
    background: var(--ink-5); border-radius: 99px; overflow: hidden;
}
.splash-fill {
    height: 100%; background: var(--br);
    width: 0%; transition: width .5s ease; border-radius: 99px;
}
.splash-status {
    font-size: 11px; color: var(--ink-3);
    letter-spacing: 1px; text-transform: uppercase;
    font-family: 'Courier Prime', monospace;
}

/* ── LOGIN ────────────────────────────────────── */
#login-screen { background: var(--bg); justify-content: center; align-items: center; overflow-y: auto; }
.login-bg-pattern {
    position: absolute; inset: 0;
    background-image:
        linear-gradient(var(--ink-5) 1px, transparent 1px),
        linear-gradient(90deg, var(--ink-5) 1px, transparent 1px);
    background-size: 40px 40px;
    opacity: .35; pointer-events: none;
}
.login-container {
    position: relative; z-index: 1;
    width: 100%; max-width: 360px;
    padding: 24px 20px 32px;
    display: flex; flex-direction: column; align-items: center; gap: 24px;
}
.login-header { text-align: center; }
.login-badge {
    width: 56px; height: 56px; border-radius: 50%;
    border: 1.5px solid var(--br);
    display: flex; align-items: center; justify-content: center;
    margin: 0 auto 12px;
    font-family: 'Cormorant Garamond', serif;
    font-size: 24px; color: var(--br); font-weight: 600;
}
.login-h1 {
    font-family: 'DM Sans', sans-serif;
    font-size: 24px; font-weight: 700;
    letter-spacing: 5px; color: var(--ink); margin-bottom: 4px;
}
.login-tagline { font-size: 11px; letter-spacing: 2px; color: var(--ink-3); text-transform: uppercase; }
.login-card {
    width: 100%;
    background: var(--paper);
    border: 1px solid var(--ink-4);
    border-radius: var(--r-xl);
    padding: 22px 20px;
    display: flex; flex-direction: column; gap: 14px;
    box-shadow: 0 4px 24px rgba(0,0,0,.08), 0 1px 4px rgba(0,0,0,.05);
}
.login-card-label {
    font-size: 10px; letter-spacing: 3px; color: var(--br);
    font-weight: 700; text-transform: uppercase; text-align: center;
    font-family: 'Courier Prime', monospace;
}
.login-hint { font-size: 13px; color: var(--ink-2); text-align: center; }

/* Widget area */
.tg-widget-area {
    min-height: 52px; position: relative;
    display: flex; flex-direction: column; align-items: center; gap: 10px;
}
.tg-tip {
    font-size: 11px; color: var(--ink-3); text-align: center; line-height: 1.5;
    padding-top: 6px;
}
.tg-tip a { color: var(--br); }

.login-divider {
    display: flex; align-items: center; gap: 12px;
    font-size: 10px; letter-spacing: 2px; color: var(--ink-4); text-transform: uppercase;
}
.login-divider::before, .login-divider::after { content: ''; flex: 1; height: 1px; background: var(--ink-5); }
.login-footer { font-size: 12px; color: var(--ink-3); text-align: center; }
.login-footer a { color: var(--br); }

/* ── BUTTONS ──────────────────────────────────── */
.btn {
    display: block; width: 100%; padding: 12px;
    border: none; border-radius: var(--r);
    font-family: 'DM Sans', sans-serif;
    font-size: 13px; font-weight: 600;
    letter-spacing: .3px; cursor: pointer;
    text-align: center;
    transition: transform .1s ease, box-shadow .15s ease, opacity .15s;
}
.btn:active { transform: scale(.97); }
.btn-bronze {
    background: var(--br); color: #fff;
    box-shadow: 0 2px 12px var(--br-dim);
}
.btn-bronze:hover { background: var(--br-l); }
.btn-outline {
    background: transparent;
    border: 1px solid var(--ink-4);
    color: var(--ink-3); cursor: not-allowed;
}

/* ── TOPBAR ───────────────────────────────────── */
.topbar {
    height: var(--top-h); min-height: var(--top-h);
    display: flex; align-items: center; justify-content: space-between;
    padding: 0 14px;
    background: var(--paper);
    border-bottom: 1px solid var(--ink-5);
    flex-shrink: 0;
    box-shadow: 0 1px 8px rgba(0,0,0,.05);
}
.topbar-left { display: flex; align-items: center; gap: 8px; }
.topbar-emblem {
    width: 28px; height: 28px; border-radius: 50%;
    border: 1.5px solid var(--br);
    display: flex; align-items: center; justify-content: center;
    font-family: 'Cormorant Garamond', serif;
    font-size: 14px; font-weight: 600; color: var(--br);
}
.topbar-title {
    font-size: 14px; font-weight: 700;
    letter-spacing: 3px; color: var(--ink);
    font-family: 'DM Sans', sans-serif;
}
.topbar-stats { display: flex; gap: 6px; align-items: center; }
.stat-pill {
    display: flex; align-items: center; gap: 4px;
    padding: 4px 9px; border-radius: 99px;
    background: var(--paper-3);
    border: 1px solid var(--ink-5);
    font-size: 12px; font-weight: 600; color: var(--ink-2);
}
.stat-pill-icon { display: flex; align-items: center; }
.stat-pill-icon svg { width: 13px; height: 13px; }
#sp-energy { color: var(--br-d); border-color: var(--br-dim); }
#sp-credits { color: var(--blue); border-color: var(--blue-d); }
#sp-rank    { color: var(--br); border-color: var(--br-dim); }

/* ── XP BAR ───────────────────────────────────── */
.xp-band {
    height: 26px; display: flex; align-items: center;
    padding: 0 14px; gap: 8px;
    background: var(--paper-2);
    border-bottom: 1px solid var(--ink-5);
    flex-shrink: 0;
}
.xp-track { flex: 1; height: 3px; background: var(--ink-5); border-radius: 99px; overflow: hidden; }
.xp-fill {
    height: 100%; background: linear-gradient(90deg, var(--br-d), var(--br));
    transition: width .6s ease; border-radius: 99px;
}
.xp-info { font-size: 10px; color: var(--ink-3); white-space: nowrap; font-family: 'Courier Prime', monospace; }

/* ── TAB AREA ─────────────────────────────────── */
.tab-area { flex: 1; position: relative; overflow: hidden; }
.tab-pane {
    position: absolute; inset: 0;
    overflow-y: auto; overflow-x: hidden;
    -webkit-overflow-scrolling: touch;
    overscroll-behavior: contain;
    opacity: 0; pointer-events: none;
    transform: translateY(4px);
    transition: opacity .22s ease, transform .22s ease;
    padding-bottom: calc(var(--nav-h) + var(--safe-b) + 8px);
}
.tab-pane.active { opacity: 1; pointer-events: all; transform: none; }

/* ── CASES TAB ────────────────────────────────── */
.swipe-zone {
    position: absolute; inset: 0;
    display: flex; justify-content: center; align-items: center;
    overflow: hidden; padding: 16px;
}
.stack-card {
    position: absolute;
    width: calc(100% - 40px); max-width: 340px;
    background: var(--paper-3);
    border: 1px solid var(--ink-5);
    border-radius: var(--r-lg);
    pointer-events: none;
}
.sc3 { height: 160px; transform: translateY(14px) scale(.87) rotate(.8deg); opacity: .35; }
.sc2 { height: 180px; transform: translateY(7px) scale(.94) rotate(.4deg); opacity: .6; }
.sc1 { height: 200px; transform: translateY(3px) scale(.98) rotate(.1deg); opacity: .8; }

/* ── RESULT OVERLAY ─────────────────────────────── */
.result-overlay {
    position: absolute; inset: 10px;
    background: var(--paper);
    border: 1px solid var(--ink-4);
    border-radius: var(--r-xl);
    box-shadow: 0 8px 40px rgba(0,0,0,.12);
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    gap: 16px; padding: 24px; text-align: center;
    z-index: 50;
    animation: resultIn .28s ease;
}
@keyframes resultIn { from { opacity: 0; transform: scale(.93); } to { opacity: 1; transform: none; } }
.ro-stamp-text {
    font-family: 'DM Sans', sans-serif;
    font-size: 20px; font-weight: 800; letter-spacing: 4px;
    text-transform: uppercase;
    padding: 6px 16px;
    border: 2.5px solid;
    border-radius: var(--r-sm);
    transform: rotate(-6deg);
    display: inline-block;
}
.ro-stamp-text.approve { color: var(--approve); border-color: var(--approve); background: var(--approve-d); }
.ro-stamp-text.deny    { color: var(--deny);    border-color: var(--deny);    background: var(--deny-d); }
.ro-text { font-family: 'Cormorant Garamond', serif; font-size: 16px; line-height: 1.6; color: var(--ink-2); }
.ro-rewards { display: flex; gap: 8px; flex-wrap: wrap; justify-content: center; }
.ro-chip {
    padding: 5px 12px; border-radius: 99px;
    font-size: 13px; font-weight: 700;
}
.ro-xp  { background: var(--br-dim); border: 1px solid rgba(168,112,48,.3); color: var(--br-d); }
.ro-cr  { background: var(--blue-d); border: 1px solid rgba(30,58,106,.25); color: var(--blue); }
.ro-en  { background: var(--deny-d); border: 1px solid rgba(139,32,32,.25); color: var(--deny); }

/* ── GAMES TAB ────────────────────────────────── */
.pane-header { padding: 16px 14px 8px; }
.pane-title  {
    font-family: 'DM Sans', sans-serif;
    font-size: 13px; font-weight: 700; letter-spacing: 2px;
    text-transform: uppercase; color: var(--ink-2);
}
.pane-sub { font-size: 12px; color: var(--ink-3); margin-top: 3px; }
.game-list { display: flex; flex-direction: column; gap: 8px; padding: 4px 14px 14px; }
.game-row {
    display: flex; align-items: center; gap: 14px;
    background: var(--paper); border: 1px solid var(--ink-5);
    border-radius: var(--r-lg); padding: 14px 12px;
    cursor: pointer; position: relative; overflow: hidden;
    transition: transform .12s ease, box-shadow .15s ease, border-color .15s;
    box-shadow: 0 1px 4px rgba(0,0,0,.04);
}
.game-row:active { transform: scale(.97); box-shadow: 0 0 0 1px var(--ink-4); }
.gr-stripe { position: absolute; left: 0; top: 0; bottom: 0; width: 3px; border-radius: var(--r-lg) 0 0 var(--r-lg); }
.gr-s-v { background: #5c3d8a; }
.gr-s-b { background: var(--blue); }
.gr-s-a { background: var(--br-d); }
.gr-icon { font-size: 32px; flex-shrink: 0; line-height: 1; }
.gr-info { flex: 1; min-width: 0; }
.gr-name { font-size: 15px; font-weight: 700; color: var(--ink); font-family: 'DM Sans', sans-serif; }
.gr-desc { font-size: 11px; color: var(--ink-3); margin-top: 2px; letter-spacing: .3px; }
.gr-prog { display: flex; align-items: center; gap: 8px; margin-top: 8px; }
.gr-bar  { flex: 1; height: 2px; background: var(--ink-5); border-radius: 99px; overflow: hidden; }
.gr-fill { height: 100%; background: var(--br); border-radius: 99px; transition: width .5s ease; }
.gr-lvl  { font-size: 11px; color: var(--ink-3); font-weight: 600; white-space: nowrap; font-family: 'Courier Prime', monospace; }
.gr-arrow { font-size: 18px; color: var(--ink-4); flex-shrink: 0; line-height: 1; }
/* game viewport */
.gvp-wrap {
    position: absolute; inset: 0; background: var(--bg-2); z-index: 100;
    display: flex; flex-direction: column; animation: fadeUp .2s ease;
}
.gvp-bar {
    height: var(--top-h); display: flex; align-items: center;
    padding: 0 14px; gap: 10px;
    background: var(--paper); border-bottom: 1px solid var(--ink-5); flex-shrink: 0;
}
.back-btn {
    background: transparent; border: 1px solid var(--ink-4);
    color: var(--ink-2); padding: 6px 12px; border-radius: var(--r);
    font-family: 'DM Sans', sans-serif; font-size: 12px; font-weight: 600;
    cursor: pointer; transition: all .15s; letter-spacing: .5px;
    display: flex; align-items: center; gap: 6px;
}
.back-btn:active { background: var(--paper-3); transform: scale(.96); }
.back-btn svg { width: 14px; height: 14px; }
.gvp-title { font-size: 13px; font-weight: 700; color: var(--ink); flex: 1; text-align: center; letter-spacing: 1px; }
.win-badge {
    padding: 4px 10px; background: var(--approve-d); border: 1px solid var(--approve);
    border-radius: 99px; font-size: 11px; font-weight: 700; color: var(--approve);
    animation: resultIn .35s ease;
}
.game-vp {
    flex: 1; overflow-y: auto; overflow-x: hidden;
    display: flex; flex-direction: column; align-items: center;
    padding: 14px; -webkit-overflow-scrolling: touch;
    overscroll-behavior: contain; background: var(--bg-2);
}

/* ── PROFILE TAB ──────────────────────────────── */
.profile-hero {
    display: flex; align-items: center; gap: 14px;
    padding: 18px 14px;
    background: var(--paper);
    border-bottom: 1px solid var(--ink-5);
    box-shadow: 0 1px 4px rgba(0,0,0,.04);
}
.profile-av {
    width: 58px; height: 58px; border-radius: 50%; flex-shrink: 0;
    background: var(--br-dim);
    border: 1.5px solid var(--br);
    display: flex; align-items: center; justify-content: center;
    font-family: 'DM Sans', sans-serif;
    font-size: 24px; font-weight: 700; color: var(--br-d);
}
.profile-info { flex: 1; min-width: 0; }
.profile-name  { font-size: 20px; font-weight: 700; color: var(--ink); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
.profile-arch  { font-size: 13px; color: var(--br); font-weight: 600; margin-top: 2px; }
.profile-id    { font-size: 11px; color: var(--ink-3); margin-top: 2px; font-family: 'Courier Prime', monospace; }
.stats-row {
    display: grid; grid-template-columns: repeat(4,1fr);
    gap: 1px; background: var(--ink-5);
    margin: 14px; border-radius: var(--r); overflow: hidden;
}
.sg {
    background: var(--paper);
    padding: 12px 8px;
    display: flex; flex-direction: column; align-items: center; gap: 4px;
}
.sg-val { font-size: 20px; font-weight: 700; color: var(--ink); line-height: 1; font-family: 'Cormorant Garamond', serif; }
.sg-lbl { font-size: 9px; letter-spacing: 1.5px; color: var(--ink-3); text-transform: uppercase; font-weight: 600; }
/* skills */
.skill-list { display: flex; flex-direction: column; gap: 8px; padding: 4px 14px 14px; }
.skill-row {
    display: flex; align-items: center; gap: 12px;
    background: var(--paper); border: 1px solid var(--ink-5);
    border-radius: var(--r-lg); padding: 13px;
    box-shadow: 0 1px 3px rgba(0,0,0,.04);
}
.sk-icon { font-size: 26px; flex-shrink: 0; }
.sk-body { flex: 1; min-width: 0; }
.sk-name { font-size: 14px; font-weight: 700; color: var(--ink); }
.sk-desc { font-size: 11px; color: var(--ink-3); margin-top: 2px; }
.sk-bar  { height: 2px; background: var(--ink-5); border-radius: 99px; overflow: hidden; margin-top: 8px; }
.sk-fill { height: 100%; background: var(--br); border-radius: 99px; transition: width .5s ease; }
.sk-side { display: flex; flex-direction: column; align-items: flex-end; gap: 6px; flex-shrink: 0; }
.sk-lv   { font-size: 12px; font-weight: 700; color: var(--br); font-family: 'Courier Prime', monospace; }
.up-btn  {
    background: var(--br); border: none; border-radius: var(--r);
    padding: 7px 11px; font-family: 'DM Sans', sans-serif;
    font-size: 12px; font-weight: 600; color: #fff;
    cursor: pointer; transition: transform .1s, background .15s; white-space: nowrap;
    box-shadow: 0 2px 8px var(--br-dim);
}
.up-btn:active { transform: scale(.93); background: var(--br-l); }
/* achievements */
.ach-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: 8px; padding: 4px 14px 14px; }
.ach-badge {
    display: flex; flex-direction: column; align-items: center;
    gap: 4px; background: var(--paper); border: 1px solid var(--ink-5);
    border-radius: var(--r); padding: 10px 4px; text-align: center;
    transition: border-color .2s;
}
.ach-badge.earned { border-color: rgba(168,112,48,.4); }
.ach-badge.locked { opacity: .35; }
.ach-icon { font-size: 22px; line-height: 1; }
.ach-lbl  { font-size: 9px; color: var(--ink-3); font-weight: 600; letter-spacing: .3px; line-height: 1.3; }

/* ── SHOP TAB ─────────────────────────────────── */
.shop-grid {
    display: grid; grid-template-columns: repeat(2,1fr);
    gap: 10px; padding: 4px 14px 14px;
}
.shop-item {
    background: var(--paper); border: 1px solid var(--ink-5);
    border-radius: var(--r-lg); padding: 16px 12px;
    display: flex; flex-direction: column; align-items: center;
    gap: 7px; cursor: pointer; text-align: center;
    transition: transform .12s, border-color .15s, box-shadow .15s;
    box-shadow: 0 1px 4px rgba(0,0,0,.04);
}
.shop-item:not(.shop-locked):active { transform: scale(.95); border-color: var(--br); box-shadow: 0 2px 12px var(--br-dim); }
.shop-locked { opacity: .4; cursor: not-allowed; }
.si-icon  { font-size: 32px; }
.si-name  { font-size: 13px; font-weight: 700; color: var(--ink); }
.si-desc  { font-size: 11px; color: var(--ink-3); line-height: 1.4; }
.si-price {
    padding: 5px 12px; border-radius: 99px; font-size: 12px; font-weight: 700;
    background: var(--br-dim); border: 1px solid rgba(168,112,48,.3); color: var(--br-d); margin-top: 2px;
}
.si-soon  { background: var(--paper-3); border-color: var(--ink-5); color: var(--ink-3); font-size: 10px; letter-spacing: 1px; }
.cant-afford .si-price { background: var(--deny-d); border-color: rgba(139,32,32,.25); color: var(--deny); }

/* ── BOTTOM NAV ───────────────────────────────── */
.bottom-nav {
    height: calc(var(--nav-h) + var(--safe-b));
    padding-bottom: var(--safe-b);
    display: flex;
    background: var(--paper);
    border-top: 1px solid var(--ink-5);
    box-shadow: 0 -2px 12px rgba(0,0,0,.06);
    flex-shrink: 0; position: relative; z-index: 20;
}
.nb {
    flex: 1; display: flex; flex-direction: column; align-items: center;
    justify-content: center; gap: 4px;
    background: transparent; border: none; cursor: pointer;
    padding: 8px 4px; position: relative; transition: transform .1s;
}
.nb:active { transform: scale(.9); }
.nb-icon { display: flex; align-items: center; justify-content: center; transition: transform .2s; }
.nb-icon svg { width: 22px; height: 22px; stroke: var(--ink-3); transition: stroke .2s; }
.nb-lbl { font-size: 9px; letter-spacing: 1.5px; color: var(--ink-4); font-weight: 700; text-transform: uppercase; transition: color .2s; font-family: 'DM Sans', sans-serif; }
.nb::after {
    content: ''; position: absolute; bottom: calc(var(--safe-b) + 5px);
    width: 18px; height: 2px; border-radius: 99px;
    background: var(--br); opacity: 0; transition: opacity .2s;
}
.nb.active .nb-icon svg { stroke: var(--br); transform: translateY(-1px); }
.nb.active .nb-lbl      { color: var(--br); }
.nb.active::after       { opacity: 1; }
.nb-badge {
    position: absolute; top: 6px; right: calc(50% - 20px);
    width: 14px; height: 14px; border-radius: 50%;
    background: var(--deny); color: #fff;
    font-size: 9px; font-weight: 800;
    display: flex; align-items: center; justify-content: center;
    border: 1.5px solid var(--paper);
}

/* ── TOAST ────────────────────────────────────── */
.toast {
    position: fixed;
    bottom: calc(var(--nav-h) + var(--safe-b) + 12px);
    left: 12px; right: 12px;
    background: var(--paper);
    border: 1px solid var(--ink-4);
    border-radius: var(--r-xl); padding: 12px 14px;
    display: flex; align-items: center; gap: 12px;
    z-index: 800; box-shadow: 0 8px 28px rgba(0,0,0,.12);
    animation: toastIn .28s ease;
}
.toast.out { animation: toastOut .28s ease forwards; }
@keyframes toastIn  { from { transform: translateY(14px); opacity: 0; } to { opacity: 1; transform: none; } }
@keyframes toastOut { from { opacity: 1; } to { transform: translateY(14px); opacity: 0; } }
.toast-icon  { font-size: 24px; flex-shrink: 0; }
.toast-title { font-size: 10px; letter-spacing: 2px; font-weight: 800; color: var(--br); text-transform: uppercase; font-family: 'DM Sans', sans-serif; }
.toast-desc  { font-size: 13px; color: var(--ink); margin-top: 2px; font-weight: 500; }

/* ── DAILY MODAL ──────────────────────────────── */
.modal-bg {
    position: fixed; inset: 0;
    background: rgba(0,0,0,.35); backdrop-filter: blur(4px); -webkit-backdrop-filter: blur(4px);
    display: flex; align-items: center; justify-content: center;
    z-index: 700; padding: 20px;
    animation: fadeIn .2s ease;
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.daily-card {
    background: var(--paper);
    border: 1px solid var(--ink-4);
    border-radius: var(--r-2xl); padding: 28px 22px;
    display: flex; flex-direction: column; align-items: center;
    gap: 14px; text-align: center;
    width: 100%; max-width: 320px;
    box-shadow: 0 16px 48px rgba(0,0,0,.15);
    animation: resultIn .35s ease;
}
.daily-icon  { font-size: 50px; }
.daily-h     { font-size: 16px; font-weight: 700; color: var(--ink); letter-spacing: .5px; }
.daily-streak { font-size: 13px; color: var(--ink-2); }
.daily-week  { display: flex; gap: 6px; justify-content: center; }
.dw-dot {
    width: 26px; height: 26px; border-radius: 50%;
    display: flex; align-items: center; justify-content: center;
    font-size: 10px; font-weight: 700;
    border: 1px solid var(--ink-5); color: var(--ink-3);
    background: var(--paper-3); font-family: 'Courier Prime', monospace;
}
.dw-dot.done  { background: var(--br-dim); border-color: var(--br); color: var(--br-d); }
.dw-dot.today { background: var(--br); border-color: var(--br-l); color: #fff; }
.daily-chips { display: flex; gap: 10px; }
.dc-chip {
    padding: 7px 16px; border-radius: 99px; font-size: 13px; font-weight: 700;
    background: var(--paper-3); border: 1px solid var(--ink-5); color: var(--ink);
}

/* ── HINT GAME MODAL (bottom sheet) ───────────── */
.hint-modal {
    position: fixed; inset: 0; top: auto;
    height: 80vh;
    background: var(--bg-2);
    border-top: 1px solid var(--ink-4);
    border-radius: 14px 14px 0 0;
    box-shadow: 0 -6px 32px rgba(0,0,0,.14);
    z-index: 300;
    display: flex; flex-direction: column;
    animation: slideUp .3s ease-out;
}
@keyframes slideUp { from { transform: translateY(100%); } to { transform: none; } }
.hint-modal.closing { animation: slideDown .25s ease-in forwards; }
@keyframes slideDown { from { transform: none; } to { transform: translateY(100%); } }
.hm-header {
    display: flex; align-items: center; justify-content: space-between;
    padding: 14px 16px;
    background: var(--paper); border-bottom: 1px solid var(--ink-5);
    flex-shrink: 0; border-radius: 14px 14px 0 0;
}
.hm-title {
    display: flex; align-items: center; gap: 8px;
    font-size: 13px; font-weight: 700; color: var(--ink); letter-spacing: .5px;
}
.hm-title svg { width: 16px; height: 16px; stroke: var(--br); flex-shrink: 0; }
.hm-close {
    background: transparent; border: 1px solid var(--ink-5);
    border-radius: var(--r); padding: 5px 10px;
    font-family: 'DM Sans', sans-serif; font-size: 11px;
    font-weight: 600; color: var(--ink-3); cursor: pointer;
    transition: all .15s;
}
.hm-close:active { background: var(--paper-3); }
.hm-vp {
    flex: 1; overflow-y: auto; overflow-x: hidden;
    padding: 14px; -webkit-overflow-scrolling: touch;
    overscroll-behavior: contain;
}
.hm-footer {
    padding: 10px 16px;
    background: var(--paper); border-top: 1px solid var(--ink-5); flex-shrink: 0;
}
.hm-footer-text { font-size: 12px; color: var(--ink-3); text-align: center; }

/* ── ERROR ────────────────────────────────────── */
#error-screen { justify-content: center; align-items: center; z-index: 9998; }
.err-center { display: flex; flex-direction: column; align-items: center; gap: 14px; padding: 32px; text-align: center; max-width: 290px; }
.err-icon  { font-size: 44px; }
.err-title { font-size: 16px; font-weight: 700; color: var(--deny); font-family: 'DM Sans', sans-serif; }
.err-msg   { font-size: 14px; color: var(--ink-2); line-height: 1.6; }

/* ── ANIMATIONS ───────────────────────────────── */
@keyframes fadeUp { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: none; } }
@keyframes popIn  { from { opacity: 0; transform: scale(.88); } to { opacity: 1; transform: none; } }

/* ── GAME-SPECIFIC ────────────────────────────── */
.doc-track {
    width: 100%; max-width: 340px; height: 72px;
    background: var(--paper); border: 1px solid var(--ink-4);
    border-radius: var(--r); position: relative; overflow: hidden;
    cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,.06);
}
.doc-target {
    position: absolute; top: 0; bottom: 0;
    background: var(--approve-d);
    border-left: 2px solid var(--approve); border-right: 2px solid var(--approve);
}
.doc-pin {
    position: absolute; top: 8px; bottom: 8px; width: 3px;
    background: var(--deny); border-radius: 99px;
    box-shadow: 0 0 6px rgba(139,32,32,.4);
    transform: translateX(-50%);
}
.doc-shake { animation: docSh .22s ease; }
@keyframes docSh { 0%,100%{transform:none} 25%{transform:translateX(-5px)} 75%{transform:translateX(5px)} }

.cipher-cell {
    width: 62px; height: 62px;
    background: var(--paper); border: 1.5px solid var(--ink-4);
    border-radius: var(--r); display: flex; align-items: center; justify-content: center;
    font-family: 'Cormorant Garamond', serif;
    font-size: 26px; font-weight: 600; color: var(--ink);
    cursor: pointer; transition: transform .1s, border-color .15s, background .15s;
    box-shadow: 0 1px 4px rgba(0,0,0,.06);
}
.cipher-cell:active { transform: scale(.93); }
.cipher-cell.sel {
    background: var(--br-dim); border-color: var(--br);
    color: var(--br-d); transform: scale(1.05);
}
.cipher-cell.over { animation: docSh .22s ease; border-color: var(--deny); background: var(--deny-d); }

/* ── SCROLLBAR ────────────────────────────────── */
::-webkit-scrollbar { width: 3px; }
::-webkit-scrollbar-track { background: transparent; }
::-webkit-scrollbar-thumb { background: var(--ink-5); border-radius: 99px; }

SDVIG_EOF

echo "  ✦ $S/card-design.css"
mkdir -p $(dirname "$S/card-design.css")
cat > "$S/card-design.css" << 'SDVIG_EOF'
/* ═══════════════════════════════════════════════
   СДВИГ · Card Design System
   Physical paper · Rubber stamps · Type variants
═══════════════════════════════════════════════ */

/* ── Card type color tokens ──────────────────── */
.case-card { --ct: #a87030; --ct-bg: rgba(168,112,48,.08); }

.ct-crime        { --ct: #8b2020; --ct-bg: rgba(139,32,32,.07); }
.ct-evidence     { --ct: #7a5020; --ct-bg: rgba(122,80,32,.07); }
.ct-suspect      { --ct: #1e3a6a; --ct-bg: rgba(30,58,106,.07); }
.ct-witness      { --ct: #2a6040; --ct-bg: rgba(42,96,64,.07); }
.ct-testimony    { --ct: #3d4a5c; --ct-bg: rgba(61,74,92,.06); }
.ct-mystery      { --ct: #4a2d6a; --ct-bg: rgba(74,45,106,.07); }
.ct-action       { --ct: #6a3010; --ct-bg: rgba(106,48,16,.08); }
.ct-revelation   { --ct: #7a5c20; --ct-bg: rgba(122,92,32,.07); }
.ct-briefing     { --ct: #2d3d4a; --ct-bg: rgba(45,61,74,.06); }
.ct-ending       { --ct: #6a5010; --ct-bg: rgba(106,80,16,.06); }
.ct-ending_bad   { --ct: #3d3530; --ct-bg: rgba(61,53,48,.05); }
.ct-ending_partial { --ct: #2d5a4a; --ct-bg: rgba(45,90,74,.06); }

/* ── Main case card ───────────────────────────── */
.case-card {
    position: absolute;
    width: calc(100% - 28px);
    max-width: 360px;
    min-height: 380px;

    /* Paper surface */
    background-color: var(--paper);
    background-image:
        /* Subtle horizontal ruling like writing paper */
        repeating-linear-gradient(
            180deg,
            transparent 0px, transparent 23px,
            rgba(0,0,0,.022) 23px, rgba(0,0,0,.022) 24px
        );

    /* Physical paper borders */
    border: 1px solid var(--ink-5);
    border-top: 3px solid var(--ct);
    border-radius: 0 0 var(--r-lg) var(--r-lg);

    /* Paper shadow — resting on desk */
    box-shadow:
        0 1px 2px rgba(0,0,0,.06),
        0 4px 12px rgba(0,0,0,.08),
        0 20px 50px rgba(0,0,0,.10),
        3px 0 6px rgba(0,0,0,.03);

    display: flex;
    flex-direction: column;
    padding: 0;
    cursor: grab;
    touch-action: none;
    transform-origin: 50% 100%;
    will-change: transform;
    z-index: 10;

    /* Slight random lean — physical papers don't sit perfectly straight */
    transform: rotate(-0.4deg);

    transition: box-shadow .25s ease;
}
.case-card:active { cursor: grabbing; }

/* Drag state borders */
.case-card.tilt-left  { border-top-color: var(--deny);    box-shadow: 0 4px 16px rgba(0,0,0,.10), 0 20px 50px rgba(0,0,0,.10), -8px 4px 24px rgba(139,32,32,.12); }
.case-card.tilt-right { border-top-color: var(--approve); box-shadow: 0 4px 16px rgba(0,0,0,.10), 0 20px 50px rgba(0,0,0,.10),  8px 4px 24px rgba(42,96,64,.12); }

/* Card entry animation */
.case-card.entering {
    animation: cardLand .45s cubic-bezier(.2,.8,.3,1) forwards;
}
@keyframes cardLand {
    from {
        opacity: 0;
        transform: translateY(-24px) rotate(-1.5deg) scale(.97);
        box-shadow: 0 20px 60px rgba(0,0,0,.15);
    }
    to {
        opacity: 1;
        transform: rotate(-0.4deg);
        box-shadow: 0 1px 2px rgba(0,0,0,.06), 0 4px 12px rgba(0,0,0,.08), 0 20px 50px rgba(0,0,0,.10);
    }
}

/* ── "СЕКРЕТНО" watermark ─────────────────────── */
.case-card::before {
    content: 'СЕКРЕТНО';
    position: absolute;
    top: 50%; left: 50%;
    transform: translate(-50%,-50%) rotate(-28deg);
    font-family: 'DM Sans', sans-serif;
    font-size: 46px; font-weight: 800; letter-spacing: 6px;
    color: rgba(168,112,48,.055);
    pointer-events: none;
    white-space: nowrap;
    text-transform: uppercase;
    z-index: 0;
    user-select: none;
}

/* ── Stamps ───────────────────────────────────── */
.stamp-wrap {
    position: absolute; inset: 0; border-radius: inherit;
    display: flex; align-items: center; justify-content: center;
    pointer-events: none; z-index: 30;
    transition: opacity .12s ease;
}
.stamp-left  { align-items: center; padding-right: 50px; }
.stamp-right { align-items: center; padding-left: 50px; }

.stamp {
    font-family: 'DM Sans', sans-serif;
    font-size: 20px;
    font-weight: 800;
    letter-spacing: 4px;
    text-transform: uppercase;
    padding: 7px 16px;
    border: 3px solid;
    border-radius: var(--r-xs);
    /* SVG filter for ink imperfection feel */
    filter: url(#ink-rough);
}
.stamp-approve-text {
    color: var(--approve);
    border-color: var(--approve);
    background: var(--approve-d);
    transform: rotate(-11deg);
}
.stamp-deny-text {
    color: var(--deny);
    border-color: var(--deny);
    background: var(--deny-d);
    transform: rotate(9deg);
}

/* Stamp landing animation */
@keyframes stampLand {
    0%  { transform: scale(1.8) rotate(-25deg); opacity: 0; }
    55% { transform: scale(.97) rotate(-11deg); opacity: 1; }
    70% { transform: scale(1.03) rotate(-12deg); }
    100%{ transform: scale(1) rotate(-11deg); opacity: 1; }
}
.stamp-approve-text.landing {
    animation: stampLand .38s cubic-bezier(.2,.8,.3,1) forwards;
}
@keyframes stampLandDeny {
    0%  { transform: scale(1.8) rotate(22deg); opacity: 0; }
    55% { transform: scale(.97) rotate(9deg); opacity: 1; }
    70% { transform: scale(1.03) rotate(10deg); }
    100%{ transform: scale(1) rotate(9deg); opacity: 1; }
}
.stamp-deny-text.landing {
    animation: stampLandDeny .38s cubic-bezier(.2,.8,.3,1) forwards;
}

/* ── Card internal layout ─────────────────────── */
.card-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 14px 0;
    position: relative; z-index: 1;
}
.card-act {
    font-family: 'Courier Prime', monospace;
    font-size: 10px; letter-spacing: 2px;
    color: var(--ct); font-weight: 700; text-transform: uppercase;
}
.card-type-badge {
    font-family: 'DM Sans', sans-serif;
    font-size: 10px; letter-spacing: 1.5px; font-weight: 700;
    text-transform: uppercase;
    padding: 2px 8px;
    border: 1px solid var(--ct);
    border-radius: 2px;
    color: var(--ct);
    background: var(--ct-bg);
}
.card-num {
    font-family: 'Courier Prime', monospace;
    font-size: 11px; color: var(--ink-3); letter-spacing: 1px;
}

/* Accent divider under head */
.card-divider {
    height: 1px;
    background: linear-gradient(90deg, transparent, var(--ink-5) 20%, var(--ink-5) 80%, transparent);
    margin: 10px 14px 0;
}

.card-body {
    flex: 1; display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    gap: 12px; padding: 16px 16px 8px;
    position: relative; z-index: 1;
}
.card-case-title {
    font-family: 'Cormorant Garamond', serif;
    font-size: 17px; font-weight: 600; color: var(--ink);
    text-align: center; letter-spacing: .3px;
    font-style: italic;
}
.card-icon-wrap {
    width: 64px; height: 64px;
    display: flex; align-items: center; justify-content: center;
    background: var(--ct-bg);
    border: 1px solid rgba(168,112,48,.15);
    border-radius: var(--r);
}
.card-icon-wrap .card-emoji {
    font-size: 32px; line-height: 1;
    animation: iconIdle 4s ease-in-out infinite;
}
@keyframes iconIdle {
    0%,100% { transform: none; }
    50%      { transform: translateY(-2px); }
}
.card-text {
    font-family: 'Cormorant Garamond', serif;
    font-size: 16px; line-height: 1.7; text-align: center;
    color: var(--ink-2); font-weight: 400;
    position: relative; z-index: 1;
}

/* ── Hint + Actions area ──────────────────────── */
.card-actions-area {
    padding: 10px 14px 14px;
    display: flex; flex-direction: column; gap: 10px;
    position: relative; z-index: 1;
}

/* Hint locked state */
.hint-locked-panel {
    background: var(--paper-3);
    border: 1px dashed var(--ink-4);
    border-radius: var(--r-lg);
    padding: 12px;
    display: flex; align-items: center; gap: 12px;
}
.hlp-icon { display: flex; align-items: center; flex-shrink: 0; }
.hlp-icon svg { width: 20px; height: 20px; stroke: var(--ink-3); }
.hlp-body { flex: 1; }
.hlp-title { font-size: 12px; font-weight: 700; color: var(--ink-2); letter-spacing: .3px; }
.hlp-sub   { font-size: 11px; color: var(--ink-3); margin-top: 2px; }
.hlp-btn {
    background: var(--br); border: none; border-radius: var(--r);
    padding: 7px 12px;
    font-family: 'DM Sans', sans-serif;
    font-size: 12px; font-weight: 600; color: #fff;
    cursor: pointer; transition: transform .1s, background .15s; white-space: nowrap;
    box-shadow: 0 2px 8px var(--br-dim);
    flex-shrink: 0;
}
.hlp-btn:active { transform: scale(.93); background: var(--br-l); }

/* Hint revealed state */
.hint-revealed-panel {
    background: #fef9ee;
    border: 1px solid rgba(168,112,48,.35);
    border-left: 3px solid var(--br);
    border-radius: var(--r);
    padding: 10px 12px;
    display: flex; gap: 10px; align-items: flex-start;
    animation: hintReveal .35s ease;
}
@keyframes hintReveal {
    from { opacity: 0; transform: translateY(-8px); max-height: 0; }
    to   { opacity: 1; transform: none; max-height: 200px; }
}
.hrp-icon { font-size: 16px; flex-shrink: 0; margin-top: 1px; }
.hrp-text {
    font-family: 'Cormorant Garamond', serif;
    font-size: 14px; line-height: 1.6; color: var(--ink-2);
    font-style: italic;
}

/* Action buttons row */
.action-row {
    display: flex; gap: 8px;
}
.action-btn {
    flex: 1; display: flex; align-items: center; justify-content: center;
    gap: 6px; padding: 11px 10px;
    border: 1.5px solid; border-radius: var(--r-lg);
    font-family: 'DM Sans', sans-serif;
    font-size: 12px; font-weight: 700;
    letter-spacing: .5px; text-transform: uppercase;
    cursor: pointer; transition: transform .1s, box-shadow .15s;
    position: relative; background: var(--paper);
}
.action-btn:active { transform: scale(.95); }
.action-btn svg { width: 16px; height: 16px; flex-shrink: 0; }

.action-deny {
    border-color: rgba(139,32,32,.35);
    color: var(--deny);
}
.action-deny:active { box-shadow: 0 2px 12px rgba(139,32,32,.15); background: var(--deny-d); }

.action-approve {
    border-color: rgba(42,96,64,.35);
    color: var(--approve);
}
.action-approve:active { box-shadow: 0 2px 12px rgba(42,96,64,.15); background: var(--approve-d); }

/* Cost chip on paid actions */
.cost-chip {
    position: absolute; top: -8px; right: -2px;
    background: var(--br); color: #fff;
    font-size: 9px; font-weight: 800;
    padding: 2px 5px; border-radius: 99px;
    font-family: 'DM Sans', sans-serif; letter-spacing: .5px;
    box-shadow: 0 1px 4px var(--br-dim);
}

/* Free badge after hint unlocked */
.free-chip {
    position: absolute; top: -8px; right: -2px;
    background: var(--approve); color: #fff;
    font-size: 9px; font-weight: 800;
    padding: 2px 5px; border-radius: 99px;
    font-family: 'DM Sans', sans-serif; letter-spacing: .5px;
}

/* SVG filter for stamp ink rough effect */
.svg-filters {
    position: absolute; width: 0; height: 0; overflow: hidden;
}

/* ── Card entry from top (new card appears) ─────── */
.case-card.slide-in {
    animation: cardIn .38s cubic-bezier(.2,.8,.3,1) forwards;
}
@keyframes cardIn {
    from { opacity: 0; transform: translateY(-20px) rotate(-1deg) scale(.96); }
    to   { opacity: 1; transform: rotate(-0.4deg); }
}

SDVIG_EOF

echo "  ✦ $S/icons.js"
mkdir -p $(dirname "$S/icons.js")
cat > "$S/icons.js" << 'SDVIG_EOF'
/* ═══════════════════════════════════════════
   СДВИГ · Icon Library
   24×24, 1.75px stroke, rounded caps
═══════════════════════════════════════════ */

const ICONS = {

    // ── Navigation ──────────────────────────
    folder: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>
  <line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="16" x2="12" y2="16"/>
</svg>`,

    gamepad: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <rect x="2" y="7" width="20" height="11" rx="5.5"/>
  <path d="M14.5 12h3M16 10.5v3"/>
  <circle cx="7.5" cy="12" r=".8" fill="currentColor" stroke="none"/>
  <circle cx="10" cy="12" r=".8" fill="currentColor" stroke="none"/>
</svg>`,

    badge: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 2L3.5 6.5v5.5C3.5 17.4 7.2 22 12 22s8.5-4.6 8.5-10V6.5z"/>
  <circle cx="12" cy="11" r="2.5"/>
  <path d="M9 17c.5-1.7 1.8-2.5 3-2.5s2.5 1 3 2.5"/>
</svg>`,

    bag: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"/>
  <line x1="3" y1="6" x2="21" y2="6"/>
  <path d="M16 10a4 4 0 0 1-8 0"/>
</svg>`,

    // ── Stats ────────────────────────────────
    bolt: `<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M13 2L4.5 13H10L9.5 22L19.5 11H14L13 2Z" stroke="none"/>
</svg>`,

    diamond: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M6 3h12l4 6-10 12L2 9z"/>
  <path d="M2 9h20M10.5 3l1.5 6 1.5-6M14 15l-2-6-2 6"/>
</svg>`,

    shield: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
  <path d="M9 12l2 2 4-4" stroke-width="1.75"/>
</svg>`,

    // ── Actions ──────────────────────────────
    checkCircle: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <path d="M8 12l3 3 5-5"/>
</svg>`,

    xCircle: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="12" cy="12" r="9"/>
  <path d="M9 9l6 6M15 9l-6 6"/>
</svg>`,

    arrowLeft: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M19 12H5M12 5l-7 7 7 7"/>
</svg>`,

    // ── Hint system ──────────────────────────
    lightbulb: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M9 21h6M12 3a6 6 0 0 1 6 6c0 2.3-1.2 4.3-3 5.4V17H9v-2.6C7.2 13.3 6 11.3 6 9a6 6 0 0 1 6-6z"/>
  <line x1="10" y1="20" x2="14" y2="20"/>
</svg>`,

    lock: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <rect x="5" y="11" width="14" height="10" rx="2"/>
  <path d="M8 11V7a4 4 0 0 1 8 0v4"/>
  <circle cx="12" cy="16" r="1.5" fill="currentColor" stroke="none"/>
</svg>`,

    lockOpen: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <rect x="5" y="11" width="14" height="10" rx="2"/>
  <path d="M8 11V7a4 4 0 0 1 7.4-1.4"/>
  <circle cx="12" cy="16" r="1.5" fill="currentColor" stroke="none"/>
</svg>`,

    // ── Misc ─────────────────────────────────
    star: `<svg viewBox="0 0 24 24" fill="currentColor">
  <path d="M12 2l3.1 6.3L22 9.3l-5 4.9 1.2 6.9-6.2-3.3-6.2 3.3L7 14.2 2 9.3l6.9-1z" stroke="none"/>
</svg>`,

    gift: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="20 12 20 22 4 22 4 12"/>
  <rect x="2" y="7" width="20" height="5"/>
  <line x1="12" y1="22" x2="12" y2="7"/>
  <path d="M12 7H7.5a2.5 2.5 0 0 1 0-5C11 2 12 7 12 7z"/>
  <path d="M12 7h4.5a2.5 2.5 0 0 0 0-5C13 2 12 7 12 7z"/>
</svg>`,

    coffee: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M18 8h1a4 4 0 0 1 0 8h-1"/>
  <path d="M2 8h16v9a4 4 0 0 1-4 4H6a4 4 0 0 1-4-4V8z"/>
  <line x1="6" y1="1" x2="6" y2="4"/><line x1="10" y1="1" x2="10" y2="4"/><line x1="14" y1="1" x2="14" y2="4"/>
</svg>`,

    x: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
  <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
</svg>`,

    check: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="20 6 9 17 4 12"/>
</svg>`,

    user: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
  <circle cx="12" cy="7" r="4"/>
</svg>`,

    search: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.75" stroke-linecap="round" stroke-linejoin="round">
  <circle cx="11" cy="11" r="8"/>
  <line x1="21" y1="21" x2="16.65" y2="16.65"/>
</svg>`,

    chevronRight: `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
  <polyline points="9 18 15 12 9 6"/>
</svg>`,
};

// Helper: inject SVG into element
function setIcon(el, name, cls) {
    if (!el || !ICONS[name]) return;
    el.innerHTML = ICONS[name];
    if (cls) el.querySelector('svg')?.classList.add(cls);
}

// Helper: SVG string with optional class
function icon(name, cls) {
    if (!ICONS[name]) return '';
    const tmp = document.createElement('div');
    tmp.innerHTML = ICONS[name];
    const svg = tmp.querySelector('svg');
    if (svg && cls) svg.classList.add(cls);
    return tmp.innerHTML;
}

SDVIG_EOF

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
    <meta name="apple-mobile-web-app-status-bar-style" content="default">
    <meta name="theme-color" content="#e8e2d8">
    <title>СДВИГ</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,400;0,500;0,600;1,400;1,500&family=DM+Sans:opsz,wght@9..40,400;9..40,500;9..40,600;9..40,700&family=Courier+Prime:wght@400;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="card-design.css">

    <!-- SVG filters for stamp ink effect -->
    <svg class="svg-filters" xmlns="http://www.w3.org/2000/svg">
        <defs>
            <filter id="ink-rough">
                <feTurbulence type="fractalNoise" baseFrequency="0.04" numOctaves="4" seed="2"/>
                <feDisplacementMap in="SourceGraphic" scale="1.2"/>
            </filter>
        </defs>
    </svg>

    <!--
      CRITICAL: onTelegramAuth stub MUST be defined here, synchronously,
      before the widget script runs. app.js overrides __tgAuthHandler later.
    -->
    <script>
        window.__tgAuthPending = null;
        window.__tgAuthHandler = null;
        function onTelegramAuth(user) {
            if (window.__tgAuthHandler) window.__tgAuthHandler(user);
            else window.__tgAuthPending = user;
        }
    </script>
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
</head>
<body>

<!-- ═══ СПЛЭШ ══════════════════════════════════ -->
<div id="splash-screen" class="screen active">
    <div class="splash-wrap">
        <div class="splash-mark"><div class="splash-mark-inner">С</div></div>
        <h1 class="splash-title">СДВИГ</h1>
        <p class="splash-sub">Кабинет Аналитика</p>
        <div class="splash-progress-wrap">
            <div class="splash-track"><div id="splash-fill" class="splash-fill"></div></div>
            <p id="splash-text" class="splash-status">Инициализация…</p>
        </div>
    </div>
</div>

<!-- ═══ ЛОГИН ══════════════════════════════════ -->
<div id="login-screen" class="screen">
    <div class="login-bg-pattern"></div>
    <div class="login-container">
        <div class="login-header">
            <div class="login-badge">С</div>
            <h1 class="login-h1">СДВИГ</h1>
            <p class="login-tagline">Кабинет Аналитика</p>
        </div>
        <div class="login-card">
            <p class="login-card-label">Доступ к системе</p>
            <p class="login-hint">Войдите через Telegram чтобы открыть дело</p>

            <!-- Виджет без spinner — показываем напрямую -->
            <div id="tg-widget-area" class="tg-widget-area">
                <script
                    src="https://telegram.org/js/telegram-widget.js?22"
                    data-telegram-login="sdvig_game_bot"
                    data-size="large"
                    data-radius="8"
                    data-onauth="onTelegramAuth"
                    data-request-access="write">
                </script>
                <!-- Показывается если виджет не появился через 6 сек -->
                <p id="tg-tip" class="tg-tip hidden">
                    Кнопка не появилась?<br>
                    Проверьте что домен добавлен в
                    <a href="https://t.me/BotFather" target="_blank">@BotFather</a>
                    командой <code>/setdomain</code>, затем
                    <a href="#" onclick="location.reload()">обновите страницу</a>.
                </p>
            </div>

            <div class="login-divider"><span>скоро</span></div>
            <button class="btn btn-outline" disabled>ВКонтакте</button>
            <button class="btn btn-outline" disabled>Google</button>
        </div>
        <p class="login-footer">Помощь: <a href="https://t.me/sdvig_game_bot" target="_blank">@sdvig_game_bot</a></p>
    </div>
</div>

<!-- ═══ ГЛАВНЫЙ ЭКРАН ═══════════════════════════ -->
<div id="main-screen" class="screen">

    <!-- Шапка -->
    <header class="topbar">
        <div class="topbar-left">
            <div class="topbar-emblem">С</div>
            <span class="topbar-title">СДВИГ</span>
        </div>
        <div class="topbar-stats">
            <div class="stat-pill" id="sp-energy">
                <span class="stat-pill-icon" id="icon-energy"></span>
                <span id="hud-energy">100</span>
            </div>
            <div class="stat-pill" id="sp-credits">
                <span class="stat-pill-icon" id="icon-credits"></span>
                <span id="hud-credits">0</span>
            </div>
            <div class="stat-pill" id="sp-rank">
                <span class="stat-pill-icon" id="icon-rank"></span>
                <span>R<span id="hud-rank">1</span></span>
            </div>
        </div>
    </header>

    <!-- XP полоса -->
    <div class="xp-band">
        <div class="xp-track"><div id="xp-fill" class="xp-fill" style="width:0%"></div></div>
        <span class="xp-info"><span id="hud-xp">0</span>/<span id="hud-xp-max">150</span> XP</span>
    </div>

    <!-- Вкладки -->
    <div class="tab-area">

        <!-- ─── ДЕЛА ──────────────────────────── -->
        <div class="tab-pane active" id="tab-cases">
            <div class="swipe-zone">
                <div class="stack-card sc3"></div>
                <div class="stack-card sc2"></div>
                <div class="stack-card sc1"></div>

                <!-- Основная карточка дела -->
                <div id="main-card" class="case-card">
                    <!-- SVG stamp filter  -->
                    <div class="stamp-wrap stamp-right" id="stamp-approve" style="opacity:0">
                        <div class="stamp stamp-approve-text">ОДОБРЕНО</div>
                    </div>
                    <div class="stamp-wrap stamp-left" id="stamp-deny" style="opacity:0">
                        <div class="stamp stamp-deny-text">ОТКЛОНЕНО</div>
                    </div>

                    <div class="card-head">
                        <span class="card-act" id="card-act">АКТ I</span>
                        <span class="card-type-badge" id="card-type-badge">ДЕЛО</span>
                        <span class="card-num" id="card-num">#2847</span>
                    </div>
                    <div class="card-divider"></div>

                    <div class="card-body">
                        <div class="card-icon-wrap">
                            <span class="card-emoji" id="card-icon">🔍</span>
                        </div>
                        <h2 class="card-case-title" id="card-title">Пентхаус на Садовом</h2>
                        <p class="card-text" id="case-description">Загружаем материалы дела…</p>
                    </div>

                    <!-- Hint + actions — заполняется JS -->
                    <div class="card-actions-area" id="swipe-actions"></div>
                </div>

                <!-- Результат -->
                <div id="result-overlay" class="result-overlay hidden">
                    <div class="ro-stamp-text" id="ro-stamp">РЕЗУЛЬТАТ</div>
                    <p class="ro-text" id="result-text"></p>
                    <div class="ro-rewards">
                        <div class="ro-chip ro-xp">+<span id="rew-xp">0</span> XP</div>
                        <div class="ro-chip ro-cr">+<span id="rew-cr">0</span> 💎</div>
                        <div class="ro-chip ro-en">−<span id="rew-en">0</span> ⚡</div>
                    </div>
                    <button class="btn btn-bronze" onclick="nextCard()">Следующее дело</button>
                </div>
            </div>
        </div>

        <!-- ─── ИГРЫ ───────────────────────────── -->
        <div class="tab-pane" id="tab-games">
            <div class="pane-header">
                <h2 class="pane-title">Арсенал аналитика</h2>
                <p class="pane-sub">Прокачивай навыки через испытания</p>
            </div>
            <div class="game-list">
                <div class="game-row" onclick="launchGame('detective')">
                    <div class="gr-stripe gr-s-v"></div>
                    <span class="gr-icon">💎</span>
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
                    <div class="gr-stripe gr-s-b"></div>
                    <span class="gr-icon">💓</span>
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
                    <div class="gr-stripe gr-s-a"></div>
                    <span class="gr-icon">🧮</span>
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

            <!-- Viewport игры -->
            <div id="gvp-wrap" class="gvp-wrap hidden">
                <div class="gvp-bar">
                    <button class="back-btn" onclick="closeGame()">
                        <span id="back-icon"></span>Выход
                    </button>
                    <span id="gvp-title" class="gvp-title"></span>
                    <div id="win-badge" class="win-badge hidden">WIN ✓</div>
                </div>
                <div id="game-vp" class="game-vp"></div>
            </div>
        </div>

        <!-- ─── АГЕНТ ──────────────────────────── -->
        <div class="tab-pane" id="tab-profile">
            <div class="profile-hero">
                <div class="profile-av" id="profile-av">?</div>
                <div class="profile-info">
                    <div class="profile-name" id="profile-name">Агент</div>
                    <div class="profile-arch" id="profile-arch">🔍 Детектив</div>
                    <div class="profile-id"   id="profile-id">ID —</div>
                </div>
            </div>
            <div class="stats-row">
                <div class="sg"><div class="sg-val" id="ps-rank">1</div><div class="sg-lbl">Ранг</div></div>
                <div class="sg"><div class="sg-val" id="ps-credits">0</div><div class="sg-lbl">Кредиты</div></div>
                <div class="sg"><div class="sg-val" id="ps-cases">0</div><div class="sg-lbl">Дел</div></div>
                <div class="sg"><div class="sg-val" id="ps-streak">0</div><div class="sg-lbl">Серия 🔥</div></div>
            </div>
            <div class="pane-header" style="margin-top:6px">
                <h2 class="pane-title">Навыки</h2>
            </div>
            <div class="skill-list">
                <div class="skill-row">
                    <span class="sk-icon">🧠</span>
                    <div class="sk-body">
                        <div class="sk-name">Проницательность</div>
                        <div class="sk-desc">+XP за каждое дело</div>
                        <div class="sk-bar"><div id="sk1-fill" class="sk-fill"></div></div>
                    </div>
                    <div class="sk-side">
                        <span class="sk-lv" id="sk1-lv">Lv.1</span>
                        <button class="up-btn" onclick="upgradeSkill(1)"><span id="sk1-cost">50💎</span></button>
                    </div>
                </div>
                <div class="skill-row">
                    <span class="sk-icon">⚙️</span>
                    <div class="sk-body">
                        <div class="sk-name">Технологии</div>
                        <div class="sk-desc">−Энергия за дело</div>
                        <div class="sk-bar"><div id="sk2-fill" class="sk-fill"></div></div>
                    </div>
                    <div class="sk-side">
                        <span class="sk-lv" id="sk2-lv">Lv.1</span>
                        <button class="up-btn" onclick="upgradeSkill(2)"><span id="sk2-cost">50💎</span></button>
                    </div>
                </div>
            </div>
            <div class="pane-header" style="margin-top:4px">
                <h2 class="pane-title">Достижения</h2>
            </div>
            <div id="achievements-grid" class="ach-grid"></div>
        </div>

        <!-- ─── МАГАЗИН ────────────────────────── -->
        <div class="tab-pane" id="tab-shop">
            <div class="pane-header">
                <h2 class="pane-title">Снаряжение</h2>
                <p class="pane-sub">Ресурсы для работы</p>
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

    </div>

    <!-- Нижняя навигация -->
    <nav class="bottom-nav">
        <button class="nb active" data-tab="cases" onclick="switchTab('cases')">
            <span class="nb-icon" id="nav-icon-cases"></span>
            <span class="nb-lbl">Дела</span>
        </button>
        <button class="nb" data-tab="games" onclick="switchTab('games')">
            <span class="nb-icon" id="nav-icon-games"></span>
            <span class="nb-lbl">Игры</span>
        </button>
        <button class="nb" data-tab="profile" onclick="switchTab('profile')">
            <span class="nb-icon" id="nav-icon-profile"></span>
            <span class="nb-lbl">Агент</span>
            <span id="ach-badge" class="nb-badge hidden">!</span>
        </button>
        <button class="nb" data-tab="shop" onclick="switchTab('shop')">
            <span class="nb-icon" id="nav-icon-shop"></span>
            <span class="nb-lbl">Магазин</span>
        </button>
    </nav>
</div>

<!-- ═══ HINT BOTTOM SHEET ═══════════════════════ -->
<div id="hint-modal" class="hint-modal hidden">
    <div class="hm-header">
        <div class="hm-title" id="hm-title">
            <span id="hm-lock-icon"></span>
            <span id="hm-title-text">Испытание</span>
        </div>
        <button class="hm-close" onclick="closeHintGame()">Пропустить →</button>
    </div>
    <div id="hm-vp" class="hm-vp"></div>
    <div class="hm-footer">
        <p class="hm-footer-text">Пройди испытание — получи подсказку аналитика бесплатно</p>
    </div>
</div>
<div id="hint-modal-backdrop" class="modal-bg hidden" style="z-index:299" onclick="closeHintGame()"></div>

<!-- ═══ ТОСТ ════════════════════════════════════ -->
<div id="toast" class="toast hidden">
    <span class="toast-icon" id="toast-icon">💡</span>
    <div><div class="toast-title" id="toast-title">УВЕДОМЛЕНИЕ</div>
    <div class="toast-desc" id="toast-desc"></div></div>
</div>

<!-- ═══ DAILY ═══════════════════════════════════ -->
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
        <button class="btn btn-bronze" onclick="claimDaily()">Забрать бонус</button>
    </div>
</div>

<!-- ═══ ERROR ════════════════════════════════════ -->
<div id="error-screen" class="screen">
    <div class="err-center">
        <div class="err-icon">⚠️</div>
        <h2 class="err-title">Ошибка системы</h2>
        <p class="err-msg" id="error-msg"></p>
        <button class="btn btn-bronze" onclick="location.reload()">Перезагрузить</button>
    </div>
</div>

<script src="icons.js"></script>
<script src="app.js"></script>
</body>
</html>

SDVIG_EOF

echo "  ✦ $S/app.js"
mkdir -p $(dirname "$S/app.js")
cat > "$S/app.js" << 'SDVIG_EOF'
// ═══════════════════════════════════════════════
//  СДВИГ · app.js
//  Analyst's Cabinet — Scenario Engine
// ═══════════════════════════════════════════════
'use strict';

const tg = window.Telegram?.WebApp ?? null;
const $  = id => document.getElementById(id);

// ── State ────────────────────────────────────────
let user         = null;
let scenarios    = null;
let currentCard  = null;
let currentCardId = 'act1_scene1';
let cardHistory  = [];
let cardCount    = 0;
let hintUnlocked = false;
let activeTab    = 'cases';
let gameDestroy  = null;
let hintGameType = null;
let dailyClaimed = false;

const FREE_CARDS = 3;     // first N cards: no hint game required
const SWIPE_COST = 5;     // crystals to swipe without hint after free cards

// ── Achievement definitions ───────────────────────
const ACH = [
    {id:'rank5',   check:p=>p.rank>=5,             icon:'🏅', title:'АГЕНТ В ДЕЛЕ',   desc:'Ранг 5'},
    {id:'rank10',  check:p=>p.rank>=10,            icon:'🏆', title:'ЭЛИТА',          desc:'Ранг 10'},
    {id:'cases10', check:p=>(p.totalCases||0)>=10, icon:'📂', title:'ДЕТЕКТИВ',       desc:'10 дел'},
    {id:'cases50', check:p=>(p.totalCases||0)>=50, icon:'🗃️', title:'АРХИВАРИУС',     desc:'50 дел'},
    {id:'streak3', check:p=>(p.streak||0)>=3,      icon:'🔥', title:'НА СЕРИИ',       desc:'3 дня подряд'},
    {id:'streak7', check:p=>(p.streak||0)>=7,      icon:'💥', title:'НЕСГИБАЕМЫЙ',    desc:'7 дней'},
    {id:'sk1max',  check:p=>p.skill1>=5,           icon:'🧠', title:'ПРОНИЦАТЕЛЬ',    desc:'Проницательность Lv.5'},
    {id:'sk2max',  check:p=>p.skill2>=5,           icon:'⚙️', title:'ТЕХНАРЬ',        desc:'Технологии Lv.5'},
];
const earned = new Set(JSON.parse(localStorage.getItem('sdvig_ach')||'[]'));

// ── Boot ─────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    if (tg) { try { tg.expand(); tg.ready(); } catch(e){} }

    // Install real auth handler (widget stub already defined in HTML)
    window.__tgAuthHandler = u => { showScreen('splash-screen'); setSplash('Проверка…'); widgetAuth(u); };
    if (window.__tgAuthPending) { window.__tgAuthHandler(window.__tgAuthPending); window.__tgAuthPending = null; }

    // Widget tip: if no iframe after 6 s, show help text
    setTimeout(() => {
        const area = $('tg-widget-area');
        const tip  = $('tg-tip');
        if (area && tip && !area.querySelector('iframe')) tip.classList.remove('hidden');
    }, 6000);

    injectIcons();
    runSplash();
});

// ── Icons injection ───────────────────────────────
function injectIcons() {
    setIcon($('icon-energy'),   'bolt');
    setIcon($('icon-credits'),  'diamond');
    setIcon($('icon-rank'),     'shield');
    setIcon($('nav-icon-cases'),   'folder');
    setIcon($('nav-icon-games'),   'gamepad');
    setIcon($('nav-icon-profile'), 'badge');
    setIcon($('nav-icon-shop'),    'bag');
    setIcon($('back-icon'),        'arrowLeft');
    const hmLock = $('hm-lock-icon');
    if (hmLock) setIcon(hmLock, 'lock');
}

// ── Splash ────────────────────────────────────────
function runSplash() {
    const fill = $('splash-fill');
    const msgs = ['Загрузка материалов…','Открываю архивы…','Авторизация…'];
    [[200,25],[700,55],[1100,85],[1450,100]].forEach(([d,w],i) => {
        setTimeout(() => {
            fill.style.width = w + '%';
            if (msgs[i]) setSplash(msgs[i]);
        }, d);
    });
    setTimeout(() => {
        if (tg?.initData?.length > 0) { setSplash('Telegram WebApp…'); webappAuth(); }
        else showScreen('login-screen');
    }, 1650);
}
function setSplash(t) { const e=$('splash-text'); if(e) e.textContent=t; }

// ── Screens ───────────────────────────────────────
function showScreen(id) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    $(id).classList.add('active');
}

// ── Auth ──────────────────────────────────────────
function webappAuth() {
    fetch('/api/game/auth/webapp', {
        method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify({initData:tg.initData, initDataUnsafe:tg.initDataUnsafe})
    }).then(r => { if(!r.ok) throw 0; return r.json(); })
      .then(onLogin)
      .catch(() => showError('Ошибка WebApp-авторизации.\nПроверьте токен бота в переменных Railway.'));
}

function widgetAuth(u) {
    const p = {};
    for (const [k,v] of Object.entries(u)) p[k] = String(v);
    fetch('/api/game/auth/widget', {
        method:'POST', headers:{'Content-Type':'application/json'},
        body: JSON.stringify(p)
    }).then(r => { if(!r.ok) return r.text().then(t=>{throw t;}); return r.json(); })
      .then(onLogin)
      .catch(e => showError(typeof e==='string' ? e + '\n\nУбедитесь что домен прописан в @BotFather → /setdomain' : 'Ошибка авторизации'));
}

function showError(m) { $('error-msg').textContent = m; showScreen('error-screen'); }

function onLogin(profile) {
    user = profile;
    updateHUD(profile);
    updateProfile(profile);
    renderAchGrid();
    showScreen('main-screen');
    initSwipe();
    loadScenarios().then(() => loadCard(currentCardId));
    checkDailyBonus();
    vib(30);
}

// ── Scenarios ─────────────────────────────────────
async function loadScenarios() {
    if (scenarios) return;
    try {
        const r = await fetch('/scenarios/detective.json');
        scenarios = await r.json();
    } catch(e) {
        scenarios = { cards: {} }; // fallback: no local scenarios
    }
}

function getCard(id) {
    return scenarios?.cards?.[id] ?? null;
}

// ── Card loading ──────────────────────────────────
function loadCard(id) {
    currentCard = getCard(id);
    if (!currentCard) {
        // Fallback to AI-generated card
        loadAICard(); return;
    }
    currentCardId = id;
    cardCount++;
    hintUnlocked = false;

    const card = $('main-card');
    card.classList.remove('slide-in');
    void card.offsetWidth;
    card.classList.add('slide-in');

    // Apply card type class
    card.className = 'case-card slide-in ct-' + (currentCard.type || 'evidence');

    // Watermark stamp reset
    $('stamp-approve').style.opacity = '0';
    $('stamp-deny').style.opacity    = '0';
    $('result-overlay').classList.add('hidden');

    // Fill content
    $('card-act').textContent         = currentCard.actTitle || ('АКТ ' + (currentCard.act || 1));
    $('card-type-badge').textContent  = formatType(currentCard.type);
    $('card-num').textContent         = '#' + String(id).toUpperCase().slice(0,8);
    $('card-icon').textContent        = currentCard.icon || '🔍';
    $('card-title').textContent       = currentCard.title || '';
    $('case-description').textContent = currentCard.text  || '';

    // Render actions panel
    renderActions(currentCard);
}

function loadAICard() {
    $('case-description').textContent = 'Запрашиваем дело из архива…';
    resetCardUI();
    fetch('/api/game/case?providerId='+enc(user.providerId))
    .then(r=>r.text()).then(raw=>{
        let d; try { d=JSON.parse(raw); if(typeof d==='string') d=JSON.parse(d); } catch{ d={text:raw}; }
        currentCard = { ...d, id:'ai_'+Date.now(), type:'evidence', actTitle:'АРХИВ', act:0 };
        $('case-description').textContent = d.text || raw;
        $('card-act').textContent  = 'ДЕЛО ИЗ АРХИВА';
        $('card-type-badge').textContent  = 'ДЕЛО';
        renderActions(currentCard);
    }).catch(() => { $('case-description').textContent='⚠️ Архив недоступен'; });
}

function resetCardUI() {
    $('card-act').textContent        = 'АРХИВ';
    $('card-type-badge').textContent = 'ДЕЛО';
    $('card-num').textContent        = '#—';
    $('card-icon').textContent       = '📁';
    $('card-title').textContent      = '';
    $('stamp-approve').style.opacity = '0';
    $('stamp-deny').style.opacity    = '0';
    $('result-overlay').classList.add('hidden');
}

function formatType(t) {
    const m = {crime:'ПРЕСТУПЛЕНИЕ',evidence:'УЛИКА',suspect:'ПОДОЗРЕВАЕМЫЙ',witness:'СВИДЕТЕЛЬ',
               testimony:'ПОКАЗАНИЯ',mystery:'ТАЙНА',action:'ОПЕРАЦИЯ',revelation:'ПРОРЫВ',
               briefing:'СВОДКА',ending:'ФИНАЛ',ending_bad:'ФИНАЛ',ending_partial:'ФИНАЛ',chase:'ПОГОНЯ'};
    return m[t] || (t||'ДЕЛО').toUpperCase();
}

// ── Actions panel ─────────────────────────────────
function renderActions(card) {
    const area = $('swipe-actions');
    if (!area) return;

    const isFree    = cardCount <= FREE_CARDS || card.isEnding || !card.hintGame;
    const hasHint   = !!card.hint;

    if (isFree || hintUnlocked) {
        area.innerHTML = buildFreeActions(card, hintUnlocked && hasHint ? card.hint : null);
    } else {
        area.innerHTML = buildLockedActions(card);
    }
}

function buildFreeActions(card, hint) {
    const hintHtml = hint ? `
        <div class="hint-revealed-panel">
            <span class="hrp-icon">💡</span>
            <p class="hrp-text">${hint}</p>
        </div>` : '';
    const freeChip = hintUnlocked ? `<span class="free-chip">FREE</span>` : '';
    return `
        ${hintHtml}
        <div class="action-row">
            <button class="action-btn action-deny" onclick="triggerSwipe('left')">
                ${icon('xCircle')} ${card.leftOption||'Отказать'} ${freeChip}
            </button>
            <button class="action-btn action-approve" onclick="triggerSwipe('right')">
                ${card.rightOption||'Одобрить'} ${icon('checkCircle')} ${freeChip}
            </button>
        </div>`;
}

function buildLockedActions(card) {
    const gameLabels = {detective:'Самоцветы 💎', doctor:'Кардиограмма 💓', universal:'Экспертиза 🧮'};
    const gameLabel  = gameLabels[card.hintGame] || 'Испытание';
    return `
        <div class="hint-locked-panel">
            <div class="hlp-icon">${icon('lock')}</div>
            <div class="hlp-body">
                <div class="hlp-title">Подсказка аналитика</div>
                <div class="hlp-sub">Пройди «${gameLabel}» — разблокируй совет</div>
            </div>
            <button class="hlp-btn" onclick="openHintGame('${card.hintGame}')">Пройти</button>
        </div>
        <div class="action-row">
            <button class="action-btn action-deny" onclick="triggerSwipePaid('left')">
                ${icon('xCircle')} ${card.leftOption||'Отказать'}
                <span class="cost-chip">${SWIPE_COST}💎</span>
            </button>
            <button class="action-btn action-approve" onclick="triggerSwipePaid('right')">
                ${card.rightOption||'Одобрить'} ${icon('checkCircle')}
                <span class="cost-chip">${SWIPE_COST}💎</span>
            </button>
        </div>`;
}

// ── Swipe engine ──────────────────────────────────
function initSwipe() {
    const card = $('main-card');
    let sx=0, cx=0, dragging=false, lx=0, vel=0, lt=0;

    const start = e => {
        if (!$('result-overlay').classList.contains('hidden')) return;
        if (!currentCard) return;
        dragging=true; sx=gx(e); lx=sx; lt=Date.now();
        card.style.transition='none';
    };
    const move = e => {
        if (!dragging) return; e.preventDefault();
        cx=gx(e);
        const now=Date.now(); vel=(cx-lx)/Math.max(1,now-lt); lx=cx; lt=now;
        const dx=cx-sx, rot=dx/18;
        card.style.transform=`rotate(${rot}deg) translateX(${dx}px)`;
        const r=Math.min(1,Math.abs(dx)/80);
        if (dx<-28){
            card.classList.add('tilt-left');  card.classList.remove('tilt-right');
            $('stamp-deny').style.opacity=r;  $('stamp-approve').style.opacity=0;
        } else if (dx>28){
            card.classList.add('tilt-right'); card.classList.remove('tilt-left');
            $('stamp-approve').style.opacity=r; $('stamp-deny').style.opacity=0;
        } else {
            card.classList.remove('tilt-left','tilt-right');
            $('stamp-approve').style.opacity=0; $('stamp-deny').style.opacity=0;
        }
    };
    const end = () => {
        if (!dragging) return; dragging=false;
        const dx=cx-sx, T=88, V=0.4;
        card.style.transition='transform .3s ease';
        if      (dx<-T || vel<-V) flyCard('left');
        else if (dx> T || vel> V) flyCard('right');
        else {
            card.style.transform='rotate(-0.4deg)';
            card.classList.remove('tilt-left','tilt-right');
            $('stamp-approve').style.opacity=0; $('stamp-deny').style.opacity=0;
        }
    };
    card.addEventListener('touchstart', start,{passive:true});
    card.addEventListener('mousedown',  start);
    window.addEventListener('touchmove',  move,{passive:false});
    window.addEventListener('mousemove',  move);
    window.addEventListener('touchend',   end);
    window.addEventListener('mouseup',    end);
}
const gx = e => e.touches?e.touches[0].clientX:e.clientX;

function triggerSwipe(dir) {
    // Check energy
    if ((user?.energy||0) < 5) { toast('⚡','Нет энергии','Купи кофе в Магазине'); return; }
    flyCard(dir);
}
window.triggerSwipe = triggerSwipe;

function triggerSwipePaid(dir) {
    if ((user?.credits||0) < SWIPE_COST) {
        toast('💎','Нет кредитов',`Нужно ${SWIPE_COST} 💎 или пройди испытание`); return;
    }
    flyCard(dir, true);
}
window.triggerSwipePaid = triggerSwipePaid;

function flyCard(dir, paid=false) {
    // Animate stamp landing
    const stampEl = dir==='left' ? $('stamp-deny') : $('stamp-approve');
    const stampText = stampEl.querySelector('.stamp');
    if (stampText) {
        stampEl.style.opacity='1';
        stampText.classList.add('landing');
    }
    vib(25);
    const card = $('main-card');
    setTimeout(() => {
        card.style.transition='transform .36s cubic-bezier(.55,0,1,.45), opacity .36s ease';
        card.style.transform  = dir==='left'?'translateX(-160vw) rotate(-25deg)':'translateX(160vw) rotate(25deg)';
        card.style.opacity    = '0';
        sendChoice(dir, paid);
    }, 120);
}

function sendChoice(dir, paid=false) {
    if (!user||!currentCard) return;
    const url = `/api/game/choice?providerId=${enc(user.providerId)}&direction=${dir}${paid?'&paid=true':''}`;
    fetch(url,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('⚡','Ошибка',t);throw 0;}); return r.json(); })
    .then(data=>{
        user=data.profile; updateHUD(user);
        // Result overlay
        const ok = dir==='right';
        const rs = $('ro-stamp');
        rs.textContent = ok ? 'ОДОБРЕНО' : 'ОТКЛОНЕНО';
        rs.className   = 'ro-stamp-text '+(ok?'approve':'deny');
        $('result-text').textContent = ok ? (currentCard.rightResult||'') : (currentCard.leftResult||'');
        $('rew-xp').textContent = data.xpGained;
        $('rew-cr').textContent = data.creditsGained;
        $('rew-en').textContent = data.energyLost;
        setTimeout(()=>{ $('result-overlay').classList.remove('hidden'); checkAch(data.profile); }, 280);
        vib([30,20,60]);
    }).catch(()=>{
        // reset card
        const card=$('main-card');
        card.style.transition='transform .35s ease'; card.style.transform='rotate(-0.4deg)';
        card.style.opacity='1'; card.classList.remove('tilt-left','tilt-right');
        $('stamp-approve').style.opacity=0; $('stamp-deny').style.opacity=0;
    });
}

function nextCard() {
    $('result-overlay').classList.add('hidden');
    // Advance scenario
    const dir = $('ro-stamp')?.classList.contains('approve') ? 'right' : 'left';
    const nextId = dir==='right' ? currentCard?.rightNext : currentCard?.leftNext;

    const card = $('main-card');
    card.style.transition='none'; card.style.opacity='0';
    card.style.transform='translateX(30px)';
    requestAnimationFrame(()=>requestAnimationFrame(()=>{
        card.style.transition='transform .35s ease, opacity .25s ease';
        card.style.transform='rotate(-0.4deg)'; card.style.opacity='1';
        if (nextId && getCard(nextId)) { loadCard(nextId); }
        else { loadAICard(); }
    }));
}
window.nextCard = nextCard;

// ── Hint mini-game ────────────────────────────────
function openHintGame(type) {
    hintGameType = type;
    const titles = {detective:'💎 Самоцветы',doctor:'💓 Кардиограмма',universal:'🧮 Экспертиза шифра'};
    $('hm-title-text').textContent = titles[type]||'Испытание';

    const modal    = $('hint-modal');
    const backdrop = $('hint-modal-backdrop');
    modal.classList.remove('hidden'); modal.classList.remove('closing');
    backdrop.classList.remove('hidden');

    const level = gameLevel(type);
    const vp    = $('hm-vp'); vp.innerHTML='';

    import('./games/'+type+'.js')
    .then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp, level, onHintGameWon);
    }).catch(()=>{ vp.innerHTML='<p style="color:var(--deny);padding:24px;text-align:center">⚠️ Ошибка загрузки игры</p>'; });
}
window.openHintGame = openHintGame;

function onHintGameWon() {
    hintUnlocked = true;
    vib([30,20,30,20,80]);
    closeHintGame(true);
    toast('💡','ПОДСКАЗКА РАЗБЛОКИРОВАНА','Теперь свайпы бесплатны');
    renderActions(currentCard);

    // Advance game level on server
    const type = hintGameType;
    fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=${type}`,{method:'POST'})
    .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
}

function closeHintGame(won=false) {
    const modal    = $('hint-modal');
    const backdrop = $('hint-modal-backdrop');
    modal.classList.add('closing');
    setTimeout(()=>{ modal.classList.add('hidden'); backdrop.classList.add('hidden'); },250);
    if(gameDestroy){try{gameDestroy();}catch(e){} gameDestroy=null;}
    $('hm-vp').innerHTML='';
}
window.closeHintGame = closeHintGame;

// ── Main game tab launcher ────────────────────────
const GTITLES={detective:'💎 Самоцветы',doctor:'💓 Кардиограмма',universal:'🧮 Экспертиза шифра'};
function launchGame(type){
    $('gvp-wrap').classList.remove('hidden');
    $('gvp-title').textContent=GTITLES[type]||'Игра';
    $('win-badge').classList.add('hidden');
    const vp=$('game-vp'); vp.innerHTML='';
    if(gameDestroy){try{gameDestroy();}catch(e){} gameDestroy=null;}
    const level=gameLevel(type);
    import('./games/'+type+'.js').then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp,level,()=>{
            $('win-badge').classList.remove('hidden');
            vib([30,20,30,20,100]);
            toast('🎮','УРОВЕНЬ ПРОЙДЕН','+50 XP');
            fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=${type}`,{method:'POST'})
            .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
        });
    }).catch(()=>{ vp.innerHTML='<p style="color:var(--deny);text-align:center;padding:24px">⚠️ Ошибка загрузки</p>'; });
}
window.launchGame=launchGame;
function closeGame(){
    if(gameDestroy){try{gameDestroy();}catch(e){} gameDestroy=null;}
    $('gvp-wrap').classList.add('hidden');
    $('game-vp').innerHTML='';
    $('win-badge').classList.add('hidden');
}
window.closeGame=closeGame;
function gameLevel(t){
    if(!user) return 1;
    return user[{detective:'detectiveLvl',doctor:'doctorLvl',universal:'universalLvl'}[t]]||1;
}

// ── HUD ───────────────────────────────────────────
function updateHUD(p){
    $('hud-energy').textContent  = p.energy;
    $('hud-credits').textContent = p.credits;
    $('hud-rank').textContent    = p.rank;
    $('hud-xp').textContent      = p.xp;
    const xpMax = p.rank*150;
    $('hud-xp-max').textContent  = xpMax;
    $('xp-fill').style.width     = Math.min(100,(p.xp/xpMax)*100)+'%';
    const dl=p.detectiveLvl||1, dc=p.doctorLvl||1, ul=p.universalLvl||1;
    $('det-lvl').textContent=dl; $('det-bar').style.width=Math.min(100,dl)+'%';
    $('doc-lvl').textContent=dc; $('doc-bar').style.width=Math.min(100,dc)+'%';
    $('uni-lvl').textContent=ul; $('uni-bar').style.width=Math.min(100,ul)+'%';
}

// ── Profile ───────────────────────────────────────
function updateProfile(p){
    const name=p.firstName||p.username||'Агент';
    $('profile-av').textContent   = name[0].toUpperCase();
    $('profile-name').textContent = name;
    $('profile-id').textContent   = 'ID ' + (p.providerId||'—').replace('tg:','');
    const a={detective:'🔍 Детектив',doctor:'⚕️ Медик',hacker:'💻 Хакер'};
    $('profile-arch').textContent = a[p.archetype]||'🔍 Детектив';
    $('ps-rank').textContent    = p.rank;
    $('ps-credits').textContent = p.credits;
    $('ps-cases').textContent   = p.totalCases||0;
    $('ps-streak').textContent  = p.streak||0;
    const s1=p.skill1||1, s2=p.skill2||1;
    $('sk1-lv').textContent='Lv.'+s1; $('sk1-cost').textContent=(s1*50)+'💎';
    $('sk2-lv').textContent='Lv.'+s2; $('sk2-cost').textContent=(s2*50)+'💎';
    $('sk1-fill').style.width=Math.min(100,s1*10)+'%';
    $('sk2-fill').style.width=Math.min(100,s2*10)+'%';
}
function renderAchGrid(){
    const g=$('achievements-grid'); if(!g) return;
    g.innerHTML=ACH.map(d=>{
        const ok=earned.has(d.id);
        return `<div class="ach-badge ${ok?'earned':'locked'}">
            <div class="ach-icon">${ok?d.icon:'❓'}</div>
            <div class="ach-lbl">${ok?d.title:'???'}</div>
        </div>`;
    }).join('');
}

// ── Tab navigation ────────────────────────────────
function switchTab(name){
    if(activeTab===name) return;
    if(activeTab==='games') closeGame();
    document.querySelectorAll('.tab-pane').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.nb').forEach(b=>b.classList.remove('active'));
    $('tab-'+name).classList.add('active');
    document.querySelector(`[data-tab="${name}"]`).classList.add('active');
    activeTab=name; vib(10);
    if(name==='profile'){ updateProfile(user); renderAchGrid(); $('ach-badge').classList.add('hidden'); }
    if(name==='shop') updateShopAfford();
}
window.switchTab=switchTab;

// ── Skills ────────────────────────────────────────
function upgradeSkill(n){
    if(!user) return;
    fetch(`/api/game/upgrade-skill?providerId=${enc(user.providerId)}&skillNum=${n}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('💎','Мало кредитов',t);throw 0;}); return r.json(); })
    .then(p=>{ user=p; updateHUD(p); updateProfile(p); vib([20,20,40]);
        toast('🧠','НАВЫК ПРОКАЧАН',n===1?'Проницательность Lv.'+p.skill1:'Технологии Lv.'+p.skill2); })
    .catch(()=>{});
}
window.upgradeSkill=upgradeSkill;

// ── Shop ──────────────────────────────────────────
function buyCoffee(){
    if(!user) return;
    fetch(`/api/game/buy-coffee?providerId=${enc(user.providerId)}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('☕','Мало кредитов',t);throw 0;}); return r.json(); })
    .then(p=>{ user=p; updateHUD(p); updateProfile(p); updateShopAfford();
        toast('☕','КОФЕ ВЫПИТ','+35 ⚡ энергии'); vib(30); })
    .catch(()=>{});
}
window.buyCoffee=buyCoffee;
function updateShopAfford(){
    if(!user) return;
    const el=$('shop-coffee'); if(!el) return;
    el.classList.toggle('cant-afford', user.credits<40);
    const pr=$('coffee-price'); if(pr) pr.textContent=user.credits>=40?'40 💎':'40 💎 (нет)';
}

// ── Daily bonus ───────────────────────────────────
function checkDailyBonus(){
    if(!user) return;
    fetch('/api/game/daily-bonus?providerId='+enc(user.providerId))
    .then(r=>r.ok?r.json():null)
    .then(d=>{ if(!d||!d.available) return; buildWeek(d.streak||1); $('daily-days').textContent=d.streak||1; $('daily-modal').classList.remove('hidden'); })
    .catch(()=>{});
}
function buildWeek(streak){
    const w=$('daily-week'); if(!w) return; w.innerHTML='';
    for(let i=1;i<=7;i++){
        const d=document.createElement('div'); d.className='dw-dot';
        if(i<(streak%7||(streak>=7?8:0))) d.classList.add('done');
        if(i===(streak%7||7)) d.classList.add('today');
        d.textContent=i; w.appendChild(d);
    }
}
function claimDaily(){
    if(!user||dailyClaimed) return; dailyClaimed=true;
    $('daily-modal').classList.add('hidden');
    fetch('/api/game/daily-bonus/claim?providerId='+enc(user.providerId),{method:'POST'})
    .then(r=>r.ok?r.json():null)
    .then(d=>{ if(!d) return; user=d.profile; updateHUD(user); updateProfile(user);
        toast('🎁','БОНУС ПОЛУЧЕН',`+50💎 · +30⚡ · Серия ${d.profile.streak}д.`); vib([30,20,30,20,80]); })
    .catch(()=>{});
}
window.claimDaily=claimDaily;

// ── Achievements ──────────────────────────────────
function checkAch(p){
    let found=false;
    for(const d of ACH){
        if(!earned.has(d.id)&&d.check(p)){
            earned.add(d.id);
            localStorage.setItem('sdvig_ach',JSON.stringify([...earned]));
            if(!found){ setTimeout(()=>toast(d.icon,d.title,d.desc),500); found=true; }
            const b=$('ach-badge'); if(b){b.textContent='!';b.classList.remove('hidden');}
        }
    }
}

// ── Toast ─────────────────────────────────────────
let _tt=null;
function toast(ic,title,desc){
    const el=$('toast');
    $('toast-icon').textContent=ic; $('toast-title').textContent=title; $('toast-desc').textContent=desc;
    el.classList.remove('hidden','out'); clearTimeout(_tt);
    _tt=setTimeout(()=>{ el.classList.add('out'); setTimeout(()=>el.classList.add('hidden'),300); },3200);
    vib(20);
}

// ── Utils ─────────────────────────────────────────
function enc(s){ return encodeURIComponent(s); }
function vib(p){ try{if(navigator.vibrate)navigator.vibrate(p);}catch(e){} }

SDVIG_EOF

echo "  ✦ $S/games/detective.js"
mkdir -p $(dirname "$S/games/detective.js")
cat > "$S/games/detective.js" << 'SDVIG_EOF'
// ─── САМОЦВЕТЫ · Match-3 (Analyst Cabinet) ───────

const GEMS  = ['🔴','🔵','🟢','🟡','🟣','🟠'];
const CKEYS = ['red','blue','green','yellow','purple','orange'];

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style,{display:'flex',flexDirection:'column',alignItems:'center',gap:'12px',width:'100%'});

    const ROWS=9, COLS=9;
    const miss = getMission(level);
    let col=0, ice=0, combo=0, active=true, busy=false;
    let board = mk2d(ROWS,COLS,null), iceB = mk2d(ROWS,COLS,0);
    let sr=null, sc=null;
    const vw   = Math.min(viewport.offsetWidth||window.innerWidth,400);
    const GAP=3, PAD=10, CELL=Math.floor((vw-PAD*2-GAP*(COLS-1))/COLS);

    // Header
    const hdr = el('div',{background:'#fdfaf5',border:'1px solid #e0d9ce',borderRadius:'8px',padding:'10px 14px',width:'100%',textAlign:'center',fontFamily:"'DM Sans',sans-serif"});
    const lv  = el('div',{fontSize:'10px',letterSpacing:'2px',color:'#8a7d6a',fontWeight:'700',textTransform:'uppercase',marginBottom:'4px',fontFamily:"'Courier Prime',monospace"});
    lv.textContent='УРОВЕНЬ '+level;
    const ms  = el('div',{fontSize:'13px',fontWeight:'600',color:'#1c1710'});
    const cm  = el('div',{fontSize:'11px',color:'#a87030',fontWeight:'700',letterSpacing:'1px',minHeight:'16px',marginTop:'4px'});
    hdr.append(lv,ms,cm); viewport.appendChild(hdr);
    refreshM();

    // Grid
    const grid = el('div',{
        display:'grid', gridTemplateColumns:`repeat(${COLS},${CELL}px)`,
        gap:GAP+'px', background:'#fdfaf5', padding:PAD+'px',
        borderRadius:'16px', border:'1px solid #c8bfb0',
        boxShadow:'0 4px 20px rgba(0,0,0,.10)'
    });
    viewport.appendChild(grid);
    const cells=mk2d(ROWS,COLS,null);

    for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++){
        const cell=el('div',{
            width:CELL+'px',height:CELL+'px',borderRadius:'6px',
            display:'flex',alignItems:'center',justifyContent:'center',
            fontSize:Math.max(16,CELL-12)+'px',cursor:'pointer',
            border:'1.5px solid transparent',
            transition:'transform .1s,border-color .1s,background .12s',
            lineHeight:'1',userSelect:'none',background:'#f5f0e8'
        });
        cell.addEventListener('click',((_r,_c)=>()=>onCell(_r,_c))(r,c));
        grid.appendChild(cell); cells[r][c]=cell;
    }

    function render(){
        for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++){
            const e=cells[r][c], clr=board[r][c], isIce=iceB[r][c]>0, isSel=sr===r&&sc===c;
            const gi=CKEYS.indexOf(clr); e.textContent=GEMS[gi]??'';
            e.style.background  = isIce?'rgba(30,58,106,.12)':'#f5f0e8';
            e.style.borderColor = isSel?'#a87030':isIce?'rgba(30,58,106,.4)':'transparent';
            e.style.boxShadow   = isSel?'0 0 0 2px #a87030':'none';
            e.style.transform   = isSel?'scale(1.1)':'scale(1)';
            e.style.filter      = isIce&&iceB[r][c]===2?'brightness(.6)':isIce?'brightness(.75)':'none';
        }
    }

    function matches(){
        const m=new Set();
        for(let r=0;r<ROWS;r++){let l=1;for(let c=1;c<=COLS;c++){if(c<COLS&&board[r][c]===board[r][c-1])l++;else{if(l>=3)for(let i=c-l;i<c;i++)m.add(r+','+i);l=1;}}}
        for(let c=0;c<COLS;c++){let l=1;for(let r=1;r<=ROWS;r++){if(r<ROWS&&board[r][c]===board[r-1][c])l++;else{if(l>=3)for(let i=r-l;i<r;i++)m.add(i+','+c);l=1;}}}
        return m;
    }
    function processM(m){
        let gc=0,gi=0;
        for(const k of m){const[r,c]=k.split(',').map(Number);if(iceB[r][c]>0){iceB[r][c]--;if(!iceB[r][c])gi++;}}
        for(const k of m){const[r,c]=k.split(',').map(Number);if(!iceB[r][c]&&miss.color&&board[r][c]===miss.color)gc++;}
        for(const k of m){const[r,c]=k.split(',').map(Number);board[r][c]=null;iceB[r][c]=0;}
        col+=gc; ice+=gi; combo++;
        if(combo>1){cm.textContent='✨ COMBO ×'+combo+'!';setTimeout(()=>{cm.textContent='';},1100);}
        refreshM(); checkWin();
    }
    function gravity(){
        for(let c=0;c<COLS;c++){const g=[],ic=[];for(let r=ROWS-1;r>=0;r--)if(board[r][c]!==null){g.push(board[r][c]);ic.push(iceB[r][c]);}while(g.length<ROWS){g.push(CKEYS[rnd(CKEYS.length)]);ic.push(0);}g.reverse();ic.reverse();for(let r=0;r<ROWS;r++){board[r][c]=g[r];iceB[r][c]=ic[r];}}
    }
    async function resolve(){if(busy)return;busy=true;let any=true;while(any&&active){const m=matches();if(!m.size){any=false;break;}processM(m);if(!active)break;gravity();render();await wait(75);}busy=false;if(active&&!hasMoves())shuffle();render();}
    function hasMoves(){for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){if(c+1<COLS){sw(r,c,r,c+1);if(matches().size){sw(r,c,r,c+1);return true;}sw(r,c,r,c+1);}if(r+1<ROWS){sw(r,c,r+1,c);if(matches().size){sw(r,c,r+1,c);return true;}sw(r,c,r+1,c);}}return false;}
    function shuffle(){const f=board.flat();for(let i=f.length-1;i>0;i--){const j=rnd(i+1);[f[i],f[j]]=[f[j],f[i]];}let idx=0;for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)board[r][c]=f[idx++];resolve();}
    function sw(r1,c1,r2,c2){[board[r1][c1],board[r2][c2]]=[board[r2][c2],board[r1][c1]];[iceB[r1][c1],iceB[r2][c2]]=[iceB[r2][c2],iceB[r1][c1]];}
    async function trySwap(r1,c1,r2,c2){if(busy||!active)return;sw(r1,c1,r2,c2);if(matches().size){combo=0;render();await resolve();}else{sw(r1,c1,r2,c2);render();}}
    function onCell(r,c){if(busy||!active)return;if(sr===null){sr=r;sc=c;render();return;}if(sr===r&&sc===c){sr=null;sc=null;render();return;}const adj=Math.abs(sr-r)+Math.abs(sc-c)===1;if(!adj){sr=r;sc=c;render();return;}const[r1,c1]=[sr,sc];sr=null;sc=null;trySwap(r1,c1,r,c);}
    function initBoard(){for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){const no=new Set();if(c>=2&&board[r][c-1]===board[r][c-2])no.add(board[r][c-1]);if(r>=2&&board[r-1][c]===board[r-2][c])no.add(board[r-1][c]);const ok=CKEYS.filter(x=>!no.has(x));board[r][c]=ok[rnd(ok.length)]||CKEYS[0];}}
    function placeIce(){const n=miss.type==='clear_ice'?miss.target:miss.targetIce||0;if(!n)return;const pos=[];for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)pos.push([r,c]);pos.sort(()=>Math.random()-.5);for(let i=0;i<Math.min(n,pos.length);i++){const[r,c]=pos[i];iceB[r][c]=level>25?2:1;}}
    function checkWin(){const done=miss.type==='collect'?col>=miss.target:miss.type==='clear_ice'?ice>=miss.target:col>=miss.targetCollect&&ice>=miss.targetIce;if(done&&active){active=false;onWin();}}
    function refreshM(){const g=GEMS[CKEYS.indexOf(miss.color)]||'';if(miss.type==='collect')ms.textContent=`${g} Собери: ${col} / ${miss.target}`;else if(miss.type==='clear_ice')ms.textContent=`❄️ Разморозь: ${ice} / ${miss.target}`;else ms.textContent=`${g} ${col}/${miss.targetCollect}  ❄️ ${ice}/${miss.targetIce}`;}

    initBoard(); placeIce(); render();
    if(!hasMoves()) shuffle();
}
function getMission(l){if(l<=5)return{type:'collect',color:'blue',target:10+l};if(l<=10)return{type:'collect',color:'green',target:15+(l-5)*2};if(l<=15)return{type:'collect',color:'purple',target:20+(l-10)*3};if(l<=20)return{type:'clear_ice',target:5+(l-15)};return{type:'mixed',color:'blue',targetCollect:20+(l-20)*2,targetIce:8+Math.floor((l-20)/2)};}
function mk2d(r,c,v){return Array.from({length:r},()=>Array(c).fill(v));}
function rnd(n){return Math.floor(Math.random()*n);}
function wait(ms){return new Promise(r=>setTimeout(r,ms));}
function el(tag,s){const d=document.createElement(tag);Object.assign(d.style,s);return d;}
export function destroy(){}

SDVIG_EOF

echo "  ✦ $S/games/doctor.js"
mkdir -p $(dirname "$S/games/doctor.js")
cat > "$S/games/doctor.js" << 'SDVIG_EOF'
// ─── КАРДИОГРАММА (Analyst Cabinet) ───────────────

let _raf = null, _tapped = false;

export function initGame(viewport, level, onWin) {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'20px',
        padding:'8px', width:'100%',
        fontFamily:"'DM Sans',sans-serif"
    });

    const speed = 2 + level * 0.13;
    const zoneW = Math.max(7, 32 - level * 0.24);
    const zoneL = 12 + Math.random() * (72 - zoneW);

    // Header
    const hdr = document.createElement('div');
    hdr.style.cssText = 'text-align:center;width:100%;';
    hdr.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:#8a7d6a;font-weight:700;
            text-transform:uppercase;font-family:'Courier Prime',monospace;">УРОВЕНЬ ${level}</div>
        <div style="font-size:40px;margin:8px 0;line-height:1;">💓</div>
        <div style="font-size:14px;color:#4a3f32;font-weight:600;">Поймай импульс в зелёной зоне</div>
    `;
    viewport.appendChild(hdr);

    // Decorative EKG
    const ekgWrap = document.createElement('div');
    ekgWrap.style.cssText = 'width:100%;max-width:340px;opacity:.18;';
    ekgWrap.innerHTML = `<svg width="100%" height="34" viewBox="0 0 340 34">
        <polyline fill="none" stroke="#8b2020" stroke-width="1.5"
            points="0,17 28,17 36,3 42,31 48,17 58,17 86,17 94,3 100,31 106,17
                    116,17 144,17 152,3 158,31 164,17 174,17 202,17 210,3 216,31
                    222,17 232,17 260,17 268,3 274,31 280,17 290,17 318,17 326,3 332,31 340,17"/>
    </svg>`;
    viewport.appendChild(ekgWrap);

    // Track
    const trackWrap = document.createElement('div');
    trackWrap.style.cssText = 'width:100%;max-width:340px;';
    const track = document.createElement('div');
    track.className = 'doc-track';

    const zone = document.createElement('div');
    zone.className = 'doc-target';
    zone.style.left = zoneL + '%';
    zone.style.width = zoneW + '%';
    track.appendChild(zone);

    const pin = document.createElement('div');
    pin.className = 'doc-pin';
    track.appendChild(pin);
    trackWrap.appendChild(track);
    viewport.appendChild(trackWrap);

    // Hint text
    const hint = document.createElement('div');
    hint.style.cssText = 'font-size:14px;color:#4a3f32;font-weight:600;text-align:center;min-height:22px;';
    hint.textContent = '↓ Нажмите в любом месте ↓';
    viewport.appendChild(hint);

    // Stats panel
    const stats = document.createElement('div');
    stats.style.cssText = `
        display:flex;gap:20px;justify-content:center;
        background:#fdfaf5;border:1px solid #e0d9ce;
        border-radius:12px;padding:10px 24px;
        width:100%;max-width:280px;
    `;
    stats.innerHTML = `
        <div style="text-align:center;">
            <div style="font-size:9px;letter-spacing:1.5px;color:#8a7d6a;font-weight:700;
                text-transform:uppercase;font-family:'Courier Prime',monospace;">СКОРОСТЬ</div>
            <div style="font-size:20px;font-weight:800;color:#8b2020;margin-top:2px;
                font-family:'Cormorant Garamond',serif;">${speed.toFixed(1)}×</div>
        </div>
        <div style="width:1px;background:#e0d9ce;"></div>
        <div style="text-align:center;">
            <div style="font-size:9px;letter-spacing:1.5px;color:#8a7d6a;font-weight:700;
                text-transform:uppercase;font-family:'Courier Prime',monospace;">ЗОНА</div>
            <div style="font-size:20px;font-weight:800;color:#2a6040;margin-top:2px;
                font-family:'Cormorant Garamond',serif;">${Math.round(zoneW)}%</div>
        </div>
    `;
    viewport.appendChild(stats);

    // Animation
    let pos = 0, dir = 1, last = performance.now();
    function frame(ts) {
        const dt = Math.min(ts - last, 50); last = ts;
        pos += speed * dir * dt / 16;
        if (pos >= 100) { pos = 100; dir = -1; }
        if (pos <= 0)   { pos = 0;   dir =  1; }
        if (level > 60 && Math.random() > .994) dir *= -1;
        pin.style.left = pos + '%';
        _raf = requestAnimationFrame(frame);
    }
    _raf = requestAnimationFrame(frame);

    viewport.addEventListener('click', () => {
        if (_tapped) return;
        const inZone = pos >= zoneL && pos <= zoneL + zoneW;
        if (inZone) {
            _tapped = true;
            cancelAnimationFrame(_raf); _raf = null;
            hint.textContent = '✓ ПОПАДАНИЕ!';
            hint.style.color = '#2a6040';
            hint.style.fontWeight = '800';
            pin.style.background = '#2a6040';
            pin.style.boxShadow  = '0 0 8px rgba(42,96,64,.4)';
            zone.style.background = 'rgba(42,96,64,.25)';
            if (navigator.vibrate) navigator.vibrate([30, 20, 60]);
            setTimeout(() => onWin(), 380);
        } else {
            if (navigator.vibrate) navigator.vibrate(70);
            track.classList.add('doc-shake');
            hint.textContent = '✗ Мимо — попробуйте ещё';
            hint.style.color = '#8b2020';
            pin.style.boxShadow = '0 0 10px rgba(139,32,32,.5)';
            setTimeout(() => {
                track.classList.remove('doc-shake');
                if (!_tapped) {
                    hint.textContent = '↓ Нажмите ещё раз ↓';
                    hint.style.color = '#4a3f32';
                    pin.style.boxShadow = '0 0 6px rgba(139,32,32,.4)';
                }
            }, 450);
        }
    });
}

export function destroy() {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;
}

SDVIG_EOF

echo "  ✦ $S/games/universal.js"
mkdir -p $(dirname "$S/games/universal.js")
cat > "$S/games/universal.js" << 'SDVIG_EOF'
// ─── ЭКСПЕРТИЗА ШИФРА (Analyst Cabinet) ───────────

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'16px', width:'100%',
        fontFamily:"'DM Sans',sans-serif"
    });

    const target  = 10 + level * 4 + Math.floor(Math.random() * 6);
    const count   = level <= 10 ? 6 : level <= 40 ? 9 : 12;
    const maxVal  = 4 + Math.floor(level / 2);
    let   sumNow  = 0;
    const picked  = new Set();

    // Числа с гарантированным решением
    const nums = Array.from({length: count}, () => Math.floor(Math.random() * maxVal) + 2);
    let acc = 0;
    for (const v of nums) { if (acc + v <= target) acc += v; }
    if (acc !== target) nums[nums.length - 1] = target - acc + (acc > 0 ? 0 : nums[0]);

    // Header
    const hdr = document.createElement('div');
    hdr.style.cssText = 'text-align:center;width:100%;';
    hdr.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:#8a7d6a;font-weight:700;
            text-transform:uppercase;font-family:'Courier Prime',monospace;margin-bottom:4px;">
            УРОВЕНЬ ${level} · ШИФР</div>
        <div style="font-size:13px;color:#4a3f32;font-weight:600;">Выбери числа в сумме:</div>
    `;
    viewport.appendChild(hdr);

    // Target
    const targetBox = document.createElement('div');
    targetBox.style.cssText = `
        background:#fdfaf5;border:1px solid #c8bfb0;
        border-radius:12px;padding:14px 36px;text-align:center;
        box-shadow:0 2px 12px rgba(0,0,0,.06);
    `;
    targetBox.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:#a87030;font-weight:700;
            text-transform:uppercase;font-family:'Courier Prime',monospace;">ЦЕЛЬ</div>
        <div style="font-size:52px;font-weight:700;color:#1c1710;line-height:1.1;
            font-family:'Cormorant Garamond',serif;">${target}</div>
    `;
    viewport.appendChild(targetBox);

    // Progress
    const progWrap = document.createElement('div');
    progWrap.style.cssText = 'width:100%;max-width:300px;';
    progWrap.innerHTML = `
        <div style="display:flex;justify-content:space-between;font-size:11px;
            color:#8a7d6a;font-weight:600;margin-bottom:6px;font-family:'Courier Prime',monospace;">
            <span>ТЕКУЩАЯ СУММА</span>
            <span id="cs-lbl">0 / ${target}</span>
        </div>
        <div style="height:4px;background:#e0d9ce;border-radius:99px;overflow:hidden;">
            <div id="cs-bar" style="height:100%;width:0%;background:#a87030;
                border-radius:99px;transition:width .2s ease,background .15s;"></div>
        </div>
    `;
    viewport.appendChild(progWrap);

    // Grid
    const grid = document.createElement('div');
    grid.style.cssText = 'display:flex;flex-wrap:wrap;gap:8px;justify-content:center;max-width:320px;';
    viewport.appendChild(grid);

    // Status
    const status = document.createElement('div');
    status.style.cssText = 'font-size:12px;color:#8a7d6a;min-height:18px;text-align:center;font-weight:500;';
    viewport.appendChild(status);

    for (let i = 0; i < count; i++) {
        const val  = nums[i];
        const cell = document.createElement('div');
        cell.className = 'cipher-cell';
        cell.textContent = val;

        cell.addEventListener('click', () => {
            if (picked.has(i)) {
                picked.delete(i); sumNow -= val; cell.classList.remove('sel');
            } else {
                picked.add(i); sumNow += val; cell.classList.add('sel');

                if (sumNow === target) {
                    grid.querySelectorAll('.cipher-cell').forEach(c => {
                        c.style.pointerEvents = 'none';
                        if (c.classList.contains('sel')) {
                            c.style.borderColor = '#2a6040';
                            c.style.background  = 'rgba(42,96,64,.10)';
                            c.style.color       = '#2a6040';
                        }
                    });
                    status.textContent = '✓ ШИФР ВЗЛОМАН';
                    status.style.color = '#2a6040';
                    status.style.fontWeight = '700';
                    setProgress(target, target);
                    if (navigator.vibrate) navigator.vibrate([30, 20, 60]);
                    setTimeout(() => onWin(), 420);
                    return;
                }
                if (sumNow > target) {
                    cell.classList.add('over');
                    setTimeout(() => cell.classList.remove('over'), 260);
                    if (navigator.vibrate) navigator.vibrate(60);
                    status.textContent = '⚠ Сумма превышена — сброс';
                    status.style.color = '#8b2020';
                    setTimeout(() => { if(status.style.color!=='rgb(42,96,64)') { status.textContent=''; status.style.color='#8a7d6a'; }}, 1000);
                    grid.querySelectorAll('.cipher-cell').forEach(c => c.classList.remove('sel'));
                    picked.clear(); sumNow = 0; setProgress(0, target);
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
        if (bar) { bar.style.width = pct + '%'; bar.style.background = cur > max ? '#8b2020' : cur === max ? '#2a6040' : '#a87030'; }
        if (lbl) lbl.textContent = `${cur} / ${max}`;
    }
}

export function destroy() {}

SDVIG_EOF

echo "  ✦ $S/scenarios/detective.json"
mkdir -p $(dirname "$S/scenarios/detective.json")
cat > "$S/scenarios/detective.json" << 'SDVIG_EOF'
{
  "id": "detective_main",
  "title": "ДЕЛО: НОЧНАЯ ТЕНЬ",
  "subtitle": "Детектив Соколов · Дело №2847",
  "opening": "Октябрь. Москва. 2:47 ночи. Виктор Краснов, один из богатейших людей страны, найден мёртвым в своём пентхаусе. Официально — самоубийство. Пистолет в правой руке. Но Краснов был левшой.",
  "cards": {

    "act1_scene1": {
      "id": "act1_scene1",
      "act": 1, "actTitle": "АКТ I · МЕСТО ПРЕСТУПЛЕНИЯ",
      "type": "crime", "icon": "🔍",
      "title": "Пентхаус на Садовом",
      "text": "Тело лежит у окна. Разбитое стекло — но осколки внутри, не снаружи. Пистолет зажат в правой руке. Коллега говорит: «Всё ясно, самоубийство». Вы смотрите на руку. Краснов был левшой.",
      "leftOption": "ОСМОТРЕТЬ ТЕЛО",
      "rightOption": "ОПРОСИТЬ ОХРАНУ",
      "leftNext": "act1_body",
      "rightNext": "act1_guard",
      "leftResult": "На запястье — следы борьбы. Под ногтем левой руки — красное волокно. Это убийство.",
      "rightResult": "Охранник Базаров явно нервничает. Его показания противоречат записям журнала входа.",
      "hint": "Осколки разбитого стекла на ПОЛУ, а не за окном. Кто-то разбил стекло изнутри уже ПОСЛЕ смерти Краснова — чтобы создать иллюзию борьбы. Это ключевая улика.",
      "hintGame": "universal",
      "cardStyle": "crime"
    },

    "act1_body": {
      "id": "act1_body",
      "act": 1, "actTitle": "АКТ I · ОСМОТР ТЕЛА",
      "type": "evidence", "icon": "🔬",
      "title": "Улика на теле",
      "text": "Судмедэксперт шепчет вам на ухо: смерть наступила от удара тупым предметом. Выстрел произведён в мёртвое тело. На шее — едва заметный след. Под ногтем — красное волокно дорогой ткани ручной работы.",
      "leftOption": "ЗАПРОСИТЬ ЛАБОРАТОРИЮ",
      "rightOption": "НАЙТИ ИСТОЧНИК ВОЛОКНА",
      "leftNext": "act1_lab",
      "rightNext": "act1_fiber",
      "leftResult": "Лаборатория подтверждает: смерть от удара в 22:30, выстрел — в 22:52. Убийца имел двадцать две минуты на инсценировку.",
      "rightResult": "Ателье 'Матиас'. Ткань такого состава шьётся только там. Два клиента в этом сезоне — один из них Дмитрий Орлов.",
      "hint": "Порядок смерти — это всё. Удар, потом выстрел. Убийца знал что делает: оглушил, подождал, выстрелил. Ищите кто знал распорядок вечера Краснова.",
      "hintGame": "doctor",
      "cardStyle": "evidence"
    },

    "act1_guard": {
      "id": "act1_guard",
      "act": 1, "actTitle": "АКТ I · ДОПРОС ОХРАНЫ",
      "type": "suspect", "icon": "👁️",
      "title": "Начальник охраны",
      "text": "Семён Базаров. 15 лет верной службы у Краснова. Сегодня он отводит взгляд. Журнал: «гость покинул здание в 22:47». Камера наружного наблюдения из соседнего здания зафиксировала другое — 23:14. Разница в 27 минут.",
      "leftOption": "НАДАВИТЬ НА БАЗАРОВА",
      "rightOption": "ЗАПРОСИТЬ ВСЕ КАМЕРЫ",
      "leftNext": "act1_pressure",
      "rightNext": "act1_cameras",
      "leftResult": "'Мне дали конверт. Наличные. Велели изменить время и молчать. Я не знал что это связано со смертью...'",
      "rightResult": "Три минуты записи стёрты. Но камера напротив зафиксировала красный пиджак, выходящий из здания в 23:09.",
      "hint": "Базаров солгал насчёт времени. Это не случайность — его купили. Выясните: ЧЬЁ алиби он прикрывал эти 27 минут.",
      "hintGame": "detective",
      "cardStyle": "suspect"
    },

    "act1_lab": {
      "id": "act1_lab",
      "act": 1, "actTitle": "АКТ I · ЛАБОРАТОРИЯ",
      "type": "evidence", "icon": "🧪",
      "title": "Заключение эксперта",
      "text": "В крови Краснова — следы редкого снотворного. Доступно только в медицинских учреждениях. Добавлено, судя по концентрации, в алкоголь — в тот виски, который Краснов пил каждый вечер в одиночестве. Кто знал об этой привычке?",
      "leftOption": "ИСКАТЬ ИСТОЧНИК ПРЕПАРАТА",
      "rightOption": "ОПРОСИТЬ БЛИЗКИХ",
      "leftNext": "act1_pharmacy",
      "rightNext": "act2_suspects",
      "leftResult": "Рецептурный журнал: вещество заказано три дня назад на имя Наталья Волк — личная секретарша Краснова.",
      "rightResult": "Жена Елена знала о привычке. Секретарша Наташа знала. И деловой партнёр Орлов — он бывал на поздних встречах в пентхаусе.",
      "hint": "Снотворное в виски — это не спонтанное убийство. Это подготовка. Кто имел возможность подмешать препарат? Кто был в пентхаусе накануне?",
      "hintGame": "universal",
      "cardStyle": "evidence"
    },

    "act1_fiber": {
      "id": "act1_fiber",
      "act": 1, "actTitle": "АКТ I · КРАСНЫЙ ПИДЖАК",
      "type": "suspect", "icon": "🔴",
      "title": "Нить к убийце",
      "text": "Ателье 'Матиас', Кузнецкий мост. VIP-база: два клиента заказывали ткань этого состава в этом сезоне. Первый — Дмитрий Орлов, деловой партнёр жертвы. Его сделка с Красновым рухнула три недели назад. Потерял три миллиарда.",
      "leftOption": "ВЫЗВАТЬ ОРЛОВА",
      "rightOption": "СЛЕДИТЬ ЗА ОРЛОВЫМ",
      "leftNext": "act2_orlov_direct",
      "rightNext": "act2_orlov_tail",
      "leftResult": "Орлов является с адвокатом Штейном. Алиби — корпоратив, двести свидетелей. Но ДНК на волокне — не его. Второй клиент ателье?",
      "rightResult": "Орлов встречается с молодой женщиной в кафе на Патриарших. Долгий разговор. Вы успеваете сфотографировать. Это Наташа Волк, секретарша жертвы.",
      "hint": "Если ДНК на волокне не совпало с Орловым — ткань носил кто-то другой. Ателье выдало ДВУХ клиентов. Узнайте кто второй — это и есть человек в красном пиджаке.",
      "hintGame": "detective",
      "cardStyle": "suspect"
    },

    "act1_pharmacy": {
      "id": "act1_pharmacy",
      "act": 1, "actTitle": "АКТ I · СЕКРЕТАРША",
      "type": "witness", "icon": "💊",
      "title": "Наталья Волк",
      "text": "Квартира Наташи Волк. Закрыто. Соседи говорят: уехала срочно три дня назад с большой сумкой. На кухонном столе — три пустых блистера от препарата. И распечатка расписания Краснова на ближайший месяц.",
      "leftOption": "ОБЪЯВИТЬ В РОЗЫСК",
      "rightOption": "ОБЫСКАТЬ КВАРТИРУ",
      "leftNext": "act2_natasha_caught",
      "rightNext": "act1_apt",
      "leftResult": "Наташа задержана на Белорусском вокзале. При ней загранпаспорт и 280 тысяч евро наличными. 'Мне угрожали. Мне заплатили.'",
      "rightResult": "В ящике стола — записная книжка. Зашифрованные записи. Одно слово встречается девять раз: «Призрак».",
      "hint": "Препарат + расписание Краснова = Наташа знала план. Но 280 тысяч евро говорят, что она не организатор — она наёмный исполнитель. Кто её нанял?",
      "hintGame": "doctor",
      "cardStyle": "witness"
    },

    "act1_cameras": {
      "id": "act1_cameras",
      "act": 1, "actTitle": "АКТ I · ЗАПИСЬ",
      "type": "evidence", "icon": "📹",
      "title": "Три минуты тишины",
      "text": "Запись с камеры соседнего дома. Фигура в красном пиджаке и кепке выходит в 23:09. Лицо не видно. Но через секунду — правая рука. На ней кольцо с синим камнем. Массивное. Эксклюзивное.",
      "leftOption": "УСТАНОВИТЬ ВЛАДЕЛЬЦА КОЛЬЦА",
      "rightOption": "ВОССТАНОВИТЬ СТЁРТЫЕ ЗАПИСИ",
      "leftNext": "act2_ring",
      "rightNext": "act2_digital",
      "leftResult": "Ювелир Микаэлян: кольцо изготовлено в единственном экземпляре. Заказчик — Дмитрий Орлов. Он лгал об алиби.",
      "rightResult": "Форензик-эксперт восстанавливает 47 секунд. На них — лицо. Система распознавания: Базаров. Он сам впустил убийцу и получил деньги.",
      "hint": "Три минуты не случайно удалены именно этот промежуток. В них — ключевой момент. Восстановление даёт лицо, кольцо даёт имя. Оба пути ведут к ответу.",
      "hintGame": "universal",
      "cardStyle": "evidence"
    },

    "act1_pressure": {
      "id": "act1_pressure",
      "act": 1, "actTitle": "АКТ I · ПРИЗНАНИЕ",
      "type": "testimony", "icon": "🗣️",
      "title": "Базаров говорит",
      "text": "Базаров получил конверт с деньгами через курьерскую службу. Без имени отправителя. Курьер — молодой, светловолосый. Описание совпадает с тысячей людей в Москве. Но в конверте была записка: 'Сервис NextDay, заказ 4477.'",
      "leftOption": "НАЙТИ КУРЬЕРА",
      "rightOption": "ПРОСЛЕДИТЬ ДЕНЬГИ",
      "leftNext": "act2_courier",
      "rightNext": "act2_money",
      "leftResult": "Курьерский сервис: заказ оплачен картой. Карта — на имя подставного ИП. Но адрес самовывоза: бизнес-центр 'Меркурий', офис 1214. Арендатор — Орлов Групп.",
      "rightResult": "Банковский след. Деньги — из ООО 'Тень'. Офшор, Кипр. Тот же счёт финансировал регистрацию несуществующего ЧОП 'Безопасность+' полгода назад.",
      "hint": "Деньги всегда оставляют след. Офшор 'Тень' связан с несуществующей охранной компанией — обе появились в одно время. Это подготовка за несколько месяцев.",
      "hintGame": "universal",
      "cardStyle": "testimony"
    },

    "act1_apt": {
      "id": "act1_apt",
      "act": 1, "actTitle": "АКТ I · ЗАПИСНАЯ КНИЖКА",
      "type": "mystery", "icon": "📓",
      "title": "Слово «Призрак»",
      "text": "В записях Наташи — шифр. Буква заменена цифрой по положению в алфавите. Ваш аналитик расшифровывает за двадцать минут. Содержание: инструкции, время, места встреч. И имя заказчика — зашифровано иначе. Только инициалы: Е.К.",
      "leftOption": "ИСКАТЬ «ПРИЗРАКА»",
      "rightOption": "ВЫЯСНИТЬ КТО Е.К.",
      "leftNext": "act2_ghost",
      "rightNext": "act2_ek",
      "leftResult": "ФСБ слышали это имя. Профессиональный ликвидатор. Специализация — инсценировки самоубийств. Примета: шрам над левой бровью.",
      "rightResult": "Е.К. — двое под эти инициалы в ближайшем окружении Краснова. Елена Краснова, вдова. И Евгений Крылов, финансовый директор. Кто из них?",
      "hint": "Инициалы — это намеренная осторожность. Наташа знала заказчика, но записала только инициалы на случай обыска. Установите ВСЕ Е.К. из окружения Краснова.",
      "hintGame": "detective",
      "cardStyle": "mystery"
    },

    "act2_suspects": {
      "id": "act2_suspects",
      "act": 2, "actTitle": "АКТ II · ПОДОЗРЕВАЕМЫЕ",
      "type": "briefing", "icon": "📋",
      "title": "Три фигуранта",
      "text": "Три человека с мотивом и возможностью. Елена Краснова — страховка 50 миллионов, холодна как лёд. Дмитрий Орлов — потерял три миллиарда из-за Краснова. Наташа Волк — исчезла с деньгами. Кто главный?",
      "leftOption": "ДОПРОСИТЬ ВДОВУ",
      "rightOption": "ПРОВЕРИТЬ ОРЛОВА",
      "leftNext": "act2_wife",
      "rightNext": "act2_orlov_direct",
      "leftResult": "'Я была у сестры в Петербурге. С шести вечера. Алиби проверяется.' Спокойна. Слишком спокойна для вдовы.",
      "rightResult": "Орлов на совещании. Его помощник приносит папку: 'Шеф просил помочь следствию.' Внутри — переписка Краснова с неизвестным абонентом.",
      "hint": "Хладнокровие вдовы — красный флаг. Нормальная реакция на смерть мужа — слёзы или шок. Её спокойствие говорит об одном: она знала это произойдёт.",
      "hintGame": "universal",
      "cardStyle": "briefing"
    },

    "act2_wife": {
      "id": "act2_wife",
      "act": 2, "actTitle": "АКТ II · ВДОВА",
      "type": "suspect", "icon": "💍",
      "title": "Елена Краснова",
      "text": "Тридцать восемь лет. Красивая. Ни одной слезы за три дня. 'Мы давно жили параллельной жизнью.' Страховой полис на 50 миллионов подписан семь месяцев назад. Именно тогда в жизни Краснова появился некий Воронов из ЧОП 'Безопасность+'.",
      "leftOption": "ПОТРЕБОВАТЬ ТЕЛЕФОН",
      "rightOption": "ПРОВЕРИТЬ АЛИБИ",
      "leftNext": "act2_phone",
      "rightNext": "act2_alibi_wife",
      "leftResult": "Судья выдаёт ордер. В переписке — шестьсот сообщений с номером без имени. Последнее: 'Всё готово. Завтра.' Отправлено в 21:44.",
      "rightResult": "Сестра в Питере подтверждает. Но билет куплен в 17:50. Убийство — в 22:30. Москва-Петербург четыре часа поездом. Теоретически успевала вернуться.",
      "hint": "Страховой полис + появление убийцы в одно время = это не совпадение. Семь месяцев назад Елена начала готовить убийство. Проверьте её контакты за тот период.",
      "hintGame": "doctor",
      "cardStyle": "suspect"
    },

    "act2_orlov_direct": {
      "id": "act2_orlov_direct",
      "act": 2, "actTitle": "АКТ II · ОРЛОВ",
      "type": "suspect", "icon": "💼",
      "title": "Деловой партнёр",
      "text": "Орлов пришёл с адвокатом Германом Штейном. Корпоратив подтверждают двести человек. Но вы замечаете: левый ботинок в характерной грязи. Здесь дождь был только в одном районе — Садовое кольцо, рядом с домом Краснова.",
      "leftOption": "АНАЛИЗ ГРЯЗИ",
      "rightOption": "КОПАТЬ ФИНАНСЫ",
      "leftNext": "act2_mud",
      "rightNext": "act2_money",
      "leftResult": "Почвенный анализ: специфический состав — только с набережной Садового. Орлов был там в ночь убийства. Адвокат требует немедленно прекратить допрос.",
      "rightResult": "Переводы: 15 миллионов ушло через ООО 'Тень' — та самая офшорная компания. Цепочка от Базарова тянется прямо к Орлову.",
      "hint": "Грязь на ботинке — это то, что не контролируют. Корпоратив может быть алиби, но Орлов успел съездить на Садовое и вернуться. Время убийства 22:30 — мог ли он успеть?",
      "hintGame": "universal",
      "cardStyle": "suspect"
    },

    "act2_orlov_tail": {
      "id": "act2_orlov_tail",
      "act": 2, "actTitle": "АКТ II · СЛЕЖКА",
      "type": "evidence", "icon": "📸",
      "title": "Встреча на Патриарших",
      "text": "Орлов и Наташа Волк. Час разговора в кафе. Вы сидите за соседним столиком. Слышны обрывки: 'деньги переведены', 'он не должен был', 'если найдут — мы оба'. На выходе Наташа плачет.",
      "leftOption": "ЗАДЕРЖАТЬ НАТАШУ",
      "rightOption": "ВЕСТИ ОРЛОВА ДАЛЬШЕ",
      "leftNext": "act2_natasha_caught",
      "rightNext": "act2_ghost",
      "leftResult": "Наташа: 'Орлов заплатил мне добавить препарат. Сказал что Краснова только усыпят и вывезут. Я не знала что убьют. Клянусь.'",
      "rightResult": "Орлов едет в отель 'Националь'. Номер 314. Через двадцать минут оттуда выходит мужчина в кепке. Шрам над левой бровью.",
      "hint": "Наташа была посредником. Орлов дал деньги и инструкции — она исполнила свою часть, не зная всего плана. Убийство организовано в несколько слоёв намеренно.",
      "hintGame": "doctor",
      "cardStyle": "evidence"
    },

    "act2_ghost": {
      "id": "act2_ghost",
      "act": 2, "actTitle": "АКТ II · ПРИЗРАК",
      "type": "mystery", "icon": "👻",
      "title": "Кодовое имя",
      "text": "ФСБ знает это имя. «Призрак» — профессиональный ликвидатор, специализируется на инсценировках. Двенадцать подозрений, ни одного обвинения. Документов нет. Единственная примета во всех делах — шрам над левой бровью. Сейчас он в Москве.",
      "leftOption": "ЗАПРОСИТЬ ФСБ",
      "rightOption": "ИСКАТЬ САМОСТОЯТЕЛЬНО",
      "leftNext": "act2_fsb",
      "rightNext": "act2_voronov",
      "leftResult": "ФСБ даёт частичный доступ. Последнее известное дело — Екатеринбург, 18 месяцев назад. Та же схема. Жертва — бизнесмен. Заказчик — партнёр по бизнесу.",
      "rightResult": "Базы данных, частные детективы. Через двое суток — фото. Зарегистрирован в отеле 'Националь' как Смирнов Игорь. Номер 314.",
      "hint": "Призрак не задерживается после задания. Если он ещё в Москве — ждёт финального платежа. Это ваш единственный шанс его поймать. Действуйте быстро.",
      "hintGame": "detective",
      "cardStyle": "mystery"
    },

    "act2_voronov": {
      "id": "act2_voronov",
      "act": 2, "actTitle": "АКТ II · ОТЕЛЬ",
      "type": "action", "icon": "🏃",
      "title": "Номер 314",
      "text": "Дверь приоткрыта. Внутри — опрокинутый стул, следы спешки. На столе — мобильный телефон. Один контакт: «Заказчик». Последнее сообщение: 'Финальный платёж после закрытия дела полицией. Жди.' Телефон оставлен намеренно или забыт?",
      "leftOption": "ВЗЯТЬ ТЕЛЕФОН",
      "rightOption": "ВЫСТАВИТЬ ПОСТ",
      "leftNext": "act3_phone_ghost",
      "rightNext": "act3_hotel_wait",
      "leftResult": "В истории звонков — три номера. Один определяется: зарегистрирован на Краснова Елену Михайловну.",
      "rightResult": "Через четыре часа Призрак возвращается. Вы выходите из тени. 'Воронов, руки.' Он смотрит на вас. Улыбается.",
      "hint": "Профессионал не забывает телефон. Он оставлен намеренно — либо как улика против конкурента, либо как ловушка для вас. Что ценнее: улика или задержание?",
      "hintGame": "doctor",
      "cardStyle": "action"
    },

    "act2_money": {
      "id": "act2_money",
      "act": 2, "actTitle": "АКТ II · ДЕНЬГИ",
      "type": "evidence", "icon": "💰",
      "title": "ООО «Тень»",
      "text": "Офшор на Кипре. Счёт открыт восемь месяцев назад. Источник средств — швейцарский банк. По официальным каналам ответ через три недели. Но ваш информатор в системе может ускорить. Риск: улика будет недопустимой в суде.",
      "leftOption": "ОФИЦИАЛЬНЫЙ ЗАПРОС",
      "rightOption": "ЧЕРЕЗ ИНФОРМАТОРА",
      "leftNext": "act2_interpol",
      "rightNext": "act2_informant",
      "leftResult": "Три недели ожидания. Результат: счёт открыт с московского IP — офис 'Орлов Групп'. Допустимо в суде.",
      "rightResult": "Немедленно. Результат: счёт открыт на двух подписантов — Орлов Дмитрий и Краснова Елена. Они действовали вместе. Но в суде — недопустимо.",
      "hint": "Официальный путь — медленно, но работает в суде. Неофициальный — быстро, но может быть исключён. Если у вас уже есть другие доказательства, ускорение может не понадобиться.",
      "hintGame": "universal",
      "cardStyle": "evidence"
    },

    "act2_ek": {
      "id": "act2_ek",
      "act": 2, "actTitle": "АКТ II · ИНИЦИАЛЫ",
      "type": "mystery", "icon": "🔤",
      "title": "Кто такой Е.К.?",
      "text": "Елена Краснова — вдова, страховка, хладнокровие. Евгений Крылов — финдиректор, знал все финансовые потоки компании, был уволен Красновым два месяца назад без выходного пособия. У обоих мотив. Один из них организатор убийства.",
      "leftOption": "ПРОВЕРИТЬ ЕЛЕНУ",
      "rightOption": "ПРОВЕРИТЬ КРЫЛОВА",
      "leftNext": "act2_wife",
      "rightNext": "act2_krylov",
      "leftResult": "Елена знала о привычке мужа — виски по вечерам. Знала расписание. Совместный счёт закрыт три месяца назад — она готовилась к разводу или... к этому.",
      "rightResult": "Крылов: алиби железное — был в командировке в Новосибирске. Гостиница, перелёт, коллеги. Он не мог. Значит — Елена.",
      "hint": "Исключение метод. Если у Крылова железное алиби — значит Е.К. это Елена. Но убедитесь что алиби Крылова настоящее, а не купленное как у Базарова.",
      "hintGame": "detective",
      "cardStyle": "mystery"
    },

    "act2_phone": {
      "id": "act2_phone",
      "act": 2, "actTitle": "АКТ II · ТЕЛЕФОН ЕЛЕНЫ",
      "type": "revelation", "icon": "📱",
      "title": "600 сообщений",
      "text": "Шестьсот сообщений с одним номером за семь месяцев. Последнее — 21:44 в день убийства: 'Всё готово. Завтра.' Номер зарегистрирован на SIM-карту, купленную за наличные в киоске у метро. Тупик? Нет. Геолокация последнего сообщения.",
      "leftOption": "ПРОБИТЬ ГЕОЛОКАЦИЮ",
      "rightOption": "ВОССТАНОВИТЬ ВСЮ ПЕРЕПИСКУ",
      "leftNext": "act3_location",
      "rightNext": "act3_full_chat",
      "leftResult": "Сообщение отправлено из радиуса 200 метров от отеля 'Националь'. Именно там жил Призрак. Связь установлена.",
      "rightResult": "Переписка восстановлена. В ней — детальный план: дата, время, метод, способ оплаты. Достаточно для обвинительного приговора.",
      "hint": "Геолокация телефона не обманывает — это технический факт. Если сообщение отправлено от 'Националя', значит Елена лично встречалась с Призраком.",
      "hintGame": "universal",
      "cardStyle": "revelation"
    },

    "act2_natasha_caught": {
      "id": "act2_natasha_caught",
      "act": 2, "actTitle": "АКТ II · ЗАДЕРЖАНИЕ",
      "type": "testimony", "icon": "😭",
      "title": "Наташа говорит",
      "text": "Наташа рыдает. Явка с повинной в обмен на смягчение. 'Елена Краснова подошла ко мне три месяца назад. Дала препарат. Сказала добавить в виски один раз. Что Виктора увезут и напугают — чтобы он подписал документы о разводе. Я не знала что убьют. Богом клянусь.'",
      "leftOption": "ПРИНЯТЬ СДЕЛКУ",
      "rightOption": "ИСКАТЬ ДОПОЛНИТЕЛЬНОЕ ПОДТВЕРЖДЕНИЕ",
      "leftNext": "act3_deal",
      "rightNext": "act3_corroborate",
      "leftResult": "Сделка подписана. Показания Наташи — ключевое звено. Теперь нужно найти самого Призрака и арестовать Елену.",
      "rightResult": "На телефоне Наташи — удалённые переписки. Восстановлены. В них — голосовое от Елены: узнаваемый голос, конкретные инструкции. Железное доказательство.",
      "hint": "Показания сообщника весомее если подкреплены техническими доказательствами. Голосовое сообщение не оспорить. Найдите его.",
      "hintGame": "doctor",
      "cardStyle": "testimony"
    },

    "act2_ring": {
      "id": "act2_ring",
      "act": 2, "actTitle": "АКТ II · КОЛЬЦО",
      "type": "evidence", "icon": "💍",
      "title": "Единственный экземпляр",
      "text": "Ювелир Микаэлян. Кольцо с сапфиром в массивной оправе. Изготовлено в единственном экземпляре по индивидуальному заказу. Заказчик назван немедленно — клиент VIP-уровня. Орлов Дмитрий Игоревич. Кольцо стоит 600 тысяч рублей. Он лгал о своём алиби.",
      "leftOption": "ПРЕДЪЯВИТЬ ОРЛОВУ",
      "rightOption": "СНАЧАЛА СОБРАТЬ ВСЮ ЦЕПЬ",
      "leftNext": "act3_orlov_ring",
      "rightNext": "act2_money",
      "leftResult": "Орлов бледнеет. 'Я потерял кольцо неделю назад.' Ложь — это видно. Адвокат Штейн требует прерваться. Но Орлов уже сломлен.",
      "rightResult": "С кольцом, деньгами и грязью на ботинке — это неопровержимо. Вы берёте ордер на арест и ждёте Орлова у входа в его офис.",
      "hint": "Предъявлять улику раньше времени — рискованно: адвокат может придумать объяснение. Имея несколько улик, лучше предъявить все вместе — тогда алиби не спасёт.",
      "hintGame": "detective",
      "cardStyle": "evidence"
    },

    "act3_phone_ghost": {
      "id": "act3_phone_ghost",
      "act": 3, "actTitle": "АКТ III · ЗАКАЗЧИК",
      "type": "revelation", "icon": "📞",
      "title": "Номер Елены",
      "text": "Телефон Призрака. Контакт «Заказчик» — номер определён. Елена Краснова. Три звонка за последнюю неделю. Последний — сегодня утром. Она ещё не знает что вы здесь. У вас есть фактор неожиданности. Как использовать его?",
      "leftOption": "АРЕСТОВАТЬ ЕЛЕНУ СЕЙЧАС",
      "rightOption": "ПОСТАВИТЬ ПРОСЛУШКУ",
      "leftNext": "act3_elena_arrest",
      "rightNext": "act3_wiretap",
      "leftResult": "Елену берут в ресторане 'Пушкин'. При свидетелях. Адвокат рядом немедленно. Но телефонный номер — железное доказательство.",
      "rightResult": "Через два часа Елена сама звонит Призраку: 'Соколов всё ближе. Уходи сегодня.' Запись сделана. Этого достаточно для ордера.",
      "hint": "Ранний арест рискует: адвокат разобьёт одно доказательство. Прослушка даёт ей возможность самой себя разоблачить — это в разы сильнее в суде.",
      "hintGame": "universal",
      "cardStyle": "revelation"
    },

    "act3_hotel_wait": {
      "id": "act3_hotel_wait",
      "act": 3, "actTitle": "АКТ III · ЗАСАДА",
      "type": "action", "icon": "🎯",
      "title": "Четыре часа ожидания",
      "text": "3:15 ночи. Коридор тих. Потом — шаги. Призрак входит в номер. Вы выходите из тени. Он оборачивается. Шрам над левой бровью. В его глазах — не страх. Интерес. 'Ты хороший, Соколов. Двенадцать дел — и никто так близко не подходил.'",
      "leftOption": "СКОВАТЬ НЕМЕДЛЕННО",
      "rightOption": "ДАТЬ ЕМУ ГОВОРИТЬ",
      "leftNext": "act3_capture_silent",
      "rightNext": "act3_surrender",
      "leftResult": "Призрак задержан. Молчит. Без показаний дело против заказчиков слабее. Но он за решёткой.",
      "rightResult": "Он говорит: 'Елена Краснова. Орлов знал о плане, но не организовывал. Только финансировал через Наташу. Я дам показания. Мне надоело.'",
      "hint": "Профессионал который улыбается при задержании — это нестандартно. Возможно он давно ищет выход. Дать ему говорить — риск, но потенциально даёт всё дело целиком.",
      "hintGame": "doctor",
      "cardStyle": "action"
    },

    "act3_surrender": {
      "id": "act3_surrender",
      "act": 3, "actTitle": "АКТ III · ИСПОВЕДЬ УБИЙЦЫ",
      "type": "revelation", "icon": "🕊️",
      "title": "Воронов говорит",
      "text": "Воронов (настоящее имя Алексей Сенин, бывший офицер ФСБ) даёт полные показания. Елена наняла его напрямую. Орлов финансировал Наташу отдельно — не зная что Елена тоже действует. Два независимых заговора случайно совпали в одну ночь.",
      "leftOption": "ЗАФИКСИРОВАТЬ ПОКАЗАНИЯ",
      "rightOption": "УТОЧНИТЬ ДЕТАЛИ ОРЛОВА",
      "leftNext": "ending_perfect",
      "rightNext": "act3_orlov_detail",
      "leftResult": "Показания Воронова + телефон + деньги + Наташа = дело закрыто полностью. Все трое будут осуждены.",
      "rightResult": "Орлов нанял Наташу через офшор. Хотел только усыпить Краснова и вывезти — заставить подписать бумаги. Убийство не планировал. Это важно для квалификации преступления.",
      "hint": "Детали про Орлова меняют квалификацию: организатор убийства или соучастник? Это разница в сроке. Но основное дело и так раскрыто.",
      "hintGame": "universal",
      "cardStyle": "revelation"
    },

    "act3_elena_arrest": {
      "id": "act3_elena_arrest",
      "act": 3, "actTitle": "АКТ III · АРЕСТ",
      "type": "action", "icon": "⚖️",
      "title": "Маска падает",
      "text": "Ресторан 'Пушкин'. Елена за столиком с подругами. Вы подходите. Кладёте на стол распечатку её номера из телефона Призрака. Смотрите ей в глаза. Долгая пауза. Потом она говорит тихо: 'Он заслуживал этого. Он украл у меня двенадцать лет жизни.'",
      "leftOption": "ПРОДОЛЖИТЬ РАБОТУ",
      "rightOption": "ЗАКРЫТЬ ДЕЛО",
      "leftNext": "act3_orlov_detail",
      "rightNext": "ending_elena",
      "leftResult": "Показания Елены указывают на Орлова. С его офшором — полная картина. Оба идут под суд.",
      "rightResult": "Дело закрыто. Елена получит двадцать лет. Орлов под следствием. Призрак в бегах — но вы знаете его лицо.",
      "hint": "Признание в ресторане, если записано — является доказательством. Включили ли вы диктофон перед тем как подойти к столику?",
      "hintGame": "doctor",
      "cardStyle": "action"
    },

    "act3_orlov_detail": {
      "id": "act3_orlov_detail",
      "act": 3, "actTitle": "АКТ III · ОРЛОВ",
      "type": "revelation", "icon": "📄",
      "title": "Финансовая цепь",
      "text": "ООО 'Тень' — деньги Орлова. Он финансировал Наташу: 'Только усыпи его, мы подпишем бумаги и уйдём.' Орлов не знал об Елене. Не знал что Краснова убьют. Но его деньги профинансировали цепочку. Это соучастие или нет?",
      "leftOption": "АРЕСТОВАТЬ ЗА СОУЧАСТИЕ",
      "rightOption": "ДАТЬ ПОКАЗАТЬ ПРОТИВ ЕЛЕНЫ",
      "leftNext": "ending_all_three",
      "rightNext": "ending_perfect",
      "leftResult": "Орлов арестован. Суд решит вопрос соучастия. Но прокурор доволен: вся схема разоблачена.",
      "rightResult": "Орлов, испугавшись соучастия, даёт подробнейшие показания против Елены. Его показания + Воронов = Елена получит максимальный срок.",
      "hint": "Орлов хочет сотрудничать — это ваш рычаг. Сделка: показания против Елены в обмен на смягчение обвинения. Это стандартная практика.",
      "hintGame": "universal",
      "cardStyle": "revelation"
    },

    "act2_fsb": {
      "id": "act2_fsb",
      "act": 2, "actTitle": "АКТ II · ФСБ",
      "type": "briefing", "icon": "🛡️",
      "title": "Досье силовиков",
      "text": "Частичный доступ к оперативным материалам. 'Призрак' — бывший офицер спецназа, завербованный частными структурами в 2019 году. Три подтверждённых операции, ни одного ареста. Последний след — Екатеринбург, та же схема: снотворное, выстрел, инсценировка. Заказчик — бизнес-партнёр жертвы.",
      "leftOption": "ПОЛУЧИТЬ ФОТО",
      "rightOption": "НАЙТИ ПАТТЕРН ЗАКАЗЧИКОВ",
      "leftNext": "act2_voronov",
      "rightNext": "act2_pattern",
      "leftResult": "Фото из Екатеринбургского дела. Мужчина, кепка, шрам над левой бровью. Загружаю в систему распознавания. Москва. Отель 'Националь'.",
      "rightResult": "Во всех делах Призрака — один тип заказчика: деловой партнёр или супруг/супруга. Всегда финансовый мотив. Всегда офшорная цепочка. Всегда подставной посредник.",
      "hint": "Паттерн преступника — это профиль. Если Призрак всегда работает для партнёров или супругов с финансовым мотивом — у вас уже есть список подозреваемых.",
      "hintGame": "detective",
      "cardStyle": "briefing"
    },

    "act2_interpol": {
      "id": "act2_interpol",
      "act": 2, "actTitle": "АКТ II · ИНТЕРПОЛ",
      "type": "evidence", "icon": "🌐",
      "title": "Три недели ожидания",
      "text": "Ответ из Швейцарии пришёл. Счёт открыт с московского IP-адреса — принадлежит бизнес-центру 'Меркурий'. Арендаторы: пятьдесят четыре компании. Среди них — 'Орлов Групп'. Допустимо в суде. Цепочка доказательств замкнулась.",
      "leftOption": "БРАТЬ ОРЛОВА",
      "rightOption": "ЖДАТЬ И СОБРАТЬ БОЛЬШЕ",
      "leftNext": "act3_orlov_ring",
      "rightNext": "act2_phone",
      "leftResult": "Ордер выдан. Орлов задержан при выходе из офиса. При обыске — ноутбук с зашифрованной перепиской.",
      "rightResult": "Пока вы ждали — появился телефон Призрака. С именем Елены. Теперь у вас ОБА организатора.",
      "hint": "Дождавшись телефона Призрака вы получаете второго организатора — Елену. Это делает дело полным. Арест Орлова сейчас может спугнуть её.",
      "hintGame": "universal",
      "cardStyle": "evidence"
    },

    "act2_informant": {
      "id": "act2_informant",
      "act": 2, "actTitle": "АКТ II · ИНФОРМАТОР",
      "type": "testimony", "icon": "🤝",
      "title": "Быстрый ответ",
      "text": "Информатор называет двух подписантов счёта: Орлов и Елена Краснова. Они вместе финансировали убийство. Но улика недопустима в суде — информатор не может появляться на процессе. Вам нужно найти легальное подтверждение той же информации.",
      "leftOption": "ОФИЦИАЛЬНЫЙ ЗАПРОС ТЕПЕРЬ",
      "rightOption": "ИСКАТЬ ПОДТВЕРЖДЕНИЕ ИНАЧЕ",
      "leftNext": "act2_interpol",
      "rightNext": "act2_phone",
      "leftResult": "Официальный запрос займёт ещё три недели. Но вы знаете что ищете — это ускоряет работу.",
      "rightResult": "Телефон Призрака даёт имя Елены напрямую. Это и есть легальное подтверждение совместного умысла.",
      "hint": "Иметь информацию и иметь доказательство — разные вещи. Используйте информацию информатора как ориентир для поиска легальных улик.",
      "hintGame": "universal",
      "cardStyle": "testimony"
    },

    "act3_wiretap": {
      "id": "act3_wiretap",
      "act": 3, "actTitle": "АКТ III · ПРОСЛУШКА",
      "type": "revelation", "icon": "🎤",
      "title": "Елена разоблачает себя",
      "text": "Прослушка санкционирована. Через два часа Елена сама звонит Призраку. 'Соколов почти у цели. Уходи через аэропорт Шереметьево, билет до Вены.' Запись сделана. Но Призрак уже в вашей засаде в отеле. Он не уйдёт.",
      "leftOption": "АРЕСТОВАТЬ ЕЛЕНУ НЕМЕДЛЕННО",
      "rightOption": "ПОЙМАТЬ ПРИЗРАКА СНАЧАЛА",
      "leftNext": "act3_elena_arrest",
      "rightNext": "act3_hotel_wait",
      "leftResult": "Елена арестована. Запись звонка — ключевое доказательство. Призрак услышав об аресте Елены сам сдаётся через три дня.",
      "rightResult": "Призрак задержан в отеле. С его показаниями арест Елены — формальность. Дело раскрыто полностью.",
      "hint": "Обе цели достижимы. Вопрос в том, какое доказательство сильнее в суде: запись телефонного разговора или показания самого убийцы?",
      "hintGame": "doctor",
      "cardStyle": "revelation"
    },

    "act3_deal": {
      "id": "act3_deal",
      "act": 3, "actTitle": "АКТ III · СДЕЛКА",
      "type": "testimony", "icon": "📝",
      "title": "Показания против заказчика",
      "text": "Наташа подписала сделку. Её показания детальны и точны. Голосовое сообщение Елены с инструкциями — приобщено к делу. Теперь нужно найти Призрака. Наташа знает номер телефона — тот самый, без имени. С него можно вычислить геолокацию.",
      "leftOption": "ПРОБИТЬ ГЕОЛОКАЦИЮ ТЕЛЕФОНА",
      "rightOption": "ИСПОЛЬЗОВАТЬ НАТАШУ КАК ПРИМАНКУ",
      "leftNext": "act2_voronov",
      "rightNext": "act3_hotel_wait",
      "leftResult": "Телефон сейчас активен. Отель 'Националь', Охотный ряд. Вы выезжаете.",
      "rightResult": "Наташа звонит Призраку: 'Мне нужно встретиться. Я видела что-то важное.' Он соглашается. Засада готова.",
      "hint": "Геолокация быстрее и точнее. Приманка рискованнее — Призрак может не прийти или прийти вооружённым. Но если он приходит — задержание на месте.",
      "hintGame": "detective",
      "cardStyle": "testimony"
    },

    "act3_capture_silent": {
      "id": "act3_capture_silent",
      "act": 3, "actTitle": "АКТ III · МОЛЧАНИЕ",
      "type": "action", "icon": "🔒",
      "title": "Без слов",
      "text": "Воронов задержан. Молчит. Адвокат прилетает из Лондона за 8 часов — явно приготовленный заранее. Без показаний Воронова дело против Елены слабее. Орлов арестован, но его адвокат требует выпустить за недостаточностью. У вас 72 часа до истечения срока задержания.",
      "leftOption": "РАБОТАТЬ С ДРУГИМИ УЛИКАМИ",
      "rightOption": "НАЙТИ СПОСОБ РАЗГОВОРИТЬ ВОРОНОВА",
      "leftNext": "act3_phone_ghost",
      "rightNext": "act3_surrender",
      "leftResult": "Телефон Призрака с номером Елены + переписка Наташи + офшор Орлова = достаточно для обвинения даже без показаний Воронова.",
      "rightResult": "Вы входите в камеру один. Без адвоката, без записи. 'Алексей Сенин. Я знаю ваше настоящее имя.' Пауза. Потом: 'Садитесь, Соколов.'",
      "hint": "Без показаний Воронова у вас всё равно достаточно улик. Но с его показаниями дело безупречно. Иногда убийца хочет поговорить — нужно создать правильные условия.",
      "hintGame": "universal",
      "cardStyle": "action"
    },

    "act3_corroborate": {
      "id": "act3_corroborate",
      "act": 3, "actTitle": "АКТ III · ПОДТВЕРЖДЕНИЕ",
      "type": "testimony", "icon": "🎙️",
      "title": "Голос Елены",
      "text": "На телефоне Наташи — голосовое сообщение. Двадцать секунд. Голос Елены Красновой: конкретные инструкции, время, место, слово «виски». Голосовая экспертиза подтверждает подлинность на 99,7%. Это не косвенная улика — это прямое доказательство.",
      "leftOption": "АРЕСТОВАТЬ ЕЛЕНУ",
      "rightOption": "СНАЧАЛА ВЗЯТЬ ПРИЗРАКА",
      "leftNext": "act3_elena_arrest",
      "rightNext": "act2_ghost",
      "leftResult": "Голосовое + показания Наташи = ордер выдан немедленно. Елена взята ещё до звонка адвокату.",
      "rightResult": "С голосовым вы сможете арестовать Елену в любой момент. Сначала нейтрализуйте убийцу, пока он не сбежал из страны.",
      "hint": "Голосовое сообщение на 99.7% — это настолько сильное доказательство, что Елену можно брать в любое удобное время. Призрак же может исчезнуть.",
      "hintGame": "doctor",
      "cardStyle": "testimony"
    },

    "act3_location": {
      "id": "act3_location",
      "act": 3, "actTitle": "АКТ III · ГЕОЛОКАЦИЯ",
      "type": "revelation", "icon": "📍",
      "title": "200 метров от убийцы",
      "text": "Сообщение 'Всё готово. Завтра' отправлено в 21:44 из радиуса 200 метров от отеля 'Националь'. Именно там — Призрак. Елена встретилась с ним лично перед убийством. Это доказывает предумышленность и организацию. Суд будет доволен.",
      "leftOption": "ВЗЯТЬ ЕЛЕНУ",
      "rightOption": "СНАЧАЛА ВЗЯТЬ ПРИЗРАКА",
      "leftNext": "act3_elena_arrest",
      "rightNext": "act3_hotel_wait",
      "leftResult": "Елена задержана. Геолокация + телефон Призрака = заговор доказан.",
      "rightResult": "Оба задержаны в течение двух часов. Совершенная финальная сцена.",
      "hint": "Если взять обоих одновременно — это идеально. Если последовательно — начните с тем кто может быстрее сбежать. Призрак скорее исчезнет чем Елена.",
      "hintGame": "universal",
      "cardStyle": "revelation"
    },

    "act3_full_chat": {
      "id": "act3_full_chat",
      "act": 3, "actTitle": "АКТ III · ВСЯ ПЕРЕПИСКА",
      "type": "revelation", "icon": "💬",
      "title": "Семь месяцев планирования",
      "text": "Семь месяцев переписки. День за днём. Елена и Призрак обсуждали всё: способ, время, оплату, эвакуацию. Читая эти сообщения, вы понимаете: она ненавидела его. Каждое сообщение — холодное, расчётливое. Это не страсть. Это деловое решение об убийстве мужа.",
      "leftOption": "НЕМЕДЛЕННЫЙ АРЕСТ",
      "rightOption": "ЗАКРЫТЬ ПОЛНУЮ ЦЕПЬ",
      "leftNext": "ending_elena",
      "rightNext": "act3_orlov_detail",
      "leftResult": "Елена арестована с полным пакетом доказательств. Дело о преднамеренном убийстве с отягчающими обстоятельствами.",
      "rightResult": "Добавив Орлова и Воронова — всё трое. Максимальный срок для каждого.",
      "hint": "Семь месяцев переписки — это исчерпывающая доказательная база. Елена не отвертится. Вопрос только в том, включать ли в дело Орлова и Воронова.",
      "hintGame": "detective",
      "cardStyle": "revelation"
    },

    "act3_orlov_ring": {
      "id": "act3_orlov_ring",
      "act": 3, "actTitle": "АКТ III · ЛОВУШКА",
      "type": "action", "icon": "🎭",
      "title": "Орлов ломается",
      "text": "Вы кладёте на стол: фото кольца с камеры, анализ грязи с его ботинка, банковскую цепочку от Базарова. Орлов смотрит на три бумаги. Адвокат Штейн говорит: 'Не отвечайте'. Но Орлов поднимает руку. 'Штейн, выйдите'. Молчание.",
      "leftOption": "ЖДАТЬ МОЛЧА",
      "rightOption": "НАЧАТЬ ЗАДАВАТЬ ВОПРОСЫ",
      "leftNext": "act3_surrender",
      "rightNext": "act3_orlov_detail",
      "leftResult": "Пауза. Потом Орлов говорит тихо: 'Я не знал что убьют. Я хотел только документы. Но я не знал что там была ещё Елена со своим планом.'",
      "rightResult": "Вопрос за вопросом. Орлов отвечает. Его версия: он финансировал Наташу чтобы усыпить Краснова и получить подпись под бумагами. Убийство — неожиданность.",
      "hint": "Молчание иногда давит сильнее вопросов. Орлов видит доказательства и понимает что выхода нет. Дайте ему самому принять решение — это даёт более искренние показания.",
      "hintGame": "doctor",
      "cardStyle": "action"
    },

    "act2_digital": {
      "id": "act2_digital",
      "act": 2, "actTitle": "АКТ II · ФОРЕНЗИКА",
      "type": "evidence", "icon": "💾",
      "title": "47 секунд правды",
      "text": "Форензик-эксперт восстанавливает 47 секунд из стёртой записи. На них: Базаров принимает конверт. Лицо второго человека — размыто. Но на руке — массивное кольцо с синим камнем. Экспертиза разрешения займёт три часа.",
      "leftOption": "ЖДАТЬ УЛУЧШЕНИЯ КАЧЕСТВА",
      "rightOption": "ИСКАТЬ ВЛАДЕЛЬЦА КОЛЬЦА",
      "leftNext": "act2_enhance",
      "rightNext": "act2_ring",
      "leftResult": "Три часа. Нейросеть восстанавливает до 68% чёткости. Лицо — Орлов. Прямой контакт с Базаровым доказан.",
      "rightResult": "Ювелир называет имя сразу: Орлов. Быстрее, и не нужно ждать экспертизы.",
      "hint": "Оба пути ведут к Орлову. Кольцо быстрее — ювелир знает клиентов VIP-уровня. Улучшение изображения медленнее но даёт его лицо напрямую.",
      "hintGame": "detective",
      "cardStyle": "evidence"
    },

    "act2_enhance": {
      "id": "act2_enhance",
      "act": 2, "actTitle": "АКТ II · АНАЛИЗ ВИДЕО",
      "type": "evidence", "icon": "🔎",
      "title": "Лицо в пикселях",
      "text": "Нейросеть восстанавливает изображение. 68% чёткость — достаточно для идентификации. Система распознавания выдаёт три кандидата. Первый: 94% совпадение — Орлов Дмитрий Игоревич. Адвокат Штейн немедленно оспорит нейросеть в суде. Вам нужна подкрепляющая улика.",
      "leftOption": "ИСКАТЬ ПОДТВЕРЖДЕНИЕ",
      "rightOption": "ПРЕДЪЯВИТЬ ОРЛОВУ",
      "leftNext": "act2_ring",
      "rightNext": "act2_orlov_direct",
      "leftResult": "Кольцо на руке в кадре + результат нейросети = 99% идентификации. Адвокат не оспорит два независимых метода.",
      "rightResult": "Орлов смотрит на кадр. 94% — он знает что это он. 'Это не доказательство'. Но голос дрогнул.",
      "hint": "Нейросеть суды часто не принимают без второго подтверждения. Кольцо даёт это подтверждение — физическая улика не оспаривается.",
      "hintGame": "universal",
      "cardStyle": "evidence"
    },

    "act2_krylov": {
      "id": "act2_krylov",
      "act": 2, "actTitle": "АКТ II · ФИНДИРЕКТОР",
      "type": "suspect", "icon": "🧮",
      "title": "Евгений Крылов",
      "text": "Крылов уволен два месяца назад без выходного пособия. Мотив есть. Но алиби — командировка в Новосибирск, трёхдневная. Авиабилет, гостиница, коллеги, совещание на камеру. Проверено и перепроверено. Он не мог организовать убийство лично. Но мог нанять?",
      "leftOption": "ПРОВЕРИТЬ ФИНАНСЫ КРЫЛОВА",
      "rightOption": "ИСКЛЮЧИТЬ ИЗ СПИСКА",
      "leftNext": "act2_krylov_finance",
      "rightNext": "act2_wife",
      "leftResult": "Финансы чисты. Никаких подозрительных переводов. Крылов злопамятен, но не убийца. Остаётся Елена.",
      "rightResult": "Исключая Крылова — Е.К. это Елена. Переходите к её проверке.",
      "hint": "Алиби Крылова физически невозможно подделать — перелёт, отель, совещание на видео. Можно смело исключить его и сосредоточиться на Елене.",
      "hintGame": "detective",
      "cardStyle": "suspect"
    },

    "act2_pattern": {
      "id": "act2_pattern",
      "act": 2, "actTitle": "АКТ II · ПРОФИЛЬ",
      "type": "briefing", "icon": "📊",
      "title": "Почерк убийцы",
      "text": "Три известных дела Призрака. Всегда: деловой партнёр или супруг. Всегда: финансовый мотив. Всегда: офшорная оплата. Всегда: подставной посредник с препаратом. Из ближайшего окружения Краснова под этот профиль подходят двое: Орлов и Елена.",
      "leftOption": "СОСРЕДОТОЧИТЬСЯ НА ОРЛОВЕ",
      "rightOption": "СОСРЕДОТОЧИТЬСЯ НА ЕЛЕНЕ",
      "leftNext": "act2_orlov_direct",
      "rightNext": "act2_wife",
      "leftResult": "Орлов подходит идеально: деловой партнёр, финансовый мотив, офшорная цепочка к Базарову.",
      "rightResult": "Елена тоже подходит: супруга, страховка, холодная рациональность. Возможно оба организаторы.",
      "hint": "В трёх предыдущих делах Призрака — оба типа присутствовали. Здесь возможно оба: Орлов как деловой партнёр и Елена как супруга. Действовали независимо.",
      "hintGame": "detective",
      "cardStyle": "briefing"
    },

    "act2_alibi_wife": {
      "id": "act2_alibi_wife",
      "act": 2, "actTitle": "АКТ II · АЛИБИ",
      "type": "evidence", "icon": "🚆",
      "title": "Билет в один конец",
      "text": "Сапсан Москва-Петербург, отправление 17:50. Время в пути — 3:50. Прибытие: 21:40. Убийство: 22:30. Елена была у сестры к тому моменту. Алиби держится. Но: обратного билета нет. Она купила только туда. Почему?",
      "leftOption": "СПРОСИТЬ У ЕЛЕНЫ",
      "rightOption": "ПРОВЕРИТЬ КАМЕРЫ ВОКЗАЛА",
      "leftNext": "act2_wife",
      "rightNext": "act2_station",
      "leftResult": "'Я не знала когда вернусь. Горе — это непредсказуемо.' Логично, но неубедительно.",
      "rightResult": "Камеры Ленинградского вокзала: Елена садилась в поезд. Но вы замечаете другое — в 21:15 она выходила из здания аэропорта Шереметьево. Что она там делала?",
      "hint": "Поезд в одну сторону — возможно она знала что дело раскроется и готовила побег. Или просто экономила. Проверьте камеры обоих вокзалов.",
      "hintGame": "universal",
      "cardStyle": "evidence"
    },

    "act2_courier": {
      "id": "act2_courier",
      "act": 2, "actTitle": "АКТ II · КУРЬЕР",
      "type": "evidence", "icon": "📦",
      "title": "Заказ 4477",
      "text": "Сервис NextDay. Заказ 4477: конверт, адрес получателя — Базаров. Оплата — карта ИП 'Рассвет'. ИП зарегистрировано три месяца назад на подставное лицо. Но адрес регистрации — бизнес-центр 'Меркурий'. Арендатор офиса 1214: Орлов Групп.",
      "leftOption": "БРАТЬ ОРЛОВА",
      "rightOption": "КОПАТЬ ГЛУБЖЕ",
      "leftNext": "act3_orlov_ring",
      "rightNext": "act2_money",
      "leftResult": "Цепочка: Орлов → ИП → курьер → Базаров. Для ордера достаточно. Но адвокат оспорит подставное ИП.",
      "rightResult": "Банковская цепочка ИП ведёт к тому же офшору 'Тень'. Одна компания финансировала всё. Это неопровержимо.",
      "hint": "Одна улика — это начало. Цепочка улик — это приговор. Дайте Орлову накопить доказательства прежде чем брать его.",
      "hintGame": "detective",
      "cardStyle": "evidence"
    },

    "act2_station": {
      "id": "act2_station",
      "act": 2, "actTitle": "АКТ II · ШЕРЕМЕТЬЕВО",
      "type": "mystery", "icon": "✈️",
      "title": "Аэровокзал в 21:15",
      "text": "Елена выходила из Шереметьево в 21:15. До отхода Сапсана — тридцать пять минут. Она явно торопилась. Камера фиксирует: она вышла из терминала международных вылетов. Там регистрируются рейсы заграницу. Кого она провожала?",
      "leftOption": "ЗАПРОСИТЬ СПИСОК ПАССАЖИРОВ",
      "rightOption": "ПОСМОТРЕТЬ КАМЕРЫ ВНУТРИ",
      "leftNext": "act3_phone_ghost",
      "rightNext": "act2_ghost",
      "leftResult": "Рейс в Вену в 20:45. Пассажир бизнес-класса: Смирнов Игорь. Воронов улетел до убийства. Кто-то другой ударил Краснова?",
      "rightResult": "Внутренние камеры: Елена с мужчиной в кепке. Шрам над левой бровью. Они прощаются. Она ему что-то передаёт. Конверт.",
      "hint": "Если Призрак улетел до убийства — у него алиби? Или он вернулся другим рейсом? Внутренние камеры покажут его лицо и ответят на этот вопрос.",
      "hintGame": "detective",
      "cardStyle": "mystery"
    },

    "act2_krylov_finance": {
      "id": "act2_krylov_finance",
      "act": 2, "actTitle": "АКТ II · ФИНАНСЫ КРЫЛОВА",
      "type": "evidence", "icon": "💳",
      "title": "Чистые руки",
      "text": "Финансовые записи Крылова проверены. Никаких офшоров, никаких подозрительных переводов. Его счёт в минусе — он берёт кредиты. После увольнения у него нет денег на найм профессионального убийцы. Злость есть. Средств нет.",
      "leftOption": "ОКОНЧАТЕЛЬНО ИСКЛЮЧИТЬ",
      "rightOption": "ВСЁ РАВНО СЛЕДИТЬ",
      "leftNext": "act2_wife",
      "rightNext": "act2_wife",
      "leftResult": "Крылов исключён. Значит Е.К. = Елена Краснова. Переходите к ней.",
      "rightResult": "Слежка за Крыловым ничего не даёт — он только ищет работу. Время потрачено впустую. Переходите к Елене.",
      "hint": "Следить за заведомо невиновным — трата ресурсов. Исключите Крылова и сосредоточьтесь на настоящих подозреваемых.",
      "hintGame": "universal",
      "cardStyle": "evidence"
    },

    "ending_perfect": {
      "id": "ending_perfect",
      "act": 4, "actTitle": "ФИНАЛ · ПРАВОСУДИЕ",
      "type": "ending", "icon": "⚖️",
      "isEnding": true,
      "title": "Все виновные осуждены",
      "text": "Процесс длился шесть месяцев. Елена Краснова — 20 лет за организацию убийства. Орлов — 8 лет за соучастие. Воронов — 15 лет, сотрудничал со следствием. Базаров — 2 года условно. Наташа — испытательный срок. Дело №2847 закрыто. Детектив Соколов смотрит на дождливую Москву. Уже другой дождь.",
      "leftOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "rightOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "leftNext": "act1_scene1",
      "rightNext": "act1_scene1",
      "leftResult": "Новое дело уже на столе.",
      "rightResult": "Новое дело уже на столе.",
      "hint": "",
      "hintGame": null,
      "cardStyle": "ending"
    },

    "ending_all_three": {
      "id": "ending_all_three",
      "act": 4, "actTitle": "ФИНАЛ · ТРОЕ",
      "type": "ending", "icon": "🏛️",
      "isEnding": true,
      "title": "Три приговора",
      "text": "Орлов, Елена и Воронов осуждены. Суд квалифицировал действия Орлова как соучастие в убийстве — его деньги запустили цепочку. Адвокат Штейн оспаривает в апелляции. Но первый приговор — виновен. Справедливость дорогостоящая, медленная, но состоялась.",
      "leftOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "rightOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "leftNext": "act1_scene1",
      "rightNext": "act1_scene1",
      "leftResult": "Следующее дело.",
      "rightResult": "Следующее дело.",
      "hint": "",
      "hintGame": null,
      "cardStyle": "ending"
    },

    "ending_elena": {
      "id": "ending_elena",
      "act": 4, "actTitle": "ФИНАЛ · ЗАКАЗЧИК",
      "type": "ending", "icon": "👸",
      "isEnding": true,
      "title": "Вдова в наручниках",
      "text": "Елена получила восемнадцать лет. Орлов — под следствием, дело затянулось. Воронов не пойман — ушёл за день до ордера. Где-то в Европе готовится очередное 'самоубийство'. Дело закрыто не полностью. Но главный организатор осуждён.",
      "leftOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "rightOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "leftNext": "act1_scene1",
      "rightNext": "act1_scene1",
      "leftResult": "Следующее дело.",
      "rightResult": "Следующее дело.",
      "hint": "",
      "hintGame": null,
      "cardStyle": "ending_partial"
    },

    "ending_orlov_only": {
      "id": "ending_orlov_only",
      "act": 4, "actTitle": "ФИНАЛ · НЕПОЛНЫЙ",
      "type": "ending", "icon": "⚠️",
      "isEnding": true,
      "title": "Половина правды",
      "text": "Орлов арестован. Но адвокат Штейн добивается выхода под залог. Без второго подписанта счёта дело шатается. Елена Краснова наследует состояние и улетает в Женеву. Призрак исчез. Дело №2847 формально открыто. Правда похоронена под деньгами.",
      "leftOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "rightOption": "НАЧАТЬ НОВОЕ ДЕЛО",
      "leftNext": "act1_scene1",
      "rightNext": "act1_scene1",
      "leftResult": "Следующее дело.",
      "rightResult": "Следующее дело.",
      "hint": "",
      "hintGame": null,
      "cardStyle": "ending_bad"
    }
  }
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

    private final TelegramAuthService authService;
    private final PlayerProfileRepository profileRepo;
    private final AiQuestService aiQuestService;
    private final Random random = new Random();

    public GameApiController(TelegramAuthService authService,
                             PlayerProfileRepository profileRepo,
                             AiQuestService aiQuestService) {
        this.authService    = authService;
        this.profileRepo    = profileRepo;
        this.aiQuestService = aiQuestService;
    }

    // ── Auth: WebApp ───────────────────────────────

    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody Map<String, Object> payload) {
        try {
            String initData = (String) payload.get("initData");
            if (!authService.validateWebAppInitData(initData))
                return ResponseEntity.status(401).body("Invalid WebApp signature.");

            @SuppressWarnings("unchecked")
            Map<String, Object> unsafe = (Map<String, Object>) payload.get("initDataUnsafe");
            if (unsafe == null || !unsafe.containsKey("user"))
                return ResponseEntity.status(400).body("User data missing");

            @SuppressWarnings("unchecked")
            Map<String, Object> u = (Map<String, Object>) unsafe.get("user");
            return ok(String.valueOf(u.get("id")),
                      str(u.get("username")),
                      str(u.get("first_name")));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    // ── Auth: Widget ───────────────────────────────

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, Object> payload) {
        try {
            if (!authService.validateWidgetAuth(payload))
                return ResponseEntity.status(401).body("Invalid widget signature");
            return ok(str(payload.get("id")),
                      str(payload.get("username")),
                      str(payload.get("first_name")));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Server error: " + e.getMessage());
        }
    }

    private ResponseEntity<?> ok(String tgId, String username, String firstName) {
        String pid = "tg:" + tgId;
        PlayerProfile p = profileRepo.findByProviderId(pid).orElseGet(() -> {
            PlayerProfile np = new PlayerProfile(); np.setProviderId(pid); return np;
        });
        if (username  != null) p.setUsername(username);
        if (firstName != null) p.setFirstName(firstName);
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    private String str(Object o) { return o == null ? null : String.valueOf(o); }

    // ── Case (AI fallback) ─────────────────────────

    @GetMapping("/case")
    public ResponseEntity<?> getCase(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        String json = aiQuestService.generateCaseJson(p.getArchetype(), p.getRank());
        return ResponseEntity.ok(json);
    }

    // ── Choice ─────────────────────────────────────

    @PostMapping("/choice")
    public ResponseEntity<?> makeChoice(
            @RequestParam String providerId,
            @RequestParam String direction,
            @RequestParam(defaultValue = "false") boolean paid) {

        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");

        // Paid swipe: deduct 5 credits (no hint)
        if (paid) {
            if (p.getCredits() < 5)
                return ResponseEntity.badRequest().body("Недостаточно кредитов для действия без подсказки.");
            p.setCredits(p.getCredits() - 5);
        }

        if (p.getEnergy() < 5)
            return ResponseEntity.badRequest().body("Недостаточно энергии! Нужен кофе.");

        int energyCost    = Math.max(3, 12 - p.getSkill2());
        int baseXp        = 15 + random.nextInt(10);
        int xpGained      = baseXp + (p.getSkill1() * 4);
        int creditsGained = 10 + random.nextInt(15);

        p.setEnergy(Math.max(0, p.getEnergy() - energyCost));
        p.setXp(p.getXp() + xpGained);
        p.setCredits(p.getCredits() + creditsGained);
        p.setTotalCases(p.getTotalCases() + 1);

        int xpReq = p.getRank() * 150;
        if (p.getXp() >= xpReq) { p.setXp(p.getXp() - xpReq); p.setRank(p.getRank() + 1); }

        profileRepo.save(p);
        return ResponseEntity.ok(Map.of(
            "profile",        p,
            "xpGained",       xpGained,
            "creditsGained",  creditsGained,
            "energyLost",     energyCost
        ));
    }

    // ── Upgrade skill ──────────────────────────────

    @PostMapping("/upgrade-skill")
    public ResponseEntity<?> upgradeSkill(@RequestParam String providerId,
                                          @RequestParam int skillNum) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        int cur = skillNum == 1 ? p.getSkill1() : p.getSkill2();
        int cost = 50 * cur;
        if (p.getCredits() < cost) return ResponseEntity.badRequest().body("Недостаточно кредитов.");
        p.setCredits(p.getCredits() - cost);
        if (skillNum == 1) p.setSkill1(p.getSkill1() + 1);
        else               p.setSkill2(p.getSkill2() + 1);
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Buy coffee ─────────────────────────────────

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

    // ── Daily bonus ────────────────────────────────

    @GetMapping("/daily-bonus")
    public ResponseEntity<?> checkDaily(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        String today = LocalDate.now().toString();
        String last  = p.getLastDailyBonus() == null ? "" : p.getLastDailyBonus();
        return ResponseEntity.ok(Map.of("available", !today.equals(last), "streak", p.getStreak()));
    }

    @PostMapping("/daily-bonus/claim")
    public ResponseEntity<?> claimDaily(@RequestParam String providerId) {
        PlayerProfile p = profileRepo.findByProviderId(providerId).orElse(null);
        if (p == null) return ResponseEntity.badRequest().body("Profile not found");
        String today = LocalDate.now().toString();
        if (today.equals(p.getLastDailyBonus())) return ResponseEntity.badRequest().body("Бонус уже получен.");
        String yest = LocalDate.now().minusDays(1).toString();
        int streak = yest.equals(p.getLastDailyBonus()) ? p.getStreak() + 1 : 1;
        p.setCredits(p.getCredits() + 50);
        p.setEnergy(Math.min(100, p.getEnergy() + 30));
        p.setStreak(streak);
        p.setLastDailyBonus(today);
        profileRepo.save(p);
        return ResponseEntity.ok(Map.of("profile", p));
    }

    // ── Advance game level ─────────────────────────

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
        p.setXp(p.getXp() + 50);
        int req = p.getRank() * 150;
        if (p.getXp() >= req) { p.setXp(p.getXp() - req); p.setRank(p.getRank() + 1); }
        profileRepo.save(p);
        return ResponseEntity.ok(p);
    }
}

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

echo "✅ Все файлы обновлены!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  git add -A"
echo "  git commit -m \"feat: Analyst Cabinet v3 + Detective storyline\""
echo "  git push"
echo ""
echo "  ⚠️  Если виджет Telegram не работает в браузере:"
echo "  @BotFather → /mybots → Ваш бот → Bot Settings"
echo "  → Domain → добавьте: your-app.railway.app"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
