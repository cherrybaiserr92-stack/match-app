/* ═══════════════════════════════════════════════════════════
   СДВИГ · feed.js — лента карт (замена 3D-карусели)
   Фаза расследования: вертикальная лента реплик/событий.
   Фаза решения (после мини-игры): активная карта по центру +
   каскады мини-карточек возможных исходов слева/справа.

   Использует существующие из app.js:
   CASE, CState, fill(), cApplyOption(), computeEnding(),
   showEnding(), saveCaseState(), openHintGame(), showChar(),
   showSpeech(), updateCaseBg(), Sound, vibrate, missionFor()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  let _wrap=null, _busy=false, _decision=false, _decTimer=null;

  window.Feed={
    /* строит ленту с нуля для текущего дела */
    init(){ buildShell(); renderFromState(); },
    /* показать конкретное событие (добавить в ленту) */
    show(evId){ pushCard(evId); },
    /* перейти к решению по текущей карте (вызывается после мини-игры) */
    enterDecision(){ enterDecisionMode(); },
    reset(){ if(_wrap)_wrap.innerHTML=''; _busy=false; _decision=false; clearInterval(_decTimer); }
  };

  /* ── оболочка ленты внутри #stage ── */
  function buildShell(){
    const stage=document.getElementById('stage'); if(!stage) return;
    stage.innerHTML='<div class="feed" id="feed"></div>';
    _wrap=document.getElementById('feed');
    injectCSS();
  }

  function injectCSS(){
    if(document.getElementById('feed-css')) return;
    const s=document.createElement('style'); s.id='feed-css';
    s.textContent=`
    .feed{position:absolute;inset:0;overflow-y:auto;-webkit-overflow-scrolling:touch;
      display:flex;flex-direction:column;gap:14px;padding:14px 16px 30vh;scroll-behavior:smooth;}
    .feed::-webkit-scrollbar{width:0;}
    /* карта-реплика в ленте */
    .fcard{position:relative;border-radius:18px;overflow:hidden;flex:0 0 auto;
      background:linear-gradient(160deg,rgba(26,22,16,.96),rgba(12,10,7,.97));
      border:1px solid rgba(200,134,10,.32);box-shadow:0 8px 24px rgba(0,0,0,.5);
      opacity:0;transform:translateY(24px);animation:fcIn .42s cubic-bezier(.25,1.1,.4,1) forwards;}
    @keyframes fcIn{to{opacity:1;transform:none}}
    .fcard .fc-pad{padding:16px 17px;}
    .fc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.12em;color:var(--acc-2,#ffcf6b);padding:5px 11px;border-radius:8px;
      background:rgba(200,134,10,.16);border:1px solid rgba(200,134,10,.4);margin-bottom:10px;}
    .fc-title{font-family:Unbounded,sans-serif;font-weight:800;font-size:19px;line-height:1.14;
      color:#fff;margin-bottom:9px;}
    .fc-text{font-size:14px;line-height:1.5;color:#ded6c4;}
    .fc-dlg{margin-top:10px;padding:9px 12px;border-radius:10px;font-size:12.5px;line-height:1.45;
      color:#e7c98a;font-style:italic;background:rgba(200,134,10,.07);border-left:3px solid var(--acc,#c8860a);}
    .fc-next{margin-top:14px;width:100%;padding:13px;border:none;border-radius:12px;cursor:pointer;
      background:linear-gradient(180deg,#ffdf95,var(--acc,#c8860a));color:#241701;
      font-family:Unbounded,sans-serif;font-weight:800;font-size:13px;letter-spacing:.04em;}
    .fc-next:active{filter:brightness(.93);}
    .fc-find{margin-top:14px;width:100%;padding:14px;border:none;border-radius:12px;cursor:pointer;
      background:linear-gradient(180deg,#ffe09a,var(--acc,#c8860a));color:#241701;
      font-family:Unbounded,sans-serif;font-weight:800;font-size:14px;display:flex;align-items:center;justify-content:center;gap:8px;
      box-shadow:0 6px 18px rgba(200,134,10,.32);}
    .fcard.dim{opacity:.4;}
    .fcard.past{opacity:.55;}

    /* ── ФАЗА РЕШЕНИЯ ── */
    .feed.decision{overflow:hidden;}
    .decision-stage{position:absolute;inset:0;z-index:20;display:flex;align-items:center;justify-content:center;
      background:radial-gradient(70% 60% at 50% 45%,rgba(10,14,22,.5),rgba(6,8,13,.85));}
    .dec-card{position:relative;width:min(72vw,290px);border-radius:18px;overflow:hidden;z-index:5;
      background:linear-gradient(160deg,rgba(28,23,16,.99),rgba(13,11,8,.99));
      border:1.5px solid var(--acc,#c8860a);box-shadow:0 16px 44px rgba(0,0,0,.6),0 0 28px rgba(200,134,10,.2);
      animation:decTension 2.8s ease-in-out infinite;}
    @keyframes decTension{
      0%,100%{transform:rotate(0) translate(0,0)}
      25%{transform:rotate(-.3deg) translate(-1.5px,1px)}
      50%{transform:rotate(.3deg) translate(1.5px,-1.5px)}
      75%{transform:rotate(-.15deg) translate(-1px,0)}}
    .dec-card.swipe-left{animation:decFlyL .5s ease-in forwards;}
    .dec-card.swipe-right{animation:decFlyR .5s ease-in forwards;}
    @keyframes decFlyL{to{transform:translateX(-140%) rotate(-18deg);opacity:0}}
    @keyframes decFlyR{to{transform:translateX(140%) rotate(18deg);opacity:0}}

    /* каскады исходов по бокам */
    .outcome-cascade{position:absolute;top:50%;z-index:3;pointer-events:none;
      display:flex;flex-direction:column;gap:6px;opacity:0;transition:opacity .5s;}
    .outcome-cascade.show{opacity:1;}
    .outcome-cascade.left{left:2vw;transform:translateY(-50%);align-items:flex-start;}
    .outcome-cascade.right{right:2vw;transform:translateY(-50%);align-items:flex-end;}
    .oc-card{border-radius:10px;padding:7px 10px;font-size:10px;font-weight:700;font-family:Unbounded,sans-serif;
      letter-spacing:.02em;color:#fff;white-space:nowrap;max-width:30vw;overflow:hidden;text-overflow:ellipsis;
      border:1px solid rgba(255,255,255,.18);box-shadow:0 4px 12px rgba(0,0,0,.4);}
    .outcome-cascade.left .oc-card{background:linear-gradient(160deg,rgba(176,80,80,.85),rgba(94,38,38,.9));transform-origin:left center;}
    .outcome-cascade.right .oc-card{background:linear-gradient(160deg,rgba(74,155,142,.85),rgba(29,74,67,.9));transform-origin:right center;}
    /* каскад: каждая следующая меньше и бледнее */
    .oc-card:nth-child(1){transform:scale(1);opacity:1;}
    .oc-card:nth-child(2){transform:scale(.88);opacity:.78;}
    .oc-card:nth-child(3){transform:scale(.76);opacity:.56;}
    .oc-card:nth-child(4){transform:scale(.66);opacity:.4;}
    .oc-hint{position:absolute;bottom:14%;left:0;right:0;text-align:center;font-size:11px;color:#c8a05a;
      font-family:Unbounded,sans-serif;letter-spacing:.05em;}
    /* таймер решения */
    .dec-timer{position:absolute;top:8%;left:50%;transform:translateX(-50%);z-index:8;
      display:flex;flex-direction:column;align-items:center;gap:3px;}
    .dt-ring2{width:50px;height:50px;position:relative;}
    .dt-ring2 svg{width:100%;height:100%;transform:rotate(-90deg);}
    .dt-ring2 .bg{fill:none;stroke:rgba(255,255,255,.1);stroke-width:5;}
    .dt-ring2 .fg{fill:none;stroke:var(--acc,#c8860a);stroke-width:5;stroke-linecap:round;transition:stroke-dashoffset .25s linear,stroke .3s;}
    .dt-n{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:17px;color:#fff;}
    .dec-timer.urgent .fg{stroke:#ff5d6c;}
    .dec-timer.urgent .dt-n{color:#ff5d6c;animation:dtP .5s ease-in-out infinite;}
    @keyframes dtP{0%,100%{transform:scale(1)}50%{transform:scale(1.18)}}
    `;
    document.head.appendChild(s);
  }

  /* ── восстановление/старт ленты ── */
  function renderFromState(){
    if(!_wrap) return;
    _wrap.innerHTML='';
    pushCard(CState.ev||CASE.start, true);
  }

  /* добавляем карту события в ленту */
  function pushCard(evId, instant){
    const ev=CASE.events[evId]; if(!ev) return;
    CState.ev=evId;
    // прошлые карты — приглушаем
    Array.from(_wrap.querySelectorAll('.fcard')).forEach(c=>c.classList.add('past'));

    const card=document.createElement('div');
    card.className='fcard'; card._ev=ev; card._id=evId;
    card.innerHTML=cardInner(ev);
    _wrap.appendChild(card);

    // персонаж + реплика (из app.js)
    try{ if(window.showChar) showChar(ev.speaker||null); if(window.showSpeech) showSpeech(ev.speaker?ev.dialogue:null); }catch(_){}
    try{ if(window.updateCaseBg) updateCaseBg(); }catch(_){}

    // прокрутка к новой карте
    setTimeout(()=>{ card.scrollIntoView({behavior:instant?'auto':'smooth', block:'center'}); }, 60);

    bindCard(card, ev, evId);
    try{ if(window.saveCaseState) saveCaseState(); }catch(_){}
  }

  function cardInner(ev){
    let body='<div class="fc-pad">'+
      '<span class="fc-badge">'+(ev.badge||'')+'</span>'+
      '<div class="fc-title">'+(ev.title||'')+'</div>'+
      '<div class="fc-text">'+fillSafe(ev.text)+'</div>'+
      ((ev.dialogue&&!ev.speaker)?'<div class="fc-dlg">'+ev.dialogue.replace(/\n/g,'<br>')+'</div>':'');
    if(ev.linear){
      body+='<button class="fc-next" data-act="next">Далее →</button>';
    } else {
      // карта-решение: сперва «Найти улики» (мини-игра), потом свайп
      body+='<button class="fc-find" data-act="find">🔍 Найти улики</button>';
    }
    body+='</div>';
    return body;
  }
  function fillSafe(t){ try{ return window.fill?fill(t,CState.flags):t; }catch(_){ return t||''; } }

  function bindCard(card, ev, evId){
    const btn=card.querySelector('[data-act]');
    if(!btn) return;
    btn.onclick=()=>{
      if(_busy) return;
      try{Sound.tap&&Sound.tap();}catch(_){}
      const act=btn.getAttribute('data-act');
      if(act==='next'){ advanceLinear(ev); }
      else if(act==='find'){ openMiniGame(ev, card); }
    };
  }

  /* линейная карта → следующая */
  function advanceLinear(ev){
    _busy=true; CState.step=(CState.step||0)+1;
    try{ if(window.cSetProgress) cSetProgress(); }catch(_){}
    const nextId=ev.next;
    setTimeout(()=>{
      _busy=false;
      if(!nextId||nextId==='__resolve__'){ finish(); }
      else pushCard(nextId);
    }, 180);
  }

  /* запуск мини-игры через куб (openHintGame в app.js) */
  function openMiniGame(ev, card){
    try{ if(window.App) App.currentCard=ev; }catch(_){}
    if(window.openHintGame){
      // openHintGame по победе вызовет unlockSwipe → Feed.enterDecision()
      openHintGame(ev);
    } else {
      enterDecisionMode(); // фолбэк
    }
  }

  /* ── ФАЗА РЕШЕНИЯ ── */
  function enterDecisionMode(){
    const ev=CState.ev?CASE.events[CState.ev]:null; if(!ev) return;
    if(ev.linear){ advanceLinear(ev); return; }
    _decision=true;
    _wrap.classList.add('decision');

    // считаем исходы по сторонам
    const opts = ev.shift
      ? {left:ev.a, right:ev.b}
      : {left:ev.left, right:ev.right};
    const leftOutcomes  = collectOutcomes(opts.left);
    const rightOutcomes = collectOutcomes(opts.right);

    const stage=document.createElement('div'); stage.className='decision-stage'; stage.id='dec-stage';
    stage.innerHTML=
      cascadeHtml('left', leftOutcomes)+
      '<div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div>'+
      cascadeHtml('right', rightOutcomes)+
      '<div class="dec-timer" id="dec-timer">'+
        '<div class="dt-ring2"><svg viewBox="0 0 50 50"><circle class="bg" cx="25" cy="25" r="21"/><circle class="fg" id="dec-fg" cx="25" cy="25" r="21"/></svg>'+
        '<div class="dt-n" id="dec-n">15</div></div></div>'+
      '<div class="oc-hint">← свайп решает →</div>';
    document.getElementById('stage').appendChild(stage);

    // показываем каскады
    requestAnimationFrame(()=>{ stage.querySelectorAll('.outcome-cascade').forEach(c=>c.classList.add('show')); });

    bindDecisionSwipe(ev, stage);
    startDecTimer();
  }

  /* собираем "исходы": куда ведёт эта ветка (заголовок целевого события) */
  function collectOutcomes(opt){
    if(!opt) return [];
    const out=[];
    const toId=opt.to;
    if(toId && toId!=='__resolve__' && CASE.events[toId]){
      out.push(CASE.events[toId].badge||CASE.events[toId].title||'…');
      // заглядываем на шаг глубже — следующие возможные ветки
      const nx=CASE.events[toId];
      ['left','right','a','b'].forEach(s=>{ if(nx[s]&&nx[s].to&&CASE.events[nx[s].to]){
        const t=CASE.events[nx[s].to]; const lbl=t.badge||t.title; if(lbl&&out.indexOf(lbl)<0&&out.length<4)out.push(lbl);
      }});
    } else if(toId==='__resolve__'){
      out.push('Развязка');
    }
    return out.slice(0,4);
  }
  function cascadeHtml(side, outcomes){
    if(!outcomes.length) outcomes=[side==='left'?'влево':'вправо'];
    return '<div class="outcome-cascade '+side+'">'+
      outcomes.map(o=>'<div class="oc-card">'+esc(o)+'</div>').join('')+'</div>';
  }
  function decCardInner(ev){
    if(ev.shift){
      return '<div class="fc-pad"><span class="fc-badge">'+(ev.badge||'СДВИГ')+'</span>'+
        '<div class="fc-title">'+(ev.title||'')+'</div>'+
        '<div class="fc-text">'+fillSafe(ev.intro||ev.text)+'</div>'+
        '<div style="margin-top:12px;display:flex;gap:8px;font-size:11px">'+
          '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(176,80,80,.2);border:1px solid rgba(176,80,80,.4);color:#ff9d85;text-align:center">◄ '+esc((ev.a&&ev.a.label||'').replace(/^◄\s*/,''))+'</div>'+
          '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(74,155,142,.2);border:1px solid rgba(74,155,142,.4);color:#9fe0ff;text-align:center">'+esc((ev.b&&ev.b.label||'').replace(/\s*►$/,''))+' ►</div>'+
        '</div></div>';
    }
    return '<div class="fc-pad"><span class="fc-badge">'+(ev.badge||'')+'</span>'+
      '<div class="fc-title">'+(ev.title||'')+'</div>'+
      '<div class="fc-text">'+fillSafe(ev.text)+'</div>'+
      '<div style="margin-top:12px;display:flex;gap:8px;font-size:11px">'+
        '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(176,80,80,.2);border:1px solid rgba(176,80,80,.4);color:#ff9d85;text-align:center">◄ '+esc((ev.left&&ev.left.label||'').replace(/^◄\s*/,''))+'</div>'+
        '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(74,155,142,.2);border:1px solid rgba(74,155,142,.4);color:#9fe0ff;text-align:center">'+esc((ev.right&&ev.right.label||'').replace(/\s*►$/,''))+' ►</div>'+
      '</div></div>';
  }

  /* свайп карты-решения */
  function bindDecisionSwipe(ev, stage){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,sy=0,down=false;
    card.addEventListener('pointerdown',e=>{ down=true; sx=e.clientX; sy=e.clientY; card.setPointerCapture&&card.setPointerCapture(e.pointerId); });
    card.addEventListener('pointermove',e=>{ if(!down)return; const dx=e.clientX-sx;
      card.style.transform='translateX('+dx*0.5+'px) rotate('+dx*0.02+'deg)'; });
    card.addEventListener('pointerup',e=>{ if(!down)return; down=false; const dx=e.clientX-sx;
      if(Math.abs(dx)>60){ commitDecision(ev, dx<0?'left':'right'); }
      else card.style.transform=''; });
  }
  function commitDecision(ev, dir){
    if(_busy) return; _busy=true;
    clearInterval(_decTimer);
    const card=document.getElementById('dec-card');
    const opt = ev.shift ? (dir==='left'?ev.a:ev.b) : (dir==='left'?ev.left:ev.right);
    try{ if(window.cApplyOption) cApplyOption(opt); }catch(_){}
    try{ Sound.burn&&Sound.burn(); Sound.swipe&&Sound.swipe(dir); vibrate&&vibrate(20); }catch(_){}
    if(card) card.classList.add(dir==='left'?'swipe-left':'swipe-right');
    CState.step=(CState.step||0)+1;
    try{ if(window.cSetProgress) cSetProgress(); }catch(_){}
    setTimeout(()=>{
      const st=document.getElementById('dec-stage'); if(st)st.remove();
      _wrap.classList.remove('decision'); _decision=false; _busy=false;
      try{ if(window.hideChar) hideChar(); }catch(_){}
      if(opt.to==='__resolve__'||!opt.to){ finish(); }
      else pushCard(opt.to);
    }, 520);
  }

  /* таймер решения */
  function startDecTimer(){
    let left=15; const total=15;
    const fg=document.getElementById('dec-fg'); const num=document.getElementById('dec-n');
    const timer=document.getElementById('dec-timer');
    const R=21,C=2*Math.PI*R;
    if(fg){ fg.style.strokeDasharray=C; fg.style.strokeDashoffset=0; }
    clearInterval(_decTimer);
    _decTimer=setInterval(()=>{
      left--;
      if(num)num.textContent=Math.max(0,left);
      if(fg)fg.style.strokeDashoffset=C*(1-left/total);
      if(left<=5&&timer){ timer.classList.add('urgent'); try{Sound.tap&&Sound.tap();}catch(_){} }
      if(left<=0){ clearInterval(_decTimer);
        if(window.toast)toast('Время вышло','Сдвиг: «Промедление — тоже выбор».','⏱');
        if(num)num.textContent='!';
      }
    },1000);
  }

  function finish(){
    try{
      const r=window.computeEnding?computeEnding(CState.flags):{kind:'win',verdict:'ФИНАЛ',text:''};
      if(window.showEnding) showEnding(r);
    }catch(e){ console.error('finish',e); }
  }

  function esc(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
})();

