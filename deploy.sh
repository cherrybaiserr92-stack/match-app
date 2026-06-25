#!/usr/bin/env bash
# СДВИГ R76 — отладчик: список уровней через addEventListener (надёжный переход)
set -e
echo "══ штамп → R76 ══"
sed -i "s/SDVIG_BUILD='R75'/SDVIG_BUILD='R76'/" src/main/resources/static/app.js
sed -i 's/>R75</>R76</' src/main/resources/static/index.html

echo ""; echo "══ список уровней — addEventListener вместо inline ═"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''  var box=document.getElementById('adm-levels');
  if(box&&window.CAMPAIGN&&CAMPAIGN.cases){
    box.innerHTML=CAMPAIGN.cases.map(function(c,i){
      var cur=(i===_caseIdx)?' cur':'';
      var sub=c.subtitle||c.title||'';
      return '<button class="adm-lvl'+cur+'" onclick="window.admGoto&&admGoto('+i+')">'+
        '<span class="adm-lvl-idx">'+(i+1)+'</span>'+
        '<span>'+(c.id)+(sub?'<br><span class="adm-lvl-sub">'+sub+'</span>':'')+'</span></button>';
    }).join('');
  }'''
new='''  var box=document.getElementById('adm-levels');
  if(box&&window.CAMPAIGN&&CAMPAIGN.cases){
    box.innerHTML='';
    CAMPAIGN.cases.forEach(function(c,i){
      var cur=(i===_caseIdx)?' cur':'';
      var sub=c.subtitle||c.title||'';
      var btn=document.createElement('button');
      btn.className='adm-lvl'+cur;
      btn.setAttribute('data-idx',i);
      btn.innerHTML='<span class="adm-lvl-idx">'+(i+1)+'</span>'+
        '<span>'+(c.id)+(sub?'<br><span class="adm-lvl-sub">'+sub+'</span>':'')+'</span>';
      btn.addEventListener('click',function(ev){
        ev.preventDefault(); ev.stopPropagation();
        var idx=parseInt(this.getAttribute('data-idx'),10);
        window.admGoto(idx);
      });
      box.appendChild(btn);
    });
  }'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + список через createElement+addEventListener")
else:
    print("  ✗ старый блок не найден")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R76 — отладчик: надёжный переход по списку уровней"
echo "   git add -A && git commit -m 'R76: admin level list via addEventListener' && git push"
echo "═══════════════════════════════════════════════════════"
