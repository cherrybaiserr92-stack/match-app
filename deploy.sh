#!/usr/bin/env bash
# СДВИГ R38 — прокачанная лента (аватары, дедукция, кликабельные улики, теги)
set -e
echo ""; echo "══ feed.js → v2 (лента+) ════════════════════════════"
F="src/main/resources/static/games/feed.js"
cp "$F" "${F}.v1.bak" 2>/dev/null || true
cat > "$F" << 'FEED2_EOF'
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

  const NAMES={shift:'Сдвиг',recruit:'Рекрут',kurator:'Куратор',arundel:'Аранделл',
    miller:'Миллер',hayes:'Хейс',romero:'Ромеро',conroy:'Конрой',jiang:'Цзян',
    purcell:'Пёрселл',danny:'Дэнни',guests:'Гости'};
  const CHARV=(window.CHAR_VER||'3');
  function avatar(id){ return id&&window.CHARS&&CHARS[id]?CHARS[id].src+'?v='+CHARV:''; }

  window.Feed={
    init(){ buildShell(); renderFromState(); },
    show(evId){ pushEvent(evId); },
    enterDecision(){ enterDecisionMode(); },
    reset(){ if(_wrap)_wrap.innerHTML=''; _busy=false; _decision=false; clearInterval(_decTimer); }
  };

  function buildShell(){
    const stage=document.getElementById('stage'); if(!stage) return;
    stage.innerHTML='<div class="feed2" id="feed2"></div>';
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
    .m2-av{width:42px;height:42px;border-radius:12px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;
      background-size:cover;background-position:center top;transition:all .3s;}
    .m2-ring{position:absolute;inset:-2px;border-radius:12px;opacity:0;transition:opacity .3s;}
    .msg2.active .m2-av{transform:scale(1.05);}
    .msg2.active .m2-ring{opacity:1;box-shadow:0 0 0 2px currentColor,0 0 16px currentColor;}
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
      display:flex;align-items:center;justify-content:center;font-size:20px;}

    .m2-clue{display:inline-flex;align-items:center;gap:4px;padding:1px 8px;margin:0 2px;border-radius:7px;
      background:rgba(70,216,155,.16);border:1px solid rgba(70,216,155,.4);color:#46d89b;
      font-weight:600;cursor:pointer;font-size:13px;transition:all .2s;white-space:nowrap;}
    .m2-clue:active{transform:scale(.94);}
    .m2-clue.collected{background:rgba(70,216,155,.3);opacity:.8;}
    .m2-clue::before{content:'🔍';font-size:10px;}

    .feed2-next{align-self:center;margin-top:6px;font-size:11px;color:#c8a05a;font-family:Unbounded,sans-serif;
      letter-spacing:.05em;opacity:.7;animation:f2tap 1.5s ease-in-out infinite;padding:8px;cursor:pointer;}
    @keyframes f2tap{0%,100%{opacity:.4}50%{opacity:.8}}
    .feed2-find{align-self:center;margin-top:8px;padding:13px 28px;border:none;border-radius:13px;cursor:pointer;
      background:linear-gradient(180deg,#ffe09a,#c8860a);color:#241701;font-family:Unbounded,sans-serif;
      font-weight:800;font-size:14px;box-shadow:0 6px 18px rgba(200,134,10,.32);}
    .clue-fly2{position:absolute;z-index:60;font-size:12px;color:#46d89b;font-weight:700;pointer-events:none;
      background:rgba(70,216,155,.2);padding:4px 9px;border-radius:8px;border:1px solid #46d89b;}
    `;
    document.head.appendChild(s);
  }

  function renderFromState(){
    if(!_wrap) return; _wrap.innerHTML='';
    pushEvent(CState.ev||CASE.start, true);
  }

  /* раскладываем событие в поток реплик */
  function pushEvent(evId, instant){
    const ev=CASE.events[evId]; if(!ev) return;
    CState.ev=evId;
    try{ if(window.updateCaseBg) updateCaseBg(); }catch(_){}

    const msgs=buildMessages(ev);
    let mi=0;

    // показываем реплики по одной, тап продвигает
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
    // 1. нарратив (text) — если есть
    if(ev.text && ev.text.trim()){
      out.push({type:'narr', text:ev.text});
    }
    // 2. прямая речь (dialogue может быть многострочной)
    if(ev.dialogue && window.parseDialogue){
      const lines=parseDialogue(ev);
      lines.forEach(l=>{
        out.push({type:'speech', speaker:l.speaker, text:l.text});
      });
    }
    // 3. дедукция + улика (если у события есть clue)
    if(ev.clue){
      out.push({type:'deduce', clue:ev.clue,
        text:ev.clue.proof.replace(ev.clue.name, '{'+ev.clue.name+'|'+ev.clue.name+'}')});
    }
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
      el.innerHTML='<div class="m2-av" style="background-image:url('+av+')"><span class="m2-ring"></span></div>'+
        '<div class="m2-body"><div class="m2-head"><span class="m2-nm">'+(NAMES[spk]||spk)+'</span>'+moodHtml+'</div>'+
        '<div class="m2-bubble"></div></div>';
      _wrap.appendChild(el);
      typeInto(el.querySelector('.m2-bubble'), m.text, done);
      // спрайт говорящего сбоку
      try{ if(window.showChar && spk!=='narrator') showChar(spk); }catch(_){}
    }
  }

  /* печать текста с поддержкой {улики} */
  function typeInto(el, text, done, hasClues){
    el._full=text; el._typing=true;
    const plain=text.replace(/\{([^|]+)\|([^}]+)\}/g,'$1'); // для печати без разметки
    let i=0; el.innerHTML='<span class="m2-caret">▌</span>';
    clearInterval(el._tt);
    el._tt=setInterval(()=>{
      i++;
      if(i>=plain.length){
        clearInterval(el._tt); el._typing=false;
        el.innerHTML=renderClues(text);
        if(hasClues) bindClues(el);
        done&&done(); return;
      }
      el.innerHTML=esc(plain.slice(0,i))+'<span class="m2-caret">▌</span>';
    }, 16);
  }
  function finishType(el){
    if(!el||!el._typing) return false;
    clearInterval(el._tt); el._typing=false;
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
      fly.style.left='14px'; fly.style.top='10px'; fly.style.opacity='0'; fly.style.transform='scale(.5)';
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
      hint.textContent='▸ тап — далее';
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
        hint.textContent='▸ тап — продолжить';
        hint.onclick=()=>{ advanceLinear(ev); };
        _wrap.appendChild(hint);
        _wrap.onclick=(e)=>{ if(!e.target.closest('.m2-clue')) advanceLinear(ev); };
      } else {
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
    if(window.openHintGame){ window._pendingClue=ev.clue||null; openHintGame(ev); }
    else enterDecisionMode();
  }

  function scrollEnd(){ setTimeout(()=>{ if(_wrap)_wrap.scrollTop=_wrap.scrollHeight; }, 40); }

  /* ── ФАЗА РЕШЕНИЯ (как было — каскады исходов) ── */
  function enterDecisionMode(){
    const ev=CState.ev?CASE.events[CState.ev]:null; if(!ev) return;
    if(ev.linear){ advanceLinear(ev); return; }
    _decision=true;
    const opts=ev.shift?{left:ev.a,right:ev.b}:{left:ev.left,right:ev.right};
    const stage=document.getElementById('stage');
    const dec=document.createElement('div'); dec.className='decision-stage'; dec.id='dec-stage';
    dec.innerHTML=cascadeHtml('left',collectOutcomes(opts.left))+
      '<div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div>'+
      cascadeHtml('right',collectOutcomes(opts.right))+
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
    return '<div class="fc-pad"><span class="fc-badge">'+(ev.badge||'')+'</span>'+
      '<div class="fc-title">'+(ev.title||'')+'</div>'+
      '<div style="margin-top:12px;display:flex;gap:8px;font-size:11px">'+
      '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(176,80,80,.2);border:1px solid rgba(176,80,80,.4);color:#ff9d85;text-align:center">◄ '+esc(lL.replace(/^◄\s*/,''))+'</div>'+
      '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(74,155,142,.2);border:1px solid rgba(74,155,142,.4);color:#9fe0ff;text-align:center">'+esc(rL.replace(/\s*►$/,''))+' ►</div>'+
      '</div></div>';
  }
  function bindDecisionSwipe(ev){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,down=false;
    card.addEventListener('pointerdown',e=>{down=true;sx=e.clientX;card.setPointerCapture&&card.setPointerCapture(e.pointerId);});
    card.addEventListener('pointermove',e=>{if(!down)return;const dx=e.clientX-sx;card.style.transform='translateX('+dx*.5+'px) rotate('+dx*.02+'deg)';});
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

FEED2_EOF
echo "✓ feed.js → v2 (старый → feed.js.v1.bak)"
echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R38 — прокачанная лента внедрена"
echo "   git add -A && git commit -m 'R38: enhanced feed - avatars, deduction, clickable clues' && git push"
echo "═══════════════════════════════════════════════════════"
