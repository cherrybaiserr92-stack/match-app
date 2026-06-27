#!/usr/bin/env bash
# СДВИГ R91 — третья мини-игра «Взлом» (головоломка с ходами) на куб и в аркады
set -e
echo "══ штамп → R91 ══"
sed -i "s/SDVIG_BUILD='R90'/SDVIG_BUILD='R91'/" src/main/resources/static/app.js
sed -i 's/>R90</>R91</' src/main/resources/static/index.html

echo ""; echo "══ 1/4  создаём games/lockpick.js ═════════════════"
echo "Lyog4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQCiAgINCh0JTQktCY0JMgwrcg0JzQuNC90Lgt0LjQs9GA0LAgwqvQktCX0JvQntCcwrsgKNCz0L7Qu9C+0LLQvtC70L7QvNC60LAg0YEg0YXQvtC00LDQvNC4KQogICDQmtC+0L3RgtGA0LDQutGCOiBMb2NrcGljay5zdGFydChjb250YWluZXIse21pc3Npb24sb25XaW4sb25Mb3NlfSkgLyAuc3RvcCgpCiAgINCf0L7QtNCx0LXRgNC4INC60L7QvNCx0LjQvdCw0YbQuNGOINC30LDQvNC60LAg0LfQsCBOINGF0L7QtNC+0LIuINCf0L7RgdC70LUg0LrQsNC20LTQvtC5INC/0L7Qv9GL0YLQutC4IOKAlAogICDQv9C+0LTRgdC60LDQt9C60Lg6INGG0LjRhNGA0LAg0L3QsCDQvNC10YHRgtC1ICjil48pINC40LvQuCDQtdGB0YLRjCwg0L3QviDQvdC1INGC0LDQvCAo4peLKS4K4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQICovCihmdW5jdGlvbigpewogIHZhciByb290LG9wdHM9bnVsbCxydW5uaW5nPWZhbHNlOwogIHZhciBMRU49MywgRElHSVRTPTYsIGNvZGU9W10sIGd1ZXNzZXM9W10sIGN1cj1bXSwgbW92ZXNMZWZ0PTAsIG1heE1vdmVzPTg7CgogIGZ1bmN0aW9uIHJuZChuKXtyZXR1cm4gKE1hdGgucmFuZG9tKCkqbil8MDt9CgogIGZ1bmN0aW9uIGdlbkNvZGUoKXsKICAgIGNvZGU9W107CiAgICBmb3IodmFyIGk9MDtpPExFTjtpKyspIGNvZGUucHVzaChybmQoRElHSVRTKSsxKTsKICB9CgogIC8vINC/0L7QtNGB0LrQsNC30LrQuDogaG93IG1hbnkgZXhhY3QgKHJpZ2h0IGRpZ2l0ICYgcGxhY2UpLCBob3cgbWFueSBwcmVzZW50IChyaWdodCBkaWdpdCB3cm9uZyBwbGFjZSkKICBmdW5jdGlvbiBldmFsdWF0ZShnKXsKICAgIHZhciBleGFjdD0wLHByZXNlbnQ9MDsKICAgIHZhciBjYz1jb2RlLnNsaWNlKCksIGdnPWcuc2xpY2UoKTsKICAgIC8vINGC0L7Rh9C90YvQtQogICAgZm9yKHZhciBpPTA7aTxMRU47aSsrKXsgaWYoZ2dbaV09PT1jY1tpXSl7IGV4YWN0Kys7IGNjW2ldPS0xOyBnZ1tpXT0tMjsgfSB9CiAgICAvLyDQv9GA0LjRgdGD0YLRgdGC0LLRg9C10YIg0L3QtSDQvdCwINC80LXRgdGC0LUKICAgIGZvcih2YXIgaT0wO2k8TEVOO2krKyl7CiAgICAgIGlmKGdnW2ldPDApIGNvbnRpbnVlOwogICAgICB2YXIgaWR4PWNjLmluZGV4T2YoZ2dbaV0pOwogICAgICBpZihpZHg+PTApeyBwcmVzZW50Kys7IGNjW2lkeF09LTE7IH0KICAgIH0KICAgIHJldHVybiB7ZXhhY3Q6ZXhhY3QscHJlc2VudDpwcmVzZW50fTsKICB9CgogIGZ1bmN0aW9uIHJlbmRlcigpewogICAgdmFyIHJvd3M9Jyc7CiAgICBmb3IodmFyIHI9MDtyPGd1ZXNzZXMubGVuZ3RoO3IrKyl7CiAgICAgIHZhciBnPWd1ZXNzZXNbcl07CiAgICAgIHZhciBjZWxscz0nJzsKICAgICAgZm9yKHZhciBpPTA7aTxMRU47aSsrKXsKICAgICAgICBjZWxscys9JzxkaXYgY2xhc3M9ImxwLWNlbGwgbHAtcGFzdCI+JytnLnZhbFtpXSsnPC9kaXY+JzsKICAgICAgfQogICAgICAvLyDQv9C40L3RiyDQv9C+0LTRgdC60LDQt9C+0LoKICAgICAgdmFyIHBpbnM9Jyc7CiAgICAgIGZvcih2YXIgZT0wO2U8Zy5yZXMuZXhhY3Q7ZSsrKSBwaW5zKz0nPHNwYW4gY2xhc3M9ImxwLXBpbiBscC1leGFjdCI+PC9zcGFuPic7CiAgICAgIGZvcih2YXIgcD0wO3A8Zy5yZXMucHJlc2VudDtwKyspIHBpbnMrPSc8c3BhbiBjbGFzcz0ibHAtcGluIGxwLXByZXNlbnQiPjwvc3Bhbj4nOwogICAgICBmb3IodmFyIG09MDttPExFTi1nLnJlcy5leGFjdC1nLnJlcy5wcmVzZW50O20rKykgcGlucys9JzxzcGFuIGNsYXNzPSJscC1waW4gbHAtbWlzcyI+PC9zcGFuPic7CiAgICAgIHJvd3MrPSc8ZGl2IGNsYXNzPSJscC1yb3ciPicrY2VsbHMrJzxkaXYgY2xhc3M9ImxwLXBpbnMiPicrcGlucysnPC9kaXY+PC9kaXY+JzsKICAgIH0KICAgIC8vINGC0LXQutGD0YnQsNGPINGB0YLRgNC+0LrQsCDQstCy0L7QtNCwCiAgICB2YXIgY3VyQ2VsbHM9Jyc7CiAgICBmb3IodmFyIGk9MDtpPExFTjtpKyspewogICAgICBjdXJDZWxscys9JzxkaXYgY2xhc3M9ImxwLWNlbGwgbHAtY3VyJysoY3VyW2ldPycnOicgbHAtZW1wdHknKSsnIiBkYXRhLXBvcz0iJytpKyciPicrKGN1cltpXXx8J8K3JykrJzwvZGl2Pic7CiAgICB9CiAgICB2YXIgcGFkPScnOwogICAgZm9yKHZhciBkPTE7ZDw9RElHSVRTO2QrKykgcGFkKz0nPGJ1dHRvbiBjbGFzcz0ibHAta2V5IiBkYXRhLWQ9IicrZCsnIj4nK2QrJzwvYnV0dG9uPic7CgogICAgcm9vdC5pbm5lckhUTUw9CiAgICAgICc8ZGl2IGNsYXNzPSJscC13cmFwIj4nKwogICAgICAgICc8ZGl2IGNsYXNzPSJscC1oZWFkIj48c3BhbiBjbGFzcz0ibHAtdGl0bGUiPtCS0JfQm9Ce0Jwg0JfQkNCc0JrQkDwvc3Bhbj4nKwogICAgICAgICAgJzxzcGFuIGNsYXNzPSJscC1tb3ZlcyI+0KXQvtC00L7QsjogPGI+Jyttb3Zlc0xlZnQrJzwvYj48L3NwYW4+PC9kaXY+JysKICAgICAgICAnPGRpdiBjbGFzcz0ibHAtYm9hcmQiPicrcm93cysKICAgICAgICAgICc8ZGl2IGNsYXNzPSJscC1yb3cgbHAtYWN0aXZlIj4nK2N1ckNlbGxzKyc8ZGl2IGNsYXNzPSJscC1waW5zIj48L2Rpdj48L2Rpdj4nKwogICAgICAgICc8L2Rpdj4nKwogICAgICAgICc8ZGl2IGNsYXNzPSJscC1sZWdlbmQiPuKXjyDQvdCwINC80LXRgdGC0LUmbmJzcDsmbmJzcDvil4sg0LXRgdGC0YwsINC90LUg0YLQsNC8Jm5ic3A7Jm5ic3A7wrcg0LzQuNC80L48L2Rpdj4nKwogICAgICAgICc8ZGl2IGNsYXNzPSJscC1wYWQiPicrcGFkKyc8L2Rpdj4nKwogICAgICAgICc8ZGl2IGNsYXNzPSJscC1hY3Rpb25zIj4nKwogICAgICAgICAgJzxidXR0b24gY2xhc3M9ImxwLWNsZWFyIiBpZD0ibHAtY2xlYXIiPtCh0LHRgNC+0YE8L2J1dHRvbj4nKwogICAgICAgICAgJzxidXR0b24gY2xhc3M9ImxwLXRyeSIgaWQ9ImxwLXRyeSI+0J/RgNC+0LLQtdGA0LjRgtGMPC9idXR0b24+JysKICAgICAgICAnPC9kaXY+JysKICAgICAgJzwvZGl2Pic7CgogICAgLy8g0L7QsdGA0LDQsdC+0YLRh9C40LrQuAogICAgcm9vdC5xdWVyeVNlbGVjdG9yQWxsKCcubHAta2V5JykuZm9yRWFjaChmdW5jdGlvbihiKXsKICAgICAgYi5vbmNsaWNrPWZ1bmN0aW9uKCl7IGFkZERpZ2l0KHBhcnNlSW50KHRoaXMuZ2V0QXR0cmlidXRlKCdkYXRhLWQnKSwxMCkpOyB9OwogICAgfSk7CiAgICByb290LnF1ZXJ5U2VsZWN0b3IoJyNscC1jbGVhcicpLm9uY2xpY2s9ZnVuY3Rpb24oKXsgY3VyPVtdOyByZW5kZXIoKTsgfTsKICAgIHJvb3QucXVlcnlTZWxlY3RvcignI2xwLXRyeScpLm9uY2xpY2s9dHJ5R3Vlc3M7CiAgfQoKICBmdW5jdGlvbiBhZGREaWdpdChkKXsKICAgIGlmKGN1ci5sZW5ndGg+PUxFTil7IGN1cj1bXTsgfQogICAgY3VyLnB1c2goZCk7IHJlbmRlcigpOwogIH0KCiAgZnVuY3Rpb24gdHJ5R3Vlc3MoKXsKICAgIGlmKGN1ci5sZW5ndGg8TEVOKXsgc2hha2UoKTsgcmV0dXJuOyB9CiAgICB2YXIgcmVzPWV2YWx1YXRlKGN1cik7CiAgICBndWVzc2VzLnB1c2goe3ZhbDpjdXIuc2xpY2UoKSxyZXM6cmVzfSk7CiAgICBtb3Zlc0xlZnQtLTsKICAgIHRyeXtuYXZpZ2F0b3IudmlicmF0ZSYmbmF2aWdhdG9yLnZpYnJhdGUoMTUpO31jYXRjaChfKXt9CiAgICBpZihyZXMuZXhhY3Q9PT1MRU4peyBjdXI9W107IHJlbmRlcigpOyB3aW4oKTsgcmV0dXJuOyB9CiAgICBjdXI9W107CiAgICBpZihtb3Zlc0xlZnQ8PTApeyByZW5kZXIoKTsgbG9zZSgpOyByZXR1cm47IH0KICAgIHJlbmRlcigpOwogIH0KCiAgZnVuY3Rpb24gc2hha2UoKXsKICAgIHZhciBhPXJvb3QucXVlcnlTZWxlY3RvcignLmxwLWFjdGl2ZScpOwogICAgaWYoYSl7IGEuc3R5bGUuYW5pbWF0aW9uPSdscFNoYWtlIC4zcyc7IHNldFRpbWVvdXQoZnVuY3Rpb24oKXthLnN0eWxlLmFuaW1hdGlvbj0nJzt9LDMwMCk7IH0KICB9CgogIGZ1bmN0aW9uIHdpbigpeyBydW5uaW5nPWZhbHNlOyBmbGFzaCgnIzQ2ZDg5YicsJ9CX0JDQnNCe0Jog0J7QotCa0KDQq9CiJyk7IHNldFRpbWVvdXQoZnVuY3Rpb24oKXtvcHRzJiZvcHRzLm9uV2luJiZvcHRzLm9uV2luKCk7fSw4MDApOyB9CiAgZnVuY3Rpb24gbG9zZSgpeyBydW5uaW5nPWZhbHNlOyBmbGFzaCgnI2Q4NDY0NicsJ9CX0JDQmtCb0JjQndCY0JvQnicpOyBzZXRUaW1lb3V0KGZ1bmN0aW9uKCl7b3B0cyYmb3B0cy5vbkxvc2UmJm9wdHMub25Mb3NlKCk7fSw4MDApOyB9CgogIGZ1bmN0aW9uIGZsYXNoKGNvbCxtc2cpewogICAgdmFyIG89ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnZGl2Jyk7CiAgICBvLnN0eWxlLmNzc1RleHQ9J3Bvc2l0aW9uOmFic29sdXRlO2luc2V0OjA7ZGlzcGxheTpmbGV4O2FsaWduLWl0ZW1zOmNlbnRlcjtqdXN0aWZ5LWNvbnRlbnQ6Y2VudGVyOycrCiAgICAgICdiYWNrZ3JvdW5kOnJnYmEoOCw4LDExLC44KTtjb2xvcjonK2NvbCsnO2ZvbnQ6ODAwIDIycHggVW5ib3VuZGVkLHNhbnMtc2VyaWY7bGV0dGVyLXNwYWNpbmc6LjFlbTsnKwogICAgICAnYm9yZGVyLXJhZGl1czoxNHB4O3otaW5kZXg6NTthbmltYXRpb246bHBGYWRlIC40czsnOwogICAgby50ZXh0Q29udGVudD1tc2c7IHJvb3QuYXBwZW5kQ2hpbGQobyk7CiAgfQoKICBmdW5jdGlvbiBpbmplY3RDU1MoKXsKICAgIGlmKGRvY3VtZW50LmdldEVsZW1lbnRCeUlkKCdscC1jc3MnKSkgcmV0dXJuOwogICAgdmFyIHM9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnc3R5bGUnKTsgcy5pZD0nbHAtY3NzJzsKICAgIHMudGV4dENvbnRlbnQ9CiAgICAnLmxwLXdyYXB7cG9zaXRpb246cmVsYXRpdmU7d2lkdGg6MTAwJTttYXgtd2lkdGg6MzgwcHg7bWFyZ2luOjAgYXV0bztjb2xvcjojZThlMmQ0O2ZvbnQtZmFtaWx5OkludGVyLHNhbnMtc2VyaWY7cGFkZGluZzo4cHg7fScrCiAgICAnLmxwLWhlYWR7ZGlzcGxheTpmbGV4O2p1c3RpZnktY29udGVudDpzcGFjZS1iZXR3ZWVuO2FsaWduLWl0ZW1zOmNlbnRlcjttYXJnaW4tYm90dG9tOjE0cHg7fScrCiAgICAnLmxwLXRpdGxle2ZvbnQ6ODAwIDE0cHggVW5ib3VuZGVkLHNhbnMtc2VyaWY7bGV0dGVyLXNwYWNpbmc6LjEyZW07Y29sb3I6I2ZmY2Y2Yjt9JysKICAgICcubHAtbW92ZXN7Zm9udC1zaXplOjEzcHg7Y29sb3I6IzlhYThiODt9LmxwLW1vdmVzIGJ7Y29sb3I6I2ZmZjt9JysKICAgICcubHAtYm9hcmR7ZGlzcGxheTpmbGV4O2ZsZXgtZGlyZWN0aW9uOmNvbHVtbjtnYXA6N3B4O21hcmdpbi1ib3R0b206MTJweDttaW4taGVpZ2h0OjQwcHg7fScrCiAgICAnLmxwLXJvd3tkaXNwbGF5OmZsZXg7YWxpZ24taXRlbXM6Y2VudGVyO2dhcDo4cHg7fScrCiAgICAnLmxwLWNlbGx7d2lkdGg6NDJweDtoZWlnaHQ6NDJweDtib3JkZXItcmFkaXVzOjEwcHg7ZGlzcGxheTpmbGV4O2FsaWduLWl0ZW1zOmNlbnRlcjtqdXN0aWZ5LWNvbnRlbnQ6Y2VudGVyOycrCiAgICAgICdmb250OjcwMCAyMHB4ICJQbGF5ZmFpciBEaXNwbGF5IixzZXJpZjtiYWNrZ3JvdW5kOnJnYmEoMCwwLDAsLjMpO2JvcmRlcjoxcHggc29saWQgcmdiYSgyNTUsMjU1LDI1NSwuMDgpO30nKwogICAgJy5scC1wYXN0e2JhY2tncm91bmQ6cmdiYSgyMDAsMTM0LDEwLC4xMik7Ym9yZGVyLWNvbG9yOnJnYmEoMjAwLDEzNCwxMCwuMjUpO2NvbG9yOiNlMGIwNTc7fScrCiAgICAnLmxwLWN1cntib3JkZXItY29sb3I6cmdiYSgyMDAsMTM0LDEwLC40KTtiYWNrZ3JvdW5kOnJnYmEoMCwwLDAsLjQpO30nKwogICAgJy5scC1lbXB0eXtjb2xvcjojNDY1MDYwODA7fScrCiAgICAnLmxwLWFjdGl2ZSAubHAtY2VsbHtib3JkZXItY29sb3I6cmdiYSgyMDAsMTM0LDEwLC41KTt9JysKICAgICcubHAtcGluc3tkaXNwbGF5OmZsZXg7ZmxleC13cmFwOndyYXA7Z2FwOjNweDt3aWR0aDozNHB4O21hcmdpbi1sZWZ0OjRweDt9JysKICAgICcubHAtcGlue3dpZHRoOjlweDtoZWlnaHQ6OXB4O2JvcmRlci1yYWRpdXM6NTAlO30nKwogICAgJy5scC1leGFjdHtiYWNrZ3JvdW5kOiM0NmQ4OWI7fS5scC1wcmVzZW50e2JhY2tncm91bmQ6I2ZmY2Y2Yjt9JysKICAgICcubHAtbWlzc3tiYWNrZ3JvdW5kOnJnYmEoMjU1LDI1NSwyNTUsLjEyKTt9JysKICAgICcubHAtbGVnZW5ke2ZvbnQtc2l6ZToxMXB4O2NvbG9yOiM3YTg0OTQ7dGV4dC1hbGlnbjpjZW50ZXI7bWFyZ2luLWJvdHRvbToxNHB4O30nKwogICAgJy5scC1wYWR7ZGlzcGxheTpncmlkO2dyaWQtdGVtcGxhdGUtY29sdW1uczpyZXBlYXQoNiwxZnIpO2dhcDo3cHg7bWFyZ2luLWJvdHRvbToxMnB4O30nKwogICAgJy5scC1rZXl7YXNwZWN0LXJhdGlvOjE7Ym9yZGVyOm5vbmU7Ym9yZGVyLXJhZGl1czoxMHB4O2JhY2tncm91bmQ6bGluZWFyLWdyYWRpZW50KDEzNWRlZywjMmEyNjIwLCMxYTE3MTQpOycrCiAgICAgICdjb2xvcjojZTBiMDU3O2ZvbnQ6NzAwIDE4cHggIlBsYXlmYWlyIERpc3BsYXkiLHNlcmlmO2N1cnNvcjpwb2ludGVyO2JvcmRlcjoxcHggc29saWQgcmdiYSgyMDAsMTM0LDEwLC4yKTsnKwogICAgICAndHJhbnNpdGlvbjp0cmFuc2Zvcm0gLjFzO30nKwogICAgJy5scC1rZXk6YWN0aXZle3RyYW5zZm9ybTpzY2FsZSguOTIpO2JhY2tncm91bmQ6cmdiYSgyMDAsMTM0LDEwLC4yNSk7fScrCiAgICAnLmxwLWFjdGlvbnN7ZGlzcGxheTpmbGV4O2dhcDoxMHB4O30nKwogICAgJy5scC1jbGVhciwubHAtdHJ5e2ZsZXg6MTtwYWRkaW5nOjEzcHg7Ym9yZGVyOm5vbmU7Ym9yZGVyLXJhZGl1czoxMnB4O2ZvbnQ6NzAwIDE0cHggSW50ZXIsc2Fucy1zZXJpZjtjdXJzb3I6cG9pbnRlcjt9JysKICAgICcubHAtY2xlYXJ7YmFja2dyb3VuZDpyZ2JhKDI1NSwyNTUsMjU1LC4wNik7Y29sb3I6IzlhYThiODt9JysKICAgICcubHAtdHJ5e2JhY2tncm91bmQ6bGluZWFyLWdyYWRpZW50KDEzNWRlZywjYzg4NjBhLCNhMDZkMDgpO2NvbG9yOiNmZmY7fScrCiAgICAnLmxwLXRyeTphY3RpdmUsLmxwLWNsZWFyOmFjdGl2ZXt0cmFuc2Zvcm06c2NhbGUoLjk3KTt9JysKICAgICdAa2V5ZnJhbWVzIGxwU2hha2V7MCUsMTAwJXt0cmFuc2Zvcm06dHJhbnNsYXRlWCgwKX0yNSV7dHJhbnNmb3JtOnRyYW5zbGF0ZVgoLTZweCl9NzUle3RyYW5zZm9ybTp0cmFuc2xhdGVYKDZweCl9fScrCiAgICAnQGtleWZyYW1lcyBscEZhZGV7ZnJvbXtvcGFjaXR5OjB9dG97b3BhY2l0eToxfX0nOwogICAgZG9jdW1lbnQuaGVhZC5hcHBlbmRDaGlsZChzKTsKICB9CgogIGZ1bmN0aW9uIHN0YXJ0KGNvbnRhaW5lcixvKXsKICAgIG9wdHM9b3x8e307IHJ1bm5pbmc9dHJ1ZTsKICAgIExFTj0zOyBESUdJVFM9NjsgbWF4TW92ZXM9ODsKICAgIC8vINGB0LvQvtC20L3QvtGB0YLRjCDQvtGCINC80LjRgdGB0LjQuAogICAgaWYob3B0cy5taXNzaW9uJiZvcHRzLm1pc3Npb24udGFyZ2V0KXsKICAgICAgaWYob3B0cy5taXNzaW9uLnRhcmdldD49MTYpeyBMRU49NDsgbWF4TW92ZXM9OTsgfQogICAgfQogICAgbW92ZXNMZWZ0PW1heE1vdmVzOyBndWVzc2VzPVtdOyBjdXI9W107CiAgICBnZW5Db2RlKCk7CiAgICBpbmplY3RDU1MoKTsKICAgIHJvb3Q9ZG9jdW1lbnQuY3JlYXRlRWxlbWVudCgnZGl2Jyk7CiAgICByb290LnN0eWxlLmNzc1RleHQ9J3Bvc2l0aW9uOnJlbGF0aXZlO3dpZHRoOjEwMCU7aGVpZ2h0OjEwMCU7ZGlzcGxheTpmbGV4O2FsaWduLWl0ZW1zOmNlbnRlcjtqdXN0aWZ5LWNvbnRlbnQ6Y2VudGVyO21pbi1oZWlnaHQ6MzgwcHg7JzsKICAgIGNvbnRhaW5lci5pbm5lckhUTUw9Jyc7IGNvbnRhaW5lci5hcHBlbmRDaGlsZChyb290KTsKICAgIHJlbmRlcigpOwogIH0KICBmdW5jdGlvbiBzdG9wKCl7IHJ1bm5pbmc9ZmFsc2U7IH0KCiAgd2luZG93LkxvY2twaWNrPXtzdGFydDpzdGFydCxzdG9wOnN0b3B9Owp9KSgpOwo=" | base64 -d > src/main/resources/static/games/lockpick.js
node --check src/main/resources/static/games/lockpick.js && echo "  ✓ lockpick.js валиден"

echo ""; echo "══ 2/4  подключаем lockpick.js ════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/index.html"
with open(path,encoding="utf-8") as f: txt=f.read()
if 'games/lockpick.js' not in txt:
    txt=txt.replace('<script src="/games/pursuit.js"></script>',
                    '<script src="/games/pursuit.js"></script>\n<script src="/games/lockpick.js"></script>')
    print("  + lockpick.js подключён")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

echo ""; echo "══ 3/4  грань куба board → Взлом ══════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/cube.js"
with open(path,encoding="utf-8") as f: txt=f.read()
old="{id:'board',   name:'Доска улик', ico:'🧷', sub:'Связи',     available:false, c1:'#c86464',c2:'#5e2626'},"
new="{id:'lockpick', name:'Взлом',     ico:'🔓', sub:'Код замка', available:true,  c1:'#c86464',c2:'#5e2626'},"
if old in txt:
    txt=txt.replace(old,new,1); print("  + грань 'lockpick' на кубе")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

python3 - << 'PYEOF'
path="src/main/resources/static/app.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
old='''  } else if(gameId==='pursuit' && window.Pursuit){
    Pursuit.start(vp, { mission, onWin, onLose });
  } else if(gameId==='match3' && window.Match3){'''
new='''  } else if(gameId==='pursuit' && window.Pursuit){
    Pursuit.start(vp, { mission, onWin, onLose });
  } else if(gameId==='lockpick' && window.Lockpick){
    Lockpick.start(vp, { mission, onWin, onLose });
  } else if(gameId==='match3' && window.Match3){'''
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + роутер: lockpick → Lockpick")
old2='''    try{Examine&&Examine.stop();}catch(_){} try{Pursuit&&Pursuit.stop();}catch(_){} try{Match3&&Match3.stop();}catch(_){}'''
new2='''    try{Examine&&Examine.stop();}catch(_){} try{Pursuit&&Pursuit.stop();}catch(_){} try{Lockpick&&Lockpick.stop();}catch(_){} try{Match3&&Match3.stop();}catch(_){}'''
if old2 in txt:
    txt=txt.replace(old2,new2,1); n+=1; print("  + остановка Lockpick")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ app.js: %d"%n)
PYEOF

echo ""; echo "══ 4/4  Взлом в аркады ════════════════════════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/arcade.js"
with open(path,encoding="utf-8") as f: txt=f.read()
old='''    { key:'Pursuit', canvas:true, name:'Слежка', desc:'Не упусти подозреваемого', icon:'👁', opts:{ mission:{target:20} } }
  ];'''
new='''    { key:'Pursuit', canvas:true, name:'Слежка', desc:'Не упусти подозреваемого', icon:'👁', opts:{ mission:{target:20} } },
    { key:'Lockpick', canvas:true, name:'Взлом', desc:'Подбери код замка', icon:'🔓', opts:{ mission:{target:12} } }
  ];'''
if old in txt:
    txt=txt.replace(old,new,1); print("  + Взлом в аркадах")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R91 — «Взлом» (головоломка) на куб и в аркады. ТРИ ИГРЫ ГОТОВЫ."
echo "   git add -A && git commit -m 'R91: Lockpick puzzle mini-game, three mechanics done' && git push"
echo "═══════════════════════════════════════════════════════"
