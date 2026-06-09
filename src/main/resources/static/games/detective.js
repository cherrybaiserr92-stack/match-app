// ═══════════════════════════════════════════════
//  САМОЦВЕТЫ · Match-3 Premium
//  CSS sphere gems · Fall physics · Particles · Bombs
// ═══════════════════════════════════════════════

const GEM_GRAD = {
    red:    'radial-gradient(circle at 38% 32%, #ff9999 0%, #dd1111 50%, #880000 100%)',
    blue:   'radial-gradient(circle at 38% 32%, #99bbff 0%, #1155ee 50%, #001188 100%)',
    green:  'radial-gradient(circle at 38% 32%, #99ffaa 0%, #11bb44 50%, #005511 100%)',
    yellow: 'radial-gradient(circle at 38% 32%, #ffee99 0%, #ddaa11 50%, #885500 100%)',
    purple: 'radial-gradient(circle at 38% 32%, #ee99ff 0%, #aa11ee 50%, #550077 100%)',
    orange: 'radial-gradient(circle at 38% 32%, #ffcc88 0%, #ee7722 50%, #882200 100%)',
    bomb:   'radial-gradient(circle at 38% 32%, #fff799 0%, #ffdd00 50%, #cc8800 100%)',
};
const GEM_GLOW = {
    red:'rgba(200,0,0,.6)',blue:'rgba(10,60,220,.6)',green:'rgba(0,160,50,.6)',
    yellow:'rgba(200,150,0,.6)',purple:'rgba(140,0,210,.6)',orange:'rgba(200,90,0,.6)',
    bomb:'rgba(255,200,0,.8)',
};
const COLORS = ['red','blue','green','yellow','purple','orange'];
const ROWS=9, COLS=9;

let _destroyed = false;

export function initGame(viewport, level, onWin) {
    _destroyed = false;
    viewport.innerHTML = '';
    Object.assign(viewport.style, {
        display:'flex', flexDirection:'column', alignItems:'center',
        gap:'10px', width:'100%', fontFamily:"'DM Sans',sans-serif",
    });

    // ── State ──────────────────────────────────
    const miss = getMission(level);
    let board   = mk2d(ROWS, COLS, null);
    let special = mk2d(ROWS, COLS, null); // 'bomb' | null
    let iceB    = mk2d(ROWS, COLS, 0);
    let colGem=0, iceGem=0, combo=0;
    let active=true, busy=false, selR=null, selC=null;

    // ── Layout ─────────────────────────────────
    const vw   = Math.min(viewport.offsetWidth || window.innerWidth, 420);
    const GAP  = 4, PAD = 10;
    const CELL = Math.floor((vw - PAD*2 - GAP*(COLS-1)) / COLS);

    // ── Header ─────────────────────────────────
    const hdr = d('div');
    css(hdr, {background:'#1a1a2e',borderRadius:'12px',padding:'10px 14px',
        width:'100%',textAlign:'center',color:'#fff',boxShadow:'0 2px 16px rgba(0,0,0,.4)'});
    const lvLbl = d('div');
    css(lvLbl,{fontSize:'10px',letterSpacing:'2px',color:'#8888aa',fontWeight:'700',
        textTransform:'uppercase',marginBottom:'4px',fontFamily:"'Courier Prime',monospace"});
    lvLbl.textContent = 'УРОВЕНЬ ' + level;
    const msLbl = d('div'); css(msLbl,{fontSize:'13px',fontWeight:'600',color:'#eee'});
    const cmLbl = d('div'); css(cmLbl,{fontSize:'12px',color:'#ffd700',fontWeight:'800',
        letterSpacing:'2px',minHeight:'18px',marginTop:'4px'});
    hdr.append(lvLbl, msLbl, cmLbl);
    viewport.appendChild(hdr);
    refreshMission();

    // ── Grid wrapper (dark background) ─────────
    const gridWrap = d('div');
    css(gridWrap, {
        background:'linear-gradient(145deg,#16162a,#0e0e1c)',
        borderRadius:'18px', padding:PAD+'px',
        boxShadow:'0 8px 36px rgba(0,0,0,.5), inset 0 1px 0 rgba(255,255,255,.08)',
        position:'relative',
    });
    const grid = d('div');
    css(grid, {
        display:'grid',
        gridTemplateColumns:`repeat(${COLS},${CELL}px)`,
        gridTemplateRows:`repeat(${ROWS},${CELL}px)`,
        gap:GAP+'px', position:'relative',
    });
    gridWrap.appendChild(grid);
    viewport.appendChild(gridWrap);

    // Combo pop container
    const comboLayer = d('div');
    css(comboLayer,{position:'absolute',inset:'0',pointerEvents:'none',overflow:'hidden',borderRadius:'18px',zIndex:'50'});
    gridWrap.appendChild(comboLayer);

    // ── Cell DOM ────────────────────────────────
    const cells = mk2d(ROWS, COLS, null);
    for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) {
        const cell = d('div');
        css(cell, {
            width:CELL+'px', height:CELL+'px',
            borderRadius: Math.round(CELL*.18)+'px',
            background:'rgba(255,255,255,.04)',
            border:'1px solid rgba(255,255,255,.05)',
            position:'relative', overflow:'visible',
            cursor:'pointer', boxSizing:'border-box',
        });
        cell.addEventListener('click', ((_r,_c)=>()=>onCell(_r,_c))(r,c));
        grid.appendChild(cell);
        cells[r][c] = cell;
    }

    // ── Gem rendering ───────────────────────────
    function makeGem(color, isIce, isBomb) {
        const pad = Math.max(2, Math.round(CELL*.07));
        const gem = d('div');
        gem.className = 'gem-ball';
        const gColor = isBomb ? 'bomb' : color;
        css(gem, {
            position:'absolute', inset:`${pad}px`,
            borderRadius:'50%',
            background: GEM_GRAD[gColor]||'#888',
            boxShadow: [
                'inset 0 -4px 8px rgba(0,0,0,.32)',
                'inset 0 5px 10px rgba(255,255,255,.22)',
                `0 4px 14px ${GEM_GLOW[gColor]||'rgba(0,0,0,.3)'}`,
                '0 0 0 1px rgba(255,255,255,.07)',
            ].join(','),
            transition:'transform .12s ease, box-shadow .12s ease',
        });
        // Main shine
        const s1=d('div');
        css(s1,{position:'absolute',top:'11%',left:'17%',width:'27%',height:'21%',
            background:'rgba(255,255,255,.55)',borderRadius:'50%',transform:'rotate(-22deg)',pointerEvents:'none'});
        // Secondary shine
        const s2=d('div');
        css(s2,{position:'absolute',bottom:'17%',right:'13%',width:'11%',height:'9%',
            background:'rgba(255,255,255,.18)',borderRadius:'50%',pointerEvents:'none'});
        gem.append(s1,s2);

        // Bomb indicator
        if (isBomb) {
            const bIco=d('div');
            css(bIco,{position:'absolute',inset:'0',display:'flex',alignItems:'center',
                justifyContent:'center',fontSize:Math.max(12,CELL*.32)+'px',
                pointerEvents:'none',zIndex:'2',lineHeight:'1'});
            bIco.textContent='💥';
            gem.appendChild(bIco);
        }

        // Ice overlay
        if (isIce) {
            const ice=d('div');
            css(ice,{position:'absolute',inset:'-2px',borderRadius:'50%',
                background:'rgba(140,190,255,.38)',border:'2px solid rgba(180,220,255,.7)',zIndex:'3'});
            gem.appendChild(ice);
        }
        return gem;
    }

    function renderCell(r, c) {
        const cell = cells[r][c];
        const old  = cell.querySelector('.gem-ball');
        if (old) old.remove();
        const color = board[r][c];
        if (!color) return;
        const gem = makeGem(color, iceB[r][c]>0, special[r][c]==='bomb');
        cell.appendChild(gem);
        applySel(r,c);
    }

    function applySel(r,c) {
        const gem=cells[r][c].querySelector('.gem-ball');
        if (!gem) return;
        const isSel=selR===r&&selC===c;
        const gc=special[r][c]==='bomb'?'bomb':board[r][c];
        gem.style.transform = isSel?'scale(1.14)':'';
        gem.style.boxShadow = isSel
            ? ['inset 0 -4px 8px rgba(0,0,0,.32)','inset 0 5px 10px rgba(255,255,255,.3)',
               '0 0 0 3px rgba(255,220,80,.9)','0 0 18px rgba(255,220,80,.7)',
               `0 4px 14px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'}`].join(',')
            : ['inset 0 -4px 8px rgba(0,0,0,.32)','inset 0 5px 10px rgba(255,255,255,.22)',
               `0 4px 14px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'}`,
               '0 0 0 1px rgba(255,255,255,.07)'].join(',');
    }

    function renderAll() { for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++) renderCell(r,c); }

    // ── Fall animation ──────────────────────────
    function renderWithFall(fallMap) {
        for (let r=0;r<ROWS;r++) for (let c=0;c<COLS;c++) {
            const cell=cells[r][c];
            const old=cell.querySelector('.gem-ball'); if(old)old.remove();
            const color=board[r][c]; if(!color) continue;
            const gem=makeGem(color, iceB[r][c]>0, special[r][c]==='bomb');
            cell.appendChild(gem);
            const fall=fallMap[r][c]||0;
            if (fall>0) {
                const dist=fall*(CELL+GAP);
                gem.style.transform=`translateY(-${dist}px)`;
                gem.style.transition='none';
                requestAnimationFrame(()=>requestAnimationFrame(()=>{
                    if(_destroyed) return;
                    const dur=Math.min(.5,.18+fall*.045);
                    gem.style.transition=`transform ${dur}s cubic-bezier(.22,1.15,.36,1)`;
                    gem.style.transform='';
                    // Bounce sound
                    setTimeout(()=>{ if(!_destroyed) Sound.gemBounce(); }, dur*800);
                }));
            }
        }
    }

    // Entry animation — column by column
    function entryAnim() {
        for (let c=0;c<COLS;c++) {
            setTimeout(()=>{
                for (let r=0;r<ROWS;r++) {
                    const gem=cells[r][c].querySelector('.gem-ball'); if(!gem) continue;
                    const dist=(ROWS-r+3)*(CELL+GAP);
                    gem.style.transition='none';
                    gem.style.transform=`translateY(-${dist}px)`;
                    gem.style.opacity='0';
                    requestAnimationFrame(()=>requestAnimationFrame(()=>{
                        if(_destroyed) return;
                        const dur=.22+r*.028;
                        gem.style.transition=`transform ${dur}s cubic-bezier(.22,1.1,.36,1), opacity .15s ease`;
                        gem.style.transform=''; gem.style.opacity='1';
                    }));
                }
            }, c*38);
        }
    }

    // ── Burst + Particles ───────────────────────
    function burstCells(matchSet, bombTargets) {
        return new Promise(res=>{
            let cnt=matchSet.size+bombTargets.size; if(!cnt){res();return;}
            const done=()=>{ if(--cnt===0) setTimeout(res,100); };
            const all=new Set([...matchSet,...bombTargets]);
            for (const k of all) {
                const[r,c]=k.split(',').map(Number);
                const cell=cells[r][c], gem=cell.querySelector('.gem-ball');
                if (!gem){done();continue;}
                spawnParticles(cell, special[r][c]==='bomb'?'bomb':board[r][c]);
                gem.style.transition='transform .1s ease, opacity .18s ease';
                gem.style.transform='scale(1.5)';
                setTimeout(()=>{
                    gem.style.transition='transform .15s ease, opacity .15s ease';
                    gem.style.transform='scale(0)'; gem.style.opacity='0';
                    done();
                },85);
            }
        });
    }

    function spawnParticles(cell, color) {
        const glow=GEM_GLOW[color]||'rgba(255,255,255,.7)';
        const n = color==='bomb' ? 12 : 7;
        for (let i=0;i<n;i++) {
            const p=d('div');
            const angle=(i/n)*Math.PI*2+Math.random()*.6;
            const dist=(color==='bomb'?28:16)+Math.random()*18;
            const sz=3+Math.random()*4;
            css(p,{position:'absolute',width:sz+'px',height:sz+'px',borderRadius:'50%',
                background:glow.replace('.6','.9').replace('.8','.9'),
                top:'50%',left:'50%',transform:'translate(-50%,-50%)',
                zIndex:'20',pointerEvents:'none',
                transition:'transform .35s ease-out, opacity .35s ease-out'});
            cell.style.overflow='visible';
            cell.appendChild(p);
            requestAnimationFrame(()=>{
                p.style.transform=`translate(calc(-50% + ${Math.cos(angle)*dist}px), calc(-50% + ${Math.sin(angle)*dist}px)) scale(.3)`;
                p.style.opacity='0';
            });
            setTimeout(()=>p.remove(),400);
        }
    }

    // ── Swap animation ──────────────────────────
    function animSwap(r1,c1,r2,c2,rev=false) {
        return new Promise(res=>{
            const g1=cells[r1][c1].querySelector('.gem-ball');
            const g2=cells[r2][c2].querySelector('.gem-ball');
            const dx=(c2-c1)*(CELL+GAP), dy=(r2-r1)*(CELL+GAP);
            const sc=rev?.9:1.08;
            [g1,g2].forEach(g=>{if(g){g.style.transition=`transform ${rev?.14:.18}s cubic-bezier(.4,0,.2,1)`;g.style.zIndex='5';}});
            if(g1) g1.style.transform=`translate(${dx}px,${dy}px) scale(${sc})`;
            if(g2) g2.style.transform=`translate(${-dx}px,${-dy}px) scale(${sc})`;
            setTimeout(res,rev?150:195);
        });
    }

    // ── Match logic ─────────────────────────────
    function getMatches() {
        const m=new Set();
        for(let r=0;r<ROWS;r++){let l=1;for(let c=1;c<=COLS;c++){if(c<COLS&&board[r][c]===board[r][c-1]&&board[r][c])l++;else{if(l>=3)for(let i=c-l;i<c;i++)m.add(r+','+i);l=1;}}}
        for(let c=0;c<COLS;c++){let l=1;for(let r=1;r<=ROWS;r++){if(r<ROWS&&board[r][c]===board[r-1][c]&&board[r][c])l++;else{if(l>=3)for(let i=r-l;i<r;i++)m.add(i+','+c);l=1;}}}
        return m;
    }

    // Find 4-in-a-row to create bombs
    function find4Plus() {
        const bombs=new Map(); // position → true (where bomb spawns)
        // Horizontal
        for(let r=0;r<ROWS;r++){
            let l=1,s=0;
            for(let c=1;c<=COLS;c++){
                if(c<COLS&&board[r][c]===board[r][c-1]&&board[r][c]){l++;}
                else{if(l===4){bombs.set(r+','+(s+1),'bomb');}
                     if(l>4){bombs.set(r+','+(s+l-1),'bomb');} s=c;l=1;}
            }
        }
        // Vertical
        for(let c=0;c<COLS;c++){
            let l=1,s=0;
            for(let r=1;r<=ROWS;r++){
                if(r<ROWS&&board[r][c]===board[r-1][c]&&board[r][c]){l++;}
                else{if(l>=4){bombs.set((s+1)+','+c,'bomb');} s=r;l=1;}
            }
        }
        return bombs;
    }

    // Expand bomb explosions (3x3)
    function getBombTargets(matchSet) {
        const bt=new Set();
        for(const k of matchSet){
            const[r,c]=k.split(',').map(Number);
            if(special[r][c]==='bomb'){
                for(let dr=-1;dr<=1;dr++)for(let dc=-1;dc<=1;dc++){
                    const nr=r+dr,nc=c+dc;
                    if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS) bt.add(nr+','+nc);
                }
            }
        }
        return bt;
    }

    function processMatches(matchSet, bombTargets) {
        let gc=0,gi=0;
        const all=new Set([...matchSet,...bombTargets]);
        let hasBomb=false;
        for(const k of matchSet){const[r,c]=k.split(',').map(Number);if(special[r][c]==='bomb')hasBomb=true;}

        for(const k of all){const[r,c]=k.split(',').map(Number);if(iceB[r][c]>0){iceB[r][c]--;if(!iceB[r][c])gi++;}}
        for(const k of all){const[r,c]=k.split(',').map(Number);if(!iceB[r][c]&&miss.color&&board[r][c]===miss.color)gc++;}
        for(const k of all){const[r,c]=k.split(',').map(Number);board[r][c]=null;special[r][c]=null;iceB[r][c]=0;}

        if(hasBomb) Sound.bombExplode();
        else Sound.gemMatch(all.size);

        colGem+=gc; iceGem+=gi; combo++;
        if(combo>1){ cmLbl.textContent=`✦ COMBO ×${combo}`; cmLbl.style.color=combo>=5?'#ff9900':combo>=3?'#ffee00':'#ffd700';
            showComboText(combo); setTimeout(()=>{if(!_destroyed)cmLbl.textContent='';},1400); Sound.combo(combo); }
        refreshMission(); checkWin();
    }

    function showComboText(n) {
        const el=d('div');
        css(el,{position:'absolute',top:'35%',left:'50%',transform:'translate(-50%,-50%) scale(.6)',
            fontFamily:"'DM Sans',sans-serif",fontSize:'32px',fontWeight:'900',
            color:'#ffd700',textShadow:'0 0 20px rgba(255,200,0,.9),0 2px 6px rgba(0,0,0,.6)',
            letterSpacing:'3px',pointerEvents:'none',zIndex:'100',whiteSpace:'nowrap',
            transition:'transform .35s cubic-bezier(.34,1.56,.64,1), opacity .6s ease',
            opacity:'0'});
        el.textContent = `COMBO ×${n}!`;
        comboLayer.appendChild(el);
        requestAnimationFrame(()=>requestAnimationFrame(()=>{
            el.style.transform='translate(-50%,-50%) scale(1) translateY(-10px)';
            el.style.opacity='1';
        }));
        setTimeout(()=>{ el.style.opacity='0'; el.style.transform='translate(-50%,-60%) scale(.9)'; setTimeout(()=>el.remove(),600); },900);
    }

    // ── Gravity ─────────────────────────────────
    function gravityWithFall() {
        const fm=mk2d(ROWS,COLS,0);
        for(let c=0;c<COLS;c++){
            let empty=0;
            for(let r=ROWS-1;r>=0;r--){
                if(!board[r][c]&&!special[r][c]){empty++;}
                else if(empty>0){
                    fm[r+empty][c]=empty;
                    board[r+empty][c]=board[r][c];
                    special[r+empty][c]=special[r][c];
                    iceB[r+empty][c]=iceB[r][c];
                    board[r][c]=null;special[r][c]=null;iceB[r][c]=0;
                }
            }
            for(let r=0;r<empty;r++){board[r][c]=COLORS[rnd(COLORS.length)];special[r][c]=null;iceB[r][c]=0;fm[r][c]=empty-r+1;}
        }
        return fm;
    }

    // ── Resolve ─────────────────────────────────
    async function resolve() {
        if(busy||_destroyed) return; busy=true;
        let any=true;
        while(any&&active&&!_destroyed){
            const m=getMatches();
            if(!m.size){any=false;break;}
            // Check for 4+ (bombs) BEFORE clearing
            const bombMap=find4Plus();
            // Apply bombs to special FIRST (only newly matched 4+)
            for(const[k,type] of bombMap){
                if(m.has(k)){const[r,c]=k.split(',').map(Number);special[r][c]=type;}
            }
            const bt=getBombTargets(m);
            await burstCells(m,bt);
            processMatches(m,bt);
            if(!active||_destroyed) break;
            const fm=gravityWithFall();
            renderWithFall(fm);
            const maxF=Math.max(0,...Object.values(fm).flat?.()??[]);
            await wait(Math.min(620,200+maxF*48));
        }
        busy=false;
        if(active&&!_destroyed&&!hasMoves()) shuffle();
    }

    // ── Swap ────────────────────────────────────
    function sw(r1,c1,r2,c2){
        [board[r1][c1],board[r2][c2]]=[board[r2][c2],board[r1][c1]];
        [special[r1][c1],special[r2][c2]]=[special[r2][c2],special[r1][c1]];
        [iceB[r1][c1],iceB[r2][c2]]=[iceB[r2][c2],iceB[r1][c1]];
    }
    let swapping=false;
    async function trySwap(r1,c1,r2,c2){
        if(busy||!active||swapping||_destroyed) return; swapping=true;
        await animSwap(r1,c1,r2,c2); sw(r1,c1,r2,c2);
        if(getMatches().size){combo=0;renderAll();await resolve();}
        else{await animSwap(r1,c1,r2,c2,true);sw(r1,c1,r2,c2);renderAll();}
        swapping=false;
    }

    function onCell(r,c){
        if(busy||!active||swapping||_destroyed) return;
        Sound.gemTap();
        if(selR===null){selR=r;selC=c;applySel(r,c);return;}
        if(selR===r&&selC===c){applySel(r,c,false);selR=null;selC=null;return;}
        const adj=Math.abs(selR-r)+Math.abs(selC-c)===1;
        const pr=selR,pc=selC;
        cells[pr][pc].querySelector('.gem-ball')&&applySel(pr,pc);
        selR=null;selC=null;
        if(adj) trySwap(pr,pc,r,c);
        else{selR=r;selC=c;applySel(r,c);}
    }

    // ── Board init ──────────────────────────────
    function initBoard(){
        for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++){
            const no=new Set();
            if(c>=2&&board[r][c-1]===board[r][c-2])no.add(board[r][c-1]);
            if(r>=2&&board[r-1][c]===board[r-2][c])no.add(board[r-1][c]);
            const ok=COLORS.filter(x=>!no.has(x));
            board[r][c]=ok[rnd(ok.length)]||COLORS[0];
        }
    }
    function placeIce(){
        const n=miss.type==='clear_ice'?miss.target:(miss.targetIce||0);
        if(!n) return;
        const pos=[];for(let r=3;r<ROWS;r++)for(let c=0;c<COLS;c++)pos.push([r,c]);
        pos.sort(()=>Math.random()-.5);
        for(let i=0;i<Math.min(n,pos.length);i++){const[r,c]=pos[i];iceB[r][c]=level>25?2:1;}
    }
    function hasMoves(){
        for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++){
            if(c+1<COLS){sw(r,c,r,c+1);if(getMatches().size){sw(r,c,r,c+1);return true;}sw(r,c,r,c+1);}
            if(r+1<ROWS){sw(r,c,r+1,c);if(getMatches().size){sw(r,c,r+1,c);return true;}sw(r,c,r+1,c);}
        }return false;
    }
    function shuffle(){const f=board.flat();for(let i=f.length-1;i>0;i--){const j=rnd(i+1);[f[i],f[j]]=[f[j],f[i]];}let idx=0;for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)board[r][c]=f[idx++];resolve();}

    function checkWin(){
        const done=miss.type==='collect'?colGem>=miss.target:miss.type==='clear_ice'?iceGem>=miss.target:colGem>=miss.targetCollect&&iceGem>=miss.targetIce;
        if(done&&active&&!_destroyed){active=false;Sound.win3();onWin();}
    }
    function refreshMission(){
        const em=['🔴','🔵','🟢','🟡','🟣','🟠'][COLORS.indexOf(miss.color)]||'';
        if(miss.type==='collect') msLbl.textContent=`${em} Собери: ${colGem} / ${miss.target}`;
        else if(miss.type==='clear_ice') msLbl.textContent=`❄️ Разморозь: ${iceGem} / ${miss.target}`;
        else msLbl.textContent=`${em} ${colGem}/${miss.targetCollect}  ❄️ ${iceGem}/${miss.targetIce}`;
    }

    // ── Start ───────────────────────────────────
    initBoard(); placeIce(); renderAll();
    setTimeout(()=>{ if(!_destroyed) entryAnim(); },60);
    if(!hasMoves()) shuffle();
}

// ── Helpers ────────────────────────────────────
function getMission(l){
    if(l<=5)  return{type:'collect',color:'blue',  target:10+l};
    if(l<=10) return{type:'collect',color:'green', target:15+(l-5)*2};
    if(l<=15) return{type:'collect',color:'purple',target:20+(l-10)*3};
    if(l<=20) return{type:'clear_ice',target:5+(l-15)};
    return{type:'mixed',color:'blue',targetCollect:20+(l-20)*2,targetIce:8+Math.floor((l-20)/2)};
}
function mk2d(r,c,v){return Array.from({length:r},()=>Array(c).fill(v))}
function rnd(n){return Math.floor(Math.random()*n)}
function wait(ms){return new Promise(r=>setTimeout(r,ms))}
function d(tag){return document.createElement(tag)}
function css(el,s){Object.assign(el.style,s)}

export function destroy(){ _destroyed=true; }

