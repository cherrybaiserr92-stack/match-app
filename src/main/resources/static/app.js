const tg = window.Telegram.WebApp;

document.addEventListener('DOMContentLoaded', () => {
    tg.expand();
    tg.ready();
    
    // Если открыто внутри Telegram, запускаем тихую авторизацию
    if (tg.initData) {
        document.getElementById('loading-screen').classList.remove('hidden');
        authWebApp();
    } else {
        // Если открыто в браузере, прячем загрузку и показываем кнопки входа
        document.getElementById('loading-screen').classList.add('hidden');
        document.getElementById('login-screen').classList.remove('hidden');
    }
});

// 1. Авторизация внутри Telegram
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
    .then(profile => startGame(profile))
    .catch(err => {
        console.error("Ошибка WebApp авторизации:", err);
        document.getElementById('loading-screen').innerHTML = "<h2>Ошибка сети</h2><button class='btn' onclick='authWebApp()'>Повторить</button>";
    });
}

// 2. Авторизация через кнопку в браузере (вызывается самим виджетом Telegram)
function onTelegramAuth(user) {
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('loading-screen').classList.remove('hidden');

    // Отправляем объект user целиком для проверки хэша
    fetch('/api/game/auth/widget', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user) 
    })
    .then(res => {
        if(!res.ok) throw new Error("Widget validation failed");
        return res.json();
    })
    .then(profile => startGame(profile))
    .catch(err => {
        console.error("Ошибка Widget авторизации:", err);
        document.getElementById('loading-screen').classList.add('hidden');
        document.getElementById('login-screen').classList.remove('hidden');
        alert("Сбой входа. Попробуйте еще раз.");
    });
}

// 3. Запуск игры
function startGame(profile) {
    document.getElementById('loading-screen').classList.add('hidden');
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('main-screen').classList.remove('hidden');
    
    document.getElementById('user-info').innerText = 
        `Добро пожаловать, ${profile.firstName}!\nУровень: ${profile.level}\nОпыт: ${profile.experience}`;
}
