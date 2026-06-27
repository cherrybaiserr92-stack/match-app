/* ═══════════════════════════════════════════════════════
   СДВИГ · Мини-игра «ОСМОТР МЕСТА» (спокойная логика/поиск)
   Контракт: Examine.start(container,{mission,onWin,onLose}) / .stop()
   Найди настоящие улики среди предметов с помощью лупы.
═══════════════════════════════════════════════════════ */
(function(){
  var cv, ctx, raf, running=false, opts=null;
  var W=0,H=0,DPR=1;
  var items=[], need=0, found=0, strikes=0, maxStrikes=3;
  var glass={x:-999,y:-999,active:false};
  var t0=0;

  // нуар-иконки предметов (рисуются процедурно)
  var ICONS=['key','watch','letter','glass','ring','coin','knife','photo','bottle','card','cig','button'];

  function rnd(a,b){ return a+Math.random()*(b-a); }
  function pick(arr){ return arr[(Math.random()*arr.length)|0]; }

  function layout(){
    items=[];
    var cols=4, rows=4;
    var pad=Math.min(W,H)*0.12;
    var cw=(W-pad*2)/cols, ch=(H-pad*2)/rows;
    var slots=[];
    for(var r=0;r<rows;r++) for(var c=0;c<cols;c++){
      slots.push({cx:pad+cw*c+cw/2, cy:pad+ch*r+ch/2});
    }
    // перемешиваем слоты
    slots.sort(function(){return Math.random()-0.5;});
    var total=Math.min(slots.length, need+8); // улики + приманки
    for(var i=0;i<total;i++){
      var s=slots[i];
      items.push({
        x:s.cx+rnd(-cw*0.12,cw*0.12),
        y:s.cy+rnd(-ch*0.12,ch*0.12),
        r:Math.min(cw,ch)*0.30,
        icon:pick(ICONS),
        real:i<need,        // первые need — настоящие улики
        found:false, wrong:false,
        glint:Math.random()*6.28,
        scale:0
      });
    }
    items.sort(function(){return Math.random()-0.5;});
  }

  function resize(){
    var rect=cv.getBoundingClientRect();
    DPR=Math.min(window.devicePixelRatio||1,2);
    W=rect.width; H=rect.height;
    cv.width=W*DPR; cv.height=H*DPR;
    ctx.setTransform(DPR,0,0,DPR,0,0);
  }

  function drawIcon(it,a){
    ctx.save();
    ctx.translate(it.x,it.y);
    var s=it.scale;
    ctx.scale(s,s);
    var col = it.found?'#46d89b' : it.wrong?'#d84646' : '#b8a888';
    ctx.strokeStyle=col; ctx.fillStyle=col; ctx.lineWidth=2.2; ctx.globalAlpha=a;
    var R=it.r;
    switch(it.icon){
      case 'key': ctx.beginPath();ctx.arc(-R*0.4,0,R*0.3,0,6.28);ctx.stroke();
        ctx.beginPath();ctx.moveTo(-R*0.1,0);ctx.lineTo(R*0.6,0);ctx.moveTo(R*0.4,0);ctx.lineTo(R*0.4,R*0.25);ctx.moveTo(R*0.6,0);ctx.lineTo(R*0.6,R*0.3);ctx.stroke();break;
      case 'watch': ctx.beginPath();ctx.arc(0,0,R*0.5,0,6.28);ctx.stroke();
        ctx.beginPath();ctx.moveTo(0,0);ctx.lineTo(0,-R*0.3);ctx.moveTo(0,0);ctx.lineTo(R*0.2,R*0.1);ctx.stroke();break;
      case 'letter': ctx.strokeRect(-R*0.5,-R*0.35,R,R*0.7);
        ctx.beginPath();ctx.moveTo(-R*0.5,-R*0.35);ctx.lineTo(0,R*0.05);ctx.lineTo(R*0.5,-R*0.35);ctx.stroke();break;
      case 'glass': ctx.beginPath();ctx.arc(-R*0.15,-R*0.15,R*0.4,0,6.28);ctx.stroke();
        ctx.beginPath();ctx.moveTo(R*0.15,R*0.15);ctx.lineTo(R*0.5,R*0.5);ctx.stroke();break;
      case 'ring': ctx.beginPath();ctx.arc(0,R*0.1,R*0.38,0,6.28);ctx.stroke();
        ctx.beginPath();ctx.moveTo(0,-R*0.28);ctx.lineTo(-R*0.12,-R*0.5);ctx.lineTo(R*0.12,-R*0.5);ctx.closePath();ctx.stroke();break;
      case 'coin': ctx.beginPath();ctx.arc(0,0,R*0.45,0,6.28);ctx.stroke();
        ctx.beginPath();ctx.arc(0,0,R*0.28,0,6.28);ctx.stroke();break;
      case 'knife': ctx.beginPath();ctx.moveTo(-R*0.5,R*0.3);ctx.lineTo(R*0.2,-R*0.4);ctx.lineTo(R*0.35,-R*0.25);ctx.lineTo(-R*0.35,R*0.45);ctx.closePath();ctx.stroke();
        ctx.beginPath();ctx.moveTo(R*0.2,-R*0.4);ctx.lineTo(R*0.5,-R*0.5);ctx.stroke();break;
      case 'photo': ctx.strokeRect(-R*0.45,-R*0.45,R*0.9,R*0.9);
        ctx.beginPath();ctx.arc(-R*0.1,-R*0.1,R*0.15,0,6.28);ctx.stroke();
        ctx.beginPath();ctx.moveTo(-R*0.4,R*0.35);ctx.lineTo(-R*0.05,R*0.0);ctx.lineTo(R*0.15,R*0.2);ctx.lineTo(R*0.4,-R*0.1);ctx.stroke();break;
      case 'bottle': ctx.beginPath();ctx.moveTo(-R*0.18,-R*0.5);ctx.lineTo(R*0.18,-R*0.5);ctx.lineTo(R*0.18,-R*0.2);ctx.lineTo(R*0.3,0);ctx.lineTo(R*0.3,R*0.5);ctx.lineTo(-R*0.3,R*0.5);ctx.lineTo(-R*0.3,0);ctx.lineTo(-R*0.18,-R*0.2);ctx.closePath();ctx.stroke();break;
      case 'card': ctx.strokeRect(-R*0.5,-R*0.32,R,R*0.64);
        ctx.beginPath();ctx.moveTo(-R*0.3,-R*0.1);ctx.lineTo(R*0.3,-R*0.1);ctx.moveTo(-R*0.3,R*0.1);ctx.lineTo(R*0.1,R*0.1);ctx.stroke();break;
      case 'cig': ctx.strokeRect(-R*0.5,-R*0.12,R,R*0.24);
        ctx.beginPath();ctx.moveTo(R*0.5,0);ctx.lineTo(R*0.7,-R*0.15);ctx.stroke();break;
      default: ctx.beginPath();ctx.arc(0,0,R*0.4,0,6.28);ctx.stroke();
    }
    ctx.restore();
  }

  function loop(ts){
    if(!running) return;
    if(!t0) t0=ts;
    ctx.clearRect(0,0,W,H);
    // нуар-фон сцены
    var g=ctx.createRadialGradient(W/2,H*0.4,40,W/2,H*0.4,Math.max(W,H)*0.7);
    g.addColorStop(0,'rgba(30,26,20,0.6)'); g.addColorStop(1,'rgba(8,8,11,0.95)');
    ctx.fillStyle=g; ctx.fillRect(0,0,W,H);

    var near=null, nd=1e9;
    for(var i=0;i<items.length;i++){
      var it=items[i];
      it.scale += (1-it.scale)*0.12; // плавное появление
      it.glint+=0.05;
      var dx=it.x-glass.x, dy=it.y-glass.y, d=Math.sqrt(dx*dx+dy*dy);
      if(glass.active && d<nd){ nd=d; near=it; }
      // базовая прорисовка
      var a=0.55;
      // под лупой ярче
      if(glass.active && d<glass.r){ a=0.95; }
      drawIcon(it,a);
      // настоящие улики под лупой — лёгкий янтарный отблеск
      if(it.real && !it.found && glass.active && d<glass.r){
        var pulse=0.4+0.3*Math.sin(it.glint*2);
        ctx.save();
        ctx.globalAlpha=pulse*0.6;
        ctx.strokeStyle='#ffcf6b'; ctx.lineWidth=2;
        ctx.beginPath(); ctx.arc(it.x,it.y,it.r*1.2,0,6.28); ctx.stroke();
        ctx.restore();
      }
    }

    // линза (лупа)
    if(glass.active){
      ctx.save();
      ctx.beginPath(); ctx.arc(glass.x,glass.y,glass.r,0,6.28);
      ctx.strokeStyle='rgba(200,160,90,0.5)'; ctx.lineWidth=3; ctx.stroke();
      ctx.strokeStyle='rgba(255,255,255,0.08)'; ctx.lineWidth=1; ctx.stroke();
      // блик
      ctx.beginPath(); ctx.arc(glass.x-glass.r*0.3,glass.y-glass.r*0.3,glass.r*0.15,0,6.28);
      ctx.fillStyle='rgba(255,255,255,0.10)'; ctx.fill();
      ctx.restore();
    }

    // HUD: счётчик улик и промахов
    ctx.save();
    ctx.font='600 14px Inter,sans-serif'; ctx.textBaseline='top';
    ctx.fillStyle='#ffcf6b'; ctx.fillText('Улики: '+found+'/'+need, 14, 12);
    ctx.fillStyle= strikes>0?'#e08080':'#6b7585';
    ctx.fillText('Промахи: '+strikes+'/'+maxStrikes, 14, 32);
    ctx.restore();

    raf=requestAnimationFrame(loop);
  }

  function pointer(e,type){
    var rect=cv.getBoundingClientRect();
    var p=(e.touches&&e.touches[0])||e;
    var x=p.clientX-rect.left, y=p.clientY-rect.top;
    if(type==='down'||type==='move'){ glass.x=x; glass.y=y; glass.active=true; }
    if(type==='up'){
      // тап = осмотреть ближайший предмет под лупой
      var best=null,bd=glass.r;
      for(var i=0;i<items.length;i++){
        var it=items[i]; if(it.found) continue;
        var d=Math.hypot(it.x-x,it.y-y);
        if(d<it.r*1.3 && d<bd){ bd=d; best=it; }
      }
      if(best){ examine(best); }
      glass.active=false; glass.x=-999; glass.y=-999;
    }
  }

  function examine(it){
    if(it.real){
      it.found=true; found++;
      try{ navigator.vibrate&&navigator.vibrate(20); }catch(_){}
      flash('#46d89b');
      if(found>=need){ win(); }
    } else {
      it.wrong=true; strikes++;
      try{ navigator.vibrate&&navigator.vibrate([10,30,10]); }catch(_){}
      flash('#d84646');
      setTimeout(function(){ it.wrong=false; },400);
      if(strikes>=maxStrikes){ lose(); }
    }
  }

  var flashEl=null;
  function flash(col){
    if(!flashEl) return;
    flashEl.style.boxShadow='inset 0 0 60px '+col;
    flashEl.style.opacity='1';
    setTimeout(function(){ flashEl.style.opacity='0'; },180);
  }

  function win(){
    running=false; cancelAnimationFrame(raf);
    setTimeout(function(){ opts&&opts.onWin&&opts.onWin(); }, 350);
  }
  function lose(){
    running=false; cancelAnimationFrame(raf);
    setTimeout(function(){ opts&&opts.onLose&&opts.onLose(); }, 350);
  }

  function start(container, o){
    opts=o||{};
    need = (opts.mission&&opts.mission.target)? Math.max(2,Math.min(5,Math.round(opts.mission.target/4))) : 3;
    if(need>5) need=5;
    found=0; strikes=0; t0=0;
    container.innerHTML='';
    var wrap=document.createElement('div');
    wrap.style.cssText='position:relative;width:100%;height:100%;min-height:380px;';
    cv=document.createElement('canvas');
    cv.style.cssText='width:100%;height:100%;display:block;border-radius:14px;touch-action:none;';
    wrap.appendChild(cv);
    flashEl=document.createElement('div');
    flashEl.style.cssText='position:absolute;inset:0;border-radius:14px;pointer-events:none;opacity:0;transition:opacity .18s;';
    wrap.appendChild(flashEl);
    // подсказка
    var tip=document.createElement('div');
    tip.style.cssText='position:absolute;bottom:8px;left:0;right:0;text-align:center;font-size:12px;color:#8a92a0;pointer-events:none;';
    tip.textContent='Веди лупой по сцене. Тапни улику, что отблёскивает янтарём.';
    wrap.appendChild(tip);
    container.appendChild(wrap);
    ctx=cv.getContext('2d');
    resize(); layout();
    cv.addEventListener('touchstart',function(e){e.preventDefault();pointer(e,'down');},{passive:false});
    cv.addEventListener('touchmove',function(e){e.preventDefault();pointer(e,'move');},{passive:false});
    cv.addEventListener('touchend',function(e){e.preventDefault();pointer(e,'up');},{passive:false});
    cv.addEventListener('mousedown',function(e){pointer(e,'down');});
    cv.addEventListener('mousemove',function(e){ if(glass.active)pointer(e,'move');});
    cv.addEventListener('mouseup',function(e){pointer(e,'up');});
    window.addEventListener('resize',resize);
    running=true; raf=requestAnimationFrame(loop);
  }
  function stop(){
    running=false; if(raf)cancelAnimationFrame(raf);
    window.removeEventListener('resize',resize);
  }

  window.Examine={start:start,stop:stop};
})();
