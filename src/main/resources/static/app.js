const tg = window.Telegram && window.Telegram.WebApp ? window.Telegram.WebApp : null;
let currentUser = null;
let currentCase = null;

const card = document.getElementById('main-card');
let startX = 0, currentX = 0, isDragging = false;

document.addEventListener('DOMContentLoaded', () => {
    if (tg) { try { tg.expand(); tg.ready(); } catch(e) {} }
    
    setTimeout(() => {
        if (tg && tg.initData && tg.initData.length > 0) {
            // Прячем логин, так как мы внутри ТГ и будем логиниться тихо
            document.getElementById('login-screen').classList.add('hidden');
            authWebApp();
        } else {
            // Если в браузере, убираем Splash — под ним уже готовый отрисованный логин с кнопкой!
            document.getElementById('splash-screen').style.opacity = '0';
            setTimeout(() => {
                document.getElementById('splash-screen').classList.add('hidden');
            }, 400);
        }
    }, 1000);
});

function switchTab(tabId, btnElement) {
    document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
    document.getElementById('tab-' + tabId).classList.remove('hidden');
    
    document.querySelectorAll('.nav-item').forEach(btn => btn.classList.remove('active'));
    btnElement.classList.add('active');
}
window.switchTab = switchTab;

function authWebApp() {
    fetch('/api/game/auth/webapp', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ initData: tg.initData, initDataUnsafe: tg.initDataUnsafe })
    })
    .then(res => { if(!res.ok) throw new Error(); return res.json(); })
    .then(loginSuccess).catch(() => alert("Ошибка WebApp. Проверьте токен."));
}

function onTelegramAuth(user) {
    document.getElementById('login-screen').classList.add('hidden');
    document.getElementById('splash-screen').classList.remove('hidden');
    document.getElementById('splash-screen').style.opacity = '1';
    
    fetch('/api/game/auth/widget', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(user)
    })
    .then(res => { if(!res.ok) throw new Error(); return res.json(); })
    .then(loginSuccess).catch(() => { alert("Ошибка виджета."); location.reload(); });
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
    
    const xpNeeded = p.rank * 150;
    document.getElementById('hud-xp').innerText = `${p.xp} / ${xpNeeded}`;
    document.getElementById('xp-bar').style.width = `${(p.xp / xpNeeded) * 100}%`;
    
    document.getElementById('lvl-skill1').innerText = `Lv.${p.skill1} (${p.skill1 * 50}🪙)`;
    document.getElementById('lvl-skill2').innerText = `Lv.${p.skill2} (${p.skill2 * 50}🪙)`;
}

function loadCase() {
    document.getElementById('case-description').innerText = "Анализ данных...";
    document.getElementById('hint-text').innerText = "";
    card.style.transform = 'none';

    fetch(`/api/game/case?providerId=${encodeURIComponent(currentUser.providerId)}&t=${Date.now()}`)
    .then(res => res.text())
    .then(text => {
        try {
            let data = JSON.parse(text);
            if (typeof data === 'string') data = JSON.parse(data);
            currentCase = data;
            document.getElementById('case-description').innerText = currentCase.text;
        } catch(e) {
            console.error("JSON Error:", e);
            currentCase = { leftOption: "Влево", rightOption: "Вправо", leftResult: "Свайп влево.", rightResult: "Свайп вправо." };
            document.getElementById('case-description').innerText = text;
        }
    }).catch(() => document.getElementById('case-description').innerText = "Ошибка ИИ.");
}

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
        
        card.style.transform = `translateX(${diffX}px) rotate(${diffX / 20}deg)`;

        const hint = document.getElementById('hint-text');
        if (diffX < -50) {
            hint.innerText = "← " + (currentCase.leftOption || "ВЛЕВО");
            hint.style.color = "var(--danger)";
        } else if (diffX > 50) {
            hint.innerText = (currentCase.rightOption || "ВПРАВО") + " →";
            hint.style.color = "var(--accent)";
        } else {
            hint.innerText = "";
        }
    };

    const endDrag = () => {
        if (!isDragging) return;
        isDragging = false;
        const diffX = currentX - startX;

        if (diffX < -120) {
            card.style.transition = 'transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
            card.style.transform = `translateX(-500px) rotate(-30deg)`;
            setTimeout(() => submitChoice('left'), 300);
        } else if (diffX > 120) {
            card.style.transition = 'transform 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
            card.style.transform = `translateX(500px) rotate(30deg)`;
            setTimeout(() => submitChoice('right'), 300);
        } else {
            card.style.transition = 'transform 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
            card.style.transform = 'translate(0px, 0px) rotate(0deg)';
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
        
        const mgBtn = document.getElementById('minigame-trigger');
        if (Math.random() < 0.2) {
            mgBtn.classList.remove('hidden');
        } else {
            mgBtn.classList.add('hidden');
        }
    })
    .catch(() => {
        card.style.transition = 'transform 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275)';
        card.style.transform = 'translate(0px, 0px) rotate(0deg)';
        document.getElementById('hint-text').innerText = "";
    });
}

function nextCase() {
    document.getElementById('result-overlay').classList.add('hidden');
    loadCase();
}
window.nextCase = nextCase;

function startMinigame(title) {
    document.getElementById('mg-title').innerText = title;
    const overlay = document.getElementById('minigame-overlay');
    overlay.classList.remove('hidden', 'vortex-exit');
    overlay.classList.add('vortex-enter');
}
window.startMinigame = startMinigame;

function closeMinigame(success) {
    const overlay = document.getElementById('minigame-overlay');
    overlay.classList.remove('vortex-enter');
    overlay.classList.add('vortex-exit');
    
    if(success) {
        alert("Взлом успешен! Вы получили бонус.");
        currentUser.credits += 25;
        updateHUD(currentUser);
    }
    
    setTimeout(() => {
        overlay.classList.add('hidden');
        nextCase();
    }, 400);
}
window.closeMinigame = closeMinigame;

function upgradeSkill(skillNum) {
    fetch(`/api/game/upgrade-skill?providerId=${encodeURIComponent(currentUser.providerId)}&skillNum=${skillNum}`, { method: 'POST' })
    .then(res => {
        if(!res.ok) return res.text().then(t => { alert(t); throw new Error(); });
        return res.json();
    })
    .then(p => { currentUser = p; updateHUD(p); }).catch(() => {});
}
window.upgradeSkill = upgradeSkill;

function buyCoffee() {
    fetch(`/api/game/buy-coffee?providerId=${encodeURIComponent(currentUser.providerId)}`, { method: 'POST' })
    .then(res => {
        if(!res.ok) return res.text().then(t => { alert(t); throw new Error(); });
        return res.json();
    })
    .then(p => { currentUser = p; updateHUD(p); }).catch(() => {});
}
window.buyCoffee = buyCoffee;
