/* ═══════════════════════════════════════════════════════
   СДВИГ · Мини-игра «СЛЕЖКА» (быстрая на реакцию)
   Контракт: Pursuit.start(container,{mission,onWin,onLose}) / .stop()
   Удержи подозреваемого в прицеле наблюдения, пока он петляет в толпе.
═══════════════════════════════════════════════════════ */
(function(){
  var cv,ctx,raf,running=false,opts=null;
  var W=0,H=0,DPR=1;
  var target,crowd=[],aim={x:0,y:0};
  var progress=0,need=100,heat=0,lost=0,maxLost=100;
  var lastT=0,duration=0,survived=0;

  function rnd(a,b){return a+Math.random()*(b-a);}

  function resize(){
    var r=cv.getBoundingClientRect();
    DPR=Math.min(window.devicePixelRatio||1,2);
    W=r.width;H=r.height;cv.width=W*DPR;cv.height=H*DPR;
    ctx.setTransform(DPR,0,0,DPR,0,0);
  }

  function spawnCrowd(){
    crowd=[];
    for(var i=0;i<10;i++){
      crowd.push({x:rnd(0,W),y:rnd(0,H),vx:rnd(-0.6,0.6),vy:rnd(-0.6,0.6),
        ph:rnd(0,6.28),sp:rnd(0.6,1.1)});
    }
  }

  function initTarget(){
    target={x:W/2,y:H/2,vx:0,vy:0,
      // подозреваемый периодически делает рывки (тест реакции)
      nextJuke:rnd(0.6,1.4),tj:0,
      hue:30};
  }

  function step(dt){
    survived+=dt;
    // подозреваемый: плавное движение + внезапные рывки
    target.tj+=dt;
    if(target.tj>=target.nextJuke){
      target.tj=0; target.nextJuke=rnd(0.5,1.3);
      var ang=rnd(0,6.28), force=rnd(2.2,3.6);
      target.vx=Math.cos(ang)*force;
      target.vy=Math.sin(ang)*force;
    }
    // лёгкое притяжение к центру, чтобы не залипал в углу
    target.vx+=(W/2-target.x)*0.0008;
    target.vy+=(H/2-target.y)*0.0008;
    target.vx*=0.96; target.vy*=0.96;
    target.x+=target.vx*dt*60; target.y+=target.vy*dt*60;
    var pad=30;
    if(target.x<pad){target.x=pad;target.vx=Math.abs(target.vx);}
    if(target.x>W-pad){target.x=W-pad;target.vx=-Math.abs(target.vx);}
    if(target.y<pad){target.y=pad;target.vy=Math.abs(target.vy);}
    if(target.y>H-pad){target.y=H-pad;target.vy=-Math.abs(target.vy);}
    // толпа
    for(var i=0;i<crowd.length;i++){
      var c=crowd[i]; c.ph+=dt*c.sp;
      c.x+=c.vx*dt*60; c.y+=c.vy*dt*60;
      if(c.x<0||c.x>W)c.vx*=-1; if(c.y<0||c.y>H)c.vy*=-1;
    }
    // в прицеле ли цель
    var d=Math.hypot(target.x-aim.x,target.y-aim.y);
    var aimR=46;
    if(d<aimR){
      progress+=dt*22;      // держим — растёт прогресс
      heat=Math.min(1,heat+dt*2);
      lost=Math.max(0,lost-dt*30);
    } else {
      lost+=dt*28;          // упустили — растёт потеря
      heat=Math.max(0,heat-dt*1.5);
    }
    if(progress>=need){ win(); }
    if(lost>=maxLost){ lose(); }
  }

  function drawFigure(x,y,col,r,filled){
    ctx.save();ctx.translate(x,y);
    ctx.strokeStyle=col;ctx.fillStyle=col;ctx.lineWidth=2.4;
    // голова
    ctx.beginPath();ctx.arc(0,-r*0.7,r*0.32,0,6.28);filled?ctx.fill():ctx.stroke();
    // плечи/тело (силуэт в шляпе — нуар)
    ctx.beginPath();
    ctx.moveTo(-r*0.5,r*0.8);ctx.quadraticCurveTo(0,-r*0.2,r*0.5,r*0.8);
    filled?ctx.fill():ctx.stroke();
    // шляпа
    ctx.beginPath();ctx.moveTo(-r*0.45,-r*0.9);ctx.lineTo(r*0.45,-r*0.9);ctx.stroke();
    ctx.restore();
  }

  function loop(ts){
    if(!running)return;
    if(!lastT)lastT=ts;
    var dt=Math.min(0.05,(ts-lastT)/1000); lastT=ts;
    step(dt);

    ctx.clearRect(0,0,W,H);
    var g=ctx.createLinearGradient(0,0,0,H);
    g.addColorStop(0,'rgba(14,14,20,0.96)');g.addColorStop(1,'rgba(8,8,11,0.99)');
    ctx.fillStyle=g;ctx.fillRect(0,0,W,H);

    // толпа (серые силуэты-приманки)
    for(var i=0;i<crowd.length;i++){ drawFigure(crowd[i].x,crowd[i].y,'rgba(120,120,135,0.5)',18,false); }
    // цель (подозреваемый — выделен)
    var tcol = heat>0.5?'#ffcf6b':'#e0a060';
    drawFigure(target.x,target.y,tcol,22,false);
    // метка над целью
    ctx.save();ctx.globalAlpha=0.5+0.4*Math.sin(survived*5);
    ctx.fillStyle=tcol;ctx.beginPath();
    ctx.moveTo(target.x,target.y-34);ctx.lineTo(target.x-6,target.y-44);ctx.lineTo(target.x+6,target.y-44);ctx.closePath();ctx.fill();
    ctx.restore();

    // прицел наблюдения
    ctx.save();
    ctx.strokeStyle='rgba(200,160,90,0.55)';ctx.lineWidth=2;
    ctx.beginPath();ctx.arc(aim.x,aim.y,46,0,6.28);ctx.stroke();
    ctx.beginPath();ctx.moveTo(aim.x-56,aim.y);ctx.lineTo(aim.x-36,aim.y);
    ctx.moveTo(aim.x+36,aim.y);ctx.lineTo(aim.x+56,aim.y);
    ctx.moveTo(aim.x,aim.y-56);ctx.lineTo(aim.x,aim.y-36);
    ctx.moveTo(aim.x,aim.y+36);ctx.lineTo(aim.x,aim.y+56);ctx.stroke();
    ctx.restore();

    // HUD: прогресс слежки + полоса потери
    ctx.save();
    ctx.fillStyle='rgba(255,255,255,0.08)';ctx.fillRect(14,14,W-28,7);
    ctx.fillStyle='#46d89b';ctx.fillRect(14,14,(W-28)*(progress/need),7);
    ctx.fillStyle='rgba(255,255,255,0.08)';ctx.fillRect(14,26,W-28,5);
    ctx.fillStyle='#d84646';ctx.fillRect(14,26,(W-28)*(lost/maxLost),5);
    ctx.font='600 12px Inter,sans-serif';ctx.fillStyle='#8a92a0';ctx.textBaseline='top';
    ctx.fillText('Слежка: '+Math.round(progress)+'%',14,38);
    ctx.restore();

    raf=requestAnimationFrame(loop);
  }

  function move(e){
    var r=cv.getBoundingClientRect();
    var p=(e.touches&&e.touches[0])||e;
    aim.x=p.clientX-r.left; aim.y=p.clientY-r.top;
  }

  function win(){running=false;cancelAnimationFrame(raf);setTimeout(function(){opts&&opts.onWin&&opts.onWin();},300);}
  function lose(){running=false;cancelAnimationFrame(raf);setTimeout(function(){opts&&opts.onLose&&opts.onLose();},300);}

  function start(container,o){
    opts=o||{};
    need=100; progress=0; lost=0; heat=0; lastT=0; survived=0;
    // сложность от миссии: больше target → выше need
    if(opts.mission&&opts.mission.target){ need=80+Math.min(60,opts.mission.target*2); }
    container.innerHTML='';
    var wrap=document.createElement('div');
    wrap.style.cssText='position:relative;width:100%;height:100%;min-height:380px;';
    cv=document.createElement('canvas');
    cv.style.cssText='width:100%;height:100%;display:block;border-radius:14px;touch-action:none;';
    wrap.appendChild(cv);
    var tip=document.createElement('div');
    tip.style.cssText='position:absolute;bottom:8px;left:0;right:0;text-align:center;font-size:12px;color:#8a92a0;pointer-events:none;';
    tip.textContent='Веди прицелом за подозреваемым. Не упусти — он петляет в толпе.';
    wrap.appendChild(tip);
    container.appendChild(wrap);
    ctx=cv.getContext('2d');
    resize();aim.x=W/2;aim.y=H/2;spawnCrowd();initTarget();
    cv.addEventListener('touchstart',function(e){e.preventDefault();move(e);},{passive:false});
    cv.addEventListener('touchmove',function(e){e.preventDefault();move(e);},{passive:false});
    cv.addEventListener('mousemove',move);
    window.addEventListener('resize',resize);
    running=true;raf=requestAnimationFrame(loop);
  }
  function stop(){running=false;if(raf)cancelAnimationFrame(raf);window.removeEventListener('resize',resize);}

  window.Pursuit={start:start,stop:stop};
})();
