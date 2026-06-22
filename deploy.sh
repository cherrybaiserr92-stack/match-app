#!/usr/bin/env bash
# СДВИГ R53 — кроп Сдвиг/Куратор, досье в угол, дубль фургона, подводки к shift-картам
set -e
echo "══ штамп → R53 ══"
sed -i "s/SDVIG_BUILD='R52'/SDVIG_BUILD='R53'/" src/main/resources/static/app.js
sed -i 's/>R52</>R53</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  кроп Сдвиг/Куратор — меньше зум, голова влезает"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Сдвиг (голова 9%, в шляпе) и Куратор (13%) — меньше зум, показать голову целиком
old='''    .m2-av.av-shift img{width:148%;left:-24%;top:9%;}
    .m2-av.av-recruit img{width:150%;left:-25%;top:7%;}
    .m2-av.av-miller img{width:145%;left:-22%;top:8%;}
    .m2-av.av-eleanor img{width:150%;left:-25%;top:7%;}
    .m2-av.av-kurator img{width:148%;left:-24%;top:8%;}'''
new='''    .m2-av.av-shift img{width:128%;left:-14%;top:1%;}
    .m2-av.av-recruit img{width:150%;left:-25%;top:7%;}
    .m2-av.av-miller img{width:140%;left:-20%;top:5%;}
    .m2-av.av-eleanor img{width:148%;left:-24%;top:5%;}
    .m2-av.av-kurator img{width:122%;left:-11%;top:0%;}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + Сдвиг/Куратор: меньше зум, голова целиком")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 2/4  улика летит в досье (вниз-вправо, где счётчик) ═"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# flyToDossier: лететь вниз-вправо (где счётчик), а не в левый верх
old='''      fly.style.left='14px'; fly.style.top='10px'; fly.style.opacity='0'; fly.style.transform='scale(.5)';'''
new='''      fly.style.left=(sr.width-60)+'px'; fly.style.top=(sr.height-30)+'px'; fly.style.opacity='0'; fly.style.transform='scale(.4)';'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + улика летит вниз-вправо (к счётчику досье)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/4  досье-счётчик: гарантируем привязку клика ════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# initEvPanel вызывается, но кнопка теперь tools-mini c id ev-chip. Убедимся что обработчик вешается заново.
# Добавим прямой обработчик с делегированием на случай пересоздания
if "_evChipBound" not in txt:
    old='''function initEvPanel(){
  const chip=document.getElementById("ev-chip");
  if(chip) chip.addEventListener("click",function(){'''
    new='''function initEvPanel(){
  const chip=document.getElementById("ev-chip");
  if(chip && !chip._evChipBound){ chip._evChipBound=true; chip.addEventListener("click",function(){'''
    if old in txt:
        # надо закрыть лишнюю скобку — найдём конец обработчика
        txt=txt.replace(old,new,1)
        # заменяем закрытие "});" первого обработчика на "}); }"
        # ищем "panel.classList.add(\"open\");\n  });"
        txt=txt.replace('panel.classList.add("open");\n  });',
                        'panel.classList.add("open");\n  }); }',1)
        n+=1; print("  + ev-chip обработчик с защитой от дубля")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 4/4  сюжет — убрать дубль фургона + подводки к shift ═"
python3 - << 'PYEOF'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
ev=d['events']
n=0

# ДУБЛЬ ФУРГОНА: Эленор даёт van_hint, Миллер — van. Оставляем подтверждение,
# но Эленор НЕ выдаёт улику в досье — её слова становятся НАВОДКОЙ (упоминание),
# а полноценную улику "Фургон" даёт только Миллер (eL3soft).
if ev['eEleanorChoice']['right'].get('clue',{}).get('id')=='van_hint':
    # убираем clue у Эленор, оставляем текст-намёк
    del ev['eEleanorChoice']['right']['clue']
    ev['eEleanorChoice']['right']['evidence']='Ты заговорил мягко, без нажима. Эленор выдохнула и тихо обронила: ночью у чёрного хода стоял длинный фургон без окон. Зацепка, но пока лишь слова.'
    n+=1; print("  + дубль фургона убран (Эленор даёт намёк, улику — Миллер)")

# ПОДВОДКИ к shift-картам: добавляем text+dialogue, чтобы не было "двух карт подряд"
ev['eShift1']['text']='Сдвиг отступил на шаг и обвёл зал взглядом — масло, борозда, ход за портьерой, чужая шестерёнка. Все нити сошлись в его глазах в одну картину.'
ev['eShift1']['dialogue']='Сдвиг: «Ну, малыш, картина сложилась. Теперь скажи мне сам — что здесь произошло?»'
ev['eShift1']['speaker']='shift'

ev['eShift2']['text']='Сдвиг подбросил на ладони пачку купюр, найденную у сторожа. Деньги, темнота, чужой голос в трубке — всё это требовало объяснения.'
ev['eShift2']['dialogue']='Сдвиг: «Старик взял деньги. Вопрос — за что именно. Реши, как это занести в дело».'
ev['eShift2']['speaker']='shift'

ev['eShift3']['text']='Плёнка автоответчика всё ещё крутилась в голове. Театральность, металлический голос, инсценировка как спектакль. Сдвиг ждал твоего слова.'
ev['eShift3']['dialogue']='Сдвиг: «Ну? Чья это работа, детектив? Назови имя — и мы знаем, за кем едем».'
ev['eShift3']['speaker']='shift'
n+=1; print("  + подводки к shift-картам (нет 'двух карт подряд')")

# ПЕРЕХОДЫ-объяснения: добавим связки "вошли в музей", "на месте"
# L1_c5 → L1_c6: добавим что переступили порог
ev['L1_c8']['text']='Сдвиг толкнул тяжёлую дверь, и мы переступили порог музея. Холод мрамора, эхо шагов под куполом. Где-то здесь час назад стоял живой человек — и растворился. Он поднял на меня взгляд холоднее ноябрьского ливня.'
n+=1; print("  + переход 'вошли в музей'")

json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print(f"✓ сюжет: {n}")
PYEOF



echo ""; echo "══ 5/5  shift: intro только на карте, не в ленте ════"
python3 - << 'PYEOF2'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""    // shift-карта (выбор версии): показываем intro как реплику-вопрос
    if(ev.shift && ev.intro){
      out.push({type:'narr', text:ev.intro});
    }"""
new="""    // shift-карта: intro показываем в ленте ТОЛЬКО если нет dialogue (иначе intro будет на самой карте)
    if(ev.shift && ev.intro && !ev.dialogue){
      out.push({type:'narr', text:ev.intro});
    }"""
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + intro не дублируется (есть на карте)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("OK: %d"%n)
PYEOF2

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R53 — кроп, досье, дубль фургона, подводки"
echo "   git add -A && git commit -m 'R53: shift/kurator crop, dossier fly, van dedup, shift-card lead-ins' && git push"
echo "═══════════════════════════════════════════════════════"
