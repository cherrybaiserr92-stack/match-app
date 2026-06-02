const cases = [
    { id: "1", type: "RED_FLAG", typeLabel: "Красный флаг", author: "🦊 Лиса_8", title: "Раздельный счет", text: "На первом свидании парень попросил разделить счет пополам, хотя сам позвал меня в дорогой ресторан. Это норма?", comments: [ {a: "Мудрец_22", e: "🦉", t: "Абсолютно поддерживаю автора. Никто не обязан терпеть подобное."}, {a: "Токсик_99", e: "🐍", t: "Сами виноваты, нужно было сразу расставлять границы."} ], isHot: true, isTurbo: true, lblL: "БЕГИ", lblR: "НОРМА" },
    { id: "2", type: "CONFESSION", typeLabel: "Исповедь", author: "☕ Бариста_Анон", title: "Кофе без кофеина", text: "Я работаю баристой и тайно наливаю обычный кофе клиентам, которые просят декаф и при этом грубят мне.", comments: [ {a: "Кофеман", e: "☕", t: "А если у человека проблемы с сердцем? Это подсудное дело!"} ], isHot: false, isTurbo: false, lblL: "ОСУДИТЬ", lblR: "ОПРАВДАТЬ" },
    { id: "3", type: "HOT_TAKE", typeLabel: "Мнение", author: "⚡ Зевс_1", title: "Голосовые сообщения", text: "Люди, которые отправляют голосовые сообщения длиннее 1 минуты без спроса, не уважают чужое время.", comments: [], isHot: true, isTurbo: false, lblL: "БРЕД", lblR: "БАЗА" }
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
    
    const targetNav = document.getElementById('nav-' + tab);
    const targetView = document.getElementById('view-' + tab);
    
    if(targetNav) targetNav.classList.add('active');
    if(targetView) targetView.classList.add('view-active');
    
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
    if(card) {
        card.style.transform = 'translate(0px, 0px) rotate(0deg)'; 
        card.style.opacity = '1';
    }
    document.getElementById('results-area').style.display = 'none';
    
    document.getElementById('card-author').innerText = item.author;
    document.getElementById('card-banner').innerText = item.typeLabel;
    document.getElementById('card-text').innerText = item.text;
    document.getElementById('ind-left').innerText = item.lblL;
    document.getElementById('ind-right').innerText = item.lblR;
}

function closeArena() { switchTab('feed'); }
function closeArenaState() { 
    document.getElementById('header-title').innerText = "Сдвиг"; 
    document.getElementById('btn-back').style.display = 'none'; 
}

// --- ФИЗИКА СВАЙПОВ ---
const card = document.getElementById('current-card');
let startX = 0, distanceX = 0, isDragging = false;

if(card) {
    card.addEventListener('touchstart', (e) => {
        if(document.getElementById('results-area').style.display === 'flex') return;
        isDragging = true; card.classList.add('dragging'); startX = e.touches[0].clientX;
    });
    card.addEventListener('touchmove', (e) => {
        if (!isDragging) return;
        distanceX = e.touches[0].clientX - startX;
        card.style.transform = `translate(${distanceX}px, ${Math.abs(distanceX)/12}px) rotate(${distanceX/24}deg)`;
        if(distanceX > 40) { 
            document.getElementById('ind-right').style.opacity = Math.min(distanceX/100, 1); 
            document.getElementById('ind-left').style.opacity = 0; 
        } else if (distanceX < -40) { 
            document.getElementById('ind-left').style.opacity = Math.min(Math.abs(distanceX)/100, 1); 
            document.getElementById('ind-right').style.opacity = 0; 
        } else { 
            document.getElementById('ind-left').style.opacity = 0; 
            document.getElementById('ind-right').style.opacity = 0; 
        }
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
}

function executeVote(dir) {
    if(navigator.vibrate) navigator.vibrate(30);
    const item = cases[activeCaseIndex];
    document.getElementById('lbl-res-left').innerText = item.lblL;
    document.getElementById('lbl-res-right').innerText = item.lblR;

    card.style.transition = 'transform 0.3s cubic-bezier(0.2, 0.8, 0.2, 1), opacity 0.25s';
    card.style.transform = `scale(0.85) translateY(-30px)`; card.style.opacity = '0';

    setTimeout(() => {
        const commentsBlock = document.getElementById('card-comments-block');
        commentsBlock.innerHTML = `<div style="font-size:16px; font-weight:700; margin-bottom:16px;">Обсуждение (${item.comments.length})</div>`;
        if(item.comments.length === 0) commentsBlock.innerHTML += `<div style="color:var(--text-secondary); font-size:14px;">Здесь пока тихо. Напишите первый комментарий!</div>`;
        item.comments.forEach(c => {
            commentsBlock.innerHTML += `
                <div class="comment">
                    <div class="comment-avatar">${c.e}</div>
                    <div class="comment-body"><div class="comment-author">${c.a}</div>${c.t}</div>
                </div>
            `;
        });
        commentsBlock.innerHTML += `<button class="action-btn" style="margin-top:20px;" onclick="nextCard()">Следующий прецедент</button>`;

        document.getElementById('results-area').style.display = 'flex';
        card.style.transform = 'scale(1) translateY(0)'; card.style.opacity = '1';
        
        setTimeout(() => {
            let r = Math.floor(Math.random() * 50) + 25;
            document.getElementById('bar-left').style.width = r + '%'; document.getElementById('lbl-left').innerText = r + '%';
            document.getElementById('bar-right').style.width = (100-r) + '%'; document.getElementById('lbl-right').innerText = (100-r) + '%';
        }, 50);
    }, 300);
}

function nextCard() {
    activeCaseIndex = (activeCaseIndex + 1) % cases.length;
    openArena(activeCaseIndex, openedFromFeed);
}

function submitCase() {
    const text = document.getElementById('new-case-text').value;
    const isBoosted = document.getElementById('boost-check').checked;
    if(text.length < 10) { alert('Опишите ситуацию немного подробнее!'); return; }
    
    if (isBoosted) {
        let currentSparks = parseInt(document.getElementById('user-sparks').innerText);
        if (currentSparks < 10) { alert('Недостаточно Искр для Сверхрезонанса!'); return; }
        document.getElementById('user-sparks').innerText = currentSparks - 10;
    }

    cases.unshift({
        id: String(cases.length + 1), type: "CONFESSION", typeLabel: "Исповедь",
        author: "🦊 Лиса_8", title: text.substring(0, 20) + "...", text: text,
        comments: [], isHot: false, isTurbo: isBoosted, lblL: "ОСУДИТЬ", lblR: "ОПРАВДАТЬ"
    });
    
    document.getElementById('new-case-text').value = '';
    document.getElementById('boost-check').checked = false;
    renderFeed(); switchTab('feed');
}

function buySparks() {
    let current = parseInt(document.getElementById('user-sparks').innerText);
    document.getElementById('user-sparks').innerText = current + 50;
    alert('Тестовая покупка: добавлено +50 Искр 💎');
}

// Инициализация при загрузке скрипта
renderFeed();
