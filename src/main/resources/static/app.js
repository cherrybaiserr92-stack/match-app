// Глобальные переменные пользователя
let userSparks = 42;
let aiDetectedCount = 0;

// Добавили флаг isAI в карточки. 4-я карточка сгенерирована ИИ!
const cases = [
    { id: "1", type: "RED_FLAG", typeLabel: "Красный флаг", author: "🦊 Лиса_8", title: "Раздельный счет", text: "На первом свидании парень попросил разделить счет пополам, хотя сам позвал меня в дорогой ресторан. Это норма?", comments: [ {a: "Мудрец_22", e: "🦉", t: "Абсолютно поддерживаю автора. Никто не обязан терпеть подобное."} ], isHot: true, isTurbo: true, lblL: "БЕГИ", lblR: "НОРМА", isAI: false },
    { id: "2", type: "CONFESSION", typeLabel: "Исповедь", author: "☕ Бариста_Анон", title: "Кофе без кофеина", text: "Я работаю баристой и тайно наливаю обычный кофе клиентам, которые просят декаф и при этом грубят мне.", comments: [ {a: "Кофеман", e: "☕", t: "А если у человека проблемы с сердцем? Это подсудное дело!"} ], isHot: false, isTurbo: false, lblL: "ОСУДИТЬ", lblR: "ОПРАВДАТЬ", isAI: false },
    { id: "3", type: "HOT_TAKE", typeLabel: "Мнение", author: "⚡ Зевс_1", title: "Голосовые сообщения", text: "Люди, которые отправляют голосовые сообщения длиннее 1 минуты без спроса, не уважают чужое время.", comments: [], isHot: true, isTurbo: false, lblL: "БРЕД", lblR: "БАЗА", isAI: false },
    { id: "4", type: "CONFESSION", typeLabel: "Исповедь", author: "🎭 Аноним", title: "Премия за ошибку", text: "Случайно удалил важную базу данных на работе. Испугался и сказал, что это хакерская атака. Руководство поверило, наняло отдел безопасности, а мне выписали премию за 'быстрое реагирование'. Совесть мучает, но деньги уже потратил.", comments: [ {a: "DevOps_Guru", e: "💻", t: "Жесть. Надеюсь мы не в одной компании работаем."} ], isHot: true, isTurbo: false, lblL: "ОСУДИТЬ", lblR: "ОПРАВДАТЬ", isAI: true }
];

let activeCaseIndex = 0;
let openedFromFeed = false;

function renderFeed() {
    const feed = document.getElementById('view-feed'); 
    if(!feed) return;
    feed.innerHTML = '';
    cases.forEach((item, index) => {
        feed.innerHTML += `
            <div class="feed-item" onclick="openArena(${index}, true)">
                <div class="feed-header">
                    <div class="feed-author"><div class="author-avatar">${item.author.charAt(0)}</div> ${item.author.substring(2)}</div>
                    <div class="feed-tags">
                        ${item.isTurbo ? '<div class="tag tag-turbo">⚡ Буст</div>' : ''}
                        ${item.isHot ? '<div class="tag tag-hot">Резонанс</div>' : ''}
                        <div class="tag tag-type">${item.typeLabel}</div>
                    </div>
                </div>
                <h3 class="feed-title">${item.title}</h3>
                <div class="feed-preview">${item.text}</div>
                <div class="feed-footer">
                    <div class="feed-stats"><span>💬 ${item.comments.length}</span><span>⚖️ Сдвинуть</span></div>
                    <span>❯</span>
                </div>
            </div>
        `;
    });
}

function switchTab(tab) {
    document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
    document.querySelectorAll('.view-container').forEach(v => v.classList.remove('view-active'));
    document.getElementById('nav-' + tab).classList.add('active');
    document.getElementById('view-' + tab).classList.add('view-active');
    if(tab !== 'arena') closeArenaState();
}

function openArenaFromNav() { openArena(activeCaseIndex, false); }

function openArena(index, fromFeed) {
    activeCaseIndex = index; openedFromFeed = fromFeed;
    const item = cases[index];
    switchTab('arena');
    if (fromFeed) {
        document.getElementById('header-title').innerText = item.title;
        document.getElementById('btn-back').style.display = 'block';
    }

    const card = document.getElementById('current-card');
    card.style.transform = 'translate(0px, 0px) rotate(0deg)'; card.style.opacity = '1';
    document.getElementById('results-area').style.display = 'none';
    
    document.getElementById('card-author').innerText = item.author;
    document.getElementById('card-banner').innerText = item.typeLabel;
    document.getElementById('card-text').innerText = item.text;
    document.getElementById('ind-left').innerText = item.lblL;
    document.getElementById('ind-right').innerText = item.lblR;
}

function closeArena() { switchTab('feed'); }
function closeArenaState() { document.getElementById('header-title').innerText = "Сдвиг"; document.getElementById('btn-back').style.display = 'none'; }

// ФИЗИКА СВАЙПОВ
const card = document.getElementById('current-card');
let startX = 0, distanceX = 0, isDragging = false;

card.addEventListener('touchstart', (e) => {
    if(document.getElementById('results-area').style.display === 'flex') return;
    isDragging = true; card.classList.add('dragging'); startX = e.touches[0].clientX;
});
card.addEventListener('touchmove', (e) => {
    if (!isDragging) return;
    distanceX = e.touches[0].clientX - startX;
    card.style.transform = `translate(${distanceX}px, ${Math.abs(distanceX)/12}px) rotate(${distanceX/24}deg)`;
    if(distanceX > 40) { document.getElementById('ind-right').style.opacity = Math.min(distanceX/100, 1); document.getElementById('ind-left').style.opacity = 0; }
    else if (distanceX < -40) { document.getElementById('ind-left').style.opacity = Math.min(Math.abs(distanceX)/100, 1); document.getElementById('ind-right').style.opacity = 0; }
    else { document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0; }
});
card.addEventListener('touchend', () => {
    if (!isDragging) return; isDragging = false; card.classList.remove('dragging');
    if (distanceX > window.innerWidth * 0.33) executeVote('right');
    else if (distanceX < -window.innerWidth * 0.33) executeVote('left');
    else {
        card.style.transition = 'transform 0.25s ease'; card.style.transform = 'translate(0px, 0px) rotate(0deg)';
        document.getElementById('ind-left').style.opacity = 0; document.getElementById('ind-right').style.opacity = 0;
        setTimeout(() => card.style.transition = '', 250);
    }
    distanceX = 0;
});

function executeVote(dir) {
    if(navigator.vibrate) navigator.vibrate(30);
    const item = cases[activeCaseIndex];
    document.getElementById('lbl-res-left').innerText = item.lblL;
    document.getElementById('lbl-res-right').innerText = item.lblR;

    card.style.transition = 'transform 0.3s cubic-bezier(0.2, 0.8, 0.2, 1), opacity 0.25s';
    card.style.transform = `scale(0.85) translateY(-30px)`; card.style.opacity = '0';

    setTimeout(() => {
        // 1. Рендерим мини-игру
        const minigameWrapper = document.getElementById('minigame-wrapper');
        minigameWrapper.innerHTML = `
            <div class="minigame-container">
                <div class="minigame-block">
                    <div class="minigame-title">🤖 Тест Тьюринга</div>
                    <div style="font-size: 12px; color: var(--text-secondary);">Кто написал эту ситуацию?</div>
                    <div class="minigame-buttons" id="minigame-btns">
                        <button class="minigame-btn" onclick="guessAuthor(false)">👤 Человек</button>
                        <button class="minigame-btn" onclick="guessAuthor(true)">🤖 Нейросеть</button>
                    </div>
                    <div class="minigame-result" id="minigame-result"></div>
                </div>
            </div>
        `;

        // 2. Рендерим комментарии
        const commentsBlock = document.getElementById('card-comments-block');
        commentsBlock.innerHTML = `<div style="font-size:16px; font-weight:700; margin-bottom:16px;">Обсуждение (${item.comments.length})</div>`;
        if(item.comments.length === 0) commentsBlock.innerHTML += `<div style="color:var(--text-secondary); font-size:14px;">Здесь пока тихо. Напишите первый комментарий!</div>`;
        item.comments.forEach(c => {
            commentsBlock.innerHTML += `
                <div class="comment"><div class="comment-avatar">${c.e}</div><div class="comment-body"><div class="comment-author">${c.a}</div>${c.t}</div></div>
            `;
        });
        commentsBlock.innerHTML += `<button class="action-btn" style="margin-top:20px;" onclick="nextCard()">Следующий прецедент</button>`;

        // 3. Показываем результат
        document.getElementById('results-area').style.display = 'flex';
        card.style.transform = 'scale(1) translateY(0)'; card.style.opacity = '1';
        
        setTimeout(() => {
            let r = Math.floor(Math.random() * 50) + 25;
            document.getElementById('bar-left').style.width = r + '%'; document.getElementById('lbl-left').innerText = r + '%';
            document.getElementById('bar-right').style.width = (100-r) + '%'; document.getElementById('lbl-right').innerText = (100-r) + '%';
        }, 50);
    }, 300);
}

// --- ЛОГИКА МИНИ-ИГРЫ ---
function guessAuthor(guessIsAI) {
    const item = cases[activeCaseIndex];
    const resultDiv = document.getElementById('minigame-result');
    document.getElementById('minigame-btns').style.display = 'none';

    if (guessIsAI === item.isAI) {
        resultDiv.className = 'minigame-result success';
        resultDiv.innerHTML = `🎯 <b>В точку!</b><br>Это ${item.isAI ? 'сгенерировал ИИ' : 'написал реальный человек'}.<br><span style="color:#FFF; display:inline-block; margin-top:6px;">+5 Искр 💎</span>`;
        updateSparks(5);
        if (item.isAI) {
            aiDetectedCount++;
            document.getElementById('stat-ai').innerText = aiDetectedCount;
        }
    } else {
        resultDiv.className = 'minigame-result error';
        resultDiv.innerHTML = `❌ <b>Интуиция подвела</b><br>На самом деле это ${item.isAI ? 'сгенерировал ИИ' : 'написал человек'}.`;
    }
}

function updateSparks(amount) {
    userSparks += amount;
    const badge = document.getElementById('spark-badge');
    document.getElementById('user-sparks').innerText = userSparks;
    badge.classList.add('bump');
    setTimeout(() => badge.classList.remove('bump'), 300);
}

function nextCard() {
    activeCaseIndex = (activeCaseIndex + 1) % cases.length;
    openArena(activeCaseIndex, openedFromFeed);
}

function submitCase() {
    const text = document.getElementById('new-case-text').value;
    const isBoosted = document.getElementById('boost-check').checked;
    if(text.length < 10) { alert('Опишите ситуацию подробнее!'); return; }
    
    if (isBoosted) {
        if (userSparks < 10) { alert('Недостаточно Искр для Сверхрезонанса!'); return; }
        updateSparks(-10);
    }

    cases.unshift({ id: String(cases.length + 1), type: "CONFESSION", typeLabel: "Исповедь", author: "🦊 Лиса_8", title: text.substring(0, 20) + "...", text: text, comments: [], isHot: false, isTurbo: isBoosted, lblL: "ОСУДИТЬ", lblR: "ОПРАВДАТЬ", isAI: false });
    document.getElementById('new-case-text').value = ''; document.getElementById('boost-check').checked = false;
    renderFeed(); switchTab('feed');
}

function buySparks() { updateSparks(50); alert('Тестовая покупка: добавлено +50 Искр 💎'); }

renderFeed();
