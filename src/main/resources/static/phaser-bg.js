/* СДВИГ · phaser-bg.js v6 — лёгкий параллакс (без перерисовки graphics) */
(function(){
  let game=null, scene=null, layers=[], rain=null, lamp=null, paused=false;
  let px=0.5, py=0.5, tx=0, ty=0;

  function boot(){
    if(game || !window.Phaser) return;
    game = new Phaser.Game({
      type:Phaser.AUTO, parent:'bg-fx',
      width:window.innerWidth, height:window.innerHeight,
      transparent:true, banner:false,
      fps:{ target:24, forceSetTimeOut:true },
      render:{ powerPreference:'low-power', antialias:false },
      scale:{ mode:Phaser.Scale.RESIZE },
      scene:{ create, update }
    });
    // КРИТИЧНО: canvas НЕ должен ловить клики
    setTimeout(()=>{ const c=document.querySelector('#bg-fx canvas');
      if(c){ c.style.pointerEvents='none'; c.style.touchAction='none'; } },50);
  }

  // создаём ТЕКСТУРЫ один раз, дальше двигаем спрайты (дёшево)
  function makeTex(scene){
    const W=scene.scale.width, H=scene.scale.height;
    // фон-окно
    let g=scene.add.graphics();
    g.fillStyle(0x0d1424,1).fillRect(0,0,W,H);
    g.fillStyle(0x16243f,0.5);
    for(let i=0;i<3;i++) g.fillRect(W*0.6,H*0.1+i*H*0.22,W*0.34,H*0.18);
    g.generateTexture('bgwin',W,H); g.destroy();
    // полки
    g=scene.add.graphics();
    for(let s=0;s<4;s++){ const y=H*0.2+s*H*0.18;
      g.fillStyle(0x0a0e16,0.7).fillRect(W*0.04,y,W*0.42,8);
      for(let b=0;b<7;b++){ g.fillStyle(0x1a2336,0.45)
        .fillRect(W*0.05+b*W*0.055,y-28-(b%3)*6,W*0.04,28+(b%3)*6);} }
    g.generateTexture('shelf',W,H); g.destroy();
  }

  function create(){
    scene=this; const W=scene.scale.width, H=scene.scale.height;
    makeTex(scene);
    const win=scene.add.image(W/2,H/2,'bgwin').setDepth(0);
    const shelf=scene.add.image(W/2,H/2,'shelf').setDepth(1);
    layers=[{o:win,d:0.02},{o:shelf,d:0.05}];

    // дождь — один TileSprite или пул из 30 линий, двигаем по Y (дёшево)
    rain=scene.add.graphics().setDepth(2);
    scene._rain=[]; for(let i=0;i<28;i++) scene._rain.push({
      x:Math.random()*W, y:Math.random()*H, l:8+Math.random()*8, s:5+Math.random()*5});
    drawRain(W,H);

    // лампа — статичная текстура свечения, дышит через alpha (без перерисовки)
    const lg=scene.add.graphics();
    for(let i=6;i>0;i--){ lg.fillStyle(0xf0a93a,0.04*i/6); lg.fillCircle(140,140,60*i); }
    lg.generateTexture('lamp',280,280); lg.destroy();
    lamp=scene.add.image(W*0.5,H*0.16,'lamp').setDepth(3).setAlpha(0.7);

    // ввод
    scene.input.on('pointermove',p=>{ px=p.x/W; py=p.y/H; });
    if(window.DeviceOrientationEvent){
      window.addEventListener('deviceorientation',e=>{
        if(e.gamma!=null) tx=Math.max(-1,Math.min(1,e.gamma/40));
        if(e.beta!=null)  ty=Math.max(-1,Math.min(1,(e.beta-45)/40));
      });
    }
    // плавное «дыхание» лампы через твин (GPU, не CPU)
    scene.tweens.add({targets:lamp,alpha:0.45,duration:2600,yoyo:true,repeat:-1,ease:'Sine.easeInOut'});
    scene._t=0; scene._rt=0;
  }

  function drawRain(W,H){
    rain.clear(); rain.lineStyle(1.3,0x5a7bb0,0.30);
    scene._rain.forEach(r=>{ rain.beginPath();
      rain.moveTo(r.x,r.y); rain.lineTo(r.x-2,r.y+r.l); rain.strokePath(); });
  }

  let frame=0;
  function update(_,dt){
    if(!scene||paused) return;
    const W=scene.scale.width, H=scene.scale.height;
    const ox=(px-0.5)+tx*0.5, oy=(py-0.5)+ty*0.5;
    layers.forEach(l=>{ l.o.x=W/2-ox*W*l.d; l.o.y=H/2-oy*H*l.d; });
    lamp.x=W*0.5+ox*30;
    // дождь обновляем через кадр (вдвое реже) — экономия
    frame++; if(frame%2===0){
      scene._rain.forEach(r=>{ r.y+=r.s*2; if(r.y>H){r.y=-r.l;r.x=Math.random()*W;} });
      drawRain(W,H);
    }
  }

  window.BgFx={
    init:boot,
    pause(){ paused=true; if(game) game.loop.sleep(); },
    resume(){ paused=false; if(game) game.loop.wake(); },
    setMood(){}
  };
  window.addEventListener('resize',()=>{ if(game) game.scale.resize(innerWidth,innerHeight); });
})();
