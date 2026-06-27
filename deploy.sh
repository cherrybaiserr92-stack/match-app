#!/usr/bin/env bash
# СДВИГ R95 — одна валюта (Кредиты), чистая Лавка, премиальный визуал
set -e
echo "══ штамп → R95 ══"
sed -i "s/SDVIG_BUILD='R94'/SDVIG_BUILD='R95'/" src/main/resources/static/app.js
sed -i 's/>R94</>R95</' src/main/resources/static/index.html

echo ""; echo "══ 1/5  топбар: убираем вторую валюту (bucks) ═════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''    <div class="th-money th-bucks" id="th-bucks">
      <span class="gem-ico" data-gem="bucks"></span>
      <span id="hud-bucks">0</span>
    </div>'''
if old in txt:
    txt=txt.replace(old,'')
    n+=1; print("  − блок bucks убран из топбара")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/5  Лавка: чистый SHOP (всё за Кредиты) ═══════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
import re
# Заменяем SHOP и BUCK_PACKS
old_shop=re.search(r'const SHOP=\[.*?\];', txt, re.S)
if old_shop:
    new_shop='''const SHOP=[
  {k:'energy',   svg:'energy',   name:'Чёрный кофе',     desc:'+3 энергии — продолжить работу', cur:'credits', price:30,
    buy(){ addEnergy(3); }},
  {k:'hourglass',svg:'hourglass',name:'Второе дыхание',   desc:'Полный заряд энергии',           cur:'credits', price:80,
    buy(){ var p=App.profile; addEnergy(p.maxEnergy); }},
  {k:'magnify',  svg:'magnify',  name:'Лупа',             desc:'Подсветит улику в «Осмотре»',     cur:'credits', price:50,
    buy(){ App.profile.tMagnify=(App.profile.tMagnify||0)+1; saveProfile(); }},
  {k:'phone',    svg:'phone',    name:'Звонок информатору',desc:'Подсветит безопасный выбор',     cur:'credits', price:60,
    buy(){ App.profile.tHint=(App.profile.tHint||0)+1; saveProfile(); }},
  {k:'file',     svg:'file',     name:'Досье',            desc:'Пропустить мини-игру',            cur:'credits', price:100,
    buy(){ App.profile.tFile=(App.profile.tFile||0)+1; saveProfile(); }}
];'''
    txt=txt[:old_shop.start()]+new_shop+txt[old_shop.end():]
    n+=1; print("  + SHOP: 5 понятных предметов за Кредиты")

# Убираем BUCK_PACKS
old_packs=re.search(r'/\* пакеты Баксов.*?const BUCK_PACKS=\[.*?\];', txt, re.S)
if old_packs:
    txt=txt[:old_packs.start()]+'/* премиум-валюта убрана — одна валюта (Кредиты) */'+txt[old_packs.end():]
    n+=1; print("  − BUCK_PACKS убраны")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/5  renderShop: чистый, премиальный ═══════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
import re
old=re.search(r'function renderShop\(\)\{.*?\n\}', txt, re.S)
if old:
    new='''function renderShop(){
  const g=$('#shop-grid'); if(!g) return; g.innerHTML='';
  SHOP.forEach(it=>{
    const item=el('div','shop-item',`
      <div class="si-glow"></div>
      <div class="si-gem">${gemIcon(it.svg)}</div>
      <div class="si-name">${it.name}</div>
      <div class="si-desc">${it.desc}</div>
      <div class="si-price"><span class="si-coin">${gemIcon('bucks')}</span>${it.price}</div>`);
    item.onclick=()=>{
      if(App.profile.credits<it.price){
        Sound.error(); vibrate([10,30,10]);
        toast('Недостаточно кредитов','Нужно '+it.price,'✗');
        return;
      }
      addCredits(-it.price);
      it.buy(); Sound.coin(); vibrate(12);
      toast('Куплено',it.name,'🛍'); renderHUD(); renderShop();
      // вспышка успеха на карточке
      item.classList.add('si-bought'); setTimeout(()=>item.classList.remove('si-bought'),500);
    };
    g.appendChild(item);
  });
}'''
    txt=txt[:old.start()]+new+txt[old.end():]
    n+=1; print("  + renderShop премиальный, одна валюта")

# Убираем openBuckShop (заглушка платежа)
old2=re.search(r'/\* окно покупки Баксов.*?function openBuckShop\(\)\{.*?\n\}', txt, re.S)
if old2:
    txt=txt[:old2.start()]+'/* окно покупки премиума убрано */'+txt[old2.end():]
    n+=1; print("  − openBuckShop убран")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 4/5  премиальный CSS Лавки (объём, переливы) ═══"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
import re
# Заменяем shop-item стили на премиальные
old=re.search(r'\.shop-item\{[^}]*\}\s*\.shop-item:active\{[^}]*\}', txt)
if old:
    new='''.shop-item{
  position:relative; overflow:hidden;
  background:linear-gradient(160deg, rgba(26,31,44,.85), rgba(16,20,28,.92));
  border:1px solid rgba(255,255,255,.10); border-radius:20px;
  padding:20px 14px 16px; text-align:center; cursor:pointer;
  box-shadow:
    0 1px 0 rgba(255,255,255,.06) inset,
    0 8px 20px rgba(0,0,0,.35);
  transition:transform .15s cubic-bezier(.34,1.56,.64,1), box-shadow .2s ease, border-color .2s ease;
  -webkit-tap-highlight-color:transparent;
}
.shop-item:active{ transform:scale(.96) translateY(1px); }
.shop-item:hover{ border-color:rgba(255,207,107,.25); box-shadow:0 1px 0 rgba(255,255,255,.08) inset, 0 12px 26px rgba(0,0,0,.4), 0 0 20px rgba(200,134,10,.1); }
/* перелив-блик по верху карточки */
.shop-item::before{
  content:''; position:absolute; top:0; left:15%; right:15%; height:1px;
  background:linear-gradient(90deg, transparent, rgba(255,207,107,.3), transparent);
}
/* свечение за иконкой */
.si-glow{
  position:absolute; top:8px; left:50%; transform:translateX(-50%);
  width:70px; height:70px; border-radius:50%;
  background:radial-gradient(circle, rgba(200,134,10,.22), transparent 70%);
  pointer-events:none;
}'''
    txt=txt[:old.start()]+new+txt[old.end():]
    n+=1; print("  + .shop-item премиальный")

# добавляем стили внутренностей карточки
if ".si-gem{" not in txt:
    txt+='''
/* внутренности карточки Лавки */
.si-gem{ position:relative; width:54px; height:54px; margin:0 auto 6px; }
.si-gem svg{ width:100%; height:100%; }
.si-name{ font-weight:700; font-size:14px; color:var(--ink); margin-top:6px; font-family:'Playfair Display',serif; }
.si-desc{ font-size:11px; color:var(--ink3); margin-top:5px; min-height:30px; line-height:1.4; }
.si-price{
  margin-top:12px; padding:9px; border-radius:12px;
  background:linear-gradient(135deg, rgba(200,134,10,.18), rgba(255,207,107,.08));
  border:1px solid rgba(255,207,107,.3);
  color:var(--acc-2); font-weight:800; font-size:14px; font-family:'Unbounded',sans-serif;
  display:flex; align-items:center; justify-content:center; gap:6px;
  box-shadow:0 0 12px rgba(200,134,10,.12) inset;
}
.si-coin{ width:18px; height:18px; display:inline-flex; }
.si-coin svg{ width:100%; height:100%; }
/* вспышка покупки */
.si-bought{ animation:siBought .5s ease; }
@keyframes siBought{ 0%{box-shadow:0 0 0 rgba(70,216,155,0);} 40%{box-shadow:0 0 30px rgba(70,216,155,.6), 0 0 0 2px rgba(70,216,155,.5) inset;} 100%{box-shadow:0 8px 20px rgba(0,0,0,.35);} }
'''
    n+=1; print("  + стили внутренностей карточки")

# топбар-валюта: премиальный объём
txt=re.sub(r'\.th-money\{[^}]*\}',
'''.th-money{
  flex:0 0 auto; display:flex; align-items:center; gap:7px;
  padding:8px 15px; border-radius:var(--rfull);
  background:linear-gradient(135deg, rgba(40,33,18,.9), rgba(26,21,12,.95));
  border:1px solid rgba(255,207,107,.35); color:var(--acc-2);
  font-weight:800; font-size:15px; font-family:'Unbounded',sans-serif;
  box-shadow:
    inset 0 1px 0 rgba(255,255,255,.12),
    0 2px 8px rgba(0,0,0,.3),
    0 0 16px rgba(200,134,10,.15);
}''', txt, count=1)
n+=1; print("  + th-money премиальный объём")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ style.css: %d"%n)
PYEOF


echo ""; echo "══ 5/5  иконка валюты в топбаре (SVG жетон) ═══════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# th-coin (data-tico) заполняем качественным SVG жетоном детектива
if "renderTopCoin" not in txt:
    code='''
// SVG-жетон валюты (Кредиты) в топбаре
function renderTopCoin(){
  var c=document.querySelector('.th-coin[data-tico="coin"]');
  if(c && !c.getAttribute('data-filled')){
    c.innerHTML='<svg viewBox="0 0 24 24" fill="none"><circle cx="12" cy="12" r="9.5" fill="url(#coinG)" stroke="#8a6410" stroke-width="1"/><circle cx="12" cy="12" r="7" fill="none" stroke="#6a4810" stroke-width=".6" opacity=".5"/><path d="M12 7v10M9.5 9h3.5a1.8 1.8 0 0 1 0 3.6H9.5h3.5a1.8 1.8 0 0 1 0 3.6H9.5" stroke="#5a3e0a" stroke-width="1.3" stroke-linecap="round" fill="none"/><ellipse cx="9" cy="9" rx="2" ry="3" fill="rgba(255,255,255,.3)"/><defs><linearGradient id="coinG" x1="0" y1="0" x2="0" y2="24"><stop offset="0" stop-color="#ffe9a8"/><stop offset=".5" stop-color="#e0b057"/><stop offset="1" stop-color="#a06d08"/></linearGradient></defs></svg>';
    c.setAttribute('data-filled','1');
  }
}
'''
    txt=txt.replace("function renderHUD(){", code+"\nfunction renderHUD(){",1)
    # вызываем в renderHUD
    txt=txt.replace("function renderHUD(){","function renderHUD(){\n  try{renderTopCoin();}catch(_){}",1)
    n+=1; print("  + SVG-жетон валюты в топбаре")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R95 — одна валюта, чистая Лавка, премиальный визуал"
echo "   git add -A && git commit -m 'R95: single currency, clean premium shop' && git push"
echo "═══════════════════════════════════════════════════════"
