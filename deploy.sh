#!/usr/bin/env bash
# СДВИГ R45 — большой фикс: сюжет под исчезновение (12+), аватары, дизайн карточки-свайпа
set -e

echo "══ штамп → R45 ══"
sed -i "s/SDVIG_BUILD='R44'/SDVIG_BUILD='R45'/" src/main/resources/static/app.js
sed -i 's/>R44</>R45</' src/main/resources/static/index.html
echo "  + штамп R45"

echo ""; echo "══ 1/4  сюжет — вступление под ИСЧЕЗНОВЕНИЕ (12+) ═══"
python3 - << 'PYEOF'
import json
path="src/main/resources/static/scenarios/case001.json"
d=json.load(open(path,encoding='utf-8'))
ev=d['events']

# Переписываем вступление: НЕ труп, а ИСЧЕЗНОВЕНИЕ. Убираем мистику-проклятие.
INTRO={
 'L1_c1':{'badge':'Октябрь 1987','title':'Дождь над кварталом',
   'text':'Дождь смывал грязь с улиц, но не из людей. Дворники полицейского «Форда» размазывали воду по стеклу — туда, обратно, как маятник, который никуда не ведёт.',
   'dialogue':'Рекрут: «Музей уже оцепили?»\nСдвиг: «Оцепили пустоту, малыш. Директор пропал прямо из запертого зала».'},
 'L1_c2':{'badge':'Напарник','title':'Щелчок диктофона',
   'text':'Человек на пассажирском сиденье не шевелился. Он слушал кассету. Щелчок. Тишина. Щелчок. Будто разбирал чужую речь на детали.',
   'dialogue':'Сдвиг: «Веришь в проклятия, малыш? Городской департамент верит. Боятся войти в музей».\nРекрут: «Я верю в улики. Проклятия их не оставляют».\nСдвиг: «Вот поэтому ты мне и нужен».'},
 'L1_c3':{'badge':'Музей','title':'Готическая глыба',
   'text':'Здание нависло над улицей. Каменные львы у входа блестели от дождя, отсветы мигалок ползли по их мордам.',
   'dialogue':'Рекрут: «По рации сказали — человек исчез из запертой комнаты. Ни окон, ни второго выхода».'},
 'L1_c4':{'badge':'Метод','title':'Сухой смешок',
   'text':'Сдвиг усмехнулся — звук как треск ломающейся ветки.',
   'dialogue':'Сдвиг: «Исчезновение из запертой комнаты. Банально. Люди верят в магию, лишь бы не думать».\nРекрут: «А ты во что веришь?»\nСдвиг: «У каждого фокуса есть механик за кулисами. Пошли искать его».'},
 'L1_c5':{'badge':'Запах','title':'Гроза в помещении',
   'text':'Под лентой — запах старой бумаги, нафталина и чего-то едкого. Озон. Воздух будто наэлектризован.',
   'dialogue':'Сдвиг: «Чувствуешь? Пахнет грозой за закрытой дверью. Запомни этот запах».'},
 'L1_c6':{'badge':'Главный зал','title':'Пустой постамент',
   'text':'Зал с колоннами. В центре — пустой постамент и опрокинутый стул. Директор должен был встречать гостей здесь. Вместо него — тишина и холодный мрамор.',
   'dialogue':'Патрульный: «Клянусь, дверь была заперта изнутри! Горгульи… это проклятие семьи основателя!»'},
 'L1_c7':{'badge':'Дедукция','title':'Следы у входа',
   'text':'Сдвиг не стал слушать про горгулий. Он присел над лужей у входа и тронул её пальцем в перчатке.',
   'dialogue':'Сдвиг: «Проклятие, которое носит одиннадцатый размер и оставляет машинное масло».\nРекрут: «Думаешь, кто-то из своих?»\nСдвиг: «Думаю, призраки не смазывают петли. А кто-то здесь — смазал».'},
 'L1_c8':{'badge':'Куантико','title':'Надевай перчатки',
   'text':'Он поднял на меня взгляд — холоднее ноябрьского ливня. Первое настоящее дело начиналось здесь и сейчас.',
   'dialogue':'Сдвиг: «Время показать, чему тебя учили. Надевай перчатки, рекрут».\nРекрут: «С чего начнём?»\nСдвиг: «С того, что все проглядели. Смотри не глазами — головой».'}
}
for eid,data in INTRO.items():
    if eid in ev:
        ev[eid].update(data)
        # чистим возможные старые поля _split
        ev[eid].pop('_split',None); ev[eid].pop('_split2',None)

# e0 — место преступления БЕЗ трупа
ev['e0'].update({
  'badge':'Октябрь 1987','title':'Пустой постамент',
  'text':'Музей под тридцатифутовым куполом. Зал заперт изнутри, а директора нет — только опрокинутый стул и следы машинного масла на мраморе. Полиция шепчет про проклятие. Сдвиг молчит.',
  'speaker':None
})
ev['e0'].pop('dialogue',None)  # убираем обрывок «проклятие горгулий»

# Чистим остальные упоминания трупа
for k,e in ev.items():
    for field in ['text','title']:
        v=e.get(field,'')
        if v:
            v=v.replace('мёртвый директор','директор').replace('парил мёртвый','исчез').replace('тело висит','человек исчез')
            v=v.replace('Тело под куполом','Пустой постамент').replace('тело','след')
            e[field]=v

json.dump(d,open(path,'w',encoding='utf-8'),ensure_ascii=False,indent=2)
print("  + вступление переписано под исчезновение (12+, без трупа/мистики)")
print(f"  + e0: '{ev['e0']['title']}'")
PYEOF


echo ""; echo "══ 2/4  feed.js — аватар: индивидуальный кроп ══════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Разные персонажи — разный кроп головы. Сдвиг в шляпе (профиль) — нужен особый.
# Делаем data-атрибут с позицией и индивидуальные правила.
# Проще: object-fit на <img> вместо background — точнее кроп.
old_av=".m2-av{width:54px;height:54px;border-radius:13px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;\n      background-size:200% auto;background-position:50% 8%;transition:all .3s;background-repeat:no-repeat;}"
new_av=(".m2-av{width:56px;height:56px;border-radius:13px;flex-shrink:0;overflow:hidden;border:2px solid;position:relative;}\n"
        "    .m2-av img{position:absolute;width:175%;left:-37%;top:6%;max-width:none;}\n"
        "    /* индивидуальный кроп под персонажа */\n"
        "    .m2-av.av-shift img{width:200%;left:-50%;top:2%;}\n"
        "    .m2-av.av-recruit img{width:170%;left:-35%;top:7%;}\n"
        "    .m2-av.av-miller img{width:165%;left:-32%;top:6%;}")
if old_av in txt:
    txt=txt.replace(old_av,new_av,1); n+=1; print("  + аватар через <img> с индивидуальным кропом")

# меняем рендер аватара: background-image → <img> внутри
old_render='el.innerHTML=\'<div class="m2-av" style="background-image:url(\'+av+\')"><span class="m2-ring"></span></div>\'+'
new_render='el.innerHTML=\'<div class="m2-av av-\'+spk+\'"><img src="\'+av+\'"><span class="m2-ring"></span></div>\'+'
if old_render in txt:
    txt=txt.replace(old_render,new_render,1); n+=1; print("  + говорящий аватар = img")

# статичный рендер тоже
old_static='el.innerHTML=\'<div class="m2-av" style="background-image:url(\'+avatar(spk)+\')"></div><div class="m2-body">'
new_static='el.innerHTML=\'<div class="m2-av av-\'+spk+\'"><img src="\'+avatar(spk)+\'"></div><div class="m2-body">'
if old_static in txt:
    txt=txt.replace(old_static,new_static,1); n+=1; print("  + статичный аватар = img")

with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 3/4  feed.js — НОВЫЙ дизайн карточки-свайпа ═════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
n=0
# Переделываем decCardInner — красивая карточка вместо примитивных прямоугольников
old=('''  function decCardInner(ev){
    const lL=ev.shift?(ev.a&&ev.a.label||''):(ev.left&&ev.left.label||'');
    const rL=ev.shift?(ev.b&&ev.b.label||''):(ev.right&&ev.right.label||'');
    return '<div class="fc-pad"><span class="fc-badge">'+(ev.badge||'')+'</span>'+
      '<div class="fc-title">'+(ev.title||'')+'</div>'+
      '<div style="margin-top:12px;display:flex;gap:8px;font-size:11px">'+
      '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(176,80,80,.2);border:1px solid rgba(176,80,80,.4);color:#ff9d85;text-align:center">◄ '+esc(lL.replace(/^◄\\s*/,''))+'</div>'+
      '<div style="flex:1;padding:8px;border-radius:8px;background:rgba(74,155,142,.2);border:1px solid rgba(74,155,142,.4);color:#9fe0ff;text-align:center">'+esc(rL.replace(/\\s*►$/,''))+' ►</div>'+
      '</div></div>';
  }''')
new=('''  function decCardInner(ev){
    const lL=ev.shift?(ev.a&&ev.a.label||''):(ev.left&&ev.left.label||'');
    const rL=ev.shift?(ev.b&&ev.b.label||''):(ev.right&&ev.right.label||'');
    const intro=ev.intro||'Реши, как действовать.';
    return '<div class="dc-inner">'+
      '<span class="dc-badge">'+esc(ev.badge||'РЕШЕНИЕ')+'</span>'+
      '<div class="dc-title">'+esc(ev.title||'')+'</div>'+
      '<div class="dc-intro">'+esc(intro)+'</div>'+
      '<div class="dc-choices">'+
        '<div class="dc-choice left"><span class="dc-arrow">◄</span><span class="dc-lbl">'+esc(lL.replace(/^◄\\s*/,''))+'</span></div>'+
        '<div class="dc-or">или</div>'+
        '<div class="dc-choice right"><span class="dc-lbl">'+esc(rL.replace(/\\s*►$/,''))+'</span><span class="dc-arrow">►</span></div>'+
      '</div></div>';
  }''')
if old in txt:
    txt=txt.replace(old,new,1); n+=1; print("  + новый decCardInner (красивая карточка)")
with open(path,"w",encoding="utf-8") as f: f.write(txt)
print("✓ feed.js: %d"%n)
PYEOF


echo ""; echo "══ 4/4  CSS — стиль новой карточки-свайпа ══════════"
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
if ".dc-inner" not in txt:
    anchor="    .dec-card .fc-pad{"
    css="""    .dc-inner{padding:20px 20px 22px;text-align:center;}
    .dc-badge{display:inline-block;font-family:Unbounded,sans-serif;font-weight:700;font-size:10px;
      letter-spacing:.14em;color:#241701;padding:5px 13px;border-radius:8px;
      background:linear-gradient(180deg,#ffe09a,#c8860a);margin-bottom:12px;}
    .dc-title{font-family:Unbounded,sans-serif;font-weight:900;font-size:20px;line-height:1.12;color:#fff;margin-bottom:8px;}
    .dc-intro{font-size:13px;line-height:1.5;color:#b8b0a0;font-style:italic;margin-bottom:18px;}
    .dc-choices{display:flex;align-items:stretch;gap:8px;}
    .dc-choice{flex:1;display:flex;align-items:center;gap:7px;padding:13px 12px;border-radius:13px;
      font-family:Unbounded,sans-serif;font-weight:700;font-size:12px;line-height:1.2;transition:transform .15s;}
    .dc-choice.left{background:linear-gradient(135deg,rgba(176,80,80,.28),rgba(120,45,45,.16));
      border:1.5px solid rgba(220,120,120,.45);color:#ffb3a0;justify-content:flex-start;text-align:left;}
    .dc-choice.right{background:linear-gradient(135deg,rgba(74,170,150,.28),rgba(40,110,95,.16));
      border:1.5px solid rgba(110,210,185,.45);color:#9fe8d4;justify-content:flex-end;text-align:right;}
    .dc-arrow{font-size:18px;opacity:.8;flex-shrink:0;}
    .dc-lbl{flex:1;}
    .dc-or{display:flex;align-items:center;font-size:10px;color:#7a7264;font-family:Unbounded,sans-serif;
      text-transform:uppercase;letter-spacing:.08em;}
    .dc-choice.left.lit{transform:scale(1.04);box-shadow:0 0 18px rgba(220,120,120,.4);}
    .dc-choice.right.lit{transform:scale(1.04);box-shadow:0 0 18px rgba(110,210,185,.4);}
"""
    txt=txt.replace(anchor,css+anchor,1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + CSS новой карточки-свайпа")
PYEOF

# Подсветка выбора при свайпе
python3 - << 'PYEOF'
path="src/main/resources/static/games/feed.js"
with open(path,encoding="utf-8") as f: txt=f.read()
old=("    card.addEventListener('pointermove',e=>{if(!down)return;const dx=e.clientX-sx;card.style.transform='translateX('+dx*.5+'px) rotate('+dx*.02+'deg)';});")
new=("    card.addEventListener('pointermove',e=>{if(!down)return;const dx=e.clientX-sx;\n"
     "      card.style.transform='translateX('+dx*.5+'px) rotate('+dx*.02+'deg)';\n"
     "      var cl=card.querySelector('.dc-choice.left'),cr=card.querySelector('.dc-choice.right');\n"
     "      if(cl)cl.classList.toggle('lit',dx<-30); if(cr)cr.classList.toggle('lit',dx>30);});")
if old in txt:
    txt=txt.replace(old,new,1)
    with open(path,"w",encoding="utf-8") as f: f.write(txt)
    print("  + подсветка выбора при свайпе")
PYEOF

echo ""
echo "═══════════════════════════════════════════════════════"
echo "✅  R45 — сюжет под исчезновение, аватары, новая карточка"
echo "   git add -A && git commit -m 'R45: rewrite story (disappearance), avatar crop, decision card redesign' && git push"
echo "═══════════════════════════════════════════════════════"
