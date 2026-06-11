/* СДВИГ · phaser-bg.js v5 — атмосферный параллакс-фон кабинета */
(function(){
  let game=null, scene=null, layers=[], rainGfx=null, lampGlow=null;
  let pointerX=0.5, pointerY=0.5, tiltX=0, tiltY=0;

  function boot(){
    if(game || !window.Phaser) return;
    const W=window.innerWidth, H=window.innerHeight;
    game = new Phaser.Game({
      type:Phaser.AUTO, parent:'bg-fx', width:W, height:H,
      transparent:true, banner:false,
      fps:{ target:30, forceSetTimeOut:true },   // 30fps достаточно для фона → меньше нагрузка
      scale:{ mode:Phaser.Scale.RESIZE },
      scene:{ create, update }
    });
  }

  function create(){
    scene=this; const W=scene.scale.width, H=scene.scale.height;

    // слой 0 — дальнее окно с дождём (синеватое)
    const g0=scene.add.graphics();
    g0.fillStyle(0x0d1424,1).fillRect(0,0,W,H);
    g0.fillStyle(0x16243f,0.6);
    for(let i=0;i<3;i++) g0.fillRect(W*0.6, H*0.1+i*H*0.22, W*0.34, H*0.18);
    layers.push({obj:g0,depth:0.02});

    // дождь
    rainGfx=scene.add.graphics(); rainGfx.setDepth(1);
    scene._rain=[]; for(let i=0;i<60;i++) scene._rain.push({
      x:Math.random()*W, y:Math.random()*H, l:6+Math.random()*10, s:6+Math.random()*8 });

    // слой 1 — полки (средний план)
    const g1=scene.add.graphics();
    g1.fillStyle(0x0a0e16,0.7);
    for(let s=0;s<4;s++){ const y=H*0.2+s*H*0.18;
      g1.fillRect(W*0.04,y,W*0.42,8);
      for(let b=0;b<7;b++){ g1.fillStyle(0x1a2336,0.5);
        g1.fillRect(W*0.05+b*W*0.055, y-28-(b%3)*6, W*0.04, 28+(b%3)*6); g1.fillStyle(0x0a0e16,0.7); } }
    layers.push({obj:g1,depth:0.05});

    // лампа — мягкое тёплое свечение (передний план)
    lampGlow=scene.add.graphics(); lampGlow.setDepth(2);

    // лёгкая виньетка
    const vg=scene.add.graphics(); vg.setDepth(3);
    vg.fillStyle(0x000000,0.45);
    vg.fillRect(0,0,W,H*0.12); vg.fillRect(0,H*0.88,W,H*0.12);

    // ввод: указатель + наклон устройства
    scene.input.on('pointermove',p=>{ pointerX=p.x/W; pointerY=p.y/H; });
    if(window.DeviceOrientationEvent){
      window.addEventListener('deviceorientation',e=>{
        if(e.gamma!=null) tiltX=Math.max(-1,Math.min(1,e.gamma/35));
        if(e.beta!=null)  tiltY=Math.max(-1,Math.min(1,(e.beta-45)/35));
      });
    }
    scene._t=0;
  }

  function update(_,dt){
    if(!scene) return;
    const W=scene.scale.width, H=scene.scale.height;
    scene._t+=dt;

    const px=(pointerX-0.5)+tiltX*0.6, py=(pointerY-0.5)+tiltY*0.6;
    layers.forEach(l=>{ l.obj.x=-px*W*l.depth; l.obj.y=-py*H*l.depth; });

    // дождь
    if(rainGfx){
      rainGfx.clear(); rainGfx.lineStyle(1.4,0x5a7bb0,0.35);
      scene._rain.forEach(r=>{ r.y+=r.s; if(r.y>H){r.y=-r.l;r.x=Math.random()*W;}
        rainGfx.beginPath(); rainGfx.moveTo(r.x,r.y); rainGfx.lineTo(r.x-2,r.y+r.l); rainGfx.strokePath(); });
    }

    // дышащее свечение лампы
    if(lampGlow){
      const fl=0.5+0.5*Math.sin(scene._t*0.0016)+0.06*Math.sin(scene._t*0.013);
      lampGlow.clear();
      const cx=W*0.5+px*40, cy=H*0.16;
      for(let i=6;i>0;i--){ lampGlow.fillStyle(0xf0a93a, 0.03*fl*i/6);
        lampGlow.fillCircle(cx,cy, 60*i); }
    }
  }

  window.BgFx={
    init:boot,
    setMood(mood){ /* задел: 'rain'|'snow'|'calm' — смена погоды по делу */ }
  };
  window.addEventListener('resize',()=>{ if(game) game.scale.resize(window.innerWidth,window.innerHeight); });
})();
