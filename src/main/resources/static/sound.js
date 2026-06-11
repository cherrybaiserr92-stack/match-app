// ═══════════════════════════════════════════════
//  СДВИГ · sound.js v5  — Web Audio Engine
// ═══════════════════════════════════════════════
class SoundEngine {
    constructor(){
        this.ctx=null;this.master=null;this.music=null;this.sfx=null;
        this._on=localStorage.getItem('sdvig_snd')!=='0';
        this._ready=false;this._loop=null;
    }
    get enabled(){return this._on;}
    toggle(){
        this._on=!this._on;localStorage.setItem('sdvig_snd',this._on?'1':'0');
        if(this.master)this.master.gain.value=this._on?1:0;
        if(this._on)this._startMusic();else this._stopMusic();
        return this._on;
    }
    async init(){
        if(this._ready)return;this._ready=true;
        const C=window.AudioContext||window.webkitAudioContext;if(!C)return;
        try{
            this.ctx=new C();
            if(this.ctx.state==='suspended')await this.ctx.resume();
            this.master=this.ctx.createGain();this.master.gain.value=this._on?1:0;
            this.master.connect(this.ctx.destination);
            this.music=this.ctx.createGain();this.music.gain.value=0.1;this.music.connect(this.master);
            this.sfx=this.ctx.createGain();this.sfx.gain.value=0.8;this.sfx.connect(this.master);
            // Limiter
            const lim=this.ctx.createDynamicsCompressor();lim.threshold.value=-6;lim.ratio.value=8;
            this.sfx.connect(lim);lim.connect(this.master);
            if(this._on)this._startMusic();
        }catch(e){this._ready=false;}
    }
    _t(){return this.ctx?.currentTime||0;}
    _osc(f,type,vol,t,dur,out){
        if(!this.ctx)return;
        const o=this.ctx.createOscillator(),g=this.ctx.createGain();
        o.type=type;o.frequency.value=f;
        g.gain.setValueAtTime(0,t);g.gain.linearRampToValueAtTime(vol,t+0.012);
        g.gain.exponentialRampToValueAtTime(0.001,t+dur);
        o.connect(g);g.connect(out||this.sfx);o.start(t);o.stop(t+dur+0.02);
    }
    _filter(freq,type='lowpass',Q=1){
        if(!this.ctx)return null;
        const f=this.ctx.createBiquadFilter();f.type=type;f.frequency.value=freq;f.Q.value=Q;return f;
    }

    // ── SFX ──────────────────────────────────────
    click(){this._osc(520,'triangle',.18,this._t(),.07);}

    swipeR(){this._whoosh(220,500,.16);}
    swipeL(){this._whoosh(500,220,.16);}

    locked(){
        const t=this._t();
        this._osc(110,'square',.22,t,.12);
        this._osc(80,'sine',.15,t+.07,.15);
    }

    unlock(){
        const t=this._t();
        [[523,0],[659,.1],[784,.2],[1047,.32]].forEach(([f,d])=>this._osc(f,'sine',.28,t+d,.3));
    }

    cardLoad(){this._osc(360,'triangle',.12,this._t(),.1);}

    swipeUp(){
        const t=this._t();
        this._osc(440,'sine',.15,t,.1);this._osc(660,'triangle',.12,t+.08,.15);this._osc(880,'sine',.1,t+.18,.2);
    }

    // Match-3
    gemTap()   {this._osc(700,'sine',.18,this._t(),.07);}
    gemBounce(){this._osc(380,'sine',.12,this._t(),.06);}

    gemMatch(n=3){
        const t=this._t(),base=600+n*60;
        this._osc(base,'sine',.22,t,.15);
        this._osc(base*1.5,'triangle',.1,t+.07,.12);
    }

    combo(n){
        if(!this.ctx||n<2)return;
        const t=this._t(),f=[523,659,784,1047,1318,1568][Math.min(n-2,5)];
        this._osc(f,'sine',.3,t,.25);this._osc(f*2,'triangle',.12,t+.08,.2);
        if(n>=4)this._osc(f*3,'sine',.07,t+.16,.18);
    }

    bombExplode(){
        if(!this.ctx)return;
        const t=this._t();
        this._osc(90,'sawtooth',.4,t,.28);this._osc(60,'square',.28,t+.06,.3);
        // Noise
        const buf=this.ctx.createBuffer(1,this.ctx.sampleRate*.25,this.ctx.sampleRate);
        const d=buf.getChannelData(0);for(let i=0;i<d.length;i++)d[i]=(Math.random()*2-1)*.45;
        const s=this.ctx.createBufferSource(),g=this.ctx.createGain();
        g.gain.setValueAtTime(.35,t);g.gain.exponentialRampToValueAtTime(.001,t+.25);
        s.buffer=buf;s.connect(g);g.connect(this.sfx);s.start(t);s.stop(t+.28);
    }

    noMoves(){
        const t=this._t();
        [[220,.0],[196,.1],[165,.2],[147,.3]].forEach(([f,d])=>this._osc(f,'triangle',.2,t+d,.25));
    }

    win3(){
        const t=this._t();
        [[523,0],[659,.1],[784,.2],[1047,.32],[1318,.46],[1568,.62]]
        .forEach(([f,d])=>this._osc(f,'sine',.28,t+d,.3));
    }

    splashImpact(){
        if(!this.ctx)return;
        const t=this._t();
        this._osc(80,'sine',.35,t,.4);this._osc(160,'triangle',.18,t+.05,.3);
    }

    splashExit(){
        const t=this._t();
        [[220,.0],[330,.08],[440,.16],[660,.26],[880,.38]]
        .forEach(([f,d])=>this._osc(f,'triangle',.18,t+d,.25));
    }

    // ── Background music ──────────────────────────
    _startMusic(){this._stopMusic();this._scheduleLoop();}
    _stopMusic(){clearTimeout(this._loop);this._loop=null;}

    _scheduleLoop(){
        if(!this.ctx)return;
        const t=this.ctx.currentTime+.15,dur=14;
        // Bass pad (Am)
        [[110,.08],[165,.04],[220,.03]].forEach(([f,v])=>this._pad(f,v,t,dur,'sine'));
        // Melodic arpeggio (sparse, detective-noir)
        [[330,1.5],[247,3.2],[294,5],[220,6.8],[330,8.5],[196,10],[247,11.5],[220,13]]
        .forEach(([f,delay])=>this._osc(f,'triangle',.045,t+delay,.9,this.music));
        this._loop=setTimeout(()=>this._scheduleLoop(),(dur-.8)*1000);
    }

    _pad(freq,vol,start,dur,type='sawtooth'){
        if(!this.ctx)return;
        const o=this.ctx.createOscillator(),f=this._filter(700),g=this.ctx.createGain();
        o.type=type;o.frequency.value=freq;
        g.gain.setValueAtTime(0,start);g.gain.linearRampToValueAtTime(vol,start+3);
        g.gain.setValueAtTime(vol,start+dur-2.5);g.gain.linearRampToValueAtTime(0,start+dur);
        o.connect(f);f.connect(g);g.connect(this.music);o.start(start);o.stop(start+dur+.1);
    }

    _whoosh(f1,f2,vol){
        if(!this.ctx)return;
        const t=this._t(),o=this.ctx.createOscillator(),g=this.ctx.createGain();
        o.type='sawtooth';o.frequency.setValueAtTime(f1,t);o.frequency.exponentialRampToValueAtTime(f2,t+.16);
        g.gain.setValueAtTime(vol,t);g.gain.exponentialRampToValueAtTime(.001,t+.18);
        o.connect(g);g.connect(this.sfx);o.start(t);o.stop(t+.22);
    }
}
window.Sound=new SoundEngine();

