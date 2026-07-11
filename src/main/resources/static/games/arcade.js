/* СДВИГ · arcade.js v2 — аркадный режим с уровнями и растущей сложностью.
   Прогресс на игру хранится в profile.arcadeLvl[key], растёт с победами.
   Сложность генерируется на лету: missionForLevel(key,lvl). */
(function(){
  const GAMES = [
    { key:'Match3',  name:'Улики дела',  desc:'Три в ряд: совпадения, лёд, спецфишки', icon:'💎' },
    { key:'Examine', name:'Осмотр места',desc:'Лупа и темнота: найди улики',           icon:'🔍' },
    { key:'Pursuit', name:'Слежка',      desc:'Не упусти цель в толпе',                icon:'👁' },
    { key:'Lockpick',name:'Взлом сейфа', desc:'Подбери код по логике',                 icon:'🔓' }
  ];

  /* ── уровень игрока в конкретной аркаде ── */
  function lvlOf(key){
    const p=window.App&&App.profile; if(!p) return 1;
    if(!p.arcadeLvl) p.arcadeLvl={};
    return p.arcadeLvl[key]||1;
  }
  function bumpLvl(key){
    const p=window.App&&App.profile; if(!p) return;
    if(!p.arcadeLvl) p.arcadeLvl={};
    p.arcadeLvl[key]=(p.arcadeLvl[key]||1)+1;
    try{ window.saveProfile&&saveProfile(); }catch(_){}
  }

  /* ── генератор сложности: каждый уровень ощутимо жёстче ── */
  function missionForLevel(key,lvl){
    if(key==='Match3'){
      const types=['clear','color','score','combo'];   // цели чередуются
      const t=types[(lvl-1)%types.length];
      const m={ type:t,
        moves:Math.max(12, 21-Math.floor(lvl/2)),      // ходов всё меньше
        ice:  lvl>=3 ? Math.min(12,(lvl-2)*2) : 0,     // с 3-го уровня лёд
        time: Math.max(75, 155-lvl*5),                 // таймер поджимает
        chapter: 1+((lvl-1)%5) };                      // фон-локация меняется
      if(t==='clear'){ m.target=12+lvl*2; }
      else if(t==='color'){ m.target=8+lvl; m.color=(lvl%5); }
      else if(t==='score'){ m.target=400+lvl*90; }
      else { m.target=2+Math.ceil(lvl/3); }
      return m;
    }
    if(key==='Examine') return { target: 8+lvl*2 };              // больше предметов
    if(key==='Pursuit') return { target: Math.min(30,2+lvl*3) }; // дольше вести цель
    return { target:12, lvl:lvl };                               // Lockpick: длина кода/попытки
  }
  function diffLabel(key,lvl){
    if(key==='Match3'){ const m=missionForLevel(key,lvl);
      const T={clear:'очисти '+m.target,color:'собери цвет ×'+m.target,score:m.target+' очков',combo:'каскад ×'+m.target};
      return T[m.type]+(m.ice?' · лёд':'')+' · '+m.moves+' ходов'; }
    if(key==='Examine'){ const need=Math.max(2,Math.min(5,Math.round((8+lvl*2)/4))); return need+' улик в темноте'; }
    if(key==='Pursuit'){ return 'слежка ~'+Math.round((80+Math.min(60,Math.min(30,2+lvl*3)*2))/10)+' сек'; }
    const L=3+Math.min(2,Math.floor((lvl-1)/4));
    return 'код из '+L+' цифр';
  }

  function cardHTML(g){
    const lvl=lvlOf(g.key);
    const fill=((lvl-1)%10)*10;
    return `<div class="game-row arcade-card" data-key="${g.key}">
      <div class="gr-stripe gr-s-v"></div>
      <div class="gr-icon">${g.icon}</div>
      <div class="gr-info">
        <div class="gr-name">${g.name}</div>
        <div class="gr-desc">${diffLabel(g.key,lvl)}</div>
        <div class="gr-prog"><div class="gr-bar"><div class="gr-fill" style="width:${fill}%"></div></div><div class="gr-lvl">УР. ${lvl}</div></div>
      </div>
      <div class="gr-arrow">›</div>
    </div>`;
  }

  function renderInto(list){
    if(!list) return;
    list.setAttribute('data-arcade','1');
    list.innerHTML = GAMES.map(cardHTML).join('');
    list.querySelectorAll('.arcade-card').forEach(c=>{
      c.addEventListener('click',()=>launch(c.getAttribute('data-key')));
    });
  }
  function refresh(){
    const list=document.getElementById('game-list');
    if(list) renderInto(list);
  }
  function ensure(){
    const list=document.getElementById('game-list');
    if(list && list.getAttribute('data-arcade')!=='1') renderInto(list);
  }

  function launch(key){
    const g = GAMES.find(x=>x.key===key);
    if(!g || !window[g.key]) return;
    const lvl=lvlOf(g.key);
    const mission=missionForLevel(g.key,lvl);
    try{ window.Sound && Sound.tap && Sound.tap(); }catch(e){}
    if(window.BgFx && BgFx.pause) BgFx.pause();

    const ov=document.createElement('div');
    ov.id='arcade-overlay';
    ov.innerHTML='<div class="arc-bar"><button class="arc-close" id="arc-close">‹ Выход</button>'+
      '<div class="arc-title">'+g.name+' · ур. '+lvl+'</div><div style="width:72px"></div></div>'+
      '<div class="arc-stage" id="arc-stage" style="padding:12px;display:flex;align-items:center;justify-content:center"></div>';
    document.body.appendChild(ov);
    const stage=ov.querySelector('#arc-stage');
    const host=document.createElement('div');
    host.style.cssText='position:relative;width:100%;max-width:520px;height:76vh;overflow:hidden;border-radius:16px;';
    stage.appendChild(host);
    function close(){ try{ window[g.key].stop&&window[g.key].stop(); }catch(_){}
      ov.remove(); if(window.BgFx&&BgFx.resume)BgFx.resume(); }
    ov.querySelector('#arc-close').onclick=close;

    try{
      window[g.key].start(host, { mission:mission,
        onWin:function(){
          const credits=15+lvl*3, xp=10+lvl*2;
          try{ window.addCredits&&addCredits(credits); }catch(_){}
          try{ window.addXP&&addXP(xp); }catch(_){}
          bumpLvl(g.key);
          try{ toast&&toast('Уровень '+lvl+' пройден!','+'+credits+' 🪙 · дальше уровень '+(lvl+1),'🏆'); }catch(_){}
          refresh();
          setTimeout(close,700);
        },
        onLose:function(){
          try{ toast&&toast('Не вышло','Уровень '+lvl+' ждёт реванша','✗'); }catch(_){}
          setTimeout(close,700);
        }
      });
    }catch(e){ console.error('arcade start',e); close(); }
  }

  function boot(){
    ensure();
    const mo=new MutationObserver(()=>{ ensure(); });
    mo.observe(document.body,{childList:true,subtree:true});
    setInterval(ensure,1500);
  }
  if(document.readyState==='loading') document.addEventListener('DOMContentLoaded',boot);
  else boot();

  window.Arcade={ launch, refresh };
})();
