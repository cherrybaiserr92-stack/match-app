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
    purcell:'Пёрселл',danny:'Дэнни',eleanor:'Эленор',cop:'Патрульный',captain:'Капитан',
    pocketman:'Свидетель',guests:'Гости',vivien:'Вивьен',narrator:''};
  function speakerName(spk){
    if(spk==='recruit'){ try{ return (window.playerName?window.playerName():'Рекрут'); }catch(_){ return 'Рекрут'; } }
    return NAMES[spk]||spk;
  }
  // портрет спикера или монограмма-фолбэк (для персонажей без арта, напр. Вивьен)
  function avFace(spk){
    var src=avatar(spk);
    if(src) return '<img src="'+src+'">';
    var nm=speakerName(spk)||'?';
    return '<span class="m2-mono">'+esc(nm.charAt(0).toUpperCase())+'</span>';
  }

  const CHARV=(window.CHAR_VER||'3');
  function avatar(id){
    var C=window.CHARS||(typeof CHARS!=='undefined'?CHARS:null);
    // рекрут — иконка по полу игрока
    if(id==='recruit'){
      try{
        var fem=(window.App&&App.profile&&App.profile.gender==='f');
        var key=fem?'recruit-f':'recruit';
        if(C&&C[key]) return C[key].src+'?v='+CHARV;
        return (fem?'/img/chars/char-recruit-f.png':'/img/chars/char-recruit.png')+'?v='+CHARV;
      }catch(_){}
    }
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
    .m2-mono{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
      font-family:Unbounded,sans-serif;font-weight:800;font-size:24px;color:currentColor;
      background:radial-gradient(circle at 50% 35%,rgba(255,255,255,.1),rgba(0,0,0,.25));}
    /* индивидуальный кроп — голова целиком влезает */
    .m2-av.av-shift img{width:128%;left:-14%;top:1%;}
    .m2-av.av-recruit img{width:150%;left:-25%;top:7%;}
    .m2-av.av-miller img{width:140%;left:-20%;top:5%;}
    .m2-av.av-eleanor img{width:148%;left:-24%;top:5%;}
    .m2-av.av-cop img{width:130%;left:-15%;top:2%;}
    .m2-av.av-captain img{width:125%;left:-12%;top:1%;}
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
    .m2-caret{display:inline-block;width:7px;color:#cfd8e3;animation:m2Caret .7s steps(1) infinite;}
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
      border-left:2px solid rgba(147,161,179,.3);}

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

    /* бит последствия выбора */
    .feed2-aftermath{align-self:stretch;flex:0 0 auto;margin:2px 0;padding:13px 16px 14px;border-radius:14px;
      position:relative;overflow:hidden;border:1px solid #000;border-left:3px solid #e0546e;
      background:linear-gradient(165deg,rgba(30,18,24,.96),rgba(14,10,14,.98));
      box-shadow:0 10px 26px rgba(0,0,0,.5),inset 0 1px 0 rgba(255,255,255,.05);
      opacity:0;transform:translateY(10px);transition:opacity .45s ease,transform .45s cubic-bezier(.2,1,.3,1);}
    .feed2-aftermath.show{opacity:1;transform:none;}
    .fa-eyebrow{font-family:Unbounded,sans-serif;font-weight:700;font-size:8.5px;letter-spacing:.22em;
      text-transform:uppercase;color:#ff8fa8;opacity:.85;margin-bottom:6px;}
    .fa-text{font-size:13.5px;line-height:1.55;color:#e6d9de;font-style:italic;}
    .fa-deltas{display:flex;gap:8px;margin-top:10px;}
    .fa-d{display:inline-flex;align-items:center;gap:4px;padding:4px 10px;border-radius:8px;
      font-family:Unbounded,sans-serif;font-weight:800;font-size:11px;border:1px solid;}
    .fa-d b{font-weight:400;font-size:12px;}
    .fa-d.rap.up{color:#ffb9c4;border-color:rgba(255,143,176,.4);background:rgba(255,143,176,.1);}
    .fa-d.rap.dn{color:#ff9a9a;border-color:rgba(255,93,108,.4);background:rgba(255,93,108,.1);}
    .fa-d.det.up{color:#8ee9c3;border-color:rgba(70,216,155,.4);background:rgba(70,216,155,.1);}
    .fa-d.det.dn{color:#ff9a9a;border-color:rgba(255,93,108,.4);background:rgba(255,93,108,.1);}
    .feed2-next{align-self:center;flex:0 0 auto;margin-top:6px;font-size:11px;color:#93a1b3;font-family:Unbounded,sans-serif;
      letter-spacing:.05em;opacity:.7;animation:f2tap 1.5s ease-in-out infinite;padding:8px;cursor:pointer;}
    @keyframes f2tap{0%,100%{opacity:.4}50%{opacity:.8}}
    .feed2-hint{align-self:center;flex:0 0 auto;max-width:88%;margin:4px auto;padding:10px 14px;border-radius:12px;
      background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.16);color:#cfd8e3;
      font-size:12.5px;line-height:1.45;display:flex;gap:8px;align-items:flex-start;font-style:italic;}
    .feed2-hint .fh-ico{font-size:14px;flex-shrink:0;}
    .feed2-find{align-self:center;flex:0 0 auto;margin-top:8px;padding:2px;border:1px solid #000;border-radius:15px;cursor:pointer;
      background:linear-gradient(160deg,#2a2a2e,#0a0a0c 55%,#000);position:relative;overflow:hidden;
      box-shadow:0 10px 26px rgba(0,0,0,.6),0 0 0 1px rgba(255,255,255,.05),inset 0 1px 0 rgba(255,255,255,.08);}
    .feed2-find span{display:block;padding:12px 26px;border-radius:13px;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));
      color:#ff8fa8;font-family:Unbounded,sans-serif;font-weight:800;font-size:14px;}
    .feed2-find::before{content:'';position:absolute;inset:0;z-index:1;pointer-events:none;opacity:.5;mix-blend-mode:color-dodge;
      background:linear-gradient(115deg,transparent 25%,rgba(224,84,110,.35) 42%,rgba(120,180,220,.4) 50%,rgba(224,180,110,.35) 58%,transparent 75%);
      background-size:250% 250%;animation:sheenMove 5s ease-in-out infinite;}
    .feed2-find:active{transform:scale(.96);}
    .decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;
      align-items:center;justify-content:center;gap:0;padding:20px 14px;
      background:transparent;pointer-events:none;}
    .decision-stage>*{pointer-events:auto;}
#dec-card.canvas-card{background:none!important;background-color:transparent!important;
      border:none!important;box-shadow:none!important;border-radius:0!important;
      width:min(84vw,330px)!important;overflow:visible!important;animation:none!important;
      margin:0 0 14px 0!important;flex:0 0 auto;position:relative;}
    #dec-card.canvas-card canvas{width:100%;height:auto;display:block;
      filter:drop-shadow(0 20px 40px rgba(0,0,0,.7));border-radius:4px;}
    .canvas-card canvas{border-radius:6px;filter:drop-shadow(0 22px 44px rgba(0,0,0,.7));}
    #dec-card canvas.burning{animation:cardBurn .62s ease-in forwards!important;}
    @keyframes cardBurn{
      0%{filter:brightness(1);}
      30%{filter:brightness(1.25) sepia(.4);}
      60%{filter:brightness(.7) sepia(.85) contrast(1.4) hue-rotate(-18deg);}
      100%{filter:brightness(.15) sepia(1) contrast(2.2);opacity:0;transform:scale(.9) translateY(24px) rotate(-3deg);}}
    .burn-ember{position:absolute;pointer-events:none;border-radius:50%;z-index:30;
      background:radial-gradient(circle,#ffd07a,#ff6a2a 50%,#8a1a0a);
      animation:emberFly 1s ease-out forwards;}
    @keyframes emberFly{0%{opacity:1;transform:translateY(0) scale(1);}
      100%{opacity:0;transform:translateY(-90px) scale(.2);}}
    .burn-edge{position:absolute;inset:0;pointer-events:none;z-index:25;opacity:0;border-radius:6px;
      background:radial-gradient(120% 90% at 50% 100%,rgba(255,120,40,.55),transparent 55%);
      animation:burnGlow .62s ease-out forwards;}
    @keyframes burnGlow{0%{opacity:0;}40%{opacity:1;}100%{opacity:0;}}
.dec-stickers{position:relative;display:flex;gap:10px;width:min(78vw,300px);
      margin:0 auto;z-index:15;flex:0 0 auto;}
    .dec-sticker{flex:1;cursor:pointer;transition:transform .15s;transform-origin:center;
      max-width:50%;max-height:66px;overflow:hidden;border-radius:8px;}
    .dec-sticker canvas{width:100%;height:auto;display:block;filter:drop-shadow(0 5px 10px rgba(0,0,0,.5));}
    .dec-sticker:active{transform:scale(.96);}
    .dec-sticker.lit{transform:scale(1.06) translateY(-4px);}
    .dec-sticker.lit canvas{filter:drop-shadow(0 12px 22px rgba(0,0,0,.6)) brightness(1.08);}
    
    .dc-stamp{position:absolute;top:26%;max-width:42%;padding:7px 11px;border-radius:8px;
      font-family:'Special Elite',monospace;font-weight:700;font-size:13px;letter-spacing:.04em;
      opacity:0;pointer-events:none;z-index:20;text-transform:uppercase;white-space:nowrap;
      overflow:hidden;text-overflow:ellipsis;transition:opacity .08s;}
    .dc-stamp.left{left:8%;transform:rotate(-11deg);color:#ffb0b0;border:3px solid rgba(224,106,106,.95);background:rgba(90,20,20,.72);}
    .dc-stamp.right{right:8%;transform:rotate(11deg);color:#8ceed6;border:3px solid rgba(116,216,190,.95);background:rgba(20,70,58,.72);}
    
    /* ═══ BLACK-КАРТА: чёрная рамка + переливы + огонь ═══ */
    .dec-cardbox{position:relative;flex:0 0 auto;margin-top:20px;}
    .dec-card{position:relative;width:min(86vw,340px);border-radius:24px;z-index:5;padding:3px;
      background:linear-gradient(160deg,#2a2a2e,#0a0a0c 55%,#000);border:1.5px solid #000;
      box-shadow:0 24px 60px rgba(0,0,0,.75),0 0 0 1px rgba(255,255,255,.04),
        inset 0 1px 0 rgba(255,255,255,.08),inset 0 -2px 4px rgba(0,0,0,.6);
      touch-action:none;will-change:transform;cursor:grab;transform-style:preserve-3d;}
    .dec-card.grabbed{cursor:grabbing;}
    .dec-card.spring{transition:transform .5s cubic-bezier(.34,1.56,.64,1);}
    .dec-card.shake{animation:cardShake .4s ease;}
    @keyframes cardShake{0%,100%{transform:translateX(0);}20%{transform:translateX(-8px) rotate(-1deg);}
      40%{transform:translateX(8px) rotate(1deg);}60%{transform:translateX(-5px);}80%{transform:translateX(5px);}}
    .dc-inner{border-radius:21px;padding:24px 22px;position:relative;overflow:hidden;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));
      border:1px solid rgba(255,255,255,.06);transition:filter .5s;}
    /* переливы (голографический блик) */
    .dc-inner::before{content:'';position:absolute;inset:0;z-index:1;pointer-events:none;opacity:.55;mix-blend-mode:color-dodge;
      background:linear-gradient(115deg,transparent 25%,rgba(224,84,110,.35) 42%,rgba(120,180,220,.4) 50%,rgba(224,180,110,.35) 58%,transparent 75%);
      background-size:250% 250%;animation:sheenMove 5s ease-in-out infinite;}
    @keyframes sheenMove{0%,100%{background-position:0% 0%;}50%{background-position:100% 100%;}}
    .dc-inner::after{content:'';position:absolute;top:0;left:0;right:0;height:45%;z-index:1;pointer-events:none;
      background:linear-gradient(180deg,rgba(255,255,255,.06),transparent);}
    .dc-badge,.dc-title,.dc-intro{position:relative;z-index:2;}
    .dc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;letter-spacing:.14em;
      color:#fff;padding:5px 13px;border-radius:20px;background:linear-gradient(135deg,#e0546e,#8e1e36);
      box-shadow:0 3px 12px rgba(142,30,54,.4);margin-bottom:14px;}
    .dc-title{font-family:Unbounded,sans-serif;font-weight:900;font-size:22px;line-height:1.13;color:#fff;
      margin-bottom:10px;overflow-wrap:break-word;text-wrap:balance;}
    .dc-intro{font-size:14.5px;line-height:1.6;color:#c8bcc2;text-wrap:pretty;}
    /* улики «в деле» на карте решения */
    .dc-evidence{position:relative;z-index:2;display:flex;flex-wrap:wrap;align-items:center;gap:6px;margin-top:13px;pointer-events:none;}
    .dc-ev-label{font-family:Unbounded,sans-serif;font-weight:700;font-size:8px;letter-spacing:.16em;
      text-transform:uppercase;color:#46d89b;opacity:.85;}
    .dc-ev-chip{display:inline-flex;align-items:center;gap:4px;font-size:11px;font-weight:600;
      padding:4px 9px;border-radius:8px;color:#8ee9c3;
      background:rgba(70,216,155,.12);border:1px solid rgba(70,216,155,.35);}
    .dc-ev-more{font-size:10px;font-weight:700;color:#8ee9c3;opacity:.7;}
    /* огонь-спрайт (языки снизу) */
    .dc-fire{position:absolute;left:0;right:0;bottom:-8%;height:120%;z-index:20;pointer-events:none;opacity:0;
      background-image:url(/img/cards/fire-sheet.png);background-repeat:no-repeat;
      mix-blend-mode:screen;transition:opacity .3s ease;}
    /* ПЛАШКИ выбора в стиле карты */
    .dc-choices{display:flex;gap:12px;width:min(86vw,340px);margin:16px auto 0;z-index:15;flex:0 0 auto;}
    .dc-choice{flex:1;min-width:0;border-radius:16px;padding:2px;cursor:pointer;
      transition:transform .2s cubic-bezier(.34,1.56,.64,1),box-shadow .25s;
      background:linear-gradient(160deg,#2a2a2e,#0a0a0c 55%,#000);border:1px solid #000;
      box-shadow:0 8px 20px rgba(0,0,0,.6),inset 0 1px 0 rgba(255,255,255,.06);}
    .dc-choice-in{border-radius:14px;padding:13px 10px;text-align:center;position:relative;overflow:hidden;
      background:linear-gradient(165deg,rgba(26,22,28,.95),rgba(14,10,16,.98));
      font-family:Unbounded,sans-serif;font-weight:700;font-size:11.5px;line-height:1.25;}
    .dc-choice-in::before{content:'';position:absolute;inset:0;z-index:1;pointer-events:none;opacity:.5;mix-blend-mode:color-dodge;
      background:linear-gradient(115deg,transparent 30%,rgba(224,84,110,.3) 45%,rgba(120,180,220,.35) 52%,rgba(224,180,110,.3) 60%,transparent 75%);
      background-size:250% 250%;animation:sheenMove 5s ease-in-out infinite;}
    .dc-choice-in span{position:relative;z-index:2;}
    .dc-choice.left .dc-choice-in span{color:#ffb9c4;}
    .dc-fx{display:flex;gap:4px;justify-content:center;margin-top:6px;position:relative;z-index:2;}
    .dc-fx i{width:6px;height:6px;border-radius:50%;}
    .dc-fx .fx-rap{background:#ff8fb0;box-shadow:0 0 6px rgba(255,143,176,.7);}
    .dc-fx .fx-det{background:#46d89b;box-shadow:0 0 6px rgba(70,216,155,.7);}
    .dc-choice.right .dc-choice-in span{color:#a8e2e8;}
    .dc-choice:active{transform:scale(.96);}
    .dc-choice.left.lit{transform:scale(1.06);box-shadow:0 10px 24px rgba(0,0,0,.6),0 0 22px rgba(224,84,110,.5);}
    .dc-choice.right.lit{transform:scale(1.06);box-shadow:0 10px 24px rgba(0,0,0,.6),0 0 22px rgba(90,180,200,.5);}
    .dec-card .fc-pad{padding:18px 18px 20px;}
    .dec-card .fc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.12em;color:#ff9db2;padding:5px 11px;border-radius:8px;
      background:rgba(176,38,66,.16);border:1px solid rgba(216,74,100,.42);margin-bottom:10px;}
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
    .oc-hint{position:absolute;bottom:6%;left:0;right:0;text-align:center;font-size:11px;color:#c06478;
      font-family:Unbounded,sans-serif;letter-spacing:.05em;}
    .dec-timer{position:absolute;top:2%;left:50%;transform:translateX(-50%);z-index:8;
      display:flex;flex-direction:column;align-items:center;gap:3px;}
    .dt-ring2{width:50px;height:50px;position:relative;}
    .dt-ring2 svg{width:100%;height:100%;transform:rotate(-90deg);}
    .dt-ring2 .bg{fill:none;stroke:rgba(255,255,255,.1);stroke-width:5;}
    .dt-ring2 .fg{fill:none;stroke:#d84a64;stroke-width:5;stroke-linecap:round;transition:stroke-dashoffset .25s linear,stroke .3s;}
    .dt-n{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
      font-family:Unbounded,sans-serif;font-weight:900;font-size:17px;color:#fff;}
    .dec-timer.urgent .fg{stroke:#ff5d6c;}
    .dec-timer.urgent .dt-n{color:#ff5d6c;animation:dtP .5s ease-in-out infinite;}
    @keyframes dtP{0%,100%{transform:scale(1)}50%{transform:scale(1.18)}}
    .feed2-sep{display:flex;align-items:center;gap:10px;margin:6px 2px;opacity:.5;}
    .feed2-sep::before,.feed2-sep::after{content:'';flex:1;height:1px;background:linear-gradient(90deg,transparent,rgba(224,84,110,.4),transparent);}
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
      el.innerHTML='<div class="m2-av av-'+spk+'">'+avFace(spk)+'</div><div class="m2-body"><div class="m2-head"><span class="m2-nm">'+speakerName(spk)+'</span></div><div class="m2-bubble">'+renderClues(m.text)+'</div></div>'; }
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
    _wrap.querySelectorAll('.feed2-next,.feed2-find').forEach(function(b){b.remove();});
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
    if(ev.dialogue){
      var NMAP={'сдвиг':'shift','рекрут':'recruit','миллер':'miller','эленор':'eleanor','куратор':'kurator','патрульный':'cop','парень':'miller','старуха':'eleanor','аранделл':'arundel','директор':'arundel','печатник':'pocketman','старик':'miller','посредник':'pocketman','кросс':'vivien','вивьен':'vivien','мадам':'vivien','капитан':'captain','хейс':'hayes','дэнни':'danny'};
      String(ev.dialogue).split('\n').forEach(function(line){
        line=line.trim(); if(!line) return;
        var m=line.match(/^([^:«»]{2,20}):\s*(.+)$/);
        if(m && NMAP[m[1].trim().toLowerCase()]){
          out.push({type:'speech', speaker:NMAP[m[1].trim().toLowerCase()], text:m[2].trim(), who:m[1].trim()});
        } else {
          out.push({type:'narr', text:line});
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
      el.innerHTML='<div class="m2-av av-'+spk+'">'+avFace(spk)+'<span class="m2-ring"></span></div>'+
        '<div class="m2-body"><div class="m2-head"><span class="m2-nm">'+speakerName(spk)+'</span>'+moodHtml+'</div>'+
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

  function _genderText(text){
    if(!text) return text;
    var fem=false;
    try{ fem=(window.App&&App.profile&&App.profile.gender==='f'); }catch(_){}
    // {муж|жен} → выбираем по полу
    return String(text).replace(/\{([^|{}]*)\|([^|{}]*)\}/g, function(_,m,f){ return fem?f:m; });
  }
  function _playerName(text){
    if(!text) return text;
    var nm='Рекрут';
    try{ nm=(window.playerName?window.playerName():'Рекрут'); }catch(_){}
    return text.replace(/Рекрут/g, nm);
  }
  function renderClues(text){
    text=_playerName(text);
    text=_genderText(text);
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
      var _chip=document.getElementById('ev-chip');
      if(_chip){ var cr=_chip.getBoundingClientRect(); var pr=fly.parentElement.getBoundingClientRect();
        fly.style.left=(cr.left-pr.left+cr.width/2-20)+'px'; fly.style.top=(cr.top-pr.top+cr.height/2-20)+'px';
      } else { fly.style.left=(sr.width-60)+'px'; fly.style.top=(sr.height-30)+'px'; }
      fly.style.opacity='0'; fly.style.transform='scale(.4)';
    });
    setTimeout(()=>fly.remove(),720);
    try{ Sound.approve&&Sound.approve(); vibrate&&vibrate(12); }catch(_){}
  }

  /* кнопка/подсказка продолжения после всех реплик события */
  function showContinue(ev, evId, nextMsg, allShown){
    // убираем старую кнопку
    _wrap.querySelectorAll('.feed2-next,.feed2-find').forEach(function(b){b.remove();});
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
        // линейное событие с НЕпойманной уликой -> тоже даём мини-игру,
        // после победы enterDecisionMode увидит ev.linear и продолжит по ev.next
        if(_hasUnfoundClue(ev)){
          renderHint(ev); renderFindButton(ev);
        } else {
          const hint=document.createElement('div'); hint.className='feed2-next';
          hint.textContent='далее ▸';
          hint.onclick=()=>{ advanceLinear(ev); };
          _wrap.appendChild(hint);
          _wrap.onclick=(e)=>{ if(!e.target.closest('.m2-clue')) advanceLinear(ev); };
        }
      } else if(ev.shift){
        // shift-карта: ждём, пока допечатается последняя реплика, потом карта
        var _waitType=function(){
          var anyTyping=false;
          _wrap.querySelectorAll('.m2-bubble,.m2-narr').forEach(function(b){ if(b._typing)anyTyping=true; });
          if(anyTyping){ setTimeout(_waitType,120); }
          else { setTimeout(function(){ enterDecisionMode(); }, 400); }
        };
        _waitType();
      } else {
        // развилка: мини-игра разблокирует свайп (плюс улика, если есть)
        renderHint(ev); renderFindButton(ev);
      }
    }
    scrollEnd();
  }
  // улика события уже собрана?
  function _hasUnfoundClue(ev){
    if(!ev || !ev.clue) return false;
    var id=ev.clue.id; if(!id) return true;
    var have=(typeof CState!=='undefined' && CState.clues)?CState.clues:[];
    return !have.some(function(c){ return c && c.id===id; });
  }
  function renderHint(ev){
    if(!(ev.hint && ev.clue)) return;
    if(_wrap.querySelector('.feed2-hint')) return;
    var hintEl=document.createElement('div'); hintEl.className='feed2-hint';
    hintEl.innerHTML='<span class="fh-ico">💡</span>'+esc(ev.hint);
    _wrap.appendChild(hintEl);
  }
  function renderFindButton(ev){
    if(_wrap.querySelector('.feed2-find')) return;
    var btn=document.createElement('button'); btn.className='feed2-find';
    var hasClue=_hasUnfoundClue(ev);
    btn.innerHTML='<span>🔍 '+(hasClue?'Найти улику':'Осмотреться')+'</span>';
    btn.onclick=function(){ openMiniGame(ev); };
    _wrap.appendChild(btn);
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
      var m=line.match(/^([^:«»]{2,20}):\s*(.+)$/);
      if(m){
        var spk=m[1].trim().toLowerCase();
        var map={'сдвиг':'shift','рекрут':'recruit','миллер':'miller','эленор':'eleanor','куратор':'kurator',
          'патрульный':'cop','парень':'miller','старуха':'eleanor','аранделл':'arundel','директор':'arundel',
          'печатник':'pocketman','старик':'miller','посредник':'pocketman','кросс':'vivien','вивьен':'vivien',
          'мадам':'vivien','капитан':'captain','хейс':'hayes','дэнни':'danny'};
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
    if(!stage){ console.error('enterDecision: нет stage'); return; }
    // убрать старую карту решения если осталась (чинит пустой экран после мини-игры)
    var _oldDec=document.getElementById('dec-stage'); if(_oldDec)_oldDec.remove();
    const dec=document.createElement('div'); dec.className='decision-stage'; dec.id='dec-stage';
    dec.innerHTML='<div class="dec-timer" id="dec-timer"><div class="dt-ring2"><svg viewBox="0 0 50 50">'+
      '<circle class="bg" cx="25" cy="25" r="21"/><circle class="fg" id="dec-fg" cx="25" cy="25" r="21"/></svg>'+
      '<div class="dt-n" id="dec-n">15</div></div></div>'+
      '<div class="dec-cardbox" id="dec-cardbox"><div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div></div>'+
      '<div class="dc-choices" id="dec-choices">'+decChoicesInner(ev)+'</div>';
    stage.appendChild(dec);
    requestAnimationFrame(()=>{
      dec.querySelectorAll('.outcome-cascade').forEach(c=>c.classList.add('show'));
      try{
        var c=document.getElementById('dec-card');
        if(c){
          var r={l:c.offsetLeft,t:c.offsetTop,w:c.offsetWidth,h:c.offsetHeight};
          for(var i=2;i>=1;i--){
            var d=document.createElement('div');d.className='dec-deck';
            d.style.cssText='position:absolute;left:'+r.l+'px;top:'+(r.t+i*9)+'px;width:'+r.w+'px;height:'+r.h+'px;'+
              'border-radius:18px;z-index:'+(4-i)+';transform:scale('+(1-i*0.05)+');transform-origin:50% 0;'+
              'background:linear-gradient(165deg,#141014,#0b080a);border:1px solid rgba(176,38,66,'+(0.35-i*0.12)+');'+
              'box-shadow:0 10px 26px rgba(0,0,0,.45);pointer-events:none;';
            dec.insertBefore(d,c);
          }
        }
      }catch(_){}
    });
    (function(){
      var box=document.getElementById('dec-choices');
      if(box){ box.querySelectorAll('.dc-choice').forEach(function(c){
        c.addEventListener('click',function(){ commitDecision(ev, c.getAttribute('data-side')); });
      }); }
    })();
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
    const stampL=esc((lL||'').replace(/^\u25c4\s*/,'').split(/\s+/).slice(0,2).join(' '));
    const stampR=esc((rL||'').replace(/\s*\u25ba$/,'').split(/\s+/).slice(0,2).join(' '));
    return '<div class="dc-inner">'+
      '<div class="dc-stamp left">'+stampL+'</div>'+
      '<div class="dc-stamp right">'+stampR+'</div>'+
      '<span class="dc-badge">'+esc(ev.badge||'РЕШЕНИЕ')+'</span>'+
      '<div class="dc-title">'+esc(ev.title||'')+'</div>'+
      '<div class="dc-intro">'+esc(intro)+'</div>'+
      _evidenceStrip()+
      '<div class="dc-fire"></div>'+
      '</div>';
  }
  // улики «в деле» на карте решения: выбор виден опёртым на собранные доказательства
  function _evidenceStrip(){
    var cl=(typeof CState!=='undefined' && CState.clues)?CState.clues:[];
    if(!cl.length) return '';
    var shown=cl.slice(-2);
    var chips=shown.map(function(c){ return '<span class="dc-ev-chip">'+(c.icon||'🔍')+' '+esc(c.name||'')+'</span>'; }).join('');
    var more=cl.length>shown.length ? '<span class="dc-ev-more">+'+(cl.length-shown.length)+'</span>' : '';
    return '<div class="dc-evidence"><span class="dc-ev-label">В деле</span>'+chips+more+'</div>';
  }
  // плашки выбора ПОД картой (чёрная рамка + переливы, клик = commitDecision)
  // точки-предвестники (Reigns): выбор заденет Сдвига (розовая) / Детектива (зелёная)
  function fxDots(opt){
    if(!opt) return '';
    var d='';
    if(typeof opt.rapport==='number'&&opt.rapport!==0) d+='<i class="fx-rap"></i>';
    if(typeof opt.dscore==='number'&&opt.dscore!==0) d+='<i class="fx-det"></i>';
    return d?'<span class="dc-fx">'+d+'</span>':'';
  }
  function decChoicesInner(ev){
    const oL=ev.shift?ev.a:ev.left, oR=ev.shift?ev.b:ev.right;
    const lL=oL&&oL.label||'', rL=oR&&oR.label||'';
    const clean=s=>esc((s||'').replace(/^◄\s*/,'').replace(/\s*►$/,''));
    return '<div class="dc-choice left" data-side="left"><div class="dc-choice-in"><span>'+clean(lL)+'</span>'+fxDots(oL)+'</div></div>'+
      '<div class="dc-choice right" data-side="right"><div class="dc-choice-in"><span>'+clean(rL)+'</span>'+fxDots(oR)+'</div></div>';
  }
  function bindDecisionSwipe(ev){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,sy=0,down=false,dx=0,dy=0,vx=0,lastX=0,lastT=0,raf=0,armed=false;
    const TH=Math.min(window.innerWidth*0.28,120);   // порог по дистанции
    const FLICK=0.55;                                 // порог по скорости, px/ms
    card.style.transformOrigin='50% 115%';            // поворот от нижнего края
    function paint(){
      raf=0;
      const rot=dx*0.07, ty=Math.abs(dx)*-0.04+dy*0.12;
      card.style.transform='translate3d('+dx+'px,'+ty+'px,0) rotate('+rot+'deg) scale(1.02)';
      const p=Math.min(1,Math.abs(dx)/TH);
      const sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');
      if(sl)sl.style.opacity=dx<0?p:0;
      if(sr)sr.style.opacity=dx>0?p:0;
      const box=document.getElementById('dec-choices');
      const cl=box&&box.querySelector('.dc-choice.left'),cr=box&&box.querySelector('.dc-choice.right');
      if(cl)cl.classList.toggle('lit',dx<-TH*0.4);
      if(cr)cr.classList.toggle('lit',dx>TH*0.4);
      const over=Math.abs(dx)>TH;
      if(over&&!armed){armed=true;try{vibrate&&vibrate(8);}catch(_){}try{Sound.tap&&Sound.tap();}catch(_){}}
      else if(!over&&armed){armed=false;}
    }
    function onDown(e){
      down=true;dx=0;dy=0;vx=0;sx=e.clientX;sy=e.clientY;lastX=e.clientX;lastT=performance.now();
      card.classList.remove('spring');card.classList.add('grabbed');
      card.setPointerCapture&&card.setPointerCapture(e.pointerId);
    }
    function onMove(e){
      if(!down)return;
      const t=performance.now();
      dx=e.clientX-sx; dy=e.clientY-sy;
      const dt=Math.max(1,t-lastT);
      vx=vx*0.8+((e.clientX-lastX)/dt)*0.2;           // сглаженная скорость
      lastX=e.clientX;lastT=t;
      if(!raf)raf=requestAnimationFrame(paint);
    }
    function onUp(){
      if(!down)return;down=false;
      card.classList.remove('grabbed');
      if(raf){cancelAnimationFrame(raf);raf=0;}
      const commit=Math.abs(dx)>TH||(Math.abs(vx)>FLICK&&Math.abs(dx)>24);
      if(commit){
        flyOut(); commitDecision(ev,(dx||vx)<0?'left':'right',true);
      }else{
        card.classList.add('spring');
        card.style.transform='';
        const sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');
        if(sl)sl.style.opacity=0; if(sr)sr.style.opacity=0;
        document.querySelectorAll('#dec-choices .dc-choice.lit').forEach(c=>c.classList.remove('lit'));
        armed=false;
        setTimeout(()=>card.classList.remove('spring'),470);
      }
    }
    function flyOut(){
      const dir=(dx||vx)<0?-1:1;
      const dist=window.innerWidth*1.2;
      const speed=Math.max(Math.abs(vx),0.9);          // px/ms — вылет со скоростью пальца
      const dur=Math.min(520,Math.max(240,dist/speed));
      card.style.transition='transform '+dur+'ms cubic-bezier(.22,.9,.36,1),opacity '+dur+'ms ease';
      card.style.transform='translate3d('+(dir*dist)+'px,'+(-dist*0.08)+'px,0) rotate('+(dir*24)+'deg)';
      card.style.opacity='0';
    }
    card.addEventListener('pointerdown',onDown);
    card.addEventListener('pointermove',onMove);
    card.addEventListener('pointerup',onUp);
    card.addEventListener('pointercancel',onUp);
  }
  function burnCard(card){
    if(!card)return;
    var box=document.getElementById('dec-cardbox');
    var inner=card.querySelector('.dc-inner');
    var fire=card.querySelector('.dc-fire');
    var COLS=5,ROWS=4,NFR=20;
    if(fire){
      var fw=fire.offsetWidth,fh=fire.offsetHeight;
      fire.style.backgroundSize=(fw*COLS)+'px '+(fh*ROWS)+'px';
      var frame=0;
      var iv=setInterval(function(){
        var cx=(frame%COLS)*fw,cy=Math.floor(frame/COLS)*fh;
        fire.style.backgroundPosition=(-cx)+'px '+(-cy)+'px';
        frame++; if(frame>=NFR)frame=0;
      },1000/24);
      fire.style.opacity='1';
      setTimeout(function(){clearInterval(iv);},1400);
    }
    if(inner){
      inner.style.filter='brightness(.6)';
      setTimeout(function(){inner.style.filter='brightness(.35) contrast(1.3) sepia(.4)';},300);
    }
    try{Sound.burn&&Sound.burn();}catch(_){}
  }

  function commitDecision(ev,dir,flew,swipeDir){
    if(_busy)return;_busy=true;clearInterval(_decTimer);
    const card=document.getElementById('dec-card');
    const opt=ev.shift?(dir==='left'?ev.a:ev.b):(dir==='left'?ev.left:ev.right);
    try{if(window.cApplyOption)cApplyOption(opt);}catch(_){}
    try{Sound.burn&&Sound.burn();vibrate&&vibrate(20);}catch(_){}
    if(card)burnCard(card);
    // вылет карты в сторону свайпа (одновременно с огнём)
    var box=document.getElementById('dec-cardbox');
    if(box&&flew){
      var dirs=(swipeDir||(dir==='left'?-1:1));
      var dist=window.innerWidth*1.3;
      box.style.transition='transform .85s cubic-bezier(.4,0,.6,1),opacity .7s ease-in .15s';
      requestAnimationFrame(function(){
        box.style.transform='translate3d('+(dirs*dist)+'px,-30px,0) rotate('+(dirs*24)+'deg) scale(.85)';
        box.style.opacity='0';
      });
    }
    CState.step=(CState.step||0)+1;
    try{if(window.cSetProgress)cSetProgress();}catch(_){}
    setTimeout(()=>{
      const st=document.getElementById('dec-stage');if(st)st.remove();
      _decision=false;_busy=false;
      try{if(window.hideChar)hideChar();}catch(_){}
      var go=function(){ if(opt.to==='__resolve__'||!opt.to){finish();}else pushEvent(opt.to); };
      // бит последствия: показать в ленте, к чему привёл выбор (opt.evidence + сдвиг шкал)
      if(opt.evidence && _wrap){ afterChoiceBeat(opt, go); } else { go(); }
    },900);
  }
  /* ── БИТ ПОСЛЕДСТВИЯ ВЫБОРА ─────────────────────────────
     Замыкает петлю: свайп → видимое последствие → следующая сцена.
     Использует opt.evidence (написан в сценарии) + показывает,
     какие шкалы двинулись. Без этого выбор ощущался пустым. */
  function _choiceDeltas(opt){
    var out='';
    if(typeof opt.rapport==='number'&&opt.rapport){ var up=opt.rapport>0;
      out+='<span class="fa-d rap '+(up?'up':'dn')+'"><b>🎩</b>'+(up?'+':'−')+Math.abs(opt.rapport)+'</span>'; }
    if(typeof opt.dscore==='number'&&opt.dscore){ var u2=opt.dscore>0;
      out+='<span class="fa-d det '+(u2?'up':'dn')+'"><b>🔍</b>'+(u2?'+':'−')+Math.abs(opt.dscore)+'</span>'; }
    return out;
  }
  function afterChoiceBeat(opt, done){
    _wrap.querySelectorAll('.feed2-next,.feed2-find').forEach(function(b){b.remove();});
    _wrap.querySelectorAll('.msg2').forEach(function(m){ m.classList.add('m2-past'); });
    var el=document.createElement('div'); el.className='feed2-aftermath';
    var dl=_choiceDeltas(opt);
    el.innerHTML='<div class="fa-eyebrow">твой ход</div>'+
      '<div class="fa-text">'+esc(opt.evidence)+'</div>'+
      (dl?'<div class="fa-deltas">'+dl+'</div>':'');
    _wrap.appendChild(el);
    requestAnimationFrame(function(){ el.classList.add('show'); });
    scrollEnd();
    var advanced=false;
    function advance(){ if(advanced)return; advanced=true;
      _wrap.onclick=null; var n=_wrap.querySelector('.feed2-next'); if(n)n.remove();
      if(done)done(); }
    var hint=document.createElement('div'); hint.className='feed2-next'; hint.textContent='далее ▸';
    hint.onclick=advance; _wrap.appendChild(hint);
    _wrap.onclick=function(e){ if(!e.target.closest('.m2-clue')) advance(); };
    setTimeout(advance, 5000); // страховка: не застрять
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

