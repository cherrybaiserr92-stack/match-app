#!/usr/bin/env bash
# СДВИГ R94 — кнопка звука из топбара во вкладку Агента + качественный SVG
set -e
echo "══ штамп → R94 ══"
sed -i "s/SDVIG_BUILD='R93'/SDVIG_BUILD='R94'/" src/main/resources/static/app.js
sed -i 's/>R93</>R94</' src/main/resources/static/index.html

echo ""; echo "══ 1/3  убираем кнопку звука из топбара ═══════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='    <button class="snd-btn" id="sound-btn" type="button">🔊</button>\n'
if old in txt:
    txt=txt.replace(old,'')
    n+=1; print("  − кнопка звука убрана из топбара")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/3  переключатель звука в секцию Игра (Агент) ═"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# вставляем переключатель звука перед кнопкой "Начать сначала"
anchor='''      <div class="ag-section-title">Игра</div>
      <button class="ag-action ag-danger"'''
inject='''      <div class="ag-section-title">Игра</div>
      <button class="ag-action" id="ag-sound-toggle" type="button">
        <span class="ag-action-ico" id="ag-sound-ico"></span>
        <span class="ag-action-txt"><b>Звук</b><small id="ag-sound-state">Включён</small></span>
        <span class="ag-toggle" id="ag-sound-switch"><span class="ag-toggle-knob"></span></span>
      </button>
      <button class="ag-action ag-danger"'''
if anchor in txt and 'ag-sound-toggle' not in txt:
    txt=txt.replace(anchor,inject,1)
    n+=1; print("  + переключатель звука в секции Игра")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 3/3  CSS toggle + SVG-иконки + логика ══════════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
if ".ag-toggle{" not in txt:
    txt+='''
/* ── переключатель звука в Агенте ── */
.ag-action{ position:relative; }
.ag-toggle{
  margin-left:auto; flex:0 0 auto; width:48px; height:28px; border-radius:16px;
  background:rgba(255,255,255,.08); border:1px solid rgba(255,255,255,.12);
  position:relative; transition:background .3s ease, border-color .3s ease;
}
.ag-toggle.on{
  background:linear-gradient(135deg, rgba(200,134,10,.5), rgba(255,207,107,.35));
  border-color:rgba(255,207,107,.5);
  box-shadow:0 0 14px rgba(200,134,10,.35), 0 0 0 1px rgba(255,207,107,.2) inset;
}
.ag-toggle-knob{
  position:absolute; top:2px; left:2px; width:22px; height:22px; border-radius:50%;
  background:linear-gradient(135deg,#fff,#d8dae0);
  box-shadow:0 2px 5px rgba(0,0,0,.4);
  transition:transform .3s cubic-bezier(.34,1.56,.64,1);
}
.ag-toggle.on .ag-toggle-knob{ transform:translateX(20px); background:linear-gradient(135deg,#fff,#ffe8b8); }
.ag-action-ico svg{ width:24px; height:24px; }
'''
    n+=1; print("  + CSS переключателя")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ style.css: %d"%n)
PYEOF

python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# SVG иконки звука (динамик с волнами / перечёркнутый)
if "SND_ICON_ON" not in txt:
    icons='''
// качественные SVG иконки звука
var SND_ICON_ON='<svg viewBox="0 0 24 24" fill="none" stroke="#ffcf6b" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10v4a1 1 0 0 0 1 1h3l4 4V5L7 9H4a1 1 0 0 0-1 1z" fill="rgba(255,207,107,.18)"/><path d="M16 9a4 4 0 0 1 0 6"/><path d="M19 6.5a8 8 0 0 1 0 11"/></svg>';
var SND_ICON_OFF='<svg viewBox="0 0 24 24" fill="none" stroke="#7d8699" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M3 10v4a1 1 0 0 0 1 1h3l4 4V5L7 9H4a1 1 0 0 0-1 1z" fill="rgba(125,134,153,.12)"/><path d="M17 9l5 6M22 9l-5 6"/></svg>';
'''
    txt=txt.replace("function bindSoundBtn(){", icons+"\nfunction bindSoundBtn(){",1)
    n+=1; print("  + SVG иконки звука")

# Новая привязка: переключатель в Агенте
old='''function bindSoundBtn(){
  const btn=$('#sound-btn');
  if(!btn) return;
  btn.textContent=Sound.isOn()?'🔊':'🔇';
  btn.onclick=()=>{ const on=Sound.toggle(); btn.textContent=on?'🔊':'🔇'; if(on)Sound.tap(); };
}'''
new='''function bindSoundBtn(){
  // звук теперь в Агенте (переключатель)
  var row=document.getElementById('ag-sound-toggle');
  if(!row) return;
  var ico=document.getElementById('ag-sound-ico');
  var sw=document.getElementById('ag-sound-switch');
  var st=document.getElementById('ag-sound-state');
  function paint(){
    var on=Sound.isOn();
    if(ico) ico.innerHTML=on?SND_ICON_ON:SND_ICON_OFF;
    if(sw) sw.classList.toggle('on',on);
    if(st) st.textContent=on?'Включён':'Выключен';
  }
  paint();
  row.onclick=function(){ var on=Sound.toggle(); if(on)Sound.tap(); paint(); try{navigator.vibrate&&navigator.vibrate(8);}catch(_){} };
}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + привязка переключателя звука в Агенте")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R94 — звук перенесён в Агента + качественный SVG"
echo "   git add -A && git commit -m 'R94: move sound toggle to Agent tab with SVG icon' && git push"
echo "═══════════════════════════════════════════════════════"
