#!/usr/bin/env bash
# СДВИГ R90 — вторая мини-игра «Слежка» (реакция) на куб и в аркады
set -e
echo "══ штамп → R90 ══"
sed -i "s/SDVIG_BUILD='R89'/SDVIG_BUILD='R90'/" src/main/resources/static/app.js
sed -i 's/>R89</>R90</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  создаём games/pursuit.js ══════════════════"
echo "Lyog4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQCiAgINCh0JTQktCY0JMgwrcg0JzQuNC90Lgt0LjQs9GA0LAgwqvQodCb0JXQltCa0JDCuyAo0LHRi9GB0YLRgNCw0Y8g0L3QsCDRgNC10LDQutGG0LjRjikKICAg0JrQvtC90YLRgNCw0LrRgjogUHVyc3VpdC5zdGFydChjb250YWluZXIse21pc3Npb24sb25XaW4sb25Mb3NlfSkgLyAuc3RvcCgpCiAgINCj0LTQtdGA0LbQuCDQv9C+0LTQvtC30YDQtdCy0LDQtdC80L7Qs9C+INCyINC/0YDQuNGG0LXQu9C1INC90LDQsdC70Y7QtNC10L3QuNGPLCDQv9C+0LrQsCDQvtC9INC/0LXRgtC70Y/QtdGCINCyINGC0L7Qu9C/0LUuCuKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkCAqLwooZnVuY3Rpb24oKXsKICB2YXIgY3YsY3R4LHJhZixydW5uaW5nPWZhbHNlLG9wdHM9bnVsbDsKICB2YXIgVz0wLEg9MCxEUFI9MTsKICB2YXIgdGFyZ2V0LGNyb3dkPVtdLGFpbT17eDowLHk6MH07CiAgdmFyIHByb2dyZXNzPTAsbmVlZD0xMDAsaGVhdD0wLGxvc3Q9MCxtYXhMb3N0PTEwMDsKICB2YXIgbGFzdFQ9MCxkdXJhdGlvbj0wLHN1cnZpdmVkPTA7CgogIGZ1bmN0aW9uIHJuZChhLGIpe3JldHVybiBhK01hdGgucmFuZG9tKCkqKGItYSk7fQoKICBmdW5jdGlvbiByZXNpemUoKXsKICAgIHZhciByPWN2LmdldEJvdW5kaW5nQ2xpZW50UmVjdCgpOwogICAgRFBSPU1hdGgubWluKHdpbmRvdy5kZXZpY2VQaXhlbFJhdGlvfHwxLDIpOwogICAgVz1yLndpZHRoO0g9ci5oZWlnaHQ7Y3Yud2lkdGg9VypEUFI7Y3YuaGVpZ2h0PUgqRFBSOwogICAgY3R4LnNldFRyYW5zZm9ybShEUFIsMCwwLERQUiwwLDApOwogIH0KCiAgZnVuY3Rpb24gc3Bhd25Dcm93ZCgpewogICAgY3Jvd2Q9W107CiAgICBmb3IodmFyIGk9MDtpPDEwO2krKyl7CiAgICAgIGNyb3dkLnB1c2goe3g6cm5kKDAsVykseTpybmQoMCxIKSx2eDpybmQoLTAuNiwwLjYpLHZ5OnJuZCgtMC42LDAuNiksCiAgICAgICAgcGg6cm5kKDAsNi4yOCksc3A6cm5kKDAuNiwxLjEpfSk7CiAgICB9CiAgfQoKICBmdW5jdGlvbiBpbml0VGFyZ2V0KCl7CiAgICB0YXJnZXQ9e3g6Vy8yLHk6SC8yLHZ4OjAsdnk6MCwKICAgICAgLy8g0L/QvtC00L7Qt9GA0LXQstCw0LXQvNGL0Lkg0L/QtdGA0LjQvtC00LjRh9C10YHQutC4INC00LXQu9Cw0LXRgiDRgNGL0LLQutC4ICjRgtC10YHRgiDRgNC10LDQutGG0LjQuCkKICAgICAgbmV4dEp1a2U6cm5kKDAuNiwxLjQpLHRqOjAsCiAgICAgIGh1ZTozMH07CiAgfQoKICBmdW5jdGlvbiBzdGVwKGR0KXsKICAgIHN1cnZpdmVkKz1kdDsKICAgIC8vINC/0L7QtNC+0LfRgNC10LLQsNC10LzRi9C5OiDQv9C70LDQstC90L7QtSDQtNCy0LjQttC10L3QuNC1ICsg0LLQvdC10LfQsNC/0L3Ri9C1INGA0YvQstC60LgKICAgIHRhcmdldC50ais9ZHQ7CiAgICBpZih0YXJnZXQudGo+PXRhcmdldC5uZXh0SnVrZSl7CiAgICAgIHRhcmdldC50aj0wOyB0YXJnZXQubmV4dEp1a2U9cm5kKDAuNSwxLjMpOwogICAgICB2YXIgYW5nPXJuZCgwLDYuMjgpLCBmb3JjZT1ybmQoMi4yLDMuNik7CiAgICAgIHRhcmdldC52eD1NYXRoLmNvcyhhbmcpKmZvcmNlOwogICAgICB0YXJnZXQudnk9TWF0aC5zaW4oYW5nKSpmb3JjZTsKICAgIH0KICAgIC8vINC70ZHQs9C60L7QtSDQv9GA0LjRgtGP0LbQtdC90LjQtSDQuiDRhtC10L3RgtGA0YMsINGH0YLQvtCx0Ysg0L3QtSDQt9Cw0LvQuNC/0LDQuyDQsiDRg9Cz0LvRgwogICAgdGFyZ2V0LnZ4Kz0oVy8yLXRhcmdldC54KSowLjAwMDg7CiAgICB0YXJnZXQudnkrPShILzItdGFyZ2V0LnkpKjAuMDAwODsKICAgIHRhcmdldC52eCo9MC45NjsgdGFyZ2V0LnZ5Kj0wLjk2OwogICAgdGFyZ2V0LngrPXRhcmdldC52eCpkdCo2MDsgdGFyZ2V0LnkrPXRhcmdldC52eSpkdCo2MDsKICAgIHZhciBwYWQ9MzA7CiAgICBpZih0YXJnZXQueDxwYWQpe3RhcmdldC54PXBhZDt0YXJnZXQudng9TWF0aC5hYnModGFyZ2V0LnZ4KTt9CiAgICBpZih0YXJnZXQueD5XLXBhZCl7dGFyZ2V0Lng9Vy1wYWQ7dGFyZ2V0LnZ4PS1NYXRoLmFicyh0YXJnZXQudngpO30KICAgIGlmKHRhcmdldC55PHBhZCl7dGFyZ2V0Lnk9cGFkO3RhcmdldC52eT1NYXRoLmFicyh0YXJnZXQudnkpO30KICAgIGlmKHRhcmdldC55PkgtcGFkKXt0YXJnZXQueT1ILXBhZDt0YXJnZXQudnk9LU1hdGguYWJzKHRhcmdldC52eSk7fQogICAgLy8g0YLQvtC70L/QsAogICAgZm9yKHZhciBpPTA7aTxjcm93ZC5sZW5ndGg7aSsrKXsKICAgICAgdmFyIGM9Y3Jvd2RbaV07IGMucGgrPWR0KmMuc3A7CiAgICAgIGMueCs9Yy52eCpkdCo2MDsgYy55Kz1jLnZ5KmR0KjYwOwogICAgICBpZihjLng8MHx8Yy54PlcpYy52eCo9LTE7IGlmKGMueTwwfHxjLnk+SCljLnZ5Kj0tMTsKICAgIH0KICAgIC8vINCyINC/0YDQuNGG0LXQu9C1INC70Lgg0YbQtdC70YwKICAgIHZhciBkPU1hdGguaHlwb3QodGFyZ2V0LngtYWltLngsdGFyZ2V0LnktYWltLnkpOwogICAgdmFyIGFpbVI9NDY7CiAgICBpZihkPGFpbVIpewogICAgICBwcm9ncmVzcys9ZHQqMjI7ICAgICAgLy8g0LTQtdGA0LbQuNC8IOKAlCDRgNCw0YHRgtGR0YIg0L/RgNC+0LPRgNC10YHRgQogICAgICBoZWF0PU1hdGgubWluKDEsaGVhdCtkdCoyKTsKICAgICAgbG9zdD1NYXRoLm1heCgwLGxvc3QtZHQqMzApOwogICAgfSBlbHNlIHsKICAgICAgbG9zdCs9ZHQqMjg7ICAgICAgICAgIC8vINGD0L/Rg9GB0YLQuNC70Lgg4oCUINGA0LDRgdGC0ZHRgiDQv9C+0YLQtdGA0Y8KICAgICAgaGVhdD1NYXRoLm1heCgwLGhlYXQtZHQqMS41KTsKICAgIH0KICAgIGlmKHByb2dyZXNzPj1uZWVkKXsgd2luKCk7IH0KICAgIGlmKGxvc3Q+PW1heExvc3QpeyBsb3NlKCk7IH0KICB9CgogIGZ1bmN0aW9uIGRyYXdGaWd1cmUoeCx5LGNvbCxyLGZpbGxlZCl7CiAgICBjdHguc2F2ZSgpO2N0eC50cmFuc2xhdGUoeCx5KTsKICAgIGN0eC5zdHJva2VTdHlsZT1jb2w7Y3R4LmZpbGxTdHlsZT1jb2w7Y3R4LmxpbmVXaWR0aD0yLjQ7CiAgICAvLyDQs9C+0LvQvtCy0LAKICAgIGN0eC5iZWdpblBhdGgoKTtjdHguYXJjKDAsLXIqMC43LHIqMC4zMiwwLDYuMjgpO2ZpbGxlZD9jdHguZmlsbCgpOmN0eC5zdHJva2UoKTsKICAgIC8vINC/0LvQtdGH0Lgv0YLQtdC70L4gKNGB0LjQu9GD0Y3RgiDQsiDRiNC70Y/Qv9C1IOKAlCDQvdGD0LDRgCkKICAgIGN0eC5iZWdpblBhdGgoKTsKICAgIGN0eC5tb3ZlVG8oLXIqMC41LHIqMC44KTtjdHgucXVhZHJhdGljQ3VydmVUbygwLC1yKjAuMixyKjAuNSxyKjAuOCk7CiAgICBmaWxsZWQ/Y3R4LmZpbGwoKTpjdHguc3Ryb2tlKCk7CiAgICAvLyDRiNC70Y/Qv9CwCiAgICBjdHguYmVnaW5QYXRoKCk7Y3R4Lm1vdmVUbygtciowLjQ1LC1yKjAuOSk7Y3R4LmxpbmVUbyhyKjAuNDUsLXIqMC45KTtjdHguc3Ryb2tlKCk7CiAgICBjdHgucmVzdG9yZSgpOwogIH0KCiAgZnVuY3Rpb24gbG9vcCh0cyl7CiAgICBpZighcnVubmluZylyZXR1cm47CiAgICBpZighbGFzdFQpbGFzdFQ9dHM7CiAgICB2YXIgZHQ9TWF0aC5taW4oMC4wNSwodHMtbGFzdFQpLzEwMDApOyBsYXN0VD10czsKICAgIHN0ZXAoZHQpOwoKICAgIGN0eC5jbGVhclJlY3QoMCwwLFcsSCk7CiAgICB2YXIgZz1jdHguY3JlYXRlTGluZWFyR3JhZGllbnQoMCwwLDAsSCk7CiAgICBnLmFkZENvbG9yU3RvcCgwLCdyZ2JhKDE0LDE0LDIwLDAuOTYpJyk7Zy5hZGRDb2xvclN0b3AoMSwncmdiYSg4LDgsMTEsMC45OSknKTsKICAgIGN0eC5maWxsU3R5bGU9ZztjdHguZmlsbFJlY3QoMCwwLFcsSCk7CgogICAgLy8g0YLQvtC70L/QsCAo0YHQtdGA0YvQtSDRgdC40LvRg9GN0YLRiy3Qv9GA0LjQvNCw0L3QutC4KQogICAgZm9yKHZhciBpPTA7aTxjcm93ZC5sZW5ndGg7aSsrKXsgZHJhd0ZpZ3VyZShjcm93ZFtpXS54LGNyb3dkW2ldLnksJ3JnYmEoMTIwLDEyMCwxMzUsMC41KScsMTgsZmFsc2UpOyB9CiAgICAvLyDRhtC10LvRjCAo0L/QvtC00L7Qt9GA0LXQstCw0LXQvNGL0Lkg4oCUINCy0YvQtNC10LvQtdC9KQogICAgdmFyIHRjb2wgPSBoZWF0PjAuNT8nI2ZmY2Y2Yic6JyNlMGEwNjAnOwogICAgZHJhd0ZpZ3VyZSh0YXJnZXQueCx0YXJnZXQueSx0Y29sLDIyLGZhbHNlKTsKICAgIC8vINC80LXRgtC60LAg0L3QsNC0INGG0LXQu9GM0Y4KICAgIGN0eC5zYXZlKCk7Y3R4Lmdsb2JhbEFscGhhPTAuNSswLjQqTWF0aC5zaW4oc3Vydml2ZWQqNSk7CiAgICBjdHguZmlsbFN0eWxlPXRjb2w7Y3R4LmJlZ2luUGF0aCgpOwogICAgY3R4Lm1vdmVUbyh0YXJnZXQueCx0YXJnZXQueS0zNCk7Y3R4LmxpbmVUbyh0YXJnZXQueC02LHRhcmdldC55LTQ0KTtjdHgubGluZVRvKHRhcmdldC54KzYsdGFyZ2V0LnktNDQpO2N0eC5jbG9zZVBhdGgoKTtjdHguZmlsbCgpOwogICAgY3R4LnJlc3RvcmUoKTsKCiAgICAvLyDQv9GA0LjRhtC10Lsg0L3QsNCx0LvRjtC00LXQvdC40Y8KICAgIGN0eC5zYXZlKCk7CiAgICBjdHguc3Ryb2tlU3R5bGU9J3JnYmEoMjAwLDE2MCw5MCwwLjU1KSc7Y3R4LmxpbmVXaWR0aD0yOwogICAgY3R4LmJlZ2luUGF0aCgpO2N0eC5hcmMoYWltLngsYWltLnksNDYsMCw2LjI4KTtjdHguc3Ryb2tlKCk7CiAgICBjdHguYmVnaW5QYXRoKCk7Y3R4Lm1vdmVUbyhhaW0ueC01NixhaW0ueSk7Y3R4LmxpbmVUbyhhaW0ueC0zNixhaW0ueSk7CiAgICBjdHgubW92ZVRvKGFpbS54KzM2LGFpbS55KTtjdHgubGluZVRvKGFpbS54KzU2LGFpbS55KTsKICAgIGN0eC5tb3ZlVG8oYWltLngsYWltLnktNTYpO2N0eC5saW5lVG8oYWltLngsYWltLnktMzYpOwogICAgY3R4Lm1vdmVUbyhhaW0ueCxhaW0ueSszNik7Y3R4LmxpbmVUbyhhaW0ueCxhaW0ueSs1Nik7Y3R4LnN0cm9rZSgpOwogICAgY3R4LnJlc3RvcmUoKTsKCiAgICAvLyBIVUQ6INC/0YDQvtCz0YDQtdGB0YEg0YHQu9C10LbQutC4ICsg0L/QvtC70L7RgdCwINC/0L7RgtC10YDQuAogICAgY3R4LnNhdmUoKTsKICAgIGN0eC5maWxsU3R5bGU9J3JnYmEoMjU1LDI1NSwyNTUsMC4wOCknO2N0eC5maWxsUmVjdCgxNCwxNCxXLTI4LDcpOwogICAgY3R4LmZpbGxTdHlsZT0nIzQ2ZDg5Yic7Y3R4LmZpbGxSZWN0KDE0LDE0LChXLTI4KSoocHJvZ3Jlc3MvbmVlZCksNyk7CiAgICBjdHguZmlsbFN0eWxlPSdyZ2JhKDI1NSwyNTUsMjU1LDAuMDgpJztjdHguZmlsbFJlY3QoMTQsMjYsVy0yOCw1KTsKICAgIGN0eC5maWxsU3R5bGU9JyNkODQ2NDYnO2N0eC5maWxsUmVjdCgxNCwyNiwoVy0yOCkqKGxvc3QvbWF4TG9zdCksNSk7CiAgICBjdHguZm9udD0nNjAwIDEycHggSW50ZXIsc2Fucy1zZXJpZic7Y3R4LmZpbGxTdHlsZT0nIzhhOTJhMCc7Y3R4LnRleHRCYXNlbGluZT0ndG9wJzsKICAgIGN0eC5maWxsVGV4dCgn0KHQu9C10LbQutCwOiAnK01hdGgucm91bmQocHJvZ3Jlc3MpKyclJywxNCwzOCk7CiAgICBjdHgucmVzdG9yZSgpOwoKICAgIHJhZj1yZXF1ZXN0QW5pbWF0aW9uRnJhbWUobG9vcCk7CiAgfQoKICBmdW5jdGlvbiBtb3ZlKGUpewogICAgdmFyIHI9Y3YuZ2V0Qm91bmRpbmdDbGllbnRSZWN0KCk7CiAgICB2YXIgcD0oZS50b3VjaGVzJiZlLnRvdWNoZXNbMF0pfHxlOwogICAgYWltLng9cC5jbGllbnRYLXIubGVmdDsgYWltLnk9cC5jbGllbnRZLXIudG9wOwogIH0KCiAgZnVuY3Rpb24gd2luKCl7cnVubmluZz1mYWxzZTtjYW5jZWxBbmltYXRpb25GcmFtZShyYWYpO3NldFRpbWVvdXQoZnVuY3Rpb24oKXtvcHRzJiZvcHRzLm9uV2luJiZvcHRzLm9uV2luKCk7fSwzMDApO30KICBmdW5jdGlvbiBsb3NlKCl7cnVubmluZz1mYWxzZTtjYW5jZWxBbmltYXRpb25GcmFtZShyYWYpO3NldFRpbWVvdXQoZnVuY3Rpb24oKXtvcHRzJiZvcHRzLm9uTG9zZSYmb3B0cy5vbkxvc2UoKTt9LDMwMCk7fQoKICBmdW5jdGlvbiBzdGFydChjb250YWluZXIsbyl7CiAgICBvcHRzPW98fHt9OwogICAgbmVlZD0xMDA7IHByb2dyZXNzPTA7IGxvc3Q9MDsgaGVhdD0wOyBsYXN0VD0wOyBzdXJ2aXZlZD0wOwogICAgLy8g0YHQu9C+0LbQvdC+0YHRgtGMINC+0YIg0LzQuNGB0YHQuNC4OiDQsdC+0LvRjNGI0LUgdGFyZ2V0IOKGkiDQstGL0YjQtSBuZWVkCiAgICBpZihvcHRzLm1pc3Npb24mJm9wdHMubWlzc2lvbi50YXJnZXQpeyBuZWVkPTgwK01hdGgubWluKDYwLG9wdHMubWlzc2lvbi50YXJnZXQqMik7IH0KICAgIGNvbnRhaW5lci5pbm5lckhUTUw9Jyc7CiAgICB2YXIgd3JhcD1kb2N1bWVudC5jcmVhdGVFbGVtZW50KCdkaXYnKTsKICAgIHdyYXAuc3R5bGUuY3NzVGV4dD0ncG9zaXRpb246cmVsYXRpdmU7d2lkdGg6MTAwJTtoZWlnaHQ6MTAwJTttaW4taGVpZ2h0OjM4MHB4Oyc7CiAgICBjdj1kb2N1bWVudC5jcmVhdGVFbGVtZW50KCdjYW52YXMnKTsKICAgIGN2LnN0eWxlLmNzc1RleHQ9J3dpZHRoOjEwMCU7aGVpZ2h0OjEwMCU7ZGlzcGxheTpibG9jaztib3JkZXItcmFkaXVzOjE0cHg7dG91Y2gtYWN0aW9uOm5vbmU7JzsKICAgIHdyYXAuYXBwZW5kQ2hpbGQoY3YpOwogICAgdmFyIHRpcD1kb2N1bWVudC5jcmVhdGVFbGVtZW50KCdkaXYnKTsKICAgIHRpcC5zdHlsZS5jc3NUZXh0PSdwb3NpdGlvbjphYnNvbHV0ZTtib3R0b206OHB4O2xlZnQ6MDtyaWdodDowO3RleHQtYWxpZ246Y2VudGVyO2ZvbnQtc2l6ZToxMnB4O2NvbG9yOiM4YTkyYTA7cG9pbnRlci1ldmVudHM6bm9uZTsnOwogICAgdGlwLnRleHRDb250ZW50PSfQktC10LTQuCDQv9GA0LjRhtC10LvQvtC8INC30LAg0L/QvtC00L7Qt9GA0LXQstCw0LXQvNGL0LwuINCd0LUg0YPQv9GD0YHRgtC4IOKAlCDQvtC9INC/0LXRgtC70Y/QtdGCINCyINGC0L7Qu9C/0LUuJzsKICAgIHdyYXAuYXBwZW5kQ2hpbGQodGlwKTsKICAgIGNvbnRhaW5lci5hcHBlbmRDaGlsZCh3cmFwKTsKICAgIGN0eD1jdi5nZXRDb250ZXh0KCcyZCcpOwogICAgcmVzaXplKCk7YWltLng9Vy8yO2FpbS55PUgvMjtzcGF3bkNyb3dkKCk7aW5pdFRhcmdldCgpOwogICAgY3YuYWRkRXZlbnRMaXN0ZW5lcigndG91Y2hzdGFydCcsZnVuY3Rpb24oZSl7ZS5wcmV2ZW50RGVmYXVsdCgpO21vdmUoZSk7fSx7cGFzc2l2ZTpmYWxzZX0pOwogICAgY3YuYWRkRXZlbnRMaXN0ZW5lcigndG91Y2htb3ZlJyxmdW5jdGlvbihlKXtlLnByZXZlbnREZWZhdWx0KCk7bW92ZShlKTt9LHtwYXNzaXZlOmZhbHNlfSk7CiAgICBjdi5hZGRFdmVudExpc3RlbmVyKCdtb3VzZW1vdmUnLG1vdmUpOwogICAgd2luZG93LmFkZEV2ZW50TGlzdGVuZXIoJ3Jlc2l6ZScscmVzaXplKTsKICAgIHJ1bm5pbmc9dHJ1ZTtyYWY9cmVxdWVzdEFuaW1hdGlvbkZyYW1lKGxvb3ApOwogIH0KICBmdW5jdGlvbiBzdG9wKCl7cnVubmluZz1mYWxzZTtpZihyYWYpY2FuY2VsQW5pbWF0aW9uRnJhbWUocmFmKTt3aW5kb3cucmVtb3ZlRXZlbnRMaXN0ZW5lcigncmVzaXplJyxyZXNpemUpO30KCiAgd2luZG93LlB1cnN1aXQ9e3N0YXJ0OnN0YXJ0LHN0b3A6c3RvcH07Cn0pKCk7Cg==" | base64 -d > src/main/resources/static/games/pursuit.js
node --check src/main/resources/static/games/pursuit.js && echo "  ✓ pursuit.js валиден"

echo ""; echo "══ 2/4  подключаем pursuit.js ═════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
if 'games/pursuit.js' not in txt:
    txt=txt.replace('<script src="/games/examine.js"></script>',
                    '<script src="/games/examine.js"></script>\n<script src="/games/pursuit.js"></script>')
    print("  + pursuit.js подключён")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

echo ""; echo "══ 3/4  грань куба wiretap → Слежка ═══════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/cube.js"
with open(path,encoding="utf-8") as f: txt=f.read()
old="{id:'wiretap', name:'Перехват',   ico:'📻', sub:'Частота',   available:false, c1:'#5ab0a0',c2:'#1d4a43'},"
new="{id:'pursuit', name:'Слежка',     ico:'👁', sub:'Не упусти', available:true,  c1:'#5ab0a0',c2:'#1d4a43'},"
if old in txt:
    txt=txt.replace(old,new,1); print("  + грань 'pursuit' на кубе")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

# роутер
python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''  if(gameId==='examine' && window.Examine){
    Examine.start(vp, { mission, onWin, onLose });
  } else if(gameId==='match3' && window.Match3){'''
new='''  if(gameId==='examine' && window.Examine){
    Examine.start(vp, { mission, onWin, onLose });
  } else if(gameId==='pursuit' && window.Pursuit){
    Pursuit.start(vp, { mission, onWin, onLose });
  } else if(gameId==='match3' && window.Match3){'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + роутер: pursuit → Pursuit")
old2='''    try{Examine&&Examine.stop();}catch(_){} try{Match3&&Match3.stop();}catch(_){}'''
new2='''    try{Examine&&Examine.stop();}catch(_){} try{Pursuit&&Pursuit.stop();}catch(_){} try{Match3&&Match3.stop();}catch(_){}'''
if old2 in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + остановка Pursuit")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""; echo "══ 4/4  Слежка в аркады ═══════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/arcade.js"
with open(path,encoding="utf-8") as f: txt=f.read()
old='''  const GAMES = [
    { key:'Examine', canvas:true, name:'Осмотр места', desc:'Найди улики на сцене', icon:'🔍', opts:{ mission:{target:12} } }
  ];'''
new='''  const GAMES = [
    { key:'Examine', canvas:true, name:'Осмотр места', desc:'Найди улики на сцене', icon:'🔍', opts:{ mission:{target:12} } },
    { key:'Pursuit', canvas:true, name:'Слежка', desc:'Не упусти подозреваемого', icon:'👁', opts:{ mission:{target:20} } }
  ];'''
if old in txt:
    txt=txt.replace(old,new,1); print("  + Слежка в аркадах")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R90 — «Слежка» (реакция) на куб и в аркады"
echo "   git add -A && git commit -m 'R90: Pursuit reaction mini-game' && git push"
echo "═══════════════════════════════════════════════════════"
