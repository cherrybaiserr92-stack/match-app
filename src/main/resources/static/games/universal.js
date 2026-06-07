// ─── ЭКСПЕРТИЗА ШИФРА (Analyst Cabinet) ───────────

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'16px', width:'100%',
        fontFamily:"'DM Sans',sans-serif"
    });

    const target  = 10 + level * 4 + Math.floor(Math.random() * 6);
    const count   = level <= 10 ? 6 : level <= 40 ? 9 : 12;
    const maxVal  = 4 + Math.floor(level / 2);
    let   sumNow  = 0;
    const picked  = new Set();

    // Числа с гарантированным решением
    const nums = Array.from({length: count}, () => Math.floor(Math.random() * maxVal) + 2);
    let acc = 0;
    for (const v of nums) { if (acc + v <= target) acc += v; }
    if (acc !== target) nums[nums.length - 1] = target - acc + (acc > 0 ? 0 : nums[0]);

    // Header
    const hdr = document.createElement('div');
    hdr.style.cssText = 'text-align:center;width:100%;';
    hdr.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:#8a7d6a;font-weight:700;
            text-transform:uppercase;font-family:'Courier Prime',monospace;margin-bottom:4px;">
            УРОВЕНЬ ${level} · ШИФР</div>
        <div style="font-size:13px;color:#4a3f32;font-weight:600;">Выбери числа в сумме:</div>
    `;
    viewport.appendChild(hdr);

    // Target
    const targetBox = document.createElement('div');
    targetBox.style.cssText = `
        background:#fdfaf5;border:1px solid #c8bfb0;
        border-radius:12px;padding:14px 36px;text-align:center;
        box-shadow:0 2px 12px rgba(0,0,0,.06);
    `;
    targetBox.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:#a87030;font-weight:700;
            text-transform:uppercase;font-family:'Courier Prime',monospace;">ЦЕЛЬ</div>
        <div style="font-size:52px;font-weight:700;color:#1c1710;line-height:1.1;
            font-family:'Cormorant Garamond',serif;">${target}</div>
    `;
    viewport.appendChild(targetBox);

    // Progress
    const progWrap = document.createElement('div');
    progWrap.style.cssText = 'width:100%;max-width:300px;';
    progWrap.innerHTML = `
        <div style="display:flex;justify-content:space-between;font-size:11px;
            color:#8a7d6a;font-weight:600;margin-bottom:6px;font-family:'Courier Prime',monospace;">
            <span>ТЕКУЩАЯ СУММА</span>
            <span id="cs-lbl">0 / ${target}</span>
        </div>
        <div style="height:4px;background:#e0d9ce;border-radius:99px;overflow:hidden;">
            <div id="cs-bar" style="height:100%;width:0%;background:#a87030;
                border-radius:99px;transition:width .2s ease,background .15s;"></div>
        </div>
    `;
    viewport.appendChild(progWrap);

    // Grid
    const grid = document.createElement('div');
    grid.style.cssText = 'display:flex;flex-wrap:wrap;gap:8px;justify-content:center;max-width:320px;';
    viewport.appendChild(grid);

    // Status
    const status = document.createElement('div');
    status.style.cssText = 'font-size:12px;color:#8a7d6a;min-height:18px;text-align:center;font-weight:500;';
    viewport.appendChild(status);

    for (let i = 0; i < count; i++) {
        const val  = nums[i];
        const cell = document.createElement('div');
        cell.className = 'cipher-cell';
        cell.textContent = val;

        cell.addEventListener('click', () => {
            if (picked.has(i)) {
                picked.delete(i); sumNow -= val; cell.classList.remove('sel');
            } else {
                picked.add(i); sumNow += val; cell.classList.add('sel');

                if (sumNow === target) {
                    grid.querySelectorAll('.cipher-cell').forEach(c => {
                        c.style.pointerEvents = 'none';
                        if (c.classList.contains('sel')) {
                            c.style.borderColor = '#2a6040';
                            c.style.background  = 'rgba(42,96,64,.10)';
                            c.style.color       = '#2a6040';
                        }
                    });
                    status.textContent = '✓ ШИФР ВЗЛОМАН';
                    status.style.color = '#2a6040';
                    status.style.fontWeight = '700';
                    setProgress(target, target);
                    if (navigator.vibrate) navigator.vibrate([30, 20, 60]);
                    setTimeout(() => onWin(), 420);
                    return;
                }
                if (sumNow > target) {
                    cell.classList.add('over');
                    setTimeout(() => cell.classList.remove('over'), 260);
                    if (navigator.vibrate) navigator.vibrate(60);
                    status.textContent = '⚠ Сумма превышена — сброс';
                    status.style.color = '#8b2020';
                    setTimeout(() => { if(status.style.color!=='rgb(42,96,64)') { status.textContent=''; status.style.color='#8a7d6a'; }}, 1000);
                    grid.querySelectorAll('.cipher-cell').forEach(c => c.classList.remove('sel'));
                    picked.clear(); sumNow = 0; setProgress(0, target);
                    return;
                }
            }
            setProgress(sumNow, target);
        });
        grid.appendChild(cell);
    }

    function setProgress(cur, max) {
        const pct = Math.min(100, Math.round(cur / max * 100));
        const bar = document.getElementById('cs-bar');
        const lbl = document.getElementById('cs-lbl');
        if (bar) { bar.style.width = pct + '%'; bar.style.background = cur > max ? '#8b2020' : cur === max ? '#2a6040' : '#a87030'; }
        if (lbl) lbl.textContent = `${cur} / ${max}`;
    }
}

export function destroy() {}

