// ═══════════════════════════════════════════════
//  СДВИГ · sound.js — Web Audio Engine
//  No external files — everything synthesized
// ═══════════════════════════════════════════════

class SoundEngine {
    constructor() {
        this.ctx   = null;
        this.master = null;
        this.music  = null;
        this.sfx    = null;
        this._on    = localStorage.getItem('sdvig_snd') !== '0';
        this._ready = false;
        this._loop  = null;
    }

    get enabled() { return this._on; }

    toggle() {
        this._on = !this._on;
        localStorage.setItem('sdvig_snd', this._on ? '1' : '0');
        if (this.master) this.master.gain.value = this._on ? 1 : 0;
        if (this._on) { this._startMusic(); } else { this._stopMusic(); }
        return this._on;
    }

    // Call on first user gesture
    async init() {
        if (this._ready) return;
        this._ready = true;
        const Ctx = window.AudioContext || window.webkitAudioContext;
        if (!Ctx) return;
        try {
            this.ctx = new Ctx();
            if (this.ctx.state === 'suspended') await this.ctx.resume();

            this.master = this.ctx.createGain();
            this.master.gain.value = this._on ? 1 : 0;
            this.master.connect(this.ctx.destination);

            this.music = this.ctx.createGain();
            this.music.gain.value = 0.13;
            this.music.connect(this.master);

            this.sfx = this.ctx.createGain();
            this.sfx.gain.value = 0.75;
            this.sfx.connect(this.master);

            if (this._on) this._startMusic();
        } catch(e) { this._ready = false; }
    }

    // ── Primitives ────────────────────────────────
    _tone(freq, type, vol, start, dur, out) {
        if (!this.ctx) return;
        const o = this.ctx.createOscillator();
        const g = this.ctx.createGain();
        o.type = type;
        o.frequency.value = freq;
        g.gain.setValueAtTime(0, start);
        g.gain.linearRampToValueAtTime(vol, start + Math.min(0.015, dur * 0.1));
        g.gain.exponentialRampToValueAtTime(0.0001, start + dur);
        o.connect(g); g.connect(out || this.sfx);
        o.start(start); o.stop(start + dur + 0.05);
    }

    _now() { return this.ctx?.currentTime || 0; }

    // ── UI SFX ────────────────────────────────────
    click()  { if(!this.ctx)return; this._tone(520,'triangle',0.22,this._now(),0.07); }

    swipeR() { this._whoosh(200, 440, 0.18); }
    swipeL() { this._whoosh(440, 200, 0.18); }

    locked() {
        if (!this.ctx) return;
        const t = this._now();
        this._tone(130, 'square', 0.28, t, 0.10);
        this._tone(90, 'sawtooth', 0.15, t + 0.08, 0.12);
    }

    unlock() {
        if (!this.ctx) return;
        const t = this._now();
        [[523,.00],[659,.10],[784,.20],[1047,.32]].forEach(([f,d]) =>
            this._tone(f, 'sine', 0.28, t + d, 0.28));
    }

    cardLoad() {
        if (!this.ctx) return;
        this._tone(330, 'triangle', 0.14, this._now(), 0.12);
    }

    // ── Match-3 SFX ──────────────────────────────
    gemTap()   { if(!this.ctx)return; this._tone(680,'sine',0.18,this._now(),0.07); }
    gemBounce(){ if(!this.ctx)return; this._tone(320,'sine',0.14,this._now(),0.06); }

    gemMatch(n) {
        if (!this.ctx) return;
        const t = this._now();
        const f = 700 + n * 40;
        this._tone(f, 'sine', 0.22, t, 0.14);
        this._tone(f * 1.5, 'triangle', 0.10, t + 0.06, 0.10);
    }

    combo(n) {
        if (!this.ctx || n < 2) return;
        const t = this._now();
        const freqs = [523,659,784,1047,1318,1568];
        const f = freqs[Math.min(n - 2, freqs.length - 1)];
        this._tone(f, 'sine', 0.30, t, 0.25);
        this._tone(f * 2, 'triangle', 0.14, t + 0.08, 0.20);
        if (n >= 5) this._tone(f * 3, 'sine', 0.08, t + 0.16, 0.18);
    }

    bombExplode() {
        if (!this.ctx) return;
        const t = this._now();
        this._tone(120, 'sawtooth', 0.35, t, 0.25);
        this._tone(80,  'square',   0.25, t + 0.05, 0.3);
        // Noise burst
        const buf = this.ctx.createBuffer(1, this.ctx.sampleRate * 0.2, this.ctx.sampleRate);
        const d = buf.getChannelData(0);
        for (let i = 0; i < d.length; i++) d[i] = (Math.random() * 2 - 1) * 0.4;
        const s = this.ctx.createBufferSource();
        s.buffer = buf;
        const g = this.ctx.createGain();
        g.gain.setValueAtTime(0.3, t);
        g.gain.exponentialRampToValueAtTime(0.001, t + 0.2);
        s.connect(g); g.connect(this.sfx);
        s.start(t); s.stop(t + 0.25);
    }

    win3() {
        if (!this.ctx) return;
        const t = this._now();
        [[523,.00],[659,.10],[784,.20],[1047,.32],[1318,.46]]
        .forEach(([f,d]) => this._tone(f, 'sine', 0.3, t + d, 0.3));
    }

    // ── Splash ────────────────────────────────────
    splashImpact() {
        if (!this.ctx) return;
        const t = this._now();
        this._tone(80, 'sine', 0.4, t, 0.4);
        this._tone(160, 'triangle', 0.2, t + 0.05, 0.3);
    }

    splashExit() {
        if (!this.ctx) return;
        const t = this._now();
        [[220,.00],[330,.08],[440,.16],[660,.26],[880,.38]]
        .forEach(([f,d]) => this._tone(f,'triangle',0.2,t+d,0.25));
    }

    // ── Background music ──────────────────────────
    _startMusic() {
        this._stopMusic();
        this._scheduleLoop();
    }

    _stopMusic() {
        if (this._loop) { clearTimeout(this._loop); this._loop = null; }
    }

    _scheduleLoop() {
        if (!this.ctx) return;
        const t   = this.ctx.currentTime + 0.2;
        const dur = 12;

        // Bass drone (Am)
        this._pad(110, 0.09, t, dur, 'sine');
        this._pad(220, 0.05, t, dur, 'sine');
        this._pad(165, 0.03, t + 4, dur - 4, 'sine');

        // Sparse high notes (detective melody)
        const melody = [
            [330,1.0],[294,2.5],[330,4.0],[247,5.5],
            [277,7.0],[330,8.5],[294,10.0],[220,11.5],
        ];
        melody.forEach(([f, delay]) =>
            this._tone(f, 'triangle', 0.05, t + delay, 0.9, this.music));

        this._loop = setTimeout(() => this._scheduleLoop(), (dur - 0.8) * 1000);
    }

    _pad(freq, vol, start, dur, type = 'sawtooth') {
        if (!this.ctx) return;
        const o = this.ctx.createOscillator();
        const f = this.ctx.createBiquadFilter();
        const g = this.ctx.createGain();
        o.type = type; o.frequency.value = freq;
        f.type = 'lowpass'; f.frequency.value = 700; f.Q.value = 0.4;
        g.gain.setValueAtTime(0, start);
        g.gain.linearRampToValueAtTime(vol, start + 2.5);
        g.gain.setValueAtTime(vol, start + dur - 2);
        g.gain.linearRampToValueAtTime(0, start + dur);
        o.connect(f); f.connect(g); g.connect(this.music);
        o.start(start); o.stop(start + dur + 0.1);
    }

    _whoosh(f1, f2, vol) {
        if (!this.ctx) return;
        const t = this._now();
        const o = this.ctx.createOscillator();
        const g = this.ctx.createGain();
        o.type = 'sawtooth';
        o.frequency.setValueAtTime(f1, t);
        o.frequency.exponentialRampToValueAtTime(f2, t + 0.16);
        g.gain.setValueAtTime(vol, t);
        g.gain.exponentialRampToValueAtTime(0.001, t + 0.18);
        o.connect(g); g.connect(this.sfx);
        o.start(t); o.stop(t + 0.22);
    }
}

window.Sound = new SoundEngine();

