// --- КОНФИГУРАЦИЯ 10 КИБЕР-РОЛЕЙ ---
const GAME_ROLES = [
    { id: 'detective', name: 'Кибер-Детектив', icon: '🕵️‍♂️', desc: 'Анализирует цифровые улики и повадки ИИ.', perk: 'Дешифровка +15%' },
    { id: 'medic', name: 'Нейро-Хирург', icon: '🩺', desc: 'Лечит ментальные искажения у био-модификантов.', perk: 'Стабильность энергии' },
    { id: 'traveler', name: 'Квантовый Путешественник', icon: '🌍', desc: 'Перемещается между слоями метавселенных.', perk: 'Бонус к опыту +10%' },
    { id: 'shaman', name: 'Техно-Шаман', icon: '🔮', desc: 'Общается с духами старого кода и ядрами ИИ.', perk: 'Крит. взлом +5%' },
    { id: 'hacker', name: 'Призрачный Хакер', icon: '💻', desc: 'Стирает следы своего присутствия в любых сетях.', perk: 'Бесплатные подсказки' },
    { id: 'insider', name: 'Корпо-Инсайдер', icon: '🏢', desc: 'Знает все теневые схемы мегакорпораций.', perk: 'Доп. Искры +20%' },
    { id: 'nomad', name: 'Сетевой Кочевник', icon: '🛞', desc: 'Выживает в пустошах глобальной темной сети.', perk: 'Сопротивление спаму' },
    { id: 'diplomat', name: 'ИИ-Дипломат', icon: '🤝', desc: 'Разрешает конфликты между людьми и машинами.', perk: 'Мягкий свайп' },
    { id: 'stalker', name: 'Цифровой Сталкер', icon: '🏹', desc: 'Охотится за редкими архивами данных.', perk: 'Редкие кейсы' },
    { id: 'mentalist', name: 'Ментальный Хакер', icon: '🧠', desc: 'Взламывает чужие мысли через нейроинтерфейс.', perk: 'Интуиция правды' }
];

let gameState = {
    role: null,
    sparks: 350,
    energy: 100,
    level: 1,
    xp: 0,
    upgrades: { up1: 1, up2: 1 }
};

// --- ИНИЦИАЛИЗАЦИЯ И ЗАСТАВКА ---
window.addEventListener('DOMContentLoaded', () => {
    // Симуляция загрузки заставки
    setTimeout(() => {
        const splash = document.getElementById('splash-screen');
        splash.style.opacity = '0';
        setTimeout(() => splash.style.display = 'none', 800);
        
        checkUserOnboarding();
    }, 1800);
});

function checkUserOnboarding() {
    const savedRole = localStorage.getItem('neuro_user_role');
    if (!savedRole) {
        buildOnboardingRoles();
        document.getElementById('onboarding-screen').style.display = 'flex';
    } else {
        initGame(savedRole);
    }
}

function buildOnboardingRoles() {
    const container = document.getElementById('roles-anchor');
    container.innerHTML = '';
    
    GAME_ROLES.forEach(r => {
        const card = document.createElement('div');
        card.className = 'role-select-card';
        card.onclick = () => chooseRole(r.id);
        card.innerHTML = `
            <div class="role-sel-icon">${r.icon}</div>
            <div class="role-sel-info">
                <h4>${r.name}</h4>
                <p>${r.desc}</p>
                <div class="role-perk">⚡ Перк: ${r.perk}</div>
            </div>
        `;
        container.appendChild(card);
    });
}

function chooseRole(roleId) {
    if(navigator.vibrate) navigator.vibrate(60);
    localStorage.setItem('neuro_user_role', roleId);
    document.getElementById('onboarding-screen').style.opacity = '0';
    setTimeout(() => document.getElementById('onboarding-screen').style.display = 'none', 500);
    initGame(roleId);
}

function initGame(roleId) {
    const userRole = GAME_ROLES.find(r => r.id === roleId);
    gameState.role = userRole;
    
    // Обновляем UI данными роли
    document.getElementById('case-role-tag').innerText = `// Профиль: ${userRole.name}`;
    document.getElementById('hq-role-display').innerText = `Профиль: ${userRole.name} [${userRole.icon}]`;
    document.getElementById('profile-name-display').innerText = `Агент_${userRole.name.split('-')[1] || userRole.name.split(' ')[1] || 'X'}`;
    document.getElementById('profile-role-display').innerText = `Класс: ${userRole.name}`;
    document.getElementById('profile-avatar-icon').innerText = userRole.icon;
    
    updateHUD();
}

function updateHUD() {
    document.getElementById('hud-energy').innerText = gameState.energy;
    document.getElementById('hud-sparks').innerText = gameState.sparks;
    document.getElementById('profile-level').innerText = `${gameState.level} Ур.`;
    
    const xpNeeded = gameState.level * 250;
    const pct = (gameState.xp / xpNeeded) * 100;
    document.getElementById('profile-xp-fill').style.width = `${pct}%`;
    document.getElementById('profile-xp-text').innerText = `${gameState.xp} / ${xpNeeded} XP`;
}

// --- НАВИГАЦИЯ ---
function tabTo(viewId) {
    document.querySelectorAll('.view-container').forEach(v => v.classList.remove('view-active', 'vortex-in', 'vortex-out'));
    document.querySelectorAll('.dock-item').forEach(d => d.classList.remove('active'));
    
    document.getElementById(`view-${viewId}`).classList.add('view-active');
    document.getElementById(`dock-${viewId}`).classList.add('active');
}

// --- ШТАБ: АПГРЕЙДЫ ---
function buyUpgrade(type) {
    let cost = type === 1 ? gameState.upgrades.up1 * 50 : gameState.upgrades.up2 * 120;
    if (gameState.sparks >= cost) {
        gameState.sparks -= cost;
        if(type === 1) {
            gameState.upgrades.up1++;
            document.getElementById('up-lvl-1').innerText = gameState.upgrades.up1;
        } else {
            gameState.upgrades.up2++;
            document.getElementById('up-lvl-2').innerText = gameState.upgrades.up2;
        }
        if(navigator.vibrate) navigator.vibrate([30, 30]);
        updateHUD();
    } else {
        alert("Недостаточно Искр для калибровки импланта.");
    }
}

// --- МИНИ-ИГРА С ВОРОНКОЙ ---
let activeMatrixNode = null;

function openMinigame() {
    const arena = document.getElementById('view-arena');
    const minigame = document.getElementById('view-minigame');
    
    if(navigator.vibrate) navigator.vibrate(40);
    arena.classList.add('vortex-out');
    
    setTimeout(() => {
        arena.classList.remove('view-active', 'vortex-out');
        buildMatrix();
        minigame.style.display = 'flex';
        minigame.classList.add('vortex-in');
        setTimeout(() => minigame.classList.remove('vortex-in'), 650);
    }, 600);
}

function buildMatrix() {
    const matrix = document.getElementById('minigame-board-matrix');
    matrix.querySelectorAll('.matrix-cell').forEach(c => c.remove());
    activeMatrixNode = null;
    
    const items = ['✨', '💎', '💾', '🔋'];
    for(let i=0; i<16; i++) {
        const cell = document.createElement('div');
        cell.className = 'matrix-cell';
        cell.innerText = items[Math.floor(Math.random() * items.length)];
        cell.onclick = () => {
            if(navigator.vibrate) navigator.vibrate(20);
            if(!activeMatrixNode) {
                activeMatrixNode = cell;
                cell.classList.add('active-node');
            } else {
                // Меняем местами элементы
                let tmp = activeMatrixNode.innerText;
                activeMatrixNode.innerText = cell.innerText;
                cell.innerText = tmp;
                
                activeMatrixNode.classList.remove('active-node');
                activeMatrixNode = null;
                
                // Победа
                setTimeout(triggerMatrixWin, 250);
            }
        };
        matrix.appendChild(cell);
    }
}

function triggerMatrixWin() {
    if(navigator.vibrate) navigator.vibrate([40, 40, 40]);
    const banner = document.getElementById('mg-success-banner');
    banner.style.display = 'flex';
    setTimeout(() => {
        banner.style.display = 'none';
        closeMinigame(true);
    }, 1200);
}

function closeMinigame(success) {
    const arena = document.getElementById('view-arena');
    const minigame = document.getElementById('view-minigame');
    
    minigame.classList.add('vortex-out');
    setTimeout(() => {
        minigame.style.display = 'none';
        minigame.classList.remove('vortex-out');
        
        arena.classList.add('view-active', 'vortex-in');
        
        if(success) {
            document.getElementById('case-clue').style.display = 'block';
            document.getElementById('hack-zone').style.display = 'none';
        }
        setTimeout(() => arena.classList.remove('vortex-in'), 650);
    }, 600);
}

// --- СВАЙПЫ С ОПЫТОМ ---
const card = document.getElementById('case-card');
let sX = 0, dX = 0, isDrag = false;

card.addEventListener('touchstart', (e) => { isDrag = true; sX = e.touches[0].clientX; });
card.addEventListener('touchmove', (e) => {
    if(!isDrag) return;
    dX = e.touches[0].clientX - sX;
    card.style.transform = `translate(${dX}px, ${Math.abs(dX)/12}px) rotate(${dX/22}deg)`;
    
    if(dX > 60) { document.getElementById('ind-right').style.opacity = Math.min(dX/120, 1); document.getElementById('ind-left').style.opacity = 0; }
    else if(dX < -60) { document.getElementById('ind-left').style.opacity = Math.min(Math.abs(dX)/120, 1); document.getElementById('ind-right').style.opacity = 0; }
    else { document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0; }
});
card.addEventListener('touchend', () => {
    if(!isDrag) return; isDrag = false;
    if(dX > window.innerWidth * 0.35) completeCase('right');
    else if(dX < -window.innerWidth * 0.35) completeCase('left');
    else {
        card.style.transform = 'translate(0,0) rotate(0deg)';
        document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0;
    }
    dX = 0;
});

function completeCase(direction) {
    if(navigator.vibrate) navigator.vibrate(35);
    
    // Начисление XP и Искр за закрытие кейса
    gameState.xp += 60;
    gameState.sparks += 15;
    
    // Проверка уровня
    let needed = gameState.level * 250;
    if(gameState.xp >= needed) {
        gameState.xp -= needed;
        gameState.level++;
        if(navigator.vibrate) navigator.vibrate([100, 50, 100]);
    }
    
    card.style.transform = `translate(${direction === 'right' ? 160 : -160}%, 60px) rotate(${direction === 'right' ? 25 : -25}deg)`;
    card.style.opacity = '0';
    
    setTimeout(() => {
        document.getElementById('case-text').innerText = "Входящий поток откалиброван. Следующая аномалия ИИ ожидает решения...";
        document.getElementById('case-num').innerText = "Кейс #" + Math.floor(Math.random() * 800 + 100);
        document.getElementById('case-clue').style.display = 'none';
        document.getElementById('hack-zone').style.display = 'block';
        
        card.style.transform = 'scale(0.85) translateY(-40px)';
        document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0;
        
        setTimeout(() => {
            card.style.transition = 'transform 0.45s cubic-bezier(0.175, 0.885, 0.32, 1.2), opacity 0.45s';
            card.style.transform = 'scale(1) translateY(0)';
            card.style.opacity = '1';
            updateHUD();
            setTimeout(() => card.style.transition = '', 450);
        }, 40);
    }, 350);
}
