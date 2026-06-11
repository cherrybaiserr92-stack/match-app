#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#  СДВИГ · deploy.sh v5  —  Dark Glass + OIDC + Full Match-3
#  Запускай из корня репозитория:  bash deploy.sh
# ═══════════════════════════════════════════════════════════════
set -e
S="src/main/resources/static"
J="src/main/java/com/example/sdvig"
echo ""
echo "🔍  СДВИГ v5 — наводим порядок в репозитории…"
echo ""

# ── Очистка устаревших файлов ───────────────────────────────
echo "🗑  Удаляем устаревшие файлы…"
rm -f "$S/sound.js" 2>/dev/null||true          # v4 sound
rm -f "$S/games/doctor.js"  2>/dev/null||true  # removed
rm -f "$S/games/universal.js" 2>/dev/null||true
rm -f "$J/service/AiQuestService.java" 2>/dev/null||true
echo ""

echo "  ✦ $S/style.css"
mkdir -p $(dirname "$S/style.css")
cat > "$S/style.css" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · v5 · Dark Glass System
   Glassmorphism · Amber · Photo backgrounds
═══════════════════════════════════════════════ */
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,600;0,700;1,500&family=JetBrains+Mono:wght@400;600&display=swap');

:root {
    /* Glass surfaces */
    --glass:      rgba(8,6,4,.72);
    --glass-l:    rgba(20,16,10,.55);
    --glass-hi:   rgba(255,255,255,.055);
    --glass-edge: rgba(255,255,255,.09);
    --glass-dark: rgba(0,0,0,.82);

    /* Amber accent (matches lamp in office photo) */
    --amber:      #c8860a;
    --amber-l:    #e8a030;
    --amber-d:    #8a5a06;
    --amber-dim:  rgba(200,134,10,.18);
    --amber-glow: rgba(200,134,10,.35);

    /* Status */
    --ok:         #22c55e;
    --ok-dim:     rgba(34,197,94,.15);
    --no:         #ef4444;
    --no-dim:     rgba(239,68,68,.15);

    /* Text */
    --tx:         rgba(255,255,255,.92);
    --tx2:        rgba(255,255,255,.58);
    --tx3:        rgba(255,255,255,.30);
    --tx4:        rgba(255,255,255,.14);

    /* Radius */
    --r:    10px;
    --rl:   16px;
    --rxl:  22px;
    --r2xl: 28px;

    /* Layout */
    --nav-h:  62px;
    --top-h:  52px;
    --safe-b: env(safe-area-inset-bottom,0px);
    --safe-t: env(safe-area-inset-top,0px);
}

/* ── Reset ──────────────────────────────────── */
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;-webkit-tap-highlight-color:transparent}
html,body{height:100%;overflow:hidden;overscroll-behavior:none}
body{
    font-family:'Inter',-apple-system,sans-serif;
    background:#0a0806;color:var(--tx);font-size:14px;line-height:1.5;
}
a{color:var(--amber)}
code{font-family:'JetBrains Mono',monospace;font-size:.9em;background:var(--glass-l);padding:2px 6px;border-radius:4px}
.hidden{display:none!important}

/* ── Widget — explicit pointer unlock ───────── */
.tg-widget-area,
.tg-widget-area *,
.tg-widget-area iframe{
    pointer-events:auto!important;
    user-select:auto!important;
    -webkit-user-select:auto!important;
    touch-action:auto!important;
    position:relative;z-index:10;
}

/* ── Screens ────────────────────────────────── */
.screen{
    position:fixed;inset:0;
    display:flex;flex-direction:column;
    opacity:0;pointer-events:none;
    padding-top:var(--safe-t);
    transition:opacity .4s ease;
}
.screen.active{opacity:1;pointer-events:all}

/* ══════════════════════════════════════════════
   SPLASH  —  door photo background
══════════════════════════════════════════════ */
#splash-screen{
    background:url('/img/bg-splash.jpg') center/cover no-repeat;
    justify-content:center;align-items:center;
    z-index:9999;overflow:hidden;
}
#splash-screen::before{
    /* Dark overlay so text is readable */
    content:'';position:absolute;inset:0;
    background:linear-gradient(180deg,rgba(0,0,0,.45) 0%,rgba(0,0,0,.15) 50%,rgba(0,0,0,.6) 100%);
    pointer-events:none;
}
.splash-flash{position:absolute;inset:0;background:#fff;opacity:0;pointer-events:none;z-index:5;transition:opacity .5s ease}
.splash-content{position:relative;z-index:2;display:flex;flex-direction:column;align-items:center;gap:8px;padding:32px;text-align:center}

/* Emblem */
.splash-emblem{
    width:80px;height:80px;border-radius:50%;
    background:var(--glass);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);
    border:1.5px solid var(--amber);
    display:flex;align-items:center;justify-content:center;
    box-shadow:0 0 0 8px rgba(200,134,10,.12),0 12px 40px rgba(0,0,0,.5);
    opacity:0;transform:translateY(50px) scale(.9);
    transition:transform .55s cubic-bezier(.2,.8,.3,1),opacity .45s ease,box-shadow .3s;
    margin-bottom:16px;
}
.splash-emblem.show{opacity:1;transform:none}
.splash-emblem.pulse-once{box-shadow:0 0 0 20px rgba(200,134,10,0),0 12px 40px rgba(0,0,0,.5)!important;transition:box-shadow .5s ease!important}
.emblem-s{font-family:'Playfair Display',serif;font-size:32px;color:var(--amber);line-height:1}

/* Title */
.splash-title-wrap{display:flex;gap:0;height:44px;overflow:hidden}
.stl{
    font-family:'Inter',sans-serif;font-size:32px;font-weight:800;
    letter-spacing:6px;color:#fff;
    opacity:0;transform:translateY(24px);
    display:inline-block;
    /* animated individually by JS */
}
.stl.in{animation:stlIn .32s cubic-bezier(.2,.8,.3,1) forwards}
@keyframes stlIn{to{opacity:1;transform:none}}

.splash-bar-wrap{
    width:180px;margin-top:20px;
    opacity:0;animation:fadeIn .4s ease .9s forwards;
}
.splash-bar-bg{height:2px;background:rgba(255,255,255,.15);border-radius:99px;overflow:hidden}
.splash-bar-fill{height:100%;background:linear-gradient(90deg,var(--amber-d),var(--amber));width:0%;transition:width .5s ease;border-radius:99px}
.splash-status{font-size:11px;color:rgba(255,255,255,.45);letter-spacing:1.5px;text-transform:uppercase;font-family:'JetBrains Mono',monospace;margin-top:8px}

@keyframes fadeIn{to{opacity:1}}

/* ══════════════════════════════════════════════
   LOGIN  —  office photo background
══════════════════════════════════════════════ */
#login-screen{
    background:url('/img/bg-login.jpg') center/cover no-repeat;
    justify-content:center;align-items:center;overflow-y:auto;
}
#login-screen::before{
    content:'';position:absolute;inset:0;
    background:linear-gradient(180deg,rgba(0,0,0,.55) 0%,rgba(0,0,0,.3) 40%,rgba(0,0,0,.7) 100%);
    pointer-events:none;
}
.login-wrap{position:relative;z-index:1;width:100%;max-width:360px;padding:24px 20px 32px;display:flex;flex-direction:column;align-items:center;gap:20px}
.login-head{text-align:center}
.login-badge{width:52px;height:52px;border-radius:50%;background:var(--glass);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1.5px solid var(--amber);display:flex;align-items:center;justify-content:center;margin:0 auto 12px;font-family:'Playfair Display',serif;font-size:22px;color:var(--amber)}
.login-h1{font-size:28px;font-weight:800;letter-spacing:5px;color:#fff}
.login-sub{font-size:11px;letter-spacing:2px;color:var(--tx3);text-transform:uppercase;margin-top:4px}

.login-card{
    width:100%;
    background:var(--glass);backdrop-filter:blur(28px) saturate(1.2);-webkit-backdrop-filter:blur(28px) saturate(1.2);
    border:1px solid var(--glass-edge);border-radius:var(--r2xl);
    padding:22px 20px;display:flex;flex-direction:column;gap:14px;
    box-shadow:0 24px 60px rgba(0,0,0,.5),inset 0 1px 0 var(--glass-hi);
}
.lc-label{font-size:10px;letter-spacing:3px;color:var(--amber);font-weight:700;text-transform:uppercase;text-align:center;font-family:'JetBrains Mono',monospace}
.lc-hint {font-size:13px;color:var(--tx2);text-align:center}

.tg-widget-area{min-height:52px;display:flex;flex-direction:column;align-items:center;gap:8px}
.tg-tip{font-size:11px;color:var(--tx3);text-align:center;line-height:1.5}

.lc-divider{display:flex;align-items:center;gap:12px;font-size:10px;letter-spacing:2px;color:var(--tx4);text-transform:uppercase}
.lc-divider::before,.lc-divider::after{content:'';flex:1;height:1px;background:var(--tx4)}

.login-footer{font-size:12px;color:var(--tx3);text-align:center;position:relative;z-index:1}

/* ── Buttons ────────────────────────────────── */
.btn{
    display:block;width:100%;padding:14px;border:none;border-radius:var(--rl);
    font-family:'Inter',sans-serif;font-size:14px;font-weight:600;
    letter-spacing:.2px;cursor:pointer;text-align:center;
    transition:transform .12s,opacity .15s,box-shadow .15s;position:relative;overflow:hidden;
}
.btn::after{content:'';position:absolute;inset:0;background:rgba(255,255,255,.08);opacity:0;transition:opacity .12s}
.btn:active{transform:scale(.96)}.btn:active::after{opacity:1}
.btn-amber{background:var(--amber);color:#fff;font-weight:700;box-shadow:0 4px 20px var(--amber-dim)}
.btn-amber:hover{background:var(--amber-l)}
.btn-glass{background:var(--glass-l);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid var(--glass-edge);color:var(--tx2)}
.btn-glass-amber{background:rgba(200,134,10,.12);border:1.5px solid var(--amber);color:var(--amber);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)}
.btn-outline{background:transparent;border:1px solid var(--tx4);color:var(--tx3);cursor:not-allowed}

/* ══════════════════════════════════════════════
   MAIN SCREEN — office background everywhere
══════════════════════════════════════════════ */
#main-screen{
    background:url('/img/bg-login.jpg') center/cover no-repeat fixed;
}
#main-screen::before{
    content:'';position:fixed;inset:0;
    background:rgba(0,0,0,.55);
    pointer-events:none;z-index:0;
}
/* All main-screen children above overlay */
#main-screen>*{position:relative;z-index:1}

/* ── Top bar ────────────────────────────────── */
.topbar{
    height:var(--top-h);display:flex;align-items:center;justify-content:space-between;
    padding:0 16px;flex-shrink:0;
    background:var(--glass-dark);backdrop-filter:blur(30px) saturate(1.1);-webkit-backdrop-filter:blur(30px) saturate(1.1);
    border-bottom:1px solid var(--glass-edge);
}
.tb-left{display:flex;align-items:center;gap:8px}
.tb-emblem{width:26px;height:26px;border-radius:50%;border:1.5px solid var(--amber);display:flex;align-items:center;justify-content:center;font-family:'Playfair Display',serif;font-size:13px;color:var(--amber)}
.tb-brand{font-size:15px;font-weight:800;letter-spacing:3px;color:#fff}
.tb-right{display:flex;align-items:center;gap:6px}

.stat-pill{display:flex;align-items:center;gap:4px;padding:4px 10px;border-radius:99px;background:var(--glass-l);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid var(--glass-edge);font-size:12px;font-weight:600}
.stat-pill svg{width:13px;height:13px}
.sp-en{color:#60a5fa}.sp-cr{color:var(--amber-l)}.sp-rk{color:var(--amber)}

.snd-btn{width:32px;height:32px;border-radius:50%;background:var(--glass-l);backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px);border:1px solid var(--glass-edge);display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:14px;transition:transform .1s}
.snd-btn:active{transform:scale(.9)}

/* XP bar */
.xp-band{height:4px;background:rgba(255,255,255,.08);flex-shrink:0;position:relative}
.xp-fill{position:absolute;left:0;top:0;bottom:0;background:linear-gradient(90deg,var(--amber-d),var(--amber));transition:width .6s ease}

/* ── Tab area ───────────────────────────────── */
.tab-area{flex:1;position:relative;overflow:hidden}
.tab-pane{position:absolute;inset:0;overflow-y:auto;overflow-x:hidden;-webkit-overflow-scrolling:touch;overscroll-behavior:contain;opacity:0;pointer-events:none;transform:translateY(5px);transition:opacity .22s ease,transform .22s ease;padding-bottom:calc(var(--nav-h) + var(--safe-b) + 24px)}
.tab-pane.active{opacity:1;pointer-events:all;transform:none}

/* ── Swipe zone ─────────────────────────────── */
.swipe-zone{position:absolute;inset:0;display:flex;justify-content:center;align-items:center;overflow:hidden}

/* Stack cards */
.scard{position:absolute;width:calc(100% - 44px);max-width:340px;border-radius:var(--r2xl);background:var(--glass);border:1px solid var(--glass-edge);pointer-events:none}
.sc3{height:170px;transform:translateY(20px) scale(.84) rotate(1.8deg);opacity:.22;filter:blur(2px)}
.sc2{height:192px;transform:translateY(10px) scale(.92) rotate(.7deg);opacity:.46;filter:blur(1px)}
.sc1{height:212px;transform:translateY(4px) scale(.975) rotate(.2deg);opacity:.72}

/* ── Result overlay ─────────────────────────── */
.result-overlay{
    position:absolute;inset:10px;
    background:var(--glass);backdrop-filter:blur(28px);-webkit-backdrop-filter:blur(28px);
    border:1px solid var(--glass-edge);border-radius:var(--r2xl);
    box-shadow:0 32px 80px rgba(0,0,0,.6),inset 0 1px 0 var(--glass-hi);
    display:flex;flex-direction:column;align-items:center;justify-content:center;
    gap:16px;padding:28px;text-align:center;z-index:50;
    animation:popIn .28s cubic-bezier(.2,.8,.3,1);
}
@keyframes popIn{from{opacity:0;transform:scale(.9)}to{opacity:1;transform:none}}
.ro-stamp{font-size:22px;font-weight:800;letter-spacing:5px;text-transform:uppercase;padding:7px 18px;border:3px solid;border-radius:4px;transform:rotate(-6deg);display:inline-block}
.ro-stamp.ok {color:var(--ok);border-color:var(--ok);background:var(--ok-dim)}
.ro-stamp.no {color:var(--no);border-color:var(--no);background:var(--no-dim)}
.ro-text{font-family:'Playfair Display',serif;font-size:16px;line-height:1.65;color:var(--tx2);font-style:italic}
.ro-chips{display:flex;gap:8px;flex-wrap:wrap;justify-content:center}
.ro-chip{padding:5px 12px;border-radius:99px;font-size:13px;font-weight:600;background:var(--glass-l);border:1px solid var(--glass-edge)}

/* ── Games tab ──────────────────────────────── */
.pane-head{padding:16px 16px 8px}
.pane-title{font-size:13px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:var(--tx2)}
.pane-sub{font-size:12px;color:var(--tx3);margin-top:3px}

.game-row{
    display:flex;align-items:center;gap:14px;
    margin:0 16px 10px;padding:16px 14px;
    background:var(--glass);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);
    border:1px solid var(--glass-edge);border-radius:var(--r2xl);
    cursor:pointer;transition:transform .12s,box-shadow .15s;
    box-shadow:0 4px 20px rgba(0,0,0,.3),inset 0 1px 0 var(--glass-hi);
    position:relative;overflow:hidden;
}
.game-row:active{transform:scale(.97)}
.gr-stripe{position:absolute;left:0;top:0;bottom:0;width:3px;border-radius:var(--r2xl) 0 0 var(--r2xl)}
.gr-gem{background:linear-gradient(135deg,#a855f7,#7c3aed)}.gr-new{background:var(--amber)}
.gr-icon{font-size:34px;flex-shrink:0}
.gr-info{flex:1;min-width:0}
.gr-name{font-size:15px;font-weight:700;color:var(--tx)}
.gr-desc{font-size:11px;color:var(--tx3);margin-top:2px}
.gr-prog{display:flex;align-items:center;gap:8px;margin-top:8px}
.gr-bar{flex:1;height:3px;background:rgba(255,255,255,.12);border-radius:99px;overflow:hidden}
.gr-fill{height:100%;background:var(--amber);border-radius:99px;transition:width .5s ease}
.gr-lvl{font-size:10px;color:var(--tx3);font-weight:600;white-space:nowrap;font-family:'JetBrains Mono',monospace}
.gr-arrow{font-size:18px;color:var(--tx4)}

/* Game viewport */
.gvp-wrap{position:absolute;inset:0;z-index:200;display:flex;flex-direction:column;background:#0a0806}
.gvp-bar{height:var(--top-h);display:flex;align-items:center;padding:0 14px;gap:10px;background:var(--glass-dark);backdrop-filter:blur(30px);-webkit-backdrop-filter:blur(30px);border-bottom:1px solid var(--glass-edge);flex-shrink:0}
.back-btn{display:flex;align-items:center;gap:6px;background:var(--glass-l);border:1px solid var(--glass-edge);color:var(--tx2);padding:7px 12px;border-radius:var(--rl);font-family:'Inter',sans-serif;font-size:12px;font-weight:600;cursor:pointer;transition:all .15s}
.back-btn:active{background:rgba(255,255,255,.08);transform:scale(.96)}
.back-btn svg{width:14px;height:14px}
.gvp-title{font-size:13px;font-weight:700;color:var(--tx);flex:1;text-align:center}
.win-badge{padding:4px 10px;background:rgba(34,197,94,.15);border:1px solid var(--ok);border-radius:99px;font-size:11px;font-weight:700;color:var(--ok);animation:popIn .35s ease}
.game-vp{flex:1;overflow:hidden;display:flex;flex-direction:column}

/* ── Profile tab ────────────────────────────── */
.profile-hero{display:flex;align-items:center;gap:14px;padding:16px;margin:16px;background:var(--glass);backdrop-filter:blur(20px);-webkit-backdrop-filter:blur(20px);border:1px solid var(--glass-edge);border-radius:var(--r2xl);box-shadow:inset 0 1px 0 var(--glass-hi)}
.profile-av{width:56px;height:56px;border-radius:50%;background:linear-gradient(135deg,rgba(200,134,10,.3),rgba(200,134,10,.6));border:2px solid var(--amber);display:flex;align-items:center;justify-content:center;font-size:24px;font-weight:700;color:var(--amber-l);flex-shrink:0}
.profile-name{font-size:19px;font-weight:700;color:var(--tx)}
.profile-arch{font-size:13px;color:var(--amber);margin-top:2px}
.profile-id  {font-size:11px;color:var(--tx3);margin-top:2px;font-family:'JetBrains Mono',monospace}

.stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;padding:0 16px}
.sg{background:var(--glass);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border:1px solid var(--glass-edge);border-radius:var(--rl);padding:12px 8px;display:flex;flex-direction:column;align-items:center;gap:4px}
.sg-val{font-size:22px;font-weight:700;color:var(--tx);font-family:'Playfair Display',serif;line-height:1}
.sg-lbl{font-size:9px;letter-spacing:1.5px;color:var(--tx3);text-transform:uppercase;font-weight:600}

.sec-head{padding:16px 16px 8px;font-size:11px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:var(--tx3)}

.skill-row{display:flex;align-items:center;gap:12px;margin:0 16px 8px;padding:14px;background:var(--glass);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border:1px solid var(--glass-edge);border-radius:var(--r2xl);box-shadow:inset 0 1px 0 var(--glass-hi)}
.sk-icon{font-size:26px;flex-shrink:0}
.sk-body{flex:1;min-width:0}
.sk-name{font-size:14px;font-weight:600;color:var(--tx)}
.sk-desc{font-size:11px;color:var(--tx3);margin-top:2px}
.sk-bar{height:3px;background:rgba(255,255,255,.12);border-radius:99px;overflow:hidden;margin-top:8px}
.sk-fill{height:100%;background:var(--amber);border-radius:99px;transition:width .5s ease}
.sk-side{display:flex;flex-direction:column;align-items:flex-end;gap:6px;flex-shrink:0}
.sk-lv{font-size:12px;font-weight:600;color:var(--amber);font-family:'JetBrains Mono',monospace}
.up-btn{background:var(--amber);border:none;border-radius:var(--rl);padding:8px 12px;font-family:'Inter',sans-serif;font-size:12px;font-weight:700;color:#fff;cursor:pointer;transition:transform .1s,background .15s;white-space:nowrap;box-shadow:0 3px 12px var(--amber-dim)}
.up-btn:active{transform:scale(.93);background:var(--amber-l)}

.ach-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;padding:4px 16px 16px}
.ach-b{display:flex;flex-direction:column;align-items:center;gap:4px;background:var(--glass);backdrop-filter:blur(12px);-webkit-backdrop-filter:blur(12px);border:1px solid var(--glass-edge);border-radius:var(--rl);padding:10px 4px;text-align:center}
.ach-b.earned{border-color:rgba(200,134,10,.4)}
.ach-b.locked{opacity:.35}
.ach-icon{font-size:22px;line-height:1}
.ach-lbl{font-size:9px;color:var(--tx3);font-weight:600;letter-spacing:.3px;line-height:1.3}

/* ── Shop tab ───────────────────────────────── */
.shop-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:10px;padding:4px 16px 16px}
.shop-item{background:var(--glass);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);border:1px solid var(--glass-edge);border-radius:var(--r2xl);padding:18px 14px;display:flex;flex-direction:column;align-items:center;gap:7px;cursor:pointer;text-align:center;transition:transform .12s,box-shadow .15s;box-shadow:inset 0 1px 0 var(--glass-hi)}
.shop-item:not(.shop-locked):active{transform:scale(.95);border-color:var(--amber)}
.shop-locked{opacity:.4;cursor:not-allowed}
.si-icon{font-size:34px}.si-name{font-size:13px;font-weight:700;color:var(--tx)}.si-desc{font-size:11px;color:var(--tx3);line-height:1.4}
.si-price{padding:5px 12px;border-radius:99px;font-size:12px;font-weight:700;background:rgba(200,134,10,.14);border:1px solid rgba(200,134,10,.3);color:var(--amber-l);margin-top:2px}
.si-soon{background:var(--glass-l);border-color:var(--glass-edge);color:var(--tx3);font-size:10px;letter-spacing:1px}

/* ── Progress map tab ───────────────────────── */
.progress-map{min-height:100%;background:transparent;position:relative;padding-bottom:16px}
.map-scene{padding:16px 16px 0}
.map-chapter-label{
    background:var(--glass);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);
    border:1px solid var(--glass-edge);border-radius:var(--r2xl);
    padding:10px 16px;margin:0 8px 0;
    font-size:11px;font-weight:700;letter-spacing:2px;text-transform:uppercase;
    color:var(--amber);text-align:center;
    box-shadow:inset 0 1px 0 var(--glass-hi);
}
.map-levels{display:flex;flex-direction:column;align-items:center;gap:0;padding:4px 0}
.map-level-row{display:flex;justify-content:center;width:100%;padding:4px 0;position:relative}
.map-level-row:nth-child(odd) {justify-content:flex-end;padding-right:30%}
.map-level-row:nth-child(even){justify-content:flex-start;padding-left:30%}
.map-connector{width:2px;height:24px;background:rgba(255,255,255,.12);margin:0 auto;border-radius:99px}
.map-node{
    width:58px;height:58px;border-radius:50%;
    display:flex;flex-direction:column;align-items:center;justify-content:center;
    gap:1px;cursor:pointer;position:relative;
    background:var(--glass);backdrop-filter:blur(16px);-webkit-backdrop-filter:blur(16px);
    border:2px solid var(--glass-edge);
    transition:transform .15s,box-shadow .15s;
    box-shadow:0 4px 16px rgba(0,0,0,.3);
}
.map-node.done{border-color:var(--amber);background:rgba(200,134,10,.15)}
.map-node.current{border-color:var(--amber-l);background:rgba(200,134,10,.25);animation:mapPulse 2s ease-in-out infinite;box-shadow:0 0 0 0 var(--amber-glow),0 4px 16px rgba(0,0,0,.3)}
@keyframes mapPulse{0%,100%{box-shadow:0 0 0 0 rgba(200,134,10,.5),0 4px 16px rgba(0,0,0,.3)}50%{box-shadow:0 0 0 10px rgba(200,134,10,0),0 4px 16px rgba(0,0,0,.3)}}
.map-node.locked{opacity:.5;cursor:not-allowed}
.map-node-num{font-size:14px;font-weight:700;color:var(--tx);line-height:1}
.map-node-icon{font-size:11px;line-height:1}
.map-node.done .map-node-icon{color:var(--amber)}
.map-node:active:not(.locked){transform:scale(.92)}

/* ── Floating bottom nav ────────────────────── */
.bottom-nav{
    position:fixed;
    bottom:calc(14px + var(--safe-b));
    left:16px;right:16px;
    height:var(--nav-h);
    background:var(--glass-dark);
    backdrop-filter:blur(32px) saturate(1.2);-webkit-backdrop-filter:blur(32px) saturate(1.2);
    border:1px solid var(--glass-edge);border-radius:31px;
    display:flex;
    box-shadow:0 12px 40px rgba(0,0,0,.5),inset 0 1px 0 var(--glass-hi);
    z-index:100;flex-shrink:0;
}
.nb{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;background:transparent;border:none;cursor:pointer;padding:8px 4px;border-radius:31px;position:relative;transition:transform .1s}
.nb:active{transform:scale(.88)}
.nb-icon{display:flex;align-items:center;justify-content:center;transition:transform .2s}
.nb-icon svg{width:22px;height:22px;stroke:var(--tx3);transition:stroke .2s}
.nb-lbl{font-size:9px;letter-spacing:1.5px;color:var(--tx4);font-weight:700;text-transform:uppercase;transition:color .2s}
.nb.active .nb-icon svg{stroke:var(--amber);transform:translateY(-1px)}
.nb.active .nb-lbl{color:var(--amber)}
.nb-badge{position:absolute;top:8px;right:calc(50% - 20px);width:14px;height:14px;border-radius:50%;background:var(--no);color:#fff;font-size:9px;font-weight:800;display:flex;align-items:center;justify-content:center;border:1.5px solid #0a0806}

/* ── Hint sheet ─────────────────────────────── */
.hint-modal{position:fixed;inset:0;top:10%;background:var(--glass-dark);backdrop-filter:blur(30px);-webkit-backdrop-filter:blur(30px);border-top:1px solid var(--glass-edge);border-radius:24px 24px 0 0;z-index:400;display:flex;flex-direction:column;animation:sheetUp .28s ease-out}
.hint-modal.closing{animation:sheetDn .22s ease-in forwards}
@keyframes sheetUp{from{transform:translateY(100%)}to{transform:none}}
@keyframes sheetDn{from{transform:none}to{transform:translateY(100%)}}
.hm-head{display:flex;align-items:center;justify-content:space-between;padding:14px 16px;background:rgba(0,0,0,.3);border-bottom:1px solid var(--glass-edge);flex-shrink:0;border-radius:24px 24px 0 0}
.hm-title{display:flex;align-items:center;gap:8px;font-size:13px;font-weight:700;color:var(--tx)}
.hm-title svg{width:16px;height:16px;stroke:var(--amber)}
.hm-close{background:var(--glass-l);border:1px solid var(--glass-edge);border-radius:var(--rl);padding:6px 12px;font-family:'Inter',sans-serif;font-size:12px;font-weight:600;color:var(--tx2);cursor:pointer;transition:all .15s}
.hm-close:active{background:rgba(255,255,255,.08)}
.hm-vp{flex:1;overflow-y:auto;overflow-x:hidden;padding:0;-webkit-overflow-scrolling:touch;background:#0a0806}
.hm-foot{padding:10px 16px;background:rgba(0,0,0,.3);border-top:1px solid var(--glass-edge);flex-shrink:0}
.hm-foot-text{font-size:12px;color:var(--tx3);text-align:center}

/* ── Toast ──────────────────────────────────── */
.toast{position:fixed;bottom:calc(var(--nav-h) + var(--safe-b) + 28px);left:14px;right:14px;background:var(--glass-dark);backdrop-filter:blur(30px);-webkit-backdrop-filter:blur(30px);border:1px solid var(--glass-edge);border-radius:var(--r2xl);padding:12px 14px;display:flex;align-items:center;gap:12px;z-index:900;box-shadow:0 8px 32px rgba(0,0,0,.5),inset 0 1px 0 var(--glass-hi);animation:toastIn .28s ease}
.toast.out{animation:toastOut .28s ease forwards}
@keyframes toastIn {from{transform:translateY(14px);opacity:0}to{opacity:1;transform:none}}
@keyframes toastOut{from{opacity:1}to{transform:translateY(14px);opacity:0}}
.toast-icon{font-size:24px;flex-shrink:0}
.toast-title{font-size:10px;letter-spacing:2px;font-weight:800;color:var(--amber);text-transform:uppercase}
.toast-desc {font-size:13px;color:var(--tx);margin-top:2px;font-weight:500}

/* ── Daily modal ────────────────────────────── */
.modal-bg{position:fixed;inset:0;background:rgba(0,0,0,.65);backdrop-filter:blur(8px);-webkit-backdrop-filter:blur(8px);display:flex;align-items:center;justify-content:center;z-index:800;padding:20px;animation:fadeIn .2s ease}
@keyframes fadeIn{from{opacity:0}to{opacity:1}}
.daily-card{background:var(--glass-dark);backdrop-filter:blur(30px);-webkit-backdrop-filter:blur(30px);border:1px solid var(--glass-edge);border-radius:var(--r2xl);padding:28px 22px;display:flex;flex-direction:column;align-items:center;gap:14px;text-align:center;width:100%;max-width:320px;box-shadow:0 20px 60px rgba(0,0,0,.6),inset 0 1px 0 var(--glass-hi);animation:popIn .35s ease}
.daily-icon{font-size:50px}.daily-h{font-size:16px;font-weight:700;color:var(--tx)}.daily-streak{font-size:13px;color:var(--tx2)}
.daily-week{display:flex;gap:6px;justify-content:center}
.dw-dot{width:26px;height:26px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:10px;font-weight:700;border:1px solid var(--glass-edge);color:var(--tx3);background:var(--glass-l);font-family:'JetBrains Mono',monospace}
.dw-dot.done{background:rgba(200,134,10,.2);border-color:var(--amber);color:var(--amber-l)}
.dw-dot.today{background:var(--amber);border-color:var(--amber-l);color:#fff}
.daily-chips{display:flex;gap:10px}
.dc-chip{padding:7px 16px;border-radius:99px;font-size:13px;font-weight:700;background:var(--glass-l);border:1px solid var(--glass-edge);color:var(--tx)}

/* ── Error ──────────────────────────────────── */
#error-screen{justify-content:center;align-items:center;z-index:9998;background:#0a0806}
.err-c{display:flex;flex-direction:column;align-items:center;gap:14px;padding:32px;text-align:center;max-width:290px}
.err-icon{font-size:44px}.err-title{font-size:16px;font-weight:700;color:var(--no)}.err-msg{font-size:14px;color:var(--tx2);line-height:1.6}

/* ── Scrollbar ──────────────────────────────── */
::-webkit-scrollbar{width:3px}::-webkit-scrollbar-track{background:transparent}::-webkit-scrollbar-thumb{background:rgba(255,255,255,.12);border-radius:99px}

EOF_SDVIG

echo "  ✦ $S/card-design.css"
mkdir -p $(dirname "$S/card-design.css")
cat > "$S/card-design.css" << 'EOF_SDVIG'
/* ═══════════════════════════════════════════════
   СДВИГ · card-design.css v5
   Dark glass · Cinematic · Swipe-only
═══════════════════════════════════════════════ */

/* Type accent tokens */
.case-card{--ct:var(--amber);--ct-d:var(--amber-dim)}
.ct-crime        {--ct:#ef4444;--ct-d:rgba(239,68,68,.15)}
.ct-evidence     {--ct:var(--amber);--ct-d:var(--amber-dim)}
.ct-suspect      {--ct:#60a5fa;--ct-d:rgba(96,165,250,.15)}
.ct-witness      {--ct:#34d399;--ct-d:rgba(52,211,153,.15)}
.ct-testimony    {--ct:#94a3b8;--ct-d:rgba(148,163,184,.12)}
.ct-mystery      {--ct:#a855f7;--ct-d:rgba(168,85,247,.15)}
.ct-action       {--ct:#fb923c;--ct-d:rgba(251,146,60,.15)}
.ct-revelation   {--ct:#fbbf24;--ct-d:rgba(251,191,36,.15)}
.ct-briefing     {--ct:#64748b;--ct-d:rgba(100,116,139,.12)}
.ct-ending       {--ct:#fbbf24;--ct-d:rgba(251,191,36,.15)}
.ct-ending_bad   {--ct:#475569;--ct-d:rgba(71,85,105,.12)}

/* ── Main card ──────────────────────────────── */
.case-card {
    position:absolute;
    width:calc(100% - 28px);max-width:360px;
    min-height:400px;

    /* Dark glass */
    background:rgba(8,5,3,.78);
    backdrop-filter:blur(28px) saturate(1.3);
    -webkit-backdrop-filter:blur(28px) saturate(1.3);

    border:1px solid rgba(255,255,255,.07);
    border-top:2px solid var(--ct);
    border-radius:24px;

    box-shadow:
        0 50px 100px rgba(0,0,0,.75),
        0 20px 40px rgba(0,0,0,.5),
        inset 0 1px 0 rgba(255,255,255,.06),
        inset 0 -1px 0 rgba(0,0,0,.3);

    display:flex;flex-direction:column;
    padding:0;
    cursor:grab;touch-action:none;
    transform-origin:50% 100%;
    will-change:transform;
    z-index:10;

    animation:cardFloat 6s ease-in-out infinite;
}
.case-card:active{cursor:grabbing;animation:none}

@keyframes cardFloat{
    0%,100%{transform:rotate(-.4deg) translateY(0)}
    33%    {transform:rotate(.2deg)  translateY(-4px)}
    66%    {transform:rotate(-.3deg) translateY(-2px)}
}

/* Type glow at top border */
.case-card::after{
    content:'';position:absolute;top:-1px;left:20%;right:20%;height:1px;
    background:var(--ct);filter:blur(4px);opacity:.7;
    border-radius:99px;pointer-events:none;
}

/* Drag tilt states */
.case-card.tilt-l{
    animation:none;border-top-color:#ef4444;
    box-shadow:0 50px 100px rgba(0,0,0,.75),0 20px 40px rgba(0,0,0,.5),-14px 4px 40px rgba(239,68,68,.18),inset 0 1px 0 rgba(255,255,255,.06);
}
.case-card.tilt-r{
    animation:none;border-top-color:#34d399;
    box-shadow:0 50px 100px rgba(0,0,0,.75),0 20px 40px rgba(0,0,0,.5), 14px 4px 40px rgba(52,211,153,.18),inset 0 1px 0 rgba(255,255,255,.06);
}
.case-card.tilt-u{
    animation:none;border-top-color:#a855f7;
    box-shadow:0 50px 100px rgba(0,0,0,.75),0 4px 40px rgba(168,85,247,.25),0 -14px 40px rgba(168,85,247,.18),inset 0 1px 0 rgba(255,255,255,.06);
}

/* Card entry */
.case-card.card-in{animation:cardIn .45s cubic-bezier(.2,.8,.3,1) forwards}
@keyframes cardIn{
    from{opacity:0;transform:rotate(-1.5deg) translateY(-30px) scale(.94)}
    to  {opacity:1;transform:rotate(-.4deg)}
}

/* Shake (locked swipe) */
.case-card.shake{animation:cardShake .5s ease!important}
@keyframes cardShake{
    0%,100%{transform:rotate(-.4deg) translateX(0)}
    12%{transform:rotate(-.4deg) translateX(-12px)}
    25%{transform:rotate(-.4deg) translateX(12px)}
    40%{transform:rotate(-.4deg) translateX(-8px)}
    55%{transform:rotate(-.4deg) translateX(8px)}
    70%{transform:rotate(-.4deg) translateX(-4px)}
    85%{transform:rotate(-.4deg) translateX(4px)}
}

/* Unlock ripple */
.case-card.unlocked{
    animation:unlockRipple .7s ease-out,cardFloat 6s ease-in-out .75s infinite!important;
    border-top-color:var(--amber)!important;
}
@keyframes unlockRipple{
    0% {box-shadow:0 0 0 0 rgba(200,134,10,.6),0 50px 100px rgba(0,0,0,.75)}
    100%{box-shadow:0 0 0 24px rgba(200,134,10,0),0 50px 100px rgba(0,0,0,.75)}
}

/* ── Stamps ─────────────────────────────────── */
.stamp-wrap{
    position:absolute;inset:0;border-radius:inherit;
    display:flex;align-items:center;justify-content:center;
    pointer-events:none;z-index:30;transition:opacity .1s;
}
.sw-l{padding-right:60px}.sw-r{padding-left:60px}.sw-u{padding-bottom:80px}
.stamp{
    font-family:'Inter',sans-serif;font-size:20px;font-weight:900;
    letter-spacing:5px;text-transform:uppercase;
    padding:8px 16px;border:3px solid;border-radius:4px;
}
.stamp-ok  {color:#34d399;border-color:#34d399;background:rgba(52,211,153,.12);transform:rotate(-11deg)}
.stamp-no  {color:#ef4444;border-color:#ef4444;background:rgba(239,68,68,.12);transform:rotate(9deg)}
.stamp-spec{color:#a855f7;border-color:#a855f7;background:rgba(168,85,247,.12);transform:rotate(-4deg)}

@keyframes stampA{0%{transform:scale(1.9)rotate(-26deg);opacity:0}55%{transform:scale(.96)rotate(-11deg);opacity:1}70%{transform:scale(1.03)rotate(-12deg)}100%{transform:scale(1)rotate(-11deg)}}
@keyframes stampN{0%{transform:scale(1.9)rotate(23deg);opacity:0}55%{transform:scale(.96)rotate(9deg);opacity:1}70%{transform:scale(1.03)rotate(10deg)}100%{transform:scale(1)rotate(9deg)}}
@keyframes stampS{0%{transform:scale(1.9)rotate(-8deg);opacity:0}55%{transform:scale(.96)rotate(-4deg);opacity:1}70%{transform:scale(1.03)rotate(-5deg)}100%{transform:scale(1)rotate(-4deg)}}
.stamp-ok.land  {animation:stampA .38s cubic-bezier(.2,.8,.3,1) forwards}
.stamp-no.land  {animation:stampN .38s cubic-bezier(.2,.8,.3,1) forwards}
.stamp-spec.land{animation:stampS .38s cubic-bezier(.2,.8,.3,1) forwards}

/* ── Card body ──────────────────────────────── */
.cc-head{
    display:flex;align-items:center;justify-content:space-between;
    padding:14px 16px 0;
}
.cc-type{
    font-size:10px;letter-spacing:2px;font-weight:700;text-transform:uppercase;
    color:var(--ct);font-family:'JetBrains Mono',monospace;
}
.cc-badge{
    font-size:10px;padding:2px 8px;border-radius:2px;font-weight:700;
    letter-spacing:1px;text-transform:uppercase;
    border:1px solid var(--ct);color:var(--ct);background:var(--ct-d);
}
.cc-body{
    flex:1;display:flex;flex-direction:column;align-items:center;
    justify-content:center;gap:14px;
    padding:18px 18px 10px;
}
.cc-icon-wrap{
    width:68px;height:68px;border-radius:50%;
    background:var(--ct-d);border:1.5px solid rgba(255,255,255,.08);
    display:flex;align-items:center;justify-content:center;
    box-shadow:0 0 20px var(--ct-d),inset 0 1px 0 rgba(255,255,255,.06);
}
.cc-icon{font-size:32px;line-height:1;animation:iconFloat 4s ease-in-out infinite}
@keyframes iconFloat{0%,100%{transform:none}50%{transform:translateY(-3px)}}

.cc-title{
    font-family:'Playfair Display',serif;
    font-size:17px;font-weight:600;font-style:italic;
    color:rgba(255,255,255,.9);text-align:center;line-height:1.35;
}
.cc-text{
    font-family:'Inter',sans-serif;font-size:15px;line-height:1.72;
    text-align:center;color:rgba(255,255,255,.65);font-weight:400;
    animation:inkReveal .7s cubic-bezier(.2,.8,.3,1) .15s both;
}
@keyframes inkReveal{
    from{opacity:0;filter:blur(3px);transform:translateY(5px)}
    to  {opacity:1;filter:none;transform:none}
}

/* ── Card actions area ──────────────────────── */
.cc-actions{padding:12px 16px 16px;display:flex;flex-direction:column;gap:10px}

/* Lock panel */
.lock-panel{
    background:rgba(255,255,255,.04);border:1px dashed rgba(255,255,255,.12);
    border-radius:16px;padding:12px 14px;
    display:flex;align-items:center;gap:12px;
}
.lp-icon{display:flex;align-items:center;flex-shrink:0}
.lp-icon svg{width:20px;height:20px;stroke:rgba(255,255,255,.35)}
.lp-body{flex:1}
.lp-title{font-size:12px;font-weight:600;color:rgba(255,255,255,.6);letter-spacing:.3px}
.lp-sub  {font-size:11px;color:rgba(255,255,255,.3);margin-top:2px}
.btn-play{
    background:var(--amber);border:none;border-radius:16px;
    padding:14px;font-family:'Inter',sans-serif;font-size:14px;font-weight:700;
    color:#000;cursor:pointer;width:100%;
    box-shadow:0 6px 20px var(--amber-dim);
    transition:transform .12s,background .15s;
    display:flex;align-items:center;justify-content:center;gap:8px;
    letter-spacing:.2px;
}
.btn-play:active{transform:scale(.96);background:var(--amber-l)}
.btn-play svg{width:20px;height:20px;stroke:#000;flex-shrink:0}

/* Hint revealed */
.hint-panel{
    background:rgba(200,134,10,.08);border:1px solid rgba(200,134,10,.2);
    border-left:3px solid var(--amber);border-radius:12px;
    padding:10px 14px;display:flex;gap:10px;align-items:flex-start;
    animation:slideIn .3s ease;
}
@keyframes slideIn{from{opacity:0;transform:translateY(-8px)}to{opacity:1;transform:none}}
.hp-icon{font-size:16px;flex-shrink:0;margin-top:1px}
.hp-text{font-family:'Playfair Display',serif;font-size:14px;line-height:1.65;color:rgba(255,255,255,.7);font-style:italic}

/* Swipe indicator (unlocked) */
.swipe-hint{
    display:flex;justify-content:space-between;align-items:center;
    padding:10px 14px 12px;
    border-top:1px solid rgba(255,255,255,.06);
    font-size:11px;font-weight:700;letter-spacing:1.5px;text-transform:uppercase;
    font-family:'Inter',sans-serif;
}
.sh-no  {color:#ef4444;opacity:.75}
.sh-ok  {color:#34d399;opacity:.75}
.sh-mid {color:rgba(255,255,255,.2);display:flex;align-items:center}
.sh-mid svg{width:16px;height:16px;stroke:rgba(255,255,255,.25)}
.sh-up  {
    text-align:center;font-size:10px;color:#a855f7;
    margin-top:-2px;letter-spacing:1px;
}

/* Locked swipe indicator */
.swipe-locked{
    display:flex;align-items:center;justify-content:center;gap:6px;
    padding:10px 14px 12px;
    border-top:1px solid rgba(255,255,255,.06);
    font-size:11px;font-weight:600;letter-spacing:1px;text-transform:uppercase;
    color:rgba(255,255,255,.2);
}
.swipe-locked svg{width:14px;height:14px;stroke:rgba(255,255,255,.2)}

/* ── Dust particles ─────────────────────────── */
.dust{
    position:absolute;width:4px;height:4px;border-radius:50%;
    pointer-events:none;z-index:200;
    background:rgba(240,220,180,.6);
    transition:transform .4s ease-out,opacity .4s ease;
}

/* ── Confetti ───────────────────────────────── */
.confetti-p{
    position:fixed;top:-10px;pointer-events:none;z-index:9999;
    border-radius:2px;
    animation:confettiFall linear both;
}
@keyframes confettiFall{
    from{transform:translateY(0) rotate(0deg);opacity:1}
    to  {transform:translateY(110vh) rotate(720deg);opacity:0}
}

/* ── Weather rain overlay ───────────────────── */
.rain-canvas{
    position:absolute;inset:0;pointer-events:none;
    opacity:.22;z-index:1;border-radius:inherit;
}

/* ── Parallax container ─────────────────────── */
.parallax-bg{
    position:absolute;inset:-24px;
    background:url('/img/bg-login.jpg') center/cover no-repeat;
    filter:brightness(.32) blur(1px);
    transition:transform .12s ease;
    z-index:0;
}
.swipe-zone>*:not(.parallax-bg){z-index:2}

EOF_SDVIG

echo "  ✦ $S/icons.js"
mkdir -p $(dirname "$S/icons.js")
cat > "$S/icons.js" << 'EOF_SDVIG'
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

EOF_SDVIG

echo "  ✦ $S/sound.js"
mkdir -p $(dirname "$S/sound.js")
cat > "$S/sound.js" << 'EOF_SDVIG'
// ═══════════════════════════════════════════════
//  СДВИГ · sound.js v5  — Web Audio Engine
// ═══════════════════════════════════════════════
class SoundEngine {
    constructor(){
        this.ctx=null;this.master=null;this.music=null;this.sfx=null;
        this._on=localStorage.getItem('sdvig_snd')!=='0';
        this._ready=false;this._loop=null;
    }
    get enabled(){return this._on;}
    toggle(){
        this._on=!this._on;localStorage.setItem('sdvig_snd',this._on?'1':'0');
        if(this.master)this.master.gain.value=this._on?1:0;
        if(this._on)this._startMusic();else this._stopMusic();
        return this._on;
    }
    async init(){
        if(this._ready)return;this._ready=true;
        const C=window.AudioContext||window.webkitAudioContext;if(!C)return;
        try{
            this.ctx=new C();
            if(this.ctx.state==='suspended')await this.ctx.resume();
            this.master=this.ctx.createGain();this.master.gain.value=this._on?1:0;
            this.master.connect(this.ctx.destination);
            this.music=this.ctx.createGain();this.music.gain.value=0.1;this.music.connect(this.master);
            this.sfx=this.ctx.createGain();this.sfx.gain.value=0.8;this.sfx.connect(this.master);
            // Limiter
            const lim=this.ctx.createDynamicsCompressor();lim.threshold.value=-6;lim.ratio.value=8;
            this.sfx.connect(lim);lim.connect(this.master);
            if(this._on)this._startMusic();
        }catch(e){this._ready=false;}
    }
    _t(){return this.ctx?.currentTime||0;}
    _osc(f,type,vol,t,dur,out){
        if(!this.ctx)return;
        const o=this.ctx.createOscillator(),g=this.ctx.createGain();
        o.type=type;o.frequency.value=f;
        g.gain.setValueAtTime(0,t);g.gain.linearRampToValueAtTime(vol,t+0.012);
        g.gain.exponentialRampToValueAtTime(0.001,t+dur);
        o.connect(g);g.connect(out||this.sfx);o.start(t);o.stop(t+dur+0.02);
    }
    _filter(freq,type='lowpass',Q=1){
        if(!this.ctx)return null;
        const f=this.ctx.createBiquadFilter();f.type=type;f.frequency.value=freq;f.Q.value=Q;return f;
    }

    // ── SFX ──────────────────────────────────────
    click(){this._osc(520,'triangle',.18,this._t(),.07);}

    swipeR(){this._whoosh(220,500,.16);}
    swipeL(){this._whoosh(500,220,.16);}

    locked(){
        const t=this._t();
        this._osc(110,'square',.22,t,.12);
        this._osc(80,'sine',.15,t+.07,.15);
    }

    unlock(){
        const t=this._t();
        [[523,0],[659,.1],[784,.2],[1047,.32]].forEach(([f,d])=>this._osc(f,'sine',.28,t+d,.3));
    }

    cardLoad(){this._osc(360,'triangle',.12,this._t(),.1);}

    swipeUp(){
        const t=this._t();
        this._osc(440,'sine',.15,t,.1);this._osc(660,'triangle',.12,t+.08,.15);this._osc(880,'sine',.1,t+.18,.2);
    }

    // Match-3
    gemTap()   {this._osc(700,'sine',.18,this._t(),.07);}
    gemBounce(){this._osc(380,'sine',.12,this._t(),.06);}

    gemMatch(n=3){
        const t=this._t(),base=600+n*60;
        this._osc(base,'sine',.22,t,.15);
        this._osc(base*1.5,'triangle',.1,t+.07,.12);
    }

    combo(n){
        if(!this.ctx||n<2)return;
        const t=this._t(),f=[523,659,784,1047,1318,1568][Math.min(n-2,5)];
        this._osc(f,'sine',.3,t,.25);this._osc(f*2,'triangle',.12,t+.08,.2);
        if(n>=4)this._osc(f*3,'sine',.07,t+.16,.18);
    }

    bombExplode(){
        if(!this.ctx)return;
        const t=this._t();
        this._osc(90,'sawtooth',.4,t,.28);this._osc(60,'square',.28,t+.06,.3);
        // Noise
        const buf=this.ctx.createBuffer(1,this.ctx.sampleRate*.25,this.ctx.sampleRate);
        const d=buf.getChannelData(0);for(let i=0;i<d.length;i++)d[i]=(Math.random()*2-1)*.45;
        const s=this.ctx.createBufferSource(),g=this.ctx.createGain();
        g.gain.setValueAtTime(.35,t);g.gain.exponentialRampToValueAtTime(.001,t+.25);
        s.buffer=buf;s.connect(g);g.connect(this.sfx);s.start(t);s.stop(t+.28);
    }

    noMoves(){
        const t=this._t();
        [[220,.0],[196,.1],[165,.2],[147,.3]].forEach(([f,d])=>this._osc(f,'triangle',.2,t+d,.25));
    }

    win3(){
        const t=this._t();
        [[523,0],[659,.1],[784,.2],[1047,.32],[1318,.46],[1568,.62]]
        .forEach(([f,d])=>this._osc(f,'sine',.28,t+d,.3));
    }

    splashImpact(){
        if(!this.ctx)return;
        const t=this._t();
        this._osc(80,'sine',.35,t,.4);this._osc(160,'triangle',.18,t+.05,.3);
    }

    splashExit(){
        const t=this._t();
        [[220,.0],[330,.08],[440,.16],[660,.26],[880,.38]]
        .forEach(([f,d])=>this._osc(f,'triangle',.18,t+d,.25));
    }

    // ── Background music ──────────────────────────
    _startMusic(){this._stopMusic();this._scheduleLoop();}
    _stopMusic(){clearTimeout(this._loop);this._loop=null;}

    _scheduleLoop(){
        if(!this.ctx)return;
        const t=this.ctx.currentTime+.15,dur=14;
        // Bass pad (Am)
        [[110,.08],[165,.04],[220,.03]].forEach(([f,v])=>this._pad(f,v,t,dur,'sine'));
        // Melodic arpeggio (sparse, detective-noir)
        [[330,1.5],[247,3.2],[294,5],[220,6.8],[330,8.5],[196,10],[247,11.5],[220,13]]
        .forEach(([f,delay])=>this._osc(f,'triangle',.045,t+delay,.9,this.music));
        this._loop=setTimeout(()=>this._scheduleLoop(),(dur-.8)*1000);
    }

    _pad(freq,vol,start,dur,type='sawtooth'){
        if(!this.ctx)return;
        const o=this.ctx.createOscillator(),f=this._filter(700),g=this.ctx.createGain();
        o.type=type;o.frequency.value=freq;
        g.gain.setValueAtTime(0,start);g.gain.linearRampToValueAtTime(vol,start+3);
        g.gain.setValueAtTime(vol,start+dur-2.5);g.gain.linearRampToValueAtTime(0,start+dur);
        o.connect(f);f.connect(g);g.connect(this.music);o.start(start);o.stop(start+dur+.1);
    }

    _whoosh(f1,f2,vol){
        if(!this.ctx)return;
        const t=this._t(),o=this.ctx.createOscillator(),g=this.ctx.createGain();
        o.type='sawtooth';o.frequency.setValueAtTime(f1,t);o.frequency.exponentialRampToValueAtTime(f2,t+.16);
        g.gain.setValueAtTime(vol,t);g.gain.exponentialRampToValueAtTime(.001,t+.18);
        o.connect(g);g.connect(this.sfx);o.start(t);o.stop(t+.22);
    }
}
window.Sound=new SoundEngine();

EOF_SDVIG

echo "  ✦ $S/index.html"
mkdir -p $(dirname "$S/index.html")
cat > "$S/index.html" << 'EOF_SDVIG'
<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no,viewport-fit=cover">
    <meta name="mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
    <meta name="theme-color" content="#0a0806">
    <title>СДВИГ</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,600;0,700;1,500&family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style.css">
    <link rel="stylesheet" href="card-design.css">
    <!-- onTelegramAuth stub before any widget script -->
    <script>
        window.__tgP=null;window.__tgH=null;
        function onTelegramAuth(u){window.__tgH?window.__tgH(u):(window.__tgP=u);}
    </script>
    <script src="https://telegram.org/js/telegram-web-app.js"></script>
</head>
<body>

<!-- ═══ SPLASH ════════════════════════════════ -->
<div id="splash-screen" class="screen active">
    <div class="splash-flash" id="splash-flash"></div>
    <div class="splash-content">
        <div class="splash-emblem" id="spl-emblem">
            <div class="emblem-s">С</div>
        </div>
        <div class="splash-title-wrap" id="spl-title"></div>
        <div class="splash-bar-wrap">
            <div class="splash-bar-bg">
                <div class="splash-bar-fill" id="spl-fill"></div>
            </div>
            <p class="splash-status" id="spl-text">Инициализация…</p>
        </div>
    </div>
</div>

<!-- ═══ LOGIN ═════════════════════════════════ -->
<div id="login-screen" class="screen">
    <div class="login-wrap">
        <div class="login-head">
            <div class="login-badge">С</div>
            <h1 class="login-h1">СДВИГ</h1>
        </div>
        <div class="login-card">
            <p class="lc-label">Доступ к системе</p>
            <p class="lc-hint">Войдите чтобы открыть дело</p>

            <!-- Telegram OIDC / Widget -->
            <div id="tg-widget-area" class="tg-widget-area">
                <script src="https://telegram.org/js/telegram-widget.js?22"
                    data-telegram-login="sdvig_game_bot"
                    data-size="large" data-radius="8"
                    data-onauth="onTelegramAuth"
                    data-request-access="write"></script>
                <p id="tg-tip" class="tg-tip hidden">
                    Кнопка не появилась?
                    <a href="https://t.me/BotFather" target="_blank">@BotFather</a> → /setdomain
                </p>
            </div>

            <!-- Telegram OIDC button (if client-id is configured) -->
            <div id="oidc-btn-wrap" class="hidden">
                <button class="btn btn-amber" onclick="oidcLogin()">
                    Войти через Telegram
                </button>
            </div>

            <div class="lc-divider"><span>или</span></div>
            <button class="btn btn-glass-amber" onclick="guestLogin()">Войти как гость</button>
            <p style="font-size:11px;color:var(--tx3);text-align:center">Прогресс сохраняется на устройстве</p>
            <div class="lc-divider"><span>скоро</span></div>
            <button class="btn btn-outline" disabled>ВКонтакте</button>
        </div>
        <p class="login-footer">
            <a href="https://t.me/sdvig_game_bot" target="_blank">@sdvig_game_bot</a>
        </p>
    </div>
</div>

<!-- ═══ MAIN ══════════════════════════════════ -->
<div id="main-screen" class="screen">

    <header class="topbar">
        <div class="tb-left">
            <div class="tb-emblem">С</div>
            <span class="tb-brand">СДВИГ</span>
        </div>
        <div class="tb-right">
            <div class="topbar-stats">
                <div class="stat-pill sp-en" id="sp-energy">
                    <span id="ic-en"></span><span id="hud-en">100</span>
                </div>
                <div class="stat-pill sp-cr" id="sp-cred">
                    <span id="ic-cr"></span><span id="hud-cr">0</span>
                </div>
                <div class="stat-pill sp-rk" id="sp-rank">
                    <span id="ic-rk"></span><span>R<span id="hud-rk">1</span></span>
                </div>
            </div>
            <button class="snd-btn" id="snd-btn" onclick="toggleSound()">🔊</button>
        </div>
    </header>

    <div class="xp-band"><div id="xp-fill" class="xp-fill" style="width:0%"></div></div>

    <div class="tab-area">

        <!-- ─ ДЕЛА ─────────────────────────── -->
        <div class="tab-pane active" id="tab-cases">
            <div class="swipe-zone" id="swipe-zone">
                <!-- Parallax background -->
                <div class="parallax-bg" id="parallax-bg"></div>
                <!-- Rain canvas (injected by JS) -->

                <!-- Card stack -->
                <div class="scard sc3"></div>
                <div class="scard sc2"></div>
                <div class="scard sc1"></div>

                <!-- Main card -->
                <div id="main-card" class="case-card">
                    <!-- Stamps -->
                    <div class="stamp-wrap sw-r" id="s-ok"  style="opacity:0"><div class="stamp stamp-ok">ОДОБРЕНО</div></div>
                    <div class="stamp-wrap sw-l" id="s-no"  style="opacity:0"><div class="stamp stamp-no">ОТКЛОНЕНО</div></div>
                    <div class="stamp-wrap sw-u" id="s-sp"  style="opacity:0"><div class="stamp stamp-spec">ОСОБЫЙ ПРИЁМ</div></div>

                    <div class="cc-head">
                        <span class="cc-type"  id="cc-type">ДЕЛО</span>
                        <span class="cc-badge" id="cc-badge">•</span>
                    </div>

                    <div class="cc-body">
                        <div class="cc-icon-wrap">
                            <span class="cc-icon" id="cc-icon">🔍</span>
                        </div>
                        <h2 class="cc-title" id="cc-title"></h2>
                        <p  class="cc-text"  id="cc-text">Загружаем дело…</p>
                    </div>

                    <div class="cc-actions" id="cc-actions"></div>
                </div>

                <!-- Result -->
                <div id="result-overlay" class="result-overlay hidden">
                    <div class="ro-stamp" id="ro-stamp">РЕЗУЛЬТАТ</div>
                    <p class="ro-text" id="ro-text"></p>
                    <div class="ro-chips">
                        <div class="ro-chip" style="color:var(--amber-l)">+<span id="rw-xp">0</span> XP</div>
                        <div class="ro-chip" style="color:#60a5fa">+<span id="rw-cr">0</span> 💎</div>
                        <div class="ro-chip" style="color:#f87171">−<span id="rw-en">0</span> ⚡</div>
                    </div>
                    <button class="btn btn-amber" onclick="nextCard()">Следующее дело →</button>
                </div>
            </div>
        </div>

        <!-- ─ ИГРЫ ──────────────────────────── -->
        <div class="tab-pane" id="tab-games">
            <div class="pane-head">
                <h2 class="pane-title">Арсенал</h2>
            </div>
            <div class="game-row" onclick="launchGame('detective')">
                <div class="gr-stripe gr-gem"></div>
                <span class="gr-icon">💎</span>
                <div class="gr-info">
                    <div class="gr-name">Самоцветы</div>
                    <div class="gr-desc">Match-3 · ограниченные ходы · бустеры</div>
                    <div class="gr-prog">
                        <div class="gr-bar"><div id="det-bar" class="gr-fill" style="width:1%"></div></div>
                        <span class="gr-lvl">Ур. <span id="det-lvl">1</span></span>
                    </div>
                </div>
                <span class="gr-arrow">›</span>
            </div>

            <!-- Game viewport (full-screen overlay) -->
            <div id="gvp-wrap" class="gvp-wrap hidden">
                <div class="gvp-bar">
                    <button class="back-btn" onclick="closeGame()">
                        <span id="back-ic"></span> Выход
                    </button>
                    <span id="gvp-title" class="gvp-title"></span>
                    <div id="win-badge" class="win-badge hidden">WIN ✓</div>
                </div>
                <div id="game-vp" class="game-vp"></div>
            </div>
        </div>

        <!-- ─ КАРТА ──────────────────────────── -->
        <div class="tab-pane" id="tab-map">
            <div class="progress-map" id="progress-map">
                <!-- Filled by JS -->
            </div>
        </div>

        <!-- ─ АГЕНТ ──────────────────────────── -->
        <div class="tab-pane" id="tab-profile">
            <div class="profile-hero">
                <div class="profile-av" id="pr-av">?</div>
                <div class="profile-info">
                    <div class="profile-name" id="pr-name">Агент</div>
                    <div class="profile-arch" id="pr-arch">🔍 Детектив</div>
                    <div class="profile-id"   id="pr-id">ID —</div>
                </div>
            </div>
            <div class="stats-row" style="margin-top:14px">
                <div class="sg"><div class="sg-val" id="ps-rk">1</div><div class="sg-lbl">Ранг</div></div>
                <div class="sg"><div class="sg-val" id="ps-cr">0</div><div class="sg-lbl">Кредиты</div></div>
                <div class="sg"><div class="sg-val" id="ps-cs">0</div><div class="sg-lbl">Дел</div></div>
                <div class="sg"><div class="sg-val" id="ps-st">0</div><div class="sg-lbl">Серия</div></div>
            </div>
            <div class="sec-head">Навыки</div>
            <div class="skill-list" style="display:flex;flex-direction:column;gap:8px;padding:0 16px">
                <div class="skill-row">
                    <span class="sk-icon">🧠</span>
                    <div class="sk-body">
                        <div class="sk-name">Проницательность</div>
                        <div class="sk-desc">+XP за дело · 3+ открывает особый приём</div>
                        <div class="sk-bar"><div id="sk1-fill" class="sk-fill"></div></div>
                    </div>
                    <div class="sk-side">
                        <span class="sk-lv" id="sk1-lv">Lv.1</span>
                        <button class="up-btn" onclick="upgradeSkill(1)"><span id="sk1-c">50💎</span></button>
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
                        <button class="up-btn" onclick="upgradeSkill(2)"><span id="sk2-c">50💎</span></button>
                    </div>
                </div>
            </div>
            <div class="sec-head">Достижения</div>
            <div id="ach-grid" class="ach-grid"></div>
        </div>

        <!-- ─ МАГАЗИН ────────────────────────── -->
        <div class="tab-pane" id="tab-shop">
            <div class="pane-head"><h2 class="pane-title">Снаряжение</h2></div>
            <div class="shop-grid">
                <div class="shop-item" id="sh-coffee" onclick="buyCoffee()">
                    <div class="si-icon">☕</div>
                    <div class="si-name">Кофе</div>
                    <div class="si-desc">+35 ⚡ энергии</div>
                    <div class="si-price" id="sh-coffee-p">40 💎</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="si-icon">🔮</div>
                    <div class="si-name">Нейроусилитель</div>
                    <div class="si-desc">×2 XP · 5 дел</div>
                    <div class="si-price si-soon">Скоро</div>
                </div>
                <div class="shop-item shop-locked">
                    <div class="si-icon">🎯</div>
                    <div class="si-name">Особый приём</div>
                    <div class="si-desc">+1 доп. вариант</div>
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

    <!-- Floating bottom nav -->
    <nav class="bottom-nav">
        <button class="nb active" data-tab="cases"   onclick="switchTab('cases')">
            <span class="nb-icon" id="ni-cases"></span>
            <span class="nb-lbl">Дела</span>
        </button>
        <button class="nb" data-tab="games" onclick="switchTab('games')">
            <span class="nb-icon" id="ni-games"></span>
            <span class="nb-lbl">Игры</span>
        </button>
        <button class="nb" data-tab="map"   onclick="switchTab('map')">
            <span class="nb-icon" id="ni-map"></span>
            <span class="nb-lbl">Карта</span>
        </button>
        <button class="nb" data-tab="profile" onclick="switchTab('profile')">
            <span class="nb-icon" id="ni-profile"></span>
            <span class="nb-lbl">Агент</span>
            <span id="ach-badge" class="nb-badge hidden">!</span>
        </button>
        <button class="nb" data-tab="shop" onclick="switchTab('shop')">
            <span class="nb-icon" id="ni-shop"></span>
            <span class="nb-lbl">Магазин</span>
        </button>
    </nav>

</div><!-- /main-screen -->

<!-- ═══ HINT SHEET (Match-3 gate) ════════════ -->
<div id="hint-modal" class="hint-modal hidden">
    <div class="hm-head">
        <div class="hm-title">
            <span id="hm-ic"></span>
            <span id="hm-title">Самоцветы</span>
        </div>
        <button class="hm-close" onclick="closeHintGame()">Пропустить</button>
    </div>
    <div id="hm-vp" class="hm-vp"></div>
    <div class="hm-foot">
        <p class="hm-foot-text">Пройди испытание — разблокируй свайп</p>
    </div>
</div>
<div id="hm-back" class="modal-bg hidden" style="z-index:399" onclick="closeHintGame()"></div>

<!-- ═══ TOAST ═════════════════════════════════ -->
<div id="toast" class="toast hidden">
    <span class="toast-icon" id="t-icon">💡</span>
    <div>
        <div class="toast-title" id="t-title">УВЕДОМЛЕНИЕ</div>
        <div class="toast-desc"  id="t-desc"></div>
    </div>
</div>

<!-- ═══ DAILY ════════════════════════════════ -->
<div id="daily-modal" class="modal-bg hidden">
    <div class="daily-card">
        <div class="daily-icon">🎁</div>
        <h2 class="daily-h">Ежедневный бонус</h2>
        <p class="daily-streak">Серия: <span id="dd-days">1</span> дн. 🔥</p>
        <div class="daily-week" id="dd-week"></div>
        <div class="daily-chips">
            <div class="dc-chip">+50 💎</div>
            <div class="dc-chip">+30 ⚡</div>
        </div>
        <button class="btn btn-amber" onclick="claimDaily()">Забрать</button>
    </div>
</div>

<!-- ═══ ERROR ════════════════════════════════ -->
<div id="error-screen" class="screen">
    <div class="err-c">
        <div class="err-icon">⚠️</div>
        <h2 class="err-title">Ошибка системы</h2>
        <p class="err-msg" id="err-msg"></p>
        <button class="btn btn-amber" onclick="location.reload()">Перезагрузить</button>
    </div>
</div>

<script src="icons.js"></script>
<script src="sound.js"></script>
<script src="app.js"></script>
</body>
</html>

EOF_SDVIG

echo "  ✦ $S/app.js"
mkdir -p $(dirname "$S/app.js")
cat > "$S/app.js" << 'EOF_SDVIG'
'use strict';
// ═══════════════════════════════════════════════
//  СДВИГ · app.js v5
// ═══════════════════════════════════════════════
const tg=$=>document.getElementById($);
const TG=window.Telegram?.WebApp??null;

// ── State ──────────────────────────────────────
let user=null,scenarios=null,card=null,cardId='act1_scene1';
let cardLocked=true,swipeDir=null,activeTab='cases';
let gameDestroy=null,dailyClaimed=false;

const ACH=[
    {id:'r5', check:p=>p.rank>=5,           icon:'🏅',title:'АГЕНТ В ДЕЛЕ', desc:'Ранг 5'},
    {id:'r10',check:p=>p.rank>=10,          icon:'🏆',title:'ЭЛИТА',        desc:'Ранг 10'},
    {id:'c10',check:p=>(p.totalCases||0)>=10,icon:'📂',title:'ДЕТЕКТИВ',    desc:'10 дел'},
    {id:'c50',check:p=>(p.totalCases||0)>=50,icon:'🗃️',title:'АРХИВАРИУС',  desc:'50 дел'},
    {id:'s3', check:p=>(p.streak||0)>=3,    icon:'🔥',title:'НА СЕРИИ',    desc:'3 дня подряд'},
    {id:'sk1',check:p=>p.skill1>=3,         icon:'🧠',title:'ПРОНИЦАТЕЛЬ',  desc:'Проницательность Lv.3'},
];
const earned=new Set(JSON.parse(localStorage.getItem('sdvig_ach')||'[]'));

// ── OIDC config (from meta or backend) ────────
const OIDC_CLIENT_ID = document.querySelector('meta[name="tg-client-id"]')?.content || '';

// ── Boot ───────────────────────────────────────
document.addEventListener('DOMContentLoaded',async()=>{
    if(TG)try{TG.expand();TG.ready();}catch(e){}

    // Install auth handler
    window.__tgH = u=>{showScreen('splash-screen');widgetAuth(u);};
    if(window.__tgP){window.__tgH(window.__tgP);window.__tgP=null;}

    // Show OIDC button if configured
    if(OIDC_CLIENT_ID) tg('oidc-btn-wrap')?.classList.remove('hidden');

    // Widget tip after 6s
    setTimeout(()=>{
        const a=tg('tg-widget-area'),tip=tg('tg-tip');
        if(a&&tip&&!a.querySelector('iframe'))tip.classList.remove('hidden');
    },6000);

    injectIcons();
    await runSplash();
});

// ── Icons ──────────────────────────────────────
function injectIcons(){
    setIcon(tg('ic-en'),  'bolt');
    setIcon(tg('ic-cr'),  'diamond');
    setIcon(tg('ic-rk'),  'shield');
    setIcon(tg('ni-cases'),  'folder');
    setIcon(tg('ni-games'),  'gamepad');
    setIcon(tg('ni-map'),    'search');
    setIcon(tg('ni-profile'),'badge');
    setIcon(tg('ni-shop'),   'bag');
    setIcon(tg('back-ic'),   'arrowLeft');
    setIcon(tg('hm-ic'),     'lock');
}

// ── Cinematic splash ───────────────────────────
async function runSplash(){
    const fill=tg('spl-fill'),emb=tg('spl-emblem'),titleEl=tg('spl-title');
    const flash=tg('splash-flash');

    await wait(180);
    emb.classList.add('show');
    Sound.splashImpact();
    await wait(580);

    // Letter-by-letter title
    for(const[i,ch] of [...'СДВИГ'].entries()){
        const s=document.createElement('span');
        s.className='stl';s.textContent=ch;titleEl.appendChild(s);
        await wait(10);s.classList.add('in');s.style.animationDelay='0s';
        await wait(72);
    }
    await wait(200);

    // Load bar
    setSplash('Загрузка сценариев…');
    for(const[w,ms] of [[25,200],[60,250],[85,300],[99,180]]){
        fill.style.width=w+'%'; await wait(ms);
    }
    fill.style.width='100%';
    await wait(220);

    // 3 pulses
    Sound.splashImpact();
    for(let i=0;i<3;i++){
        emb.classList.add('pulse-once');
        emb.style.boxShadow='0 0 0 20px rgba(200,134,10,0),0 12px 40px rgba(0,0,0,.5)';
        await wait(380);emb.classList.remove('pulse-once');await wait(80);
    }
    await wait(120);

    // Cinematic exit — flash
    Sound.splashExit();
    flash.style.opacity='1';
    await wait(280);

    // Decide next screen
    if(TG?.initData?.length>0){setSplash('Telegram…');webappAuth();}
    else showScreen('login-screen');

    await wait(120);
    flash.style.transition='opacity .5s ease';flash.style.opacity='0';
}
function setSplash(t){const e=tg('spl-text');if(e)e.textContent=t;}

// ── Screen ─────────────────────────────────────
function showScreen(id){
    document.querySelectorAll('.screen').forEach(s=>s.classList.remove('active'));
    tg(id).classList.add('active');
}

// ── Auth ───────────────────────────────────────
function webappAuth(){
    fetch('/api/game/auth/webapp',{method:'POST',headers:{'Content-Type':'application/json'},
        body:JSON.stringify({initData:TG.initData,initDataUnsafe:TG.initDataUnsafe})})
    .then(r=>{if(!r.ok)throw 0;return r.json();}).then(onLogin)
    .catch(()=>showError('Ошибка WebApp-авторизации.\nПроверьте токен бота в Railway.'));
}

function widgetAuth(u){
    const p={};for(const[k,v] of Object.entries(u))p[k]=String(v);
    fetch('/api/game/auth/widget',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(p)})
    .then(r=>{if(!r.ok)return r.text().then(t=>{throw t;});return r.json();}).then(onLogin)
    .catch(e=>showError(typeof e==='string'?e:'Ошибка виджета.\n@BotFather → /setdomain'));
}

function oidcLogin(){
    const state=Math.random().toString(36).slice(2);
    sessionStorage.setItem('oidc_state',state);
    const redirect=encodeURIComponent(location.origin+'/auth/oidc-callback');
    const url=`https://id.telegram.org/auth?response_type=code&client_id=${OIDC_CLIENT_ID}&redirect_uri=${redirect}&scope=userinfo&state=${state}`;
    const popup=window.open(url,'TgOIDC','width=520,height=580,popup=1');
    window.addEventListener('message',function h(e){
        if(e.data?.type!=='tg_oidc')return;
        window.removeEventListener('message',h);
        popup?.close();
        if(e.data.error)return showError('OIDC ошибка: '+e.data.error);
        if(e.data.state!==state)return showError('Ошибка состояния OIDC');
        showScreen('splash-screen');setSplash('Авторизация…');
        fetch('/api/game/auth/oidc',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({code:e.data.code})})
        .then(r=>{if(!r.ok)throw 0;return r.json();}).then(onLogin)
        .catch(()=>showError('Ошибка OIDC авторизации'));
    });
}
window.oidcLogin=oidcLogin;

function guestLogin(){
    Sound.click();
    let gid=localStorage.getItem('sdvig_gid');
    if(!gid){gid='g'+Date.now();localStorage.setItem('sdvig_gid',gid);}
    showScreen('splash-screen');setSplash('Гостевой вход…');
    fetch('/api/game/auth/guest',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({deviceId:gid})})
    .then(r=>{if(!r.ok)throw 0;return r.json();}).then(onLogin)
    .catch(()=>{
        // Full offline fallback
        onLogin({providerId:'guest:'+gid,firstName:'Гость',username:'guest',
            energy:100,credits:150,rank:1,xp:0,skill1:1,skill2:1,
            detectiveLvl:1,totalCases:0,streak:0,archetype:'detective'});
    });
}
window.guestLogin=guestLogin;

function showError(m){tg('err-msg').textContent=m;showScreen('error-screen');}

// ── Login success ──────────────────────────────
async function onLogin(profile){
    user=profile;
    await Sound.init();
    updateHUD(profile);updateProfile(profile);renderAchGrid();
    showScreen('main-screen');
    initSwipe();initParallax();initRain();
    await loadScenarios();
    loadCard(cardId);
    checkDailyBonus();
    updateShopAfford();
    vib(30);
}

// ── Sound toggle ───────────────────────────────
function toggleSound(){
    const on=Sound.toggle();
    tg('snd-btn').textContent=on?'🔊':'🔇';
}
window.toggleSound=toggleSound;

// ── Scenarios ──────────────────────────────────
async function loadScenarios(){
    if(scenarios)return;
    try{const r=await fetch('/scenarios/detective.json');scenarios=await r.json();}
    catch{scenarios={cards:{}};}
}
function getCard(id){return scenarios?.cards?.[id]??null;}

// ── Card load ──────────────────────────────────
function loadCard(id){
    const c=getCard(id);if(!c){loadCard('act1_scene1');return;}
    card=c;cardId=id;cardLocked=!c.isEnding;

    const el=tg('main-card');
    el.className='case-card card-in ct-'+(c.type||'evidence');
    tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
    tg('result-overlay').classList.add('hidden');

    tg('cc-type').textContent=fmtType(c.type);
    tg('cc-badge').textContent=c.actTitle||(c.act?'АКТ '+c.act:'');
    tg('cc-icon').textContent=c.icon||'🔍';
    tg('cc-title').textContent=c.title||'';

    // Ink reveal on text
    const tx=tg('cc-text');
    tx.style.animation='none';tx.textContent=c.text||'';
    void tx.offsetWidth;
    tx.style.animation='';

    renderActions();
    Sound.cardLoad();vib(15);
}

function fmtType(t){
    return ({crime:'ПРЕСТУПЛЕНИЕ',evidence:'УЛИКА',suspect:'ПОДОЗРЕВАЕМЫЙ',
        witness:'СВИДЕТЕЛЬ',testimony:'ПОКАЗАНИЯ',mystery:'ТАЙНА',
        action:'ОПЕРАЦИЯ',revelation:'ПРОРЫВ',briefing:'СВОДКА',
        ending:'ФИНАЛ',ending_bad:'ФИНАЛ',chase:'ПОГОНЯ'}[t]||(t||'ДЕЛО').toUpperCase());
}

// ── Actions panel ──────────────────────────────
function renderActions(){
    const a=tg('cc-actions');
    const hasSpecial=(user?.skill1||1)>=3&&card?.specialOption;

    if(cardLocked){
        a.innerHTML=`
            <div class="lock-panel">
                <div class="lp-icon">${icon('lock')}</div>
                <div class="lp-body">
                    <div class="lp-title">Свайп заблокирован</div>
                    <div class="lp-sub">Пройди Самоцветы чтобы принять решение</div>
                </div>
            </div>
            <button class="btn-play" onclick="openCardGame()">
                ${icon('gamepad')} Играть в Самоцветы
            </button>
            <div class="swipe-locked">${icon('lock')} Свайп недоступен</div>`;
    } else {
        const hint=card?.hint;
        a.innerHTML=`
            ${hint?`<div class="hint-panel"><span class="hp-icon">💡</span><p class="hp-text">${hint}</p></div>`:''}
            <div class="swipe-hint">
                <span class="sh-no">← ${card?.leftOption||'ОТКЛОНИТЬ'}</span>
                <span class="sh-mid">${icon('lockOpen')}</span>
                <span class="sh-ok">${card?.rightOption||'ОДОБРИТЬ'} →</span>
            </div>
            ${hasSpecial?`<div class="sh-up">↑ ОСОБЫЙ ПРИЁМ (−10⚡)</div>`:''}`;
    }
}

// ── Swipe engine ───────────────────────────────
function initSwipe(){
    const el=tg('main-card');
    let sx=0,sy=0,cx=0,cy=0,dragging=false,lx=0,vel=0,lt=0;

    const start=e=>{
        if(!tg('result-overlay').classList.contains('hidden'))return;
        dragging=true;sx=gx(e);sy=gy(e);lx=sx;lt=Date.now();
        el.style.transition='none';el.style.animationPlayState='paused';
    };
    const move=e=>{
        if(!dragging)return;e.preventDefault();
        cx=gx(e);cy=gy(e);
        const now=Date.now();vel=(cx-lx)/Math.max(1,now-lt);lx=cx;lt=now;
        const dx=cx-sx,dy=cy-sy;
        const rot=dx/18;
        el.style.transform=`rotate(${rot}deg) translateX(${dx}px) translateY(${Math.min(0,dy*.3)}px)`;
        const r=Math.min(1,Math.abs(dx)/80);
        const ru=Math.min(1,Math.max(0,-dy-40)/60);

        if(dy<-40&&Math.abs(dx)<60){
            // Swipe UP
            el.classList.remove('tilt-l','tilt-r');el.classList.add('tilt-u');
            tg('s-sp').style.opacity=ru;tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';
        } else if(dx<-28){
            el.classList.add('tilt-l');el.classList.remove('tilt-r','tilt-u');
            tg('s-no').style.opacity=r;tg('s-ok').style.opacity='0';tg('s-sp').style.opacity='0';
        } else if(dx>28){
            el.classList.add('tilt-r');el.classList.remove('tilt-l','tilt-u');
            tg('s-ok').style.opacity=r;tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
        } else {
            el.classList.remove('tilt-l','tilt-r','tilt-u');
            tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
        }
    };
    const end=()=>{
        if(!dragging)return;dragging=false;
        el.style.animationPlayState='running';
        const dx=cx-sx,dy=cy-sy,T=85,V=0.36;
        el.style.transition='transform .3s ease';
        if(dy<-100&&Math.abs(dx)<80)      flyCard('up');
        else if(dx<-T||vel<-V)            flyCard('left');
        else if(dx>T||vel>V)              flyCard('right');
        else resetCardPos();
    };

    el.addEventListener('touchstart',start,{passive:true});
    el.addEventListener('mousedown',start);
    window.addEventListener('touchmove',move,{passive:false});
    window.addEventListener('mousemove',move);
    window.addEventListener('touchend',end);
    window.addEventListener('mouseup',end);
}
const gx=e=>e.touches?e.touches[0].clientX:e.clientX;
const gy=e=>e.touches?e.touches[0].clientY:e.clientY;

function resetCardPos(){
    const el=tg('main-card');
    el.style.transform='rotate(-.4deg)';
    el.classList.remove('tilt-l','tilt-r','tilt-u');
    tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
}

function flyCard(dir){
    if(cardLocked){
        const el=tg('main-card');
        el.classList.add('shake');setTimeout(()=>el.classList.remove('shake'),600);
        resetCardPos();Sound.locked();vib([80,40,80]);
        toast('🎮','ЗАБЛОКИРОВАНО','Сначала пройди Самоцветы!');
        return;
    }
    const hasSpecial=(user?.skill1||1)>=3&&card?.specialOption;
    if(dir==='up'&&!hasSpecial){resetCardPos();return;}

    // Dust particles
    spawnDust(dir);

    // Stamp animation
    const sMap={left:'s-no',right:'s-ok',up:'s-sp'};
    const sEl=tg(sMap[dir]);
    if(sEl){sEl.style.opacity='1';sEl.querySelector('.stamp')?.classList.add('land');}

    if(dir==='left')Sound.swipeL();else Sound.swipeR();
    vib(25);swipeDir=dir;

    const el=tg('main-card');
    setTimeout(()=>{
        el.style.transition='transform .38s cubic-bezier(.55,0,1,.45),opacity .38s ease';
        if(dir==='left') el.style.transform='translateX(-160vw) rotate(-25deg)';
        else if(dir==='right')el.style.transform='translateX(160vw) rotate(25deg)';
        else el.style.transform='translateY(-140vh) scale(.8)';
        el.style.opacity='0';
        sendChoice(dir);
    },100);
}

function sendChoice(dir){
    if(!user||!card)return;
    const extra=dir==='up'?'&special=true':'';
    fetch(`/api/game/choice?providerId=${enc(user.providerId)}&direction=${dir==='up'?'up':dir}${extra}`,{method:'POST'})
    .then(r=>{if(!r.ok)return r.text().then(t=>{toast('⚡','Ошибка',t);throw 0;});return r.json();})
    .then(data=>{
        user=data.profile;updateHUD(user);
        const ok=dir==='right'||dir==='up';
        const rs=tg('ro-stamp');
        rs.textContent=dir==='up'?'ОСОБЫЙ ПРИЁМ':ok?'ОДОБРЕНО':'ОТКЛОНЕНО';
        rs.className='ro-stamp '+(ok?'ok':'no');
        tg('ro-text').textContent=dir==='up'?(card.specialResult||card.rightResult||''):ok?(card.rightResult||''):(card.leftResult||'');
        tg('rw-xp').textContent=data.xpGained;
        tg('rw-cr').textContent=data.creditsGained;
        tg('rw-en').textContent=data.energyLost;
        setTimeout(()=>{
            tg('result-overlay').classList.remove('hidden');
            if(ok)launchConfetti();
            checkAch(data.profile);
        },280);
        vib([30,20,60]);
    })
    .catch(()=>{
        const el=tg('main-card');
        el.style.transition='transform .35s ease';el.style.transform='rotate(-.4deg)';
        el.style.opacity='1';el.classList.remove('tilt-l','tilt-r','tilt-u');
    });
}

function nextCard(){
    tg('result-overlay').classList.add('hidden');
    const dir=swipeDir==='up'?'right':swipeDir;
    const nid=dir==='right'?card?.rightNext:card?.leftNext;
    const el=tg('main-card');
    el.style.transition='none';el.style.opacity='0';
    requestAnimationFrame(()=>requestAnimationFrame(()=>{
        el.style.transition='opacity .25s ease';el.style.opacity='1';
        loadCard(nid&&getCard(nid)?nid:'act1_scene1');
    }));
}
window.nextCard=nextCard;

// ── Card game gate ─────────────────────────────
function openCardGame(){
    Sound.click();
    const level=Math.max(1,((card?.act||1)-1)*2+1);
    tg('hm-title').textContent='💎 Самоцветы';
    const modal=tg('hint-modal'),back=tg('hm-back');
    modal.classList.remove('hidden','closing');back.classList.remove('hidden');
    const vp=tg('hm-vp');vp.innerHTML='';
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    import('./games/detective.js').then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp,level,onCardGameWon,true);
    }).catch(()=>{vp.innerHTML='<p style="color:var(--no);padding:24px;text-align:center">⚠️ Ошибка загрузки</p>';});
}
window.openCardGame=openCardGame;

function onCardGameWon(){
    cardLocked=false;closeHintGame();Sound.unlock();vib([30,20,30,20,80]);
    tg('main-card').classList.add('unlocked');
    setTimeout(()=>tg('main-card').classList.remove('unlocked'),800);
    renderActions();
    toast('🔓','РАЗБЛОКИРОВАНО','Теперь прими решение — свайп влево или вправо');
    fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=detective`,{method:'POST'})
    .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
}

function closeHintGame(){
    const m=tg('hint-modal'),b=tg('hm-back');
    m.classList.add('closing');setTimeout(()=>{m.classList.add('hidden');b.classList.add('hidden');},240);
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    tg('hm-vp').innerHTML='';
}
window.closeHintGame=closeHintGame;

// ── Games tab ──────────────────────────────────
function launchGame(type){
    tg('gvp-wrap').classList.remove('hidden');
    tg('gvp-title').textContent='💎 Самоцветы';
    tg('win-badge').classList.add('hidden');
    const vp=tg('game-vp');vp.innerHTML='';
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    import('./games/detective.js').then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp,user?.detectiveLvl||1,()=>{
            tg('win-badge').classList.remove('hidden');Sound.win3();vib([30,20,30,20,100]);
            toast('🏆','УРОВЕНЬ ПРОЙДЕН','+50 XP');
            fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=detective`,{method:'POST'})
            .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
        },false);
    }).catch(()=>{vp.innerHTML='<p style="color:var(--no);text-align:center;padding:32px">⚠️ Ошибка</p>';});
}
window.launchGame=launchGame;
function closeGame(){
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    tg('gvp-wrap').classList.add('hidden');tg('game-vp').innerHTML='';tg('win-badge').classList.add('hidden');
}
window.closeGame=closeGame;

// ── HUD ────────────────────────────────────────
function updateHUD(p){
    tg('hud-en').textContent=p.energy;
    tg('hud-cr').textContent=p.credits;
    tg('hud-rk').textContent=p.rank;
    const xpMax=p.rank*150;
    tg('xp-fill').style.width=Math.min(100,(p.xp/xpMax)*100)+'%';
    const dl=p.detectiveLvl||1;
    tg('det-lvl').textContent=dl;tg('det-bar').style.width=Math.min(100,dl)+'%';
}

// ── Profile ────────────────────────────────────
function updateProfile(p){
    const n=p.firstName||p.username||'Агент';
    tg('pr-av').textContent=n[0].toUpperCase();
    tg('pr-name').textContent=n;
    tg('pr-id').textContent='ID '+(p.providerId||'—').replace(/^(tg:|guest:)/,'');
    tg('pr-arch').textContent=({detective:'🔍 Детектив',doctor:'⚕️ Медик',hacker:'💻 Хакер'}[p.archetype]||'🔍 Детектив');
    tg('ps-rk').textContent=p.rank;tg('ps-cr').textContent=p.credits;
    tg('ps-cs').textContent=p.totalCases||0;tg('ps-st').textContent=p.streak||0;
    const s1=p.skill1||1,s2=p.skill2||1;
    tg('sk1-lv').textContent='Lv.'+s1;tg('sk1-c').textContent=(s1*50)+'💎';
    tg('sk2-lv').textContent='Lv.'+s2;tg('sk2-c').textContent=(s2*50)+'💎';
    tg('sk1-fill').style.width=Math.min(100,s1*10)+'%';
    tg('sk2-fill').style.width=Math.min(100,s2*10)+'%';
}

function renderAchGrid(){
    const g=tg('ach-grid');if(!g)return;
    g.innerHTML=ACH.map(d=>{
        const ok=earned.has(d.id);
        return `<div class="ach-b ${ok?'earned':'locked'}">
            <div class="ach-icon">${ok?d.icon:'❓'}</div>
            <div class="ach-lbl">${ok?d.title:'???'}</div>
        </div>`;
    }).join('');
}

// ── Progress map ───────────────────────────────
function renderProgressMap(){
    const container=tg('progress-map');
    if(!container||!scenarios)return;
    const cards=Object.values(scenarios.cards||{});
    const chapters=[
        {id:'act1',label:'Акт I · Место преступления',color:'#ef4444',cards:cards.filter(c=>c.act===1)},
        {id:'act2',label:'Акт II · Подозреваемые',    color:'#c8860a',cards:cards.filter(c=>c.act===2)},
        {id:'act3',label:'Акт III · Заказчик',         color:'#a855f7',cards:cards.filter(c=>c.act===3)},
        {id:'act4',label:'Акт IV · Развязка',          color:'#fbbf24',cards:cards.filter(c=>c.act===4)},
    ].filter(ch=>ch.cards.length>0);

    let html='<div style="padding-bottom:40px">';
    let levelNum=1;
    for(const ch of chapters){
        html+=`<div class="map-scene">
            <div class="map-chapter-label" style="border-color:${ch.color}40;color:${ch.color}">${ch.label}</div>
        </div>
        <div class="map-levels">`;
        for(const c of ch.cards){
            const isCurrent=c.id===cardId;
            const isDone=cardHistory?.includes(c.id)||false;
            const isLocked=false;
            const cls=isCurrent?'current':isDone?'done':isLocked?'locked':'';
            html+=`<div class="map-level-row">
                <div class="map-node ${cls}" onclick="jumpToCard('${c.id}')" title="${c.title||''}">
                    <div class="map-node-num">${levelNum}</div>
                    <div class="map-node-icon">${isCurrent?'▶':isDone?'★':c.icon||'○'}</div>
                </div>
            </div>
            ${levelNum<ch.cards.length?'<div class="map-connector"></div>':''}`;
            levelNum++;
        }
        html+='</div><div style="height:12px"></div>';
    }
    html+='</div>';
    container.innerHTML=html;
}

function jumpToCard(id){
    if(!getCard(id))return;
    switchTab('cases');
    setTimeout(()=>loadCard(id),200);
}
window.jumpToCard=jumpToCard;

// ── Tabs ───────────────────────────────────────
function switchTab(name){
    if(activeTab===name)return;
    if(activeTab==='games')closeGame();
    document.querySelectorAll('.tab-pane').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.nb').forEach(b=>b.classList.remove('active'));
    tg('tab-'+name).classList.add('active');
    document.querySelector(`[data-tab="${name}"]`)?.classList.add('active');
    activeTab=name;Sound.click();vib(10);
    if(name==='profile'){updateProfile(user);renderAchGrid();tg('ach-badge').classList.add('hidden');}
    if(name==='map')renderProgressMap();
    if(name==='shop')updateShopAfford();
}
window.switchTab=switchTab;

// ── Skills ─────────────────────────────────────
function upgradeSkill(n){
    if(!user)return;Sound.click();
    fetch(`/api/game/upgrade-skill?providerId=${enc(user.providerId)}&skillNum=${n}`,{method:'POST'})
    .then(r=>{if(!r.ok)return r.text().then(t=>{toast('💎','Мало кредитов',t);throw 0;});return r.json();})
    .then(p=>{user=p;updateHUD(p);updateProfile(p);vib([20,20,40]);
        toast('🧠','НАВЫК',n===1?'Проницательность Lv.'+p.skill1:'Технологии Lv.'+p.skill2);})
    .catch(()=>{});
}
window.upgradeSkill=upgradeSkill;

// ── Shop ───────────────────────────────────────
function buyCoffee(){
    if(!user)return;Sound.click();
    fetch(`/api/game/buy-coffee?providerId=${enc(user.providerId)}`,{method:'POST'})
    .then(r=>{if(!r.ok)return r.text().then(t=>{toast('☕','Мало кредитов',t);throw 0;});return r.json();})
    .then(p=>{user=p;updateHUD(p);updateProfile(p);updateShopAfford();toast('☕','КОФЕ','+35 ⚡');vib(30);})
    .catch(()=>{});
}
window.buyCoffee=buyCoffee;
function updateShopAfford(){
    if(!user)return;
    const el=tg('sh-coffee');if(!el)return;
    el.classList.toggle('cant-afford',user.credits<40);
    const pr=tg('sh-coffee-p');if(pr)pr.textContent=user.credits>=40?'40 💎':'40 💎 (нет)';
}

// ── Daily bonus ────────────────────────────────
function checkDailyBonus(){
    if(!user)return;
    fetch('/api/game/daily-bonus?providerId='+enc(user.providerId))
    .then(r=>r.ok?r.json():null)
    .then(d=>{if(!d||!d.available)return;buildWeek(d.streak||1);tg('dd-days').textContent=d.streak||1;tg('daily-modal').classList.remove('hidden');})
    .catch(()=>{});
}
function buildWeek(s){
    const w=tg('dd-week');if(!w)return;w.innerHTML='';
    for(let i=1;i<=7;i++){
        const d=document.createElement('div');d.className='dw-dot';
        if(i<(s%7||(s>=7?8:0)))d.classList.add('done');
        if(i===(s%7||7))d.classList.add('today');
        d.textContent=i;w.appendChild(d);
    }
}
function claimDaily(){
    if(!user||dailyClaimed)return;dailyClaimed=true;Sound.click();
    tg('daily-modal').classList.add('hidden');
    fetch('/api/game/daily-bonus/claim?providerId='+enc(user.providerId),{method:'POST'})
    .then(r=>r.ok?r.json():null)
    .then(d=>{if(!d)return;user=d.profile;updateHUD(user);updateProfile(user);
        toast('🎁','БОНУС',`+50💎 · +30⚡`);vib([30,20,30,20,80]);})
    .catch(()=>{});
}
window.claimDaily=claimDaily;

// ── Achievements ───────────────────────────────
function checkAch(p){
    let found=false;
    for(const d of ACH){
        if(!earned.has(d.id)&&d.check(p)){
            earned.add(d.id);localStorage.setItem('sdvig_ach',JSON.stringify([...earned]));
            if(!found){setTimeout(()=>toast(d.icon,d.title,d.desc),600);found=true;}
            const b=tg('ach-badge');if(b){b.textContent='!';b.classList.remove('hidden');}
        }
    }
}

// ── Toast ──────────────────────────────────────
let _tt=null;
function toast(ic,title,desc){
    const el=tg('toast');
    tg('t-icon').textContent=ic;tg('t-title').textContent=title;tg('t-desc').textContent=desc;
    el.classList.remove('hidden','out');clearTimeout(_tt);
    _tt=setTimeout(()=>{el.classList.add('out');setTimeout(()=>el.classList.add('hidden'),300);},3200);
    vib(18);
}

// ── Visual Effects ─────────────────────────────

// Rain
let _rainRAF=null;
function initRain(){
    const zone=tg('swipe-zone');if(!zone)return;
    const canvas=document.createElement('canvas');
    canvas.className='rain-canvas';
    zone.insertBefore(canvas,zone.firstChild);
    const ctx=canvas.getContext('2d');
    const drops=[];
    function resize(){canvas.width=zone.clientWidth;canvas.height=zone.clientHeight;}
    resize();window.addEventListener('resize',resize);
    for(let i=0;i<70;i++)drops.push({x:Math.random()*canvas.width,y:Math.random()*canvas.height,s:2+Math.random()*3,l:8+Math.random()*12});
    function frame(){
        if(_rainRAF===null)return;
        ctx.clearRect(0,0,canvas.width,canvas.height);
        ctx.strokeStyle='rgba(180,200,240,.45)';ctx.lineWidth=.7;
        for(const d of drops){
            ctx.beginPath();ctx.moveTo(d.x,d.y);ctx.lineTo(d.x-.8,d.y+d.l);ctx.stroke();
            d.y+=d.s;if(d.y>canvas.height){d.y=-d.l;d.x=Math.random()*canvas.width;}
        }
        _rainRAF=requestAnimationFrame(frame);
    }
    _rainRAF=requestAnimationFrame(frame);
}

// Parallax
function initParallax(){
    const bg=tg('parallax-bg');if(!bg)return;
    if(window.DeviceOrientationEvent){
        window.addEventListener('deviceorientation',e=>{
            const rx=(e.beta||0)/90*12,ry=(e.gamma||0)/90*12;
            bg.style.transform=`translate(${ry*.5}px,${rx*.5}px)`;
        });
    }
}

// Dust particles on swipe
function spawnDust(dir){
    const zone=tg('swipe-zone');if(!zone)return;
    const rect=zone.getBoundingClientRect();
    const cx=rect.width/2,cy=rect.height*.55;
    for(let i=0;i<10;i++){
        const p=document.createElement('div');
        p.className='dust';
        const ang=(dir==='left'?Math.PI:dir==='up'?-Math.PI/2:0)+(Math.random()-.5)*1.8;
        const dist=25+Math.random()*40;
        Object.assign(p.style,{left:cx+'px',top:cy+'px'});
        zone.appendChild(p);
        requestAnimationFrame(()=>{
            p.style.transform=`translate(${Math.cos(ang)*dist}px,${Math.sin(ang)*dist}px) scale(.4)`;
            p.style.opacity='0';
        });
        setTimeout(()=>p.remove(),450);
    }
}

// Confetti
function launchConfetti(){
    const cols=['#c8860a','#e8a030','#ffd700','#ffed4a','#ffffff','#a855f7'];
    for(let i=0;i<60;i++){
        const p=document.createElement('div');
        p.className='confetti-p';
        const col=cols[Math.floor(Math.random()*cols.length)];
        const dur=1.4+Math.random()*.8;
        const delay=Math.random()*.5;
        Object.assign(p.style,{
            left:Math.random()*100+'%',
            width:(4+Math.random()*7)+'px',height:(4+Math.random()*7)+'px',
            background:col,
            animationDuration:dur+'s',animationDelay:delay+'s',
            transform:`rotate(${Math.random()*360}deg)`,
            borderRadius:Math.random()>.5?'50%':'2px',
        });
        document.body.appendChild(p);
        setTimeout(()=>p.remove(),(delay+dur)*1000+100);
    }
}

// ── Utils ──────────────────────────────────────
function enc(s){return encodeURIComponent(s||'');}
function vib(p){try{if(navigator.vibrate)navigator.vibrate(p);}catch(e){}}
function wait(ms){return new Promise(r=>setTimeout(r,ms));}

EOF_SDVIG

echo "  ✦ $S/games/detective.js"
mkdir -p $(dirname "$S/games/detective.js")
cat > "$S/games/detective.js" << 'EOF_SDVIG'
// ═══════════════════════════════════════════════
//  САМОЦВЕТЫ v5 · Full-screen Match-3
//  Drag-to-swap · Limited moves · Boosters · Canvas particles
// ═══════════════════════════════════════════════

const GEM_GRAD={
    red:   'radial-gradient(circle at 38% 32%,#ff9999,#dd1111 50%,#880000)',
    blue:  'radial-gradient(circle at 38% 32%,#99bbff,#1155ee 50%,#001188)',
    green: 'radial-gradient(circle at 38% 32%,#99ffaa,#11bb44 50%,#005511)',
    yellow:'radial-gradient(circle at 38% 32%,#ffee99,#ddaa11 50%,#885500)',
    purple:'radial-gradient(circle at 38% 32%,#ee99ff,#aa11ee 50%,#550077)',
    orange:'radial-gradient(circle at 38% 32%,#ffcc88,#ee7722 50%,#882200)',
    bomb:  'radial-gradient(circle at 38% 32%,#fff799,#ffdd00 50%,#cc8800)',
    rainbow:'radial-gradient(circle at 30% 30%,#ff6b6b,#ffd93d 30%,#6bcb77 60%,#4d96ff)',
};
const GEM_GLOW={
    red:'rgba(200,0,0,.7)',blue:'rgba(10,60,220,.7)',green:'rgba(0,160,50,.7)',
    yellow:'rgba(200,150,0,.7)',purple:'rgba(140,0,210,.7)',orange:'rgba(200,90,0,.7)',
    bomb:'rgba(255,200,0,.9)',rainbow:'rgba(255,255,255,.6)',
};
const COLORS=['red','blue','green','yellow','purple','orange'];
const ROWS=9,COLS=9;
let _destroyed=false;

export function initGame(viewport,level,onWin,isGateMode=false){
    _destroyed=false;
    viewport.innerHTML='';
    Object.assign(viewport.style,{
        display:'flex',flexDirection:'column',
        width:'100%',height:'100%',
        background:'#070508',
        userSelect:'none',WebkitUserSelect:'none',
        overflow:'hidden',
    });

    // ── State ──────────────────────────────────
    const miss=getMission(level);
    let board=mk2d(ROWS,COLS,null),spec=mk2d(ROWS,COLS,null),iceB=mk2d(ROWS,COLS,0);
    let colGem=0,iceGem=0,combo=0;
    let movesLeft=getMoves(level);
    let active=true,busy=false,selR=null,selC=null;
    let boosterMode=null; // 'hammer'|'lightning'|null
    let boosters={hammer:3,lightning:2,bomb:1};

    // ── Layout calc ────────────────────────────
    const vpW=viewport.clientWidth||window.innerWidth;
    const vpH=viewport.clientHeight||(window.innerHeight-52-4);
    const headerH=56,boosterH=60,padding=8;
    const gridH=vpH-headerH-boosterH-padding*2;
    const GAP=3;
    const CELL=Math.floor(Math.min((vpW-padding*2-GAP*(COLS-1))/COLS,(gridH-GAP*(ROWS-1))/ROWS));
    const gridW=CELL*COLS+GAP*(COLS-1);

    // ── Header ─────────────────────────────────
    const hdr=el('div');
    css(hdr,{
        height:headerH+'px',minHeight:headerH+'px',
        display:'flex',alignItems:'center',justifyContent:'space-between',
        padding:'0 16px',flexShrink:'0',
        background:'rgba(0,0,0,.6)',backdropFilter:'blur(16px)',WebkitBackdropFilter:'blur(16px)',
        borderBottom:'1px solid rgba(255,255,255,.08)',
    });
    const lvEl=el('div');css(lvEl,{fontSize:'11px',fontWeight:'700',color:'rgba(255,255,255,.5)',letterSpacing:'1.5px',fontFamily:"'JetBrains Mono',monospace",textTransform:'uppercase'});
    lvEl.textContent=`УР. ${level}`;
    const msEl=el('div');css(msEl,{fontSize:'13px',fontWeight:'700',color:'#fff',textAlign:'center',flex:'1',padding:'0 8px'});
    const mvEl=el('div');
    css(mvEl,{display:'flex',flexDirection:'column',alignItems:'center',gap:'1px'});
    const mvNum=el('div');css(mvNum,{fontSize:'22px',fontWeight:'800',color:'#fff',lineHeight:'1',fontFamily:"'Playfair Display',serif"});
    const mvLbl=el('div');css(mvLbl,{fontSize:'9px',letterSpacing:'1.5px',color:'rgba(255,255,255,.4)',textTransform:'uppercase'});
    mvLbl.textContent='ХОДОВ';
    mvEl.append(mvNum,mvLbl);
    hdr.append(lvEl,msEl,mvEl);
    viewport.appendChild(hdr);
    function refreshHUD(){
        mvNum.textContent=movesLeft;
        mvNum.style.color=movesLeft<=5?'#ef4444':movesLeft<=10?'#f59e0b':'#fff';
        refreshMission();
    }

    // ── Grid area ──────────────────────────────
    const gridArea=el('div');
    css(gridArea,{
        flex:'1',display:'flex',alignItems:'center',justifyContent:'center',
        position:'relative',overflow:'hidden',
    });

    // Particle canvas
    const pCanvas=el('canvas');
    css(pCanvas,{position:'absolute',inset:'0',pointerEvents:'none',zIndex:'10'});
    pCanvas.width=vpW;pCanvas.height=vpH-headerH-boosterH;
    const pCtx=pCanvas.getContext('2d');
    const particles=[];

    // Grid wrapper
    const gridWrap=el('div');
    css(gridWrap,{
        background:'linear-gradient(145deg,#14101e,#0a0810)',
        borderRadius:'18px',padding:padding+'px',
        boxShadow:'0 8px 40px rgba(0,0,0,.6),inset 0 1px 0 rgba(255,255,255,.06)',
        position:'relative',flexShrink:'0',
    });

    const grid=el('div');
    css(grid,{
        display:'grid',
        gridTemplateColumns:`repeat(${COLS},${CELL}px)`,
        gridTemplateRows:`repeat(${ROWS},${CELL}px)`,
        gap:GAP+'px',position:'relative',
    });

    // Combo overlay
    const comboOverlay=el('div');
    css(comboOverlay,{position:'absolute',inset:'0',pointerEvents:'none',overflow:'hidden',borderRadius:'18px',zIndex:'20'});
    gridWrap.append(grid,comboOverlay);
    gridArea.append(pCanvas,gridWrap);
    viewport.appendChild(gridArea);

    // Particle animation loop
    let pRAF=requestAnimationFrame(function pLoop(){
        if(_destroyed)return;
        pCtx.clearRect(0,0,pCanvas.width,pCanvas.height);
        for(let i=particles.length-1;i>=0;i--){
            const p=particles[i];
            p.x+=p.vx;p.y+=p.vy;p.vy+=.15;p.life-=p.decay;
            if(p.life<=0){particles.splice(i,1);continue;}
            pCtx.globalAlpha=p.life;pCtx.fillStyle=p.color;
            pCtx.beginPath();pCtx.arc(p.x,p.y,p.r*p.life,0,Math.PI*2);pCtx.fill();
        }
        pCtx.globalAlpha=1;
        pRAF=requestAnimationFrame(pLoop);
    });

    function emitParticles(cellEl,color,n=7){
        const gr=gridWrap.getBoundingClientRect();
        const cr=cellEl.getBoundingClientRect();
        const ox=cr.left-gr.left+cr.width/2;
        const oy=cr.top-gr.top+cr.height/2;
        const gl=GEM_GLOW[color]||'rgba(255,255,255,.8)';
        for(let i=0;i<n;i++){
            const ang=(i/n)*Math.PI*2+Math.random()*.6;
            const sp=2+Math.random()*4;
            particles.push({x:ox,y:oy,vx:Math.cos(ang)*sp,vy:Math.sin(ang)*sp-1.5,r:2+Math.random()*4,color:gl.replace('.7','.9').replace('.8','.9'),life:1,decay:.025+Math.random()*.02});
        }
    }

    // ── Cell DOM ───────────────────────────────
    const cells=mk2d(ROWS,COLS,null);
    const R=Math.max(4,Math.round(CELL*.16));
    for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
        const cell=el('div');
        css(cell,{width:CELL+'px',height:CELL+'px',borderRadius:R+'px',
            background:'rgba(255,255,255,.04)',border:'1px solid rgba(255,255,255,.05)',
            position:'relative',boxSizing:'border-box',cursor:'pointer',flexShrink:'0'});
        cell.dataset.r=r;cell.dataset.c=c;
        grid.appendChild(cell);cells[r][c]=cell;
    }

    // ── Gem rendering ──────────────────────────
    function makeGem(color,isIce,isBomb,isRainbow){
        const pad=Math.max(2,Math.round(CELL*.07));
        const gm=el('div');gm.className='gm';
        const gc=isRainbow?'rainbow':isBomb?'bomb':color;
        css(gm,{position:'absolute',inset:`${pad}px`,borderRadius:'50%',
            background:GEM_GRAD[gc]||'#888',willChange:'transform',
            boxShadow:[
                'inset 0 -4px 8px rgba(0,0,0,.32)',
                'inset 0 5px 10px rgba(255,255,255,.22)',
                `0 3px 12px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'}`,
                '0 0 0 1px rgba(255,255,255,.06)',
            ].join(','),
        });
        // Main shine
        const s=el('div');css(s,{position:'absolute',top:'11%',left:'17%',width:'27%',height:'21%',background:'rgba(255,255,255,.55)',borderRadius:'50%',transform:'rotate(-22deg)',pointerEvents:'none'});
        const s2=el('div');css(s2,{position:'absolute',bottom:'17%',right:'13%',width:'11%',height:'9%',background:'rgba(255,255,255,.18)',borderRadius:'50%',pointerEvents:'none'});
        gm.append(s,s2);
        if(isBomb||isRainbow){
            const ico=el('div');css(ico,{position:'absolute',inset:'0',display:'flex',alignItems:'center',justifyContent:'center',fontSize:Math.max(10,CELL*.3)+'px',pointerEvents:'none',zIndex:'2',lineHeight:'1'});
            ico.textContent=isBomb?'💥':'🌈';gm.appendChild(ico);
        }
        if(isIce){
            const ice=el('div');css(ice,{position:'absolute',inset:'-2px',borderRadius:'50%',background:'rgba(140,190,255,.38)',border:'2px solid rgba(180,220,255,.7)',zIndex:'3'});gm.appendChild(ice);
        }
        return gm;
    }

    function renderCell(r,c,animFall=0){
        const cell=cells[r][c];
        const old=cell.querySelector('.gm');if(old)old.remove();
        const color=board[r][c];if(!color)return;
        const gm=makeGem(color,iceB[r][c]>0,spec[r][c]==='bomb',spec[r][c]==='rainbow');
        cell.appendChild(gm);
        if(animFall>0){
            const dist=animFall*(CELL+GAP);
            gm.style.transform=`translateY(-${dist}px)`;gm.style.transition='none';
            requestAnimationFrame(()=>requestAnimationFrame(()=>{
                if(_destroyed)return;
                const dur=Math.min(.5,.18+animFall*.045);
                gm.style.transition=`transform ${dur}s cubic-bezier(.22,1.15,.36,1)`;
                gm.style.transform='';
                setTimeout(()=>{if(!_destroyed)Sound.gemBounce();},dur*800);
            }));
        }
        applySel(r,c);
    }

    function applySel(r,c,isSel=selR===r&&selC===c){
        const gm=cells[r][c].querySelector('.gm');if(!gm)return;
        const gc=spec[r][c]==='bomb'?'bomb':spec[r][c]==='rainbow'?'rainbow':board[r][c];
        gm.style.transform=isSel?'scale(1.14)':'';
        gm.style.boxShadow=isSel
            ?`inset 0 -4px 8px rgba(0,0,0,.32),inset 0 5px 10px rgba(255,255,255,.3),0 0 0 3px rgba(255,220,80,.9),0 0 18px rgba(255,220,80,.7),0 3px 12px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'}`
            :`inset 0 -4px 8px rgba(0,0,0,.32),inset 0 5px 10px rgba(255,255,255,.22),0 3px 12px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'},0 0 0 1px rgba(255,255,255,.06)`;
    }

    function renderAll(){for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)renderCell(r,c);}

    function renderWithFall(fm){
        for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
            const old=cells[r][c].querySelector('.gm');if(old)old.remove();
            if(!board[r][c])continue;
            const gm=makeGem(board[r][c],iceB[r][c]>0,spec[r][c]==='bomb',spec[r][c]==='rainbow');
            cells[r][c].appendChild(gm);
            if(fm[r][c]>0){
                const dist=fm[r][c]*(CELL+GAP);gm.style.transform=`translateY(-${dist}px)`;gm.style.transition='none';
                requestAnimationFrame(()=>requestAnimationFrame(()=>{
                    if(_destroyed)return;
                    const dur=Math.min(.5,.18+fm[r][c]*.045);
                    gm.style.transition=`transform ${dur}s cubic-bezier(.22,1.15,.36,1)`;gm.style.transform='';
                    setTimeout(()=>{if(!_destroyed)Sound.gemBounce();},dur*700);
                }));
            }
        }
    }

    // ── Entry animation ────────────────────────
    function entryAnim(){
        for(let c=0;c<COLS;c++){
            setTimeout(()=>{
                for(let r=0;r<ROWS;r++){
                    const gm=cells[r][c].querySelector('.gm');if(!gm)continue;
                    const dist=(ROWS-r+3)*(CELL+GAP);
                    gm.style.transition='none';gm.style.transform=`translateY(-${dist}px)`;gm.style.opacity='0';
                    requestAnimationFrame(()=>requestAnimationFrame(()=>{
                        if(_destroyed)return;
                        gm.style.transition=`transform ${.22+r*.028}s cubic-bezier(.22,1.1,.36,1),opacity .15s ease`;
                        gm.style.transform='';gm.style.opacity='1';
                    }));
                }
            },c*35);
        }
    }

    // ── Burst ──────────────────────────────────
    function burstCells(matchSet,bombT){
        return new Promise(res=>{
            let cnt=matchSet.size+bombT.size;if(!cnt){res();return;}
            const done=()=>{if(--cnt===0)setTimeout(res,90);};
            for(const k of new Set([...matchSet,...bombT])){
                const[r,c]=k.split(',').map(Number);
                const cell=cells[r][c],gm=cell.querySelector('.gm');
                if(!gm){done();continue;}
                emitParticles(cell,spec[r][c]==='bomb'?'bomb':board[r][c],spec[r][c]==='bomb'?12:7);
                gm.style.transition='transform .1s ease,opacity .18s ease';
                gm.style.transform='scale(1.5)';
                setTimeout(()=>{gm.style.transition='transform .15s ease,opacity .15s ease';gm.style.transform='scale(0)';gm.style.opacity='0';done();},80);
            }
        });
    }

    // ── Swap animation ─────────────────────────
    function animSwap(r1,c1,r2,c2,rev=false){
        return new Promise(res=>{
            const g1=cells[r1][c1].querySelector('.gm'),g2=cells[r2][c2].querySelector('.gm');
            const dx=(c2-c1)*(CELL+GAP),dy=(r2-r1)*(CELL+GAP);
            const sc=rev?.88:1.1,dur=rev?.13:.19;
            [g1,g2].forEach(g=>{if(g){g.style.transition=`transform ${dur}s cubic-bezier(.4,0,.2,1)`;g.style.zIndex='5';}});
            if(g1)g1.style.transform=`translate(${dx}px,${dy}px) scale(${sc})`;
            if(g2)g2.style.transform=`translate(${-dx}px,${-dy}px) scale(${sc})`;
            setTimeout(res,dur*1000+10);
        });
    }

    // ── Combo text ─────────────────────────────
    function showComboText(n){
        const el2=el('div');
        css(el2,{position:'absolute',top:'35%',left:'50%',transform:'translate(-50%,-50%) scale(.5)',fontFamily:"'Inter',sans-serif",fontSize:'30px',fontWeight:'900',color:'#ffd700',textShadow:'0 0 24px rgba(255,200,0,.9),0 2px 6px rgba(0,0,0,.7)',letterSpacing:'3px',pointerEvents:'none',zIndex:'100',whiteSpace:'nowrap',opacity:'0',transition:'transform .35s cubic-bezier(.34,1.56,.64,1),opacity .5s ease'});
        el2.textContent=`COMBO ×${n}`;comboOverlay.appendChild(el2);
        requestAnimationFrame(()=>requestAnimationFrame(()=>{el2.style.transform='translate(-50%,-50%) scale(1) translateY(-8px)';el2.style.opacity='1';}));
        setTimeout(()=>{el2.style.opacity='0';el2.style.transform='translate(-50%,-60%) scale(.9)';setTimeout(()=>el2.remove(),600);},900);
    }

    // ── Match logic ────────────────────────────
    function getMatches(){
        const m=new Set();
        for(let r=0;r<ROWS;r++){let l=1;for(let c=1;c<=COLS;c++){if(c<COLS&&board[r][c]===board[r][c-1]&&board[r][c])l++;else{if(l>=3)for(let i=c-l;i<c;i++)m.add(r+','+i);l=1;}}}
        for(let c=0;c<COLS;c++){let l=1;for(let r=1;r<=ROWS;r++){if(r<ROWS&&board[r][c]===board[r-1][c]&&board[r][c])l++;else{if(l>=3)for(let i=r-l;i<r;i++)m.add(i+','+c);l=1;}}}
        return m;
    }

    function find4Plus(){
        const bm=new Map();
        for(let r=0;r<ROWS;r++){let l=1,s=0;for(let c=1;c<=COLS;c++){if(c<COLS&&board[r][c]===board[r][c-1]&&board[r][c])l++;else{if(l===4)bm.set(r+','+(s+2),'bomb');if(l===5)bm.set(r+','+(s+2),'rainbow');if(l>5)bm.set(r+','+(s+2),'rainbow');s=c;l=1;}}}
        for(let c=0;c<COLS;c++){let l=1,s=0;for(let r=1;r<=ROWS;r++){if(r<ROWS&&board[r][c]===board[r-1][c]&&board[r][c])l++;else{if(l>=4){const k=(s+2)+','+c;if(!bm.has(k))bm.set(k,l>=5?'rainbow':'bomb');}s=r;l=1;}}}
        return bm;
    }

    function getBombTargets(m){
        const bt=new Set();
        for(const k of m){const[r,c]=k.split(',').map(Number);
            if(spec[r][c]==='bomb'){for(let dr=-1;dr<=1;dr++)for(let dc=-1;dc<=1;dc++){const nr=r+dr,nc=c+dc;if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS)bt.add(nr+','+nc);}}
            if(spec[r][c]==='rainbow'){const color=board[r][c];for(let rr=0;rr<ROWS;rr++)for(let cc=0;cc<COLS;cc++)if(board[rr][cc]===color)bt.add(rr+','+cc);}
        }
        return bt;
    }

    function processMatches(m,bt){
        let gc=0,gi=0;const all=new Set([...m,...bt]);
        for(const k of all){const[r,c]=k.split(',').map(Number);if(iceB[r][c]>0){iceB[r][c]--;if(!iceB[r][c])gi++;}}
        for(const k of all){const[r,c]=k.split(',').map(Number);if(!iceB[r][c]&&miss.color&&board[r][c]===miss.color)gc++;}
        for(const k of all){const[r,c]=k.split(',').map(Number);board[r][c]=null;spec[r][c]=null;iceB[r][c]=0;}
        for(const[k,type] of find4Plus()){if(m.has(k)){const[r,c]=k.split(',').map(Number);board[r][c]=board[r][c]||COLORS[rnd(COLORS.length)];spec[r][c]=type;}}
        colGem+=gc;iceGem+=gi;combo++;
        if(combo>1){showComboText(combo);Sound.combo(combo);}
        else Sound.gemMatch(all.size);
        for(const k of m){const[r,c]=k.split(',').map(Number);if(spec[r][c]==='bomb'||spec[r][c]==='rainbow')Sound.bombExplode();}
        refreshMission();checkWin();refreshHUD();
    }

    function gravityWithFall(){
        const fm=mk2d(ROWS,COLS,0);
        for(let c=0;c<COLS;c++){
            let empty=0;
            for(let r=ROWS-1;r>=0;r--){
                if(!board[r][c]){empty++;}
                else if(empty>0){fm[r+empty][c]=empty;board[r+empty][c]=board[r][c];spec[r+empty][c]=spec[r][c];iceB[r+empty][c]=iceB[r][c];board[r][c]=null;spec[r][c]=null;iceB[r][c]=0;}
            }
            for(let r=0;r<empty;r++){board[r][c]=COLORS[rnd(COLORS.length)];spec[r][c]=null;iceB[r][c]=0;fm[r][c]=empty-r+1;}
        }
        return fm;
    }

    async function resolve(){
        if(busy||_destroyed)return;busy=true;
        let any=true;
        while(any&&active&&!_destroyed){
            const m=getMatches();if(!m.size){any=false;break;}
            const bt=getBombTargets(m);
            await burstCells(m,bt);
            processMatches(m,bt);
            if(!active||_destroyed)break;
            const fm=gravityWithFall();renderWithFall(fm);
            const maxF=Math.max(0,...fm.flat());await wait(Math.min(600,200+maxF*48));
        }
        busy=false;
        if(active&&!_destroyed&&!hasMoves())shuffle();
    }

    function sw(r1,c1,r2,c2){
        [board[r1][c1],board[r2][c2]]=[board[r2][c2],board[r1][c1]];
        [spec[r1][c1],spec[r2][c2]]=[spec[r2][c2],spec[r1][c1]];
        [iceB[r1][c1],iceB[r2][c2]]=[iceB[r2][c2],iceB[r1][c1]];
    }

    let swapping=false;
    async function trySwap(r1,c1,r2,c2){
        if(busy||!active||swapping||_destroyed)return;
        swapping=true;
        await animSwap(r1,c1,r2,c2);sw(r1,c1,r2,c2);
        if(getMatches().size){
            combo=0;renderAll();
            movesLeft--;refreshHUD();
            await resolve();
            if(movesLeft<=0&&active&&!checkWinSilent())showOutOfMoves();
        }else{
            await animSwap(r1,c1,r2,c2,true);sw(r1,c1,r2,c2);renderAll();
        }
        swapping=false;
    }

    // ── Input ──────────────────────────────────
    let dragStartCell=null;

    function getCell(x,y){
        const el2=document.elementFromPoint(x,y);
        const c2=el2?.closest('[data-r]');
        if(!c2)return null;
        return{r:+c2.dataset.r,c:+c2.dataset.c};
    }
    function isAdj(r1,c1,r2,c2){return Math.abs(r1-r2)+Math.abs(c1-c2)===1;}

    grid.addEventListener('touchstart',e=>{
        if(busy||!active||swapping)return;
        const t=e.touches[0];
        dragStartCell=getCell(t.clientX,t.clientY);
        if(dragStartCell&&boosterMode){
            useBooster(dragStartCell.r,dragStartCell.c);
            dragStartCell=null;return;
        }
        if(dragStartCell){selR=dragStartCell.r;selC=dragStartCell.c;applySel(selR,selC,true);}
    },{passive:true});

    grid.addEventListener('touchmove',e=>{
        if(!dragStartCell||busy||swapping||!active)return;
        e.preventDefault();
        const t=e.touches[0];const cur=getCell(t.clientX,t.clientY);
        if(cur&&(cur.r!==dragStartCell.r||cur.c!==dragStartCell.c)&&isAdj(dragStartCell.r,dragStartCell.c,cur.r,cur.c)){
            const{r:r1,c:c1}=dragStartCell;
            applySel(r1,c1,false);selR=null;selC=null;dragStartCell=null;
            Sound.gemTap();trySwap(r1,c1,cur.r,cur.c);
        }
    },{passive:false});

    grid.addEventListener('touchend',()=>{
        if(!dragStartCell)return;
        // Tap select
        dragStartCell=null;
    });

    // Mouse support
    grid.addEventListener('click',e=>{
        if(busy||!active||swapping)return;
        const cell2=e.target.closest('[data-r]');if(!cell2)return;
        const r=+cell2.dataset.r,c=+cell2.dataset.c;
        Sound.gemTap();
        if(boosterMode){useBooster(r,c);return;}
        if(selR===null){selR=r;selC=c;applySel(r,c,true);return;}
        if(selR===r&&selC===c){applySel(r,c,false);selR=null;selC=null;return;}
        if(isAdj(selR,selC,r,c)){
            const[pr,pc]=[selR,selC];applySel(pr,pc,false);selR=null;selC=null;trySwap(pr,pc,r,c);
        }else{applySel(selR,selC,false);selR=r;selC=c;applySel(r,c,true);}
    });

    // ── Boosters ──────────────────────────────
    function useBooster(r,c){
        if(boosterMode==='hammer'){
            if(!board[r][c])return;
            boosterMode=null;updateBoosterUI();
            boosters.hammer--;
            emitParticles(cells[r][c],board[r][c],8);
            const gm=cells[r][c].querySelector('.gm');
            if(gm){gm.style.transition='transform .15s ease,opacity .15s ease';gm.style.transform='scale(0)';gm.style.opacity='0';}
            board[r][c]=null;spec[r][c]=null;iceB[r][c]=0;
            Sound.bombExplode();
            setTimeout(async()=>{const fm=gravityWithFall();renderWithFall(fm);await wait(400);await resolve();},200);
        } else if(boosterMode==='lightning'){
            if(!board[r][c])return;
            boosterMode=null;updateBoosterUI();
            boosters.lightning--;
            // Clear entire row
            const affected=new Set();for(let cc=0;cc<COLS;cc++)affected.add(r+','+cc);
            burstCells(affected,new Set()).then(async()=>{
                for(const k of affected){const[rr,cc]=k.split(',').map(Number);board[rr][cc]=null;spec[rr][cc]=null;iceB[rr][cc]=0;}
                Sound.bombExplode();const fm=gravityWithFall();renderWithFall(fm);await wait(400);await resolve();
            });
        }
    }

    function activateBooster(type){
        if(boosters[type]<=0)return;
        boosterMode=boosterMode===type?null:type;
        updateBoosterUI();
    }

    function updateBoosterUI(){
        const btns=boosterBar.querySelectorAll('.bst-btn');
        btns.forEach(b=>{
            const t=b.dataset.type;
            b.style.opacity=boosters[t]>0?'1':'.3';
            b.style.border=boosterMode===t?'2px solid var(--amber)':'2px solid rgba(255,255,255,.12)';
            b.style.background=boosterMode===t?'rgba(200,134,10,.25)':'rgba(255,255,255,.06)';
        });
    }

    // ── Booster bar ────────────────────────────
    const boosterBar=el('div');
    css(boosterBar,{height:boosterH+'px',display:'flex',alignItems:'center',justifyContent:'center',gap:'12px',padding:'0 16px',flexShrink:'0',background:'rgba(0,0,0,.5)',backdropFilter:'blur(16px)',WebkitBackdropFilter:'blur(16px)',borderTop:'1px solid rgba(255,255,255,.08)'});
    const bstDefs=[{type:'hammer',icon:'🔨',label:'Молот'},{type:'lightning',icon:'⚡',label:'Молния'}];
    for(const b of bstDefs){
        const btn=el('button');btn.dataset.type=b.type;
        css(btn,{background:'rgba(255,255,255,.06)',border:'2px solid rgba(255,255,255,.12)',borderRadius:'14px',padding:'8px 14px',cursor:'pointer',display:'flex',flexDirection:'column',alignItems:'center',gap:'2px',minWidth:'64px'});
        const ico=el('div');css(ico,{fontSize:'22px',lineHeight:'1'});ico.textContent=b.icon;
        const lbl=el('div');css(lbl,{fontSize:'9px',letterSpacing:'1px',color:'rgba(255,255,255,.5)',fontWeight:'700',textTransform:'uppercase'});lbl.textContent=b.label;
        const cnt=el('div');css(cnt,{fontSize:'11px',fontWeight:'800',color:'#fff',fontFamily:"'JetBrains Mono',monospace"});cnt.textContent='×'+boosters[b.type];cnt.id='bst-cnt-'+b.type;
        btn.append(ico,lbl,cnt);
        btn.addEventListener('click',()=>{Sound.click();activateBooster(b.type);});
        boosterBar.appendChild(btn);
    }
    viewport.appendChild(boosterBar);

    function refreshBoosterCounts(){
        bstDefs.forEach(b=>{const el2=document.getElementById('bst-cnt-'+b.type);if(el2)el2.textContent='×'+boosters[b.type];});
    }

    // ── Out of moves overlay ───────────────────
    function showOutOfMoves(){
        active=false;Sound.noMoves();
        const ov=el('div');
        css(ov,{position:'absolute',inset:'0',background:'rgba(0,0,0,.75)',backdropFilter:'blur(8px)',WebkitBackdropFilter:'blur(8px)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',gap:'16px',zIndex:'50',borderRadius:'18px'});
        ov.innerHTML=`<div style="font-size:48px">😔</div><div style="font-size:18px;font-weight:800;color:#fff;letter-spacing:1px">ХОДЫ КОНЧИЛИСЬ</div><div style="font-size:13px;color:rgba(255,255,255,.55)">Попробуй ещё раз</div>`;
        const retryBtn=el('button');
        css(retryBtn,{background:'var(--amber,#c8860a)',border:'none',borderRadius:'14px',padding:'13px 28px',fontFamily:"'Inter',sans-serif",fontSize:'14px',fontWeight:'700',color:'#000',cursor:'pointer'});
        retryBtn.textContent='Начать заново';
        retryBtn.addEventListener('click',()=>{
            ov.remove();
            // Reset
            initBoard();placeIce();movesLeft=getMoves(level);
            colGem=0;iceGem=0;combo=0;active=true;busy=false;
            renderAll();entryAnim();refreshHUD();
        });
        ov.appendChild(retryBtn);
        gridWrap.appendChild(ov);
    }

    // ── Board init ─────────────────────────────
    function initBoard(){
        for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
            const no=new Set();
            if(c>=2&&board[r][c-1]===board[r][c-2])no.add(board[r][c-1]);
            if(r>=2&&board[r-1][c]===board[r-2][c])no.add(board[r-1][c]);
            const ok=COLORS.filter(x=>!no.has(x));board[r][c]=ok[rnd(ok.length)]||COLORS[0];
            spec[r][c]=null;
        }
    }
    function placeIce(){
        const n=miss.type==='clear_ice'?miss.target:(miss.targetIce||0);if(!n)return;
        const pos=[];for(let r=3;r<ROWS;r++)for(let c=0;c<COLS;c++)pos.push([r,c]);
        pos.sort(()=>Math.random()-.5);
        for(let i=0;i<Math.min(n,pos.length);i++){const[r,c]=pos[i];iceB[r][c]=level>20?2:1;}
    }
    function hasMoves(){
        for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
            if(c+1<COLS){sw(r,c,r,c+1);if(getMatches().size){sw(r,c,r,c+1);return true;}sw(r,c,r,c+1);}
            if(r+1<ROWS){sw(r,c,r+1,c);if(getMatches().size){sw(r,c,r+1,c);return true;}sw(r,c,r+1,c);}
        }return false;
    }
    function shuffle(){const f=board.flat();for(let i=f.length-1;i>0;i--){const j=rnd(i+1);[f[i],f[j]]=[f[j],f[i]];}let idx=0;for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)board[r][c]=f[idx++];resolve();}

    function checkWinSilent(){
        return miss.type==='collect'?colGem>=miss.target:miss.type==='clear_ice'?iceGem>=miss.target:colGem>=miss.targetCollect&&iceGem>=miss.targetIce;
    }
    function checkWin(){if(checkWinSilent()&&active&&!_destroyed){active=false;Sound.win3();setTimeout(()=>onWin(),300);}}

    function refreshMission(){
        const em=['🔴','🔵','🟢','🟡','🟣','🟠'][COLORS.indexOf(miss.color)]||'';
        if(miss.type==='collect')msEl.textContent=`${em} Собери: ${colGem}/${miss.target}`;
        else if(miss.type==='clear_ice')msEl.textContent=`❄️ Разморозь: ${iceGem}/${miss.target}`;
        else msEl.textContent=`${em} ${colGem}/${miss.targetCollect} ❄️ ${iceGem}/${miss.targetIce}`;
    }

    // ── Start ──────────────────────────────────
    initBoard();placeIce();renderAll();refreshHUD();
    setTimeout(()=>{if(!_destroyed)entryAnim();},80);
    if(!hasMoves())shuffle();
}

// ── Helpers ────────────────────────────────────
function getMission(l){
    const t=['collect','collect','collect','clear_ice','mixed'];
    const type=t[Math.min(Math.floor((l-1)/5),t.length-1)];
    if(type==='collect')return{type,color:COLORS[Math.floor((l-1)/5)%COLORS.length],target:10+Math.floor(l/2)*2};
    if(type==='clear_ice')return{type,target:5+Math.floor((l-15)/2)};
    return{type:'mixed',color:COLORS[l%COLORS.length],targetCollect:18+l,targetIce:6+Math.floor(l/4)};
}
function getMoves(l){return Math.max(18,30-Math.floor(l/5));}
function mk2d(r,c,v){return Array.from({length:r},()=>Array(c).fill(v));}
function rnd(n){return Math.floor(Math.random()*n);}
function wait(ms){return new Promise(r=>setTimeout(r,ms));}
function el(tag){return document.createElement(tag);}
function css(e,s){Object.assign(e.style,s);}

export function destroy(){_destroyed=true;}

EOF_SDVIG

echo "  ✦ $S/scenarios/detective.json"
mkdir -p $(dirname "$S/scenarios/detective.json")
cat > "$S/scenarios/detective.json" << 'EOF_SDVIG'
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

EOF_SDVIG

echo "  ✦ $S/auth/oidc-callback.html"
mkdir -p $(dirname "$S/auth/oidc-callback.html")
cat > "$S/auth/oidc-callback.html" << 'EOF_SDVIG'
<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Авторизация…</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{height:100%;background:#070508;display:flex;align-items:center;justify-content:center}
.wrap{text-align:center;color:rgba(255,255,255,.7);font-family:-apple-system,sans-serif;padding:32px}
.ring{width:48px;height:48px;border-radius:50%;border:3px solid rgba(200,134,10,.2);border-top-color:#c8860a;animation:spin .9s linear infinite;margin:0 auto 20px}
@keyframes spin{to{transform:rotate(360deg)}}
p{font-size:14px;letter-spacing:.5px}
.err{color:#ef4444;font-size:13px;margin-top:12px;display:none}
</style>
</head>
<body>
<div class="wrap">
    <div class="ring"></div>
    <p>Проверяем данные…</p>
    <div class="err" id="err"></div>
</div>
<script>
(function(){
    try {
        var p = new URLSearchParams(location.search);
        var code  = p.get('code');
        var state = p.get('state');
        var error = p.get('error');
        var edesc = p.get('error_description');

        if (window.opener && !window.opener.closed) {
            // Popup flow — post to parent and close
            window.opener.postMessage(
                {type:'tg_oidc', code:code, state:state, error:error},
                window.opener.location.origin
            );
            document.querySelector('p').textContent = 'Готово! Закрываем окно…';
            setTimeout(function(){ window.close(); }, 800);
        } else {
            // Redirect flow (no popup) — stash in sessionStorage and go to root
            if (error) {
                sessionStorage.setItem('tg_oidc_error', edesc || error);
            } else {
                sessionStorage.setItem('tg_oidc_code',  code  || '');
                sessionStorage.setItem('tg_oidc_state', state || '');
            }
            document.querySelector('p').textContent = 'Перенаправляем…';
            setTimeout(function(){ location.href = '/'; }, 500);
        }
    } catch(e) {
        var errEl = document.getElementById('err');
        errEl.style.display = 'block';
        errEl.textContent = 'Ошибка: ' + e.message;
    }
})();
</script>
</body>
</html>

EOF_SDVIG

echo "  ✦ $S/img/bg-splash.jpg  (binary)"
mkdir -p $(dirname "$S/img/bg-splash.jpg")
base64 -d << 'B64_SDVIG' > "$S/img/bg-splash.jpg"
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
R2KvpJz03eMBGlFSi6R0dJcYbnM7hF1mgaPWQSalhg6T+Mz7nHzYvScHL1ustXVTTtI6ulzQxN2u
6FUwqKayLF1XuO16rsjYRik3bJ9Qr0mOpeumL1KfyJOgOBL1f/kj1FsearpV/kj0km0VEdJ31Evs
Wgkk65IaH70k/BdbKiNNy/sDeQXbAr7nfkCc/pS3yZ22wSkqw82LGeWlyIH07SeSlYS3IdyquSsH
apgN20sIRpuh7cecCqVxyQK7d52F2Vew13FryB7UUIv7TSTUrQG8KuAd7ugNvJXuCTu6ApXJsK2b
CJJ0q9x5Yj7glG83sZtOgDG02rbYZvG4Y73Yr2eArRfpf3Eg8tNDRl/aaKUuEAms/wBOXghCqpFt
fGnIlpPGxYw6elVSf2Kan/p1eMEun+pstq56eN/4kajlSzhgz3mjL1JUZtOQRni2FZ4A2kFJoBXT
vHJ0L9id+SEo1Hfk6FnQkEgaaatt8DdZns+w0Y9ydL+wTqX6o/6UGkV9OfJ1tfoQ+zOR7I65yl8q
FYwwPN1MJlOh+snO+1lugXro6Ryvb1ID02mjaceGHta2ZGiP0r3EbbxsPLyLTkrWwQY7bktX9uRR
LtVJk9Vv5ctjN7bnTx513SsppY0rolO3Nl9LOi0ysud5sRW1RR0hKtljIbF9N3ps59nR0aSfywJT
t7iy2HnfgSX0kKCSe50Q2x/Bzx8F9Oqtm2T4rYNbGVSABnHN19zf7Abbe5r8gZ7eTJLwGvAuOQPo
k6YkmGJpWYdEnfAH9LtjXlkpXnBpCSzInKmq5Hd8CMyNEzim7MrrJrxSNJS/3R+50xk3KqOZ25RT
8nUk1IlWKxtm1em09ZW8S4aDp1eEWjfCoyuuP/iem+pPUj/ki2j1ak91LynudsNqZDqei0eoV12y
4lHAxdcfxDrJr9OKcYtbvk8XUg4S74P8HsavSdTpabi2uo09vdHmNacNStSMu3lcoJW6fWcpRUpu
J7WlHSWm3HqtS6tJHl63RxjpfO6WffDlcor0Gnp68ZqWo46kVaXkljUrpm9WWg5PqJ34s5dGMtXW
enq68lHtsvF/oStnDqpRk5uWyJGqbWioy+XpzepeEPL4XqQh3fMSdW14G+HQSUuo1pUl9K5YOp1Z
zv5mo4x4it2aZvSK0+2Ndyc4+DSj2+pbMGinKX6GnJlkt4yVLleCxlPS1uyS8HYtRbpo87Ui9N52
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
SkG1d7IzXcm0Y1qcUNSDXa2y8492gknyHXVKF7G1LWlFp8m5WLMSliGsvdEZYlazgvNXpask1uiG
pdqjUYTdt7YL6t2l4RG7x7nRrJ7qtio87qvpR2/C8I5Os+iK9zs+GLDo3OnO9vVUrNbtLgWOA5f2
IO34bj5nOBm0p37nD83U0otaLUW/JzS1ut7n69P+DH5ut66PicYWpRVN7nk9Uv039jrnPWkl85p/
Y5Oq/bZZFt+PO0uSmrJfJRG6eCutJfJSNuLnbAngzyjJJLJQFwWlfbSRLBRu4IgSWwoWBlxKaFlY
qyUNi0fZ2aiHScTJ+xsvBkvTgEbFltH9uVEHX5Onp/23RKsLGs2iiiq2sSV37Dxm63Mq7RW2DbIZ
YNAO6sW21lBabiD+0sHPqV3Mm8bIaeG2K3aujAyavYsuHwQzuW/tN8UrTbabrBfRUXGLd3RzyklG
lZ06VdiqVEqxSLSsMWnuxYqt3YUreDLSuKDG23kXCQywrQDQTvLOL4tDu6VNL6Zpnaq8o5/iK/4S
a/IHmRaenTDpqtyMpVppoeDbVtAUxJ4N3KKAp9vAJVJ+CBlbSa5KRvK8E77UqHT9NILiHVR7lZya
CrqEjv1l6Wjj0kl1UPBrxj13an07HDqv17Hfqu02cGt9SfAhyZr1ItFZRFyuqLafHklXiorcskYZ
1JfctB3PJLT9M5/cLUtf+77k4bj6ztsWG7NeMLR2Gp4pgqsWOsGW2W+42kk1JcsGMm0Wk5ZxQWB2
0p/YZJtCt4l9hlj+4AwVyaZRdr9KBpqNt3k1NTVIy1HSlCMMnPF+v2KN+l/cSCbvH5IL/PaVA7nN
5I1RXSuUqBpnSWBErew0scgftuVQp70VqtN3uJFryUdOD8kVsISOZsytux4RSm3ZKSElCffaygu3
pL2LRku6lySVrvh4ZJWiqTUUgNu9gxSupMya7qRUZZeS2U0kiT+rcsm+1NCkBwqxGsJ+4upqOLHt
OKvYjRtODlN0dEtN9jfsS00/m/p5VZOinHTaa348GLWpHL1EezpnvbOdJ9iSq6OrrM6DT4OeKUqV
1gs6SqdNptx8umdupH9KGODl6S3h+Gd2sqhFNYoza1xnx57ruGdd0bvYEl6hq7p0nsikJpx7pyvY
q4OKF0Y9sm35LdRKo4MVuOfX+mF+RtT9lKryLOSnGK9ymqq0VXk3HLkk3WhqPt5RzaqbljCOmUr6
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
0BwSl9hVF39hov023lmFg20a2D1YxgaHIVmqjS3H01SURI5kysEs2AJSUsIfTi07MlG7ZVSSW2CK
bTu7ZZy7o1HBzS+Y/p2H0++mmiKp3RWL+5KWp290k8JYKdqrO5z61OUYPzYhowXbpq93lkZ33ek6
dVpRWDlnSlg1GaVW5U9gttLBleUjO6SRSNF3uUSvBoqL+41IjUNFJYs54q3J+XY8nXdn2DpwTjXh
EBULiu3crpqOKeQVSx4Hgu2Hd42IL6cbbi7pBafelwDT7klSzLcM23rUuNzFbBwbk72Gjp9qbTHi
rb5NN1FqtxByd7n1Uk3hJHatOMdPvZw9NFPU1Jc91HoyxpxXktiRoK42htWDUF7g03wVllxTMVuJ
1SdEXmH5OmfODmbaklRYlNCL2NqJ/wBVpL2ZXTi+4TVx1mn9mEW7ZJAa1ElnNlk1gnqO5qiNQH3Y
t7mi0tS9w9j1JZewsrTpIoEo7093sJOMYbeATjJT7rf2Fnm7LEc/USVR9pI7HBtpnBqw9N+Gmek5
pRTFI5tS1KiOvlJR5dZOjUa7mzl6hrsk1vaYiJaT7dTtkso6cttLwcU53r6ept3bnX6o6totSAqk
ov8Akm6TnGO1FdOHqalad2JOlqtLwI0XSt0zq+qG5yaLq0zoTrTYqQlW2rD2NKrBGa72M5d2CLpZ
Ks2bFK+TaiSQqdYeTSFnSdJm0mowkk8piUssVTXd91QTVm4rJza0KymW+pKyOp7iM1CStWK3TTdl
G81wTawbZNHUqXsWWr3YRyxTTyyydbDBXuUdWE1s8MrqTfbKPBxS7k2uODpi/maXvRFlcUjztX6m
eg8XyefqL1M3xc+YR2YXsCKpWCWxpgEZmMAVszPCMtmZu6CFYYsHAYlDLIyFWwyWCjboJtkYDAYQ
MgxHV+osR1PqAusL3HhFxVsGnC13Me/Jl0gLMsDRjcqoCbS23Giqz5IHVXnZC5lLuvC2BNpukB55
oqnbBb2YrwgqQRRPFcFFRKI6usEWHjGuQ3QIxfgWbqNsgFqU1Ffk6LwQhFKPd/cyi2ooyTYralPB
XstbmjCMU7JrWJ7zSW3JnUXsPjuwBqyI0ZKrYspJJtIdxVpInP6sbIsFYKopr8mbctkaMvSiijWU
RYENOSiOleJMp3NpKhJvtuiKeGpjGyH+a47LDE04ycEqWSzVLZBS/MgnlnPptamrKayuBpdqhLbw
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

B64_SDVIG

echo "  ✦ $S/img/bg-login.jpg  (binary)"
mkdir -p $(dirname "$S/img/bg-login.jpg")
base64 -d << 'B64_SDVIG' > "$S/img/bg-login.jpg"
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
8akTSNWJitRv307bnTg51qlaMaUvE9kcaqRPV7FxEKOIUm4Zb65o3OXPp14dvuO0YdtQ9k1PEuTo
5UsmW7S6s+L759T9TwftHgZdkunXqxccuV5Yu1j8w7WjQwvaVWlh5qVHSUGnfR6pHH47x6jd+3uJ
oz8TZpKpq9Tlp1E27FOsk2mdMRvnOnFVPBh7v+6X8Wed3yOjFzcY4dyTV6Stf1Yzyb4KU9NzGfiR
PfRYOrEuM6/W+yp952d2fL72Gh/CxrhIxqY2dKonkqwlCS8mjy+wK7n7P9nVFyo5fyk0dEsQ6VdT
jJxqcro8tuc3bjx+3DEx9iOxabXgxErdazOn/wAIdhOCUsJKa/eqy/1PKr43tF6/0nW/wxgv5GDx
WLcXm7Rxb/xpfwR0nzcWf8b5LG3tLRXZeEg8F7rD4alaFNXet3b1sfL4PGTh2fXwM8UsXKUO8jCl
Fykr2bV+t2z7vCdoYNYOjRr4+mq2TXvKqzP8zojQozanSqU5P7yUX+qNceWsWWeHz+A7Qp06Macl
Uo1bJzw1bRp9Y9fQ8X2rqRljcJOLupUXZ/4j7XE4XPFxmqc7q2qZ8V7W0e6xeAjlsu7mrJ35otsq
8O3zVaHeKSN+woprER/fa/MlRy1HdaSY+x3k7Rrw5Oz/AIDd411s8x+o9kvvOw8JJ790l+Wn8iMq
clldn1VKxfYCv2FQX3XJfqwk53f1qL8lC5I43tyShONW16klrrZJGCpz2caur3c1p+R21W7yjnnd
S0y0+XQ569OTmpqVVX0tG2gHHKg3FRdNtXu71GRWw9OdnKN7abs6q0Gqai4znzvms/zOVQahKPdc
XKVS5qDleHowd1CK8zKpCPdtJaHTOhZfBp3vezdyJU0o2SS05Goj8voU+6xzi+U3H+J39q082AbX
2ZJ/yMe0Ydz2ziI7KNd/xJxrnOg+7jdPTc9GW8pY5bJwsryE7M279SXjjd9UZShJbom0v+M9Dzte
+SvkVn1YUlmnq9+bIUJN8vzOvCYadWooqVON+cppIsiWs+6i/wC9gCoR/wC9A9H+gsTyxGE/+dFw
7BxDX7ThP/mRr61nY81UV/3oDdOK/vYH0uC9jpYjDqrVxsYt8qccy/O50P2Lox3x036QX+pnZGpK
4OwHlpTSkn6GntFU+or0O2PZVPsyDUK0ql97qx5PtDP6ol5Hj5T/AJHs43PjfI7ms17tGS2N6nwk
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
AALBYAALBYAALGtOlOULxlZABB//2Q==

B64_SDVIG

echo "  ✦ $J/controller/GameApiController.java"
mkdir -p $(dirname "$J/controller/GameApiController.java")
cat > "$J/controller/GameApiController.java" << 'EOF_SDVIG'
package com.example.sdvig.controller;

import com.example.sdvig.model.PlayerProfile;
import com.example.sdvig.repository.PlayerProfileRepository;
import com.example.sdvig.service.TelegramAuthService;
import com.example.sdvig.service.TelegramOIDCService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.Map;
import java.util.Random;
import java.util.UUID;

@RestController
@RequestMapping("/api/game")
public class GameApiController {

    private final TelegramAuthService     auth;
    private final TelegramOIDCService     oidc;
    private final PlayerProfileRepository repo;
    private final Random                  rng = new Random();

    public GameApiController(TelegramAuthService auth,
                             TelegramOIDCService oidc,
                             PlayerProfileRepository repo) {
        this.auth = auth;
        this.oidc = oidc;
        this.repo = repo;
    }

    // ────────────────────────────────────────────
    //  Auth endpoints
    // ────────────────────────────────────────────

    @PostMapping("/auth/webapp")
    public ResponseEntity<?> authWebApp(@RequestBody Map<String, Object> payload) {
        try {
            String initData = str(payload.get("initData"));
            if (!auth.validateWebAppInitData(initData))
                return err(401, "Invalid WebApp signature");

            @SuppressWarnings("unchecked")
            var unsafe = (Map<String, Object>) payload.get("initDataUnsafe");
            if (unsafe == null) return err(400, "Missing initDataUnsafe");

            @SuppressWarnings("unchecked")
            var u = (Map<String, Object>) unsafe.get("user");
            if (u == null) return err(400, "Missing user");

            return login("tg:" + u.get("id"), str(u.get("username")), str(u.get("first_name")));
        } catch (Exception e) {
            return err(500, "WebApp auth error: " + e.getMessage());
        }
    }

    @PostMapping("/auth/widget")
    public ResponseEntity<?> authWidget(@RequestBody Map<String, Object> payload) {
        try {
            if (!auth.validateWidgetAuth(payload))
                return err(401, "Invalid widget signature");
            return login("tg:" + payload.get("id"),
                         str(payload.get("username")),
                         str(payload.get("first_name")));
        } catch (Exception e) {
            return err(500, "Widget auth error: " + e.getMessage());
        }
    }

    /** Telegram OpenID Connect — exchange code for profile */
    @PostMapping("/auth/oidc")
    public ResponseEntity<?> authOIDC(@RequestBody Map<String, String> payload) {
        String code = payload.getOrDefault("code", "").trim();
        if (code.isBlank()) return err(400, "Missing code");
        try {
            Map<String, Object> info = oidc.exchangeCode(code);
            String tgId = str(info.get("id") != null ? info.get("id") : info.get("sub"));
            if (tgId == null || tgId.isBlank()) return err(400, "No user id in OIDC response");
            return login("tg:" + tgId,
                         str(info.get("username")),
                         str(info.get("first_name")));
        } catch (Exception e) {
            return err(500, "OIDC error: " + e.getMessage());
        }
    }

    /** Guest / offline login via device fingerprint */
    @PostMapping("/auth/guest")
    public ResponseEntity<?> authGuest(@RequestBody Map<String, String> payload) {
        String raw = payload.getOrDefault("deviceId", UUID.randomUUID().toString());
        String deviceId = raw.replaceAll("[^a-zA-Z0-9\\-_]", "")
                             .substring(0, Math.min(raw.length(), 64));
        if (deviceId.isBlank()) deviceId = UUID.randomUUID().toString().replace("-", "");
        return login("guest:" + deviceId, "Гость", "Гость");
    }

    // ── Shared login helper ───────────────────

    private ResponseEntity<?> login(String pid, String username, String firstName) {
        PlayerProfile p = repo.findByProviderId(pid).orElseGet(() -> {
            PlayerProfile np = new PlayerProfile();
            np.setProviderId(pid);
            np.setCredits(150);     // starter pack
            np.setEnergy(100);
            return np;
        });
        if (username  != null && !username.isBlank())  p.setUsername(username);
        if (firstName != null && !firstName.isBlank()) p.setFirstName(firstName);
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    // ────────────────────────────────────────────
    //  Game endpoints
    // ────────────────────────────────────────────

    @PostMapping("/choice")
    public ResponseEntity<?> choice(
            @RequestParam String providerId,
            @RequestParam String direction,
            @RequestParam(defaultValue = "false") boolean special) {

        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");

        // Special move (swipe up) requires skill1 >= 3 and costs more energy
        int energyCost = special
            ? Math.max(8, 18 - p.getSkill2())
            : Math.max(3, 12 - p.getSkill2());

        if (p.getEnergy() < energyCost)
            return err(400, "Нет энергии — нужен кофе ☕ (" + energyCost + " ⚡)");

        int xpBase   = special ? 25 + rng.nextInt(10) : 15 + rng.nextInt(10);
        int xpGained = xpBase + p.getSkill1() * 4;
        int crGained = special ? 15 + rng.nextInt(20) : 10 + rng.nextInt(15);

        p.setEnergy(Math.max(0, p.getEnergy() - energyCost));
        p.setXp(p.getXp() + xpGained);
        p.setCredits(p.getCredits() + crGained);
        p.setTotalCases(p.getTotalCases() + 1);

        // Rank up
        int req = p.getRank() * 150;
        if (p.getXp() >= req) { p.setXp(p.getXp() - req); p.setRank(p.getRank() + 1); }

        repo.save(p);
        return ResponseEntity.ok(Map.of(
            "profile",        p,
            "xpGained",       xpGained,
            "creditsGained",  crGained,
            "energyLost",     energyCost
        ));
    }

    @PostMapping("/upgrade-skill")
    public ResponseEntity<?> upgradeSkill(@RequestParam String providerId,
                                           @RequestParam int skillNum) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        int cur  = skillNum == 1 ? p.getSkill1() : p.getSkill2();
        int cost = 50 * cur;
        if (p.getCredits() < cost) return err(400, "Нужно " + cost + " 💎");
        p.setCredits(p.getCredits() - cost);
        if (skillNum == 1) p.setSkill1(cur + 1); else p.setSkill2(cur + 1);
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    @PostMapping("/buy-coffee")
    public ResponseEntity<?> buyCoffee(@RequestParam String providerId) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        if (p.getCredits() < 40) return err(400, "Нужно 40 💎");
        p.setCredits(p.getCredits() - 40);
        p.setEnergy(Math.min(100, p.getEnergy() + 35));
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    @GetMapping("/daily-bonus")
    public ResponseEntity<?> checkDaily(@RequestParam String providerId) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        String today = LocalDate.now().toString();
        boolean avail = !today.equals(p.getLastDailyBonus());
        return ResponseEntity.ok(Map.of("available", avail, "streak", p.getStreak()));
    }

    @PostMapping("/daily-bonus/claim")
    public ResponseEntity<?> claimDaily(@RequestParam String providerId) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        String today = LocalDate.now().toString();
        if (today.equals(p.getLastDailyBonus()))
            return err(400, "Бонус уже получен сегодня");
        String yest = LocalDate.now().minusDays(1).toString();
        int streak = yest.equals(p.getLastDailyBonus()) ? p.getStreak() + 1 : 1;
        p.setCredits(p.getCredits() + 50);
        p.setEnergy(Math.min(100, p.getEnergy() + 30));
        p.setStreak(streak);
        p.setLastDailyBonus(today);
        repo.save(p);
        return ResponseEntity.ok(Map.of("profile", p));
    }

    @PostMapping("/advance-level")
    public ResponseEntity<?> advanceLevel(@RequestParam String providerId,
                                           @RequestParam String gameType) {
        PlayerProfile p = find(providerId);
        if (p == null) return err(400, "Profile not found");
        if ("detective".equals(gameType))
            p.setDetectiveLvl(Math.min(100, p.getDetectiveLvl() + 1));
        p.setXp(p.getXp() + 50);
        int req = p.getRank() * 150;
        if (p.getXp() >= req) { p.setXp(p.getXp() - req); p.setRank(p.getRank() + 1); }
        repo.save(p);
        return ResponseEntity.ok(p);
    }

    // ── Helpers ──────────────────────────────

    private PlayerProfile find(String pid) {
        return repo.findByProviderId(pid).orElse(null);
    }

    private ResponseEntity<String> err(int status, String msg) {
        return ResponseEntity.status(status).body(msg);
    }

    private String str(Object o) { return o == null ? null : String.valueOf(o); }
}

EOF_SDVIG

echo "  ✦ $J/service/TelegramOIDCService.java"
mkdir -p $(dirname "$J/service/TelegramOIDCService.java")
cat > "$J/service/TelegramOIDCService.java" << 'EOF_SDVIG'
package com.example.sdvig.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;

@Service
public class TelegramOIDCService {

    @Value("${telegram.oidc.client-id:}")
    private String clientId;

    @Value("${telegram.oidc.client-secret:}")
    private String clientSecret;

    @Value("${app.base-url:}")
    private String baseUrl;

    private final ObjectMapper mapper = new ObjectMapper();

    public boolean isConfigured() {
        return clientId != null && !clientId.isBlank()
            && clientSecret != null && !clientSecret.isBlank();
    }

    /**
     * Exchange authorization code for Telegram user info.
     * Returns map with keys: id, first_name, username, photo_url
     */
    @SuppressWarnings("unchecked")
    public Map<String, Object> exchangeCode(String code) throws Exception {
        if (!isConfigured()) {
            throw new IllegalStateException("Telegram OIDC not configured");
        }

        String redirectUri = baseUrl.endsWith("/")
            ? baseUrl + "auth/oidc-callback"
            : baseUrl + "/auth/oidc-callback";

        // 1. Exchange code for access token
        String tokenUrl = "https://id.telegram.org/auth/token";
        String body = "grant_type=authorization_code"
            + "&code=" + enc(code)
            + "&client_id=" + enc(clientId)
            + "&client_secret=" + enc(clientSecret)
            + "&redirect_uri=" + enc(redirectUri);

        String tokenJson = post(tokenUrl, body, "application/x-www-form-urlencoded", null);
        Map<?, ?> tokenMap = mapper.readValue(tokenJson, Map.class);

        if (tokenMap.containsKey("error")) {
            throw new Exception("Token error: " + tokenMap.get("error_description"));
        }

        String accessToken = (String) tokenMap.get("access_token");
        if (accessToken == null || accessToken.isBlank()) {
            throw new Exception("No access_token in response");
        }

        // 2. Get user info
        String userInfoUrl = "https://id.telegram.org/auth/userinfo";
        String userJson = get(userInfoUrl, "Bearer " + accessToken);
        Map<String, Object> userInfo = mapper.readValue(userJson, Map.class);

        return normalise(userInfo);
    }

    /** Map OIDC claims to our standard keys */
    private Map<String, Object> normalise(Map<String, Object> raw) {
        // OIDC may use "sub" instead of "id"
        if (!raw.containsKey("id") && raw.containsKey("sub")) {
            raw.put("id", raw.get("sub"));
        }
        // "given_name" → "first_name"
        if (!raw.containsKey("first_name") && raw.containsKey("given_name")) {
            raw.put("first_name", raw.get("given_name"));
        }
        // "preferred_username" → "username"
        if (!raw.containsKey("username") && raw.containsKey("preferred_username")) {
            raw.put("username", raw.get("preferred_username"));
        }
        return raw;
    }

    // ── HTTP helpers ─────────────────────────

    private String post(String url, String body, String contentType, String auth) throws Exception {
        HttpURLConnection c = open(url);
        c.setRequestMethod("POST");
        c.setDoOutput(true);
        c.setRequestProperty("Content-Type", contentType);
        if (auth != null) c.setRequestProperty("Authorization", auth);
        try (OutputStream os = c.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }
        return read(c);
    }

    private String get(String url, String auth) throws Exception {
        HttpURLConnection c = open(url);
        c.setRequestMethod("GET");
        if (auth != null) c.setRequestProperty("Authorization", auth);
        return read(c);
    }

    private HttpURLConnection open(String url) throws Exception {
        HttpURLConnection c = (HttpURLConnection) new URL(url).openConnection();
        c.setConnectTimeout(8000);
        c.setReadTimeout(8000);
        return c;
    }

    private String read(HttpURLConnection c) throws Exception {
        int code = c.getResponseCode();
        InputStream is = code >= 400 ? c.getErrorStream() : c.getInputStream();
        if (is == null) throw new Exception("Empty response, HTTP " + code);
        return new String(is.readAllBytes(), StandardCharsets.UTF_8);
    }

    private String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}

EOF_SDVIG

echo "  ✦ $J/model/PlayerProfile.java"
mkdir -p $(dirname "$J/model/PlayerProfile.java")
cat > "$J/model/PlayerProfile.java" << 'EOF_SDVIG'
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

echo "✅  Все файлы записаны!"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  git add -A"
echo "  git commit -m \"feat: v5 dark glass, OIDC, full Match-3, rain fx\""
echo "  git push"
echo ""
echo "  Railway переменные которые нужны:"
echo "  ┌─────────────────────────────────────────────────┐"
echo "  │ TELEGRAM_BOT_TOKEN   — токен бота               │"
echo "  │ DATABASE_URL         — строка подключения PG    │"
echo "  │ TELEGRAM_CLIENT_ID   — из Telegram OIDC         │"
echo "  │ TELEGRAM_CLIENT_SECRET — из Telegram OIDC       │"
echo "  │ APP_BASE_URL         — https://your-app.up.railway.app │"
echo "  └─────────────────────────────────────────────────┘"
echo ""
echo "  Telegram виджет (если используется):"
echo "  @BotFather → /mybots → Bot Settings → Domain"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
