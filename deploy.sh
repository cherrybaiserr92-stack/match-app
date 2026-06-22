#!/usr/bin/env bash
# СДВИГ R54 — интеграция новых артов: Эленор, Патрульный, фоны глав
set -e
echo "══ штамп → R54 ══"
sed -i "s/SDVIG_BUILD='R53'/SDVIG_BUILD='R54'/" src/main/resources/static/app.js
sed -i 's/>R53</>R54</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  CHARS — Эленор реальный арт + новые персонажи"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Эленор: guests-заглушка → реальный арт
old="  eleanor:{src:'/img/chars/char-guests.png',  side:'left'},  /* TODO: арт Эленор */"
new='''  eleanor:{src:'/img/chars/char-eleanor.png', side:'left'},
  cop:    {src:'/img/chars/char-cop.png',     side:'left'},
  captain:{src:'/img/chars/char-captain.png', side:'right'},
  pocketman:{src:'/img/chars/char-pocketman.png',side:'left'},'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + Эленор реальный арт + cop/captain/pocketman")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/3  фоны глав 2-5 ═══════════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''const CASE_BGS={
  'case001':'/img/bg/bg-ch1-hall.png'
  /* остальные фоны добавить, когда арт будет готов */
};'''
new='''const CASE_BGS={
  'case001':'/img/bg/bg-ch1-hall.png',
  'case002':'/img/bg/bg-oldcity.jpg',
  'case003':'/img/bg/bg-docks.jpg',
  'case004':'/img/bg/bg-mansion-ext.jpg',
  'case005':'/img/bg/bg-mansion-int.jpg'
};'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + фоны глав 2-5 (старый город/доки/особняк)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/3  имена в ленте (Патрульный, Капитан) ════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# NAMES в ленте
if "cop:'Патрульный'" not in txt:
    txt=txt.replace("eleanor:'Эленор',","eleanor:'Эленор',cop:'Патрульный',captain:'Капитан',pocketman:'Свидетель',")
    n+=1; print("  + имена Патрульный/Капитан в ленте")
# av-cop кроп (патрульный — фуражка, голова чуть ниже)
if ".m2-av.av-cop img" not in txt:
    anchor=".m2-av.av-eleanor img{width:148%;left:-24%;top:5%;}"
    add=anchor+"\n    .m2-av.av-cop img{width:130%;left:-15%;top:2%;}\n    .m2-av.av-captain img{width:125%;left:-12%;top:1%;}"
    txt=txt.replace(anchor,add,1); n+=1; print("  + кроп Патрульного/Капитана")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R54 — арты интегрированы (Эленор, Патрульный, фоны)"
echo "   git add -A && git commit -m 'R54: integrate new art - Eleanor, cop, chapter backgrounds' && git push"
echo "═══════════════════════════════════════════════════════"
