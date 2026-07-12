/* СДВИГ · sound.js v6 — кинематографичный процедурный звук (Web Audio)
   Принцип: никаких «голых» осцилляторов. Каждый звук — слои шума,
   расстроенных голосов, фильтр-свипов и конволюционного реверба.
   + нуар-эмбиент (дождь, гул города, далёкий тон) на фоне. 0 КБ ассетов. */
(function(){
  let ctx=null, master=null, busDry=null, busWet=null, reverbIR=null, enabled=true;
  try{ enabled = localStorage.getItem('sdvig_sound')!=='0'; }catch(e){}

  /* ── граф: master → compressor → limiter → out
        реверб-шина (busWet) подмешивается параллельно ── */
  function ac(){
    if(ctx) return ctx;
    const AC = window.AudioContext||window.webkitAudioContext;
    if(!AC) return null;
    ctx = new AC();

    master = ctx.createGain(); master.gain.value=0.62;

    // мягкий клей-компрессор
    const comp = ctx.createDynamicsCompressor();
    comp.threshold.value=-20; comp.knee.value=26; comp.ratio.value=8;
    comp.attack.value=.004; comp.release.value=.22;

    // финальный лимитер (жёсткий, чтобы не было клиппинга)
    const lim = ctx.createDynamicsCompressor();
    lim.threshold.value=-2; lim.knee.value=0; lim.ratio.value=20;
    lim.attack.value=.001; lim.release.value=.05;

    master.connect(comp); comp.connect(lim); lim.connect(ctx.destination);

    // шины dry/wet
    busDry = ctx.createGain(); busDry.gain.value=1; busDry.connect(master);
    busWet = ctx.createGain(); busWet.gain.value=0.0; // включается через reverb send
    const conv = ctx.createConvolver(); conv.buffer = makeIR(2.0, 2.6);
    busWet.connect(conv); conv.connect(master);

    return ctx;
  }
  function resume(){ const c=ac(); if(c&&c.state==='suspended') c.resume(); }

  /* ── процедурный импульсный отклик для реверба (зал/комната) ── */
  function makeIR(dur, decay){
    const c=ac(); if(!c) return null;
    const rate=c.sampleRate, len=Math.floor(rate*dur);
    const buf=c.createBuffer(2,len,rate);
    for(let ch=0; ch<2; ch++){
      const d=buf.getChannelData(ch);
      for(let i=0;i<len;i++){
        // экспоненциальный хвост + лёгкая ранняя «комната»
        const t=i/len;
        d[i]=(Math.random()*2-1)*Math.pow(1-t, decay);
      }
    }
    return buf;
  }

  /* ── расстроенный «голос» с ADSR, фильтром и send в реверб ── */
  function voice(opt){
    if(!enabled) return; const c=ac(); if(!c) return;
    const t=c.currentTime;
    const {type='sine',freq=440,to=null,dur=.18,gain=.3,
           a=.005,d=.05,s=.6,r=.1,filter=null,detune=0,pan=0,
           reverb=0.12, voices=1, spread=7}=opt;

    const out=c.createGain(); // суммирующий узел этого звука
    const env=c.createGain();
    env.gain.setValueAtTime(.0001,t);
    env.gain.exponentialRampToValueAtTime(gain,t+a);
    env.gain.exponentialRampToValueAtTime(Math.max(.0001,gain*s),t+a+d);
    env.gain.setValueAtTime(Math.max(.0001,gain*s),t+dur);
    env.gain.exponentialRampToValueAtTime(.0001,t+dur+r);

    // несколько расстроенных осцилляторов = «жирный» тон вместо писка
    for(let v=0; v<voices; v++){
      const osc=c.createOscillator(); osc.type=type;
      osc.frequency.setValueAtTime(freq,t);
      if(to) osc.frequency.exponentialRampToValueAtTime(Math.max(40,to),t+dur);
      osc.detune.value = detune + (v - (voices-1)/2)*spread;
      osc.connect(out); osc.start(t); osc.stop(t+dur+r+.03);
    }

    let node=out;
    if(filter){
      const f=c.createBiquadFilter(); f.type=filter.type||'lowpass';
      f.frequency.setValueAtTime(filter.freq||1400,t);
      if(filter.to) f.frequency.exponentialRampToValueAtTime(filter.to,t+dur);
      f.Q.value=filter.q||1; node.connect(f); node=f;
    }
    node.connect(env);

    const p=c.createStereoPanner?c.createStereoPanner():null;
    if(p){ p.pan.value=pan; env.connect(p);
      p.connect(busDry);
      if(reverb>0){ const sg=c.createGain(); sg.gain.value=reverb; p.connect(sg); sg.connect(busWet); }
    } else {
      env.connect(busDry);
      if(reverb>0){ const sg=c.createGain(); sg.gain.value=reverb; env.connect(sg); sg.connect(busWet); }
    }
  }

  /* ── фильтрованный шум (удары, щелчки, дождь, шорох) ── */
  function noise(opt){
    if(!enabled) return; const c=ac(); if(!c) return;
    const {dur=.12,gain=.18,freq=2200,to=null,q=.8,type='bandpass',
           a=.002,r=.06,reverb=0.08,pan=0}=opt;
    const t=c.currentTime; const n=Math.floor(c.sampleRate*dur);
    const buf=c.createBuffer(1,n,c.sampleRate); const ch=buf.getChannelData(0);
    for(let i=0;i<n;i++) ch[i]=(Math.random()*2-1);
    const src=c.createBufferSource(); src.buffer=buf;
    const f=c.createBiquadFilter(); f.type=type;
    f.frequency.setValueAtTime(freq,t);
    if(to) f.frequency.exponentialRampToValueAtTime(to,t+dur);
    f.Q.value=q;
    const g=c.createGain();
    g.gain.setValueAtTime(.0001,t);
    g.gain.exponentialRampToValueAtTime(gain,t+a);
    g.gain.exponentialRampToValueAtTime(.0001,t+dur+r);
    src.connect(f); f.connect(g);
    const p=c.createStereoPanner?c.createStereoPanner():null;
    if(p){ p.pan.value=pan; g.connect(p); p.connect(busDry);
      if(reverb>0){ const sg=c.createGain(); sg.gain.value=reverb; p.connect(sg); sg.connect(busWet); } }
    else { g.connect(busDry); if(reverb>0){ const sg=c.createGain(); sg.gain.value=reverb; g.connect(sg); sg.connect(busWet); } }
    src.start(t); src.stop(t+dur+r+.02);
  }

  /* ════════════════════════════════════════════════════
     НУАР-ЭМБИЕНТ: дождь + низкий гул + редкие капли
  ════════════════════════════════════════════════════ */
  let ambient=null;
  function startAmbient(){
    if(!enabled) return; const c=ac(); if(!c) return;
    if(ambient) return;
    const t=c.currentTime;

    // 1. дождь — розовый шум через полосовой фильтр
    const rl=Math.floor(c.sampleRate*4);
    const rb=c.createBuffer(1,rl,c.sampleRate); const rd=rb.getChannelData(0);
    let last=0;
    for(let i=0;i<rl;i++){ const w=Math.random()*2-1; last=(last+0.02*w)/1.02; rd[i]=last*3.2; }
    const rain=c.createBufferSource(); rain.buffer=rb; rain.loop=true;
    const rf=c.createBiquadFilter(); rf.type='bandpass'; rf.frequency.value=1600; rf.Q.value=.5;
    const rg=c.createGain(); rg.gain.value=0; rain.connect(rf); rf.connect(rg); rg.connect(master);
    rain.start(t); rg.gain.linearRampToValueAtTime(0.05, t+3);

    // 2. низкий городской гул — две расстроенные пилы под фильтром
    const hum=c.createGain(); hum.gain.value=0;
    [55, 55.4].forEach(f=>{
      const o=c.createOscillator(); o.type='sawtooth'; o.frequency.value=f;
      const lp=c.createBiquadFilter(); lp.type='lowpass'; lp.frequency.value=180; lp.Q.value=.6;
      o.connect(lp); lp.connect(hum); o.start(t);
    });
    hum.connect(master); hum.gain.linearRampToValueAtTime(0.035, t+4);

    // 3. медленное «дыхание» громкости дождя
    const lfo=c.createOscillator(); lfo.frequency.value=0.07;
    const lfg=c.createGain(); lfg.gain.value=0.018;
    lfo.connect(lfg); lfg.connect(rg.gain); lfo.start(t);

    ambient={rain,rg,hum,lfo,nodes:[rain,lfo]};
  }
  function stopAmbient(){
    if(!ambient) return; const c=ac(); const t=c.currentTime;
    try{
      ambient.rg.gain.linearRampToValueAtTime(0, t+1.2);
      ambient.hum.gain.linearRampToValueAtTime(0, t+1.2);
      setTimeout(()=>{ try{ambient.nodes.forEach(n=>n.stop());}catch(e){} ambient=null; }, 1400);
    }catch(e){ ambient=null; }
  }

  /* ════════════════════════════════════════════════════
     БИБЛИОТЕКА SFX (всё многослойное, с ревербом)
  ════════════════════════════════════════════════════ */
  const S = {
    /* интерфейс */
    tap(){ noise({dur:.035,gain:.10,freq:3200,type:'bandpass',q:1.4,reverb:.04});
           voice({type:'triangle',freq:480,to:430,dur:.04,gain:.07,a:.001,d:.02,s:.2,r:.03,reverb:.05,filter:{type:'lowpass',freq:2600}}); },
    nav(){ noise({dur:.05,gain:.07,freq:2400,type:'bandpass',q:1,reverb:.06});
           voice({type:'sine',freq:520,to:680,dur:.07,gain:.08,a:.002,d:.03,s:.3,r:.05,reverb:.1}); },

    /* свайп — «шорох карты» + тональный свип, панорамирован по направлению */
    swipe(dir){
      const pan = dir==='left'?-.5:dir==='right'?.5:0;
      noise({dur:.16,gain:.13,freq:dir==='left'?900:1500,to:dir==='left'?300:4000,
             type:'bandpass',q:.7,reverb:.1,pan,a:.004,r:.1});
      voice({type:'sine',freq:dir==='left'?340:520,to:dir==='left'?180:760,dur:.16,gain:.1,
             a:.003,d:.04,s:.4,r:.08,pan,reverb:.14,filter:{type:'lowpass',freq:3000}});
    },

    /* выбор-«улика подтверждена» — тёплый мажорный аккорд с ревером */
    approve(){ [392,494,587].forEach((f,i)=>setTimeout(()=>voice(
      {type:'triangle',freq:f,dur:.3,gain:.1,a:.005,d:.08,s:.5,r:.2,voices:2,spread:6,
       reverb:.22,filter:{type:'lowpass',freq:3600}}),i*60)); },
    deny(){ voice({type:'sawtooth',freq:180,to:90,dur:.36,gain:.13,a:.004,d:.1,s:.4,r:.18,voices:2,spread:10,
                   reverb:.18,filter:{type:'lowpass',freq:900,to:400}});
            noise({dur:.18,gain:.05,freq:500,type:'lowpass',reverb:.1}); },

    /* СДВИГ — «раскол реальности»: расстроенный свип + металлический шум-реверс */
    special(){
      const c=ac(); if(!c)return;
      voice({type:'sawtooth',freq:120,to:520,dur:.7,gain:.12,a:.02,d:.1,s:.6,r:.3,voices:3,spread:14,
             reverb:.3,filter:{type:'bandpass',freq:300,to:2400,q:2}});
      noise({dur:.6,gain:.07,freq:600,to:6000,type:'bandpass',q:.6,reverb:.28,a:.2,r:.3});
      [0,.12,.24].forEach((dl,i)=>setTimeout(()=>voice(
        {type:'sine',freq:880+i*220,dur:.3,gain:.06,a:.003,d:.06,s:.4,r:.2,pan:(i-1)*.5,reverb:.3}),dl*1000));
    },

    /* сжигание карты (огонь) */
    burn(){ noise({dur:.5,gain:.12,freq:800,to:200,type:'lowpass',q:.5,reverb:.16,a:.01,r:.3});
            noise({dur:.35,gain:.06,freq:5000,type:'highpass',reverb:.1,a:.005,r:.2});
            voice({type:'sawtooth',freq:90,to:50,dur:.5,gain:.08,a:.02,d:.1,s:.5,r:.3,reverb:.2,filter:{type:'lowpass',freq:400}}); },

    /* match-3 */
    gemSelect(){ voice({type:'sine',freq:760,dur:.05,gain:.08,a:.002,d:.02,s:.3,r:.04,reverb:.08}); },
    gemSwap(){ noise({dur:.05,gain:.07,freq:2600,type:'bandpass',q:1.5,reverb:.05});
               voice({type:'triangle',freq:560,to:720,dur:.08,gain:.08,a:.002,d:.03,s:.4,r:.05,reverb:.1}); },
    gemMatch(n){ const base=440+Math.min(n||3,6)*55;
      voice({type:'sine',freq:base,to:base*1.5,dur:.2,gain:.12,a:.003,d:.04,s:.5,r:.12,voices:2,spread:5,reverb:.18});
      noise({dur:.12,gain:.05,freq:4800,type:'highpass',reverb:.12}); },
    gemCascade(step){ voice({type:'sine',freq:520+(step||0)*80,dur:.12,gain:.09,a:.002,d:.03,s:.4,r:.08,reverb:.14}); },
    gemFall(){ voice({type:'sine',freq:280,to:180,dur:.08,gain:.05,a:.002,d:.02,s:.4,r:.05,reverb:.06}); },
    booster(){ [523,698,880,1047].forEach((f,i)=>setTimeout(()=>voice(
      {type:'triangle',freq:f,dur:.2,gain:.1,a:.002,d:.05,s:.5,r:.14,voices:2,spread:5,reverb:.2}),i*55)); },
    /* спецфишки match-3 */
    lineBlast(){ noise({dur:.28,gain:.15,freq:900,to:5200,type:'bandpass',q:.8,reverb:.18,a:.005,r:.15});
      voice({type:'sawtooth',freq:300,to:900,dur:.22,gain:.09,a:.003,d:.05,s:.5,r:.12,voices:2,spread:9,reverb:.2,filter:{type:'lowpass',freq:4000}}); },
    bombBlast(){ voice({type:'sine',freq:140,to:48,dur:.5,gain:.2,a:.004,d:.1,s:.4,r:.3,reverb:.3,filter:{type:'lowpass',freq:600,to:140}});
      noise({dur:.35,gain:.11,freq:300,type:'lowpass',reverb:.25,a:.004,r:.25});
      noise({dur:.12,gain:.05,freq:3800,type:'highpass',reverb:.15}); },
    rainbowBlast(){ [660,880,1175,1568].forEach((f,i)=>setTimeout(()=>voice(
      {type:'sine',freq:f,dur:.22,gain:.08,a:.003,d:.05,s:.4,r:.16,voices:2,spread:6,reverb:.28}),i*70));
      noise({dur:.5,gain:.05,freq:2000,to:8000,type:'bandpass',q:.6,reverb:.3,a:.05,r:.3}); },
    starChime(){ voice({type:'triangle',freq:1319,dur:.25,gain:.1,a:.002,d:.06,s:.4,r:.2,voices:2,spread:5,reverb:.3});
      setTimeout(()=>voice({type:'triangle',freq:1760,dur:.3,gain:.08,a:.002,d:.06,s:.4,r:.24,reverb:.32}),80); },
    shot(){ noise({dur:.09,gain:.19,freq:900,to:200,type:'bandpass',q:.7,reverb:.2,a:.001,r:.08});
      voice({type:'square',freq:220,to:80,dur:.08,gain:.09,a:.001,d:.03,s:.3,r:.06,reverb:.15,filter:{type:'lowpass',freq:1200}}); },
    /* щелчок защёлки сейфа */
    latch(){ noise({dur:.05,gain:.2,freq:2400,type:'bandpass',q:2.5,reverb:.08});
      voice({type:'square',freq:340,to:210,dur:.06,gain:.07,a:.001,d:.02,s:.3,r:.05,reverb:.08,filter:{type:'lowpass',freq:1800}}); },
    /* четыре частоты «прослушки» (Simon) */
    simon(i){ const F=[392,494,587,740];
      voice({type:'triangle',freq:F[(i||0)%4],dur:.24,gain:.12,a:.004,d:.06,s:.6,r:.14,voices:2,spread:6,reverb:.18,
             filter:{type:'lowpass',freq:3800}}); },

    /* экономика / прогресс */
    coin(){ noise({dur:.04,gain:.06,freq:5200,type:'bandpass',q:2,reverb:.05});
            voice({type:'triangle',freq:1180,to:1560,dur:.1,gain:.08,a:.002,d:.03,s:.3,r:.06,reverb:.12,filter:{type:'lowpass',freq:5000}}); },
    levelUp(){ [392,523,659,784].forEach((f,i)=>setTimeout(()=>voice(
      {type:'sine',freq:f,dur:.3,gain:.11,a:.004,d:.07,s:.5,r:.2,voices:2,spread:6,reverb:.26}),i*95)); },
    win(){ [392,523,659,784,1047].forEach((f,i)=>setTimeout(()=>voice(
      {type:'triangle',freq:f,dur:.34,gain:.1,a:.005,d:.08,s:.5,r:.24,voices:2,spread:7,reverb:.3,
       filter:{type:'lowpass',freq:5000}}),i*85));
      noise({dur:.4,gain:.04,freq:6000,type:'highpass',reverb:.2,a:.1,r:.3}); },
    error(){ voice({type:'sawtooth',freq:150,to:100,dur:.26,gain:.1,a:.003,d:.07,s:.4,r:.12,voices:2,spread:8,
                    reverb:.12,filter:{type:'lowpass',freq:800}}); },
    daily(){ [523,659,880].forEach((f,i)=>setTimeout(()=>voice(
      {type:'sine',freq:f,dur:.28,gain:.1,a:.004,d:.07,s:.5,r:.18,voices:2,spread:6,reverb:.24}),i*100)); },

    /* кинематографичные акценты */
    splashImpact(){
      // глубокий «бум» с под-басом и хвостом-ревером
      voice({type:'sine',freq:160,to:55,dur:.9,gain:.2,a:.005,d:.15,s:.4,r:.5,reverb:.35,filter:{type:'lowpass',freq:500,to:120}});
      noise({dur:.5,gain:.08,freq:200,type:'lowpass',reverb:.3,a:.005,r:.4});
      noise({dur:.15,gain:.05,freq:4000,type:'highpass',reverb:.2}); // лёгкий «воздух»
    },
    transition(){
      noise({dur:.7,gain:.06,freq:400,to:6000,type:'bandpass',q:.5,reverb:.26,a:.3,r:.4});
      voice({type:'sine',freq:220,to:880,dur:.7,gain:.1,a:.02,d:.1,s:.6,r:.3,voices:2,spread:8,reverb:.3,filter:{type:'lowpass',freq:5000}});
    },
    /* щелчок кассетного диктофона — для старта дела/кат-сцен */
    tape(){
      noise({dur:.02,gain:.16,freq:1800,type:'bandpass',q:3,reverb:.04}); // клик
      setTimeout(()=>noise({dur:.02,gain:.10,freq:1400,type:'bandpass',q:3,reverb:.04}),90); // второй клик
    },

    /* управление эмбиентом — вызывать при входе/выходе из дела */
    ambientOn(){ try{startAmbient();}catch(e){} },
    ambientOff(){ try{stopAmbient();}catch(e){} }
  };

  window.Sound = new Proxy(S,{
    get(target,prop){
      if(prop==='resume') return resume;
      if(prop==='toggle') return ()=>{ enabled=!enabled;
        try{localStorage.setItem('sdvig_sound',enabled?'1':'0');}catch(e){}
        if(!enabled) stopAmbient(); return enabled; };
      if(prop==='isOn') return ()=>enabled;
      const fn=target[prop];
      if(typeof fn==='function') return (...a)=>{ try{ resume(); return fn(...a);}catch(e){} };
      return fn;
    }
  });

  ['touchstart','pointerdown','click'].forEach(ev=>
    document.addEventListener(ev,resume,{once:true,passive:true}));
})();

