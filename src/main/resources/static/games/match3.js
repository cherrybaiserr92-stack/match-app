/* ═══════════════════════════════════════════════════════════
   СДВИГ · match3.js v10 — DOM/CSS, композиция Jewels Planet
   Фиксы v10:
   • невидимые фишки — появляются сразу + opacity-fade (без двойного rAF)
   • производительность — только transform/opacity (GPU), без box-shadow-анимаций
   • усилители — панель снизу со счётчиком + кнопка «+» (покупка) + пополнение по времени
   • звёзды-улики (прогресс), цель, ходы — как в Jewels Planet
   Контракт: Match3.start(container,{mission,boosters,onWin,onLose}) / .stop()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  const GEMS=[
    {id:'trace',  c1:'#ff7a86',c2:'#a51f2c',glow:'#ff5d6c'},
    {id:'witness',c1:'#6fd6ff',c2:'#155e8a',glow:'#5cd0ff'},
    {id:'exhibit',c1:'#52e0a6',c2:'#10704c',glow:'#46d89b'},
    {id:'alibi',  c1:'#f6d27a',c2:'#9a6a18',glow:'#ffcf6b'},
    {id:'link',   c1:'#bda6ff',c2:'#5a3fb0',glow:'#a98bff'}
  ];
  const NC=GEMS.length, N=8;
  const SP={NONE:0,LINEH:1,LINEV:2,BOMB:3,RAINBOW:4};
  const EMBLEM={
    trace:'<path d="M12 3C12 3 19 12 19 16a7 7 0 0 1-14 0c0-4 7-13 7-13z" fill="currentColor"/>',
    witness:'<ellipse cx="12" cy="12" rx="9" ry="6" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="12" r="3.4" fill="currentColor"/>',
    exhibit:'<circle cx="8" cy="12" r="4.5" fill="none" stroke="currentColor" stroke-width="2.2"/><path d="M12 12h8M17 12v4" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>',
    alibi:'<circle cx="12" cy="12" r="8.5" fill="none" stroke="currentColor" stroke-width="2"/><path d="M12 12V6.5M12 12l4.5 2.5" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/>',
    link:'<path d="M5 9c0 7 5 11 7 11s7-4 7-11" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/><circle cx="5" cy="8.5" r="2.4" fill="currentColor"/><circle cx="19" cy="8.5" r="2.4" fill="currentColor"/>'
  };
  const SPMARK={1:'↔',2:'↕',3:'✸',4:'★'};

  // усилители: восстанавливаются по времени (как в Jewels Planet)
  const BOOST_DEF=[
    {k:'shot',   field:'boosters', name:'Выстрел',   hint:'сбей одну фишку',     regenMs:6*60*1000,  max:3, price:100},
    {k:'siren',  field:'bSiren',   name:'Мигалка',   hint:'снять ряд и колонку', regenMs:10*60*1000, max:2, price:150},
    {k:'review', field:'bShuffle', name:'Пересмотр', hint:'перемешать доску',    regenMs:8*60*1000,  max:3, price:150}
  ];
  // рисованные иконки усилителей (сталь + кармин)
  const BOOST_ICON={
    shot:'<svg viewBox="0 0 40 40">'+
      '<rect x="13" y="12" width="21" height="5" rx="1.5" fill="#cfd8e3"/>'+
      '<rect x="13" y="12" width="21" height="1.8" fill="#eef4fb"/>'+
      '<rect x="9" y="10.5" width="9" height="9" rx="2" fill="#aebccb"/>'+
      '<circle cx="13.5" cy="15" r="2" fill="#39424e"/>'+
      '<path d="M11 19.5 L7 31 h7 l3.5-11.5z" fill="#8fa0b3"/>'+
      '<path d="M18 19.5h4l-1.8 4.5h-3z" fill="#6d7c8d"/>'+
      '<path d="M35 12.5l4.5 2-4.5 2 1.4-2z" fill="#ff8fa8"/></svg>',
    siren:'<svg viewBox="0 0 40 40">'+
      '<path d="M20 10a9 9 0 0 1 9 9v5H11v-5a9 9 0 0 1 9-9z" fill="#e0546e"/>'+
      '<path d="M20 10a9 9 0 0 1 9 9v1.5H11V19a9 9 0 0 1 9-9z" fill="#ff8fa8" opacity=".5"/>'+
      '<path d="M16 12a7 7 0 0 1 4-1.4V17h-6a7 7 0 0 1 2-5z" fill="#fff" opacity=".35"/>'+
      '<rect x="8" y="24" width="24" height="6" rx="2.5" fill="#93a1b3"/>'+
      '<rect x="8" y="24" width="24" height="2" rx="1" fill="#cfd8e3"/>'+
      '<path d="M20 2.5v4.5M6.5 6.5l3.2 3.2M33.5 6.5l-3.2 3.2" stroke="#ffd27d" stroke-width="2.6" stroke-linecap="round"/></svg>',
    review:'<svg viewBox="0 0 40 40">'+
      '<path d="M5 12.5v-2a2 2 0 0 1 2-2h6.5l3 3.5z" fill="#93a1b3"/>'+
      '<path d="M5 12.5h9.5l3 3h17.5v14a3 3 0 0 1-3 3H8a3 3 0 0 1-3-3z" fill="#cfd8e3"/>'+
      '<path d="M5 12.5h9.5l3 3h17.5v2H5z" fill="#aebccb"/>'+
      '<path d="M26.5 21.5a5.8 5.8 0 1 0 1.7 6.6" stroke="#8e1e36" stroke-width="2.8" fill="none" stroke-linecap="round"/>'+
      '<path d="M27.4 17.2l1.4 5.6-5.6-1.3z" fill="#8e1e36"/></svg>'
  };

  let opts=null, mission=null, moves=0, score=0, progress=0, combo=0, comboMax=0;
  let grid=[], ice=[], invMode=null, running=false, busy=false, sel=null, idleT=0, hintTimer=null;
  let timeLeft=0, timeUp=false, _timerIv=null, _lastMoves=-1, _lastStars=-1;
  let _root,_board,_hud,_bar,_stage,_cellPx=40,_resize,_cellBgs=null;
  const HINT_DELAY=6000;
  const STARS=[0.4,0.7,1.0]; // пороги «улик»-звёзд от target


  // формы огранки (общие для clipPath и тела)
  const GEM_PATHS={
    trace:'M24 3 C24 3 40 21 40 30.5 A16 16 0 0 1 8 30.5 C8 21 24 3 24 3 Z',
    witness:'M24 5 A19 19 0 1 1 23.99 5 Z',
    exhibit:'M15.5 5.5 L32.5 5.5 L42.5 15.5 L42.5 32.5 L32.5 42.5 L15.5 42.5 L5.5 32.5 L5.5 15.5 Z',
    alibi:'M24 2.5 L45 24 L24 45.5 L3 24 Z',
    link:'M24 3 L42.5 13.5 L42.5 34.5 L24 45 L5.5 34.5 L5.5 13.5 Z'
  };
  // дефы: богатые градиенты (4 стопа), стол, перелив, свечение, клипы огранки
  function injectGemDefs(){
    var old=document.getElementById('m3gem-defs'); if(old&&old.parentNode) old.parentNode.removeChild(old);
    var NS='http://www.w3.org/2000/svg';
    var HUES={
      red:   ['#ffd4d8','#ff6d7c','#d92739','#6e0a16'],
      blue:  ['#dff5ff','#5fc6ff','#1f7fc4','#083a5e'],
      green: ['#d8ffe9','#5ce8ab','#17a86c','#064a2e'],
      amber: ['#fff3d0','#ffd06a','#e8981f','#6e4004'],
      violet:['#f0e4ff','#c09aff','#7a48d8','#2e1560']
    };
    var svg=document.createElementNS(NS,'svg'); svg.id='m3gem-defs';
    svg.setAttribute('width','0'); svg.setAttribute('height','0'); svg.style.position='absolute';
    var html='';
    Object.keys(HUES).forEach(function(k){ var h=HUES[k];
      html+='<radialGradient id="m3g-'+k+'" cx="36%" cy="26%" r="85%">'+
        '<stop offset="0%" stop-color="'+h[0]+'"/><stop offset="30%" stop-color="'+h[1]+'"/>'+
        '<stop offset="68%" stop-color="'+h[2]+'"/><stop offset="100%" stop-color="'+h[3]+'"/></radialGradient>'+
        '<linearGradient id="m3t-'+k+'" x1="0" y1="0" x2="0" y2="1">'+
        '<stop offset="0%" stop-color="'+h[0]+'" stop-opacity=".8"/>'+
        '<stop offset="55%" stop-color="'+h[1]+'" stop-opacity=".28"/>'+
        '<stop offset="100%" stop-color="'+h[2]+'" stop-opacity=".5"/></linearGradient>';
    });
    html+='<linearGradient id="m3sheenG" x1="0" y1="0" x2="1" y2="0">'+
      '<stop offset="0%" stop-color="#fff" stop-opacity="0"/>'+
      '<stop offset="35%" stop-color="#bfe8ff" stop-opacity=".25"/>'+
      '<stop offset="50%" stop-color="#ffffff" stop-opacity=".6"/>'+
      '<stop offset="65%" stop-color="#ffc8e0" stop-opacity=".25"/>'+
      '<stop offset="100%" stop-color="#fff" stop-opacity="0"/></linearGradient>'+
     '<radialGradient id="m3glow" cx="50%" cy="50%" r="50%">'+
      '<stop offset="0%" stop-color="#fff" stop-opacity=".9"/>'+
      '<stop offset="100%" stop-color="#fff" stop-opacity="0"/></radialGradient>';
    Object.keys(GEM_PATHS).forEach(function(id){
      html+='<clipPath id="m3clip-'+id+'"><path d="'+GEM_PATHS[id]+'"/></clipPath>'; });
    var defs=document.createElementNS(NS,'defs'); defs.innerHTML=html;
    svg.appendChild(defs); document.body.appendChild(svg);
  }

  // острый 4-лучевой блик (вместо мутного пятна)
  function glintAt(x,y,s,o){
    return '<path d="M0 -5.2 L1.3 -1.3 L5.2 0 L1.3 1.3 L0 5.2 L-1.3 1.3 L-5.2 0 L-1.3 -1.3 Z" fill="#fff" opacity="'+(o||.95)+'" transform="translate('+x+' '+y+') scale('+(s||1)+')"/>';
  }

  /* премиум-самоцвет: огранка с фасетами, стол, внутренний ободок,
     отражённый свет снизу, острые блики и бегущий радужный перелив */
  function gemSVG(gid){
    var G={
      trace:{hue:'red', facets:
        '<path d="M24 3 L13.5 26.5 L24 33.5 Z" fill="#fff" opacity=".16"/>'+
        '<path d="M24 3 L34.5 26.5 L24 33.5 Z" fill="#000" opacity=".18"/>'+
        '<path d="M24 3 L8.5 28 L13.5 26.5 Z" fill="#fff" opacity=".07"/>'+
        '<path d="M24 3 L39.5 28 L34.5 26.5 Z" fill="#000" opacity=".1"/>'+
        '<path d="M10 28 Q24 34.5 38 28" fill="none" stroke="#fff" stroke-opacity=".22" stroke-width="1.1"/>'+
        '<ellipse cx="24" cy="36" rx="9" ry="5" fill="url(#m3glow)" opacity=".45"/>'+
        glintAt(19,14,.9)+glintAt(29,25,.45,.6)},
      witness:{hue:'blue', facets:
        '<rect x="12" y="8" width="7" height="11" rx="3.4" transform="rotate(-28 15.5 13.5)" fill="#fff" opacity=".5"/>'+
        '<rect x="20.5" y="6.5" width="3.2" height="6.5" rx="1.6" transform="rotate(-28 22 9.5)" fill="#fff" opacity=".38"/>'+
        '<circle cx="24" cy="24" r="12.8" fill="none" stroke="#fff" stroke-opacity=".15" stroke-width="1.4"/>'+
        '<circle cx="25.5" cy="26" r="7" fill="#083a5e" opacity=".45"/>'+
        '<circle cx="25.5" cy="26" r="7" fill="none" stroke="#9fdcff" stroke-opacity=".35" stroke-width="1"/>'+
        '<ellipse cx="24" cy="36" rx="10" ry="4.5" fill="url(#m3glow)" opacity=".35"/>'+
        glintAt(31,13,.55,.75)},
      exhibit:{hue:'green', facets:
        '<path d="M15.5 5.5 L32.5 5.5 L29.5 11.5 L18.5 11.5 Z" fill="#fff" opacity=".18"/>'+
        '<path d="M5.5 15.5 L15.5 5.5 L18.5 11.5 L11.5 18.5 Z" fill="#fff" opacity=".12"/>'+
        '<path d="M15.5 42.5 L32.5 42.5 L29.5 36.5 L18.5 36.5 Z" fill="#000" opacity=".22"/>'+
        '<path d="M42.5 32.5 L32.5 42.5 L29.5 36.5 L36.5 29.5 Z" fill="#000" opacity=".16"/>'+
        '<path d="M17 8.5 L31 8.5 L39.5 17 L39.5 31 L31 39.5 L17 39.5 L8.5 31 L8.5 17 Z" fill="none" stroke="#fff" stroke-opacity=".2" stroke-width="1.2"/>'+
        '<rect x="15" y="15" width="18" height="18" rx="2.5" fill="url(#m3t-green)" stroke="#fff" stroke-opacity=".18"/>'+
        '<ellipse cx="24" cy="33" rx="8" ry="3.5" fill="url(#m3glow)" opacity=".3"/>'+
        glintAt(14,13,.8)+glintAt(33,32,.4,.5)},
      alibi:{hue:'amber', facets:
        '<path d="M24 2.5 L33 15 L24 24 L15 15 Z" fill="#fff" opacity=".18"/>'+
        '<path d="M45 24 L33 33 L24 24 L33 15 Z" fill="#000" opacity=".1"/>'+
        '<path d="M24 45.5 L15 33 L24 24 L33 33 Z" fill="#000" opacity=".22"/>'+
        '<path d="M3 24 L15 15 L24 24 L15 33 Z" fill="#fff" opacity=".08"/>'+
        '<path d="M24 13.5 L34.5 24 L24 34.5 L13.5 24 Z" fill="url(#m3t-amber)" stroke="#fff" stroke-opacity=".2"/>'+
        '<ellipse cx="24" cy="33" rx="7" ry="3.5" fill="url(#m3glow)" opacity=".35"/>'+
        glintAt(24,11,.85)+glintAt(13,24,.4,.55)},
      link:{hue:'violet', facets:
        '<path d="M24 3 L42.5 13.5 L24 24 Z" fill="#fff" opacity=".17"/>'+
        '<path d="M42.5 13.5 L42.5 34.5 L24 24 Z" fill="#000" opacity=".08"/>'+
        '<path d="M42.5 34.5 L24 45 L24 24 Z" fill="#000" opacity=".2"/>'+
        '<path d="M24 45 L5.5 34.5 L24 24 Z" fill="#000" opacity=".14"/>'+
        '<path d="M5.5 34.5 L5.5 13.5 L24 24 Z" fill="#fff" opacity=".06"/>'+
        '<path d="M5.5 13.5 L24 3 L24 24 Z" fill="#fff" opacity=".12"/>'+
        '<path d="M24 12 L34.5 18 L34.5 30 L24 36 L13.5 30 L13.5 18 Z" fill="url(#m3t-violet)" stroke="#fff" stroke-opacity=".18"/>'+
        '<ellipse cx="24" cy="32" rx="8" ry="3.5" fill="url(#m3glow)" opacity=".3"/>'+
        glintAt(18,11,.85)+glintAt(31,30,.4,.5)}
    };
    var g=G[gid]||G.trace;
    var body=GEM_PATHS[gid]||GEM_PATHS.trace;
    var delay=(Math.random()*4.6).toFixed(2);
    return '<svg viewBox="0 0 48 48" style="width:100%;height:100%;display:block;overflow:visible">'+
      '<path d="'+body+'" fill="url(#m3g-'+g.hue+')" stroke="#000" stroke-opacity=".5" stroke-width="1.3"/>'+
      g.facets+
      '<path d="'+body+'" fill="none" stroke="#fff" stroke-opacity=".26" stroke-width="1.2" transform="translate(24 24) scale(.93) translate(-24 -24)"/>'+
      '<g clip-path="url(#m3clip-'+gid+')">'+
        '<rect class="gsheen" style="animation-delay:-'+delay+'s" x="-30" y="-8" width="20" height="64" fill="url(#m3sheenG)"/>'+
      '</g>'+
    '</svg>';
  }

  window.Match3={
    start(container,o){
      opts=o||{}; mission=opts.mission||{type:'score',target:600,moves:14};
      moves=mission.moves||14; score=0; progress=0; combo=0; comboMax=0;
      invMode=null; sel=null; busy=false; running=true; idleT=0; _lastMoves=-1; _lastStars=-1;
      try{ if(window.BgFx&&BgFx.pause) BgFx.pause(); }catch(e){}
      regenAll();
      injectGemDefs(); injectCSS(); buildDOM(container); initGrid(); renderBar(); hud(); startTimer(); scheduleHint();
    },
    _dbg:{ getIce:function(){return ice.slice();},
      clearAt:function(k){ clearSet(new Set([k])); },
      setIce:function(k,v){ice[k]=v; if(typeof renderIce==='function')renderIce();},
      getGrid:function(){return grid.map(function(g){return g?g.c:-9;});},
      setSp:function(k,c,sp){ if(grid[k]&&grid[k].el&&grid[k].el.parentNode)grid[k].el.parentNode.removeChild(grid[k].el);
        grid[k]={c:c,sp:sp,el:makeGem(c,sp)}; _board.appendChild(grid[k].el); place(grid[k].el,k,false); },
      swap:function(a,b){ trySwap(a,b); } },
    stop(){ running=false; clearTimeout(hintTimer); clearInterval(_timerIv); clearInterval(barTick);
      try{ window.removeEventListener('resize',_resize); }catch(e){}
      if(_root&&_root.parentNode) _root.parentNode.innerHTML=''; _cellBgs=null; _iceEls=null; _boostEls=null; }
  };

  /* ── восстановление усилителей по времени ── */
  function regenAll(){
    const p=(window.App&&App.profile); if(!p) return;
    let changed=false;
    if(!p.boostTs) p.boostTs={};
    // стартовый запас новичку — чтобы усилители можно было попробовать сразу
    if(!p._boostInit){ p._boostInit=1;
      if(!p.boosters)p.boosters=2; if(!p.bSiren)p.bSiren=1; if(!p.bShuffle)p.bShuffle=2; changed=true; }
    const now=Date.now();
    BOOST_DEF.forEach(b=>{
      const cur=p[b.field]||0;
      if(cur>=b.max){ p.boostTs[b.k]=now; return; }
      const last=p.boostTs[b.k]||now;
      const gained=Math.floor((now-last)/b.regenMs);
      if(gained>0){ p[b.field]=Math.min(b.max,cur+gained); p.boostTs[b.k]=last+gained*b.regenMs;
        if(p[b.field]>=b.max)p.boostTs[b.k]=now; changed=true; }
      else if(!p.boostTs[b.k]){ p.boostTs[b.k]=now; changed=true; }
    });
    if(changed){ try{ window.saveProfile&&saveProfile(); }catch(e){} }
  }
  function boostLeftMs(b){ const p=(window.App&&App.profile); if(!p)return 0;
    const cur=p[b.field]||0; if(cur>=b.max)return 0;
    const last=(p.boostTs&&p.boostTs[b.k])||Date.now();
    return b.regenMs-((Date.now()-last)%b.regenMs); }

  /* ── CSS ── */
  function injectCSS(){
    if(document.getElementById('m3v10-css')) return;
    const s=document.createElement('style'); s.id='m3v10-css';
    s.textContent=`
    .m3root{position:absolute;inset:0;display:flex;flex-direction:column;background:radial-gradient(circle at 50% 20%,#16141a,#050507);overflow:hidden;}
    /* фон главы: место действия сюжета за доской (Jewels Planet style) */
    .m3bg{position:absolute;inset:-26px;background-size:cover;background-position:center 32%;
      filter:blur(2px) brightness(.62) saturate(.9);transform:scale(1.05);}
    .m3vig{position:absolute;inset:0;background:
      radial-gradient(135% 100% at 50% 34%, transparent 46%, rgba(3,4,7,.7) 100%),
      linear-gradient(180deg,rgba(4,5,8,.5),rgba(4,5,8,.08) 30%,rgba(4,5,8,.1) 62%,rgba(4,5,8,.6));}
    .m3top,.m3stage,.m3bar{position:relative;z-index:1;}
    .m3top{flex:0 0 auto;padding:10px 12px 6px;display:flex;align-items:stretch;gap:8px;font-family:Unbounded,sans-serif;}
    /* чипы ХОДЫ / ВРЕМЯ — крупные, как в Jewels Planet */
    .m3chip{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1px;
      min-width:62px;padding:5px 8px;border-radius:14px;
      background:linear-gradient(165deg,rgba(26,22,28,.93),rgba(10,8,12,.97));border:1px solid #000;
      box-shadow:0 8px 18px rgba(0,0,0,.55),inset 0 1px 0 rgba(255,255,255,.09),0 0 0 1px rgba(255,255,255,.05);}
    .m3chip .l{font-size:8px;color:#93a1b3;letter-spacing:.12em;white-space:nowrap;}
    .m3chip .n{font-size:25px;font-weight:900;line-height:1.02;color:#fff;font-variant-numeric:tabular-nums;}
    .m3chip .n.bump{animation:m3bump .32s cubic-bezier(.2,1.6,.4,1);}
    @keyframes m3bump{0%{transform:scale(1)}40%{transform:scale(1.4)}100%{transform:scale(1)}}
    .m3chip .n.low{color:#ff6470;text-shadow:0 0 14px rgba(255,80,100,.7);animation:m3lowPulse 1s ease-in-out infinite;}
    @keyframes m3lowPulse{0%,100%{transform:scale(1)}50%{transform:scale(1.14)}}
    .m3timer .n{font-size:18px;letter-spacing:.02em;}
    .m3goalwrap{flex:1;display:flex;flex-direction:column;gap:7px;justify-content:center;
      padding:6px 10px;border-radius:14px;
      background:linear-gradient(165deg,rgba(26,22,28,.93),rgba(10,8,12,.97));border:1px solid #000;
      box-shadow:0 8px 18px rgba(0,0,0,.55),inset 0 1px 0 rgba(255,255,255,.09),0 0 0 1px rgba(255,255,255,.05);}
    .m3goalrow{display:flex;align-items:center;gap:8px;}
    .m3goalico{width:26px;height:26px;flex:0 0 auto;display:inline-flex;filter:drop-shadow(0 2px 4px rgba(0,0,0,.5));}
    .m3goalemoji{font-size:20px;align-items:center;justify-content:center;}
    .m3goaltxt{font-family:Unbounded,sans-serif;font-weight:700;font-size:12px;letter-spacing:.03em;color:#e6edf5;}
    .m3star{width:20px;height:20px;color:#3a3f48;transition:color .3s,transform .3s;}
    .m3star.ontrack{position:absolute;top:50%;transform:translate(-50%,-50%);}
    .m3star.ontrack.on{color:#46d89b;transform:translate(-50%,-50%) scale(1.15);filter:drop-shadow(0 0 6px rgba(70,216,155,.8));}
    .m3star.ontrack.gain{animation:m3starGain .6s cubic-bezier(.2,1.6,.4,1);}
    @keyframes m3starGain{0%{transform:translate(-50%,-50%) scale(2.6)}100%{transform:translate(-50%,-50%) scale(1.15)}}
    .m3star svg{width:100%;height:100%;display:block;fill:currentColor;stroke:#0a0c10;stroke-width:1.2;}
    .m3track{position:relative;height:8px;border-radius:6px;background:rgba(255,255,255,.08);margin-right:10px;
      box-shadow:inset 0 1px 2px rgba(0,0,0,.5);}
    .m3fill{height:100%;border-radius:6px;background:linear-gradient(90deg,#2a9d6f,#46d89b);transition:width .35s cubic-bezier(.3,1,.4,1);box-shadow:0 0 8px rgba(70,216,155,.45);}
    .m3stage{flex:1 1 auto;display:flex;align-items:center;justify-content:center;min-height:0;position:relative;}
    .m3board{position:relative;touch-action:none;border-radius:14px;
      background:linear-gradient(160deg,rgba(33,32,38,.93),rgba(9,9,12,.95) 60%,rgba(0,0,0,.97));padding:3px;border:1px solid #000;
      box-shadow:inset 0 0 34px rgba(0,0,0,.6),0 16px 38px rgba(0,0,0,.65),0 0 0 1px rgba(255,255,255,.06);}
    .m3cellbg{position:absolute;border-radius:8px;background:rgba(255,255,255,.022);box-shadow:inset 0 1px 2px rgba(0,0,0,.5);}
    .m3cellbg.alt{background:rgba(255,255,255,.055);}
    /* фишка: ТОЛЬКО transform/opacity анимируются (GPU) */
    .m3gem{position:absolute;will-change:transform;cursor:pointer;
      transition:transform .15s cubic-bezier(.34,1.4,.6,1);}
    .m3gem.fall{transition:transform .3s cubic-bezier(.3,1.45,.45,1);}
    .m3gem.spawn{animation:m3spawn .26s ease forwards;}
    @keyframes m3spawn{from{opacity:0}to{opacity:1}}
    .m3gem.pop{animation:m3pop .26s ease forwards;}
    @keyframes m3pop{
      0%{transform:translate3d(var(--tx),var(--ty),0) scale(1);filter:brightness(1)}
      35%{transform:translate3d(var(--tx),var(--ty),0) scale(1.28);filter:brightness(2.1)}
      100%{transform:translate3d(var(--tx),var(--ty),0) scale(0);opacity:0;filter:brightness(2.4)}}
    .m3gem.sel{z-index:3;animation:m3sel .55s ease-in-out infinite;}
    @keyframes m3sel{0%,100%{transform:translate3d(var(--tx),var(--ty),0) scale(1)}50%{transform:translate3d(var(--tx),var(--ty),0) scale(1.1)}}
    .m3gem.hint .gemstone{animation:m3hintPulse .8s ease-in-out infinite;}
    @keyframes m3hintPulse{0%,100%{transform:scale(1)}50%{transform:scale(1.12)}}
    .gemstone{position:absolute;inset:5%;}
    /* бегущий радужный перелив внутри каждого самоцвета */
    .gsheen{animation:gemSheen 4.6s cubic-bezier(.45,.1,.35,1) infinite;transform:rotate(16deg);}
    @keyframes gemSheen{
      0%{transform:rotate(16deg) translateX(-6px)}
      48%{transform:rotate(16deg) translateX(84px)}
      100%{transform:rotate(16deg) translateX(84px)}}
    /* лёд: вмороженная клетка */
    .m3ice{position:absolute;border-radius:8px;z-index:4;pointer-events:none;
      background:linear-gradient(158deg,rgba(168,214,255,.34),rgba(96,146,208,.20));
      border:1px solid rgba(196,232,255,.55);
      box-shadow:inset 0 1px 3px rgba(255,255,255,.35), inset 0 -2px 4px rgba(40,80,140,.3);}
    .m3ice.lv2{background:linear-gradient(158deg,rgba(198,232,255,.5),rgba(120,168,224,.34));
      border-color:rgba(220,242,255,.8);}
    .m3ice.cracked{background-image:linear-gradient(158deg,rgba(168,214,255,.28),rgba(96,146,208,.16)),
      url('data:image/svg+xml;utf8,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 40 40"><path d="M8 6 L20 19 L14 30 M20 19 L33 12 M20 19 L27 33" stroke="white" stroke-opacity=".55" stroke-width="1.2" fill="none"/></svg>');
      background-size:cover;}
    .m3iceshard{position:absolute;width:7px;height:7px;pointer-events:none;will-change:transform,opacity;
      background:linear-gradient(140deg,#dff0ff,#8ab6e8);border-radius:2px;}
    .m3gem.frozenshake{animation:m3fshake .32s ease;}
    @keyframes m3fshake{0%,100%{}25%{margin-left:-4px}75%{margin-left:4px}}
    .m3flash{position:absolute;width:8px;height:8px;border-radius:50%;pointer-events:none;
      background:#fff;box-shadow:0 0 18px 10px rgba(255,255,255,.55);
      transform:translate(-50%,-50%);animation:m3fl .3s ease-out forwards;}
    @keyframes m3fl{from{opacity:.9;transform:translate(-50%,-50%) scale(.6)}to{opacity:0;transform:translate(-50%,-50%) scale(2.2)}}
    .m3stage.bigshake{animation:m3bigshake .34s ease;}
    @keyframes m3bigshake{0%,100%{transform:none}20%{transform:translate(-5px,2px)}45%{transform:translate(5px,-3px)}70%{transform:translate(-3px,-2px)}}
    /* спецфишка-линия: бегущий блик + стрелки-наконечники */
    .spline{position:absolute;inset:0;pointer-events:none;z-index:2;}
    .spline b{position:absolute;width:19%;height:19%;background:#fff;
      filter:drop-shadow(0 0 4px rgba(255,255,255,.95)) drop-shadow(0 1px 1px rgba(0,0,0,.6));}
    .spline.h b.l{left:2%;top:50%;transform:translateY(-50%);clip-path:polygon(100% 0,0 50%,100% 100%);}
    .spline.h b.r{right:2%;top:50%;transform:translateY(-50%);clip-path:polygon(0 0,100% 50%,0 100%);}
    .spline.v b.u{top:2%;left:50%;transform:translateX(-50%);clip-path:polygon(0 100%,50% 0,100% 100%);}
    .spline.v b.d{bottom:2%;left:50%;transform:translateX(-50%);clip-path:polygon(0 0,50% 100%,100% 0);}
    .spline.h::before{content:'';position:absolute;left:12%;right:12%;top:44%;height:12%;border-radius:6px;
      background:linear-gradient(90deg,transparent,rgba(255,255,255,.95),transparent);
      animation:spStreak 1s ease-in-out infinite alternate;}
    .spline.v::before{content:'';position:absolute;top:12%;bottom:12%;left:44%;width:12%;border-radius:6px;
      background:linear-gradient(180deg,transparent,rgba(255,255,255,.95),transparent);
      animation:spStreak 1s ease-in-out infinite alternate;}
    @keyframes spStreak{from{opacity:.4}to{opacity:1}}
    /* спецфишка-бомба: пульсирующее кольцо */
    .spbomb{position:absolute;inset:24%;border-radius:50%;pointer-events:none;z-index:2;
      border:2.5px solid rgba(255,255,255,.95);
      box-shadow:0 0 10px rgba(255,255,255,.8),inset 0 0 8px rgba(255,255,255,.55);
      animation:spBomb .9s ease-in-out infinite;}
    .spbomb::after{content:'';position:absolute;inset:28%;border-radius:50%;
      background:radial-gradient(circle,#fff 20%,rgba(255,255,255,0) 72%);opacity:.85;}
    @keyframes spBomb{0%,100%{transform:scale(1);opacity:.95}50%{transform:scale(1.18);opacity:.6}}
    /* радужная сфера (цветобомба) */
    .m3orb{position:absolute;inset:9%;border-radius:50%;
      background:conic-gradient(#ff5d6c,#ffcf6b,#46d89b,#5cd0ff,#a98bff,#ff5d6c);
      box-shadow:0 0 16px rgba(255,255,255,.55),0 4px 10px rgba(0,0,0,.5),inset 0 0 12px rgba(0,0,0,.3);
      animation:orbHue 3s linear infinite;}
    .m3orb::before{content:'';position:absolute;inset:12%;border-radius:50%;
      background:radial-gradient(circle at 34% 28%,rgba(255,255,255,.95),rgba(255,255,255,.05) 52%,transparent);}
    .m3orbspark{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-style:normal;
      font-size:13px;color:#fff;text-shadow:0 0 8px #fff;animation:orbSpark 1.4s ease-in-out infinite;}
    @keyframes orbHue{to{filter:hue-rotate(360deg)}}
    @keyframes orbSpark{0%,100%{transform:translate(-50%,-50%) scale(1)}50%{transform:translate(-50%,-50%) scale(1.35)}}
    /* комета спецфишки: белое ядро + карминовый хвост, летит по ряду */
    .m3comet{position:absolute;pointer-events:none;z-index:6;width:46px;height:9px;border-radius:5px;
      background:linear-gradient(90deg,rgba(255,110,140,0),rgba(255,120,150,.75) 55%,#fff 90%);
      box-shadow:0 0 16px 4px rgba(255,100,130,.55);}
    .m3comet::after{content:'';position:absolute;right:-3px;top:50%;width:13px;height:13px;border-radius:50%;
      transform:translateY(-50%);background:radial-gradient(circle,#fff 30%,rgba(255,150,175,.65) 60%,transparent 75%);}
    /* след кометы: мягкое свечение ряда */
    .m3rowglow{position:absolute;pointer-events:none;z-index:5;border-radius:8px;
      background:linear-gradient(90deg,transparent,rgba(255,110,140,.22),transparent);
      animation:m3rowGl .45s ease-out forwards;}
    @keyframes m3rowGl{0%{opacity:0}30%{opacity:1}100%{opacity:0}}
    /* всплывающие очки */
    .m3pts{position:absolute;z-index:7;pointer-events:none;transform:translate(-50%,0);
      font-family:Unbounded,sans-serif;font-weight:900;font-size:14px;color:#fff;
      text-shadow:0 0 10px rgba(255,255,255,.75),0 2px 4px #000;animation:m3ptsUp .8s ease-out forwards;}
    @keyframes m3ptsUp{0%{opacity:0;transform:translate(-50%,4px) scale(.7)}18%{opacity:1;transform:translate(-50%,-4px) scale(1.15)}100%{opacity:0;transform:translate(-50%,-32px) scale(1)}}
    /* вспышка на всю доску (двойная радуга) */
    .m3mega{position:absolute;inset:0;z-index:8;pointer-events:none;border-radius:14px;
      background:radial-gradient(circle at 50% 50%,rgba(255,255,255,.85),rgba(255,255,255,.15) 60%,transparent);
      animation:m3megaFl .55s ease-out forwards;}
    @keyframes m3megaFl{0%{opacity:0}25%{opacity:1}100%{opacity:0}}
    .m3board.aim{cursor:crosshair;}
    .m3board.aim .m3cellbg{background:rgba(224,84,110,.06);}
    /* панель усилителей снизу (Jewels Planet style) */
    .m3bar{flex:0 0 auto;display:flex;gap:12px;justify-content:center;padding:8px 10px max(10px,env(safe-area-inset-bottom));}
    .m3boost{position:relative;width:76px;height:66px;border-radius:16px;cursor:pointer;touch-action:manipulation;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));
      border:1px solid #000;box-shadow:0 6px 16px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.07),0 0 0 1px rgba(255,255,255,.05);
      display:flex;flex-direction:column;align-items:center;justify-content:center;gap:1px;
      transition:transform .12s,border-color .15s,box-shadow .15s;}
    .m3boost.on{border-color:#e0546e;box-shadow:0 0 16px rgba(224,84,110,.5),inset 0 1px 0 rgba(255,255,255,.07);transform:translateY(-3px);}
    .m3boost:active{transform:scale(.93);}
    .m3boost .bi{width:30px;height:30px;}
    .m3boost .bi svg{width:100%;height:100%;display:block;filter:drop-shadow(0 2px 3px rgba(0,0,0,.6));}
    .m3boost .bname{font-family:Unbounded,sans-serif;font-size:8px;font-weight:700;color:#e6edf5;letter-spacing:.03em;}
    .m3boost .btimer{font-size:8px;color:#93a1b3;line-height:1;}
    .m3boost .bcount{position:absolute;top:-8px;right:-8px;min-width:22px;height:22px;border-radius:11px;padding:0 5px;
      background:linear-gradient(180deg,#ff8fa8,#8e1e36);border:2px solid #14060a;color:#fff;font-weight:900;font-size:12px;
      display:flex;align-items:center;justify-content:center;line-height:1;box-shadow:0 2px 6px rgba(0,0,0,.5);}
    .m3boost.empty .bcount{background:linear-gradient(180deg,#5fd16a,#2e9b3a);border-color:#0d2712;}
    .m3burst{position:absolute;border-radius:50%;pointer-events:none;will-change:transform,opacity;}
    .m3spark{position:absolute;pointer-events:none;will-change:transform,opacity;line-height:1;
      font-family:sans-serif;color:#fff;}
    .m3combo{position:absolute;top:36%;left:0;right:0;text-align:center;pointer-events:none;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:30px;color:#ff8fa8;text-shadow:0 0 22px #8e1e36;
      animation:m3combo 1s ease forwards;}
    @keyframes m3combo{0%{opacity:0;transform:translateY(10px) scale(.8)}25%{opacity:1;transform:translateY(0) scale(1.1)}100%{opacity:0;transform:translateY(-26px)}}
    .m3ring{position:absolute;border-radius:50%;pointer-events:none;will-change:transform,opacity;border:3px solid #fff;}
    .m3end{position:absolute;inset:0;z-index:10;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;
      background:radial-gradient(60% 50% at 50% 45%,rgba(10,14,22,.75),rgba(4,7,12,.96));animation:m3fade .4s ease;}
    @keyframes m3fade{from{opacity:0}to{opacity:1}}
    .m3end .v{font-family:Unbounded,sans-serif;font-weight:900;font-size:25px;}
    .m3end .s{font-size:13px;color:#9aa3b2;}
    .m3endstars{display:flex;gap:14px;margin-bottom:4px;}
    .m3endstar{width:44px;height:44px;color:#2c3138;}
    .m3endstar svg{width:100%;height:100%;fill:currentColor;stroke:#0a0c10;stroke-width:1;}
    .m3endstar.earn{color:#46d89b;opacity:0;transform:scale(2.2);
      animation:m3starIn .45s cubic-bezier(.2,1.6,.4,1) forwards;filter:drop-shadow(0 0 12px rgba(70,216,155,.8));}
    @keyframes m3starIn{to{opacity:1;transform:scale(1)}}
    `;
    document.head.appendChild(s);
  }

  /* ── каркас ── */
  function buildDOM(container){
    container.innerHTML='';
    _root=document.createElement('div'); _root.className='m3root';
    // фон главы — место действия сюжета за доской
    const bgUrl=mission.bg||(window.CHAPTER_BGS&&window.CHAPTER_BGS[mission.chapter||1])||null;
    if(bgUrl){
      const bg=document.createElement('div'); bg.className='m3bg';
      bg.style.backgroundImage='url("'+bgUrl+'")'; _root.appendChild(bg);
      const vig=document.createElement('div'); vig.className='m3vig'; _root.appendChild(vig);
    }
    _hud=document.createElement('div'); _hud.className='m3top';
    _hud.innerHTML=
      '<div class="m3chip m3moves"><span class="l">ХОДЫ</span><span class="n" id="m3mv"></span></div>'+
      '<div class="m3goalwrap">'+
        '<div class="m3goalrow" id="m3goalrow"></div>'+
        '<div class="m3track" id="m3track"><div class="m3fill" id="m3fill" style="width:0%"></div>'+
          [0,1,2].map(i=>'<span class="m3star ontrack" data-st="'+i+'" style="left:'+(STARS[i]*100)+'%">'+STAR_SVG+'</span>').join('')+
        '</div>'+
      '</div>'+
      ((mission.time|0)>0?'<div class="m3chip m3timer"><span class="l">ВРЕМЯ</span><span class="n" id="m3tm"></span></div>':'');
    _stage=document.createElement('div'); _stage.className='m3stage';
    _board=document.createElement('div'); _board.className='m3board';
    _stage.appendChild(_board);
    _bar=document.createElement('div'); _bar.className='m3bar';
    _root.appendChild(_hud); _root.appendChild(_stage); _root.appendChild(_bar);
    container.appendChild(_root);
    _cellBgs=null; _resize=()=>layout(); window.addEventListener("resize",_resize);
    layout();
  }
  function layout(){
    if(!_stage) return;
    const r=_stage.getBoundingClientRect();
    const avail=Math.min(r.width||340, r.height||440)-6;
    _cellPx=Math.max(28,Math.floor(avail/N));
    const px=_cellPx*N;
    _board.style.width=px+'px'; _board.style.height=px+'px';
    if(!_cellBgs){ _cellBgs=[];
      for(let y=0;y<N;y++)for(let x=0;x<N;x++){ const c=document.createElement('div');
        c.className='m3cellbg'+(((x+y)%2)?' alt':''); _board.appendChild(c); _cellBgs.push(c); }
    }
    let bi=0;
    for(let y=0;y<N;y++)for(let x=0;x<N;x++){ const c=_cellBgs[bi++]; if(!c)continue;
      c.style.left=(x*_cellPx+2)+'px'; c.style.top=(y*_cellPx+2)+'px';
      c.style.width=(_cellPx-4)+'px'; c.style.height=(_cellPx-4)+'px'; }
    for(let k=0;k<N*N;k++){ if(grid[k]&&grid[k].el) place(grid[k].el,k,false); }
    if(_iceEls) renderIce();
  }

  /* ── сетка ── */
  function initGrid(){
    grid=new Array(N*N); ice=new Array(N*N).fill(0);
    for(let k=0;k<N*N;k++) grid[k]={c:rnd(),sp:SP.NONE,el:null};
    let guard=0; while(findMatches().length&&guard++<200){ findMatches().forEach(g=>g.forEach(k=>grid[k].c=rnd())); }
    // лёд: mission.ice клеток в средней зоне; на глубоких главах часть двухслойные
    var nIce=(mission.ice|0);
    if(nIce>0){
      var cand=[]; for(let y=2;y<N-1;y++)for(let x=0;x<N;x++)cand.push(idx(x,y));
      cand.sort(function(){return Math.random()-0.5;});
      for(var i=0;i<Math.min(nIce,cand.length);i++){
        ice[cand[i]]=(mission.chapter>=4 && i<nIce/3)?2:1;
      }
    }
    for(let k=0;k<N*N;k++){ grid[k].el=makeGem(grid[k].c,grid[k].sp); _board.appendChild(grid[k].el); place(grid[k].el,k,false); }
    renderIce();
    bindInput();
  }
  // слой льда: элементы поверх cellbg, под камнями
  var _iceEls=null;
  function renderIce(){
    if(!_iceEls){ _iceEls=[];
      for(let k=0;k<N*N;k++){ const d=document.createElement('div'); d.className='m3ice'; d.style.display='none';
        _board.appendChild(d); _iceEls.push(d); } }
    for(let k=0;k<N*N;k++){
      const d=_iceEls[k], x=k%N, y=k/N|0, lv=ice[k];
      d.style.left=(x*_cellPx+2)+'px'; d.style.top=(y*_cellPx+2)+'px';
      d.style.width=(_cellPx-4)+'px'; d.style.height=(_cellPx-4)+'px';
      d.style.display=lv>0?'block':'none';
      d.classList.toggle('lv2', lv>=2);
      d.classList.toggle('cracked', lv===1 && d._wasHit===true);
    }
  }
  function hitIce(k){
    if(ice[k]<=0) return false;
    ice[k]--;
    if(_iceEls&&_iceEls[k]) _iceEls[k]._wasHit=true;
    iceShatter(k);
    try{Sound.tap&&Sound.tap();}catch(_){}
    return true; // лёд поглотил удар
  }
  function iceShatter(k){
    const x=k%N,y=k/N|0;
    for(let i=0;i<6;i++){ const p=document.createElement('div'); p.className='m3iceshard';
      p.style.left=(x*_cellPx+_cellPx/2)+'px'; p.style.top=(y*_cellPx+_cellPx/2)+'px';
      const a=Math.random()*6.28,d2=12+Math.random()*20; _board.appendChild(p);
      requestAnimationFrame(()=>{ p.style.transition='transform .5s ease-out,opacity .5s';
        p.style.opacity='0'; p.style.transform='translate3d('+(Math.cos(a)*d2)+'px,'+(Math.sin(a)*d2+10)+'px,0) rotate('+(Math.random()*180-90)+'deg)'; });
      setTimeout(()=>{ if(p.parentNode)p.parentNode.removeChild(p); },520); }
  }
  function rnd(){ return Math.floor(Math.random()*NC); }
  const idx=(x,y)=>y*N+x;
  const inb=(x,y)=>x>=0&&x<N&&y>=0&&y<N;

  function makeGem(c,sp){
    const g=GEMS[c]||GEMS[0];
    const el=document.createElement('div'); el.className='m3gem';
    if(sp===SP.RAINBOW){ // радужная сфера — как цветобомба в JP
      el.innerHTML='<div class="m3orb"><i class="m3orbspark">✦</i></div>';
      return el;
    }
    let ov='';
    if(sp===SP.LINEH) ov='<div class="spline h"><b class="l"></b><b class="r"></b></div>';
    else if(sp===SP.LINEV) ov='<div class="spline v"><b class="u"></b><b class="d"></b></div>';
    else if(sp===SP.BOMB) ov='<div class="spbomb"></div>';
    el.innerHTML='<div class="gemstone" style="filter:drop-shadow(0 3px 6px rgba(0,0,0,.55)) drop-shadow(0 0 7px '+g.glow+'55)">'+gemSVG(g.id)+'</div>'+ov;
    return el;
  }
  /* ключевое: устанавливаем позицию через CSS-переменные + transform.
     Новые фишки появляются СРАЗУ (видимы), со spawn-fade — без двойного rAF */
  function place(el,k,animate,fromY){
    const x=k%N,y=k/N|0;
    el.style.width=_cellPx+'px'; el.style.height=_cellPx+'px';
    el.style.setProperty('--tx',(x*_cellPx)+'px');
    el.style.setProperty('--ty',(y*_cellPx)+'px');
    if(animate==='fall'){ el.classList.add('fall'); }
    el.style.transform='translate3d('+(x*_cellPx)+'px,'+(y*_cellPx)+'px,0)';
    if(animate==='spawn'){ el.classList.add('spawn'); }
  }

  function findMatches(){
    const groups=[];
    for(let y=0;y<N;y++){ let run=1;
      for(let x=1;x<=N;x++){ const same=x<N&&grid[idx(x,y)].c===grid[idx(x-1,y)].c&&grid[idx(x,y)].c>=0;
        if(same)run++; else{ if(run>=3){const g=[];for(let k=x-run;k<x;k++)g.push(idx(k,y));groups.push(g);} run=1; } } }
    for(let x=0;x<N;x++){ let run=1;
      for(let y=1;y<=N;y++){ const same=y<N&&grid[idx(x,y)].c===grid[idx(x,y-1)].c&&grid[idx(x,y)].c>=0;
        if(same)run++; else{ if(run>=3){const g=[];for(let k=y-run;k<y;k++)g.push(idx(x,k));groups.push(g);} run=1; } } }
    return groups;
  }
  function findHint(){ for(let y=0;y<N;y++)for(let x=0;x<N;x++) for(const[dx,dy] of [[1,0],[0,1]]){
    if(!inb(x+dx,y+dy))continue;
    if(ice[idx(x,y)]>0||ice[idx(x+dx,y+dy)]>0)continue;
    sd(idx(x,y),idx(x+dx,y+dy));
    const m=findMatches().length>0; sd(idx(x,y),idx(x+dx,y+dy)); if(m)return[idx(x,y),idx(x+dx,y+dy)]; } return null; }
  function sd(a,b){ const tc=grid[a].c; grid[a].c=grid[b].c; grid[b].c=tc; const ts=grid[a].sp; grid[a].sp=grid[b].sp; grid[b].sp=ts; }

  /* ── ввод ── */
  function bindInput(){
    let downK=null,sx=0,sy=0;
    function pick(e){ const r=_board.getBoundingClientRect();
      const px=(e.touches?e.touches[0].clientX:e.clientX)-r.left, py=(e.touches?e.touches[0].clientY:e.clientY)-r.top;
      const x=Math.floor(px/_cellPx), y=Math.floor(py/_cellPx); return inb(x,y)?idx(x,y):null; }
    _board.onpointerdown=(e)=>{ if(busy||!running)return; const k=pick(e); if(k==null)return; clearHint(); idleT=0;
      if(invMode){ applyInventory(k); return; } downK=k; sx=e.clientX; sy=e.clientY; setSel(k); Sound.gemSelect&&Sound.gemSelect(); };
    _board.onpointermove=(e)=>{ if(downK==null||busy)return; const dx=e.clientX-sx,dy=e.clientY-sy;
      if(Math.abs(dx)>_cellPx*0.4||Math.abs(dy)>_cellPx*0.4){ const x=downK%N,y=downK/N|0; let tx=x,ty=y;
        if(Math.abs(dx)>Math.abs(dy))tx+=dx>0?1:-1; else ty+=dy>0?1:-1;
        if(inb(tx,ty))trySwap(downK,idx(tx,ty)); downK=null; setSel(null); } };
    _board.onpointerup=(e)=>{ if(downK!=null){ const k=pick(e);
      if(k!=null&&k!==downK){ const ax=downK%N,ay=downK/N|0,bx=k%N,by=k/N|0;
        if(Math.abs(ax-bx)+Math.abs(ay-by)===1)trySwap(downK,k); else setSel(null); }
      else if(k===downK) setSel(downK); } downK=null; };
  }
  function setSel(k){ if(sel!=null&&grid[sel]&&grid[sel].el) grid[sel].el.classList.remove('sel');
    sel=k; if(k!=null&&grid[k]&&grid[k].el) grid[k].el.classList.add('sel'); }

  function swapFull(a,b){ const ta=grid[a],tb=grid[b]; grid[a]=tb; grid[b]=ta; place(grid[a].el,a); place(grid[b].el,b); }

  function trySwap(a,b){
    if(busy||!running) return;
    const ax=a%N,ay=a/N|0,bx=b%N,by=b/N|0;
    if(Math.abs(ax-bx)+Math.abs(ay-by)!==1) return;
    if(ice[a]>0||ice[b]>0){ // вмороженный камень не сдвинуть
      Sound.error&&Sound.error(); vibrate(10);
      const el=grid[ice[a]>0?a:b].el; if(el){ el.classList.add('frozenshake'); setTimeout(()=>el.classList.remove('frozenshake'),320); }
      setSel(null); return;
    }
    setSel(null); idleT=0; clearHint();
    if(grid[a].sp&&grid[b].sp){ // спец+спец = усиленный взрыв (как в JP)
      busy=true; Sound.gemSwap&&Sound.gemSwap(); swapFull(a,b);
      setTimeout(()=>{ comboDetonate(a,b); spendMove(); },170); return;
    }
    if(grid[a].sp===SP.RAINBOW||grid[b].sp===SP.RAINBOW){
      busy=true; Sound.gemSwap&&Sound.gemSwap(); swapFull(a,b);
      setTimeout(()=>{ const rk=grid[a].sp===SP.RAINBOW?a:b; const col=grid[rk===a?b:a].c; detonateRainbow(rk,col); spendMove(); },160); return;
    }
    busy=true; Sound.gemSwap&&Sound.gemSwap(); swapFull(a,b);
    setTimeout(()=>{ const ms=findMatches();
      if(ms.length===0){ Sound.error&&Sound.error(); swapFull(a,b); setTimeout(()=>{busy=false;},160); }
      else{ spendMove(); resolveBoard(ms); } },160);
  }
  function spendMove(){ moves--; combo=0; idleT=0; hud(); }

  function resolveBoard(first){
    let cascade=0;
    function step(matches){
      if(!matches) matches=findMatches();
      if(matches.length===0){ busy=false; scheduleHint(); checkEnd(); return; }
      cascade++; combo++; comboMax=Math.max(comboMax,combo);
      if(combo>=2) showCombo(combo);
      if(mission.type==='combo') progress=comboMax;
      const toClear=new Set(); const specials=[];
      matches.forEach(g=>{ const len=g.length,c=grid[g[0]].c; g.forEach(k=>toClear.add(k));
        if(len===4) specials.push({k:g[len>>1],sp:(g[1]-g[0]===1?SP.LINEH:SP.LINEV),c});
        else if(len>=5) specials.push({k:g[len>>1],sp:SP.RAINBOW,c}); });
      detectL(matches,specials);
      const expand=new Set(toClear); toClear.forEach(k=>{ if(grid[k].sp) triggerSpecial(k,expand); });
      let gained=0;
      expand.forEach(k=>{ if(grid[k].c<0)return; gained+=10+cascade*2; burst(k);
        if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++;
        if(mission.type==='clear')progress++; });
      score+=gained+(combo>1?combo*5:0); if(mission.type==='score')progress=score;
      matches.forEach(g=>floatScore(g[g.length>>1], g.length*(10+cascade*2)));
      Sound.gemMatch&&Sound.gemMatch(matches.length);
      if(cascade>1){Sound.gemCascade&&Sound.gemCascade(cascade);vibrate(8);} else vibrate(12);
      const absorbed=new Set();
      expand.forEach(k=>{ if(hitIce(k)) absorbed.add(k); });
      renderIce();
      expand.forEach(k=>{ if(absorbed.has(k))return; if(specials.some(s=>s.k===k))return; removeGem(k); });
      if(cascade>=3){ _stage.classList.remove('bigshake'); void _stage.offsetWidth; _stage.classList.add('bigshake'); }
      specials.forEach(s=>{ const old=grid[s.k].el; if(old&&old.parentNode)old.parentNode.removeChild(old);
        grid[s.k].c=s.c; grid[s.k].sp=s.sp; grid[s.k].el=makeGem(s.c,s.sp); _board.appendChild(grid[s.k].el); place(grid[s.k].el,s.k,'spawn'); ring(s.k); });
      hud();
      setTimeout(()=>{ collapse(); setTimeout(()=>step(null),300); },260);
    }
    step(first);
  }
  function removeGem(k){ const el=grid[k].el; if(el){ el.classList.add('pop'); setTimeout(()=>{ if(el.parentNode)el.parentNode.removeChild(el); },250); }
    grid[k].c=-1; grid[k].sp=SP.NONE; grid[k].el=null; }
  function detectL(matches,specials){ const inH={},inV={};
    matches.forEach(g=>{ const h=(g[1]-g[0]===1); g.forEach(k=>{(h?inH:inV)[k]=true;}); });
    Object.keys(inH).forEach(k=>{ if(inV[k]){ const kk=+k; if(!specials.some(s=>s.k===kk)) specials.push({k:kk,sp:SP.BOMB,c:grid[kk].c}); } }); }
  function triggerSpecial(k,set){ const x=k%N,y=k/N|0,sp=grid[k].sp; ring(k);
    if(sp===SP.LINEH){ for(let xx=0;xx<N;xx++)set.add(idx(xx,y)); beamFX(y,'h',k); Sound.lineBlast&&Sound.lineBlast(); }
    else if(sp===SP.LINEV){ for(let yy=0;yy<N;yy++)set.add(idx(x,yy)); beamFX(x,'v',k); Sound.lineBlast&&Sound.lineBlast(); }
    else if(sp===SP.BOMB){ for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++)if(inb(x+dx,y+dy))set.add(idx(x+dx,y+dy));
      shockFX(k,1.6); Sound.bombBlast&&Sound.bombBlast(); }
    else if(sp===SP.RAINBOW){ const c=grid[k].c; for(let i=0;i<N*N;i++)if(grid[i].c===c)set.add(i);
      Sound.rainbowBlast&&Sound.rainbowBlast(); } }
  /* спец+спец: комбинации как в Jewels Planet */
  function comboDetonate(pa,pb){
    const s1=grid[pa].sp, s2=grid[pb].sp;
    const x=pb%N, y=pb/N|0;
    const set=new Set([pa,pb]);
    const isLine=s=>s===SP.LINEH||s===SP.LINEV;
    if(s1===SP.RAINBOW&&s2===SP.RAINBOW){ // вся доска
      for(let i=0;i<N*N;i++)set.add(i);
      megaFlash(); Sound.rainbowBlast&&Sound.rainbowBlast(); vibrate([15,40,15,60]);
    }
    else if(s1===SP.RAINBOW||s2===SP.RAINBOW){
      const other=(s1===SP.RAINBOW)?s2:s1;
      const col=grid[(s1===SP.RAINBOW)?pb:pa].c;
      if(other===SP.BOMB){ // цвет + соседи каждого
        for(let i=0;i<N*N;i++) if(grid[i].c===col&&!grid[i].sp){ set.add(i);
          const ix=i%N, iy=i/N|0;
          for(let dx=-1;dx<=1;dx++)for(let dy=-1;dy<=1;dy++) if(inb(ix+dx,iy+dy))set.add(idx(ix+dx,iy+dy)); }
        shockFX(pb,2.2);
      } else { // радуга+линия: лучи из каждой фишки цвета
        let flip=(other===SP.LINEV);
        for(let i=0;i<N*N;i++) if(grid[i].c===col&&!grid[i].sp){ set.add(i);
          const ix=i%N, iy=i/N|0;
          if(flip){ for(let yy=0;yy<N;yy++)set.add(idx(ix,yy)); beamFX(ix,'v',i); }
          else{ for(let xx=0;xx<N;xx++)set.add(idx(xx,iy)); beamFX(iy,'h',i); }
          flip=!flip; }
      }
      Sound.rainbowBlast&&Sound.rainbowBlast(); vibrate([12,30,12]);
    }
    else if(s1===SP.BOMB&&s2===SP.BOMB){ // 5×5
      for(let dx=-2;dx<=2;dx++)for(let dy=-2;dy<=2;dy++) if(inb(x+dx,y+dy))set.add(idx(x+dx,y+dy));
      shockFX(pb,2.6); Sound.bombBlast&&Sound.bombBlast(); vibrate([15,50]);
    }
    else if((s1===SP.BOMB&&isLine(s2))||(s2===SP.BOMB&&isLine(s1))){ // 3 ряда + 3 колонки
      for(let d=-1;d<=1;d++){
        if(y+d>=0&&y+d<N){ for(let xx=0;xx<N;xx++)set.add(idx(xx,y+d)); beamFX(y+d,'h',pb); }
        if(x+d>=0&&x+d<N){ for(let yy=0;yy<N;yy++)set.add(idx(x+d,yy)); beamFX(x+d,'v',pb); }
      }
      Sound.bombBlast&&Sound.bombBlast(); vibrate([15,50]);
    }
    else { // линия+линия = крест
      for(let xx=0;xx<N;xx++)set.add(idx(xx,y));
      for(let yy=0;yy<N;yy++)set.add(idx(x,yy));
      beamFX(y,'h',pb); beamFX(x,'v',pb); Sound.lineBlast&&Sound.lineBlast(); vibrate([10,30]);
    }
    grid[pa].sp=SP.NONE; grid[pb].sp=SP.NONE;
    clearSet(set);
  }

  function detonateRainbow(rk,color){ const set=new Set(); for(let i=0;i<N*N;i++)if(grid[i].c===color)set.add(i); set.add(rk);
    Sound.special&&Sound.special(); let gained=0;
    set.forEach(k=>{ if(grid[k].c<0)return; gained+=14; burst(k);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++; if(mission.type==='clear')progress++;
      if(hitIce(k))return; removeGem(k); });
    renderIce();
    score+=gained; if(mission.type==='score')progress=score; hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),300); },260); }

  /* гравитация: переносим элементы вниз; новые — СРАЗУ видимы на месте + spawn-fade */
  function collapse(){
    for(let x=0;x<N;x++){
      let write=N-1;
      for(let y=N-1;y>=0;y--){ const k=idx(x,y);
        if(grid[k].c>=0){ const w=idx(x,write);
          if(w!==k){ grid[w]={c:grid[k].c,sp:grid[k].sp,el:grid[k].el}; grid[k]={c:-1,sp:SP.NONE,el:null}; place(grid[w].el,w,'fall'); }
          write--; } }
      for(let y=write;y>=0;y--){ const k=idx(x,y); const c=rnd(); const el=makeGem(c,SP.NONE);
        _board.appendChild(el); grid[k]={c,sp:SP.NONE,el};
        place(el,k,'spawn'); // СРАЗУ на месте + opacity-fade. Видима всегда.
      }
    }
    Sound.gemFall&&Sound.gemFall();
  }

  /* ── усилители (инвентарь) ── */
  function applyInventory(k){
    const p=(window.App&&App.profile)||{};
    const def=BOOST_DEF.find(b=>b.k===invMode); if(!def){ invMode=null; _board.classList.remove('aim'); tickBar(); return; }
    if((p[def.field]||0)<=0){ invMode=null; _board.classList.remove('aim'); tickBar(); return; }
    p[def.field]=(p[def.field]||0)-1;
    if(p.boostTs&&p.boostTs[def.k]===undefined) p.boostTs[def.k]=Date.now();
    saveP();
    if(invMode==='shot'){ Sound.shot&&Sound.shot(); vibrate(20); clearSet(new Set([k])); }
    else if(invMode==='siren'){ const x=k%N,y=k/N|0,set=new Set(); for(let i=0;i<N;i++){set.add(idx(i,y));set.add(idx(x,i));}
      beamFX(y,'h',k); beamFX(x,'v',k); Sound.lineBlast&&Sound.lineBlast(); clearSet(set); }
    invMode=null; _board.classList.remove('aim'); tickBar();
  }
  function clearSet(set){ Sound.booster&&Sound.booster(); vibrate([10,30]); busy=true; let gained=0;
    // цепная детонация: спецфишки в зоне поражения тоже срабатывают
    const chain=[]; set.forEach(k=>{ if(grid[k]&&grid[k].sp) chain.push(k); });
    chain.forEach(k=>triggerSpecial(k,set));
    let firstK=-1;
    set.forEach(k=>{ if(grid[k].c<0)return; if(firstK<0)firstK=k; gained+=12; burst(k);
      if(mission.type==='color'&&grid[k].c===(mission.color||0))progress++; if(mission.type==='clear')progress++;
      if(hitIce(k))return; removeGem(k); });
    renderIce();
    score+=gained; if(mission.type==='score')progress=score;
    if(firstK>=0&&gained>0) floatScore(firstK,gained);
    hud();
    setTimeout(()=>{ collapse(); setTimeout(()=>resolveBoard(null),300); },260); }
  function shuffleBoard(){ busy=true; const cs=[]; for(let k=0;k<N*N;k++) if(grid[k].c>=0) cs.push(grid[k].c);
    for(let i=cs.length-1;i>0;i--){ const j=Math.random()*(i+1)|0; [cs[i],cs[j]]=[cs[j],cs[i]]; }
    let p=0; for(let k=0;k<N*N;k++){ const c=cs[p++];
      if(grid[k].el&&grid[k].el.parentNode) grid[k].el.parentNode.removeChild(grid[k].el);
      grid[k]={c,sp:SP.NONE,el:makeGem(c,SP.NONE)}; _board.appendChild(grid[k].el); place(grid[k].el,k,'spawn'); }
    let guard=0; while(findMatches().length&&guard++<100){ findMatches().forEach(g=>g.forEach(k=>{ grid[k].c=rnd();
      if(grid[k].el&&grid[k].el.parentNode) grid[k].el.parentNode.removeChild(grid[k].el);
      grid[k].el=makeGem(grid[k].c,grid[k].sp); _board.appendChild(grid[k].el); place(grid[k].el,k,false); })); }
    Sound.transition&&Sound.transition(); setTimeout(()=>{ busy=false; checkEnd(); },340); }
  function saveP(){ try{ window.saveProfile&&saveProfile(); }catch(e){} }

  /* ── эффекты ── */
  function burst(k){ const g=GEMS[grid[k].c]||GEMS[0]; const x=k%N,y=k/N|0;
    const cx=x*_cellPx+_cellPx/2, cy=y*_cellPx+_cellPx/2;
    const fl=document.createElement('div'); fl.className='m3flash';
    fl.style.left=cx+'px'; fl.style.top=cy+'px';
    _board.appendChild(fl); setTimeout(()=>{ if(fl.parentNode)fl.parentNode.removeChild(fl); },300);
    for(let i=0;i<7;i++){
      const isStar=i<2;
      const p=document.createElement('div'); p.className=isStar?'m3spark':'m3burst';
      p.style.left=cx+'px'; p.style.top=cy+'px';
      if(isStar){ p.textContent='✦'; p.style.fontSize=(8+Math.random()*6)+'px';
        p.style.textShadow='0 0 7px '+g.glow+', 0 0 3px #fff'; }
      else{ const s=4+Math.random()*5; p.style.width=s+'px'; p.style.height=s+'px';
        p.style.background='radial-gradient(circle at 35% 35%, #fff 15%, '+g.c1+' 55%, transparent 78%)';
        p.style.boxShadow='0 0 6px '+g.glow; }
      _board.appendChild(p);
      const a=Math.random()*6.28, d=12+Math.random()*24;
      const dx=Math.cos(a)*d, dy=Math.sin(a)*d;
      p.animate(
        [{transform:'translate(-50%,-50%) translate(0,0) scale(1) rotate(0deg)',opacity:1},
         {transform:'translate(-50%,-50%) translate('+dx+'px,'+(dy-6)+'px) scale(.9) rotate('+(Math.random()*140-70)+'deg)',opacity:.95,offset:.55},
         {transform:'translate(-50%,-50%) translate('+(dx*1.25)+'px,'+(dy+14)+'px) scale(.15) rotate('+(Math.random()*200-100)+'deg)',opacity:0}],
        {duration:430+Math.random()*180,easing:'cubic-bezier(.2,.7,.35,1)'}
      ).onfinish=()=>{ if(p.parentNode)p.parentNode.removeChild(p); };
    } }
  /* кометы спецфишки: из точки срабатывания в обе стороны ряда/колонки */
  function beamFX(i,axis,fromK){
    if(!_board) return;
    const total=N*_cellPx;
    const lane=i*_cellPx+_cellPx/2;                    // центр ряда/колонки
    const oc=(fromK!=null)
      ? ((axis==='v') ? (Math.floor(fromK/N))*_cellPx+_cellPx/2 : (fromK%N)*_cellPx+_cellPx/2)
      : total/2;                                       // точка старта вдоль оси
    // мягкое свечение полосы
    const gl=document.createElement('div'); gl.className='m3rowglow';
    if(axis==='v'){ gl.style.left=(i*_cellPx+2)+'px'; gl.style.width=(_cellPx-4)+'px'; gl.style.top='0'; gl.style.bottom='0';
      gl.style.background='linear-gradient(180deg,transparent,rgba(255,110,140,.22),transparent)'; }
    else{ gl.style.top=(i*_cellPx+2)+'px'; gl.style.height=(_cellPx-4)+'px'; gl.style.left='0'; gl.style.right='0'; }
    _board.appendChild(gl); setTimeout(()=>{ if(gl.parentNode)gl.parentNode.removeChild(gl); },470);
    // две кометы в противоположные стороны
    [1,-1].forEach(dir=>{
      const d=document.createElement('div'); d.className='m3comet';
      const dist=(dir>0? total-oc : oc)+26;
      if(dist<30) return;
      if(axis==='v'){ d.style.left=(lane-23)+'px'; d.style.top=(oc-4.5)+'px';
        d.style.transform='rotate('+(dir>0?90:-90)+'deg)'; }
      else{ d.style.left=(oc-23)+'px'; d.style.top=(lane-4.5)+'px';
        d.style.transform='rotate('+(dir>0?0:180)+'deg)'; }
      _board.appendChild(d);
      const rot=d.style.transform;
      d.animate(
        [{transform:rot+' translateX(0)',opacity:1},
         {transform:rot+' translateX('+(dist*0.8)+'px)',opacity:1,offset:.75},
         {transform:rot+' translateX('+dist+'px)',opacity:0}],
        {duration:200+dist/total*160,easing:'cubic-bezier(.25,.6,.35,1)'}
      ).onfinish=()=>{ if(d.parentNode)d.parentNode.removeChild(d); };
    });
  }
  /* ударная волна бомбы */
  function shockFX(k,mult){
    const x=k%N,y=k/N|0; const r=document.createElement('div'); r.className='m3ring';
    r.style.cssText+='left:'+(x*_cellPx+_cellPx/2)+'px;top:'+(y*_cellPx+_cellPx/2)+'px;width:0;height:0;transform:translate(-50%,-50%);opacity:.95;color:#fff;border-width:4px;z-index:6;';
    _board.appendChild(r); requestAnimationFrame(()=>{ r.style.transition='all .55s ease-out';
      const sz=_cellPx*(mult||2)*1.6; r.style.width=sz+'px'; r.style.height=sz+'px'; r.style.opacity='0'; });
    setTimeout(()=>{ if(r.parentNode)r.parentNode.removeChild(r); },580);
    _stage.classList.remove('bigshake'); void _stage.offsetWidth; _stage.classList.add('bigshake');
  }
  /* всплывающие очки */
  function floatScore(k,n){
    if(!_board||!n) return;
    const x=k%N,y=k/N|0; const d=document.createElement('div'); d.className='m3pts'; d.textContent='+'+n;
    d.style.left=(x*_cellPx+_cellPx/2)+'px'; d.style.top=(y*_cellPx)+'px';
    _board.appendChild(d); setTimeout(()=>{ if(d.parentNode)d.parentNode.removeChild(d); },820);
  }
  /* вспышка всей доски */
  function megaFlash(){
    if(!_board) return;
    const d=document.createElement('div'); d.className='m3mega';
    _board.appendChild(d); setTimeout(()=>{ if(d.parentNode)d.parentNode.removeChild(d); },580);
  }
  function ring(k){ const x=k%N,y=k/N|0; const r=document.createElement('div'); r.className='m3ring';
    r.style.cssText+='left:'+(x*_cellPx+_cellPx/2)+'px;top:'+(y*_cellPx+_cellPx/2)+'px;width:0;height:0;transform:translate(-50%,-50%);opacity:.9;color:'+(GEMS[grid[k].c]||GEMS[0]).glow;
    _board.appendChild(r); requestAnimationFrame(()=>{ r.style.transition='all .5s ease-out';
      r.style.width=(_cellPx*1.7)+'px'; r.style.height=(_cellPx*1.7)+'px'; r.style.opacity='0'; });
    setTimeout(()=>{ if(r.parentNode)r.parentNode.removeChild(r); },520); }
  function showCombo(n){ const w=['','','Хорошо!','Отлично!','Превосходно!','Блестяще!','Гениально!'];
    const d=document.createElement('div'); d.className='m3combo'; d.textContent=w[Math.min(n,6)]||'Комбо!';
    _stage.appendChild(d); setTimeout(()=>{ if(d.parentNode)d.parentNode.removeChild(d); },1000); Sound.approve&&Sound.approve(); }

  /* ── конец ── */
  function checkEnd(){ const target=mission.target||600; if(progress>=target){ win(); return; } if(timeUp){ lose(); return; } if(moves<=0) lose(); }
  function win(){ running=false; clearTimeout(hintTimer); clearInterval(_timerIv); Sound.win&&Sound.win(); vibrate([10,40,10,40]);
    finale(0, ()=>{ end(true); setTimeout(()=>opts.onWin&&opts.onWin(),1100); }); }
  /* финал JP: оставшиеся ходы стреляют лучами по доске и добирают очки */
  function finale(step,done){
    const bonus=Math.min(moves,6);
    if(step>=bonus){ setTimeout(done,320); return; }
    const alive=[]; for(let k=0;k<N*N;k++) if(grid[k].c>=0&&!grid[k].sp&&ice[k]<=0) alive.push(k);
    if(!alive.length){ done(); return; }
    const k=alive[Math.random()*alive.length|0];
    const axis=Math.random()<.5?'h':'v'; const x=k%N,y=k/N|0;
    const set=new Set();
    if(axis==='h'){ for(let xx=0;xx<N;xx++)set.add(idx(xx,y)); beamFX(y,'h',k); }
    else{ for(let yy=0;yy<N;yy++)set.add(idx(x,yy)); beamFX(x,'v',k); }
    Sound.lineBlast&&Sound.lineBlast();
    let gained=0;
    set.forEach(kk=>{ if(grid[kk].c<0)return; gained+=15; burst(kk); if(hitIce(kk))return; removeGem(kk); });
    renderIce(); score+=gained; if(mission.type==='score')progress=score;
    if(gained>0) floatScore(k,gained);
    moves--; hud();
    setTimeout(()=>finale(step+1,done),270);
  }
  function lose(){ running=false; clearTimeout(hintTimer); clearInterval(_timerIv); Sound.deny&&Sound.deny(); end(false); setTimeout(()=>opts.onLose&&opts.onLose(),1500); }
  function end(won){ const stars=starsEarned();
    const o=document.createElement('div'); o.className='m3end';
    o.innerHTML='<div class="m3endstars">'+[0,1,2].map(i=>
        '<span class="m3endstar'+(i<stars&&won?' earn':'')+'" style="animation-delay:'+(0.25+i*0.3)+'s">'+STAR_SVG+'</span>').join('')+'</div>'+
      '<div class="v" style="color:'+(won?'#46d89b':'#ff6470')+';text-shadow:0 0 24px '+(won?'#46d89b':'#ff6470')+'">'+
      (won?'УЛИКА ПОЛУЧЕНА':'УЛИКА УТЕРЯНА')+'</div>'+
      '<div class="s">'+(won?('Точность сыска: '+stars+' из 3')
        :((timeUp||((mission.time|0)>0&&timeLeft<=0))?'Время вышло. Сдвиг недоволен.':'Ходы кончились. Попробуй ещё.'))+'</div>';
    _root.appendChild(o);
    if(won&&stars>0){ let si=0; const tick=()=>{ if(si++<stars){ try{Sound.approve&&Sound.approve();}catch(_){ } setTimeout(tick,300);} }; setTimeout(tick,250); } }

  /* ── HUD: ходы + звёзды-улики + цель ── */
  function starsEarned(){ const target=mission.target||600; let s=0; STARS.forEach(t=>{ if(progress>=target*t)s++; }); return s; }
  const STAR_SVG='<svg viewBox="0 0 24 24"><path d="M12 2l3 6.3 6.9 1-5 4.9 1.2 6.8L12 17.8 5.9 21l1.2-6.8-5-4.9 6.9-1z"/></svg>';
  function goalIconHtml(){
    if(mission.type==='color'){ const g=GEMS[mission.color||0];
      return '<span class="m3goalico">'+gemSVG(g.id)+'</span>'; }
    if(mission.type==='clear') return '<span class="m3goalico">'+
      '<svg viewBox="0 0 24 24" style="width:100%;height:100%">'+
      '<rect x="2.5" y="2.5" width="8.5" height="8.5" rx="2.2" fill="#93a1b3"/>'+
      '<rect x="13" y="2.5" width="8.5" height="8.5" rx="2.2" fill="#cfd8e3"/>'+
      '<rect x="2.5" y="13" width="8.5" height="8.5" rx="2.2" fill="#cfd8e3"/>'+
      '<rect x="13" y="13" width="8.5" height="8.5" rx="2.2" fill="#e0546e"/>'+
      '<path d="M15 15.6 L19.5 17.2 L15.6 19 L17.2 15.2z" fill="#fff" opacity=".7"/></svg></span>';
    if(mission.type==='combo') return '<span class="m3goalico">'+
      '<svg viewBox="0 0 24 24" style="width:100%;height:100%">'+
      '<path d="M13.5 1.5 L4.5 13.5 h5.5 l-2.5 9 L19.5 9.5 h-6 l2.5-8z" fill="#ffcf6b" stroke="#7d4a06" stroke-width=".9"/>'+
      '<path d="M13.5 1.5 L4.5 13.5 h5.5 l-1 3.6 L17 9.5 h-3.5 l2.5-8z" fill="#fff3d0" opacity=".55"/></svg></span>';
    return '<span class="m3goalico">'+
      '<svg viewBox="0 0 24 24" style="width:100%;height:100%">'+
      '<circle cx="12" cy="12" r="9.2" fill="none" stroke="#cfd8e3" stroke-width="2.2"/>'+
      '<circle cx="12" cy="12" r="5" fill="none" stroke="#e0546e" stroke-width="2.2"/>'+
      '<circle cx="12" cy="12" r="1.8" fill="#fff"/></svg></span>';
  }
  function goalLeftTxt(){
    const target=mission.target||600;
    const left=Math.max(0,target-progress);
    if(mission.type==='score') return progress+' / '+target;
    if(mission.type==='combo') return 'лучший ×'+comboMax+' из ×'+target;
    return left>0 ? ('осталось '+left) : 'готово!';
  }
  function hud(){
    if(!_hud) return;
    const target=mission.target||600, pct=Math.min(100,Math.round(progress/target*100)), st=starsEarned();
    const mv=_hud.querySelector('#m3mv');
    if(mv){
      mv.textContent=moves;
      mv.classList.toggle('low',moves<=3);
      if(_lastMoves>=0&&moves<_lastMoves){ mv.classList.remove('bump'); void mv.offsetWidth; mv.classList.add('bump'); }
      _lastMoves=moves;
    }
    const gr=_hud.querySelector('#m3goalrow');
    if(gr) gr.innerHTML=goalIconHtml()+'<span class="m3goaltxt">'+goalLeftTxt()+'</span>';
    const fill=_hud.querySelector('#m3fill');
    if(fill) fill.style.width=pct+'%';
    _hud.querySelectorAll('.m3star.ontrack').forEach(el=>{
      const was=el.classList.contains('on'), now=(+el.dataset.st)<st;
      el.classList.toggle('on', now);
      if(now&&!was){ el.classList.add('gain'); setTimeout(()=>el.classList.remove('gain'),650); }
    });
    if(st>_lastStars&&_lastStars>=0){ Sound.starChime&&Sound.starChime(); }
    _lastStars=st;
  }

  /* ── таймер партии ── */
  function startTimer(){
    clearInterval(_timerIv); timeUp=false;
    timeLeft=(mission.time|0); if(timeLeft<=0){ return; }
    updateTimer();
    _timerIv=setInterval(()=>{
      if(!running){ clearInterval(_timerIv); return; }
      timeLeft--; updateTimer();
      if(timeLeft<=5&&timeLeft>0){ try{Sound.tap&&Sound.tap();}catch(_){}}
      if(timeLeft<=0){
        clearInterval(_timerIv);
        if(busy){ timeUp=true; } else { lose(); }
      }
    },1000);
  }
  function updateTimer(){
    const el=_hud&&_hud.querySelector('#m3tm'); if(!el)return;
    const s=Math.max(0,timeLeft);
    el.textContent=Math.floor(s/60)+':'+String(s%60).padStart(2,'0');
    el.classList.toggle('low', s<=15);
  }

  /* ── панель усилителей: DOM строится ОДИН раз, тикают только тексты.
        (пересборка innerHTML каждую секунду съедала тапы — фикс) ── */
  let barTick=null,_boostEls=null;
  function renderBar(){
    regenAll();
    _bar.innerHTML=BOOST_DEF.map(b=>
      '<div class="m3boost" data-k="'+b.k+'">'+
        '<span class="bi">'+(BOOST_ICON[b.k]||'')+'</span>'+
        '<span class="bname">'+b.name+'</span>'+
        '<span class="btimer" data-t></span>'+
        '<span class="bcount" data-c></span>'+
      '</div>').join('');
    _boostEls={};
    _bar.querySelectorAll('.m3boost').forEach(el=>{
      _boostEls[el.dataset.k]=el;
      el.addEventListener('pointerup',ev=>{ ev.stopPropagation(); ev.preventDefault(); onBoostTap(el.dataset.k); });
    });
    tickBar();
    clearInterval(barTick); barTick=setInterval(tickBar,1000);
  }
  function tickBar(){
    regenAll();
    const p=(window.App&&App.profile)||{};
    BOOST_DEF.forEach(b=>{
      const el=_boostEls&&_boostEls[b.k]; if(!el) return;
      const n=p[b.field]||0, ms=boostLeftMs(b);
      el.classList.toggle('on', invMode===b.k);
      el.classList.toggle('empty', n<=0);
      const c=el.querySelector('[data-c]'); if(c) c.textContent = n>0 ? n : '+';
      const t=el.querySelector('[data-t]'); if(t) t.textContent = n>=b.max ? 'макс' : fmt(ms);
    });
  }
  function onBoostTap(k){
    const b=BOOST_DEF.find(x=>x.k===k); if(!b) return;
    const p=(window.App&&App.profile)||{};
    const n=p[b.field]||0;
    if(n<=0){ buyBoost(k); return; }
    if(k==='review'){ // применяется сразу, без цели
      if(busy||!running){ Sound.error&&Sound.error(); return; }
      p[b.field]=n-1; if(p.boostTs&&p.boostTs[k]===undefined)p.boostTs[k]=Date.now(); saveP();
      invMode=null; _board.classList.remove('aim');
      Sound.transition&&Sound.transition(); shuffleBoard(); tickBar(); return;
    }
    invMode = (invMode===k) ? null : k;
    _board.classList.toggle('aim', !!invMode);
    Sound.tap&&Sound.tap(); tickBar();
    if(invMode&&window.toast) toast(b.name, b.hint+' — тапни по фишке', '🎯');
  }
  function buyBoost(k){ const b=BOOST_DEF.find(x=>x.k===k); const p=(window.App&&App.profile); if(!p)return;
    if((p.bucks||0)<b.price){ Sound.error&&Sound.error(); if(window.toast)toast('Мало баксов',b.name+' — '+b.price+' 💵','✗');
      if(window.openBuckShop)openBuckShop(); return; }
    p.bucks-=b.price; p[b.field]=(p[b.field]||0)+1; saveP(); Sound.coin&&Sound.coin();
    if(window.toast)toast('Куплено',b.name+' — '+b.price+' 💵','🛍'); if(window.renderHUD)renderHUD(); tickBar(); }
  function fmt(ms){ const s=Math.ceil(ms/1000); const m=Math.floor(s/60); return m>0?(m+':'+String(s%60).padStart(2,'0')):(s+'с'); }

  /* ── подсказка ── */
  function scheduleHint(){ clearTimeout(hintTimer); if(!running)return;
    hintTimer=setTimeout(()=>{ if(busy||!running)return; const h=findHint();
      if(h)h.forEach(k=>{ if(grid[k].el)grid[k].el.classList.add('hint'); }); }, HINT_DELAY); }
  function clearHint(){ for(let k=0;k<N*N;k++) if(grid[k]&&grid[k].el) grid[k].el.classList.remove('hint'); scheduleHint(); }
})();

