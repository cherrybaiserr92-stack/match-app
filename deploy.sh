#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  СДВИГ R10 · Полная интеграция карусели в основное приложение
#  Меняем: index.html · app.js · card-design.css
# ═══════════════════════════════════════════════════════════
set -e
echo ""
echo "══ 1/4  Логотип + index.html ════════════════════════"
python3 - << 'PYEOF'
import re, base64, os

STATIC = "src/main/resources/static"

# ── 1a. Извлекаем логотип из sdvig-shift.html и сохраняем как файл ──
shift_path = os.path.join(STATIC, "sdvig-shift.html")
with open(shift_path, encoding="utf-8") as f:
    shift_html = f.read()

m = re.search(r'src="(data:image/webp;base64,([A-Za-z0-9+/=\s]+))"', shift_html)
if m:
    raw = m.group(2).replace('\n','').replace('\r','').replace(' ','')
    logo_bytes = base64.b64decode(raw)
    logo_path = os.path.join(STATIC, "img", "logo-main.webp")
    with open(logo_path, "wb") as f:
        f.write(logo_bytes)
    print("  + logo-main.webp сохранён (%d KB)" % (len(logo_bytes)//1024))
else:
    print("  ⚠ логотип не найден в sdvig-shift.html")

# ── 1b. Патчим index.html ──
idx_path = os.path.join(STATIC, "index.html")
with open(idx_path, encoding="utf-8") as f:
    idx = f.read()

# Сплэш: заменяем emblem.png на настоящий логотип
old_splash_emblem = (
    '    <div class="splash-emblem" id="splash-emblem">\n'
    '      <img class="emblem-img" src="/img/emblem.png" alt="СДВИГ">\n'
    '    </div>'
)
new_splash_emblem = (
    '    <div class="splash-emblem" id="splash-emblem">\n'
    '      <img class="emblem-img sdvig-logo" src="/img/logo-main.webp" alt="СДВИГ">\n'
    '    </div>'
)
if old_splash_emblem in idx:
    idx = idx.replace(old_splash_emblem, new_splash_emblem, 1)
    print("  + сплэш-логотип обновлён")

# Логин: вставляем логотип вместо badge+h1
old_login = (
    '    <div class="login-header">\n'
    '      <div class="login-badge">С</div>\n'
    '      <div class="login-h1">СДВИГ</div>\n'
    '      <div class="login-tagline">Детективное агентство</div>\n'
    '    </div>'
)
new_login = (
    '    <div class="login-header">\n'
    '      <img class="login-logo" src="/img/logo-main.webp" alt="СДВИГ">\n'
    '      <div class="login-tagline">Детективное агентство</div>\n'
    '    </div>'
)
if old_login in idx:
    idx = idx.replace(old_login, new_login, 1)
    print("  + логин-логотип обновлён")

# #tab-cases: заменяем swipe-zone + tools-bar на кольцо карусели
old_cases_start = '    <div class="tab-pane active" id="tab-cases">'
old_tools_end   = '      </div>\n    </div>\n\n    <div class="tab-pane" id="tab-map">'

start_i = idx.find(old_cases_start)
end_i   = idx.find(old_tools_end)

if start_i != -1 and end_i != -1:
    new_cases_block = '''\
    <div class="tab-pane active" id="tab-cases">
      <div class="case-prog-bar"><i id="prog"></i></div>
      <div class="stage" id="stage">
        <div class="ring-scene"><div class="ring" id="ring"></div></div>
      </div>
      <div class="tools-bar" id="tools-bar">
        <div class="ev-chip" id="ev-chip">
          <span class="ev-dot"></span>
          <span>Улики</span>
          <b id="ev-count">0</b>
        </div>
        <button class="tool-btn" data-tool="magnify" title="Лупа — подсветит важную улику">
          <span class="tool-ico" data-tico="magnify"></span>
          <span class="tool-badge" id="tool-magnify-n">2</span>
        </button>
        <button class="tool-btn" data-tool="file" title="Досье — пропустить мини-игру">
          <span class="tool-ico" data-tico="file"></span>
          <span class="tool-badge" id="tool-file-n">1</span>
        </button>
        <button class="tool-btn" data-tool="hourglass" title="Песочные часы — +20 энергии">
          <span class="tool-ico" data-tico="hourglass"></span>
          <span class="tool-badge" id="tool-hourglass-n">1</span>
        </button>
        <button class="tool-btn tool-shop" data-tool="shop" title="Купить инструменты">
          <span class="tool-ico" data-tico="plus"></span>
        </button>
      </div>
    </div>

    <div class="tab-pane" id="tab-map">'''
    idx = idx[:start_i] + new_cases_block + idx[end_i + len(old_tools_end):]
    print("  + #tab-cases пересобран с каруселью")
else:
    print("  ⚠ не нашли #tab-cases блок (уже пропатчено?)")

# Добавляем ev-panel и ending перед </body>
ev_panel = '''
<!-- ══ ДОСКА УЛИК ══ -->
<div class="ev-panel" id="ev-panel">
  <h3>Доска улик</h3>
  <div class="ev-list" id="ev-list"></div>
  <button class="ev-close" id="ev-close">Закрыть</button>
</div>

<!-- ══ КОНЦОВКА ДЕЛА ══ -->
<div class="ending" id="ending">
  <div class="seal" id="e-seal"></div>
  <div class="e-verdict" id="e-verdict"></div>
  <div class="e-text" id="e-text"></div>
  <div class="e-meta" id="e-meta"></div>
  <button class="btn-ending" id="e-restart">Играть заново</button>
</div>

'''
if 'id="ev-panel"' not in idx:
    idx = idx.replace('</body>', ev_panel + '</body>', 1)
    print("  + ev-panel + ending добавлены")

with open(idx_path, "w", encoding="utf-8") as f:
    f.write(idx)
print("✓ index.html сохранён")
PYEOF


echo ""
echo "══ 2/4  app.js — заменяем движок карточек ══════════"
python3 - << 'PYEOF'
import sys, os

path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f:
    txt = f.read()

START = "/* ═══════════════════════════════════════════════\n   СЦЕНАРИЙ + КОЛОДА\n═══════════════════════════════════════════════ */"
END   = "/* ═══════════════════════════════════════════════\n   КАРТА ПРОГРЕССА\n═══════════════════════════════════════════════ */"

si = txt.find(START)
ei = txt.find(END)
if si == -1 or ei == -1:
    print("⚠ маркеры не найдены (уже пропатчено?)")
    sys.exit(0)

NEW_SECTION = r"""/* ═══════════════════════════════════════════════
   ДВИЖОК КАРУСЕЛИ (R10)
═══════════════════════════════════════════════ */

/* арт-мотивы по типу события */
const ART={
  crime:"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 70' fill='none' stroke='%23ffcf6b' stroke-width='1'><rect x='30' y='20' width='40' height='34' rx='2'/><path d='M30 28h40M38 20v8M62 20v8'/><circle cx='50' cy='40' r='5'/></svg>",
  evidence:"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 70' fill='none' stroke='%23ffcf6b' stroke-width='1'><circle cx='44' cy='32' r='13'/><path d='M54 42l14 14' stroke-width='1.6' stroke-linecap='round'/></svg>",
  witness:"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 70' fill='none' stroke='%23ffcf6b' stroke-width='1'><rect x='34' y='14' width='32' height='44' rx='2'/><path d='M50 14v44M34 36h32'/></svg>",
  suspect:"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 70' fill='none' stroke='%23ffcf6b' stroke-width='1'><circle cx='50' cy='28' r='10'/><path d='M32 58c2-12 34-12 36 0' stroke-linecap='round'/></svg>",
  shift:"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 70' fill='none' stroke='%23ffcf6b' stroke-width='1'><path d='M50 8v54M40 22l-12 13 12 13M60 22l12 13-12 13' stroke-linecap='round'/></svg>",
  final:"<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 100 70' fill='none' stroke='%23ffcf6b' stroke-width='1'><path d='M40 26l20-8 8 20-20 8z'/><path d='M48 22l16 14M30 56h28' stroke-linecap='round'/></svg>"
};
function artBg(t){ return "url(\"data:image/svg+xml;utf8,"+(ART[t]||ART.evidence)+"\")"; }

/* ═══ ДЕЛО №001 · ЗВЕЗДА СЕВЕРА ═══ */
const CASE={
  name:"Дело №001 · Звезда Севера",
  truth:{time:"day",liar:"restorer",guard:"clean"},
  start:"e0", total:9,
  events:{
    e0:{t:"crime",badge:"Преступление",title:"Кража в музее",
      text:"Утро. Из главного зала исчезла «Звезда Севера» — сапфир в платине. Витрина заперта, сигнализация молчала. У пустого постамента ты впервые ловишь сдвиг: воздух дрожит.",
      left:{label:"Осмотреть зал",to:"eHall"},right:{label:"Опросить охрану",to:"eGuard"}},
    eHall:{t:"evidence",badge:"Осмотр",title:"Главный зал",
      text:"Мрамор, пыль, холодный свет. Витрина и постамент просят внимания.",
      left:{label:"Витрина",evidence:"Витрина: замок заводской, стекло без царапин — не вскрывали.",to:"eClue1"},
      right:{label:"Постамент",evidence:"Постамент: микрослед монтажного клея — след от копии.",to:"eClue1"}},
    eClue1:{t:"evidence",badge:"Улика",title:"Тихий взлом",
      text:"Ни взлома, ни борьбы. Экспонат вынес тот, у кого был ключ — или подменили заранее.",
      left:{label:"Журнал доступа",evidence:"Ключ-карта реставратора: вход в часы профилактики зала.",to:"eGuard"},
      right:{label:"Книга смен",evidence:"Ночная смена — один Седов. Днём бригада без сопровождения.",to:"eGuard"}},
    eGuard:{t:"witness",badge:"Свидетель",title:"Охранник Седов",
      text:"Седов мнёт фуражку. Ночью никто не входил. Камеры «барахлили с обеда». Чем дольше говорит, тем больше спотыкается.",
      left:{label:"Надавить",evidence:"Седов: реставраторов пускали без сопровождения.",to:"eCams"},
      right:{label:"Поднять записи",evidence:"Записи обрываются в 15:40 — средь бела дня.",to:"eCams"}},
    eCams:{t:"evidence",badge:"Архив камер",title:"Обрыв в 15:40",
      text:"Картинка с зала глохнет днём. Кто-то знал график камер. Сдвиг нарастает.",
      left:{label:"К версиям",to:"eShift1"},right:{label:"К версиям",to:"eShift1"}},
    eShift1:{shift:true,t:"shift",badge:"СДВИГ · 1",title:"Две ночи",
      intro:"Зал раскалывается надвое. Тяни карту — одна реальность твердеет, ей и сбыться.",
      a:{label:"◄ НОЧЬ",vtext:"Ночная кража: вошли через служебный ход, пока сигнализация спала.",set:{time:"night"},bad:true,to:"eAfter1"},
      b:{label:"ДЕНЬ ►",vtext:"Подмена днём: экспонат заменили копией на профилактике.",set:{time:"day"},to:"eAfter1"}},
    eAfter1:{t:"suspect",badge:"Озарение",title:"Двое у постамента",
      text:"@T@ Двое могли провернуть подмену: куратор Лацис и реставратор Корн.",
      left:{label:"Куратор Лацис",evidence:"Лацис: алиби — «весь день в архиве», но журнал архива пуст.",to:"eRestorer"},
      right:{label:"Реставратор Корн",evidence:"Корн: «копия для выставки», которой нет ни в одной описи.",to:"eRestorer"}},
    eRestorer:{t:"suspect",badge:"Допрос",title:"Кто ближе к делу",
      text:"Оба нервничают, оба недоговаривают. Ложь — только у одного из них.",
      left:{label:"Слушать Лациса",evidence:"Лацис: «он один трогал крепления».",to:"eShift2"},
      right:{label:"Слушать Корна",evidence:"Корн: «у него ключи от всего».",to:"eShift2"}},
    eShift2:{shift:true,t:"shift",badge:"СДВИГ · 2",title:"Чья ложь",
      intro:"Снова раскол. Один лжёт прямо сейчас. Выбери, чью ложь видишь.",
      a:{label:"◄ ЛЖЁТ ЛАЦИС",vtext:"Куратор: доступ ко всему, мотив, пустое алиби.",set:{liar:"curator"},bad:true,to:"eGuardFate"},
      b:{label:"ЛЖЁТ КОРН ►",vtext:"Реставратор: только он касался экспоната и знал крепления.",set:{liar:"restorer"},to:"eGuardFate"}},
    eGuardFate:{t:"witness",badge:"Свидетель",title:"Удобный виноватый",
      text:"Следствие давит — всё на Седова. Но что-то не сходится.",
      left:{label:"Счета Седова",evidence:"Счета чисты: ни лишней копейки. Его подставили.",to:"eShift3"},
      right:{label:"Он не в доле",evidence:"Седов лишь проспал смену. Подстава.",to:"eShift3"}},
    eShift3:{shift:true,t:"shift",badge:"СДВИГ · 3",title:"Судьба Седова",
      intro:"Последний раскол. Охранник — звено схемы или козёл отпущения?",
      a:{label:"◄ СОУЧАСТНИК",vtext:"Седов в деле: отключил камеры за долю. Быстрое закрытие.",set:{guard:"paid"},bad:true,to:"eAccuse"},
      b:{label:"ПОДСТАВА ►",vtext:"Настоящий вор увёл след на охранника.",set:{guard:"clean"},to:"eAccuse"}},
    eAccuse:{t:"final",badge:"Финал",title:"Имя на постановлении",
      text:"Сдвиги улеглись. Пора назвать имя — обратной дороги нет.",
      left:{label:"Куратор Лацис",set:{accused:"curator"},bad:true,to:"__resolve__"},
      right:{label:"Реставратор Корн",set:{accused:"restorer"},to:"__resolve__"}}
  }
};

function fill(text,f){
  if(text.indexOf("@T@")<0) return text;
  const pre=f.time==="day"?"Версия дня обретает вес. ":"Следов ночного входа всё меньше. ";
  return pre+text.replace("@T@","").trim();
}
function computeEnding(f){
  const t=CASE.truth;
  const align=(f.time===t.time?1:0)+(f.liar===t.liar?1:0)+(f.guard===t.guard?1:0);
  if(f.accused==="restorer"&&align===3)
    return{kind:"win",mark:"✓",verdict:"ДЕЛО РАСКРЫТО",
      text:"Корн сломался. Копию прятал в реставрационной, оригинал — к перепродаже. Каждый сдвиг лёг точно в линию правды.",align};
  if(f.accused==="restorer")
    return{kind:"partial",mark:"≈",verdict:"РАСКРЫТО НА ВОЛОСКЕ",
      text:"Верный виновный, но часть сдвигов вела в сторону. Победа, которой повезло.",align};
  return{kind:"fail",mark:"✗",verdict:"ЛОЖНЫЙ СЛЕД",
    text:"Лациса увели в наручниках. Через неделю «Звезду» нашли у перекупщика — с подписью Корна.",align};
}
function haptic(kind){
  try{if(window.Telegram&&Telegram.WebApp&&Telegram.WebApp.HapticFeedback){
    if(kind==="shift")Telegram.WebApp.HapticFeedback.notificationOccurred("warning");
    else if(kind==="burn")Telegram.WebApp.HapticFeedback.impactOccurred("heavy");
    else Telegram.WebApp.HapticFeedback.impactOccurred("medium");return;}}catch(e){}
  try{navigator.vibrate&&navigator.vibrate(kind==="shift"?[14,40,14,40,30]:kind==="burn"?[10,30,60]:14);}catch(e){}
}

/* ════ КОЛЬЦО ════ */
const CState={ev:CASE.start,flags:{},evidence:[],step:0};
let _ring=null,_evCountEl=null,_progEl=null;
let cfCards=[],centerIndex=0,cBusy=false,cActive=null,SPIN_DUR=640;
const CN=6,CSTEPD=60,CRX=150,CYL=152,CZL=120,CSD=0.42;

function cNorm(a){a=a%360;if(a>180)a-=360;if(a<-180)a+=360;return a;}
function cPosFor(phi){
  const r=phi*Math.PI/180,c=Math.cos(r),s=Math.sin(r);
  const x=CRX*s,y=CYL*(c-1),z=CZL*(c-1),sc=1-CSD*(1-c)/2;
  return{t:'translate(-50%,-50%) translate3d('+x.toFixed(1)+'px,'+y.toFixed(1)+'px,'+z.toFixed(1)+'px) scale('+sc.toFixed(3)+')',d:(1-c)/2};
}
function cPhiOf(e){return cNorm((e-centerIndex)*CSTEPD);}
function gframeHTML(){return '<div class="gframe"><i class="fil tl"></i><i class="fil tr"></i><i class="fil bl"></i><i class="fil br"></i></div>';}
function backHTML(){return gframeHTML()+'<span class="crank t">С</span><span class="crank b">С</span><div class="cmono">С</div>';}
function cardHTML(ev){
  const scene='<div class="scene"><div class="grad"></div><div class="art" style="background-image:'+artBg(ev.t)+'"></div></div>';
  if(ev.shift){
    return gframeHTML()+scene+'<div class="pad"><span class="badge">'+ev.badge+'</span>'
      +'<div class="title">'+ev.title+'</div>'
      +'<div class="shift-intro">'+ev.intro+'</div><div class="vstack">'
      +'<div class="vpanel a"><div class="vlabel">'+ev.a.label+'</div><div class="vtext">'+ev.a.vtext+'</div></div>'
      +'<div class="seam"></div>'
      +'<div class="vpanel b"><div class="vlabel">'+ev.b.label+'</div><div class="vtext">'+ev.b.vtext+'</div></div>'
      +'</div></div>';
  }
  return gframeHTML()+scene
    +'<span class="stamp l">'+(ev.left.label||'').replace(/^◄\s*/,'')+'</span>'
    +'<span class="stamp r">'+(ev.right.label||'').replace(/\s*►$/,'')+'</span>'
    +'<div class="pad"><span class="badge">'+ev.badge+'</span>'
    +'<div class="title">'+ev.title+'</div>'
    +'<div class="text">'+fill(ev.text,CState.flags)+'</div>'
    +'<div class="spacer"></div><div class="choices">'
    +'<div class="choice l"><span class="dir">СВАЙП ВЛЕВО</span>'+ev.left.label+'</div>'
    +'<div class="choice r"><span class="dir">СВАЙП ВПРАВО</span>'+ev.right.label+'</div>'
    +'</div></div>';
}
function setBack(el){el.classList.remove("active","shift","grab","burning");el._ev=null;
  el.innerHTML='<div class="cfinner">'+backHTML()+'</div>';}
function setActive(el,ev){
  el.classList.add("active"); el.classList.toggle("shift",!!ev.shift);
  el.innerHTML='<div class="cfinner">'+cardHTML(ev)+'</div>'; el._ev=ev; cActive=el;
  App.currentCard=ev; App.swipeUnlocked=false;
  addLockOverlay(el);
}
function cLayout(animate){
  cfCards.forEach(function(c,e){
    const phi=cPhiOf(e),P=cPosFor(phi);
    const prev=c._phi,jump=(prev!==undefined&&Math.abs(cNorm(phi-prev))>CSTEPD+1);
    c.style.transition=(animate&&!jump)?("transform "+SPIN_DUR+"ms cubic-bezier(.22,.7,.24,1)"):"none";
    c.style.transform=P.t; c.style.zIndex=String(100-Math.round(P.d*100)); c._phi=phi;
  });
}
function buildBacks(){
  for(let i=0;i<CN;i++){
    const c=document.createElement("div"); c.className="cfcard"; c._phi=undefined;
    _ring.appendChild(c); cfCards.push(c); bindDrag(c);
  }
  cfCards.forEach(function(c,e){
    if(e===centerIndex) setActive(c,CASE.events[CASE.start]); else setBack(c);
  });
  cLayout(false);
}

/* ── мини-игра: блокировка свайпа ── */
function addLockOverlay(cardEl){
  const pad=cardEl.querySelector('.pad'); if(!pad) return;
  if(pad.querySelector('.card-lock')) return;
  const lock=document.createElement('div'); lock.className='card-lock';
  lock.innerHTML='<button class="card-lock-btn" id="play-gems-ring">'
    +'<span class="clb-ico">🔍</span><span>Найти улики</span></button>'
    +'<div class="card-lock-hint">⟵ свайп заблокирован ⟶</div>';
  pad.appendChild(lock);
  lock.querySelector('#play-gems-ring').addEventListener('click',function(){
    try{Sound.tap();}catch(_){} openHintGame(App.currentCard||{});
  });
}
function removeLockOverlay(){
  const lock=document.querySelector('.cfcard.active .card-lock');
  if(lock) lock.remove();
}

/* ── огонь (общий движок) ── */
function _spawnSparks(el,fx,cls){
  for(let i=0;i<3;i++){
    const s=document.createElement('div'); s.className='spark'+(cls?' '+cls:'');
    s.style.left=(fx*100+(Math.random()-.5)*14)+'%';
    s.style.top=(10+Math.random()*78)+'%';
    s.style.setProperty('--sx',((Math.random()*2-1)*48|0)+'px');
    s.style.setProperty('--sy',((-35-Math.random()*95)|0)+'px');
    s.style.setProperty('--sd',((580+Math.random()*720)|0)+'ms');
    el.appendChild(s); setTimeout(function(){s.remove();},1500);
  }
}
function _runBurn(el,fromLeft,sparksClass,fireCls,smokeCls,done){
  haptic("burn"); el.onpointerdown=null; el.classList.add("burning");
  const inner=el.querySelector('.cfinner');
  const fire=document.createElement('div'); fire.className='fire'+(fireCls?' '+fireCls:''); el.appendChild(fire);
  const smk=document.createElement('div'); smk.className='smoke'+(smokeCls?' '+smokeCls:''); el.appendChild(smk);
  const DUR=1850; let t0=0,last=0;
  function frame(ts){
    if(!t0){t0=ts;last=ts;}
    const p=Math.min(1,(ts-t0)/DUR), ep=p*p*(3-2*p);
    const fx=fromLeft?(1-ep):ep, soft=0.08;
    let g;
    if(fromLeft){const a=Math.max(0,(fx-soft)*100),b=Math.min(100,fx*100);
      g='linear-gradient(90deg,#000 0,#000 '+a.toFixed(1)+'%,transparent '+b.toFixed(1)+'%,transparent 100%)';}
    else{const a=Math.max(0,fx*100),b=Math.min(100,(fx+soft)*100);
      g='linear-gradient(90deg,transparent 0,transparent '+a.toFixed(1)+'%,#000 '+b.toFixed(1)+'%,#000 100%)';}
    inner.style.webkitMaskImage=g; inner.style.maskImage=g;
    fire.style.left=(fx*100)+'%';
    fire.style.opacity=(p<0.06?p/0.06:p>0.88?Math.max(0,(1-p)/.12):1).toFixed(2);
    const tilt=(fromLeft?-1:1);
    el.style.transform='translate(-50%,-50%) translateX('+(tilt*ep*54).toFixed(1)+'px) rotate('+(tilt*ep*3.2).toFixed(2)+'deg) scale('+(1-ep*.045).toFixed(3)+')';
    if(ts-last>38){last=ts; _spawnSparks(el,fx,sparksClass);}
    if(p<1) requestAnimationFrame(frame); else{done&&done();}
  }
  requestAnimationFrame(frame);
}
/* Оранжевый огонь — свайп влево */
function burnCard(el,dir,done){ _runBurn(el,dir==='left','','','',done); }
/* Синий огонь — свайп вправо */
function burnCardBlue(el,dir,done){ _runBurn(el,false,'spark-blue','fire-blue','smoke-blue',done); }

function cAdvance(dir,ev,opt){
  if(cBusy) return; cBusy=true;
  cApplyOption(opt);
  const c0=cfCards[centerIndex]; c0.onpointerdown=null;
  function turn(){
    centerIndex=(centerIndex+(dir==="left"?1:-1)+CN)%CN;
    CState.step++; cSetProgress();
    const resolve=(opt.to==="__resolve__");
    if(!resolve) setActive(cfCards[centerIndex],CASE.events[opt.to]);
    cLayout(true);
    setTimeout(function(){
      if(resolve) showEnding(computeEnding(CState.flags));
      else if(c0!==cfCards[centerIndex]) setBack(c0);
      SPIN_DUR=640; cBusy=false;
    },resolve?520:Math.max(580,SPIN_DUR+40));
  }
  if(dir==="left"){ burnCard(c0,"left",function(){setBack(c0);turn();}); }
  else { burnCardBlue(c0,"right",function(){setBack(c0);turn();}); }
}

function cAddEvidence(t){
  if(t&&CState.evidence.indexOf(t)<0) CState.evidence.push(t);
  if(_evCountEl) _evCountEl.textContent=CState.evidence.length;
  addXP(10);
}
function cSetProgress(){
  const p=Math.min(100,Math.round(CState.step/CASE.total*100));
  if(_progEl) _progEl.style.width=p+"%";
}
function cApplyOption(o){
  if(o.set) Object.assign(CState.flags,o.set);
  if(o.evidence) cAddEvidence(o.evidence);
}

function bindDrag(card){
  let sx=0,sy=0,dx=0,drag=false,pid=null,vx=0,lastX=0,lastT=0,evc=null,pA=null,pB=null,stL=null,stR=null;
  const TH=86;
  function setShiftGap(k){if(!pA||!pB)return;
    pA.classList.toggle("hot",k<-.2); pA.classList.toggle("dim",k>.2);
    pB.classList.toggle("hot",k>.2);  pB.classList.toggle("dim",k<-.2);}
  function snap(){card.style.transition="transform .28s cubic-bezier(.3,1.3,.5,1)";card.style.transform="translate(-50%,-50%)";
    if(evc&&evc.shift)setShiftGap(0);if(stL)stL.style.opacity=0;if(stR)stR.style.opacity=0;
    setTimeout(function(){card.style.transition="";},280);}
  function down(x,y,id){
    if(cBusy||!card.classList.contains("active")||!App.swipeUnlocked) return false;
    evc=card._ev; pA=card.querySelector(".vpanel.a"); pB=card.querySelector(".vpanel.b");
    stL=card.querySelector(".stamp.l"); stR=card.querySelector(".stamp.r");
    drag=true;pid=id;sx=x;sy=y;dx=0;vx=0;lastT=0;lastX=x;
    card.classList.add("grab");card.style.transition="";return true;}
  function move(x,y){if(!drag)return;const now=performance.now();
    if(lastT){const d=now-lastT;if(d>0)vx=vx*.65+.35*((x-lastX)/d*1000);}
    lastX=x;lastT=now;dx=x-sx;const dy=(y-sy)*.18;
    card.style.transform="translate(-50%,-50%) translate("+dx+"px,"+dy.toFixed(1)+"px) rotate("+(dx/26)+"deg)";
    const k=Math.max(-1,Math.min(1,dx/TH));
    if(evc&&evc.shift)setShiftGap(k);
    else{if(stL)stL.style.opacity=Math.max(0,-k);if(stR)stR.style.opacity=Math.max(0,k);}}
  function up(){if(!drag)return;drag=false;card.classList.remove("grab");
    if(Math.abs(dx)>TH)commit(dx>0?"right":"left");else snap();}
  function commit(side){const ev=evc;if(!ev)return;
    const opt=ev.shift?(side==="left"?ev.a:ev.b):(side==="left"?ev.left:ev.right);
    const sp=Math.min(1,Math.abs(vx)/3800); SPIN_DUR=Math.round(660-sp*160);
    cAdvance(side,ev,opt);}
  card.addEventListener("pointerdown",function(e){if(!down(e.clientX,e.clientY,e.pointerId))return;
    try{card.setPointerCapture(e.pointerId);}catch(_){}});
  card.addEventListener("pointermove",function(e){if(pid!=null&&e.pointerId!==pid)return;move(e.clientX,e.clientY);});
  card.addEventListener("pointerup",function(e){if(pid!=null&&e.pointerId!==pid)return;up();try{card.releasePointerCapture(e.pointerId);}catch(_){}});
  card.addEventListener("pointercancel",function(e){if(drag){drag=false;card.classList.remove("grab");snap();}});
}

function showEnding(r){
  const endEl=document.getElementById("ending");if(!endEl)return;
  const seal=document.getElementById("e-seal");if(seal){seal.className="seal "+r.kind;seal.textContent=r.mark;}
  const ver=document.getElementById("e-verdict");if(ver){ver.className="e-verdict "+r.kind;ver.textContent=r.verdict;}
  const txt=document.getElementById("e-text");if(txt)txt.textContent=r.text;
  const meta=document.getElementById("e-meta");if(meta)meta.innerHTML="Сходимость: <b>"+r.align+" / 3</b> · улик: <b>"+CState.evidence.length+"</b>";
  if(_progEl)_progEl.style.width="100%";
  haptic(r.kind==="fail"?"shift":"burn"); endEl.classList.add("show");
  if(r.kind==="win"){try{addXP(150);addCredits(100);vibrate([20,40,80]);}catch(_){}}
  else if(r.kind==="partial"){try{addXP(60);addCredits(40);}catch(_){}}
  else{try{addXP(20);addCredits(10);}catch(_){}}
  try{saveProfile();}catch(_){}
}

function nextCard(){ restartCarousel(); }
function restartCarousel(){
  CState.ev=CASE.start;CState.flags={};CState.evidence=[];CState.step=0;
  if(_evCountEl)_evCountEl.textContent="0";
  if(_progEl)_progEl.style.width="0%";
  const endEl=document.getElementById("ending");if(endEl)endEl.classList.remove("show");
  cfCards.forEach(function(c){if(c.parentNode)c.parentNode.removeChild(c);});
  cfCards=[];centerIndex=0;cBusy=false;cActive=null;SPIN_DUR=640;
  App.swipeUnlocked=false;
  buildBacks();
}

function initEvPanel(){
  const chip=document.getElementById("ev-chip");
  if(chip) chip.addEventListener("click",function(){
    const panel=document.getElementById("ev-panel");
    const list=document.getElementById("ev-list");
    if(!panel||!list)return;
    list.innerHTML=CState.evidence.length
      ? CState.evidence.map(function(t){return '<div class="ev-item">'+t+'</div>';}).join("")
      : '<div class="ev-empty">Улики появятся по ходу расследования.</div>';
    panel.classList.add("open");
  });
  const closeBtn=document.getElementById("ev-close");
  if(closeBtn) closeBtn.addEventListener("click",function(){
    const panel=document.getElementById("ev-panel");if(panel)panel.classList.remove("open");
  });
  const restartBtn=document.getElementById("e-restart");
  if(restartBtn) restartBtn.addEventListener("click",function(){restartCarousel();});
}

function initCarousel(){
  _ring=document.getElementById("ring");
  _evCountEl=document.getElementById("ev-count");
  _progEl=document.getElementById("prog");
  if(!_ring)return;
  cfCards=[];centerIndex=0;cBusy=false;cActive=null;SPIN_DUR=640;
  CState.ev=CASE.start;CState.flags={};CState.evidence=[];CState.step=0;
  if(_evCountEl)_evCountEl.textContent="0";
  cSetProgress(); buildBacks(); initEvPanel();
}

"""

txt = txt[:si] + NEW_SECTION + txt[ei:]
with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
print("✓ app.js: движок карусели вставлен")
PYEOF


echo ""
echo "══ 3/4  app.js — enterMain, unlockSwipe, tools ══════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f:
    txt = f.read()

# enterMain: buildDeck(); renderCard(); dealDeck() → initCarousel()
old_e = "  try{ buildDeck(); renderCard(); dealDeck(); }catch(e){ console.error('renderCard',e); }"
new_e = "  try{ initCarousel(); }catch(e){ console.error('initCarousel',e); }"
if old_e in txt:
    txt = txt.replace(old_e, new_e, 1); print("  + enterMain обновлён")

# unlockSwipe: добавляем removeLockOverlay()
old_u = "function unlockSwipe(){\n  App.swipeUnlocked=true;\n  vibrate(20); Sound.booster();"
new_u = "function unlockSwipe(){\n  App.swipeUnlocked=true;\n  vibrate(20); Sound.booster();\n  try{removeLockOverlay();}catch(_){}"
if old_u in txt:
    txt = txt.replace(old_u, new_u, 1); print("  + unlockSwipe обновлён")

# useTool('file') — досье разблокирует свайп через unlockSwipe
old_f = "else if(t==='file'){ T[t]--; App.swipeUnlocked=true;\n    const c=App.deck[App.cardIndex]; const card=document.querySelector('.case-card');\n    if(card&&c) renderCardActions(card,c);\n    toast('Досье','Свайп разблокирован','📁'); }"
new_f = "else if(t==='file'){ T[t]--; unlockSwipe(); toast('Досье','Свайп разблокирован','📁'); }"
if old_f in txt:
    txt = txt.replace(old_f, new_f, 1); print("  + useTool file обновлён")

with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
print("✓ app.js вторичные патчи применены")
PYEOF


echo ""
echo "══ 4/4  card-design.css — стили карусели ════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f:
    txt = f.read()

if ".cfcard" in txt:
    print("  · CSS уже есть, пропускаем")
    exit(0)

carousel_css = """
/* ════════════════════════════════════════════════════
   СДВИГ · КАРУСЕЛЬ (R10) — интегрирована в index.html
════════════════════════════════════════════════════ */

/* переменные карусели (алиасы под основную систему) */
:root{
  --gold:linear-gradient(135deg,#5a3c0a 0%,#f3d27a 26%,#caa033 50%,#f8e9b8 72%,#6a4810 100%);
  --amber:var(--acc); --amber-lite:var(--acc-2); --amber-deep:var(--acc-d);
  --dim:var(--ink3); --line:var(--glass-line);
  --cyan:var(--gem); --rose:var(--no); --win:var(--ok); --fail:var(--no);
  --card-w:min(62%,218px); --card-h:min(50vh,400px);
}

/* ── лейаут #tab-cases ── */
#tab-cases{ display:flex; flex-direction:column; }
.case-prog-bar{
  flex:0 0 auto; height:3px; margin:4px 14px 2px; border-radius:3px;
  background:rgba(255,255,255,.07); overflow:hidden; z-index:5;
}
.case-prog-bar > i{
  display:block; height:100%; width:0; border-radius:3px;
  background:linear-gradient(90deg,var(--acc-d),var(--acc-2));
  box-shadow:0 0 8px var(--acc); transition:width .5s cubic-bezier(.3,1,.4,1);
}
.stage{ position:relative; flex:1; touch-action:none; overflow:hidden; }
.ring-scene{ position:absolute; inset:0; z-index:1; perspective:1300px; perspective-origin:50% 47%; }
.ring{ position:absolute; inset:0; transform-style:preserve-3d; touch-action:none; }

/* ── карта (cfcard) ── */
.cfcard{
  position:absolute; left:50%; top:50%;
  width:var(--card-w); height:var(--card-h);
  touch-action:none; will-change:transform,opacity;
}
.cfinner{
  position:absolute; inset:0; border-radius:15px; overflow:hidden;
  backface-visibility:hidden; touch-action:none;
  display:flex; flex-direction:column; align-items:center; justify-content:center;
  background:
    radial-gradient(130% 75% at 50% -6%, rgba(74,56,30,.42), transparent 58%),
    repeating-linear-gradient(115deg, rgba(255,255,255,.014) 0 2px, transparent 2px 5px),
    linear-gradient(158deg,#221d16 0%,#0b0907 72%);
  box-shadow:0 0 0 3px #a9790f, 0 0 0 4px rgba(0,0,0,.5),
    0 22px 46px rgba(0,0,0,.62), 0 0 24px rgba(180,120,20,.16), inset 0 0 70px rgba(0,0,0,.6);
}
.gframe{ position:absolute; inset:6px; border:1.5px solid rgba(240,205,130,.45); border-radius:9px; pointer-events:none; z-index:6; }
.fil{ position:absolute; width:46px; height:46px; background:no-repeat center/contain;
  background-image:url("data:image/svg+xml;utf8,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 48 48' fill='none' stroke='%23eccd86' stroke-width='1.5' stroke-linecap='round'><path d='M5 21 C5 11 10 5 21 5'/><path d='M10 23 C10 15 14 10 23 10'/><path d='M23 10 c10 -1 15 7 13 16 c-3 -6 -8 -8 -14 -6 c2 -3 1 -7 1 -10z'/><circle cx='34' cy='15' r='1.7' fill='%23eccd86' stroke='none'/><path d='M5 21 q-1 7 1 13'/><path d='M21 5 q7 -1 13 1'/></svg>"); }
.fil.tl{ left:-2px; top:-2px; } .fil.tr{ right:-2px; top:-2px; transform:scaleX(-1); }
.fil.bl{ left:-2px; bottom:-2px; transform:scaleY(-1); } .fil.br{ right:-2px; bottom:-2px; transform:scale(-1); }
.cmono{ position:relative; z-index:2; font-family:'Unbounded',sans-serif; font-weight:900; font-size:108px; line-height:1;
  background:var(--gold); -webkit-background-clip:text; background-clip:text; color:transparent;
  filter:drop-shadow(0 3px 5px rgba(0,0,0,.75)); }
.crank{ position:absolute; z-index:7; font-family:'Unbounded',sans-serif; font-weight:900; font-size:24px; line-height:1;
  background:var(--gold); -webkit-background-clip:text; background-clip:text; color:transparent; filter:drop-shadow(0 1px 2px rgba(0,0,0,.7)); }
.crank.t{ left:15px; top:13px; } .crank.b{ right:15px; bottom:10px; transform:rotate(180deg); }
.cfcard.active{ z-index:20; cursor:grab; }
.cfcard.active .cfinner{ align-items:stretch; justify-content:flex-start; }
.cfcard.active.grab{ cursor:grabbing; }

/* фон сцены */
.scene{ position:absolute; inset:0; z-index:0; opacity:.95; }
.scene .grad{ position:absolute; inset:0;
  background:radial-gradient(95% 55% at 50% 0%, rgba(200,134,10,.16), transparent 62%),
    linear-gradient(180deg, rgba(14,20,30,.15), rgba(5,8,13,.9)); }
.scene .art{ position:absolute; inset:0; opacity:.14; background:no-repeat center 30%/72%; }
.scene::after{ content:''; position:absolute; inset:0; box-shadow:inset 0 -110px 80px rgba(0,0,0,.55); }

/* pad + типографика */
.pad{ position:relative; z-index:3; padding:16px 17px 12px; display:flex; flex-direction:column; height:100%; overflow:hidden; }
.badge{ align-self:flex-start; font-family:'Unbounded',sans-serif; font-size:9px; font-weight:700;
  letter-spacing:.16em; text-transform:uppercase; padding:5px 10px; border-radius:8px;
  color:var(--amber-lite); background:rgba(200,134,10,.13); border:1px solid rgba(200,134,10,.4); }
.title{ font-family:'Unbounded',sans-serif; font-weight:900; font-size:20px; line-height:1.15; margin:10px 0 8px;
  text-shadow:0 2px 18px rgba(0,0,0,.5); }
.text{ font-size:13.5px; line-height:1.48; color:#ded6c4; overflow:hidden; display:-webkit-box;
  -webkit-line-clamp:5; -webkit-box-orient:vertical; }
.spacer{ flex:1; min-height:4px; }

/* choices */
.choices{ display:flex; gap:8px; margin-top:10px; }
.choice{ flex:1; padding:10px 8px; border-radius:13px; font-size:12px; font-weight:600; text-align:center;
  border:1px solid var(--line); background:rgba(255,255,255,.035); color:#d6cebd; transition:border-color .15s; }
.choice .dir{ display:block; font-size:9.5px; margin-bottom:3px; letter-spacing:.12em; }
.choice.l .dir{ color:var(--rose); } .choice.r .dir{ color:var(--cyan); }

/* штампы */
.stamp{ position:absolute; top:28px; z-index:6; font-family:'Unbounded',sans-serif; font-weight:900;
  font-size:21px; letter-spacing:.06em; padding:6px 13px; border-radius:10px; opacity:0; border:3px solid currentColor; }
.stamp.l{ right:24px; transform:rotate(11deg); color:var(--rose); }
.stamp.r{ left:24px; transform:rotate(-11deg); color:var(--cyan); }

/* СДВИГ: раскол */
.cfcard.shift .scene .grad{
  background:
    radial-gradient(70% 50% at 22% 12%, rgba(92,208,255,.18), transparent 55%),
    radial-gradient(70% 50% at 78% 88%, rgba(255,111,134,.18), transparent 55%),
    linear-gradient(180deg, rgba(8,12,20,.4), rgba(4,7,12,.92)); }
.shift-intro{ font-size:12.5px; line-height:1.42; color:#cdd6e2; margin:4px 0 6px; }
.vstack{ display:flex; flex-direction:column; gap:6px; margin-top:6px; }
.vpanel{ position:relative; padding:9px 12px; border-radius:12px; border:1px solid;
  transition:transform .14s ease,opacity .14s ease,box-shadow .14s ease; }
.vpanel .vlabel{ font-family:'Unbounded',sans-serif; font-weight:800; font-size:15px; letter-spacing:.04em; margin-bottom:4px; }
.vpanel .vtext{ font-size:12px; line-height:1.36; opacity:.92; }
.vpanel.a{ color:var(--cyan); border-color:rgba(92,208,255,.38);
  background:linear-gradient(120deg, rgba(92,208,255,.13), rgba(92,208,255,.02)); }
.vpanel.b{ color:var(--rose); border-color:rgba(255,111,134,.38);
  background:linear-gradient(240deg, rgba(255,111,134,.13), rgba(255,111,134,.02)); }
.vpanel.dim{ opacity:.34; } .vpanel.hot{ box-shadow:0 0 22px currentColor,inset 0 0 14px rgba(255,255,255,.06); transform:scale(1.025); }
.seam{ height:2px; margin:0 12px; border-radius:2px;
  background:linear-gradient(90deg,transparent,var(--amber-lite),#fff,var(--amber-lite),transparent);
  box-shadow:0 0 10px var(--amber-lite); animation:seamflick 2s steps(2) infinite; }
@keyframes seamflick{ 0%,90%{opacity:.85}93%{opacity:.3}96%{opacity:1}100%{opacity:.6} }

/* ── СЖИГАНИЕ (огонь) ── */
.cfcard.burning{ pointer-events:none; z-index:25; }
.fire{ position:absolute; top:-6%; bottom:-6%; width:52px; transform:translateX(-50%);
  pointer-events:none; z-index:9; mix-blend-mode:screen; will-change:left,opacity; }
.fire::before{ content:''; position:absolute; inset:0;
  background:linear-gradient(90deg,transparent,rgba(255,70,0,.38) 26%,rgba(255,150,40,.9) 44%,rgba(255,250,210,1) 50%,rgba(255,150,40,.9) 56%,rgba(255,70,0,.38) 74%,transparent);
  filter:blur(2.5px); box-shadow:0 0 30px 8px rgba(255,110,20,.7),0 0 70px 18px rgba(255,60,0,.4);
  animation:fireFlick .10s steps(2) infinite; }
.fire::after{ content:''; position:absolute; left:50%; top:-4%; width:14px; height:108%; transform:translateX(-50%);
  background:linear-gradient(180deg,transparent,rgba(255,240,190,.9) 28%,#fff 50%,rgba(255,240,190,.9) 72%,transparent);
  filter:blur(1.2px); animation:fireFlick .08s steps(2) infinite; }
@keyframes fireFlick{ 0%{opacity:.80;transform:translateX(-50%) scaleY(1)}100%{opacity:1;transform:translateX(-50%) scaleY(1.08)} }

/* Синий огонь */
.fire-blue::before{
  background:linear-gradient(90deg,transparent,rgba(20,80,255,.38) 26%,rgba(60,160,255,.9) 44%,rgba(210,240,255,1) 50%,rgba(60,160,255,.9) 56%,rgba(20,80,255,.38) 74%,transparent);
  box-shadow:0 0 30px 8px rgba(40,130,255,.7),0 0 70px 18px rgba(20,80,255,.4); }
.fire-blue::after{
  background:linear-gradient(180deg,transparent,rgba(160,225,255,.9) 28%,#fff 50%,rgba(160,225,255,.9) 72%,transparent); }

/* искры */
.spark{ position:absolute; width:4px; height:4px; border-radius:50%; pointer-events:none; z-index:10;
  background:radial-gradient(circle,#fff,#ffd36b 40%,#ff7a18 72%,transparent);
  box-shadow:0 0 8px 2px rgba(255,150,40,.8); animation:sparkUp var(--sd,900ms) ease-out forwards; }
.spark-blue{
  background:radial-gradient(circle,#fff,#a0d8ff 40%,#2563ff 72%,transparent);
  box-shadow:0 0 8px 2px rgba(60,160,255,.8); }
@keyframes sparkUp{ 0%{transform:translate(0,0) scale(1);opacity:1} 100%{transform:translate(var(--sx,0),var(--sy,-60px)) scale(.2);opacity:0} }

/* дым */
.smoke{ position:absolute; left:-6%; right:-6%; bottom:0; height:130%; z-index:7; pointer-events:none; opacity:0;
  background:radial-gradient(72% 58% at 50% 100%,rgba(22,18,15,.7),transparent 72%); filter:blur(7px);
  animation:smokeRise 1.9s ease-out forwards; }
.smoke-blue{ background:radial-gradient(72% 58% at 50% 100%,rgba(10,20,50,.7),transparent 72%); }
@keyframes smokeRise{ 0%{opacity:0;transform:translateY(12%) scale(1)}20%{opacity:.5}100%{opacity:0;transform:translateY(-34%) scale(1.25)} }

/* ── мини-игра: замок ── */
.card-lock{
  position:absolute; bottom:0; left:0; right:0;
  padding:12px 15px 14px; border-radius:0 0 14px 14px;
  background:linear-gradient(0deg,rgba(5,8,13,.97) 0%,rgba(5,8,13,.82) 100%);
  display:flex; flex-direction:column; align-items:center; gap:8px; z-index:10;
}
.card-lock-btn{
  display:flex; align-items:center; justify-content:center; gap:8px;
  width:100%; padding:12px 16px; border:none; border-radius:11px; cursor:pointer;
  background:linear-gradient(135deg,rgba(200,134,10,.22),rgba(200,134,10,.1));
  border:1px solid rgba(200,134,10,.5); color:var(--acc-2);
  font-family:'Unbounded',sans-serif; font-weight:700; font-size:12.5px;
  letter-spacing:.04em; transition:background .15s;
}
.card-lock-btn:active{ background:rgba(200,134,10,.3); }
.clb-ico{ font-size:15px; }
.card-lock-hint{ font-size:10px; letter-spacing:.17em; text-transform:uppercase; color:rgba(139,148,164,.55); }

/* ── ev-chip в tools-bar ── */
.ev-chip{
  display:flex; align-items:center; gap:6px; padding:8px 12px;
  border-radius:var(--rfull); cursor:pointer;
  background:var(--glass-2); -webkit-backdrop-filter:blur(var(--glass-blur)); backdrop-filter:blur(var(--glass-blur));
  border:1px solid var(--glass-line); font-size:12px; font-weight:600; pointer-events:auto;
}
.ev-chip b{ color:var(--acc-2); font-family:'Unbounded',sans-serif; }
.ev-dot{ width:7px; height:7px; border-radius:50%; background:var(--acc); box-shadow:0 0 10px var(--acc); flex-shrink:0; }

/* ── доска улик ── */
.ev-panel{
  position:fixed; left:0; right:0; bottom:0; z-index:150; max-width:480px; margin:0 auto;
  background:rgba(8,12,19,.97); backdrop-filter:blur(16px);
  border-top:1px solid var(--glass-line); border-radius:22px 22px 0 0;
  padding:18px 18px max(18px,env(safe-area-inset-bottom));
  transform:translateY(112%); transition:transform .3s cubic-bezier(.3,1,.4,1);
}
.ev-panel.open{ transform:translateY(0); }
.ev-panel h3{ font-family:'Unbounded',sans-serif; font-size:12px; letter-spacing:.12em; text-transform:uppercase;
  color:var(--acc-2); margin:0 0 12px; }
.ev-list{ display:flex; flex-direction:column; gap:8px; max-height:40vh; overflow:auto; }
.ev-item{ font-size:13px; line-height:1.45; color:#d8d0bf; padding:10px 12px; border-radius:11px;
  background:rgba(255,255,255,.04); border-left:3px solid var(--acc); }
.ev-empty{ font-size:13px; color:var(--ink3); }
.ev-close{ display:block; width:100%; margin-top:14px; padding:13px; border:none; border-radius:12px;
  background:rgba(255,255,255,.06); color:var(--ink); font-weight:600; font-size:14px; cursor:pointer; }

/* ── концовка ── */
.ending{
  position:fixed; inset:0; z-index:200; display:none; flex-direction:column;
  align-items:center; justify-content:center; padding:28px; text-align:center;
  background:radial-gradient(80% 60% at 50% 28%,rgba(18,26,40,.65),rgba(4,7,12,.97));
}
.ending.show{ display:flex; animation:cfade .55s ease; }
@keyframes cfade{ from{opacity:0}to{opacity:1} }
.seal{ width:106px; height:106px; border-radius:50%; display:flex; align-items:center; justify-content:center;
  font-family:'Unbounded',sans-serif; font-weight:900; font-size:40px; margin-bottom:20px; border:3px solid;
  box-shadow:0 0 34px currentColor; animation:sealpop .5s cubic-bezier(.2,1.5,.4,1) both; }
@keyframes sealpop{ 0%{transform:scale(.3);opacity:0}100%{transform:scale(1);opacity:1} }
.seal.win{color:var(--ok)} .seal.partial{color:var(--acc-2)} .seal.fail{color:var(--no)}
.e-verdict{ font-family:'Unbounded',sans-serif; font-weight:900; font-size:25px; letter-spacing:.03em; margin-bottom:8px; }
.e-verdict.win{color:var(--ok)} .e-verdict.partial{color:var(--acc-2)} .e-verdict.fail{color:var(--no)}
.e-text{ font-size:14.5px; line-height:1.6; color:#d8d0bf; max-width:350px; margin-bottom:16px; }
.e-meta{ font-size:12px; color:var(--ink3); letter-spacing:.06em; margin-bottom:24px; }
.e-meta b{ color:var(--acc-2); }
.btn-ending{
  font-family:'Unbounded',sans-serif; font-weight:800; font-size:14px; letter-spacing:.04em;
  padding:15px 36px; border-radius:14px; border:none; cursor:pointer;
  background:linear-gradient(180deg,#ffdf95,var(--acc)); color:#241701;
  box-shadow:0 10px 26px rgba(200,134,10,.4);
}

/* ── логотип на сплэше и логине ── */
.sdvig-logo{ width:min(78%,340px); filter:drop-shadow(0 18px 40px rgba(0,0,0,.65)) drop-shadow(0 0 30px rgba(204,140,30,.26)); }
.login-logo{ width:min(68%,240px); margin-bottom:8px; filter:drop-shadow(0 12px 30px rgba(0,0,0,.6)) drop-shadow(0 0 20px rgba(204,140,30,.22)); }
"""

txt += carousel_css
with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
print("✓ card-design.css: стили карусели добавлены")
PYEOF


echo ""
echo "═══════════════════════════════════════════════════"
echo "✅  R10 готов"
echo "   git add -A && git commit -m 'R10: carousel integrated + blue flame + lock overlay' && git push"
echo "═══════════════════════════════════════════════════"
