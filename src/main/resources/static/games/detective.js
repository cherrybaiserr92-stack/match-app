// ─── САМОЦВЕТЫ · Match-3 (Analyst Cabinet) ───────

const GEMS  = ['🔴','🔵','🟢','🟡','🟣','🟠'];
const CKEYS = ['red','blue','green','yellow','purple','orange'];

export function initGame(viewport, level, onWin) {
    viewport.innerHTML = '';
    Object.assign(viewport.style,{display:'flex',flexDirection:'column',alignItems:'center',gap:'12px',width:'100%'});

    const ROWS=9, COLS=9;
    const miss = getMission(level);
    let col=0, ice=0, combo=0, active=true, busy=false;
    let board = mk2d(ROWS,COLS,null), iceB = mk2d(ROWS,COLS,0);
    let sr=null, sc=null;
    const vw   = Math.min(viewport.offsetWidth||window.innerWidth,400);
    const GAP=3, PAD=10, CELL=Math.floor((vw-PAD*2-GAP*(COLS-1))/COLS);

    // Header
    const hdr = el('div',{background:'#fdfaf5',border:'1px solid #e0d9ce',borderRadius:'8px',padding:'10px 14px',width:'100%',textAlign:'center',fontFamily:"'DM Sans',sans-serif"});
    const lv  = el('div',{fontSize:'10px',letterSpacing:'2px',color:'#8a7d6a',fontWeight:'700',textTransform:'uppercase',marginBottom:'4px',fontFamily:"'Courier Prime',monospace"});
    lv.textContent='УРОВЕНЬ '+level;
    const ms  = el('div',{fontSize:'13px',fontWeight:'600',color:'#1c1710'});
    const cm  = el('div',{fontSize:'11px',color:'#a87030',fontWeight:'700',letterSpacing:'1px',minHeight:'16px',marginTop:'4px'});
    hdr.append(lv,ms,cm); viewport.appendChild(hdr);
    refreshM();

    // Grid
    const grid = el('div',{
        display:'grid', gridTemplateColumns:`repeat(${COLS},${CELL}px)`,
        gap:GAP+'px', background:'#fdfaf5', padding:PAD+'px',
        borderRadius:'16px', border:'1px solid #c8bfb0',
        boxShadow:'0 4px 20px rgba(0,0,0,.10)'
    });
    viewport.appendChild(grid);
    const cells=mk2d(ROWS,COLS,null);

    for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++){
        const cell=el('div',{
            width:CELL+'px',height:CELL+'px',borderRadius:'6px',
            display:'flex',alignItems:'center',justifyContent:'center',
            fontSize:Math.max(16,CELL-12)+'px',cursor:'pointer',
            border:'1.5px solid transparent',
            transition:'transform .1s,border-color .1s,background .12s',
            lineHeight:'1',userSelect:'none',background:'#f5f0e8'
        });
        cell.addEventListener('click',((_r,_c)=>()=>onCell(_r,_c))(r,c));
        grid.appendChild(cell); cells[r][c]=cell;
    }

    function render(){
        for(let r=0;r<ROWS;r++) for(let c=0;c<COLS;c++){
            const e=cells[r][c], clr=board[r][c], isIce=iceB[r][c]>0, isSel=sr===r&&sc===c;
            const gi=CKEYS.indexOf(clr); e.textContent=GEMS[gi]??'';
            e.style.background  = isIce?'rgba(30,58,106,.12)':'#f5f0e8';
            e.style.borderColor = isSel?'#a87030':isIce?'rgba(30,58,106,.4)':'transparent';
            e.style.boxShadow   = isSel?'0 0 0 2px #a87030':'none';
            e.style.transform   = isSel?'scale(1.1)':'scale(1)';
            e.style.filter      = isIce&&iceB[r][c]===2?'brightness(.6)':isIce?'brightness(.75)':'none';
        }
    }

    function matches(){
        const m=new Set();
        for(let r=0;r<ROWS;r++){let l=1;for(let c=1;c<=COLS;c++){if(c<COLS&&board[r][c]===board[r][c-1])l++;else{if(l>=3)for(let i=c-l;i<c;i++)m.add(r+','+i);l=1;}}}
        for(let c=0;c<COLS;c++){let l=1;for(let r=1;r<=ROWS;r++){if(r<ROWS&&board[r][c]===board[r-1][c])l++;else{if(l>=3)for(let i=r-l;i<r;i++)m.add(i+','+c);l=1;}}}
        return m;
    }
    function processM(m){
        let gc=0,gi=0;
        for(const k of m){const[r,c]=k.split(',').map(Number);if(iceB[r][c]>0){iceB[r][c]--;if(!iceB[r][c])gi++;}}
        for(const k of m){const[r,c]=k.split(',').map(Number);if(!iceB[r][c]&&miss.color&&board[r][c]===miss.color)gc++;}
        for(const k of m){const[r,c]=k.split(',').map(Number);board[r][c]=null;iceB[r][c]=0;}
        col+=gc; ice+=gi; combo++;
        if(combo>1){cm.textContent='✨ COMBO ×'+combo+'!';setTimeout(()=>{cm.textContent='';},1100);}
        refreshM(); checkWin();
    }
    function gravity(){
        for(let c=0;c<COLS;c++){const g=[],ic=[];for(let r=ROWS-1;r>=0;r--)if(board[r][c]!==null){g.push(board[r][c]);ic.push(iceB[r][c]);}while(g.length<ROWS){g.push(CKEYS[rnd(CKEYS.length)]);ic.push(0);}g.reverse();ic.reverse();for(let r=0;r<ROWS;r++){board[r][c]=g[r];iceB[r][c]=ic[r];}}
    }
    async function resolve(){if(busy)return;busy=true;let any=true;while(any&&active){const m=matches();if(!m.size){any=false;break;}processM(m);if(!active)break;gravity();render();await wait(75);}busy=false;if(active&&!hasMoves())shuffle();render();}
    function hasMoves(){for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){if(c+1<COLS){sw(r,c,r,c+1);if(matches().size){sw(r,c,r,c+1);return true;}sw(r,c,r,c+1);}if(r+1<ROWS){sw(r,c,r+1,c);if(matches().size){sw(r,c,r+1,c);return true;}sw(r,c,r+1,c);}}return false;}
    function shuffle(){const f=board.flat();for(let i=f.length-1;i>0;i--){const j=rnd(i+1);[f[i],f[j]]=[f[j],f[i]];}let idx=0;for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)board[r][c]=f[idx++];resolve();}
    function sw(r1,c1,r2,c2){[board[r1][c1],board[r2][c2]]=[board[r2][c2],board[r1][c1]];[iceB[r1][c1],iceB[r2][c2]]=[iceB[r2][c2],iceB[r1][c1]];}
    async function trySwap(r1,c1,r2,c2){if(busy||!active)return;sw(r1,c1,r2,c2);if(matches().size){combo=0;render();await resolve();}else{sw(r1,c1,r2,c2);render();}}
    function onCell(r,c){if(busy||!active)return;if(sr===null){sr=r;sc=c;render();return;}if(sr===r&&sc===c){sr=null;sc=null;render();return;}const adj=Math.abs(sr-r)+Math.abs(sc-c)===1;if(!adj){sr=r;sc=c;render();return;}const[r1,c1]=[sr,sc];sr=null;sc=null;trySwap(r1,c1,r,c);}
    function initBoard(){for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){const no=new Set();if(c>=2&&board[r][c-1]===board[r][c-2])no.add(board[r][c-1]);if(r>=2&&board[r-1][c]===board[r-2][c])no.add(board[r-1][c]);const ok=CKEYS.filter(x=>!no.has(x));board[r][c]=ok[rnd(ok.length)]||CKEYS[0];}}
    function placeIce(){const n=miss.type==='clear_ice'?miss.target:miss.targetIce||0;if(!n)return;const pos=[];for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)pos.push([r,c]);pos.sort(()=>Math.random()-.5);for(let i=0;i<Math.min(n,pos.length);i++){const[r,c]=pos[i];iceB[r][c]=level>25?2:1;}}
    function checkWin(){const done=miss.type==='collect'?col>=miss.target:miss.type==='clear_ice'?ice>=miss.target:col>=miss.targetCollect&&ice>=miss.targetIce;if(done&&active){active=false;onWin();}}
    function refreshM(){const g=GEMS[CKEYS.indexOf(miss.color)]||'';if(miss.type==='collect')ms.textContent=`${g} Собери: ${col} / ${miss.target}`;else if(miss.type==='clear_ice')ms.textContent=`❄️ Разморозь: ${ice} / ${miss.target}`;else ms.textContent=`${g} ${col}/${miss.targetCollect}  ❄️ ${ice}/${miss.targetIce}`;}

    initBoard(); placeIce(); render();
    if(!hasMoves()) shuffle();
}
function getMission(l){if(l<=5)return{type:'collect',color:'blue',target:10+l};if(l<=10)return{type:'collect',color:'green',target:15+(l-5)*2};if(l<=15)return{type:'collect',color:'purple',target:20+(l-10)*3};if(l<=20)return{type:'clear_ice',target:5+(l-15)};return{type:'mixed',color:'blue',targetCollect:20+(l-20)*2,targetIce:8+Math.floor((l-20)/2)};}
function mk2d(r,c,v){return Array.from({length:r},()=>Array(c).fill(v));}
function rnd(n){return Math.floor(Math.random()*n);}
function wait(ms){return new Promise(r=>setTimeout(r,ms));}
function el(tag,s){const d=document.createElement(tag);Object.assign(d.style,s);return d;}
export function destroy(){}

