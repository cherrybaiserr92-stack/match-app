/* ═══════════════════════════════════════════════════════════
   СДВИГ · dialogue.js — диалоговая система (визуальная новелла)
   • прямая речь печатается динамически (typewriter) в окне внизу
   • тап = дописать мгновенно; ещё тап = следующая реплика
   • персонажи выезжают с разных сторон, говорящий подсвечен
   • фон притухает, инструменты прячутся на время диалога
   • в карточке остаётся ТОЛЬКО авторский текст (нарратив)

   API:
   Dialogue.play(lines, onDone)   // lines: [{speaker, text}]
   Dialogue.isActive()
   Dialogue.skip()
═══════════════════════════════════════════════════════════ */
(function(){
  'use strict';

  // имена для подписи (id → отображение)
  const NAMES={
    shift:'Сдвиг', recruit:'Рекрут', kurator:'Куратор', arundel:'Аранделл',
    miller:'Миллер', hayes:'Хейс', romero:'Ромеро', conroy:'Конрой',
    jiang:'Цзян', purcell:'Пёрселл', danny:'Дэнни', guests:'Гости'
  };

  let _box=null, _name=null, _text=null, _hint=null, _scrim=null;
  let _lines=[], _i=0, _onDone=null, _active=false;
  let _typing=false, _typeTimer=null, _full='', _shown=0;

  window.Dialogue={
    isActive(){ return _active; },
    play(lines, onDone){
      if(!lines||!lines.length){ onDone&&onDone(); return; }
      _lines=lines; _i=0; _onDone=onDone||null; _active=true;
      injectCSS(); buildUI(); enterMode(); showLine();
    },
    skip(){ finish(); }
  };

  function injectCSS(){
    if(document.getElementById('dlg-css')) return;
    const s=document.createElement('style'); s.id='dlg-css';
    s.textContent=`
    .dlg-scrim{position:fixed;inset:0;z-index:22;background:rgba(6,8,13,.62);
      opacity:0;transition:opacity .4s;pointer-events:none;}
    .dlg-scrim.show{opacity:1;pointer-events:auto;}
    /* притушить карточки ленты во время диалога */
    body.dlg-on .feed .fcard{filter:brightness(.4) saturate(.8);transition:filter .4s;}
    body.dlg-on .tools-bar{opacity:0;pointer-events:none;transition:opacity .3s;transform:translateY(20px);}
    /* говорящий персонаж — ярче, неговорящий — притушен */
    .char-sprite.dlg-dim{filter:brightness(.5) saturate(.85) blur(.5px);}
    .char-sprite.dlg-active{z-index:23 !important;filter:drop-shadow(0 8px 28px rgba(0,0,0,.75)) drop-shadow(0 0 18px rgba(200,134,10,.35)) !important;}

    .dlg-box{position:fixed;left:10px;right:10px;z-index:28;
      bottom:calc(var(--navh,60px) + 6px + var(--safeb,0px));
      border-radius:18px;padding:0;overflow:hidden;
      background:linear-gradient(160deg,rgba(24,20,14,.98),rgba(12,10,7,.99));
      border:1px solid rgba(200,134,10,.45);
      box-shadow:0 16px 44px rgba(0,0,0,.6),inset 0 1px 0 rgba(255,255,255,.06);
      opacity:0;transform:translateY(24px);transition:opacity .35s,transform .35s cubic-bezier(.25,1.1,.4,1);}
    .dlg-box.show{opacity:1;transform:none;}
    .dlg-namebar{display:flex;align-items:center;gap:8px;padding:10px 16px 0;}
    .dlg-namechip{font-family:Unbounded,sans-serif;font-weight:800;font-size:12px;letter-spacing:.04em;
      color:#241701;padding:5px 13px;border-radius:9px;
      background:linear-gradient(180deg,#ffdf95,var(--acc,#c8860a));
      box-shadow:0 3px 8px rgba(200,134,10,.3);}
    .dlg-namechip.narr{background:rgba(255,255,255,.08);color:#9aa3b2;box-shadow:none;}
    .dlg-body{padding:12px 18px 16px;min-height:64px;}
    .dlg-textline{font-size:15px;line-height:1.55;color:#ece2cf;}
    .dlg-textline.narr{font-style:italic;color:#b9b0a0;}
    .dlg-textline .caret{display:inline-block;width:8px;color:var(--acc-2,#ffcf6b);animation:dlgCaret .7s steps(1) infinite;}
    @keyframes dlgCaret{0%,50%{opacity:1}50.01%,100%{opacity:0}}
    .dlg-hint{position:absolute;right:16px;bottom:10px;font-size:10px;color:#c8a05a;
      letter-spacing:.05em;opacity:0;transition:opacity .3s;display:flex;align-items:center;gap:5px;}
    .dlg-hint.show{opacity:.8;animation:dlgHint 1.4s ease-in-out infinite;}
    @keyframes dlgHint{0%,100%{opacity:.4}50%{opacity:.85}}
    .dlg-hint .tri{font-size:13px;}
    `;
    document.head.appendChild(s);
  }

  function buildUI(){
    const host=document.getElementById('main-screen')||document.body;
    _scrim=null; _box=null;
    if(!_scrim){ _scrim=document.createElement('div'); _scrim.className='dlg-scrim'; host.appendChild(_scrim); }
    if(!_box){
      _box=document.createElement('div'); _box.className='dlg-box';
      _box.innerHTML=
        '<div class="dlg-namebar"><span class="dlg-namechip" id="dlg-name">—</span></div>'+
        '<div class="dlg-body"><div class="dlg-textline" id="dlg-text"></div></div>'+
        '';
      host.appendChild(_box);
      _name=_box.querySelector('#dlg-name');
      _text=_box.querySelector('#dlg-text');
      _hint=_box.querySelector('#dlg-hint')||{classList:{add(){},remove(){}}};
    }
    // тап по всему экрану продвигает диалог
    _scrim.onclick=onTap;
    _box.onclick=function(e){ e.stopPropagation(); onTap(); };
  }

  function enterMode(){
    document.body.classList.add('dlg-on');
    requestAnimationFrame(()=>{ _scrim.classList.add('show'); _box.classList.add('show'); });
  }
  function exitMode(){
    document.body.classList.remove('dlg-on');
    _scrim.classList.remove('show'); _box.classList.remove('show');
    // вернуть спрайты в норму
    document.querySelectorAll('.char-sprite').forEach(s=>{ s.classList.remove('dlg-dim','dlg-active'); });
    try{ if(window.hideChar) hideChar(); }catch(_){}
  }

  /* показать текущую реплику */
  function showLine(){
    const line=_lines[_i]; if(!line){ finish(); return; }
    const spk=line.speaker;
    const isNarr=!spk||spk==='narrator';

    // имя
    if(isNarr){ _name.textContent='Рекрут'; _name.classList.add('narr'); }
    else { _name.textContent=NAMES[spk]||spk; _name.classList.remove('narr'); }

    // персонажи: говорящий активен, прочие притушены
    updateSprites(spk, isNarr);

    // печать
    _full=line.text||'';
    _text.className='dlg-textline'+(isNarr?' narr':'');
    startType();
  }

  function updateSprites(spk, isNarr){
    // показываем говорящего (если есть спрайт)
    try{
      if(!isNarr && window.showChar){ showChar(spk); }
    }catch(_){}
    // подсветка: активный ярче
    setTimeout(()=>{
      document.querySelectorAll('.char-sprite').forEach(s=>{
        s.classList.remove('dlg-dim','dlg-active');
        if(!isNarr){ s.classList.add('dlg-active'); }
      });
    }, 30);
  }

  /* typewriter */
  function startType(){
    _typing=true; _shown=0; _text.innerHTML='<span class="caret">▌</span>';
    _hint.classList.remove('show');
    clearInterval(_typeTimer);
    const speed=18; // мс на символ
    _typeTimer=setInterval(()=>{
      _shown++;
      if(_shown>=_full.length){
        clearInterval(_typeTimer); _typing=false;
        _text.textContent=_full;
        _hint.classList.add('show');
        return;
      }
      _text.innerHTML=esc(_full.slice(0,_shown))+'<span class="caret">▌</span>';
      // звук печати (редко, чтобы не трещало)
      if(_shown%3===0){ try{Sound.tap&&Sound.tap();}catch(_){} }
    }, speed);
  }

  function onTap(){
    if(_typing){
      // дописать мгновенно
      clearInterval(_typeTimer); _typing=false;
      _text.textContent=_full; _hint.classList.add('show');
      try{Sound.tap&&Sound.tap();}catch(_){}
      return;
    }
    // следующая реплика
    _i++;
    if(_i>=_lines.length){ finish(); }
    else { try{Sound.nav&&Sound.nav();}catch(_){} showLine(); }
  }

  function finish(){
    clearInterval(_typeTimer); _typing=false; _active=false;
    exitMode();
    const cb=_onDone; _onDone=null; _lines=[]; _i=0;
    setTimeout(()=>{
      // ПОЛНОСТЬЮ убираем scrim/box из DOM, чтобы не блокировать тапы
      try{ if(_scrim&&_scrim.parentNode){_scrim.parentNode.removeChild(_scrim);} _scrim=null; }catch(_){}
      try{ if(_box&&_box.parentNode){_box.parentNode.removeChild(_box);} _box=null; }catch(_){}
      if(cb)cb();
    }, 360);
  }

  function esc(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/\n/g,'<br>'); }

  /* ── парсер: превращает поле dialogue события в массив реплик ──
     Формат поля dialogue может быть:
       "Сдвиг: «реплика»\nРекрут: «ответ»"
     или просто текст одной реплики (тогда speaker берётся из ev.speaker)
  */
  window.parseDialogue=function(ev){
    const out=[];
    const raw=(ev.dialogue||'').trim();
    if(!raw){ return out; }
    // разбиваем по строкам «Имя: реплика»
    const lines=raw.split(/\n+/);
    const nameMap={'сдвиг':'shift','рекрут':'recruit','куратор':'kurator','аранделл':'arundel',
      'миллер':'miller','хейс':'hayes','ромеро':'romero','конрой':'conroy','цзян':'jiang',
      'пёрселл':'purcell','перселл':'purcell','дэнни':'danny','гости':'guests'};
    lines.forEach(ln=>{
      const m=ln.match(/^([А-ЯЁA-Z][а-яёa-z]+)\s*[:—-]\s*(.+)$/);
      if(m){
        const sid=nameMap[m[1].toLowerCase()]||ev.speaker||null;
        out.push({speaker:sid, text:cleanQuotes(m[2])});
      } else {
        out.push({speaker:ev.speaker||null, text:cleanQuotes(ln)});
      }
    });
    return out;
  };
  function cleanQuotes(s){ return (s||'').replace(/^[«»"]/,'').replace(/[«»"]$/,'').trim(); }

})();

