#!/usr/bin/env bash
# СДВИГ R86 — интерлюдии между главами (течение времени, заполнение обрывов)
set -e
echo "══ штамп → R86 ══"
sed -i "s/SDVIG_BUILD='R85'/SDVIG_BUILD='R86'/" src/main/resources/static/app.js
sed -i 's/>R85</>R86</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  HTML экрана интерлюдии ════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if 'id="interlude"' not in txt:
    modal='''
  <!-- ИНТЕРЛЮДИЯ между главами (течение времени) -->
  <div id="interlude" class="interlude" style="display:none">
    <div class="il-inner">
      <div class="il-time" id="il-time"></div>
      <div class="il-line"></div>
      <div class="il-title" id="il-title"></div>
      <div class="il-text" id="il-text"></div>
      <button class="il-continue" id="il-continue">Продолжить</button>
    </div>
  </div>'''
    end=txt.find('</body>')
    txt=txt[:end]+modal+'\n'+txt[end:]
    n+=1; print("  + HTML интерлюдии")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/4  CSS интерлюдии (кинематографично) ═════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".interlude{" not in txt:
    txt+='''
/* ── ИНТЕРЛЮДИЯ между главами ── */
.interlude{position:fixed;inset:0;z-index:9000;background:#080a0e;
  display:flex;align-items:center;justify-content:center;padding:30px;
  animation:ilFade .8s ease;}
@keyframes ilFade{from{opacity:0}to{opacity:1}}
.il-inner{max-width:540px;text-align:center;animation:ilRise 1.2s ease;}
@keyframes ilRise{from{opacity:0;transform:translateY(20px)}to{opacity:1;transform:translateY(0)}}
.il-time{font-family:'Unbounded',sans-serif;font-weight:900;font-size:14px;
  letter-spacing:.25em;color:#c8860a;margin-bottom:18px;}
.il-line{width:60px;height:2px;background:linear-gradient(90deg,transparent,#c8860a,transparent);
  margin:0 auto 24px;}
.il-title{font-family:'Playfair Display',serif;font-size:30px;color:#ffd98a;margin-bottom:22px;}
.il-text{color:#b8b8c0;font-size:16px;line-height:1.8;margin-bottom:34px;white-space:pre-line;
  text-align:left;}
.il-continue{padding:13px 40px;background:linear-gradient(135deg,#c8860a,#a06d08);
  border:none;border-radius:30px;color:#fff;font-size:15px;font-weight:700;cursor:pointer;
  font-family:'Unbounded',sans-serif;letter-spacing:.03em;transition:transform .15s;}
.il-continue:active{transform:scale(.96);}
'''
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS интерлюдии")
PYEOF


echo ""; echo "══ 3/4  данные интерлюдий + функция показа ════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if "window.INTERLUDES" not in txt:
    il_js='{"2": {"time": "ДВЕ НЕДЕЛИ СПУСТЯ", "title": "Между делами", "text": "Дело музея закрыли, но оно не отпускало. Две недели Сдвиг и {name} складывали обрывки: свежие купюры, карточка с тиснёной буквой, «исчезнувший» директор. По отдельности — мелочи. Вместе — узор, который не давал спать.\\n\\nНить вела в Старый город — туда, где доживали свой век заброшенные типографии и где, по слухам, кто-то снова запустил печатные станки. Не для газет."}, "3": {"time": "ДВА МЕСЯЦА СПУСТЯ", "title": "По следу теней", "text": "Два месяца ушло на то, чтобы распутать клубок Старого города. Посредник заговорил, Аранделл дал показания в обмен на защиту, имя мадам Кросс всплывало снова и снова. Сеть оказалась глубже, чем думали, — щупальца тянулись через весь город к воде.\\n\\nК докам. Туда, где по ночам грузили на суда контейнеры, в которых что-то — или кто-то — дышало. {name} и Сдвиг знали: там, у чёрной воды, прячется ответ. И он им не понравится."}, "4": {"time": "ТОЙ ЖЕ НОЧЬЮ", "title": "Чёрная вода", "text": "Времени на передышку не было. Маршрут к острову был известен, корабль с грузом ушёл вперёд, и каждый час промедления стоил кому-то жизни или свободы.\\n\\nЛодка резала чёрную воду, унося Сдвига, {name} и Вивьен к острову, где гнила усадьба коллекционера. Позади остался город со всеми его тайнами. Впереди — логово человека, что собирал людей, как иные собирают бабочек."}, "5": {"time": "НА РАССВЕТЕ", "title": "У порога", "text": "Мёртвый сад остался позади. Оранжерея с её живыми картинами — тоже. Чистильщики, что гнали их от самого Старого города, пали в разгромленном холле.\\n\\nВпереди была последняя лестница и последняя дверь, за которой ждал хозяин острова — спокойный, любезный и безумный. {name} переступил порог его дома, зная: назад дороги нет. Только вперёд, к развязке, какой бы страшной она ни оказалась."}}'
    code='''
// ════ ИНТЕРЛЮДИИ между главами ════
window.INTERLUDES=''' + il_js + ''';
window._pendingInterludeNext=null;
function showInterlude(chapter, onContinue){
  var il=window.INTERLUDES[chapter];
  if(!il){ onContinue&&onContinue(); return; }
  var box=document.getElementById('interlude'); if(!box){ onContinue&&onContinue(); return; }
  var nm='Детектив'; try{ nm=window.playerName?window.playerName():'Детектив'; }catch(_){}
  document.getElementById('il-time').textContent=il.time||'';
  document.getElementById('il-title').textContent=il.title||'';
  document.getElementById('il-text').textContent=(il.text||'').replace(/\\{name\\}/g,nm);
  box.style.display='flex';
  window._pendingInterludeNext=onContinue;
  var btn=document.getElementById('il-continue');
  if(btn) btn.onclick=function(){
    box.style.display='none';
    var cb=window._pendingInterludeNext; window._pendingInterludeNext=null;
    cb&&cb();
  };
}
window.showInterlude=showInterlude;
// определить главу уровня по индексу
function chapterOfIndex(i){
  try{
    var cid=CAMPAIGN.cases[i].id;
    // chapter хранится в файле — у нас есть в campaign.subtitle/title, но надёжнее карта
    var map={'level-1':1,'case001':1,'level-2':2,'level-3':3,'level-4':4,'level-5':5};
    for(var k in map){ if(cid.indexOf(k)===0) return map[k]; }
  }catch(_){}
  return 1;
}
window.chapterOfIndex=chapterOfIndex;
'''
    # вставляем перед showEnding
    txt=txt.replace("function showEnding(r){", code+"\nfunction showEnding(r){",1)
    n+=1; print("  + данные интерлюдий + showInterlude + chapterOfIndex")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 4/4  вставка интерлюдии при переходе главы ═════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''  const restartBtn=document.getElementById("e-restart");
  if(restartBtn) restartBtn.addEventListener("click",function(){
    const _hn=CAMPAIGN&&(_caseIdx+1)<CAMPAIGN.cases.length;
    if(_hn){ loadCaseByIndex(_caseIdx+1); computeEnding._invalidate=true; }
    if(window.Feed){ initCarousel_data(); Feed.reset(); Feed.init(); } else { restartCarousel(); }
  });'''
new='''  const restartBtn=document.getElementById("e-restart");
  if(restartBtn) restartBtn.addEventListener("click",function(){
    const _hn=CAMPAIGN&&(_caseIdx+1)<CAMPAIGN.cases.length;
    if(_hn){
      var curCh=chapterOfIndex(_caseIdx);
      var nextCh=chapterOfIndex(_caseIdx+1);
      var doLoad=function(){
        loadCaseByIndex(_caseIdx+1); computeEnding._invalidate=true;
        var endEl=document.getElementById("ending"); if(endEl)endEl.classList.remove("show");
        if(window.Feed){ initCarousel_data(); Feed.reset(); Feed.init(); } else { restartCarousel(); }
      };
      // если переходим в НОВУЮ главу — показать интерлюдию
      if(nextCh>curCh && window.INTERLUDES[nextCh]){
        showInterlude(nextCh, doLoad);
      } else { doLoad(); }
    } else {
      if(window.Feed){ initCarousel_data(); Feed.reset(); Feed.init(); } else { restartCarousel(); }
    }
  });'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + интерлюдия при переходе в новую главу")
else:
    print("  ✗ обработчик не найден точно")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R86 — интерлюдии между главами (2 нед / 2 мес / по горячему)"
echo "   git add -A && git commit -m 'R86: chapter interludes with time passage' && git push"
echo "═══════════════════════════════════════════════════════"
