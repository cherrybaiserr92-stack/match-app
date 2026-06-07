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

