const ARCHETYPES = [
    { id: 'detective', name: 'Детектив', icon: '🕵️‍♂️', desc: 'Специалист по поиску улик, зацепок и скрытых мотивов.', perk: '+15% к опыту расследований', game: 'Мемори-анализ' },
    { id: 'doctor', name: 'Врач', icon: '🩺', desc: 'Определяет ложь по физиологическим реакциям и пульсу.', perk: 'Экономия энергии 10%', game: 'Кардиограмма' },
    { id: 'traveler', name: 'Путешественник', icon: '🧳', desc: 'Обладает широким кругозором и знанием локальных обычаев.', perk: '+20% монет за правильный выбор', game: 'Ориентирование' },
    { id: 'scientist', name: 'Ученый', icon: '🔬', desc: 'Опирается на жесткие химические, физические и цифровые тесты.', perk: 'Подсказки стоят дешевле', game: 'Калибровка веса' },
    { id: 'psychologist', name: 'Психолог', icon: '🧠', desc: 'Читает микромимику, жесты и ловит скрытые паттерны речи.', perk: 'Видит процент вероятности лжи', game: 'Спектр эмоций' },
    { id: 'engineer', name: 'Инженер', icon: '🛠️', desc: 'Разбирается в механизмах, замках, электронике и логах.', perk: 'Пропуск 1 сложной игры в день', game: 'Замкнутая цепь' },
    { id: 'journalist', name: 'Журналист', icon: '🎙️', desc: 'Умеет разговорить любого и находить скрытые архивы.', perk: 'Дополнительные улики', game: 'Шумоподавление' },
    { id: 'diplomat', name: 'Дипломат', icon: '💼', desc: 'Мастер переговоров, видит скрытые манипуляции в текстах.', perk: 'Иммунитет к штрафам за ошибки', game: 'Линия компромисса' },
    { id: 'thief', name: 'Взломщик', icon: '🗝️', desc: 'Обладает феноменальной ловкостью рук и слухом для вскрытия замков.', perk: '+25% к критическому заработку', game: 'Тактильный сейф' },
    { id: 'hunter', name: 'Охотник', icon: '🏹', desc: 'Отслеживает перемещения, ищет несостыковки в таймингах.', perk: 'Быстрый сброс карточки', game: 'Перехват цели' }
];

// Подключаем Telegram WebApp SDK
const tg = window.Telegram?.WebApp;
if(tg) tg.expand(); 

export let playerState = {
    telegramId: tg?.initDataUnsafe?.user?.id || 123456, 
    username: tg?.initDataUnsafe?.user?.username || "Guest Operator",
    classData: null,
    energy: 100,
    credits: 150,
    rank: 1,
    xp: 0,
    skills: { s1: 1, s2: 1 },
    currentLevel: 1 
};

const authHeader = tg?.initData || "MOCK_DATA_FOR_LOCAL_TESTING";

window.addEventListener('DOMContentLoaded', () => {
    setTimeout(() => {
        const splash = document.getElementById('splash-layer');
        if(splash) {
            splash.style.opacity = '0';
            setTimeout(() => splash.style.display = 'none', 600);
        }
        checkGameAuth();
    }, 1200);
});

async function checkGameAuth() {
    try {
        const response = await fetch('/api/game/profile', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-TG-Auth': authHeader
            },
            body: JSON.stringify({
                telegramId: playerState.telegramId,
                username: playerState.username
            })
        });
        
        if (response.ok) {
            const dbProfile = await response.json();
            if (!dbProfile.archetype || dbProfile.archetype === "detective" && !localStorage.getItem('sdvig_user_class')) {
                renderOnboardingGrid();
                document.getElementById('onboarding-layer').style.display = 'flex';
            } else {
                mapProfileData(dbProfile);
            }
        }
    } catch (err) {
        console.error("Сервер не ответил. Локальный автономный режим.", err);
        loadProfileData('detective'); 
    }
}

function mapProfileData(dbData) {
    playerState.energy = dbData.energy;
    playerState.credits = dbData.credits;
    playerState.rank = dbData.rank;
    playerState.xp = dbData.xp;
    playerState.skills.s1 = dbData.skill1;
    playerState.skills.s2 = dbData.skill2;
    playerState.currentLevel = dbData.currentGameLevel;
    
    loadProfileData(dbData.archetype);
    loadNewAiCase();
}

async function syncProgressWithServer() {
    try {
        await fetch('/api/game/sync', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-TG-Auth': authHeader
            },
            body: JSON.stringify({
                telegramId: playerState.telegramId,
                username: playerState.username,
                archetype: playerState.classData.id,
                energy: playerState.energy,
                credits: playerState.credits,
                rank: playerState.rank,
                xp: playerState.xp,
                skill1: playerState.skills.s1,
                skill2: playerState.skills.s2,
                currentGameLevel: playerState.currentLevel
            })
        });
    } catch(e) { console.error("Ошибка синхронизации данных с сервером"); }
}

async function loadNewAiCase() {
    try {
        document.getElementById('active-case-text').innerText = "Запрос к ИИ-Архиву...";
        const res = await fetch(`/api/game/case?archetype=${playerState.classData.id}&level=${playerState.currentLevel}`, {
            headers: { 'X-TG-Auth': authHeader }
        });
        if(res.ok) {
            const data = await res.json();
            document.getElementById('active-case-text').innerText = data.text;
        }
    } catch(e) { 
        document.getElementById('active-case-text').innerText = "Ошибка соединения. Взят локальный архивный документ.";
    }
}

function renderOnboardingGrid() {
    const container = document.getElementById('class-cards-container');
    container.innerHTML = '';
    ARCHETYPES.forEach(arch => {
        const card = document.createElement('div');
        card.className = 'class-card';
        card.onclick = () => {
            if(navigator.vibrate) navigator.vibrate(50);
            localStorage.setItem('sdvig_user_class', arch.id);
            document.getElementById('onboarding-layer').style.opacity = '0';
            setTimeout(() => document.getElementById('onboarding-layer').style.display = 'none', 400);
            playerState.classData = arch;
            syncProgressWithServer().then(() => loadProfileData(arch.id));
        };
        card.innerHTML = `
            <div class="class-icon">${arch.icon}</div>
            <div class="class-info">
                <h4>${arch.name}</h4>
                <p>${arch.desc}</p>
                <div class="class-perk">Особенность: ${arch.perk}</div>
            </div>
        `;
        container.appendChild(card);
    });
}

function loadProfileData(classId) {
    playerState.classData = ARCHETYPES.find(a => a.id === classId) || ARCHETYPES[0];
    
    document.getElementById('case-class-lbl').innerText = `// Модуль: ${playerState.classData.name}`;
    document.getElementById('hq-class-title').innerText = `Штаб: ${playerState.classData.name} ${playerState.classData.icon}`;
    document.getElementById('dossier-class-lbl').innerText = `Специализация: ${playerState.classData.name}`;
    document.getElementById('dossier-avatar-icon').innerText = playerState.classData.icon;
    document.getElementById('dossier-name-lbl').innerText = playerState.username;
    
    document.getElementById('tab-hq').onclick = () => switchView('hq');
    document.getElementById('tab-arena').onclick = () => switchView('arena');
    document.getElementById('tab-profile').onclick = () => switchView('profile');
    document.getElementById('start-game-btn').onclick = () => startClassMinigame();
    document.getElementById('close-mg-btn').onclick = () => exitMinigame(false);
    
    refreshHUD();
}

export function refreshHUD() {
    document.getElementById('hud-energy-val').innerText = playerState.energy;
    document.getElementById('hud-credits-val').innerText = playerState.credits;
    document.getElementById('dossier-rank-lbl').innerText = `${playerState.rank} Ранг`;
    document.getElementById('minigame-lv-indicator').innerText = playerState.currentLevel;
    
    let nextXp = playerState.rank * 200;
    let pct = (playerState.xp / nextXp) * 100;
    document.getElementById('dossier-xp-fill').style.width = `${pct}%`;
    document.getElementById('dossier-xp-text').innerText = `${playerState.xp} / ${nextXp} XP`;
}

function switchView(viewId) {
    document.querySelectorAll('.view-container').forEach(v => v.classList.remove('view-active'));
    document.querySelectorAll('.nav-tab').forEach(t => t.classList.remove('active'));
    document.getElementById(`view-${viewId}`).classList.add('view-active');
    document.getElementById(`tab-${viewId}`).classList.add('active');
}

let activeModule = null;

async function startClassMinigame() {
    const arena = document.getElementById('view-arena');
    const overlay = document.getElementById('minigame-overlay-layer');
    
    if(navigator.vibrate) navigator.vibrate(40);
    arena.classList.add('vortex-suck');
    
    try {
        activeModule = await import(`./games/${playerState.classData.id}.js`);
        executeGameLaunch(arena, overlay);
    } catch (err) {
        activeModule = await import('./games/universal.js');
        executeGameLaunch(arena, overlay);
    }
}

function executeGameLaunch(arena, overlay) {
    setTimeout(() => {
        arena.classList.remove('view-active', 'vortex-suck');
        document.getElementById('mg-title-lbl').innerText = playerState.classData.game;
        document.getElementById('mg-subtitle-lbl').innerText = `Уровень ${playerState.currentLevel} из 100`;
        
        const viewport = document.getElementById('mg-render-viewport');
        viewport.querySelectorAll(':not(#mg-success-screen)').forEach(el => el.remove());
        
        activeModule.initGame(viewport, playerState.currentLevel, finishStageCallback);
        
        overlay.style.display = 'flex';
        overlay.classList.add('vortex-spit');
        setTimeout(() => overlay.classList.remove('vortex-spit'), 550);
    }, 500);
}

function finishStageCallback() {
    if(navigator.vibrate) navigator.vibrate(40);
    document.getElementById('mg-success-screen').style.display = 'flex';
    
    setTimeout(() => {
        document.getElementById('mg-success-screen').style.display = 'none';
        playerState.currentLevel++;
        exitMinigame(true);
    }, 1200);
}

function exitMinigame(success) {
    if(activeModule && activeModule.destroy) activeModule.destroy();
    
    const arena = document.getElementById('view-arena');
    const overlay = document.getElementById('minigame-overlay-layer');
    
    overlay.classList.add('vortex-suck');
    setTimeout(() => {
        overlay.style.display = 'none';
        overlay.classList.remove('vortex-suck');
        arena.classList.add('view-active', 'vortex-spit');
        
        if (success) {
            document.getElementById('active-case-clue').style.display = 'block';
            document.getElementById('active-case-clue').innerText = `Экспертиза успешно завершена. Получены новые зацепки для анализа дела.`;
            document.getElementById('game-trigger-footer').style.display = 'none';
            syncProgressWithServer(); // Отправляем прогресс уровня на бэкенд
        }
        setTimeout(() => arena.classList.remove('vortex-spit'), 550);
        refreshHUD();
    }, 500);
}

// --- СВАЙПЫ КАРТОЧЕК ---
const card = document.getElementById('active-case-card');
let startX = 0, diffX = 0, dragActive = false;

card.addEventListener('touchstart', (e) => { dragActive = true; startX = e.touches[0].clientX; card.style.transition = 'none'; });
card.addEventListener('touchmove', (e) => {
    if(!dragActive) return;
    diffX = e.touches[0].clientX - startX;
    card.style.transform = `translate(${diffX}px, ${Math.abs(diffX)/15}px) rotate(${diffX/25}deg)`;
    if(diffX > 50) { document.getElementById('tag-r').style.opacity = Math.min(diffX/100, 1); document.getElementById('tag-l').style.opacity = 0; }
    else if(diffX < -50) { document.getElementById('tag-l').style.opacity = Math.min(Math.abs(diffX)/100, 1); document.getElementById('tag-r').style.opacity = 0; }
});
card.addEventListener('touchend', () => {
    if(!dragActive) return; dragActive = false;
    if(Math.abs(diffX) > window.innerWidth * 0.35) {
        if(navigator.vibrate) navigator.vibrate(30);
        
        // НАЧИСЛЕНИЕ НАГРАД ЗА СВАЙП
        playerState.xp += 50; 
        playerState.credits += 10;
        
        // Проверка на повышение Ранга
        let nextXp = playerState.rank * 200;
        if (playerState.xp >= nextXp) {
            playerState.xp -= nextXp;
            playerState.rank++;
        }

        card.style.transition = 'transform 0.3s ease-out, opacity 0.2s';
        card.style.transform = `translate(${diffX > 0 ? 150 : -150}%, 40px) rotate(${diffX > 0 ? 20 : -20}deg)`;
        card.style.opacity = '0';
        
        // СИНХРОНИЗАЦИЯ ПОСЛЕ СВАЙПА
        syncProgressWithServer();

        setTimeout(() => {
            document.getElementById('active-case-clue').style.display = 'none';
            document.getElementById('game-trigger-footer').style.display = 'block';
            card.style.transition = 'none'; card.style.transform = 'scale(0.9) translateY(-30px)';
            
            // ЗАГРУЗКА СЛЕДУЮЩЕЙ КАРТОЧКИ ИЗ ИИ
            loadNewAiCase().then(() => {
                setTimeout(() => { 
                    card.style.transition = 'transform 0.4s cubic-bezier(0.22, 1, 0.36, 1), opacity 0.4s'; 
                    card.style.transform = 'scale(1) translateY(0)'; 
                    card.style.opacity = '1'; 
                    refreshHUD(); 
                }, 30);
            });
        }, 350);
    } else {
        card.style.transition = 'transform 0.4s cubic-bezier(0.22, 1, 0.36, 1)'; card.style.transform = 'translate(0,0) rotate(0deg)';
        document.getElementById('tag-l').style.opacity = 0; document.getElementById('tag-r').style.opacity = 0;
    }
    diffX = 0;
});
