// ─── КАРДИОГРАММА · Precision tap ────────────

let _loop = null;

export function initGame(viewport, level, onWin) {
    if (_loop) { clearInterval(_loop); _loop = null; }

    viewport.innerHTML = '';
    viewport.style.display        = 'flex';
    viewport.style.flexDirection  = 'column';
    viewport.style.alignItems     = 'center';
    viewport.style.gap            = '20px';
    viewport.style.padding        = '12px';

    // ── Header ─────────────────────────────
    const header = document.createElement('div');
    header.style.cssText = `
        text-align: center;
        width: 100%;
    `;
    header.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--text-3);font-weight:700;text-transform:uppercase;">УРОВЕНЬ ${level}</div>
        <div style="font-size:36px;margin:8px 0;filter:drop-shadow(0 0 12px rgba(248,113,113,0.5));">💓</div>
        <div style="font-size:13px;color:var(--text-2);font-weight:600;">Поймай импульс в зелёной зоне</div>
    `;
    viewport.appendChild(header);

    // ── EKG Decoration ─────────────────────
    const ekgWrap = document.createElement('div');
    ekgWrap.style.cssText = 'width:100%;max-width:340px;height:40px;position:relative;overflow:hidden;opacity:0.35;';
    const ekgSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
    ekgSvg.setAttribute('viewBox', '0 0 340 40');
    ekgSvg.setAttribute('width', '100%');
    ekgSvg.setAttribute('height', '40');
    ekgSvg.innerHTML = `
        <polyline
          fill="none"
          stroke="var(--red)"
          stroke-width="1.5"
          points="0,20 30,20 38,5 44,35 50,20 60,20 90,20 98,5 104,35 110,20 120,20 150,20 158,5 164,35 170,20 180,20 210,20 218,5 224,35 230,20 240,20 270,20 278,5 284,35 290,20 300,20 330,20 338,5 340,35"
        />
    `;
    ekgWrap.appendChild(ekgSvg);
    viewport.appendChild(ekgWrap);

    // ── Track ──────────────────────────────
    const trackWrap = document.createElement('div');
    trackWrap.style.cssText = `
        width: 100%;
        max-width: 340px;
        padding: 0 4px;
    `;

    const track = document.createElement('div');
    track.className = 'doctor-track';
    trackWrap.appendChild(track);
    viewport.appendChild(trackWrap);

    // Target zone
    const targetWidth = Math.max(6, 30 - level * 0.25);
    const targetLeft  = Math.floor(Math.random() * (70 - targetWidth)) + 15;

    const targetEl = document.createElement('div');
    targetEl.className = 'doctor-target';
    targetEl.style.left  = targetLeft + '%';
    targetEl.style.width = targetWidth + '%';
    track.appendChild(targetEl);

    // Pulse pin
    const pin = document.createElement('div');
    pin.className = 'doctor-pin';
    track.appendChild(pin);

    // ── Hint ───────────────────────────────
    const hint = document.createElement('div');
    hint.className = 'doctor-tap-hint';
    hint.textContent = '↓ Нажми в любом месте ↓';
    viewport.appendChild(hint);

    // ── Stats ──────────────────────────────
    const stats = document.createElement('div');
    stats.style.cssText = 'display:flex;gap:16px;justify-content:center;';
    stats.innerHTML = `
        <div style="text-align:center;">
            <div style="font-size:10px;letter-spacing:1.5px;color:var(--text-3);font-weight:700;">СКОРОСТЬ</div>
            <div style="font-size:18px;font-weight:800;color:var(--red);">${(2 + level * 0.12).toFixed(1)}×</div>
        </div>
        <div style="text-align:center;">
            <div style="font-size:10px;letter-spacing:1.5px;color:var(--text-3);font-weight:700;">ЗОНА</div>
            <div style="font-size:18px;font-weight:800;color:var(--green);">${Math.round(targetWidth)}%</div>
        </div>
    `;
    viewport.appendChild(stats);

    // ── Animation ──────────────────────────
    let pos = 0, dir = 1;
    const speed = 2 + level * 0.12;

    _loop = setInterval(() => {
        pos += speed * dir;
        if (pos >= 100 || pos <= 0) {
            dir *= -1;
            // Chaos mode on high levels
            if (level > 65 && Math.random() > 0.88) dir *= -1;
        }
        pin.style.left = pos + '%';
    }, 16);

    // ── Click handler ──────────────────────
    let tapped = false;
    const tapHandler = (e) => {
        if (tapped) return;
        const inZone = pos >= targetLeft && pos <= targetLeft + targetWidth;
        if (inZone) {
            tapped = true;
            clearInterval(_loop);
            _loop = null;
            hint.textContent = '✓ ПОПАДАНИЕ!';
            hint.style.color = 'var(--green)';
            pin.style.background     = 'var(--green)';
            pin.style.boxShadow      = '0 0 10px var(--green), 0 0 20px var(--green-glow)';
            targetEl.style.background = 'rgba(52,211,153,0.35)';
            targetEl.style.borderColor = 'var(--green)';
            setTimeout(() => onWin(), 400);
        } else {
            if (navigator.vibrate) navigator.vibrate([80, 40, 80]);
            track.classList.add('doctor-miss');
            hint.textContent = '✗ МИМО — попробуй ещё';
            hint.style.color = 'var(--red)';
            pin.style.boxShadow = '0 0 16px var(--red), 0 0 30px var(--red-glow)';
            setTimeout(() => {
                track.classList.remove('doctor-miss');
                pin.style.boxShadow = '0 0 10px var(--red), 0 0 20px var(--red-glow)';
                hint.textContent = '↓ Нажми ещё раз ↓';
                hint.style.color = 'var(--text-2)';
            }, 500);
        }
    };

    viewport.addEventListener('click', tapHandler);
    viewport._tapHandler = tapHandler;
}

export function destroy() {
    if (_loop) { clearInterval(_loop); _loop = null; }
}

