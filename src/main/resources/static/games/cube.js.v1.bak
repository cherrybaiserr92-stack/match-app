/* ═══════════════════════════════════════════════════════════
   СДВИГ · cube.js — 3D-куб «рулетка мини-игр»
   При «Найти улики» открывается куб. Грань = мини-игра.
   Куб крутится → останавливается → выпавшая грань зумится
   на весь экран → запускается соответствующая игра.

   API:  MiniCube.open(container, { onPick(gameId){...} })
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  /* 6 граней. available:false → грань-превью (ещё не готова).
     Сейчас готов только match3; чтобы игроку всегда выпадало рабочее,
     невыпавшие-неготовые перекидывают на match3 (см. resolvePick). */
  const FACES=[
    {id:'match3',  name:'Улики дела', ico:'💎', sub:'Три в ряд', available:true,  col1:'#c8860a',col2:'#7a4e08'},
    {id:'board',   name:'Доска улик',     ico:'🧷', sub:'Связи',     available:false, col1:'#b05050',col2:'#5e2626'},
    {id:'wiretap', name:'Перехват',       ico:'📻', sub:'Частота',   available:false, col1:'#4a9b8e',col2:'#1d4a43'},
    {id:'spot',    name:'Сверка',         ico:'🔍', sub:'Детали',    available:false, col1:'#5c7fb0',col2:'#28384f'},
    {id:'dossier', name:'Картотека',      ico:'🗂', sub:'Сортировка',available:false, col1:'#9a7fb0',col2:'#4a3f5a'},
    {id:'match3b', name:'Улики дела', ico:'💎', sub:'Три в ряд', available:true,  col1:'#c8860a',col2:'#7a4e08'}
  ];

  // ориентации куба, чтобы нужная грань смотрела на зрителя
  // порядок граней: front, back, right, left, top, bottom
  const FACE_TRANSFORM=[
    'translateZ(var(--h))',                          // 0 front
    'rotateY(180deg) translateZ(var(--h))',          // 1 back
    'rotateY(90deg)  translateZ(var(--h))',          // 2 right
    'rotateY(-90deg) translateZ(var(--h))',          // 3 left
    'rotateX(90deg)  translateZ(var(--h))',          // 4 top
    'rotateX(-90deg) translateZ(var(--h))'           // 5 bottom
  ];
  // какой rotate привести куб, чтобы грань i оказалась спереди
  const SHOW_FACE=[
    'rotateY(0deg)',
    'rotateY(-180deg)',
    'rotateY(-90deg)',
    'rotateY(90deg)',
    'rotateX(-90deg)',
    'rotateX(90deg)'
  ];

  let _root,_css=false,_onPick,_spinning=false;

  window.MiniCube={
    open(container, opts){
      _onPick=(opts&&opts.onPick)||function(){};
      injectCSS(); build(container); startSpin();
    },
    close(){ if(_root&&_root.parentNode) _root.parentNode.innerHTML=''; _root=null; }
  };

  function injectCSS(){
    if(_css) return; _css=true;
    const s=document.createElement('style'); s.id='minicube-css';
    s.textContent=`
    .mc-root{position:absolute;inset:0;display:flex;flex-direction:column;align-items:center;justify-content:center;
      background:radial-gradient(circle at 50% 40%,#1a1611,#0a0806);overflow:hidden;}
    .mc-title{font-family:Unbounded,sans-serif;font-weight:800;font-size:15px;letter-spacing:.04em;color:#f3d27a;
      margin-bottom:6px;text-align:center;opacity:0;animation:mcFadeIn .4s .1s forwards;}
    .mc-sub{font-size:11px;color:#9aa3b2;margin-bottom:26px;opacity:0;animation:mcFadeIn .4s .2s forwards;text-align:center;}
    @keyframes mcFadeIn{to{opacity:1}}
    .mc-stage{perspective:900px;width:var(--cube);height:var(--cube);position:relative;}
    .mc-cube{width:100%;height:100%;position:relative;transform-style:preserve-3d;
      transform:translateZ(calc(var(--h) * -1));}
    .mc-cube.spin{transition:transform 3.6s cubic-bezier(.12,.62,.18,1);}
    .mc-cube.zoom{transition:transform 1.1s cubic-bezier(.5,0,.2,1);}
    .mc-face{position:absolute;width:var(--cube);height:var(--cube);border-radius:18px;
      display:flex;flex-direction:column;align-items:center;justify-content:center;gap:8px;
      border:2px solid rgba(255,255,255,.18);box-shadow:inset 0 0 40px rgba(0,0,0,.45);
      backface-visibility:hidden;overflow:hidden;}
    .mc-face .mcf-glow{position:absolute;inset:0;opacity:.9;}
    .mc-face .mcf-ico{font-size:54px;line-height:1;filter:drop-shadow(0 4px 12px rgba(0,0,0,.5));z-index:2;}
    .mc-face .mcf-name{font-family:Unbounded,sans-serif;font-weight:800;font-size:15px;color:#fff;
      text-shadow:0 2px 8px rgba(0,0,0,.7);z-index:2;text-align:center;padding:0 8px;}
    .mc-face .mcf-sub{font-size:11px;color:rgba(255,255,255,.85);z-index:2;letter-spacing:.05em;}
    .mc-face .mcf-lock{position:absolute;top:10px;right:12px;font-size:13px;opacity:.7;z-index:3;}
    .mc-face.dim::after{content:'';position:absolute;inset:0;background:rgba(0,0,0,.45);z-index:2;}
    .mc-spinhint{margin-top:30px;font-size:12px;color:#c8a05a;letter-spacing:.06em;
      opacity:0;animation:mcPulse 1.6s ease-in-out infinite;}
    @keyframes mcPulse{0%,100%{opacity:.4}50%{opacity:1}}
    .mc-spinhint.hide{display:none;}
    .mc-result{position:absolute;bottom:18%;left:0;right:0;text-align:center;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:20px;color:#ffcf6b;
      text-shadow:0 0 20px #c8860a;opacity:0;}
    .mc-result.show{animation:mcResult .6s ease forwards;}
    @keyframes mcResult{0%{opacity:0;transform:translateY(12px) scale(.9)}100%{opacity:1;transform:none}}
    .mc-flash{position:absolute;inset:0;background:radial-gradient(circle,rgba(255,207,107,.5),transparent 60%);
      opacity:0;pointer-events:none;}
    .mc-flash.go{animation:mcFlash .5s ease;}
    @keyframes mcFlash{0%{opacity:0}30%{opacity:1}100%{opacity:0}}
    `;
    document.head.appendChild(s);
  }

  function build(container){
    container.innerHTML='';
    _root=document.createElement('div'); _root.className='mc-root';
    // размеры куба от ширины контейнера
    const w=Math.min(container.getBoundingClientRect().width||320, 360);
    const cube=Math.round(Math.min(w*0.56,200));
    _root.style.setProperty('--cube', cube+'px');
    _root.style.setProperty('--h', (cube/2)+'px');

    _root.innerHTML=
      '<div class="mc-title">КОЛЕСО УЛИК</div>'+
      '<div class="mc-sub">Куб решит, как ты добудешь улику</div>'+
      '<div class="mc-stage"><div class="mc-cube" id="mc-cube">'+
        FACES.map((f,i)=>faceHtml(f,i)).join('')+
      '</div></div>'+
      '<div class="mc-spinhint" id="mc-spinhint">⟳ Куб вращается…</div>'+
      '<div class="mc-result" id="mc-result"></div>'+
      '<div class="mc-flash" id="mc-flash"></div>';
    container.appendChild(_root);
  }

  function faceHtml(f,i){
    return '<div class="mc-face'+(f.available?'':' dim')+'" style="transform:'+FACE_TRANSFORM[i]+'" data-i="'+i+'">'+
      '<div class="mcf-glow" style="background:radial-gradient(circle at 50% 35%,'+f.col1+','+f.col2+')"></div>'+
      (f.available?'':'<span class="mcf-lock">🔒</span>')+
      '<span class="mcf-ico">'+f.ico+'</span>'+
      '<span class="mcf-name">'+f.name+'</span>'+
      '<span class="mcf-sub">'+f.sub+'</span>'+
    '</div>';
  }

  function startSpin(){
    if(_spinning) return; _spinning=true;
    const cube=document.getElementById('mc-cube');
    try{ Sound.transition&&Sound.transition(); }catch(_){}

    // выбираем грань: только доступные (чтобы выпало проходимое)
    const availIdx=FACES.map((f,i)=>f.available?i:-1).filter(i=>i>=0);
    const pickI=availIdx[Math.floor(Math.random()*availIdx.length)];

    // много оборотов + финальная ориентация на выбранную грань
    const spins=4+Math.floor(Math.random()*2);
    const base=SHOW_FACE[pickI];
    cube.classList.add('spin');
    // крутим: добавляем полные обороты по обеим осям + финал
    cube.style.transform='translateZ(calc(var(--h) * -1)) rotateX('+(spins*360)+'deg) rotateY('+(spins*360)+'deg) '+base;

    // клац-клац во время вращения
    let ticks=0; const tickTimer=setInterval(()=>{ try{Sound.tap&&Sound.tap();}catch(_){} if(++ticks>18)clearInterval(tickTimer); },180);

    setTimeout(()=>{
      clearInterval(tickTimer);
      onSpinEnd(pickI);
    }, 3700);
  }

  function onSpinEnd(pickI){
    const f=FACES[pickI];
    const hint=document.getElementById('mc-spinhint');
    const res=document.getElementById('mc-result');
    const flash=document.getElementById('mc-flash');
    if(hint) hint.classList.add('hide');
    try{ Sound.win&&Sound.win(); vibrate&&vibrate([10,30,10]); }catch(_){}
    if(res){ res.textContent=f.name; res.classList.add('show'); }
    if(flash) flash.classList.add('go');

    // пауза, потом зум грани на весь экран → запуск игры
    setTimeout(()=>{ zoomAndLaunch(pickI); }, 1100);
  }

  function zoomAndLaunch(pickI){
    const cube=document.getElementById('mc-cube');
    const stage=_root.querySelector('.mc-stage');
    if(cube){
      cube.classList.remove('spin'); cube.classList.add('zoom');
      // приближаем выбранную грань к камере (z вперёд) — эффект «вход в грань»
      const base=SHOW_FACE[pickI];
      cube.style.transform='translateZ(140px) '+base;
    }
    // затемняем антураж
    if(stage) stage.style.transition='opacity .8s ease';
    setTimeout(()=>{
      const gameId=resolvePick(FACES[pickI]);
      try{ _onPick(gameId); }catch(e){ console.error('cube onPick',e); }
    }, 950);
  }

  /* если грань-превью (недоступна) — откатываем на match3,
     чтобы игрок всё равно сыграл в готовую игру */
  function resolvePick(face){
    if(face.available) return face.id==='match3b'?'match3':face.id;
    return 'match3';
  }

})();

