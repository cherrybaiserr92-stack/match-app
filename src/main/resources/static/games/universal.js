// Универсальный модуль: Экспертиза шифра (Математическая дедукция)
export function initGame(viewport, level, onWin) {
    viewport.style.flexDirection = 'column';
    
    const container = document.createElement('div');
    container.style.padding = '15px';
    container.style.textAlign = 'center';
    
    // 100 уровней масштабирования суммы улик
    let targetSum = 10 + (level * 4) + Math.floor(Math.random() * 5);
    
    container.innerHTML = `
        <div style="font-size:12px; color:var(--text-muted); text-transform:uppercase;">Необходимый вес улик:</div>
        <div style="font-size:36px; font-weight:800; color:#fff; margin:6px 0;">${targetSum}</div>
    `;
    viewport.appendChild(container);
    
    const grid = document.createElement('div');
    grid.className = 'grid-4x4';
    
    let currentSum = 0;
    // Количество ячеек растет с уровнем
    let cellsCount = level <= 10 ? 6 : (level <= 40 ? 8 : 12);
    
    for(let i=0; i < cellsCount; i++) {
        let val = Math.floor(Math.random() * (5 + Math.floor(level/2))) + 2;
        const cell = document.createElement('div');
        cell.className = 'grid-cell';
        cell.innerText = val;
        
        cell.onclick = () => {
            if (cell.classList.contains('selected')) {
                cell.classList.remove('selected');
                currentSum -= val;
            } else {
                cell.classList.add('selected');
                currentSum += val;
                
                if (currentSum === targetSum) {
                    onWin();
                } else if (currentSum > targetSum) {
                    if(navigator.vibrate) navigator.vibrate(60);
                    currentSum = 0;
                    grid.querySelectorAll('.grid-cell').forEach(c => c.classList.remove('selected'));
                }
            }
        };
        grid.appendChild(cell);
    }
    viewport.appendChild(grid);
}

export function destroy() {}
