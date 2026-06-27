#!/usr/bin/env bash
# СДВИГ R88 — фоны по главам с параллаксом, удаление старого кабинета
set -e
echo "══ штамп → R88 ══"
sed -i "s/SDVIG_BUILD='R87'/SDVIG_BUILD='R88'/" src/main/resources/static/app.js
sed -i 's/>R87</>R88</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  маппинг фонов ПО ГЛАВАМ ══════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Заменяем CASE_BGS (старые id) на функцию по главам
old='''const CASE_BGS={
  'case001':'/img/bg/bg-ch1-hall.png',
  'case002':'/img/bg/bg-oldcity.jpg',
  'case003':'/img/bg/bg-docks.jpg',
  'case004':'/img/bg/bg-mansion-ext.jpg',
  'case005':'/img/bg/bg-mansion-int.jpg'
};'''
new='''// фон ПО ГЛАВАМ (1 на главу; позже можно по уровням)
const CHAPTER_BGS={
  1:'/img/bg/bg-ch1-hall.png',     // Музейный квартал
  2:'/img/bg/bg-oldcity.jpg',      // Старый город
  3:'/img/bg/bg-docks.jpg',        // Ночные доки
  4:'/img/bg/bg-forest.jpg',       // Остров (туманный лес/сад)
  5:'/img/bg/bg-mansion-int.jpg'   // Усадьба
};
function bgForCase(cid){
  if(!cid) return null;
  // определяем главу по id уровня
  var ch=1;
  if(cid.indexOf('level-1')===0||cid==='case001') ch=1;
  else if(cid.indexOf('level-2')===0) ch=2;
  else if(cid.indexOf('level-3')===0) ch=3;
  else if(cid.indexOf('level-4')===0) ch=4;
  else if(cid.indexOf('level-5')===0) ch=5;
  return CHAPTER_BGS[ch]||null;
}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + CHAPTER_BGS + bgForCase() по главам")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/4  updateCaseBg — фон главы + параллакс всегда ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''function updateCaseBg(){
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
}'''
new='''function updateCaseBg(){
  try{
    const cid=CAMPAIGN&&CAMPAIGN.cases[_caseIdx]?CAMPAIGN.cases[_caseIdx].id:'';
    const bg=bgForCase(cid);
    const sb=document.getElementById('scene-bg');
    const st=document.getElementById('stage'); if(st)st.style.backgroundImage='';
    if(sb){
      if(bg){
        if(sb.getAttribute('data-bg')!==bg){
          sb.style.backgroundImage="url('"+bg+"')";
          sb.setAttribute('data-bg',bg);
        }
        sb.classList.add('on');
      }
      else { sb.style.backgroundImage=''; sb.classList.remove('on'); sb.removeAttribute('data-bg'); }
    }
    /* СТАРЫЙ КАБИНЕТ (bg-fx) полностью убираем */
    var bf=document.getElementById('bg-fx');
    if(bf){ bf.style.display='none'; bf.style.opacity='0'; }
  }catch(_){}
}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + фон главы, кабинет скрыт")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/4  CSS .scene-bg (параллакс, плавность) ══════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if ".scene-bg{" not in txt:
    css='''
/* ── ФОН ГЛАВЫ с параллаксом ── */
.scene-bg{
  position:fixed; inset:-6% -6% -6% -6%;
  z-index:0; pointer-events:none;
  background-size:cover; background-position:center center;
  opacity:0; transition:opacity .9s ease;
  will-change:transform;
  transform:translate3d(0,0,0) scale(1.08);
}
.scene-bg.on{ opacity:.5; }
/* затемнение поверх фона для читаемости ленты */
.scene-bg.on::after{
  content:''; position:absolute; inset:0;
  background:linear-gradient(180deg, rgba(8,10,14,.55) 0%, rgba(8,10,14,.78) 55%, rgba(8,10,14,.92) 100%);
}
'''
    txt+=css; n+=1; print("  + CSS .scene-bg с параллакс-трансформом и затемнением")
# старый кабинет bg-fx — спрятать на уровне CSS тоже
if "#bg-fx{ display:none" not in txt:
    txt=txt.replace("#bg-fx{","#bg-fx{ display:none !important;",1)
    print("  + #bg-fx скрыт в CSS")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ style.css: %d"%n)
PYEOF


echo ""; echo "══ 4/4  параллакс scene-bg по движению/наклону ════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# параллакс уже частично есть в BgFxDrag — усилим и подключим к device tilt/touch
# проверим, есть ли обработчик; если scene-bg.on — двигаем фон
if "_sceneParallax" not in txt:
    code='''
// ── ПАРАЛЛАКС фона главы (наклон устройства + движение) ──
(function(){
  function _sceneParallax(nx,ny){
    var sb=document.getElementById('scene-bg');
    if(sb&&sb.classList.contains('on')){
      sb.style.transform='translate3d('+(-nx*16)+'px,'+(-ny*12)+'px,0) scale(1.08)';
    }
  }
  window._sceneParallax=_sceneParallax;
  // device orientation (наклон телефона)
  window.addEventListener('deviceorientation',function(e){
    if(e.gamma==null||e.beta==null) return;
    var nx=Math.max(-1,Math.min(1,(e.gamma||0)/30));
    var ny=Math.max(-1,Math.min(1,((e.beta||0)-45)/30));
    _sceneParallax(nx,ny);
  },true);
  // touch-move (палец по экрану слегка двигает фон)
  document.addEventListener('touchmove',function(e){
    if(!e.touches||!e.touches[0]) return;
    var w=window.innerWidth,h=window.innerHeight;
    var nx=(e.touches[0].clientX/w-0.5)*2;
    var ny=(e.touches[0].clientY/h-0.5)*2;
    _sceneParallax(nx,ny);
  },{passive:true});
  // мышь (для десктопа/превью)
  document.addEventListener('mousemove',function(e){
    var w=window.innerWidth,h=window.innerHeight;
    var nx=(e.clientX/w-0.5)*2;
    var ny=(e.clientY/h-0.5)*2;
    _sceneParallax(nx,ny);
  });
})();
'''
    # вставляем перед updateCaseBg
    txt=txt.replace("function updateCaseBg(){", code+"\nfunction updateCaseBg(){",1)
    n+=1; print("  + параллакс scene-bg (наклон + касание + мышь)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R88 — фоны по главам с параллаксом, кабинет убран"
echo "   git add -A && git commit -m 'R88: chapter backgrounds with parallax, remove office bg' && git push"
echo "═══════════════════════════════════════════════════════"
