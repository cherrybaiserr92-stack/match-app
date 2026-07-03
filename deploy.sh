#!/usr/bin/env bash
# СДВИГ R102 — карточка-досье на canvas (текст впечатан в бумагу) + свайп
set -e
echo "══ штамп → R102 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R102'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R102</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 0/5  проверка арта в img/cards/ ════════════════"
if [ -f img/cards/folder-v.png ]; then
  echo "  ✓ арт карточек на месте"
else
  echo "  ⚠ ВНИМАНИЕ: положи арт в img/cards/ (из арт-карточек.zip)!"
  echo "    folder-v.png, folder-h.png, sticker.png"
  mkdir -p img/cards
fi

echo ""; echo "══ 1/5  cardgen.js (генератор canvas-карты) ═══════"
echo "Lyog4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQCiAgINCh0JTQktCY0JMgwrcg0JPQtdC90LXRgNCw0YLQvtGAINC60LDRgNGC0L7Rh9C60Lgt0LTQvtGB0YzQtSAoY2FudmFzLCDRgtC10LrRgdGCINCy0L/QtdGH0LDRgtCw0L0g0LIg0LHRg9C80LDQs9GDKQogICBDYXJkR2VuLnJlbmRlcihvcHRzKSDihpIgPGNhbnZhcz4g0YEg0LTQvtGB0YzQtSArINCw0LLRgtC+LdCy0L/QuNGB0LDQvdC90YvQvCDRgtC10LrRgdGC0L7QvArilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZAgKi8KKGZ1bmN0aW9uKCl7CiAgdmFyIEFSVD17fTsgICAgICAgICAgICAgICAgIC8vINC60Y3RiCDQt9Cw0LPRgNGD0LbQtdC90L3QvtCz0L4g0LDRgNGC0LAKICB2YXIgUkVBRFk9ZmFsc2UsIGxvYWRpbmdQPW51bGw7CiAgdmFyIEJBU0U9ewogICAgdjonL2ltZy9jYXJkcy9mb2xkZXItdi5wbmcnLCAgIC8vINCy0LXRgNGC0LjQutCw0LvRjNC90L7QtSAo0YEg0L/QvtC70LDRgNC+0LjQtNC+0LwpCiAgICBoOicvaW1nL2NhcmRzL2ZvbGRlci1oLnBuZycsICAgLy8g0LPQvtGA0LjQt9C+0L3RgtCw0LvRjNC90L7QtQogICAgc3RpY2tlcjonL2ltZy9jYXJkcy9zdGlja2VyLnBuZycKICB9OwoKICBmdW5jdGlvbiBsb2FkSW1nKHNyYyl7CiAgICByZXR1cm4gbmV3IFByb21pc2UoZnVuY3Rpb24ocmVzLHJlail7CiAgICAgIHZhciBpPW5ldyBJbWFnZSgpOyBpLm9ubG9hZD1mdW5jdGlvbigpe3JlcyhpKTt9OyBpLm9uZXJyb3I9cmVqOyBpLnNyYz1zcmM7CiAgICB9KTsKICB9CiAgZnVuY3Rpb24gcHJlbG9hZCgpewogICAgaWYobG9hZGluZ1ApIHJldHVybiBsb2FkaW5nUDsKICAgIGxvYWRpbmdQPVByb21pc2UuYWxsKFsKICAgICAgbG9hZEltZyhCQVNFLnYpLnRoZW4oZnVuY3Rpb24oaSl7QVJULnY9aTt9KS5jYXRjaChmdW5jdGlvbigpe30pLAogICAgICBsb2FkSW1nKEJBU0UuaCkudGhlbihmdW5jdGlvbihpKXtBUlQuaD1pO30pLmNhdGNoKGZ1bmN0aW9uKCl7fSksCiAgICAgIGxvYWRJbWcoQkFTRS5zdGlja2VyKS50aGVuKGZ1bmN0aW9uKGkpe0FSVC5zdGlja2VyPWk7fSkuY2F0Y2goZnVuY3Rpb24oKXt9KSwKICAgICAgKGRvY3VtZW50LmZvbnRzJiZkb2N1bWVudC5mb250cy5yZWFkeSl8fFByb21pc2UucmVzb2x2ZSgpCiAgICBdKS50aGVuKGZ1bmN0aW9uKCl7UkVBRFk9dHJ1ZTt9KTsKICAgIHJldHVybiBsb2FkaW5nUDsKICB9CgogIC8vINC/0LXRgNC10L3QvtGBINC/0L4g0YHQu9C+0LLQsNC8INGBINCw0LLRgtC+LdC/0L7QtNCx0L7RgNC+0Lwg0YDQsNC30LzQtdGA0LAg0L/QvtC0INC60L7RgNC+0LHQutGDCiAgZnVuY3Rpb24gZml0VGV4dChjdHgsIHRleHQsIGJveFcsIGJveEgsIHN0YXJ0UHgsIG1pblB4LCBmYW1pbHksIHdlaWdodCl7CiAgICBmb3IodmFyIHNpemU9c3RhcnRQeDsgc2l6ZT49bWluUHg7IHNpemUtPTEpewogICAgICBjdHguZm9udD0od2VpZ2h0fHwnJykrJyAnK3NpemUrJ3B4ICcrZmFtaWx5OwogICAgICB2YXIgd29yZHM9KHRleHR8fCcnKS5zcGxpdCgvXHMrLyksIGxpbmVzPVtdLCBjdXI9Jyc7CiAgICAgIGZvcih2YXIgaT0wO2k8d29yZHMubGVuZ3RoO2krKyl7CiAgICAgICAgdmFyIHQ9KGN1cj9jdXIrJyAnOicnKSt3b3Jkc1tpXTsKICAgICAgICBpZihjdHgubWVhc3VyZVRleHQodCkud2lkdGg8PWJveFcpIGN1cj10OwogICAgICAgIGVsc2UgeyBpZihjdXIpbGluZXMucHVzaChjdXIpOyBjdXI9d29yZHNbaV07IH0KICAgICAgfQogICAgICBpZihjdXIpbGluZXMucHVzaChjdXIpOwogICAgICB2YXIgbGg9c2l6ZSoxLjM7CiAgICAgIGlmKGxpbmVzLmxlbmd0aCpsaDw9Ym94SCkgcmV0dXJuIHtzaXplOnNpemUsbGluZXM6bGluZXMsbGg6bGh9OwogICAgfQogICAgLy8g0LzQuNC90LjQvNGD0Lwg4oCUINCy0LXRgNC90ZHQvCDQutCw0Log0LXRgdGC0YwKICAgIGN0eC5mb250PSh3ZWlnaHR8fCcnKSsnICcrbWluUHgrJ3B4ICcrZmFtaWx5OwogICAgdmFyIHcyPSh0ZXh0fHwnJykuc3BsaXQoL1xzKy8pLCBsMj1bXSwgYzI9Jyc7CiAgICBmb3IodmFyIGo9MDtqPHcyLmxlbmd0aDtqKyspe3ZhciB0dD0oYzI/YzIrJyAnOicnKSt3MltqXTsKICAgICAgaWYoY3R4Lm1lYXN1cmVUZXh0KHR0KS53aWR0aDw9Ym94VyljMj10dDsgZWxzZXtpZihjMilsMi5wdXNoKGMyKTtjMj13MltqXTt9fQogICAgaWYoYzIpbDIucHVzaChjMik7CiAgICByZXR1cm4ge3NpemU6bWluUHgsbGluZXM6bDIsbGg6bWluUHgqMS4zfTsKICB9CgogIGZ1bmN0aW9uIGRyYXdMaW5lcyhjdHgsIGZpdCwgeCwgeSwgY29sb3IpewogICAgY3R4LmZpbGxTdHlsZT1jb2xvcjsKICAgIGZvcih2YXIgaT0wO2k8Zml0LmxpbmVzLmxlbmd0aDtpKyspewogICAgICBjdHguZmlsbFRleHQoZml0LmxpbmVzW2ldLCB4LCB5K2kqZml0LmxoKTsKICAgIH0KICAgIHJldHVybiB5K2ZpdC5saW5lcy5sZW5ndGgqZml0LmxoOwogIH0KCiAgLyogb3B0czoge29yaWVudDondid8J2gnLCBjYXNlTGFiZWwsIGJhZGdlLCBzcGVha2VyLCB0aXRsZSwgYm9keSwgcG9ydHJhaXQoSW1hZ2V8bnVsbCl9ICovCiAgZnVuY3Rpb24gcmVuZGVyKG9wdHMpewogICAgb3B0cz1vcHRzfHx7fTsKICAgIHZhciBvcmllbnQgPSBvcHRzLm9yaWVudD09PSdoJyA/ICdoJzondic7CiAgICB2YXIgYXJ0ID0gQVJUW29yaWVudF07CiAgICB2YXIgRFBSID0gTWF0aC5taW4od2luZG93LmRldmljZVBpeGVsUmF0aW98fDEsIDIuNSk7CiAgICAvLyDQu9C+0LPQuNGH0LXRgdC60LjQuSDRgNCw0LfQvNC10YAg0LrQsNGA0YLRiyDQv9C+INCw0YDRgtGDCiAgICB2YXIgYmFzZVcgPSBhcnQ/IGFydC53aWR0aCA6IChvcmllbnQ9PT0ndic/NzE3OjgyMCk7CiAgICB2YXIgYmFzZUggPSBhcnQ/IGFydC5oZWlnaHQgOiAob3JpZW50PT09J3YnPzk2MDo0NDcpOwogICAgLy8g0LzQsNGB0YjRgtCw0LEg0L/QvtC0INGN0LrRgNCw0L0gKNGI0LjRgNC40L3QsCDQutCw0YDRgtGLIH4gOTB2dywg0L3QviDRgNC40YHRg9C10Lwg0LIg0YDQsNC30YDQtdGI0LXQvdC40Lgg0LDRgNGC0LAqRFBSKQogICAgdmFyIGN2PWRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoJ2NhbnZhcycpOwogICAgY3Yud2lkdGg9YmFzZVcqRFBSOyBjdi5oZWlnaHQ9YmFzZUgqRFBSOwogICAgY3Yuc3R5bGUud2lkdGg9JzEwMCUnOyBjdi5zdHlsZS5oZWlnaHQ9J2F1dG8nOyBjdi5zdHlsZS5kaXNwbGF5PSdibG9jayc7CiAgICB2YXIgY3R4PWN2LmdldENvbnRleHQoJzJkJyk7CiAgICBjdHguc2NhbGUoRFBSLERQUik7CiAgICBjdHgudGV4dEJhc2VsaW5lPSd0b3AnOwoKICAgIC8vINC/0L7QtNC70L7QttC60LAg0LTQvtGB0YzQtQogICAgaWYoYXJ0KSBjdHguZHJhd0ltYWdlKGFydCwwLDAsYmFzZVcsYmFzZUgpOwoKICAgIHZhciBXPWJhc2VXLEg9YmFzZUg7CiAgICB2YXIgSU5LPScjMjQxODExJywgSU5LMj0nIzJmMjMxOCcsIFNFQUw9JyM4ZTI0MzQnLCBMQUJFTD0nIzVhM2QyZSc7CiAgICB2YXIgU0VSSUY9IidQbGF5ZmFpciBEaXNwbGF5JywgR2VvcmdpYSwgc2VyaWYiOwogICAgdmFyIE1PTk89IidTcGVjaWFsIEVsaXRlJywgJ0NvdXJpZXIgTmV3JywgbW9ub3NwYWNlIjsKICAgIHZhciBCT0RZPSInUFQgU2VyaWYnLCBHZW9yZ2lhLCBzZXJpZiI7CgogICAgaWYob3JpZW50PT09J3YnKXsKICAgICAgLy8g0LfQvtC90Ysg0LLQtdGA0YLQuNC60LDQu9GM0L3QvtCz0L4gKNCyINC00L7Qu9GP0YUpOiDQv9C+0LvQsNGA0L7QuNC0IFg1Ni04NiBZMTEtNDAsINC/0LXRh9Cw0YLRjCB+WDYyLTgyIFk2OC04NgogICAgICAvLyDRj9GA0LvRi9C6CiAgICAgIGN0eC5mb250PSc0MDAgJysoVyowLjAyOCkrJ3B4ICcrTU9OTzsKICAgICAgY3R4LmZpbGxTdHlsZT1MQUJFTDsgY3R4Lmdsb2JhbEFscGhhPS44OwogICAgICBjdHguZmlsbFRleHQob3B0cy5jYXNlTGFiZWx8fCfQlNCV0JvQnicsIFcqMC4yMSwgSCowLjE1KTsKICAgICAgY3R4Lmdsb2JhbEFscGhhPTE7CiAgICAgIC8vINC30LDQs9C+0LvQvtCy0L7QuiDigJQg0LvQtdCy0LXQtSDQv9C+0LvQsNGA0L7QuNC00LAgKNGI0LjRgNC40L3QsCB+MzQlKQogICAgICB2YXIgdGY9Zml0VGV4dChjdHgsIG9wdHMudGl0bGV8fCcnLCBXKjAuMzMsIEgqMC4xNywgVyowLjA4NSwgVyowLjA1LCBTRVJJRiwgJzkwMCcpOwogICAgICBkcmF3TGluZXMoY3R4LCB0ZiwgVyowLjIxLCBIKjAuMTg1LCAnIzFjMTMwYycpOwogICAgICAvLyDQv9C+0LTQv9C40YHRjAogICAgICBjdHguZm9udD0nNDAwICcrKFcqMC4wMjgpKydweCAnK01PTk87CiAgICAgIGN0eC5maWxsU3R5bGU9U0VBTDsKICAgICAgY3R4LmZpbGxUZXh0KChvcHRzLmJhZGdlfHwn0KDQkNCX0JLQmNCb0JrQkCcpKyhvcHRzLnNwZWFrZXI/JyDCtyAnK29wdHMuc3BlYWtlci50b1VwcGVyQ2FzZSgpOicnKSwgVyowLjIxLCBIKjAuNDA1KTsKICAgICAgLy8g0YLQtdC70L4g4oCUINCy0YHRjyDRiNC40YDQuNC90LAg0LHRg9C80LDQs9C4LCDQstGL0YjQtSDQv9C10YfQsNGC0LggKFkg0LTQviB+NjQlKQogICAgICB2YXIgYmY9Zml0VGV4dChjdHgsIG9wdHMuYm9keXx8JycsIFcqMC42MCwgSCowLjIwLCBXKjAuMDUyLCBXKjAuMDMyLCBCT0RZLCAnNDAwJyk7CiAgICAgIGRyYXdMaW5lcyhjdHgsIGJmLCBXKjAuMjEsIEgqMC40NiwgSU5LMik7CiAgICAgIC8vINC/0L7RgNGC0YDQtdGCINCyINC/0L7Qu9Cw0YDQvtC40LQKICAgICAgaWYob3B0cy5wb3J0cmFpdCl7CiAgICAgICAgdmFyIHB4PVcqMC41ODUsIHB5PUgqMC4xMzUsIHB3PVcqMC4yNTUsIHBoPUgqMC4yMzU7CiAgICAgICAgY3R4LnNhdmUoKTsKICAgICAgICBjdHguYmVnaW5QYXRoKCk7IGN0eC5yZWN0KHB4LHB5LHB3LHBoKTsgY3R4LmNsaXAoKTsKICAgICAgICAvLyDQstC/0LjRgdCw0YLRjCDQv9C+0YDRgtGA0LXRgiDQv9C+INGG0LXQvdGC0YDRgwogICAgICAgIHZhciBpcj1vcHRzLnBvcnRyYWl0LndpZHRoL29wdHMucG9ydHJhaXQuaGVpZ2h0LCBicj1wdy9waCwgZHcsZGgsZHgsZHk7CiAgICAgICAgaWYoaXI+YnIpe2RoPXBoO2R3PXBoKmlyO2R4PXB4LShkdy1wdykvMjtkeT1weTt9CiAgICAgICAgZWxzZXtkdz1wdztkaD1wdy9pcjtkeD1weDtkeT1weS0oZGgtcGgpLzI7fQogICAgICAgIGN0eC5nbG9iYWxBbHBoYT0uOTI7CiAgICAgICAgY3R4LmRyYXdJbWFnZShvcHRzLnBvcnRyYWl0LGR4LGR5LGR3LGRoKTsKICAgICAgICAvLyDQu9GR0LPQutCw0Y8g0YHQtdC/0LjRjy3QstGD0LDQu9GMCiAgICAgICAgY3R4Lmdsb2JhbEFscGhhPS4xODsgY3R4LmZpbGxTdHlsZT0nIzNhMmExYSc7IGN0eC5maWxsUmVjdChweCxweSxwdyxwaCk7CiAgICAgICAgY3R4LnJlc3RvcmUoKTsKICAgICAgfQogICAgfSBlbHNlIHsKICAgICAgLy8g0LPQvtGA0LjQt9C+0L3RgtCw0LvRjNC90L7QtTog0LHRg9C80LDQs9CwIFgyNi03MgogICAgICBjdHguZm9udD0nNDAwICcrKFcqMC4wMjQpKydweCAnK01PTk87CiAgICAgIGN0eC5maWxsU3R5bGU9TEFCRUw7IGN0eC5nbG9iYWxBbHBoYT0uODsKICAgICAgY3R4LmZpbGxUZXh0KG9wdHMuY2FzZUxhYmVsfHwn0JTQldCb0J4nLCBXKjAuMjcsIEgqMC4xNSk7CiAgICAgIGN0eC5nbG9iYWxBbHBoYT0xOwogICAgICB2YXIgdGZoPWZpdFRleHQoY3R4LCBvcHRzLnRpdGxlfHwnJywgVyowLjQwLCBIKjAuMTgsIFcqMC4wNiwgVyowLjAzOCwgU0VSSUYsICc5MDAnKTsKICAgICAgZHJhd0xpbmVzKGN0eCwgdGZoLCBXKjAuMjcsIEgqMC4yMCwgJyMxYzEzMGMnKTsKICAgICAgY3R4LmZvbnQ9JzQwMCAnKyhXKjAuMDIyKSsncHggJytNT05POwogICAgICBjdHguZmlsbFN0eWxlPVNFQUw7CiAgICAgIGN0eC5maWxsVGV4dChvcHRzLmJhZGdlfHwn0KDQkNCX0JLQmNCb0JrQkCcsIFcqMC4yNywgSCowLjM3KTsKICAgICAgdmFyIGJmaD1maXRUZXh0KGN0eCwgb3B0cy5ib2R5fHwnJywgVyowLjQ0LCBIKjAuMzQsIFcqMC4wMzgsIFcqMC4wMjQsIEJPRFksICc0MDAnKTsKICAgICAgZHJhd0xpbmVzKGN0eCwgYmZoLCBXKjAuMjcsIEgqMC40MywgSU5LMik7CiAgICB9CiAgICByZXR1cm4gY3Y7CiAgfQoKICAvLyDRgdGC0LjQutC10YAt0LrQvdC+0L/QutCwINCy0YvQsdC+0YDQsCDRgSDRgtC10LrRgdGC0L7QvAogIGZ1bmN0aW9uIHJlbmRlclN0aWNrZXIobGFiZWwsIHN1Yil7CiAgICB2YXIgYXJ0PUFSVC5zdGlja2VyOwogICAgdmFyIERQUj1NYXRoLm1pbih3aW5kb3cuZGV2aWNlUGl4ZWxSYXRpb3x8MSwyLjUpOwogICAgdmFyIFc9YXJ0P2FydC53aWR0aDo0ODAsIEg9YXJ0P2FydC5oZWlnaHQ6MzE2OwogICAgdmFyIGN2PWRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoJ2NhbnZhcycpOwogICAgY3Yud2lkdGg9VypEUFI7IGN2LmhlaWdodD1IKkRQUjsgY3Yuc3R5bGUud2lkdGg9JzEwMCUnOyBjdi5zdHlsZS5oZWlnaHQ9J2F1dG8nOyBjdi5zdHlsZS5kaXNwbGF5PSdibG9jayc7CiAgICB2YXIgY3R4PWN2LmdldENvbnRleHQoJzJkJyk7IGN0eC5zY2FsZShEUFIsRFBSKTsgY3R4LnRleHRCYXNlbGluZT0ndG9wJzsKICAgIGlmKGFydCljdHguZHJhd0ltYWdlKGFydCwwLDAsVyxIKTsKICAgIHZhciBNT05PPSInU3BlY2lhbCBFbGl0ZScsJ0NvdXJpZXIgTmV3Jyxtb25vc3BhY2UiLCBTRVJJRj0iJ1BsYXlmYWlyIERpc3BsYXknLEdlb3JnaWEsc2VyaWYiOwogICAgY3R4LmZvbnQ9JzQwMCAnKyhXKjAuMDUpKydweCAnK01PTk87IGN0eC5maWxsU3R5bGU9JyM3YTVhMmEnOwogICAgY3R4LmZpbGxUZXh0KHN1Ynx8J9Cg0JXQqNCV0J3QmNCVJywgVyowLjEwLCBIKjAuMjQpOwogICAgdmFyIHRmPWZpdFRleHQoY3R4LGxhYmVsfHwnJyxXKjAuODAsSCowLjQyLFcqMC4wODUsVyowLjA1LFNFUklGLCc4MDAnKTsKICAgIGN0eC5maWxsU3R5bGU9JyMyNDE4MTEnOwogICAgZm9yKHZhciBpPTA7aTx0Zi5saW5lcy5sZW5ndGg7aSsrKSBjdHguZmlsbFRleHQodGYubGluZXNbaV0sVyowLjEwLEgqMC40MCtpKnRmLmxoKTsKICAgIHJldHVybiBjdjsKICB9CgogIHdpbmRvdy5DYXJkR2VuPXtwcmVsb2FkOnByZWxvYWQscmVuZGVyOnJlbmRlcixyZW5kZXJTdGlja2VyOnJlbmRlclN0aWNrZXIsaXNSZWFkeTpmdW5jdGlvbigpe3JldHVybiBSRUFEWTt9fTsKfSkoKTsK" | base64 -d > games/cardgen.js
node --check games/cardgen.js && echo "  ✓ cardgen.js валиден"

echo ""; echo "══ 2/5  шрифты для canvas (Playfair 900, Special Elite, PT Serif) ═"
python3 - << 'PYEOF'
path="style.css"
with open(path,encoding="utf-8") as f: txt=f.read()
if "Special+Elite" not in txt:
    # добавляем к первому @import нужные семейства
    add="@import url('https://fonts.googleapis.com/css2?family=Playfair+Display:wght@800;900&family=Special+Elite&family=PT+Serif:wght@400;700&display=swap');\n"
    txt=add+txt
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + шрифты Playfair900/Special Elite/PT Serif подключены")
else:
    print("  шрифты уже есть")
PYEOF

echo ""; echo "══ 3/5  подключаем cardgen.js в index.html ════════"
python3 - << 'PYEOF'
path="index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
if 'games/cardgen.js' not in txt:
    txt=txt.replace('<script src="/games/feed.js"></script>',
                    '<script src="/games/cardgen.js"></script>\n<script src="/games/feed.js"></script>')
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + cardgen.js подключён перед feed.js")
else:
    print("  уже подключён")
PYEOF

echo ""; echo "══ 4/5  предзагрузка арта карт при старте ═════════"
python3 - << 'PYEOF'
path="app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
if "CardGen.preload" not in txt:
    # запускаем предзагрузку арта пораньше
    txt=txt.replace("window.SDVIG_STATIC=true;",
                    "window.SDVIG_STATIC=true;\ntry{window.CardGen&&CardGen.preload();}catch(_){}",1)
    if "CardGen.preload" not in txt:
        # запасной якорь
        txt=txt.replace("document.addEventListener('DOMContentLoaded',",
                        "document.addEventListener('DOMContentLoaded',function(){try{window.CardGen&&CardGen.preload();}catch(_){}} );\ndocument.addEventListener('DOMContentLoaded',",1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + предзагрузка арта карт")
else:
    print("  уже есть")
PYEOF

echo ""; echo "══ 5/5  renderDecision → canvas-досье ═════════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
import re

# определим говорящего/портрет для сцены + выбор ориентации
# Вставляем новую сборку карты вместо decCardInner-разметки в renderDecision.
# Находим блок построения dec.innerHTML
old="dec.innerHTML='<div class=\"dec-card\" id=\"dec-card\">'+decCardInner(ev)+'</div>'+"
if old in txt:
    new='''dec.innerHTML='<div class="dec-card canvas-card" id="dec-card"></div>'+'''
    txt=txt.replace(old,new,1)
    print("  + карта-контейнер под canvas")

# После создания stage — построить canvas-карту
anchor="bindDecisionSwipe(ev); startDecTimer();"
inject='''(function(){
      try{
        var host=document.getElementById('dec-card'); if(!host) return;
        var spk=(ev.speaker||'').toLowerCase();
        // портрет говорящего, если есть арт персонажа
        var portraitSrc=null;
        var CH={kurator:'/img/chars/char-kurator.png',shift:'/img/chars/char-shift.png',
                vivien:'/img/chars/char-vivien.png',arundel:'/img/chars/char-arundel.png'};
        for(var k in CH){ if(spk.indexOf(k)>=0){ portraitSrc=CH[k]; break; } }
        var orient = portraitSrc ? 'v' : (Math.random()<0.5?'v':'h');
        if(portraitSrc) orient='v';
        var lL=(ev.left&&ev.left.label)||'', rL=(ev.right&&ev.right.label)||'';
        function build(portrait){
          var cv=CardGen.render({
            orient:orient,
            caseLabel:(window.currentCaseLabel||('ДЕЛО'))+'',
            badge:ev.badge||'РЕШЕНИЕ',
            speaker:ev.speaker||'',
            title:ev.title||'',
            body:ev.intro||ev.text||'',
            portrait:portrait
          });
          cv.id='dec-canvas';
          host.innerHTML=''; host.appendChild(cv);
          // штампы поверх
          var sl=document.createElement('div'); sl.className='dc-stamp left';
          sl.textContent=lL.replace(/^\u25c4\s*/,'').split(/\s+/).slice(0,2).join(' ');
          var sr=document.createElement('div'); sr.className='dc-stamp right';
          sr.textContent=rL.replace(/\s*\u25ba$/,'').split(/\s+/).slice(0,2).join(' ');
          host.appendChild(sl); host.appendChild(sr);
        }
        function go(){
          if(portraitSrc){
            var im=new Image();
            im.onload=function(){build(im);};
            im.onerror=function(){build(null);};
            im.src=portraitSrc;
          } else build(null);
        }
        if(CardGen.isReady()) go();
        else CardGen.preload().then(go);
      }catch(e){ console.error('card build',e); }
    })();
    bindDecisionSwipe(ev); startDecTimer();'''
txt=txt.replace(anchor,inject,1)
print("  + canvas-карта строится в renderDecision")

# стикеры-выбор через CardGen тоже (заменить кнопки на canvas-стикеры)
# найдём где рендерятся choices и добавим canvas-подложку
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js обновлён")
PYEOF

echo ""; echo "══ CSS: canvas-карта + штампы ═════════════════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".canvas-card{" not in txt:
    # добавляем стили в <style> блок feed (в начало CSS-строки .dec-card)
    add=""".canvas-card{background:none!important;border:none!important;box-shadow:none!important;
      width:min(90vw,350px)!important;overflow:visible!important;animation:none!important;}
    .canvas-card canvas{border-radius:6px;filter:drop-shadow(0 22px 44px rgba(0,0,0,.7));}
    .dc-stamp{position:absolute;top:12%;max-width:50%;padding:8px 13px;border-radius:8px;
      font-family:'Special Elite',monospace;font-weight:700;font-size:13px;letter-spacing:.05em;
      opacity:0;pointer-events:none;z-index:20;text-transform:uppercase;white-space:nowrap;
      overflow:hidden;text-overflow:ellipsis;transition:opacity .1s;}
    .dc-stamp.left{left:4%;transform:rotate(-12deg);color:#ffb0b0;border:3px solid rgba(224,106,106,.95);background:rgba(90,20,20,.65);}
    .dc-stamp.right{right:4%;transform:rotate(12deg);color:#8ceed6;border:3px solid rgba(116,216,190,.95);background:rgba(20,70,58,.65);}
    """
    txt=txt.replace("    .dec-card{position:relative;",add+"\n    .dec-card{position:relative;",1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS canvas-карты и штампов")
PYEOF

echo ""; echo "══ 6/6  новая физика свайпа (velocity/флик/пружина) ═"
python3 - << 'PYEOF2'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
old="""  function bindDecisionSwipe(ev){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,down=false;
    card.addEventListener('pointerdown',e=>{down=true;sx=e.clientX;card.setPointerCapture&&card.setPointerCapture(e.pointerId);});
    card.addEventListener('pointermove',e=>{if(!down)return;const dx=e.clientX-sx;
      card.style.transform='translateX('+dx*.5+'px) rotate('+dx*.02+'deg)';
      var cl=card.querySelector('.dc-choice.left'),cr=card.querySelector('.dc-choice.right');
      if(cl)cl.classList.toggle('lit',dx<-30); if(cr)cr.classList.toggle('lit',dx>30);});
    card.addEventListener('pointerup',e=>{if(!down)return;down=false;const dx=e.clientX-sx;
      if(Math.abs(dx)>60)commitDecision(ev,dx<0?'left':'right');else card.style.transform='';});
  }"""
new="""  function bindDecisionSwipe(ev){
    const card=document.getElementById('dec-card'); if(!card) return;
    let sx=0,down=false,dx=0,vx=0,lastX=0,lastT=0,raf=0,armed=false;
    const TH=Math.min(window.innerWidth*0.28,120), FLICK=0.55;
    card.style.transformOrigin='50% 120%'; card.style.touchAction='none';
    function paint(){ raf=0;
      card.style.transform='translate3d('+dx+'px,'+(Math.abs(dx)*-0.03)+'px,0) rotate('+(dx*0.06)+'deg) scale(1.015)';
      var p=Math.min(1,Math.abs(dx)/TH);
      var sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');
      if(sl)sl.style.opacity=dx<0?p:0; if(sr)sr.style.opacity=dx>0?p:0;
      var over=Math.abs(dx)>TH;
      if(over&&!armed){armed=true;try{vibrate&&vibrate(8)}catch(_){}} else if(!over&&armed)armed=false;
    }
    card.addEventListener('pointerdown',function(e){down=true;dx=0;vx=0;sx=e.clientX;lastX=e.clientX;lastT=performance.now();
      card.style.transition='none';card.setPointerCapture&&card.setPointerCapture(e.pointerId);});
    card.addEventListener('pointermove',function(e){if(!down)return;var t=performance.now();dx=e.clientX-sx;
      var dt=Math.max(1,t-lastT);vx=vx*0.8+((e.clientX-lastX)/dt)*0.2;lastX=e.clientX;lastT=t;
      if(!raf)raf=requestAnimationFrame(paint);});
    function up(){if(!down)return;down=false;if(raf){cancelAnimationFrame(raf);raf=0;}
      var commit=Math.abs(dx)>TH||(Math.abs(vx)>FLICK&&Math.abs(dx)>24);
      if(commit){var dir=(dx||vx)<0?-1:1,dist=window.innerWidth*1.3;
        var dur=Math.min(520,Math.max(240,dist/Math.max(Math.abs(vx),0.9)));
        card.style.transition='transform '+dur+'ms cubic-bezier(.22,.9,.36,1),opacity '+dur+'ms ease';
        card.style.transform='translate3d('+(dir*dist)+'px,0,0) rotate('+(dir*22)+'deg)';card.style.opacity='0';
        try{vibrate&&vibrate(18)}catch(_){}
        commitDecision(ev,dir<0?'left':'right',true);
      } else {
        card.style.transition='transform .45s cubic-bezier(.34,1.56,.64,1)';card.style.transform='';
        var sl=card.querySelector('.dc-stamp.left'),sr=card.querySelector('.dc-stamp.right');
        if(sl)sl.style.opacity=0; if(sr)sr.style.opacity=0; armed=false;
      }
    }
    card.addEventListener('pointerup',up); card.addEventListener('pointercancel',up);
  }"""
if old in txt:
    txt=txt.replace(old,new,1); print("  + новая физика свайпа для canvas-карты")
else:
    print("  ⚠ старый свайп не найден (возможно уже заменён)")
# commitDecision с флагом flew
if "function commitDecision(ev,dir,flew)" not in txt:
    txt=txt.replace("function commitDecision(ev,dir){","function commitDecision(ev,dir,flew){",1)
    txt=txt.replace("if(card)card.classList.add(dir==='left'?'swipe-left':'swipe-right');",
                    "if(card&&!flew)card.classList.add(dir==='left'?'swipe-left':'swipe-right');",1)
    print("  + commitDecision не дублирует анимацию при свайпе")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF2

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"
node --check src/main/resources/static/games/cardgen.js && echo "✓ cardgen.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R102 — карточка-досье на canvas (текст впечатан)"
echo "   ⚠ СНАЧАЛА положи арт в img/cards/ (из арт-карточек.zip):"
echo "     unzip -o /sdcard/Download/арт-карточек.zip -d src/main/resources/static/img/cards/"
echo "   git add -A && git commit -m 'R102: canvas dossier card' && git push"
echo "═══════════════════════════════════════════════════════"
