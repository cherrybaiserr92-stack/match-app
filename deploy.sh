#!/usr/bin/env bash
# СДВИГ R37 — КРИТФИКС: диалог завис, тап не продвигает (мёртвые scrim в DOM)
set -e
echo ""; echo "══ dialogue.js — чистим старые scrim перед новым диалогом"
python3 - << 'PYEOF'
path="src/main/resources/static/games/dialogue.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# buildUI: удаляем ВСЕ старые .dlg-scrim и .dlg-box из DOM перед созданием новых
old=("  function buildUI(){\n"
     "    const host=document.getElementById('main-screen')||document.body;\n"
     "    _scrim=null; _box=null;\n"
     "    if(!_scrim){ _scrim=document.createElement('div'); _scrim.className='dlg-scrim'; host.appendChild(_scrim); }")
new=("  function buildUI(){\n"
     "    const host=document.getElementById('main-screen')||document.body;\n"
     "    // КРИТИЧНО: убираем все старые диалоговые элементы из DOM (иначе блокируют тапы)\n"
     "    try{ document.querySelectorAll('.dlg-scrim,.dlg-box').forEach(function(el){ if(el.parentNode)el.parentNode.removeChild(el); }); }catch(_){}\n"
     "    _scrim=null; _box=null;\n"
     "    if(!_scrim){ _scrim=document.createElement('div'); _scrim.className='dlg-scrim'; host.appendChild(_scrim); }")
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + старые scrim/box удаляются перед новым диалогом")

# play: если уже активен диалог — сначала жёстко закрыть предыдущий
old_play=("    play(lines, onDone){\n"
          "      if(!lines||!lines.length){ onDone&&onDone(); return; }\n"
          "      _lines=lines; _i=0; _onDone=onDone||null; _active=true;")
new_play=("    play(lines, onDone){\n"
          "      if(!lines||!lines.length){ onDone&&onDone(); return; }\n"
          "      // если предыдущий диалог не закрылся — закрываем принудительно\n"
          "      if(_active){ try{ document.body.classList.remove('dlg-on'); }catch(_){} }\n"
          "      _lines=lines; _i=0; _onDone=onDone||null; _active=true;")
if old_play in txt:
    txt=txt.replace(old_play,new_play,1); n+=1; print("  + повторный play закрывает предыдущий")

# страховка: при finish снять dlg-on с body всегда (вкладка Карта показывала окно)
old_exit=("  function exitMode(){\n"
          "    document.body.classList.remove('dlg-on');")
new_exit=("  function exitMode(){\n"
          "    document.body.classList.remove('dlg-on');\n"
          "    try{ document.querySelectorAll('.dlg-scrim,.dlg-box').forEach(function(el){ if(el.parentNode)el.parentNode.removeChild(el); }); }catch(_){}")
if old_exit in txt:
    txt=txt.replace(old_exit,new_exit,1); n+=1; print("  + exitMode чистит DOM (окно не висит на др. вкладках)")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ dialogue.js: %d"%n)
PYEOF


echo ""; echo "══ app.js — смена вкладки закрывает диалог ═════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="    const tab=b.dataset.tab; if(!tab || tab===App.tab) return;\n    try{ Sound.nav(); }catch(_){}"
new="    const tab=b.dataset.tab; if(!tab || tab===App.tab) return;\n    try{ if(window.Dialogue && Dialogue.isActive()) Dialogue.skip(); }catch(_){}\n    try{ Sound.nav(); }catch(_){}"
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + смена вкладки закрывает диалог")
else:
    print("  · якорь вкладок не найден")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R37 — диалог больше не зависает, тап продвигает"
echo "   git add -A && git commit -m 'R37: fix dialogue freeze - clean stale scrim from DOM' && git push"
echo "═══════════════════════════════════════════════════════"
