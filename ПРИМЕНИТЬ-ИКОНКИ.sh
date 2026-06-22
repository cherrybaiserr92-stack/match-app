#!/usr/bin/env bash
set -e
if [ ! -d "src/main/resources/static" ]; then echo "✗ Запусти из корня match-app-main"; exit 1; fi
mkdir -p src/main/resources/static/img/icons
cp -fv img/icons/*.png src/main/resources/static/img/icons/
git add -A && git commit -m "premium icons (magnify, hat, scales, cards, etc)" && git push
echo "✓ Иконки добавлены"
