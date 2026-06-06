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

