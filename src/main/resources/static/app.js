// --- НАВИГАЦИЯ ---
function switchTab(tabId) {
    document.querySelectorAll('.view-container').forEach(el => {
        el.classList.remove('view-active');
        el.classList.remove('vortex-in', 'vortex-out');
    });
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    
    document.getElementById(`view-${tabId}`).classList.add('view-active');
    document.getElementById(`nav-${tabId}`).classList.add('active');
}

function selectRole(role) {
    const roleNames = { 'detective': 'Следователь', 'hacker': 'Кибер-Взломщик', 'psycho': 'Нейро-Психолог' };
    const roleColors = { 'detective': '#00E5FF', 'hacker': '#00FF66', 'psycho': '#FF007A' };
    
    const banner = document.getElementById('case-role');
    banner.innerText = `// Роль: ${roleNames[role]}`;
    banner.style.color = roleColors[role];
    
    // Сбрасываем состояние карточки при новой сессии
    document.getElementById('clue-box').style.display = 'none';
    document.getElementById('action-area').style.display = 'block';
    
    switchTab('investigation');
}

// --- ВОРОНКА И МИНИ-ИГРА ---
let selectedNode = null;

function triggerMinigameVortex() {
    const currentView = document.getElementById('view-investigation');
    const minigameView = document.getElementById('view-minigame');
    
    if(navigator.vibrate) navigator.vibrate(50);
    currentView.classList.add('vortex-out');
    
    setTimeout(() => {
        currentView.classList.remove('view-active', 'vortex-out');
        
        // Генерация новой доски
        generateBoard();
        
        minigameView.style.display = 'flex';
        minigameView.classList.add('vortex-in');
        
        setTimeout(() => minigameView.classList.remove('vortex-in'), 700);
    }, 700);
}

// Генерация интерактивного поля
function generateBoard() {
    const board = document.getElementById('cyber-board');
    // Очищаем старые узлы (оставляем только скрытое сообщение об успехе)
    board.innerHTML = '<div class="mg-success-msg" id="mg-success">ДОСТУП ОТКРЫТ</div>';
    
    const symbols = ['💎', '⚡', '👁️', '🧬'];
    selectedNode = null;
    
    for (let i = 0; i < 16; i++) {
        const node = document.createElement('div');
        node.className = 'cyber-node';
        node.innerText = symbols[Math.floor(Math.random() * symbols.length)];
        node.dataset.index = i;
        
        node.onclick = () => handleNodeClick(node);
        board.appendChild(node);
    }
}

function handleNodeClick(node) {
    if(navigator.vibrate) navigator.vibrate(20);
    
    if (!selectedNode) {
        selectedNode = node;
        node.classList.add('selected');
    } else {
        if (selectedNode === node) {
            node.classList.remove('selected');
            selectedNode = null;
            return;
        }
        
        // Анимация свапа (просто меняем текст для прототипа)
        const temp = selectedNode.innerText;
        selectedNode.innerText = node.innerText;
        node.innerText = temp;
        
        selectedNode.classList.remove('selected');
        selectedNode = null;
        
        // Имитация победы после 1 свапа
        setTimeout(winMinigame, 300);
    }
}

function winMinigame() {
    if(navigator.vibrate) navigator.vibrate([50, 50, 50]);
    document.getElementById('mg-success').classList.add('show');
    
    setTimeout(() => {
        document.getElementById('mg-success').classList.remove('show');
        returnToArena(true);
    }, 1500);
}

function cancelMinigame() { returnToArena(false); }

function returnToArena(success) {
    const minigameView = document.getElementById('view-minigame');
    const returnView = document.getElementById('view-investigation');
    
    minigameView.classList.add('vortex-out');
    
    setTimeout(() => {
        minigameView.style.display = 'none';
        minigameView.classList.remove('vortex-out');
        
        returnView.classList.add('view-active', 'vortex-in');
        
        if (success) {
            // Прячем кнопку взлома, показываем подсказку
            document.getElementById('action-area').style.display = 'none';
            document.getElementById('clue-box').style.display = 'block';
        }
        
        setTimeout(() => returnView.classList.remove('vortex-in'), 700);
    }, 700);
}

// --- ФИЗИКА СВАЙПОВ АРЕНЫ ---
const card = document.getElementById('current-case');
let startX = 0, distanceX = 0, isDragging = false;

card.addEventListener('touchstart', (e) => {
    isDragging = true; card.classList.add('dragging'); startX = e.touches[0].clientX;
});
card.addEventListener('touchmove', (e) => {
    if (!isDragging) return;
    distanceX = e.touches[0].clientX - startX;
    card.style.transform = `translate(${distanceX}px, ${Math.abs(distanceX)/10}px) rotate(${distanceX/20}deg)`;
    
    if(distanceX > 50) { document.getElementById('ind-right').style.opacity = Math.min(distanceX/100, 1); document.getElementById('ind-left').style.opacity = 0; }
    else if (distanceX < -50) { document.getElementById('ind-left').style.opacity = Math.min(Math.abs(distanceX)/100, 1); document.getElementById('ind-right').style.opacity = 0; }
    else { document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0; }
});
card.addEventListener('touchend', () => {
    if (!isDragging) return; isDragging = false; card.classList.remove('dragging');
    if (distanceX > window.innerWidth * 0.35) executeSwipe('right');
    else if (distanceX < -window.innerWidth * 0.35) executeSwipe('left');
    else {
        card.style.transition = 'transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
        card.style.transform = 'translate(0px, 0px) rotate(0deg)';
        document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0;
        setTimeout(() => card.style.transition = '', 400);
    }
    distanceX = 0;
});

function executeSwipe(dir) {
    if(navigator.vibrate) navigator.vibrate(40);
    
    // Анимация улета карточки
    card.style.transition = 'transform 0.4s ease-out, opacity 0.3s';
    card.style.transform = `translate(${dir === 'right' ? 150 : -150}%, 50px) rotate(${dir === 'right' ? 30 : -30}deg)`;
    card.style.opacity = '0';

    setTimeout(() => {
        // Здесь мы подгружали бы новую карточку с сервера.
        // Пока просто сбрасываем состояние текущей.
        document.getElementById('card-text').innerText = "Входящий сигнал зашифрован. Требуется анализ нового узла сети...";
        document.getElementById('case-id').innerText = "Дело #" + Math.floor(Math.random() * 900 + 100);
        document.getElementById('clue-box').style.display = 'none';
        document.getElementById('action-area').style.display = 'block';
        
        card.style.transition = 'none';
        card.style.transform = 'scale(0.8) translateY(-50px)';
        document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0;
        
        // Плавное появление новой карточки
        setTimeout(() => {
            card.style.transition = 'transform 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275), opacity 0.5s';
            card.style.transform = 'scale(1) translateY(0)';
            card.style.opacity = '1';
            setTimeout(() => card.style.transition = '', 500);
        }, 50);
    }, 400);
}
