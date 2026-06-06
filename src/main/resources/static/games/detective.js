// ─── САМОЦВЕТЫ · Match-3 ──────────────────────────

const GEMS = ['🔴','🔵','🟢','🟡','🟣','🟠'];
const COLORS = ['red','blue','green','yellow','purple','orange'];
const GEM_CSS = {
    red:'#d95454', blue:'#4a8cdb', green:'#3eb077',
    yellow:'#d4971a', purple:'#8b72d4', orange:'#d4691a'
};

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column',
        alignItems:'center', gap:'12px', width:'100%'
    });

    const ROWS=9, COLS=9;
    const mission = getMission(level);
    let collected=0, iceCleared=0, combo=0;
    let board    = mk2d(ROWS, COLS, null);
    let ice      = mk2d(ROWS, COLS, 0);
    let selR=null, selC=null;
    let active=true, busy=false;

    // Cell size — responsive
    const vw   = Math.min(viewport.offsetWidth || window.innerWidth, 400);
    const GAP  = 3, PAD = 10;
    const CELL = Math.floor((vw - PAD*2 - GAP*(COLS-1)) / COLS);

    // ── Header ───────────────────────────────────
    const hdr = div({
        background:'var(--s1)', border:'1px solid var(--b2)',
        borderRadius:'var(--r)', padding:'10px 14px',
        width:'100%', textAlign:'center',
        fontFamily:'inherit', color:'var(--tx)', fontSize:'13px'
    });
    const lvlEl = div({fontSize:'10px',letterSpacing:'2px',color:'var(--tx3)',
        fontWeight:'700',textTransform:'uppercase',marginBottom:'4px'});
    lvlEl.textContent = 'УРОВЕНЬ ' + level;
    const msnEl = div({fontWeight:'600'});
    const cmbEl = div({fontSize:'11px',color:'var(--amber)',fontWeight:'700',
        letterSpacing:'1px',minHeight:'16px',marginTop:'4px'});
    hdr.append(lvlEl, msnEl, cmbEl);
    viewport.appendChild(hdr);
    refreshMission();

    // ── Grid ─────────────────────────────────────
    const grid = div({
        display:'grid',
        gridTemplateColumns:`repeat(${COLS}, ${CELL}px)`,
        gap: GAP+'px',
        background:'var(--s1)',
        padding: PAD+'px',
        borderRadius:'var(--r-xl)',
        border:'1px solid var(--b2)',
        boxShadow:'0 12px 40px rgba(0,0,0,.4)'
    });
    viewport.appendChild(grid);

    const cells = mk2d(ROWS, COLS, null);

    for (let r=0;r<ROWS;r++) {
        for (let c=0;c<COLS;c++) {
            const cell = div({
                width: CELL+'px', height: CELL+'px',
                borderRadius:'6px',
                display:'flex', alignItems:'center', justifyContent:'center',
                fontSize: Math.max(16, CELL-12)+'px',
                cursor:'pointer',
                border:'1.5px solid transparent',
                transition:'transform .1s, border-color .1s, background .1s',
                lineHeight:'1', userSelect:'none', WebkitUserSelect:'none',
                flexShrink:'0'
            });
            cell.addEventListener('click', ((r,c)=>()=>onCell(r,c))(r,c));
            grid.appendChild(cell);
            cells[r][c] = cell;
        }
    }

    // ── Render ───────────────────────────────────
    function render() {
        for (let r=0;r<ROWS;r++) {
            for (let c=0;c<COLS;c++) {
                const el    = cells[r][c];
                const color = board[r][c];
                const isIce = ice[r][c] > 0;
                const isSel = selR===r && selC===c;
                const gemIdx= COLORS.indexOf(color);
                el.textContent = GEMS[gemIdx] ?? '';
                el.style.background    = isIce ? 'rgba(74,140,219,.18)' : 'var(--s2)';
                el.style.borderColor   = isSel  ? 'var(--amber)'
                                       : isIce  ? 'rgba(74,140,219,.5)'
                                       : 'transparent';
                el.style.boxShadow     = isSel ? '0 0 0 2px var(--amber)' : 'none';
                el.style.transform     = isSel ? 'scale(1.1)' : 'scale(1)';
                el.style.filter        = isIce && ice[r][c]===2
                    ? 'brightness(.55) saturate(.4)'
                    : isIce ? 'brightness(.75) saturate(.6)' : 'none';
            }
        }
    }

    // ── Match logic ──────────────────────────────
    function matches() {
        const m = new Set();
        for (let r=0;r<ROWS;r++){
            let l=1;
            for (let c=1;c<=COLS;c++){
                if (c<COLS && board[r][c]===board[r][c-1]) l++;
                else { if(l>=3) for(let i=c-l;i<c;i++) m.add(r+','+i); l=1; }
            }
        }
        for (let c=0;c<COLS;c++){
            let l=1;
            for (let r=1;r<=ROWS;r++){
                if (r<ROWS && board[r][c]===board[r-1][c]) l++;
                else { if(l>=3) for(let i=r-l;i<r;i++) m.add(i+','+c); l=1; }
            }
        }
        return m;
    }

    function processMatches(m) {
        let gcol=0, gice=0;
        for (const k of m) {
            const [r,c] = k.split(',').map(Number);
            if (ice[r][c]>0) { ice[r][c]--; if (ice[r][c]===0) gice++; }
        }
        for (const k of m) {
            const [r,c] = k.split(',').map(Number);
            if (ice[r][c]===0 && mission.color && board[r][c]===mission.color) gcol++;
        }
        for (const k of m) {
            const [r,c] = k.split(',').map(Number);
            board[r][c] = null; ice[r][c] = 0;
        }
        collected  += gcol; iceCleared += gice; combo++;
        if (combo > 1) {
            cmbEl.textContent = '✨ COMBO ×'+combo+'!';
            setTimeout(()=>{cmbEl.textContent='';}, 1100);
        }
        refreshMission(); checkWin();
    }

    function gravity() {
        for (let c=0;c<COLS;c++) {
            const g=[], ic=[];
            for (let r=ROWS-1;r>=0;r--)
                if (board[r][c]!==null) { g.push(board[r][c]); ic.push(ice[r][c]); }
            while (g.length<ROWS){ g.push(COLORS[rnd(COLORS.length)]); ic.push(0); }
            g.reverse(); ic.reverse();
            for (let r=0;r<ROWS;r++) { board[r][c]=g[r]; ice[r][c]=ic[r]; }
        }
    }

    async function resolve() {
        if (busy) return; busy=true;
        let any=true;
        while (any && active) {
            const m = matches();
            if (!m.size) { any=false; break; }
            processMatches(m);
            if (!active) break;
            gravity(); render();
            await wait(75);
        }
        busy=false;
        if (active && !hasMoves()) shuffle();
        render();
    }

    function hasMoves() {
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) {
            if (c+1<COLS) { sw(r,c,r,c+1); if(matches().size){sw(r,c,r,c+1);return true;} sw(r,c,r,c+1); }
            if (r+1<ROWS) { sw(r,c,r+1,c); if(matches().size){sw(r,c,r+1,c);return true;} sw(r,c,r+1,c); }
        }
        return false;
    }

    function shuffle() {
        const flat = board.flat();
        for (let i=flat.length-1;i>0;i--){ const j=rnd(i+1); [flat[i],flat[j]]=[flat[j],flat[i]]; }
        let idx=0;
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) board[r][c]=flat[idx++];
        resolve();
    }

    function sw(r1,c1,r2,c2){
        [board[r1][c1],board[r2][c2]]=[board[r2][c2],board[r1][c1]];
        [ice[r1][c1],ice[r2][c2]]=[ice[r2][c2],ice[r1][c1]];
    }

    async function trySwap(r1,c1,r2,c2) {
        if (busy||!active) return;
        sw(r1,c1,r2,c2);
        if (matches().size) { combo=0; render(); await resolve(); }
        else { sw(r1,c1,r2,c2); render(); }
    }

    function onCell(r,c) {
        if (busy||!active) return;
        if (selR===null) { selR=r; selC=c; render(); return; }
        if (selR===r&&selC===c) { selR=null; selC=null; render(); return; }
        const adj = Math.abs(selR-r)+Math.abs(selC-c)===1;
        if (!adj) { selR=r; selC=c; render(); return; }
        const [r1,c1]=[selR,selC]; selR=null; selC=null;
        trySwap(r1,c1,r,c);
    }

    // ── Board init ───────────────────────────────
    function initBoard() {
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) {
            const no=new Set();
            if (c>=2&&board[r][c-1]===board[r][c-2]) no.add(board[r][c-1]);
            if (r>=2&&board[r-1][c]===board[r-2][c]) no.add(board[r-1][c]);
            const ok=COLORS.filter(x=>!no.has(x));
            board[r][c]=ok[rnd(ok.length)]||COLORS[0];
        }
    }

    function placeIce() {
        const n = mission.type==='clear_ice' ? mission.target
                : mission.targetIce || 0;
        if (!n) return;
        const pos=[];
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) pos.push([r,c]);
        pos.sort(()=>Math.random()-.5);
        for (let i=0;i<Math.min(n,pos.length);i++) {
            const [r,c]=pos[i]; ice[r][c]= level>25?2:1;
        }
    }

    function checkWin() {
        const done =
            mission.type==='collect'   ? collected>=mission.target :
            mission.type==='clear_ice' ? iceCleared>=mission.target :
            collected>=mission.targetCollect && iceCleared>=mission.targetIce;
        if (done&&active) { active=false; onWin(); }
    }

    function refreshMission() {
        const gem = GEMS[COLORS.indexOf(mission.color)] || '';
        if (mission.type==='collect')
            msnEl.textContent=`${gem} Собери: ${collected} / ${mission.target}`;
        else if (mission.type==='clear_ice')
            msnEl.textContent=`❄️ Разморозь: ${iceCleared} / ${mission.target}`;
        else
            msnEl.textContent=`${gem} ${collected}/${mission.targetCollect}  ❄️ ${iceCleared}/${mission.targetIce}`;
    }

    initBoard(); placeIce(); render();
    if (!hasMoves()) shuffle();
}

// ── Helpers ───────────────────────────────────────
function getMission(l) {
    if (l<=5)  return {type:'collect', color:'blue',   target:10+l};
    if (l<=10) return {type:'collect', color:'green',  target:15+(l-5)*2};
    if (l<=15) return {type:'collect', color:'purple', target:20+(l-10)*3};
    if (l<=20) return {type:'clear_ice', target:5+(l-15)};
    return {type:'mixed',color:'blue',targetCollect:20+(l-20)*2,targetIce:8+Math.floor((l-20)/2)};
}
function mk2d(r,c,v){return Array.from({length:r},()=>Array(c).fill(v))}
function rnd(n){return Math.floor(Math.random()*n)}
function wait(ms){return new Promise(r=>setTimeout(r,ms))}
function div(styles){ const d=document.createElement('div'); Object.assign(d.style,styles); return d; }

export function destroy() {}

