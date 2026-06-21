#!/usr/bin/env bash
# СДВИГ R47 — фикс застревания на shift-картах + дедукция не спойлерит улику
set -e
echo "══ штамп → R47 ══"
sed -i "s/SDVIG_BUILD='R46'/SDVIG_BUILD='R47'/" src/main/resources/static/app.js
sed -i 's/>R46</>R47</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  buildMessages — intro для shift + БЕЗ спойлера улики"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Переписываем buildMessages: 
#  - shift-карты используют intro как текст
#  - дедукция/улику НЕ показываем до мини-игры (убираем спойлер)
old=('''  function buildMessages(ev){
    const out=[];
    // 1. нарратив (text) — если есть
    if(ev.text && ev.text.trim()){
      out.push({type:'narr', text:ev.text});
    }
    // 2. прямая речь (dialogue может быть многострочной)
    if(ev.dialogue && window.parseDialogue){
      const lines=parseDialogue(ev);
      lines.forEach(l=>{
        if(!l.speaker || l.speaker==='narrator'){
          out.push({type:'narr', text:l.text}); // безымянная реплика = нарратив
        } else {
          out.push({type:'speech', speaker:l.speaker, text:l.text});
        }
      });
    }
    // 3. дедукция + улика (если у события есть clue)
    if(ev.clue){
      out.push({type:'deduce', clue:ev.clue,
        text:ev.clue.proof.replace(ev.clue.name, '{'+ev.clue.name+'|'+ev.clue.name+'}')});
    }
    return out;
  }''')
new=('''  function buildMessages(ev){
    const out=[];
    // нарратив
    if(ev.text && ev.text.trim()){
      out.push({type:'narr', text:ev.text});
    }
    // прямая речь
    if(ev.dialogue && window.parseDialogue){
      const lines=parseDialogue(ev);
      lines.forEach(l=>{
        if(!l.speaker || l.speaker==='narrator'){
          out.push({type:'narr', text:l.text});
        } else {
          out.push({type:'speech', speaker:l.speaker, text:l.text});
        }
      });
    }
    // shift-карта (выбор версии): показываем intro как реплику-вопрос
    if(ev.shift && ev.intro){
      out.push({type:'narr', text:ev.intro});
    }
    // ВАЖНО: дедукция/улика тут НЕ добавляется — она появится ПОСЛЕ мини-игры
    // (раньше спойлерило улику до находки)
    return out;
  }''')
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + shift использует intro, улика НЕ спойлерится")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 2/3  pushEvent — пустое событие → сразу карта решения"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Если msgs пуст (shift-карта без контента) — сразу показываем продолжение
old=('''    const msgs=buildMessages(ev);
    let mi=0;

    // показываем реплики по одной, тап продвигает
    function next(){
      if(mi<msgs.length){
        addMessage(msgs[mi], ()=>{}); mi++;
        scrollEnd();
        showContinue(ev, evId, next, mi>=msgs.length);''')
new=('''    const msgs=buildMessages(ev);
    let mi=0;

    // если контента нет (shift-карта) — сразу к решению
    if(msgs.length===0){
      showContinue(ev, evId, function(){}, true);
      try{ if(window.saveCaseState) saveCaseState(); }catch(_){}
      return;
    }

    function next(){
      if(mi<msgs.length){
        addMessage(msgs[mi], ()=>{}); mi++;
        scrollEnd();
        showContinue(ev, evId, next, mi>=msgs.length);''')
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + пустое событие → сразу карта решения (не застревает)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/3  showContinue — shift-карта идёт сразу в решение"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# shift-карты (выбор версии) НЕ показывают «Найти улики» — сразу карта решения свайпом
old=('''      } else {
        const btn=document.createElement('button'); btn.className='feed2-find';
        btn.textContent='🔍 Найти улики';
        btn.onclick=()=>{ openMiniGame(ev); };
        _wrap.appendChild(btn);
      }''')
new=('''      } else if(ev.shift){
        // shift-карта: сразу карта-решение (выбор версии свайпом, без мини-игры)
        enterDecisionMode();
      } else {
        const btn=document.createElement('button'); btn.className='feed2-find';
        btn.textContent='🔍 Найти улики';
        btn.onclick=()=>{ openMiniGame(ev); };
        _wrap.appendChild(btn);
      }''')
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + shift-карта → сразу решение (без 'Найти улики')")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R47 — shift-карты не застревают, улика не спойлерится"
echo "   git add -A && git commit -m 'R47: fix shift-card freeze + no clue spoiler before minigame' && git push"
echo "═══════════════════════════════════════════════════════"
