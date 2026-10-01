// Партия B: риг героя на 5 скинов, 8 анимаций, портреты/аватары/заглушки, снаряды, «шлёп», аура. После gen.js + anim.js.
Object.assign(SH,{'#F0A04B':'#CC7B2E','#FFB0C0':'#EE8AA2','#E77A93':'#C45C76','#FFE07A':'#E6B545','#C98B4A':'#A56C33','#F7A1B5':'#E27D96','#E0584B':'#B8433A'});
Object.assign(HL,{'#F0A04B':'#FFCB8E','#FFB0C0':'#FFD8E0','#E77A93':'#F5A5B8','#FFE07A':'#FFF3C2','#C98B4A':'#E3B27C','#F7A1B5':'#FFCFDA'});
const SKINS={
 raccoon:{fur:K.fur,torso:K.denim,bib:1,btn:K.coin,sleeve:K.ui,leg:K.denim,foot:K.furD,hand:K.furD,tail:'raccoon',head:'raccoon',proj:'apple',ek:'mask',mouth:[93.5,71]},
 corgi:{fur:'#F0A04B',torso:'#F0A04B',belly:K.cream,leg:'#F0A04B',foot:K.cream,hand:K.cream,tail:'stub',head:'corgi',hatC:K.red,proj:'bone',ek:'color',mouth:[94,72.5]},
 pig:{fur:'#FFB0C0',torso:K.straw,bib:1,btn:K.wood,leg:K.straw,foot:'#E77A93',hand:'#E77A93',tail:'curl',head:'pig',proj:'acorn',ek:'color',mouth:[87,75]},
 rabbit:{fur:K.goose,torso:K.sky,bib:1,pocket:1,leg:K.sky,foot:K.goose,hand:K.goose,tail:'pom',head:'rabbit',proj:'carrot',ek:'white',mouth:[90,72]},
 chicken:{fur:'#FFE07A',torso:'#FFE07A',belly:K.cream,leg:K.ui,foot:K.ui,hand:'#FFE07A',wing:1,tail:'feathers',head:'chicken',hatC:K.sky,proj:'egg',ek:'color'}
};
function eyesX(S,kind,e){
 const lc=kind==='mask'?K.cream:O;let o='';
 [[49.5,55.5,6.6,0],[72,54.5,7.4,1]].forEach(([x,y,s,i])=>{
  const st=`fill="none" stroke="${lc}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"`;
  if(e==='open'||e==='sad')o+=eyeSvg(S,x,y,s,kind);
  else if(e==='blink')o+=`<path d="M${f(x-s*.8)} ${f(y)}Q${f(x)} ${f(y+s*.7)} ${f(x+s*.8)} ${f(y)}" ${st}/>`;
  else if(e==='happy')o+=`<path d="M${f(x-s*.75)} ${f(y+s*.35)}Q${f(x)} ${f(y-s*.75)} ${f(x+s*.75)} ${f(y+s*.35)}" ${st}/>`;
  else if(e==='hurt'){const d=i?-1:1;o+=`<path d="M${f(x-d*s*.55)} ${f(y-s*.6)}L${f(x+d*s*.5)} ${f(y)}L${f(x-d*s*.55)} ${f(y+s*.6)}" ${st}/>`}
  else if(e==='dizzy'){const p=[];for(let k=0;k<=16;k++){const t=k/16,a=t*Math.PI*3.6+i,r=s*(.85-.7*t);p.push([x+Math.cos(a)*r,y+Math.sin(a)*r])}o+=`<path d="${curve(p)}" ${st}/>`}
  if(e==='sad'){const d=i?1:-1;o+=`<path d="M${f(x+d*s*.85)} ${f(y-s*.95)}L${f(x-d*s*.55)} ${f(y-s*1.45)}" ${st}/>`}
 });return o}
function mouthX(sk,m){const [x,y]=sk.mouth,R='#C9475A',st=`stroke="${O}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"`;
 switch(m){
  case 'open':return `<path d="M${x-5} ${y-2}Q${x} ${y+6} ${x+5} ${y-2.5}Z" fill="${R}" ${st}/>`;
  case 'grin':return `<path d="M${x-6.5} ${y-2.5}Q${x} ${y+9} ${x+6.5} ${y-3}Z" fill="${R}" ${st}/>`;
  case 'o':return `<path d="${E(x,y+1,2.6,3)}" fill="${R}" ${st}/>`;
  case 'frown':return `<path d="M${x-4} ${y+1.5}Q${x} ${y-2.2} ${x+4} ${y+1.2}" fill="none" ${st}/>`;
  case 'wavy':return `<path d="M${x-5} ${y}q1.7 -2 3.3 0t3.3 0t3.3 0" fill="none" ${st}/>`;
  default:return `<path d="M${x-4.5} ${y-1}Q${x} ${y+2.5} ${x+4.5} ${y-1.5}" fill="none" ${st}/>`;
 }}
function starD(cx,cy,R,r){const p=[];for(let i=0;i<10;i++){const a=-Math.PI/2+i*Math.PI/5,q=i%2?r:R;p.push([cx+Math.cos(a)*q,cy+Math.sin(a)*q])}return RP(p,.8)}
function spark(x,y){return RP([[x,y-5.5],[x+1.4,y-1.4],[x+5.5,y],[x+1.4,y+1.4],[x,y+5.5],[x-1.4,y+1.4],[x-5.5,y],[x-1.4,y-1.4]],.6)}
function coinIt(x,y,tf){return {tf,ds:[E(x,y,4.8)],fill:K.coin,line:2,off:1.3,hl:[x-1.6,y-1.8,1.5,1,-35],mark:[`<path d="${E(x,y,2.5)}" fill="none" stroke="${sh(K.coin)}" stroke-width="1.3"/>`]}}
function projItems(type,cx,cy,a=0,k=1,tf=''){
 const r=a*Math.PI/180,c=Math.cos(r),s=Math.sin(r),T=([x,y])=>[cx+k*(x*c-y*s),cy+k*(x*s+y*c)];
 const e=(x,y,rx,ry,d=0)=>{const q=T([x,y]);return ER(q[0],q[1],rx*k,ry*k,d+a)};
 const po=(p,rr)=>RP(p.map(T),rr*k),H=(x,y,rx,ry,d)=>[cx+k*x,cy+k*y,rx*k,ry*k,d];
 const it=x=>({tf,line:k<.8?1.8:2.75,off:Math.max(1,2*k),...x});
 switch(type){
  case 'apple':return [it({limb:curve([T([0,-7]),T([1.5,-12.5])]),w:2.6*k,fill:K.wood}),it({ds:[e(5,-11,4.2,2.1,-25)],fill:K.sprout,sh:false}),it({ds:[e(0,1.5,10.5,9.5)],fill:K.red,hl:H(-4.5,-3,3,1.8,-35)})];
  case 'bone':return [it({ds:[po([[-8,-2.8],[8,-2.8],[8,2.8],[-8,2.8]],1),e(-8.5,-3.4,3.8,3.8),e(-8.5,3.4,3.8,3.8),e(8.5,-3.4,3.8,3.8),e(8.5,3.4,3.8,3.8)],fill:K.cream,hl:H(-9.5,-5,1.6,1,-35)})];
  case 'acorn':return [it({limb:curve([T([0,-8]),T([1.2,-12.5])]),w:2.6*k,fill:K.wood}),it({ds:[e(0,3,7.2,8.4)],fill:'#C98B4A',hl:H(-2.8,0,2,1.4,-30)}),it({ds:[e(0,-4.5,9,5)],fill:K.wood,hl:H(-3.5,-6,2.6,1.2,-10)})];
  case 'carrot':return [it({ds:[e(-2.6,-10.5,2.1,4.6,-25),e(2.6,-10.5,2.1,4.6,25)],fill:K.sprout,sh:false}),it({ds:[po([[-6,-7.5],[6,-7.5],[0,12]],3)],fill:K.ui,hl:H(-2.5,-4,1.4,2.2,-15)})];
  case 'egg':return [it({ds:[e(0,0,8.2,10.6)],fill:K.cream,hl:H(-3,-5,2.4,1.6,-30)})];
 }}
function tailIt(sk,tf){const F=sk.fur;switch(sk.tail){
 case 'raccoon':{const tp=[[47,96],[34,93],[23,83],[18,68]],td=curve(tp),L=plen(tp),tw=14;return [{tf,limb:td,w:tw,fill:F,extra:`<path d="${td}" fill="none" stroke="${K.furD}" stroke-width="${tw}" stroke-dasharray="0 ${f(L*.3)} ${f(L*.13)} ${f(L*.13)} ${f(L*.13)} ${f(L*.13)} ${f(L)}"/><path d="${E(18,68,tw/2)}" fill="${K.furD}"/>`}]}
 case 'stub':return [{tf,ds:[ER(43,90,7.5,6.5,-30)],fill:F,mark:[`<path d="${E(38,86,4)}" fill="${K.cream}"/>`]}];
 case 'curl':return [{tf,limb:'M46 94C39 96 34 91 36.5 86.5C39 82.5 44.5 85 42.5 88.5',w:3.6,fill:'#E77A93'}];
 case 'pom':return [{tf,ds:[E(42,92,8,7.5)],fill:F,hl:[39,89,2.6,1.6,-30]}];
 case 'feathers':return [{tf,ds:[ER(37,86,5,11,-55),ER(39,80,5,12,-35),ER(44,77,4.5,11,-15)],fill:F}];
 }}
function headIt(S,sk,P,HT,HAT){
 const F=sk.fur,I=[],ear=P.ear||0,dr=P.droop||0,mo=P.mouth||'smile';
 const eyes={raw:`<g transform="${HT}">${eyesX(S,sk.ek,P.eyes||'open')}</g>`},mouth=sk.mouth?{raw:`<g transform="${HT}">${mouthX(sk,mo)}</g>`}:null;
 const nose=(x,y,rx,ry)=>({tf:HT,ds:[E(x,y,rx,ry)],fill:O,line:0,sh:false,mark:[`<path d="${E(x-1.6,y-1.4,1.6,1)}" fill="#fff"/>`]});
 switch(sk.head){
 case 'raccoon':{const TH=HAT+' rotate(-5 58 36)';
  I.push({tf:HT,ds:[E(60,54,32,25),RP([[34,58],[23,75],[45,71]],3),RP([[79,69],[91,83],[86,64]],3)],fill:F,r:25,mark:[`<path d="${ER(62,77,30,10,0)}" fill="${K.cream}"/>`,`<path d="${ER(49,55.5,11.5,9.5,14)}" fill="${K.furD}"/><path d="${ER(71,55,13.5,10.5,-12)}" fill="${K.furD}"/><path d="${RR(50,46,22,9,4)}" fill="${K.furD}"/>`]},eyes,
   {tf:HT,ds:[E(89,65,13,10)],fill:K.cream,r:9,hl:[84,59.5,4,2,-15]},nose(100,61,5,3.8),mouth,
   {tf:TH,ds:[ER(58,36,40,11.5,0)],fill:K.straw,r:11,hl:[36,33,8,2.6,-8]},
   {raw:`<g transform="${TH}"><path d="${E(39,32.5,6.5,2.6)}" fill="${sh(K.straw)}"/><path d="${E(79,31.5,6.5,2.6)}" fill="${sh(K.straw)}"/></g>`},
   {tf:TH+` rotate(${ear-dr} 38 32)`,ds:[RP([[31,33],[33,15],[46,31]],4.5)],fill:F,sh:false,mark:[`<path d="${RP([[35,31],[35.5,21],[42,30]],2.5)}" fill="${K.cream}"/>`]},
   {tf:TH+` rotate(${ear+dr} 79 31)`,ds:[RP([[72,31],[84,13],[88,31]],4.5)],fill:F,sh:false,mark:[`<path d="${RP([[76,30],[83.5,20],[85,30]],2.5)}" fill="${K.cream}"/>`]},
   {tf:TH,ds:['M42 38C41 22 49 13 58.5 13C68 13 75 22 75 37Q58.5 43 42 38Z'],fill:K.straw,r:13,hl:[51,20,4.5,2.6,-35],mark:[`<path d="M39 30Q58.5 36.5 78 30L78 38Q58.5 44.5 39 38Z" fill="${K.ui}"/>`]});break}
 case 'corgi':
  I.push({tf:HT,ds:[E(60,54,31,25),RP([[34,59],[24,74],[45,71]],3)],fill:F,r:25,mark:[`<path d="${ER(74,77,30,12,-6)}" fill="${K.cream}"/><path d="${ER(85,50,3.4,8,-25)}" fill="${K.cream}"/>`]},eyes,
   {tf:HT,ds:[E(90,66,13,10)],fill:K.cream,r:9,hl:[85,60.5,4,2,-15]},nose(101,61.5,5.2,4),mouth,
   {tf:HAT,ds:['M33 40C32 22 45 13 60 13C75 13 87 21 87 38Q60 45 33 40Z'],fill:sk.hatC,r:12,hl:[48,21,6,3,-25]},
   {tf:HAT,ds:[blob([[80,37],[100,35.5],[111,40],[101,45],[82,44]])],fill:sk.hatC,r:5},
   {tf:HAT,ds:[E(60,13.5,3.6,2.4)],fill:sk.hatC,sh:false},
   {tf:HAT+` rotate(${ear-dr} 40 30)`,ds:[RP([[34,33],[29,10],[49,25]],3.5)],fill:F,sh:false,mark:[`<path d="${RP([[36.5,29.5],[33,16.5],[44.5,26]],2)}" fill="${K.cream}"/>`]},
   {tf:HAT+` rotate(${ear+dr} 78 28)`,ds:[RP([[68,25],[84,8.5],[89,33]],3.5)],fill:F,sh:false,mark:[`<path d="${RP([[72,26],[83,15],[86,30]],2)}" fill="${K.cream}"/>`]});break;
 case 'pig':
  I.push({tf:HT,ds:[E(60,55,31,25)],fill:F,r:25,hl:[44,40,6,3,-30]},
   {tf:HAT+` rotate(${ear-dr} 42 32)`,ds:[RP([[35,38],[31,18],[51,29]],4)],fill:F,sh:false,mark:[`<path d="${RP([[37.5,34],[35,24],[46,30]],2)}" fill="#E77A93"/>`]},
   {tf:HAT+` rotate(${ear+dr} 76 30)`,ds:[RP([[67,31],[81,14],[86,37]],4)],fill:F,sh:false,mark:[`<path d="${RP([[71,31],[80,20.5],[83,34]],2)}" fill="#E77A93"/>`]},
   eyes,{tf:HT,ds:[E(94,62,8.5,9)],fill:'#F7A1B5',r:9,hl:[91,57,2.6,1.6,-20],mark:[`<path d="${ER(92,62.5,1.5,2.6,0)}" fill="#B9506A"/><path d="${ER(97.5,62,1.3,2.4,0)}" fill="#B9506A"/>`]},mouth);break;
 case 'rabbit':
  I.push({tf:HAT+` rotate(${ear-dr*2} 49 38)`,ds:[ER(48,27.5,6.5,13.5,-12)],fill:F,r:6,mark:[`<path d="${ER(48,29,3,9,-12)}" fill="${K.pink}"/>`]},
   {tf:HAT+` rotate(${ear-dr*1.6} 68 36)`,ds:[ER(70,26,7,14,14)],fill:F,r:6,mark:[`<path d="${ER(70,27.5,3.3,10,14)}" fill="${K.pink}"/>`]},
   {tf:HT,ds:[E(60,57,30,24)],fill:F,r:24,hl:[45,43,6,3,-30]},eyes,
   {tf:HT,ds:[E(88,67,10,8)],fill:K.cream,r:8},
   {tf:HT,ds:[ER(96.5,62.5,3.4,2.6,0)],fill:K.pink,line:1.6,sh:false},mouth,
   {tf:HT,ds:[RR(88.5,72.5,4.2,3.6,1)],fill:'#FFFFFF',line:1.2,sh:false});break;
 case 'chicken':{const op=['open','grin','o'].includes(mo);
  I.push({tf:HAT,ds:[RP([[31,56],[15,63],[22,71]],3),RP([[32,59],[22,77],[31,75]],3)],fill:sk.hatC,r:4},
   {tf:HT,ds:[E(60,54,30,25)],fill:F,r:25,hl:[44,40,6,3,-30]},eyes,
   {tf:HT,ds:[ER(88,74.5,3.4,5,10)],fill:K.red,r:4});
  if(op)I.push({tf:HT,ds:[RP([[85,60],[101,64.5],[85,69]],2)],fill:'#C9475A',sh:false},{tf:HT,ds:[RP([[85,56],[104,60.5],[86,63.5]],3)],fill:K.ui,r:4},{tf:HT,ds:[RP([[86,65.5],[99,71.5],[85,72]],3)],fill:K.ui,r:4});
  else I.push({tf:HT,ds:[RP([[85,57.5],[104,63.5],[85,70]],3.5)],fill:K.ui,r:6,hl:[90,60.5,3,1.3,15]});
  I.push({tf:HAT,ds:['M31 50C29 28 44 18 61 18C78 18 90 29 90 44Q58 38 31 50Z'],fill:sk.hatC,r:12,hl:[50,26,6,3,-25]},{tf:HAT,ds:[E(31,54,5.5,5)],fill:sk.hatC,r:5});break}
 }
 return I.filter(Boolean);
}
function hero(S,sk,P={}){
 const D=Doc(128,128,S,`translate(0 ${-(P.lift||0)}) rotate(${P.lean||0} 64 116)`);
 const I=[],F=sk.fur,by=P.by||0,hb=by+(P.hy||0);
 const [fdx,fdy]=P.footF||[0,0],[bdx,bdy]=P.footB||[0,0],aF=P.armF||0,aB=P.armB||0;
 const TB=`translate(0 ${by})`,HT=`translate(0 ${hb}) rotate(${P.ht||0} 62 80)`,HAT=HT+` translate(0 ${P.hat||0})`;
 const rot=(o,v,a)=>{const r=a*Math.PI/180,c=Math.cos(r),s=Math.sin(r);return [o[0]+v[0]*c-v[1]*s,o[1]+v[0]*s+v[1]*c]};
 const lw=sk.wing?5:9;
 I.push(...tailIt(sk,TB+` rotate(${P.tail||0} 47 96)`));
 I.push({limb:curve([[56,100+by],[54+bdx*.7,107+bdy]]),w:lw,fill:sh(sk.leg)},{ds:[E(50.5+bdx,111.5+bdy,7,4.3)],fill:sh(sk.foot),sh:false});
 const rc=P.reach||1,sB=[53,87],eB=rot(sB,[-6*rc,7*rc],aB),pB=rot(sB,[-7*rc,13*rc],aB),qB=rot(sB,[-7.2*rc,13.5*rc],aB);
 I.push({tf:TB,limb:curve([sB,eB,pB]),w:sk.wing?9:7.5,fill:sh(F)},{tf:TB,ds:[E(qB[0],qB[1],4.8,4.5)],fill:sh(sk.hand),sh:false});
 if(sk.sleeve)I.push({tf:TB,ds:[E(54,87,6,5.5)],fill:sh(sk.sleeve),sh:false});
 I.push({tf:TB,ds:[E(63,93,19.5,16)],fill:sk.torso,r:16,hl:[50,88,4,2.4,-30],mark:sk.belly?[`<path d="${E(70,99,11.5,10)}" fill="${sk.belly}"/>`]:undefined});
 I.push({limb:curve([[69,100+by],[71+fdx*.7,107+fdy]]),w:lw,fill:sk.leg},{ds:[E(74.5+fdx,111.5+fdy,7.5,4.5)],fill:sk.foot,sh:false});
 if(sk.bib){I.push({tf:TB,ds:[RR(62,81,17,14,5)],fill:sk.torso,line:2.5,sh:false});
  if(sk.pocket)I.push({tf:TB,ds:[ER(68.5,82,1.8,3.6,-20),ER(72,81.5,1.8,3.6,20)],fill:K.sprout,line:1.3,sh:false},{tf:TB,ds:[RP([[65.5,87],[74.5,86.5],[70,96]],1.5)],fill:K.ui,line:1.5,sh:false},{tf:TB,ds:[RR(63.5,89.5,12,6.5,2)],fill:sk.torso,line:1.5,sh:false});
  else I.push({tf:TB,ds:[E(65.5,84.5,2.1)],fill:sk.btn,line:1.2,sh:false},{tf:TB,ds:[E(75.5,84,2.1)],fill:sk.btn,line:1.2,sh:false});}
 const sF=[73,86],eF=rot(sF,[6*rc,7*rc],aF),pF=rot(sF,[8.5*rc,13.5*rc],aF),qF=rot(sF,[9*rc,14.5*rc],aF);
 const arm=[{tf:TB,limb:curve([sF,eF,pF]),w:sk.wing?9:8,fill:F},{tf:TB,ds:[E(qF[0],qF[1],5,4.7)],fill:sk.hand,sh:false}];
 if(sk.sleeve)arm.push({tf:TB,ds:[E(72,86,6.5,6)],fill:sk.sleeve,r:6});
 for(const pr of P.props||[]){const hand=pr.at==='hand',[px,py]=hand?qF:pr.at,ptf=hand?TB:'';
  if(pr.ladle){const [lx,ly]=[px+13,py-7];arm.push({tf:ptf,limb:`M${f(px-2)} ${f(py+1)}L${f(lx)} ${f(ly)}`,w:3.2,fill:K.wood},{tf:ptf,ds:[E(lx+4,ly+1,6,4.2)],fill:K.stone,line:2,sh:false,mark:[`<path d="${E(lx+4,ly-.6,4.6,1.8)}" fill="#FFB23F"/>`]},...(pr.drip!=null?[{tf:ptf,ds:[`M${f(lx+6)} ${f(ly+5+pr.drip)}Q${f(lx+8.4)} ${f(ly+9+pr.drip)} ${f(lx+6)} ${f(ly+11+pr.drip)}Q${f(lx+3.6)} ${f(ly+9+pr.drip)} ${f(lx+6)} ${f(ly+5+pr.drip)}Z`],fill:'#FFB23F',line:1.5,sh:false}]:[]))}
  else if(pr.coin)arm.push(coinIt(px,py,ptf));else if(pr.spark)arm.push({tf:ptf,ds:[spark(px,py)],fill:'#FFF0B0',line:1.6,sh:false});else arm.push(...projItems(sk.proj,px,py,pr.a||0,.55,ptf));}
 if(!P.armFront)I.push(...arm);
 I.push(...headIt(S,sk,P,HT,HAT));
 if(P.veil!=null)I.push({raw:`<g transform="${HAT}"><path d="M37 ${40+P.veil}Q34 62 42 76L84 76Q92 62 88 ${40+P.veil}Z" fill="#FFFFFF" fill-opacity=".38" stroke="${O}" stroke-width="2.2" stroke-linejoin="round"/><path d="M44 44V75M53 42V76M62 42V76M71 42V76M80 44V75M38 54H87M38 65H88" stroke="#FFFFFF" stroke-opacity=".55" stroke-width="1.2"/></g>`});
 if(P.armFront)I.push(...arm);
 if(P.bees)P.bees.forEach(([x,y,w])=>I.push(...beeSmall(x,y,w)));
 if(P.stars!=null)for(let k=0;k<3;k++){const a=P.stars*Math.PI/2+k*Math.PI*2/3;I.push({tf:HT,ds:[starD(60+Math.cos(a)*27,11+Math.sin(a)*6,5.2,2.4)],fill:K.coin,line:2,sh:false})}
 if(P.tear!=null){const x=71,y=64+P.tear;I.push({tf:HT,ds:[`M${x} ${f(y-4)}Q${x+3.6} ${f(y+1.2)} ${x} ${f(y+3.6)}Q${x-3.6} ${f(y+1.2)} ${x} ${f(y-4)}Z`],fill:K.sky,line:1.8,sh:false})}
 render(D,I);return D.svg();
}
const RUN2=[
 {lean:8,by:2,footF:[10,0],footB:[-9,-5],armF:32,armB:-32,tail:4,ear:-4},
 {lean:8,by:3.5,hy:1,footF:[2,0],footB:[-4,-8],armF:12,armB:-12,tail:10,ear:4,hat:-1.5},
 {lean:8,by:-4,hy:-1,footF:[-8,-4],footB:[7,-9],armF:-30,armB:30,tail:-8,ear:-10,hat:2},
 {lean:8,by:2,footF:[-9,-5],footB:[10,0],armF:-32,armB:32,tail:4,ear:-4},
 {lean:8,by:3.5,hy:1,footF:[-4,-8],footB:[2,0],armF:-12,armB:12,tail:10,ear:4,hat:-1.5},
 {lean:8,by:-4,hy:-1,footF:[7,-9],footB:[-8,-4],armF:30,armB:-30,tail:-8,ear:-10,hat:2}].map(p=>({...p,mouth:'open'}));
const JOY=(o)=>({eyes:'happy',mouth:'grin',...o});
const ANIMS=[
 ['idle',6,1,[{},{by:1,hy:.5,hat:.5,armF:3,armB:-3,tail:3},{by:1.5,hy:1,hat:1,armF:5,armB:-5,tail:5,eyes:'blink'},{by:.5,hy:.5,hat:.5,armF:2,armB:-2,tail:2}]],
 ['run',12,1,RUN2],
 ['throw',12,0,[
  {lean:-10,by:1,armF:110,armB:-25,footF:[5,0],footB:[-5,0],props:[{at:'hand',a:0}]},
  {lean:10,by:2,armF:-75,armB:35,footF:[7,0],footB:[-6,-3],mouth:'open',armFront:1,props:[{at:[104,74],a:90}]},
  {lean:6,by:1.5,armF:-30,armB:20,footF:[7,0],footB:[-6,0],armFront:1},
  {lean:1,by:.5,armF:5,armB:-5,footF:[2,0],footB:[-2,0]}]],
 ['build',10,1,[
  {lean:4,armF:-70,armB:-10,armFront:1,props:[{at:'hand',coin:1}]},
  {lean:6,by:1,armF:-20,armB:-5,armFront:1,eyes:'happy',props:[{at:[100,70],coin:1}]},
  {lean:5,by:.5,props:[{at:[108,94],coin:1}]},
  {lean:4,armF:-40,armB:-8,armFront:1,props:[{at:[110,111],spark:1}]}]],
 ['hit',12,0,[
  {lean:-10,by:1,hy:-1,armF:130,armB:60,footF:[-2,0],footB:[-4,0],eyes:'hurt',mouth:'o',hat:-3,ear:-12,tail:-10},
  {lean:-5,by:.5,armF:40,armB:20,footF:[-1,0],footB:[-2,0],eyes:'blink',mouth:'frown',hat:-1,ear:-5,tail:-4}]],
 ['stun',8,1,[0,1,2,3].map(i=>({lean:[-3,0,3,0][i],hy:i%2,ht:[-7,0,7,0][i],armF:[12,6,0,6][i],armB:[-8,-4,0,-4][i],eyes:'dizzy',mouth:'wavy',stars:i}))],
 ['joy',10,1,[
  JOY({by:5,hy:1,armF:25,armB:-20,tail:8,ear:4}),
  JOY({lift:4,by:-1,armF:-80,armB:100,armFront:1,footF:[2,-2],footB:[-2,-2],tail:-10,ear:-8,hat:-.5}),
  JOY({lift:6,by:-1,armF:-95,armB:115,armFront:1,footF:[3,-5],footB:[-3,-5],tail:-14,ear:-12,hat:-1}),
  JOY({lift:4,armF:-75,armB:95,armFront:1,footF:[1,-2],footB:[-1,-2],tail:-6,ear:-6,hat:-.5}),
  JOY({by:4,hy:1.5,armF:10,armB:-10,tail:10,ear:6,hat:1}),
  JOY({by:1,armF:-30,armB:30,armFront:1,tail:2})]],
 ['sad',6,1,[
  {by:2,hy:3,ht:6,droop:22,armF:-4,armB:4,tail:-14,eyes:'sad',mouth:'frown',hat:1},
  {by:2.5,hy:3.5,ht:6.5,droop:24,armF:-4,armB:4,tail:-15,eyes:'sad',mouth:'frown',hat:1,tear:0},
  {by:3,hy:4,ht:7,droop:26,armF:-5,armB:5,tail:-16,eyes:'sad',mouth:'frown',hat:1.2,tear:4},
  {by:2.5,hy:3.5,ht:6.5,droop:24,armF:-4,armB:4,tail:-15,eyes:'blink',mouth:'frown',hat:1,tear:8}]]
];
const ANIMS2=[
 ['shake',12,1,[
  {lean:16,by:1,reach:1.7,armF:-72,armB:-108,armFront:1,footF:[9,0],footB:[-9,0],hat:-4,mouth:'open',tail:6,ear:-6},
  {lean:9,by:2.5,hy:1,reach:1.6,armF:-64,armB:-100,armFront:1,footF:[8,0],footB:[-8,0],hat:1,eyes:'hurt',mouth:'wavy',tail:-2,ear:3},
  {lean:2,by:1,reach:1.8,armF:-80,armB:-114,armFront:1,footF:[9,0],footB:[-9,0],hat:-6,mouth:'open',tail:-8,ear:-8},
  {lean:10,by:2.5,hy:1,reach:1.6,armF:-66,armB:-102,armFront:1,footF:[8,0],footB:[-8,0],hat:1,eyes:'hurt',mouth:'wavy',tail:2,ear:4}]],
 ['pick',10,1,[
  {lean:14,by:6,hy:1,reach:1.5,armF:-18,armB:-50,armFront:1,footF:[4,0],footB:[-8,0],tail:4},
  {lean:8,by:6,hy:1,reach:1.5,armF:-28,armB:-60,armFront:1,footF:[8,0],footB:[-8,0],eyes:'blink',tail:0},
  {lean:-12,by:4,reach:1.5,armF:-52,armB:-84,armFront:1,footF:[11,0],footB:[-9,0],eyes:'hurt',mouth:'o',hat:-2,tail:-10,ear:-6},
  {lean:-8,by:5,reach:1.5,armF:-44,armB:-76,armFront:1,footF:[10,0],footB:[-9,0],eyes:'hurt',mouth:'wavy',hat:-1,tail:-6,ear:-3}]],
 ['honey',10,1,[
  {lean:6,by:1,veil:0,reach:1.3,armF:-40,armB:-20,armFront:1,props:[{at:'hand',ladle:1}],bees:[[104,34,0],[24,52,1]]},
  {lean:8,by:2,veil:0,reach:1.3,armF:-20,armB:-24,armFront:1,props:[{at:'hand',ladle:1}],bees:[[108,40,1],[20,46,0]]},
  {lean:2,by:1,veil:0,reach:1.3,armF:-78,armB:-18,armFront:1,eyes:'happy',props:[{at:'hand',ladle:1,drip:0}],bees:[[100,30,0],[26,40,1]]},
  {lean:3,by:1,veil:0,reach:1.3,armF:-66,armB:-18,armFront:1,eyes:'happy',props:[{at:'hand',ladle:1,drip:5}],bees:[[96,38,1],[30,48,0]]}]]
];
function heroSheets2(){const out={},S=STY.a,p='assets/o/';
 for(const [id,sk] of Object.entries(SKINS))for(const [an,fps,loop,Ps] of ANIMS2)out[p+`hero_${id}_${an}_4f.svg`]=sheet(Ps.map(P=>hero(S,sk,P)),128,128);
 return out}
function splat(S,i){const D=Doc(32,32,S),C='#FFF4DC',ring=(n,R,r)=>{const p=[];for(let k=0;k<n;k++){const a=k/n*Math.PI*2,q=k%2?r:R;p.push([16+Math.cos(a)*q,16+Math.sin(a)*q])}return p},dots=(n,R,rr,o)=>Array.from({length:n},(_,k)=>{const a=k/n*Math.PI*2+o;return E(16+Math.cos(a)*R,16+Math.sin(a)*R,rr)});
 render(D,i===0?[{ds:[RP(ring(12,9,4.5),1.2)],fill:C,sh:false}]:i===1?[{ds:[blob(ring(16,11,7))],fill:C,sh:false},{ds:dots(5,12,1.9,.4),fill:C,line:1.6,sh:false}]:[{ds:dots(6,12,1.8,.9).concat(dots(3,7,1.2,.2)),fill:C,line:1.4,sh:false}]);return D.svg()}
function aura(S,fi){const D=Doc(160,160,S),cx=80,cy=132,rx=58,ry=15,N=14,T=[];
 for(let i=0;i<N;i++){const th=i/N*Math.PI*2+.11,sd=Math.abs(Math.cos(th));T.push({x:cx+Math.cos(th)*rx,y:cy+Math.sin(th)*ry,h:(14+34*sd**1.5)*(.78+.26*Math.sin(fi*Math.PI/2+i*2.1)),w:5.5+3*sd,b:3.5*Math.sin(fi*Math.PI/2+i*1.3),back:Math.sin(th)<0})}
 const tp=(t,k)=>`M${f(t.x-t.w*k)} ${f(t.y)}Q${f(t.x-t.w*k)} ${f(t.y-t.h*k*.55)} ${f(t.x+t.b)} ${f(t.y-t.h*k)}Q${f(t.x+t.w*k)} ${f(t.y-t.h*k*.55)} ${f(t.x+t.w*k)} ${f(t.y)}Z`;
 const B=T.filter(t=>t.back),Fr=T.filter(t=>!t.back),sp=[0,1,2,3].map(k=>E(cx+Math.cos(k*1.7+fi*.4)*44,cy-20-((fi*9+k*23)%60),2.2));
 D.add(`<path d="${E(cx,cy,rx+8,ry+6)}" fill="${K.ui}" opacity=".35"/>`);
 render(D,[{ds:B.map(t=>tp(t,1)),fill:K.ui,sh:false,line:2.5},{ds:B.map(t=>tp(t,.55)),fill:K.coin,line:0,sh:false},{ds:Fr.map(t=>tp(t,1)),fill:K.ui,sh:false,line:2.5},{ds:Fr.map(t=>tp(t,.55)),fill:K.coin,line:0,sh:false},{ds:sp,fill:K.coin,line:1.5,sh:false}]);
 return D.svg()}
function heroSheets(){
 const out={},S=STY.a,s=small(S),p='assets/b/';
 for(const [id,sk] of Object.entries(SKINS)){
  for(const [an,fps,loop,Ps] of ANIMS){const fr=Ps.map(P=>hero(S,sk,P));out[p+`hero_${id}_${an}_${fr.length}f.svg`]=sheet(fr,128,128);
   if(id==='raccoon'&&an==='run'){fr.forEach((v,i)=>out[`assets/1a/anim/hero_raccoon_run_${i+1}.svg`]=v);out['assets/1a/anim/hero_raccoon_run_6f.svg']=sheet(fr,128,128)}}
  const inner=hero(S,sk,{}).replace(/^<svg[^>]*>/,'').replace(/<\/svg>$/,'');
  const por=`<svg xmlns="http://www.w3.org/2000/svg" width="256" height="256" viewBox="4 -1 114 114">${inner}</svg>`;
  out[p+`ui_portrait_${id}.svg`]=por;
  out[p+`ui_portrait_${id}_locked.svg`]=por.replace(/(fill|stroke)="#[0-9A-Fa-f]{3,6}"/g,'$1="#3F3D55"');
  out[p+`ui_avatar_${id}.svg`]=`<svg xmlns="http://www.w3.org/2000/svg" width="96" height="96" viewBox="0 0 96 96"><defs><clipPath id="av"><circle cx="48" cy="48" r="36"/></clipPath></defs><circle cx="48" cy="48" r="45.5" fill="${O}"/><circle cx="48" cy="48" r="41.5" fill="${K.ui}"/><circle cx="48" cy="48" r="36" fill="${K.panel}"/><g clip-path="url(#av)"><svg x="4" y="6" width="88" height="88" viewBox="24 10 80 80">${inner}</svg></g><circle cx="48" cy="48" r="36" fill="none" stroke="${O}" stroke-width="3"/></svg>`;
 }
 const ANG={apple:[0,90,180,270],bone:[30,75,120,165],acorn:[0,90,180,270],carrot:[0,90,180,270],egg:[20,65,110,155]};
 for(const [t,angs] of Object.entries(ANG))out[p+`proj_${t}_spin_4f.svg`]=sheet(angs.map(a=>{const D=Doc(32,32,s);render(D,projItems(t,16,16.5,a,1));return D.svg()}),32,32);
 out[p+'proj_splat_3f.svg']=sheet([0,1,2].map(i=>splat(s,i)),32,32);
 out[p+'fx_rage_aura_4f.svg']=sheet([0,1,2,3].map(i=>aura(S,i)),160,160);
 return out;
}
