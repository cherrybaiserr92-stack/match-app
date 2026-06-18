#!/usr/bin/env bash
# СДВИГ R13 — энергия на свайпах + реген + match-3 гейт + диалоги + отношения
set -e
echo ""; echo "══ app.js — механики из ТЗ п.3 ═════════════════════"
python3 - << 'PYEOF'
import sys
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f:
    txt = f.read()
n = 0

# ════════════════════════════════════════════════════════
# 1. ПРОФИЛЬ: поля энергии-времени + отношения со Сдвигом
# ════════════════════════════════════════════════════════
old_prof = ("  skills:{ insight:1, tech:1, charisma:1, nerve:1 },\n"
            "  achievements:[], dailyStreak:0, lastDaily:null, sound:true")
new_prof = ("  skills:{ insight:1, tech:1, charisma:1, nerve:1 },\n"
            "  achievements:[], dailyStreak:0, lastDaily:null, sound:true,\n"
            "  lastEnergyTs:0, rapport:0")
if old_prof in txt:
    txt = txt.replace(old_prof, new_prof, 1); n+=1; print("  + профиль: lastEnergyTs + rapport")

# ════════════════════════════════════════════════════════
# 2. РЕГЕН ЭНЕРГИИ: 1 кофе / 30 мин, максимум maxEnergy
# ════════════════════════════════════════════════════════
if "function regenEnergy" not in txt:
    anchor = "function addEnergy(n){"
    regen = (
        "const ENERGY_MS=30*60*1000; /* 30 мин на 1 кофе */\n"
        "function regenEnergy(){\n"
        "  const p=App.profile; if(!p) return;\n"
        "  if(!p.lastEnergyTs){ p.lastEnergyTs=Date.now(); return; }\n"
        "  if(p.energy>=p.maxEnergy){ p.lastEnergyTs=Date.now(); return; }\n"
        "  const elapsed=Date.now()-p.lastEnergyTs;\n"
        "  const gained=Math.floor(elapsed/ENERGY_MS);\n"
        "  if(gained>0){\n"
        "    p.energy=clamp(p.energy+gained,0,p.maxEnergy);\n"
        "    p.lastEnergyTs+=gained*ENERGY_MS;\n"
        "    if(p.energy>=p.maxEnergy)p.lastEnergyTs=Date.now();\n"
        "    renderHUD(); saveProfile();\n"
        "  }\n"
        "}\n"
        "function energyMsLeft(){\n"
        "  const p=App.profile; if(!p||p.energy>=p.maxEnergy) return 0;\n"
        "  return ENERGY_MS-((Date.now()-(p.lastEnergyTs||Date.now()))%ENERGY_MS);\n"
        "}\n"
    )
    txt = txt.replace(anchor, regen+anchor, 1); n+=1; print("  + регенерация энергии по времени")

# запускаем тикер регена при входе в игру (enterMain → initCarousel рядом)
old_init = "  try{ initCarousel(); }catch(e){ console.error('initCarousel',e); }"
new_init = ("  try{ initCarousel(); }catch(e){ console.error('initCarousel',e); }\n"
            "  try{ regenEnergy(); if(!App._energyTimer) App._energyTimer=setInterval(regenEnergy,60*1000); }catch(_){}")
if old_init in txt and "_energyTimer" not in txt:
    txt = txt.replace(old_init, new_init, 1); n+=1; print("  + тикер регена (раз в минуту)")

# ════════════════════════════════════════════════════════
# 3. СПИСАНИЕ ЭНЕРГИИ НА СВАЙПЕ + блок при нуле
# ════════════════════════════════════════════════════════
old_commit = ("  function commit(side){const ev=evc;if(!ev)return;\n"
              "    const opt=ev.shift?(side===\"left\"?ev.a:ev.b):(side===\"left\"?ev.left:ev.right);\n"
              "    const sp=Math.min(1,Math.abs(vx)/3800); SPIN_DUR=Math.round(660-sp*160);\n"
              "    cAdvance(side,ev,opt);}")
new_commit = ("  function commit(side){const ev=evc;if(!ev)return;\n"
              "    const opt=ev.shift?(side===\"left\"?ev.a:ev.b):(side===\"left\"?ev.left:ev.right);\n"
              "    /* энергия: 1 свайп = 1 кофе */\n"
              "    const p=App.profile;\n"
              "    if(p && p.energy<=0){ snap(); showNoEnergy(); return; }\n"
              "    if(p){ p.energy=clamp(p.energy-1,0,p.maxEnergy); if(!p.lastEnergyTs)p.lastEnergyTs=Date.now(); renderHUD(); saveProfile(); }\n"
              "    const sp=Math.min(1,Math.abs(vx)/3800); SPIN_DUR=Math.round(660-sp*160);\n"
              "    cAdvance(side,ev,opt);}")
if old_commit in txt:
    txt = txt.replace(old_commit, new_commit, 1); n+=1; print("  + свайп тратит 1 энергию")

# модалка «нет кофе»
if "function showNoEnergy" not in txt:
    anchor = "function unlockSwipe(){"
    noe = (
        "function showNoEnergy(){\n"
        "  try{haptic('shift');}catch(_){}\n"
        "  const mins=Math.ceil(energyMsLeft()/60000);\n"
        "  if(window.toast) toast('Термос пуст','Сдвиг: «Без кофе ты проспишь улику». +1 \\u2615 через '+mins+' мин','\\u2615');\n"
        "  const tab=document.getElementById('tab-cases');\n"
        "  if(tab){ var b=document.createElement('div'); b.className='noenergy-flash'; tab.appendChild(b); setTimeout(function(){b.remove();},900); }\n"
        "}\n"
    )
    txt = txt.replace(anchor, noe+anchor, 1); n+=1; print("  + модалка «нет кофе»")

# ════════════════════════════════════════════════════════
# 4. ДИАЛОГИ СДВИГА на карточке (поле ev.dialogue)
# ════════════════════════════════════════════════════════
# вставляем рендер реплики в cardHTML (не-shift ветка)
old_text = ("    +'<div class=\"text\">'+fill(ev.text,CState.flags)+'</div>'\n"
            "    +'<div class=\"spacer\"></div><div class=\"choices\">'")
new_text = ("    +'<div class=\"text\">'+fill(ev.text,CState.flags)+'</div>'\n"
            "    +(ev.dialogue?'<div class=\"dlg\">'+ev.dialogue.replace(/\\n/g,'<br>')+'</div>':'')\n"
            "    +'<div class=\"spacer\"></div><div class=\"choices\">'")
if old_text in txt:
    txt = txt.replace(old_text, new_text, 1); n+=1; print("  + диалоги Сдвига на карточке")

# ════════════════════════════════════════════════════════
# 5. MATCH-3 ГЕЙТ НА КАЖДОМ УРОВНЕ (кроме linear)
#    + поражение усложняет (минус энергия), победа = улика
# ════════════════════════════════════════════════════════
# 5a. карта получает mission из дела ИЛИ генерится по типу
if "function missionFor" not in txt:
    anchor = "function addLockOverlay(cardEl){"
    mfn = (
        "function missionFor(ev){\n"
        "  if(ev && ev.mission) return ev.mission;\n"
        "  /* генерация по типу события, если в сценарии не задано */\n"
        "  const t=(ev&&ev.t)||'evidence';\n"
        "  const M={\n"
        "    crime:    {type:'score', target:700, moves:16, label:'Собери 700 очков — осмотри сцену'},\n"
        "    evidence: {type:'clear', target:16, moves:18, label:'Очисти 16 ячеек — найди улику'},\n"
        "    witness:  {type:'color', color:0, target:12, moves:16, label:'Собери 12 красных — разговори свидетеля'},\n"
        "    suspect:  {type:'combo', target:3, moves:15, label:'Сделай 3 комбо — дожми подозреваемого'},\n"
        "    revelation:{type:'score',target:900, moves:18, label:'Собери 900 очков — собери факты'},\n"
        "    final:    {type:'score', target:1200,moves:20, label:'Собери 1200 очков — назови имя'}\n"
        "  };\n"
        "  return M[t]||M.evidence;\n"
        "}\n"
    )
    txt = txt.replace(anchor, mfn+anchor, 1); n+=1; print("  + missionFor (гейт на каждой карте)")

# 5b. openHintGame: брать mission через missionFor + поражение штрафует
old_ohg = "  const mission = card.mission || pickMission();"
new_ohg = "  const mission = missionFor(card);"
if old_ohg in txt:
    txt = txt.replace(old_ohg, new_ohg, 1); n+=1; print("  + openHintGame использует missionFor")

old_lose = "      onLose:()=>{ /* остаётся закрытым */ }"
new_lose = ("      onLose:()=>{ /* поражение усложняет путь: -1 кофе, репутация */\n"
            "        try{ const p=App.profile; if(p){ p.energy=clamp(p.energy-1,0,p.maxEnergy); addRapport(-1); renderHUD(); saveProfile(); } }catch(_){}\n"
            "        if(window.toast) toast('Улика ускользнула','Сдвиг недоволен. Попробуй снова.','\\ud83d\\udd0d');\n"
            "      }")
if old_lose in txt:
    txt = txt.replace(old_lose, new_lose, 1); n+=1; print("  + поражение в match-3 штрафует")

# ════════════════════════════════════════════════════════
# 6. СИСТЕМА ОТНОШЕНИЙ со Сдвигом (rapport)
#    растёт за «верные» (не-bad) выборы и победы, падает за поражения
# ════════════════════════════════════════════════════════
if "function addRapport" not in txt:
    anchor = "function cApplyOption(o){"
    rap = (
        "function addRapport(n){\n"
        "  const p=App.profile; if(!p) return;\n"
        "  p.rapport=clamp((p.rapport||0)+n,-10,20); saveProfile();\n"
        "}\n"
        "function rapportTitle(){\n"
        "  const r=(App.profile&&App.profile.rapport)||0;\n"
        "  if(r>=12) return 'Напарник';\n"
        "  if(r>=6)  return 'Доверие';\n"
        "  if(r>=1)  return 'Интерес';\n"
        "  if(r<=-3) return 'Раздражение';\n"
        "  return 'Новичок';\n"
        "}\n"
    )
    txt = txt.replace(anchor, rap+anchor, 1); n+=1; print("  + система отношений (rapport)")

# выбор без bad повышает rapport; bad — понижает
old_apply = ("function cApplyOption(o){\n"
             "  if(o.set) Object.assign(CState.flags,o.set);\n"
             "  if(o.evidence) cAddEvidence(o.evidence);\n"
             "}")
new_apply = ("function cApplyOption(o){\n"
             "  if(o.set) Object.assign(CState.flags,o.set);\n"
             "  if(o.evidence) cAddEvidence(o.evidence);\n"
             "  try{ addRapport(o.bad?-1:1); }catch(_){}\n"
             "}")
if old_apply in txt:
    txt = txt.replace(old_apply, new_apply, 1); n+=1; print("  + выборы влияют на отношения")

# ════════════════════════════════════════════════════════
# 7. отношения в концовке + бонус за высокий rapport
# ════════════════════════════════════════════════════════
old_meta = '  const meta=document.getElementById("e-meta");if(meta)meta.innerHTML="Сходимость: <b>"+r.align+" / 3</b> · улик: <b>"+CState.evidence.length+"</b>";'
new_meta = '  const meta=document.getElementById("e-meta");if(meta)meta.innerHTML="Сходимость: <b>"+r.align+" / 3</b> · улик: <b>"+CState.evidence.length+"</b> · Сдвиг: <b>"+rapportTitle()+"</b>";'
if old_meta in txt:
    txt = txt.replace(old_meta, new_meta, 1); n+=1; print("  + отношения в концовке")

with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
print("✓ app.js сохранён  (применено патчей: %d)" % n)
PYEOF


echo ""; echo "══ card-design.css — стили диалога/энергии ═════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f:
    txt = f.read()
if "/* R13 */" in txt:
    print("  · уже применено")
else:
    css = """
/* ════ R13 — диалоги Сдвига, нехватка кофе ════ */

/* реплика-диалог на карточке */
.dlg{
  margin-top:8px; padding:8px 11px; border-radius:10px;
  font-size:12px; line-height:1.42; color:#e7c98a;
  background:linear-gradient(120deg,rgba(200,134,10,.12),rgba(200,134,10,.03));
  border-left:2.5px solid var(--acc,#c8860a);
  font-style:italic;
}
.cfcard.active .text{ -webkit-line-clamp:3; }

/* вспышка «нет кофе» */
.noenergy-flash{
  position:absolute; inset:0; z-index:60; pointer-events:none;
  background:radial-gradient(circle at 50% 50%,rgba(255,60,40,.16),transparent 60%);
  animation:noenergyPulse .9s ease-out forwards;
}
@keyframes noenergyPulse{ 0%{opacity:0}20%{opacity:1}100%{opacity:0} }
"""
    txt += "\n/* R13 */\n" + css
    with open(path, "w", encoding="utf-8") as f:
        f.write(txt)
    print("  + CSS диалога и вспышки добавлен")
PYEOF


echo ""; echo "══ index.html — подзаголовок дела в topbar ═════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/index.html"
with open(path, encoding="utf-8") as f:
    txt = f.read()
if 'id="case-sub"' in txt:
    print("  · case-sub уже есть")
else:
    # добавляем подпись под case-name, если есть такой элемент
    import re
    if 'id="case-name"' in txt:
        txt = re.sub(r'(<div class="case-name"[^>]*id="case-name"[^>]*>.*?</div>)',
                     r'\1<div class="case-sub" id="case-sub"></div>', txt, count=1, flags=re.S)
        with open(path, "w", encoding="utf-8") as f:
            f.write(txt)
        print("  + case-sub добавлен")
    else:
        print("  · case-name не найден (подзаголовок не критичен)")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R13 готов — механики ТЗ п.3"
echo "   • энергия тратится на свайп (1 кофе) + реген 1/30мин"
echo "   • match-3 гейт на каждом уровне (поражение штрафует)"
echo "   • диалоги Сдвига на карточках"
echo "   • система отношений (Новичок→Напарник)"
echo "   git add -A && git commit -m 'R13: energy/match3-gate/dialogue/rapport' && git push"
echo "═══════════════════════════════════════════════════════"


echo ""; echo "══ scenarios — реплики Сдвига в поле dialogue ═════"
python3 - << 'PYEOF'
import json, os
SDIR = "src/main/resources/static/scenarios"

# Явные реплики для ключевых карт (id → dialogue). Текст карты НЕ трогаем.
DLG = {
  "case001.json": {
    "e0": "Сдвиг: «Проклятие, которое носит одиннадцатый размер и оставляет следы масла. Чудесно».",
    "eL2c4": "Сдвиг: «Физика, сержант. Пластина в пиджаке, магнит под куполом. Никаких горгулий».",
    "eL3c4": "Миллер: «Голос — как из машины. Я должен был вырубить рубильник на пятнадцать минут. И всё!»",
    "eL4c2": "Куратор: «Приветствую, Сдвиг. Нравится инсталляция? Я назвал её — Вознесение Скупца».",
    "eAccuse": "Сдвиг: «Куратор не убивает. Он открывает выставку. Едем»."
  },
  "case002.json": {
    "e0": "Сдвиг: «ЖАДНОСТЬ выдавлена заранее. Это не убийство в гневе. Это подпись».",
    "eL3c1": "Сдвиг: «Дорогое пальто для человека с долгами на двести тысяч. Любопытно».",
    "eL4c2": "Куратор: «Сдвиг, ты слышишь мой ритм? Следующая выставка откроется у воды».",
    "eAccuse": "Сдвиг: «Вторая глава дописана. Доки ждут третью»."
  },
  "case003.json": {
    "e0": "Сдвиг: «Утопленник без воды в лёгких. В этой воде нет воды, рекрут».",
    "eL2c2": "Сдвиг: «Горький миндаль. Цианид. Кто-то угостил капитана кофе с сюрпризом».",
    "eL4c1": "Куратор: «Третья выставка. Доки. Тщеславие красивее смотрится в тумане».",
    "eAccuse": "Сдвиг: «Сеть сменит порт, но не исчезнет. А Куратор зовёт меня в лес»."
  },
  "case004.json": {
    "e0": "Сдвиг: «Он знает, что я приду. Этот лес — не поиск мальчика. Это приглашение».",
    "eL3c2": "Сдвиг: «Уходи. Он хочет меня, не тебя». — и идёт вперёд один.",
    "eL4c1": "Дэнни: «Человек в плаще дал конфету и сказал передать записки тому, кто придёт первым».",
    "eAccuse": "Сдвиг: «Перстень с буквой А. Теперь у меня есть его инициал»."
  },
  "case005.json": {
    "e0": "Голос: «Добро пожаловать на финальную выставку. Экспонаты — вы».",
    "eL2c4": "Сдвиг: «Его отца мы закрыли в 83-м. Дело сфабриковано. Я знал — и молчал».",
    "eL3c4": "Куратор: «Я не убивал невиновных. Только тех, кто уничтожал их. Счёт закрыт. Пока».",
    "eL4c2": "Сдвиг: «Ты выбрал людей. Значит, ты не я». — и протягивает значок.",
    "eAccuse": "Сдвиг: «Куратор никогда не было имя. Это идея. А идеи не арестуют»."
  }
}

total = 0
for fn, mapping in DLG.items():
    fp = os.path.join(SDIR, fn)
    if not os.path.exists(fp): 
        print(f"  · {fn} нет"); continue
    with open(fp, encoding="utf-8") as f: d = json.load(f)
    c = 0
    for eid, line in mapping.items():
        ev = d.get("events",{}).get(eid)
        if ev and not ev.get("dialogue"):
            ev["dialogue"] = line; c += 1
    if c:
        with open(fp, "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False, indent=2)
    print(f"  + {fn}: реплик добавлено — {c}")
    total += c
print(f"✓ диалогов проставлено: {total}")
PYEOF
