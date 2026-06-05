let currentUser = null;
let currentCase = null;

// Безопасное получение объекта Telegram WebApp
const tg = window.Telegram && window.Telegram.WebApp ? window.Telegram.WebApp : null;

document.addEventListener('DOMContentLoaded', () => {
    const splash = document.getElementById('splash-screen');
    const loginScreen = document.getElementById('login-screen');
    const splashText = document.getElementById('splash-text');

    if (tg) {
        try { tg.expand(); tg.ready(); } catch(e) {}
    }
    
    // Небольшая задержка, чтобы WebApp успел проинициализироваться
    setTimeout(() => {
        if (tg && tg.initData && tg.initData.length > 0) {
            // Мы точно внутри Telegram - авторизуемся напрямую
            splashText.innerText = "Авторизация через Telegram...";
            authWebApp();
        } else {
            // Мы в браузере (или initData пуст) - показываем окно входа
            splash.classList.add('hidden');
            loginScreen.classList.remove('hidden');
        }
    }, 800);
});

// Авторизация внутри Telegram (Mini App)
function authWebApp() {
    fetch('/api/game/auth/webapp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            initData: tg.initData,
            initDataUnsafe: tg.initDataUnsafe
        })
    })
    .then(res => {
        if (!res.ok) throw new Error("Validation failed");
        return res.json();
    })
    .then(profile => loginSuccess(profile))
    .catch(err => {
        console.error("Auth error:", err);
        document.getElementById('splash-screen').innerHTML = `
            <h2 style='color:#ff3333;'>ОШИБКА АВТОРИЗАЦИИ</h2>
            <p style='color:#aaa; font-size:12px;'>Токен бота не настроен на сервере.</p>
            <button class="btn" onclick="location.reload()">Повторить</button>
        `;
    });
}

// Авторизация в браузере (через виджет)
function onTelegramAuth(user) {
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('splash-screen').classList.remove('hidden');
    document.getElementById('splash-text').innerText = "Проверка данных виджета...";

    fetch('/api/game/auth/widget', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    })
    .then(res => {
        if (!res.ok) throw new Error("Auth failed");
        return res.json();
    })
    .then(profile => loginSuccess(profile))
    .catch(err => {
        alert("Ошибка входа через виджет. Проверьте настройки бота.");
        location.reload();
    });
}
window.onTelegramAuth = onTelegramAuth;

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
    document.getElementById('lvl-skill1').innerText = "Lvl " + p.skill1;
    document.getElementById('lvl-skill2').innerText = "Lvl " + p.skill2;
}

// Заглушки для механики свайпов, чтобы приложение не падало
function loadCase() {
    document.getElementById('case-description').innerText = "ИИ генерирует дело...";
    // Здесь будет fetch('/api/game/case...')
}

function initCardPhysics() {
    // Здесь логика свайпов (оставил пустой для краткости, она у тебя уже есть)
}

function nextCase() {
    document.getElementById('result-overlay').classList.add('hidden');
    loadCase();
}
window.nextCase = nextCase;

function upgradeSkill(skillNum) { /* Логика улучшения */ }
window.upgradeSkill = upgradeSkill;

function buyCoffee() { /* Логика кофе */ }
window.buyCoffee = buyCoffee;
