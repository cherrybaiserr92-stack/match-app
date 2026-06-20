#!/usr/bin/env bash
# СДВИГ R42 — аватары: больше квадрат + точный кроп на лицо
set -e
echo ""; echo "══ feed.js — аватар больше и кроп на лицо ══════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Спрайт 800×1200, голова в Y 113..330 (~18% высоты), центр по X.
# Для аватара 52×52: масштабируем так, чтобы голова заняла квадрат.
# background-size: ширина 200% (голова ~центр), position по Y чтобы показать верх лица.
old=".m2-av{width:44px;height:44px;border-radius:12px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;\n      background-size:160% auto;background-position:center top;transition:all .3s;background-repeat:no-repeat;}"
new=".m2-av{width:54px;height:54px;border-radius:13px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;\n      background-size:200% auto;background-position:50% 8%;transition:all .3s;background-repeat:no-repeat;}"
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + аватар 54px, кроп на лицо (200% ширина, Y 8%)")

# деуцкия-аватар (мозг) тоже крупнее
old_d=".msg2.deduce .m2-av{border-color:#46d89b;color:#46d89b;background:rgba(70,216,155,.1);\n      display:flex;align-items:center;justify-content:center;font-size:20px;}"
new_d=".msg2.deduce .m2-av{border-color:#46d89b;color:#46d89b;background:rgba(70,216,155,.1);\n      display:flex;align-items:center;justify-content:center;font-size:24px;}"
if old_d in txt:
    txt=txt.replace(old_d,new_d,1); n+=1; print("  + аватар дедукции крупнее")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF
echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R42 — аватары увеличены и кропнуты на лицо"
echo "   git add -A && git commit -m 'R42: bigger avatars, face crop' && git push"
echo "═══════════════════════════════════════════════════════"
