// Игра класса Детектив: Мемори-анализ доказательств
export function initGame(viewport, level, onWin) {
    viewport.style.flexDirection = 'column';
    
    // Алгоритм расчета сетки для 100 уровней
    let totalCards;
    if (level <= 5) totalCards = 4;        // Сетка 2x2
    else if (level <= 25) totalCards = 8;   // Сетка 4x2
    else if (level <= 60) totalCards = 12;  // Сетка 4x3
    else if (level <= 85) totalCards = 16;  // Сетка 4x4
    else totalCards = 20;                   // Премиум сложность 5x4

    const iconsPool = ['🔍', '📁', '💼', '🗝️', '📜', '🩸', '🚬', '🕶️', '🪙', '📸'];
    let selectedIcons = iconsPool.slice(0, totalCards / 2);
    let deck = [...selectedIcons, ...selectedIcons].sort(() => Math.random() - 0.5);
    
    const grid = document.createElement('div');
    grid.className = 'grid-4x4';
    
    // Подстройка CSS сетки под размер
    if(totalCards > 12) grid.style.gridTemplateColumns = 'repeat(4, 1fr)';
    else if (totalCards === 4) grid.style.gridTemplateColumns = 'repeat(2, 1fr)';
    
    let activeSelection = [];
    let remainingPairs = totalCards / 2;

    deck.forEach(icon => {
        const cell = document.createElement('div');
        cell.className = 'grid-cell';
        cell.dataset.icon = icon;
        
        // AAA механика: На уровнях до 40 показываем карты на пару секунд на старте
        let previewTime = Math.max(300, 2000 - (level * 25)); // Чем выше уровень, тем меньше времени на запоминание
        cell.innerText = icon;
        setTimeout(() => { cell.innerText = '❓'; }, previewTime);

        cell.onclick = () => {
            if (cell.innerText !== '❓' || activeSelection.length >= 2) return;
            
            cell.innerText = icon;
            cell.classList.add('selected');
            activeSelection.push(cell);

            if (activeSelection.length === 2) {
                if (activeSelection[0].dataset.icon === activeSelection[1].dataset.icon) {
                    activeSelection = [];
                    remainingPairs--;
                    if (remainingPairs === 0) onWin();
                } else {
                    // На уровнях 50+ штраф по времени на закрытие карт жестче
                    let closeDelay = Math.max(250, 600 - (level * 4));
                    setTimeout(() => {
                        activeSelection.forEach(c => { c.innerText = '❓'; c.classList.remove('selected'); });
                        activeSelection = [];
                    }, closeDelay);
                }
            }
        };
        grid.appendChild(cell);
    });
    
    viewport.appendChild(grid);
}

export function destroy() {
    // Чистка памяти при выходе
}
