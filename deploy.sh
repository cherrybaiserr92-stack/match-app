#!/usr/bin/env bash
# СДВИГ R10.2 — инструменты к низу, карусель полностью видна
set -e

python3 - << 'PYEOF'
path = "src/main/resources/static/card-design.css"
with open(path, encoding="utf-8") as f:
    txt = f.read()

if "/* R10.2 */" in txt:
    print("· уже применено")
    exit(0)

# ── 1. убираем двойной padding-bottom (#tab-cases) ──────────
# tab-area уже имеет margin-bottom под nav, второй раз не нужен
old_pb = (
    "/* 3. Отступ под нижнее меню (tab-cases учитывает nav) */\n"
    "#tab-cases{\n"
    "  padding-bottom:calc(var(--navh) + var(--safeb)) !important;\n"
    "}"
)
new_pb = (
    "/* 3. R10.2: padding-bottom убран — tab-area.margin-bottom уже даёт отступ под nav */\n"
    "#tab-cases{\n"
    "  padding-bottom:max(2px,env(safe-area-inset-bottom)) !important;\n"
    "}"
)
if old_pb in txt:
    txt = txt.replace(old_pb, new_pb, 1)
    print("  + padding-bottom исправлен")
else:
    print("  · padding-bottom уже исправлен")

# ── 2. дополнительные правки компактности ───────────────────
extra = """
/* R10.2 — тулбар в самый низ + карусель видна полностью */

/* tools-bar: прижать к нижнему меню, без лишнего отступа */
#tab-cases > .tools-bar{
  padding-top:5px !important;
  padding-bottom:max(6px,env(safe-area-inset-bottom)) !important;
}

/* stage занимает ровно оставшееся пространство */
#tab-cases > .stage{
  flex:1 1 0 !important;
  min-height:0 !important;
}

/* карточки: высота под реальный экран */
:root{
  --card-h: min(48vh, 390px);
  --card-w: min(60%, 212px);
}

/* кольцо: перспектива и центр немного выше
   чтобы боковые карточки не выходили за экран */
.ring-scene{
  perspective-origin:50% 44% !important;
}
"""

if "R10.2" not in txt:
    txt += extra
    print("  + R10.2 компактность добавлена")

with open(path, "w", encoding="utf-8") as f:
    f.write(txt)
print("✓ card-design.css сохранён")
PYEOF

echo ""
echo "✅  R10.2 готов"
echo "   git add -A && git commit -m 'R10.2: tools to bottom, carousel fits screen' && git push"
