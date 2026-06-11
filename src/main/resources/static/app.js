'use strict';
// ═══════════════════════════════════════════════
//  СДВИГ · app.js v5
// ═══════════════════════════════════════════════
const tg=$=>document.getElementById($);
const TG=window.Telegram?.WebApp??null;

// ── State ──────────────────────────────────────
let user=null,scenarios=null,card=null,cardId='act1_scene1';
let cardLocked=true,swipeDir=null,activeTab='cases';
let gameDestroy=null,dailyClaimed=false;

const ACH=[
    {id:'r5', check:p=>p.rank>=5,           icon:'🏅',title:'АГЕНТ В ДЕЛЕ', desc:'Ранг 5'},
    {id:'r10',check:p=>p.rank>=10,          icon:'🏆',title:'ЭЛИТА',        desc:'Ранг 10'},
    {id:'c10',check:p=>(p.totalCases||0)>=10,icon:'📂',title:'ДЕТЕКТИВ',    desc:'10 дел'},
    {id:'c50',check:p=>(p.totalCases||0)>=50,icon:'🗃️',title:'АРХИВАРИУС',  desc:'50 дел'},
    {id:'s3', check:p=>(p.streak||0)>=3,    icon:'🔥',title:'НА СЕРИИ',    desc:'3 дня подряд'},
    {id:'sk1',check:p=>p.skill1>=3,         icon:'🧠',title:'ПРОНИЦАТЕЛЬ',  desc:'Проницательность Lv.3'},
];
const earned=new Set(JSON.parse(localStorage.getItem('sdvig_ach')||'[]'));

// ── OIDC config (from meta or backend) ────────
const OIDC_CLIENT_ID = document.querySelector('meta[name="tg-client-id"]')?.content || '';

// ── Boot ───────────────────────────────────────
document.addEventListener('DOMContentLoaded',async()=>{
    if(TG)try{TG.expand();TG.ready();}catch(e){}

    // Install auth handler
    window.__tgH = u=>{showScreen('splash-screen');widgetAuth(u);};
    if(window.__tgP){window.__tgH(window.__tgP);window.__tgP=null;}

    // Show OIDC button if configured
    if(OIDC_CLIENT_ID) tg('oidc-btn-wrap')?.classList.remove('hidden');

    // Widget tip after 6s
    setTimeout(()=>{
        const a=tg('tg-widget-area'),tip=tg('tg-tip');
        if(a&&tip&&!a.querySelector('iframe'))tip.classList.remove('hidden');
    },6000);

    injectIcons();
    await runSplash();
});

// ── Icons ──────────────────────────────────────
function injectIcons(){
    setIcon(tg('ic-en'),  'bolt');
    setIcon(tg('ic-cr'),  'diamond');
    setIcon(tg('ic-rk'),  'shield');
    setIcon(tg('ni-cases'),  'folder');
    setIcon(tg('ni-games'),  'gamepad');
    setIcon(tg('ni-map'),    'search');
    setIcon(tg('ni-profile'),'badge');
    setIcon(tg('ni-shop'),   'bag');
    setIcon(tg('back-ic'),   'arrowLeft');
    setIcon(tg('hm-ic'),     'lock');
}

// ── Cinematic splash ───────────────────────────
async function runSplash(){
    const fill=tg('spl-fill'),emb=tg('spl-emblem'),titleEl=tg('spl-title');
    const flash=tg('splash-flash');

    await wait(180);
    emb.classList.add('show');
    Sound.splashImpact();
    await wait(580);

    // Letter-by-letter title
    for(const[i,ch] of [...'СДВИГ'].entries()){
        const s=document.createElement('span');
        s.className='stl';s.textContent=ch;titleEl.appendChild(s);
        await wait(10);s.classList.add('in');s.style.animationDelay='0s';
        await wait(72);
    }
    await wait(200);

    // Load bar
    setSplash('Загрузка сценариев…');
    for(const[w,ms] of [[25,200],[60,250],[85,300],[99,180]]){
        fill.style.width=w+'%'; await wait(ms);
    }
    fill.style.width='100%';
    await wait(220);

    // 3 pulses
    Sound.splashImpact();
    for(let i=0;i<3;i++){
        emb.classList.add('pulse-once');
        emb.style.boxShadow='0 0 0 20px rgba(200,134,10,0),0 12px 40px rgba(0,0,0,.5)';
        await wait(380);emb.classList.remove('pulse-once');await wait(80);
    }
    await wait(120);

    // Cinematic exit — flash
    Sound.splashExit();
    flash.style.opacity='1';
    await wait(280);

    // Decide next screen
    if(TG?.initData?.length>0){setSplash('Telegram…');webappAuth();}
    else{showScreen('login-screen');initLogin();}

    await wait(120);
    flash.style.transition='opacity .5s ease';flash.style.opacity='0';
}
function setSplash(t){const e=tg('spl-text');if(e)e.textContent=t;}

// ── Screen ─────────────────────────────────────
function showScreen(id){
    document.querySelectorAll('.screen').forEach(s=>s.classList.remove('active'));
    tg(id).classList.add('active');
}

// ── Auth ───────────────────────────────────────
function initLogin(){
  const status = document.getElementById('tg-status');
  const gb = document.getElementById('guest-btn');
  if(gb){ gb.style.pointerEvents='auto'; gb.disabled=false; }

  const oidcWrap = document.getElementById('oidc-btn-wrap');
  const widgetArea = document.getElementById('tg-widget-area');

  if(OIDC_CLIENT_ID) {
      if(oidcWrap) oidcWrap.classList.remove('hidden');
      if(widgetArea) widgetArea.classList.add('hidden');
      if(status) status.textContent = '';
  } else {
      const BOT = window.SDVIG_BOT_USERNAME || 'sdvig_game_bot';
      if(widgetArea && BOT) {
          if(status) status.textContent='';
          const sc=document.createElement('script');
          sc.src='https://telegram.org/js/telegram-widget.js?22';
          sc.async=true;
          sc.setAttribute('data-telegram-login',BOT);
          sc.setAttribute('data-size','large');
          sc.setAttribute('data-radius','12');
          sc.setAttribute('data-request-access','write');
          sc.setAttribute('data-onauth','onTelegramAuth(user)');
          widgetArea.innerHTML=''; widgetArea.appendChild(sc);
      } else {
          if(status) status.textContent='Войдите через Telegram (в приложении) или как гость.';
      }
  }
}

window.onTelegramAuth=function(user){
  fetch('/api/game/auth/widget',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(user)})
  .then(r=>{if(!r.ok)throw 0;return r.json();})
  .then(onLogin)
  .catch(()=>{toast('💡','Ошибка входа','Попробуйте как гость');});
};

function webappAuth(){
    fetch('/api/game/auth/webapp',{method:'POST',headers:{'Content-Type':'application/json'},
        body:JSON.stringify({initData:TG.initData,initDataUnsafe:TG.initDataUnsafe})})
    .then(r=>{if(!r.ok)throw 0;return r.json();}).then(onLogin)
    .catch(()=>showError('Ошибка WebApp-авторизации.\nПроверьте токен бота в Railway.'));
}

function widgetAuth(u){
    const p={};for(const[k,v] of Object.entries(u))p[k]=String(v);
    fetch('/api/game/auth/widget',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(p)})
    .then(r=>{if(!r.ok)return r.text().then(t=>{throw t;});return r.json();}).then(onLogin)
    .catch(e=>showError(typeof e==='string'?e:'Ошибка виджета.\n@BotFather → /setdomain'));
}

function oidcLogin(){
    const state=Math.random().toString(36).slice(2);
    sessionStorage.setItem('oidc_state',state);
    const redirect=encodeURIComponent(location.origin+'/auth/oidc-callback');
    const url=`https://id.telegram.org/auth?response_type=code&client_id=${OIDC_CLIENT_ID}&redirect_uri=${redirect}&scope=userinfo&state=${state}`;
    const popup=window.open(url,'TgOIDC','width=520,height=580,popup=1');
    window.addEventListener('message',function h(e){
        if(e.data?.type!=='tg_oidc')return;
        window.removeEventListener('message',h);
        popup?.close();
        if(e.data.error)return showError('OIDC ошибка: '+e.data.error);
        if(e.data.state!==state)return showError('Ошибка состояния OIDC');
        showScreen('splash-screen');setSplash('Авторизация…');
        fetch('/api/game/auth/oidc',{method:'POST',headers:{'Content-Type':'application/json'},
            body:JSON.stringify({code:e.data.code})})
        .then(r=>{if(!r.ok)throw 0;return r.json();}).then(onLogin)
        .catch(()=>showError('Ошибка OIDC авторизации'));
    });
}
window.oidcLogin=oidcLogin;

function guestLogin(){
    Sound.click();
    let gid=localStorage.getItem('sdvig_gid');
    if(!gid){gid='g'+Date.now();localStorage.setItem('sdvig_gid',gid);}
    showScreen('splash-screen');setSplash('Гостевой вход…');
    fetch('/api/game/auth/guest',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({deviceId:gid})})
    .then(r=>{if(!r.ok)throw 0;return r.json();}).then(onLogin)
    .catch(()=>{
        // Full offline fallback
        onLogin({providerId:'guest:'+gid,firstName:'Гость',username:'guest',
            energy:100,credits:150,rank:1,xp:0,skill1:1,skill2:1,
            detectiveLvl:1,totalCases:0,streak:0,archetype:'detective'});
    });
}
window.guestLogin=guestLogin;

function showError(m){tg('err-msg').textContent=m;showScreen('error-screen');}

// ── Login success ──────────────────────────────
async function onLogin(profile){
    user=profile;
    await Sound.init();
    updateHUD(profile);updateProfile(profile);renderAchGrid();
    showScreen('main-screen');
    initSwipe();initParallax();initRain();
    await loadScenarios();
    loadCard(cardId);
    checkDailyBonus();
    updateShopAfford();
    vib(30);
}

// ── Sound toggle ───────────────────────────────
function toggleSound(){
    const on=Sound.toggle();
    tg('snd-btn').textContent=on?'🔊':'🔇';
}
window.toggleSound=toggleSound;

// ── Scenarios ──────────────────────────────────
async function loadScenarios(){
    if(scenarios)return;
    try{const r=await fetch('/scenarios/detective.json');scenarios=await r.json();}
    catch{scenarios={cards:{}};}
}
function getCard(id){return scenarios?.cards?.[id]??null;}

// ── Card load ──────────────────────────────────
function loadCard(id){
    const c=getCard(id);if(!c){loadCard('act1_scene1');return;}
    card=c;cardId=id;cardLocked=!c.isEnding;

    const el=tg('main-card');
    el.className='case-card card-in ct-'+(c.type||'evidence');
    tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
    tg('result-overlay').classList.add('hidden');

    tg('cc-type').textContent=fmtType(c.type);
    tg('cc-badge').textContent=c.actTitle||(c.act?'АКТ '+c.act:'');
    tg('cc-icon').textContent=c.icon||'🔍';
    tg('cc-title').textContent=c.title||'';

    // Ink reveal on text
    const tx=tg('cc-text');
    tx.style.animation='none';tx.textContent=c.text||'';
    void tx.offsetWidth;
    tx.style.animation='';

    renderActions();
    Sound.cardLoad();vib(15);
}

function fmtType(t){
    return ({crime:'ПРЕСТУПЛЕНИЕ',evidence:'УЛИКА',suspect:'ПОДОЗРЕВАЕМЫЙ',
        witness:'СВИДЕТЕЛЬ',testimony:'ПОКАЗАНИЯ',mystery:'ТАЙНА',
        action:'ОПЕРАЦИЯ',revelation:'ПРОРЫВ',briefing:'СВОДКА',
        ending:'ФИНАЛ',ending_bad:'ФИНАЛ',chase:'ПОГОНЯ'}[t]||(t||'ДЕЛО').toUpperCase());
}

// ── Actions panel ──────────────────────────────
function renderActions(){
    const a=tg('cc-actions');
    const hasSpecial=(user?.skill1||1)>=3&&card?.specialOption;

    if(cardLocked){
        a.innerHTML=`
            <div class="lock-panel">
                <div class="lp-icon">${icon('lock')}</div>
                <div class="lp-body">
                    <div class="lp-title">Свайп заблокирован</div>
                    <div class="lp-sub">Пройди Самоцветы чтобы принять решение</div>
                </div>
            </div>
            <button class="btn-play" onclick="openCardGame()">
                ${icon('gamepad')} Играть в Самоцветы
            </button>
            <div class="swipe-locked">${icon('lock')} Свайп недоступен</div>`;
    } else {
        const hint=card?.hint;
        a.innerHTML=`
            ${hint?`<div class="hint-panel"><span class="hp-icon">💡</span><p class="hp-text">${hint}</p></div>`:''}
            <div class="swipe-hint">
                <span class="sh-no">← ${card?.leftOption||'ОТКЛОНИТЬ'}</span>
                <span class="sh-mid">${icon('lockOpen')}</span>
                <span class="sh-ok">${card?.rightOption||'ОДОБРИТЬ'} →</span>
            </div>
            ${hasSpecial?`<div class="sh-up">↑ ОСОБЫЙ ПРИЁМ (−10⚡)</div>`:''}`;
    }
}

// ── Swipe engine ───────────────────────────────
function initSwipe(){
    const el=tg('main-card');
    let sx=0,sy=0,cx=0,cy=0,dragging=false,lx=0,vel=0,lt=0;

    const start=e=>{
        if(!tg('result-overlay').classList.contains('hidden'))return;
        dragging=true;sx=gx(e);sy=gy(e);lx=sx;lt=Date.now();
        el.style.transition='none';el.style.animationPlayState='paused';
    };
    const move=e=>{
        if(!dragging)return;e.preventDefault();
        cx=gx(e);cy=gy(e);
        const now=Date.now();vel=(cx-lx)/Math.max(1,now-lt);lx=cx;lt=now;
        const dx=cx-sx,dy=cy-sy;
        const rot=dx/18;
        el.style.transform=`rotate(${rot}deg) translateX(${dx}px) translateY(${Math.min(0,dy*.3)}px)`;
        const r=Math.min(1,Math.abs(dx)/80);
        const ru=Math.min(1,Math.max(0,-dy-40)/60);

        if(dy<-40&&Math.abs(dx)<60){
            // Swipe UP
            el.classList.remove('tilt-l','tilt-r');el.classList.add('tilt-u');
            tg('s-sp').style.opacity=ru;tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';
        } else if(dx<-28){
            el.classList.add('tilt-l');el.classList.remove('tilt-r','tilt-u');
            tg('s-no').style.opacity=r;tg('s-ok').style.opacity='0';tg('s-sp').style.opacity='0';
        } else if(dx>28){
            el.classList.add('tilt-r');el.classList.remove('tilt-l','tilt-u');
            tg('s-ok').style.opacity=r;tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
        } else {
            el.classList.remove('tilt-l','tilt-r','tilt-u');
            tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
        }
    };
    const end=()=>{
        if(!dragging)return;dragging=false;
        el.style.animationPlayState='running';
        const dx=cx-sx,dy=cy-sy,T=85,V=0.36;
        el.style.transition='transform .3s ease';
        if(dy<-100&&Math.abs(dx)<80)      flyCard('up');
        else if(dx<-T||vel<-V)            flyCard('left');
        else if(dx>T||vel>V)              flyCard('right');
        else resetCardPos();
    };

    el.addEventListener('touchstart',start,{passive:true});
    el.addEventListener('mousedown',start);
    window.addEventListener('touchmove',move,{passive:false});
    window.addEventListener('mousemove',move);
    window.addEventListener('touchend',end);
    window.addEventListener('mouseup',end);
}
const gx=e=>e.touches?e.touches[0].clientX:e.clientX;
const gy=e=>e.touches?e.touches[0].clientY:e.clientY;

function resetCardPos(){
    const el=tg('main-card');
    el.style.transform='rotate(-.4deg)';
    el.classList.remove('tilt-l','tilt-r','tilt-u');
    tg('s-ok').style.opacity='0';tg('s-no').style.opacity='0';tg('s-sp').style.opacity='0';
}

function flyCard(dir){
    if(cardLocked){
        const el=tg('main-card');
        el.classList.add('shake');setTimeout(()=>el.classList.remove('shake'),600);
        resetCardPos();Sound.locked();vib([80,40,80]);
        toast('🎮','ЗАБЛОКИРОВАНО','Сначала пройди Самоцветы!');
        return;
    }
    const hasSpecial=(user?.skill1||1)>=3&&card?.specialOption;
    if(dir==='up'&&!hasSpecial){resetCardPos();return;}

    // Dust particles
    spawnDust(dir);

    // Stamp animation
    const sMap={left:'s-no',right:'s-ok',up:'s-sp'};
    const sEl=tg(sMap[dir]);
    if(sEl){sEl.style.opacity='1';sEl.querySelector('.stamp')?.classList.add('land');}

    if(dir==='left')Sound.swipeL();else Sound.swipeR();
    vib(25);swipeDir=dir;

    const el=tg('main-card');
    setTimeout(()=>{
        el.style.transition='transform .38s cubic-bezier(.55,0,1,.45),opacity .38s ease';
        if(dir==='left') el.style.transform='translateX(-160vw) rotate(-25deg)';
        else if(dir==='right')el.style.transform='translateX(160vw) rotate(25deg)';
        else el.style.transform='translateY(-140vh) scale(.8)';
        el.style.opacity='0';
        sendChoice(dir);
    },100);
}

function sendChoice(dir){
    if(!user||!card)return;
    const extra=dir==='up'?'&special=true':'';
    fetch(`/api/game/choice?providerId=${enc(user.providerId)}&direction=${dir==='up'?'up':dir}${extra}`,{method:'POST'})
    .then(r=>{if(!r.ok)return r.text().then(t=>{toast('⚡','Ошибка',t);throw 0;});return r.json();})
    .then(data=>{
        user=data.profile;updateHUD(user);
        const ok=dir==='right'||dir==='up';
        const rs=tg('ro-stamp');
        rs.textContent=dir==='up'?'ОСОБЫЙ ПРИЁМ':ok?'ОДОБРЕНО':'ОТКЛОНЕНО';
        rs.className='ro-stamp '+(ok?'ok':'no');
        tg('ro-text').textContent=dir==='up'?(card.specialResult||card.rightResult||''):ok?(card.rightResult||''):(card.leftResult||'');
        tg('rw-xp').textContent=data.xpGained;
        tg('rw-cr').textContent=data.creditsGained;
        tg('rw-en').textContent=data.energyLost;
        setTimeout(()=>{
            tg('result-overlay').classList.remove('hidden');
            if(ok)launchConfetti();
            checkAch(data.profile);
        },280);
        vib([30,20,60]);
    })
    .catch(()=>{
        const el=tg('main-card');
        el.style.transition='transform .35s ease';el.style.transform='rotate(-.4deg)';
        el.style.opacity='1';el.classList.remove('tilt-l','tilt-r','tilt-u');
    });
}

function nextCard(){
    tg('result-overlay').classList.add('hidden');
    const dir=swipeDir==='up'?'right':swipeDir;
    const nid=dir==='right'?card?.rightNext:card?.leftNext;
    const el=tg('main-card');
    el.style.transition='none';el.style.opacity='0';
    requestAnimationFrame(()=>requestAnimationFrame(()=>{
        el.style.transition='opacity .25s ease';el.style.opacity='1';
        loadCard(nid&&getCard(nid)?nid:'act1_scene1');
    }));
}
window.nextCard=nextCard;

// ── Card game gate ─────────────────────────────
function openCardGame(){
    Sound.click();
    const level=Math.max(1,((card?.act||1)-1)*2+1);
    tg('hm-title').textContent='💎 Самоцветы';
    const modal=tg('hint-modal'),back=tg('hm-back');
    modal.classList.remove('hidden','closing');back.classList.remove('hidden');
    const vp=tg('hm-vp');vp.innerHTML='';
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    if(window.BgFx) BgFx.pause();
    import('./games/detective.js').then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp,level,onCardGameWon,true);
    }).catch(()=>{vp.innerHTML='<p style="color:var(--no);padding:24px;text-align:center">⚠️ Ошибка загрузки</p>';});
}
window.openCardGame=openCardGame;

function onCardGameWon(){
    if(window.BgFx) BgFx.resume();
    cardLocked=false;closeHintGame();Sound.unlock();vib([30,20,30,20,80]);
    tg('main-card').classList.add('unlocked');
    setTimeout(()=>tg('main-card').classList.remove('unlocked'),800);
    renderActions();
    toast('🔓','РАЗБЛОКИРОВАНО','Теперь прими решение — свайп влево или вправо');
    fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=detective`,{method:'POST'})
    .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
}

function closeHintGame(){
    const m=tg('hint-modal'),b=tg('hm-back');
    if(window.BgFx) BgFx.resume();
    m.classList.add('closing');setTimeout(()=>{m.classList.add('hidden');b.classList.add('hidden');},240);
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    tg('hm-vp').innerHTML='';
}
window.closeHintGame=closeHintGame;

// ── Games tab ──────────────────────────────────
function launchGame(type){
    tg('gvp-wrap').classList.remove('hidden');
    tg('gvp-title').textContent='💎 Самоцветы';
    tg('win-badge').classList.add('hidden');
    const vp=tg('game-vp');vp.innerHTML='';
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    if(window.BgFx) BgFx.pause();
    import('./games/detective.js').then(mod=>{
        gameDestroy=mod.destroy;
        mod.initGame(vp,user?.detectiveLvl||1,()=>{
            tg('win-badge').classList.remove('hidden');Sound.win3();vib([30,20,30,20,100]);
            toast('🏆','УРОВЕНЬ ПРОЙДЕН','+50 XP');
            fetch(`/api/game/advance-level?providerId=${enc(user.providerId)}&gameType=detective`,{method:'POST'})
            .then(r=>r.ok?r.json():null).then(p=>{if(p){user=p;updateHUD(p);}}).catch(()=>{});
        },false);
    }).catch(()=>{vp.innerHTML='<p style="color:var(--no);text-align:center;padding:32px">⚠️ Ошибка</p>';});
}
window.launchGame=launchGame;
function closeGame(){
    if(gameDestroy){try{gameDestroy();}catch(e){}gameDestroy=null;}
    if(window.BgFx) BgFx.resume();
    tg('gvp-wrap').classList.add('hidden');tg('game-vp').innerHTML='';tg('win-badge').classList.add('hidden');
}
window.closeGame=closeGame;

// ── HUD ────────────────────────────────────────
function updateHUD(p){
    tg('hud-en').textContent=p.energy;
    tg('hud-cr').textContent=p.credits;
    tg('hud-rk').textContent=p.rank;
    const xpMax=p.rank*150;
    tg('xp-fill').style.width=Math.min(100,(p.xp/xpMax)*100)+'%';
    const dl=p.detectiveLvl||1;
    tg('det-lvl').textContent=dl;tg('det-bar').style.width=Math.min(100,dl)+'%';
}

// ── Profile ────────────────────────────────────
function updateProfile(p){
    const n=p.firstName||p.username||'Агент';
    tg('pr-av').textContent=n[0].toUpperCase();
    tg('pr-name').textContent=n;
    tg('pr-id').textContent='ID '+(p.providerId||'—').replace(/^(tg:|guest:)/,'');
    tg('pr-arch').textContent=({detective:'🔍 Детектив',doctor:'⚕️ Медик',hacker:'💻 Хакер'}[p.archetype]||'🔍 Детектив');
    tg('ps-rk').textContent=p.rank;tg('ps-cr').textContent=p.credits;
    tg('ps-cs').textContent=p.totalCases||0;tg('ps-st').textContent=p.streak||0;
    const s1=p.skill1||1,s2=p.skill2||1;
    tg('sk1-lv').textContent='Lv.'+s1;tg('sk1-c').textContent=(s1*50)+'💎';
    tg('sk2-lv').textContent='Lv.'+s2;tg('sk2-c').textContent=(s2*50)+'💎';
    tg('sk1-fill').style.width=Math.min(100,s1*10)+'%';
    tg('sk2-fill').style.width=Math.min(100,s2*10)+'%';
}

function renderAchGrid(){
    const g=tg('ach-grid');if(!g)return;
    g.innerHTML=ACH.map(d=>{
        const ok=earned.has(d.id);
        return `<div class="ach-b ${ok?'earned':'locked'}">
            <div class="ach-icon">${ok?d.icon:'❓'}</div>
            <div class="ach-lbl">${ok?d.title:'???'}</div>
        </div>`;
    }).join('');
}

// ── Progress map ───────────────────────────────
function renderProgressMap(){
    const container=tg('progress-map');
    if(!container||!scenarios)return;
    const cards=Object.values(scenarios.cards||{});
    const chapters=[
        {id:'act1',label:'Акт I · Место преступления',color:'#ef4444',cards:cards.filter(c=>c.act===1)},
        {id:'act2',label:'Акт II · Подозреваемые',    color:'#c8860a',cards:cards.filter(c=>c.act===2)},
        {id:'act3',label:'Акт III · Заказчик',         color:'#a855f7',cards:cards.filter(c=>c.act===3)},
        {id:'act4',label:'Акт IV · Развязка',          color:'#fbbf24',cards:cards.filter(c=>c.act===4)},
    ].filter(ch=>ch.cards.length>0);

    let html='<div style="padding-bottom:40px">';
    let levelNum=1;
    for(const ch of chapters){
        html+=`<div class="map-scene">
            <div class="map-chapter-label" style="border-color:${ch.color}40;color:${ch.color}">${ch.label}</div>
        </div>
        <div class="map-levels">`;
        for(const c of ch.cards){
            const isCurrent=c.id===cardId;
            const isDone=cardHistory?.includes(c.id)||false;
            const isLocked=false;
            const cls=isCurrent?'current':isDone?'done':isLocked?'locked':'';
            html+=`<div class="map-level-row">
                <div class="map-node ${cls}" onclick="jumpToCard('${c.id}')" title="${c.title||''}">
                    <div class="map-node-num">${levelNum}</div>
                    <div class="map-node-icon">${isCurrent?'▶':isDone?'★':c.icon||'○'}</div>
                </div>
            </div>
            ${levelNum<ch.cards.length?'<div class="map-connector"></div>':''}`;
            levelNum++;
        }
        html+='</div><div style="height:12px"></div>';
    }
    html+='</div>';
    container.innerHTML=html;
}

function jumpToCard(id){
    if(!getCard(id))return;
    switchTab('cases');
    setTimeout(()=>loadCard(id),200);
}
window.jumpToCard=jumpToCard;

// ── Tabs ───────────────────────────────────────
function switchTab(name){
    if(activeTab===name)return;
    if(activeTab==='games')closeGame();
    document.querySelectorAll('.tab-pane').forEach(p=>p.classList.remove('active'));
    document.querySelectorAll('.nb').forEach(b=>b.classList.remove('active'));
    tg('tab-'+name).classList.add('active');
    document.querySelector(`[data-tab="${name}"]`)?.classList.add('active');
    activeTab=name;Sound.click();vib(10);
    if(name==='profile'){updateProfile(user);renderAchGrid();tg('ach-badge').classList.add('hidden');}
    if(name==='map')renderProgressMap();
    if(name==='shop')updateShopAfford();
}
window.switchTab=switchTab;

// ── Skills ─────────────────────────────────────
function upgradeSkill(n){
    if(!user)return;Sound.click();
    fetch(`/api/game/upgrade-skill?providerId=${enc(user.providerId)}&skillNum=${n}`,{method:'POST'})
    .then(r=>{if(!r.ok)return r.text().then(t=>{toast('💎','Мало кредитов',t);throw 0;});return r.json();})
    .then(p=>{user=p;updateHUD(p);updateProfile(p);vib([20,20,40]);
        toast('🧠','НАВЫК',n===1?'Проницательность Lv.'+p.skill1:'Технологии Lv.'+p.skill2);})
    .catch(()=>{});
}
window.upgradeSkill=upgradeSkill;

// ── Shop ───────────────────────────────────────
function buyCoffee(){
    if(!user)return;Sound.click();
    fetch(`/api/game/buy-coffee?providerId=${enc(user.providerId)}`,{method:'POST'})
    .then(r=>{if(!r.ok)return r.text().then(t=>{toast('☕','Мало кредитов',t);throw 0;});return r.json();})
    .then(p=>{user=p;updateHUD(p);updateProfile(p);updateShopAfford();toast('☕','КОФЕ','+35 ⚡');vib(30);})
    .catch(()=>{});
}
window.buyCoffee=buyCoffee;
function updateShopAfford(){
    if(!user)return;
    const el=tg('sh-coffee');if(!el)return;
    el.classList.toggle('cant-afford',user.credits<40);
    const pr=tg('sh-coffee-p');if(pr)pr.textContent=user.credits>=40?'40 💎':'40 💎 (нет)';
}

// ── Daily bonus ────────────────────────────────
function checkDailyBonus(){
    if(!user)return;
    fetch('/api/game/daily-bonus?providerId='+enc(user.providerId))
    .then(r=>r.ok?r.json():null)
    .then(d=>{if(!d||!d.available)return;buildWeek(d.streak||1);tg('dd-days').textContent=d.streak||1;tg('daily-modal').classList.remove('hidden');})
    .catch(()=>{});
}
function buildWeek(s){
    const w=tg('dd-week');if(!w)return;w.innerHTML='';
    for(let i=1;i<=7;i++){
        const d=document.createElement('div');d.className='dw-dot';
        if(i<(s%7||(s>=7?8:0)))d.classList.add('done');
        if(i===(s%7||7))d.classList.add('today');
        d.textContent=i;w.appendChild(d);
    }
}
function claimDaily(){
    if(!user||dailyClaimed)return;dailyClaimed=true;Sound.click();
    tg('daily-modal').classList.add('hidden');
    fetch('/api/game/daily-bonus/claim?providerId='+enc(user.providerId),{method:'POST'})
    .then(r=>r.ok?r.json():null)
    .then(d=>{if(!d)return;user=d.profile;updateHUD(user);updateProfile(user);
        toast('🎁','БОНУС',`+50💎 · +30⚡`);vib([30,20,30,20,80]);})
    .catch(()=>{});
}
window.claimDaily=claimDaily;

// ── Achievements ───────────────────────────────
function checkAch(p){
    let found=false;
    for(const d of ACH){
        if(!earned.has(d.id)&&d.check(p)){
            earned.add(d.id);localStorage.setItem('sdvig_ach',JSON.stringify([...earned]));
            if(!found){setTimeout(()=>toast(d.icon,d.title,d.desc),600);found=true;}
            const b=tg('ach-badge');if(b){b.textContent='!';b.classList.remove('hidden');}
        }
    }
}

// ── Toast ──────────────────────────────────────
let _tt=null;
function toast(ic,title,desc){
    const el=tg('toast');
    tg('t-icon').textContent=ic;tg('t-title').textContent=title;tg('t-desc').textContent=desc;
    el.classList.remove('hidden','out');clearTimeout(_tt);
    _tt=setTimeout(()=>{el.classList.add('out');setTimeout(()=>el.classList.add('hidden'),300);},3200);
    vib(18);
}

// ── Visual Effects ─────────────────────────────

// Rain
let _rainRAF=null;
function initRain(){
    const zone=tg('swipe-zone');if(!zone)return;
    const canvas=document.createElement('canvas');
    canvas.className='rain-canvas';
    zone.insertBefore(canvas,zone.firstChild);
    const ctx=canvas.getContext('2d');
    const drops=[];
    function resize(){canvas.width=zone.clientWidth;canvas.height=zone.clientHeight;}
    resize();window.addEventListener('resize',resize);
    for(let i=0;i<70;i++)drops.push({x:Math.random()*canvas.width,y:Math.random()*canvas.height,s:2+Math.random()*3,l:8+Math.random()*12});
    function frame(){
        if(_rainRAF===null)return;
        ctx.clearRect(0,0,canvas.width,canvas.height);
        ctx.strokeStyle='rgba(180,200,240,.45)';ctx.lineWidth=.7;
        for(const d of drops){
            ctx.beginPath();ctx.moveTo(d.x,d.y);ctx.lineTo(d.x-.8,d.y+d.l);ctx.stroke();
            d.y+=d.s;if(d.y>canvas.height){d.y=-d.l;d.x=Math.random()*canvas.width;}
        }
        _rainRAF=requestAnimationFrame(frame);
    }
    _rainRAF=requestAnimationFrame(frame);
}

// Parallax
function initParallax(){
    const bg=tg('parallax-bg');if(!bg)return;
    if(window.DeviceOrientationEvent){
        window.addEventListener('deviceorientation',e=>{
            const rx=(e.beta||0)/90*12,ry=(e.gamma||0)/90*12;
            bg.style.transform=`translate(${ry*.5}px,${rx*.5}px)`;
        });
    }
}

// Dust particles on swipe
function spawnDust(dir){
    const zone=tg('swipe-zone');if(!zone)return;
    const rect=zone.getBoundingClientRect();
    const cx=rect.width/2,cy=rect.height*.55;
    for(let i=0;i<10;i++){
        const p=document.createElement('div');
        p.className='dust';
        const ang=(dir==='left'?Math.PI:dir==='up'?-Math.PI/2:0)+(Math.random()-.5)*1.8;
        const dist=25+Math.random()*40;
        Object.assign(p.style,{left:cx+'px',top:cy+'px'});
        zone.appendChild(p);
        requestAnimationFrame(()=>{
            p.style.transform=`translate(${Math.cos(ang)*dist}px,${Math.sin(ang)*dist}px) scale(.4)`;
            p.style.opacity='0';
        });
        setTimeout(()=>p.remove(),450);
    }
}

// Confetti
function launchConfetti(){
    const cols=['#c8860a','#e8a030','#ffd700','#ffed4a','#ffffff','#a855f7'];
    for(let i=0;i<60;i++){
        const p=document.createElement('div');
        p.className='confetti-p';
        const col=cols[Math.floor(Math.random()*cols.length)];
        const dur=1.4+Math.random()*.8;
        const delay=Math.random()*.5;
        Object.assign(p.style,{
            left:Math.random()*100+'%',
            width:(4+Math.random()*7)+'px',height:(4+Math.random()*7)+'px',
            background:col,
            animationDuration:dur+'s',animationDelay:delay+'s',
            transform:`rotate(${Math.random()*360}deg)`,
            borderRadius:Math.random()>.5?'50%':'2px',
        });
        document.body.appendChild(p);
        setTimeout(()=>p.remove(),(delay+dur)*1000+100);
    }
}

// ── Utils ──────────────────────────────────────
function enc(s){return encodeURIComponent(s||'');}
function vib(p){try{if(navigator.vibrate)navigator.vibrate(p);}catch(e){}}
function wait(ms){return new Promise(r=>setTimeout(r,ms));}

