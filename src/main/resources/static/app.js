const tg = window.Telegram && window.Telegram.WebApp ? window.Telegram.WebApp : null;
let currentUser = null;
let currentCase = null;

// Элементы свайпа
const card = document.getElementById('main-card');
let startX = 0, currentX = 0, isDragging = false;

document.addEventListener('DOMContentLoaded', () => {
    if (tg) { try { tg.expand(); tg.ready(); } catch(e) {} }
    
    setTimeout(() => {
        if (tg && tg.initData && tg.initData.length > 0) {
            document.getElementById('splash-text').innerText = "Авторизация WebApp...";
            authWebApp();
        } else {
            document.getElementById('splash-screen').style.opacity = '0';
            setTimeout(() => {
                document.getElementById('splash-screen').classList.add('hidden');
                document.getElementById('login-screen').classList.remove('hidden');
            }, 500);
        }
    }, 800);
});

// 1. Авторизации
function authWebApp() {
    fetch('/api/game/auth/webapp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ initData: tg.initData, initDataUnsafe: tg.initDataUnsafe })
    })
    .then(res => { if (!res.ok) throw new Error(); return res.json(); })
    .then(profile => loginSuccess(profile))
    .catch(() => showError("Ошибка входа WebApp. Проверьте токен."));
}

function onTelegramAuth(user) {
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('splash-screen').classList.remove('hidden');
    document.getElementById('splash-screen').style.opacity = '1';
    document.getElementById('splash-text').innerText = "Проверка данных виджета...";

    fetch('/api/game/auth/widget', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    })
    .then(res => { if (!res.ok) throw new Error(); return res.json(); })
    .then(profile => loginSuccess(profile))
    .catch(() => { alert("Ошибка виджета."); location.reload(); });
}
window.onTelegramAuth = onTelegramAuth;

function showError(msg) {
    document.getElementById('splash-screen').innerHTML = 
        `<h2 style="color:#ff3333">ОШИБКА</h2><p>${msg}</p><button class="btn" onclick="location.reload()">Повторить</button>`;
}

// 2. Старт игры
function loginSuccess(profile) {
    currentUser = profile;
    updateHUD(profile);
    
    document.getElementById('splash-screen').classList.add('hidden');
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('main-screen').classList.remove('hidden');
    
    loadCase();
    initCardPhysics();
}

function updateHUD(p) {
    document.getElementById('hud-energy').innerText = p.energy;
    document.getElementById('hud-credits').innerText = p.credits;
    document.getElementById('hud-rank').innerText = p.rank;
    document.getElementById('hud-xp').innerText = p.xp + " / " + (p.rank * 150);
    document.getElementById('lvl-skill1').innerText = "Lv." + p.skill1 + " (" + (p.skill1 * 50) + "🪙)";
    document.getElementById('lvl-skill2').innerText = "Lv." + p.skill2 + " (" + (p.skill2 * 50) + "🪙)";
}

// 3. Генерация дел ИИ
function loadCase() {
    document.getElementById('case-description').innerText = "ИИ сканирует архивы...";
    document.getElementById('hint-text').innerText = "";
    card.style.transform = 'none';

    fetch('/api/game/case?providerId=' + encodeURIComponent(currentUser.providerId))
    .then(res => res.text()) // Получаем как текст, так как Spring может вернуть JSON-строку
    .then(text => {
        try {
            // Парсим JSON из ответа ИИ
            let data = typeof text === 'string' ? JSON.parse(text) : text;
            if (typeof data === 'string') data = JSON.parse(data); // Двойной парсинг, если ИИ вернул строку в строке
            currentCase = data;
            document.getElementById('case-description').innerText = currentCase.text;
        } catch(e) {
            currentCase = { text: text, leftOption: "Действовать", rightOption: "Отступить", leftResult: "Вы действовали наугад.", rightResult: "Вы отступили." };
            document.getElementById('case-description').innerText = currentCase.text;
        }
    })
    .catch(() => document.getElementById('case-description').innerText = "Ошибка загрузки ИИ.");
}

// 4. Физика свайпов
function initCardPhysics() {
    const startDrag = (e) => {
        if (!document.getElementById('result-overlay').classList.contains('hidden') || !currentCase) return;
        isDragging = true;
        startX = e.type.includes('mouse') ? e.clientX : e.touches[0].clientX;
        card.style.transition = 'none';
    };

    const moveDrag = (e) => {
        if (!isDragging) return;
        currentX = e.type.includes('mouse') ? e.clientX : e.touches[0].clientX;
        const diffX = currentX - startX;
        
        card.style.transform = `translateX(${diffX}px) rotate(${diffX / 15}deg)`;

        const hint = document.getElementById('hint-text');
        if (diffX < -50) {
            hint.innerText = "← " + (currentCase.leftOption || "ВЛЕВО");
            hint.style.color = "#ff3333";
        } else if (diffX > 50) {
            hint.innerText = (currentCase.rightOption || "ВПРАВО") + " →";
            hint.style.color = "#00ff66";
        } else {
            hint.innerText = "";
        }
    };

    const endDrag = () => {
        if (!isDragging) return;
        isDragging = false;
        const diffX = currentX - startX;
        card.style.transition = 'transform 0.3s ease';

        if (diffX < -100) submitChoice('left');
        else if (diffX > 100) submitChoice('right');
        else {
            card.style.transform = 'none';
            document.getElementById('hint-text').innerText = "";
        }
    };

    card.addEventListener('mousedown', startDrag);
    window.addEventListener('mousemove', moveDrag);
    window.addEventListener('mouseup', endDrag);

    card.addEventListener('touchstart', startDrag);
    window.addEventListener('touchmove', moveDrag);
    window.addEventListener('touchend', endDrag);
}

// 5. Отправка решения и результаты
function submitChoice(direction) {
    fetch(`/api/game/choice?providerId=${encodeURIComponent(currentUser.providerId)}&direction=${direction}`, { method: 'POST' })
    .then(res => {
        if (!res.ok) return res.text().then(t => { alert(t); throw new Error(); });
        return res.json();
    })
    .then(data => {
        currentUser = data.profile;
        updateHUD(currentUser);

        document.getElementById('result-text').innerText = direction === 'left' ? currentCase.leftResult : currentCase.rightResult;
        document.getElementById('rew-xp').innerText = data.xpGained;
        document.getElementById('rew-credits').innerText = data.creditsGained;
        document.getElementById('rew-energy').innerText = data.energyLost;

        document.getElementById('result-overlay').classList.remove('hidden');
    })
    .catch(() => {
        card.style.transform = 'none';
        document.getElementById('hint-text').innerText = "";
    });
}

function nextCase() {
    document.getElementById('result-overlay').classList.add('hidden');
    loadCase();
}
window.nextCase = nextCase;

// 6. Навыки и Магазин
function upgradeSkill(skillNum) {
    fetch(`/api/game/upgrade-skill?providerId=${encodeURIComponent(currentUser.providerId)}&skillNum=${skillNum}`, { method: 'POST' })
    .then(res => {
        if(!res.ok) return res.text().then(t => { alert(t); throw new Error(); });
        return res.json();
    })
    .then(profile => { currentUser = profile; updateHUD(profile); })
    .catch(() => {});
}
window.upgradeSkill = upgradeSkill;

function buyCoffee() {
    fetch(`/api/game/buy-coffee?providerId=${encodeURIComponent(currentUser.providerId)}`, { method: 'POST' })
    .then(res => {
        if(!res.ok) return res.text().then(t => { alert(t); throw new Error(); });
        return res.json();
    })
    .then(profile => { currentUser = profile; updateHUD(profile); })
    .catch(() => {});
}
window.buyCoffee = buyCoffee;
