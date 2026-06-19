#!/usr/bin/env bash
# Копирует char-*.png и bg-*.png из /sdcard/Download/ в репозиторий
REPO="$(pwd)"
DL="/sdcard/Download"

mkdir -p "$REPO/src/main/resources/static/img/chars"
mkdir -p "$REPO/src/main/resources/static/img/bg"

C=0; B=0
for f in "$DL"/char-*.png; do
  [ -f "$f" ] || continue
  cp "$f" "$REPO/src/main/resources/static/img/chars/"
  echo "  ✓ $(basename $f)"
  C=$((C+1))
done
for f in "$DL"/bg-*.png "$DL"/bg-*.jpg "$DL"/bg-*.webp; do
  [ -f "$f" ] || continue
  cp "$f" "$REPO/src/main/resources/static/img/bg/"
  echo "  ✓ $(basename $f)"
  B=$((B+1))
done
echo ""
echo "Персонажей: $C | Фонов: $B"
[ $C -gt 0 ] && echo "✅ Готово" || echo "⚠️  Файлы не найдены в $DL — сначала скачай из чата"
