#!/usr/bin/env bash
# СДВИГ R68 — скрытая админ-панель для тестирования уровней
set -e
echo "══ штамп → R68 ══"
sed -i "s/SDVIG_BUILD='R67'/SDVIG_BUILD='R68'/" src/main/resources/static/app.js
sed -i 's/>R67</>R68</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  HTML админ-панели ══════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if 'id="admin-panel"' not in txt:
    panel='''
  <!-- СКРЫТАЯ АДМИН-ПАНЕЛЬ (5 тапов по штампу версии) -->
  <div id="admin-panel" class="admin-panel" style="display:none">
    <div class="adm-sheet">
      <div class="adm-head">
        <span>⚙ ОТЛАДКА</span>
        <button class="adm-close" onclick="window.closeAdmin&&closeAdmin()">✕</button>
      </div>

      <div class="adm-sec">Перейти на уровень</div>
      <div class="adm-levels" id="adm-levels"></div>

      <div class="adm-sec">Шкалы</div>
      <div class="adm-scale">
        <label>🎩 Отношения: <b id="adm-rap-val">50</b></label>
        <input type="range" id="adm-rap" min="0" max="100" value="50" oninput="window.admSetRap&&admSetRap(this.value)">
      </div>
      <div class="adm-scale">
        <label>🔍 Детектив: <b id="adm-skill-val">30</b></label>
        <input type="range" id="adm-skill" min="0" max="100" value="30" oninput="window.admSetSkill&&admSetSkill(this.value)">
      </div>

      <div class="adm-sec">Действия</div>
      <div class="adm-actions">
        <button onclick="window.admJump&&admJump(-1)">◄ Пред. уровень</button>
        <button onclick="window.admJump&&admJump(1)">След. уровень ►</button>
        <button onclick="window.admRestartLevel&&admRestartLevel()">↻ Перезапуск уровня</button>
        <button onclick="window.admMaxScales&&admMaxScales()">Шкалы 100/100</button>
        <button onclick="window.admMinScales&&admMinScales()">Шкалы 0/0</button>
        <button class="adm-danger" onclick="window.admWipe&&admWipe()">⌫ Полный сброс</button>
      </div>

      <div class="adm-info" id="adm-info"></div>
    </div>
  </div>
</body>'''
    txt=txt.replace("</body>",panel,1); n+=1; print("  + HTML админ-панели")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/3  CSS админ-панели ═══════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".admin-panel{" not in txt:
    txt+='''
/* ════ АДМИН-ПАНЕЛЬ ════ */
.admin-panel{position:fixed;inset:0;z-index:99999;background:rgba(0,0,0,.7);
  display:flex;align-items:flex-end;justify-content:center;}
.adm-sheet{width:100%;max-width:480px;max-height:85vh;overflow-y:auto;background:#12161e;
  border-top:2px solid #c8860a;border-radius:18px 18px 0 0;padding:16px 18px 30px;}
.adm-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px;
  font-family:Unbounded,sans-serif;font-weight:900;font-size:15px;color:#ffcf6b;letter-spacing:.05em;}
.adm-close{background:rgba(255,255,255,.1);border:none;color:#fff;width:30px;height:30px;
  border-radius:8px;font-size:14px;cursor:pointer;}
.adm-sec{font-size:11px;text-transform:uppercase;letter-spacing:.06em;color:#7a8494;
  margin:16px 0 8px;font-weight:700;}
.adm-levels{display:flex;flex-direction:column;gap:6px;}
.adm-lvl{display:flex;align-items:center;gap:10px;padding:10px 12px;border-radius:10px;
  background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.08);color:#e8e2d4;
  cursor:pointer;text-align:left;font-size:13px;transition:all .15s;}
.adm-lvl:active{transform:scale(.98);}
.adm-lvl.cur{border-color:#ffcf6b;background:rgba(200,134,10,.12);}
.adm-lvl-idx{font-family:Unbounded,sans-serif;font-weight:800;color:#c8860a;min-width:32px;}
.adm-lvl-sub{color:#7a8494;font-size:11px;}
.adm-scale{margin-bottom:12px;}
.adm-scale label{font-size:12px;color:#b8b0a0;display:block;margin-bottom:5px;}
.adm-scale label b{color:#ffcf6b;}
.adm-scale input[type=range]{width:100%;accent-color:#c8860a;}
.adm-actions{display:grid;grid-template-columns:1fr 1fr;gap:8px;}
.adm-actions button{padding:11px;border-radius:9px;background:rgba(255,255,255,.06);
  border:1px solid rgba(255,255,255,.1);color:#e8e2d4;font-size:12px;cursor:pointer;
  font-family:Unbounded,sans-serif;font-weight:600;}
.adm-actions button:active{transform:scale(.97);}
.adm-actions .adm-danger{grid-column:1/3;border-color:rgba(220,120,120,.4);color:#ff9b88;
  background:rgba(176,80,80,.12);}
.adm-info{margin-top:14px;font-size:11px;color:#7a8494;font-family:monospace;
  background:rgba(0,0,0,.3);padding:8px 10px;border-radius:8px;}
'''
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS админ-панели")
PYEOF


echo ""; echo "══ 3/3  логика админ-панели ════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if "window.openAdmin" not in txt:
    code='''
// ════ АДМИН-ПАНЕЛЬ (отладка) ════
(function(){
  var _admTaps=0, _admTimer=null;
  // тайный триггер: 5 быстрых тапов по штампу версии
  document.addEventListener('click', function(e){
    var t=e.target.closest&&e.target.closest('#build-tag,.build-tag,[id^="build"]');
    if(!t) return;
    _admTaps++;
    clearTimeout(_admTimer); _admTimer=setTimeout(function(){_admTaps=0;},800);
    if(_admTaps>=5){ _admTaps=0; window.openAdmin&&window.openAdmin(); }
  });
})();
window.openAdmin=function(){
  var p=document.getElementById('admin-panel'); if(!p) return;
  p.style.display='flex';
  // список уровней
  var box=document.getElementById('adm-levels');
  if(box&&window.CAMPAIGN&&CAMPAIGN.cases){
    box.innerHTML=CAMPAIGN.cases.map(function(c,i){
      var cur=(i===_caseIdx)?' cur':'';
      var sub=c.subtitle||c.title||'';
      return '<button class="adm-lvl'+cur+'" onclick="window.admGoto&&admGoto('+i+')">'+
        '<span class="adm-lvl-idx">'+(i+1)+'</span>'+
        '<span>'+(c.id)+(sub?'<br><span class="adm-lvl-sub">'+sub+'</span>':'')+'</span></button>';
    }).join('');
  }
  // текущие шкалы в ползунки
  var p2=App.profile||{};
  var r=document.getElementById('adm-rap'), s=document.getElementById('adm-skill');
  if(r){ r.value=p2.rapport||50; document.getElementById('adm-rap-val').textContent=p2.rapport||50; }
  if(s){ s.value=p2.skill||30; document.getElementById('adm-skill-val').textContent=p2.skill||30; }
  _admUpdateInfo();
};
window.closeAdmin=function(){ var p=document.getElementById('admin-panel'); if(p)p.style.display='none'; };
function _admUpdateInfo(){
  var el=document.getElementById('adm-info'); if(!el) return;
  var p=App.profile||{};
  el.textContent='уровень: '+(_caseIdx+1)+'/'+((window.CAMPAIGN&&CAMPAIGN.cases.length)||'?')+
    ' | id: '+((window.CAMPAIGN&&CAMPAIGN.cases[_caseIdx]&&CAMPAIGN.cases[_caseIdx].id)||'?')+
    ' | 🎩'+(p.rapport||0)+' 🔍'+(p.skill||0)+' | build '+(window.SDVIG_BUILD||'?');
}
window.admGoto=function(i){
  try{
    _caseIdx=i;
    try{ localStorage.setItem('sdvig_case', CAMPAIGN.cases[i].id); }catch(_){}
    loadCaseByIndex(i);
    if(window.Feed){ try{initCarousel_data();}catch(_){}; Feed.reset(); Feed.init(); }
    closeAdmin();
    if(window.toast) toast('Уровень '+(i+1),CAMPAIGN.cases[i].id,'⚙');
  }catch(e){ alert('Ошибка перехода: '+e.message); }
};
window.admJump=function(d){
  var ni=Math.max(0,Math.min((CAMPAIGN.cases.length-1),_caseIdx+d));
  admGoto(ni);
};
window.admRestartLevel=function(){ admGoto(_caseIdx); };
window.admSetRap=function(v){ if(App.profile){App.profile.rapport=+v;saveProfile();} var e=document.getElementById('adm-rap-val');if(e)e.textContent=v; try{updateScaleBars();}catch(_){}; _admUpdateInfo(); };
window.admSetSkill=function(v){ if(App.profile){App.profile.skill=+v;saveProfile();} var e=document.getElementById('adm-skill-val');if(e)e.textContent=v; try{updateScaleBars();}catch(_){}; _admUpdateInfo(); };
window.admMaxScales=function(){ admSetRap(100); admSetSkill(100); var r=document.getElementById('adm-rap'),s=document.getElementById('adm-skill'); if(r)r.value=100; if(s)s.value=100; };
window.admMinScales=function(){ admSetRap(0); admSetSkill(0); var r=document.getElementById('adm-rap'),s=document.getElementById('adm-skill'); if(r)r.value=0; if(s)s.value=0; };
window.admWipe=function(){
  if(!confirm('Полный сброс прогресса и профиля?')) return;
  try{ Object.keys(localStorage).filter(function(k){return k.indexOf('sdvig')===0;}).forEach(function(k){localStorage.removeItem(k);}); }catch(_){}
  location.reload();
};
'''
    # вставляем перед последним закрытием (после initEvPanel или в конец app)
    txt=txt.replace("function initEvPanel(){", code+"\nfunction initEvPanel(){",1)
    n+=1; print("  + логика админ-панели (переход, шкалы, сброс)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R68 — админ-панель (5 тапов по штампу версии R68 внизу)"
echo "   git add -A && git commit -m 'R68: hidden admin debug panel for level testing' && git push"
echo "═══════════════════════════════════════════════════════"
