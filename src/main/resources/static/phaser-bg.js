/* ═══════════════════════════════════════════════
   СДВИГ · phaser-bg.js v10 — фон кабинета (вкладка Дела)
   ✓ Фото-фон bg-cases.jpg (детективный стол)
   ✓ ОЧЕНЬ плавный параллакс (сглаживание + ease)
   ✓ Лёгкое свечение лампы (дышит)
   ✓ Пылинки
   ✓ input:false
═══════════════════════════════════════════════ */
(function(){
  let game=null, scene=null, paused=false;
  let tx=0, ty=0;            // целевое смещение
  let cx=0, cy=0;            // текущее (сглаженное)
  let vx=0, vy=0;            // скорость (для пружинного сглаживания)
  let frame=0;

  function boot(){
    if(game || !window.Phaser) return;
    game = new Phaser.Game({
      type:Phaser.AUTO, parent:'bg-fx',
      width:window.innerWidth, height:window.innerHeight,
      transparent:true, banner:false,
      input:false,
      fps:{ target:60, forceSetTimeOut:false },   // выше fps = плавнее параллакс
      render:{ powerPreference:'high-performance', antialias:true },
      scale:{ mode:Phaser.Scale.RESIZE },
      scene:{ preload, create, update }
    });
    const kill=()=>document.querySelectorAll('#bg-fx canvas,#bg-fx *')
      .forEach(c=>{ c.style.pointerEvents='none'; c.style.touchAction='none'; });
    [40,200,600].forEach(t=>setTimeout(kill,t));
    if(window.DeviceOrientationEvent){
      window.addEventListener('deviceorientation',e=>{
        if(e.gamma!=null) tx=Math.max(-1,Math.min(1,e.gamma/40));
        if(e.beta!=null)  ty=Math.max(-1,Math.min(1,(e.beta-45)/40));
      },{passive:true});
    }
  }

  function preload(){ this.load.image('cases','/img/bg-cases.jpg'); }

  function create(){
    scene=this;
    const W=scene.scale.width, H=scene.scale.height;

    const photo=scene.add.image(W/2,H/2,'cases').setDepth(0);
    const scl=Math.max(W/photo.width,H/photo.height)*1.14;
    photo.setScale(scl);
    scene._photo=photo;

    // мягкая виньетка для глубины
    const vig=scene.add.graphics().setDepth(1);
    vig.fillStyle(0x000000,0.32); vig.fillRect(0,0,W,H*0.16);
    vig.fillStyle(0x000000,0.42); vig.fillRect(0,H*0.82,W,H*0.18);
    const steps=12;
    for(let i=0;i<steps;i++){ const a=0.4*(1-i/steps)*0.5;
      vig.fillStyle(0x000000,a);
      vig.fillRect(i*(W*0.04),0,W*0.04,H);
      vig.fillRect(W-(i+1)*(W*0.04),0,W*0.04,H); }

    // свечение лампы (правый край, как на фото)
    makeLamp(scene,W);
    const glow=scene.add.image(W*0.82,H*0.42,'lampG').setDepth(2)
      .setBlendMode(Phaser.BlendModes.ADD).setAlpha(0.4);
    scene._glow=glow;
    scene.tweens.add({targets:glow,alpha:0.24,duration:3400,yoyo:true,repeat:-1,ease:'Sine.easeInOut'});

    // пылинки
    scene._dust=[];
    for(let i=0;i<20;i++) scene._dust.push({
      x:W*(0.4+Math.random()*0.5), y:H*(0.25+Math.random()*0.5),
      r:0.6+Math.random()*1.6, vx:(Math.random()-0.5)*0.08, vy:-0.04-Math.random()*0.08,
      a:0.08+Math.random()*0.3, ph:Math.random()*6.28 });
    scene._dustG=scene.add.graphics().setDepth(3).setBlendMode(Phaser.BlendModes.ADD);

    scene._W=W; scene._H=H;
  }

  window.BgFxDrag=function(nx,ny){ tx=Math.max(-1,Math.min(1,nx)); ty=Math.max(-1,Math.min(1,ny)); };

  function makeLamp(scene,W){
    if(scene.textures.exists('lampG')) return;
    const s=Math.round(W*0.9), g=scene.make.graphics({x:0,y:0,add:false}), c=s/2;
    for(let i=22;i>0;i--){ const r=(s/2)*(i/22); g.fillStyle(0x6bd47a,0.03*(1-i/22)+0.003); g.fillCircle(c,c,r); }
    for(let i=12;i>0;i--){ const r=(s/4)*(i/12); g.fillStyle(0xfff0c0,0.05*(1-i/12)+0.004); g.fillCircle(c,c,r); }
    g.generateTexture('lampG',s,s); g.destroy();
  }

  function update(_,dt){
    if(!scene||paused) return;
    const W=scene._W, H=scene._H;
    const f=Math.min(dt/16.67,2);   // нормализация к 60fps

    // ── Пружинное сглаживание (критотерий плавности) ──
    // вместо линейного lerp используем spring-damper: очень мягко и без рывков
    const stiff=0.012, damp=0.82;
    vx += (tx-cx)*stiff*f; vy += (ty-cy)*stiff*f;
    vx *= Math.pow(damp,f); vy *= Math.pow(damp,f);
    cx += vx*f; cy += vy*f;

    if(scene._photo){ scene._photo.x=W/2-cx*22; scene._photo.y=H/2-cy*16; }
    if(scene._glow){ scene._glow.x=W*0.82-cx*30; scene._glow.y=H*0.42-cy*20; }

    frame++;
    if(scene._dustG){
      const g=scene._dustG; g.clear(); const t=frame*0.018;
      for(const d of scene._dust){
        d.x+=d.vx; d.y+=d.vy;
        if(d.y<H*0.18){ d.y=H*0.7; d.x=W*(0.4+Math.random()*0.5); }
        const tw=d.a*(0.55+0.45*Math.sin(t+d.ph));
        g.fillStyle(0xffe6b0,tw);
        g.fillCircle(d.x-cx*26, d.y-cy*18, d.r);
      }
    }
  }

  window.BgFx={
    init:boot,
    pause(){ paused=true; if(game){ try{game.loop.sleep();}catch(e){}
      const c=document.querySelector('#bg-fx canvas'); if(c)c.style.visibility='hidden'; } },
    resume(){ paused=false; if(game){ try{game.loop.wake();}catch(e){}
      const c=document.querySelector('#bg-fx canvas'); if(c)c.style.visibility='visible'; } },
    setMood(){}
  };
  window.addEventListener('resize',()=>{ if(game) game.scale.resize(innerWidth,innerHeight); });
})();

