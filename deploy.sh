#!/usr/bin/env bash
# СДВИГ R107 — фикс текста плашек (shift a/b), убрать хинт, усилить фон и сгорание
set -e
echo "══ штамп → R107 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R107'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R107</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/4  ФИКС текста плашек: shift a/b vs left/right ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="        var lL=(ev.left&&ev.left.label)||'', rL=(ev.right&&ev.right.label)||'';"
new="        var lL=ev.shift?((ev.a&&ev.a.label)||''):((ev.left&&ev.left.label)||''), rL=ev.shift?((ev.b&&ev.b.label)||''):((ev.right&&ev.right.label)||'');"
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + плашки читают a/b для shift-развилок (текст появится)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 2/4  убрать 'свайп или тап' ════════════════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""      '<div class="oc-hint">← свайп или тап →</div>';"""
new="""      '';"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + хинт убран")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 3/4  фон уровня виден (ещё прозрачнее) ═════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="background:radial-gradient(70% 55% at 50% 45%,rgba(10,7,9,.35),rgba(10,7,9,.62));"
new="background:radial-gradient(60% 50% at 50% 42%,rgba(10,7,9,.12),rgba(10,7,9,.42));"
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + фон ещё прозрачнее (уровень виден)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 4/4  сгорание: canvas точно обугливается ═══════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# проверим: burnCard добавляет .burning на canvas и есть @keyframes
# усилим — применяем фильтр напрямую через JS (гарантия, без зависимости от CSS-класса)
old="""  function burnCard(card){
    if(!card)return;
    var cv=card.querySelector('canvas'); var target=cv||card;
    if(cv){ cv.classList.add('burning'); }"""
new="""  function burnCard(card){
    if(!card)return;
    var cv=card.querySelector('canvas'); var target=cv||card;
    if(cv){
      cv.classList.add('burning');
      // гарантированное обугливание через JS (не зависит от CSS-класса)
      cv.style.transition='filter .6s ease-in, opacity .6s ease-in, transform .6s ease-in';
      requestAnimationFrame(function(){
        cv.style.filter='brightness(.2) sepia(1) contrast(2.2) hue-rotate(-15deg)';
        cv.style.opacity='0';
        cv.style.transform='scale(.9) translateY(20px)';
      });
    }"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + сгорание через JS (гарантия обугливания)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R107 — текст плашек (shift), хинт убран, фон, сгорание"
echo "   git add -A && git commit -m 'R107: fix sticker text for shift forks, remove hint, bg, burn' && git push"
echo "═══════════════════════════════════════════════════════"
