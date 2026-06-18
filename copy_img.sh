#!/usr/bin/env bash
# Копирует char-*.png и bg-*.png из /sdcard/Download/ в репозиторий
set -e
REPO_DIR="$(pwd)"
DL="/sdcard/Download"

mkdir -p "$REPO_DIR/src/main/resources/static/img/chars"
mkdir -p "$REPO_DIR/src/main/resources/static/img/bg"

CHARS=0; BGS=0

for f in "$DL"/char-*.png; do
  [ -f "$f" ] || continue
  cp "$f" "$REPO_DIR/src/main/resources/static/img/chars/"
  echo "  ✓ chars/$(basename "$f")"
  CHARS=$((CHARS+1))
done

for f in "$DL"/bg-*.png; do
  [ -f "$f" ] || continue
  cp "$f" "$REPO_DIR/src/main/resources/static/img/bg/"
  echo "  ✓ bg/$(basename "$f")"
  BGS=$((BGS+1))
done

echo ""
echo "Персонажей: $CHARS / 12"
echo "Фонов:      $BGS / 1"
[ $CHARS -gt 0 ] && echo "✅ Готово к деплою" || echo "⚠️  Файлы не найдены в $DL"
