#!/usr/bin/env bash
# СДВИГ R24 — выезжающие персонажи + смена фонов
# ════════════════════════════════════════════════
# ПЕРЕД ЗАПУСКОМ: скопируй папку img/ в репозиторий:
#   cp -r /sdcard/Download/img src/main/resources/static/
# ════════════════════════════════════════════════
set -e

echo ""; echo "══ 1/4  Создаём папки для арта ══════════════════════"
mkdir -p src/main/resources/static/img/chars
mkdir -p src/main/resources/static/img/bg
echo "  ✓ img/chars/ img/bg/ готовы"
echo "  ! Убедись что скопировал файлы из /sdcard/Download/img/ сюда"
ls src/main/resources/static/img/chars/*.png 2>/dev/null | wc -l | xargs -I{} echo "  Персонажей найдено: {}"
ls src/main/resources/static/img/bg/*.png 2>/dev/null | wc -l | xargs -I{} echo "  Фонов найдено: {}"


echo ""; echo "══ 2/4  app.js — система персонажей + фонов ══════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n = 0

# ── CHARS map + showChar/hideChar/updateCaseBg ──────
if "const CHARS=" not in txt:
    anchor = "function initCarousel(){"
    code = r"""
/* ═══ ПЕРСОНАЖИ-СПРАЙТЫ (R24) ═══ */
const CHARS={
  shift:  {src:'/img/chars/char-shift.png',   side:'left'},
  recruit:{src:'/img/chars/char-recruit.png', side:'left'},
  kurator:{src:'/img/chars/char-kurator.png', side:'right'},
  arundel:{src:'/img/chars/char-arundel.png', side:'right'},
  miller: {src:'/img/chars/char-miller.png',  side:'right'},
  hayes:  {src:'/img/chars/char-hayes.png',   side:'right'},
  romero: {src:'/img/chars/char-romero.png',  side:'right'},
  conroy: {src:'/img/chars/char-conroy.png',  side:'right'},
  jiang:  {src:'/img/chars/char-jiang.png',   side:'right'},
  purcell:{src:'/img/chars/char-purcell.png', side:'right'},
  danny:  {src:'/img/chars/char-danny.png',   side:'right'},
  guests: {src:'/img/chars/char-guests.png',  side:'right'}
};
const CASE_BGS={
  'case001':'/img/bg/bg-ch1-hall.png'
  /* остальные фоны добавить, когда арт будет готов */
};
let _charEl=null,_charId=null;
function showChar(id){
  if(!id||!CHARS[id]){hideChar();return;}
  const def=CHARS[id];
  if(!_charEl){
    _charEl=document.createElement('img');
    _charEl.className='char-sprite';
    (document.getElementById('main-screen')||document.body).appendChild(_charEl);
  }
  if(_charId!==id){
    _charEl.style.transition='none';
    _charEl.classList.remove('show');
    _charEl.className='char-sprite '+def.side;
    _charEl.src=def.src; _charId=id;
    /* double rAF гарантирует что CSS transition подхватит */
    requestAnimationFrame(function(){requestAnimationFrame(function(){
      _charEl.style.transition='';_charEl.classList.add('show');
    });});
  } else { _charEl.classList.add('show'); }
}
function hideChar(){
  if(!_charEl)return; _charEl.classList.remove('show'); _charId=null;
}
function updateCaseBg(){
  try{
    const cid=CAMPAIGN&&CAMPAIGN.cases[_caseIdx]?CAMPAIGN.cases[_caseIdx].id:'';
    const bg=CASE_BGS[cid]||null;
    const st=document.getElementById('stage'); if(!st)return;
    if(bg){ st.style.backgroundImage="url('"+bg+"')"; st.style.backgroundSize='cover'; st.style.backgroundPosition='center top'; }
    else { st.style.backgroundImage=''; }
  }catch(_){}
}
"""
    txt = txt.replace(anchor, code+anchor, 1); n+=1; print("  + CHARS + showChar/hideChar/updateCaseBg")

# ── setActive: вызываем showChar при каждой новой карте ──
old_setactive_end = ("  App.currentCard=ev; App.swipeUnlocked=false;\n"
                     "  if(ev.linear){\n"
                     "    var btn=el.querySelector('.linear-next');\n"
                     "    if(btn) btn.addEventListener('click',function(){ try{Sound.tap();}catch(_){} linearAdvance(ev); });\n"
                     "    App.swipeUnlocked=false;\n"
                     "  } else {\n"
                     "    addLockOverlay(el);\n"
                     "  }\n"
                     "}")
new_setactive_end = ("  App.currentCard=ev; App.swipeUnlocked=false;\n"
                     "  try{ showChar(ev.speaker||null); }catch(_){}\n"
                     "  if(ev.linear){\n"
                     "    var btn=el.querySelector('.linear-next');\n"
                     "    if(btn) btn.addEventListener('click',function(){ try{Sound.tap();}catch(_){} linearAdvance(ev); });\n"
                     "    App.swipeUnlocked=false;\n"
                     "  } else {\n"
                     "    addLockOverlay(el);\n"
                     "  }\n"
                     "}")
if old_setactive_end in txt:
    txt = txt.replace(old_setactive_end, new_setactive_end, 1); n+=1; print("  + setActive вызывает showChar")

# ── initCarousel: updateCaseBg + hideChar при старте ──
old_init_end = "  cSetProgress(); buildBacks(); initEvPanel();"
new_init_end = "  cSetProgress(); buildBacks(); initEvPanel(); try{updateCaseBg();hideChar();}catch(_){}"
if old_init_end in txt:
    txt = txt.replace(old_init_end, new_init_end, 1); n+=1; print("  + initCarousel вызывает updateCaseBg + hideChar")

# ── при смене дела — обновляем фон ──
old_loadcase_end = '    localStorage.setItem("sdvig_case",cid);}catch(e){}'
new_loadcase_end = '    localStorage.setItem("sdvig_case",cid); try{updateCaseBg();hideChar();}catch(_){};}catch(e){}'
if old_loadcase_end in txt:
    txt = txt.replace(old_loadcase_end, new_loadcase_end, 1); n+=1; print("  + смена дела обновляет фон")

# ── при showEnding — скрываем персонажа ──
old_ending = "  haptic(r.kind===\"fail\"?\"shift\":\"burn\"); endEl.classList.add(\"show\");"
new_ending = "  haptic(r.kind===\"fail\"?\"shift\":\"burn\"); endEl.classList.add(\"show\"); try{hideChar();}catch(_){}"
if old_ending in txt:
    txt = txt.replace(old_ending, new_ending, 1); n+=1; print("  + showEnding скрывает персонажа")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: применено %d" % n)
PYEOF


echo ""; echo "══ 3/4  сценарии — добавляем speaker в ключевые карты"
python3 - << 'PYEOF'
import json, os
SDIR = "src/main/resources/static/scenarios"

SPEAKERS = {
  "case001.json": {
    "L1_c2":"shift","L1_c4":"shift","L1_c5":"shift","L1_c7":"shift","L1_c8":"shift",
    "eL2c4":"shift",
    "eL3c1":"miller","eL3c2":"miller","eL3c3":"shift","eL3c4":"miller",
    "eL4c2":"kurator","eL4c3":"shift","eAccuse":"shift"
  },
  "case002.json": {
    "e0":"shift","eL3c1":"hayes","eL3c2":"hayes","eL3c3":"romero",
    "eL4c2":"kurator","eAccuse":"shift"
  },
  "case003.json": {
    "e0":"shift","eL2c3":"jiang",
    "eL3c1":"conroy","eL3c2":"conroy",
    "eL4c1":"kurator","eAccuse":"shift"
  },
  "case004.json": {
    "e0":"shift","eL2c2":"purcell",
    "eL3c2":"shift","eL4c1":"danny","eAccuse":"shift"
  },
  "case005.json": {
    "e0":"shift","eL2c4":"shift",
    "eL3c4":"kurator","eL4c2":"shift",
    "eShift3":"shift","eAccuse":"arundel"
  }
}

total = 0
for fn, mapping in SPEAKERS.items():
    fp = os.path.join(SDIR, fn)
    if not os.path.exists(fp): print(f"  · {fn} нет"); continue
    with open(fp, encoding="utf-8") as f: d = json.load(f)
    c = 0
    for eid, spk in mapping.items():
        ev = d.get("events",{}).get(eid)
        if ev and ev.get("speaker") != spk:
            ev["speaker"] = spk; c += 1
    if c:
        with open(fp, "w", encoding="utf-8") as f:
            json.dump(d, f, ensure_ascii=False, indent=2)
    print(f"  + {fn}: speaker проставлен в {c} событиях")
    total += c
print(f"✓ всего speaker-меток: {total}")
PYEOF


echo ""; echo "══ 4/4  card-design.css — спрайты + фон сцены ══════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f: txt = f.read()
if "/* R24 */" in txt:
    print("  · уже применено")
else:
    css = r"""
/* ════ R24 — выезжающие персонажи + фон ════ */

/* фон сцены (меняется по делам) */
#stage{
  background-size:cover !important;
  background-position:center top !important;
  transition:background-image .6s ease;
}
/* затемнение центра под карточку */
#stage::after{
  content:'';position:absolute;inset:0;pointer-events:none;z-index:0;
  background:radial-gradient(70% 55% at 50% 55%,rgba(8,10,16,.45) 0%,rgba(8,10,16,.0) 100%);
}

/* спрайт персонажа */
.char-sprite{
  position:fixed;
  bottom:calc(var(--navh,60px) + var(--safeb,0px));
  z-index:24;
  height:min(50vh,320px); width:auto; max-width:48vw;
  pointer-events:none;
  object-fit:contain; object-position:bottom;
  opacity:0;
  filter:drop-shadow(0 8px 28px rgba(0,0,0,.75));
  transition:transform .38s cubic-bezier(.25,1.2,.4,1), opacity .28s ease;
}
.char-sprite.left{
  left:0; transform:translate3d(-108%,0,0);
  transform-origin:bottom left;
}
.char-sprite.right{
  right:0; transform:translate3d(108%,0,0);
  transform-origin:bottom right;
}
.char-sprite.show{
  opacity:1; transform:translate3d(0,0,0);
}
/* на СДВИГ-картах персонаж чуть прозрачнее (не мешает выбору) */
.cfcard.active.shift ~ .char-sprite{ opacity:.55; }
"""
    txt += "\n/* R24 */\n" + css
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + CSS спрайтов и фона сцены добавлен")
PYEOF


echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R24 готов — персонажи выезжают, фон Музея включён"
echo ""
echo "  Не забудь скопировать арты ПЕРЕД деплоем:"
echo "  cp -r /sdcard/Download/img src/main/resources/static/"
echo ""
echo "  git add -A && git commit -m 'R24: character sprites + scene backgrounds' && git push"
echo "═══════════════════════════════════════════════════════"
