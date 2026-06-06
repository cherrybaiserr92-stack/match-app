// ─── САМОЦВЕТЫ · Match-3 ──────────────────────

const GEM_EMOJI = {
    red:    '🔴', blue:   '🔵', green:  '🟢',
    yellow: '🟡', purple: '🟣', orange: '🟠'
};

const GEM_COLORS_CSS = {
    red:    '#f87171', blue:   '#60a5fa', green:  '#34d399',
    yellow: '#fbbf24', purple: '#a78bfa', orange: '#fb923c'
};

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    viewport.style.display        = 'flex';
    viewport.style.flexDirection  = 'column';
    viewport.style.alignItems     = 'center';
    viewport.style.gap            = '12px';
    viewport.style.width          = '100%';

    const ROWS   = 9;
    const COLS   = 9;
    const COLORS = Object.keys(GEM_EMOJI);

    // ── Mission ──────────────────────────────
    const mission = getMission(level);
    let collected  = 0;
    let iceCleared = 0;
    let combo      = 0;

    // ── Board state ──────────────────────────
    let board    = Array.from({ length: ROWS }, () => Array(COLS).fill(null));
    let iceLayer = Array.from({ length: ROWS }, () => Array(COLS).fill(0));
    let selR = null, selC = null;
    let gameActive = true, processing = false;

    // ── Cell size (responsive) ───────────────
    const vw      = Math.min(viewport.offsetWidth || window.innerWidth, 400);
    const GAP     = 3;
    const PAD     = 12;
    const CELL    = Math.floor((vw - PAD * 2 - GAP * (COLS - 1)) / COLS);

    // ── Mission panel ────────────────────────
    const panel = mkDiv({
        width: '100%',
        background: 'var(--surface)',
        border: '1px solid var(--border)',
        borderRadius: 'var(--radius)',
        padding: '10px 14px',
        fontFamily: 'inherit',
        color: 'var(--text)',
        textAlign: 'center',
        fontSize: '13px',
        fontWeight: '600',
    });

    const lvlLabel = document.createElement('div');
    lvlLabel.style.cssText = 'font-size:11px;letter-spacing:2px;color:var(--text-3);margin-bottom:4px;';
    lvlLabel.textContent = 'УРОВЕНЬ ' + level;
    panel.appendChild(lvlLabel);

    const missionLabel = document.createElement('div');
    missionLabel.id = 'gem-mission';
    panel.appendChild(missionLabel);

    const comboLabel = document.createElement('div');
    comboLabel.style.cssText = 'font-size:11px;color:var(--primary);margin-top:4px;font-weight:700;letter-spacing:1px;min-height:16px;';
    panel.appendChild(comboLabel);

    viewport.appendChild(panel);
    refreshMission();

    // ── Grid ─────────────────────────────────
    const grid = document.createElement('div');
    grid.style.cssText = `
        display: grid;
        grid-template-columns: repeat(${COLS}, ${CELL}px);
        gap: ${GAP}px;
        background: var(--surface);
        padding: ${PAD}px;
        border-radius: var(--radius-lg);
        border: 1px solid var(--border-hi);
        box-shadow: 0 0 40px var(--primary-glow);
    `;
    viewport.appendChild(grid);

    const cells = Array.from({ length: ROWS }, () => Array(COLS).fill(null));

    // ── Render ───────────────────────────────
    function renderBoard() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                const cell  = cells[r][c];
                const color = board[r][c];

                cell.textContent = GEM_EMOJI[color] || '';

                const isIce = iceLayer[r][c] > 0;
                const isSel = selR === r && selC === c;

                cell.style.background   = isIce ? 'rgba(34,211,238,0.15)' : 'var(--surface-2)';
                cell.style.borderColor  = isSel ? 'var(--gold)' :
                                          isIce ? 'rgba(34,211,238,0.5)' :
                                          'transparent';
                cell.style.boxShadow    = isSel
                    ? `0 0 0 2px var(--gold), 0 0 16px var(--gold-glow)`
                    : isIce
                    ? `inset 0 0 8px rgba(34,211,238,0.2)`
                    : 'none';
                cell.style.transform    = isSel ? 'scale(1.1)' : 'scale(1)';
                cell.style.opacity      = '1';
                cell.style.filter       = isIce ? 'brightness(0.7) saturate(0.5)' : 'none';

                if (isIce && iceLayer[r][c] === 2) {
                    cell.style.background = 'rgba(34,211,238,0.3)';
                }
            }
        }
    }

    function createGrid() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                const cell = mkDiv({
                    width:          CELL + 'px',
                    height:         CELL + 'px',
                    borderRadius:   '8px',
                    display:        'flex',
                    alignItems:     'center',
                    justifyContent: 'center',
                    fontSize:       Math.max(16, CELL - 12) + 'px',
                    cursor:         'pointer',
                    border:         '1.5px solid transparent',
                    transition:     'transform 0.12s, border-color 0.12s, box-shadow 0.12s, background 0.12s',
                    lineHeight:     '1',
                    userSelect:     'none',
                    WebkitUserSelect: 'none',
                });
                cell.addEventListener('click', ((_r, _c) => () => onCellClick(_r, _c))(r, c));
                grid.appendChild(cell);
                cells[r][c] = cell;
            }
        }
    }

    // ── Match logic ───────────────────────────
    function getAllMatches() {
        const m = new Set();
        for (let r = 0; r < ROWS; r++) {
            let len = 1;
            for (let c = 1; c <= COLS; c++) {
                if (c < COLS && board[r][c] === board[r][c-1]) { len++; }
                else { if (len >= 3) for (let i = c-len; i < c; i++) m.add(`${r},${i}`); len = 1; }
            }
        }
        for (let c = 0; c < COLS; c++) {
            let len = 1;
            for (let r = 1; r <= ROWS; r++) {
                if (r < ROWS && board[r][c] === board[r-1][c]) { len++; }
                else { if (len >= 3) for (let i = r-len; i < r; i++) m.add(`${i},${c}`); len = 1; }
            }
        }
        return m;
    }

    function processMatches(matchSet) {
        let gainColor = 0, gainIce = 0;
        for (const coord of matchSet) {
            const [r, c] = coord.split(',').map(Number);
            if (iceLayer[r][c] > 0) {
                iceLayer[r][c]--;
                if (iceLayer[r][c] === 0) gainIce++;
            }
        }
        for (const coord of matchSet) {
            const [r, c] = coord.split(',').map(Number);
            if (iceLayer[r][c] === 0 && mission.color && board[r][c] === mission.color) gainColor++;
        }
        for (const coord of matchSet) {
            const [r, c] = coord.split(',').map(Number);
            board[r][c]    = null;
            iceLayer[r][c] = 0;
        }
        collected  += gainColor;
        iceCleared += gainIce;
        combo++;
        if (combo > 1) {
            comboLabel.textContent = `✨ COMBO x${combo}!`;
            setTimeout(() => { comboLabel.textContent = ''; }, 1200);
        }
        refreshMission();
        checkVictory();
    }

    function applyGravityAndRefill() {
        for (let c = 0; c < COLS; c++) {
            const gems = [], ice = [];
            for (let r = ROWS - 1; r >= 0; r--) {
                if (board[r][c] !== null) { gems.push(board[r][c]); ice.push(iceLayer[r][c]); }
            }
            while (gems.length < ROWS) { gems.push(COLORS[Math.floor(Math.random() * COLORS.length)]); ice.push(0); }
            gems.reverse(); ice.reverse();
            for (let r = 0; r < ROWS; r++) { board[r][c] = gems[r]; iceLayer[r][c] = ice[r]; }
        }
    }

    async function resolveLoop() {
        if (processing) return;
        processing = true;
        let any = true;
        while (any && gameActive) {
            const m = getAllMatches();
            if (m.size === 0) { any = false; break; }
            processMatches(m);
            if (!gameActive) break;
            applyGravityAndRefill();
            renderBoard();
            await delay(80);
        }
        processing = false;
        if (gameActive && !hasValidMove()) shuffleBoard();
        renderBoard();
    }

    function hasValidMove() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                if (c + 1 < COLS) { swap(r,c,r,c+1); if (getAllMatches().size > 0) { swap(r,c,r,c+1); return true; } swap(r,c,r,c+1); }
                if (r + 1 < ROWS) { swap(r,c,r+1,c); if (getAllMatches().size > 0) { swap(r,c,r+1,c); return true; } swap(r,c,r+1,c); }
            }
        }
        return false;
    }

    function shuffleBoard() {
        const flat = board.flat();
        for (let i = flat.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [flat[i], flat[j]] = [flat[j], flat[i]];
        }
        let idx = 0;
        for (let r = 0; r < ROWS; r++) for (let c = 0; c < COLS; c++) board[r][c] = flat[idx++];
        resolveLoop();
    }

    function swap(r1,c1,r2,c2) {
        [board[r1][c1], board[r2][c2]] = [board[r2][c2], board[r1][c1]];
        [iceLayer[r1][c1], iceLayer[r2][c2]] = [iceLayer[r2][c2], iceLayer[r1][c1]];
    }

    async function trySwap(r1,c1,r2,c2) {
        if (processing || !gameActive) return;
        swap(r1,c1,r2,c2);
        if (getAllMatches().size > 0) { combo = 0; renderBoard(); await resolveLoop(); }
        else { swap(r1,c1,r2,c2); renderBoard(); }
    }

    function onCellClick(r, c) {
        if (processing || !gameActive) return;
        if (selR === null) { selR = r; selC = c; renderBoard(); return; }
        if (selR === r && selC === c) { selR = null; selC = null; renderBoard(); return; }
        const isAdj = Math.abs(selR - r) + Math.abs(selC - c) === 1;
        if (!isAdj) { selR = r; selC = c; renderBoard(); return; }
        const [r1,c1] = [selR, selC]; selR = null; selC = null;
        trySwap(r1,c1,r,c).catch(console.error);
    }

    // ── Init board ────────────────────────────
    function initBoard() {
        for (let r = 0; r < ROWS; r++) {
            for (let c = 0; c < COLS; c++) {
                const forbidden = new Set();
                if (c >= 2 && board[r][c-1] === board[r][c-2]) forbidden.add(board[r][c-1]);
                if (r >= 2 && board[r-1][c] === board[r-2][c]) forbidden.add(board[r-1][c]);
                const avail = COLORS.filter(x => !forbidden.has(x));
                board[r][c] = avail[Math.floor(Math.random() * avail.length)] || COLORS[0];
            }
        }
    }

    function placeIce() {
        if (mission.type === 'collect') return;
        const count = mission.type === 'clear_ice' ? mission.target : (mission.targetIce || 0);
        if (count === 0) return;
        const positions = [];
        for (let r = 0; r < ROWS; r++) for (let c = 0; c < COLS; c++) positions.push([r,c]);
        positions.sort(() => Math.random() - 0.5);
        let placed = 0;
        for (const [r,c] of positions) {
            if (placed >= count) break;
            iceLayer[r][c] = level > 25 ? 2 : 1;
            placed++;
        }
    }

    // ── Victory ───────────────────────────────
    function checkVictory() {
        const done =
            mission.type === 'collect'   ? collected  >= mission.target :
            mission.type === 'clear_ice' ? iceCleared >= mission.target :
            /* mixed */ collected >= mission.targetCollect && iceCleared >= mission.targetIce;

        if (done && gameActive) {
            gameActive = false;
            onWin();
        }
    }

    // ── Mission text ──────────────────────────
    function refreshMission() {
        const el = document.getElementById('gem-mission');
        if (!el) return;
        const gem = GEM_EMOJI[mission.color] || '';
        if (mission.type === 'collect') {
            el.innerHTML = `${gem} Собери: ${collected} / ${mission.target}`;
        } else if (mission.type === 'clear_ice') {
            el.innerHTML = `❄️ Разморозь: ${iceCleared} / ${mission.target}`;
        } else {
            el.innerHTML = `${gem} ${collected}/${mission.targetCollect} &nbsp; ❄️ ${iceCleared}/${mission.targetIce}`;
        }
    }

    // ── Start ─────────────────────────────────
    initBoard();
    placeIce();
    createGrid();
    renderBoard();
    if (!hasValidMove()) shuffleBoard();
}

// ── Helpers ───────────────────────────────────
function getMission(lvl) {
    if (lvl <= 5)  return { type: 'collect', color: 'blue',   target: 10 + lvl };
    if (lvl <= 10) return { type: 'collect', color: 'green',  target: 15 + (lvl-5)*2 };
    if (lvl <= 15) return { type: 'collect', color: 'purple', target: 20 + (lvl-10)*3 };
    if (lvl <= 20) return { type: 'clear_ice', target: 5 + (lvl-15) };
    return { type: 'mixed', color: 'blue', targetCollect: 20+(lvl-20)*2, targetIce: 8+Math.floor((lvl-20)/2) };
}

function mkDiv(styles) {
    const d = document.createElement('div');
    Object.assign(d.style, styles);
    return d;
}

function delay(ms) { return new Promise(r => setTimeout(r, ms)); }

export function destroy() {}

