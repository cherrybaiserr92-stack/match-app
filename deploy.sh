#!/usr/bin/env bash
# СДВИГ R111 — фикс: карта после мини-игры (очистка старой stage + гарантия показа)
set -e
echo "══ штамп → R111 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R111'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R111</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/2  enterDecisionMode: очистка старой карты + видимость ═"
python3 - << 'PYEOF'
path="games/feed.js"; txt=open(path,encoding="utf-8").read()
n=0
old='''  function enterDecisionMode(){
    const ev=CState.ev?CASE.events[CState.ev]:null; if(!ev) return;
    if(ev.linear){ advanceLinear(ev); return; }
    _decision=true;
    const opts=ev.shift?{left:ev.a,right:ev.b}:{left:ev.left,right:ev.right};
    const stage=document.getElementById('stage');
    const dec=document.createElement('div'); dec.className='decision-stage'; dec.id='dec-stage';'''
new='''  function enterDecisionMode(){
    const ev=CState.ev?CASE.events[CState.ev]:null; if(!ev) return;
    if(ev.linear){ advanceLinear(ev); return; }
    _decision=true;
    const opts=ev.shift?{left:ev.a,right:ev.b}:{left:ev.left,right:ev.right};
    const stage=document.getElementById('stage');
    if(!stage){ console.error('enterDecision: нет stage'); return; }
    // убрать старую карту решения если осталась (чинит пустой экран после мини-игры)
    var _oldDec=document.getElementById('dec-stage'); if(_oldDec)_oldDec.remove();
    const dec=document.createElement('div'); dec.className='decision-stage'; dec.id='dec-stage';'''
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + очистка старой decision-stage + проверка stage")
open(path,"w",encoding="utf-8").write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 2/2  _goDecision: гарантия показа карты (фолбэк) ═"
python3 - << 'PYEOF'
path="app.js"; txt=open(path,encoding="utf-8").read()
n=0
# после Feed.enterDecision — проверка что карта появилась, иначе повтор
old='''  var _goDecision=function(){
    // показываем реакцию персонажей на находку (если есть), потом решение
    if(window._pendingReact && window.Feed && Feed.pushReaction){
      var rc=window._pendingReact; window._pendingReact=null;
      Feed.pushReaction(rc, function(){
        if(window.Feed){ try{ Feed.enterDecision(); }catch(_){} } else { try{ startDecisionMode(); }catch(_){} }
      });
      return;
    }
    if(window.Feed){ try{ Feed.enterDecision(); }catch(_){} }
    else { try{ startDecisionMode(); }catch(_){} }
  };'''
new='''  var _showDecisionCard=function(){
    if(window.Feed){
      try{ Feed.enterDecision(); }catch(e){ console.error('enterDecision fail',e); }
      // гарантия: если карта не появилась за 400мс — повторить
      setTimeout(function(){
        if(!document.getElementById('dec-stage')){
          console.warn('карта не появилась — повтор');
          try{ Feed.enterDecision(); }catch(_){}
        }
      },400);
    } else { try{ startDecisionMode(); }catch(_){} }
  };
  var _goDecision=function(){
    // показываем реакцию персонажей на находку (если есть), потом решение
    if(window._pendingReact && window.Feed && Feed.pushReaction){
      var rc=window._pendingReact; window._pendingReact=null;
      Feed.pushReaction(rc, function(){ _showDecisionCard(); });
      return;
    }
    _showDecisionCard();
  };'''
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + гарантия показа карты + фолбэк-повтор")
open(path,"w",encoding="utf-8").write(txt)
print("✓ %d"%n)
PYEOF

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"
node --check src/main/resources/static/app.js && echo "✓ app.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R111 — фикс карты после мини-игры (очистка + гарантия показа)"
echo "   git add -A && git commit -m 'R111: fix card not showing after minigame' && git push"
echo "═══════════════════════════════════════════════════════"
