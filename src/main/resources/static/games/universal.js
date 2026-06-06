// ─── ЭКСПЕРТИЗА ШИФРА · Math cipher ──────────────

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'16px', width:'100%'
    });

    const target   = 10 + level * 4 + Math.floor(Math.random() * 6);
    const count    = level <= 10 ? 6 : level <= 40 ? 9 : 12;
    const maxVal   = 4 + Math.floor(level / 2);
    let   sumNow   = 0;
    const picked   = new Set();

    // Генерируем числа с гарантированным решением
    const nums = Array.from({length: count}, () => Math.floor(Math.random() * maxVal) + 2);
    let acc = 0;
    for (let i = 0; i < nums.length; i++) {
        if (acc + nums[i] <= target) acc += nums[i];
    }
    if (acc !== target) nums[nums.length - 1] = target - acc + (acc > 0 ? 0 : nums[0]);

    // ── Шапка ────────────────────────────────────
    const hdr = document.createElement('div');
    hdr.style.cssText = 'text-align:center;width:100%;';
    hdr.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--tx3);font-weight:700;
            text-transform:uppercase;margin-bottom:4px;">УРОВЕНЬ ${level} · ШИФР</div>
        <div style="font-size:13px;color:var(--tx2);font-weight:600;">Выбери числа в сумме:</div>
    `;
    viewport.appendChild(hdr);

    // ── Цель ─────────────────────────────────────
    const targetBox = document.createElement('div');
    targetBox.style.cssText = `
        background:var(--s1);border:1px solid var(--b2);
        border-radius:var(--r);padding:14px 36px;text-align:center;
        box-shadow:0 4px 20px rgba(212,151,26,.08);
    `;
    targetBox.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:var(--amber);
            font-weight:700;text-transform:uppercase;">ЦЕЛЬ</div>
        <div id="cipher-target" style="font-size:52px;font-weight:800;
            color:var(--tx);line-height:1.1;">${target}</div>
    `;
    viewport.appendChild(targetBox);

    // ── Прогресс ─────────────────────────────────
    const progWrap = document.createElement('div');
    progWrap.style.cssText = 'width:100%;max-width:300px;';
    progWrap.innerHTML = `
        <div style="display:flex;justify-content:space-between;
            font-size:11px;color:var(--tx3);font-weight:600;
            margin-bottom:6px;letter-spacing:.3px;">
            <span>ТЕКУЩАЯ СУММА</span>
            <span id="cs-lbl">0 / ${target}</span>
        </div>
        <div style="height:4px;background:var(--s3);border-radius:99px;overflow:hidden;">
            <div id="cs-bar" style="height:100%;width:0%;
                background:var(--amber);border-radius:99px;
                transition:width .2s ease,background .15s;"></div>
        </div>
    `;
    viewport.appendChild(progWrap);

    // ── Сетка числе ──────────────────────────────
    const grid = document.createElement('div');
    grid.style.cssText = `
        display:flex;flex-wrap:wrap;gap:8px;
        justify-content:center;max-width:320px;
    `;
    viewport.appendChild(grid);

    // ── Статус ────────────────────────────────────
    const status = document.createElement('div');
    status.style.cssText = `
        font-size:12px;color:var(--tx3);min-height:18px;
        text-align:center;font-weight:500;letter-spacing:.3px;
    `;
    viewport.appendChild(status);

    // Строим ячейки
    for (let i = 0; i < count; i++) {
        const val  = nums[i];
        const cell = document.createElement('div');
        cell.className  = 'cipher-cell';
        cell.textContent = val;
        cell.dataset.idx = i;

        cell.addEventListener('click', () => {
            if (picked.has(i)) {
                // Снимаем
                picked.delete(i);
                sumNow -= val;
                cell.classList.remove('sel');
            } else {
                picked.add(i);
                sumNow += val;
                cell.classList.add('sel');

                if (sumNow === target) {
                    // WIN
                    grid.querySelectorAll('.cipher-cell').forEach(c => {
                        c.style.pointerEvents = 'none';
                        if (c.classList.contains('sel')) {
                            c.style.borderColor = 'var(--green)';
                            c.style.background  = 'var(--green-d)';
                            c.style.color       = 'var(--green)';
                            c.style.boxShadow   = '0 0 10px rgba(62,176,119,.3)';
                        }
                    });
                    status.textContent = '✓ ШИФР ВЗЛОМАН!';
                    status.style.color = 'var(--green)';
                    status.style.fontWeight = '700';
                    setProgress(target, target);
                    if (navigator.vibrate) navigator.vibrate([30,20,60]);
                    setTimeout(() => onWin(), 450);
                    return;
                }

                if (sumNow > target) {
                    // Перебор — сброс
                    cell.classList.add('over');
                    setTimeout(() => cell.classList.remove('over'), 280);
                    if (navigator.vibrate) navigator.vibrate(70);
                    status.textContent = '⚠ Сумма превышена — сброс';
                    status.style.color = 'var(--red)';
                    setTimeout(() => {
                        if (status.style.color !== 'var(--green)') {
                            status.textContent = '';
                            status.style.color = 'var(--tx3)';
                        }
                    }, 1100);
                    grid.querySelectorAll('.cipher-cell').forEach(c => c.classList.remove('sel'));
                    picked.clear();
                    sumNow = 0;
                    setProgress(0, target);
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
        if (bar) {
            bar.style.width = pct + '%';
            bar.style.background =
                cur > max   ? 'var(--red)' :
                cur === max ? 'var(--green)' : 'var(--amber)';
        }
        if (lbl) lbl.textContent = `${cur} / ${max}`;
    }
}

export function destroy() {}

