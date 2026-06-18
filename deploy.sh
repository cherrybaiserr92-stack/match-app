#!/usr/bin/env bash
# СДВИГ R14 — вступление + лейаут карт + скролл текста + рубашка без «С» + разные исходы
set -e

echo ""; echo "══ 1/4  case001 — добавляем Уровень 1 «Знакомство» ══"
python3 - << 'PYEOF'
import json
fp = "src/main/resources/static/scenarios/case001.json"
with open(fp, encoding="utf-8") as f: d = json.load(f)

# Уже добавлено?
if "L1_c1" in d.get("events",{}):
    print("  · вступление уже есть"); 
else:
    # 8 линейных карт вступления (тап «Далее», без свайпа/энергии/match-3)
    intro = {
      "L1_c1":{"linear":True,"t":"intro","badge":"Октябрь 1987","title":"Дождь над кварталом",
        "text":"Дождь смывал грязь с улиц, но не из людей. Дворники полицейского «Форда» размазывали воду по стеклу — туда, обратно, как маятник, который никуда не ведёт.",
        "dialogue":"Рекрут: «Почти на месте, агент Сдвиг».","next":"L1_c2"},
      "L1_c2":{"linear":True,"t":"intro","badge":"Напарник","title":"Щелчок диктофона",
        "text":"Человек на пассажирском сиденье не шевелился. Он слушал кассету. Щелчок. Тишина. Щелчок. Будто разбирал чужую речь на детали.",
        "dialogue":"Сдвиг: «Веришь в призраков, малыш? Городской департамент верит. Они боятся войти в музей».","next":"L1_c3"},
      "L1_c3":{"linear":True,"t":"intro","badge":"Музей","title":"Готическая глыба",
        "text":"Здание нависло над улицей. Каменные львы у входа казались мокрыми от крови — но это лишь отсветы мигалок ползли по их мордам.",
        "dialogue":"Рекрут: «По рации сказали — тело висит в воздухе. Никаких тросов».","next":"L1_c4"},
      "L1_c4":{"linear":True,"t":"intro","badge":"Метод","title":"Сухой смешок",
        "text":"Сдвиг усмехнулся — звук как треск ломающейся ветки.",
        "dialogue":"Сдвиг: «Левитация. Банально. Люди готовы поверить в магию, лишь бы не думать. Пошли».","next":"L1_c5"},
      "L1_c5":{"linear":True,"t":"intro","badge":"Запах","title":"Гроза в помещении",
        "text":"Под лентой — запах старой бумаги, нафталина и чего-то едкого. Озон. Воздух будто наэлектризован.",
        "dialogue":"Сдвиг: «Чувствуешь? Пахнет грозой за закрытой дверью. Запомни этот запах».","next":"L1_c6"},
      "L1_c6":{"linear":True,"t":"crime","badge":"Главный зал","title":"Тело под куполом",
        "text":"Зал с колоннами. На высоте тридцати футов, раскинув руки, парил мёртвый директор музея. Под ним — только холодный мраморный пол.",
        "dialogue":"Патрульный: «Клянусь, он просто висит! Горгульи… это проклятие семьи основателя!»","next":"L1_c7"},
      "L1_c7":{"linear":True,"t":"intro","badge":"Дедукция","title":"Ботинки проклятия",
        "text":"Сдвиг даже не поднял глаза вверх. Он присел над лужей у входа и тронул её пальцем в перчатке.",
        "dialogue":"Сдвиг: «Проклятие, которое носит одиннадцатый размер и оставляет следы машинного масла. Чудесно».","next":"L1_c8"},
      "L1_c8":{"linear":True,"t":"intro","badge":"Куантико","title":"Надевай перчатки",
        "text":"Он поднял на меня взгляд — холоднее ноябрьского ливня. Первое настоящее дело начиналось здесь и сейчас.",
        "dialogue":"Сдвиг: «Время показать, чему тебя учили. Надевай перчатки, рекрут».","next":"e0"}
    }
    # вставляем в начало, стартуем со вступления
    d["events"] = {**intro, **d["events"]}
    d["start"] = "L1_c1"
    d["total"] = d.get("total",16) + 8
    with open(fp, "w", encoding="utf-8") as f:
        json.dump(d, f, ensure_ascii=False, indent=2)
    print("  + 8 карт вступления добавлены, start=L1_c1")
PYEOF


echo ""; echo "══ 2/4  app.js — linear-режим + разные исходы ══════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n = 0

# ── 2a. cardHTML: ветка для linear-карт (тап «Далее», без выбора) ──
old_fn_start = "function cardHTML(ev){\n  const scene="
new_fn_start = ("function cardHTML(ev){\n"
  "  const scene_=")
# вставим linear-ветку сразу после объявления scene
old_scene = "  const scene='<div class=\"scene\"><div class=\"grad\"></div><div class=\"art\" style=\"background-image:'+artBg(ev.t)+'\"></div></div>';\n  if(ev.shift){"
new_scene = ("  const scene='<div class=\"scene\"><div class=\"grad\"></div><div class=\"art\" style=\"background-image:'+artBg(ev.t)+'\"></div></div>';\n"
  "  if(ev.linear){\n"
  "    return gframeHTML()+scene+'<div class=\"pad\">'\n"
  "      +'<span class=\"badge\">'+ev.badge+'</span>'\n"
  "      +'<div class=\"title\">'+ev.title+'</div>'\n"
  "      +'<div class=\"text scrollable\">'+fill(ev.text,CState.flags)+'</div>'\n"
  "      +(ev.dialogue?'<div class=\"dlg\">'+ev.dialogue.replace(/\\n/g,'<br>')+'</div>':'')\n"
  "      +'<div class=\"spacer\"></div>'\n"
  "      +'<button class=\"linear-next\">Далее \\u2192</button>'\n"
  "      +'</div>';\n"
  "  }\n"
  "  if(ev.shift){")
if old_scene in txt:
    txt = txt.replace(old_scene, new_scene, 1); n+=1; print("  + linear-ветка в cardHTML")

# ── 2b. текст карт делаем скроллируемым (.scrollable) ──
old_text2 = "    +'<div class=\"text\">'+fill(ev.text,CState.flags)+'</div>'\n    +(ev.dialogue?"
new_text2 = "    +'<div class=\"text scrollable\">'+fill(ev.text,CState.flags)+'</div>'\n    +(ev.dialogue?"
if old_text2 in txt:
    txt = txt.replace(old_text2, new_text2, 1); n+=1; print("  + текст карт скроллируемый")

# ── 2c. setActive: для linear — кнопка «Далее», без замка/match-3 ──
old_setactive = ("function setActive(el,ev){\n"
  "  el.classList.add(\"active\"); el.classList.toggle(\"shift\",!!ev.shift);\n"
  "  el.innerHTML='<div class=\"cfinner\">'+cardHTML(ev)+'</div>'; el._ev=ev; cActive=el;\n"
  "  App.currentCard=ev; App.swipeUnlocked=false;\n"
  "  addLockOverlay(el);\n"
  "}")
new_setactive = ("function setActive(el,ev){\n"
  "  el.classList.add(\"active\"); el.classList.toggle(\"shift\",!!ev.shift);\n"
  "  el.classList.toggle(\"linear\",!!ev.linear);\n"
  "  el.innerHTML='<div class=\"cfinner\">'+cardHTML(ev)+'</div>'; el._ev=ev; cActive=el;\n"
  "  App.currentCard=ev; App.swipeUnlocked=false;\n"
  "  if(ev.linear){\n"
  "    var btn=el.querySelector('.linear-next');\n"
  "    if(btn) btn.addEventListener('click',function(){ try{Sound.tap();}catch(_){} linearAdvance(ev); });\n"
  "    App.swipeUnlocked=false;\n"
  "  } else {\n"
  "    addLockOverlay(el);\n"
  "  }\n"
  "}")
if old_setactive in txt:
    txt = txt.replace(old_setactive, new_setactive, 1); n+=1; print("  + setActive: linear без match-3")

# ── 2d. linearAdvance: переход по next без свайпа/энергии/огня ──
if "function linearAdvance" not in txt:
    anchor = "function cAdvance(dir,ev,opt){"
    la = ("function linearAdvance(ev){\n"
      "  if(cBusy) return; cBusy=true;\n"
      "  var nextId=ev.next;\n"
      "  var c0=cfCards[centerIndex];\n"
      "  CState.step++; cSetProgress();\n"
      "  // лёгкий поворот кольца вперёд, без огня\n"
      "  centerIndex=(centerIndex+1+CN)%CN;\n"
      "  var resolve=(nextId==='__resolve__'||!nextId);\n"
      "  if(!resolve) setActive(cfCards[centerIndex],CASE.events[nextId]);\n"
      "  cLayout(true);\n"
      "  setTimeout(function(){\n"
      "    if(resolve) showEnding(computeEnding(CState.flags));\n"
      "    else if(c0!==cfCards[centerIndex]) setBack(c0);\n"
      "    cBusy=false;\n"
      "  }, Math.max(560,SPIN_DUR+40));\n"
      "}\n")
    txt = txt.replace(anchor, la+anchor, 1); n+=1; print("  + linearAdvance")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js (часть 1): применено %d" % n)
PYEOF


echo ""; echo "══ 3/4  app.js — рубашка без «С» (только декор) ════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()

# Убираем огромную «С» в центре рубашки — оставляем только рамку с филигранью
old_back = 'function backHTML(){return gframeHTML()+\'<div class="cmono">С</div>\';}'
new_back = 'function backHTML(){return gframeHTML()+\'<div class="cback-emblem"></div>\';}'
if old_back in txt:
    txt = txt.replace(old_back, new_back, 1)
    print("  + «С» на рубашке заменена на тонкий эмблемный декор")
else:
    print("  · backHTML уже без «С»")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js (часть 2)")
PYEOF


echo ""; echo "══ 4/4  card-design.css — лейаут, скролл, рубашка ══"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f: txt = f.read()

if "/* R14 */" in txt:
    print("  · уже применено")
else:
    css = """
/* ════════ R14 — финальный лейаут карт ════════ */

/* 1. КАРТЫ НЕ ВЫЛЕЗАЮТ ЗА ВЕРХ: уменьшаем высоту + центр кольца ниже */
:root{
  --card-h: min(46vh, 366px) !important;
  --card-w: min(58%, 206px) !important;
}
.ring-scene{ perspective-origin:50% 42% !important; }
/* верхние боковые карты притушить, чтобы не лезли под HUD */
.stage{ overflow:hidden !important; }

/* 2. РУБАШКА БЕЗ «С» — тонкий ромб-эмблема по центру */
.cmono{ display:none !important; }
.cback-emblem{
  position:absolute; left:50%; top:50%; transform:translate(-50%,-50%) rotate(45deg);
  width:54px; height:54px; border:1.5px solid rgba(240,205,130,.22);
  border-radius:8px; z-index:2;
}
.cback-emblem::after{
  content:''; position:absolute; inset:9px; border:1px solid rgba(240,205,130,.14); border-radius:5px;
}

/* 3. ТЕКСТ: правильное расположение + СКРОЛЛ если не влезает */
.cfcard.active .cfinner .pad{
  padding-top:46px !important;
  padding-bottom:12px !important;
  display:flex; flex-direction:column;
}
.cfcard.active .title{
  font-size:17px !important; line-height:1.16 !important; margin:6px 0 8px !important;
}
.text.scrollable{
  -webkit-line-clamp:unset !important; display:block !important;
  overflow-y:auto !important; -webkit-overflow-scrolling:touch;
  max-height:34vh; padding-right:4px;
  -webkit-mask-image:linear-gradient(180deg,#000 0,#000 88%,transparent 100%);
  mask-image:linear-gradient(180deg,#000 0,#000 88%,transparent 100%);
}
.text.scrollable::-webkit-scrollbar{ width:3px; }
.text.scrollable::-webkit-scrollbar-thumb{ background:rgba(200,134,10,.4); border-radius:3px; }
/* во время свайпа активной карты — скролл не мешает жесту */
.cfcard.active.grab .text.scrollable{ overflow:hidden !important; }

/* 4. ДИАЛОГ компактнее, чтобы не выталкивал кнопку */
.dlg{ margin-top:6px !important; font-size:11.5px !important; max-height:none; }

/* 5. КНОПКА «ДАЛЕЕ» для линейных карт вступления */
.linear-next{
  width:100%; margin-top:8px; padding:13px 16px; border:none; border-radius:12px; cursor:pointer;
  background:linear-gradient(180deg,#ffdf95,var(--acc,#c8860a)); color:#241701;
  font-family:'Unbounded',sans-serif; font-weight:800; font-size:13px; letter-spacing:.04em;
  box-shadow:0 8px 22px rgba(200,134,10,.32);
}
.linear-next:active{ filter:brightness(.92); }
/* у линейных карт нет замка/выбора — pad выстроен под текст+кнопку */
.cfcard.linear .pad{ justify-content:flex-start; }
.cfcard.linear .scene .grad{
  background:radial-gradient(95% 55% at 50% 0%,rgba(200,134,10,.1),transparent 62%),
    linear-gradient(180deg,rgba(14,20,30,.2),rgba(5,8,13,.92)) !important;
}

/* 6. choices: исходы свайпа чуть крупнее и читаемее */
.choice{ padding:9px 7px !important; }
.choice .dir{ opacity:.85; }
"""
    txt += "\n/* R14 */\n" + css
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + R14 CSS добавлен")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R14 готов"
echo "   git add -A && git commit -m 'R14: intro chapter + card layout + scroll + clean back' && git push"
echo "═══════════════════════════════════════════════════════"

echo ""; echo "══ 5/5  scenarios — различаем «карты-связки» ════════"
python3 - << 'PYEOF'
import json, os
SDIR = "src/main/resources/static/scenarios"

# Для переходных карт (left==right) даём осмысленно-разные ярлыки.
# Текст исхода (evidence) остаётся, т.к. оба пути ведут к одной сюжетной точке —
# но игрок видит РАЗНЫЕ формулировки выбора (стиль действия), а не дубль.
RELABEL = {
  "case001.json": {
    "e0":     ("Войти молча", "Войти за Сдвигом"),
    "eL2c3":  ("Резать аккуратно", "Резать решительно"),
    "eL2c4":  ("Осмотреть тело", "Звать патрульного"),
    "eL3c3":  ("Дожать молчанием", "Дожать вопросом"),
    "eL3c4":  ("Записать показания", "Поверить старику"),
    "eL4c3":  ("Слушать наушником", "Вывести на динамик"),
    "eAccuse":("Назвать имя вслух", "Записать в протокол")
  },
  "case002.json": {
    "e0":     ("Войти в цех", "Осмотреть с порога"),
    "eL2c4":  ("Подойти к Хейсу", "Наблюдать за Хейсом"),
    "eL3c4":  ("Изъять факс", "Сфотографировать факс"),
    "eAccuse":("Брать Хейса", "Оформить протокол")
  },
  "case003.json": {
    "e0":     ("К телу через причал", "К телу по воде"),
    "eL2c4":  ("Подойти к Конрою", "Наблюдать за Конроем"),
    "eL3c4":  ("Вскрыть ящик", "Проверить замок"),
    "eAccuse":("В лес немедленно", "Доложить и в лес")
  },
  "case004.json": {
    "e0":     ("Идти по следам", "Идти за Сдвигом"),
    "eL2c3":  ("Войти первым", "Прикрыть Сдвига"),
    "eL3c3":  ("Спуститься тихо", "Спуститься быстро"),
    "eAccuse":("К особняку сразу", "К особняку с уликой")
  },
  "case005.json": {
    "eL2c4":  ("Слушать Сдвига", "Изучать досье"),
    "eL3c4":  ("Идти в тоннель", "Осмотреть подвал"),
    "eAccuse":("Закрыть дело", "Оставить открытым")
  }
}

total = 0
for fn, mapping in RELABEL.items():
    fp = os.path.join(SDIR, fn)
    if not os.path.exists(fp): continue
    with open(fp, encoding="utf-8") as f: d = json.load(f)
    c = 0
    for eid, (ll, rl) in mapping.items():
        ev = d.get("events",{}).get(eid)
        if not ev: continue
        if ev.get("left") and ev.get("right"):
            # меняем ярлык только если они совпадали
            if ev["left"].get("label")==ev["right"].get("label"):
                ev["left"]["label"]=ll; ev["right"]["label"]=rl; c+=1
    if c:
        with open(fp, "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False, indent=2)
    print(f"  + {fn}: различено связок — {c}")
    total += c
print(f"✓ переходных карт различено: {total}")
PYEOF
