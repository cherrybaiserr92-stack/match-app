/* ═══════════════════════════════════════════════════════
   СДВИГ · Генератор карточки-досье (canvas, текст впечатан в бумагу)
   CardGen.render(opts) → <canvas> с досье + авто-вписанным текстом
═══════════════════════════════════════════════════════ */
(function(){
  var ART={};                 // кэш загруженного арта
  var READY=false, loadingP=null;
  var BASE={
    v:'/img/cards/folder-v.png',   // вертикальное (с полароидом)
    h:'/img/cards/folder-h.png',   // горизонтальное
    sticker:'/img/cards/sticker.png'
  };

  function loadImg(src){
    return new Promise(function(res,rej){
      var i=new Image(); i.onload=function(){res(i);}; i.onerror=rej; i.src=src;
    });
  }
  function preload(){
    if(loadingP) return loadingP;
    loadingP=Promise.all([
      loadImg(BASE.v).then(function(i){ART.v=i;}).catch(function(){}),
      loadImg(BASE.h).then(function(i){ART.h=i;}).catch(function(){}),
      loadImg(BASE.sticker).then(function(i){ART.sticker=i;}).catch(function(){}),
      (document.fonts&&document.fonts.ready)||Promise.resolve()
    ]).then(function(){READY=true;});
    return loadingP;
  }

  // перенос по словам с авто-подбором размера под коробку
  function fitText(ctx, text, boxW, boxH, startPx, minPx, family, weight){
    for(var size=startPx; size>=minPx; size-=1){
      ctx.font=(weight||'')+' '+size+'px '+family;
      var words=(text||'').split(/\s+/), lines=[], cur='';
      for(var i=0;i<words.length;i++){
        var t=(cur?cur+' ':'')+words[i];
        if(ctx.measureText(t).width<=boxW) cur=t;
        else { if(cur)lines.push(cur); cur=words[i]; }
      }
      if(cur)lines.push(cur);
      var lh=size*1.3;
      if(lines.length*lh<=boxH) return {size:size,lines:lines,lh:lh};
    }
    // минимум — вернём как есть
    ctx.font=(weight||'')+' '+minPx+'px '+family;
    var w2=(text||'').split(/\s+/), l2=[], c2='';
    for(var j=0;j<w2.length;j++){var tt=(c2?c2+' ':'')+w2[j];
      if(ctx.measureText(tt).width<=boxW)c2=tt; else{if(c2)l2.push(c2);c2=w2[j];}}
    if(c2)l2.push(c2);
    return {size:minPx,lines:l2,lh:minPx*1.3};
  }

  function drawLines(ctx, fit, x, y, color){
    ctx.fillStyle=color;
    for(var i=0;i<fit.lines.length;i++){
      ctx.fillText(fit.lines[i], x, y+i*fit.lh);
    }
    return y+fit.lines.length*fit.lh;
  }

  /* opts: {orient:'v'|'h', caseLabel, badge, speaker, title, body, portrait(Image|null)} */
  function render(opts){
    opts=opts||{};
    var orient = opts.orient==='h' ? 'h':'v';
    var art = ART[orient];
    var DPR = Math.min(window.devicePixelRatio||1, 2.5);
    // логический размер карты по арту
    var baseW = art? art.width : (orient==='v'?717:820);
    var baseH = art? art.height : (orient==='v'?960:447);
    // масштаб под экран (ширина карты ~ 90vw, но рисуем в разрешении арта*DPR)
    var cv=document.createElement('canvas');
    cv.width=baseW*DPR; cv.height=baseH*DPR;
    cv.style.width='100%'; cv.style.height='auto'; cv.style.display='block';
    var ctx=cv.getContext('2d');
    ctx.scale(DPR,DPR);
    ctx.textBaseline='top';

    // подложка досье
    if(art) ctx.drawImage(art,0,0,baseW,baseH);

    var W=baseW,H=baseH;
    var INK='#241811', INK2='#2f2318', SEAL='#8e2434', LABEL='#5a3d2e';
    var SERIF="'Playfair Display', Georgia, serif";
    var MONO="'Special Elite', 'Courier New', monospace";
    var BODY="'PT Serif', Georgia, serif";

    if(orient==='v'){
      // зоны вертикального (в долях): полароид X56-86 Y11-40, печать ~X62-82 Y68-86
      // ярлык
      ctx.font='400 '+(W*0.028)+'px '+MONO;
      ctx.fillStyle=LABEL; ctx.globalAlpha=.8;
      ctx.fillText(opts.caseLabel||'ДЕЛО', W*0.21, H*0.15);
      ctx.globalAlpha=1;
      // заголовок — левее полароида (ширина ~34%)
      var tf=fitText(ctx, opts.title||'', W*0.33, H*0.17, W*0.085, W*0.05, SERIF, '900');
      drawLines(ctx, tf, W*0.21, H*0.185, '#1c130c');
      // подпись
      ctx.font='400 '+(W*0.028)+'px '+MONO;
      ctx.fillStyle=SEAL;
      ctx.fillText((opts.badge||'РАЗВИЛКА')+(opts.speaker?' · '+opts.speaker.toUpperCase():''), W*0.21, H*0.405);
      // тело — вся ширина бумаги, выше печати (Y до ~64%)
      var bf=fitText(ctx, opts.body||'', W*0.60, H*0.20, W*0.052, W*0.032, BODY, '400');
      drawLines(ctx, bf, W*0.21, H*0.46, INK2);
      // вопросительный знак в пустой полароид (нет подозреваемого)
      if(!opts.portrait){
        var qx=W*0.585, qy=H*0.135, qw=W*0.255, qh=H*0.235;
        ctx.save();
        ctx.font='900 '+(qh*0.6)+'px '+SERIF; ctx.fillStyle='rgba(90,70,55,.55)';
        ctx.textAlign='center'; ctx.textBaseline='middle';
        ctx.fillText('?', qx+qw/2, qy+qh/2);
        ctx.restore();
        ctx.textAlign='left'; ctx.textBaseline='top';
      }
      // портрет в полароид
      if(opts.portrait){
        var px=W*0.585, py=H*0.135, pw=W*0.255, ph=H*0.235;
        ctx.save();
        ctx.beginPath(); ctx.rect(px,py,pw,ph); ctx.clip();
        // вписать портрет по центру
        var ir=opts.portrait.width/opts.portrait.height, br=pw/ph, dw,dh,dx,dy;
        if(ir>br){dh=ph;dw=ph*ir;dx=px-(dw-pw)/2;dy=py;}
        else{dw=pw;dh=pw/ir;dx=px;dy=py-(dh-ph)/2;}
        ctx.globalAlpha=.92;
        ctx.drawImage(opts.portrait,dx,dy,dw,dh);
        // лёгкая сепия-вуаль
        ctx.globalAlpha=.18; ctx.fillStyle='#3a2a1a'; ctx.fillRect(px,py,pw,ph);
        ctx.restore();
      }
    } else {
      // горизонтальное: бумага X26-72
      ctx.font='400 '+(W*0.024)+'px '+MONO;
      ctx.fillStyle=LABEL; ctx.globalAlpha=.8;
      ctx.fillText(opts.caseLabel||'ДЕЛО', W*0.27, H*0.15);
      ctx.globalAlpha=1;
      var tfh=fitText(ctx, opts.title||'', W*0.40, H*0.18, W*0.06, W*0.038, SERIF, '900');
      drawLines(ctx, tfh, W*0.27, H*0.20, '#1c130c');
      ctx.font='400 '+(W*0.022)+'px '+MONO;
      ctx.fillStyle=SEAL;
      ctx.fillText(opts.badge||'РАЗВИЛКА', W*0.27, H*0.37);
      var bfh=fitText(ctx, opts.body||'', W*0.44, H*0.34, W*0.038, W*0.024, BODY, '400');
      drawLines(ctx, bfh, W*0.27, H*0.43, INK2);
    }
    return cv;
  }

  // стикер-кнопка выбора с текстом
  function renderSticker(label, arrow){
    var art=ART.sticker;
    var DPR=Math.min(window.devicePixelRatio||1,2.5);
    var W=art?art.width:480, H=art?art.height:316;
    var cv=document.createElement('canvas');
    cv.width=W*DPR; cv.height=H*DPR; cv.style.width='100%'; cv.style.height='auto'; cv.style.display='block';
    var ctx=cv.getContext('2d'); ctx.scale(DPR,DPR); ctx.textBaseline='middle';
    if(art)ctx.drawImage(art,0,0,W,H);
    var SERIF="'Playfair Display',Georgia,serif";
    // стрелка (крупная, слева или справа)
    var isLeft=(arrow==='left');
    ctx.font='800 '+(W*0.13)+'px '+SERIF; ctx.fillStyle='#8e2434'; ctx.textAlign='center';
    ctx.fillText(isLeft?'‹':'›', isLeft?W*0.14:W*0.86, H*0.5);
    // текст выбора — по центру, с авто-вписыванием
    ctx.textAlign='left'; ctx.textBaseline='top';
    var tx=isLeft?W*0.24:W*0.08, tw=W*0.68;
    var tf=fitText(ctx,label||'',tw,H*0.62,W*0.08,W*0.048,SERIF,'800');
    ctx.fillStyle='#241811';
    var totalH=tf.lines.length*tf.lh, sy=(H-totalH)/2;
    for(var i=0;i<tf.lines.length;i++) ctx.fillText(tf.lines[i],tx,sy+i*tf.lh);
    return cv;
  }

  window.CardGen={preload:preload,render:render,renderSticker:renderSticker,isReady:function(){return READY;}};
})();
