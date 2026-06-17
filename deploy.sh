#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#  СДВИГ · Патч: связываем sdvig-shift.html с основным приложением
#  Изменения: app.js · sdvig-shift.html · style.css
# ═══════════════════════════════════════════════════════════
set -e

echo ""
echo "══ 1/3  sdvig-shift.html — кнопка «← Дела» ══════"
python3 - << 'PYEOF'
import sys

path = "src/main/resources/static/sdvig-shift.html"
with open(path, encoding="utf-8") as f:
    txt = f.read()

# ── CSS ──────────────────────────────────────────────────
back_css = """
/* ── back-btn (R9) ── */
.back-btn{
  display:flex;align-items:center;gap:4px;flex-shrink:0;
  padding:6px 11px;border-radius:8px;cursor:pointer;
  background:rgba(14,20,30,.55);border:1px solid rgba(255,255,255,.12);
  backdrop-filter:blur(6px);color:var(--amber-lite);text-decoration:none;
  font-size:12px;font-weight:700;letter-spacing:.05em;
  transition:background .15s,border-color .15s;
  -webkit-tap-highlight-color:transparent;
}
.back-btn:active{ background:rgba(200,134,10,.25); border-color:var(--amber); }
"""

if ".back-btn" not in txt:
    txt = txt.replace("</style>", back_css + "</style>", 1)
    print("  + CSS добавлен")
else:
    print("  · CSS уже есть, пропускаем")

# ── HTML: вставляем кнопку в topbar ─────────────────────
old = ('  <div class="topbar">\n'
       '    <div>\n'
       '      <div class="case-name"')
new = ('  <div class="topbar">\n'
       '    <a class="back-btn" href="/" title="На главную">&#8592; Дела</a>\n'
       '    <div style="flex:1;min-width:0">\n'
       '      <div class="case-name"')

if old in txt:
    txt = txt.replace(old, new, 1)
    print("  + back-btn вставлена в topbar")
else:
    print("  · topbar уже пропатчен (OK)")

# ── версия ───────────────────────────────────────────────
txt = txt.replace(
    "ПРОТОТИП «СДВИГ» · СБОРКА R8 · логотип+карты",
    "ПРОТОТИП «СДВИГ» · СБОРКА R9 · linked to app"
)

with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
print("✓ sdvig-shift.html сохранён")
PYEOF


echo ""
echo "══ 2/3  app.js — renderCard() → launcher ══════════"
python3 - << 'PYEOF'
import sys

path = "src/main/resources/static/app.js"
with open(path, encoding="utf-8") as f:
    txt = f.read()

marker = "function renderCard(){"
if marker not in txt:
    print("⚠  renderCard не найден — пропускаем")
    sys.exit(0)

# Находим конец функции подсчётом скобок
start = txt.index(marker)
depth = 0
end = start
i = start
while i < len(txt):
    ch = txt[i]
    if ch == '{':
        depth += 1
    elif ch == '}':
        depth -= 1
        if depth == 0:
            end = i + 1
            break
    i += 1

new_fn = (
    "function renderCard(){\n"
    "  const zone=$('#swipe-zone');\n"
    "  zone.querySelector('.case-card')?.remove();\n"
    "  // ── Портал в sdvig-shift.html (R9) ──\n"
    "  const card=el('div','case-card card-enter ct-crime case-launcher');\n"
    "  card.innerHTML=`\n"
    "    <div class=\"card-bg\">${cardBackground('crime')}</div>\n"
    "    <div class=\"launch-inner\">\n"
    "      <div class=\"launch-eyebrow\">\u0410\u041a\u0422\u0418\u0412\u041d\u041e\u0415 \u0414\u0415\u041b\u041e</div>\n"
    "      <div class=\"launch-num\">\u2116 001</div>\n"
    "      <div class=\"launch-title\">\u0417\u0432\u0435\u0437\u0434\u0430 \u0421\u0435\u0432\u0435\u0440\u0430</div>\n"
    "      <div class=\"launch-meta\">\u041a\u0440\u0430\u0436\u0430 \u0432 \u043c\u0443\u0437\u0435\u0435 \u00b7 3 \u043a\u043b\u044e\u0447\u0435\u0432\u044b\u0445 \u043c\u043e\u043c\u0435\u043d\u0442\u0430</div>\n"
    "      <div class=\"launch-divider\"></div>\n"
    "      <div class=\"launch-hint\">\u041d\u0430\u0436\u043c\u0438, \u0447\u0442\u043e\u0431\u044b \u043d\u0430\u0447\u0430\u0442\u044c \u0440\u0430\u0441\u0441\u043b\u0435\u0434\u043e\u0432\u0430\u043d\u0438\u0435</div>\n"
    "    </div>\n"
    "  `;\n"
    "  card.onclick=()=>{ try{Sound.tap();}catch(_){} window.location.href='/sdvig-shift.html'; };\n"
    "  zone.appendChild(card);\n"
    "  try{Sound.tap();}catch(_){}\n"
    "}"
)

txt = txt[:start] + new_fn + txt[end:]

with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
print("✓ renderCard() заменён на launcher")
PYEOF


echo ""
echo "══ 3/3  style.css — стили лаунчера ════════════════"
python3 - << 'PYEOF'
path = "src/main/resources/static/style.css"
with open(path, encoding="utf-8") as f:
    txt = f.read()

if ".case-launcher" in txt:
    print("  · launcher-CSS уже есть, пропускаем")
else:
    launcher_css = """
/* ════ case-launcher: портал в sdvig-shift.html (R9) ════ */
.case-launcher{ cursor:pointer; transition:filter .15s; }
.case-launcher:active{ filter:brightness(.82); }
.launch-inner{
  position:relative; z-index:3;
  display:flex; flex-direction:column; align-items:center;
  justify-content:center; height:100%; padding:28px 24px; gap:8px;
  text-align:center;
}
.launch-eyebrow{
  font-family:'Unbounded',sans-serif; font-size:9px; font-weight:700;
  letter-spacing:.24em; color:var(--amber); text-transform:uppercase; opacity:.8;
}
.launch-num{
  font-family:'Unbounded',sans-serif; font-size:44px; font-weight:900; line-height:1;
  background:linear-gradient(135deg,#5a3c0a 0%,#f3d27a 28%,#caa033 52%,#f8e9b8 74%,#6a4810 100%);
  -webkit-background-clip:text; background-clip:text; color:transparent;
  filter:drop-shadow(0 2px 10px rgba(200,134,10,.5));
}
.launch-title{
  font-family:'Unbounded',sans-serif; font-size:21px; font-weight:800;
  color:#ece5d4; text-shadow:0 2px 14px rgba(0,0,0,.75); line-height:1.22;
}
.launch-meta{
  font-size:11.5px; color:#8b94a4; letter-spacing:.06em;
}
.launch-divider{
  width:48px; height:1.5px; margin:4px auto;
  background:linear-gradient(90deg,transparent,var(--amber),transparent);
}
.launch-hint{
  font-size:10.5px; letter-spacing:.15em; text-transform:uppercase;
  color:rgba(200,134,10,.65);
  animation:launchPulse 2.2s ease-in-out infinite;
}
@keyframes launchPulse{ 0%,100%{opacity:.4} 50%{opacity:.95} }
"""
    txt += launcher_css
    with open(path, "w", encoding="utf-8") as f:
        f.write(txt)
    print("✓ launcher-CSS добавлен")
PYEOF


echo ""
echo "═══════════════════════════════════════════════════"
echo "✅  Патч применён (R9)"
echo "   Теперь: git add -A && git commit -m 'R9: link sdvig-shift to main app' && git push"
echo "═══════════════════════════════════════════════════"
