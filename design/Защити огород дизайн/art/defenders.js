// Партия D: защитники ×4 × 3 уровня (build/idle/attack), апгрейды, забор ×3, портреты, снаряды. После gen/anim/heroes/pests.
const FROG='#8BD450',BEAV='#7B4A32';
Object.assign(SH,{'#7B4A32':'#5E3724','#5E3724':'#46291B'});Object.assign(HL,{'#7B4A32':'#9C6A4E'});
const LVM=[{a:K.woodL,b:K.wood,t:K.wood},{a:K.red,b:'#B8433A',t:K.panel},{a:K.stone,b:'#8A909C',t:K.coin}];
function matMark(lv,x,y,w,h,dir){const st=`stroke="${sh(LVM[lv].a)}" stroke-width="2.4"`;let s='';
 if(lv===2){const rows=Math.max(2,Math.round(h/13)),rh=h/rows,cols=Math.max(2,Math.round(w/22));for(let r=0;r<rows;r++){const yy=y+r*rh;if(r)s+=`<path d="M${f(x)} ${f(yy)}H${f(x+w)}" ${st}/>`;for(let k=1;k<=cols;k++){const xx=x+(k-(r%2)*.5)*w/cols;if(xx>x+3&&xx<x+w-3)s+=`<path d="M${f(xx)} ${f(yy)}V${f(yy+rh)}" ${st}/>`}}}
 else{const n=Math.max(2,Math.round((dir==='h'?h:w)/12));for(let i=1;i<n;i++)s+=dir==='h'?`<path d="M${f(x)} ${f(y+h*i/n)}H${f(x+w)}" ${st}/>`:`<path d="M${f(x+w*i/n)} ${f(y)}V${f(y+h)}" ${st}/>`}
 return s}
function flagIt(x,y,h,ph=0){const t=y-h,w=[0,2,-1,1][ph%4];return [{limb:`M${x} ${y}V${t}`,w:3.6,fill:K.wood},{ds:[`M${x+1} ${t+1}Q${x+11} ${t+3+w} ${x+23} ${t+7}Q${x+11} ${t+11-w} ${x+1} ${t+14}Z`],fill:K.ui,r:4},{ds:[E(x,t-1,3)],fill:K.coin,sh:false}]}
const sparkIt=L=>({ds:L.map(([x,y,s])=>spk(x,y,s)),fill:'#FFF0B0',line:2,sh:false});
function flashSvg(S,k=1,cx=80,cy=92){const D=Doc(160,160,S),p=[];for(let i=0;i<16;i++){const a=i/16*Math.PI*2,q=(i%2?26:52)*k;p.push([cx+Math.cos(a)*q,cy+Math.sin(a)*q])}
 D.add('<g opacity=".9">');render(D,[{ds:[RP(p,3)],fill:'#FFF0B0',line:3,sh:false},{ds:[E(cx,cy,20*k)],fill:'#FFFFFF',line:0,sh:false}]);D.add('</g>');return D.svg()}
function dEyes(S,L,e,kind='color'){if(e==='blink')return L.map(([x,y,s])=>`<path d="M${f(x-s*.8)} ${f(y)}Q${f(x)} ${f(y+s*.7)} ${f(x+s*.8)} ${f(y)}" fill="none" stroke="${O}" stroke-width="${f(Math.max(1.6,s*.36))}" stroke-linecap="round"/>`).join('');if(kind==='white'&&(!e||e==='open'))return L.map(([x,y,s])=>eyeSvg(S,x,y,s,'white')).join('');return pEyes(S,L,e)}
const DT=P=>{const sc=P.sc||1;return `translate(80 146) scale(${sc*(P.sx||1)} ${sc*(P.sy||1)}) translate(-80 -146)`};
function scaffold(S,x0,x1,top,base=146,dx=0){const D=Doc(160,160,S,`translate(${dx} 0)`);render(D,[{limb:`M${x0} ${base}V${top}`,w:7,fill:K.woodL},{limb:`M${x1} ${base}V${top}`,w:7,fill:K.woodL},{limb:`M${x0} ${base-8}L${x1} ${top+10}`,w:5,fill:K.wood},{limb:`M${x0-5} ${top+5}H${x1+5}`,w:7,fill:K.woodL},{limb:`M${x0-5} ${f((base+top)/2)}H${x1+5}`,w:6,fill:K.woodL}]);return D.svg()}

// ---------- Гусь-стрелок на вышке ----------
function gooseBird(S,lv,P){
 const G=`translate(0 ${(P.gb||0)-(P.lift||0)}) translate(-10 -16) scale(1.12)`,H=G+` rotate(${P.ht||0} 92 60)`,T=H+` rotate(${P.tr??8} 112 33)`,I=[];
 I.push({tf:G,ds:[E(76,66,26,16),RP([[56,60],[40,47],[60,54]],3.5)],fill:K.goose,r:16,hl:[62,57,6,3,-20]});
 I.push({tf:G,ds:[P.cheer?ER(64,50,17,8.5,-40):ER(71,67,17,9.5,6)],fill:K.goose,r:9,line:2.5});
 I.push({tf:H,limb:curve([[91,60],[97,48],[100,37]]),w:12,fill:K.goose});
 I.push({tf:G,ds:[blob([[87,50],[96,46],[105,47],[106,54],[97,57],[88,58]])],fill:K.sky,r:5},{tf:G,ds:[RP([[91,55],[100,55],[95,66]],3)],fill:K.sky,r:4});
 I.push({tf:T,ds:[RR(112,29,32,8,4)],fill:K.bamboo,r:4,mark:[`<path d="${RR(135,27,3.5,12,0)}" fill="${lv===2?K.coin:K.wood}"/>`]});
 if(P.muzzle)I.push({tf:T,ds:[E(149,33,5),E(153,28.5,3.4),E(153,37.5,3.4)],fill:'#FFF4DC',line:2,sh:false});
 I.push({tf:H,ds:[E(101,31.5,11.5,11)],fill:K.goose,r:11,hl:[96,25,3.5,2,-30]});
 if(P.puff)I.push({tf:H,ds:[E(108,37,6,5.5)],fill:K.goose,r:5});
 I.push({tf:H,ds:[RP([[108.5,27],[124,32.5],[108.5,38.5]],4)],fill:K.ui,r:5});
 I.push({raw:`<g transform="${H}">${dEyes(S,[[103.5,29,3.6]],P.eyes,'white')}</g>`});
 return I}
function goose(S,lv,P={}){
 const D=Doc(160,160,S,'translate(-5 0) '+DT(P)),I=[],M=LVM[lv];
 if(lv===2)I.push(...flagIt(30,70,58,P.ph||0));
 if(lv<2){I.push({ds:[RR(50,94,9,44,3.5),RR(101,94,9,44,3.5)],fill:sh(M.a),sh:false});
  I.push({limb:curve([[42,108],[118,140]]),w:5,fill:M.b},{limb:curve([[118,108],[42,140]]),w:5,fill:M.b});
  I.push({ds:[RR(33,98,12,50,4),RR(115,98,12,50,4)],fill:lv?M.a:M.b,r:6});
  I.push({ds:[RR(24,70,112,30,8)],fill:M.a,sh:false,mark:[matMark(lv,24,70,112,30,'v')]});}
 else{I.push({ds:[RR(32,84,96,64,6)],fill:K.stone,r:14,mark:[matMark(2,32,84,96,64)]},{ds:[starD(80,120,10,4.6)],fill:K.coin,line:2.5,sh:false},{ds:[RR(22,66,116,28,7)],fill:K.stone,sh:false,mark:[matMark(2,22,66,116,28)]});}
 if(!P.noAnimal)I.push(...gooseBird(S,lv,P));
 if(lv<2)I.push({ds:[36,77,118].map(x=>RR(x,80,6,14,2)),fill:lv?M.t:M.b,sh:false},{ds:[RR(22,76,116,8,4)],fill:lv?M.t:M.b,hl:[44,78,14,1.2,0]},{ds:[RR(24,92,112,12,4)],fill:sh(lv?M.a:M.b),sh:false});
 else I.push({ds:[22,50,78,106,126].map(x=>RR(x,64,12,10,2.5)),fill:K.stone,r:4},{ds:[RR(20,72,120,14,4)],fill:K.stone,r:5,mark:[matMark(2,20,72,120,14)]},{ds:[RR(20,70,120,4.5,2)],fill:K.coin,sh:false});
 if(P.spark)I.push(sparkIt(P.spark));
 render(D,I);return D.svg()}

// ---------- Поливалка: лягушка ----------
function frogParts(S,P,part){const I=[],T=`translate(0 ${(P.by||0)-(P.lift||0)})`;
 if(part==='back'){
  I.push({tf:T,ds:[E(72,82,20,14)],fill:FROG,r:12,mark:[`<path d="${E(74,86,12,9)}" fill="${K.cream}"/>`]});
  if(P.cheer)I.push({tf:T,limb:'M58 76L46 50',w:8,fill:FROG},{tf:T,limb:'M88 76L100 48',w:8,fill:FROG},{tf:T,ds:[E(45,48,6),E(101,46,6)],fill:FROG,r:4});
  I.push({tf:T,ds:[E(72,62,24,16)],fill:FROG,r:16,hl:[58,54,5,2.5,-20]});
  I.push({tf:T,ds:[E(60,48,8.5,8),E(84,47,9,8.5)],fill:FROG,r:6});
  I.push({raw:`<g transform="${T}">${dEyes(S,[[60.5,48,5.4],[84.5,47,5.8]],P.eyes)}<path d="${E(56,64,4.2,2.3)}" fill="${K.pink}"/><path d="${E(89,63,4.2,2.3)}" fill="${K.pink}"/>${P.open?`<path d="M60 65Q73 80 87 64Z" fill="#C9475A" stroke="${O}" stroke-width="2.4" stroke-linejoin="round"/>`:`<path d="M60 66Q73 74 87 65" fill="none" stroke="${O}" stroke-width="2.4" stroke-linecap="round"/>`}</g>`});
 } else if(!P.cheer)I.push({tf:T,ds:[E(53,88,7,4.5),E(95,88,7,4.5)],fill:FROG,r:4});
 return I}
function sprinkler(th,spray,drip,lv){const c=lv===2?K.coin:K.stone,hx=116,hy=50,I=[],a=th*Math.PI/180,tip=s=>[hx+Math.cos(a)*20*s,hy+Math.sin(a)*7*s],t1=tip(1),t2=tip(-1);
 I.push({limb:`M${f(t2[0])} ${f(t2[1])}L${f(t1[0])} ${f(t1[1])}`,w:4,fill:c});
 I.push({ds:[E(hx,hy,5.5,4),E(t1[0],t1[1],3,2.4),E(t2[0],t2[1],3,2.4)],fill:c,line:2.2,sh:false});
 const dr=[];
 if(spray)[[t1,1],[t2,-1]].forEach(([t,s])=>{const dx=Math.cos(a)*s,dy=Math.sin(a)*.35*s;[7,14,21].forEach((k,j)=>dr.push([t[0]+dx*k,t[1]+dy*k+[1,3,7][j],[3.2,2.8,2.3][j]]))});
 if(drip!=null)dr.push([t1[0],t1[1]+6+drip*4,2.6]);
 if(dr.length)I.push({ds:dr.map(([x,y,r])=>`M${f(x)} ${f(y-r*1.4)}Q${f(x+r)} ${f(y+r*.2)} ${f(x)} ${f(y+r)}Q${f(x-r)} ${f(y+r*.2)} ${f(x)} ${f(y-r*1.4)}Z`),fill:K.sky,line:1.8,sh:false});
 return I}
function frog(S,lv,P={}){
 const D=Doc(160,160,S,DT(P)),I=[],M=LVM[lv];
 if(lv===2)I.push(...flagIt(44,88,64,P.ph||0));
 I.push({limb:'M100 124H116V52',w:6,fill:lv===2?K.coin:K.stone});
 I.push({ds:[E(74,86,30,8)],fill:lv===2?'#8A909C':M.b,sh:false},{ds:[E(74,87,25,5.5)],fill:K.sky,line:2,sh:false});
 if(!P.noAnimal)I.push(...frogParts(S,P,'back'));
 I.push({ds:[RP([[44,86],[104,86],[110,116],[104,146],[44,146],[38,116]],10)],fill:M.a,r:14,mark:[matMark(lv,38,86,72,60,'v'),lv<2?`<path d="M40 102H108M40 132H108" stroke="${lv?M.t:K.wood}" stroke-width="6"/>`:`<path d="M38 97H110" stroke="${K.coin}" stroke-width="5"/>`]});
 I.push({limb:'M45 88Q74 99 103 88',w:6,fill:lv===2?K.coin:M.b});
 if(!P.noAnimal)I.push(...frogParts(S,P,'front'));
 I.push(...sprinkler(P.th||0,P.spray,P.drip,lv));
 if(P.spark)I.push(sparkIt(P.spark));
 render(D,I);return D.svg()}

// ---------- Помидорная пушка: бобёр ----------
function tomatoIt(x,y,a=0,k=1,tf=''){const r=a*Math.PI/180,st=[];for(let i=0;i<10;i++){const q=i%2?1.7:5,an=-Math.PI/2+i*Math.PI/5,u=Math.cos(an)*q,v=-6.5+Math.sin(an)*q;st.push([x+k*(u*Math.cos(r)-v*Math.sin(r)),y+k*(u*Math.sin(r)+v*Math.cos(r))])}
 return [{tf,ds:[E(x,y,9*k,8.2*k)],fill:K.red,r:8*k,hl:[x-3.2*k,y-3*k,2.6*k,1.6*k,-30]},{tf,ds:[RP(st,.6)],fill:K.sprout,line:Math.max(1.4,1.8*k),sh:false}]}
function beaver(S,P,part){const I=[],by=P.by||0,li=P.lift||0,T=`translate(0 ${by-li})`,HT=`translate(0 ${by-li+(P.hy||0)}) rotate(${P.ht||0} 44 106)`,F=`translate(0 ${-li})`;
 if(part==='body'){
  I.push({tf:T,ds:[ER(20,137,13,6.5,-18)],fill:sh(BEAV),r:5,mark:[`<path d="M12 134L28 140M14 139L26 134" stroke="#46291B" stroke-width="1.6"/>`]});
  I.push({tf:F,ds:[E(30,143,7,4)],fill:'#46291B',sh:false});
  const sB=[32,108],hB=rotP(sB,[-2,14],P.armB||0);
  I.push({tf:T,limb:curve([sB,hB]),w:7.5,fill:sh(BEAV)},{tf:T,ds:[E(hB[0],hB[1],4.8,4.4)],fill:'#46291B',sh:false});
  I.push({tf:T,ds:[E(40,120,17,19)],fill:BEAV,r:17,hl:[30,110,4,6,-20],mark:[`<path d="${E(46,125,10,13)}" fill="${K.cream}"/>`]});
  I.push({tf:F,ds:[E(48,144.5,8,4.5)],fill:sh(BEAV),sh:false});
  I.push({tf:HT,ds:[E(42,93,17,15.5)],fill:BEAV,r:15,hl:[33,86,4,2.2,-30]});
  I.push({tf:HT,ds:[E(55,99,9,6.5)],fill:K.cream,r:6});
  I.push({tf:HT,ds:[E(62,95,3.8,3)],fill:O,line:0,sh:false});
  I.push({tf:HT,ds:[RR(52.5,103,7,6.5,1.5)],fill:'#FFFFFF',line:1.6,sh:false,mark:[`<path d="M56 103V109.5" stroke="${O}" stroke-width="1"/>`]});
  I.push({raw:`<g transform="${HT}">${dEyes(S,[[40,91,4.6],[50,90.5,5]],P.eyes)}<path d="M50 102Q55 105 60 101" fill="none" stroke="${O}" stroke-width="2" stroke-linecap="round"/></g>`});
  I.push({tf:HT,ds:['M26 85C25 71 33 64 43 64C53 64 60 71 60 83Q43 88 26 85Z'],fill:K.straw,r:10,hl:[36,70,4,2,-25]},{tf:HT,ds:[RR(40.5,64.5,5,14,2.5)],fill:sh(K.straw),sh:false},{tf:HT,ds:[RR(21,81,44,5.5,2.7)],fill:K.straw,r:3});
 } else {const sF=[52,108],hF=rotP(sF,[3,14],P.armF||0);
  I.push({tf:T,limb:curve([sF,hF]),w:8,fill:BEAV},{tf:T,ds:[E(hF[0],hF[1],5,4.6)],fill:sh(BEAV),sh:false});
  if(P.handTom)I.push(...tomatoIt(hF[0]+2,hF[1]-5,0,.7,T));}
 return I}
function beaverCat(S,lv,P={}){
 const D=Doc(160,160,S,DT(P)),I=[],M=LVM[lv],A=(P.aa??160)*Math.PI/180,ax=106,ay=88,ex=ax+Math.cos(A)*48,ey=ay+Math.sin(A)*48,bx=ax-Math.cos(A)*10,byy=ay-Math.sin(A)*10;
 if(lv===2)I.push(...flagIt(12,126,76,P.ph||0));
 if(!P.noAnimal)I.push(...beaver(S,P,'body'));
 if(lv<2)I.push({ds:[RR(62,110,90,16,5)],fill:M.a,r:6,mark:[matMark(lv,62,110,90,16,'h')]});
 else I.push({ds:[RR(60,102,94,32,6)],fill:K.stone,r:10,mark:[matMark(2,60,102,94,32)]},{ds:[RR(60,100,94,5,2.5)],fill:K.coin,sh:false});
 I.push({ds:[RP([[92,112],[106,82],[120,112]],4)],fill:lv===2?K.stone:M.a,r:6,mark:lv===1?[`<path d="M99 100H113" stroke="${K.panel}" stroke-width="4"/>`]:undefined});
 I.push({limb:`M${f(bx)} ${f(byy)}L${f(ex)} ${f(ey)}`,w:8,fill:lv===1?K.panel:K.woodL});
 const sc=lv===2?K.coin:M.b;
 I.push({ds:[E(ex,ey,10,7)],fill:sc,r:5,mark:[`<path d="${E(ex,ey-1.5,6.5,3.5)}" fill="${sh(sc)}"/>`]});
 if(P.tom)I.push(...tomatoIt(ex,ey-6,0,1));
 if(P.tomFly)I.push(...tomatoIt(P.tomFly[0],P.tomFly[1],P.tomFly[2]||0,1));
 I.push({ds:[E(ax,ay,5.5)],fill:lv===2?K.coin:K.wood,r:4});
 if(lv<2)I.push({ds:[E(76,136,10),E(138,136,10)],fill:lv?K.panel:K.wood,r:8,mark:[`<path d="${E(76,136,3.5)}" fill="${lv?K.red:K.woodL}"/><path d="${E(138,136,3.5)}" fill="${lv?K.red:K.woodL}"/>`]});
 if(!P.noAnimal)I.push(...beaver(S,P,'arm'));
 if(P.spark)I.push(sparkIt(P.spark));
 render(D,I);return D.svg()}

// ---------- Улей ----------
function beeSmall(x,y,w=0){return [{ds:[ER(x-1.5,y-4.5-w,2.6,3.6,-20),ER(x+1.5,y-4.5-w,2.6,3.6,20)],fill:'#FFFFFF',line:1.4,sh:false},{ds:[E(x,y,5,4)],fill:K.coin,line:1.8,sh:false,mark:[`<path d="M${f(x-1.5)} ${f(y-4)}V${f(y+4)}M${f(x+1.5)} ${f(y-4)}V${f(y+4)}" stroke="${O}" stroke-width="1.5"/>`]},{ds:[E(x+4.5,y-.5,2.8)],fill:K.coin,line:1.6,sh:false,mark:[`<path d="${E(x+5.3,y-1,1)}" fill="${O}"/>`]}]}
function beeBig(S,x,y,P){const I=[],wg=P.wing||0;
 I.push({ds:[ER(x-6,y-12-wg,6,9,-25),ER(x+4,y-13-wg,6,9,20)],fill:'#FFFFFF',line:2.2,sh:false});
 I.push({ds:[RP([[x-12,y-1],[x-18,y+2],[x-12,y+4]],1)],fill:O,line:0,sh:false});
 I.push({ds:[E(x,y,13,11)],fill:K.coin,r:11,hl:[x-5,y-5,3,1.8,-30],mark:[`<path d="M${x-7} ${y-12}V${y+12}M${x+1} ${y-12}V${y+12}" stroke="${O}" stroke-width="4"/>`]});
 I.push({limb:`M${x+9} ${y-10}Q${x+6} ${y-15} ${x+5} ${y-19}`,w:1.8,fill:O,line:0},{limb:`M${x+14} ${y-10}Q${x+16} ${y-15} ${x+18} ${y-19}`,w:1.8,fill:O,line:0},{ds:[E(x+5,y-19.5,2.2),E(x+18,y-19.5,2.2)],fill:O,line:0,sh:false});
 I.push({ds:[E(x+11,y-4,8.5,8)],fill:K.coin,r:8,hl:[x+8,y-9,2.4,1.4,-30]});
 I.push({raw:dEyes(S,[[x+8.5,y-5,3.1],[x+14,y-5,3.4]],P.eyes)+(P.open?`<path d="M${x+8} ${y}Q${x+12} ${y+6} ${x+16} ${y-.5}Z" fill="#C9475A" stroke="${O}" stroke-width="1.8" stroke-linejoin="round"/>`:`<path d="M${x+8.5} ${y}Q${x+12} ${y+3} ${x+15.5} ${y-.5}" fill="none" stroke="${O}" stroke-width="1.8" stroke-linecap="round"/>`)});
 return I}
function hive(S,lv,P={}){
 const D=Doc(160,160,S,DT(P)),I=[],M=LVM[lv];
 if(lv===2)I.push(...flagIt(104,72,54,P.ph||0));
 if(lv<2)I.push({ds:[RR(46,126,9,20,3),RR(93,126,9,20,3)],fill:M.b,r:4},{ds:[RR(38,120,72,9,4)],fill:M.b,r:4});
 else I.push({ds:[RR(36,118,76,28,6)],fill:K.stone,r:10,mark:[matMark(2,36,118,76,28)]});
 const bc=lv===2?K.panel:M.a;
 I.push({ds:[RR(42,94,64,28,5)],fill:bc,r:8,mark:[lv<2?matMark(lv,42,94,64,28,'h'):`<path d="M42 100H106" stroke="${K.coin}" stroke-width="4"/>`]});
 I.push({ds:[RR(55,111,22,6,3)],fill:'#3B2A22',line:2,sh:false},{ds:[RR(50,117,32,5,2.5)],fill:lv===2?K.coin:M.b,sh:false});
 I.push({ds:[RR(44,70,60,26,5)],fill:bc,r:8,mark:[lv<2?matMark(lv,44,70,60,26,'h'):`<path d="M44 76H104" stroke="${K.coin}" stroke-width="4"/>`]});
 I.push({ds:[RP([[34,74],[74,48],[114,74]],6)],fill:lv===0?K.wood:lv===1?K.panel:K.coin,r:10,hl:[60,62,6,2,-30]},{ds:[RR(32,72,84,6,3)],fill:lv===1?K.red:lv===2?sh(K.coin):sh(K.wood),sh:false});
 if(!P.noAnimal)I.push(...beeBig(S,70,42-(P.lift||0)+(P.by||0),P));
 (P.bees||[]).forEach(([x,y,w])=>I.push(...beeSmall(x,y,w)));
 if(P.spark)I.push(sparkIt(P.spark));
 render(D,I);return D.svg()}

// ---------- Забор 128×64 ----------
function fencePieces(lv){const P=[];
 if(lv===0){[8,59.5,111].forEach(x=>P.push({st:1,tall:1,d:RP([[x,58],[x,17],[x+4.5,12],[x+9,17],[x+9,58]],2),c:[x+4.5,36],fill:K.wood,r:5}));
  [[4,20],[4,37]].forEach(([x,y])=>[0,1].forEach(h=>P.push({st:2,d:RR(x+h*60,y,60,10,3),c:[x+h*60+30,y+5],fill:K.woodL,r:5,mark:`<path d="${E(x+h*60+(h?54:6),y+5,1.4)}" fill="${O}"/>`})));}
 else if(lv===1){[[4,24],[4,42]].forEach(([x,y])=>[0,1].forEach(h=>P.push({st:1,d:RR(x+h*60,y,60,6,2),c:[x+h*60+30,y+3],fill:'#EAD6AE',r:4})));
  for(let i=0;i<9;i++){const x=5+i*13.5;P.push({st:2,tall:1,d:RP([[x,57],[x,17],[x+5,11],[x+10,17],[x+10,57]],2),c:[x+5,34],fill:K.panel,r:5})}}
 else{let s=7;const rnd=()=>(s=(s*9301+49297)%233280)/233280;for(let r=2;r>=0;r--){let x=4-(r%2)*11;const y=15+r*14;while(x<122){const w=19+rnd()*9,x0=Math.max(4,x),x1=Math.min(124,x+w);if(x1-x0>7)P.push({st:r===2?1:2,d:RR(x0,y,x1-x0-1.5,13.5,5),c:[(x0+x1)/2,y+7],fill:K.stone,r:5});x+=w}}}
 return P}
const crackM=c=>`<path d="M${f(c[0]-3)} ${f(c[1]-5)}l3 3.5l-2.5 2.5l3 4" fill="none" stroke="${O}" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round"/>`;
function fence(S,lv,P={}){
 const D=Doc(128,64,S,`translate(${P.dx||0} 0) rotate(${P.rot||0} 64 58) translate(64 58) scale(1 ${P.sy||1}) translate(-64 -58)`),I=[];
 fencePieces(lv).forEach((p,i)=>{const t=P.tr?P.tr(i,p)||{}:{};if(t.hide)return;I.push({tf:`translate(${f(t.dx||0)} ${f(t.dy||0)}) rotate(${f(t.rot||0)} ${f(p.c[0])} ${f(p.c[1])})`,ds:[p.d],fill:p.fill,r:p.r,mark:[p.mark||'',t.crack?crackM(p.c):'']})});
 if(P.extra)I.push(...P.extra);
 render(D,I);return D.svg()}
const DMG=[null,(i)=>({crack:i%3===1,rot:i%7===3?6:0}),(i,p)=>i%5===2?{hide:1}:{crack:i%2===0,rot:i%3===0?(p.tall?12:-9):0,dy:i%3===0?3:0}];
function flyT(i,p,t){const s=(i+3)*7919%1000/1000,s2=(i+5)*104729%1000/1000,vx=(p.c[0]-64)*.2+(s-.5)*16,vy=-48-s2*18;let dx=vx*t,dy=vy*t+96*t*t;const lim=52-p.c[1];if(dy>lim)dy=lim;return {dx,dy,rot:(p.tall?(p.c[0]<64?-1:1)*(80+s*15):(s2-.5)*70)*Math.min(1,t*1.3)}}

function defSheets(){
 const S=STY.a,s=small(S),out={},p='assets/d/';
 const add=(name,fr,w,h)=>{out[p+`${name}_${fr.length}f.svg`]=sheet(fr,w,h||w)};
 const DEFS={
  goose:{fn:goose,scaf:[28,128,70,146,-5],idle:[{},{gb:1},{gb:1,eyes:'blink'},{gb:.5}],attack:[{ht:-8,puff:1,eyes:'blink',gb:1},{ht:4,muzzle:1,tr:4},{ht:-5,tr:13,eyes:'happy',gb:-1},{}],jump:{lift:6,eyes:'happy'},cheer:{eyes:'happy',cheer:1,spark:[[40,40,6],[140,24,5],[118,58,4]]}},
  frog:{fn:frog,scaf:[42,106,78],idle:[{drip:0},{by:1,drip:1},{by:1,eyes:'blink',drip:2},{by:.5}],attack:[0,45,90,135].map((th,i)=>({th,spray:1,eyes:i%2?'happy':'open',open:i%2})),jump:{lift:16,eyes:'happy',open:1},cheer:{cheer:1,eyes:'happy',open:1,spark:[[30,40,6],[112,24,5],[134,80,4]]}},
  beaver:{fn:beaverCat,scaf:[60,150,84],idle:[{tom:1,armF:-55},{tom:1,armF:-55,by:1},{tom:1,armF:-55,by:1,eyes:'blink'},{tom:1,armF:-55,by:.5}],attack:[{aa:166,tom:1,armF:-45,by:1.5,ht:-4},{aa:172,tom:1,armF:-35,by:2.5,ht:-6,eyes:'blink'},{aa:276,armF:-150,eyes:'happy',tomFly:[128,26,40]},{aa:292,armF:-140,eyes:'happy'},{aa:235,armF:-40,handTom:1}],jump:{lift:10,eyes:'happy',armF:-150},cheer:{eyes:'happy',armF:-150,armB:150,spark:[[16,60,6],[70,52,5],[140,70,4]]}},
  hive:{fn:hive,scaf:[38,110,52],idle:[0,1,2,3].map(fi=>({wing:fi%2*2,eyes:fi===2?'blink':'open',bees:[0,1,2].map(k=>{const a=(fi*90+k*120)*Math.PI/180;return [74+Math.cos(a)*54,98+Math.sin(a)*28,fi%2]})})),attack:[{eyes:'wide',bees:[[64,110,0],[74,107,1],[84,111,0]]},{open:1,eyes:'happy',wing:2,bees:[[90,106,1],[100,99,0],[96,114,1],[108,108,0]]},{open:1,eyes:'happy',bees:[[118,98,0],[130,106,1],[138,95,0],[124,114,1],[146,104,0]]},{eyes:'happy',bees:[[148,98,1],[154,110,0]]}],jump:{lift:12,eyes:'happy',wing:3,open:1},cheer:{eyes:'happy',wing:3,open:1,spark:[[30,40,6],[122,30,5],[130,90,4]],bees:[[30,90,0],[126,100,1]]}}
 };
 const NM=['l1','l2','l3'];
 for(const [id,d] of Object.entries(DEFS)){
  for(let lv=0;lv<3;lv++){const fn=(q)=>d.fn(S,lv,q);
   add(`def_${id}_${NM[lv]}_build`,[poofSvg(S,160,160,78,126,30),scaffold(S,...d.scaf),fn({noAnimal:1}),fn(d.jump),fn(d.cheer),fn({})],160);
   add(`def_${id}_${NM[lv]}_idle`,d.idle.map((q,i)=>fn({...q,ph:i})),160);
   add(`def_${id}_${NM[lv]}_attack`,d.attack.map(q=>fn(q)),160);
   if(lv<2){const nx=q=>d.fn(S,lv+1,q);add(`def_${id}_upgrade_${lv+1}to${lv+2}`,[comb(160,160,[fn({}),flashSvg(S,.55)]),comb(160,160,[fn({sc:1.06}),flashSvg(S,1)]),comb(160,160,[nx({sc:.94}),flashSvg(S,1.1)]),nx({sc:1.04,sy:.97,spark:[[30,50,7],[132,40,6],[120,112,5],[40,112,5]]}),nx({})],160)}
  }
  const por=`<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="6 4 150 150">${unwrap(d.fn(S,0,{}))}</svg>`;
  out[p+`ui_def_portrait_${id}.svg`]=por;
  out[p+`ui_def_portrait_${id}_locked.svg`]=por.replace(/(fill|stroke)="#[0-9A-Fa-f]{3,6}"/g,'$1="#3F3D55"');
 }
 for(let lv=0;lv<3;lv++){const n=`fence_${NM[lv]}`,F=q=>fence(s,lv,q);
  add(n+'_idle',[F({})],128,64);
  add(n+'_damage',[F({}),F({tr:DMG[1]}),F({tr:DMG[2]})],128,64);
  add(n+'_build',[poofSvg(s,128,64,64,42,18),F({tr:(i,p)=>p.st===1?{}:{hide:1}}),F({tr:(i,p)=>p.st===1?{}:(i%2?{hide:1}:{dy:-6})}),F({sy:.94,extra:[sparkIt([[20,12,5],[108,10,4],[64,6,4]])]}),F({})],128,64);
  add(n+'_hit',[F({dx:-3,rot:-2.5,extra:[sparkIt([[112,26,7]]),...chipsIt(2,104,30,1)]}),F({dx:1.5,rot:1})],128,64);
  add(n+'_destroy',[F({tr:DMG[2],dx:-2,extra:[sparkIt([[108,24,8]])]}),F({tr:(i,p)=>flyT(i,p,.18)}),F({tr:(i,p)=>flyT(i,p,.45)}),F({tr:(i,p)=>flyT(i,p,.8)}),comb(128,64,[F({tr:(i,p)=>({...flyT(i,p,1),hide:i%2})}),poofSvg(s,128,64,64,44,18)]),blank(128,64,s)],128,64);
  add(n+'_repair',[F({tr:(i,p)=>flyT(i,p,1)}),F({tr:(i,p)=>flyT(i,p,.55)}),F({tr:(i,p)=>flyT(i,p,.15),extra:[sparkIt([[24,14,5],[100,12,5]])]}),F({extra:[sparkIt([[64,8,5]])]})],128,64);
 }
 {const D=Doc(16,16,s);render(D,[{ds:[E(8,8,5)],fill:K.pea,hl:[6.3,6.2,1.6,1,-30]}]);out[p+'proj_pea.svg']=D.svg()}
 {const D=Doc(16,16,s);render(D,[{ds:['M8 1.5Q13.5 8.5 8 14.5Q2.5 8.5 8 1.5Z'],fill:K.sky,hl:[6.2,8.5,1.3,2,-10]}]);out[p+'proj_drop.svg']=D.svg()}
 add('proj_tomato_spin',[0,90,180,270].map(a=>{const D=Doc(32,32,s);render(D,tomatoIt(16,17,a,1.15));return D.svg()}),32);
 return out;
}
