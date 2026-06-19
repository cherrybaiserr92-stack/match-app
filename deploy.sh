#!/usr/bin/env bash
# СДВИГ R33 — фиксы диалога: спрайт над scrim, текст карточки динамический, тап вместо «Далее»
set -e

echo ""; echo "══ 1/3  dialogue.js — спрайт поверх scrim + убрать «тап»"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/dialogue.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# Говорящий спрайт должен быть ПОВЕРХ scrim (z-index выше 22) и НЕ размываться
old_active = ".char-sprite.dlg-active{filter:drop-shadow(0 8px 28px rgba(0,0,0,.75)) drop-shadow(0 0 18px rgba(200,134,10,.3));}"
new_active = ".char-sprite.dlg-active{z-index:25 !important;filter:drop-shadow(0 8px 28px rgba(0,0,0,.75)) drop-shadow(0 0 18px rgba(200,134,10,.35)) !important;}"
if old_active in txt:
    txt = txt.replace(old_active, new_active, 1); n+=1; print("  + говорящий спрайт над scrim (z-index 25)")

# scrim не должен блюрить — убираем backdrop-filter (он мылит спрайт)
old_scrim = ".dlg-scrim{position:fixed;inset:0;z-index:22;background:rgba(6,8,13,.55);\n      backdrop-filter:blur(1.5px);opacity:0;transition:opacity .4s;pointer-events:auto;}"
new_scrim = ".dlg-scrim{position:fixed;inset:0;z-index:22;background:rgba(6,8,13,.62);\n      opacity:0;transition:opacity .4s;pointer-events:auto;}"
if old_scrim in txt:
    txt = txt.replace(old_scrim, new_scrim, 1); n+=1; print("  + scrim без blur (спрайт не мылится)")

# убираем подсказку «тап»
old_hint = ('        \'<div class="dlg-hint" id="dlg-hint"><span class="tri">▸</span> тап</div>\';')
new_hint = ('        \'\';')
if old_hint in txt:
    txt = txt.replace(old_hint, new_hint, 1); n+=1; print("  + надпись «тап» убрана")
# и обращения к _hint делаем безопасными
txt = txt.replace("_hint=_box.querySelector('#dlg-hint');", "_hint=_box.querySelector('#dlg-hint')||{classList:{add(){},remove(){}}};")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ dialogue.js: %d" % n)
PYEOF

echo ""; echo "══ 2/3  feed.js — текст карточки динамический + тап ════"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/feed.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n=0

# cardInner: убираем кнопку «Далее» у линейных карт (продвижение тапом).
# Кнопку «Найти улики» оставляем (нужно явное действие). Текст в обёртке для печати.
old_inner = '''  function cardInner(ev){
    let body='<div class="fc-pad">'+
      '<span class="fc-badge">'+(ev.badge||'')+'</span>'+
      '<div class="fc-title">'+(ev.title||'')+'</div>'+
      '<div class="fc-text">'+fillSafe(ev.text)+'</div>'+
      '';  // прямая речь вынесена в диалоговое окно (R32)
    if(ev.linear){
      body+='<button class="fc-next" data-act="next">Далее →</button>';
    } else {
      // карта-решение: сперва «Найти улики» (мини-игра), потом свайп
      body+='<button class="fc-find" data-act="find">🔍 Найти улики</button>';
    }
    body+='</div>';
    return body;
  }'''
new_inner = '''  function cardInner(ev){
    let body='<div class="fc-pad">'+
      '<span class="fc-badge">'+(ev.badge||'')+'</span>'+
      '<div class="fc-title">'+(ev.title||'')+'</div>'+
      '<div class="fc-text" data-full="'+escAttr(fillSafe(ev.text))+'"></div>';
    if(ev.linear){
      // линейная карта: продвижение ТАПОМ по карте, без кнопки
      body+='<div class="fc-taphint" data-act="next">▸ нажми, чтобы продолжить</div>';
    } else {
      body+='<button class="fc-find" data-act="find">🔍 Найти улики</button>';
    }
    body+='</div>';
    return body;
  }
  function escAttr(s){ return (s||'').replace(/"/g,'&quot;').replace(/</g,'&lt;'); }'''
if old_inner in txt:
    txt = txt.replace(old_inner, new_inner, 1); n+=1; print("  + кнопка «Далее» → тап-подсказка, текст в data-full")

# pushCard: после вставки карты — печатаем текст динамически
old_push = "    bindCard(card, ev, evId);"
new_push = ("    typeCardText(card);\n"
            "    bindCard(card, ev, evId);")
if old_push in txt:
    txt = txt.replace(old_push, new_push, 1); n+=1; print("  + вызов typeCardText")

# функция печати текста карты
if "function typeCardText" not in txt:
    anchor = "  function bindCard(card, ev, evId){"
    fn = ('''  function typeCardText(card){
    var el=card.querySelector('.fc-text'); if(!el) return;
    var full=el.getAttribute('data-full')||''; el._full=full; el._typing=true;
    var i=0; el.innerHTML='<span class="fc-caret">▌</span>';
    clearInterval(el._tt);
    el._tt=setInterval(function(){
      i++;
      if(i>=full.length){ clearInterval(el._tt); el._typing=false; el.textContent=full; return; }
      el.innerHTML=full.slice(0,i).replace(/&/g,'&amp;').replace(/</g,'&lt;')+'<span class="fc-caret">▌</span>';
    }, 16);
  }
  function finishCardText(card){
    var el=card.querySelector('.fc-text'); if(!el||!el._typing) return false;
    clearInterval(el._tt); el._typing=false; el.textContent=el._full||''; return true;
  }
''')
    txt = txt.replace(anchor, fn+anchor, 1); n+=1; print("  + typeCardText (печать текста карты)")

# bindCard: тап по всей карте — дописать текст или продвинуть
old_bind = '''  function bindCard(card, ev, evId){
    const btn=card.querySelector('[data-act]');
    if(!btn) return;
    btn.onclick=()=>{
      if(_busy) return;
      try{Sound.tap&&Sound.tap();}catch(_){}
      const act=btn.getAttribute('data-act');
      if(act==='next'){ advanceLinear(ev); }
      else if(act==='find'){ openMiniGame(ev, card); }
    };
  }'''
new_bind = '''  function bindCard(card, ev, evId){
    const act = ev.linear ? 'next' : 'find';
    // тап по всей карте
    card.onclick=(e)=>{
      if(_busy) return;
      // если идёт диалог — пусть им управляет Dialogue
      if(window.Dialogue && Dialogue.isActive()) return;
      // 1) если текст ещё печатается — дописать
      if(finishCardText(card)){ try{Sound.tap&&Sound.tap();}catch(_){} return; }
      // 2) иначе действие карты
      try{Sound.tap&&Sound.tap();}catch(_){}
      if(act==='next'){ advanceLinear(ev); }
      else if(act==='find'){
        // на карте-решении «Найти улики» — только по кнопке, не по всей карте
        const btn=e.target.closest&&e.target.closest('.fc-find');
        if(btn){ openMiniGame(ev, card); }
      }
    };
  }'''
if old_bind in txt:
    txt = txt.replace(old_bind, new_bind, 1); n+=1; print("  + тап по карте: дописать/продвинуть")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d" % n)
PYEOF

echo ""; echo "══ 3/3  CSS — каретка, тап-подсказка ═══════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/games/feed.js"
with open(path, encoding="utf-8") as f: txt = f.read()
# добавим стили каретки и тап-подсказки в инжектируемый CSS feed
if ".fc-caret" not in txt:
    anchor = ".fcard.past{opacity:.55;}"
    css = (".fcard.past{opacity:.55;}\n"
           "    .fc-caret{display:inline-block;width:7px;color:var(--acc-2,#ffcf6b);animation:fcCaret .7s steps(1) infinite;}\n"
           "    @keyframes fcCaret{0%,50%{opacity:1}50.01%,100%{opacity:0}}\n"
           "    .fc-taphint{margin-top:14px;text-align:center;font-size:11px;color:#c8a05a;letter-spacing:.05em;\n"
           "      font-family:Unbounded,sans-serif;opacity:.7;animation:fcTap 1.5s ease-in-out infinite;}\n"
           "    @keyframes fcTap{0%,100%{opacity:.4}50%{opacity:.8}}")
    txt = txt.replace(anchor, css, 1)
    with open(path, "w", encoding="utf-8") as f: f.write(txt)
    print("  + CSS каретки и тап-подсказки")
else:
    print("  · уже есть")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R33 — спрайт над окном, текст печатается, тап вместо кнопки"
echo "   git add -A && git commit -m 'R33: sprite over scrim, typed card text, tap-to-advance' && git push"
echo "═══════════════════════════════════════════════════════"
