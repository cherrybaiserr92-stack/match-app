#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Генератор карты сюжета СДВИГ.
Читает scenarios/*.json и собирает SDVIG-STORY-MAP.md:
события, полные диалоги, развилки с эффектами, улики, концовки,
сквозные нити (story-флаги -> финал) и авто-раздел «где работать».

Запуск из корня репо:  python3 tools/story-map.py
"""
import json, os, collections

ROOT = os.path.join(os.path.dirname(__file__), '..', 'src', 'main', 'resources', 'static', 'scenarios')
OUT  = os.path.join(os.path.dirname(__file__), '..', 'SDVIG-STORY-MAP.md')

# сквозные флаги (STORY_KEYS из app.js) и кто их читает в финале (threads в computeEnding)
STORY_KEYS = ['danny','vivien','cap_fate','stance','pact','choice','curator','arundel','aesthetic','shift']
FINALE_READS = {
    'danny':   {'ally':'Дэнни жив и держит твою сторону', 'jail':'Дэнни сгинул в системе'},
    'choice':  {'rescue':'Спасённые на причале живы', 'track':'Неспасённые — на твоей совести'},
    'pact':    {'trust':'Вивьен сдержала слово', 'wary':'Вивьен ушла своей дорогой'},
    'vivien':  {'vendetta':'Месть Вивьен сошлась с делом'},
    'cap_fate':{'informant':'Капитан — твои глаза в порту'},
    'curator': {'law':'Куратор перед судом', 'fire':'Куратор сгорел в доме'},
}

def load(fid):
    with open(os.path.join(ROOT, fid + '.json'), encoding='utf-8') as f:
        return json.load(f, object_pairs_hook=collections.OrderedDict)

def opts_of(e):
    out = []
    for side in ('left','right','a','b'):
        o = e.get(side)
        if isinstance(o, dict) and ('label' in o or 'to' in o):
            out.append((side, o))
    return out

def fmt_dialogue(s, pad='  '):
    return '\n'.join(pad + '> ' + ln for ln in s.split('\n') if ln.strip())

def fmt_effects(o):
    fx = []
    if o.get('set'):
        fx.append('флаги: ' + ', '.join(f'`{k}={v}`' for k, v in o['set'].items()))
    if isinstance(o.get('rapport'), (int, float)) and o['rapport']:
        fx.append(f"🎩 Сдвиг {o['rapport']:+d}")
    if isinstance(o.get('dscore'), (int, float)) and o['dscore']:
        fx.append(f"🔍 Детектив {o['dscore']:+d}")
    if o.get('clue'):
        fx.append(f"улика: {o['clue'].get('icon','')} {o['clue'].get('name','')}")
    if o.get('bad'):
        fx.append('⚠ плохой исход')
    return ' · '.join(fx) if fx else '—'

def main():
    camp = load('campaign')
    order = [c['id'] for c in camp['cases']]

    issues = []              # (уровень, текст проблемы) -> раздел «где работать»
    flags_set = collections.defaultdict(list)   # flag -> [(fid, ev, side, value)]
    lines = []
    w = lines.append

    w('# СДВИГ — Карта сюжета')
    w('')
    w('_Автогенерация: `python3 tools/story-map.py` (не редактируй руками — правь сценарии)._')
    w('')
    w(f'Уровней в кампании: **{len(order)}**. Легенда: 🎬 линейное · 🔀 развилка · 🧠 ВЕРСИЯ (дедукция) · 🔍 улика (мини-игра).')
    w('')

    cur_ch = None
    for fid in order:
        d = load(fid)
        ev = d['events']
        ch = d.get('chapter', '?')
        if ch != cur_ch:
            cur_ch = ch
            w(f'\n---\n\n# Глава {ch}')
        w(f'\n## {fid} — «{d.get("name","")}»')

        truth = d.get('truth', {})
        if truth:
            w(f'\n**Правда дела:** ' + ', '.join(f'`{k}={v}`' for k, v in truth.items()) +
              ' — выигрыш, если игрок пришёл к этому выводу на ВЕРСИЯ-развилке.')
        else:
            w('\n**Правда дела:** нет (уровень без «провала» — драма/эпилог).')

        e_end = d.get('endings', {})
        if e_end:
            w('\n**Концовки:**')
            for kind in ('win','partial','fail'):
                if kind in e_end:
                    en = e_end[kind]
                    w(f'- **{kind}** {en.get("mark","")} «{en.get("verdict","")}» — {en.get("text","")}')

        w('\n### События')
        for k, e in ev.items():
            kind = ('🧠 ВЕРСИЯ' if e.get('shift')
                    else '🎬 линейное' if e.get('linear')
                    else '🔀 развилка')
            has_clue = ' · 🔍 улика' if e.get('clue') else ''
            w(f'\n#### [{k}] {e.get("badge","")} / {e.get("title","")}  — {kind}{has_clue}')
            if e.get('text'):
                w(f'\n_{e["text"]}_')
            if e.get('intro'):
                w(f'\n_Интро карты:_ {e["intro"]}')
            if e.get('dialogue'):
                w('')
                w(fmt_dialogue(e['dialogue']))
            if e.get('hint'):
                w(f'\n💡 **Наводка:** {e["hint"]}')
            if e.get('clue'):
                c = e['clue']
                w(f'\n🔍 **Улика:** {c.get("icon","")} **{c.get("name","")}** — {c.get("proof","")}')
            if e.get('react'):
                w('\n**Реакция после улики:**')
                w(fmt_dialogue(e['react']))
            if e.get('linear'):
                w(f'\n→ далее: `{e.get("next","?")}`')
            for side, o in opts_of(e):
                to = o.get('to') or o.get('next') or '?'
                arrow = '◀' if side in ('left','a') else '▶'
                w(f'\n- {arrow} **«{o.get("label","")}»** → `{to}`')
                w(f'  - эффекты: {fmt_effects(o)}')
                if o.get('evidence'):
                    w(f'  - _последствие («твой ход»):_ {o["evidence"]}')
                else:
                    if not e.get('shift'):
                        issues.append((fid, f'[{k}].{side} «{o.get("label","")}» — нет текста последствия (бит «твой ход» не покажется)'))
                if o.get('set'):
                    for fk, fv in o['set'].items():
                        flags_set[fk].append((fid, k, side, fv))

        # ── авто-анализ уровня ──
        clue_events = [k for k, e in ev.items() if e.get('clue')]
        if not clue_events:
            issues.append((fid, 'нет ни одной улики (мини-игра не даёт находку) — намеренно только для экшн/драма-уровней'))
        for k, e in ev.items():
            os_ = opts_of(e)
            if e.get('shift') or e.get('linear') or len(os_) < 2:
                continue
            (s1, o1), (s2, o2) = os_[0], os_[1]
            same_to = (o1.get('to') == o2.get('to'))
            diff = (json.dumps(o1.get('set')) != json.dumps(o2.get('set'))
                    or o1.get('rapport') != o2.get('rapport')
                    or o1.get('dscore') != o2.get('dscore')
                    or bool(o1.get('clue')) != bool(o2.get('clue')))
            if same_to and not diff:
                issues.append((fid, f'[{k}] пустой выбор: обе опции ведут в `{o1.get("to")}` без различий в эффектах'))
        # суммарный потенциал шкал
        rp = sum(max(0, o.get('rapport') or 0) for _, e in ev.items() for _, o in opts_of(e))
        dp = sum(max(0, o.get('dscore') or 0) for _, e in ev.items() for _, o in opts_of(e))
        w(f'\n**Потенциал уровня:** 🎩 до +{rp} · 🔍 до +{dp} · улик: {len(clue_events)}')

    # ── сквозные нити ──
    w('\n\n---\n\n# Сквозные нити (влияние на финал)')
    w('\nФлаги из `STORY_KEYS` сохраняются в профиль и читаются в финале кампании (эпилог-нити в `computeEnding`).')
    for fk in STORY_KEYS:
        setters = flags_set.get(fk, [])
        reads = FINALE_READS.get(fk)
        w(f'\n### `{fk}`')
        if setters:
            for fid, k, side, v in setters:
                w(f'- ставится: {fid} [{k}].{side} = `{v}`')
        else:
            w('- ⚠ нигде не ставится')
            issues.append(('finale', f'сквозной флаг `{fk}` из STORY_KEYS нигде не ставится'))
        if reads:
            for v, txt in reads.items():
                w(f'- финал читает `{v}` → «{txt}»')
            set_vals = {v for _, _, _, v in setters}
            for v in reads:
                if v not in set_vals:
                    issues.append(('finale', f'финал ждёт `{fk}={v}`, но ни один выбор его не ставит'))
        else:
            w('- финал не читает (флаг пока ни на что не влияет)')
            if setters:
                issues.append(('finale', f'флаг `{fk}` ставится, но финал его не читает — потенциал для новой нити'))

    # ── где работать ──
    w('\n\n---\n\n# 🔧 Где работать (авто-анализ)')
    if not issues:
        w('\nПроблем не найдено.')
    else:
        by = collections.defaultdict(list)
        for fid, t in issues:
            by[fid].append(t)
        for fid in list(dict.fromkeys([f for f, _ in issues])):
            w(f'\n### {fid}')
            for t in by[fid]:
                w(f'- {t}')

    with open(OUT, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')
    print(f'OK: {OUT} ({len(lines)} строк, {len(issues)} пунктов в «где работать»)')

if __name__ == '__main__':
    main()
