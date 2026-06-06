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

