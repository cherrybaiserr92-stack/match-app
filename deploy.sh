#!/usr/bin/env bash
# СДВИГ R89 — удаление 3 старых игр + новая «Осмотр места» на куб и в аркады
set -e
echo "══ штамп → R89 ══"
sed -i "s/SDVIG_BUILD='R88'/SDVIG_BUILD='R89'/" src/main/resources/static/app.js
sed -i 's/>R88</>R89</' src/main/resources/static/index.html

echo ""; echo "══ 1/5  удаляем 3 старые нерабочие игры ═══════════"
cd src/main/resources/static
for f in crime-board detective-mahjong torn-letter; do
  rm -f games/$f.js && echo "  − games/$f.js удалён"
done
# убираем их <script> из index.html
python3 - << 'PYEOF'
path="index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
for s in ['detective-mahjong','torn-letter','crime-board']:
    line='<script src="/games/%s.js"></script>'%s
    if line in txt:
        txt=txt.replace(line+'\n',''); txt=txt.replace(line,'')
        print("  − script %s убран"%s)
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF
cd - >/dev/null

echo ""; echo "══ 2/5  создаём games/examine.js ══════════════════"
echo "Lyog4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQCiAgINCh0JTQktCY0JMgwrcg0JzQuNC90Lgt0LjQs9GA0LAgwqvQntCh0JzQntCi0KAg0JzQldCh0KLQkMK7ICjRgdC/0L7QutC+0LnQvdCw0Y8g0LvQvtCz0LjQutCwL9C/0L7QuNGB0LopCiAgINCa0L7QvdGC0YDQsNC60YI6IEV4YW1pbmUuc3RhcnQoY29udGFpbmVyLHttaXNzaW9uLG9uV2luLG9uTG9zZX0pIC8gLnN0b3AoKQogICDQndCw0LnQtNC4INC90LDRgdGC0L7Rj9GJ0LjQtSDRg9C70LjQutC4INGB0YDQtdC00Lgg0L/RgNC10LTQvNC10YLQvtCyINGBINC/0L7QvNC+0YnRjNGOINC70YPQv9GLLgrilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZAgKi8KKGZ1bmN0aW9uKCl7CiAgdmFyIGN2LCBjdHgsIHJhZiwgcnVubmluZz1mYWxzZSwgb3B0cz1udWxsOwogIHZhciBXPTAsSD0wLERQUj0xOwogIHZhciBpdGVtcz1bXSwgbmVlZD0wLCBmb3VuZD0wLCBzdHJpa2VzPTAsIG1heFN0cmlrZXM9MzsKICB2YXIgZ2xhc3M9e3g6LTk5OSx5Oi05OTksYWN0aXZlOmZhbHNlfTsKICB2YXIgdDA9MDsKCiAgLy8g0L3Rg9Cw0YAt0LjQutC+0L3QutC4INC/0YDQtdC00LzQtdGC0L7QsiAo0YDQuNGB0YPRjtGC0YHRjyDQv9GA0L7RhtC10LTRg9GA0L3QvikKICB2YXIgSUNPTlM9WydrZXknLCd3YXRjaCcsJ2xldHRlcicsJ2dsYXNzJywncmluZycsJ2NvaW4nLCdrbmlmZScsJ3Bob3RvJywnYm90dGxlJywnY2FyZCcsJ2NpZycsJ2J1dHRvbiddOwoKICBmdW5jdGlvbiBybmQoYSxiKXsgcmV0dXJuIGErTWF0aC5yYW5kb20oKSooYi1hKTsgfQogIGZ1bmN0aW9uIHBpY2soYXJyKXsgcmV0dXJuIGFyclsoTWF0aC5yYW5kb20oKSphcnIubGVuZ3RoKXwwXTsgfQoKICBmdW5jdGlvbiBsYXlvdXQoKXsKICAgIGl0ZW1zPVtdOwogICAgdmFyIGNvbHM9NCwgcm93cz00OwogICAgdmFyIHBhZD1NYXRoLm1pbihXLEgpKjAuMTI7CiAgICB2YXIgY3c9KFctcGFkKjIpL2NvbHMsIGNoPShILXBhZCoyKS9yb3dzOwogICAgdmFyIHNsb3RzPVtdOwogICAgZm9yKHZhciByPTA7cjxyb3dzO3IrKykgZm9yKHZhciBjPTA7Yzxjb2xzO2MrKyl7CiAgICAgIHNsb3RzLnB1c2goe2N4OnBhZCtjdypjK2N3LzIsIGN5OnBhZCtjaCpyK2NoLzJ9KTsKICAgIH0KICAgIC8vINC/0LXRgNC10LzQtdGI0LjQstCw0LXQvCDRgdC70L7RgtGLCiAgICBzbG90cy5zb3J0KGZ1bmN0aW9uKCl7cmV0dXJuIE1hdGgucmFuZG9tKCktMC41O30pOwogICAgdmFyIHRvdGFsPU1hdGgubWluKHNsb3RzLmxlbmd0aCwgbmVlZCs4KTsgLy8g0YPQu9C40LrQuCArINC/0YDQuNC80LDQvdC60LgKICAgIGZvcih2YXIgaT0wO2k8dG90YWw7aSsrKXsKICAgICAgdmFyIHM9c2xvdHNbaV07CiAgICAgIGl0ZW1zLnB1c2goewogICAgICAgIHg6cy5jeCtybmQoLWN3KjAuMTIsY3cqMC4xMiksCiAgICAgICAgeTpzLmN5K3JuZCgtY2gqMC4xMixjaCowLjEyKSwKICAgICAgICByOk1hdGgubWluKGN3LGNoKSowLjMwLAogICAgICAgIGljb246cGljayhJQ09OUyksCiAgICAgICAgcmVhbDppPG5lZWQsICAgICAgICAvLyDQv9C10YDQstGL0LUgbmVlZCDigJQg0L3QsNGB0YLQvtGP0YnQuNC1INGD0LvQuNC60LgKICAgICAgICBmb3VuZDpmYWxzZSwgd3Jvbmc6ZmFsc2UsCiAgICAgICAgZ2xpbnQ6TWF0aC5yYW5kb20oKSo2LjI4LAogICAgICAgIHNjYWxlOjAKICAgICAgfSk7CiAgICB9CiAgICBpdGVtcy5zb3J0KGZ1bmN0aW9uKCl7cmV0dXJuIE1hdGgucmFuZG9tKCktMC41O30pOwogIH0KCiAgZnVuY3Rpb24gcmVzaXplKCl7CiAgICB2YXIgcmVjdD1jdi5nZXRCb3VuZGluZ0NsaWVudFJlY3QoKTsKICAgIERQUj1NYXRoLm1pbih3aW5kb3cuZGV2aWNlUGl4ZWxSYXRpb3x8MSwyKTsKICAgIFc9cmVjdC53aWR0aDsgSD1yZWN0LmhlaWdodDsKICAgIGN2LndpZHRoPVcqRFBSOyBjdi5oZWlnaHQ9SCpEUFI7CiAgICBjdHguc2V0VHJhbnNmb3JtKERQUiwwLDAsRFBSLDAsMCk7CiAgfQoKICBmdW5jdGlvbiBkcmF3SWNvbihpdCxhKXsKICAgIGN0eC5zYXZlKCk7CiAgICBjdHgudHJhbnNsYXRlKGl0LngsaXQueSk7CiAgICB2YXIgcz1pdC5zY2FsZTsKICAgIGN0eC5zY2FsZShzLHMpOwogICAgdmFyIGNvbCA9IGl0LmZvdW5kPycjNDZkODliJyA6IGl0Lndyb25nPycjZDg0NjQ2JyA6ICcjYjhhODg4JzsKICAgIGN0eC5zdHJva2VTdHlsZT1jb2w7IGN0eC5maWxsU3R5bGU9Y29sOyBjdHgubGluZVdpZHRoPTIuMjsgY3R4Lmdsb2JhbEFscGhhPWE7CiAgICB2YXIgUj1pdC5yOwogICAgc3dpdGNoKGl0Lmljb24pewogICAgICBjYXNlICdrZXknOiBjdHguYmVnaW5QYXRoKCk7Y3R4LmFyYygtUiowLjQsMCxSKjAuMywwLDYuMjgpO2N0eC5zdHJva2UoKTsKICAgICAgICBjdHguYmVnaW5QYXRoKCk7Y3R4Lm1vdmVUbygtUiowLjEsMCk7Y3R4LmxpbmVUbyhSKjAuNiwwKTtjdHgubW92ZVRvKFIqMC40LDApO2N0eC5saW5lVG8oUiowLjQsUiowLjI1KTtjdHgubW92ZVRvKFIqMC42LDApO2N0eC5saW5lVG8oUiowLjYsUiowLjMpO2N0eC5zdHJva2UoKTticmVhazsKICAgICAgY2FzZSAnd2F0Y2gnOiBjdHguYmVnaW5QYXRoKCk7Y3R4LmFyYygwLDAsUiowLjUsMCw2LjI4KTtjdHguc3Ryb2tlKCk7CiAgICAgICAgY3R4LmJlZ2luUGF0aCgpO2N0eC5tb3ZlVG8oMCwwKTtjdHgubGluZVRvKDAsLVIqMC4zKTtjdHgubW92ZVRvKDAsMCk7Y3R4LmxpbmVUbyhSKjAuMixSKjAuMSk7Y3R4LnN0cm9rZSgpO2JyZWFrOwogICAgICBjYXNlICdsZXR0ZXInOiBjdHguc3Ryb2tlUmVjdCgtUiowLjUsLVIqMC4zNSxSLFIqMC43KTsKICAgICAgICBjdHguYmVnaW5QYXRoKCk7Y3R4Lm1vdmVUbygtUiowLjUsLVIqMC4zNSk7Y3R4LmxpbmVUbygwLFIqMC4wNSk7Y3R4LmxpbmVUbyhSKjAuNSwtUiowLjM1KTtjdHguc3Ryb2tlKCk7YnJlYWs7CiAgICAgIGNhc2UgJ2dsYXNzJzogY3R4LmJlZ2luUGF0aCgpO2N0eC5hcmMoLVIqMC4xNSwtUiowLjE1LFIqMC40LDAsNi4yOCk7Y3R4LnN0cm9rZSgpOwogICAgICAgIGN0eC5iZWdpblBhdGgoKTtjdHgubW92ZVRvKFIqMC4xNSxSKjAuMTUpO2N0eC5saW5lVG8oUiowLjUsUiowLjUpO2N0eC5zdHJva2UoKTticmVhazsKICAgICAgY2FzZSAncmluZyc6IGN0eC5iZWdpblBhdGgoKTtjdHguYXJjKDAsUiowLjEsUiowLjM4LDAsNi4yOCk7Y3R4LnN0cm9rZSgpOwogICAgICAgIGN0eC5iZWdpblBhdGgoKTtjdHgubW92ZVRvKDAsLVIqMC4yOCk7Y3R4LmxpbmVUbygtUiowLjEyLC1SKjAuNSk7Y3R4LmxpbmVUbyhSKjAuMTIsLVIqMC41KTtjdHguY2xvc2VQYXRoKCk7Y3R4LnN0cm9rZSgpO2JyZWFrOwogICAgICBjYXNlICdjb2luJzogY3R4LmJlZ2luUGF0aCgpO2N0eC5hcmMoMCwwLFIqMC40NSwwLDYuMjgpO2N0eC5zdHJva2UoKTsKICAgICAgICBjdHguYmVnaW5QYXRoKCk7Y3R4LmFyYygwLDAsUiowLjI4LDAsNi4yOCk7Y3R4LnN0cm9rZSgpO2JyZWFrOwogICAgICBjYXNlICdrbmlmZSc6IGN0eC5iZWdpblBhdGgoKTtjdHgubW92ZVRvKC1SKjAuNSxSKjAuMyk7Y3R4LmxpbmVUbyhSKjAuMiwtUiowLjQpO2N0eC5saW5lVG8oUiowLjM1LC1SKjAuMjUpO2N0eC5saW5lVG8oLVIqMC4zNSxSKjAuNDUpO2N0eC5jbG9zZVBhdGgoKTtjdHguc3Ryb2tlKCk7CiAgICAgICAgY3R4LmJlZ2luUGF0aCgpO2N0eC5tb3ZlVG8oUiowLjIsLVIqMC40KTtjdHgubGluZVRvKFIqMC41LC1SKjAuNSk7Y3R4LnN0cm9rZSgpO2JyZWFrOwogICAgICBjYXNlICdwaG90byc6IGN0eC5zdHJva2VSZWN0KC1SKjAuNDUsLVIqMC40NSxSKjAuOSxSKjAuOSk7CiAgICAgICAgY3R4LmJlZ2luUGF0aCgpO2N0eC5hcmMoLVIqMC4xLC1SKjAuMSxSKjAuMTUsMCw2LjI4KTtjdHguc3Ryb2tlKCk7CiAgICAgICAgY3R4LmJlZ2luUGF0aCgpO2N0eC5tb3ZlVG8oLVIqMC40LFIqMC4zNSk7Y3R4LmxpbmVUbygtUiowLjA1LFIqMC4wKTtjdHgubGluZVRvKFIqMC4xNSxSKjAuMik7Y3R4LmxpbmVUbyhSKjAuNCwtUiowLjEpO2N0eC5zdHJva2UoKTticmVhazsKICAgICAgY2FzZSAnYm90dGxlJzogY3R4LmJlZ2luUGF0aCgpO2N0eC5tb3ZlVG8oLVIqMC4xOCwtUiowLjUpO2N0eC5saW5lVG8oUiowLjE4LC1SKjAuNSk7Y3R4LmxpbmVUbyhSKjAuMTgsLVIqMC4yKTtjdHgubGluZVRvKFIqMC4zLDApO2N0eC5saW5lVG8oUiowLjMsUiowLjUpO2N0eC5saW5lVG8oLVIqMC4zLFIqMC41KTtjdHgubGluZVRvKC1SKjAuMywwKTtjdHgubGluZVRvKC1SKjAuMTgsLVIqMC4yKTtjdHguY2xvc2VQYXRoKCk7Y3R4LnN0cm9rZSgpO2JyZWFrOwogICAgICBjYXNlICdjYXJkJzogY3R4LnN0cm9rZVJlY3QoLVIqMC41LC1SKjAuMzIsUixSKjAuNjQpOwogICAgICAgIGN0eC5iZWdpblBhdGgoKTtjdHgubW92ZVRvKC1SKjAuMywtUiowLjEpO2N0eC5saW5lVG8oUiowLjMsLVIqMC4xKTtjdHgubW92ZVRvKC1SKjAuMyxSKjAuMSk7Y3R4LmxpbmVUbyhSKjAuMSxSKjAuMSk7Y3R4LnN0cm9rZSgpO2JyZWFrOwogICAgICBjYXNlICdjaWcnOiBjdHguc3Ryb2tlUmVjdCgtUiowLjUsLVIqMC4xMixSLFIqMC4yNCk7CiAgICAgICAgY3R4LmJlZ2luUGF0aCgpO2N0eC5tb3ZlVG8oUiowLjUsMCk7Y3R4LmxpbmVUbyhSKjAuNywtUiowLjE1KTtjdHguc3Ryb2tlKCk7YnJlYWs7CiAgICAgIGRlZmF1bHQ6IGN0eC5iZWdpblBhdGgoKTtjdHguYXJjKDAsMCxSKjAuNCwwLDYuMjgpO2N0eC5zdHJva2UoKTsKICAgIH0KICAgIGN0eC5yZXN0b3JlKCk7CiAgfQoKICBmdW5jdGlvbiBsb29wKHRzKXsKICAgIGlmKCFydW5uaW5nKSByZXR1cm47CiAgICBpZighdDApIHQwPXRzOwogICAgY3R4LmNsZWFyUmVjdCgwLDAsVyxIKTsKICAgIC8vINC90YPQsNGALdGE0L7QvSDRgdGG0LXQvdGLCiAgICB2YXIgZz1jdHguY3JlYXRlUmFkaWFsR3JhZGllbnQoVy8yLEgqMC40LDQwLFcvMixIKjAuNCxNYXRoLm1heChXLEgpKjAuNyk7CiAgICBnLmFkZENvbG9yU3RvcCgwLCdyZ2JhKDMwLDI2LDIwLDAuNiknKTsgZy5hZGRDb2xvclN0b3AoMSwncmdiYSg4LDgsMTEsMC45NSknKTsKICAgIGN0eC5maWxsU3R5bGU9ZzsgY3R4LmZpbGxSZWN0KDAsMCxXLEgpOwoKICAgIHZhciBuZWFyPW51bGwsIG5kPTFlOTsKICAgIGZvcih2YXIgaT0wO2k8aXRlbXMubGVuZ3RoO2krKyl7CiAgICAgIHZhciBpdD1pdGVtc1tpXTsKICAgICAgaXQuc2NhbGUgKz0gKDEtaXQuc2NhbGUpKjAuMTI7IC8vINC/0LvQsNCy0L3QvtC1INC/0L7Rj9Cy0LvQtdC90LjQtQogICAgICBpdC5nbGludCs9MC4wNTsKICAgICAgdmFyIGR4PWl0LngtZ2xhc3MueCwgZHk9aXQueS1nbGFzcy55LCBkPU1hdGguc3FydChkeCpkeCtkeSpkeSk7CiAgICAgIGlmKGdsYXNzLmFjdGl2ZSAmJiBkPG5kKXsgbmQ9ZDsgbmVhcj1pdDsgfQogICAgICAvLyDQsdCw0LfQvtCy0LDRjyDQv9GA0L7RgNC40YHQvtCy0LrQsAogICAgICB2YXIgYT0wLjU1OwogICAgICAvLyDQv9C+0LQg0LvRg9C/0L7QuSDRj9GA0YfQtQogICAgICBpZihnbGFzcy5hY3RpdmUgJiYgZDxnbGFzcy5yKXsgYT0wLjk1OyB9CiAgICAgIGRyYXdJY29uKGl0LGEpOwogICAgICAvLyDQvdCw0YHRgtC+0Y/RidC40LUg0YPQu9C40LrQuCDQv9C+0LQg0LvRg9C/0L7QuSDigJQg0LvRkdCz0LrQuNC5INGP0L3RgtCw0YDQvdGL0Lkg0L7RgtCx0LvQtdGB0LoKICAgICAgaWYoaXQucmVhbCAmJiAhaXQuZm91bmQgJiYgZ2xhc3MuYWN0aXZlICYmIGQ8Z2xhc3Mucil7CiAgICAgICAgdmFyIHB1bHNlPTAuNCswLjMqTWF0aC5zaW4oaXQuZ2xpbnQqMik7CiAgICAgICAgY3R4LnNhdmUoKTsKICAgICAgICBjdHguZ2xvYmFsQWxwaGE9cHVsc2UqMC42OwogICAgICAgIGN0eC5zdHJva2VTdHlsZT0nI2ZmY2Y2Yic7IGN0eC5saW5lV2lkdGg9MjsKICAgICAgICBjdHguYmVnaW5QYXRoKCk7IGN0eC5hcmMoaXQueCxpdC55LGl0LnIqMS4yLDAsNi4yOCk7IGN0eC5zdHJva2UoKTsKICAgICAgICBjdHgucmVzdG9yZSgpOwogICAgICB9CiAgICB9CgogICAgLy8g0LvQuNC90LfQsCAo0LvRg9C/0LApCiAgICBpZihnbGFzcy5hY3RpdmUpewogICAgICBjdHguc2F2ZSgpOwogICAgICBjdHguYmVnaW5QYXRoKCk7IGN0eC5hcmMoZ2xhc3MueCxnbGFzcy55LGdsYXNzLnIsMCw2LjI4KTsKICAgICAgY3R4LnN0cm9rZVN0eWxlPSdyZ2JhKDIwMCwxNjAsOTAsMC41KSc7IGN0eC5saW5lV2lkdGg9MzsgY3R4LnN0cm9rZSgpOwogICAgICBjdHguc3Ryb2tlU3R5bGU9J3JnYmEoMjU1LDI1NSwyNTUsMC4wOCknOyBjdHgubGluZVdpZHRoPTE7IGN0eC5zdHJva2UoKTsKICAgICAgLy8g0LHQu9C40LoKICAgICAgY3R4LmJlZ2luUGF0aCgpOyBjdHguYXJjKGdsYXNzLngtZ2xhc3MuciowLjMsZ2xhc3MueS1nbGFzcy5yKjAuMyxnbGFzcy5yKjAuMTUsMCw2LjI4KTsKICAgICAgY3R4LmZpbGxTdHlsZT0ncmdiYSgyNTUsMjU1LDI1NSwwLjEwKSc7IGN0eC5maWxsKCk7CiAgICAgIGN0eC5yZXN0b3JlKCk7CiAgICB9CgogICAgLy8gSFVEOiDRgdGH0ZHRgtGH0LjQuiDRg9C70LjQuiDQuCDQv9GA0L7QvNCw0YXQvtCyCiAgICBjdHguc2F2ZSgpOwogICAgY3R4LmZvbnQ9JzYwMCAxNHB4IEludGVyLHNhbnMtc2VyaWYnOyBjdHgudGV4dEJhc2VsaW5lPSd0b3AnOwogICAgY3R4LmZpbGxTdHlsZT0nI2ZmY2Y2Yic7IGN0eC5maWxsVGV4dCgn0KPQu9C40LrQuDogJytmb3VuZCsnLycrbmVlZCwgMTQsIDEyKTsKICAgIGN0eC5maWxsU3R5bGU9IHN0cmlrZXM+MD8nI2UwODA4MCc6JyM2Yjc1ODUnOwogICAgY3R4LmZpbGxUZXh0KCfQn9GA0L7QvNCw0YXQuDogJytzdHJpa2VzKycvJyttYXhTdHJpa2VzLCAxNCwgMzIpOwogICAgY3R4LnJlc3RvcmUoKTsKCiAgICByYWY9cmVxdWVzdEFuaW1hdGlvbkZyYW1lKGxvb3ApOwogIH0KCiAgZnVuY3Rpb24gcG9pbnRlcihlLHR5cGUpewogICAgdmFyIHJlY3Q9Y3YuZ2V0Qm91bmRpbmdDbGllbnRSZWN0KCk7CiAgICB2YXIgcD0oZS50b3VjaGVzJiZlLnRvdWNoZXNbMF0pfHxlOwogICAgdmFyIHg9cC5jbGllbnRYLXJlY3QubGVmdCwgeT1wLmNsaWVudFktcmVjdC50b3A7CiAgICBpZih0eXBlPT09J2Rvd24nfHx0eXBlPT09J21vdmUnKXsgZ2xhc3MueD14OyBnbGFzcy55PXk7IGdsYXNzLmFjdGl2ZT10cnVlOyB9CiAgICBpZih0eXBlPT09J3VwJyl7CiAgICAgIC8vINGC0LDQvyA9INC+0YHQvNC+0YLRgNC10YLRjCDQsdC70LjQttCw0LnRiNC40Lkg0L/RgNC10LTQvNC10YIg0L/QvtC0INC70YPQv9C+0LkKICAgICAgdmFyIGJlc3Q9bnVsbCxiZD1nbGFzcy5yOwogICAgICBmb3IodmFyIGk9MDtpPGl0ZW1zLmxlbmd0aDtpKyspewogICAgICAgIHZhciBpdD1pdGVtc1tpXTsgaWYoaXQuZm91bmQpIGNvbnRpbnVlOwogICAgICAgIHZhciBkPU1hdGguaHlwb3QoaXQueC14LGl0LnkteSk7CiAgICAgICAgaWYoZDxpdC5yKjEuMyAmJiBkPGJkKXsgYmQ9ZDsgYmVzdD1pdDsgfQogICAgICB9CiAgICAgIGlmKGJlc3QpeyBleGFtaW5lKGJlc3QpOyB9CiAgICAgIGdsYXNzLmFjdGl2ZT1mYWxzZTsgZ2xhc3MueD0tOTk5OyBnbGFzcy55PS05OTk7CiAgICB9CiAgfQoKICBmdW5jdGlvbiBleGFtaW5lKGl0KXsKICAgIGlmKGl0LnJlYWwpewogICAgICBpdC5mb3VuZD10cnVlOyBmb3VuZCsrOwogICAgICB0cnl7IG5hdmlnYXRvci52aWJyYXRlJiZuYXZpZ2F0b3IudmlicmF0ZSgyMCk7IH1jYXRjaChfKXt9CiAgICAgIGZsYXNoKCcjNDZkODliJyk7CiAgICAgIGlmKGZvdW5kPj1uZWVkKXsgd2luKCk7IH0KICAgIH0gZWxzZSB7CiAgICAgIGl0Lndyb25nPXRydWU7IHN0cmlrZXMrKzsKICAgICAgdHJ5eyBuYXZpZ2F0b3IudmlicmF0ZSYmbmF2aWdhdG9yLnZpYnJhdGUoWzEwLDMwLDEwXSk7IH1jYXRjaChfKXt9CiAgICAgIGZsYXNoKCcjZDg0NjQ2Jyk7CiAgICAgIHNldFRpbWVvdXQoZnVuY3Rpb24oKXsgaXQud3Jvbmc9ZmFsc2U7IH0sNDAwKTsKICAgICAgaWYoc3RyaWtlcz49bWF4U3RyaWtlcyl7IGxvc2UoKTsgfQogICAgfQogIH0KCiAgdmFyIGZsYXNoRWw9bnVsbDsKICBmdW5jdGlvbiBmbGFzaChjb2wpewogICAgaWYoIWZsYXNoRWwpIHJldHVybjsKICAgIGZsYXNoRWwuc3R5bGUuYm94U2hhZG93PSdpbnNldCAwIDAgNjBweCAnK2NvbDsKICAgIGZsYXNoRWwuc3R5bGUub3BhY2l0eT0nMSc7CiAgICBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7IGZsYXNoRWwuc3R5bGUub3BhY2l0eT0nMCc7IH0sMTgwKTsKICB9CgogIGZ1bmN0aW9uIHdpbigpewogICAgcnVubmluZz1mYWxzZTsgY2FuY2VsQW5pbWF0aW9uRnJhbWUocmFmKTsKICAgIHNldFRpbWVvdXQoZnVuY3Rpb24oKXsgb3B0cyYmb3B0cy5vbldpbiYmb3B0cy5vbldpbigpOyB9LCAzNTApOwogIH0KICBmdW5jdGlvbiBsb3NlKCl7CiAgICBydW5uaW5nPWZhbHNlOyBjYW5jZWxBbmltYXRpb25GcmFtZShyYWYpOwogICAgc2V0VGltZW91dChmdW5jdGlvbigpeyBvcHRzJiZvcHRzLm9uTG9zZSYmb3B0cy5vbkxvc2UoKTsgfSwgMzUwKTsKICB9CgogIGZ1bmN0aW9uIHN0YXJ0KGNvbnRhaW5lciwgbyl7CiAgICBvcHRzPW98fHt9OwogICAgbmVlZCA9IChvcHRzLm1pc3Npb24mJm9wdHMubWlzc2lvbi50YXJnZXQpPyBNYXRoLm1heCgyLE1hdGgubWluKDUsTWF0aC5yb3VuZChvcHRzLm1pc3Npb24udGFyZ2V0LzQpKSkgOiAzOwogICAgaWYobmVlZD41KSBuZWVkPTU7CiAgICBmb3VuZD0wOyBzdHJpa2VzPTA7IHQwPTA7CiAgICBjb250YWluZXIuaW5uZXJIVE1MPScnOwogICAgdmFyIHdyYXA9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnZGl2Jyk7CiAgICB3cmFwLnN0eWxlLmNzc1RleHQ9J3Bvc2l0aW9uOnJlbGF0aXZlO3dpZHRoOjEwMCU7aGVpZ2h0OjEwMCU7bWluLWhlaWdodDozODBweDsnOwogICAgY3Y9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnY2FudmFzJyk7CiAgICBjdi5zdHlsZS5jc3NUZXh0PSd3aWR0aDoxMDAlO2hlaWdodDoxMDAlO2Rpc3BsYXk6YmxvY2s7Ym9yZGVyLXJhZGl1czoxNHB4O3RvdWNoLWFjdGlvbjpub25lOyc7CiAgICB3cmFwLmFwcGVuZENoaWxkKGN2KTsKICAgIGZsYXNoRWw9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnZGl2Jyk7CiAgICBmbGFzaEVsLnN0eWxlLmNzc1RleHQ9J3Bvc2l0aW9uOmFic29sdXRlO2luc2V0OjA7Ym9yZGVyLXJhZGl1czoxNHB4O3BvaW50ZXItZXZlbnRzOm5vbmU7b3BhY2l0eTowO3RyYW5zaXRpb246b3BhY2l0eSAuMThzOyc7CiAgICB3cmFwLmFwcGVuZENoaWxkKGZsYXNoRWwpOwogICAgLy8g0L/QvtC00YHQutCw0LfQutCwCiAgICB2YXIgdGlwPWRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoJ2RpdicpOwogICAgdGlwLnN0eWxlLmNzc1RleHQ9J3Bvc2l0aW9uOmFic29sdXRlO2JvdHRvbTo4cHg7bGVmdDowO3JpZ2h0OjA7dGV4dC1hbGlnbjpjZW50ZXI7Zm9udC1zaXplOjEycHg7Y29sb3I6IzhhOTJhMDtwb2ludGVyLWV2ZW50czpub25lOyc7CiAgICB0aXAudGV4dENvbnRlbnQ9J9CS0LXQtNC4INC70YPQv9C+0Lkg0L/QviDRgdGG0LXQvdC1LiDQotCw0L/QvdC4INGD0LvQuNC60YMsINGH0YLQviDQvtGC0LHQu9GR0YHQutC40LLQsNC10YIg0Y/QvdGC0LDRgNGR0LwuJzsKICAgIHdyYXAuYXBwZW5kQ2hpbGQodGlwKTsKICAgIGNvbnRhaW5lci5hcHBlbmRDaGlsZCh3cmFwKTsKICAgIGN0eD1jdi5nZXRDb250ZXh0KCcyZCcpOwogICAgcmVzaXplKCk7IGxheW91dCgpOwogICAgY3YuYWRkRXZlbnRMaXN0ZW5lcigndG91Y2hzdGFydCcsZnVuY3Rpb24oZSl7ZS5wcmV2ZW50RGVmYXVsdCgpO3BvaW50ZXIoZSwnZG93bicpO30se3Bhc3NpdmU6ZmFsc2V9KTsKICAgIGN2LmFkZEV2ZW50TGlzdGVuZXIoJ3RvdWNobW92ZScsZnVuY3Rpb24oZSl7ZS5wcmV2ZW50RGVmYXVsdCgpO3BvaW50ZXIoZSwnbW92ZScpO30se3Bhc3NpdmU6ZmFsc2V9KTsKICAgIGN2LmFkZEV2ZW50TGlzdGVuZXIoJ3RvdWNoZW5kJyxmdW5jdGlvbihlKXtlLnByZXZlbnREZWZhdWx0KCk7cG9pbnRlcihlLCd1cCcpO30se3Bhc3NpdmU6ZmFsc2V9KTsKICAgIGN2LmFkZEV2ZW50TGlzdGVuZXIoJ21vdXNlZG93bicsZnVuY3Rpb24oZSl7cG9pbnRlcihlLCdkb3duJyk7fSk7CiAgICBjdi5hZGRFdmVudExpc3RlbmVyKCdtb3VzZW1vdmUnLGZ1bmN0aW9uKGUpeyBpZihnbGFzcy5hY3RpdmUpcG9pbnRlcihlLCdtb3ZlJyk7fSk7CiAgICBjdi5hZGRFdmVudExpc3RlbmVyKCdtb3VzZXVwJyxmdW5jdGlvbihlKXtwb2ludGVyKGUsJ3VwJyk7fSk7CiAgICB3aW5kb3cuYWRkRXZlbnRMaXN0ZW5lcigncmVzaXplJyxyZXNpemUpOwogICAgcnVubmluZz10cnVlOyByYWY9cmVxdWVzdEFuaW1hdGlvbkZyYW1lKGxvb3ApOwogIH0KICBmdW5jdGlvbiBzdG9wKCl7CiAgICBydW5uaW5nPWZhbHNlOyBpZihyYWYpY2FuY2VsQW5pbWF0aW9uRnJhbWUocmFmKTsKICAgIHdpbmRvdy5yZW1vdmVFdmVudExpc3RlbmVyKCdyZXNpemUnLHJlc2l6ZSk7CiAgfQoKICB3aW5kb3cuRXhhbWluZT17c3RhcnQ6c3RhcnQsc3RvcDpzdG9wfTsKfSkoKTsK" | base64 -d > src/main/resources/static/games/examine.js
node --check src/main/resources/static/games/examine.js && echo "  ✓ examine.js валиден"

echo ""; echo "══ 3/5  подключаем examine.js ═════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
if 'games/examine.js' not in txt:
    txt=txt.replace('<script src="/games/match3.js"></script>',
                    '<script src="/games/match3.js"></script>\n<script src="/games/examine.js"></script>')
    print("  + examine.js подключён")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

echo ""; echo "══ 4/5  examine как ГРАНЬ КУБА (spot → доступна) ══"
python3 - << 'PYEOF'
path="src/main/resources/static/games/cube.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# делаем грань 'spot' доступной и переименовываем под examine
old="{id:'spot',    name:'Сверка',     ico:'🔍', sub:'Детали',    available:false, c1:'#6c8fc0',c2:'#28384f'},"
new="{id:'examine',  name:'Осмотр места',ico:'🔍', sub:'Поиск улик',available:true,  c1:'#6c8fc0',c2:'#28384f'},"
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + грань 'examine' доступна на кубе")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ cube.js: %d"%n)
PYEOF

# роутер startMiniGame: examine → Examine.start
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''  // роутер мини-игр (расширяемый): пока все ведут на match3
  if(gameId==='match3' && window.Match3){
    Match3.start(vp, { mission, boosters:App.profile.boosters||0, onWin, onLose });
  } else if(window.Match3){
    Match3.start(vp, { mission, boosters:App.profile.boosters||0, onWin, onLose });
  }'''
new='''  // роутер мини-игр (расширяемый)
  if(gameId==='examine' && window.Examine){
    Examine.start(vp, { mission, onWin, onLose });
  } else if(gameId==='match3' && window.Match3){
    Match3.start(vp, { mission, boosters:App.profile.boosters||0, onWin, onLose });
  } else if(window.Match3){
    Match3.start(vp, { mission, boosters:App.profile.boosters||0, onWin, onLose });
  }'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + роутер: examine → Examine, иначе match3")
# при закрытии останавливать Examine тоже
old2='''    try{Match3&&Match3.stop();}catch(_){} try{MiniCube&&MiniCube.close();}catch(_){} };'''
new2='''    try{Examine&&Examine.stop();}catch(_){} try{Match3&&Match3.stop();}catch(_){} try{MiniCube&&MiniCube.close();}catch(_){} };'''
if old2 in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + остановка Examine при закрытии")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""; echo "══ 5/5  examine В АРКАДЫ (+ убрать 3 старые) ══════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/arcade.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# заменяем список GAMES: убираем 3 старые, добавляем examine (canvas-тип)
old='''  const GAMES = [
    { key:'DetectiveMahjong', name:'Детективный маджонг', desc:'Соединяй связанные улики', icon:'🀄', evt:'detective-mahjong-complete', opts:{ maxTime:140, maxErrors:5 } },
    { key:'TornLetterScene',  name:'Разорванное письмо',  desc:'Собери письмо из кусков',  icon:'✉️', evt:'torn-letter-complete',      opts:{} },
    { key:'CrimeBoardScene',  name:'Доска улик',          desc:'Построй цепочку связей',   icon:'🧩', evt:'crime-board-complete',     opts:{ maxTime:80 } }
  ];'''
new='''  const GAMES = [
    { key:'Examine', canvas:true, name:'Осмотр места', desc:'Найди улики на сцене', icon:'🔍', opts:{ mission:{target:12} } }
  ];'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + аркады: 3 старые убраны, +Осмотр места")

# launch(): для canvas-игр (не Phaser) запускаем через .start()
oldL='''  function launch(key){
    const g = GAMES.find(x=>x.key===key);
    if(!g) return;
    if(!window.Phaser){ alert('Phaser не загружен'); return; }
    if(!window[key]){ alert('Игра не найдена: '+key); return; }'''
newL='''  function launch(key){
    const g = GAMES.find(x=>x.key===key);
    if(!g) return;
    // canvas-игры (новые, лёгкие) — запускаем напрямую, без Phaser
    if(g.canvas){ launchCanvas(g); return; }
    if(!window.Phaser){ alert('Phaser не загружен'); return; }
    if(!window[key]){ alert('Игра не найдена: '+key); return; }'''
if oldL in txt:
    txt=txt.replace(oldL,newL,1); n+=1; print("  + ветка запуска canvas-игр")

# добавляем функцию launchCanvas
if "function launchCanvas" not in txt:
    canvasFn='''
  function launchCanvas(g){
    try{ window.Sound && Sound.tap && Sound.tap(); }catch(e){}
    if(window.BgFx && BgFx.pause) BgFx.pause();
    const ov=document.createElement('div');
    ov.id='arcade-overlay';
    ov.innerHTML='<div class="arc-bar"><button class="arc-close" id="arc-close">‹ Выход</button>'+
      '<div class="arc-title">'+g.name+'</div><div style="width:72px"></div></div>'+
      '<div class="arc-stage" id="arc-stage" style="padding:16px;display:flex;align-items:center;justify-content:center"></div>';
    document.body.appendChild(ov);
    const stage=ov.querySelector('#arc-stage');
    const host=document.createElement('div');
    host.style.cssText='width:100%;max-width:520px;height:70vh;';
    stage.appendChild(host);
    function close(){ try{window[g.key]&&window[g.key].stop&&window[g.key].stop();}catch(_){} ov.remove(); if(window.BgFx&&BgFx.resume)BgFx.resume(); }
    ov.querySelector('#arc-close').onclick=close;
    var done=function(ok){ setTimeout(close,600); };
    try{
      window[g.key].start(host, Object.assign({}, g.opts, {
        onWin:function(){ try{toast&&toast('Победа','Улики собраны','🔍');}catch(_){}; done(true); },
        onLose:function(){ try{toast&&toast('Не вышло','Попробуй снова','🔍');}catch(_){}; done(false); }
      }));
    }catch(e){ console.error('canvas game',e); close(); }
  }
'''
    # вставляем перед launch
    txt=txt.replace("  function launch(key){", canvasFn+"\n  function launch(key){",1)
    n+=1; print("  + функция launchCanvas")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ arcade.js: %d"%n)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R89 — старые игры убраны, «Осмотр места» на куб и в аркады"
echo "   git add -A && git commit -m 'R89: remove old games, add Examine to cube and arcade' && git push"
echo "═══════════════════════════════════════════════════════"
