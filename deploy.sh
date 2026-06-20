#!/usr/bin/env bash
# СДВИГ R46 — КРИТФИКС застревания: дубль улики oil_trace + grantClue не продолжал игру
set -e
echo "══ штамп → R46 ══"
sed -i "s/SDVIG_BUILD='R45'/SDVIG_BUILD='R46'/" src/main/resources/static/app.js
sed -i 's/>R45</>R46</' src/main/resources/static/index.html

echo ""; echo "══ 1/2  app.js — grantClue продолжает игру при дубле ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# При дубле улики — НЕ молчать, а вызвать _afterClue (продолжить игру)
old=('function grantClue(clue){\n'
     '  if(!clue||!clue.id) return;\n'
     '  if(!CState.clues) CState.clues=[];\n'
     '  if(CState.clues.some(function(c){return c.id===clue.id;})) return; // уже есть\n'
     '  CState.clues.push(clue);')
new=('function grantClue(clue){\n'
     '  if(!clue||!clue.id){ var cb0=window._afterClue; window._afterClue=null; if(cb0)cb0(); return; }\n'
     '  if(!CState.clues) CState.clues=[];\n'
     '  if(CState.clues.some(function(c){return c.id===clue.id;})){\n'
     '    // улика уже есть — НЕ показываем повторно, но игру ПРОДОЛЖАЕМ\n'
     '    var cb=window._afterClue; window._afterClue=null; if(cb)cb(); return;\n'
     '  }\n'
     '  CState.clues.push(clue);')
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + grantClue вызывает _afterClue даже при дубле (не застревает)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/2  убираем ДУБЛЬ улики oil_trace (e0 vs eL2a) ══"
python3 - << 'PYEOF'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
ev=d['events']
# e0 и eL2a/eL2b имеют одну улику oil_trace. e0 — общая сцена ДО развилки.
# Улику логичнее давать в ветках (eL2a/eL2b), а у e0 убрать — там просто завязка.
n=0
if ev['e0'].get('clue',{}).get('id')=='oil_trace':
    # e0 — первая карта-решение (выбор входа). Улику убираем, она будет в ветке.
    del ev['e0']['clue']; n+=1
    print("  + улика убрана с e0 (остаётся в ветках eL2a/eL2b)")
# Проверяем что в ветках улика есть
for k in ['eL2a','eL2b']:
    if ev[k].get('clue',{}).get('id')=='oil_trace':
        print(f"  · {k}: улика 'Машинное масло' на месте")
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print(f"✓ дубль устранён ({n})")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R46 — застревание после улики исправлено"
echo "   git add -A && git commit -m 'R46: fix freeze - duplicate clue + grantClue continues game' && git push"
echo "═══════════════════════════════════════════════════════"
