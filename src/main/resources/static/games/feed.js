/* ═══════════════════════════════════════════════════════════
   СДВИГ · feed.js v2 — ПРОКАЧАННАЯ ЛЕНТА
   Поток реплик вместо карточек-коробок. Фишки сверх конкурентов:
   • живые аватары (говорящий подсвечен)
   • голос дедукции (выводы Сдвига особым стилем)
   • улики кликабельны прямо в тексте → летят в досье
   • теги настроения (подтекст реплик)
   Сохраняет API: Feed.init / show / enterDecision / reset
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  let _wrap=null, _busy=false, _decision=false, _decTimer=null;
  var _history=[];  // история показанных событий (вся глава)
  var _builtFor=null;  // для какого CState.ev построена лента

  const NAMES={shift:'Сдвиг',recruit:'Рекрут',kurator:'Куратор',arundel:'Аранделл',
    miller:'Миллер',hayes:'Хейс',romero:'Ромеро',conroy:'Конрой',jiang:'Цзян',
    purcell:'Пёрселл',danny:'Дэнни',eleanor:'Эленор',guests:'Гости'};
  const CHARV=(window.CHAR_VER||'3');
  function avatar(id){
    var C=window.CHARS||(typeof CHARS!=='undefined'?CHARS:null);
    if(id&&C&&C[id]) return C[id].src+'?v='+CHARV;
    return '';
  }

  window.Feed={
    init(){ buildShell(); renderFromState(); },
    show(evId){ pushEvent(evId); },
    enterDecision(){ enterDecisionMode(); },
    pushReaction(dialogueStr, done){ showReaction(dialogueStr, done); },
    reset(){ _lastRenderedEv=null; _history=[]; _builtFor=null; if(_wrap)_wrap.innerHTML=''; _busy=false; _decision=false; clearInterval(_decTimer); }
  };

  function buildShell(){
    const stage=document.getElementById('stage'); if(!stage) return;
    stage.innerHTML='<div class="feed2" id="feed2"></div>';
    try{ if(window.hideChar) hideChar(); }catch(_){}
    _wrap=document.getElementById('feed2');
    injectCSS();
  }

  function injectCSS(){
    if(document.getElementById('feed2-css')) return;
    const s=document.createElement('style'); s.id='feed2-css';
    s.textContent=`
    .feed2{position:absolute;inset:0;overflow-y:auto;-webkit-overflow-scrolling:touch;
      display:flex;flex-direction:column;gap:14px;padding:16px 14px 32vh;scroll-behavior:smooth;}
    .feed2::-webkit-scrollbar{width:0;}
    .msg2{display:flex;gap:11px;opacity:0;transform:translateY(14px);animation:m2In .5s cubic-bezier(.2,1,.3,1) forwards;}
    @keyframes m2In{to{opacity:1;transform:none}}
    .m2-av{width:62px;height:62px;border-radius:50%;flex-shrink:0;overflow:hidden;border:2.5px solid;position:relative;}
    .m2-av img{position:absolute;width:150%;left:-25%;top:8%;max-width:none;}
    /* индивидуальный кроп — голова целиком влезает */
    .m2-av.av-shift img{width:128%;left:-14%;top:1%;}
    .m2-av.av-recruit img{width:150%;left:-25%;top:7%;}
    .m2-av.av-miller img{width:140%;left:-20%;top:5%;}
    .m2-av.av-eleanor img{width:148%;left:-24%;top:5%;}
    .m2-av.av-kurator img{width:122%;left:-11%;top:0%;}
    .m2-ring{position:absolute;inset:-2px;border-radius:12px;opacity:0;transition:opacity .3s;}
    .msg2.active .m2-av{transform:scale(1.05);}
    .msg2.active .m2-ring{opacity:1;box-shadow:0 0 0 2px currentColor,0 0 16px currentColor;}
    .m2-av.talking{animation:avTalk .7s ease-in-out infinite;}
    @keyframes avTalk{0%,100%{transform:scale(1)}50%{transform:scale(1.06)}}
    .m2-av.talking .m2-ring{animation:ringTalk .5s ease-in-out infinite;}
    @keyframes ringTalk{0%,100%{box-shadow:0 0 0 2px currentColor,0 0 12px currentColor;opacity:.9}50%{box-shadow:0 0 0 3px currentColor,0 0 22px currentColor;opacity:1}}
    .m2-body{flex:1;min-width:0;}
    .m2-head{display:flex;align-items:center;gap:7px;margin-bottom:4px;}
    .m2-nm{font-family:Unbounded,sans-serif;font-weight:700;font-size:12px;letter-spacing:.02em;}
    .m2-mood{font-size:9px;padding:2px 7px;border-radius:6px;font-weight:700;letter-spacing:.03em;text-transform:uppercase;}
    .m2-bubble{font-size:14px;line-height:1.5;padding:11px 14px;border-radius:14px;border-top-left-radius:4px;
      background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);}
    .m2-caret{display:inline-block;width:7px;color:var(--acc-2,#ffcf6b);animation:m2Caret .7s steps(1) infinite;}
    @keyframes m2Caret{0%,50%{opacity:1}50.01%,100%{opacity:0}}

    .msg2.shift .m2-av{border-color:#ffcf6b;color:#ffcf6b;}
    .msg2.shift .m2-nm{color:#ffcf6b;}
    .msg2.shift .m2-bubble{background:linear-gradient(135deg,rgba(255,207,107,.1),rgba(200,134,10,.04));border-color:rgba(255,207,107,.2);}
    .msg2.recruit .m2-av{border-color:#6bb6ff;color:#6bb6ff;}
    .msg2.recruit .m2-nm{color:#6bb6ff;}
    .msg2.recruit .m2-bubble{background:linear-gradient(135deg,rgba(107,182,255,.1),rgba(60,120,200,.04));border-color:rgba(107,182,255,.2);}
    .msg2.other .m2-av{border-color:#d88c6b;color:#d88c6b;}
    .msg2.other .m2-nm{color:#d88c6b;}

    .msg2.narr{padding-left:6px;}
    .msg2.narr .m2-narr{font-style:italic;color:#9aa090;font-size:13px;line-height:1.55;padding:8px 0 8px 14px;
      border-left:2px solid rgba(200,134,10,.3);}

    .msg2.deduce .m2-bubble{background:linear-gradient(135deg,rgba(70,216,155,.12),rgba(40,150,110,.05));
      border:1px solid rgba(70,216,155,.3);border-left:3px solid #46d89b;}
    .msg2.deduce .m2-nm{color:#46d89b;}
    .msg2.deduce .m2-av{border-color:#46d89b;color:#46d89b;background:rgba(70,216,155,.1);
      display:flex;align-items:center;justify-content:center;font-size:24px;}

    .m2-clue{display:inline-flex;align-items:center;gap:4px;padding:1px 8px;margin:0 2px;border-radius:7px;
      background:rgba(70,216,155,.16);border:1px solid rgba(70,216,155,.4);color:#46d89b;
      font-weight:600;cursor:pointer;font-size:13px;transition:all .2s;white-space:nowrap;}
    .m2-clue:active{transform:scale(.94);}
    .m2-clue.collected{background:rgba(70,216,155,.3);opacity:.8;}
    .m2-clue::before{content:'🔍';font-size:10px;}

    .feed2-next{align-self:center;margin-top:6px;font-size:11px;color:#c8a05a;font-family:Unbounded,sans-serif;
      letter-spacing:.05em;opacity:.7;animation:f2tap 1.5s ease-in-out infinite;padding:8px;cursor:pointer;}
    @keyframes f2tap{0%,100%{opacity:.4}50%{opacity:.8}}
    .feed2-hint{align-self:center;max-width:88%;margin:4px auto;padding:10px 14px;border-radius:12px;
      background:rgba(255,207,107,.1);border:1px solid rgba(255,207,107,.28);color:#ffd98a;
      font-size:12.5px;line-height:1.45;display:flex;gap:8px;align-items:flex-start;font-style:italic;}
    .feed2-hint .fh-ico{font-size:14px;flex-shrink:0;}
    .feed2-find{align-self:center;margin-top:8px;padding:13px 28px;border:none;border-radius:13px;cursor:pointer;
      background:linear-gradient(180deg,#ffe09a,#c8860a);color:#241701;font-family:Unbounded,sans-serif;
      font-weight:800;font-size:14px;box-shadow:0 6px 18px rgba(200,134,10,.32);}
    .decision-stage{position:absolute;inset:0;z-index:40;display:flex;align-items:center;justify-content:center;
      background:radial-gradient(70% 60% at 50% 45%,rgba(10,14,22,.7),rgba(6,8,13,.95));}
    .dec-card{position:relative;width:min(80vw,320px);margin-top:56px;border-radius:18px;overflow:hidden;z-index:5;
      background:linear-gradient(160deg,rgba(28,23,16,.99),rgba(13,11,8,.99));
      border:1.5px solid var(--acc,#c8860a);box-shadow:0 16px 44px rgba(0,0,0,.6),0 0 28px rgba(200,134,10,.2);
      animation:decT 2.8s ease-in-out infinite;}
    @keyframes decT{0%,100%{transform:rotate(0) translate(0,0)}25%{transform:rotate(-.3deg) translate(-1.5px,1px)}
      50%{transform:rotate(.3deg) translate(1.5px,-1.5px)}75%{transform:rotate(-.15deg) translate(-1px,0)}}
    .dec-card.swipe-left{animation:decFL .5s ease-in forwards;}
    .dec-card.swipe-right{animation:decFR .5s ease-in forwards;}
    @keyframes decFL{to{transform:translateX(-140%) rotate(-18deg);opacity:0}}
    @keyframes decFR{to{transform:translateX(140%) rotate(18deg);opacity:0}}
    .dc-inner{padding:18px 16px 20px;text-align:center;overflow:hidden;box-sizing:border-box;width:100%;}
    .dc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.14em;color:#241701;padding:5px 13px;border-radius:8px;
      background:linear-gradient(180deg,#ffe09a,#c8860a);margin-bottom:12px;}
    .dc-title{font-family:Unbounded,sans-serif;font-weight:900;font-size:18px;line-height:1.15;color:#fff;margin-bottom:8px;word-wrap:break-word;overflow-wrap:break-word;hyphens:auto;}
    .dc-intro{font-size:13px;line-height:1.5;color:#b8b0a0;font-style:italic;margin-bottom:18px;}
    .dc-choices{display:flex;align-items:stretch;gap:8px;}
    .dc-choice{flex:1;min-width:0;display:flex;align-items:center;gap:6px;padding:12px 10px;border-radius:12px;
      font-family:Unbounded,sans-serif;font-weight:700;font-size:11px;line-height:1.2;transition:transform .15s;
      word-wrap:break-word;overflow-wrap:break-word;hyphens:auto;box-sizing:border-box;}
    .dc-choice.left{background:linear-gradient(135deg,rgba(176,80,80,.28),rgba(120,45,45,.16));
      border:1.5px solid rgba(220,120,120,.45);color:#ffb3a0;justify-content:flex-start;text-align:left;}
    .dc-choice.right{background:linear-gradient(135deg,rgba(74,170,150,.28),rgba(40,110,95,.16));
      border:1.5px solid rgba(110,210,185,.45);color:#9fe8d4;justify-content:flex-end;text-align:right;}
    .dc-arrow{font-size:18px;opacity:.8;flex-shrink:0;}
    .dc-lbl{flex:1;min-width:0;word-wrap:break-word;overflow-wrap:break-word;}
    .dc-or{display:flex;align-items:center;font-size:10px;color:#7a7264;font-family:Unbounded,sans-serif;
      text-transform:uppercase;letter-spacing:.08em;}
    .dc-choice.left.lit{transform:scale(1.04);box-shadow:0 0 18px rgba(220,120,120,.4);}
    .dc-choice.right.lit{transform:scale(1.04);box-shadow:0 0 18px rgba(110,210,185,.4);}
    .dec-card .fc-pad{padding:18px 18px 20px;}
    .dec-card .fc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.12em;color:#ffcf6b;padding:5px 11px;border-radius:8px;
      background:rgba(200,134,10,.16);border:1px solid rgba(200,134,10,.4);margin-bottom:10px;}
    .dec-card .fc-title{font-family:Unbounded,sans-serif;font-weight:800;font-size:18px;line-height:1.15;color:#fff;}
    .outcome-cascade{position:absolute;top:50%;z-index:3;pointer-events:none;display:flex;flex-direction:column;gap:6px;
      opacity:0;transition:opacity .5s;}
    .outcome-cascade.show{opacity:1;}
    .outcome-cascade.left{left:2vw;transform:translateY(-50%);align-items:flex-start;}
    .outcome-cascade.right{right:2vw;transform:translateY(-50%);align-items:flex-end;}
    .oc-card{border-radius:10px;padding:7px 10px;font-size:10px;font-weight:700;font-family:Unbounded,sans-serif;
      color:#fff;white-space:nowrap;max-width:30vw;overflow:hidden;text-overflow:ellipsis;
      border:1px solid rgba(255,255,255,.18);box-shadow:0 4px 12px rgba(0,0,0,.4);}
    .outcome-cascade.left .oc-card{background:linear-gradient(160deg,rgba(176,80,80,.85),rgba(94,38,38,.9));}
    .outcome-cascade.right .oc-card{background:linear-gradient(160deg,rgba(74,155,142,.85),rgba(29,74,67,.9));}
    .oc-card:nth-child(1){transform:scale(1);opacity:1;}
    .oc-card:nth-child(2){transform:scale(.88);opacity:.78;}
    .oc-card:nth-child(3){transform:scale(.76);opacity:.56;}
    .oc-hint{position:absolute;bottom:6%;left:0;right:0;text-align:center;font-size:11px;color:#c8a05a;
      font-family:Unbounded,sans-serif;letter-spacing:.05em;}
    .dec-timer{position:absolute;top:2%;left:50%;transform:translateX(-50%);z-index:8;
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
    .feed2-sep{display:flex;align-items:center;gap:10px;margin:6px 2px;opacity:.5;}
    .feed2-sep::before,.feed2-sep::after{content:'';flex:1;height:1px;background:linear-gradient(90deg,transparent,rgba(200,134,10,.4),transparent);}
    .feed2-sep-thin{margin:10px 20%;opacity:.3;}
    .feed2-sep-thin::before,.feed2-sep-thin::after{height:1px;}
    .feed2-sep span{font-family:Unbounded,sans-serif;font-size:9px;letter-spacing:.12em;color:#c8a05a;text-transform:uppercase;white-space:nowrap;}
    .msg2.m2-past{opacity:.62;}
    .msg2.m2-past .m2-av{filter:grayscale(.3) brightness(.85);}
    .clue-fly2{position:absolute;z-index:60;font-size:12px;color:#46d89b;font-weight:700;pointer-events:none;
      background:rgba(70,216,155,.2);padding:4px 9px;border-radius:8px;border:1px solid #46d89b;}
    `;
    document.head.appendChild(s);
  }

  function renderFromState(){
    if(!_wrap) return;
    // если лента уже построена для этого события — не пересоздаём (не мигает)
    if(_builtFor===CState.ev && _wrap.children.length>0) return;
    _builtFor=CState.ev;
    _wrap.innerHTML=''; _lastRenderedEv=null;
    // восстанавливаем всю историю кроме последнего (его покажем интерактивно)
    var hist=_history.slice(); var cur=CState.ev||CASE.start;
    if(hist.length===0 || hist[hist.length-1]!==cur){
      // нет истории — начинаем с текущего
      pushEvent(cur, true);
    } else {
      // восстанавливаем прошлые события статично, последнее — интерактивно
      for(var i=0;i<hist.length-1;i++){ renderStatic(hist[i]); }
      _lastRenderedEv=null; pushEvent(cur, true);
    }
  }
  // статичный рендер прошлого события (вся реплики сразу, без печати)
  function renderStatic(evId){
    var ev=CASE.events[evId]; if(!ev) return;
    if(_wrap.children.length>0){
      var sep=document.createElement('div'); sep.className='feed2-sep feed2-sep-thin'; _wrap.appendChild(sep);
    }
    var msgs=buildMessages(ev);
    msgs.forEach(function(m){ addMessageStatic(m); });
  }
  // добавить сообщение без анимации печати (для истории)
  function addMessageStatic(m){
    var el=document.createElement('div');
    if(m.type==='narr'){ el.className='msg2 narr m2-past';
      el.innerHTML='<div class="m2-narr">'+renderClues(m.text)+'</div>'; }
    else if(m.type==='deduce'){ el.className='msg2 deduce m2-past';
      el.innerHTML='<div class="m2-av">🧠</div><div class="m2-body"><div class="m2-head"><span class="m2-nm">Дедукция</span></div><div class="m2-bubble">'+renderClues(m.text)+'</div></div>'; }
    else { var spk=m.speaker||'narrator'; var cls=(spk==='shift')?'shift':(spk==='recruit')?'recruit':'other';
      el.className='msg2 '+cls+' m2-past';
      el.innerHTML='<div class="m2-av av-'+spk+'"><img src="'+avatar(spk)+'"></div><div class="m2-body"><div class="m2-head"><span class="m2-nm">'+(NAMES[spk]||spk)+'</span></div><div class="m2-bubble">'+renderClues(m.text)+'</div></div>'; }
    _wrap.appendChild(el);
    var b=el.querySelector('.m2-bubble,.m2-narr'); if(b) bindClues(b);
  }

  /* раскладываем событие в поток реплик */
  var _lastRenderedEv=null;
  function pushEvent(evId, instant){
    const ev=CASE.events[evId]; if(!ev) return;
    // защита от повторного рендера того же события
    if(_lastRenderedEv===evId && _wrap && _wrap.children.length>0) return;
    _lastRenderedEv=evId;
    CState.ev=evId;
    // добавляем в историю (не дублируя)
    if(_history.indexOf(evId)<0) _history.push(evId);
    // убираем прошлую кнопку/подсказку, но НЕ стираем ленту (история копится)
    var oldc=_wrap.querySelector('.feed2-next,.feed2-find'); if(oldc)oldc.remove();
    _wrap.onclick=null;
    // прошлые сообщения тускнеют
    _wrap.querySelectorAll('.msg2').forEach(function(m){ m.classList.add('m2-past'); m.classList.remove('active'); });
    try{ if(window.updateCaseBg) updateCaseBg(); }catch(_){}

    // тонкий разделитель между событиями (без текста-бейджа — он сбивал с толку)
    if(_wrap.children.length>0){
      var sep=document.createElement('div'); sep.className='feed2-sep feed2-sep-thin';
      _wrap.appendChild(sep);
    }
    const msgs=buildMessages(ev);
    let mi=0;

    // если контента нет (shift-карта) — сразу к решению
    if(msgs.length===0){
      showContinue(ev, evId, function(){}, true);
      try{ if(window.saveCaseState) saveCaseState(); }catch(_){}
      return;
    }

    function next(){
      if(mi<msgs.length){
        addMessage(msgs[mi], ()=>{}); mi++;
        scrollEnd();
        showContinue(ev, evId, next, mi>=msgs.length);
      }
    }
    next();
    try{ if(window.saveCaseState) saveCaseState(); }catch(_){}
  }

  /* событие → массив сообщений */
  function buildMessages(ev){
    const out=[];
    // нарратив
    if(ev.text && ev.text.trim()){
      out.push({type:'narr', text:ev.text});
    }
    // прямая речь
    if(ev.dialogue && window.parseDialogue){
      const lines=parseDialogue(ev);
      lines.forEach(l=>{
        if(!l.speaker || l.speaker==='narrator'){
          out.push({type:'narr', text:l.text});
        } else {
          out.push({type:'speech', speaker:l.speaker, text:l.text});
        }
      });
    }
    // shift-карта: intro показываем в ленте ТОЛЬКО если нет dialogue (иначе intro будет на самой карте)
    if(ev.shift && ev.intro && !ev.dialogue){
      out.push({type:'narr', text:ev.intro});
    }
    // ВАЖНО: дедукция/улика тут НЕ добавляется — она появится ПОСЛЕ мини-игры
    // (раньше спойлерило улику до находки)
    return out;
  }

  /* добавить одно сообщение в ленту */
  function addMessage(m, done){
    _wrap.querySelectorAll('.msg2').forEach(x=>x.classList.remove('active'));
    const el=document.createElement('div');
    if(m.type==='narr'){
      el.className='msg2 narr active';
      el.innerHTML='<div class="m2-narr"></div>';
      _wrap.appendChild(el);
      typeInto(el.querySelector('.m2-narr'), m.text, done);
    } else if(m.type==='deduce'){
      el.className='msg2 deduce active';
      el.innerHTML='<div class="m2-av"><span class="m2-ring"></span>🧠</div>'+
        '<div class="m2-body"><div class="m2-head"><span class="m2-nm">Дедукция</span></div>'+
        '<div class="m2-bubble"></div></div>';
      _wrap.appendChild(el);
      const b=el.querySelector('.m2-bubble');
      typeInto(b, m.text, ()=>{ bindClues(b); done&&done(); }, true);
    } else {
      const spk=m.speaker||'narrator';
      const cls=(spk==='shift')?'shift':(spk==='recruit')?'recruit':'other';
      el.className='msg2 '+cls+' active';
      const av=avatar(spk);
      const moodHtml=m.mood?'<span class="m2-mood" style="background:'+m.moodc+'22;color:'+m.moodc+';border:1px solid '+m.moodc+'55">'+m.mood+'</span>':'';
      el.innerHTML='<div class="m2-av av-'+spk+'"><img src="'+av+'"><span class="m2-ring"></span></div>'+
        '<div class="m2-body"><div class="m2-head"><span class="m2-nm">'+(NAMES[spk]||spk)+'</span>'+moodHtml+'</div>'+
        '<div class="m2-bubble"></div></div>';
      _wrap.appendChild(el);
      typeInto(el.querySelector('.m2-bubble'), m.text, done);
      // в ленте спрайт сбоку НЕ показываем — есть аватар (не перекрывает интерфейс)
    }
  }

  /* печать текста с поддержкой {улики} */
  function typeInto(el, text, done, hasClues){
    el._full=text; el._typing=true;
    // включаем "говорит" на аватаре этой реплики
    var _msgEl=el.closest&&el.closest('.msg2'); var _avEl=_msgEl&&_msgEl.querySelector('.m2-av');
    if(_avEl) _avEl.classList.add('talking');
    const plain=text.replace(/\{([^|]+)\|([^}]+)\}/g,'$1'); // для печати без разметки
    let i=0; el.innerHTML='<span class="m2-caret">▌</span>';
    clearInterval(el._tt);
    el._tt=setInterval(()=>{
      i++;
      if(i>=plain.length){
        clearInterval(el._tt); el._typing=false;
        el.innerHTML=renderClues(text);
        if(hasClues) bindClues(el);
        if(_avEl) _avEl.classList.remove('talking');
        done&&done(); return;
      }
      el.innerHTML=esc(plain.slice(0,i))+'<span class="m2-caret">▌</span>';
    }, 16);
  }
  function finishType(el){
    if(!el||!el._typing) return false;
    clearInterval(el._tt); el._typing=false;
    var _m=el.closest&&el.closest('.msg2'); var _a=_m&&_m.querySelector('.m2-av'); if(_a)_a.classList.remove('talking');
    el.innerHTML=renderClues(el._full); bindClues(el); return true;
  }

  function renderClues(text){
    return esc(text).replace(/\{([^|]+)\|([^}]+)\}/g,(m,disp,name)=>
      '<span class="m2-clue" data-clue="'+escAttr(name)+'">'+esc(disp)+'</span>');
  }
  function bindClues(container){
    container.querySelectorAll('.m2-clue').forEach(tag=>{
      tag.onclick=(e)=>{ e.stopPropagation(); grabClue(tag); };
    });
  }
  function grabClue(tag){
    if(tag.classList.contains('collected')) return;
    tag.classList.add('collected');
    const name=tag.getAttribute('data-clue');
    // ищем clue-объект текущего события
    const ev=CASE.events[CState.ev];
    const clue=(ev&&ev.clue&&ev.clue.name===name)?ev.clue:{id:name,name:name,icon:'🔍',proof:''};
    try{ if(window.grantClue) grantClue(clue); }catch(_){}
    flyToDossier(tag, name);
  }
  function flyToDossier(tag, name){
    const stage=document.getElementById('stage'); if(!stage) return;
    const r=tag.getBoundingClientRect(), sr=stage.getBoundingClientRect();
    const fly=document.createElement('div'); fly.className='clue-fly2';
    fly.textContent='🔍 '+name;
    fly.style.left=(r.left-sr.left)+'px'; fly.style.top=(r.top-sr.top)+'px';
    stage.appendChild(fly);
    requestAnimationFrame(()=>{
      fly.style.transition='all .7s cubic-bezier(.5,0,.7,1)';
      fly.style.left=(sr.width-60)+'px'; fly.style.top=(sr.height-30)+'px'; fly.style.opacity='0'; fly.style.transform='scale(.4)';
    });
    setTimeout(()=>fly.remove(),720);
    try{ Sound.approve&&Sound.approve(); vibrate&&vibrate(12); }catch(_){}
  }

  /* кнопка/подсказка продолжения после всех реплик события */
  function showContinue(ev, evId, nextMsg, allShown){
    // убираем старую кнопку
    const old=_wrap.querySelector('.feed2-next,.feed2-find'); if(old)old.remove();
    if(!allShown){
      const hint=document.createElement('div'); hint.className='feed2-next';
      hint.textContent='далее ▸';
      hint.onclick=()=>{ if(finishCurrentTyping())return; hint.remove(); nextMsg(); };
      _wrap.appendChild(hint);
      // тап по ленте тоже продвигает
      _wrap.onclick=(e)=>{
        if(e.target.closest('.m2-clue')) return;
        if(finishCurrentTyping()) return;
        const h=_wrap.querySelector('.feed2-next'); if(h){ h.remove(); nextMsg(); }
      };
    } else {
      // все реплики показаны — следующий шаг (решение или линейный переход)
      _wrap.onclick=null;
      if(ev.linear){
        const hint=document.createElement('div'); hint.className='feed2-next';
        hint.textContent='далее ▸';
        hint.onclick=()=>{ advanceLinear(ev); };
        _wrap.appendChild(hint);
        _wrap.onclick=(e)=>{ if(!e.target.closest('.m2-clue')) advanceLinear(ev); };
      } else if(ev.shift){
        // shift-карта: сразу карта-решение (выбор версии свайпом, без мини-игры)
        enterDecisionMode();
      } else {
        // наводка перед мини-игрой (если у события есть hint и ещё нет улики)
        if(ev.hint && ev.clue){
          var hintEl=_wrap.querySelector('.feed2-hint');
          if(!hintEl){
            hintEl=document.createElement('div'); hintEl.className='feed2-hint';
            hintEl.innerHTML='<span class="fh-ico">💡</span>'+esc(ev.hint);
            _wrap.appendChild(hintEl);
          }
        }
        const btn=document.createElement('button'); btn.className='feed2-find';
        btn.textContent='🔍 Найти улики';
        btn.onclick=()=>{ openMiniGame(ev); };
        _wrap.appendChild(btn);
      }
    }
    scrollEnd();
  }

  function finishCurrentTyping(){
    const last=_wrap.querySelector('.msg2.active');
    if(!last) return false;
    const el=last.querySelector('.m2-bubble,.m2-narr');
    return finishType(el);
  }

  function advanceLinear(ev){
    if(_busy) return; _busy=true;
    CState.step=(CState.step||0)+1;
    try{ if(window.cSetProgress) cSetProgress(); }catch(_){}
    const nx=ev.next;
    setTimeout(()=>{ _busy=false;
      if(!nx||nx==='__resolve__'){ finish(); } else pushEvent(nx);
    }, 160);
  }

  function openMiniGame(ev){
    try{ if(window.App) App.currentCard=ev; }catch(_){}
    if(window.openHintGame){ window._pendingClue=ev.clue||null; window._pendingReact=ev.react||null; openHintGame(ev); }
    else enterDecisionMode();
  }

  function scrollEnd(){ setTimeout(()=>{ if(_wrap)_wrap.scrollTop=_wrap.scrollHeight; }, 40); }

  /* ── ФАЗА РЕШЕНИЯ (как было — каскады исходов) ── */
  function showReaction(dialogueStr, done){
    // разбираем строку реакции на реплики и показываем в ленте
    if(!dialogueStr){ done&&done(); return; }
    var lines=dialogueStr.split('\n').filter(function(s){return s.trim();});
    var msgs=lines.map(function(line){
      var m=line.match(/^([^:]+):\s*(.+)$/);
      if(m){
        var spk=m[1].trim().toLowerCase();
        var map={'сдвиг':'shift','рекрут':'recruit','миллер':'miller','эленор':'eleanor','куратор':'kurator','патрульный':'narrator'};
        return {type:'speech', speaker:map[spk]||'narrator', text:m[2].trim()};
      }
      return {type:'narr', text:line.trim()};
    });
    // разделитель "после находки"
    var sep=document.createElement('div'); sep.className='feed2-sep';
    sep.innerHTML='<span>улика найдена</span>'; _wrap.appendChild(sep);
    var i=0;
    function nextR(){
      if(i<msgs.length){
        addMessage(msgs[i], function(){}); i++;
        scrollEnd();
        var old=_wrap.querySelector('.feed2-next'); if(old)old.remove();
        if(i<msgs.length){
          var hint=document.createElement('div'); hint.className='feed2-next';
          hint.textContent='далее ▸'; _wrap.appendChild(hint);
          _wrap.onclick=function(){ if(finishCurrentTyping())return; var h=_wrap.querySelector('.feed2-next'); if(h){h.remove(); nextR();} };
        } else {
          _wrap.onclick=null; setTimeout(function(){ done&&done(); }, 500);
        }
      }
    }
    nextR();
  }
  function enterDecisionMode(){
    const ev=CState.ev?CASE.events[CState.ev]:null; if(!ev) return;
    if(ev.linear){ advanceLinear(ev); return; }
    _decision=true;
    const opts=ev.shift?{left:ev.a,right:ev.b}:{left:ev.left,right:ev.right};
    const stage=document.getElementById('stage');
    const dec=document.createElement('div'); dec.className='decision-stage'; dec.id='dec-stage';
    dec.innerHTML='<div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div>'+
      '<div class="dec-timer" id="dec-timer"><div class="dt-ring2"><svg viewBox="0 0 50 50">'+
      '<circle class="bg" cx="25" cy="25" r="21"/><circle class="fg" id="dec-fg" cx="25" cy="25" r="21"/></svg>'+
      '<div class="dt-n" id="dec-n">15</div></div></div><div class="oc-hint">← свайп решает →</div>';
    stage.appendChild(dec);
    requestAnimationFrame(()=>dec.querySelectorAll('.outcome-cascade').forEach(c=>c.classList.add('show')));
    bindDecisionSwipe(ev); startDecTimer();
  }
  function collectOutcomes(opt){
    if(!opt) return []; const out=[]; const toId=opt.to;
    if(toId&&toId!=='__resolve__'&&CASE.events[toId]) out.push(CASE.events[toId].badge||CASE.events[toId].title||'…');
    else if(toId==='__resolve__') out.push('Развязка');
    return out.slice(0,4);
  }
  function cascadeHtml(side,outcomes){
    if(!outcomes.length) outcomes=[side==='left'?'влево':'вправо'];
    return '<div class="outcome-cascade '+side+'">'+outcomes.map(o=>'<div class="oc-card">'+esc(o)+'</div>').join('')+'</div>';
  }
  function decCardInner(ev){
    const lL=ev.shift?(ev.a&&ev.a.label||''):(ev.left&&ev.left.label||'');
    const rL=ev.shift?(ev.b&&ev.b.label||''):(ev.right&&ev.right.label||'');
    const intro=ev.intro||'Реши, как действовать.';
    return '<div class="dc-inner">'+
      '<span class="dc-badge">'+esc(ev.badge||'РЕШЕНИЕ')+'</span>'+
      '<div class="dc-title">'+esc(ev.title||'')+'</div>'+
      '<div class="dc-intro">'+esc(intro)+'</div>'+
      '<div class="dc-choices">'+
        '<div class="dc-choice left"><span class="dc-arrow">◄</span><span class="dc-lbl">'+esc(lL.replace(/^◄\s*/,''))+'</span></div>'+
        '<div class="dc-or">или</div>'+
        '<div class="dc-choice right"><span class="dc-lbl">'+esc(rL.replace(/\s*►$/,''))+'</span><span class="dc-arrow">►</span></div>'+
      '</div></div>';
  }
  function bindDecisionSwipe(ev){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,down=false;
    card.addEventListener('pointerdown',e=>{down=true;sx=e.clientX;card.setPointerCapture&&card.setPointerCapture(e.pointerId);});
    card.addEventListener('pointermove',e=>{if(!down)return;const dx=e.clientX-sx;
      card.style.transform='translateX('+dx*.5+'px) rotate('+dx*.02+'deg)';
      var cl=card.querySelector('.dc-choice.left'),cr=card.querySelector('.dc-choice.right');
      if(cl)cl.classList.toggle('lit',dx<-30); if(cr)cr.classList.toggle('lit',dx>30);});
    card.addEventListener('pointerup',e=>{if(!down)return;down=false;const dx=e.clientX-sx;
      if(Math.abs(dx)>60)commitDecision(ev,dx<0?'left':'right');else card.style.transform='';});
  }
  function commitDecision(ev,dir){
    if(_busy)return;_busy=true;clearInterval(_decTimer);
    const card=document.getElementById('dec-card');
    const opt=ev.shift?(dir==='left'?ev.a:ev.b):(dir==='left'?ev.left:ev.right);
    try{if(window.cApplyOption)cApplyOption(opt);}catch(_){}
    try{Sound.burn&&Sound.burn();vibrate&&vibrate(20);}catch(_){}
    if(card)card.classList.add(dir==='left'?'swipe-left':'swipe-right');
    CState.step=(CState.step||0)+1;
    try{if(window.cSetProgress)cSetProgress();}catch(_){}
    setTimeout(()=>{
      const st=document.getElementById('dec-stage');if(st)st.remove();
      _decision=false;_busy=false;
      try{if(window.hideChar)hideChar();}catch(_){}
      if(opt.to==='__resolve__'||!opt.to){finish();}else pushEvent(opt.to);
    },520);
  }
  function startDecTimer(){
    let left=15;const total=15;
    const fg=document.getElementById('dec-fg'),num=document.getElementById('dec-n'),timer=document.getElementById('dec-timer');
    const R=21,C=2*Math.PI*R;if(fg){fg.style.strokeDasharray=C;fg.style.strokeDashoffset=0;}
    clearInterval(_decTimer);
    _decTimer=setInterval(()=>{left--;if(num)num.textContent=Math.max(0,left);
      if(fg)fg.style.strokeDashoffset=C*(1-left/total);
      if(left<=5&&timer){timer.classList.add('urgent');try{Sound.tap&&Sound.tap();}catch(_){}}
      if(left<=0){clearInterval(_decTimer);if(window.toast)toast('Время вышло','Сдвиг: «Промедление — тоже выбор».','⏱');if(num)num.textContent='!';}
    },1000);
  }

  function finish(){
    try{ const r=window.computeEnding?computeEnding(CState.flags):{kind:'win'};
      if(window.showEnding) showEnding(r);
    }catch(e){ console.error('finish',e); }
  }

  function esc(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function escAttr(s){ return (s||'').replace(/"/g,'&quot;').replace(/</g,'&lt;'); }
})();

