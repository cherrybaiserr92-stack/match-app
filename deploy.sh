#!/usr/bin/env bash
# СДВИГ R58 — финал главы 1: Патрульный диалогом, гендер-обращения, тайминг карточки, фон
set -e
echo "══ штамп → R58 ══"
sed -i "s/SDVIG_BUILD='R57'/SDVIG_BUILD='R58'/" src/main/resources/static/app.js
sed -i 's/>R57</>R58</' src/main/resources/static/index.html

echo ""; echo "══ 1/5  Патрульный — диалогом (арт cop) ════════════"
python3 - << 'PYEOF'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
ev=d['events']
# L1_c6: Патрульный — отдельная реплика (cop), потом Сдвиг
ev['L1_c6']['text']='Зал тонул в полумраке колонн. В самом центре — пустой постамент и опрокинутый стул. Здесь директор должен был встречать гостей. Вместо него — тишина да холодный блеск мрамора.'
ev['L1_c6']['dialogue']='Патрульный: «Дверь была заперта изнутри, я сам проверял замок. Тут дело нечисто, помяните моё слово».\nСдвиг: «Нечисто — это верно. Только пахнет здесь не чертовщиной, а машинным маслом».'
ev['L1_c6'].pop('speaker',None)
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print("  + Патрульный говорит диалогом (cop), затем Сдвиг")
PYEOF


echo ""; echo "══ 2/5  парсинг 'Патрульный:' → cop в ленте ════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# В buildMessages маппинг имён реплик: добавляем Патрульный→cop
# Находим место где dialogue парсится (parseDialogue или построчно)
if "parseDialogue" in txt and "function buildMessages" in txt:
    # buildMessages использует parseDialogue (app.js) — но нужен маппинг cop.
    # Проверяем: parseDialogue берёт speaker из ev.speaker. Нам нужен построчный.
    old='''    if(ev.dialogue && window.parseDialogue){
      const lines=parseDialogue(ev);
      lines.forEach(l=>{
        if(!l.speaker || l.speaker==='narrator'){
          out.push({type:'narr', text:l.text});
        } else {
          out.push({type:'speech', speaker:l.speaker, text:l.text});
        }
      });
    }'''
    new='''    if(ev.dialogue){
      var NMAP={'сдвиг':'shift','рекрут':'recruit','миллер':'miller','эленор':'eleanor','куратор':'kurator','патрульный':'cop','капитан':'captain','хейс':'hayes','дэнни':'danny'};
      String(ev.dialogue).split('\\n').forEach(function(line){
        line=line.trim(); if(!line) return;
        var m=line.match(/^([^:«»]{2,20}):\\s*(.+)$/);
        if(m && NMAP[m[1].trim().toLowerCase()]){
          out.push({type:'speech', speaker:NMAP[m[1].trim().toLowerCase()], text:m[2].trim(), who:m[1].trim()});
        } else {
          out.push({type:'narr', text:line});
        }
      });
    }'''
    if old in txt:
        txt=txt.replace(old,new,1); n+=1; print("  + построчный парсинг с Патрульным→cop")

# имя в шапке из who (если есть)
txt=txt.replace("'<span class=\"m2-nm\">'+(NAMES[spk]||spk)+'</span>'+moodHtml",
                "'<span class=\"m2-nm\">'+(m.who||NAMES[spk]||spk)+'</span>'+moodHtml")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/5  ГЕНДЕР-обращения {м|ж} + замена 'малыш' ════"
python3 - << 'PYEOF'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
ev=d['events']
n=0
# Заменяем "малыш" на гендерный шаблон {малыш|малышка}
# и мужские глаголы в нарративе от лица Рекрута (там где "я увидел" и т.п.)
def gx(s):
    if not s: return s
    s=s.replace('малыш,','{малыш|малышка},').replace('малыш.','{малыш|малышка}.').replace('малыш»','{малыш|малышка}»').replace('малыш ','{малыш|малышка} ')
    return s
for k,e in ev.items():
    for f in ['text','dialogue','intro','react']:
        if e.get(f):
            ne=gx(e[f])
            if ne!=e[f]: e[f]=ne; n+=1
# нарратив от Рекрута (мужские формы) — eL4c3 "увидел"
if 'тень' in ev['eL4c3'].get('text','') and 'увидел' in ev['eL4c3']['text']:
    ev['eL4c3']['text']=ev['eL4c3']['text'].replace('Я впервые увидел на нём не усмешку','Впервые на его лице была не усмешка')
    n+=1
json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print(f"  + гендер-шаблон {{малыш|малышка}} в {n} местах")
PYEOF


echo ""; echo "══ 4/5  renderClues обрабатывает {м|ж} по полу ═════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# В renderClues добавляем обработку гендер-шаблона {male|female}
old="  function renderClues(text){"
new='''  function _genderText(text){
    if(!text) return text;
    var fem=false;
    try{ fem=(window.App&&App.profile&&App.profile.gender==='f'); }catch(_){}
    // {муж|жен} → выбираем по полу
    return String(text).replace(/\\{([^|{}]*)\\|([^|{}]*)\\}/g, function(_,m,f){ return fem?f:m; });
  }
  function renderClues(text){
    text=_genderText(text);'''
if old in txt and "_genderText" not in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + renderClues применяет гендер-шаблон")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 5/5  тайминг карточки + чёрный фон ══════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# ТАЙМИНГ: shift-карта ждёт окончания печати последней реплики
old='''      } else if(ev.shift){
        // shift-карта: сразу карта-решение (выбор версии свайпом, без мини-игры)
        enterDecisionMode();
      } else {'''
new='''      } else if(ev.shift){
        // shift-карта: ждём, пока допечатается последняя реплика, потом карта
        var _waitType=function(){
          var anyTyping=false;
          _wrap.querySelectorAll('.m2-bubble,.m2-narr').forEach(function(b){ if(b._typing)anyTyping=true; });
          if(anyTyping){ setTimeout(_waitType,120); }
          else { setTimeout(function(){ enterDecisionMode(); }, 400); }
        };
        _waitType();
      } else {'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + карта ждёт окончания печати диалога")

# ЧЁРНЫЙ ФОН: смягчаем градиент decision-stage (был почти чёрный по краям)
old_bg='''    .decision-stage{position:absolute;inset:0;z-index:40;display:flex;align-items:center;justify-content:center;
      background:radial-gradient(70% 60% at 50% 45%,rgba(10,14,22,.7),rgba(6,8,13,.95));}'''
new_bg='''    .decision-stage{position:absolute;inset:0;z-index:40;display:flex;align-items:center;justify-content:center;
      background:radial-gradient(80% 70% at 50% 45%,rgba(12,16,24,.55),rgba(8,11,18,.82));
      backdrop-filter:blur(3px);}'''
if old_bg in txt:
    txt=txt.replace(old_bg,new_bg,1); n+=1; print("  + фон карточки мягче (не чёрный, блюр)")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R58 — финал главы 1 (Патрульный, гендер, тайминг, фон)"
echo "   git add -A && git commit -m 'R58: ch1 polish - cop dialogue, gender text, card timing, bg' && git push"
echo "═══════════════════════════════════════════════════════"
