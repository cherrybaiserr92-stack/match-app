#!/usr/bin/env bash
# СДВИГ R52 — большой UI-фикс: аватары, лента, карточка, досье, шкала
set -e
echo "══ штамп → R52 ══"
sed -i "s/SDVIG_BUILD='R51'/SDVIG_BUILD='R52'/" src/main/resources/static/app.js
sed -i 's/>R51</>R52</' src/main/resources/static/index.html

echo ""; echo "══ 1/6  аватары — круглые, больше, Сдвиг влезает, говорят"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Круглые, больше (62px), кроп лучше под Сдвига
old=".m2-av{width:56px;height:56px;border-radius:13px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;}"
new=".m2-av{width:62px;height:62px;border-radius:50%;flex-shrink:0;overflow:hidden;border:2.5px solid;position:relative;}"
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + аватар круглый 62px")

# Кроп: показываем голову+плечи, Сдвиг в шляпе влезает
old2='''    .m2-av img{position:absolute;width:175%;left:-37%;top:6%;max-width:none;}
    /* индивидуальный кроп под персонажа */
    .m2-av.av-shift img{width:200%;left:-50%;top:2%;}
    .m2-av.av-recruit img{width:170%;left:-35%;top:7%;}
    .m2-av.av-miller img{width:165%;left:-32%;top:6%;}'''
new2='''    .m2-av img{position:absolute;width:150%;left:-25%;top:8%;max-width:none;}
    /* индивидуальный кроп — голова целиком влезает */
    .m2-av.av-shift img{width:148%;left:-24%;top:9%;}
    .m2-av.av-recruit img{width:150%;left:-25%;top:7%;}
    .m2-av.av-miller img{width:145%;left:-22%;top:8%;}
    .m2-av.av-eleanor img{width:150%;left:-25%;top:7%;}
    .m2-av.av-kurator img{width:148%;left:-24%;top:8%;}'''
if old2 in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + кроп: голова влезает, индив. под каждого")

# Анимация "говорит" при печати — пульсация кольца
if ".m2-av.talking" not in txt:
    anchor=".msg2.active .m2-ring{opacity:1;box-shadow:0 0 0 2px currentColor,0 0 16px currentColor;}"
    css=anchor+'''
    .m2-av.talking{animation:avTalk .7s ease-in-out infinite;}
    @keyframes avTalk{0%,100%{transform:scale(1)}50%{transform:scale(1.06)}}
    .m2-av.talking .m2-ring{animation:ringTalk .5s ease-in-out infinite;}
    @keyframes ringTalk{0%,100%{box-shadow:0 0 0 2px currentColor,0 0 12px currentColor;opacity:.9}50%{box-shadow:0 0 0 3px currentColor,0 0 22px currentColor;opacity:1}}'''
    txt=txt.replace(anchor,css,1); n+=1; print("  + анимация 'говорит' при печати")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 2/6  лента — 'далее', класс talking при печати ══"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# "тап — далее" → "далее", "тап — продолжить" → "далее"
txt=txt.replace("hint.textContent='▸ тап — далее';","hint.textContent='далее ▸';")
txt=txt.replace("hint.textContent='▸ тап — продолжить';","hint.textContent='далее ▸';")
n+=1; print("  + 'тап — далее' → 'далее'")

# talking-класс на аватар во время печати, снимаем после
old='''  function typeInto(el, text, done, hasClues){
    el._full=text; el._typing=true;'''
new='''  function typeInto(el, text, done, hasClues){
    el._full=text; el._typing=true;
    // включаем "говорит" на аватаре этой реплики
    var _msgEl=el.closest&&el.closest('.msg2'); var _avEl=_msgEl&&_msgEl.querySelector('.m2-av');
    if(_avEl) _avEl.classList.add('talking');'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + talking при старте печати")

# снимаем talking когда печать закончилась
old_fin='''        clearInterval(el._tt); el._typing=false;
        el.innerHTML=renderClues(text);
        if(hasClues) bindClues(el);
        done&&done(); return;'''
new_fin='''        clearInterval(el._tt); el._typing=false;
        el.innerHTML=renderClues(text);
        if(hasClues) bindClues(el);
        if(_avEl) _avEl.classList.remove('talking');
        done&&done(); return;'''
if old_fin in txt:
    txt=txt.replace(old_fin,new_fin,1); n+=1; print("  + talking снимается после печати")

# finishType тоже снимает talking
old_ft='''  function finishType(el){
    if(!el||!el._typing) return false;
    clearInterval(el._tt); el._typing=false;'''
new_ft='''  function finishType(el){
    if(!el||!el._typing) return false;
    clearInterval(el._tt); el._typing=false;
    var _m=el.closest&&el.closest('.msg2'); var _a=_m&&_m.querySelector('.m2-av'); if(_a)_a.classList.remove('talking');'''
if old_ft in txt:
    txt=txt.replace(old_ft,new_ft,1); n+=1; print("  + finishType снимает talking")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/6  убрать бейджи-сепараторы между событиями ════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Убираем разделитель с бейджем ("МЕТОД", "МУЗЕЙ") — он сбивает с толку
# Оставляем только тонкую линию без текста
old='''    // разделитель главы перед новым событием (кроме первого)
    if(_wrap.children.length>0 && ev.badge){
      var sep=document.createElement('div'); sep.className='feed2-sep';
      sep.innerHTML='<span>'+esc(ev.badge)+'</span>';
      _wrap.appendChild(sep);
    }'''
new='''    // тонкий разделитель между событиями (без текста-бейджа — он сбивал с толку)
    if(_wrap.children.length>0){
      var sep=document.createElement('div'); sep.className='feed2-sep feed2-sep-thin';
      _wrap.appendChild(sep);
    }'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + бейдж-сепаратор убран (тонкая линия)")

# renderStatic тоже без бейджа
old2='''    if(ev.badge && _wrap.children.length>0){
      var sep=document.createElement('div'); sep.className='feed2-sep';
      sep.innerHTML='<span>'+esc(ev.badge)+'</span>'; _wrap.appendChild(sep);
    }'''
new2='''    if(_wrap.children.length>0){
      var sep=document.createElement('div'); sep.className='feed2-sep feed2-sep-thin'; _wrap.appendChild(sep);
    }'''
if old2 in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + renderStatic без бейджа")

# CSS тонкого разделителя
if ".feed2-sep-thin" not in txt:
    anchor=".feed2-sep span{"
    css=".feed2-sep-thin{margin:10px 20%;opacity:.3;}\n    .feed2-sep-thin::before,.feed2-sep-thin::after{height:1px;}\n    .feed2-sep span{"
    txt=txt.replace(anchor,css,1); n+=1; print("  + CSS тонкого разделителя")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 4/6  карточка — короткие метки, без След, таймер ═"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Убираем боковые каскады "След" (outcome-cascade) — они путают
old_cascade='''    const dec=document.createElement('div'); dec.className='decision-stage'; dec.id='dec-stage';
    dec.innerHTML=cascadeHtml('left',collectOutcomes(opts.left))+
      '<div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div>'+
      cascadeHtml('right',collectOutcomes(opts.right))+'''
new_cascade='''    const dec=document.createElement('div'); dec.className='decision-stage'; dec.id='dec-stage';
    dec.innerHTML='<div class="dec-card" id="dec-card">'+decCardInner(ev)+'</div>'+'''
if old_cascade in txt:
    txt=txt.replace(old_cascade,new_cascade,1); n+=1; print("  + боковые 'След' убраны")

# Таймер: переносим НАД карточкой с отступом (не наезжает)
old_t="    .dec-timer{position:absolute;top:7%;left:50%;transform:translateX(-50%);z-index:8;"
new_t="    .dec-timer{position:absolute;top:2%;left:50%;transform:translateX(-50%);z-index:8;"
if old_t in txt:
    txt=txt.replace(old_t,new_t,1); n+=1; print("  + таймер выше (не наезжает)")

# dec-card: отступ сверху под таймер, "свайп решает" ниже
old_card2=".dec-card{position:relative;width:min(74vw,300px);border-radius:18px;overflow:hidden;z-index:5;"
new_card2=".dec-card{position:relative;width:min(80vw,320px);margin-top:56px;border-radius:18px;overflow:hidden;z-index:5;"
if old_card2 in txt:
    txt=txt.replace(old_card2,new_card2,1); n+=1; print("  + карточка шире + отступ под таймер")

# "свайп решает" — дальше от карточки
old_h="    .oc-hint{position:absolute;bottom:13%;left:0;right:0;text-align:center;font-size:11px;color:#c8a05a;"
new_h="    .oc-hint{position:absolute;bottom:6%;left:0;right:0;text-align:center;font-size:11px;color:#c8a05a;"
if old_h in txt:
    txt=txt.replace(old_h,new_h,1); n+=1; print("  + 'свайп решает' ниже")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 5/6  счётчик внизу открывает ДОСЬЕ + rapport=50 ═"
python3 - << 'PYEOF'
import re
# index.html: возвращаем id=ev-chip счётчику (открывает досье), убираем data-tool=shop
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''        <button class="tools-mini" data-tool="shop" title="Инструменты">
          <span class="ev-chip-mini"><span class="ev-dot"></span><b id="ev-count">0</b></span>
        </button>'''
new='''        <button class="tools-mini" id="ev-chip" title="Досье улик">
          <span class="ev-chip-mini"><span class="ev-dot"></span><b id="ev-count">0</b></span>
        </button>'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + счётчик = ev-chip (открывает досье)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print(f"✓ index.html: {n}")

# app.js: rapport стартует с 50 (был 0 — потому шкала на нуле)
path2="src/main/resources/static/app.js"
with open(path2,encoding="utf-8") as f: txt2=f.read()
n2=0
txt2=txt2.replace("lastEnergyTs:0, rapport:0, skill:30, onboarded:false",
                  "lastEnergyTs:0, rapport:50, skill:30, onboarded:false")
n2+=1; print("  + rapport старт 50 (было 0)")
# Миграция: если у существующего профиля rapport<=20 от старой системы — поднять к 50
if "_migrateRapport" not in txt2:
    anchor="function updateScaleBars(){"
    mig='''var _migrateRapport=(function(){
  try{ var p=App.profile; if(p && (p.rapport===0||p.rapport===undefined) && !p._rapMigrated){ p.rapport=50; p._rapMigrated=true; saveProfile(); } }catch(_){}
})();
'''
    txt2=txt2.replace(anchor, mig+anchor, 1); n2+=1; print("  + миграция старого rapport→50")
with open(path2,"w",encoding="utf-8") as f: f.write(txt2)
print(f"✓ app.js: {n2}")
PYEOF


echo ""; echo "══ 6/6  сюжет — Патрульный как реплика + 'проклятие' ══"
python3 - << 'PYEOF'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
ev=d['events']
n=0

# L1_c6: реплика Патрульного шла как текст автора. Делаем speaker + переписываем "проклятие основателей"
ev['L1_c6']['text']='Зал тонул в полумраке колонн. В центре — пустой постамент и опрокинутый стул. Молоденький патрульный у входа нервно козырнул: «Дверь была заперта изнутри, я сам проверял замок. Тут дело нечисто». Сдвиг лишь хмыкнул.'
ev['L1_c6']['dialogue']='Сдвиг: «Нечисто — это верно. Только пахнет здесь не чертовщиной, а машинным маслом».'
ev['L1_c6']['speaker']='shift'
n+=1
print("  + L1_c6: Патрульный как реплика, 'проклятие основателей' переписано")

# Уберём другие упоминания "проклятие основателей" если есть
for k,e in ev.items():
    for f in ['text','dialogue']:
        v=e.get(f,'')
        if 'проклятие основателей' in v.lower() or 'проклятие семьи' in v.lower():
            e[f]=v.replace('Это проклятие основателей, не иначе!','Тут дело нечисто!').replace('проклятие семьи основателя','чью-то злую волю')
            n+=1

json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print(f"✓ сюжет: {n}")
PYEOF



echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R52 — аватары, лента, карточка, досье, шкала"
echo "   git add -A && git commit -m 'R52: round avatars, talking anim, card layout, dossier, rapport fix' && git push"
echo "═══════════════════════════════════════════════════════"
