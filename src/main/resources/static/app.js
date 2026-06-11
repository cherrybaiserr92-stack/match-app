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
  tab:'cases'
};

const DEFAULT_PROFILE = {
  level:1, xp:0, energy:5, maxEnergy:5, credits:0,
  casesSolved:0, streak:0, prestige:0, mapNode:0,
  skills:{ insight:1, tech:1, charisma:1, nerve:1 },
  achievements:[], dailyStreak:0, lastDaily:null, sound:true
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
const SPLASH_BG = '/img/splash.jpg';   // фон №1 (экран загрузки)
const LOGIN_BG  = '/img/login.jpg';    // фон №2 (экран входа)

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
  if(window.BgFx) BgFx.init();
  Icons.paint();
  buildDeck();
  renderCard();
  renderHUD();
  renderMap();
  renderGameList();
  renderProfile();
  renderShop();
  bindNav();
  bindSoundBtn();
  checkDaily();
}

/* ── навигация ─────────────────────────────────── */
function bindNav(){
  $$('.nb').forEach(b=>{
    b.onclick=()=>{
      const tab=b.dataset.tab; if(tab===App.tab) return;
      Sound.nav(); vibrate(8);
      App.tab=tab;
      $$('.nb').forEach(x=>x.classList.toggle('active',x===b));
      $$('.tab-pane').forEach(p=>p.classList.toggle('active',p.id==='tab-'+tab));
      if(tab==='map') renderMap();
      if(tab==='profile') renderProfile();
    };
  });
}

function bindSoundBtn(){
  const btn=$('#sound-btn');
  btn.textContent=Sound.isOn()?'🔊':'🔇';
  btn.onclick=()=>{ const on=Sound.toggle(); btn.textContent=on?'🔊':'🔇'; if(on)Sound.tap(); };
}

/* ── HUD ───────────────────────────────────────── */
function renderHUD(){
  const p=App.profile;
  $('#hud-energy').textContent=p.energy;
  $('#hud-credits').textContent=p.credits;
  const need=xpNeeded(p.level);
  $('#xp-fill').style.width=clamp(p.xp/need*100,0,100)+'%';
  $('#xp-info').textContent=`УР ${p.level} · ${p.xp}/${need}`;
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
function addEnergy(n){ const p=App.profile; p.energy=clamp(p.energy+n,0,p.maxEnergy); renderHUD(); saveProfile(); }

/* ═══════════════════════════════════════════════
   BOOT
═══════════════════════════════════════════════ */
window.addEventListener('DOMContentLoaded',()=>{
  $('#sound-btn'); // noop
  runSplash().catch(err=>{ console.error(err); decideEntry(); });
});

/* ═══════════════════════════════════════════════
   СЦЕНАРИЙ + КОЛОДА
═══════════════════════════════════════════════ */
async function loadScenario(){
  if(App.scenario) return App.scenario;
  const res=await fetch('/scenarios/detective.json');
  if(!res.ok) throw new Error('scenario '+res.status);
  App.scenario=await res.json();
  return App.scenario;
}

function buildDeck(){
  const sc=App.scenario;
  if(!sc||!sc.cards){ App.deck=[]; return; }
  App.deck=sc.cards.slice();
  App.cardIndex=App.profile.mapNode % App.deck.length;
}

/* ═══════════════════════════════════════════════
   РЕНДЕР КАРТОЧКИ ДЕЛА
═══════════════════════════════════════════════ */
function renderCard(){
  const zone=$('#swipe-zone');
  zone.querySelector('.case-card')?.remove();
  if(!App.deck.length){ return; }

  const c=App.deck[App.cardIndex];
  App.currentCard=c; App.swipeUnlocked=false;

  const type=c.type||'evidence';
  const card=el('div','case-card card-enter ct-'+type);
  card.innerHTML=`
    <div class="stamp-wrap stamp-left"><div class="stamp stamp-deny-text">${c.leftStamp||'ОТКАЗ'}</div></div>
    <div class="stamp-wrap stamp-right"><div class="stamp stamp-approve-text">${c.rightStamp||'ПРИНЯТЬ'}</div></div>
    <div class="stamp-wrap stamp-up"><div class="stamp stamp-special-text">СПЕЦ</div></div>
    <div class="card-head">
      <span class="card-act">Дело №${(App.cardIndex+1).toString().padStart(3,'0')}</span>
      <span class="card-type-badge">${typeLabel(type)}</span>
    </div>
    <div class="card-divider"></div>
    <div class="card-body">
      <div class="card-icon-box">${c.icon||'🗂'}</div>
      <div class="card-case-title">${c.title||'Без названия'}</div>
      <div class="card-text">${c.text||''}</div>
    </div>
    <div class="card-actions-area" id="card-actions"></div>
  `;
  zone.appendChild(card);
  renderCardActions(card,c);
  bindSwipe(card,c);
  Sound.tap();
}

function typeLabel(t){
  return ({crime:'Преступление',suspect:'Подозреваемый',evidence:'Улика',
           witness:'Свидетель',revelation:'Озарение',ending:'Финал'})[t]||'Улика';
}

function renderCardActions(card,c){
  const a=card.querySelector('#card-actions');
  if(App.swipeUnlocked){
    a.innerHTML=`
      <div class="swipe-indicator swipe-unlocked">
        <span class="si-deny">◄ ${c.leftLabel||'Отказать'}</span>
        <span class="si-center">${Icons.get('arrows')}</span>
        <span class="si-approve">${c.rightLabel||'Принять'} ►</span>
      </div>
      ${c.special?`<span class="si-special">▲ Свайп вверх — спецприём</span>`:''}`;
  }else{
    a.innerHTML=`
      <button class="btn-play-gems" id="play-gems">${Icons.get('gem')}<span>Найти улики</span></button>
      <div class="swipe-indicator"><span class="si-locked">${Icons.get('lock')} Свайп заблокирован</span></div>`;
    a.querySelector('#play-gems').onclick=()=>{ Sound.tap(); openHintGame(c); };
  }
}

/* разблокировка свайпа после мини-игры */
function unlockSwipe(){
  App.swipeUnlocked=true;
  vibrate(20); Sound.booster();
  const card=$('#swipe-zone .case-card');
  if(card){ renderCardActions(card,App.currentCard);
    const hint=App.currentCard.hint;
    if(hint){ const hp=el('div','hint-revealed-panel',
      `<span class="hrp-icon">🔍</span><span class="hrp-text">${hint}</span>`);
      card.querySelector('.card-body').appendChild(hp); } }
}

/* ═══════════════════════════════════════════════
   СВАЙПЫ (left / right / up = спецприём)
═══════════════════════════════════════════════ */
function bindSwipe(card,c){
  let sx=0,sy=0,dx=0,dy=0,drag=false;
  const TH=90, UPTH=110;

  const start=(x,y)=>{ if(!App.swipeUnlocked){ return; } drag=true; sx=x; sy=y; dx=dy=0; card.style.transition='none'; };
  const move=(x,y)=>{
    if(!drag) return;
    dx=x-sx; dy=y-sy;
    const rot=dx/18;
    card.style.transform=`translate(-50%,-50%) translate(${dx}px,${dy*0.4}px) rotate(${rot}deg)`;
    card.classList.toggle('tilt-left',dx<-30);
    card.classList.toggle('tilt-right',dx>30);
    card.classList.toggle('tilt-up',c.special&&dy<-40&&Math.abs(dx)<60);
    setStampOpacity(card,dx,dy,c);
    if(Math.abs(dx)>TH||(c.special&&dy<-UPTH)) vibrate(6);
  };
  const end=()=>{
    if(!drag) return; drag=false;
    card.style.transition='transform .35s cubic-bezier(.4,0,.2,1), opacity .35s ease';
    if(c.special && dy<-UPTH && Math.abs(dx)<70){ flySpecial(card,c); return; }
    if(dx>TH){ flyOut(card,'right',c); return; }
    if(dx<-TH){ flyOut(card,'left',c); return; }
    // вернуть на место
    card.style.transform=`translate(-50%,-50%) rotate(-.4deg)`;
    card.className='case-card ct-'+(c.type||'evidence');
    resetStamps(card);
  };

  card.addEventListener('pointerdown',e=>{ start(e.clientX,e.clientY); card.setPointerCapture?.(e.pointerId); });
  card.addEventListener('pointermove',e=>move(e.clientX,e.clientY));
  card.addEventListener('pointerup',end);
  card.addEventListener('pointercancel',end);
}

function setStampOpacity(card,dx,dy,c){
  const l=card.querySelector('.stamp-left'), r=card.querySelector('.stamp-right'), u=card.querySelector('.stamp-up');
  l.style.opacity=clamp(-dx/90,0,1); r.style.opacity=clamp(dx/90,0,1);
  u.style.opacity=c.special?clamp(-dy/110,0,1):0;
}
function resetStamps(card){ card.querySelectorAll('.stamp-wrap').forEach(s=>s.style.opacity=0); }

function flyOut(card,dir,c){
  const off=dir==='right'?window.innerWidth:-window.innerWidth;
  card.style.transform=`translate(-50%,-50%) translate(${off}px,40px) rotate(${dir==='right'?22:-22}deg)`;
  card.style.opacity='0';
  Sound.swipe(dir); vibrate(12);
  spawnTrail(dir);
  setTimeout(()=>resolveChoice(c,dir==='right'?'right':'left'),320);
}
function flySpecial(card,c){
  card.style.transform=`translate(-50%,-50%) translateY(-${window.innerHeight}px) rotate(-3deg)`;
  card.style.opacity='0';
  Sound.special(); vibrate([10,30,10]);
  setTimeout(()=>resolveChoice(c,'special'),320);
}

/* ═══════════════════════════════════════════════
   РЕЗУЛЬТАТ ВЫБОРА + каскад улик
═══════════════════════════════════════════════ */
function resolveChoice(c,dir){
  const branch = dir==='special' ? (c.special||c.right) : (dir==='right'?c.right:c.left);
  if(!branch){ nextCard(); return; }

  // каскад: промежуточная карточка-вопрос
  if(branch.followup){
    const fc=branch.followup; fc.type=fc.type||'revelation'; fc._followOf=c;
    App.deck.splice(App.cardIndex+1,0,fc);
  }

  applyOutcome(branch);
  showResultOverlay(branch,dir);
}

function applyOutcome(b){
  const o=b.outcome||b; const p=App.profile;
  if(o.xp) addXP(o.xp);
  if(o.credits) addCredits(o.credits);
  if(o.energy) addEnergy(o.energy);
  if(o.prestige){ p.prestige+=o.prestige; }
  if(o.skill && p.skills[o.skill]!=null) p.skills[o.skill]+=(o.skillUp||1);
  if(o.solved){ p.casesSolved++; p.streak++; advanceMap(); }
  saveProfile();
}

function showResultOverlay(b,dir){
  const card=el('div','case-card ct-revelation');
  const o=b.outcome||b;
  const ok=dir!=='left';
  card.innerHTML=`<div class="result-overlay">
      <div class="ro-stamp-text">${ok?'УЛИКА ПОЛУЧЕНА':'ВЕРСИЯ ОТКЛОНЕНА'}</div>
      <div class="ro-text">${b.result||b.text||''}</div>
      <div class="ro-rewards">
        ${o.xp?`<span class="ro-chip ro-xp">+${o.xp} XP</span>`:''}
        ${o.credits?`<span class="ro-chip ro-cr">+${o.credits} ◈</span>`:''}
        ${o.prestige?`<span class="ro-chip ro-xp">+${o.prestige} престиж</span>`:''}
      </div>
      <button class="btn btn-bronze" id="ro-next" style="max-width:200px">Дальше</button>
    </div>`;
  $('#swipe-zone').appendChild(card);
  if(ok){ Sound.approve(); if(o.solved) confetti(); } else Sound.deny();
  card.querySelector('#ro-next').onclick=()=>{ Sound.tap(); card.remove(); nextCard(); };
}

function nextCard(){
  App.cardIndex=(App.cardIndex+1)%App.deck.length;
  App.profile.mapNode=App.cardIndex;
  saveProfile();
  renderCard();
}

/* ═══════════════════════════════════════════════
   КОНФЕТТИ (золотые улики)
═══════════════════════════════════════════════ */
function confetti(){
  const colors=['#ffcf6b','#f0a93a','#6be0ff','#35d49b'];
  for(let i=0;i<28;i++){
    const c=el('div','confetti');
    c.style.left=(40+Math.random()*20)+'vw';
    c.style.top='40vh';
    c.style.background=colors[i%colors.length];
    document.body.appendChild(c);
    const ang=Math.random()*Math.PI*2, dist=120+Math.random()*200;
    const ax=Math.cos(ang)*dist, ay=Math.sin(ang)*dist-200;
    c.animate([
      {transform:'translate(0,0) rotate(0)',opacity:1},
      {transform:`translate(${ax}px,${ay+window.innerHeight*0.5}px) rotate(${720*Math.random()}deg)`,opacity:0}
    ],{duration:1100+Math.random()*600,easing:'cubic-bezier(.2,.7,.3,1)'}).onfinish=()=>c.remove();
  }
}
function spawnTrail(dir){
  const zone=$('#swipe-zone'); const r=zone.getBoundingClientRect();
  for(let i=0;i<8;i++){ const t=el('div','swipe-trail');
    const sz=4+Math.random()*8; t.style.width=t.style.height=sz+'px';
    t.style.background='rgba(240,169,58,'+(0.3+Math.random()*0.3)+')';
    t.style.left=(r.width/2+(dir==='right'?40:-40)+Math.random()*30-15)+'px';
    t.style.top=(r.height/2+Math.random()*60-30)+'px';
    zone.appendChild(t);
    t.animate([{opacity:.8,transform:'scale(1)'},{opacity:0,transform:'scale(0) translateY(20px)'}],
      {duration:500+Math.random()*300}).onfinish=()=>t.remove(); }
}

/* ═══════════════════════════════════════════════
   КАРТА ПРОГРЕССА
═══════════════════════════════════════════════ */
const CHAPTERS=[
  {title:'Глава I · Пропавший экспонат', levels:5},
  {title:'Глава II · Тень музея',        levels:6},
  {title:'Глава III · Ночной свидетель', levels:6},
  {title:'Глава IV · Двойная игра',      levels:7},
  {title:'Глава V · Финал',              levels:6}
];

function totalLevels(){ return CHAPTERS.reduce((s,c)=>s+c.levels,0); }

function renderMap(){
  const inner=$('#map-inner'); const svg=$('#map-path');
  inner.querySelectorAll('.map-node,.map-chapter').forEach(e=>e.remove());

  const total=totalLevels();
  const W=inner.clientWidth||window.innerWidth;
  const rowH=120, padTop=40;
  const H=padTop+total*rowH+120;
  inner.style.height=H+'px';
  svg.setAttribute('viewBox',`0 0 ${W} ${H}`);

  const cur=App.profile.mapNode||0;
  let idx=0, pts=[], pathD='';

  CHAPTERS.forEach((ch,ci)=>{
    // заголовок главы
    const chY=padTop+idx*rowH;
    const unlocked = idx<=cur;
    const head=el('div','map-chapter'+(unlocked?'':' mc-locked'),
      `<div class="mc-title">${ch.title}</div><div class="mc-sub">${ch.levels} уровней</div>`);
    head.style.left='50%'; head.style.top=(chY)+'px';
    inner.appendChild(head);

    for(let l=0;l<ch.levels;l++){
      const y=padTop+ (idx+0.6+l)*rowH + (l===0?40:0);
      const x=W*(0.5+0.30*Math.sin(idx*0.9));
      pts.push({x,y});
      const state = idx<cur?'done':idx===cur?'current':'locked';
      const node=el('div','map-node '+state);
      if(state==='locked') node.innerHTML=Icons.get('lock');
      else node.textContent=(idx+1);
      node.style.left=x+'px'; node.style.top=y+'px';
      if(state!=='locked'){
        node.onclick=()=>{ Sound.tap(); vibrate(8);
          if(state==='current'){ goToTab('cases'); }
          else toast('Пройдено','Уровень '+(idx+1)+' завершён','✓'); };
      }else{
        node.onclick=()=>{ Sound.error(); vibrate(15); toast('Закрыто','Пройдите предыдущие уровни','🔒'); };
      }
      inner.appendChild(node);
      idx++;
    }
  });

  // извилистый путь
  pts.forEach((p,i)=>{ pathD+= i===0?`M ${p.x} ${p.y}`:` L ${p.x} ${p.y}`; });
  svg.innerHTML=`
    <path d="${pathD}" fill="none" stroke="rgba(255,255,255,.07)" stroke-width="6" stroke-linecap="round"/>
    <path d="${pathD}" fill="none" stroke="url(#mg)" stroke-width="4" stroke-linecap="round"
          stroke-dasharray="${(cur/total)*100000}" pathLength="100000"/>
    <defs><linearGradient id="mg" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#ffcf6b"/><stop offset="1" stop-color="#b3741c"/></linearGradient></defs>`;
}

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
  const mission = card.mission || pickMission();
  $('#hint-footer').textContent=mission.label;
  if(window.BgFx) BgFx.pause();
  if(window.Match3){
    Match3.start($('#hint-vp'), {
      mission,
      boosters:App.profile.boosters||0,
      onWin:()=>{ modal.classList.add('hidden'); if(window.BgFx)BgFx.resume(); unlockSwipe(); },
      onLose:()=>{ /* остаётся закрытым */ }
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
