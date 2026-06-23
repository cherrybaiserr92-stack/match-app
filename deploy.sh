#!/usr/bin/env bash
# СДВИГ R62 — иконка детектива обрезана, текст пролога/выбора исправлен
set -e
echo "══ штамп → R62 ══"
sed -i "s/SDVIG_BUILD='R61'/SDVIG_BUILD='R62'/" src/main/resources/static/app.js
sed -i 's/>R61</>R62</' src/main/resources/static/index.html

echo ""; echo "══ 1/2  подписи карточек выбора + текст пролога ════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# Карточки выбора: убираем одинаковые "Детектив", делаем М/Ж
# Первая карточка (м)
txt=txt.replace(
  '''<button class="gm-card" data-gender="m">
          <div class="gm-portrait"><img src="/img/chars/char-recruit.png" alt="М"></div>
          <div class="gm-label">Детектив</div>
        </button>''',
  '''<button class="gm-card" data-gender="m">
          <div class="gm-portrait"><img src="/img/chars/char-recruit.png" alt="М"></div>
          <div class="gm-label">Мужчина</div>
        </button>''')
# Вторая карточка (ж)
txt=txt.replace(
  '''<button class="gm-card" data-gender="f">
          <div class="gm-portrait"><img src="/img/chars/char-recruit-f.png" alt="Ж"></div>
          <div class="gm-label">Детектив</div>
        </button>''',
  '''<button class="gm-card" data-gender="f">
          <div class="gm-portrait"><img src="/img/chars/char-recruit-f.png" alt="Ж"></div>
          <div class="gm-label">Женщина</div>
        </button>''')
n+=1; print("  + карточки выбора: Мужчина/Женщина (вместо Детектив/Детектив)")

# Текст пролога слайд 1: убираем "Добро пожаловать в СДВИГ" → нейтральнее
txt=txt.replace('<div class="pr-eyebrow">Добро пожаловать в СДВИГ</div>',
                '<div class="pr-eyebrow">Твоя роль</div>')
n+=1; print("  + слайд 1 eyebrow: 'Твоя роль'")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ index.html: %d"%n)
PYEOF


echo ""; echo "══ 2/2  CSS иконки пролога — без пятна/рамки ═══════"
python3 - << 'PYEOF'
path="src/main/resources/static/style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Иконка детектива теперь сама с углами — убираем лишнюю тень-свечение, чтобы не было "пятна"
# для слайда 1 (детектив-сцена) — мягкая тень, остальные иконки — свечение
old=".pr-ico img{width:130px;height:130px;object-fit:contain;filter:drop-shadow(0 8px 30px rgba(200,134,10,.4));}"
new='''.pr-ico img{width:130px;height:130px;object-fit:contain;filter:drop-shadow(0 6px 20px rgba(0,0,0,.5));}
.pr-slide[data-s="0"] .pr-ico img{width:140px;height:140px;border-radius:24px;
  filter:drop-shadow(0 8px 24px rgba(0,0,0,.6));}'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + иконка детектива без пятна (мягкая тень)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ style.css: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R62 — иконка обрезана, текст исправлен"
echo "   git add -A && git commit -m 'R62: detective icon crop, prologue text fixes' && git push"
echo "═══════════════════════════════════════════════════════"
