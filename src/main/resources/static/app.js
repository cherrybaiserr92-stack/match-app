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
  level:1, xp:0, energy:5, maxEnergy:5, credits:0,
  casesSolved:0, streak:0, prestige:0, mapNode:0, mapStars:{},
  skills:{ insight:1, tech:1, charisma:1, nerve:1 },
  achievements:[], dailyStreak:0, lastDaily:null, sound:true,
  lastEnergyTs:0, rapport:0
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
  showScreen('main-screen');
  // навигацию и звук вешаем ПЕРВЫМИ — чтобы ошибка в рендере не убила меню
  bindNav();
  bindSoundBtn();
  bindTools();
  if(window.BgFx) BgFx.init();
  Icons.paint();
  try{ initCarousel(); }catch(e){ console.error('initCarousel',e); }
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
function renderHUD(){
  const p=App.profile;
  const en=$('#hud-energy'); if(en) en.textContent=p.energy;
  const cr=$('#hud-credits'); if(cr) cr.textContent=p.credits;
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
    x.send();if(x.status===200)CASE=JSON.parse(x.responseText);
    localStorage.setItem("sdvig_case",cid);}catch(e){}
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
  if(align===keys.length&&e.win)  return Object.assign({},e.win,{align:align});
  if(align>=Math.ceil(keys.length/2)&&e.partial) return Object.assign({},e.partial,{align:align});
  return Object.assign({},e.fail||{mark:'✗',verdict:'ПРОВАЛ',text:'Сдвиг промолчал.'},{ align:align,kind:'fail'});
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
function backHTML(){return gframeHTML()+'<div class="cback-emblem"></div>';}
function cardHTML(ev){
  const scene='<div class="scene"><div class="grad"></div><div class="art" style="background-image:'+artBg(ev.t)+'"></div></div>';
  if(ev.linear){
    return gframeHTML()+scene+'<div class="pad">'
      +'<span class="badge">'+ev.badge+'</span>'
      +'<div class="title">'+ev.title+'</div>'
      +'<div class="text scrollable">'+fill(ev.text,CState.flags)+'</div>'
      +(ev.dialogue?'<div class="dlg">'+ev.dialogue.replace(/\n/g,'<br>')+'</div>':'')
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
    +(ev.dialogue?'<div class="dlg">'+ev.dialogue.replace(/\n/g,'<br>')+'</div>':'')
    +'<div class="spacer"></div><div class="choices">'
    +'<div class="choice l"><span class="dir">СВАЙП ВЛЕВО</span>'+ev.left.label+'</div>'
    +'<div class="choice r"><span class="dir">СВАЙП ВПРАВО</span>'+ev.right.label+'</div>'
    +'</div></div>';
}
function setBack(el){el.classList.remove("active","shift","grab","burning");el._ev=null;
  el.innerHTML='<div class="cfinner">'+backHTML()+'</div>';}
function setActive(el,ev){
  el.classList.add("active"); el.classList.toggle("shift",!!ev.shift);
  el.classList.toggle("linear",!!ev.linear);
  el.innerHTML='<div class="cfinner">'+cardHTML(ev)+'</div>'; el._ev=ev; cActive=el;
  App.currentCard=ev; App.swipeUnlocked=false;
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
  cfCards.forEach(function(c,e){
    if(e===centerIndex) setActive(c,CASE.events[CASE.start]); else setBack(c);
  });
  cLayout(false);
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
  lock.innerHTML='<button class="card-lock-btn" id="play-gems-ring">'
    +'<span class="clb-ico">🔍</span><span>Найти улики</span></button>'
    +'<div class="card-lock-hint">⟵ свайп заблокирован ⟶</div>';
  pad.appendChild(lock);
  lock.querySelector('#play-gems-ring').addEventListener('click',function(){
    try{Sound.tap();}catch(_){} openHintGame(App.currentCard||{});
  });
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
}
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
  if(!resolve) setActive(cfCards[centerIndex],CASE.events[nextId]);
  cLayout(true);
  setTimeout(function(){
    if(resolve) showEnding(computeEnding(CState.flags));
    else if(c0!==cfCards[centerIndex]) setBack(c0);
    cBusy=false;
  }, Math.max(560,SPIN_DUR+40));
}
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
function addRapport(n){
  const p=App.profile; if(!p) return;
  p.rapport=clamp((p.rapport||0)+n,-10,20); saveProfile();
}
function rapportTitle(){
  const r=(App.profile&&App.profile.rapport)||0;
  if(r>=12) return 'Напарник';
  if(r>=6)  return 'Доверие';
  if(r>=1)  return 'Интерес';
  if(r<=-3) return 'Раздражение';
  return 'Новичок';
}
function cApplyOption(o){
  if(o.set) Object.assign(CState.flags,o.set);
  if(o.evidence) cAddEvidence(o.evidence);
  try{ addRapport(o.bad?-1:1); }catch(_){}
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

function showEnding(r){
  const endEl=document.getElementById("ending");if(!endEl)return;
  const seal=document.getElementById("e-seal");if(seal){seal.className="seal "+r.kind;seal.textContent=r.mark;}
  const ver=document.getElementById("e-verdict");if(ver){ver.className="e-verdict "+r.kind;ver.textContent=r.verdict;}
  const txt=document.getElementById("e-text");if(txt)txt.textContent=r.text;
  const meta=document.getElementById("e-meta");if(meta)meta.innerHTML="Сходимость: <b>"+r.align+" / 3</b> · улик: <b>"+CState.evidence.length+"</b> · Сдвиг: <b>"+rapportTitle()+"</b>";
  if(_progEl)_progEl.style.width="100%";
  haptic(r.kind==="fail"?"shift":"burn"); endEl.classList.add("show");
  const _rb=document.getElementById("e-restart");
  if(_rb){
    const _hn=CAMPAIGN&&(_caseIdx+1)<CAMPAIGN.cases.length;
    _rb.textContent=_hn?"Следующее дело →":"Играть заново";
  }
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
  if(restartBtn) restartBtn.addEventListener("click",function(){
    const _hn=CAMPAIGN&&(_caseIdx+1)<CAMPAIGN.cases.length;
    if(_hn){ loadCaseByIndex(_caseIdx+1); computeEnding._invalidate=true; }
    restartCarousel();
  });
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
  cSetProgress(); buildBacks(); initEvPanel();
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
const SHOP=[
  {k:'energy', icon:'⚡', name:'Энергия', desc:'+3 энергии', price:30,
    buy(){ addEnergy(3); }},
  {k:'hint',   icon:'🔍', name:'Подсказка', desc:'Открыть свайп', price:50,
    buy(){ if(!App.swipeUnlocked) unlockSwipe(); }},
  {k:'shuffle',icon:'🔀', name:'Перетасовка', desc:'Сменить дело', price:20,
    buy(){ nextCard(); }},
  {k:'booster',icon:'💥', name:'Бустер-бомба', desc:'Для аркады', price:40,
    buy(){ App.profile.boosters=(App.profile.boosters||0)+1; saveProfile(); }}
];
function renderShop(){
  const g=$('#shop-grid'); g.innerHTML='';
  SHOP.forEach(it=>{
    const item=el('div','shop-item',`
      <div class="si-icon">${it.icon}</div>
      <div class="si-name">${it.name}</div>
      <div class="si-desc">${it.desc}</div>
      <div class="si-price">${it.price} ◈</div>`);
    item.onclick=()=>{
      if(App.profile.credits<it.price){ Sound.error(); toast('Мало кредитов','Нужно '+it.price+' ◈','✗'); return; }
      addCredits(-it.price); it.buy(); Sound.coin(); vibrate(10);
      toast('Куплено',it.name,'🛍'); renderShop();
    };
    g.appendChild(item);
  });
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
  $('#hint-footer').textContent=mission.label;
  if(window.BgFx) BgFx.pause();
  if(window.Match3){
    Match3.start($('#hint-vp'), {
      mission,
      boosters:App.profile.boosters||0,
      onWin:()=>{ modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); unlockSwipe(); },
      onLose:()=>{ /* поражение усложняет путь: -1 кофе, репутация */
        try{ const p=App.profile; if(p){ p.energy=clamp(p.energy-1,0,p.maxEnergy); addRapport(-1); renderHUD(); saveProfile(); } }catch(_){}
        if(window.toast) toast('Улика ускользнула','Сдвиг недоволен. Попробуй снова.','\ud83d\udd0d');
      }
    });
  }
  $('#hint-close').onclick=()=>{ Sound.tap(); modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); Match3&&Match3.stop(); };
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

