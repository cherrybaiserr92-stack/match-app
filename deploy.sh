#!/usr/bin/env bash
# СДВИГ R39 — фикс: наложение реплик, пустые аватары, кроп лица
set -e

echo ""; echo "══ 1/3  app.js — CHARS в window (для ленты) ════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# делаем CHARS глобальным, чтобы feed.js видел
if "window.CHARS=CHARS" not in txt:
    # после объявления CHARS добавляем экспорт
    import re
    # находим конец объявления CHARS={...};
    idx=txt.find("const CHARS={")
    if idx>=0:
        # ищем закрывающую }; этого объекта
        end=txt.find("};", idx)
        if end>=0:
            insert_at=end+2
            txt=txt[:insert_at]+"\nwindow.CHARS=CHARS; window.CHAR_VER=CHAR_VER;"+txt[insert_at:]
            n+=1; print("  + CHARS + CHAR_VER экспортированы в window")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/3  feed.js — очистка ленты + кроп аватара ═════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# pushEvent: ОЧИЩАЕМ ленту перед новым событием (фикс наложения)
old=("  function pushEvent(evId, instant){\n"
     "    const ev=CASE.events[evId]; if(!ev) return;\n"
     "    CState.ev=evId;\n"
     "    try{ if(window.updateCaseBg) updateCaseBg(); }catch(_){}")
new=("  function pushEvent(evId, instant){\n"
     "    const ev=CASE.events[evId]; if(!ev) return;\n"
     "    CState.ev=evId;\n"
     "    // ФИКС наложения: чистим ленту перед новым событием\n"
     "    if(_wrap) _wrap.innerHTML='';\n"
     "    _wrap.onclick=null;\n"
     "    try{ if(window.updateCaseBg) updateCaseBg(); }catch(_){}")
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + лента чистится перед новым событием (нет наложения)")

# аватар: кроп лица (верх спрайта, через background-position)
# уже background-position:center top — но размер фигуры 800×1200, лицо вверху ~20%
# меняем на показ только головы
old_av=".m2-av{width:42px;height:42px;border-radius:12px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;\n      background-size:cover;background-position:center top;transition:all .3s;}"
new_av=".m2-av{width:44px;height:44px;border-radius:12px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;\n      background-size:280%;background-position:center -2px;transition:all .3s;background-repeat:no-repeat;}"
if old_av in txt:
    txt=txt.replace(old_av,new_av,1); n+=1; print("  + аватар кропается на лицо (увеличен, по центру верха)")

# avatar(): фолбэк если CHARS недоступен — пробуем оба источника
old_fn="  function avatar(id){ return id&&window.CHARS&&CHARS[id]?CHARS[id].src+'?v='+CHARV:''; }"
new_fn=("  function avatar(id){\n"
        "    var C=window.CHARS||(typeof CHARS!=='undefined'?CHARS:null);\n"
        "    if(id&&C&&C[id]) return C[id].src+'?v='+CHARV;\n"
        "    return '';\n"
        "  }")
if old_fn in txt:
    txt=txt.replace(old_fn,new_fn,1); n+=1; print("  + avatar() с фолбэком на CHARS")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/3  feed.js — спрайт не перекрывает интерфейс ══"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# спрайт сбоку при реплике в ленте — он не нужен (есть аватар). Отключаем showChar в ленте.
old="      // спрайт говорящего сбоку\n      try{ if(window.showChar && spk!=='narrator') showChar(spk); }catch(_){}"
new="      // в ленте спрайт сбоку НЕ показываем — есть аватар (не перекрывает интерфейс)"
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + спрайт сбоку убран (аватар достаточно, не перекрывает UI)")
# и прячем любой висящий спрайт при старте ленты
old2="    stage.innerHTML='<div class=\"feed2\" id=\"feed2\"></div>';"
new2="    stage.innerHTML='<div class=\"feed2\" id=\"feed2\"></div>';\n    try{ if(window.hideChar) hideChar(); }catch(_){}"
if old2 in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + прячем спрайт при построении ленты")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R39 — наложение убрано, аватары на лицо, чистый UI"
echo "   git add -A && git commit -m 'R39: fix message overlap, avatar face-crop, clean UI' && git push"
echo "═══════════════════════════════════════════════════════"
