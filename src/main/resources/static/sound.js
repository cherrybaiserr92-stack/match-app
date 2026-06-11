/* СДВИГ · sound.js v5 — приятные синтезированные SFX (Web Audio) */
(function(){
  let ctx=null, master=null, enabled=true;
  try{ enabled = localStorage.getItem('sdvig_sound')!=='0'; }catch(e){}

  function ac(){
    if(ctx) return ctx;
    const AC = window.AudioContext||window.webkitAudioContext;
    if(!AC) return null;
    ctx = new AC();
    master = ctx.createGain();
    master.gain.value = 0.5;
    // мягкий лимитер через компрессор — убирает «резкость»
    const comp = ctx.createDynamicsCompressor();
    comp.threshold.value=-18; comp.knee.value=24; comp.ratio.value=12;
    comp.attack.value=.003; comp.release.value=.25;
    master.connect(comp); comp.connect(ctx.destination);
    return ctx;
  }
  function resume(){ const c=ac(); if(c&&c.state==='suspended') c.resume(); }

  // базовый «голос» с ADSR-огибающей и фильтром
  function voice(opt){
    if(!enabled) return; const c=ac(); if(!c) return;
    const t=c.currentTime;
    const {type='sine',freq=440,to=null,dur=.18,gain=.3,
           a=.005,d=.05,s=.6,r=.08,filter=null,detune=0,pan=0}=opt;
    const osc=c.createOscillator(); osc.type=type;
    osc.frequency.setValueAtTime(freq,t);
    if(to) osc.frequency.exponentialRampToValueAtTime(Math.max(40,to),t+dur);
    if(detune) osc.detune.value=detune;
    const g=c.createGain(); const peak=gain;
    g.gain.setValueAtTime(.0001,t);
    g.gain.exponentialRampToValueAtTime(peak,t+a);
    g.gain.exponentialRampToValueAtTime(peak*s+.0001,t+a+d);
    g.gain.setValueAtTime(peak*s+.0001,t+dur);
    g.gain.exponentialRampToValueAtTime(.0001,t+dur+r);
    let node=osc;
    if(filter){ const f=c.createBiquadFilter(); f.type=filter.type||'lowpass';
      f.frequency.value=filter.freq||1200; f.Q.value=filter.q||1; node.connect(f); node=f; }
    const p=c.createStereoPanner?c.createStereoPanner():null;
    if(p){ p.pan.value=pan; node.connect(g); g.connect(p); p.connect(master); }
    else { node.connect(g); g.connect(master); }
    osc.start(t); osc.stop(t+dur+r+.02);
  }

  // короткий шум (для частиц/щелчков/дождя)
  function noise(opt){
    if(!enabled) return; const c=ac(); if(!c) return;
    const {dur=.12,gain=.18,freq=2200,q=.8,type='bandpass'}=opt;
    const t=c.currentTime; const n=Math.floor(c.sampleRate*dur);
    const buf=c.createBuffer(1,n,c.sampleRate); const ch=buf.getChannelData(0);
    for(let i=0;i<n;i++) ch[i]=(Math.random()*2-1)*(1-i/n);
    const src=c.createBufferSource(); src.buffer=buf;
    const f=c.createBiquadFilter(); f.type=type; f.frequency.value=freq; f.Q.value=q;
    const g=c.createGain(); g.gain.setValueAtTime(gain,t); g.gain.exponentialRampToValueAtTime(.0001,t+dur);
    src.connect(f); f.connect(g); g.connect(master); src.start(t); src.stop(t+dur);
  }

  const S = {
    tap(){ voice({type:'triangle',freq:520,to:440,dur:.05,gain:.12,a:.002,d:.02,s:.3,r:.04,
                  filter:{type:'lowpass',freq:2400}}); },
    nav(){ voice({type:'sine',freq:660,dur:.08,gain:.14,a:.003,d:.03,s:.4,r:.06}); },
    // мягкое «дзынь» при свайпе/выборе
    swipe(dir){ const f=dir==='left'?300:dir==='up'?720:520;
      voice({type:'sine',freq:f,to:f*1.6,dur:.18,gain:.2,a:.003,d:.04,s:.5,r:.1,
             pan:dir==='left'?-.4:dir==='right'?.4:0,filter:{type:'lowpass',freq:3200}});
      noise({dur:.08,gain:.06,freq:3000,type:'highpass'}); },
    approve(){ [523,659,784].forEach((f,i)=>setTimeout(()=>voice(
      {type:'sine',freq:f,dur:.16,gain:.18,a:.004,d:.05,s:.5,r:.12,filter:{type:'lowpass',freq:4000}}),i*70)); },
    deny(){ voice({type:'sawtooth',freq:200,to:120,dur:.28,gain:.16,a:.004,d:.08,s:.4,r:.14,
                   filter:{type:'lowpass',freq:1100}}); },
    special(){ [392,523,659,880].forEach((f,i)=>setTimeout(()=>voice(
      {type:'triangle',freq:f,dur:.18,gain:.16,a:.003,d:.05,s:.5,r:.14,filter:{type:'lowpass',freq:5000}}),i*55)); },
    // match-3
    gemSelect(){ voice({type:'sine',freq:880,dur:.06,gain:.12,a:.002,d:.02,s:.3,r:.05}); },
    gemSwap(){ voice({type:'triangle',freq:600,to:760,dur:.09,gain:.14,a:.002,d:.03,s:.4,r:.05}); },
    gemMatch(n){ const base=520+Math.min(n,6)*60;
      voice({type:'sine',freq:base,to:base*1.5,dur:.16,gain:.18,a:.003,d:.04,s:.5,r:.1});
      noise({dur:.1,gain:.05,freq:5000,type:'highpass'}); },
    gemCascade(step){ voice({type:'sine',freq:600+step*90,dur:.1,gain:.14,a:.002,d:.03,s:.4,r:.07}); },
    gemFall(){ voice({type:'sine',freq:300,to:200,dur:.07,gain:.06,a:.002,d:.02,s:.4,r:.04}); },
    booster(){ [659,880,1175].forEach((f,i)=>setTimeout(()=>voice(
      {type:'triangle',freq:f,dur:.14,gain:.16,a:.002,d:.04,s:.5,r:.1}),i*45)); },
    // прочее
    coin(){ voice({type:'square',freq:1320,to:1760,dur:.08,gain:.1,a:.002,d:.03,s:.3,r:.05,
                   filter:{type:'lowpass',freq:4000}}); },
    levelUp(){ [523,659,784,1047].forEach((f,i)=>setTimeout(()=>voice(
      {type:'sine',freq:f,dur:.22,gain:.18,a:.004,d:.06,s:.5,r:.16}),i*90)); },
    win(){ [523,659,784,1047,1319].forEach((f,i)=>setTimeout(()=>voice(
      {type:'triangle',freq:f,dur:.24,gain:.17,a:.004,d:.07,s:.5,r:.18,filter:{type:'lowpass',freq:6000}}),i*80)); },
    error(){ voice({type:'sawtooth',freq:160,to:110,dur:.2,gain:.12,a:.003,d:.06,s:.4,r:.1,
                    filter:{type:'lowpass',freq:900}}); },
    daily(){ [659,880,1047].forEach((f,i)=>setTimeout(()=>voice(
      {type:'sine',freq:f,dur:.2,gain:.16,a:.004,d:.06,s:.5,r:.14}),i*100)); },
    // splash — мягкий «бум» без резкости
    splashImpact(){ voice({type:'sine',freq:180,to:90,dur:.5,gain:.22,a:.006,d:.1,s:.4,r:.3,
                           filter:{type:'lowpass',freq:600}}); },
    transition(){ voice({type:'sine',freq:300,to:900,dur:.6,gain:.16,a:.01,d:.1,s:.5,r:.3,
                         filter:{type:'lowpass',freq:5000}});
                  noise({dur:.5,gain:.04,freq:6000,type:'highpass'}); }
  };

  window.Sound = new Proxy(S,{
    get(target,prop){
      if(prop==='resume') return resume;
      if(prop==='toggle') return ()=>{ enabled=!enabled;
        try{localStorage.setItem('sdvig_sound',enabled?'1':'0');}catch(e){} return enabled; };
      if(prop==='isOn') return ()=>enabled;
      const fn=target[prop];
      if(typeof fn==='function') return (...a)=>{ try{ resume(); fn(...a);}catch(e){} };
      return fn;
    }
  });

  ['touchstart','pointerdown','click'].forEach(ev=>
    document.addEventListener(ev,resume,{once:true,passive:true}));
})();
