/* ═══════════════════════════════════════════════
   СДВИГ · phaser-bg.js v8 — кинематографичный фон кабинета
   ✓ Реальное фото кабинета с параллаксом по слоям
   ✓ Глубина резкости (фокус на столе, размытие по краям)
   ✓ Тёплый свет лампы (дышит)
   ✓ Пылинки в луче света
   ✓ Дождь за окном
   ✓ input:false — не крадёт тачи
═══════════════════════════════════════════════ */
(function(){
  let game=null, scene=null, paused=false;
  let tx=0, ty=0, cx=0, cy=0;
  let frame=0;

  function boot(){
    if(game || !window.Phaser) return;
    game = new Phaser.Game({
      type:Phaser.AUTO, parent:'bg-fx',
      width:window.innerWidth, height:window.innerHeight,
      transparent:true, banner:false,
      input:false,                                   // не трогаем ввод
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

    // ── СЛОЙ 1: фото кабинета (дальний план, мягкое размытие глубины) ──
    const photo=scene.add.image(W/2,H/2,'office').setDepth(0);
    const scl=Math.max(W/photo.width,H/photo.height)*1.16;   // запас для параллакса
    photo.setScale(scl);
    photo.setTint(0x9fb0c8);
    scene._photo=photo;
    scene._baseScale=scl;

    // ── СЛОЙ 2: затемнение + виньетка (глубина, фокус в центре) ──
    const vig=scene.add.graphics().setDepth(1);
    drawVignette(vig,W,H);
    scene._vig=vig;

    // ── СЛОЙ 3: тёплый луч лампы (дышит) ──
    const lampTex=makeLampTexture(scene,W);
    const lamp=scene.add.image(W*0.5,H*0.40,'lampGlow').setDepth(2)
      .setBlendMode(Phaser.BlendModes.ADD).setAlpha(0.55);
    scene._lamp=lamp;
    scene.tweens.add({targets:lamp,alpha:0.34,duration:3200,yoyo:true,repeat:-1,ease:'Sine.easeInOut'});

    // ── СЛОЙ 4: пылинки в луче ──
    scene._dust=[];
    for(let i=0;i<22;i++) scene._dust.push({
      x:W*(0.3+Math.random()*0.4), y:H*(0.2+Math.random()*0.5),
      r:0.6+Math.random()*1.8, vx:(Math.random()-0.5)*0.12, vy:-0.05-Math.random()*0.12,
      a:0.1+Math.random()*0.35, ph:Math.random()*6.28
    });
    scene._dustG=scene.add.graphics().setDepth(3).setBlendMode(Phaser.BlendModes.ADD);

    // ── СЛОЙ 5: дождь за окном (правый верх) ──
    scene._rain=[];
    for(let i=0;i<26;i++) scene._rain.push({
      x:W*(0.55+Math.random()*0.4), y:Math.random()*H*0.6,
      l:8+Math.random()*10, s:6+Math.random()*5
    });
    scene._rainG=scene.add.graphics().setDepth(2);

    scene._W=W; scene._H=H;
  }

  // публичный хук — app.js двигает фон при свайпе карточки
  window.BgFxDrag=function(nx,ny){ tx=Math.max(-1,Math.min(1,nx)); ty=Math.max(-1,Math.min(1,ny)); };

  function makeLampTexture(scene,W){
    if(scene.textures.exists('lampGlow')) return;
    const size=Math.round(W*1.1);
    const g=scene.make.graphics({x:0,y:0,add:false});
    const cx=size/2, cy=size/2;
    for(let i=20;i>0;i--){
      const r=(size/2)*(i/20);
      const a=0.05*(1-i/20)+0.005;
      // тёплый янтарный свет лампы
      g.fillStyle(0xffb347, a);
      g.fillCircle(cx,cy,r);
    }
    g.generateTexture('lampGlow',size,size);
    g.destroy();
  }

  function drawVignette(g,W,H){
    g.clear();
    // верх — темнее (потолок в тени)
    g.fillStyle(0x05070c,0.55); g.fillRect(0,0,W,H*0.22);
    // низ — глубокая тень (пол)
    g.fillStyle(0x04060a,0.6);  g.fillRect(0,H*0.72,W,H*0.28);
    // боковые виньетки
    const steps=14;
    for(let i=0;i<steps;i++){
      const a=0.5*(1-i/steps);
      g.fillStyle(0x04060a,a*0.5);
      g.fillRect(i*(W*0.04),0,W*0.04,H);            // левый край
      g.fillRect(W-(i+1)*(W*0.04),0,W*0.04,H);      // правый край
    }
  }

  function update(){
    if(!scene||paused) return;
    const W=scene._W, H=scene._H;
    // плавный параллакс
    cx += (tx-cx)*0.06; cy += (ty-cy)*0.06;

    if(scene._photo){
      scene._photo.x = W/2 - cx*26;
      scene._photo.y = H/2 - cy*18;
    }
    if(scene._lamp){
      scene._lamp.x = W*0.5 - cx*40;
      scene._lamp.y = H*0.40 - cy*26;
    }

    frame++;
    // пылинки — каждый кадр (их мало)
    if(scene._dustG){
      const g=scene._dustG; g.clear();
      const t=frame*0.02;
      for(const d of scene._dust){
        d.x+=d.vx; d.y+=d.vy;
        if(d.y<H*0.15){ d.y=H*0.6; d.x=W*(0.3+Math.random()*0.4); }
        if(d.x<W*0.25||d.x>W*0.75) d.vx*=-1;
        const tw=d.a*(0.6+0.4*Math.sin(t+d.ph));
        g.fillStyle(0xffe0a0, tw);
        g.fillCircle(d.x - cx*30, d.y - cy*20, d.r);
      }
    }
    // дождь — через кадр
    if(frame%2===0 && scene._rainG){
      const g=scene._rainG; g.clear();
      g.lineStyle(1.2,0x6a8bbf,0.22);
      for(const r of scene._rain){
        r.y+=r.s; if(r.y>H*0.62){ r.y=-r.l; r.x=W*(0.55+Math.random()*0.4); }
        g.beginPath();
        g.moveTo(r.x - cx*8, r.y);
        g.lineTo(r.x - cx*8 - 1.5, r.y+r.l);
        g.strokePath();
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

