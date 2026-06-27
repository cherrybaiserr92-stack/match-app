#!/usr/bin/env bash
# СДВИГ R87 — сюжетные флаги: выборы сохраняются между уровнями и влияют на финал
set -e
echo "══ штамп → R87 ══"
sed -i "s/SDVIG_BUILD='R86'/SDVIG_BUILD='R87'/" src/main/resources/static/app.js
sed -i 's/>R86</>R87</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  поле story в профиль ══════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if "story:{}" not in txt:
    txt=txt.replace("gender:'m', genderChosen:false, playerName:'',",
                    "gender:'m', genderChosen:false, playerName:'', story:{},")
    n+=1; print("  + story:{} в DEFAULT_PROFILE")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 2/4  сохранение ключевых флагов в profile.story ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''function cApplyOption(o){
  if(o.set) Object.assign(CState.flags,o.set);'''
new='''// сюжетные флаги, влияющие на дальнейшую историю и финал
window.STORY_KEYS=['danny','vivien','cap_fate','stance','pact','choice','curator','arundel','aesthetic','shift'];
function _saveStoryFlags(set){
  try{
    if(!App.profile.story) App.profile.story={};
    for(var k in set){
      if(window.STORY_KEYS.indexOf(k)>=0){ App.profile.story[k]=set[k]; }
    }
    saveProfile();
  }catch(_){}
}
window.storyFlag=function(k){ try{ return App.profile.story?App.profile.story[k]:undefined; }catch(_){ return undefined; } };
function cApplyOption(o){
  if(o.set){ Object.assign(CState.flags,o.set); _saveStoryFlags(o.set); }'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + сохранение story-флагов + storyFlag()")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 3/4  финал учитывает накопленные выборы ════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# в computeEnding добавляем сюжетный итог для последнего уровня (эпилог 5-4)
old='''  base.rap=rap; base.det=det;
  if(base.kind==='win'){
    if(rap>=60 && det>=60) base.epilogue='Сдвиг хлопнул тебя по плечу. «Напарник». Впервые это слово прозвучало всерьёз.';
    else if(det>=60 && rap<40) base.epilogue='Ты раскрыл дело блестяще. Но Сдвиг смотрел на тебя холодно — машина, а не человек. «Берегись, рекрут. Лёд трескается изнутри».';
    else if(rap>=60 && det<40) base.epilogue='«Голова у тебя ещё сырая, но сердце на месте, — буркнул Сдвиг. — С этим можно работать».';
  }
  return base;'''
new='''  base.rap=rap; base.det=det;
  if(base.kind==='win'){
    if(rap>=60 && det>=60) base.epilogue='Сдвиг хлопнул тебя по плечу. «Напарник». Впервые это слово прозвучало всерьёз.';
    else if(det>=60 && rap<40) base.epilogue='Ты раскрыл дело блестяще. Но Сдвиг смотрел на тебя холодно — машина, а не человек. «Берегись. Лёд трескается изнутри».';
    else if(rap>=60 && det<40) base.epilogue='«Голова у тебя ещё сырая, но сердце на месте, — буркнул Сдвиг. — С этим можно работать».';
  }
  // ── СЮЖЕТНЫЙ ИТОГ: на последнем уровне собираем последствия выборов всей игры ──
  try{
    var isFinale=(window.CAMPAIGN && _caseIdx===CAMPAIGN.cases.length-1);
    if(isFinale){
      var s=App.profile.story||{};
      var threads=[];
      if(s.danny==='ally') threads.push('Дэнни, которого ты однажды отпустил, выжил и держит твою сторону на улицах города.');
      else if(s.danny==='jail') threads.push('Дэнни, которого ты сдал в участок, давно сгинул в системе — улицы не прощают.');
      if(s.choice==='rescue') threads.push('Люди, которых ты спас на причале, живы — пусть и ценой упущенного следа.');
      else if(s.choice==='track') threads.push('Те, кого ты не спас на причале ради нити, остались на твоей совести навсегда.');
      if(s.pact==='trust'||s.vivien==='vendetta') threads.push('Вивьен Кросс сдержала слово — её месть и твоё дело сошлись в одной точке.');
      else if(s.pact==='wary') threads.push('Вивьен ушла своей дорогой, и ты так и не узнал, кем она была на самом деле.');
      if(s.cap_fate==='informant') threads.push('Капитан, ставший твоими глазами в порту, ещё пригодится.');
      if(s.curator==='law') threads.push('Куратор предстанет перед судом — ты не стал палачом, и Сдвиг бы это одобрил.');
      else if(s.curator==='fire') threads.push('Куратор сгорел в своём доме — справедливость это или твоя тьма, рассудит время.');
      if(threads.length){ base.threads=threads; }
    }
  }catch(_){}
  return base;'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + сюжетный итог выборов на финале")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF


echo ""; echo "══ 4/4  показ сюжетного итога в концовке ══════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# в showEnding добавляем вывод threads (последствия выборов)
# найдём где выводится epilogue или текст концовки
if 'r.threads' not in txt:
    # вставляем после установки текста концовки в showEnding
    anchor='haptic(r.kind==="fail"?"shift":"burn"); endEl.classList.add("show");'
    inject='''haptic(r.kind==="fail"?"shift":"burn");
  // сюжетный итог выборов (на финале)
  try{
    if(r.threads && r.threads.length){
      var tEl=document.getElementById("ending-threads");
      if(!tEl){
        tEl=document.createElement("div");
        tEl.id="ending-threads";
        tEl.style.cssText="margin-top:16px;padding:14px 16px;background:rgba(200,134,10,.08);border-left:3px solid #c8860a;border-radius:8px;text-align:left;font-size:13px;line-height:1.7;color:#c8b89a;";
        var ec=document.querySelector("#ending .ending-card,#ending .e-body,#ending");
        if(ec) ec.appendChild(tEl);
      }
      tEl.innerHTML='<div style="color:#ffcf6b;font-weight:700;margin-bottom:8px;font-size:12px;letter-spacing:.05em">ЧТО ОСТАЛОСЬ ПОСЛЕ ТЕБЯ</div>'+r.threads.map(function(t){return '• '+t;}).join('<br>');
    }
  }catch(_){}
  endEl.classList.add("show");'''
    txt=txt.replace(anchor,inject,1); n+=1; print("  + вывод сюжетного итога в концовке")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R87 — сюжетные флаги (выборы влияют на финал)"
echo "   git add -A && git commit -m 'R87: persistent story flags affecting finale' && git push"
echo "═══════════════════════════════════════════════════════"
