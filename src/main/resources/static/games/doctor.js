// Игра класса Врач: Кардиограмма (Прецизионный клик в зону пульса)
let loop = null;

export function initGame(viewport, level, onWin) {
    const track = document.createElement('div');
    track.className = 'timeline-track';
    
    const target = document.createElement('div');
    target.className = 'timeline-target';
    
    // Алгоритм сужения зоны под 100 уровней
    let targetWidth = Math.max(4, 32 - (level * 0.28)); 
    target.style.width = `${targetWidth}%`;
    
    // Рандомизируем позицию зоны на треке, чтобы игрок не привыкал к центру
    let targetLeft = Math.floor(Math.random() * (70 - targetWidth)) + 15;
    target.style.left = `${targetLeft}%`;

    const pin = document.createElement('div');
    pin.className = 'timeline-pin';
    
    track.appendChild(target);
    track.appendChild(pin);
    viewport.appendChild(track);
    
    let position = 0;
    let direction = 1;
    
    // Алгоритмическая скорость
    let speed = 2 + (level * 0.12);
    
    loop = setInterval(() => {
        position += speed * direction;
        if (position >= 100 || position <= 0) {
            direction *= -1;
            // Механика безумия: на 65+ уровнях пульс может хаотично дергаться назад
            if (level > 65 && Math.random() > 0.85) direction *= -1;
        }
        pin.style.left = `${position}%`;
    }, 16);
    
    viewport.onclick = () => {
        let minBound = targetLeft;
        let maxBound = targetLeft + targetWidth;
        
        if (position >= minBound && position <= maxBound) {
            clearInterval(loop);
            onWin();
        } else {
            if(navigator.vibrate) navigator.vibrate([80, 40, 80]); // Эффект ошибки
        }
    };
}

export function destroy() {
    if(loop) clearInterval(loop);
}
