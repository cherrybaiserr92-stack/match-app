/* ═══════════════════════════════════════════════════════════
   СДВИГ · cube.js v2 — 3D-куб «рулетка мини-игр»
   Переписан на requestAnimationFrame-физику:
   • плавное вращение покадрово (ease-out), без рывков CSS-transition
   • фиксированные пиксельные размеры (никаких var() в transform)
   • чистый зум выпавшей грани
   API: MiniCube.open(container,{onPick}) / MiniCube.close()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  const FACES=[
    {id:'match3',  name:'Улики дела', ico:'💎', sub:'Три в ряд', available:true,  c1:'#e0a020',c2:'#7a4e08'},
    {id:'board',   name:'Доска улик', ico:'🧷', sub:'Связи',     available:false, c1:'#c86464',c2:'#5e2626'},
    {id:'wiretap', name:'Перехват',   ico:'📻', sub:'Частота',   available:false, c1:'#5ab0a0',c2:'#1d4a43'},
    {id:'examine',  name:'Осмотр места',ico:'🔍', sub:'Поиск улик',available:true,  c1:'#6c8fc0',c2:'#28384f'},
    {id:'dossier', name:'Картотека',  ico:'🗂', sub:'Сортировка',available:false, c1:'#a78fc0',c2:'#4a3f5a'},
    {id:'match3b', name:'Улики дела', ico:'💎', sub:'Три в ряд', available:true,  c1:'#e0a020',c2:'#7a4e08'}
  ];
  // грань → целевые углы (deg), чтобы она смотрела в камеру
  const FACE_ANGLE=[
    {x:0,   y:0  },  // 0 front
    {x:0,   y:180},  // 1 back
    {x:0,   y:-90},  // 2 right
    {x:0,   y:90 },  // 3 left
    {x:-90, y:0  },  // 4 top
    {x:90,  y:0  }   // 5 bottom
  ];
  // позиция каждой грани в кубе (для статической раскладки)
  const FACE_POS=[
    'rotateY(0deg)',
    'rotateY(180deg)',
    'rotateY(90deg)',
    'rotateY(-90deg)',
    'rotateX(90deg)',
    'rotateX(-90deg)'
  ];

  let _root,_css=false,_onPick,_cube,_half=100,_raf=null,_active=false;

  window.MiniCube={
    open(container,opts){ _onPick=(opts&&opts.onPick)||function(){};
      injectCSS(); build(container); spin(); },
    close(){ _active=false; if(_raf)cancelAnimationFrame(_raf);
      if(_root&&_root.parentNode) _root.parentNode.innerHTML=''; _root=null; }
  };

  function injectCSS(){
    if(_css)return; _css=true;
    const s=document.createElement('style'); s.id='minicube-css';
    s.textContent=`
    .mc-root{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;
      background:radial-gradient(circle at 50% 38%,#1c1812,#0a0806);overflow:hidden;}
    .mc-title{font-family:Unbounded,sans-serif;font-weight:800;font-size:15px;letter-spacing:.05em;color:#f3d27a;
      text-align:center;opacity:0;animation:mcIn .5s .1s forwards;}
    .mc-sub{font-size:11px;color:#9aa3b2;margin-bottom:30px;opacity:0;animation:mcIn .5s .25s forwards;text-align:center;}
    @keyframes mcIn{to{opacity:1}}
    .mc-stage{perspective:760px;perspective-origin:50% 50%;position:relative;}
    .mc-cube{position:relative;transform-style:preserve-3d;}
    .mc-face{position:absolute;border-radius:16px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:7px;
      border:2px solid rgba(255,255,255,.16);overflow:hidden;
      box-shadow:inset 0 0 36px rgba(0,0,0,.5);}
    .mcf-glow{position:absolute;inset:0;}
    .mcf-sheen{position:absolute;inset:0;background:linear-gradient(135deg,rgba(255,255,255,.22),transparent 45%);}
    .mcf-ico{font-size:46px;line-height:1;z-index:2;filter:drop-shadow(0 3px 8px rgba(0,0,0,.6));}
    .mcf-name{font-family:Unbounded,sans-serif;font-weight:800;font-size:13px;color:#fff;z-index:2;
      text-shadow:0 2px 6px rgba(0,0,0,.7);text-align:center;padding:0 6px;}
    .mcf-sub{font-size:10px;color:rgba(255,255,255,.85);z-index:2;letter-spacing:.06em;}
    .mcf-lock{position:absolute;top:9px;right:11px;font-size:12px;z-index:3;opacity:.75;}
    .mc-face.dim .mcf-glow{filter:saturate(.5) brightness(.7);}
    .mc-face.dim::after{content:'';position:absolute;inset:0;background:rgba(0,0,0,.4);z-index:1;}
    .mc-hint{margin-top:34px;font-size:12px;color:#c8a05a;letter-spacing:.06em;height:16px;
      opacity:0;animation:mcPulse 1.6s ease-in-out infinite;}
    @keyframes mcPulse{0%,100%{opacity:.4}50%{opacity:1}}
    .mc-hint.hide{opacity:0 !important;animation:none;}
    .mc-result{position:absolute;bottom:16%;left:0;right:0;text-align:center;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:21px;color:#ffcf6b;
      text-shadow:0 0 22px #c8860a;opacity:0;}
    .mc-result.show{animation:mcRes .5s ease forwards;}
    @keyframes mcRes{0%{opacity:0;transform:translateY(14px) scale(.85)}100%{opacity:1;transform:none}}
    .mc-flash{position:absolute;inset:0;pointer-events:none;opacity:0;
      background:radial-gradient(circle at 50% 45%,rgba(255,207,107,.55),transparent 55%);}
    .mc-flash.go{animation:mcFl .5s ease;}
    @keyframes mcFl{0%{opacity:0}28%{opacity:1}100%{opacity:0}}
    `;
    document.head.appendChild(s);
  }

  function build(container){
    container.innerHTML='';
    _root=document.createElement('div'); _root.className='mc-root';
    const cw=container.getBoundingClientRect().width||320;
    const side=Math.round(Math.min(cw*0.5,170));   // ребро куба, px
    _half=side/2;

    _root.innerHTML=
      '<div class="mc-title">КОЛЕСО УЛИК</div>'+
      '<div class="mc-sub">Куб решит, как ты добудешь улику</div>'+
      '<div class="mc-stage" style="width:'+side+'px;height:'+side+'px">'+
        '<div class="mc-cube" id="mc-cube" style="width:'+side+'px;height:'+side+'px">'+
          FACES.map((f,i)=>faceHtml(f,i,side)).join('')+
        '</div>'+
      '</div>'+
      '<div class="mc-hint" id="mc-hint">⟳ Куб вращается…</div>'+
      '<div class="mc-result" id="mc-result"></div>'+
      '<div class="mc-flash" id="mc-flash"></div>';
    container.appendChild(_root);
    _cube=document.getElementById('mc-cube');
    setCube(0,0,0); // стартовая ориентация
  }

  function faceHtml(f,i,side){
    return '<div class="mc-face'+(f.available?'':' dim')+'" '+
      'style="width:'+side+'px;height:'+side+'px;transform:'+FACE_POS[i]+' translateZ('+_half+'px)">'+
      '<div class="mcf-glow" style="background:radial-gradient(circle at 50% 32%,'+f.c1+','+f.c2+')"></div>'+
      '<div class="mcf-sheen"></div>'+
      (f.available?'':'<span class="mcf-lock">🔒</span>')+
      '<span class="mcf-ico">'+f.ico+'</span>'+
      '<span class="mcf-name">'+f.name+'</span>'+
      '<span class="mcf-sub">'+f.sub+'</span>'+
    '</div>';
  }

  // ставим куб в ориентацию (px-translateZ, без var())
  function setCube(rx,ry,zoom){
    if(!_cube)return;
    const tz = zoom||(-_half);
    _cube.style.transform='translateZ('+tz+'px) rotateX('+rx+'deg) rotateY('+ry+'deg)';
  }

  /* ── ВРАЩЕНИЕ покадрово (ease-out), без CSS-transition ── */
  function spin(){
    _active=true;
    try{ Sound.transition&&Sound.transition(); }catch(_){}

    // выбираем доступную грань
    const avail=FACES.map((f,i)=>f.available?i:-1).filter(i=>i>=0);
    const pickI=avail[Math.floor(Math.random()*avail.length)];
    const target=FACE_ANGLE[pickI];

    // стартовые и конечные углы: несколько оборотов + доводка до грани
    const turns=3+Math.floor(Math.random()*2);
    const startX=0, startY=0;
    const endX=target.x + 360*turns;       // крутим по X
    const endY=target.y + 360*turns;       // и по Y
    const dur=2600;                         // мс
    const t0=performance.now();

    let lastTick=0;
    function frame(now){
      if(!_active)return;
      let p=(now-t0)/dur; if(p>1)p=1;
      // ease-out cubic — быстрый старт, плавное замедление
      const e=1-Math.pow(1-p,3);
      const rx=startX+(endX-startX)*e;
      const ry=startY+(endY-startY)*e;
      setCube(rx,ry);
      // клац по мере замедления
      const tick=Math.floor(ry/45);
      if(tick!==lastTick && p<0.96){ lastTick=tick; try{Sound.tap&&Sound.tap();}catch(_){} }
      if(p<1){ _raf=requestAnimationFrame(frame); }
      else { setCube(target.x,target.y); onStop(pickI); }
    }
    _raf=requestAnimationFrame(frame);
  }

  function onStop(pickI){
    const f=FACES[pickI];
    const hint=document.getElementById('mc-hint');
    const res=document.getElementById('mc-result');
    const flash=document.getElementById('mc-flash');
    if(hint) hint.classList.add('hide');
    try{ Sound.win&&Sound.win(); vibrate&&vibrate([10,30,10]); }catch(_){}
    if(res){ res.textContent=f.name; res.classList.add('show'); }
    if(flash) flash.classList.add('go');
    setTimeout(()=>zoom(pickI), 1050);
  }

  /* зум выпавшей грани — тоже покадрово (плавно «входим» в грань) */
  function zoom(pickI){
    const target=FACE_ANGLE[pickI];
    const t0=performance.now(); const dur=850;
    const startZoom=-_half, endZoom=_half*2.4; // придвигаем грань к камере
    function frame(now){
      if(!_active)return;
      let p=(now-t0)/dur; if(p>1)p=1;
      const e=p<.5?2*p*p:1-Math.pow(-2*p+2,2)/2; // ease-in-out
      setCube(target.x,target.y, startZoom+(endZoom-startZoom)*e);
      // плавно гасим антураж
      if(_root){ _root.style.opacity=String(1-e*0.5); }
      if(p<1){ _raf=requestAnimationFrame(frame); }
      else { launch(pickI); }
    }
    _raf=requestAnimationFrame(frame);
  }

  function launch(pickI){
    const gameId=FACES[pickI].available ? (FACES[pickI].id==='match3b'?'match3':FACES[pickI].id) : 'match3';
    try{ _onPick(gameId); }catch(e){ console.error('cube onPick',e); }
  }

})();

