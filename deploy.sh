#!/usr/bin/env bash
# СДВИГ R25 — фиксы: фон сцены (движется, без наложения), спрайты выезжают, реплики→спрайт, текст/кнопка
set -e

echo ""; echo "══ 1/3  index.html — слой фона сцены ════════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/index.html"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0
# Добавляем слой #scene-bg внутри #bg-fx (он во весь экран, под каруселью, двигается)
if 'id="scene-bg"' not in txt:
    txt = txt.replace('<div id="bg-fx"></div>',
                      '<div id="bg-fx"></div>\n<div id="scene-bg" class="scene-bg"></div>', 1)
    n+=1; print("  + слой #scene-bg добавлен")
with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d" % n)
PYEOF


echo ""; echo "══ 2/3  app.js — фон на свой слой + спрайты + реплики"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# ── updateCaseBg: вешаем фон на #scene-bg (не на #stage), прячем параллакс ──
old_ucb = (
    'function updateCaseBg(){\n'
    '  try{\n'
    '    const cid=CAMPAIGN&&CAMPAIGN.cases[_caseIdx]?CAMPAIGN.cases[_caseIdx].id:\'\';\n'
    '    const bg=CASE_BGS[cid]||null;\n'
    '    const st=document.getElementById(\'stage\'); if(!st)return;\n'
    '    if(bg){ st.style.backgroundImage="url(\'"+bg+"\')"; st.style.backgroundSize=\'cover\'; st.style.backgroundPosition=\'center top\'; }\n'
    '    else { st.style.backgroundImage=\'\'; }\n'
    '  }catch(_){}\n'
    '}'
)
new_ucb = (
    'function updateCaseBg(){\n'
    '  try{\n'
    '    const cid=CAMPAIGN&&CAMPAIGN.cases[_caseIdx]?CAMPAIGN.cases[_caseIdx].id:\'\';\n'
    '    const bg=CASE_BGS[cid]||null;\n'
    '    const sb=document.getElementById(\'scene-bg\');\n'
    '    const st=document.getElementById(\'stage\'); if(st)st.style.backgroundImage=\'\';\n'
    '    if(sb){\n'
    '      if(bg){ sb.style.backgroundImage="url(\'"+bg+"\')"; sb.classList.add(\'on\'); }\n'
    '      else { sb.style.backgroundImage=\'\'; sb.classList.remove(\'on\'); }\n'
    '    }\n'
    '    /* прячем параллакс кабинета, когда показан фон дела */\n'
    '    var bf=document.getElementById(\'bg-fx\');\n'
    '    if(bf) bf.style.opacity = bg ? \'0\' : \'1\';\n'
    '  }catch(_){}\n'
    '}'
)
if old_ucb in txt:
    txt = txt.replace(old_ucb, new_ucb, 1); n+=1; print("  + фон на #scene-bg + скрытие параллакса")

# ── фон сцены двигается параллаксом: хукаем BgFxDrag ──
if "_origBgFxDrag" not in txt:
    anchor = "function updateCaseBg(){"
    hook = (
        "var _origBgFxDrag=null;\n"
        "function installSceneParallax(){\n"
        "  if(_origBgFxDrag) return;\n"
        "  _origBgFxDrag=window.BgFxDrag||function(){};\n"
        "  window.BgFxDrag=function(nx,ny){\n"
        "    try{_origBgFxDrag(nx,ny);}catch(_){}\n"
        "    var sb=document.getElementById('scene-bg');\n"
        "    if(sb&&sb.classList.contains('on')){\n"
        "      sb.style.transform='translate3d('+(-nx*14)+'px,'+(-ny*10)+'px,0) scale(1.08)';\n"
        "    }\n"
        "  };\n"
        "}\n"
    )
    txt = txt.replace(anchor, hook+anchor, 1); n+=1; print("  + фон сцены двигается параллаксом")
    # вызвать install при старте игры
    txt = txt.replace("  if(window.BgFx) BgFx.init();",
                      "  if(window.BgFx) BgFx.init();\n  try{installSceneParallax();}catch(_){}", 1)

# ── showChar: гарантированно в #main-screen, + лог-проверка видимости ──
old_sc = (
    "function showChar(id){\n"
    "  if(!id||!CHARS[id]){hideChar();return;}\n"
    "  const def=CHARS[id];\n"
    "  if(!_charEl){\n"
    "    _charEl=document.createElement('img');\n"
    "    _charEl.className='char-sprite';\n"
    "    (document.getElementById('main-screen')||document.body).appendChild(_charEl);\n"
    "  }\n"
    "  if(_charId!==id){\n"
    "    _charEl.style.transition='none';\n"
    "    _charEl.classList.remove('show');\n"
    "    _charEl.className='char-sprite '+def.side;\n"
    "    _charEl.src=def.src; _charId=id;\n"
    "    /* double rAF гарантирует что CSS transition подхватит */\n"
    "    requestAnimationFrame(function(){requestAnimationFrame(function(){\n"
    "      _charEl.style.transition='';_charEl.classList.add('show');\n"
    "    });});\n"
    "  } else { _charEl.classList.add('show'); }\n"
    "}"
)
new_sc = (
    "function showChar(id){\n"
    "  if(!id||!CHARS[id]){hideChar();return;}\n"
    "  const def=CHARS[id];\n"
    "  var host=document.getElementById('main-screen')||document.body;\n"
    "  if(!_charEl){\n"
    "    _charEl=document.createElement('img');\n"
    "    _charEl.alt=''; _charEl.className='char-sprite';\n"
    "    host.appendChild(_charEl);\n"
    "  }\n"
    "  if(_charEl.parentNode!==host) host.appendChild(_charEl);\n"
    "  if(_charId!==id){\n"
    "    _charEl.classList.remove('show');\n"
    "    _charEl.className='char-sprite '+(def.side||'right');\n"
    "    _charEl.onload=function(){ _charEl.classList.add('show'); };\n"
    "    _charEl.src=def.src; _charId=id;\n"
    "    /* запасной показ, если onload уже отработал из кэша */\n"
    "    requestAnimationFrame(function(){requestAnimationFrame(function(){ _charEl.classList.add('show'); });});\n"
    "  } else { _charEl.classList.add('show'); }\n"
    "}"
)
if old_sc in txt:
    txt = txt.replace(old_sc, new_sc, 1); n+=1; print("  + showChar: надёжный показ (onload + rAF)")

# ── cardHTML: НЕ рендерить dialogue, если есть speaker (реплику скажет спрайт) ──
txt = txt.replace(
    "+(ev.dialogue?'<div class=\"dlg\">'+ev.dialogue.replace(/\\n/g,'<br>')+'</div>':'')",
    "+((ev.dialogue&&!ev.speaker)?'<div class=\"dlg\">'+ev.dialogue.replace(/\\n/g,'<br>')+'</div>':'')"
)
n+=1; print("  + реплики убраны из карточки, если есть спрайт (speaker)")

# ── реплика спрайта показывается отдельным «пузырём» под персонажем ──
old_showchar_call = "  try{ showChar(ev.speaker||null); }catch(_){}"
new_showchar_call = "  try{ showChar(ev.speaker||null); showSpeech(ev.speaker?ev.dialogue:null); }catch(_){}"
if old_showchar_call in txt:
    txt = txt.replace(old_showchar_call, new_showchar_call, 1); n+=1; print("  + showSpeech (пузырь реплики)")

# showSpeech + прячем в hideChar
if "function showSpeech" not in txt:
    anchor = "function hideChar(){"
    sp = (
        "var _speechEl=null;\n"
        "function showSpeech(text){\n"
        "  var host=document.getElementById('main-screen')||document.body;\n"
        "  if(!_speechEl){ _speechEl=document.createElement('div'); _speechEl.className='char-speech'; host.appendChild(_speechEl); }\n"
        "  if(!text){ _speechEl.classList.remove('show'); return; }\n"
        "  _speechEl.innerHTML='<span class=\"cs-quote\">'+text.replace(/^[^:]*:\\s*/,'').replace(/[«»\"]/g,'')+'</span>';\n"
        "  requestAnimationFrame(function(){requestAnimationFrame(function(){ _speechEl.classList.add('show'); });});\n"
        "}\n"
    )
    txt = txt.replace(anchor, sp+anchor, 1); n+=1; print("  + showSpeech определён")
    txt = txt.replace("function hideChar(){\n  if(!_charEl)return; _charEl.classList.remove('show'); _charId=null;\n}",
                      "function hideChar(){\n  if(_charEl)_charEl.classList.remove('show'); _charId=null;\n  if(_speechEl)_speechEl.classList.remove('show');\n}", 1)

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: применено %d" % n)
PYEOF


echo ""; echo "══ 3/3  CSS — фон сцены, пузырь реплики, текст/кнопка"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f: txt = f.read()
if "/* R25 */" in txt:
    print("  · уже применено"); 
else:
    css = r"""
/* ════ R25 — фон сцены (движется), пузырь реплики, фикс лейаута ════ */

/* слой фона дела — во весь экран, под каруселью, двигается параллаксом */
.scene-bg{
  position:fixed; inset:0; z-index:0; pointer-events:none;
  background-size:cover; background-position:center top;
  opacity:0; transition:opacity .6s ease, transform .12s ease-out;
  transform:scale(1.08); will-change:transform;
}
.scene-bg.on{ opacity:1; }
/* затемнение под карточку поверх фона сцены */
.scene-bg.on::after{
  content:''; position:absolute; inset:0;
  background:radial-gradient(72% 56% at 50% 50%,rgba(8,10,16,.5) 0%,rgba(8,10,16,.72) 100%);
}

/* пузырь реплики персонажа (вместо текста в карточке) */
.char-speech{
  position:fixed; left:50%; bottom:calc(var(--navh,60px) + 12px + var(--safeb,0px));
  transform:translate(-50%,16px); z-index:26; pointer-events:none;
  max-width:min(78vw,420px); padding:11px 15px; border-radius:14px;
  background:linear-gradient(160deg,rgba(26,21,15,.97),rgba(12,10,7,.97));
  border:1px solid rgba(200,134,10,.5); border-bottom:3px solid var(--acc,#c8860a);
  box-shadow:0 10px 30px rgba(0,0,0,.6);
  opacity:0; transition:opacity .3s ease, transform .3s cubic-bezier(.25,1.2,.4,1);
}
.char-speech.show{ opacity:1; transform:translate(-50%,0); }
.char-speech .cs-quote{
  font-size:13px; line-height:1.45; color:#e7c98a; font-style:italic; display:block; text-align:center;
}
.char-speech::before{
  content:'«'; color:var(--acc,#c8860a); font-size:18px; font-weight:800; opacity:.6;
  margin-right:2px;
}

/* фикс: текст карточки не наезжает на кнопку «Найти улики» */
.cfcard.active .text.scrollable{ max-height:26vh !important; }
.cfcard.active .pad{ padding-bottom:8px !important; }

/* спрайт поверх фона сцены, но под карточкой */
.char-sprite{ z-index:6 !important; }
.char-speech{ z-index:7 !important; }
"""
    txt += "\n/* R25 */\n" + css
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + R25 CSS")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R25 готов — фон/спрайты/реплики/лейаут исправлены"
echo "   git add -A && git commit -m 'R25: fix scene bg layering+parallax, sprites, speech bubble, card layout' && git push"
echo "═══════════════════════════════════════════════════════"
