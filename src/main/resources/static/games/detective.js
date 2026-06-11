// ═══════════════════════════════════════════════
//  САМОЦВЕТЫ v5 · Full-screen Match-3
//  Drag-to-swap · Limited moves · Boosters · Canvas particles
// ═══════════════════════════════════════════════

const GEM_GRAD={
    red:   'radial-gradient(circle at 38% 32%,#ff9999,#dd1111 50%,#880000)',
    blue:  'radial-gradient(circle at 38% 32%,#99bbff,#1155ee 50%,#001188)',
    green: 'radial-gradient(circle at 38% 32%,#99ffaa,#11bb44 50%,#005511)',
    yellow:'radial-gradient(circle at 38% 32%,#ffee99,#ddaa11 50%,#885500)',
    purple:'radial-gradient(circle at 38% 32%,#ee99ff,#aa11ee 50%,#550077)',
    orange:'radial-gradient(circle at 38% 32%,#ffcc88,#ee7722 50%,#882200)',
    bomb:  'radial-gradient(circle at 38% 32%,#fff799,#ffdd00 50%,#cc8800)',
    rainbow:'radial-gradient(circle at 30% 30%,#ff6b6b,#ffd93d 30%,#6bcb77 60%,#4d96ff)',
};
const GEM_GLOW={
    red:'rgba(200,0,0,.7)',blue:'rgba(10,60,220,.7)',green:'rgba(0,160,50,.7)',
    yellow:'rgba(200,150,0,.7)',purple:'rgba(140,0,210,.7)',orange:'rgba(200,90,0,.7)',
    bomb:'rgba(255,200,0,.9)',rainbow:'rgba(255,255,255,.6)',
};
const COLORS=['red','blue','green','yellow','purple','orange'];
const ROWS=9,COLS=9;
let _destroyed=false;

export function initGame(viewport,level,onWin,isGateMode=false){
    _destroyed=false;
    viewport.innerHTML='';
    Object.assign(viewport.style,{
        display:'flex',flexDirection:'column',
        width:'100%',height:'100%',
        background:'#070508',
        userSelect:'none',WebkitUserSelect:'none',
        overflow:'hidden',
    });

    // ── State ──────────────────────────────────
    const miss=getMission(level);
    let board=mk2d(ROWS,COLS,null),spec=mk2d(ROWS,COLS,null),iceB=mk2d(ROWS,COLS,0);
    let colGem=0,iceGem=0,combo=0;
    let movesLeft=getMoves(level);
    let active=true,busy=false,selR=null,selC=null;
    let boosterMode=null; // 'hammer'|'lightning'|null
    let boosters={hammer:3,lightning:2,bomb:1};

    // ── Layout calc ────────────────────────────
    const vpW=viewport.clientWidth||window.innerWidth;
    const vpH=viewport.clientHeight||(window.innerHeight-52-4);
    const headerH=56,boosterH=60,padding=8;
    const gridH=vpH-headerH-boosterH-padding*2;
    const GAP=3;
    const CELL=Math.floor(Math.min((vpW-padding*2-GAP*(COLS-1))/COLS,(gridH-GAP*(ROWS-1))/ROWS));
    const gridW=CELL*COLS+GAP*(COLS-1);

    // ── Header ─────────────────────────────────
    const hdr=el('div');
    css(hdr,{
        height:headerH+'px',minHeight:headerH+'px',
        display:'flex',alignItems:'center',justifyContent:'space-between',
        padding:'0 16px',flexShrink:'0',
        background:'rgba(0,0,0,.6)',backdropFilter:'blur(16px)',WebkitBackdropFilter:'blur(16px)',
        borderBottom:'1px solid rgba(255,255,255,.08)',
    });
    const lvEl=el('div');css(lvEl,{fontSize:'11px',fontWeight:'700',color:'rgba(255,255,255,.5)',letterSpacing:'1.5px',fontFamily:"'JetBrains Mono',monospace",textTransform:'uppercase'});
    lvEl.textContent=`УР. ${level}`;
    const msEl=el('div');css(msEl,{fontSize:'13px',fontWeight:'700',color:'#fff',textAlign:'center',flex:'1',padding:'0 8px'});
    const mvEl=el('div');
    css(mvEl,{display:'flex',flexDirection:'column',alignItems:'center',gap:'1px'});
    const mvNum=el('div');css(mvNum,{fontSize:'22px',fontWeight:'800',color:'#fff',lineHeight:'1',fontFamily:"'Playfair Display',serif"});
    const mvLbl=el('div');css(mvLbl,{fontSize:'9px',letterSpacing:'1.5px',color:'rgba(255,255,255,.4)',textTransform:'uppercase'});
    mvLbl.textContent='ХОДОВ';
    mvEl.append(mvNum,mvLbl);
    hdr.append(lvEl,msEl,mvEl);
    viewport.appendChild(hdr);
    function refreshHUD(){
        mvNum.textContent=movesLeft;
        mvNum.style.color=movesLeft<=5?'#ef4444':movesLeft<=10?'#f59e0b':'#fff';
        refreshMission();
    }

    // ── Grid area ──────────────────────────────
    const gridArea=el('div');
    css(gridArea,{
        flex:'1',display:'flex',alignItems:'center',justifyContent:'center',
        position:'relative',overflow:'hidden',
    });

    // Particle canvas
    const pCanvas=el('canvas');
    css(pCanvas,{position:'absolute',inset:'0',pointerEvents:'none',zIndex:'10'});
    pCanvas.width=vpW;pCanvas.height=vpH-headerH-boosterH;
    const pCtx=pCanvas.getContext('2d');
    const particles=[];

    // Grid wrapper
    const gridWrap=el('div');
    css(gridWrap,{
        background:'linear-gradient(145deg,#14101e,#0a0810)',
        borderRadius:'18px',padding:padding+'px',
        boxShadow:'0 8px 40px rgba(0,0,0,.6),inset 0 1px 0 rgba(255,255,255,.06)',
        position:'relative',flexShrink:'0',
    });

    const grid=el('div');
    css(grid,{
        display:'grid',
        gridTemplateColumns:`repeat(${COLS},${CELL}px)`,
        gridTemplateRows:`repeat(${ROWS},${CELL}px)`,
        gap:GAP+'px',position:'relative',
    });

    // Combo overlay
    const comboOverlay=el('div');
    css(comboOverlay,{position:'absolute',inset:'0',pointerEvents:'none',overflow:'hidden',borderRadius:'18px',zIndex:'20'});
    gridWrap.append(grid,comboOverlay);
    gridArea.append(pCanvas,gridWrap);
    viewport.appendChild(gridArea);

    // Particle animation loop
    let pRAF=requestAnimationFrame(function pLoop(){
        if(_destroyed)return;
        pCtx.clearRect(0,0,pCanvas.width,pCanvas.height);
        for(let i=particles.length-1;i>=0;i--){
            const p=particles[i];
            p.x+=p.vx;p.y+=p.vy;p.vy+=.15;p.life-=p.decay;
            if(p.life<=0){particles.splice(i,1);continue;}
            pCtx.globalAlpha=p.life;pCtx.fillStyle=p.color;
            pCtx.beginPath();pCtx.arc(p.x,p.y,p.r*p.life,0,Math.PI*2);pCtx.fill();
        }
        pCtx.globalAlpha=1;
        pRAF=requestAnimationFrame(pLoop);
    });

    function emitParticles(cellEl,color,n=7){
        const gr=gridWrap.getBoundingClientRect();
        const cr=cellEl.getBoundingClientRect();
        const ox=cr.left-gr.left+cr.width/2;
        const oy=cr.top-gr.top+cr.height/2;
        const gl=GEM_GLOW[color]||'rgba(255,255,255,.8)';
        for(let i=0;i<n;i++){
            const ang=(i/n)*Math.PI*2+Math.random()*.6;
            const sp=2+Math.random()*4;
            particles.push({x:ox,y:oy,vx:Math.cos(ang)*sp,vy:Math.sin(ang)*sp-1.5,r:2+Math.random()*4,color:gl.replace('.7','.9').replace('.8','.9'),life:1,decay:.025+Math.random()*.02});
        }
    }

    // ── Cell DOM ───────────────────────────────
    const cells=mk2d(ROWS,COLS,null);
    const R=Math.max(4,Math.round(CELL*.16));
    for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
        const cell=el('div');
        css(cell,{width:CELL+'px',height:CELL+'px',borderRadius:R+'px',
            background:'rgba(255,255,255,.04)',border:'1px solid rgba(255,255,255,.05)',
            position:'relative',boxSizing:'border-box',cursor:'pointer',flexShrink:'0'});
        cell.dataset.r=r;cell.dataset.c=c;
        grid.appendChild(cell);cells[r][c]=cell;
    }

    // ── Gem rendering ──────────────────────────
    function makeGem(color,isIce,isBomb,isRainbow){
        const pad=Math.max(2,Math.round(CELL*.07));
        const gm=el('div');gm.className='gm';
        const gc=isRainbow?'rainbow':isBomb?'bomb':color;
        css(gm,{position:'absolute',inset:`${pad}px`,borderRadius:'50%',
            background:GEM_GRAD[gc]||'#888',willChange:'transform',
            boxShadow:[
                'inset 0 -4px 8px rgba(0,0,0,.32)',
                'inset 0 5px 10px rgba(255,255,255,.22)',
                `0 3px 12px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'}`,
                '0 0 0 1px rgba(255,255,255,.06)',
            ].join(','),
        });
        // Main shine
        const s=el('div');css(s,{position:'absolute',top:'11%',left:'17%',width:'27%',height:'21%',background:'rgba(255,255,255,.55)',borderRadius:'50%',transform:'rotate(-22deg)',pointerEvents:'none'});
        const s2=el('div');css(s2,{position:'absolute',bottom:'17%',right:'13%',width:'11%',height:'9%',background:'rgba(255,255,255,.18)',borderRadius:'50%',pointerEvents:'none'});
        gm.append(s,s2);
        if(isBomb||isRainbow){
            const ico=el('div');css(ico,{position:'absolute',inset:'0',display:'flex',alignItems:'center',justifyContent:'center',fontSize:Math.max(10,CELL*.3)+'px',pointerEvents:'none',zIndex:'2',lineHeight:'1'});
            ico.textContent=isBomb?'💥':'🌈';gm.appendChild(ico);
        }
        if(isIce){
            const ice=el('div');css(ice,{position:'absolute',inset:'-2px',borderRadius:'50%',background:'rgba(140,190,255,.38)',border:'2px solid rgba(180,220,255,.7)',zIndex:'3'});gm.appendChild(ice);
        }
        return gm;
    }

    function renderCell(r,c,animFall=0){
        const cell=cells[r][c];
        const old=cell.querySelector('.gm');if(old)old.remove();
        const color=board[r][c];if(!color)return;
        const gm=makeGem(color,iceB[r][c]>0,spec[r][c]==='bomb',spec[r][c]==='rainbow');
        cell.appendChild(gm);
        if(animFall>0){
            const dist=animFall*(CELL+GAP);
            gm.style.transform=`translateY(-${dist}px)`;gm.style.transition='none';
            requestAnimationFrame(()=>requestAnimationFrame(()=>{
                if(_destroyed)return;
                const dur=Math.min(.5,.18+animFall*.045);
                gm.style.transition=`transform ${dur}s cubic-bezier(.22,1.15,.36,1)`;
                gm.style.transform='';
                setTimeout(()=>{if(!_destroyed)Sound.gemBounce();},dur*800);
            }));
        }
        applySel(r,c);
    }

    function applySel(r,c,isSel=selR===r&&selC===c){
        const gm=cells[r][c].querySelector('.gm');if(!gm)return;
        const gc=spec[r][c]==='bomb'?'bomb':spec[r][c]==='rainbow'?'rainbow':board[r][c];
        gm.style.transform=isSel?'scale(1.14)':'';
        gm.style.boxShadow=isSel
            ?`inset 0 -4px 8px rgba(0,0,0,.32),inset 0 5px 10px rgba(255,255,255,.3),0 0 0 3px rgba(255,220,80,.9),0 0 18px rgba(255,220,80,.7),0 3px 12px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'}`
            :`inset 0 -4px 8px rgba(0,0,0,.32),inset 0 5px 10px rgba(255,255,255,.22),0 3px 12px ${GEM_GLOW[gc]||'rgba(0,0,0,.3)'},0 0 0 1px rgba(255,255,255,.06)`;
    }

    function renderAll(){for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)renderCell(r,c);}

    function renderWithFall(fm){
        for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
            const old=cells[r][c].querySelector('.gm');if(old)old.remove();
            if(!board[r][c])continue;
            const gm=makeGem(board[r][c],iceB[r][c]>0,spec[r][c]==='bomb',spec[r][c]==='rainbow');
            cells[r][c].appendChild(gm);
            if(fm[r][c]>0){
                const dist=fm[r][c]*(CELL+GAP);gm.style.transform=`translateY(-${dist}px)`;gm.style.transition='none';
                requestAnimationFrame(()=>requestAnimationFrame(()=>{
                    if(_destroyed)return;
                    const dur=Math.min(.5,.18+fm[r][c]*.045);
                    gm.style.transition=`transform ${dur}s cubic-bezier(.22,1.15,.36,1)`;gm.style.transform='';
                    setTimeout(()=>{if(!_destroyed)Sound.gemBounce();},dur*700);
                }));
            }
        }
    }

    // ── Entry animation ────────────────────────
    function entryAnim(){
        for(let c=0;c<COLS;c++){
            setTimeout(()=>{
                for(let r=0;r<ROWS;r++){
                    const gm=cells[r][c].querySelector('.gm');if(!gm)continue;
                    const dist=(ROWS-r+3)*(CELL+GAP);
                    gm.style.transition='none';gm.style.transform=`translateY(-${dist}px)`;gm.style.opacity='0';
                    requestAnimationFrame(()=>requestAnimationFrame(()=>{
                        if(_destroyed)return;
                        gm.style.transition=`transform ${.22+r*.028}s cubic-bezier(.22,1.1,.36,1),opacity .15s ease`;
                        gm.style.transform='';gm.style.opacity='1';
                    }));
                }
            },c*35);
        }
    }

    // ── Burst ──────────────────────────────────
    function burstCells(matchSet,bombT){
        return new Promise(res=>{
            let cnt=matchSet.size+bombT.size;if(!cnt){res();return;}
            const done=()=>{if(--cnt===0)setTimeout(res,90);};
            for(const k of new Set([...matchSet,...bombT])){
                const[r,c]=k.split(',').map(Number);
                const cell=cells[r][c],gm=cell.querySelector('.gm');
                if(!gm){done();continue;}
                emitParticles(cell,spec[r][c]==='bomb'?'bomb':board[r][c],spec[r][c]==='bomb'?12:7);
                gm.style.transition='transform .1s ease,opacity .18s ease';
                gm.style.transform='scale(1.5)';
                setTimeout(()=>{gm.style.transition='transform .15s ease,opacity .15s ease';gm.style.transform='scale(0)';gm.style.opacity='0';done();},80);
            }
        });
    }

    // ── Swap animation ─────────────────────────
    function animSwap(r1,c1,r2,c2,rev=false){
        return new Promise(res=>{
            const g1=cells[r1][c1].querySelector('.gm'),g2=cells[r2][c2].querySelector('.gm');
            const dx=(c2-c1)*(CELL+GAP),dy=(r2-r1)*(CELL+GAP);
            const sc=rev?.88:1.1,dur=rev?.13:.19;
            [g1,g2].forEach(g=>{if(g){g.style.transition=`transform ${dur}s cubic-bezier(.4,0,.2,1)`;g.style.zIndex='5';}});
            if(g1)g1.style.transform=`translate(${dx}px,${dy}px) scale(${sc})`;
            if(g2)g2.style.transform=`translate(${-dx}px,${-dy}px) scale(${sc})`;
            setTimeout(res,dur*1000+10);
        });
    }

    // ── Combo text ─────────────────────────────
    function showComboText(n){
        const el2=el('div');
        css(el2,{position:'absolute',top:'35%',left:'50%',transform:'translate(-50%,-50%) scale(.5)',fontFamily:"'Inter',sans-serif",fontSize:'30px',fontWeight:'900',color:'#ffd700',textShadow:'0 0 24px rgba(255,200,0,.9),0 2px 6px rgba(0,0,0,.7)',letterSpacing:'3px',pointerEvents:'none',zIndex:'100',whiteSpace:'nowrap',opacity:'0',transition:'transform .35s cubic-bezier(.34,1.56,.64,1),opacity .5s ease'});
        el2.textContent=`COMBO ×${n}`;comboOverlay.appendChild(el2);
        requestAnimationFrame(()=>requestAnimationFrame(()=>{el2.style.transform='translate(-50%,-50%) scale(1) translateY(-8px)';el2.style.opacity='1';}));
        setTimeout(()=>{el2.style.opacity='0';el2.style.transform='translate(-50%,-60%) scale(.9)';setTimeout(()=>el2.remove(),600);},900);
    }

    // ── Match logic ────────────────────────────
    function getMatches(){
        const m=new Set();
        for(let r=0;r<ROWS;r++){let l=1;for(let c=1;c<=COLS;c++){if(c<COLS&&board[r][c]===board[r][c-1]&&board[r][c])l++;else{if(l>=3)for(let i=c-l;i<c;i++)m.add(r+','+i);l=1;}}}
        for(let c=0;c<COLS;c++){let l=1;for(let r=1;r<=ROWS;r++){if(r<ROWS&&board[r][c]===board[r-1][c]&&board[r][c])l++;else{if(l>=3)for(let i=r-l;i<r;i++)m.add(i+','+c);l=1;}}}
        return m;
    }

    function find4Plus(){
        const bm=new Map();
        for(let r=0;r<ROWS;r++){let l=1,s=0;for(let c=1;c<=COLS;c++){if(c<COLS&&board[r][c]===board[r][c-1]&&board[r][c])l++;else{if(l===4)bm.set(r+','+(s+2),'bomb');if(l===5)bm.set(r+','+(s+2),'rainbow');if(l>5)bm.set(r+','+(s+2),'rainbow');s=c;l=1;}}}
        for(let c=0;c<COLS;c++){let l=1,s=0;for(let r=1;r<=ROWS;r++){if(r<ROWS&&board[r][c]===board[r-1][c]&&board[r][c])l++;else{if(l>=4){const k=(s+2)+','+c;if(!bm.has(k))bm.set(k,l>=5?'rainbow':'bomb');}s=r;l=1;}}}
        return bm;
    }

    function getBombTargets(m){
        const bt=new Set();
        for(const k of m){const[r,c]=k.split(',').map(Number);
            if(spec[r][c]==='bomb'){for(let dr=-1;dr<=1;dr++)for(let dc=-1;dc<=1;dc++){const nr=r+dr,nc=c+dc;if(nr>=0&&nr<ROWS&&nc>=0&&nc<COLS)bt.add(nr+','+nc);}}
            if(spec[r][c]==='rainbow'){const color=board[r][c];for(let rr=0;rr<ROWS;rr++)for(let cc=0;cc<COLS;cc++)if(board[rr][cc]===color)bt.add(rr+','+cc);}
        }
        return bt;
    }

    function processMatches(m,bt){
        let gc=0,gi=0;const all=new Set([...m,...bt]);
        for(const k of all){const[r,c]=k.split(',').map(Number);if(iceB[r][c]>0){iceB[r][c]--;if(!iceB[r][c])gi++;}}
        for(const k of all){const[r,c]=k.split(',').map(Number);if(!iceB[r][c]&&miss.color&&board[r][c]===miss.color)gc++;}
        for(const k of all){const[r,c]=k.split(',').map(Number);board[r][c]=null;spec[r][c]=null;iceB[r][c]=0;}
        for(const[k,type] of find4Plus()){if(m.has(k)){const[r,c]=k.split(',').map(Number);board[r][c]=board[r][c]||COLORS[rnd(COLORS.length)];spec[r][c]=type;}}
        colGem+=gc;iceGem+=gi;combo++;
        if(combo>1){showComboText(combo);Sound.combo(combo);}
        else Sound.gemMatch(all.size);
        for(const k of m){const[r,c]=k.split(',').map(Number);if(spec[r][c]==='bomb'||spec[r][c]==='rainbow')Sound.bombExplode();}
        refreshMission();checkWin();refreshHUD();
    }

    function gravityWithFall(){
        const fm=mk2d(ROWS,COLS,0);
        for(let c=0;c<COLS;c++){
            let empty=0;
            for(let r=ROWS-1;r>=0;r--){
                if(!board[r][c]){empty++;}
                else if(empty>0){fm[r+empty][c]=empty;board[r+empty][c]=board[r][c];spec[r+empty][c]=spec[r][c];iceB[r+empty][c]=iceB[r][c];board[r][c]=null;spec[r][c]=null;iceB[r][c]=0;}
            }
            for(let r=0;r<empty;r++){board[r][c]=COLORS[rnd(COLORS.length)];spec[r][c]=null;iceB[r][c]=0;fm[r][c]=empty-r+1;}
        }
        return fm;
    }

    async function resolve(){
        if(busy||_destroyed)return;busy=true;
        let any=true;
        while(any&&active&&!_destroyed){
            const m=getMatches();if(!m.size){any=false;break;}
            const bt=getBombTargets(m);
            await burstCells(m,bt);
            processMatches(m,bt);
            if(!active||_destroyed)break;
            const fm=gravityWithFall();renderWithFall(fm);
            const maxF=Math.max(0,...fm.flat());await wait(Math.min(600,200+maxF*48));
        }
        busy=false;
        if(active&&!_destroyed&&!hasMoves())shuffle();
    }

    function sw(r1,c1,r2,c2){
        [board[r1][c1],board[r2][c2]]=[board[r2][c2],board[r1][c1]];
        [spec[r1][c1],spec[r2][c2]]=[spec[r2][c2],spec[r1][c1]];
        [iceB[r1][c1],iceB[r2][c2]]=[iceB[r2][c2],iceB[r1][c1]];
    }

    let swapping=false;
    async function trySwap(r1,c1,r2,c2){
        if(busy||!active||swapping||_destroyed)return;
        swapping=true;
        await animSwap(r1,c1,r2,c2);sw(r1,c1,r2,c2);
        if(getMatches().size){
            combo=0;renderAll();
            movesLeft--;refreshHUD();
            await resolve();
            if(movesLeft<=0&&active&&!checkWinSilent())showOutOfMoves();
        }else{
            await animSwap(r1,c1,r2,c2,true);sw(r1,c1,r2,c2);renderAll();
        }
        swapping=false;
    }

    // ── Input ──────────────────────────────────
    let dragStartCell=null;

    function getCell(x,y){
        const el2=document.elementFromPoint(x,y);
        const c2=el2?.closest('[data-r]');
        if(!c2)return null;
        return{r:+c2.dataset.r,c:+c2.dataset.c};
    }
    function isAdj(r1,c1,r2,c2){return Math.abs(r1-r2)+Math.abs(c1-c2)===1;}

    grid.addEventListener('touchstart',e=>{
        if(busy||!active||swapping)return;
        const t=e.touches[0];
        dragStartCell=getCell(t.clientX,t.clientY);
        if(dragStartCell&&boosterMode){
            useBooster(dragStartCell.r,dragStartCell.c);
            dragStartCell=null;return;
        }
        if(dragStartCell){selR=dragStartCell.r;selC=dragStartCell.c;applySel(selR,selC,true);}
    },{passive:true});

    grid.addEventListener('touchmove',e=>{
        if(!dragStartCell||busy||swapping||!active)return;
        e.preventDefault();
        const t=e.touches[0];const cur=getCell(t.clientX,t.clientY);
        if(cur&&(cur.r!==dragStartCell.r||cur.c!==dragStartCell.c)&&isAdj(dragStartCell.r,dragStartCell.c,cur.r,cur.c)){
            const{r:r1,c:c1}=dragStartCell;
            applySel(r1,c1,false);selR=null;selC=null;dragStartCell=null;
            Sound.gemTap();trySwap(r1,c1,cur.r,cur.c);
        }
    },{passive:false});

    grid.addEventListener('touchend',()=>{
        if(!dragStartCell)return;
        // Tap select
        dragStartCell=null;
    });

    // Mouse support
    grid.addEventListener('click',e=>{
        if(busy||!active||swapping)return;
        const cell2=e.target.closest('[data-r]');if(!cell2)return;
        const r=+cell2.dataset.r,c=+cell2.dataset.c;
        Sound.gemTap();
        if(boosterMode){useBooster(r,c);return;}
        if(selR===null){selR=r;selC=c;applySel(r,c,true);return;}
        if(selR===r&&selC===c){applySel(r,c,false);selR=null;selC=null;return;}
        if(isAdj(selR,selC,r,c)){
            const[pr,pc]=[selR,selC];applySel(pr,pc,false);selR=null;selC=null;trySwap(pr,pc,r,c);
        }else{applySel(selR,selC,false);selR=r;selC=c;applySel(r,c,true);}
    });

    // ── Boosters ──────────────────────────────
    function useBooster(r,c){
        if(boosterMode==='hammer'){
            if(!board[r][c])return;
            boosterMode=null;updateBoosterUI();
            boosters.hammer--;
            emitParticles(cells[r][c],board[r][c],8);
            const gm=cells[r][c].querySelector('.gm');
            if(gm){gm.style.transition='transform .15s ease,opacity .15s ease';gm.style.transform='scale(0)';gm.style.opacity='0';}
            board[r][c]=null;spec[r][c]=null;iceB[r][c]=0;
            Sound.bombExplode();
            setTimeout(async()=>{const fm=gravityWithFall();renderWithFall(fm);await wait(400);await resolve();},200);
        } else if(boosterMode==='lightning'){
            if(!board[r][c])return;
            boosterMode=null;updateBoosterUI();
            boosters.lightning--;
            // Clear entire row
            const affected=new Set();for(let cc=0;cc<COLS;cc++)affected.add(r+','+cc);
            burstCells(affected,new Set()).then(async()=>{
                for(const k of affected){const[rr,cc]=k.split(',').map(Number);board[rr][cc]=null;spec[rr][cc]=null;iceB[rr][cc]=0;}
                Sound.bombExplode();const fm=gravityWithFall();renderWithFall(fm);await wait(400);await resolve();
            });
        }
    }

    function activateBooster(type){
        if(boosters[type]<=0)return;
        boosterMode=boosterMode===type?null:type;
        updateBoosterUI();
    }

    function updateBoosterUI(){
        const btns=boosterBar.querySelectorAll('.bst-btn');
        btns.forEach(b=>{
            const t=b.dataset.type;
            b.style.opacity=boosters[t]>0?'1':'.3';
            b.style.border=boosterMode===t?'2px solid var(--amber)':'2px solid rgba(255,255,255,.12)';
            b.style.background=boosterMode===t?'rgba(200,134,10,.25)':'rgba(255,255,255,.06)';
        });
    }

    // ── Booster bar ────────────────────────────
    const boosterBar=el('div');
    css(boosterBar,{height:boosterH+'px',display:'flex',alignItems:'center',justifyContent:'center',gap:'12px',padding:'0 16px',flexShrink:'0',background:'rgba(0,0,0,.5)',backdropFilter:'blur(16px)',WebkitBackdropFilter:'blur(16px)',borderTop:'1px solid rgba(255,255,255,.08)'});
    const bstDefs=[{type:'hammer',icon:'🔨',label:'Молот'},{type:'lightning',icon:'⚡',label:'Молния'}];
    for(const b of bstDefs){
        const btn=el('button');btn.dataset.type=b.type;
        css(btn,{background:'rgba(255,255,255,.06)',border:'2px solid rgba(255,255,255,.12)',borderRadius:'14px',padding:'8px 14px',cursor:'pointer',display:'flex',flexDirection:'column',alignItems:'center',gap:'2px',minWidth:'64px'});
        const ico=el('div');css(ico,{fontSize:'22px',lineHeight:'1'});ico.textContent=b.icon;
        const lbl=el('div');css(lbl,{fontSize:'9px',letterSpacing:'1px',color:'rgba(255,255,255,.5)',fontWeight:'700',textTransform:'uppercase'});lbl.textContent=b.label;
        const cnt=el('div');css(cnt,{fontSize:'11px',fontWeight:'800',color:'#fff',fontFamily:"'JetBrains Mono',monospace"});cnt.textContent='×'+boosters[b.type];cnt.id='bst-cnt-'+b.type;
        btn.append(ico,lbl,cnt);
        btn.addEventListener('click',()=>{Sound.click();activateBooster(b.type);});
        boosterBar.appendChild(btn);
    }
    viewport.appendChild(boosterBar);

    function refreshBoosterCounts(){
        bstDefs.forEach(b=>{const el2=document.getElementById('bst-cnt-'+b.type);if(el2)el2.textContent='×'+boosters[b.type];});
    }

    // ── Out of moves overlay ───────────────────
    function showOutOfMoves(){
        active=false;Sound.noMoves();
        const ov=el('div');
        css(ov,{position:'absolute',inset:'0',background:'rgba(0,0,0,.75)',backdropFilter:'blur(8px)',WebkitBackdropFilter:'blur(8px)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',gap:'16px',zIndex:'50',borderRadius:'18px'});
        ov.innerHTML=`<div style="font-size:48px">😔</div><div style="font-size:18px;font-weight:800;color:#fff;letter-spacing:1px">ХОДЫ КОНЧИЛИСЬ</div><div style="font-size:13px;color:rgba(255,255,255,.55)">Попробуй ещё раз</div>`;
        const retryBtn=el('button');
        css(retryBtn,{background:'var(--amber,#c8860a)',border:'none',borderRadius:'14px',padding:'13px 28px',fontFamily:"'Inter',sans-serif",fontSize:'14px',fontWeight:'700',color:'#000',cursor:'pointer'});
        retryBtn.textContent='Начать заново';
        retryBtn.addEventListener('click',()=>{
            ov.remove();
            // Reset
            initBoard();placeIce();movesLeft=getMoves(level);
            colGem=0;iceGem=0;combo=0;active=true;busy=false;
            renderAll();entryAnim();refreshHUD();
        });
        ov.appendChild(retryBtn);
        gridWrap.appendChild(ov);
    }

    // ── Board init ─────────────────────────────
    function initBoard(){
        for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
            const no=new Set();
            if(c>=2&&board[r][c-1]===board[r][c-2])no.add(board[r][c-1]);
            if(r>=2&&board[r-1][c]===board[r-2][c])no.add(board[r-1][c]);
            const ok=COLORS.filter(x=>!no.has(x));board[r][c]=ok[rnd(ok.length)]||COLORS[0];
            spec[r][c]=null;
        }
    }
    function placeIce(){
        const n=miss.type==='clear_ice'?miss.target:(miss.targetIce||0);if(!n)return;
        const pos=[];for(let r=3;r<ROWS;r++)for(let c=0;c<COLS;c++)pos.push([r,c]);
        pos.sort(()=>Math.random()-.5);
        for(let i=0;i<Math.min(n,pos.length);i++){const[r,c]=pos[i];iceB[r][c]=level>20?2:1;}
    }
    function hasMoves(){
        for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++){
            if(c+1<COLS){sw(r,c,r,c+1);if(getMatches().size){sw(r,c,r,c+1);return true;}sw(r,c,r,c+1);}
            if(r+1<ROWS){sw(r,c,r+1,c);if(getMatches().size){sw(r,c,r+1,c);return true;}sw(r,c,r+1,c);}
        }return false;
    }
    function shuffle(){const f=board.flat();for(let i=f.length-1;i>0;i--){const j=rnd(i+1);[f[i],f[j]]=[f[j],f[i]];}let idx=0;for(let r=0;r<ROWS;r++)for(let c=0;c<COLS;c++)board[r][c]=f[idx++];resolve();}

    function checkWinSilent(){
        return miss.type==='collect'?colGem>=miss.target:miss.type==='clear_ice'?iceGem>=miss.target:colGem>=miss.targetCollect&&iceGem>=miss.targetIce;
    }
    function checkWin(){if(checkWinSilent()&&active&&!_destroyed){active=false;Sound.win3();setTimeout(()=>onWin(),300);}}

    function refreshMission(){
        const em=['🔴','🔵','🟢','🟡','🟣','🟠'][COLORS.indexOf(miss.color)]||'';
        if(miss.type==='collect')msEl.textContent=`${em} Собери: ${colGem}/${miss.target}`;
        else if(miss.type==='clear_ice')msEl.textContent=`❄️ Разморозь: ${iceGem}/${miss.target}`;
        else msEl.textContent=`${em} ${colGem}/${miss.targetCollect} ❄️ ${iceGem}/${miss.targetIce}`;
    }

    // ── Start ──────────────────────────────────
    initBoard();placeIce();renderAll();refreshHUD();
    setTimeout(()=>{if(!_destroyed)entryAnim();},80);
    if(!hasMoves())shuffle();
}

// ── Helpers ────────────────────────────────────
function getMission(l){
    const t=['collect','collect','collect','clear_ice','mixed'];
    const type=t[Math.min(Math.floor((l-1)/5),t.length-1)];
    if(type==='collect')return{type,color:COLORS[Math.floor((l-1)/5)%COLORS.length],target:10+Math.floor(l/2)*2};
    if(type==='clear_ice')return{type,target:5+Math.floor((l-15)/2)};
    return{type:'mixed',color:COLORS[l%COLORS.length],targetCollect:18+l,targetIce:6+Math.floor(l/4)};
}
function getMoves(l){return Math.max(18,30-Math.floor(l/5));}
function mk2d(r,c,v){return Array.from({length:r},()=>Array(c).fill(v));}
function rnd(n){return Math.floor(Math.random()*n);}
function wait(ms){return new Promise(r=>setTimeout(r,ms));}
function el(tag){return document.createElement(tag);}
function css(e,s){Object.assign(e.style,s);}

export function destroy(){_destroyed=true;}

