'use strict';
// ═══════════════════════════════════════════
//  СДВИГ · app.js v4
// ═══════════════════════════════════════════

const tg = window.Telegram?.WebApp ?? null;
const $  = id => document.getElementById(id);

let user        = null;
let scenarios   = null;
let currentCard = null;
let cardId      = 'act1_scene1';
let cardHistory = [];
let cardCount   = 0;
let cardLocked  = true;
let activeTab   = 'cases';
let gameDestroy = null;
let dailyClaimed = false;
let swipeDir    = null;   // last swipe direction for result nav

const ACH = [
    {id:'rank5',   check:p=>p.rank>=5,             icon:'🏅',title:'АГЕНТ В ДЕЛЕ',  desc:'Ранг 5'},
    {id:'rank10',  check:p=>p.rank>=10,            icon:'🏆',title:'ЭЛИТА',         desc:'Ранг 10'},
    {id:'cases10', check:p=>(p.totalCases||0)>=10, icon:'📂',title:'ДЕТЕКТИВ',      desc:'10 дел'},
    {id:'cases50', check:p=>(p.totalCases||0)>=50, icon:'🗃️',title:'АРХИВАРИУС',    desc:'50 дел'},
    {id:'streak3', check:p=>(p.streak||0)>=3,      icon:'🔥',title:'НА СЕРИИ',      desc:'3 дня подряд'},
    {id:'sk1max',  check:p=>p.skill1>=5,           icon:'🧠',title:'ПРОНИЦАТЕЛЬ',   desc:'Проницательность Lv.5'},
];
const earned = new Set(JSON.parse(localStorage.getItem('sdvig_ach')||'[]'));

// ── BOOT ─────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
    if (tg) try { tg.expand(); tg.ready(); } catch(e){}

    // Wire auth handler
    window.__tgHandler = u => { showScreen('splash-screen'); widgetAuth(u); };
    if (window.__tgPending) { window.__tgHandler(window.__tgPending); window.__tgPending=null; }

    // Widget tip after 6 s
    setTimeout(() => {
        const area=$('tg-widget-area'), tip=$('tg-tip');
        if (area && tip && !area.querySelector('iframe')) tip.classList.remove('hidden');
    }, 6000);

    injectIcons();
    runSplash();
});

// ── ICONS ────────────────────────────────────
function injectIcons() {
    setIcon($('icon-energy'),  'bolt');
    setIcon($('icon-credits'), 'diamond');
    setIcon($('icon-rank'),    'shield');
    setIcon($('nav-cases'),    'folder');
    setIcon($('nav-games'),    'gamepad');
    setIcon($('nav-profile'),  'badge');
    setIcon($('nav-shop'),     'bag');
    setIcon($('back-icon'),    'arrowLeft');
    setIcon($('hm-icon'),      'lock');
}

// ── CINEMATIC SPLASH ─────────────────────────
async function runSplash() {
    const fill    = $('splash-fill');
    const emblem  = $('splash-emblem');
    const titleEl = $('splash-title');
    const flash   = $('splash-flash');

    // 1. Emblem slides in
    await wait(200);
    emblem.classList.add('visible');
    await wait(580);

    // 2. Title letters appear
    for (const [i, ch] of [...'СДВИГ'].entries()) {
        const sp = document.createElement('span');
        sp.className = 'title-letter';
        sp.textContent = ch;
        titleEl.appendChild(sp);
        await wait(10);
        sp.classList.add('in');
        sp.style.animationDelay = '0s';
        await wait(75);
    }
    await wait(180);

    // 3. Loading bar
    setSplash('Загрузка материалов…');
    for (const [w, ms] of [[25,180],[55,220],[80,280],[98,200]]) {
        fill.style.width = w + '%';
        await wait(ms);
    }
    fill.style.width = '100%';
    setSplash('Готово');
    await wait(250);

    // 4. Pulses × 3
    for (let i = 0; i < 3; i++) {
        emblem.classList.add('pulse');
        Sound.splashImpact();
        await wait(400);
        emblem.classList.remove('pulse');
        await wait(80);
    }
    await wait(120);

    // 5. Cinematic exit
    Sound.splashExit();
    emblem.classList.add('explode');
    flash.style.transition = 'opacity .3s ease';
    flash.style.opacity = '1';
    await wait(280);

    // Decide next screen
    if (tg?.initData?.length > 0) {
        setSplash('Telegram WebApp…');
        webappAuth();
    } else {
        showScreen('login-screen');
    }
    await wait(120);
    flash.style.transition = 'opacity .45s ease';
    flash.style.opacity = '0';
}

function setSplash(t) { const e=$('splash-text'); if(e) e.textContent=t; }

// ── SCREENS ──────────────────────────────────
function showScreen(id) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'));
    $(id).classList.add('active');
}

// ── AUTH ─────────────────────────────────────
function webappAuth() {
    fetch('/api/game/auth/webapp', {
        method:'POST', headers:{'Content-Type':'application/json'},
        body:JSON.stringify({initData:tg.initData, initDataUnsafe:tg.initDataUnsafe})
    })
    .then(r => { if(!r.ok) throw 0; return r.json(); })
    .then(onLogin)
    .catch(() => showError('Ошибка WebApp-авторизации.\nПроверьте токен бота в переменных Railway.'));
}

function widgetAuth(u) {
    const p = {}; for (const [k,v] of Object.entries(u)) p[k]=String(v);
    fetch('/api/game/auth/widget', {
        method:'POST', headers:{'Content-Type':'application/json'},
        body:JSON.stringify(p)
    })
    .then(r => { if(!r.ok) return r.text().then(t=>{throw t;}); return r.json(); })
    .then(onLogin)
    .catch(e => showError(typeof e==='string'?e:'Ошибка виджета.\nДобавьте домен в @BotFather → /setdomain'));
}

function guestLogin() {
    Sound.click();
    let gid = localStorage.getItem('sdvig_guest_id');
    if (!gid) { gid = 'g' + Date.now(); localStorage.setItem('sdvig_guest_id', gid); }
    fetch('/api/game/auth/guest', {
        method:'POST', headers:{'Content-Type':'application/json'},
        body:JSON.stringify({deviceId: gid})
    })
    .then(r => { if(!r.ok) throw 0; return r.json(); })
    .then(onLogin)
    .catch(() => {
        // Full offline guest fallback
        const mockProfile = {
            providerId: 'guest:' + gid, firstName:'Гость', username:'guest',
            energy:100, credits:100, rank:1, xp:0, skill1:1, skill2:1,
            detectiveLvl:1, totalCases:0, streak:0, archetype:'detective'
        };
        onLogin(mockProfile);
    });
}
window.guestLogin = guestLogin;

function showError(m) { $('error-msg').textContent=m; showScreen('error-screen'); }

// ── LOGIN SUCCESS ─────────────────────────────
async function onLogin(profile) {
    user = profile;
    await Sound.init();
    updateHUD(profile);
    updateProfile(profile);
    renderAchGrid();
    showScreen('main-screen');
    initSwipe();
    await loadScenarios();
    loadCard(cardId);
    checkDailyBonus();
    updateShopAfford();
    vib(30);
}

// ── SOUND TOGGLE ─────────────────────────────
function toggleSound() {
    const on = Sound.toggle();
    $('sound-btn').textContent = on ? '🔊' : '🔇';
}
window.toggleSound = toggleSound;

// ── SCENARIOS ────────────────────────────────
async function loadScenarios() {
    if (scenarios) return;
    try {
        const r = await fetch('/scenarios/detective.json');
        scenarios = await r.json();
    } catch { scenarios = {cards:{}}; }
}

// ── CARD LOADING ──────────────────────────────
function loadCard(id) {
    const card = scenarios?.cards?.[id];
    if (!card) { loadCard('act1_scene1'); return; }

    currentCard = card;
    cardId      = id;
    cardCount++;
    cardLocked  = !card.isEnding; // endings auto-unlock

    const el = $('main-card');
    el.className = 'case-card card-enter ct-' + (card.type || 'evidence');

    $('stamp-approve').style.opacity = '0';
    $('stamp-deny').style.opacity    = '0';
    $('result-overlay').classList.add('hidden');
    $('card-act').textContent        = card.actTitle || 'АКТ ' + (card.act||1);
    $('card-type-badge').textContent = fmtType(card.type);
    $('card-num').textContent        = '#' + String(id).slice(0,8).toUpperCase();
    $('card-icon').textContent       = card.icon || '🔍';
    $('card-title').textContent      = card.title || '';
    $('case-description').textContent= card.text  || '';

    renderCardActions();
    Sound.cardLoad();
    vib(15);
}

function fmtType(t) {
    return ({crime:'ПРЕСТУПЛЕНИЕ',evidence:'УЛИКА',suspect:'ПОДОЗРЕВАЕМЫЙ',
        witness:'СВИДЕТЕЛЬ',testimony:'ПОКАЗАНИЯ',mystery:'ТАЙНА',
        action:'ОПЕРАЦИЯ',revelation:'ПРОРЫВ',briefing:'СВОДКА',
        ending:'ФИНАЛ',ending_bad:'ФИНАЛ',ending_partial:'ФИНАЛ',chase:'ПОГОНЯ'}[t]
        || (t||'ДЕЛО').toUpperCase());
}

// ── CARD ACTIONS PANEL ────────────────────────
function renderCardActions() {
    const a = $('card-actions');
    if (!a) return;

    if (cardLocked) {
        a.innerHTML = `
            <div class="lock-panel">
                <div class="lp-icon">${icon('lock')}</div>
                <div class="lp-body">
                    <div class="lp-title">Свайп заблокирован</div>
                    <div class="lp-sub">Пройди Самоцветы чтобы принять решение</div>
                </div>
            </div>
            <button class="btn-play-gems" onclick="openCardGame()">
                ${icon('gamepad')} Играть в Самоцветы
            </button>
            <div class="swipe-indicator">
                <span class="si-locked">${icon('lock')} Свайп недоступен</span>
            </div>`;
    } else {
        const hint = currentCard?.hint;
        a.innerHTML = `
            ${hint ? `<div class="hint-revealed-panel">
                <span class="hrp-icon">💡</span>
                <p class="hrp-text">${hint}</p>
            </div>` : ''}
            <div class="swipe-indicator swipe-unlocked">
                <span class="si-deny">← ${currentCard?.leftOption  || 'ОТКЛОНИТЬ'}</span>
                <span class="si-center">${icon('lockOpen')}</span>
                <span class="si-approve">${currentCard?.rightOption || 'ОДОБРИТЬ'} →</span>
            </div>`;
    }
}

// ── SWIPE ENGINE ──────────────────────────────
function initSwipe() {
    const card = $('main-card');
    let sx=0, cx=0, dragging=false, lx=0, vel=0, lt=0;

    const onStart = e => {
        if (!$('result-overlay').classList.contains('hidden')) return;
        dragging=true; sx=gx(e); lx=sx; lt=Date.now();
        card.style.transition='none';
        card.style.animationPlayState='paused';
    };
    const onMove = e => {
        if (!dragging) return; e.preventDefault();
        cx=gx(e);
        const now=Date.now(); vel=(cx-lx)/Math.max(1,now-lt); lx=cx; lt=now;
        const dx=cx-sx, rot=dx/18;
        card.style.transform=`rotate(${rot}deg) translateX(${dx}px)`;
        const r=Math.min(1,Math.abs(dx)/80);
        if (dx<-28){ card.classList.add('tilt-left'); card.classList.remove('tilt-right');
            $('stamp-deny').style.opacity=r; $('stamp-approve').style.opacity=0;
        } else if (dx>28){ card.classList.add('tilt-right'); card.classList.remove('tilt-left');
            $('stamp-approve').style.opacity=r; $('stamp-deny').style.opacity=0;
        } else { card.classList.remove('tilt-left','tilt-right');
            $('stamp-approve').style.opacity=0; $('stamp-deny').style.opacity=0; }
    };
    const onEnd = () => {
        if (!dragging) return; dragging=false;
        card.style.animationPlayState='running';
        const dx=cx-sx, T=88, V=0.38;
        card.style.transition='transform .3s ease';
        if      (dx<-T || vel<-V) flyCard('left');
        else if (dx> T || vel> V) flyCard('right');
        else { resetCardPos(); }
    };

    card.addEventListener('touchstart', onStart,{passive:true});
    card.addEventListener('mousedown',  onStart);
    window.addEventListener('touchmove',  onMove,{passive:false});
    window.addEventListener('mousemove',  onMove);
    window.addEventListener('touchend',   onEnd);
    window.addEventListener('mouseup',    onEnd);
}
const gx = e => e.touches?e.touches[0].clientX:e.clientX;

function resetCardPos() {
    const card=$('main-card');
    card.style.transform='rotate(-.5deg)';
    card.classList.remove('tilt-left','tilt-right');
    $('stamp-approve').style.opacity=0;
    $('stamp-deny').style.opacity=0;
}

function flyCard(dir) {
    if (cardLocked) {
        // Shake + deny
        const card=$('main-card');
        card.classList.add('shaking');
        setTimeout(()=>card.classList.remove('shaking'),600);
        resetCardPos();
        Sound.locked();
        vib([80,40,80]);
        toast('🎮','ЗАБЛОКИРОВАНО','Сначала пройди Самоцветы!');
        return;
    }

    const stampEl = dir==='left' ? $('stamp-deny') : $('stamp-approve');
    const stampTxt = stampEl.querySelector('.stamp');
    if (stampTxt) { stampEl.style.opacity='1'; stampTxt.classList.add('landing'); }

    if (dir==='left') Sound.swipeL(); else Sound.swipeR();
    vib(25);

    const card=$('main-card');
    swipeDir = dir;
    setTimeout(() => {
        card.style.transition='transform .38s cubic-bezier(.55,0,1,.45),opacity .38s ease';
        card.style.transform=`translateX(${dir==='left'?'-160vw':'160vw'}) rotate(${dir==='left'?'-25deg':'25deg'})`;
        card.style.opacity='0';
        sendChoice(dir);
    }, 110);
}

// ── SEND CHOICE ───────────────────────────────
function sendChoice(dir) {
    if (!user||!currentCard) return;
    fetch(`/api/game/choice?providerId=${enc(user.providerId)}&direction=${dir}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('⚡','Ошибка',t);throw 0;}); return r.json(); })
    .then(data=>{
        user=data.profile; updateHUD(user);
        const ok=dir==='right';
        const rs=$('ro-stamp');
        rs.textContent=ok?'ОДОБРЕНО':'ОТКЛОНЕНО';
        rs.className='ro-stamp-text '+(ok?'approve':'deny');
        $('result-text').textContent=ok?(currentCard.rightResult||''):(currentCard.leftResult||'');
        $('rew-xp').textContent=data.xpGained;
        $('rew-cr').textContent=data.creditsGained;
        $('rew-en').textContent=data.energyLost;
        setTimeout(()=>{ $('result-overlay').classList.remove('hidden'); checkAch(data.profile); }, 300);
        vib([30,20,60]);
    })
    .catch(()=>{
        const card=$('main-card');
        card.style.transition='transform .35s ease'; card.style.transform='rotate(-.5deg)';
        card.style.opacity='1'; card.classList.remove('tilt-left','tilt-right');
    });
}

function nextCard() {
    $('result-overlay').classList.add('hidden');
    const dir = swipeDir;
    const nextId = dir==='right' ? currentCard?.rightNext : currentCard?.leftNext;
    const card=$('main-card');
    card.style.transition='none'; card.style.opacity='0';
    requestAnimationFrame(()=>requestAnimationFrame(()=>{
        card.style.transition='opacity .25s ease';
        card.style.opacity='1';
        loadCard(nextId && scenarios?.cards?.[nextId] ? nextId : 'act1_scene1');
    }));
}
window.nextCard = nextCard;

// ── CARD GAME (Match-3 gate) ──────────────────
function openCardGame() {
    Sound.click();
    const level = Math.max(1, ((currentCard?.act||1)-1)*2 + 1);
    $('hm-title-text').textContent = '💎 Самоцветы';
    const modal=$('hint-modal'), back=$('hint-backdrop');
    modal.classList.remove('hidden','closing');
    back.classList.remove('hidden');

    const vp=$('hm-vp'); vp.innerHTML='';
    if (gameDestroy) { try{gameDestroy();}catch(e){} gameDestroy=null; }

    import('./games/detective.js').then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp, level, onCardGameWon);
    }).catch(()=>{ vp.innerHTML='<p style="color:var(--no);padding:24px;text-align:center">⚠️ Ошибка загрузки игры</p>'; });
}
window.openCardGame = openCardGame;

function onCardGameWon() {
    cardLocked = false;
    closeHintGame();
    Sound.unlock();
    vib([30,20,30,20,80]);

    const card=$('main-card');
    card.classList.add('just-unlocked');
    setTimeout(()=>card.classList.remove('just-unlocked'),700);

    renderCardActions();
    toast('🔓','РАЗБЛОКИРОВАНО','Теперь ты можешь принять решение!');

    // Advance level on server
    fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=detective`,{method:'POST'})
    .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
}

function closeHintGame() {
    const modal=$('hint-modal'), back=$('hint-backdrop');
    modal.classList.add('closing');
    setTimeout(()=>{ modal.classList.add('hidden'); back.classList.add('hidden'); },240);
    if (gameDestroy) { try{gameDestroy();}catch(e){} gameDestroy=null; }
    $('hm-vp').innerHTML='';
}
window.closeHintGame = closeHintGame;

// ── GAMES TAB (standalone) ────────────────────
function launchGame(type) {
    $('gvp-wrap').classList.remove('hidden');
    $('gvp-title').textContent = '💎 Самоцветы';
    $('win-badge').classList.add('hidden');
    const vp=$('game-vp'); vp.innerHTML='';
    if (gameDestroy){try{gameDestroy();}catch(e){} gameDestroy=null;}
    const level=user?.detectiveLvl||1;
    import('./games/detective.js').then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp,level,()=>{
            $('win-badge').classList.remove('hidden');
            Sound.win3(); vib([30,20,30,20,100]);
            toast('🏆','УРОВЕНЬ ПРОЙДЕН','+50 XP');
            fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=detective`,{method:'POST'})
            .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
        });
    }).catch(()=>{ vp.innerHTML='<p style="color:var(--no);text-align:center;padding:24px">⚠️ Ошибка</p>'; });
}
window.launchGame = launchGame;

function closeGame(){
    if(gameDestroy){try{gameDestroy();}catch(e){} gameDestroy=null;}
    $('gvp-wrap').classList.add('hidden');
    $('game-vp').innerHTML='';
    $('win-badge').classList.add('hidden');
}
window.closeGame=closeGame;

// ── HUD ───────────────────────────────────────
function updateHUD(p) {
    $('hud-energy').textContent  = p.energy;
    $('hud-credits').textContent = p.credits;
    $('hud-rank').textContent    = p.rank;
    $('hud-xp').textContent      = p.xp;
    const xpMax = p.rank*150;
    $('hud-xp-max').textContent  = xpMax;
    $('xp-fill').style.width     = Math.min(100,(p.xp/xpMax)*100)+'%';
    const dl=p.detectiveLvl||1;
    $('det-lvl').textContent=dl; $('det-bar').style.width=Math.min(100,dl)+'%';
}

function updateProfile(p) {
    const name=p.firstName||p.username||'Агент';
    $('profile-av').textContent   = name[0].toUpperCase();
    $('profile-name').textContent = name;
    $('profile-id').textContent   = 'ID '+(p.providerId||'—').replace(/^(tg:|guest:)/,'');
    $('profile-arch').textContent = ({detective:'🔍 Детектив',doctor:'⚕️ Медик',hacker:'💻 Хакер'}[p.archetype]||'🔍 Детектив');
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

function renderAchGrid() {
    const g=$('ach-grid'); if(!g) return;
    g.innerHTML=ACH.map(d=>{
        const ok=earned.has(d.id);
        return `<div class="ach-badge ${ok?'earned':'locked'}">
            <div class="ach-icon">${ok?d.icon:'❓'}</div>
            <div class="ach-lbl">${ok?d.title:'???'}</div>
        </div>`;
    }).join('');
}

// ── TABS ──────────────────────────────────────
function switchTab(name) {
    if (activeTab===name) return;
    if (activeTab==='games') closeGame();
    document.querySelectorAll('.tab-pane').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.nb').forEach(b=>b.classList.remove('active'));
    $('tab-'+name).classList.add('active');
    document.querySelector(`[data-tab="${name}"]`).classList.add('active');
    activeTab=name; Sound.click(); vib(10);
    if (name==='profile') { updateProfile(user); renderAchGrid(); $('ach-badge').classList.add('hidden'); }
    if (name==='shop') updateShopAfford();
}
window.switchTab=switchTab;

// ── SKILLS ────────────────────────────────────
function upgradeSkill(n) {
    if (!user) return; Sound.click();
    fetch(`/api/game/upgrade-skill?providerId=${enc(user.providerId)}&skillNum=${n}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('💎','Мало кредитов',t);throw 0;}); return r.json(); })
    .then(p=>{ user=p; updateHUD(p); updateProfile(p); vib([20,20,40]);
        toast('🧠','НАВЫК ПРОКАЧАН',n===1?'Проницательность Lv.'+p.skill1:'Технологии Lv.'+p.skill2); })
    .catch(()=>{});
}
window.upgradeSkill=upgradeSkill;

// ── SHOP ──────────────────────────────────────
function buyCoffee() {
    if (!user) return; Sound.click();
    fetch(`/api/game/buy-coffee?providerId=${enc(user.providerId)}`,{method:'POST'})
    .then(r=>{ if(!r.ok) return r.text().then(t=>{toast('☕','Мало кредитов',t);throw 0;}); return r.json(); })
    .then(p=>{ user=p; updateHUD(p); updateProfile(p); updateShopAfford();
        toast('☕','КОФЕ ВЫПИТ','+35 ⚡'); vib(30); })
    .catch(()=>{});
}
window.buyCoffee=buyCoffee;
function updateShopAfford() {
    if (!user) return;
    const el=$('shop-coffee'); if(!el) return;
    el.classList.toggle('cant-afford',user.credits<40);
    const pr=$('coffee-price'); if(pr) pr.textContent=user.credits>=40?'40 💎':'40 💎 (нет)';
}

// ── DAILY BONUS ───────────────────────────────
function checkDailyBonus() {
    if (!user) return;
    fetch('/api/game/daily-bonus?providerId='+enc(user.providerId))
    .then(r=>r.ok?r.json():null)
    .then(d=>{ if(!d||!d.available) return;
        buildWeek(d.streak||1); $('daily-days').textContent=d.streak||1;
        $('daily-modal').classList.remove('hidden'); })
    .catch(()=>{});
}
function buildWeek(s) {
    const w=$('daily-week'); if(!w) return; w.innerHTML='';
    for (let i=1;i<=7;i++) {
        const d=document.createElement('div'); d.className='dw-dot';
        if (i<(s%7||(s>=7?8:0))) d.classList.add('done');
        if (i===(s%7||7)) d.classList.add('today');
        d.textContent=i; w.appendChild(d);
    }
}
function claimDaily() {
    if (!user||dailyClaimed) return; dailyClaimed=true; Sound.click();
    $('daily-modal').classList.add('hidden');
    fetch('/api/game/daily-bonus/claim?providerId='+enc(user.providerId),{method:'POST'})
    .then(r=>r.ok?r.json():null)
    .then(d=>{ if(!d) return; user=d.profile; updateHUD(user); updateProfile(user);
        toast('🎁','БОНУС ПОЛУЧЕН',`+50💎 · +30⚡ · Серия ${d.profile.streak}д.`); vib([30,20,30,20,80]); })
    .catch(()=>{});
}
window.claimDaily=claimDaily;

// ── ACHIEVEMENTS ──────────────────────────────
function checkAch(p) {
    let found=false;
    for (const d of ACH) {
        if (!earned.has(d.id)&&d.check(p)) {
            earned.add(d.id);
            localStorage.setItem('sdvig_ach',JSON.stringify([...earned]));
            if (!found) { setTimeout(()=>toast(d.icon,d.title,d.desc),500); found=true; }
            const b=$('ach-badge'); if(b){b.textContent='!';b.classList.remove('hidden');}
        }
    }
}

// ── TOAST ─────────────────────────────────────
let _tt=null;
function toast(ic,title,desc) {
    const el=$('toast');
    $('toast-icon').textContent=ic; $('toast-title').textContent=title; $('toast-desc').textContent=desc;
    el.classList.remove('hidden','out'); clearTimeout(_tt);
    _tt=setTimeout(()=>{ el.classList.add('out'); setTimeout(()=>el.classList.add('hidden'),300); },3200);
    vib(18);
}

// ── UTILS ─────────────────────────────────────
function enc(s) { return encodeURIComponent(s||''); }
function vib(p) { try{if(navigator.vibrate)navigator.vibrate(p);}catch(e){} }
function wait(ms){ return new Promise(r=>setTimeout(r,ms)); }

