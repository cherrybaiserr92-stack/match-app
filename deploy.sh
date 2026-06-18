#!/usr/bin/env bash
# СДВИГ R23 — дырокол-табель + карта↔дела + rapport-подсказки
set -e
echo ""; echo "══ app.js — три улучшения ═══════════════════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f: txt = f.read()
n = 0

# ══════════════════════════════════════════════════════
# 1. ДЫРОКОЛ-ТАБЕЛЬ: перерисовка showDaily
# ══════════════════════════════════════════════════════
DAILY_REWARDS = [
    {"credits": 30,  "bucks": 0},
    {"credits": 40,  "bucks": 0},
    {"credits": 50,  "bucks": 50},
    {"credits": 60,  "bucks": 0},
    {"credits": 70,  "bucks": 0},
    {"credits": 80,  "bucks": 100},
    {"credits": 120, "bucks": 200},
]

old_daily = r"""function showDaily(streak,reward){
  const bg=$('#daily-modal'); if(!bg) return;
  const today=new Date().toDateString();
  const days=Array.from({length:7},(_,i)=>{
    const done=i<streak; const cur=i===streak-1;
    return `<div class="dday ${done?'done':''} ${cur?'cur':''}">`+
      `<div class="dd-num">${i+1}</div>`+
      `<div class="dd-ico">${done?(cur?'★':'✓'):'○'}</div>`+
      `</div>`;
  }).join('');
  bg.innerHTML=`<div class="daily-card">
    <div class="daily-icon">🎁</div>
    <div class="daily-h">Ежедневный бонус</div>
    <div class="daily-streak">Серия входов: ${streak} ${streak>=7?'🔥':''}</div>
    <div class="daily-week">${days}</div>
    <div class="daily-chips"><span class="dc-chip">+${reward} ◈</span></div>
    <button class="btn btn-bronze" id="daily-ok" style="max-width:220px">Забрать</button>
  </div>`;
  bg.classList.remove('hidden'); Sound.daily();
  bg.querySelector('#daily-ok').onclick=()=>{ Sound.coin(); vibrate(10); bg.classList.add('hidden'); };
}"""

new_daily = r"""function showDaily(streak,reward){
  const bg=$('#daily-modal'); if(!bg) return;
  const DAYS=[
    {credits:30, bucks:0},{credits:40,bucks:0},{credits:50,bucks:50},
    {credits:60,bucks:0},{credits:70,bucks:0},{credits:80,bucks:100},
    {credits:120,bucks:200}
  ];
  const s=Math.max(1,Math.min(streak,7));
  const today=DAYS[s-1];
  function dayHtml(i){
    const done=i<s, cur=i===s-1;
    const d=DAYS[i];
    return '<div class="dday'+(done?' done':'')+(cur?' cur':'')+'">'
      +'<div class="dd-ico">'+(done?(cur?'★':'✓'):'○')+'</div>'
      +'<div class="dd-n">'+(i+1)+'</div>'
      +'<div class="dd-reward">+'+d.credits+'◈'+(d.bucks?'<br><span style="color:#9fe0ff">+'+d.bucks+'💵</span>':'')+'</div>'
      +'</div>';
  }
  const daysHtml=Array.from({length:7},(_,i)=>dayHtml(i)).join('');
  const bigReward='<span class="dc-chip">+'+today.credits+' ◈</span>'
    +(today.bucks?'&nbsp;<span class="dc-chip bucks-chip">+'+today.bucks+' 💵</span>':'');
  bg.innerHTML='<div class="daily-card">'
    +'<div class="daily-punch-label"><span class="dpl-orn">✦</span> ТАБЕЛЬ ДЕЖУРСТВ <span class="dpl-orn">✦</span></div>'
    +'<div class="daily-h">'+( s>=7?'НЕДЕЛЯ ПРОЙДЕНА 🔥':'ДЕНЬ '+ s+'</div>'
    +'<div class="daily-streak">Серия входов: <b>'+ s+'</b> из 7</div>'
    +'<div class="daily-week">'+ daysHtml+'</div>'
    +'<div class="daily-chips">Сегодня: '+ bigReward+'</div>'
    +'<button class="btn btn-bronze" id="daily-ok">Получить</button>'
    +'</div>';
  bg.classList.remove('hidden'); Sound.daily();
  bg.querySelector('#daily-ok').onclick=()=>{
    Sound.coin(); vibrate(10);
    addCredits(today.credits);
    if(today.bucks) addBucks(today.bucks);
    bg.classList.add('hidden');
  };
}"""

if old_daily in txt:
    txt = txt.replace(old_daily, new_daily, 1); n+=1; print("  + дырокол-табель переписан")
else:
    print("  · showDaily не найден или уже обновлён")

# ══════════════════════════════════════════════════════
# 2. КАРТА ↔ ДЕЛА: при победе двигаем mapNode + stars
# ══════════════════════════════════════════════════════
old_win_end = ('  if(r.kind===\"win\"){try{addXP(150);addCredits(100);vibrate([20,40,80]);}catch(_){}}\n'
               '  else if(r.kind===\"partial\"){try{addXP(60);addCredits(40);}catch(_){}}\n'
               '  else{try{addXP(20);addCredits(10);}catch(_){}}')
new_win_end = ('  if(r.kind===\"win\"){\n'
               '    try{addXP(150);addCredits(100);vibrate([20,40,80]);}catch(_){}\n'
               '    try{ advanceMap(); App.profile.casesSolved=(App.profile.casesSolved||0)+1;\n'
               '      const st=r.align>=3?3:r.align>=2?2:1;\n'
               '      if(!App.profile.mapStars)App.profile.mapStars={};\n'
               '      App.profile.mapStars[_caseIdx]=Math.max(st,App.profile.mapStars[_caseIdx]||0);\n'
               '    }catch(_){}\n'
               '  }\n'
               '  else if(r.kind===\"partial\"){try{addXP(60);addCredits(40);}catch(_){}}\n'
               '  else{try{addXP(20);addCredits(10);}catch(_){}}')
if old_win_end in txt:
    txt = txt.replace(old_win_end, new_win_end, 1); n+=1; print("  + карта: победа двигает mapNode + записывает звёзды")

# ══════════════════════════════════════════════════════
# 3. RAPPORT → ПОДСКАЗКИ СДВИГА на замке карты
# ══════════════════════════════════════════════════════
RAPPORT_HINTS = {
    'crime':    'Ищи то, чего быть не должно.',
    'evidence': 'Одна улика всегда важнее остальных.',
    'witness':  'Люди врут, но тело не умеет.',
    'suspect':  'Виновный всегда спокойнее, чем должен быть.',
    'shift':    'Обе версии верны — выбери ту, где меньше случайностей.',
    'final':    'Ты уже знаешь. Просто доверься себе.',
    'revelation':'Детали складываются в одно.',
}

old_lock_overlay = (
    '  lock.innerHTML=\'<button class="card-lock-btn" id="play-gems-ring">\'\n'
    '    +\'<span class="clb-ico">🔍</span><span>Найти улики</span></button>\'\n'
    '    +\'<div class="card-lock-hint">⟵ свайп заблокирован ⟶</div>\';'
)
new_lock_overlay = (
    '  const _rp=(window.App&&App.profile&&App.profile.rapport)||0;\n'
    '  const _rt=(window.App&&App.profile)?rapportTitle():\'Новичок\';\n'
    '  const _ev=App.currentCard||{};\n'
    '  const _hints={\n'
    '    crime:"Ищи то, чего быть не должно.",\n'
    '    evidence:"Одна улика всегда важнее остальных.",\n'
    '    witness:"Люди врут, но тело не умеет.",\n'
    '    suspect:"Виновный всегда спокойнее, чем должен быть.",\n'
    '    shift:"Обе версии верны — выбери ту, где меньше случайностей.",\n'
    '    final:"Ты уже знаешь. Просто доверься себе.",\n'
    '    revelation:"Детали складываются в одно."\n'
    '  };\n'
    '  const _hint=_rp>=6?(_hints[_ev.t]||""):""; \n'
    '  lock.innerHTML=\'<button class="card-lock-btn" id="play-gems-ring">\'\n'
    '    +\'<span class="clb-ico">🔍</span><span>Найти улики</span></button>\'\n'
    '    +(_hint?\'<div class="card-rapport-hint"><span class="crh-name">Сдвиг</span> \'+_hint+\'</div>\':\'\')\n'
    '    +\'<div class="card-lock-hint">⟵ свайп заблокирован ⟶</div>\';'
)
if old_lock_overlay in txt:
    txt = txt.replace(old_lock_overlay, new_lock_overlay, 1); n+=1; print("  + rapport-подсказки Сдвига на замке карты")

with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("✓ app.js: применено %d" % n)
PYEOF


echo ""; echo "══ card-design.css — дырокол + rapport-hint ════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f: txt = f.read()
if "/* R23 */" in txt:
    print("  · уже применено"); exit()

css = """
/* ════ R23 — дырокол-табель + rapport-подсказки ════ */

/* ── дырокол-табель ── */
.daily-punch-label{
  font-family:'Unbounded',sans-serif; font-size:10px; letter-spacing:.22em; text-transform:uppercase;
  color:var(--acc,#c8860a); margin-bottom:6px;
}
.dpl-orn{ opacity:.6; }
.daily-card .daily-h{ font-family:'Unbounded',sans-serif; font-weight:900; font-size:22px; margin:4px 0 2px; }
.daily-card .daily-streak{ font-size:12px; color:var(--ink3); margin-bottom:14px; }
.daily-week{ display:flex; gap:6px; justify-content:center; flex-wrap:nowrap; }
.dday{
  display:flex; flex-direction:column; align-items:center; gap:2px;
  padding:7px 4px; border-radius:10px; min-width:36px;
  background:rgba(255,255,255,.04); border:1px solid rgba(255,255,255,.07);
  transition:transform .2s;
}
.dday.done{ background:rgba(200,134,10,.14); border-color:rgba(200,134,10,.4); }
.dday.cur{
  background:rgba(200,134,10,.26); border-color:var(--acc,#c8860a);
  transform:scale(1.1); box-shadow:0 0 14px rgba(200,134,10,.35);
  animation:dayPulse 1.6s ease-in-out infinite;
}
@keyframes dayPulse{ 0%,100%{box-shadow:0 0 14px rgba(200,134,10,.3)} 50%{box-shadow:0 0 22px rgba(200,134,10,.6)} }
.dd-ico{ font-size:14px; line-height:1; color:var(--acc-2,#ffcf6b); }
.dday:not(.done) .dd-ico{ color:rgba(255,255,255,.22); }
.dd-n{ font-size:9px; color:var(--ink3); font-weight:700; }
.dd-reward{ font-size:8px; color:var(--acc,#c8860a); line-height:1.3; text-align:center; }
.dday:not(.done) .dd-reward{ opacity:.4; }
.daily-chips{ margin:14px 0 10px; display:flex; gap:8px; justify-content:center; align-items:center; }
.dc-chip{ padding:6px 14px; border-radius:10px; font-weight:800; font-size:14px;
  background:rgba(200,134,10,.18); border:1px solid rgba(200,134,10,.4); color:var(--acc-2,#ffcf6b); }
.bucks-chip{ background:rgba(92,208,255,.14); border-color:rgba(92,208,255,.35); color:#9fe0ff; }

/* ── rapport-подсказка Сдвига на замке карты ── */
.card-rapport-hint{
  padding:9px 12px; border-radius:10px; font-size:11.5px; line-height:1.42;
  color:#c8c0b0; background:rgba(255,255,255,.03); border:1px solid rgba(200,134,10,.25);
  border-left:3px solid rgba(200,134,10,.7); margin-bottom:6px; text-align:left;
  font-style:italic;
}
.crh-name{ font-family:'Unbounded',sans-serif; font-size:9.5px; font-weight:700; font-style:normal;
  color:var(--acc,#c8860a); letter-spacing:.06em; display:block; margin-bottom:3px; }
"""
txt += "\n/* R23 */\n" + css
with open(path, "w", encoding="utf-8") as f: f.write(txt)
print("  + дырокол-табель + rapport-hint CSS")
PYEOF


echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R23 готов"
echo "   git add -A && git commit -m 'R23: daily punch card + map progression + rapport hints' && git push"
echo "═══════════════════════════════════════════════════════"
