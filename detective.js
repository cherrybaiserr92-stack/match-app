// Игра "Планета самоцветов" — Match-3 с динамическими заданиями
export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    viewport.style.display = 'flex';
    viewport.style.flexDirection = 'column';
    viewport.style.alignItems = 'center';
    viewport.style.justifyContent = 'center';
    viewport.style.fontFamily = 'Arial, sans-serif';

    // ---------- Конфигурация поля ----------
    const ROWS = 9;
    const COLS = 9;
    const COLORS = ['red', 'blue', 'green', 'yellow', 'purple', 'orange'];

    // ---------- Система заданий ----------
    function getMissionForLevel(lvl) {
        if (lvl <= 5) {
            return { type: 'collect', color: 'blue', target: 10 + lvl };
        } else if (lvl <= 10) {
            return { type: 'collect', color: 'green', target: 15 + (lvl-5)*2 };
        } else if (lvl <= 15) {
            return { type: 'collect', color: 'purple', target: 20 + (lvl-10)*3 };
        } else if (lvl <= 20) {
            return { type: 'clear_ice', target: 5 + (lvl-15) };
        } else {
            return { type: 'mixed', color: 'blue', targetCollect: 20 + (lvl-20)*2, targetIce: 8 + Math.floor((lvl-20)/2) };
        }
    }

    const mission = getMissionForLevel(level);
    let requiredColor = mission.color || null;
    let requiredCollect = mission.target || mission.targetCollect || 0;
    let requiredIce = mission.targetIce || 0;
    let isMixed = mission.type === 'mixed';

    // ---------- Состояние игры ----------
    let board = Array(ROWS).fill().map(() => Array(COLS).fill(null));
    let iceLayer = Array(ROWS).fill().map(() => Array(COLS).fill(0));
    let collected = 0;
    let iceCleared = 0;
    let selectedRow = null, selectedCol = null;
    let gameActive = true;
    let processing = false;

    // ---------- DOM элементы ----------
    const panel = document.createElement('div');
    panel.style.marginBottom = '15px';
    panel.style.padding = '10px';
    panel.style.backgroundColor = '#2c3e2b';
    panel.style.borderRadius = '20px';
    panel.style.color = '#f0e6a0';
    panel.style.textAlign = 'center';
    panel.style.width = '100%';

    const levelInfo = document.createElement('div');
    levelInfo.textContent = `🔮 Уровень ${level}`;
    const missionInfo = document.createElement('div');
    updateMissionText();
    panel.appendChild(levelInfo);
    panel.appendChild(missionInfo);
    viewport.appendChild(panel);

    const grid = document.createElement('div');
    grid.style.display = 'grid';
    grid.style.gridTemplateColumns = `repeat(${COLS}, 60px)`;
    grid.style.gap = '4px';
    grid.style.backgroundColor = '#4a5b3e';
    grid.style.padding = '12px';
    grid.style.borderRadius = '20px';
    grid.style.border = '3px solid #d4af37';
    viewport.appendChild(grid);

    const cells = Array(ROWS).fill().map(() => Array(COLS).fill(null));

    function updateMissionText() {
        if (mission.type === 'collect') {
            missionInfo.innerHTML = `🎯 Собери ${requiredColor.toUpperCase()} самоцветы: ${collected} / ${requiredCollect}`;
        } else if (mission.type === 'clear_ice') {
            missionInfo.innerHTML = `❄️ Разморозь клетки: ${iceCleared} / ${requiredIce}`;
        } else if (mission.type === 'mixed') {
            missionInfo.innerHTML = `🎯 ${requiredColor.toUpperCase()}: ${collected}/${requiredCollect} &nbsp;&nbsp; ❄️ Лёд: ${iceCleared}/${requiredIce}`;
        }
    }

    function checkVictory() {
        let completed = false;
        if (mission.type === 'collect') completed = (collected >= requiredCollect);
        else if (mission.type === 'clear_ice') completed = (iceCleared >= requiredIce);
        else if (mission.type === 'mixed') completed = (collected >= requiredCollect && iceCleared >= requiredIce);

        if (completed && gameActive) {
            gameActive = false;
            onWin();
            const winMsg = document.createElement('div');
            winMsg.textContent = '✨ Победа! Уровень пройден ✨';
            winMsg.style.marginTop = '15px';
            winMsg.style.fontSize = '1.4rem';
            winMsg.style.color = '#ffd966';
            winMsg.style.fontWeight = 'bold';
            viewport.appendChild(winMsg);
            setTimeout(() => winMsg.remove(), 2000);
        }
    }

    function getRandomColorExcluding(forbiddenSet = new Set()) {
        const available = COLORS.filter(c => !forbiddenSet.has(c));
        if (available.length === 0) return COLORS[Math.floor(Math.random() * COLORS.length)];
        return available[Math.floor(Math.random() * available.length)];
    }

    function initBoardNoMatches() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                const forbidden = new Set();
                if (c >= 2 && board[r][c-1] === board[r][c-2]) forbidden.add(board[r][c-1]);
                if (r >= 2 && board[r-1][c] === board[r-2][c]) forbidden.add(board[r-1][c]);
                board[r][c] = getRandomColorExcluding(forbidden);
            }
        }
    }

    function placeIce() {
        if (mission.type === 'collect' && !isMixed) return;
        let iceCellsTotal = (mission.type === 'clear_ice') ? requiredIce : (isMixed ? requiredIce : 0);
        let positions = [];
        for (let r = 0; r < ROWS; r++)
            for (let c = 0; c < COLS; c++)
                positions.push([r, c]);
        for (let i = positions.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [positions[i], positions[j]] = [positions[j], positions[i]];
        }
        let placed = 0;
        for (let [r, c] of positions) {
            if (placed >= iceCellsTotal) break;
            if (iceLayer[r][c] === 0) {
                let thickness = (level > 25 && !isMixed) ? 2 : 1;
                iceLayer[r][c] = thickness;
                placed++;
            }
        }
    }

    function getAllMatches() {
        const matches = new Set();
        for (let r = 0; r < ROWS; r++) {
            let len = 1;
            for (let c = 1; c <= COLS; c++) {
                if (c < COLS && board[r][c] === board[r][c-1]) len++;
                else {
                    if (len >= 3) {
                        for (let i = c - len; i < c; i++) matches.add(`${r},${i}`);
                    }
                    len = 1;
                }
            }
        }
        for (let c = 0; c < COLS; c++) {
            let len = 1;
            for (let r = 1; r <= ROWS; r++) {
                if (r < ROWS && board[r][c] === board[r-1][c]) len++;
                else {
                    if (len >= 3) {
                        for (let i = r - len; i < r; i++) matches.add(`${i},${c}`);
                    }
                    len = 1;
                }
            }
        }
        return matches;
    }

    function processMatches(matchesSet) {
        let gainedColor = 0;
        let gainedIce = 0;
        for (const coord of matchesSet) {
            const [r, c] = coord.split(',').map(Number);
            if (iceLayer[r][c] > 0) {
                iceLayer[r][c]--;
                if (iceLayer[r][c] === 0) gainedIce++;
            }
        }
        for (const coord of matchesSet) {
            const [r, c] = coord.split(',').map(Number);
            if (iceLayer[r][c] === 0 && requiredColor && board[r][c] === requiredColor) {
                gainedColor++;
            }
        }
        for (const coord of matchesSet) {
            const [r, c] = coord.split(',').map(Number);
            board[r][c] = null;
            iceLayer[r][c] = 0;
        }
        collected += gainedColor;
        iceCleared += gainedIce;
        updateMissionText();
        checkVictory();
    }

    function applyGravityAndRefill() {
        for (let c = 0; c < COLS; c++) {
            const columnColors = [];
            const columnIce = [];
            for (let r = ROWS-1; r >= 0; r--) {
                if (board[r][c] !== null) {
                    columnColors.push(board[r][c]);
                    columnIce.push(iceLayer[r][c]);
                }
            }
            while (columnColors.length < ROWS) {
                const newColor = COLORS[Math.floor(Math.random() * COLORS.length)];
                columnColors.push(newColor);
                columnIce.push(0);
            }
            columnColors.reverse();
            columnIce.reverse();
            for (let r = 0; r < ROWS; r++) {
                board[r][c] = columnColors[r];
                iceLayer[r][c] = columnIce[r];
            }
        }
    }

    async function resolveMatchesAndDrop() {
        if (processing) return;
        processing = true;
        let anyMatches = true;
        while (anyMatches && gameActive) {
            const matches = getAllMatches();
            if (matches.size === 0) break;
            processMatches(matches);
            if (!gameActive) break;
            applyGravityAndRefill();
            renderBoard();
            await new Promise(r => setTimeout(r, 50));
        }
        processing = false;
        if (gameActive && !hasAnyValidMove()) {
            shuffleBoardWithoutReset();
        }
        renderBoard();
    }

    function hasAnyValidMove() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                if (c+1 < COLS) {
                    swap(r, c, r, c+1);
                    if (getAllMatches().size > 0) { swap(r, c, r, c+1); return true; }
                    swap(r, c, r, c+1);
                }
                if (r+1 < ROWS) {
                    swap(r, c, r+1, c);
                    if (getAllMatches().size > 0) { swap(r, c, r+1, c); return true; }
                    swap(r, c, r+1, c);
                }
            }
        }
        return false;
    }

    function shuffleBoardWithoutReset() {
        const flatColors = [];
        for (let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++) flatColors.push(board[r][c]);
        for (let i=flatColors.length-1;i>0;i--) {
            const j = Math.floor(Math.random()*(i+1));
            [flatColors[i], flatColors[j]] = [flatColors[j], flatColors[i]];
        }
        let idx=0;
        for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++) board[r][c]=flatColors[idx++];
        resolveMatchesAndDrop();
    }

    function swap(r1,c1,r2,c2) {
        [board[r1][c1], board[r2][c2]] = [board[r2][c2], board[r1][c1]];
        [iceLayer[r1][c1], iceLayer[r2][c2]] = [iceLayer[r2][c2], iceLayer[r1][c1]];
    }

    async function trySwap(r1,c1,r2,c2) {
        if (processing || !gameActive) return false;
        swap(r1,c1,r2,c2);
        const matches = getAllMatches();
        if (matches.size > 0) {
            renderBoard();
            await resolveMatchesAndDrop();
            return true;
        } else {
            swap(r1,c1,r2,c2);
            renderBoard();
            return false;
        }
    }

    function renderBoard() {
        for (let r=0;r<ROWS;r++) {
            for (let c=0;c<COLS;c++) {
                const cell = cells[r][c];
                const color = board[r][c];
                cell.style.backgroundColor = getColorStyle(color);
                if (iceLayer[r][c] > 0) {
                    cell.innerHTML = `❄️${iceLayer[r][c]}`;
                    cell.style.color = 'white';
                    cell.style.fontSize = '1.2rem';
                    cell.style.fontWeight = 'bold';
                    cell.style.textShadow = '0 0 2px black';
                } else {
                    cell.innerHTML = '';
                }
                if (selectedRow === r && selectedCol === c && gameActive) {
                    cell.style.boxShadow = '0 0 0 3px gold';
                    cell.style.transform = 'scale(1.02)';
                } else {
                    cell.style.boxShadow = 'none';
                    cell.style.transform = 'scale(1)';
                }
            }
        }
    }

    function getColorStyle(color) {
        switch(color) {
            case 'red': return '#e57373';
            case 'blue': return '#64b5f6';
            case 'green': return '#81c784';
            case 'yellow': return '#fff176';
            case 'purple': return '#ba68c8';
            case 'orange': return '#ffb74d';
            default: return '#b0bec5';
        }
    }

    function createGridUI() {
        for(let r=0;r<ROWS;r++) {
            for(let c=0;c<COLS;c++) {
                const cell = document.createElement('div');
                cell.style.width = '60px';
                cell.style.height = '60px';
                cell.style.borderRadius = '12px';
                cell.style.cursor = 'pointer';
                cell.style.transition = 'all 0.1s';
                cell.style.display = 'flex';
                cell.style.alignItems = 'center';
                cell.style.justifyContent = 'center';
                cell.style.fontSize = '1.2rem';
                cell.addEventListener('click', (function(row,col) {
                    return () => onCellClick(row,col);
                })(r,c));
                grid.appendChild(cell);
                cells[r][c] = cell;
            }
        }
    }

    function onCellClick(row, col) {
        if (processing || !gameActive) return;
        if (selectedRow === null) {
            selectedRow = row;
            selectedCol = col;
            renderBoard();
            return;
        }
        if (selectedRow === row && selectedCol === col) {
            selectedRow = null;
            selectedCol = null;
            renderBoard();
            return;
        }
        const isAdjacent = (Math.abs(selectedRow - row) + Math.abs(selectedCol - col)) === 1;
        if (!isAdjacent) {
            selectedRow = row;
            selectedCol = col;
            renderBoard();
            return;
        }
        const r1=selectedRow, c1=selectedCol, r2=row, c2=col;
        selectedRow = null;
        selectedCol = null;
        trySwap(r1,c1,r2,c2).catch(console.error);
    }

    function start() {
        initBoardNoMatches();
        placeIce();
        createGridUI();
        renderBoard();
        updateMissionText();
        if (!hasAnyValidMove()) shuffleBoardWithoutReset();
    }
    start();
}

export function destroy() {
    // Очистка ресурсов (все элементы привязаны к viewport)
}
