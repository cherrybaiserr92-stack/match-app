let currentUser = null;
let currentCase = null;
let tg = null;

// 1. Безопасная инициализация Telegram
try {
    if (window.Telegram && window.Telegram.WebApp) {
        tg = window.Telegram.WebApp;
    }
} catch (e) {
    console.warn("Telegram WebApp не найден. Работаем в режиме браузера.");
}

const card = document.getElementById('main-card');
let startX = 0;
let currentX = 0;
let isDragging = false;

document.addEventListener('DOMContentLoaded', () => {
    if (tg && tg.expand) {
        try { tg.expand(); tg.ready(); } catch(e) {}
    }
    
    setTimeout(() => {
        if (tg && tg.initData && tg.initData !== "") {
            authWebApp();
        } else {
            // Режим обычного браузера - прячем лоадер и открываем логин
            document.getElementById('splash-screen').style.opacity = '0';
            setTimeout(() => {
                document.getElementById('splash-screen').classList.add('hidden');
                document.getElementById('login-screen').classList.remove('hidden');
            }, 500);
        }
    }, 1500);
});

// 2. Авторизация внутри Telegram
function authWebApp() {
    document.getElementById('splash-screen').innerHTML = `
        <h1 style="letter-spacing: 5px; margin: 0; color: #fff;">СДВИГ</h1>
        <p style="color: #00ff66; font-size: 12px; margin: 5px 0 0 0;">Связь с сервером...</p>
        <div class="spinner"></div>
    `;

    fetch('/api/game/auth/webapp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            initData: tg.initData,
            initDataUnsafe: tg.initDataUnsafe
        })
    })
    .then(res => {
        if (!res.ok) return res.text().then(t => { throw new Error(t); });
        return res.json();
    })
    .then(profile => loginSuccess(profile))
    .catch(err => {
        console.error("Auth error:", err);
        document.getElementById('splash-screen').innerHTML = `
            <h2 style='color:#ff3333;'>ОТКАЗ В ДОСТУПЕ</h2>
            <p style='color:#aaa; font-size:12px; padding: 0 20px;'>Не удалось проверить подпись Telegram.</p>
            <p style='color:#ffcc00; font-size:11px; padding: 0 20px;'>Убедись, что в Railway добавлена переменная TELEGRAM_BOT_TOKEN</p>
            <button onclick="location.reload()" style="margin-top:15px; padding:10px; background:#333; color:#fff; border:none; border-radius:4px;">Повторить</button>
        `;
    });
}

// 3. Авторизация через браузер (Виджет)
function onTelegramAuth(user) {
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('splash-screen').classList.remove('hidden');
    document.getElementById('splash-screen').style.opacity = '1';
    
    document.getElementById('splash-screen').innerHTML = `
        <h1 style="letter-spacing: 5px; margin: 0; color: #fff;">СДВИГ</h1>
        <p style="color: #00ff66; font-size: 12px; margin: 5px 0 0 0;">Проверка ID...</p>
        <div class="spinner"></div>
    `;

    fetch('/api/game/auth/widget', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    })
    .then(res => {
        if (!res.ok) return res.text().then(t => { throw new Error(t); });
        return res.json();
    })
    .then(profile => loginSuccess(profile))
    .catch(err => {
        console.error("Widget Auth error:", err);
        alert("Ошибка входа через виджет. Проверь токен на сервере!");
        location.reload();
    });
}

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

function loadCase() {
    document.getElementById('case-description').innerText = "Связь с архивом ИИ... Сканирование терабайтов данных...";
    document.getElementById('hint-text').innerText = "";
    card.style.transform = 'none';

    fetch('/api/game/case?providerId=' + encodeURIComponent(currentUser.providerId))
    .then(res => res.json())
    .then(data => {
        currentCase = data;
        document.getElementById('case-description').innerText = data.text;
    })
    .catch(() => {
        document.getElementById('case-description').innerText = "Ошибка загрузки дела. Архивы ИИ недоступны.";
    });
}

function initCardPhysics() {
    const startDrag = (e) => {
        if (document.getElementById('result-overlay').classList.contains('hidden') === false) return;
        isDragging = true;
        startX = e.touches ? e.touches[0].clientX : e.clientX;
        card.style.transition = 'none';
    };

    const moveDrag = (e) => {
        if (!isDragging || !currentCase) return;
        currentX = e.touches ? e.touches[0].clientX : e.clientX;
        const diffX = currentX - startX;
        
        card.style.transform = "translateX(" + diffX + "px) rotate(" + (diffX / 15) + "deg)";

        if (diffX < -40) {
            document.getElementById('hint-text').innerText = "← ВЛЕВО: " + currentCase.leftOption;
            document.getElementById('hint-text').style.color = "#ff3333";
        } else if (diffX > 40) {
            document.getElementById('hint-text').innerText = "ВПРАВО: " + currentCase.rightOption + " →";
            document.getElementById('hint-text').style.color = "#00ff66";
        } else {
            document.getElementById('hint-text').innerText = "";
        }
    };

    const endDrag = () => {
        if (!isDragging) return;
        isDragging = false;
        const diffX = currentX - startX;

        card.style.transition = 'transform 0.4s ease';

        if (diffX < -120) {
            submitChoice('left');
        } else if (diffX > 120) {
            submitChoice('right');
        } else {
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

function submitChoice(direction) {
    fetch('/api/game/choice?providerId=' + encodeURIComponent(currentUser.providerId) + '&direction=' + direction, {
        method: 'POST'
    })
    .then(res => {
        if (!res.ok) return res.text().then(text => { alert(text); throw new Error(); });
        return res.json();
    })
    .then(data => {
        currentUser = data.profile;
        updateHUD(currentUser);

        const resultText = direction === 'left' ? currentCase.leftResult : currentCase.rightResult;
        document.getElementById('result-text').innerText = resultText;
        
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

function upgradeSkill(skillNum) {
    fetch('/api/game/upgrade-skill?providerId=' + encodeURIComponent(currentUser.providerId) + '&skillNum=' + skillNum, {
        method: 'POST'
    })
    .then(res => {
        if(!res.ok) return res.text().then(t => { alert(t); throw new Error(); });
        return res.json();
    })
    .then(profile => {
        currentUser = profile;
        updateHUD(profile);
    })
    .catch(() => {});
}
window.upgradeSkill = upgradeSkill;

function buyCoffee() {
    fetch('/api/game/buy-coffee?providerId=' + encodeURIComponent(currentUser.providerId), {
        method: 'POST'
    })
    .then(res => {
        if(!res.ok) return res.text().then(t => { alert(t); throw new Error(); });
        return res.json();
    })
    .then(profile => {
        currentUser = profile;
        updateHUD(profile);
    })
    .catch(() => {});
}
window.buyCoffee = buyCoffee;
