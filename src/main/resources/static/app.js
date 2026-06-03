function switchTab(tabId) {
    // Убираем активные классы
    document.querySelectorAll('.view-container').forEach(el => {
        el.classList.remove('view-active');
        el.classList.remove('vortex-in'); // очищаем анимации
        el.classList.remove('vortex-out');
    });
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    
    // Включаем нужную
    document.getElementById(`view-${tabId}`).classList.add('view-active');
    document.getElementById(`nav-${tabId}`).classList.add('active');
}

function selectRole(role) {
    // В реальном приложении здесь будет запрос к серверу на получение кейсов для роли
    const roleNames = { 'detective': 'Следователь', 'hacker': 'Кибер-Взломщик', 'psycho': 'Нейро-Психолог' };
    document.getElementById('case-role').innerText = roleNames[role];
    switchTab('investigation');
}

// Запуск анимации воронки и открытие мини-игры
function triggerMinigameVortex() {
    const currentView = document.getElementById('view-investigation');
    const minigameView = document.getElementById('view-minigame');
    
    // 1. Закручиваем текущий экран в воронку
    currentView.classList.add('vortex-out');
    
    // 2. Ждем окончания анимации (800мс), скрываем экран и показываем игру
    setTimeout(() => {
        currentView.classList.remove('view-active');
        currentView.classList.remove('vortex-out');
        
        // Показываем мини-игру с анимацией раскручивания из воронки
        minigameView.style.display = 'flex'; // Overlay forced flex
        minigameView.classList.add('vortex-in');
        
        setTimeout(() => {
            minigameView.classList.remove('vortex-in');
        }, 800);
    }, 750);
}

function exitMinigame() {
    const minigameView = document.getElementById('view-minigame');
    const returnView = document.getElementById('view-investigation');
    
    // Закручиваем игру
    minigameView.classList.add('vortex-out');
    
    setTimeout(() => {
        minigameView.style.display = 'none';
        minigameView.classList.remove('vortex-out');
        
        // Возвращаем на арену
        returnView.classList.add('view-active');
        returnView.classList.add('vortex-in');
        
        setTimeout(() => {
            returnView.classList.remove('vortex-in');
            // Здесь должна быть логика выдачи подсказки в карточке
            alert("Подсказка получена: Вероятность обмана 89%");
        }, 800);
    }, 750);
}
