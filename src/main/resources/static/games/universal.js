// ─── ЭКСПЕРТИЗА ШИФРА · Math cipher ──────────

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    viewport.style.display        = 'flex';
    viewport.style.flexDirection  = 'column';
    viewport.style.alignItems     = 'center';
    viewport.style.gap            = '16px';
    viewport.style.width          = '100%';

    const targetSum   = 10 + level * 4 + Math.floor(Math.random() * 5);
    const cellsCount  = level <= 10 ? 6 : level <= 40 ? 8 : 12;
    let currentSum    = 0;
    const selected    = new Set();

    // ── Header ─────────────────────────────
    const header = document.createElement('div');
    header.style.cssText = 'text-align:center;width:100%;';
    header.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--text-3);font-weight:700;text-transform:uppercase;margin-bottom:4px;">УРОВЕНЬ ${level} · ЭКСПЕРТИЗА ШИФРА</div>
        <div style="font-size:13px;color:var(--text-2);font-weight:600;">Выбери числа в сумме:</div>
    `;
    viewport.appendChild(header);

    // ── Target display ─────────────────────
    const targetBox = document.createElement('div');
    targetBox.style.cssText = `
        background: var(--surface);
        border: 1px solid var(--border-hi);
        border-radius: var(--radius);
        padding: 14px 32px;
        text-align: center;
        box-shadow: 0 0 20px var(--primary-glow);
    `;
    targetBox.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:var(--primary);font-weight:700;text-transform:uppercase;">ЦЕЛЬ</div>
        <div style="font-size:48px;font-weight:800;color:var(--text);line-height:1.1;">${targetSum}</div>
    `;
    viewport.appendChild(targetBox);

    // ── Progress bar ───────────────────────
    const progressWrap = document.createElement('div');
    progressWrap.style.cssText = 'width:100%;max-width:300px;';
    progressWrap.innerHTML = `
        <div style="display:flex;justify-content:space-between;font-size:11px;color:var(--text-3);font-weight:600;margin-bottom:6px;letter-spacing:0.5px;">
            <span>ТЕКУЩАЯ СУММА</span>
            <span id="cipher-sum-label">0 / ${targetSum}</span>
        </div>
        <div style="height:4px;background:var(--surface-3);border-radius:99px;overflow:hidden;">
            <div id="cipher-progress" style="height:100%;width:0%;background:linear-gradient(90deg,var(--primary),var(--cyan));border-radius:99px;transition:width 0.25s ease,background 0.2s;"></div>
        </div>
    `;
    viewport.appendChild(progressWrap);

    // ── Number grid ────────────────────────
    const grid = document.createElement('div');
    grid.className = 'cipher-grid';
    viewport.appendChild(grid);

    // ── Reset hint ─────────────────────────
    const hint = document.createElement('div');
    hint.style.cssText = 'font-size:11px;color:var(--text-3);letter-spacing:0.5px;min-height:16px;text-align:center;font-weight:500;';
    viewport.appendChild(hint);

    // ── Generate values ────────────────────
    const maxVal  = 5 + Math.floor(level / 2);
    const values  = Array.from({ length: cellsCount }, () => Math.floor(Math.random() * maxVal) + 2);

    // Guarantee solution exists: replace last value if needed
    let testSum = 0;
    const soln = [];
    for (const v of values) {
        if (testSum + v <= targetSum) { testSum += v; soln.push(v); }
    }
    if (testSum !== targetSum) {
        values[values.length - 1] = targetSum - testSum + (soln.length > 0 ? 0 : values[0]);
    }

    // Build cells
    for (let i = 0; i < cellsCount; i++) {
        const val  = values[i];
        const cell = document.createElement('div');
        cell.className = 'cipher-cell';
        cell.textContent = val;
        cell.dataset.val = val;
        cell.dataset.idx = i;

        cell.addEventListener('click', () => {
            if (selected.has(i)) {
                selected.delete(i);
                currentSum -= val;
                cell.classList.remove('selected');
            } else {
                selected.add(i);
                currentSum += val;
                cell.classList.add('selected');

                if (currentSum === targetSum) {
                    // Win!
                    grid.querySelectorAll('.cipher-cell').forEach(c => {
                        c.style.pointerEvents = 'none';
                        if (c.classList.contains('selected')) {
                            c.style.borderColor = 'var(--green)';
                            c.style.background  = 'rgba(52,211,153,0.2)';
                            c.style.color       = 'var(--green)';
                            c.style.boxShadow   = '0 0 12px var(--green-glow)';
                        }
                    });
                    hint.textContent = '✓ ШИФР ВЗЛОМАН';
                    hint.style.color = 'var(--green)';
                    updateProgress(currentSum, targetSum);
                    setTimeout(() => onWin(), 500);
                    return;
                }

                if (currentSum > targetSum) {
                    // Overshoot — reset
                    cell.classList.add('over-target');
                    setTimeout(() => cell.classList.remove('over-target'), 300);
                    if (navigator.vibrate) navigator.vibrate(60);
                    hint.textContent = '⚠️ Сумма превышена — сброс';
                    hint.style.color = 'var(--red)';
                    setTimeout(() => { hint.textContent = ''; hint.style.color = 'var(--text-3)'; }, 1200);
                    // deselect all
                    grid.querySelectorAll('.cipher-cell').forEach(c => c.classList.remove('selected'));
                    selected.clear();
                    currentSum = 0;
                    updateProgress(0, targetSum);
                    return;
                }
            }
            updateProgress(currentSum, targetSum);
        });

        grid.appendChild(cell);
    }

    function updateProgress(cur, target) {
        const pct = Math.min(100, Math.round((cur / target) * 100));
        const bar = document.getElementById('cipher-progress');
        const lbl = document.getElementById('cipher-sum-label');
        if (bar) {
            bar.style.width = pct + '%';
            bar.style.background = cur > target
                ? 'linear-gradient(90deg,var(--red),var(--red))'
                : cur === target
                ? 'linear-gradient(90deg,var(--green),var(--green))'
                : 'linear-gradient(90deg,var(--primary),var(--cyan))';
        }
        if (lbl) lbl.textContent = `${cur} / ${target}`;
    }
}

export function destroy() {}

