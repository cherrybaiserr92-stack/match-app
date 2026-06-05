const tg = window.Telegram.WebApp;
let currentUser = null;
let currentCase = null;

// Переменные для отслеживания тачей и свайпов карточки
const card = document.getElementById('main-card');
let startX = 0;
let currentX = 0;
let isDragging = false;

document.addEventListener('DOMContentLoaded', () => {
    tg.expand();
    tg.ready();
    
    // Эмуляция работы Splash-экрана на 1.5 секунды перед разводкой
    setTimeout(() => {
        if (tg.initData && tg.initData !== "") {
            // Если мы внутри Telegram App — запускаем тихий вход
            authWebApp();
        } else {
            // Если в обычном браузере — убираем Splash и показываем Login с виджетом
            document.getElementById('splash-screen').style.opacity = '0';
            setTimeout(() => document.getElementById('splash-screen').classList.add('hidden'), 500);
        }
    }, 1500);
});

// 1. Авторизация в Telegram WebApp
function authWebApp() {
    fetch('/api/game/auth/webapp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            initData: tg.initData,
            initDataUnsafe: tg.initDataUnsafe
        })
    })
    .then(res => { if (!res.ok) throw new Error(); return res.json(); })
    .then(profile => loginSuccess(profile))
    .catch(() => {
        document.getElementById('splash-screen').innerHTML = "<h2 style='color:red;'>ОШИБКА СЕТИ</h2>";
    });
}

// 2. Авторизация через Виджет в Браузере
function onTelegramAuth(user) {
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('splash-screen').classList.remove('hidden');
    document.getElementById('splash-screen').style.opacity = '1';

    fetch('/api/game/auth/widget', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    })
    .then(res => { if (!res.ok) throw new Error(); return res.json(); })
    .then(profile => loginSuccess(profile))
    .catch(() => {
        alert("Ошибка верификации через виджет");
        document.getElementById('login-screen').classList.remove('hidden');
        document.getElementById('splash-screen').classList.add('hidden');
    });
}

// Успешный вход в систему
function loginSuccess(profile) {
    currentUser = profile;
    updateHUD(profile);
    
    document.getElementById('splash-screen').classList.add('hidden');
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('main-screen').classList.remove('remove');
    document.getElementById('main-screen').classList.remove('hidden');
    
    loadCase();
    initCardPhysics();
}

// Обновление интерфейса параметров игрока
function updateHUD(p) {
    document.getElementById('hud-energy').innerText = p.energy;
    document.getElementById('hud-credits').innerText = p.credits;
    document.getElementById('hud-rank').innerText = p.rank;
    document.getElementById('hud-xp').innerText = p.xp + " / " + (p.rank * 150);
    
    document.getElementById('lvl-skill1').innerText = `Lvl ${p.skill1} (Цена: ${p.skill1 * 50})`;
    document.getElementById('lvl-skill2').innerText = `Lvl ${p.skill2} (Цена: ${p.skill2 * 50})`;
}

// Загрузка нового ИИ-инцидента с бэкенда
function loadCase() {
    document.getElementById('case-description').innerText = "Связь с архивом ИИ... Сканирование терабайтов данных...";
    document.getElementById('hint-text').innerText = "";
    card.style.transform = 'none';

    fetch(`/api/game/case?providerId=${encodeURIComponent(currentUser.providerId)}`)
    .then(res => res.json())
    .then(data => {
        currentCase = data;
        document.getElementById('case-description').innerText = data.text;
    });
}

// Инициализация механики свайпов
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
        
        // Поворот и смещение карты в зависимости от перемещения
        card.style.transform = `translateX(${diffX}px) rotate(${diffX / 15}deg)`;

        // Динамический вывод вариантов выбора прямо во время наклона
        if (diffX < -40) {
            document.getElementById('hint-text').innerText = `← ВЛЕВО: ${currentCase.leftOption}`;
            document.getElementById('hint-text').style.color = "#ff3333";
        } else if (diffX > 40) {
            document.getElementById('hint-text').innerText = `ВПРАВО: ${currentCase.rightOption} →`;
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
            // Зафиксирован уверенный свайп влево
            submitChoice('left');
        } else if (diffX > 120) {
            // Зафиксирован уверенный свайп вправо
            submitChoice('right');
        } else {
            // Возврат карты в центр, если сдвинули мало
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

// Отправка решения игрока на сервер
function submitChoice(direction) {
    fetch(`/api/game/choice?providerId=${encodeURIComponent(currentUser.providerId)}&direction=${direction}`, {
        method: 'POST'
    })
    .then(res => {
        if (!res.ok) {
            return res.text().then(text => { alert(text); throw new Error(); });
        }
        return res.json();
    })
    .then(data => {
        currentUser = data.profile;
        updateHUD(currentUser);

        // Показываем текст развертывания сюжета на основе выбора
        const resultText = direction === 'left' ? currentCase.leftResult : currentCase.rightResult;
        document.getElementById('result-text').innerText = resultText;
        
        document.getElementById('rew-xp').innerText = data.xpGained;
        document.getElementById('rew-credits').innerText = data.creditsGained;
        document.getElementById('rew-energy').innerText = data.energyLost;

        // Показываем оверлей результатов
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

// Прокачка Навыков
function upgradeSkill(skillNum) {
    fetch(`/api/game/upgrade-skill?providerId=${encodeURIComponent(currentUser.providerId)}&skillNum=${skillNum}`, {
        method: 'POST'
    })
    .then(res => res.json())
    .then(profile => {
        currentUser = profile;
        updateHUD(profile);
    })
    .catch(() => alert("Недостаточно кредитов!"));
}

// Покупка Кофе (Инвентарь)
function buyCoffee() {
    fetch(`/api/game/buy-coffee?providerId=${encodeURIComponent(currentUser.providerId)}`, {
        method: 'POST'
    })
    .then(res => res.json())
    .then(profile => {
        currentUser = profile;
        updateHUD(profile);
    })
    .catch(() => alert("Недостаточно кредитов для покупки кофе!"));
}
