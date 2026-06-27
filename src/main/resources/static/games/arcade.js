/* СДВИГ · arcade.js — независимый модуль аркад */
(function(){
  const GAMES = [
    { key:'Examine', canvas:true, name:'Осмотр места', desc:'Найди улики на сцене', icon:'🔍', opts:{ mission:{target:12} } },
    { key:'Pursuit', canvas:true, name:'Слежка', desc:'Не упусти подозреваемого', icon:'👁', opts:{ mission:{target:20} } },
    { key:'Lockpick', canvas:true, name:'Взлом', desc:'Подбери код замка', icon:'🔓', opts:{ mission:{target:12} } }
  ];

  let game=null;

  function cardHTML(g){
    return `<div class="game-row arcade-card" data-key="${g.key}">
      <div class="gr-stripe gr-s-v"></div>
      <div class="gr-icon">${g.icon}</div>
      <div class="gr-info">
        <div class="gr-name">${g.name}</div>
        <div class="gr-desc">${g.desc}</div>
        <div class="gr-prog"><div class="gr-bar"><div class="gr-fill" style="width:40%"></div></div><div class="gr-lvl">PLAY</div></div>
      </div>
      <div class="gr-arrow">›</div>
    </div>`;
  }

  function renderInto(list){
    if(!list) return;
    if(list.getAttribute('data-arcade')==='1') return;
    list.setAttribute('data-arcade','1');
    list.innerHTML = GAMES.map(cardHTML).join('');
    list.querySelectorAll('.arcade-card').forEach(c=>{
      c.addEventListener('click',()=>launch(c.getAttribute('data-key')));
    });
  }

  function ensure(){
    const list=document.getElementById('game-list');
    if(list) renderInto(list);
  }


  function launchCanvas(g){
    try{ window.Sound && Sound.tap && Sound.tap(); }catch(e){}
    if(window.BgFx && BgFx.pause) BgFx.pause();
    const ov=document.createElement('div');
    ov.id='arcade-overlay';
    ov.innerHTML='<div class="arc-bar"><button class="arc-close" id="arc-close">‹ Выход</button>'+
      '<div class="arc-title">'+g.name+'</div><div style="width:72px"></div></div>'+
      '<div class="arc-stage" id="arc-stage" style="padding:16px;display:flex;align-items:center;justify-content:center"></div>';
    document.body.appendChild(ov);
    const stage=ov.querySelector('#arc-stage');
    const host=document.createElement('div');
    host.style.cssText='width:100%;max-width:520px;height:70vh;';
    stage.appendChild(host);
    function close(){ try{window[g.key]&&window[g.key].stop&&window[g.key].stop();}catch(_){} ov.remove(); if(window.BgFx&&BgFx.resume)BgFx.resume(); }
    ov.querySelector('#arc-close').onclick=close;
    var done=function(ok){ setTimeout(close,600); };
    try{
      window[g.key].start(host, Object.assign({}, g.opts, {
        onWin:function(){ try{toast&&toast('Победа','Улики собраны','🔍');}catch(_){}; done(true); },
        onLose:function(){ try{toast&&toast('Не вышло','Попробуй снова','🔍');}catch(_){}; done(false); }
      }));
    }catch(e){ console.error('canvas game',e); close(); }
  }

  function launch(key){
    const g = GAMES.find(x=>x.key===key);
    if(!g) return;
    // canvas-игры (новые, лёгкие) — запускаем напрямую, без Phaser
    if(g.canvas){ launchCanvas(g); return; }
    if(!window.Phaser){ alert('Phaser не загружен'); return; }
    if(!window[key]){ alert('Игра не найдена: '+key); return; }
    try{ window.Sound && Sound.tap && Sound.tap(); }catch(e){}
    if(window.BgFx && BgFx.pause) BgFx.pause();

    const ov=document.createElement('div');
    ov.id='arcade-overlay';
    ov.innerHTML=`
      <div class="arc-bar">
        <button class="arc-close" id="arc-close">‹ Выход</button>
        <div class="arc-title">${g.name}</div>
        <div style="width:72px"></div>
      </div>
      <div class="arc-stage" id="arc-stage"></div>`;
    document.body.appendChild(ov);

    const stage=ov.querySelector('#arc-stage');
    game=new Phaser.Game({
      type:Phaser.AUTO,
      parent:stage,
      width:800, height:600,
      backgroundColor:'#0f1117',
      scale:{ mode:Phaser.Scale.FIT, autoCenter:Phaser.Scale.CENTER_BOTH },
      // ═══ ввод привязан к canvas игры, а не к window ═══
      // target:null → слушает на своём canvas; touch.capture=false → не глотает чужие тачи
      input:{
        activePointers:2,
        touch:{ capture:false },
        mouse:{ preventDefaultDown:false, preventDefaultUp:false }
      },
      render:{ antialias:true }
    });
    game.scene.add(key, window[key], true, g.opts);

    game.events.once(g.evt,(payload)=>{
      reward(payload);
      setTimeout(close,400);
    });

    ov.querySelector('#arc-close').onclick=close;
  }

  function reward(p){
    try{
      if(!p) return;
      if(window.App && App.profile){
        if(typeof addXP==='function' && p.rewardXP) addXP(p.rewardXP);
        if(typeof addCredits==='function') addCredits(p.deductionSuccess?20:5);
        if(typeof unlockSwipe==='function' && p.deductionSuccess) unlockSwipe();
      }
      if(window.Sound){ p.deductionSuccess?(Sound.win&&Sound.win()):(Sound.deny&&Sound.deny()); }
    }catch(e){}
  }

  function close(){
    try{ if(game){ game.destroy(true); game=null; } }catch(e){}
    const ov=document.getElementById('arcade-overlay');
    if(ov) ov.remove();
    if(window.BgFx && BgFx.resume) BgFx.resume();
  }

  // следим, чтобы карточки всегда были на месте
  function boot(){
    ensure();
    const mo=new MutationObserver(()=>{
      const list=document.getElementById('game-list');
      if(list && list.getAttribute('data-arcade')!=='1') renderInto(list);
    });
    mo.observe(document.body,{childList:true,subtree:true});
    setInterval(ensure,1500);
  }

  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',boot);
  else boot();

  window.Arcade={ launch, close };
})();

