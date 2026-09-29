// Партия C: вредители (жук, гусеница, крот, ворона, босс-лис), портреты, HP-полоска, морковка. После gen.js, anim.js, heroes.js.
const PC=K.pest,PD=sh(K.pest),PL=K.pestL,PB='#C79BDD',SACK='#D9C08A';
Object.assign(SH,{'#C79BDD':'#A97BC2','#D9C08A':'#B89C62'});
Object.assign(HL,{'#C79BDD':'#E2C6EE','#D9C08A':'#F0DFB4'});
const unwrap=s=>s.replace(/^<svg[^>]*>/,'').replace(/<\/svg>$/,'');
const comb=(w,h,L)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${L.map(unwrap).join('')}</svg>`;
const rotP=(o,v,a)=>{const r=a*Math.PI/180,c=Math.cos(r),s=Math.sin(r);return [o[0]+v[0]*c-v[1]*s,o[1]+v[0]*s+v[1]*c]};
function spk(x,y,s){return RP([[x,y-s],[x+s*.26,y-s*.26],[x+s,y],[x+s*.26,y+s*.26],[x,y+s],[x-s*.26,y+s*.26],[x-s,y],[x-s*.26,y-s*.26]],s*.1)}
function pEyes(S,L,e){let o='';for(const [x,y,s] of L){const st=`fill="none" stroke="${O}" stroke-width="${f(Math.max(1.4,s*.4))}" stroke-linecap="round" stroke-linejoin="round"`;
 if(e==='dizzy'){const p=[];for(let k=0;k<=14;k++){const t=k/14,a=t*Math.PI*3.4,r=s*(.85-.7*t);p.push([x+Math.cos(a)*r,y+Math.sin(a)*r])}o+=`<path d="${E(x,y,s*.95)}" fill="#fff"/><path d="${curve(p)}" ${st}/>`}
 else if(e==='happy')o+=`<path d="M${f(x-s*.75)} ${f(y+s*.3)}Q${f(x)} ${f(y-s*.8)} ${f(x+s*.75)} ${f(y+s*.3)}" ${st}/>`;
 else if(e==='wide')o+=`<path d="${E(x,y,s*.95,s*1.1)}" fill="#fff" stroke="${O}" stroke-width="${f(Math.max(1,s*.2))}"/><path d="${E(x+s*.15,y,s*.34)}" fill="${O}"/>`;
 else o+=eyeSvg(S,x,y,s,'color');}return o}
function pMouth(m,x,y,k=1){const R='#C9475A',st=`stroke="${O}" stroke-width="${f(Math.max(1.3,1.4*k))}" stroke-linecap="round" stroke-linejoin="round"`,q=v=>f(v*k),tooth=`<path d="${RR(x-1.2*k,y+.3*k,2.6*k,2.3*k,.6*k)}" fill="#fff" stroke="${O}" stroke-width="${f(.8*k)}"/>`;
 switch(m){
  case 'open':return `<path d="M${f(x-4*k)} ${f(y-1.5*k)}Q${f(x)} ${f(y+5.5*k)} ${f(x+4*k)} ${f(y-2*k)}Z" fill="${R}" ${st}/>`+tooth;
  case 'chomp':return `<path d="M${f(x-3.8*k)} ${f(y)}L${f(x+3.8*k)} ${f(y-.6*k)}" fill="none" ${st}/>`+tooth;
  case 'o':return `<path d="${E(x,y+k,2*k,2.4*k)}" fill="${R}" ${st}/>`;
  case 'wavy':return `<path d="M${f(x-4*k)} ${f(y)}q${q(1.35)} ${q(-1.6)} ${q(2.7)} 0t${q(2.7)} 0t${q(2.7)} 0" fill="none" ${st}/>`;
  default:return `<path d="M${f(x-4.3*k)} ${f(y-.8*k)}Q${f(x)} ${f(y+2.6*k)} ${f(x+4.2*k)} ${f(y-1.6*k)}" fill="none" ${st}/>`+tooth;
 }}
function starsRing(cx,cy,rx,ry,R,ph,tf){return [0,1,2].map(k=>{const a=ph*Math.PI/2+k*Math.PI*2/3;return {tf,ds:[starD(cx+Math.cos(a)*rx,cy+Math.sin(a)*ry,R,R*.46)],fill:K.coin,line:Math.max(1.4,R*.34),sh:false}})}
function chipsIt(ph,x,y,k=1){const C=ph===1?[[2,-3],[5,1]]:ph===2?[[4,-6],[8,-1],[6,4]]:[];return C.length?[{ds:C.map(([dx,dy],i)=>ER(x+dx*k,y+dy*k,1.7*k,1.1*k,i*50)),fill:K.woodL,line:Math.max(1,1.1*k),sh:false}]:[]}
function poofSvg(S,w,h,cx,cy,R){const D=Doc(w,h,S),pts=[[0,0,.62],[-.6,.2,.44],[.62,.22,.45],[-.3,-.48,.4],[.34,-.46,.4],[0,.42,.38]];
 render(D,[{ds:pts.map(([x,y,r])=>E(cx+x*R,cy+y*R,r*R)),fill:'#FFF4DC',line:Math.max(1.8,R*.1),sh:false},{ds:[spk(cx-R*1.02,cy-R*.6,R*.22),spk(cx+R*1,cy-R*.72,R*.18)],fill:'#FFF0B0',line:Math.max(1.2,R*.07),sh:false}]);return D.svg()}
const blank=(w,h,S)=>Doc(w,h,S).svg();
function defeat(fn,S,w,h,c,R,x={}){return [fn(S,{eyes:'dizzy',mouth:'wavy',stars:0,rot:-6,...x}),fn(S,{eyes:'dizzy',mouth:'wavy',stars:1,rot:10,by:.5,...x}),fn(S,{eyes:'dizzy',mouth:'o',stars:2,rot:-16,by:1,...x}),poofSvg(S,w,h,c[0],c[1],R),blank(w,h,S)]}

// ---------- Жук 48 ----------
function bug(S,P={}){
 const D=Doc(48,48,S,`translate(${P.dx||0} ${-(P.lift||0)}) rotate(${P.rot||0} 24 38)`),I=[],by=P.by||0,at=P.ant||0;
 const LF=P.legs||[[0,0],[0,0],[0,0]],LB=P.legsB||[[0,0],[0,0],[0,0]],HT=`translate(${P.hx||0} ${(P.hy||0)+by}) rotate(${P.hr||0} 33 34)`;
 I.push({tf:HT,limb:curve([[33.5,22],[31.5,16+at/2],[29,13+at]]),w:1.6,fill:PD},{tf:HT,limb:curve([[38,22],[40,16+at/2],[42.5,13.5+at]]),w:1.6,fill:PD},{tf:HT,ds:[E(28.8,12.5+at,2.4),E(43,13+at,2.4)],fill:PL,sh:false});
 [[13,34,11,40.5],[21,36,20,41.5],[29,36,30,41.5]].forEach(([a,b,c,d],i)=>I.push({limb:curve([[a,b+by],[c+LB[i][0],d+LB[i][1]]]),w:3,fill:PD}));
 I.push({ds:[E(21,28.5+by,15.5,12)],fill:PC,r:12,hl:[13.5,23+by,4.6,2.6,-30],mark:[`<path d="M31 ${19+by}Q21 ${21+by} 9 ${31+by}" fill="none" stroke="${O}" stroke-width="1.6" stroke-linecap="round"/>`]});
 [[15,37,14,42.5],[23,38,23.5,43],[31,37,33,42.5]].forEach(([a,b,c,d],i)=>I.push({limb:curve([[a,b+by],[c+LF[i][0],d+LF[i][1]]]),w:3,fill:PC}));
 I.push({tf:HT,ds:[E(35.5,30,9.6,9.2)],fill:PL,r:9,hl:[32,25,3,1.8,-30]});
 I.push({raw:`<g transform="${HT}">${pEyes(S,[[33,27.5,3.7],[39,28,4.3]],P.eyes)}${pMouth(P.mouth,38.8,35)}</g>`});
 if(P.carrot)I.push(...projItems('carrot',P.carrot[0],P.carrot[1],P.carrot[2],.5,HT));
 I.push(...chipsIt(P.chips,42,34,.7));
 if(P.stars!=null)I.push(...starsRing(35,17,11,3,3.2,P.stars,HT));
 render(D,I);return D.svg();
}
// ---------- Гусеница 64 ----------
function cat(S,P={}){
 const D=Doc(64,64,S,`translate(${P.dx||0} ${-(P.lift||0)}) rotate(${P.rot||0} 32 50)`),I=[],W=P.wy||[0,0,0,0],by=P.by||0;
 const seg=[[9,42,7.2],[18.5,41.5,8],[28,41,8.6],[37.5,40.5,9]],HT=`translate(${P.hx||0} ${(P.hy||0)+by+W[3]*.6}) rotate(${P.hr||0} 44 41)`;
 seg.forEach(([x],i)=>I.push({ds:[E(x+1,50+Math.min(0,W[i])*.45,2.7,2.1)],fill:PD,line:1.8,sh:false}));
 seg.forEach(([x,y,r],i)=>I.push({ds:[E(x,y+W[i]+by,r)],fill:i%2?PL:PC,r,hl:[x-r*.4,y+W[i]+by-r*.45,r*.28,r*.17,-30]}));
 I.push({tf:HT,limb:curve([[44,25],[41.5,19],[39,15]]),w:1.8,fill:PD},{tf:HT,limb:curve([[51,25],[53.5,19],[56,15.5]]),w:1.8,fill:PD},{tf:HT,ds:[E(39,15,2.6),E(56,15.5,2.6)],fill:PL,sh:false});
 I.push({tf:HT,ds:[E(48,33,11.5,11)],fill:PC,r:11,hl:[43.5,27,3.4,2,-30]});
 I.push({raw:`<g transform="${HT}">${pEyes(S,[[45,31,4.3],[52.5,31.5,4.9]],P.eyes)}${pMouth(P.mouth,52,38.5,1.1)}</g>`});
 if(P.carrot)I.push(...projItems('carrot',P.carrot[0],P.carrot[1],P.carrot[2],.55,HT));
 I.push(...chipsIt(P.chips,54,37,.7));
 if(P.stars!=null)I.push(...starsRing(48,16,13,3.5,3.6,P.stars,HT));
 render(D,I);return D.svg();
}
// ---------- Крот 56 ----------
function mole(S,P={}){
 const D=Doc(56,56,S,`translate(${P.dx||0} ${-(P.lift||0)}) rotate(${P.rot||0} 28 48)`),I=[],by=P.by||0;
 const [fdx,fdy]=P.footF||[0,0],[bdx,bdy]=P.footB||[0,0],HT=`translate(${P.hx||0} ${(P.hy||0)+by}) rotate(${P.hr||0} 34 36)`,TB=`translate(0 ${by})`;
 I.push({tf:TB,limb:'M10 38Q6 37 5 34',w:2,fill:K.pink});
 I.push({ds:[E(18+bdx,46.5+bdy,5.5,3.2)],fill:sh(PD),line:2.2,sh:false});
 I.push({tf:TB,ds:[E(25,35,16,13)],fill:PC,r:13,hl:[16,28,4,2.2,-30],mark:[`<path d="${E(31,41,9,7)}" fill="${PB}"/>`]});
 I.push({ds:[E(31+fdx,47+fdy,6,3.4)],fill:PD,line:2.2,sh:false});
 I.push({tf:HT,ds:[E(36,27,11,10)],fill:PC,r:10,hl:[31,21.5,3.2,1.8,-30]});
 I.push({tf:HT,limb:'M33 17.5Q34 14 37.5 14.5',w:2,fill:PC});
 I.push({tf:HT,ds:[E(47.5,29,4.8,3.8)],fill:K.pink,r:4,hl:[46,27.4,1.4,.9,-20]});
 I.push({raw:`<g transform="${HT}">${pEyes(S,[[35,25,3.4],[41,25.5,3.8]],P.eyes)}${pMouth(P.mouth,43,33.5,.9)}</g>`});
 const pw=rotP([38,37],[6,6],P.armF||0);
 I.push({tf:TB,ds:[E(pw[0],pw[1],4.6,3.8)],fill:K.cream,line:2.2,off:1.2,mark:[`<path d="M${f(pw[0]+1)} ${f(pw[1]-3.5)}V${f(pw[1]+3.5)}M${f(pw[0]+3.2)} ${f(pw[1]-2.5)}V${f(pw[1]+2.5)}" stroke="${O}" stroke-width="1"/>`]});
 if(P.carrot)I.push(...projItems('carrot',pw[0]+1,pw[1]-5,-150,.5,TB));
 I.push(...chipsIt(P.chips,50,36,.6));
 if(P.stars!=null)I.push(...starsRing(36,13,12,3.2,3.2,P.stars,HT));
 render(D,I);return D.svg();
}
function moundSvg(S,ph,big=0,crack=0){const D=Doc(56,56,S),s=1+big*.18,cx=29+ph*1.5;
 const pts=[[-16,1],[-12,-4],[-6,-8.5-ph],[1,-10.5-ph*.5],[8,-8],[13,-4],[16,1]].map(([x,y])=>[cx+x*s,48+y*s]);
 const cr=crack?[`<path d="M${f(cx-3)} ${f(39)}l2 3l-2 2.5M${f(cx+5)} ${f(41)}l-1.5 2.5l2 2" fill="none" stroke="${O}" stroke-width="1.3" stroke-linecap="round" stroke-linejoin="round"/>`]:[];
 render(D,[{ds:[blob(pts)],fill:K.soil,r:6,hl:[cx-5*s,40.5,3*s,1.5,-15],mark:cr},{ds:[[-11,42.5],[12,43.5],[2+ph*2,35.5-big*3]].map(([x,y])=>E(cx+x*s,y,1.6,1.2)),fill:K.soil,line:1.3,sh:false}]);return D.svg()}
function diveHole(S){const D=Doc(56,56,S);render(D,[{ds:[E(34,47.5,12,3.6)],fill:'#3B2A22',line:2.2,sh:false},{limb:'M31 46Q30 40 27 37',w:4,fill:PD},{limb:'M37 46Q39 40 42 38',w:4,fill:PD},{ds:[E(26.5,36,3.6,2.4),E(42.8,37,3.6,2.4)],fill:sh(PD),line:1.8,sh:false},{limb:'M34 46Q34 41 32 39',w:2,fill:K.pink},{ds:[E(19,40,2.2,1.6),E(47,38,2.4,1.7),E(23,33,1.8,1.3),E(44,31,1.9,1.4),E(33,30,1.6,1.2)],fill:K.soil,line:1.4,sh:false}]);return D.svg()}
// ---------- Ворона 56 ----------
function crow(S,P={}){
 const D=Doc(56,56,S,`translate(${P.dx||0} ${P.dy||0}) rotate(${P.rot||0} 28 28)`),I=[],by=P.by||0,wa=P.wing??20,T=`translate(0 ${by})`;
 const wingD=(a,k)=>{const r=a*Math.PI/180,c=Math.cos(r),s=Math.sin(r),o=[27,24+by];return blob([[2,-3],[-7,-6.5],[-17,-5],[-21,-1],[-15,1.5],[-18,4],[-9,4.5],[1,4]].map(([x,y])=>[o[0]+k*(x*c-y*s),o[1]+k*(x*s+y*c)]))};
 I.push({ds:[wingD(wa+14,.88)],fill:PD,sh:false});
 I.push({tf:T,ds:[RP([[16,27],[4,22],[3,28],[5,33],[16,31]],2.5)],fill:PC,r:5});
 if(P.claws)I.push({tf:T,limb:curve([[28,35],[30,42]]),w:2.2,fill:K.ui},{tf:T,limb:curve([[23,35],[23.5,42]]),w:2.2,fill:K.ui});
 else I.push({tf:T,ds:[E(23,37.5,2.6,1.8),E(28.5,37.5,2.6,1.8)],fill:K.ui,line:1.6,sh:false});
 if(P.carrot)I.push(...projItems('carrot',26,45,P.carrot,.45,T));
 I.push({tf:T,ds:[E(25,29,12.5,9.5)],fill:PC,r:9.5,hl:[18,24.5,3.4,1.9,-25],mark:[`<path d="${E(29,33.5,7,5)}" fill="${PL}"/>`]});
 const HT=`translate(${P.hx||0} ${(P.hy||0)+by}) rotate(${P.hr||0} 36 26)`,op=['open','o'].includes(P.mouth);
 I.push({tf:HT,ds:[ER(35,12.5,1.8,4,-20),ER(38.5,12,1.8,4.2,15)],fill:PC,sh:false});
 I.push({tf:HT,ds:[E(37,21,8.8,8.2)],fill:PC,r:8,hl:[33.5,16.5,2.6,1.5,-30]});
 if(op)I.push({tf:HT,ds:[RP([[44,20],[51,23],[44,26]],1)],fill:'#C9475A',sh:false},{tf:HT,ds:[RP([[44,18.5],[53,20.5],[44.5,22]],1.5)],fill:K.coin,line:1.8,sh:false},{tf:HT,ds:[RP([[44.5,23.5],[51,26.5],[44,27]],1.5)],fill:K.coin,line:1.8,sh:false});
 else I.push({tf:HT,ds:[RP([[44,19],[53,22.5],[44,26]],2)],fill:K.coin,r:4});
 I.push({raw:`<g transform="${HT}">${pEyes(S,[[36,19.5,3.1],[40.8,19.8,3.5]],P.eyes)}</g>`});
 I.push({ds:[wingD(wa,1)],fill:PC,r:6,hl:[20,20+by,3,1.4,-20]});
 if(P.stars!=null)I.push(...starsRing(38,9,10,2.8,3,P.stars,HT));
 render(D,I);return D.svg();
}
// ---------- Босс-Лис 192 ----------
function sackIt(x,y,s,fill,ang,tf=''){const r=ang*Math.PI/180,c=Math.cos(r),n=Math.sin(r),T=([u,v])=>[x+s*(u*c-v*n),y+s*(u*n+v*c)],I=[];
 for(let i=0;i<fill;i++){const [lx,ly]=T([-8+i*4,-30]);I.push({tf,ds:[ER(lx,ly,1.9*s,5.4*s,(i-2)*16+ang)],fill:K.sprout,line:1.8,sh:false})}
 I.push({tf,ds:[blob([[-19,-4],[-13,-17],[0,-21],[13,-17],[19,-3],[17,12],[0,19],[-17,12]].map(T))],fill:SACK,r:18,hl:[...T([-9,-10]),4,2.4,-30],mark:[`<path d="${RP([[3,2],[12,1],[12,10],[4,10]].map(T),1.5)}" fill="#B89C62"/>`]});
 I.push({tf,ds:[RP([[-6,-27],[6,-27],[4,-19],[-4,-19]].map(T),2)],fill:SACK,r:4});
 I.push({tf,limb:`M${P2(T([-6.5,-20]))}L${P2(T([6.5,-20]))}`,w:3,fill:K.wood});
 return I}
function foxMouth(m){const R='#C9475A',st=`stroke="${O}" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"`,fang=`<path d="${RP([[131,82.5],[135.5,83.5],[132.5,88.5]],1)}" fill="#fff" stroke="${O}" stroke-width="1.6" stroke-linejoin="round"/>`;
 switch(m){
  case 'open':return `<path d="M125 79Q136 95 147 77Z" fill="${R}" ${st}/>`+fang;
  case 'grin':return `<path d="M124 78Q136 97 148 76Z" fill="${R}" ${st}/>`+fang;
  case 'tongue':return `<path d="M134 83Q135 93 141 91Q143 86 141 82Z" fill="${K.pink}" ${st}/><path d="M126 80Q135 87 145 78" fill="none" ${st}/>`;
  case 'o':return `<path d="${E(137,83,4.5,5.5)}" fill="${R}" ${st}/>`;
  case 'wavy':return `<path d="M126 81q3.3 -3.5 6.6 0t6.6 0t6.6 0" fill="none" ${st}/>`;
  default:return `<path d="M126 80Q135 87 145 78" fill="none" ${st}/>`+fang;
 }}
function fox(S,P={}){
 const D=Doc(192,192,S,`translate(${P.dx||0} ${-(P.lift||0)}) rotate(${P.lean||0} 96 176)`),I=[],by=P.by||0,hb=by+(P.hy||0);
 const [fdx,fdy]=P.footF||[0,0],[bdx,bdy]=P.footB||[0,0],aF=P.armF||0,aB=P.armB||0,sk=P.sack??'back',fl=P.fill||0;
 const TB=`translate(0 ${by})`,HT=`translate(0 ${hb}) rotate(${P.ht||0} 104 96)`;
 I.push({tf:TB+` rotate(${P.tail||0} 76 134)`,ds:[blob([[78,140],[58,147],[38,139],[26,121],[24,101],[32,84],[43,95],[49,113],[62,124],[78,127]])],fill:PC,r:16,hl:[34,104,3.5,7,-20],mark:[`<path d="${ER(29,92,10,12.5,-15)}" fill="${K.cream}"/>`]});
 if(sk==='back')I.push(...sackIt(60,106,1+fl*.05,fl,-12,TB));
 I.push({limb:curve([[88,148+by],[84+bdx*.5,160+bdy*.5],[80+bdx,167+bdy]]),w:15,fill:PD},{ds:[E(77+bdx,172+bdy,12,6)],fill:sh(PD),sh:false});
 const sB=[84,104],hB=rotP(sB,[-4,26],aB);
 I.push({tf:TB,limb:curve([sB,rotP(sB,[-3,13],aB),hB]),w:12,fill:PD},{tf:TB,ds:[E(hB[0],hB[1],7,6.5)],fill:sh(PD),sh:false});
 I.push({tf:TB,ds:[E(98,132,24,30)],fill:PC,r:24,hl:[82,116,4.5,8,-20],mark:[`<path d="${ER(108,131,13,20,-8)}" fill="${K.cream}"/>`]});
 if(sk==='back')I.push({tf:TB,limb:'M90 108L118 152',w:3.4,fill:K.wood});
 I.push({limb:curve([[106,150+by],[110+fdx*.5,160+fdy*.5],[112+fdx,167+fdy]]),w:15,fill:PC},{ds:[E(116+fdx,172+fdy,13,6.5)],fill:PD,sh:false});
 I.push({tf:TB,ds:[RP([[86,98],[124,96],[108,118]],4)],fill:K.red,r:6});
 const sF=[110,106],hF=rotP(sF,[6,26],aF),arm=[{tf:TB,limb:curve([sF,rotP(sF,[3,13],aF),hF]),w:12,fill:PC},{tf:TB,ds:[E(hF[0],hF[1],7.5,7)],fill:PD,sh:false}];
 if(P.hc)[-20,0,20].slice(0,P.hc).forEach(a=>arm.push(...projItems('carrot',hF[0]+a*.3,hF[1]+10,a,.8,TB)));
 if(P.impact)arm.push({tf:TB,ds:[spk(hF[0]+12,hF[1]+4,15)],fill:'#FFF0B0',line:2.6,sh:false});
 if(P.fly)P.fly.forEach(([x,y,a])=>I.push(...projItems('carrot',x,y,a,.8)));
 if(!P.armFront)I.push(...arm);
 I.push({tf:HT,ds:[RP([[82,58],[79,20],[103,44]],5)],fill:PC,sh:false,mark:[`<path d="${RP([[86,52],[84.5,31],[98,45]],3)}" fill="${PB}"/>`]});
 I.push({tf:HT,ds:[E(108,66,30,25),RP([[82,72],[71,90],[94,83]],3)],fill:PC,r:25,hl:[92,51,7,3.4,-25],mark:[`<path d="${ER(120,84,26,11,-8)}" fill="${K.cream}"/>`]});
 I.push({tf:HT,ds:[RP([[110,44],[127,15],[135,47]],5)],fill:PC,sh:false,mark:[`<path d="${RP([[116,43],[126,26],[130,45]],3)}" fill="${PB}"/>`]});
 I.push({tf:HT,ds:[blob([[116,70],[134,64],[150,67],[153,74],[141,82],[118,84]])],fill:K.cream,r:8,hl:[130,67.5,5,2,-8]});
 I.push({tf:HT,ds:[E(150,69.5,5.5,4.5)],fill:O,line:0,sh:false,mark:[`<path d="${E(148.4,68,1.8,1.1)}" fill="#fff"/>`]});
 const bst=`fill="none" stroke="${O}" stroke-width="3" stroke-linecap="round"`,brows=(!P.eyes||P.eyes==='open')?`<path d="M94 51.5L106.5 55" ${bst}/><path d="M114 54L127 49.5" ${bst}/>`:'';
 I.push({raw:`<g transform="${HT}">${pEyes(S,[[102,62,7.2],[120,61,8.2]],P.eyes)}${brows}${foxMouth(P.mouth)}</g>`});
 if(P.armFront)I.push(...arm);
 if(P.stars!=null)I.push(...starsRing(108,24,34,8,8,P.stars,HT));
 render(D,I);return D.svg();
}
function sackDoc(S,x,y,a,fl=0){const D=Doc(192,192,S);render(D,sackIt(x,y,1,fl,a));return D.svg()}
function groundSack(S){const D=Doc(192,192,S),I=[...sackIt(58,158,1,2,72)];[[84,171,80],[99,173,100],[112,170,66]].forEach(([x,y,a])=>I.push(...projItems('carrot',x,y,a,.75)));render(D,I);return D.svg()}

function pestSheets(){
 const S=STY.a,s=small(S),out={},p='assets/c/';
 const add=(name,fr,w)=>{out[p+`${name}_${fr.length}f.svg`]=sheet(fr,w,w)};
 const BUGA={chew:[{hx:-2,mouth:'open',ant:1},{hy:.5,mouth:'chomp',chips:1,ant:-.5},{hx:-1,mouth:'smile',chips:2,ant:.5}],grab:[{hx:-2,hy:3,hr:14,rot:4,mouth:'open'},{hx:-1,hy:2,hr:8,rot:3,mouth:'chomp',carrot:[42,38,-85]},{hy:-1,hr:-6,mouth:'chomp',eyes:'happy',carrot:[42.5,33,-35],ant:-1}]};
 add('enemy_beetle_walk',WALK.map(P=>bug(s,P)),48);
 add('enemy_beetle_chew',BUGA.chew.map(P=>bug(s,P)),48);
 add('enemy_beetle_grab',BUGA.grab.map(P=>bug(s,P)),48);
 add('enemy_beetle_defeat',defeat(bug,s,48,48,[24,32],13),48);
 const CW=[[-4,-1,0,0],[0,-4,-1,0],[0,0,-4,-1],[-1,0,0,-4]];
 add('enemy_caterpillar_walk',CW.map((wy,i)=>cat(s,{wy,hy:[0,0,-.5,-1][i]})),64);
 add('enemy_caterpillar_chew',[{hx:-2,mouth:'open'},{hy:.5,mouth:'chomp',chips:1},{hx:-1,mouth:'smile',chips:2}].map(P=>cat(s,P)),64);
 add('enemy_caterpillar_grab',[{hx:-2,hy:5,hr:14,mouth:'open'},{hx:-1,hy:4,hr:10,mouth:'chomp',carrot:[53,44,-75]},{hy:-2,hr:-6,mouth:'chomp',eyes:'happy',carrot:[53.5,39,-35]}].map(P=>cat(s,P)),64);
 add('enemy_caterpillar_defeat',defeat(cat,s,64,64,[32,38],17),64);
 add('enemy_mole_walk',[{footF:[3,0],footB:[-3,-2],armF:18},{footF:[0,-1.5],by:-1.2},{footF:[-3,-2],footB:[3,0],armF:-18},{footB:[0,-1.5],by:-1.2}].map(P=>mole(s,P)),56);
 add('enemy_mole_dive',[mole(s,{by:2,hy:2,hr:16,armF:40,eyes:'happy'}),mole(s,{rot:36,lift:3,dx:-3,armF:-70}),diveHole(s),moundSvg(s,0)],56);
 add('enemy_mole_underground',[moundSvg(s,0),moundSvg(s,1)],56);
 add('enemy_mole_emerge',[moundSvg(s,0,1,1),comb(56,56,[mole(s,{lift:-6,armF:-100,mouth:'open'}),moundSvg(s,0,.6,1)]),comb(56,56,[moundSvg(s,0,-.4),mole(s,{lift:6,armF:-110,eyes:'happy',mouth:'open',footF:[1,-2],footB:[-1,-2]})]),mole(s,{})],56);
 add('enemy_mole_chew',[{hx:-2,mouth:'open'},{hy:.5,mouth:'chomp',chips:1},{hx:-1,mouth:'smile',chips:2}].map(P=>mole(s,P)),56);
 add('enemy_mole_grab',[{hx:-3,hy:3,hr:12,rot:5,armF:-20,mouth:'open'},{hx:-2,hy:2,hr:6,rot:4,armF:-40,carrot:1},{hx:-1,hy:-1,hr:-6,armF:-115,carrot:1,eyes:'happy',mouth:'open'}].map(P=>mole(s,P)),56);
 add('enemy_mole_defeat',defeat(mole,s,56,56,[28,36],15),56);
 add('enemy_crow_fly',[{wing:62,by:1},{wing:22},{wing:-22,by:-1.5},{wing:22,by:-.5}].map(P=>crow(s,P)),56);
 add('enemy_crow_swoop',[{rot:28,wing:70,dy:2,hr:-5},{rot:8,wing:40,dy:4,claws:1,carrot:-10,mouth:'open'},{rot:-18,wing:-15,dy:1,claws:1,carrot:-20,eyes:'happy'}].map(P=>crow(s,P)),56);
 add('enemy_crow_defeat',defeat(crow,s,56,56,[28,26],15,{wing:30}),56);
 out[p+'enemy_crow_shadow_1f.svg']=`<svg xmlns="http://www.w3.org/2000/svg" width="56" height="56" viewBox="0 0 56 56"><path d="${E(28,50,13,3.6)}" fill="${O}" opacity=".22"/></svg>`;
 const FW=[{footF:[12,0],footB:[-12,-1],armF:-22,armB:22,by:1,tail:3},{footF:[3,0],footB:[-2,-7],armF:-6,armB:6,by:2,tail:6},{footF:[-6,0],footB:[6,-5],armF:12,armB:-12,by:-2,tail:1},{footF:[-12,-1],footB:[12,0],armF:22,armB:-22,by:1,tail:3},{footF:[-2,-7],footB:[3,0],armF:6,armB:-6,by:2,tail:6},{footF:[6,-5],footB:[-6,0],armF:-12,armB:12,by:-2,tail:1}].map(q=>({lean:3,...q}));
 const RUNF=[{footF:[14,-2],footB:[-14,-6],armF:-40,armB:40,by:-1,tail:-14},{footF:[-12,-6],footB:[12,-2],armF:40,armB:-40,by:1,tail:-10}].map(q=>({...q,sack:'none',eyes:'wide',mouth:'o',lean:12}));
 add('boss_fox_appear',[fox(S,{...FW[0],dx:-80}),fox(S,{...FW[3],dx:-40}),fox(S,{...FW[1],dx:-8}),fox(S,{armF:-130,armFront:1,mouth:'tongue',eyes:'happy',lean:-4,tail:12}),fox(S,{armF:-105,armFront:1,mouth:'tongue',eyes:'happy',lean:-7,tail:-8,hy:1}),fox(S,{})],192);
 add('boss_fox_walk',FW.map(P=>fox(S,P)),192);
 add('boss_fox_strike',[{lean:-8,armF:150,armB:-20,footF:[8,0],footB:[-8,0]},{lean:10,armF:-70,armFront:1,mouth:'open',footF:[10,0],footB:[-8,0]},{lean:14,armF:-40,armFront:1,mouth:'open',impact:1,footF:[10,0],footB:[-8,0]},{lean:6,armF:-10,footF:[6,0],footB:[-6,0]},{}].map(P=>fox(S,P)),192);
 add('boss_fox_stun',[0,1,2,3].map(i=>fox(S,{lean:[-3,0,3,0][i],ht:[-6,0,6,0][i],hy:i%2,eyes:'dizzy',mouth:'wavy',stars:i,tail:-8,armF:10,armB:-10})),192);
 add('boss_fox_grab',[{lean:14,by:3,hy:3,armF:-25,armFront:1},{lean:12,by:3,hy:3,armF:-30,armFront:1,hc:3,eyes:'happy',mouth:'grin'},{armF:150,hc:1,fill:2,fly:[[76,62,150],[62,70,210]]},{lean:-2,fill:5,eyes:'happy',mouth:'grin',armF:-10}].map(P=>fox(S,P)),192);
 add('boss_fox_defeat',[fox(S,{eyes:'dizzy',mouth:'wavy',stars:0,lean:-5,ht:-6}),fox(S,{eyes:'dizzy',mouth:'wavy',stars:1,lean:6,ht:7,tail:-10}),fox(S,{eyes:'dizzy',mouth:'o',stars:2,lean:-8,ht:-8}),comb(192,192,[fox(S,{eyes:'wide',mouth:'o',sack:'none',lean:-4,armF:30,armB:-30}),sackDoc(S,48,152,40,2)]),comb(192,192,[groundSack(S),fox(S,{...RUNF[0],dx:14})]),comb(192,192,[groundSack(S),fox(S,{...RUNF[1],dx:58})]),comb(192,192,[poofSvg(S,192,192,70,156,30),fox(S,{...RUNF[0],dx:112})]),blank(192,192,S)],192);
 const port=(svg,vb)=>`<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="${vb}">${unwrap(svg)}</svg>`;
 out[p+'ui_enemy_portrait_beetle.svg']=port(bug(s,{}),'0 3 48 48');
 out[p+'ui_enemy_portrait_caterpillar.svg']=port(cat(s,{}),'0 2 64 64');
 out[p+'ui_enemy_portrait_mole.svg']=port(mole(s,{}),'0 0 56 56');
 out[p+'ui_enemy_portrait_crow.svg']=port(crow(s,{wing:40}),'0 0 56 56');
 out[p+'ui_enemy_portrait_fox.svg']=port(fox(S,{sack:'none'}),'54 10 108 108');
 out[p+'ui_hp_mini_frame.svg']=`<svg xmlns="http://www.w3.org/2000/svg" width="48" height="6" viewBox="0 0 48 6"><rect width="48" height="6" rx="3" fill="${O}"/><rect x="1.5" y="1.5" width="45" height="3" rx="1.5" fill="#4A4858"/></svg>`;
 out[p+'ui_hp_mini_fill.svg']=`<svg xmlns="http://www.w3.org/2000/svg" width="45" height="3" viewBox="0 0 45 3"><rect width="45" height="3" rx="1.5" fill="${K.red}"/><rect x="1.5" y=".45" width="42" height=".9" rx=".45" fill="#F59287"/></svg>`;
 {const D=Doc(24,24,s);render(D,projItems('carrot',12,12.5,-35,.75));out[p+'item_carrot_hold.svg']=D.svg()}
 return out;
}
