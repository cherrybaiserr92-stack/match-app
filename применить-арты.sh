#!/usr/bin/env bash
# СДВИГ — автодобавление артов R54 из папки Download
# Запускать из корня репозитория match-app-main
set -e

echo "═══════════════════════════════════════════════════════"
echo "  СДВИГ — добавление новых артов (Эленор, фоны глав)"
echo "═══════════════════════════════════════════════════════"

# 1. Проверяем что мы в репозитории
if [ ! -d "src/main/resources/static" ]; then
  echo "✗ ОШИБКА: запусти скрипт из корня репозитория match-app-main"
  echo "  Сначала: cd ~/match-app-main  (или где у тебя репо)"
  exit 1
fi

# 2. Ищем архив артов в Download
ZIP=""
for p in /sdcard/Download/арты-R54.zip /sdcard/Download/arty-R54.zip /storage/emulated/0/Download/арты-R54.zip ~/storage/downloads/арты-R54.zip; do
  if [ -f "$p" ]; then ZIP="$p"; break; fi
done

if [ -z "$ZIP" ]; then
  echo "✗ Не нашёл арты-R54.zip в папке Download"
  echo "  Положи файл арты-R54.zip в Download и запусти снова"
  exit 1
fi
echo "✓ Нашёл архив: $ZIP"

# 3. Распаковываем во временную папку
TMP=$(mktemp -d)
unzip -qo "$ZIP" -d "$TMP"
echo "✓ Архив распакован"

# 4. Копируем персонажей
mkdir -p src/main/resources/static/img/chars
cp -f "$TMP"/img/chars/*.png src/main/resources/static/img/chars/
echo "✓ Персонажи скопированы (Эленор, Патрульный, Капитан, Аранделл, нервный)"

# 5. Копируем фоны
mkdir -p src/main/resources/static/img/bg
cp -f "$TMP"/img/bg/*.jpg src/main/resources/static/img/bg/
echo "✓ Фоны глав скопированы (старый город, доки, лес, особняк ×2)"

# 6. Удаляем старые ненужные арты
rm -f src/main/resources/static/img/chars/char-guests.png
rm -f src/main/resources/static/img/chars/char-conroy.png
echo "✓ Старые заглушки удалены (guests, conroy)"

# 7. Чистим временное
rm -rf "$TMP"

# 8. Коммит и пуш
echo ""
echo "Отправляю в репозиторий..."
git add -A
git commit -m "R54 art: Eleanor, cop, captain, chapter backgrounds"
git push

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  ГОТОВО! Арты добавлены и отправлены."
echo "    Railway пересоберёт проект через 1-2 минуты."
echo "═══════════════════════════════════════════════════════"
