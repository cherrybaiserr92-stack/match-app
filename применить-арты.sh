#!/usr/bin/env bash
# СДВИГ — автодобавление артов из Download. Запускать из корня match-app-main
set -e
echo "═══ СДВИГ — добавление артов ═══"
if [ ! -d "src/main/resources/static" ]; then
  echo "✗ Запусти из корня репозитория: cd ~/match-app-main"; exit 1
fi
ZIP=""
for p in /sdcard/Download/арты-финал.zip /storage/emulated/0/Download/арты-финал.zip ~/storage/downloads/арты-финал.zip; do
  [ -f "$p" ] && ZIP="$p" && break
done
[ -z "$ZIP" ] && { echo "✗ Не нашёл арты-финал.zip в Download"; exit 1; }
echo "✓ Архив: $ZIP"
TMP=$(mktemp -d); unzip -qo "$ZIP" -d "$TMP"
cp -f "$TMP"/img/chars/*.png src/main/resources/static/img/chars/
mkdir -p src/main/resources/static/img/bg
cp -f "$TMP"/img/bg/*.jpg src/main/resources/static/img/bg/
rm -f src/main/resources/static/img/chars/char-guests.png src/main/resources/static/img/chars/char-conroy.png
rm -rf "$TMP"
echo "✓ Арты разложены"
git add -A && git commit -m "art: transparent characters + backgrounds" && git push
echo "✅ Готово! Railway пересоберёт через 1-2 мин."
