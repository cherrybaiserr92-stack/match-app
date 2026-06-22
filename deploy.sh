#!/usr/bin/env bash
# СДВИГ R57 — полный редизайн вкладки Агент (по принципам топ-игр) + рабочие кнопки
set -e
echo "══ штамп → R57 ══"
sed -i "s/SDVIG_BUILD='R56'/SDVIG_BUILD='R57'/" src/main/resources/static/app.js
sed -i 's/>R56</>R57</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  новый HTML вкладки Агент ════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Находим весь старый tab-profile и заменяем
import re
start=txt.find('<div class="tab-pane" id="tab-profile">')
end=txt.find('<div class="tab-pane" id="tab-shop">')
if start>=0 and end>start:
    old=txt[start:end]
    new='''<div class="tab-pane" id="tab-profile">
      <!-- Герой-карточка -->
      <div class="ag-hero">
        <div class="ag-hero-bg"></div>
        <div class="ag-portrait" id="ag-portrait"><img id="ag-portrait-img" src="/img/chars/char-recruit.png" alt=""></div>
        <div class="ag-hero-info">
          <div class="ag-name" id="ag-name">Детектив</div>
          <div class="ag-rank" id="ag-rank">Новичок · Дело 1</div>
          <div class="ag-lvlbar"><div class="ag-lvlfill" id="ag-lvlfill"></div><span class="ag-lvltext" id="ag-lvltext">УР 1</span></div>
        </div>
      </div>

      <!-- Статистика карточками -->
      <div class="ag-stats">
        <div class="ag-stat"><div class="ag-stat-ico">🔍</div><div class="ag-stat-val" id="ag-skill">30</div><div class="ag-stat-lbl">Детектив</div></div>
        <div class="ag-stat"><div class="ag-stat-ico">🎩</div><div class="ag-stat-val" id="ag-rap">50</div><div class="ag-stat-lbl">Сдвиг</div></div>
        <div class="ag-stat"><div class="ag-stat-ico">📁</div><div class="ag-stat-val" id="ag-cases">0</div><div class="ag-stat-lbl">Дел</div></div>
      </div>

      <!-- Выбор персонажа -->
      <div class="ag-section-title">Персонаж</div>
      <div class="ag-chars">
        <button class="ag-char" id="agc-m" onclick="window.setRecruitGender&&window.setRecruitGender('m')">
          <div class="ag-char-pic"><img src="/img/chars/char-recruit.png" alt="М"></div>
          <div class="ag-char-name">Мужчина</div>
          <div class="ag-char-check">✓</div>
        </button>
        <button class="ag-char" id="agc-f" onclick="window.setRecruitGender&&window.setRecruitGender('f')">
          <div class="ag-char-pic"><img src="/img/chars/char-recruit-f.png" alt="Ж"></div>
          <div class="ag-char-name">Женщина</div>
          <div class="ag-char-check">✓</div>
        </button>
      </div>

      <!-- Действия -->
      <div class="ag-section-title">Игра</div>
      <button class="ag-action ag-danger" onclick="window.resetGameProgress&&window.resetGameProgress()">
        <span class="ag-action-ico">↺</span>
        <span class="ag-action-txt"><b>Начать сначала</b><small>Сбросить прогресс и улики</small></span>
      </button>

      </div>

    '''
    txt=txt.replace(old,new,1); n+=1; print("  + новый HTML Агента (герой, статы, персонаж, действия)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/3  CSS нового Агента ═══════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".ag-hero{" not in txt:
    css='''
/* ════ R57 — РЕДИЗАЙН АГЕНТА ════ */
#tab-profile{padding:14px 14px 90px;}
.ag-hero{position:relative;border-radius:20px;overflow:hidden;padding:20px 18px;margin-bottom:14px;
  display:flex;align-items:center;gap:16px;background:linear-gradient(135deg,#1a2433,#0d1420);
  border:1px solid rgba(200,134,10,.25);}
.ag-hero-bg{position:absolute;inset:0;background:radial-gradient(circle at 80% 20%,rgba(200,134,10,.15),transparent 60%);}
.ag-portrait{position:relative;width:84px;height:84px;border-radius:50%;overflow:hidden;flex-shrink:0;
  border:3px solid #c8860a;box-shadow:0 0 20px rgba(200,134,10,.4);background:#0d1119;}
.ag-portrait img{position:absolute;width:135%;left:-17%;top:8%;}
.ag-hero-info{position:relative;flex:1;min-width:0;}
.ag-name{font-family:Unbounded,sans-serif;font-weight:900;font-size:22px;color:#fff;line-height:1.1;margin-bottom:3px;}
.ag-rank{font-size:12px;color:#c8a05a;margin-bottom:10px;}
.ag-lvlbar{position:relative;height:18px;border-radius:9px;background:rgba(0,0,0,.4);overflow:hidden;}
.ag-lvlfill{height:100%;border-radius:9px;background:linear-gradient(90deg,#c8860a,#ffcf6b);width:30%;transition:width .6s;}
.ag-lvltext{position:absolute;inset:0;display:flex;align-items:center;justify-content:center;
  font-family:Unbounded,sans-serif;font-weight:800;font-size:10px;color:#fff;text-shadow:0 1px 2px rgba(0,0,0,.6);}

.ag-stats{display:flex;gap:10px;margin-bottom:20px;}
.ag-stat{flex:1;background:rgba(16,20,28,.8);border:1px solid rgba(255,255,255,.08);border-radius:16px;
  padding:14px 8px;text-align:center;}
.ag-stat-ico{font-size:20px;margin-bottom:6px;}
.ag-stat-val{font-family:Unbounded,sans-serif;font-weight:900;font-size:22px;color:#ffcf6b;line-height:1;}
.ag-stat-lbl{font-size:10px;color:#7a8494;margin-top:4px;text-transform:uppercase;letter-spacing:.04em;}

.ag-section-title{font-family:Unbounded,sans-serif;font-weight:700;font-size:13px;color:#c8a05a;
  text-transform:uppercase;letter-spacing:.05em;margin:0 0 10px 4px;}

.ag-chars{display:flex;gap:12px;margin-bottom:22px;}
.ag-char{flex:1;position:relative;background:rgba(16,20,28,.8);border:2px solid rgba(255,255,255,.1);
  border-radius:18px;padding:12px 10px 14px;cursor:pointer;transition:all .2s;overflow:hidden;}
.ag-char:active{transform:scale(.97);}
.ag-char.active{border-color:#ffcf6b;box-shadow:0 0 20px rgba(200,134,10,.35);background:rgba(200,134,10,.08);}
.ag-char-pic{width:100%;aspect-ratio:1/1;border-radius:13px;overflow:hidden;margin-bottom:9px;
  background:linear-gradient(180deg,#1a2230,#0d1119);position:relative;}
.ag-char-pic img{position:absolute;width:135%;left:-17%;top:6%;}
.ag-char-name{font-family:Unbounded,sans-serif;font-weight:700;font-size:13px;color:#e8e2d4;text-align:center;}
.ag-char.active .ag-char-name{color:#ffcf6b;}
.ag-char-check{position:absolute;top:10px;right:10px;width:24px;height:24px;border-radius:50%;
  background:#c8860a;color:#241701;display:flex;align-items:center;justify-content:center;
  font-weight:900;font-size:14px;opacity:0;transform:scale(.5);transition:all .2s;}
.ag-char.active .ag-char-check{opacity:1;transform:scale(1);}

.ag-action{width:100%;display:flex;align-items:center;gap:14px;padding:16px;border-radius:16px;
  border:1px solid rgba(255,255,255,.1);background:rgba(16,20,28,.8);cursor:pointer;transition:all .2s;
  text-align:left;margin-bottom:10px;}
.ag-action:active{transform:scale(.98);}
.ag-action-ico{font-size:22px;width:32px;text-align:center;flex-shrink:0;}
.ag-action-txt{display:flex;flex-direction:column;gap:2px;}
.ag-action-txt b{font-family:Unbounded,sans-serif;font-weight:700;font-size:14px;color:#e8e2d4;}
.ag-action-txt small{font-size:11px;color:#7a8494;}
.ag-danger{border-color:rgba(220,120,120,.3);}
.ag-danger .ag-action-ico{color:#ff8f7a;}
.ag-danger:active{background:rgba(176,80,80,.15);}
'''
    txt+=css
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS Агента")
PYEOF


echo ""; echo "══ 3/3  renderProfile + рабочие функции (inline onclick)"
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Заменяем renderProfile целиком под новый HTML
import re
start=txt.find('function renderProfile(){')
if start>=0:
    # находим конец функции (первая '}' на нулевом уровне)
    depth=0; i=txt.find('{',start); end=-1
    for j in range(i,len(txt)):
        if txt[j]=='{':depth+=1
        elif txt[j]=='}':
            depth-=1
            if depth==0: end=j+1; break
    old=txt[start:end]
    new='''function renderProfile(){
  var p=App.profile||{}, u=App.user||{};
  var name=u.firstName||u.name||'Детектив';
  var gid=document.getElementById('ag-name'); if(gid)gid.textContent=name;
  // ранг + дело
  var rank=(typeof detTitle==='function')?detTitle(clamp(p.skill||30,0,100)):'Новичок';
  var caseN=(p.casesSolved||0)+1;
  var ar=document.getElementById('ag-rank'); if(ar)ar.textContent=rank+' · Дело '+caseN;
  // уровень-бар (по детективности)
  var det=clamp(p.skill||30,0,100), rap=clamp(p.rapport||50,0,100);
  var lf=document.getElementById('ag-lvlfill'); if(lf)lf.style.width=det+'%';
  var lt=document.getElementById('ag-lvltext'); if(lt)lt.textContent='УР '+(p.level||1);
  // статы
  var s1=document.getElementById('ag-skill'); if(s1)s1.textContent=det;
  var s2=document.getElementById('ag-rap'); if(s2)s2.textContent=rap;
  var s3=document.getElementById('ag-cases'); if(s3)s3.textContent=p.casesSolved||0;
  // портрет по полу
  var src=(p.gender==='f')?'/img/chars/char-recruit-f.png':'/img/chars/char-recruit.png';
  var pi=document.getElementById('ag-portrait-img'); if(pi)pi.src=src;
  // подсветка выбранного персонажа
  var g=p.gender||'m';
  var cm=document.getElementById('agc-m'), cf=document.getElementById('agc-f');
  if(cm)cm.classList.toggle('active',g==='m');
  if(cf)cf.classList.toggle('active',g==='f');
}
// ── рабочие функции Агента (inline onclick — надёжно) ──
window.setRecruitGender=function(g){
  if(App.profile){ App.profile.gender=g; App.profile.genderChosen=true; saveProfile(); }
  try{ applyRecruitGender(); }catch(_){}
  try{ renderProfile(); }catch(_){}
  try{ if(window.toast) toast('Персонаж выбран', (g==='f'?'Детектив-женщина':'Детектив-мужчина')+'. Обновлено во всей игре.', '🕵️'); }catch(_){}
};
window.resetGameProgress=function(){
  if(!confirm('Начать игру сначала? Прогресс, улики и шкалы сбросятся. Выбранный персонаж сохранится.')) return;
  try{
    var gen=(App.profile&&App.profile.gender)||'m';
    var chosen=(App.profile&&App.profile.genderChosen)||false;
    ['sdvig_case_state','sdvig_progress','sdvig_feed_history','caseState','feedHistory'].forEach(function(k){
      try{ localStorage.removeItem(k); }catch(_){}
    });
    App.profile=normalizeProfile({...DEFAULT_PROFILE, gender:gen, genderChosen:chosen, onboarded:true});
    saveProfile();
    location.reload();
  }catch(e){ console.error('reset',e); alert('Не удалось сбросить: '+e.message); }
};'''
    txt=txt.replace(old,new,1); n+=1; print("  + renderProfile переписан + setRecruitGender/resetGameProgress")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R57 — редизайн Агента + рабочие кнопки"
echo "   git add -A && git commit -m 'R57: agent tab redesign + working buttons' && git push"
echo "═══════════════════════════════════════════════════════"
