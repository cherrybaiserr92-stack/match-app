// ─── КАРДИОГРАММА · Precision tap ────────────────

let _raf = null;
let _tapped = false;

export function initGame(viewport, level, onWin) {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;

    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'20px',
        padding:'8px 4px', width:'100%'
    });

    const speed = 2 + level * 0.13;
    const zoneW = Math.max(7, 32 - level * 0.24); // % ширина зоны
    const zoneL = 12 + Math.random() * (72 - zoneW);

    // ── Шапка ────────────────────────────────────
    const hdr = el('div', {
        textAlign:'center', width:'100%',
        fontFamily:'inherit'
    });
    hdr.innerHTML = `
        <div style="font-size:11px;letter-spacing:2px;color:var(--tx3);font-weight:700;text-transform:uppercase;">УРОВЕНЬ ${level}</div>
        <div style="font-size:44px;margin:8px 0;line-height:1;" id="doc-heart">💓</div>
        <div style="font-size:14px;color:var(--tx2);font-weight:600;">Поймай импульс в зелёной зоне</div>
    `;
    viewport.appendChild(hdr);

    // Мини-ЭКГ декоративная
    const ekgSvg = `<svg width="100%" height="36" viewBox="0 0 340 36"
        style="opacity:.2;display:block;margin:0 auto;max-width:340px;">
        <polyline fill="none" stroke="var(--red)" stroke-width="1.5"
            points="0,18 28,18 36,4 42,32 48,18 58,18 86,18 94,4 100,32 106,18
                    116,18 144,18 152,4 158,32 164,18 174,18 202,18 210,4 216,32
                    222,18 232,18 260,18 268,4 274,32 280,18 290,18 318,18 326,4 332,32 340,18"/>
    </svg>`;
    const ekgWrap = el('div', {width:'100%'});
    ekgWrap.innerHTML = ekgSvg;
    viewport.appendChild(ekgWrap);

    // ── Трек ─────────────────────────────────────
    const trackWrap = el('div', {width:'100%', maxWidth:'340px'});

    const track = el('div', {
        width:'100%', height:'72px',
        background:'var(--s1)', border:'1px solid var(--b2)',
        borderRadius:'var(--r)', position:'relative',
        overflow:'hidden', cursor:'pointer',
        userSelect:'none', WebkitUserSelect:'none'
    });

    // Зелёная зона
    const zone = el('div', {
        position:'absolute', top:'0', bottom:'0',
        left: zoneL+'%', width: zoneW+'%',
        background:'var(--green-d)',
        borderLeft:'2px solid var(--green)',
        borderRight:'2px solid var(--green)',
        transition:'background .1s'
    });
    track.appendChild(zone);

    // Пин
    const pin = el('div', {
        position:'absolute', top:'10px', bottom:'10px', width:'3px',
        background:'var(--red)', borderRadius:'99px',
        transform:'translateX(-50%)',
        boxShadow:'0 0 8px var(--red)',
        transition:'background .15s, box-shadow .15s'
    });
    track.appendChild(pin);
    trackWrap.appendChild(track);
    viewport.appendChild(trackWrap);

    // ── Подсказка ─────────────────────────────────
    const hint = el('div', {
        fontSize:'14px', color:'var(--tx2)',
        fontWeight:'600', textAlign:'center',
        minHeight:'22px', letterSpacing:'.3px'
    });
    hint.textContent = '↓ Нажмите в любом месте ↓';
    viewport.appendChild(hint);

    // ── Параметры уровня ──────────────────────────
    const info = el('div', {
        display:'flex', gap:'20px', justifyContent:'center',
        background:'var(--s2)', border:'1px solid var(--b)',
        borderRadius:'var(--r)', padding:'10px 24px',
        width:'100%', maxWidth:'280px'
    });
    info.innerHTML = `
        <div style="text-align:center">
            <div style="font-size:9px;letter-spacing:1.5px;color:var(--tx3);font-weight:700;text-transform:uppercase;">СКОРОСТЬ</div>
            <div style="font-size:20px;font-weight:800;color:var(--red);margin-top:2px;">${speed.toFixed(1)}×</div>
        </div>
        <div style="width:1px;background:var(--b)"></div>
        <div style="text-align:center">
            <div style="font-size:9px;letter-spacing:1.5px;color:var(--tx3);font-weight:700;text-transform:uppercase;">ЗОНА</div>
            <div style="font-size:20px;font-weight:800;color:var(--green);margin-top:2px;">${Math.round(zoneW)}%</div>
        </div>
    `;
    viewport.appendChild(info);

    // ── Анимация ─────────────────────────────────
    let pos = 0, dir = 1;
    let lastTime = performance.now();

    function frame(ts) {
        const dt = Math.min(ts - lastTime, 50); lastTime = ts;
        pos += speed * dir * dt / 16;
        if (pos >= 100) { pos = 100; dir = -1; }
        if (pos <= 0)   { pos = 0;   dir = 1;  }
        // chaos at high levels
        if (level > 60 && Math.random() > .994) dir *= -1;
        pin.style.left = pos + '%';
        _raf = requestAnimationFrame(frame);
    }
    _raf = requestAnimationFrame(frame);

    // ── Тап ──────────────────────────────────────
    viewport.addEventListener('click', () => {
        if (_tapped) return;
        const inZone = pos >= zoneL && pos <= zoneL + zoneW;

        if (inZone) {
            _tapped = true;
            cancelAnimationFrame(_raf); _raf = null;
            hint.textContent = '✓ ПОПАДАНИЕ!';
            hint.style.color = 'var(--green)';
            hint.style.fontWeight = '800';
            pin.style.background  = 'var(--green)';
            pin.style.boxShadow   = '0 0 10px var(--green)';
            zone.style.background = 'rgba(62,176,119,.35)';
            if (navigator.vibrate) navigator.vibrate([30, 20, 60]);
            setTimeout(() => onWin(), 380);
        } else {
            if (navigator.vibrate) navigator.vibrate(80);
            track.classList.add('doc-shake');
            hint.textContent = '✗ Мимо — попробуйте ещё';
            hint.style.color = 'var(--red)';
            pin.style.boxShadow = '0 0 14px var(--red)';
            setTimeout(() => {
                track.classList.remove('doc-shake');
                if (!_tapped) {
                    hint.textContent = '↓ Нажмите ещё раз ↓';
                    hint.style.color = 'var(--tx2)';
                    pin.style.boxShadow = '0 0 8px var(--red)';
                }
            }, 450);
        }
    });
}

function el(tag, styles) {
    const d = document.createElement(tag);
    Object.assign(d.style, styles);
    return d;
}

export function destroy() {
    if (_raf) { cancelAnimationFrame(_raf); _raf = null; }
    _tapped = false;
}

