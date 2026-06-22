window.SDVIG_BUILD='R56';console.log('%cСДВИГ '+window.SDVIG_BUILD,'color:#c8860a;font-weight:bold');
/* ═══════════════════════════════════════════════
   СДВИГ · app.js  v5 · Dark Glass
═══════════════════════════════════════════════ */
'use strict';

/* ── глобальное состояние ──────────────────────── */
const App = {
  user:null,
  guest:false,
  token:null,
  profile:null,
  scenario:null,
  deck:[],
  cardIndex:0,
  swipeUnlocked:false,
  currentCard:null,
  pendingSwipe:null,
  flags:{},
  tab:'cases'
};

const DEFAULT_PROFILE = {
  level:1, xp:0, energy:5, maxEnergy:5, credits:0, bucks:0,
  casesSolved:0, streak:0, prestige:0, mapNode:0, mapStars:{},
  skills:{ insight:1, tech:1, charisma:1, nerve:1 },
  achievements:[], dailyStreak:0, lastDaily:null, sound:true,
  lastEnergyTs:0, rapport:50, skill:30, gender:'m', genderChosen:false, onboarded:false
};

/* ── DOM helpers ───────────────────────────────── */
const $  = s=>document.querySelector(s);
const $$ = s=>Array.from(document.querySelectorAll(s));
const el = (tag,cls,html)=>{ const e=document.createElement(tag); if(cls)e.className=cls; if(html!=null)e.innerHTML=html; return e; };
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));
const vibrate=ms=>{ try{ navigator.vibrate&&navigator.vibrate(ms);}catch(e){} };

function lsGet(k,d){ try{ const v=localStorage.getItem(k); return v==null?d:JSON.parse(v);}catch(e){return d;} }
function lsSet(k,v){ try{ localStorage.setItem(k,JSON.stringify(v)); }catch(e){} }

/* ── экраны ────────────────────────────────────── */
function showScreen(id){
  $$('.screen').forEach(s=>s.classList.remove('active'));
  const t=$('#'+id); if(t) t.classList.add('active');
}

/* ── toast ─────────────────────────────────────── */
let toastTimer=null;
function toast(title,desc,icon){
  const t=$('#toast');
  $('#toast-icon').textContent=icon||'✦';
  $('#toast-title').textContent=title||'';
  $('#toast-desc').textContent=desc||'';
  t.classList.add('show');
  clearTimeout(toastTimer);
  toastTimer=setTimeout(()=>t.classList.remove('show'),2600);
}

function fatal(msg){
  $('#error-msg').textContent=msg||'Не удалось загрузить данные.';
  showScreen('error-screen');
}

/* ═══════════════════════════════════════════════
   SPLASH → кинематографичный переход → LOGIN
═══════════════════════════════════════════════ */
const SPLASH_BG = '/img/bg-splash.jpg';   // фон №1 (экран загрузки)
const LOGIN_BG  = '/img/bg-login.jpg';    // фон №2 (экран входа)

const wait = ms=>new Promise(r=>setTimeout(r,ms));

async function runSplash(){
  // фоны (если файлов нет — просто не покажутся, без ошибок)
  document.documentElement.style.setProperty('--splash-img',`url('${SPLASH_BG}')`);
  document.documentElement.style.setProperty('--login-img',`url('${LOGIN_BG}')`);

  const emblem=$('#splash-emblem');
  const titleRow=$('#splash-title');
  const fill=$('#splash-fill');
  const status=$('#splash-status');

  // буквы СДВИГ
  'СДВИГ'.split('').forEach(ch=>{ const s=el('span','title-letter',ch); titleRow.appendChild(s); });

  await wait(120);
  emblem.classList.add('visible');
  Sound.splashImpact();

  await wait(380);
  $$('.title-letter').forEach((l,i)=>setTimeout(()=>l.classList.add('in'),i*90));

  // прогресс загрузки — плавный, без «лагов»
  const steps=[
    [22,'Загрузка дел'],
    [48,'Сбор улик'],
    [74,'Калибровка'],
    [100,'Готово']
  ];
  for(const [w,txt] of steps){
    await wait(360);
    fill.style.width=w+'%';
    status.textContent=txt;
    if(w<100){ emblem.classList.add('pulse'); setTimeout(()=>emblem.classList.remove('pulse'),220); }
  }

  await wait(300);

  // параллельно грузим всё нужное, пока идёт переход
  const ready = preload();

  // кинематографичная вспышка + уход эмблемы (без explode)
  Sound.transition();
  const flash=$('#splash-flash');
  flash.style.transition='opacity .35s ease';
  flash.style.opacity='0.9';
  await wait(180);

  await ready.catch(()=>{});           // дождались данных
  decideEntry();                        // показываем login/main под вспышкой
  flash.style.opacity='0';
  await wait(380);
}

/* предзагрузка: профиль из кэша, сценарий */
async function preload(){
  await loadScenario().catch(()=>{});
}

/* куда заходим после сплэша */
function decideEntry(){
  // 1) Telegram Mini App
  const tg = window.Telegram && window.Telegram.WebApp;
  if(tg && tg.initData && tg.initData.length>0){
    tg.ready(); tg.expand();
    return tgWebAppLogin(tg);
  }
  // 2) сохранённая сессия
  const saved=lsGet('sdvig_session',null);
  if(saved && saved.profile){
    App.user=saved.user||null; App.guest=!!saved.guest; App.token=saved.token||null;
    App.profile=normalizeProfile(saved.profile);
    enterMain(); return;
  }
  // 3) экран входа
  showScreen('login-screen');
  initLogin();
}

/* ═══════════════════════════════════════════════
   AUTH (Вариант A: Telegram Mini App + гость)
═══════════════════════════════════════════════ */
async function tgWebAppLogin(tg){
  showScreen('login-screen');
  $('#tg-status').textContent='Вход через Telegram…';
  try{
    const res=await fetch('/api/auth/webapp',{
      method:'POST',headers:{'Content-Type':'application/json'},
      body:JSON.stringify({ initData: tg.initData })
    });
    if(!res.ok) throw new Error('auth '+res.status);
    const data=await res.json();
    App.user=data.user; App.token=data.token; App.guest=false;
    App.profile=normalizeProfile(data.profile);
    persistSession();
    enterMain();
  }catch(e){
    // не вышло — даём гостя, чтобы не блокировать
    $('#tg-status').textContent='Telegram недоступен — используйте гостевой вход';
    initLogin();
  }
}

function initLogin(){
  const status=$('#tg-status');
  const gb=$('#guest-btn');
  // ГОСТЬ — всегда рабочий
  if(gb){ gb.style.pointerEvents='auto'; gb.disabled=false;
    gb.onclick=()=>{ Sound.tap(); guestLogin(); }; }

  // Telegram Login Widget для обычного браузера
  const BOT = window.SDVIG_BOT_USERNAME || '';   // имя бота без @
  const area=$('#tg-widget-area');
  if(area && BOT){
    status.textContent='';
    const sc=document.createElement('script');
    sc.src='https://telegram.org/js/telegram-widget.js?22';
    sc.async=true;
    sc.setAttribute('data-telegram-login',BOT);
    sc.setAttribute('data-size','large');
    sc.setAttribute('data-radius','12');
    sc.setAttribute('data-request-access','write');
    sc.setAttribute('data-onauth','onTelegramAuth(user)');
    area.innerHTML=''; area.appendChild(sc);
  } else {
    status.textContent='Войдите через Telegram (в приложении) или как гость.';
  }
}

// callback от Telegram Login Widget (браузер)
window.onTelegramAuth=function(user){
  fetch('/api/auth/widget',{method:'POST',headers:{'Content-Type':'application/json'},
    body:JSON.stringify(user)})
    .then(r=>{ if(!r.ok) throw 0; return r.json(); })
    .then(data=>{ App.user=data.user; App.token=data.token; App.guest=false;
      App.profile=normalizeProfile(data.profile); persistSession(); enterMain(); })
    .catch(()=>{ toast('Ошибка входа','Попробуйте как гость','✗'); });
};

function guestLogin(){
  App.guest=true; App.user={ id:'guest', name:'Гость', firstName:'Гость' };
  App.token=null;
  // профиль из кэша или новый
  const cached=lsGet('sdvig_guest_profile',null);
  App.profile=normalizeProfile(cached||{...DEFAULT_PROFILE});
  persistSession();
  enterMain();
}

function normalizeProfile(p){
  const n={...DEFAULT_PROFILE,...(p||{})};
  n.skills={...DEFAULT_PROFILE.skills,...(p&&p.skills||{})};
  n.achievements=Array.isArray(p&&p.achievements)?p.achievements:[];
  return n;
}

function persistSession(){
  const sess={ user:App.user, guest:App.guest, token:App.token, profile:App.profile };
  lsSet('sdvig_session',sess);
  if(App.guest) lsSet('sdvig_guest_profile',App.profile);
}

/* сохранение профиля (сервер для авторизованных, локально для гостя) */
let saveTimer=null;
function saveProfile(){
  persistSession();
  if(App.guest||!App.token) return;
  clearTimeout(saveTimer);
  saveTimer=setTimeout(()=>{
    fetch('/api/profile',{
      method:'PUT',
      headers:{'Content-Type':'application/json','Authorization':'Bearer '+App.token},
      body:JSON.stringify(App.profile)
    }).catch(()=>{});
  },800);
}

/* ═══════════════════════════════════════════════
   ВХОД В ИГРУ
═══════════════════════════════════════════════ */
function enterMain(){
  try{ updateScaleBars(); }catch(_){}
  showScreen('main-screen');
  // навигацию и звук вешаем ПЕРВЫМИ — чтобы ошибка в рендере не убила меню
  bindNav();
  bindSoundBtn();
  bindTools();
  if(window.BgFx) BgFx.init();
  try{installSceneParallax();}catch(_){}
  Icons.paint();
  try{ if(window.Feed){ initCarousel_data(); Feed.init(); } else { initCarousel(); } }catch(e){ console.error('feed init',e); try{initCarousel();}catch(_){} }
  try{ Sound.ambientOn(); }catch(_){}
  try{ regenEnergy(); if(!App._energyTimer) App._energyTimer=setInterval(regenEnergy,60*1000); }catch(_){}
  try{ renderHUD(); }catch(e){ console.error('renderHUD',e); }
  try{ renderGameList(); }catch(e){ console.error('renderGameList',e); }
  try{ renderProfile(); }catch(e){ console.error('renderProfile',e); }
  try{ renderShop(); }catch(e){ console.error('renderShop',e); }
  try{ checkDaily(); }catch(e){ console.error('checkDaily',e); }
}

/* ── навигация ─────────────────────────────────── */
function bindNav(){
  const nav=document.querySelector('.bottom-nav');
  if(!nav || nav.dataset.bound) return;
  nav.dataset.bound='1';
  nav.addEventListener('click',e=>{
    const b=e.target.closest('.nb'); if(!b) return;
    const tab=b.dataset.tab; if(!tab || tab===App.tab) return;
    try{ if(window.Dialogue && Dialogue.isActive()) Dialogue.skip(); }catch(_){}
    try{ Sound.nav(); }catch(_){}
    vibrate(8);
    App.tab=tab;
    document.querySelectorAll('.nb').forEach(x=>x.classList.toggle('active',x===b));
    document.querySelectorAll('.tab-pane').forEach(p=>p.classList.toggle('active',p.id==='tab-'+tab));
    if(tab==='map') requestAnimationFrame(()=>{ try{renderMap();}catch(_){} });
    if(tab==='profile') try{renderProfile();}catch(_){}
  });
}

function bindSoundBtn(){
  const btn=$('#sound-btn');
  if(!btn) return;
  btn.textContent=Sound.isOn()?'🔊':'🔇';
  btn.onclick=()=>{ const on=Sound.toggle(); btn.textContent=on?'🔊':'🔇'; if(on)Sound.tap(); };
}

function bindTools(){
  const bar=document.querySelector('.tools-bar');
  if(!bar || bar.dataset.bound) return;
  bar.dataset.bound='1';
  App.profile.tools = App.profile.tools || {magnify:2,file:1,hourglass:1};
  refreshTools();
  bar.addEventListener('click',e=>{
    const b=e.target.closest('.tool-btn'); if(!b) return;
    const t=b.dataset.tool;
    vibrate(8); try{Sound.tap();}catch(_){}
    if(t==='shop'){ App.tab='shop';
      document.querySelectorAll('.nb').forEach(x=>x.classList.toggle('active',x.dataset.tab==='shop'));
      document.querySelectorAll('.tab-pane').forEach(p=>p.classList.toggle('active',p.id==='tab-shop'));
      return; }
    useTool(t);
  });
}
function refreshTools(){
  const T=(App.profile&&App.profile.tools)||{};
  ['magnify','file','hourglass'].forEach(k=>{
    const el=$('#tool-'+k+'-n'); if(el){ const n=T[k]||0; el.textContent=n; el.style.display=n>0?'':'none'; }
  });
}
function useTool(t){
  const T=App.profile.tools||(App.profile.tools={});
  if((T[t]||0)<=0){ toast('Инструменты','Нет в наличии — загляни в Лавку','🛠️'); return; }
  if(t==='hourglass'){ T[t]--; addEnergy(20); toast('Песочные часы','+20 энергии','⏳'); }
  else if(t==='magnify'){ T[t]--; App.flags.hintNext=true; toast('Лупа','Подсказка активна','🔍'); }
  else if(t==='file'){ T[t]--; unlockSwipe(); toast('Досье','Свайп разблокирован','📁'); }
  refreshTools(); saveProfile();
}

/* ── HUD ───────────────────────────────────────── */
function paintGems(){
  try{ document.querySelectorAll("[data-gem]").forEach(function(elx){
    if(elx._painted) return; var k=elx.getAttribute("data-gem");
    if(window.GEM_SVG&&GEM_SVG[k]){ elx.innerHTML=GEM_SVG[k]; elx._painted=true; }
  }); }catch(e){}
}
function renderHUD(){
  setTimeout(paintGems,0);
  const p=App.profile;
  const en=$('#hud-energy'); if(en) en.textContent=p.energy;
  const cr=$('#hud-credits'); if(cr) cr.textContent=p.credits;
  const bk=$('#hud-bucks'); if(bk) bk.textContent=p.bucks||0;
  const need=xpNeeded(p.level);
  const xf=$('#xp-fill'); if(xf) xf.style.width=clamp(p.xp/need*100,0,100)+'%';
  const xi=$('#xp-info'); if(xi) xi.textContent=`УР ${p.level} · ${p.xp}/${need}`;
}
function xpNeeded(lvl){ return 100+(lvl-1)*60; }

function addXP(n){
  const p=App.profile; p.xp+=n;
  let need=xpNeeded(p.level), leveled=false;
  while(p.xp>=need){ p.xp-=need; p.level++; leveled=true; need=xpNeeded(p.level); }
  if(leveled){ Sound.levelUp(); vibrate([10,40,10]);
    toast('Новый уровень','Уровень '+p.level,'⬆️');
    p.maxEnergy=5+Math.floor((p.level-1)/3); p.energy=p.maxEnergy; }
  renderHUD(); saveProfile();
}
function addCredits(n){ App.profile.credits=Math.max(0,App.profile.credits+n); if(n>0)Sound.coin(); renderHUD(); saveProfile(); }
const ENERGY_MS=30*60*1000; /* 30 мин на 1 кофе */
function regenEnergy(){
  const p=App.profile; if(!p) return;
  if(!p.lastEnergyTs){ p.lastEnergyTs=Date.now(); return; }
  if(p.energy>=p.maxEnergy){ p.lastEnergyTs=Date.now(); return; }
  const elapsed=Date.now()-p.lastEnergyTs;
  const gained=Math.floor(elapsed/ENERGY_MS);
  if(gained>0){
    p.energy=clamp(p.energy+gained,0,p.maxEnergy);
    p.lastEnergyTs+=gained*ENERGY_MS;
    if(p.energy>=p.maxEnergy)p.lastEnergyTs=Date.now();
    renderHUD(); saveProfile();
  }
}
function energyMsLeft(){
  const p=App.profile; if(!p||p.energy>=p.maxEnergy) return 0;
  return ENERGY_MS-((Date.now()-(p.lastEnergyTs||Date.now()))%ENERGY_MS);
}
function addBucks(n){ const p=App.profile; p.bucks=Math.max(0,(p.bucks||0)+n); renderHUD(); saveProfile(); }
function addEnergy(n){ const p=App.profile; p.energy=clamp(p.energy+n,0,p.maxEnergy); renderHUD(); saveProfile(); }

/* ═══════════════════════════════════════════════
   BOOT
═══════════════════════════════════════════════ */
window.addEventListener('DOMContentLoaded',()=>{
  $('#sound-btn'); // noop
  runSplash().catch(err=>{ console.error(err); decideEntry(); });
});

/* ═══════════════════════════════════════════════
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
let CASE=null,CAMPAIGN=null,_caseIdx=0;
(function(){
  function xhrJson(u){try{var x=new XMLHttpRequest();x.open("GET",u,false);x.send();if(x.status===200)return JSON.parse(x.responseText);}catch(e){}return null;}
  CAMPAIGN=xhrJson("/scenarios/campaign.json");
  if(!CAMPAIGN)CAMPAIGN={cases:[{id:"case001"}]};
  try{var s=localStorage.getItem("sdvig_case");if(s&&CAMPAIGN){var i=CAMPAIGN.cases.findIndex(function(c){return c.id===s;});if(i>=0)_caseIdx=i;}}catch(e){}
  loadCaseByIndex(_caseIdx);
})();
function loadCaseByIndex(i){
  if(!CAMPAIGN||i>=CAMPAIGN.cases.length)return;
  _caseIdx=i; var cid=CAMPAIGN.cases[i].id;
  try{var x=new XMLHttpRequest();x.open("GET","/scenarios/"+cid+".json",false);
    x.send();if(x.status===200){CASE=JSON.parse(x.responseText);
      try{Object.keys(CASE.events).forEach(function(k){CASE.events[k]._id=k;});}catch(_){}}
    localStorage.setItem("sdvig_case",cid); try{updateCaseBg();hideChar();}catch(_){};}catch(e){}
  if(!CASE){CASE={name:"...",truth:{},start:"e0",total:1,events:{e0:{t:"crime",badge:"...",title:"...",text:"Ошибка загрузки.",left:{label:"...",to:"__resolve__"},right:{label:"...",to:"__resolve__"}}}};}
}

function fill(text,f){
  if(text.indexOf("@T@")<0) return text;
  const pre=f.time==="day"?"Версия дня обретает вес. ":"Следов ночного входа всё меньше. ";
  return pre+text.replace("@T@","").trim();
}
function computeEnding(f){
  const t=CASE.truth;
  const keys=Object.keys(t);
  const align=keys.filter(function(k){return f[k]===t[k];}).length;
  const e=CASE.endings||{};
  var p=App.profile||{};
  var rap=clamp(p.rapport||0,0,100), det=clamp(p.skill||30,0,100);
  // базовая концовка по сходимости версий
  var base;
  if(align===keys.length&&e.win)  base=Object.assign({},e.win,{align:align});
  else if(align>=Math.ceil(keys.length/2)&&e.partial) base=Object.assign({},e.partial,{align:align});
  else base=Object.assign({},e.fail||{mark:'✗',verdict:'ПРОВАЛ',text:'Сдвиг промолчал.'},{align:align,kind:'fail'});
  // шкалы добавляют эпилог-оттенок (задел на сквозную драму)
  base.rap=rap; base.det=det;
  if(base.kind==='win'){
    if(rap>=60 && det>=60) base.epilogue='Сдвиг хлопнул тебя по плечу. «Напарник». Впервые это слово прозвучало всерьёз.';
    else if(det>=60 && rap<40) base.epilogue='Ты раскрыл дело блестяще. Но Сдвиг смотрел на тебя холодно — машина, а не человек. «Берегись, рекрут. Лёд трескается изнутри».';
    else if(rap>=60 && det<40) base.epilogue='«Голова у тебя ещё сырая, но сердце на месте, — буркнул Сдвиг. — С этим можно работать».';
  }
  return base;
}
function haptic(kind){
  try{if(window.Telegram&&Telegram.WebApp&&Telegram.WebApp.HapticFeedback){
    if(kind==="shift")Telegram.WebApp.HapticFeedback.notificationOccurred("warning");
    else if(kind==="burn")Telegram.WebApp.HapticFeedback.impactOccurred("heavy");
    else Telegram.WebApp.HapticFeedback.impactOccurred("medium");return;}}catch(e){}
  try{navigator.vibrate&&navigator.vibrate(kind==="shift"?[14,40,14,40,30]:kind==="burn"?[10,30,60]:14);}catch(e){}
}

/* ════ КОЛЬЦО ════ */
const CState={ev:CASE.start,flags:{},evidence:[],clues:[],step:0};
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
function backHTML(){return gframeHTML()+'<div class="cback-emblem"></div>';}
function cardHTML(ev){
  const scene='<div class="scene"><div class="grad"></div><div class="art" style="background-image:'+artBg(ev.t)+'"></div></div>';
  if(ev.linear){
    return gframeHTML()+scene+'<div class="pad">'
      +'<span class="badge">'+ev.badge+'</span>'
      +'<div class="title">'+ev.title+'</div>'
      +'<div class="text scrollable">'+fill(ev.text,CState.flags)+'</div>'
      +((ev.dialogue&&!ev.speaker)?'<div class="dlg">'+ev.dialogue.replace(/\n/g,'<br>')+'</div>':'')
      +'<div class="spacer"></div>'
      +'<button class="linear-next">Далее \u2192</button>'
      +'</div>';
  }
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
    +'<div class="text scrollable">'+fill(ev.text,CState.flags)+'</div>'
    +((ev.dialogue&&!ev.speaker)?'<div class="dlg">'+ev.dialogue.replace(/\n/g,'<br>')+'</div>':'')
    +'<div class="spacer"></div><div class="choices">'
    +'<div class="choice l"><span class="dir">СВАЙП ВЛЕВО</span>'+ev.left.label+'</div>'
    +'<div class="choice r"><span class="dir">СВАЙП ВПРАВО</span>'+ev.right.label+'</div>'
    +'</div></div>';
}
function setBack(el){el.classList.remove("active","shift","grab","burning");el._ev=null;
  el.innerHTML='<div class="cfinner">'+backHTML()+'</div>';}
function setActive(el,ev){
  el.classList.add("active"); el.classList.toggle("shift",!!ev.shift);
  if(ev&&ev.shift){ try{Sound.special();}catch(_){} }
  el.classList.toggle("linear",!!ev.linear);
  el.innerHTML='<div class="cfinner">'+cardHTML(ev)+'</div>'; el._ev=ev; cActive=el;
  App.currentCard=ev; App.swipeUnlocked=false;
  if(ev&&ev._id){ CState.ev=ev._id; }
  /* речь обрабатывается диалоговой системой (R32) */
  if(ev.linear){
    var btn=el.querySelector('.linear-next');
    if(btn) btn.addEventListener('click',function(){ try{Sound.tap();}catch(_){} linearAdvance(ev); });
    App.swipeUnlocked=false;
  } else {
    addLockOverlay(el);
  }
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
  var _saved=loadCaseState();
  var _startEv=(_saved&&_saved.ev)?_saved.ev:CASE.start;
  if(_saved){ CState.ev=_saved.ev; CState.flags=_saved.flags||{}; CState.evidence=_saved.evidence||[]; CState.clues=_saved.clues||[]; CState.step=_saved.step||0;
    if(_evCountEl)_evCountEl.textContent=(CState.clues?CState.clues.length:0); cSetProgress();
    if(window.toast) toast('Дело продолжается','Ты вернулся туда, где остановился.','\ud83d\udcc2'); }
  cfCards.forEach(function(c,e){
    if(e===centerIndex) setActive(c,CASE.events[_startEv]); else setBack(c);
  });
  cLayout(false);
  try{ Sound.tape(); }catch(_){}
}

/* ── мини-игра: блокировка свайпа ── */
function missionFor(ev){
  if(ev && ev.mission) return ev.mission;
  /* генерация по типу события, если в сценарии не задано */
  const t=(ev&&ev.t)||'evidence';
  const M={
    crime:    {type:'score', target:700, moves:16, label:'Собери 700 очков — осмотри сцену'},
    evidence: {type:'clear', target:16, moves:18, label:'Очисти 16 ячеек — найди улику'},
    witness:  {type:'color', color:0, target:12, moves:16, label:'Собери 12 красных — разговори свидетеля'},
    suspect:  {type:'combo', target:3, moves:15, label:'Сделай 3 комбо — дожми подозреваемого'},
    revelation:{type:'score',target:900, moves:18, label:'Собери 900 очков — собери факты'},
    final:    {type:'score', target:1200,moves:20, label:'Собери 1200 очков — назови имя'}
  };
  return M[t]||M.evidence;
}
function addLockOverlay(cardEl){
  const pad=cardEl.querySelector('.pad'); if(!pad) return;
  if(pad.querySelector('.card-lock')) return;
  const _ch=pad.querySelector('.choices'); if(_ch) _ch.style.display='none';
  const lock=document.createElement('div'); lock.className='card-lock';
  const _rp=(window.App&&App.profile&&App.profile.rapport)||0;
  const _rt=(window.App&&App.profile)?rapportTitle():'Новичок';
  const _ev=App.currentCard||{};
  const _hints={
    crime:"Ищи то, чего быть не должно.",
    evidence:"Одна улика всегда важнее остальных.",
    witness:"Люди врут, но тело не умеет.",
    suspect:"Виновный всегда спокойнее, чем должен быть.",
    shift:"Обе версии верны — выбери ту, где меньше случайностей.",
    final:"Ты уже знаешь. Просто доверься себе.",
    revelation:"Детали складываются в одно."
  };
  const _hint=_rp>=6?(_hints[_ev.t]||""):""; 
  lock.innerHTML='<button class="card-lock-btn" id="play-gems-ring">'
    +'<span class="clb-ico">🔍</span><span>Найти улики</span></button>'
    +(_hint?'<div class="card-rapport-hint"><span class="crh-name">Сдвиг</span> '+_hint+'</div>':'')
    +'<div class="card-lock-hint">⟵ свайп заблокирован ⟶</div>';
  pad.appendChild(lock);
  lock.querySelector('#play-gems-ring').addEventListener('click',function(){
    try{Sound.tap();}catch(_){} openHintGame(App.currentCard||{});
  });
  try{ onbMaybeStart(); }catch(_){}
}
function showNoEnergy(){
  try{haptic('shift');}catch(_){}
  const mins=Math.ceil(energyMsLeft()/60000);
  if(window.toast) toast('Термос пуст','Сдвиг: «Без кофе ты проспишь улику». +1 \u2615 через '+mins+' мин','\u2615');
  const tab=document.getElementById('tab-cases');
  if(tab){ var b=document.createElement('div'); b.className='noenergy-flash'; tab.appendChild(b); setTimeout(function(){b.remove();},900); }
}
function unlockSwipe(){
  App.swipeUnlocked=true;
  vibrate(20); try{Sound.booster();}catch(_){}
  try{removeLockOverlay();}catch(_){}
  var _goDecision=function(){
    // показываем реакцию персонажей на находку (если есть), потом решение
    if(window._pendingReact && window.Feed && Feed.pushReaction){
      var rc=window._pendingReact; window._pendingReact=null;
      Feed.pushReaction(rc, function(){
        if(window.Feed){ try{ Feed.enterDecision(); }catch(_){} } else { try{ startDecisionMode(); }catch(_){} }
      });
      return;
    }
    if(window.Feed){ try{ Feed.enterDecision(); }catch(_){} }
    else { try{ startDecisionMode(); }catch(_){} }
  };
  if(window._pendingClue){
    // показываем улику, а карту решения — ТОЛЬКО после её закрытия
    window._afterClue=_goDecision;
    try{ grantClue(window._pendingClue); }catch(_){ _goDecision(); }
    window._pendingClue=null;
  } else {
    _goDecision();
  }
}

var _decTimer=null,_decLeft=0;
function startDecisionMode(){
  var ev=App.currentCard; if(!ev||ev.linear) return;
  /* карта по центру + тряска */
  var st=document.getElementById('stage'); if(st)st.classList.add('decision-mode');
  if(cActive)cActive.classList.add('decision');
  /* корни-исходы по бокам */
  showOutcomeRoots(ev);
  /* таймер на решение */
  _decLeft=15; var dt=document.getElementById('decision-timer');
  var fg=document.getElementById('dt-fg'); var num=document.getElementById('dt-num');
  var R=22, C=2*Math.PI*R;
  if(fg){ fg.style.strokeDasharray=C; fg.style.strokeDashoffset=0; }
  if(dt){ dt.classList.add('show'); dt.classList.remove('urgent'); }
  if(num) num.textContent=_decLeft;
  clearInterval(_decTimer);
  var total=15;
  _decTimer=setInterval(function(){
    _decLeft--;
    if(num) num.textContent=Math.max(0,_decLeft);
    if(fg){ var frac=_decLeft/total; fg.style.strokeDashoffset=C*(1-frac); }
    if(_decLeft<=5 && dt){ dt.classList.add('urgent'); try{Sound.tap&&Sound.tap();}catch(_){} }
    if(_decLeft<=0){ clearInterval(_decTimer); onDecisionTimeout(); }
  },1000);
}
function endDecisionMode(){
  clearInterval(_decTimer);
  var st=document.getElementById('stage'); if(st)st.classList.remove('decision-mode');
  if(cActive)cActive.classList.remove('decision');
  var dt=document.getElementById('decision-timer'); if(dt)dt.classList.remove('show');
  var or=document.getElementById('outcome-roots'); if(or)or.classList.remove('show');
}
function onDecisionTimeout(){
  /* время вышло — Сдвиг подгоняет, но не штрафуем жёстко */
  if(window.toast) toast('Время уходит','Сдвиг: «Решай, рекрут. Промедление — тоже выбор».','\u23f1');
  var dt=document.getElementById('decision-timer');
  if(dt){ var num=document.getElementById('dt-num'); if(num)num.textContent='!'; }
}
function showOutcomeRoots(ev){
  var or=document.getElementById('outcome-roots'); var svg=document.getElementById('roots-svg');
  if(!or||!svg) return;
  var lLabel=(ev.left&&ev.left.label)?ev.left.label.replace(/^◄\s*/,''):'влево';
  var rLabel=(ev.right&&ev.right.label)?ev.right.label.replace(/\s*►$/,''):'вправо';
  if(ev.shift){ lLabel=(ev.a&&ev.a.label||'').replace(/^◄\s*/,''); rLabel=(ev.b&&ev.b.label||'').replace(/\s*►$/,''); }
  /* рисуем ветвящиеся корни от центра к краям */
  svg.innerHTML=
    '<path class="or-path or-left" d="M50 50 Q 30 48 20 40 T 4 30"/>'+
    '<path class="or-path or-left" d="M50 50 Q 32 54 22 58 T 6 66"/>'+
    '<path class="or-path or-right" d="M50 50 Q 70 48 80 40 T 96 30"/>'+
    '<path class="or-path or-right" d="M50 50 Q 68 54 78 58 T 94 66"/>'+
    '<text class="or-label left" x="3" y="26">'+esc(lLabel)+'</text>'+
    '<text class="or-label right" x="60" y="26">'+esc(rLabel)+'</text>';
  or.classList.add('show');
}
function esc(s){ return (s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
function removeLockOverlay(){
  const lock=document.querySelector('.cfcard.active .card-lock');
  if(!lock) return;
  const _p=lock.closest('.pad'); lock.remove();
  if(_p){const _c=_p.querySelector('.choices');if(_c) _c.style.display='';}
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

function linearAdvance(ev){
  if(cBusy) return; cBusy=true;
  var nextId=ev.next;
  var c0=cfCards[centerIndex];
  CState.step++; cSetProgress();
  // лёгкий поворот кольца вперёд, без огня
  centerIndex=(centerIndex+1+CN)%CN;
  var resolve=(nextId==='__resolve__'||!nextId);
  if(!resolve){ CState.ev=nextId; setActive(cfCards[centerIndex],CASE.events[nextId]); saveCaseState(); }
  cLayout(true);
  setTimeout(function(){
    if(resolve) showEnding(computeEnding(CState.flags));
    else if(c0!==cfCards[centerIndex]) setBack(c0);
    cBusy=false;
  }, Math.max(560,SPIN_DUR+40));
}
function cAdvance(dir,ev,opt){
  if(cBusy) return; cBusy=true;
  try{endDecisionMode();}catch(_){}
  cApplyOption(opt);
  const c0=cfCards[centerIndex]; c0.onpointerdown=null;
  function turn(){
    centerIndex=(centerIndex+(dir==="left"?1:-1)+CN)%CN;
    CState.step++; cSetProgress();
    const resolve=(opt.to==="__resolve__");
    if(!resolve){ CState.ev=opt.to; setActive(cfCards[centerIndex],CASE.events[opt.to]); saveCaseState(); }
    cLayout(true);
    setTimeout(function(){
      if(resolve) showEnding(computeEnding(CState.flags));
      else if(c0!==cfCards[centerIndex]) setBack(c0);
      SPIN_DUR=640; cBusy=false;
    },resolve?520:Math.max(580,SPIN_DUR+40));
  }
  try{Sound.burn(); Sound.swipe(dir);}catch(_){}
  if(dir==="left"){ burnCard(c0,"left",function(){setBack(c0);turn();}); }
  else { burnCardBlue(c0,"right",function(){setBack(c0);turn();}); }
}

function grantClue(clue){
  if(!clue||!clue.id){ var cb0=window._afterClue; window._afterClue=null; if(cb0)cb0(); return; }
  if(!CState.clues) CState.clues=[];
  if(CState.clues.some(function(c){return c.id===clue.id;})){
    // улика уже есть — НЕ показываем повторно, но игру ПРОДОЛЖАЕМ
    var cb=window._afterClue; window._afterClue=null; if(cb)cb(); return;
  }
  CState.clues.push(clue);
  if(_evCountEl) _evCountEl.textContent=CState.clues.length;
  try{ var _ec=document.getElementById('ev-count'); if(_ec)_ec.textContent=CState.clues.length; }catch(_){}
  try{ showClueReveal(clue, window._afterClue||null); window._afterClue=null; }catch(_){}
  try{ saveCaseState&&saveCaseState(); }catch(_){}
}
function showClueReveal(clue, onClose){
  // эффектная выдача: улика «ложится» в досье
  var ov=document.createElement('div'); ov.className='clue-reveal';
  ov.innerHTML='<div class="cr-card">'+
    '<div class="cr-ico">'+(clue.icon||'🔍')+'</div>'+
    '<div class="cr-label">УЛИКА НАЙДЕНА</div>'+
    '<div class="cr-name">'+esc(clue.name||'')+'</div>'+
    '<div class="cr-proof">'+esc(clue.proof||'')+'</div>'+
    '<div class="cr-hint">▸ в досье</div>'+
  '</div>';
  document.body.appendChild(ov);
  try{ Sound.approve&&Sound.approve(); vibrate&&vibrate([10,40,10]); }catch(_){}
  requestAnimationFrame(function(){ ov.classList.add('show'); });
  var _closed=false;
  function _close(){ if(_closed)return; _closed=true; ov.classList.add('tofile');
    setTimeout(function(){ if(ov.parentNode)ov.parentNode.removeChild(ov); if(onClose)onClose(); },600); }
  ov.onclick=_close;
  setTimeout(_close, 3000);
}
function cAddEvidence(t){
  if(t&&CState.evidence.indexOf(t)<0){ CState.evidence.push(t); try{Sound.approve();}catch(_){} }
  if(_evCountEl) _evCountEl.textContent=CState.evidence.length;
  addXP(10);
}
function cSetProgress(){
  const p=Math.min(100,Math.round(CState.step/CASE.total*100));
  if(_progEl) _progEl.style.width=p+"%";
}
function addRapport(n){
  const p=App.profile; if(!p) return;
  p.rapport=clamp((p.rapport||0)+n,0,100); saveProfile();
  try{ updateScaleBars&&updateScaleBars(); scalePop&&scalePop('rap',n); }catch(_){}
}
var _migrateRapport=(function(){
  try{ var p=App.profile; if(p && (p.rapport===0||p.rapport===undefined) && !p._rapMigrated){ p.rapport=50; p._rapMigrated=true; saveProfile(); } }catch(_){}
})();
function updateScaleBars(){
  var p=App.profile; if(!p) return;
  var rap=clamp(p.rapport||0,0,100), det=clamp(p.skill||30,0,100);
  var rn=document.getElementById('rap-num'), rf=document.getElementById('rap-fill'), rs=document.getElementById('rap-stat');
  var dn=document.getElementById('det-num'), df=document.getElementById('det-fill'), ds=document.getElementById('det-stat');
  if(rn)rn.textContent=rap; if(rf)rf.style.width=rap+'%'; if(rs)rs.textContent=rapTitle(rap);
  if(dn)dn.textContent=det; if(df)df.style.width=det+'%'; if(ds)ds.textContent=detTitle(det);
}
function rapTitle(v){
  if(v>=95)return'Брат'; if(v>=80)return'Свой'; if(v>=60)return'Доверяет';
  if(v>=40)return'Напарник'; if(v>=20)return'Терпит'; return'Чужак';
}
function detTitle(v){
  if(v>=95)return'Легенда'; if(v>=80)return'Профи'; if(v>=60)return'Детектив';
  if(v>=40)return'Сыщик'; if(v>=20)return'Стажёр'; return'Новичок';
}
function scalePop(which,delta){
  var el=document.getElementById(which+'-pop'); if(!el)return;
  el.textContent=(delta>0?'+':'')+delta;
  el.style.color=delta>0?(which==='rap'?'#ff8fb0':'#46d89b'):'#ff5d6c';
  el.classList.remove('show'); void el.offsetWidth; el.classList.add('show');
}
function rapportTitle(){
  const r=(App.profile&&App.profile.rapport)||0;
  if(r>=12) return 'Напарник';
  if(r>=6)  return 'Доверие';
  if(r>=1)  return 'Интерес';
  if(r<=-3) return 'Раздражение';
  return 'Новичок';
}
function applyChoiceStats(o){
  if(!o) return;
  if(typeof o.dscore==='number'){ addSkill(o.dscore); }
  if(typeof o.rapport==='number'){ addRapport(o.rapport); }
}
function addSkill(n){
  var p=App.profile; p.skill=clamp((p.skill||30)+n,0,100); saveProfile();
  try{ updateScaleBars&&updateScaleBars(); scalePop&&scalePop('det',n); }catch(_){}
}
function cApplyOption(o){
  if(o.set) Object.assign(CState.flags,o.set);
  if(o.evidence) cAddEvidence(o.evidence);
  if(o.clue && window.grantClue){ try{ grantClue(o.clue); }catch(_){} }
  // шкалы: dscore (детективность) + rapport из выбора
  try{ applyChoiceStats(o); }catch(_){}
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
    /* энергия: 1 свайп = 1 кофе */
    const p=App.profile;
    if(p && p.energy<=0){ snap(); showNoEnergy(); return; }
    if(p){ p.energy=clamp(p.energy-1,0,p.maxEnergy); if(!p.lastEnergyTs)p.lastEnergyTs=Date.now(); renderHUD(); saveProfile(); }
    const sp=Math.min(1,Math.abs(vx)/3800); SPIN_DUR=Math.round(660-sp*160);
    cAdvance(side,ev,opt);}
  card.addEventListener("pointerdown",function(e){if(!down(e.clientX,e.clientY,e.pointerId))return;
    try{card.setPointerCapture(e.pointerId);}catch(_){}});
  card.addEventListener("pointermove",function(e){if(pid!=null&&e.pointerId!==pid)return;move(e.clientX,e.clientY);});
  card.addEventListener("pointerup",function(e){if(pid!=null&&e.pointerId!==pid)return;up();try{card.releasePointerCapture(e.pointerId);}catch(_){}});
  card.addEventListener("pointercancel",function(e){if(drag){drag=false;card.classList.remove("grab");snap();}});
}

function _scaleWarning(r){
  // предупреждение при низких шкалах (драматический задел)
  var msg=null;
  if((r.rap||50)<25) msg='Сдвиг задержался у двери. «Ты хорош, рекрут. Слишком хорош, чтобы слушать. Смотри, не останься один». — Отношения на грани. Если упадут ещё — он уйдёт.';
  else if((r.det||30)<25) msg='«Ты идёшь за мной, как тень, — сказал Сдвиг. — А тень не раскрывает дел. Учись думать сам». — Детективность слишком низкая.';
  if(msg){
    setTimeout(function(){ try{ toast('Предупреждение', msg, '⚠'); }catch(_){} }, 2600);
  }
}
function showEnding(r){
  const endEl=document.getElementById("ending");if(!endEl)return;
  const seal=document.getElementById("e-seal");if(seal){seal.className="seal "+r.kind;seal.textContent=r.mark;}
  const ver=document.getElementById("e-verdict");if(ver){ver.className="e-verdict "+r.kind;ver.textContent=r.verdict;}
  const txt=document.getElementById("e-text");if(txt)txt.textContent=r.text;
  const meta=document.getElementById("e-meta");if(meta){
    var _rt=(typeof rapTitle==='function')?rapTitle(r.rap||0):'';
    var _dt=(typeof detTitle==='function')?detTitle(r.det||0):'';
    meta.innerHTML="Сходимость: <b>"+r.align+" / 3</b> · 🎩 Сдвиг: <b style='color:#ff8fb0'>"+(r.rap||0)+" "+_rt+"</b> · 🔍 Детектив: <b style='color:#46d89b'>"+(r.det||0)+" "+_dt+"</b>";
  }
  // эпилог-оттенок от шкал
  if(r.epilogue){
    var _te=document.getElementById("e-text");
    if(_te) _te.textContent=(r.text||'')+"\n\n"+r.epilogue;
  }
  if(_progEl)_progEl.style.width="100%";
  haptic(r.kind==="fail"?"shift":"burn"); endEl.classList.add("show"); try{ _scaleWarning(r); }catch(_){} try{hideChar();}catch(_){} try{hideChar();}catch(_){}
  const _rb=document.getElementById("e-restart");
  if(_rb){
    const _hn=CAMPAIGN&&(_caseIdx+1)<CAMPAIGN.cases.length;
    _rb.textContent=_hn?"Следующее дело →":"Играть заново";
  }
  if(r.kind==="win"){
    try{addXP(150);addCredits(100);vibrate([20,40,80]);}catch(_){}
    try{ advanceMap(); App.profile.casesSolved=(App.profile.casesSolved||0)+1;
      const st=r.align>=3?3:r.align>=2?2:1;
      if(!App.profile.mapStars)App.profile.mapStars={};
      App.profile.mapStars[_caseIdx]=Math.max(st,App.profile.mapStars[_caseIdx]||0);
    }catch(_){}
  }
  else if(r.kind==="partial"){try{addXP(60);addCredits(40);}catch(_){}}
  else{try{addXP(20);addCredits(10);}catch(_){}}
  try{saveProfile();clearCaseState();}catch(_){}
}

function nextCard(){ restartCarousel(); }
function restartCarousel(){
  clearCaseState();
  CState.ev=CASE.start;CState.flags={};CState.evidence=[];CState.step=0;
  if(_evCountEl)_evCountEl.textContent="0";
  if(_progEl)_progEl.style.width="0%";
  const endEl=document.getElementById("ending");if(endEl)endEl.classList.remove("show");
  cfCards.forEach(function(c){if(c.parentNode)c.parentNode.removeChild(c);});
  cfCards=[];centerIndex=0;cBusy=false;cActive=null;SPIN_DUR=640;
  App.swipeUnlocked=false;
  buildBacks();
}


function initGenderSelect(){
  var modal=document.getElementById('gender-select'); if(!modal) return;
  var picked=null, confirm=document.getElementById('gm-confirm');
  modal.querySelectorAll('.gm-card').forEach(function(c){
    c.addEventListener('click',function(){
      modal.querySelectorAll('.gm-card').forEach(function(x){x.classList.remove('sel');});
      c.classList.add('sel'); picked=c.getAttribute('data-gender');
      if(confirm) confirm.disabled=false;
    });
  });
  if(confirm) confirm.addEventListener('click',function(){
    if(!picked) return;
    if(App.profile){ App.profile.gender=picked; App.profile.genderChosen=true; App.profile.onboarded=true; saveProfile(); }
    applyRecruitGender();
    modal.style.display='none';
    try{ updateProfileUI&&updateProfileUI(); }catch(_){}
  });
}
function bindAgentControls(){
  if(window._agentBound) return; window._agentBound=true;
  document.addEventListener('click', function(e){
    var t=e.target.closest&&e.target.closest('[data-gender]');
    // смена персонажа в Агенте (кнопки cs-m/cs-f)
    if(t && (t.id==='cs-m'||t.id==='cs-f')){
      var g=t.getAttribute('data-gender');
      if(App.profile){ App.profile.gender=g; saveProfile(); }
      applyRecruitGender();
      document.querySelectorAll('#cs-m,#cs-f').forEach(function(b){
        b.classList.toggle('active', b.getAttribute('data-gender')===g);
      });
      try{ if(window.toast) toast('Персонаж изменён','Рекрут обновлён во всей игре.','👤'); }catch(_){}
      return;
    }
    // сброс прогресса
    if(e.target.closest&&e.target.closest('#reset-progress')){
      if(confirm('Начать игру сначала? Прогресс, улики и шкалы сбросятся (выбранный персонаж сохранится).')){
        try{
          var gen=(App.profile&&App.profile.gender)||'m';
          localStorage.removeItem('sdvig_case_state');
          localStorage.removeItem('sdvig_progress');
          localStorage.removeItem('sdvig_feed_history');
          App.profile=normalizeProfile({...DEFAULT_PROFILE, gender:gen, onboarded:true});
          saveProfile();
          location.reload();
        }catch(err){ console.error('reset',err); }
      }
      return;
    }
  });
}
function _refreshAgentGender(){
  var g=(App.profile&&App.profile.gender)||'m';
  document.querySelectorAll('#cs-m,#cs-f').forEach(function(b){
    b.classList.toggle('active', b.getAttribute('data-gender')===g);
  });
}
function maybeShowGenderSelect(){
  try{
    applyRecruitGender();
    if(App.profile && !App.profile.genderChosen){
      var m=document.getElementById('gender-select');
      if(m){ m.style.display='flex'; initGenderSelect(); }
    }
  }catch(_){}
}
window.openGenderSelect=function(){
  var m=document.getElementById('gender-select');
  if(m){ m.style.display='flex'; initGenderSelect(); }
};
function initCharSwitch(){
  var m=document.getElementById('cs-m'), f=document.getElementById('cs-f');
  function refresh(){
    var g=(App.profile&&App.profile.gender)||'m';
    if(m)m.classList.toggle('active',g==='m');
    if(f)f.classList.toggle('active',g==='f');
  }
  function set(g){ if(App.profile){ App.profile.gender=g; saveProfile(); } applyRecruitGender(); refresh();
    try{ if(window.toast) toast('Персонаж изменён','Рекрут обновлён.','👤'); }catch(_){} }
  if(m)m.addEventListener('click',function(){set('m');});
  if(f)f.addEventListener('click',function(){set('f');});
  refresh();
}
function initResetProgress(){
  var btn=document.getElementById('reset-progress'); if(!btn) return;
  btn.addEventListener('click',function(){
    if(confirm('Начать игру сначала? Весь прогресс, улики и шкалы будут сброшены.')){
      try{
        // сброс прогресса дел, шкал, но СОХРАНЯЕМ выбранный пол
        var g=(App.profile&&App.profile.gender)||'m';
        localStorage.removeItem('sdvig_case_state');
        localStorage.removeItem('sdvig_progress');
        App.profile=normalizeProfile({...DEFAULT_PROFILE, gender:g, onboarded:true});
        saveProfile();
        try{ if(window.Feed&&Feed.reset) Feed.reset(); }catch(_){}
        location.reload();
      }catch(e){ console.error('reset',e); }
    }
  });
}

function initEvPanel(){
  const chip=document.getElementById("ev-chip");
  if(chip && !chip._evChipBound){ chip._evChipBound=true; chip.addEventListener("click",function(){
    const panel=document.getElementById("ev-panel");
    const list=document.getElementById("ev-list");
    if(!panel||!list)return;
    var cl=CState.clues||[];
    list.innerHTML=cl.length
      ? cl.map(function(c){return '<div class="ev-clue"><div class="ec-ico">'+(c.icon||'🔍')+'</div>'+
          '<div class="ec-body"><div class="ec-name">'+c.name+'</div><div class="ec-proof">'+c.proof+'</div></div></div>';}).join("")
      : '<div class="ev-empty">Улики появятся по ходу расследования.</div>';
    panel.classList.add("open");
  }); }
  const closeBtn=document.getElementById("ev-close");
  if(closeBtn) closeBtn.addEventListener("click",function(){
    const panel=document.getElementById("ev-panel");if(panel)panel.classList.remove("open");
  });
  const restartBtn=document.getElementById("e-restart");
  if(restartBtn) restartBtn.addEventListener("click",function(){
    const _hn=CAMPAIGN&&(_caseIdx+1)<CAMPAIGN.cases.length;
    if(_hn){ loadCaseByIndex(_caseIdx+1); computeEnding._invalidate=true; }
    if(window.Feed){ initCarousel_data(); Feed.reset(); Feed.init(); } else { restartCarousel(); }
  });
}

function saveCaseState(){
  try{
    var cid=(CAMPAIGN&&CAMPAIGN.cases[_caseIdx])?CAMPAIGN.cases[_caseIdx].id:'case001';
    lsSet('sdvig_progress',{cid:cid,ev:CState.ev,flags:CState.flags,evidence:CState.evidence,clues:CState.clues,step:CState.step});
  }catch(e){}
}
function clearCaseState(){ try{localStorage.removeItem('sdvig_progress');}catch(e){} }
function loadCaseState(){
  try{
    var p=lsGet('sdvig_progress',null); if(!p) return null;
    var cid=(CAMPAIGN&&CAMPAIGN.cases[_caseIdx])?CAMPAIGN.cases[_caseIdx].id:'case001';
    if(p.cid!==cid) return null;
    if(!CASE.events[p.ev]) return null; /* карта из старой версии сценария */
    return p;
  }catch(e){ return null; }
}

/* ═══ ОНБОРДИНГ (R16) ═══ */
var ONB_ICONS={
  swipe:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
    +'<rect x="22" y="10" width="20" height="34" rx="5" fill="rgba(200,134,10,.1)"/>'
    +'<circle cx="32" cy="27" r="4.5" fill="#f3d27a" stroke="none"/>'
    +'<g class="sway-l"><path d="M16 27l-7 0M12 23l-4 4 4 4"/></g>'
    +'<g class="sway-r"><path d="M48 27l7 0M52 23l4 4-4 4"/></g></svg>',
  gems:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.2" stroke-linejoin="round">'
    +'<g class="pulse"><path d="M32 8l9 9-9 9-9-9z" fill="rgba(92,208,255,.25)"/>'
    +'<path d="M16 30l7 7-7 7-7-7z" fill="rgba(255,111,134,.22)"/>'
    +'<path d="M48 30l7 7-7 7-7-7z" fill="rgba(200,134,10,.28)"/>'
    +'<path d="M32 40l9 9-9 9-9-9z" fill="rgba(120,220,150,.22)"/></g></svg>',
  shift:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">'
    +'<line x1="32" y1="8" x2="32" y2="56" stroke="rgba(243,210,122,.5)" stroke-dasharray="3 4"/>'
    +'<g class="sway-l" stroke="#5cd0ff"><path d="M24 20l-9 9 9 9"/></g>'
    +'<g class="sway-r" stroke="#ff6f86"><path d="M40 20l9 9-9 9"/></g></svg>',
  energy:'<svg viewBox="0 0 64 64" fill="none" stroke="#f3d27a" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">'
    +'<path d="M20 24h20v10a10 10 0 0 1-20 0z" fill="rgba(200,134,10,.15)"/>'
    +'<path d="M40 26h4a4 4 0 0 1 0 8h-4"/>'
    +'<g class="pulse" stroke="#f3d27a"><path d="M24 14c-1 2 1 3 0 5M30 13c-1 2 1 3 0 5M36 14c-1 2 1 3 0 5"/></g></svg>'
};


var ONB_STEPS=[
  {key:'gems',  icon:'gems',  title:'Сначала — улики',
    text:'Каждая карта дела заперта. Нажми «Найти улики» и пройди мини-игру «Улики», чтобы разблокировать выбор.'},
  {key:'swipe', icon:'swipe', title:'Свайп решает',
    text:'После мини-игры тяни карту влево или вправо — это твой выбор в расследовании. Каждый свайп тратит ☕ кофе (энергию).'},
  {key:'shift', icon:'shift', title:'Момент СДВИГА',
    text:'Иногда реальность раскалывается надвое. Выбранная версия станет правдой дела — и определит финал. Думай как детектив.'}
];
function onbDone(){ try{ if(App.profile){ App.profile.onboarded=true; saveProfile(); } }catch(_){} }
function onbSeen(){ try{ return !!(App.profile&&App.profile.onboarded); }catch(_){ return false; } }
function onbShow(i){
  var el=document.getElementById('onb'); if(!el) return;
  var s=ONB_STEPS[i]; if(!s){ el.setAttribute('hidden',''); onbDone(); return; }
  el.removeAttribute('hidden');
  document.getElementById('onb-ico').innerHTML=ONB_ICONS[s.icon]||'';
  document.getElementById('onb-title').textContent=s.title;
  document.getElementById('onb-text').textContent=s.text;
  var dots=document.getElementById('onb-dots');
  if(dots){ dots.innerHTML=ONB_STEPS.map(function(_,j){return '<i class="'+(j===i?'on':'')+'"></i>';}).join(''); }
  var btn=document.getElementById('onb-btn');
  btn.textContent=(i>=ONB_STEPS.length-1)?'Начать дело':'Дальше';
  btn.onclick=function(){ try{Sound.tap();}catch(_){} onbShow(i+1); };
}
function onbMaybeStart(){
  if(onbSeen()) return;
  /* показываем на первой НЕ-линейной карте (когда реально нужен match-3+свайп) */
  setTimeout(function(){ if(!onbSeen()) onbShow(0); }, 400);
}


/* ═══ ПЕРСОНАЖИ-СПРАЙТЫ (R24) ═══ */
const CHAR_VER='3';  /* поднимай при замене артов — пробивает кэш */
const CHARS={
  shift:  {src:'/img/chars/char-shift.png',   side:'right'},
  recruit:{src:'/img/chars/char-recruit.png', side:'left'},
  'recruit-f':{src:'/img/chars/char-recruit-f.png', side:'left'},
  kurator:{src:'/img/chars/char-kurator.png', side:'right'},
  arundel:{src:'/img/chars/char-arundel.png', side:'right'},
  miller: {src:'/img/chars/char-miller.png',  side:'right'},
  hayes:  {src:'/img/chars/char-hayes.png',   side:'right'},
  romero: {src:'/img/chars/char-romero.png',  side:'right'},
  conroy: {src:'/img/chars/char-conroy.png',  side:'right'},
  jiang:  {src:'/img/chars/char-jiang.png',   side:'right'},
  purcell:{src:'/img/chars/char-purcell.png', side:'right'},
  danny:  {src:'/img/chars/char-danny.png',   side:'right'},
  eleanor:{src:'/img/chars/char-eleanor.png', side:'left'},
  cop:    {src:'/img/chars/char-cop.png',     side:'left'},
  captain:{src:'/img/chars/char-captain.png', side:'right'},
  pocketman:{src:'/img/chars/char-pocketman.png',side:'left'},
  guests: {src:'/img/chars/char-guests.png',  side:'right'}
};
window.CHARS=CHARS; window.CHAR_VER=CHAR_VER;
const CASE_BGS={
  'case001':'/img/bg/bg-ch1-hall.png',
  'case002':'/img/bg/bg-oldcity.jpg',
  'case003':'/img/bg/bg-docks.jpg',
  'case004':'/img/bg/bg-mansion-ext.jpg',
  'case005':'/img/bg/bg-mansion-int.jpg'
};
function recruitSrc(){
  try{ return (App.profile&&App.profile.gender==='f')?'/img/chars/char-recruit-f.png':'/img/chars/char-recruit.png'; }
  catch(_){ return '/img/chars/char-recruit.png'; }
}
function applyRecruitGender(){
  try{ if(window.CHARS&&CHARS.recruit){ CHARS.recruit.src=recruitSrc(); window.CHAR_VER=String(Date.now()); } }catch(_){}
}
let _charEl=null,_charId=null;
function showChar(id){
  if(!id||!CHARS[id]){hideChar();return;}
  const def=CHARS[id];
  var host=document.getElementById('main-screen')||document.body;
  if(!_charEl){
    _charEl=document.createElement('img');
    _charEl.alt=''; _charEl.className='char-sprite';
    host.appendChild(_charEl);
  }
  if(_charEl.parentNode!==host) host.appendChild(_charEl);
  if(_charId!==id){
    _charEl.classList.remove('show');
    _charEl.className='char-sprite '+(def.side||'right');
    _charEl.onload=function(){ _charEl.classList.add('show'); };
    _charEl.src=def.src+'?v='+CHAR_VER; _charId=id;
    /* запасной показ, если onload уже отработал из кэша */
    requestAnimationFrame(function(){requestAnimationFrame(function(){ _charEl.classList.add('show'); });});
  } else { _charEl.classList.add('show'); }
}
var _speechEl=null;
function showSpeech(text){
  var host=document.getElementById('main-screen')||document.body;
  if(!_speechEl){ _speechEl=document.createElement('div'); _speechEl.className='char-speech'; host.appendChild(_speechEl); }
  if(!text){ _speechEl.classList.remove('show'); return; }
  _speechEl.innerHTML='<span class="cs-quote">'+text.replace(/^[^:]*:\s*/,'').replace(/[«»"]/g,'')+'</span>';
  requestAnimationFrame(function(){requestAnimationFrame(function(){ _speechEl.classList.add('show'); });});
}
function hideChar(){
  if(_charEl)_charEl.classList.remove('show'); _charId=null;
  if(_speechEl)_speechEl.classList.remove('show');
}
var _origBgFxDrag=null;
function installSceneParallax(){
  if(_origBgFxDrag) return;
  _origBgFxDrag=window.BgFxDrag||function(){};
  window.BgFxDrag=function(nx,ny){
    try{_origBgFxDrag(nx,ny);}catch(_){}
    var sb=document.getElementById('scene-bg');
    if(sb&&sb.classList.contains('on')){
      sb.style.transform='translate3d('+(-nx*14)+'px,'+(-ny*10)+'px,0) scale(1.08)';
    }
  };
}
function updateCaseBg(){
  try{
    const cid=CAMPAIGN&&CAMPAIGN.cases[_caseIdx]?CAMPAIGN.cases[_caseIdx].id:'';
    const bg=CASE_BGS[cid]||null;
    const sb=document.getElementById('scene-bg');
    const st=document.getElementById('stage'); if(st)st.style.backgroundImage='';
    if(sb){
      if(bg){ sb.style.backgroundImage="url('"+bg+"')"; sb.classList.add('on'); }
      else { sb.style.backgroundImage=''; sb.classList.remove('on'); }
    }
    /* прячем параллакс кабинета, когда показан фон дела */
    var bf=document.getElementById('bg-fx');
    if(bf) bf.style.opacity = bg ? '0' : '1';
  }catch(_){}
}
function initCarousel_data(){
  // подготовка состояния дела без 3D-кольца (для ленты)
  try{
    var _saved=window.loadCaseState?loadCaseState():null;
    if(_saved){ CState.ev=_saved.ev; CState.flags=_saved.flags||{}; CState.evidence=_saved.evidence||[]; CState.step=_saved.step||0; }
    else { CState.ev=CASE.start; CState.flags={}; CState.evidence=[]; CState.step=0; }
    var _cn=document.getElementById('case-name'); if(_cn)_cn.textContent=CASE.name||'';
    if(window.cSetProgress)cSetProgress();
    if(window.initEvPanel)initEvPanel();
    if(window.updateCaseBg)updateCaseBg();
  }catch(e){ console.error('initCarousel_data',e); }
}
function initCarousel(){
  _ring=document.getElementById("ring");
  _evCountEl=document.getElementById("ev-count");
  _progEl=document.getElementById("prog");
  if(!_ring)return;
  cfCards=[];centerIndex=0;cBusy=false;cActive=null;SPIN_DUR=640;
  CState.ev=CASE.start;CState.flags={};CState.evidence=[];CState.step=0;
  if(_evCountEl)_evCountEl.textContent="0";
  var _cn=document.getElementById("case-name");if(_cn)_cn.textContent=CASE.name||"";
  var _cs=document.getElementById("case-sub");if(_cs)_cs.textContent=(CAMPAIGN&&CAMPAIGN.cases[_caseIdx])?CAMPAIGN.cases[_caseIdx].title:"";
  cSetProgress(); buildBacks(); initEvPanel(); try{maybeShowGenderSelect();bindAgentControls();}catch(_){} try{updateCaseBg();hideChar();}catch(_){} try{updateCaseBg();hideChar();}catch(_){}
}

/* ═══════════════════════════════════════════════
   КАРТА ПРОГРЕССА
═══════════════════════════════════════════════ */
const CHAPTERS=[
  {title:'Глава I · Музейный квартал', levels:4, district:'Музейный квартал', tint:'#6be0ff'},
  {title:'Глава II · Старый город',    levels:5, district:'Старый город',     tint:'#a98bff'},
  {title:'Глава III · Ночные доки',    levels:5, district:'Доки',             tint:'#35d49b'},
  {title:'Глава IV · Туманный лес',    levels:3, district:'Туманный лес',     tint:'#7ec88f'},
  {title:'Глава V · Особняк',          levels:4, district:'Особняк',          tint:'#ffcf6b'}
];

function totalLevels(){ return CHAPTERS.reduce((s,c)=>s+c.levels,0); }

// нормализованные точки узлов на нарисованной дороге (из map-art/nodes.json)
const MAP_NODES=[[0.506,0.958],[0.502,0.92],[0.499,0.882],[0.496,0.84],[0.495,0.788],[0.495,0.748],[0.507,0.71],[0.511,0.672],[0.5,0.632],[0.495,0.582],[0.499,0.548],[0.495,0.508],[0.516,0.468],[0.495,0.43],[0.51,0.375],[0.509,0.34],[0.507,0.27],[0.509,0.178],[0.454,0.138],[0.502,0.115],[0.5,0.085]];
const MAP_ASPECT=6080/768;  // высота карты = ширина × 4

function renderMap(){
  const inner=$('#map-inner'); const svg=$('#map-path');
  inner.querySelectorAll('.map-node,.map-chapter,.map-plaque').forEach(e=>e.remove());
  if(svg) svg.innerHTML='';

  const total=Math.min(totalLevels(), MAP_NODES.length);
  const scroll=$('#map-scroll');
  const W=inner.clientWidth || (scroll&&scroll.clientWidth) || window.innerWidth || 360;
  const H=W*MAP_ASPECT;
  inner.style.height=H+'px';
  // нарисованная карта-город как фон
  inner.style.background="url('/img/map-city.jpg') top center / 100% auto no-repeat";

  const cur=App.profile.mapNode||0;
  const stars=App.profile.mapStars||{};

  // границы районов (по N глав)
  let bounds=[], acc=0;
  CHAPTERS.forEach(ch=>{ bounds.push(acc); acc+=ch.levels; });

  // ── таблички: музей в самом низу, остальные на туманных стыках ──
  const PLAQUES=[
    {name:'Музейный квартал', y:0.975},
    {name:'Старый город',     y:0.800},
    {name:'Ночные доки',      y:0.600},
    {name:'Туманный лес',     y:0.400},
    {name:'Особняк',          y:0.200},
  ];
  PLAQUES.forEach((p)=>{
    const plq=el('div','map-plaque',
      `<span class="mp-orn">✦</span><span class="mp-text">${p.name}</span><span class="mp-orn">✦</span>`);
    plq.style.top=(p.y*100)+'%';
    inner.appendChild(plq);
  });

  for(let idx=0; idx<total; idx++){
    const [nx,ny]=MAP_NODES[idx];

    const tint=CHAPTERS[Math.max(0,bounds.filter(b=>b<=idx).length-1)]?.tint||'#ffcf6b';
    const isMile=bounds.includes(idx+1)||idx===total-1;
    const state = idx<cur?'done':idx===cur?'current':'locked';
    const node=el('div','map-node '+state+(isMile?' milestone':''));
    node.style.setProperty('--nt',tint);
    if(state==='locked'){ node.innerHTML=Icons.get('lock'); }
    else { node.innerHTML=`<span class="mn-num">${idx+1}</span>`; }
    if(state==='done'){ const st=stars[idx]||1;
      node.innerHTML+=`<span class="mn-stars">${'★'.repeat(st)}${'☆'.repeat(3-st)}</span>`; }
    if(state==='current'){ /* только пульсация, без аватара */ }
    node.style.left=(nx*100)+'%'; node.style.top=(ny*100)+'%';
    const myIdx=idx, myState=state;
    node.onclick=()=>{
      if(myState==='locked'){ try{Sound.error();}catch(_){} vibrate(15); toast('Закрыто','Пройдите предыдущие дела','🔒'); return; }
      Sound.tap(); vibrate(8);
      if(myState==='current') goToTab('cases');
      else toast('Пройдено','Дело №'+(myIdx+1)+' закрыто','✓');
    };
    inner.appendChild(node);
  }

  // автопрокрутка к текущему уровню
  if(scroll){
    const [,cy]=MAP_NODES[Math.min(cur,total-1)];
    const target=cy*H - scroll.clientHeight*0.5;
    setTimeout(()=>{ scroll.scrollTo({top:Math.max(0,target), behavior:'smooth'}); }, 60);
  }
}

/* старый генератор кварталов больше не нужен — карта нарисована */
function drawDistrict(){ return ''; }

function advanceMap(){ App.profile.mapNode=Math.min(totalLevels()-1,(App.profile.mapNode||0)+1); }
function goToTab(t){ $('.nb[data-tab="'+t+'"]')?.click(); }

/* ═══════════════════════════════════════════════
   ПРОФИЛЬ
═══════════════════════════════════════════════ */
const SKILLS=[
  {k:'insight', icon:'🧠', name:'Проницательность', desc:'Видеть скрытое'},
  {k:'tech',    icon:'🔬', name:'Технологии',       desc:'Анализ улик'},
  {k:'charisma',icon:'🎭', name:'Харизма',          desc:'Разговорить свидетеля'},
  {k:'nerve',   icon:'🔥', name:'Хладнокровие',     desc:'Спецприёмы'}
];
const ACHIEVEMENTS=[
  {k:'first',  icon:'🎖', title:'Первое дело'},
  {k:'streak5',icon:'🔥', title:'Серия 5'},
  {k:'gem500', icon:'💎', title:'Магнат'},
  {k:'lvl10',  icon:'⭐', title:'Ветеран'},
  {k:'special',icon:'⚡', title:'Спецагент'},
  {k:'map1',   icon:'🗺', title:'Глава I'}
];

function renderProfile(){
  const p=App.profile, u=App.user||{};
  try{ _refreshAgentGender(); }catch(_){}
  const name=u.firstName||u.name||'Агент';
  $('#prof-av').textContent=(name[0]||'С').toUpperCase();
  $('#prof-name').textContent=name;
  $('#prof-arch').textContent=archetype(p);
  $('#prof-id').textContent='#'+String(u.id||'000000').slice(-6).padStart(6,'0');
  $('#st-cases').textContent=p.casesSolved;
  $('#st-streak').textContent=p.streak;
  $('#st-prestige').textContent=p.prestige;
  $('#st-lvl').textContent=p.level;

  const sl=$('#skill-list'); sl.innerHTML='';
  SKILLS.forEach(s=>{
    const lv=p.skills[s.k]||1; const cost=lv*40;
    const row=el('div','skill-row',`
      <div class="sk-icon">${s.icon}</div>
      <div class="sk-body"><div class="sk-name">${s.name}</div><div class="sk-desc">${s.desc}</div>
        <div class="sk-bar"><div class="sk-fill" style="width:${clamp(lv/10*100,5,100)}%"></div></div></div>
      <div class="sk-side"><div class="sk-lv">ур ${lv}</div>
        <button class="up-btn" ${p.credits<cost?'disabled':''}>+${cost}◈</button></div>`);
    row.querySelector('.up-btn').onclick=()=>{
      if(App.profile.credits<cost) return;
      addCredits(-cost); App.profile.skills[s.k]=lv+1;
      Sound.booster(); vibrate(10); toast('Навык повышен',s.name+' ур '+(lv+1),'⬆️');
      renderProfile();
    };
    sl.appendChild(row);
  });

  const ag=$('#ach-grid'); ag.innerHTML='';
  ACHIEVEMENTS.forEach(a=>{
    const earned=p.achievements.includes(a.k);
    ag.appendChild(el('div','ach-cell'+(earned?' earned':''),
      `<div class="ach-ico">${a.icon}</div><div class="ach-title">${a.title}</div>`));
  });
}
function archetype(p){
  const m=Math.max(...Object.values(p.skills));
  const k=Object.keys(p.skills).find(x=>p.skills[x]===m);
  return ({insight:'Аналитик',tech:'Криминалист',charisma:'Переговорщик',nerve:'Силовик'})[k]||'Новичок';
}
function unlockAch(k){ if(!App.profile.achievements.includes(k)){ App.profile.achievements.push(k);
  Sound.win(); toast('Достижение',ACHIEVEMENTS.find(a=>a.k===k)?.title||'','🏆'); saveProfile(); } }

/* ═══════════════════════════════════════════════
   МАГАЗИН
═══════════════════════════════════════════════ */

/* ═══ Анимированные SVG-иконки товаров (R18) ═══ */
var GEM_SVG={
  bucks:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M20 3l9 6v14l-9 6-9-6V9z" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><path d="M20 3v34M11 9l9 5 9-5M11 23l9-5 9 5" fill="none" stroke="#8a6410" stroke-width=".7" opacity=".55"/><ellipse cx="16" cy="12" rx="3" ry="5" fill="url(#gemSpark)"/></svg>',
  energy:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M12 14h16v8a8 8 0 0 1-16 0z" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><path d="M28 16h3a4 4 0 0 1 0 8h-3" fill="none" stroke="#8a6410" stroke-width="1.4"/><path d="M16 6c-1 2 1 3 0 5M20 5c-1 2 1 3 0 5M24 6c-1 2 1 3 0 5" fill="none" stroke="url(#gemShine)" stroke-width="1.6" stroke-linecap="round"><animate attributeName="opacity" values=".4;1;.4" dur="1.5s" repeatCount="indefinite"/></path><ellipse cx="17" cy="17" rx="2.5" ry="4" fill="url(#gemSpark)"/></svg>',
  magnify:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><circle cx="17" cy="17" r="10" fill="url(#gemCyan)" stroke="#1b6fa8" stroke-width="1.2" opacity=".92"/><circle cx="17" cy="17" r="6" fill="none" stroke="#d6f4ff" stroke-width="1" opacity=".6"/><path d="M25 25l9 9" stroke="url(#gemShine)" stroke-width="2.6" stroke-linecap="round"/><ellipse cx="14" cy="13" rx="2.5" ry="4" fill="url(#gemSpark)"/></svg>',
  file:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M11 6h12l6 6v22H11z" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><path d="M23 6v6h6" fill="none" stroke="#6a4810" stroke-width="1"/><path d="M15 19h11M15 24h11M15 29h7" stroke="#6a4810" stroke-width="1.2" opacity=".5"/><ellipse cx="16" cy="11" rx="2" ry="3.5" fill="url(#gemSpark)"/></svg>',
  hourglass:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M12 6h16M12 34h16M14 6c0 7 12 9 12 14s-12 7-12 14M26 6c0 7-12 9-12 14s12 7 12 14" fill="none" stroke="url(#gemShine)" stroke-width="2" stroke-linecap="round"/><path d="M20 18l-4 4h8z" fill="url(#gemShine)"><animateTransform attributeName="transform" type="translate" values="0 0;0 6;0 0" dur="2s" repeatCount="indefinite"/></path><ellipse cx="17" cy="10" rx="2" ry="3" fill="url(#gemSpark)"/></svg>',
  ashtray:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><ellipse cx="20" cy="26" rx="13" ry="6" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><ellipse cx="20" cy="24" rx="9" ry="4" fill="#1a1206" opacity=".6"/><path d="M22 20l8-8" stroke="#caa033" stroke-width="2" stroke-linecap="round"/><path d="M29 13c1-2 3-1 2-3" stroke="#aaa" stroke-width="1" fill="none" opacity=".5"><animate attributeName="opacity" values=".2;.6;.2" dur="2s" repeatCount="indefinite"/></path></svg>',
  siren:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><rect x="12" y="18" width="16" height="10" rx="3" fill="url(#gemRose)" stroke="#a8324a" stroke-width="1"/><path d="M16 18a4 4 0 0 1 8 0" fill="url(#gemCyan)" stroke="#1b6fa8" stroke-width="1"/><circle cx="20" cy="11" r="2" fill="url(#gemShine)"><animate attributeName="opacity" values="1;.3;1" dur=".7s" repeatCount="indefinite"/></circle><path d="M8 22h3M29 22h3" stroke="url(#gemShine)" stroke-width="1.6" stroke-linecap="round"/></svg>',
  tape:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><rect x="6" y="12" width="28" height="16" rx="2" fill="url(#gemShine)" stroke="#6a4810" stroke-width="1"/><circle cx="15" cy="20" r="3.5" fill="#1a1206"/><circle cx="25" cy="20" r="3.5" fill="#1a1206"/><circle cx="15" cy="20" r="1.4" fill="url(#gemShine)"><animateTransform attributeName="transform" type="rotate" from="0 15 20" to="360 15 20" dur="2s" repeatCount="indefinite"/></circle><circle cx="25" cy="20" r="1.4" fill="url(#gemShine)"><animateTransform attributeName="transform" type="rotate" from="0 25 20" to="360 25 20" dur="2s" repeatCount="indefinite"/></circle></svg>',
  phone:'<svg viewBox="0 0 40 40" filter="url(#gemGlow)"><path d="M10 8c0 2 1 4 3 4l3-1 2 4-3 2c2 5 6 9 11 11l2-3 4 2-1 3c0 2 2 3 4 3" fill="none" stroke="url(#gemShine)" stroke-width="2.4" stroke-linecap="round"/><circle cx="30" cy="11" r="2.5" fill="url(#gemRose)"><animate attributeName="r" values="2.5;3.2;2.5" dur="1s" repeatCount="indefinite"/></circle></svg>'
};
function gemIcon(k){ return GEM_SVG[k]||GEM_SVG.bucks; }

const SHOP=[
  /* ── За 📁 Зацепки (credits) — бесплатный контур ── */
  {k:'energy',   svg:'energy',   name:'Чёрный кофе', desc:'+3 энергии', cur:'credits', price:30,
    buy(){ addEnergy(3); }},
  {k:'magnify',  svg:'magnify',  name:'Лупа',        desc:'Подсветит улику', cur:'credits', price:40,
    buy(){ App.profile.tMagnify=(App.profile.tMagnify||0)+1; saveProfile(); }},
  {k:'file',     svg:'file',     name:'Досье',       desc:'Пропустить мини-игру', cur:'credits', price:60,
    buy(){ App.profile.tFile=(App.profile.tFile||0)+1; saveProfile(); }},
  {k:'hourglass',svg:'hourglass',name:'Песочные часы',desc:'+20 энергии', cur:'credits', price:30,
    buy(){ addEnergy(20); }},
  /* ── За 💵 Баксы (премиум-валюта) — бустеры match-3 ── */
  {k:'ashtray',  svg:'ashtray',  name:'Тяжёлая пепельница', desc:'Разбить 1 камень', cur:'bucks', price:100,
    buy(){ App.profile.boosters=(App.profile.boosters||0)+1; saveProfile(); }},
  {k:'siren',    svg:'siren',    name:'Полицейская мигалка', desc:'Очистить ряд+столбец', cur:'bucks', price:150,
    buy(){ App.profile.bSiren=(App.profile.bSiren||0)+1; saveProfile(); }},
  {k:'tape',     svg:'tape',     name:'Плёнка диктофона', desc:'Перемешать поле', cur:'bucks', price:150,
    buy(){ App.profile.bShuffle=(App.profile.bShuffle||0)+1; saveProfile(); }},
  {k:'phone',    svg:'phone',    name:'Звонок информатору', desc:'Подсветит безопасный выбор', cur:'bucks', price:50,
    buy(){ App.profile.tHint=(App.profile.tHint||0)+1; saveProfile(); }}
];

/* пакеты Баксов за реальные деньги (заглушка под платёж Telegram Stars / Wallet) */
const BUCK_PACKS=[
  {amount:500,  price:'$1.99'},
  {amount:1400, price:'$4.99'},
  {amount:6500, price:'$19.99'},
  {amount:50000,price:'$99.99', label:'Чемодан с наличностью'}
];

function renderShop(){
  const g=$('#shop-grid'); if(!g) return; g.innerHTML='';
  SHOP.forEach(it=>{
    const isBucks=it.cur==='bucks';
    const curIco=isBucks?'<span class="gem-ico mini" data-gem="bucks"></span>':'◈';
    const item=el('div','shop-item'+(isBucks?' premium':''),`
      <div class="si-gem">${gemIcon(it.svg)}</div>
      <div class="si-name">${it.name}</div>
      <div class="si-desc">${it.desc}</div>
      <div class="si-price ${isBucks?'pr-bucks':'pr-credits'}">${it.price} ${curIco}</div>`);
    item.onclick=()=>{
      const bal=isBucks?(App.profile.bucks||0):App.profile.credits;
      if(bal<it.price){
        Sound.error();
        if(isBucks){ openBuckShop(); }
        else toast('Мало зацепок','Нужно '+it.price+' ◈','✗');
        return;
      }
      if(isBucks){ App.profile.bucks-=it.price; } else { addCredits(-it.price); }
      it.buy(); Sound.coin(); vibrate(10);
      toast('Куплено',it.name,'🛍'); renderHUD(); renderShop();
    };
    g.appendChild(item);
  });
}

/* окно покупки Баксов (заглушка платежа) */
function openBuckShop(){
  let html='<div class="buckshop-back" id="buckshop"><div class="buckshop-card">'
    +'<div class="bs-title"><span class="gem-ico" data-gem="bucks"></span> Служебный бюджет</div>'
    +'<div class="bs-sub">Баксы ускоряют расследование. Игра проходится и без них.</div>'
    +'<div class="bs-list">';
  BUCK_PACKS.forEach((p,i)=>{
    html+='<button class="bs-pack" data-i="'+i+'"><span class="bs-amt"><span class="gem-ico mini" data-gem="bucks"></span> '+p.amount.toLocaleString('ru')+'</span>'
      +(p.label?'<span class="bs-label">'+p.label+'</span>':'')
      +'<span class="bs-price">'+p.price+'</span></button>';
  });
  html+='</div><button class="bs-close" id="bs-close">Закрыть</button></div></div>';
  const wrap=document.createElement('div'); wrap.innerHTML=html; document.body.appendChild(wrap.firstChild);
  const back=document.getElementById('buckshop');
  back.querySelectorAll('.bs-pack').forEach(b=>b.onclick=()=>{
    const p=BUCK_PACKS[+b.dataset.i];
    /* TODO: реальный платёж (Telegram Stars / Wallet). Пока — выдаём для теста. */
    addBucks(p.amount); Sound.coin(); vibrate([10,30,10]);
    toast('Бюджет пополнен','+'+p.amount.toLocaleString('ru')+' баксов','💵');
    back.remove(); renderShop();
  });
  back.querySelector('#bs-close').onclick=()=>{ Sound.tap(); back.remove(); };
  back.onclick=(e)=>{ if(e.target===back){ back.remove(); } };
}

/* ═══════════════════════════════════════════════
   ЕЖЕДНЕВНЫЙ БОНУС
═══════════════════════════════════════════════ */
function checkDaily(){
  const p=App.profile; const today=new Date().toDateString();
  if(p.lastDaily===today) return;
  const yest=new Date(Date.now()-864e5).toDateString();
  p.dailyStreak = (p.lastDaily===yest)?(p.dailyStreak+1):1;
  p.lastDaily=today;
  const reward=20+Math.min(p.dailyStreak,7)*10;
  setTimeout(()=>showDaily(p.dailyStreak,reward),700);
  addCredits(reward); saveProfile();
}
function showDaily(streak,reward){
  const bg=$('#daily-modal');
  const days=Array.from({length:7},(_,i)=>`<div class="dw-day${i<streak?' done':''}">${i+1}</div>`).join('');
  bg.innerHTML=`<div class="daily-card">
    <div class="daily-icon">🎁</div>
    <div class="daily-h">Ежедневный бонус</div>
    <div class="daily-streak">Серия входов: ${streak} ${streak>=7?'🔥':''}</div>
    <div class="daily-week">${days}</div>
    <div class="daily-chips"><span class="dc-chip">+${reward} ◈</span></div>
    <button class="btn btn-bronze" id="daily-ok" style="max-width:220px">Забрать</button>
  </div>`;
  bg.classList.remove('hidden'); Sound.daily();
  bg.querySelector('#daily-ok').onclick=()=>{ Sound.coin(); vibrate(10); bg.classList.add('hidden'); };
  bg.onclick=e=>{ if(e.target===bg) bg.classList.add('hidden'); };
}

/* ═══════════════════════════════════════════════
   HINT GAME (match-3) — мост к match3.js
═══════════════════════════════════════════════ */
function openHintGame(card){
  const modal=$('#hint-modal');
  modal.classList.remove('hidden');
  const mission = missionFor(card);
  $('#hint-footer').textContent='Колесо улик решает...';
  if(window.BgFx) BgFx.pause();

  const vp=$('#hint-vp');

  function launchGame(gameId){
    // сейчас готова только match3; остальные грани откатываются на неё в cube.js
    startMiniGame(gameId, card, mission, modal);
  }

  // показываем 3D-куб; он сам выберет грань и вызовет launchGame
  if(window.MiniCube){
    MiniCube.open(vp, { onPick:launchGame });
  } else {
    launchGame('match3'); // фолбэк, если куб не загрузился
  }

  $('#hint-close').onclick=()=>{ Sound.tap(); modal.classList.add('hidden'); if(window.BgFx)BgFx.resume();
    try{Match3&&Match3.stop();}catch(_){} try{MiniCube&&MiniCube.close();}catch(_){} };
}

function startMiniGame(gameId, card, mission, modal){
  const vp=$('#hint-vp');
  $('#hint-footer').textContent=mission.label;
  const onWin=()=>{ modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); unlockSwipe(); };
  const onLose=()=>{
    try{ const p=App.profile; if(p){ p.energy=clamp(p.energy-1,0,p.maxEnergy); addRapport(-1); renderHUD(); saveProfile(); } }catch(_){}
    if(window.toast) toast('Улика ускользнула','Сдвиг недоволен. Попробуй снова.','\ud83d\udd0d');
  };
  // роутер мини-игр (расширяемый): пока все ведут на match3
  if(gameId==='match3' && window.Match3){
    Match3.start(vp, { mission, boosters:App.profile.boosters||0, onWin, onLose });
  } else if(window.Match3){
    Match3.start(vp, { mission, boosters:App.profile.boosters||0, onWin, onLose });
  }
}
function pickMission(){
  const M=[
    {type:'score', target:600, moves:14, label:'Набери 600 очков за 14 ходов'},
    {type:'color', color:0, target:12, moves:16, label:'Собери 12 красных улик'},
    {type:'clear', target:20, moves:18, label:'Очисти 20 ячеек'},
    {type:'combo', target:3,  moves:15, label:'Сделай 3 каскада подряд'}
  ];
  return M[Math.floor(Math.random()*M.length)];
}

/* ── главная вкладка-переход для кнопки карты ── */
window.goToTab=goToTab;

