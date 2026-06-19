#!/usr/bin/env bash
# Чинит дубль Сдвига: char-shift-1.png (новый) → char-shift.png (затирает старый)
set -e
D="src/main/resources/static/img/chars"

if [ -f "$D/char-shift-1.png" ]; then
  mv -f "$D/char-shift-1.png" "$D/char-shift.png"
  echo "✓ char-shift-1.png → char-shift.png (старый затёрт)"
else
  echo "⚠️  char-shift-1.png не найден — возможно уже исправлено"
fi

echo ""
echo "Файлы Сдвига сейчас:"
ls -la "$D"/char-shift*.png 2>/dev/null
