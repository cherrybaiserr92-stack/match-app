#!/usr/bin/env bash
# СДВИГ R85 — нормализация шкал: сетка 3/6/10 (отношения и детектив)
set -e
echo "══ штамп → R85 ══"
sed -i "s/SDVIG_BUILD='R84'/SDVIG_BUILD='R85'/" src/main/resources/static/app.js
sed -i 's/>R84</>R85</' src/main/resources/static/index.html

echo ""; echo "══ нормализация всех развилок к сетке 3/6/10 ═══════"
cd src/main/resources/static
python3 - << 'PYEOF'
import json
camp=json.load(open('scenarios/campaign.json',encoding='utf-8'))
order=[c['id'] for c in camp['cases']]

def snap(v):
    if v==0: return 0
    a=abs(v); s=1 if v>0 else -1
    if a<=4: return s*3
    if a<=7: return s*6
    return s*10

changed=0
for cid in order:
    p=f'scenarios/{cid}.json'
    d=json.load(open(p,encoding='utf-8'))
    for e in d['events'].values():
        is_shift=e.get('shift')
        for sd in ['left','right','mid','a','b']:
            o=e.get(sd)
            if not o: continue
            if is_shift and sd in ('a','b'):
                # ВЕРСИИ: верная +10 детектив, неверная -6 детектив / -3 отн
                if o.get('bad'):
                    if 'dscore' in o: o['dscore']=-6; changed+=1
                    if 'rapport' in o: o['rapport']=(-3 if o['rapport']<0 else 0); changed+=1
                else:
                    if 'dscore' in o: o['dscore']=10; changed+=1
                    if 'rapport' in o: o['rapport']=(3 if o['rapport']>0 else 0); changed+=1
            else:
                # ОБЫЧНЫЕ: сетка 3/6/10
                for key in ['dscore','rapport']:
                    if key in o:
                        nv=snap(o[key])
                        if o[key]!=nv: changed+=1
                        o[key]=nv
    json.dump(d,open(p,'w',encoding='utf-8'),ensure_ascii=False,indent=2)

print(f"  ✓ нормализовано значений: {changed}")
# контроль
rap=set(); det=set()
for cid in order:
    d=json.load(open(f'scenarios/{cid}.json',encoding='utf-8'))
    for e in d['events'].values():
        for sd in ['left','right','mid','a','b']:
            o=e.get(sd)
            if o:
                if 'rapport' in o: rap.add(o['rapport'])
                if 'dscore' in o: det.add(o['dscore'])
print("  отношения:", sorted(rap))
print("  детектив:", sorted(det))
PYEOF
cd - >/dev/null

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R85 — шкалы по сетке 3/6/10 (малый±3 средний±6 крупный±10)"
echo "   git add -A && git commit -m 'R85: normalize scales to 3/6/10 grid' && git push"
echo "═══════════════════════════════════════════════════════"
