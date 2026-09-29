// Партия E-3: база-грядка, морковка, спавн, площадки, значки. После env_obj.js.
const HOLE='#3B2A22',PADL='#5E6270';
function carrotFull(x,y,a,k=1){const r=a*Math.PI/180,c=Math.cos(r),s=Math.sin(r),T=([u,v])=>[x+k*(u*c-v*s),y+k*(u*s+v*c)];
 return [{ds:[ER(...T([-2.6,-5]),2.4*k,6*k,a-25),ER(...T([0,-6]),2.4*k,7*k,a),ER(...T([2.6,-5]),2.4*k,6*k,a+25)],fill:K.sprout,line:2,sh:false},
 {ds:[RP([[-5.5,0],[5.5,0],[1.2,17],[-1.2,17]].map(T),[3,3,1.2,1.2])],fill:K.ui,r:4,hl:[...T([-2.5,3]),1.2*k,3*k,a],mark:[`<path d="M${P2(T([-4,5]))}L${P2(T([-1,5.5]))}M${P2(T([1,9]))}L${P2(T([3.5,8.5]))}" stroke="${sh(K.ui)}" stroke-width="1.3" stroke-linecap="round"/>`]}]}
const moundFront={ds:['M6 24Q16 20.5 26 24Q26 29 16 29Q6 29 6 24Z'],fill:K.soil,line:2,sh:false};
function carrotGround(S,P={}){const D=Doc(32,32,S),T=`rotate(${P.lean||0} 16 21) translate(0 ${-(P.up||0)}) `+(P.st?`translate(16 21) scale(1 ${P.st}) translate(-16 -21)`:''),I=[];
 I.push({ds:[E(16,25,10,4.2)],fill:K.soil,line:2,sh:false});
 I.push({tf:T,ds:[ER(12,13,2.6,6.5,-25),ER(16,11,2.6,7.5,0),ER(20,13,2.6,6.5,25)],fill:K.sprout,line:2,sh:false});
 I.push({tf:`translate(0 ${-(P.up||0)})`,ds:[E(16,22.5,6,4.2)],fill:K.ui,r:3,hl:[13.5,21,1.6,1,-20]});
 I.push({...moundFront,mark:P.crack?[`<path d="M10 25l2 2M22 25l-2 2" stroke="${HOLE}" stroke-width="1.3" stroke-linecap="round"/>`]:undefined});
 render(D,I);return D.svg()}
const crumbs=L=>({ds:L.map(([x,y])=>E(x,y,1.7,1.3)),fill:K.soil,line:1.3,sh:false});
function holeSvg(S,extra=[]){const D=Doc(32,32,S);render(D,[{ds:[E(16,24,10,4.5)],fill:K.soil,line:2,sh:false},{ds:[E(16,23.8,5.5,2.4)],fill:HOLE,line:0,sh:false},crumbs([[6.5,20.5],[25,21]]),...extra]);return D.svg()}
function carrotPull(S,k){if(k===0)return carrotGround(S,{st:1.25,up:2,crack:1});if(k===3)return holeSvg(S);
 const D=Doc(32,32,S),I=[{ds:[E(16,25,10,4.2)],fill:K.soil,line:2,sh:false},{ds:[E(16,24.5,5.5,2.4)],fill:HOLE,line:0,sh:false}];
 if(k===1)I.push(...carrotFull(16,12,8,.9),moundFront,crumbs([[6,14],[26,12],[23,18]]));
 else I.push(...carrotFull(17,5,-14,.9),crumbs([[5,10],[27,6],[8,20]]));
 render(D,I);return D.svg()}
function baseBed(S){const D=Doc(256,256,S),I=[];
 I.push({ds:[RR(12,58,232,188,20)],fill:sh(K.wood),sh:false},{ds:[RR(12,40,232,190,20)],fill:K.wood,r:22,hl:[60,46,40,2.4,0],sh:false});
 I.push({ds:[RR(26,54,204,160,12)],fill:K.soil,line:2.5,sh:false,mark:[80,116,152,188].map(y=>`<path d="M36 ${y+3}H220" stroke="${sh(K.soil)}" stroke-width="4" stroke-linecap="round"/>`)});
 I.push({ds:[[20,48],[236,48],[20,222],[236,222]].map(([x,y])=>E(x,y,6.5,5)),fill:K.woodL,r:4,sh:false});
 render(D,I);return D.svg()}
const SLOTS=[];for(let j=0;j<4;j++)for(let i=0;i<5;i++)SLOTS.push([50+i*39,80+j*36]);
function spawnSvg(S,fi=-1){const D=Doc(96,96,S),I=[];
 I.push({ds:[blob([[8,66],[16,48],[34,38],[62,38],[80,48],[88,66],[70,80],[26,80]])],fill:K.soil,r:16,hl:[30,46,8,3,-15]});
 I.push({ds:[E(48,62,22,11)],fill:'#2B2230',line:3,sh:false});
 const eyes={0:[[38,60],[44,60]],1:[[52,59],[58,59]],2:[[36,61],[42,61],[55,60],[61,60]]}[fi]||[];
 if(eyes.length)I.push({raw:eyes.map(([x,y])=>`<path d="${E(x,y,2.7,2.2)}" fill="#fff"/><path d="${E(x+.6,y+.3,1.3)}" fill="${K.pest}"/>`).join('')});
 I.push({ds:['M24 66Q48 80 72 66Q72 77 48 79Q24 77 24 66Z'],fill:K.soil,line:2.6,sh:false});
 I.push({ds:[E(14,72,6,4.5),E(83,70,5,4)],fill:K.stone,r:4,hl:[12,70,2,1,-20]});
 const sp={0:[[30,40],[62,34]],1:[[40,28],[70,42],[24,46]],2:[[48,24],[34,34],[64,30]]}[fi];if(sp)I.push(crumbs(sp.map(([x,y])=>[x,y])));
 I.push({raw:tuft(20,44,.8,false,K.grass2)+tuft(66,46,.8,false,K.grass2)});
 render(D,I);return D.svg()}
const PADP=[[64,4],[125,46],[64,88],[3,46]];
function padSvg(S,o={}){const D=Doc(128,96,S),Ls=Math.hypot(46,30),c=11,gp=6.5,d=(Ls-2*c-3*gp)/2,a=[c];for(let i=0;i<4;i++){a.push(gp,d,gp,d,gp);a.push(i<3?2*c:c)}
 let s=`<path d="${RP(PADP,12)}" fill="${o.fill||K.padG}"/>`;
 if(o.glow)s+=`<path d="${RP([[64,24],[98,46],[64,68],[30,46]],6)}" fill="none" stroke="${o.glow}" stroke-width="${o.gw}" stroke-linejoin="round"/>`;
 s+=`<path d="M64 16L110 46L64 76L18 46Z" fill="none" stroke="${o.dash||'#FFFFFF'}" stroke-width="${o.dw||4.5}" stroke-linejoin="round" stroke-dasharray="${a.map(f).join(' ')}"/>`;
 D.add(s);if(o.items)render(D,o.items);return D.svg()}
function lockIt(x,y,k=1,open=0,rot=0){const tf=`rotate(${rot} ${x} ${y})`,q=v=>f(v*k),sh_=open?`M${f(x-6*k)} ${f(y-8*k)}V${f(y-14*k)}Q${f(x-6*k)} ${f(y-21*k)} ${x} ${f(y-21*k)}Q${f(x+6*k)} ${f(y-21*k)} ${f(x+6*k)} ${f(y-14*k)}V${f(y-11*k)}`:`M${f(x-6*k)} ${f(y-2*k)}V${f(y-8*k)}Q${f(x-6*k)} ${f(y-15*k)} ${x} ${f(y-15*k)}Q${f(x+6*k)} ${f(y-15*k)} ${f(x+6*k)} ${f(y-8*k)}V${f(y-2*k)}`;
 return [{tf,limb:sh_,w:3.6*k,fill:K.stone},{tf,ds:[RR(x-10*k,y-3*k,20*k,16*k,4*k)],fill:K.panel,r:5,hl:[x-5*k,y,2*k,1.2*k,0],mark:[`<path d="${E(x,y+3*k,2.2*k)}" fill="${O}"/><path d="M${x} ${f(y+4*k)}V${f(y+8*k)}" stroke="${O}" stroke-width="${q(2.2)}" stroke-linecap="round"/>`]}]}
const PAD_LOCK={fill:PADL,dash:'#9EA3AE'};
function envMiscSheets(){const S=STY.a,s=small(S),out={},p='assets/e/',add=(n,fr,w,h)=>out[p+`${n}_${fr.length}f.svg`]=sheet(fr,w,h||w);
 out[p+'base_bed.svg']=baseBed(S);
 add('base_carrot_idle',[carrotGround(s,{lean:-6}),carrotGround(s,{lean:6})],32);
 add('base_carrot_pull',[0,1,2,3].map(k=>carrotPull(s,k)),32);out[p+'base_hole.svg']=holeSvg(s);
 add('spawn_burrow_idle',[spawnSvg(S)],96);add('spawn_burrow_exit',[0,1,2].map(i=>spawnSvg(S,i)),96);
 out[p+'pad_normal.svg']=padSvg(S);out[p+'pad_locked.svg']=padSvg(S,{...PAD_LOCK,items:lockIt(64,44)});
 out[p+'pad_max.svg']=padSvg(S,{dash:K.coin,items:[{ds:[starD(64,46,15,6.8)],fill:K.coin,r:6,hl:[60,40,2.4,1.4,-30]}]});
 add('pad_highlight',[{},{fill:'#377C3E',glow:'#9BDD7C',gw:5,dw:5.5},{fill:'#337439',glow:'#7ACB6A',gw:3,dw:5}].map(o=>padSvg(S,o)),128,96);
 add('pad_unlock',[padSvg(S,{...PAD_LOCK,items:lockIt(64,44)}),padSvg(S,{...PAD_LOCK,items:[...lockIt(64,40,1,1,-8),sparkIt([[86,24,5]])]}),padSvg(S,{items:[...lockIt(66,28,.8,1,16),sparkIt([[40,30,6],[92,40,5],[64,64,5]])]}),padSvg(S)],128,96);
 out[p+'pad_progress_track.svg']=`<svg xmlns="http://www.w3.org/2000/svg" width="128" height="96" viewBox="0 0 128 96"><path d="${E(64,46,32,21)}" fill="none" stroke="${O}" stroke-width="12"/><path d="${E(64,46,32,21)}" fill="none" stroke="#1F4A24" stroke-width="7"/></svg>`;
 out[p+'pad_progress_fill.svg']=`<svg xmlns="http://www.w3.org/2000/svg" width="128" height="96" viewBox="0 0 128 96"><path d="${E(64,46,32,21)}" fill="none" stroke="${K.coin}" stroke-width="7"/><path d="${E(64,45,31,20)}" fill="none" stroke="#FFF0B0" stroke-width="1.6"/></svg>`;
 [1,2,3].forEach(n=>{const D=Doc(48,16,s);render(D,[0,1,2].map(i=>({ds:[starD(8+i*16,8.6,6.4,2.9)],fill:i<n?K.coin:PADL,line:1.8,sh:false})));out[p+`ui_def_stars_${n}.svg`]=D.svg()});
 {const D=Doc(48,16,s);render(D,[{ds:[RR(3,3,42,10.5,5)],fill:K.red,line:2,r:3,hl:[12,5.5,6,1,0]}]);out[p+'ui_def_max_plate.svg']=D.svg()}
 out[p+'ui_attack_radius.svg']=`<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="0 0 256 256"><circle cx="128" cy="128" r="122" fill="#FFFFFF" fill-opacity=".16" stroke="#FFFFFF" stroke-opacity=".9" stroke-width="4"/><circle cx="128" cy="128" r="110" fill="none" stroke="#FFFFFF" stroke-opacity=".4" stroke-width="2.5" stroke-dasharray="10 9"/></svg>`;
 add('ui_edge_arrow',[[1,0],[1.12,3],[1.05,1.5]].map(([k,dx])=>{const D=Doc(64,64,s,`translate(${dx} 0) translate(32 32) scale(${k}) translate(-32 -32)`);render(D,[{ds:[RP([[10,25],[31,25],[31,13],[54,32],[31,51],[31,39],[10,39]],[4,1,3,4,3,1,4])],fill:K.ui,r:8,hl:[18,28,5,1.5,0]}]);return D.svg()}),64);
 return out}
