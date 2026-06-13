/* ═══════════════════════════════════════════════
   СДВИГ · phaser-bg.js v9 — премиум кинематографичный фон
   ✓ Фото кабинета + многослойная глубина (параллакс)
   ✓ Объёмный свет лампы (два слоя, дышит)
   ✓ Световые лучи из окна (god rays)
   ✓ Парящие пылинки в свете
   ✓ Плёночное зерно (film grain) для «дорогого» вида
   ✓ БЕЗ дождя
   ✓ input:false — не крадёт тачи
═══════════════════════════════════════════════ */
(function(){
  let game=null, scene=null, paused=false;
  let tx=0, ty=0, cx=0, cy=0, frame=0;

  function boot(){
    if(game || !window.Phaser) return;
    game = new Phaser.Game({
      type:Phaser.AUTO, parent:'bg-fx',
      width:window.innerWidth, height:window.innerHeight,
      transparent:true, banner:false,
      input:false,
      fps:{ target:30, forceSetTimeOut:true },
      render:{ powerPreference:'low-power', antialias:true },
      scale:{ mode:Phaser.Scale.RESIZE },
      scene:{ preload, create, update }
    });
    const kill=()=>document.querySelectorAll('#bg-fx canvas,#bg-fx *')
      .forEach(c=>{ c.style.pointerEvents='none'; c.style.touchAction='none'; });
    [40,200,600].forEach(t=>setTimeout(kill,t));
    if(window.DeviceOrientationEvent){
      window.addEventListener('deviceorientation',e=>{
        if(e.gamma!=null) tx=Math.max(-1,Math.min(1,e.gamma/35));
        if(e.beta!=null)  ty=Math.max(-1,Math.min(1,(e.beta-45)/35));
      },{passive:true});
    }
  }

  function preload(){
    this.load.image('office','/img/bg-login.jpg');
  }

  function create(){
    scene=this;
    const W=scene.scale.width, H=scene.scale.height;

    // ── СЛОЙ 0: фото кабинета ──
    const photo=scene.add.image(W/2,H/2,'office').setDepth(0);
    const scl=Math.max(W/photo.width,H/photo.height)*1.18;
    photo.setScale(scl);
    photo.setTint(0xb8c4d8);                 // лёгкая холодная коррекция
    scene._photo=photo;

    // ── СЛОЙ 1: цветокоррекция (тёплый низ / холодный верх) ──
    const grade=scene.add.graphics().setDepth(1).setBlendMode(Phaser.BlendModes.MULTIPLY);
    grade.fillStyle(0x1a2840,0.35); grade.fillRect(0,0,W,H*0.5);          // холодный верх
    grade.fillStyle(0x3a2410,0.30); grade.fillRect(0,H*0.5,W,H*0.5);      // тёплый низ
    scene._grade=grade;

    // ── СЛОЙ 2: глубокая виньетка ──
    const vig=scene.add.graphics().setDepth(2);
    drawVignette(vig,W,H);
    scene._vig=vig;

    // ── СЛОЙ 3: god rays (лучи из окна, ADD) ──
    makeRayTexture(scene,W,H);
    const rays=scene.add.image(W*0.72,H*0.3,'godRays').setDepth(3)
      .setBlendMode(Phaser.BlendModes.ADD).setAlpha(0.16).setAngle(18);
    scene._rays=rays;
    scene.tweens.add({targets:rays,alpha:0.07,duration:4200,yoyo:true,repeat:-1,ease:'Sine.easeInOut'});

    // ── СЛОЙ 4: объёмный свет лампы (два круга, ADD, дышит) ──
    makeLampTexture(scene,W);
    const lampOuter=scene.add.image(W*0.5,H*0.42,'lampGlow').setDepth(4)
      .setBlendMode(Phaser.BlendModes.ADD).setAlpha(0.5).setScale(1.4);
    const lampCore=scene.add.image(W*0.5,H*0.42,'lampCore').setDepth(4)
      .setBlendMode(Phaser.BlendModes.ADD).setAlpha(0.6);
    scene._lampOuter=lampOuter; scene._lampCore=lampCore;
    scene.tweens.add({targets:[lampOuter,lampCore],alpha:'-=0.18',duration:3000,yoyo:true,repeat:-1,ease:'Sine.easeInOut'});

    // ── СЛОЙ 5: пылинки в свете ──
    scene._dust=[];
    for(let i=0;i<26;i++) scene._dust.push({
      x:W*(0.28+Math.random()*0.44), y:H*(0.2+Math.random()*0.55),
      r:0.6+Math.random()*2.0, vx:(Math.random()-0.5)*0.1, vy:-0.04-Math.random()*0.1,
      a:0.08+Math.random()*0.35, ph:Math.random()*6.28
    });
    scene._dustG=scene.add.graphics().setDepth(5).setBlendMode(Phaser.BlendModes.ADD);

    // ── СЛОЙ 6: плёночное зерно ──
    makeGrainTexture(scene);
    scene._grain=scene.add.image(W/2,H/2,'grain0').setDepth(6)
      .setBlendMode(Phaser.BlendModes.ADD).setAlpha(0.035);

    scene._W=W; scene._H=H;
  }

  window.BgFxDrag=function(nx,ny){ tx=Math.max(-1,Math.min(1,nx)); ty=Math.max(-1,Math.min(1,ny)); };

  function makeLampTexture(scene,W){
    if(!scene.textures.exists('lampGlow')){
      const size=Math.round(W*1.0), g=scene.make.graphics({x:0,y:0,add:false});
      const c=size/2;
      for(let i=24;i>0;i--){ const r=(size/2)*(i/24); g.fillStyle(0xffb347,0.045*(1-i/24)+0.004); g.fillCircle(c,c,r); }
      g.generateTexture('lampGlow',size,size); g.destroy();
    }
    if(!scene.textures.exists('lampCore')){
      const size=Math.round(W*0.5), g=scene.make.graphics({x:0,y:0,add:false});
      const c=size/2;
      for(let i=16;i>0;i--){ const r=(size/2)*(i/16); g.fillStyle(0xffd27a,0.08*(1-i/16)+0.006); g.fillCircle(c,c,r); }
      g.generateTexture('lampCore',size,size); g.destroy();
    }
  }

  function makeRayTexture(scene,W,H){
    if(scene.textures.exists('godRays')) return;
    const ww=Math.round(W*0.7), hh=Math.round(H*0.9);
    const g=scene.make.graphics({x:0,y:0,add:false});
    // несколько мягких параллельных лучей
    for(let i=0;i<5;i++){
      const x=ww*(0.15+i*0.16);
      const w=ww*0.05;
      g.fillStyle(0xffe0a0, 0.06);
      g.fillRect(x,0,w,hh);
    }
    g.generateTexture('godRays',ww,hh); g.destroy();
  }

  function makeGrainTexture(scene){
    if(scene.textures.exists('grain0')) return;
    const s=128, g=scene.make.graphics({x:0,y:0,add:false});
    for(let i=0;i<2200;i++){
      const x=Math.random()*s, y=Math.random()*s, a=Math.random()*0.5;
      g.fillStyle(0xffffff,a); g.fillRect(x,y,1,1);
    }
    g.generateTexture('grain0',s,s); g.destroy();
  }

  function drawVignette(g,W,H){
    g.clear();
    g.fillStyle(0x04060c,0.62); g.fillRect(0,0,W,H*0.18);       // потолок
    g.fillStyle(0x030509,0.7);  g.fillRect(0,H*0.78,W,H*0.22);  // пол
    const steps=16;
    for(let i=0;i<steps;i++){
      const a=0.55*(1-i/steps)*0.5;
      g.fillStyle(0x030509,a);
      g.fillRect(i*(W*0.035),0,W*0.035,H);
      g.fillRect(W-(i+1)*(W*0.035),0,W*0.035,H);
    }
  }

  function update(){
    if(!scene||paused) return;
    const W=scene._W, H=scene._H;
    cx += (tx-cx)*0.06; cy += (ty-cy)*0.06;

    if(scene._photo){ scene._photo.x=W/2-cx*28; scene._photo.y=H/2-cy*20; }
    if(scene._lampOuter){ scene._lampOuter.x=W*0.5-cx*44; scene._lampOuter.y=H*0.42-cy*30; }
    if(scene._lampCore){ scene._lampCore.x=W*0.5-cx*44; scene._lampCore.y=H*0.42-cy*30; }
    if(scene._rays){ scene._rays.x=W*0.72-cx*60; }

    frame++;
    // пылинки
    if(scene._dustG){
      const g=scene._dustG; g.clear();
      const t=frame*0.02;
      for(const d of scene._dust){
        d.x+=d.vx; d.y+=d.vy;
        if(d.y<H*0.12){ d.y=H*0.66; d.x=W*(0.28+Math.random()*0.44); }
        if(d.x<W*0.22||d.x>W*0.78) d.vx*=-1;
        const tw=d.a*(0.55+0.45*Math.sin(t+d.ph));
        g.fillStyle(0xffe6b0,tw);
        g.fillCircle(d.x-cx*32, d.y-cy*22, d.r);
      }
    }
    // зерно — лёгкое дрожание позиции каждые 3 кадра
    if(scene._grain && frame%3===0){
      scene._grain.x = W/2 + (Math.random()-0.5)*8;
      scene._grain.y = H/2 + (Math.random()-0.5)*8;
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

