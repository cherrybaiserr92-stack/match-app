/* ═══════════════════════════════════════════════════════
   СДВИГ · Мини-игра «ОСМОТР МЕСТА» (спокойная логика/поиск)
   Контракт: Examine.start(container,{mission,onWin,onLose}) / .stop()
   Найди настоящие улики среди предметов с помощью лупы.
═══════════════════════════════════════════════════════ */
(function(){
  var cv, ctx, raf, running=false, opts=null;
  var W=0,H=0,DPR=1;
  var items=[], need=0, found=0, strikes=0, maxStrikes=3;
  var glass={x:0,y:0,r:78,active:true};
  var t0=0;

  var ICONS=['key','watch','letter','glass','ring','coin','knife','photo','bottle','card','cig','button'];

  // ── детализированные SVG-предметы (data-URI -> Image; id-градиенты изолированы в своём документе) ──
  var ITEM_SVG={
    key:'<defs><linearGradient id="b" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#e8c877"/><stop offset=".5" stop-color="#b08a3e"/><stop offset="1" stop-color="#6e5218"/></linearGradient></defs>'+
      '<circle cx="14" cy="20" r="9" fill="none" stroke="url(#b)" stroke-width="5"/>'+
      '<rect x="21" y="17.5" width="22" height="5" rx="2" fill="url(#b)"/>'+
      '<rect x="34" y="21" width="4" height="8" rx="1.4" fill="url(#b)"/><rect x="40" y="21" width="4" height="10" rx="1.4" fill="url(#b)"/>'+
      '<ellipse cx="11" cy="15" rx="3.4" ry="1.8" fill="#fff" opacity=".5" transform="rotate(-28 11 15)"/>',
    watch:'<defs><linearGradient id="m" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#d9dee6"/><stop offset=".6" stop-color="#9aa4b2"/><stop offset="1" stop-color="#5c6572"/></linearGradient></defs>'+
      '<path d="M24 7 Q30 2 34 6" fill="none" stroke="#8a94a2" stroke-width="2.4" stroke-linecap="round"/>'+
      '<circle cx="24" cy="27" r="17" fill="url(#m)"/><circle cx="24" cy="27" r="13.6" fill="#f4f0e4"/>'+
      '<circle cx="24" cy="27" r="13.6" fill="none" stroke="#7a828e" stroke-width="1"/>'+
      '<path d="M24 27 L24 17.6 M24 27 L30.4 30.4" stroke="#3a3f48" stroke-width="2" stroke-linecap="round"/>'+
      '<circle cx="24" cy="27" r="1.8" fill="#3a3f48"/>'+
      '<ellipse cx="18" cy="18" rx="4.6" ry="2.6" fill="#fff" opacity=".55" transform="rotate(-30 18 18)"/>',
    letter:'<defs><linearGradient id="p" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#f4e9cf"/><stop offset="1" stop-color="#cdbb92"/></linearGradient></defs>'+
      '<rect x="5" y="12" width="38" height="26" rx="2.4" fill="url(#p)"/>'+
      '<path d="M5 13 L24 28 L43 13" fill="none" stroke="#a08c5e" stroke-width="1.6"/>'+
      '<rect x="5" y="12" width="38" height="26" rx="2.4" fill="none" stroke="#8f7c50" stroke-width="1.2"/>'+
      '<circle cx="24" cy="30" r="4.6" fill="#a52432"/><circle cx="24" cy="30" r="3" fill="#7c1420"/>',
    glass:'<defs><linearGradient id="s" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#e6ecf4"/><stop offset="1" stop-color="#8b96a6"/></linearGradient></defs>'+
      '<circle cx="19" cy="19" r="12.4" fill="rgba(160,200,235,.22)" stroke="url(#s)" stroke-width="4"/>'+
      '<rect x="28" y="26" width="16" height="6" rx="3" transform="rotate(45 28 26)" fill="url(#s)"/>'+
      '<ellipse cx="14.6" cy="13.6" rx="4.4" ry="2.6" fill="#fff" opacity=".6" transform="rotate(-32 14.6 13.6)"/>',
    ring:'<defs><linearGradient id="g" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#f4dc94"/><stop offset=".5" stop-color="#c8a24a"/><stop offset="1" stop-color="#8a6a22"/></linearGradient></defs>'+
      '<circle cx="24" cy="29" r="11.4" fill="none" stroke="url(#g)" stroke-width="5"/>'+
      '<path d="M18.6 14.8 L24 7.6 L29.4 14.8 L24 18.4 Z" fill="#c22743"/>'+
      '<path d="M18.6 14.8 L24 7.6 L24 18.4 Z" fill="#e6506b"/>'+
      '<ellipse cx="19.4" cy="22.6" rx="3.2" ry="1.6" fill="#fff" opacity=".5" transform="rotate(-38 19.4 22.6)"/>',
    coin:'<defs><linearGradient id="c" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#eee2b8"/><stop offset=".55" stop-color="#c2a25c"/><stop offset="1" stop-color="#7e6428"/></linearGradient></defs>'+
      '<circle cx="24" cy="24" r="16" fill="url(#c)"/><circle cx="24" cy="24" r="12" fill="none" stroke="#8a6f30" stroke-width="1.6"/>'+
      '<text x="24" y="30" font-family="Georgia" font-size="16" font-weight="bold" text-anchor="middle" fill="#6e561e">1</text>'+
      '<ellipse cx="17" cy="15" rx="5.4" ry="2.6" fill="#fff" opacity=".5" transform="rotate(-30 17 15)"/>',
    knife:'<defs><linearGradient id="k" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#eef2f8"/><stop offset="1" stop-color="#8d97a5"/></linearGradient></defs>'+
      '<path d="M6 36 L26 12 L32 9 L30 15 L11 40 Z" fill="url(#k)" stroke="#6a7482" stroke-width=".8"/>'+
      '<path d="M6 36 L26 12 L27 16 L10 39 Z" fill="#fff" opacity=".35"/>'+
      '<rect x="28" y="6" width="13" height="7" rx="3" transform="rotate(38 28 6)" fill="#5e4126"/>'+
      '<rect x="29.4" y="7.6" width="10" height="2" rx="1" transform="rotate(38 29.4 7.6)" fill="#7c5a38"/>',
    photo:'<rect x="7" y="9" width="34" height="30" rx="1.6" fill="#efe8d8"/>'+
      '<rect x="10.4" y="12.4" width="27.2" height="20" fill="#5a6472"/>'+
      '<circle cx="20" cy="20" r="3.6" fill="#8d97a5"/><path d="M11 32 L19 24 L24 28 L31 21 L37 27 L37 32 Z" fill="#77828f"/>'+
      '<rect x="7" y="9" width="34" height="30" rx="1.6" fill="none" stroke="#b8ad94" stroke-width="1"/>',
    bottle:'<defs><linearGradient id="v" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="#2c5d3f"/><stop offset=".5" stop-color="#183a26"/><stop offset="1" stop-color="#0d2416"/></linearGradient></defs>'+
      '<path d="M20 5 L28 5 L28 15 Q34 19 34 26 L34 41 Q34 44 31 44 L17 44 Q14 44 14 41 L14 26 Q14 19 20 15 Z" fill="url(#v)"/>'+
      '<rect x="19.6" y="3" width="8.8" height="5" rx="1.4" fill="#6e5a2e"/>'+
      '<rect x="16.6" y="27" width="15" height="10" rx="1" fill="#d9cfae" opacity=".9"/>'+
      '<path d="M21 8 L21 15 Q17 19 16.6 24" stroke="#fff" stroke-width="1.6" fill="none" opacity=".28" stroke-linecap="round"/>',
    cig:'<rect x="6" y="21" width="27" height="6.4" rx="2.6" fill="#efeadb"/>'+
      '<rect x="27" y="21" width="6" height="6.4" fill="#c8873e"/>'+
      '<circle cx="35.4" cy="24.2" r="2.6" fill="#e0542e"/><circle cx="35.4" cy="24.2" r="1.2" fill="#ffb36e"/>'+
      '<path d="M37 20 Q40 16 38.6 12 Q37.6 9.4 40 7" stroke="#9aa3ad" stroke-width="1.6" fill="none" opacity=".6" stroke-linecap="round"/>',
    button:'<defs><radialGradient id="t" cx="38%" cy="32%" r="80%"><stop offset="0" stop-color="#7d8ea2"/><stop offset="1" stop-color="#39434f"/></radialGradient></defs>'+
      '<circle cx="24" cy="24" r="13" fill="url(#t)"/><circle cx="24" cy="24" r="13" fill="none" stroke="#20262e" stroke-width="1.4"/>'+
      '<circle cx="20" cy="21" r="1.8" fill="#1c2229"/><circle cx="28" cy="21" r="1.8" fill="#1c2229"/>'+
      '<circle cx="20" cy="28" r="1.8" fill="#1c2229"/><circle cx="28" cy="28" r="1.8" fill="#1c2229"/>',
    card:'<rect x="7" y="13" width="34" height="22" rx="2.4" fill="#efe6ce"/>'+
      '<rect x="7" y="13" width="34" height="22" rx="2.4" fill="none" stroke="#a89a74" stroke-width="1.2"/>'+
      '<rect x="12" y="19" width="18" height="2.4" rx="1" fill="#8a7c54"/>'+
      '<rect x="12" y="24" width="12" height="2.4" rx="1" fill="#a89a74"/>'+
      '<text x="35" y="31" font-family="Georgia" font-size="11" font-weight="bold" text-anchor="middle" fill="#7c1420">K</text>'
  };
  var ITEM_IMGS={}, IMGS_READY=false;
  function preloadItems(cb){
    var keys=Object.keys(ITEM_SVG), left=keys.length;
    keys.forEach(function(k){
      var im=new Image();
      im.onload=im.onerror=function(){ if(--left===0){ IMGS_READY=true; cb&&cb(); } };
      im.src='data:image/svg+xml;utf8,'+encodeURIComponent('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'+ITEM_SVG[k]+'</svg>');
      ITEM_IMGS[k]=im;
    });
  }


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
    if(!glass._init){ glass.x=W/2; glass.y=H*0.42; glass.r=Math.min(W,H)*0.21; glass._init=true; }
  }

  function drawIcon(it,a){
    ctx.save();
    ctx.translate(it.x,it.y);
    var s=it.scale;
    ctx.scale(s,s);
    var img=ITEM_IMGS[it.icon];
    if(IMGS_READY&&img&&img.complete&&img.naturalWidth){
      var sz=it.r*2.1;
      ctx.globalAlpha=a;
      // мягкая тень предмета на полу
      ctx.save(); ctx.globalAlpha=a*0.45; ctx.fillStyle='#000';
      ctx.beginPath(); ctx.ellipse(0,it.r*0.85,it.r*0.8,it.r*0.24,0,0,6.28); ctx.fill(); ctx.restore();
      ctx.drawImage(img,-sz/2,-sz/2,sz,sz);
      if(it.found){ ctx.globalAlpha=Math.min(1,a+0.2); ctx.strokeStyle='#46d89b'; ctx.lineWidth=2.4;
        ctx.beginPath(); ctx.arc(0,0,it.r*1.15,0,6.28); ctx.stroke(); }
      else if(it.wrong){ ctx.globalAlpha=0.9; ctx.strokeStyle='#e0546e'; ctx.lineWidth=2.4;
        ctx.beginPath(); ctx.arc(0,0,it.r*1.15,0,6.28); ctx.stroke(); }
      ctx.restore(); return;
    }
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
    // нуар-фон: паркетные доски + виньетка
    ctx.fillStyle='#171310'; ctx.fillRect(0,0,W,H);
    var bw=Math.max(46,W/7);
    for(var bi=0;bi*bw<W+bw;bi++){
      ctx.fillStyle=(bi%2? '#1c1712':'#191410');
      ctx.fillRect(bi*bw,0,bw,H);
      ctx.fillStyle='rgba(0,0,0,.35)'; ctx.fillRect(bi*bw,0,1.2,H);
    }
    for(var sy=0;sy<H;sy+=64){ ctx.fillStyle='rgba(0,0,0,.22)'; ctx.fillRect(((sy/64)%2)*bw*0.5,sy,W,1); }
    var g=ctx.createRadialGradient(W/2,H*0.4,60,W/2,H*0.4,Math.max(W,H)*0.75);
    g.addColorStop(0,'rgba(0,0,0,0)'); g.addColorStop(1,'rgba(0,0,0,0.88)');
    ctx.fillStyle=g; ctx.fillRect(0,0,W,H);
    // свет лупы: тёплое пятно на «полу»
    var lg=ctx.createRadialGradient(glass.x,glass.y,glass.r*0.2,glass.x,glass.y,glass.r*1.6);
    lg.addColorStop(0,'rgba(255,214,150,0.10)');
    lg.addColorStop(0.6,'rgba(255,200,130,0.05)');
    lg.addColorStop(1,'rgba(0,0,0,0)');
    ctx.fillStyle=lg; ctx.fillRect(0,0,W,H);

    var near=null, nd=1e9;
    for(var i=0;i<items.length;i++){
      var it=items[i];
      it.scale += (1-it.scale)*0.12; // плавное появление
      it.glint+=0.05;
      var dx=it.x-glass.x, dy=it.y-glass.y, d=Math.sqrt(dx*dx+dy*dy);
      if(d<nd){ nd=d; near=it; }
      // тьма: предмет виден только в свете лупы, силуэтом — рядом с ней
      var a = d<glass.r ? 0.95 : Math.max(0.10, 0.42 - (d-glass.r)/(glass.r*3));
      if(it.found) a=Math.max(a,0.85);
      drawIcon(it,a);
      // настоящие улики под лупой — янтарный отблеск
      if(it.real && !it.found && d<glass.r){
        var pulse=0.4+0.3*Math.sin(it.glint*2);
        ctx.save();
        ctx.globalAlpha=pulse*0.6;
        ctx.strokeStyle='#ffcf6b'; ctx.lineWidth=2;
        ctx.beginPath(); ctx.arc(it.x,it.y,it.r*1.2,0,6.28); ctx.stroke();
        ctx.restore();
      }
    }

    // линза (лупа): стальная оправа + ручка
    ctx.save();
    ctx.beginPath(); ctx.arc(glass.x,glass.y,glass.r,0,6.28);
    ctx.strokeStyle='rgba(207,216,227,0.75)'; ctx.lineWidth=4; ctx.stroke();
    ctx.beginPath(); ctx.arc(glass.x,glass.y,glass.r-4,0,6.28);
    ctx.strokeStyle='rgba(0,0,0,0.6)'; ctx.lineWidth=2; ctx.stroke();
    // ручка вниз-вправо
    var hx=Math.cos(0.7)*glass.r, hy=Math.sin(0.7)*glass.r;
    ctx.beginPath(); ctx.moveTo(glass.x+hx,glass.y+hy);
    ctx.lineTo(glass.x+hx*1.55,glass.y+hy*1.55);
    ctx.strokeStyle='rgba(147,161,179,0.8)'; ctx.lineWidth=7; ctx.lineCap='round'; ctx.stroke();
    // блик линзы
    ctx.beginPath(); ctx.arc(glass.x-glass.r*0.32,glass.y-glass.r*0.32,glass.r*0.14,0,6.28);
    ctx.fillStyle='rgba(255,255,255,0.09)'; ctx.fill();
    ctx.restore();

    // HUD: счётчик улик и промахов
    ctx.save();
    ctx.font='700 13px Manrope,sans-serif'; ctx.textBaseline='top';
    ctx.fillStyle='#46d89b'; ctx.fillText('Улики: '+found+'/'+need, 14, 12);
    ctx.fillStyle= strikes>0?'#ff8fa8':'#93a1b3';
    ctx.fillText('Промахи: '+strikes+'/'+maxStrikes, 14, 32);
    ctx.restore();

    raf=requestAnimationFrame(loop);
  }

  function pointer(e,type){
    var rect=cv.getBoundingClientRect();
    var p=(e.touches&&e.touches[0])||e;
    var x=p.clientX-rect.left, y=p.clientY-rect.top;
    if(type==='down'||type==='move'){ glass.x=x; glass.y=y; }
    if(type==='up'){
      // тап = осмотреть ближайший предмет под лупой
      glass.x=x; glass.y=y;
      var best=null,bd=glass.r;
      for(var i=0;i<items.length;i++){
        var it=items[i]; if(it.found) continue;
        var d=Math.hypot(it.x-x,it.y-y);
        if(d<it.r*1.3 && d<bd){ bd=d; best=it; }
      }
      if(best){ examine(best); }
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
    tip.textContent='Веди лупу по тёмной сцене. Настоящая улика отблёскивает янтарём — тапни её.';
    wrap.appendChild(tip);
    container.appendChild(wrap);
    ctx=cv.getContext('2d');
    preloadItems();
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
