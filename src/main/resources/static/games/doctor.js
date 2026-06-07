// ─── КАРДИОГРАММА (Analyst Cabinet) ───────────────

let _raf = null, _tapped = false;

export function initGame(viewport, level, onWin) {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'20px',
        padding:'8px', width:'100%',
        fontFamily:"'DM Sans',sans-serif"
    });

    const speed = 2 + level * 0.13;
    const zoneW = Math.max(7, 32 - level * 0.24);
    const zoneL = 12 + Math.random() * (72 - zoneW);

    // Header
    const hdr = document.createElement('div');
    hdr.style.cssText = 'text-align:center;width:100%;';
    hdr.innerHTML = `
        <div style="font-size:10px;letter-spacing:2px;color:#8a7d6a;font-weight:700;
            text-transform:uppercase;font-family:'Courier Prime',monospace;">УРОВЕНЬ ${level}</div>
        <div style="font-size:40px;margin:8px 0;line-height:1;">💓</div>
        <div style="font-size:14px;color:#4a3f32;font-weight:600;">Поймай импульс в зелёной зоне</div>
    `;
    viewport.appendChild(hdr);

    // Decorative EKG
    const ekgWrap = document.createElement('div');
    ekgWrap.style.cssText = 'width:100%;max-width:340px;opacity:.18;';
    ekgWrap.innerHTML = `<svg width="100%" height="34" viewBox="0 0 340 34">
        <polyline fill="none" stroke="#8b2020" stroke-width="1.5"
            points="0,17 28,17 36,3 42,31 48,17 58,17 86,17 94,3 100,31 106,17
                    116,17 144,17 152,3 158,31 164,17 174,17 202,17 210,3 216,31
                    222,17 232,17 260,17 268,3 274,31 280,17 290,17 318,17 326,3 332,31 340,17"/>
    </svg>`;
    viewport.appendChild(ekgWrap);

    // Track
    const trackWrap = document.createElement('div');
    trackWrap.style.cssText = 'width:100%;max-width:340px;';
    const track = document.createElement('div');
    track.className = 'doc-track';

    const zone = document.createElement('div');
    zone.className = 'doc-target';
    zone.style.left = zoneL + '%';
    zone.style.width = zoneW + '%';
    track.appendChild(zone);

    const pin = document.createElement('div');
    pin.className = 'doc-pin';
    track.appendChild(pin);
    trackWrap.appendChild(track);
    viewport.appendChild(trackWrap);

    // Hint text
    const hint = document.createElement('div');
    hint.style.cssText = 'font-size:14px;color:#4a3f32;font-weight:600;text-align:center;min-height:22px;';
    hint.textContent = '↓ Нажмите в любом месте ↓';
    viewport.appendChild(hint);

    // Stats panel
    const stats = document.createElement('div');
    stats.style.cssText = `
        display:flex;gap:20px;justify-content:center;
        background:#fdfaf5;border:1px solid #e0d9ce;
        border-radius:12px;padding:10px 24px;
        width:100%;max-width:280px;
    `;
    stats.innerHTML = `
        <div style="text-align:center;">
            <div style="font-size:9px;letter-spacing:1.5px;color:#8a7d6a;font-weight:700;
                text-transform:uppercase;font-family:'Courier Prime',monospace;">СКОРОСТЬ</div>
            <div style="font-size:20px;font-weight:800;color:#8b2020;margin-top:2px;
                font-family:'Cormorant Garamond',serif;">${speed.toFixed(1)}×</div>
        </div>
        <div style="width:1px;background:#e0d9ce;"></div>
        <div style="text-align:center;">
            <div style="font-size:9px;letter-spacing:1.5px;color:#8a7d6a;font-weight:700;
                text-transform:uppercase;font-family:'Courier Prime',monospace;">ЗОНА</div>
            <div style="font-size:20px;font-weight:800;color:#2a6040;margin-top:2px;
                font-family:'Cormorant Garamond',serif;">${Math.round(zoneW)}%</div>
        </div>
    `;
    viewport.appendChild(stats);

    // Animation
    let pos = 0, dir = 1, last = performance.now();
    function frame(ts) {
        const dt = Math.min(ts - last, 50); last = ts;
        pos += speed * dir * dt / 16;
        if (pos >= 100) { pos = 100; dir = -1; }
        if (pos <= 0)   { pos = 0;   dir =  1; }
        if (level > 60 && Math.random() > .994) dir *= -1;
        pin.style.left = pos + '%';
        _raf = requestAnimationFrame(frame);
    }
    _raf = requestAnimationFrame(frame);

    viewport.addEventListener('click', () => {
        if (_tapped) return;
        const inZone = pos >= zoneL && pos <= zoneL + zoneW;
        if (inZone) {
            _tapped = true;
            cancelAnimationFrame(_raf); _raf = null;
            hint.textContent = '✓ ПОПАДАНИЕ!';
            hint.style.color = '#2a6040';
            hint.style.fontWeight = '800';
            pin.style.background = '#2a6040';
            pin.style.boxShadow  = '0 0 8px rgba(42,96,64,.4)';
            zone.style.background = 'rgba(42,96,64,.25)';
            if (navigator.vibrate) navigator.vibrate([30, 20, 60]);
            setTimeout(() => onWin(), 380);
        } else {
            if (navigator.vibrate) navigator.vibrate(70);
            track.classList.add('doc-shake');
            hint.textContent = '✗ Мимо — попробуйте ещё';
            hint.style.color = '#8b2020';
            pin.style.boxShadow = '0 0 10px rgba(139,32,32,.5)';
            setTimeout(() => {
                track.classList.remove('doc-shake');
                if (!_tapped) {
                    hint.textContent = '↓ Нажмите ещё раз ↓';
                    hint.style.color = '#4a3f32';
                    pin.style.boxShadow = '0 0 6px rgba(139,32,32,.4)';
                }
            }, 450);
        }
    });
}

export function destroy() {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;
}

