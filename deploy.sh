#!/usr/bin/env bash
# СДВИГ R106 — фон уровня виден, плашки меньше+стрелки, сгорание на месте, вопрос в полароид
set -e
echo "══ штамп → R106 ══"
sed -i -E "s/SDVIG_BUILD='R[0-9]+'/SDVIG_BUILD='R106'/" src/main/resources/static/app.js
sed -i -E 's/>R[0-9]+</>R106</' src/main/resources/static/index.html

cd src/main/resources/static

echo ""; echo "══ 1/5  обновить cardgen.js (стрелки, вопрос) ═════"
echo "Lyog4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQCiAgINCh0JTQktCY0JMgwrcg0JPQtdC90LXRgNCw0YLQvtGAINC60LDRgNGC0L7Rh9C60Lgt0LTQvtGB0YzQtSAoY2FudmFzLCDRgtC10LrRgdGCINCy0L/QtdGH0LDRgtCw0L0g0LIg0LHRg9C80LDQs9GDKQogICBDYXJkR2VuLnJlbmRlcihvcHRzKSDihpIgPGNhbnZhcz4g0YEg0LTQvtGB0YzQtSArINCw0LLRgtC+LdCy0L/QuNGB0LDQvdC90YvQvCDRgtC10LrRgdGC0L7QvArilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZDilZAgKi8KKGZ1bmN0aW9uKCl7CiAgdmFyIEFSVD17fTsgICAgICAgICAgICAgICAgIC8vINC60Y3RiCDQt9Cw0LPRgNGD0LbQtdC90L3QvtCz0L4g0LDRgNGC0LAKICB2YXIgUkVBRFk9ZmFsc2UsIGxvYWRpbmdQPW51bGw7CiAgdmFyIEJBU0U9ewogICAgdjonL2ltZy9jYXJkcy9mb2xkZXItdi5wbmcnLCAgIC8vINCy0LXRgNGC0LjQutCw0LvRjNC90L7QtSAo0YEg0L/QvtC70LDRgNC+0LjQtNC+0LwpCiAgICBoOicvaW1nL2NhcmRzL2ZvbGRlci1oLnBuZycsICAgLy8g0LPQvtGA0LjQt9C+0L3RgtCw0LvRjNC90L7QtQogICAgc3RpY2tlcjonL2ltZy9jYXJkcy9zdGlja2VyLnBuZycKICB9OwoKICBmdW5jdGlvbiBsb2FkSW1nKHNyYyl7CiAgICByZXR1cm4gbmV3IFByb21pc2UoZnVuY3Rpb24ocmVzLHJlail7CiAgICAgIHZhciBpPW5ldyBJbWFnZSgpOyBpLm9ubG9hZD1mdW5jdGlvbigpe3JlcyhpKTt9OyBpLm9uZXJyb3I9cmVqOyBpLnNyYz1zcmM7CiAgICB9KTsKICB9CiAgZnVuY3Rpb24gcHJlbG9hZCgpewogICAgaWYobG9hZGluZ1ApIHJldHVybiBsb2FkaW5nUDsKICAgIGxvYWRpbmdQPVByb21pc2UuYWxsKFsKICAgICAgbG9hZEltZyhCQVNFLnYpLnRoZW4oZnVuY3Rpb24oaSl7QVJULnY9aTt9KS5jYXRjaChmdW5jdGlvbigpe30pLAogICAgICBsb2FkSW1nKEJBU0UuaCkudGhlbihmdW5jdGlvbihpKXtBUlQuaD1pO30pLmNhdGNoKGZ1bmN0aW9uKCl7fSksCiAgICAgIGxvYWRJbWcoQkFTRS5zdGlja2VyKS50aGVuKGZ1bmN0aW9uKGkpe0FSVC5zdGlja2VyPWk7fSkuY2F0Y2goZnVuY3Rpb24oKXt9KSwKICAgICAgKGRvY3VtZW50LmZvbnRzJiZkb2N1bWVudC5mb250cy5yZWFkeSl8fFByb21pc2UucmVzb2x2ZSgpCiAgICBdKS50aGVuKGZ1bmN0aW9uKCl7UkVBRFk9dHJ1ZTt9KTsKICAgIHJldHVybiBsb2FkaW5nUDsKICB9CgogIC8vINC/0LXRgNC10L3QvtGBINC/0L4g0YHQu9C+0LLQsNC8INGBINCw0LLRgtC+LdC/0L7QtNCx0L7RgNC+0Lwg0YDQsNC30LzQtdGA0LAg0L/QvtC0INC60L7RgNC+0LHQutGDCiAgZnVuY3Rpb24gZml0VGV4dChjdHgsIHRleHQsIGJveFcsIGJveEgsIHN0YXJ0UHgsIG1pblB4LCBmYW1pbHksIHdlaWdodCl7CiAgICBmb3IodmFyIHNpemU9c3RhcnRQeDsgc2l6ZT49bWluUHg7IHNpemUtPTEpewogICAgICBjdHguZm9udD0od2VpZ2h0fHwnJykrJyAnK3NpemUrJ3B4ICcrZmFtaWx5OwogICAgICB2YXIgd29yZHM9KHRleHR8fCcnKS5zcGxpdCgvXHMrLyksIGxpbmVzPVtdLCBjdXI9Jyc7CiAgICAgIGZvcih2YXIgaT0wO2k8d29yZHMubGVuZ3RoO2krKyl7CiAgICAgICAgdmFyIHQ9KGN1cj9jdXIrJyAnOicnKSt3b3Jkc1tpXTsKICAgICAgICBpZihjdHgubWVhc3VyZVRleHQodCkud2lkdGg8PWJveFcpIGN1cj10OwogICAgICAgIGVsc2UgeyBpZihjdXIpbGluZXMucHVzaChjdXIpOyBjdXI9d29yZHNbaV07IH0KICAgICAgfQogICAgICBpZihjdXIpbGluZXMucHVzaChjdXIpOwogICAgICB2YXIgbGg9c2l6ZSoxLjM7CiAgICAgIGlmKGxpbmVzLmxlbmd0aCpsaDw9Ym94SCkgcmV0dXJuIHtzaXplOnNpemUsbGluZXM6bGluZXMsbGg6bGh9OwogICAgfQogICAgLy8g0LzQuNC90LjQvNGD0Lwg4oCUINCy0LXRgNC90ZHQvCDQutCw0Log0LXRgdGC0YwKICAgIGN0eC5mb250PSh3ZWlnaHR8fCcnKSsnICcrbWluUHgrJ3B4ICcrZmFtaWx5OwogICAgdmFyIHcyPSh0ZXh0fHwnJykuc3BsaXQoL1xzKy8pLCBsMj1bXSwgYzI9Jyc7CiAgICBmb3IodmFyIGo9MDtqPHcyLmxlbmd0aDtqKyspe3ZhciB0dD0oYzI/YzIrJyAnOicnKSt3MltqXTsKICAgICAgaWYoY3R4Lm1lYXN1cmVUZXh0KHR0KS53aWR0aDw9Ym94VyljMj10dDsgZWxzZXtpZihjMilsMi5wdXNoKGMyKTtjMj13MltqXTt9fQogICAgaWYoYzIpbDIucHVzaChjMik7CiAgICByZXR1cm4ge3NpemU6bWluUHgsbGluZXM6bDIsbGg6bWluUHgqMS4zfTsKICB9CgogIGZ1bmN0aW9uIGRyYXdMaW5lcyhjdHgsIGZpdCwgeCwgeSwgY29sb3IpewogICAgY3R4LmZpbGxTdHlsZT1jb2xvcjsKICAgIGZvcih2YXIgaT0wO2k8Zml0LmxpbmVzLmxlbmd0aDtpKyspewogICAgICBjdHguZmlsbFRleHQoZml0LmxpbmVzW2ldLCB4LCB5K2kqZml0LmxoKTsKICAgIH0KICAgIHJldHVybiB5K2ZpdC5saW5lcy5sZW5ndGgqZml0LmxoOwogIH0KCiAgLyogb3B0czoge29yaWVudDondid8J2gnLCBjYXNlTGFiZWwsIGJhZGdlLCBzcGVha2VyLCB0aXRsZSwgYm9keSwgcG9ydHJhaXQoSW1hZ2V8bnVsbCl9ICovCiAgZnVuY3Rpb24gcmVuZGVyKG9wdHMpewogICAgb3B0cz1vcHRzfHx7fTsKICAgIHZhciBvcmllbnQgPSBvcHRzLm9yaWVudD09PSdoJyA/ICdoJzondic7CiAgICB2YXIgYXJ0ID0gQVJUW29yaWVudF07CiAgICB2YXIgRFBSID0gTWF0aC5taW4od2luZG93LmRldmljZVBpeGVsUmF0aW98fDEsIDIuNSk7CiAgICAvLyDQu9C+0LPQuNGH0LXRgdC60LjQuSDRgNCw0LfQvNC10YAg0LrQsNGA0YLRiyDQv9C+INCw0YDRgtGDCiAgICB2YXIgYmFzZVcgPSBhcnQ/IGFydC53aWR0aCA6IChvcmllbnQ9PT0ndic/NzE3OjgyMCk7CiAgICB2YXIgYmFzZUggPSBhcnQ/IGFydC5oZWlnaHQgOiAob3JpZW50PT09J3YnPzk2MDo0NDcpOwogICAgLy8g0LzQsNGB0YjRgtCw0LEg0L/QvtC0INGN0LrRgNCw0L0gKNGI0LjRgNC40L3QsCDQutCw0YDRgtGLIH4gOTB2dywg0L3QviDRgNC40YHRg9C10Lwg0LIg0YDQsNC30YDQtdGI0LXQvdC40Lgg0LDRgNGC0LAqRFBSKQogICAgdmFyIGN2PWRvY3VtZW50LmNyZWF0ZUVsZW1lbnQoJ2NhbnZhcycpOwogICAgY3Yud2lkdGg9YmFzZVcqRFBSOyBjdi5oZWlnaHQ9YmFzZUgqRFBSOwogICAgY3Yuc3R5bGUud2lkdGg9JzEwMCUnOyBjdi5zdHlsZS5oZWlnaHQ9J2F1dG8nOyBjdi5zdHlsZS5kaXNwbGF5PSdibG9jayc7CiAgICB2YXIgY3R4PWN2LmdldENvbnRleHQoJzJkJyk7CiAgICBjdHguc2NhbGUoRFBSLERQUik7CiAgICBjdHgudGV4dEJhc2VsaW5lPSd0b3AnOwoKICAgIC8vINC/0L7QtNC70L7QttC60LAg0LTQvtGB0YzQtQogICAgaWYoYXJ0KSBjdHguZHJhd0ltYWdlKGFydCwwLDAsYmFzZVcsYmFzZUgpOwoKICAgIHZhciBXPWJhc2VXLEg9YmFzZUg7CiAgICB2YXIgSU5LPScjMjQxODExJywgSU5LMj0nIzJmMjMxOCcsIFNFQUw9JyM4ZTI0MzQnLCBMQUJFTD0nIzVhM2QyZSc7CiAgICB2YXIgU0VSSUY9IidQbGF5ZmFpciBEaXNwbGF5JywgR2VvcmdpYSwgc2VyaWYiOwogICAgdmFyIE1PTk89IidTcGVjaWFsIEVsaXRlJywgJ0NvdXJpZXIgTmV3JywgbW9ub3NwYWNlIjsKICAgIHZhciBCT0RZPSInUFQgU2VyaWYnLCBHZW9yZ2lhLCBzZXJpZiI7CgogICAgaWYob3JpZW50PT09J3YnKXsKICAgICAgLy8g0LfQvtC90Ysg0LLQtdGA0YLQuNC60LDQu9GM0L3QvtCz0L4gKNCyINC00L7Qu9GP0YUpOiDQv9C+0LvQsNGA0L7QuNC0IFg1Ni04NiBZMTEtNDAsINC/0LXRh9Cw0YLRjCB+WDYyLTgyIFk2OC04NgogICAgICAvLyDRj9GA0LvRi9C6CiAgICAgIGN0eC5mb250PSc0MDAgJysoVyowLjAyOCkrJ3B4ICcrTU9OTzsKICAgICAgY3R4LmZpbGxTdHlsZT1MQUJFTDsgY3R4Lmdsb2JhbEFscGhhPS44OwogICAgICBjdHguZmlsbFRleHQob3B0cy5jYXNlTGFiZWx8fCfQlNCV0JvQnicsIFcqMC4yMSwgSCowLjE1KTsKICAgICAgY3R4Lmdsb2JhbEFscGhhPTE7CiAgICAgIC8vINC30LDQs9C+0LvQvtCy0L7QuiDigJQg0LvQtdCy0LXQtSDQv9C+0LvQsNGA0L7QuNC00LAgKNGI0LjRgNC40L3QsCB+MzQlKQogICAgICB2YXIgdGY9Zml0VGV4dChjdHgsIG9wdHMudGl0bGV8fCcnLCBXKjAuMzMsIEgqMC4xNywgVyowLjA4NSwgVyowLjA1LCBTRVJJRiwgJzkwMCcpOwogICAgICBkcmF3TGluZXMoY3R4LCB0ZiwgVyowLjIxLCBIKjAuMTg1LCAnIzFjMTMwYycpOwogICAgICAvLyDQv9C+0LTQv9C40YHRjAogICAgICBjdHguZm9udD0nNDAwICcrKFcqMC4wMjgpKydweCAnK01PTk87CiAgICAgIGN0eC5maWxsU3R5bGU9U0VBTDsKICAgICAgY3R4LmZpbGxUZXh0KChvcHRzLmJhZGdlfHwn0KDQkNCX0JLQmNCb0JrQkCcpKyhvcHRzLnNwZWFrZXI/JyDCtyAnK29wdHMuc3BlYWtlci50b1VwcGVyQ2FzZSgpOicnKSwgVyowLjIxLCBIKjAuNDA1KTsKICAgICAgLy8g0YLQtdC70L4g4oCUINCy0YHRjyDRiNC40YDQuNC90LAg0LHRg9C80LDQs9C4LCDQstGL0YjQtSDQv9C10YfQsNGC0LggKFkg0LTQviB+NjQlKQogICAgICB2YXIgYmY9Zml0VGV4dChjdHgsIG9wdHMuYm9keXx8JycsIFcqMC42MCwgSCowLjIwLCBXKjAuMDUyLCBXKjAuMDMyLCBCT0RZLCAnNDAwJyk7CiAgICAgIGRyYXdMaW5lcyhjdHgsIGJmLCBXKjAuMjEsIEgqMC40NiwgSU5LMik7CiAgICAgIC8vINCy0L7Qv9GA0L7RgdC40YLQtdC70YzQvdGL0Lkg0LfQvdCw0Log0LIg0L/Rg9GB0YLQvtC5INC/0L7Qu9Cw0YDQvtC40LQgKNC90LXRgiDQv9C+0LTQvtC30YDQtdCy0LDQtdC80L7Qs9C+KQogICAgICBpZighb3B0cy5wb3J0cmFpdCl7CiAgICAgICAgdmFyIHF4PVcqMC41ODUsIHF5PUgqMC4xMzUsIHF3PVcqMC4yNTUsIHFoPUgqMC4yMzU7CiAgICAgICAgY3R4LnNhdmUoKTsKICAgICAgICBjdHguZm9udD0nOTAwICcrKHFoKjAuNikrJ3B4ICcrU0VSSUY7IGN0eC5maWxsU3R5bGU9J3JnYmEoOTAsNzAsNTUsLjU1KSc7CiAgICAgICAgY3R4LnRleHRBbGlnbj0nY2VudGVyJzsgY3R4LnRleHRCYXNlbGluZT0nbWlkZGxlJzsKICAgICAgICBjdHguZmlsbFRleHQoJz8nLCBxeCtxdy8yLCBxeStxaC8yKTsKICAgICAgICBjdHgucmVzdG9yZSgpOwogICAgICAgIGN0eC50ZXh0QWxpZ249J2xlZnQnOyBjdHgudGV4dEJhc2VsaW5lPSd0b3AnOwogICAgICB9CiAgICAgIC8vINC/0L7RgNGC0YDQtdGCINCyINC/0L7Qu9Cw0YDQvtC40LQKICAgICAgaWYob3B0cy5wb3J0cmFpdCl7CiAgICAgICAgdmFyIHB4PVcqMC41ODUsIHB5PUgqMC4xMzUsIHB3PVcqMC4yNTUsIHBoPUgqMC4yMzU7CiAgICAgICAgY3R4LnNhdmUoKTsKICAgICAgICBjdHguYmVnaW5QYXRoKCk7IGN0eC5yZWN0KHB4LHB5LHB3LHBoKTsgY3R4LmNsaXAoKTsKICAgICAgICAvLyDQstC/0LjRgdCw0YLRjCDQv9C+0YDRgtGA0LXRgiDQv9C+INGG0LXQvdGC0YDRgwogICAgICAgIHZhciBpcj1vcHRzLnBvcnRyYWl0LndpZHRoL29wdHMucG9ydHJhaXQuaGVpZ2h0LCBicj1wdy9waCwgZHcsZGgsZHgsZHk7CiAgICAgICAgaWYoaXI+YnIpe2RoPXBoO2R3PXBoKmlyO2R4PXB4LShkdy1wdykvMjtkeT1weTt9CiAgICAgICAgZWxzZXtkdz1wdztkaD1wdy9pcjtkeD1weDtkeT1weS0oZGgtcGgpLzI7fQogICAgICAgIGN0eC5nbG9iYWxBbHBoYT0uOTI7CiAgICAgICAgY3R4LmRyYXdJbWFnZShvcHRzLnBvcnRyYWl0LGR4LGR5LGR3LGRoKTsKICAgICAgICAvLyDQu9GR0LPQutCw0Y8g0YHQtdC/0LjRjy3QstGD0LDQu9GMCiAgICAgICAgY3R4Lmdsb2JhbEFscGhhPS4xODsgY3R4LmZpbGxTdHlsZT0nIzNhMmExYSc7IGN0eC5maWxsUmVjdChweCxweSxwdyxwaCk7CiAgICAgICAgY3R4LnJlc3RvcmUoKTsKICAgICAgfQogICAgfSBlbHNlIHsKICAgICAgLy8g0LPQvtGA0LjQt9C+0L3RgtCw0LvRjNC90L7QtTog0LHRg9C80LDQs9CwIFgyNi03MgogICAgICBjdHguZm9udD0nNDAwICcrKFcqMC4wMjQpKydweCAnK01PTk87CiAgICAgIGN0eC5maWxsU3R5bGU9TEFCRUw7IGN0eC5nbG9iYWxBbHBoYT0uODsKICAgICAgY3R4LmZpbGxUZXh0KG9wdHMuY2FzZUxhYmVsfHwn0JTQldCb0J4nLCBXKjAuMjcsIEgqMC4xNSk7CiAgICAgIGN0eC5nbG9iYWxBbHBoYT0xOwogICAgICB2YXIgdGZoPWZpdFRleHQoY3R4LCBvcHRzLnRpdGxlfHwnJywgVyowLjQwLCBIKjAuMTgsIFcqMC4wNiwgVyowLjAzOCwgU0VSSUYsICc5MDAnKTsKICAgICAgZHJhd0xpbmVzKGN0eCwgdGZoLCBXKjAuMjcsIEgqMC4yMCwgJyMxYzEzMGMnKTsKICAgICAgY3R4LmZvbnQ9JzQwMCAnKyhXKjAuMDIyKSsncHggJytNT05POwogICAgICBjdHguZmlsbFN0eWxlPVNFQUw7CiAgICAgIGN0eC5maWxsVGV4dChvcHRzLmJhZGdlfHwn0KDQkNCX0JLQmNCb0JrQkCcsIFcqMC4yNywgSCowLjM3KTsKICAgICAgdmFyIGJmaD1maXRUZXh0KGN0eCwgb3B0cy5ib2R5fHwnJywgVyowLjQ0LCBIKjAuMzQsIFcqMC4wMzgsIFcqMC4wMjQsIEJPRFksICc0MDAnKTsKICAgICAgZHJhd0xpbmVzKGN0eCwgYmZoLCBXKjAuMjcsIEgqMC40MywgSU5LMik7CiAgICB9CiAgICByZXR1cm4gY3Y7CiAgfQoKICAvLyDRgdGC0LjQutC10YAt0LrQvdC+0L/QutCwINCy0YvQsdC+0YDQsCDRgSDRgtC10LrRgdGC0L7QvAogIGZ1bmN0aW9uIHJlbmRlclN0aWNrZXIobGFiZWwsIGFycm93KXsKICAgIHZhciBhcnQ9QVJULnN0aWNrZXI7CiAgICB2YXIgRFBSPU1hdGgubWluKHdpbmRvdy5kZXZpY2VQaXhlbFJhdGlvfHwxLDIuNSk7CiAgICB2YXIgVz1hcnQ/YXJ0LndpZHRoOjQ4MCwgSD1hcnQ/YXJ0LmhlaWdodDozMTY7CiAgICB2YXIgY3Y9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnY2FudmFzJyk7CiAgICBjdi53aWR0aD1XKkRQUjsgY3YuaGVpZ2h0PUgqRFBSOyBjdi5zdHlsZS53aWR0aD0nMTAwJSc7IGN2LnN0eWxlLmhlaWdodD0nYXV0byc7IGN2LnN0eWxlLmRpc3BsYXk9J2Jsb2NrJzsKICAgIHZhciBjdHg9Y3YuZ2V0Q29udGV4dCgnMmQnKTsgY3R4LnNjYWxlKERQUixEUFIpOyBjdHgudGV4dEJhc2VsaW5lPSdtaWRkbGUnOwogICAgaWYoYXJ0KWN0eC5kcmF3SW1hZ2UoYXJ0LDAsMCxXLEgpOwogICAgdmFyIFNFUklGPSInUGxheWZhaXIgRGlzcGxheScsR2VvcmdpYSxzZXJpZiI7CiAgICAvLyDRgdGC0YDQtdC70LrQsCAo0LrRgNGD0L/QvdCw0Y8sINGB0LvQtdCy0LAg0LjQu9C4INGB0L/RgNCw0LLQsCkKICAgIHZhciBpc0xlZnQ9KGFycm93PT09J2xlZnQnKTsKICAgIGN0eC5mb250PSc4MDAgJysoVyowLjEzKSsncHggJytTRVJJRjsgY3R4LmZpbGxTdHlsZT0nIzhlMjQzNCc7IGN0eC50ZXh0QWxpZ249J2NlbnRlcic7CiAgICBjdHguZmlsbFRleHQoaXNMZWZ0PyfigLknOifigLonLCBpc0xlZnQ/VyowLjE0OlcqMC44NiwgSCowLjUpOwogICAgLy8g0YLQtdC60YHRgiDQstGL0LHQvtGA0LAg4oCUINC/0L4g0YbQtdC90YLRgNGDLCDRgSDQsNCy0YLQvi3QstC/0LjRgdGL0LLQsNC90LjQtdC8CiAgICBjdHgudGV4dEFsaWduPSdsZWZ0JzsgY3R4LnRleHRCYXNlbGluZT0ndG9wJzsKICAgIHZhciB0eD1pc0xlZnQ/VyowLjI0OlcqMC4wOCwgdHc9VyowLjY4OwogICAgdmFyIHRmPWZpdFRleHQoY3R4LGxhYmVsfHwnJyx0dyxIKjAuNjIsVyowLjA4LFcqMC4wNDgsU0VSSUYsJzgwMCcpOwogICAgY3R4LmZpbGxTdHlsZT0nIzI0MTgxMSc7CiAgICB2YXIgdG90YWxIPXRmLmxpbmVzLmxlbmd0aCp0Zi5saCwgc3k9KEgtdG90YWxIKS8yOwogICAgZm9yKHZhciBpPTA7aTx0Zi5saW5lcy5sZW5ndGg7aSsrKSBjdHguZmlsbFRleHQodGYubGluZXNbaV0sdHgsc3kraSp0Zi5saCk7CiAgICByZXR1cm4gY3Y7CiAgfQoKICB3aW5kb3cuQ2FyZEdlbj17cHJlbG9hZDpwcmVsb2FkLHJlbmRlcjpyZW5kZXIscmVuZGVyU3RpY2tlcjpyZW5kZXJTdGlja2VyLGlzUmVhZHk6ZnVuY3Rpb24oKXtyZXR1cm4gUkVBRFk7fX07Cn0pKCk7Cg==" | base64 -d > games/cardgen.js
node --check games/cardgen.js && echo "  ✓ cardgen.js обновлён"

echo ""; echo "══ 2/5  фон уровня виден (убрать тёмный фон stage) ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old=""".decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;
      align-items:center;justify-content:center;gap:0;padding:20px 14px;
      background:radial-gradient(80% 70% at 50% 45%,rgba(12,16,24,.55),rgba(8,11,18,.82));
      backdrop-filter:blur(3px);}"""
new=""".decision-stage{position:absolute;inset:0;z-index:40;display:flex;flex-direction:column;
      align-items:center;justify-content:center;gap:0;padding:20px 14px;
      background:radial-gradient(70% 55% at 50% 45%,rgba(10,7,9,.35),rgba(10,7,9,.62));
      backdrop-filter:blur(2px);}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + фон stage прозрачнее (фон уровня виден)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 3/5  плашки меньше (ограничить высоту) ═════════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old=""".dec-stickers{position:relative;display:flex;gap:12px;width:min(84vw,330px);
      margin:0 auto;z-index:15;flex:0 0 auto;}
    .dec-sticker{flex:1;cursor:pointer;transition:transform .15s;transform-origin:center;max-width:50%;}
    .dec-sticker canvas{width:100%;height:auto;display:block;filter:drop-shadow(0 6px 12px rgba(0,0,0,.5));}"""
new=""".dec-stickers{position:relative;display:flex;gap:10px;width:min(78vw,300px);
      margin:0 auto;z-index:15;flex:0 0 auto;}
    .dec-sticker{flex:1;cursor:pointer;transition:transform .15s;transform-origin:center;
      max-width:50%;max-height:66px;overflow:hidden;border-radius:8px;}
    .dec-sticker canvas{width:100%;height:auto;display:block;filter:drop-shadow(0 5px 10px rgba(0,0,0,.5));}"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + плашки компактнее (max-height 66px)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 4/5  стикеры: стрелки вместо дубля РЕШЕНИЕ ═════"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""              box.appendChild(mkSticker(lL,'◄ РЕШЕНИЕ','l'));
              box.appendChild(mkSticker(rL,'РЕШЕНИЕ ►','r'));"""
new="""              box.appendChild(mkSticker(lL,'left','l'));
              box.appendChild(mkSticker(rL,'right','r'));"""
if old in txt: txt=txt.replace(old,new,1); n+=1
# в mkSticker передаём arrow вместо sub
old2="""              var mkSticker=function(label,sub,side){
                var wrap=document.createElement('div'); wrap.className='dec-sticker '+side;
                var scv=CardGen.renderSticker(label.replace(/^[\u25c4\u25ba]\s*/,'').replace(/\s*[\u25c4\u25ba]$/,''), sub);"""
new2="""              var mkSticker=function(label,arrow,side){
                var wrap=document.createElement('div'); wrap.className='dec-sticker '+side;
                var scv=CardGen.renderSticker(label.replace(/^[\u25c4\u25ba]\s*/,'').replace(/\s*[\u25c4\u25ba]$/,''), arrow);"""
if old2 in txt: txt=txt.replace(old2,new2,1); n+=1
print("  + стрелки в стикерах: %d"%n)
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 5/5  СГОРАНИЕ на месте (не улетать) + больше искр ═"
python3 - << 'PYEOF'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0

# При коммите свайпа: НЕ улетать вбок, а сгорать на месте
old="""      if(commit){var dir=(dx||vx)<0?-1:1,dist=window.innerWidth*1.3;
        var dur=Math.min(520,Math.max(240,dist/Math.max(Math.abs(vx),0.9)));
        card.style.transition='transform '+dur+'ms cubic-bezier(.22,.9,.36,1),opacity '+dur+'ms ease';
        card.style.transform='translate3d('+(dir*dist)+'px,0,0) rotate('+(dir*22)+'deg)';card.style.opacity='0';
        try{vibrate&&vibrate(18)}catch(_){}
        commitDecision(ev,dir<0?'left':'right',true);
      } else {"""
new="""      if(commit){var dir=(dx||vx)<0?-1:1;
        // короткий толчок в сторону выбора, затем сгорание на месте
        card.style.transition='transform .18s ease-out';
        card.style.transform='translate3d('+(dir*40)+'px,0,0) rotate('+(dir*4)+'deg)';
        try{vibrate&&vibrate(18)}catch(_){}
        commitDecision(ev,dir<0?'left':'right',true);
      } else {"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + свайп: толчок + сгорание на месте (не улетает)")

# burnCard: больше искр (14→26), крупнее, дольше
old2="""    for(var i=0;i<14;i++){
      (function(i){
        var e=document.createElement('div'); e.className='burn-ember';
        var sz=3+Math.random()*5;
        e.style.width=sz+'px'; e.style.height=sz+'px';
        e.style.left=(10+Math.random()*80)+'%';
        e.style.top=(40+Math.random()*55)+'%';
        e.style.animationDelay=(Math.random()*0.25)+'s';
        card.appendChild(e);
      })(i);
    }"""
new2="""    for(var i=0;i<30;i++){
      (function(i){
        var e=document.createElement('div'); e.className='burn-ember';
        var sz=3+Math.random()*7;
        e.style.width=sz+'px'; e.style.height=sz+'px';
        e.style.left=(6+Math.random()*88)+'%';
        e.style.top=(30+Math.random()*65)+'%';
        e.style.animationDelay=(Math.random()*0.4)+'s';
        e.style.setProperty('--dx',((Math.random()-0.5)*60)+'px');
        card.appendChild(e);
      })(i);
    }"""
if old2 in txt: txt=txt.replace(old2,new2,1); n+=1; print("  + 30 искр, разлёт в стороны")

# ember-анимация с горизонтальным разлётом
old3="""    @keyframes emberFly{0%{opacity:1;transform:translateY(0) scale(1);}100%{opacity:0;transform:translateY(-90px) scale(.2);}}"""
new3="""    @keyframes emberFly{0%{opacity:1;transform:translate(0,0) scale(1);}
      100%{opacity:0;transform:translate(var(--dx,0),-100px) scale(.15);}}"""
if old3 in txt: txt=txt.replace(old3,new3,1); n+=1; print("  + искры разлетаются вбок+вверх")

# сгорание держим дольше перед удалением
txt=txt.replace("},640);","},900);")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF

echo ""; echo "══ 6/6  фикс иконки пола рекрута в диалогах ═══════"
python3 - << 'PYEOF2'
path="games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old="""  function avatar(id){
    var C=window.CHARS||(typeof CHARS!=='undefined'?CHARS:null);
    if(id&&C&&C[id]) return C[id].src+'?v='+CHARV;
    return '';
  }"""
new="""  function avatar(id){
    var C=window.CHARS||(typeof CHARS!=='undefined'?CHARS:null);
    // рекрут — иконка по полу игрока
    if(id==='recruit'){
      try{
        var fem=(window.App&&App.profile&&App.profile.gender==='f');
        var key=fem?'recruit-f':'recruit';
        if(C&&C[key]) return C[key].src+'?v='+CHARV;
        return (fem?'/img/chars/char-recruit-f.png':'/img/chars/char-recruit.png')+'?v='+CHARV;
      }catch(_){}
    }
    if(id&&C&&C[id]) return C[id].src+'?v='+CHARV;
    return '';
  }"""
if old in txt: txt=txt.replace(old,new,1); n+=1; print("  + avatar рекрута по полу игрока")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ %d"%n)
PYEOF2

cd - >/dev/null
node --check src/main/resources/static/games/feed.js && echo "✓ feed.js OK"
node --check src/main/resources/static/games/cardgen.js && echo "✓ cardgen.js OK"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R106 — фон виден, плашки-стрелки, сгорание на месте, вопрос"
echo "   git add -A && git commit -m 'R106: level bg visible, arrow stickers, burn in place, question mark' && git push"
echo "═══════════════════════════════════════════════════════"
