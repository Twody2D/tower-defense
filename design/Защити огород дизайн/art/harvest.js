// Партия K: урожай фермы (192) и урожай в бою (160). После gen/.../screens.
const PUMP='#F5902A',RASP='#E24A78',HONEY='#FFB23F',POT='#B8743A',UNR='#A5D152',GLOW='#FFF0B0',UNR2='#D9D35A',NEAR='#F07A4A',PUMPY='#E8B84A',RASPL='#F59AB4';
Object.assign(SH,{[PUMP]:'#D06A14',[RASP]:'#B82E5A',[HONEY]:'#E08A1A',[POT]:'#8E5424',[UNR]:'#7FAE33',[UNR2]:'#B5AF3A',[NEAR]:'#C9542A',[PUMPY]:'#C29530',[RASPL]:'#D9718F'});
Object.assign(HL,{[PUMP]:'#FFBE73',[RASP]:'#FF8FB0',[HONEY]:'#FFE08A',[POT]:'#D89A60',[UNR]:'#CDEB8A',[UNR2]:'#F0EC96',[NEAR]:'#FFA982',[PUMPY]:'#F7DC8E',[RASPL]:'#FFC4D4'});
const lw=k=>Math.max(1.2,1.7*k);
const appleF=(x,y,k=1,c=K.red,tf='')=>[{tf,limb:`M${f(x)} ${f(y-7*k)}Q${f(x+1*k)} ${f(y-11*k)} ${f(x+3*k)} ${f(y-13*k)}`,w:Math.max(1.4,1.8*k),fill:K.wood},{tf,ds:[E(x,y,8.5*k,8*k)],fill:c,r:7*k,hl:[x-3*k,y-3*k,2.3*k,1.5*k,-30]},{tf,ds:[ER(x+5*k,y-10*k,3.8*k,2*k,-25)],fill:K.sprout,line:lw(k),sh:false}];
const pumpF=(x,y,k=1,c=PUMP,tf='')=>[{tf,ds:[RR(x-2*k,y-12*k,4*k,6*k,1.5*k)],fill:K.wood,sh:false},{tf,ds:[E(x-6*k,y,6.5*k,8*k),E(x+6*k,y,6.5*k,8*k)],fill:c,r:6*k,sh:false},{tf,ds:[E(x,y,7*k,8.6*k)],fill:c,r:7*k,hl:[x-2.5*k,y-3.5*k,1.8*k,2.6*k,0]},{tf,ds:[ER(x+5*k,y-10*k,4*k,2.2*k,-20)],fill:K.leaf,line:lw(k),sh:false}];
const raspF=(x,y,k=1,c=RASP,tf='')=>[{tf,ds:[[0,-3],[-3.2,-.6],[3.2,-.6],[-2,2.8],[2,2.8],[0,5.6]].map(([u,v])=>E(x+u*k,y+v*k,2.7*k)),fill:c,line:lw(k)*.85,sh:false},{tf,ds:[E(x-1.3*k,y-3.8*k,1.1*k,.75*k)],fill:hl(c),line:0,sh:false},{tf,ds:[ER(x-2.6*k,y-6.4*k,3*k,1.5*k,-30),ER(x+2.6*k,y-6.4*k,3*k,1.5*k,30)],fill:K.leaf,line:lw(k)*.8,sh:false}];
const honeyF=(x,y,k=1,full=1,tf='')=>{const I=[{tf,ds:[`M${f(x-9*k)} ${f(y-6*k)}Q${f(x-13*k)} ${f(y+9*k)} ${f(x)} ${f(y+10*k)}Q${f(x+13*k)} ${f(y+9*k)} ${f(x+9*k)} ${f(y-6*k)}Z`],fill:POT,r:8*k,hl:[x-5.5*k,y+1*k,1.6*k,3*k,0]},{tf,ds:[E(x,y-6.5*k,10*k,3.6*k)],fill:full?HONEY:sh(POT),line:lw(k),sh:false}];
 if(full)I.push({tf,ds:[`M${f(x+2.5*k)} ${f(y-5*k)}Q${f(x+6.5*k)} ${f(y-1*k)} ${f(x+5.5*k)} ${f(y+3.5*k)}Q${f(x+3.6*k)} ${f(y+4.6*k)} ${f(x+3.2*k)} ${f(y+1*k)}Q${f(x+3*k)} ${f(y-2*k)} ${f(x+1*k)} ${f(y-4*k)}Z`],fill:HONEY,line:lw(k)*.8,sh:false});
 I.push({tf,ds:[RR(x-6.5*k,y-.5*k,13*k,5.5*k,1.6*k)],fill:K.panel,line:lw(k)*.8,sh:false});return I};
const FRUIT={apple:appleF,pumpkin:pumpF,rasp:raspF,honey:(x,y,k,c,tf)=>honeyF(x,y,k,c!==0,tf)};
function fruitsAt(kind,L,P,col,k0,tf=''){const I=[],fy=P.fy||0,fk=P.fk||1;
 L.forEach(([x,y],i)=>{const yy=y+fy*(1+(i%3)*.18);if(P.puff){if(i%2===0||L.length<6)I.push({tf,...puffs([[x,yy,7*k0],[x-6*k0,yy+4*k0,5*k0],[x+6*k0,yy+4*k0,5*k0]],'#FFF4DC')})}else I.push(...FRUIT[kind](x,yy,k0*fk,col,tf))});
 if(P.glint!=null&&!P.puff&&L.length){const [x,y]=L[(P.glint*2+1)%L.length];I.push({tf,...sparkIt([[x+7*k0,y-7*k0+fy,5.5]])})}
 return I}
function fenceFront(lv,x0,x1,yb,fk=1){const I=[],m=(x0+x1)/2;
 if(lv===0){I.push({limb:`M${x0} ${yb-15}Q${m} ${yb-9} ${x1} ${yb-15}`,w:2.4,fill:K.straw});[x0,m,x1].forEach(x=>I.push({ds:[RR(x-3,yb-22,6,24,2)],fill:K.wood,r:3,sh:false}));}
 else if(lv===1){[yb-19,yb-9].forEach(y=>I.push({ds:[RR(x0-4,y-2.5,x1-x0+8,5,2.5)],fill:K.woodL,sh:false}));const n=Math.round((x1-x0)/19);for(let i=0;i<=n;i++){const x=x0+i*(x1-x0)/n;I.push({ds:[RR(x-3,yb-25,6,27,2.5)],fill:K.wood,r:3,sh:false})}}
 else{[yb-19,yb-9].forEach(y=>I.push({ds:[RR(x0-4,y-3,x1-x0+8,6,3)],fill:'#FFFFFF',sh:false}));const n=Math.round((x1-x0)/13);for(let i=0;i<=n;i++){const x=x0+i*(x1-x0)/n;I.push({ds:[RP([[x-4,yb+2],[x-4,yb-24],[x,yb-29],[x+4,yb-24],[x+4,yb+2]],1.5)],fill:'#FFFFFF',r:3,sh:false})}I.push({ds:[E(x0,yb-30,3.4),E(x1,yb-30,3.4)],fill:K.coin,line:1.8,sh:false});}
 const T=`translate(0 ${yb}) scale(1 ${fk}) translate(0 ${-yb})`;return I.map(o=>({...o,tf:T}))}
function appleTree(P,bt){const I=[],cr=`rotate(${P.rot||0} 96 176)`;
 I.push({ds:[E(96,178,34,7)],fill:K.soil,line:2.2,sh:false});
 I.push({ds:[RP([[83,180],[88,118],[104,118],[109,180]],6)],fill:K.wood,r:9,mark:[`<path d="M93 160Q97 146 95 130" stroke="${sh(K.wood)}" stroke-width="2.5" fill="none" stroke-linecap="round"/>`]});
 I.push({tf:cr,ds:[E(96,74,44,40),E(58,94,32,28),E(134,94,32,28),E(76,116,28,22),E(116,116,28,22),E(66,56,26,24),E(126,58,26,24)],fill:K.leaf,r:44,hl:[64,44,14,8,-30]});
 if(P.flw)I.push({tf:cr,ds:[[70,70],[116,62],[134,96],[88,104],[56,98],[100,40],[120,118]].map(([x,y])=>E(x,y,4.6)),fill:K.pink,line:2,sh:false,mark:[[70,70],[116,62],[134,96],[88,104],[56,98],[100,40],[120,118]].map(([x,y])=>`<path d="${E(x,y,1.6)}" fill="${K.coin}"/>`)});
 const L=bt?[[64,80],[118,64],[138,104],[92,112],[54,108]]:[[70,72],[116,62],[134,98],[88,106],[56,100],[100,42],[120,124],[74,126],[148,74]].slice(0,[5,7,9][P.lv||0]);
 if(P.fr)I.push(...fruitsAt('apple',L,P,P.fr[0],P.fr[1],cr));
 return I}
function wheatBed(P){const I=[],lv=P.lv||0,cols=[4,5,6][lv],fr=[K.wood,K.woodL,K.red][lv];
 I.push({ds:[RR(18,128,156,54,14)],fill:sh(fr),sh:false},{ds:[RR(18,118,156,54,14)],fill:fr,r:16,hl:[40,122,20,2,0],sh:false},{ds:[RR(28,126,136,38,8)],fill:K.soil,line:2.5,sh:false});
 if(lv)I.push({ds:[E(24,124,4.8),E(168,124,4.8),E(24,166,4.8),E(168,166,4.8)],fill:lv===2?K.coin:K.wood,line:2,sh:false});
 const H=P.h||10;
 [134,146,158].forEach((y,r)=>{for(let i=0;i<cols;i++){const x=42+i*(108/(cols-1))+(r%2)*6-3,sw=(P.sw||0)*(1+((i+r)%2)*.6),tx=x+sw,ty=y-H;
  I.push({limb:`M${f(x)} ${y}Q${f(x+sw*.3)} ${f(y-H*.5)} ${f(tx)} ${f(ty+4)}`,w:2.3,fill:P.fr&&P.fr[0]===K.straw?sh(K.straw):K.leaf});
  if(!P.fr)I.push({ds:[ER(tx-3,ty+5,3,1.6,-35),ER(tx+3,ty+5,3,1.6,35)],fill:K.sprout,line:1.6,sh:false});
  else if(P.puff){if((i+r)%3===0)I.push(puffs([[tx,ty+(P.fy||0),6],[tx-5,ty+4+(P.fy||0),4]],'#FFF4DC'))}
  else{const k=P.fr[1]*(P.fk||1),yy=ty+(P.fy||0)*(1+(i%3)*.2);I.push({ds:[ER(tx,yy,3.2*k,7.5*k,sw*2)],fill:P.fr[0],r:3,line:2,mark:[`<path d="M${f(tx-2.6*k)} ${f(yy-2*k)}L${f(tx)} ${f(yy)}L${f(tx+2.6*k)} ${f(yy-2*k)}M${f(tx-2.6*k)} ${f(yy+2.6*k)}L${f(tx)} ${f(yy+4.6*k)}L${f(tx+2.6*k)} ${f(yy+2.6*k)}" fill="none" stroke="${sh(P.fr[0])}" stroke-width="1.2"/>`]})}}});
 if(P.glint!=null&&!P.puff&&P.fr)I.push(sparkIt([[52+P.glint*28,100+(P.fy||0),6]]));
 return I}
function pumpkinPatch(P,bt){const I=[],lv=P.lv||0,cr=`rotate(${P.rot||0} 96 166)`;
 I.push({ds:[E(96,160,74,20)],fill:K.soil,line:2.5,sh:false,mark:[`<path d="M40 158Q60 152 80 158M110 164Q130 158 150 164" stroke="${sh(K.soil)}" stroke-width="3" fill="none" stroke-linecap="round"/>`]});
 I.push({tf:cr,limb:'M26 158Q50 136 80 148Q110 160 136 140Q152 130 168 148',w:3.4,fill:K.leaf});
 I.push({tf:cr,ds:[ER(44,144,12,7.5,-20),ER(88,138,13,8,15),ER(128,146,12,7.5,-10),ER(162,138,11,7,25),ER(64,168,11,6.5,10),ER(142,170,11,6.5,-15)],fill:K.sprout,r:5,line:2.4});
 if(P.flw)I.push({tf:cr,ds:[[60,150],[112,150],[150,156]].map(([x,y])=>starD(x,y,5.5,2.6)),fill:K.coin,line:1.8,sh:false});
 const L=bt?[[58,148],[132,150],[96,164]]:[[62,150],[128,152],[96,166],[44,170],[150,172]].slice(0,[2,3,4][lv]);
 if(P.fr)I.push(...fruitsAt('pumpkin',L,P,P.fr[0],P.fr[1],cr));
 return I}
function raspBush(P){const cr=`rotate(${P.rot||0} 96 178)`,I=[{ds:[E(96,176,56,9)],fill:K.soil,line:2.2,sh:false},{tf:cr,ds:[E(96,118,42,36),E(58,138,32,28),E(134,138,32,28),E(76,94,28,24),E(118,96,28,24),E(96,152,54,22)],fill:K.leaf,r:30,hl:[70,90,10,6,-30]}];
 const L=[[70,112],[110,96],[132,128],[88,140],[54,136],[116,154],[96,116]];
 if(P.fr)I.push(...fruitsAt('rasp',L,P,P.fr[0],P.fr[1],cr));
 return I}
function hiveBox(x,yb,w,lv){const h=w*1.05,c=[K.woodL,K.panel,'#FFFFFF'][lv],rf=[K.wood,K.red,K.coin][lv],I=[],b1=yb-10-h*.48,b2=yb-10-h*.95,ln=y=>`<path d="M${f(x-w/2+2)} ${f(y)}H${f(x+w/2-2)}" stroke="${sh(c)}" stroke-width="2.4"/>`;
 I.push({ds:[RR(x-w/2+4,yb-11,6,11,2),RR(x+w/2-10,yb-11,6,11,2)],fill:K.wood,sh:false});
 I.push({ds:[RR(x-w/2,b1,w,h*.48,5)],fill:c,r:6,mark:[ln(b1+h*.24)]},{ds:[RR(x-w/2+2,b2,w-4,h*.48,5)],fill:c,r:6,mark:[ln(b2+h*.24)]});
 I.push({ds:[RR(x-w/2-5,b2-9,w+10,11,4)],fill:rf,r:4,hl:[x-w/4,b2-6,w*.14,1.4,0]},{ds:[RR(x-7,yb-23,14,6,3)],fill:'#3B2A22',line:2,sh:false});
 return I}
function apiary(P){const I=[],lv=P.lv||0,hs=lv?[[44,40],[96,42],[148,40]]:[[62,50],[130,50]],ph=P.ph||0;
 I.push({ds:[E(96,168,78,14)],fill:'#6FBF5A',line:2.2,sh:false});
 hs.forEach(([x,w])=>I.push(...hiveBox(x,156,w,lv)));
 const L=[[58,172],[96,176],[134,172]].slice(0,P.pots||0);
 L.forEach(([x,y],i)=>{const half=P.half&&i===L.length-1,fy=y+(P.fy||0)*(1+i*.18),k=1.25*(P.fk||1);if(P.puff)I.push(puffs([[x,fy-8,8],[x-7,fy-4,6],[x+7,fy-4,6]],'#FFF4DC'));else I.push(...honeyF(x,fy-10,k,half?0:1))});
 if(P.glint!=null&&!P.puff&&L.length){const [x,y]=L[P.glint%L.length];I.push(sparkIt([[x+10,y-26+(P.fy||0),5.5]]))}
 const B=[[40,70],[150,64],[96,48],[124,96]].slice(0,P.bees||0);B.forEach(([x,y],i)=>{const a=(ph*90+i*97)*Math.PI/180;I.push(...beeSmall(x+Math.cos(a)*9,y+Math.sin(a)*5,(ph+i)%2))});
 return I}
const CROPS={wheat:P=>wheatBed(P),apple:P=>appleTree(P,0),pumpkin:P=>pumpkinPatch(P,0),apiary:P=>apiary(P)};
const FEN={apple:[48,144,190,1],pumpkin:[26,166,192,.6],apiary:[20,172,192,.55]};
function cropSvg(S,type,P){const D=Doc(192,192,S,P.sq?'translate(96 186) scale(1.05 .94) translate(-96 -186)':''),I=CROPS[type](P);if(FEN[type])I.push(...fenceFront(P.lv||0,...FEN[type]));render(D,I);return D.svg()}
function lockedPlot(S){const D=Doc(192,192,S),I=[{ds:[E(96,170,70,17)],fill:K.soil,line:2.5,sh:false,mark:[`<path d="M44 168Q64 162 84 168M110 174Q128 168 146 174" stroke="${sh(K.soil)}" stroke-width="3" fill="none" stroke-linecap="round"/>`]},{ds:[E(40,176,7,5),E(152,166,6,4.5)],fill:K.stone,r:4,sh:false},
 {ds:[RR(91,104,10,70,3)],fill:K.wood,r:4},{ds:[RR(46,70,100,52,10)],fill:K.panel,r:10,hl:[60,74,14,2,0],mark:[`<path d="${RR(100,80,38,32,7)}" fill="#EAD6AE"/>`]},...lockIt(72,98,1.05),{ds:[E(50,74,3),E(142,74,3)],fill:K.wood,line:1.6,sh:false}];
 render(D,I);D.add(tuft(52,166,1.1,false,K.grass2)+tuft(140,174,1.1,true,K.grass2)+tuft(118,160,.9,false,K.grass2));return D.svg()}
const BT={apple:P=>appleTree(P,1),pumpkin:P=>pumpkinPatch(P,1),rasp:P=>raspBush(P)};
function battleSvg(S,type,P){const D=Doc(160,160,S,'scale(.8333333)');render(D,BT[type](P));return D.svg()}
function glowSvg(w,h,src,R,op){const id='gl'+R;return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}"><defs><filter id="${id}" x="-10%" y="-10%" width="120%" height="120%"><feMorphology in="SourceAlpha" operator="dilate" radius="${R}" result="d"/><feFlood flood-color="${GLOW}" flood-opacity="${op}"/><feComposite in2="d" operator="in" result="c"/><feComposite in="c" in2="SourceAlpha" operator="out"/></filter></defs><g filter="url(#${id})">${unwrap(src)}</g></svg>`}
function fallFruit(S,kind,i){const F={apple:appleF,pumpkin:pumpF,rasp:raspF}[kind],k0={apple:1.5,pumpkin:1.25,rasp:1.9}[kind];
 if(i===0)return doc(48,48,S,[{limb:'M17 3V11M31 1V9',w:2.2,fill:'#FFFFFF',line:1.2},...F(24,22,k0)]);
 if(i===1)return doc(48,48,S,[puffs([[11,41,3.5],[37,41,3.5]]),...F(24,32,k0)],'translate(24 44) scale(1.18 .8) translate(-24 -44)');
 return doc(48,48,S,[puffs([[16,28,8],[32,28,8],[24,20,8],[24,34,7]],'#FFF4DC'),...coinIt(24,27,8,1),sparkIt([[40,11,4]])]);}
function harvestSheets(){const S=STY.a,s=small(S),out={},pk='assets/k/',add=(n,fr,w,h)=>out[pk+`${n}_${fr.length}f.svg`]=sheet(fr,w,h||w),put=(n,v)=>out[pk+n+'.svg']=v;
 const ST={
  wheat:{grow:[{h:10},{h:22,fr:[K.sprout,.6]},{h:32,fr:[UNR,.85]}],ripe:{h:38,fr:[K.straw,1]}},
  apple:{grow:[{flw:1},{fr:[UNR,.6]},{fr:[UNR2,.9]}],ripe:{fr:[K.red,1.15]}},
  pumpkin:{grow:[{flw:1},{fr:[UNR,.7]},{fr:[PUMPY,1.05]}],ripe:{fr:[PUMP,1.5]}},
  apiary:{grow:[{pots:0,bees:1},{pots:1,half:1,bees:2},{pots:2,half:1,bees:3}],ripe:{pots:3,bees:4}}};
 const SW={wheat:[-2,1,3,1],apple:[-1.5,0,1.5,0],pumpkin:[-1.2,0,1.2,0],apiary:[0,0,0,0]};
 for(const [t,d] of Object.entries(ST)){const C=P=>cropSvg(S,t,P),rp=(lv,i)=>({...d.ripe,lv,sw:SW[t][i],rot:t==='wheat'?0:SW[t][i],glint:i,ph:i});
  add(`harvest_${t}_grow`,d.grow.map(g=>C({...g,lv:0,ph:0})),192);
  add(`harvest_${t}_ripe`,[0,1,2,3].map(i=>C(rp(0,i))),192);
  put(`harvest_${t}_ripe_lv2`,C(rp(1,0)));put(`harvest_${t}_ripe_lv3`,C(rp(2,0)));
  add(`harvest_${t}_collect`,[C({...rp(0,0),glint:null,sq:1,fk:1.08}),C({...rp(0,1),glint:null,fy:-12}),C({...rp(0,2),glint:null,fy:-28,fk:.8}),C({...rp(0,0),glint:null,fy:-30,puff:1}),C({...d.grow[0],lv:0})],192);}
 put('harvest_locked',lockedPlot(S));
 put('harvest_shadow',`<svg xmlns="http://www.w3.org/2000/svg" width="192" height="192" viewBox="0 0 192 192"><path d="${E(96,180,70,11)}" fill="${O}" fill-opacity=".22"/></svg>`);
 const BS={apple:{ripe:[K.red,1.7],reg:[[UNR,.9],[NEAR,1.4]],sw:[-1.6,0,1.6],fall:34},pumpkin:{ripe:[PUMP,2.05],reg:[[UNR,.9],[PUMPY,1.6]],sw:[-1,0,1],fall:8},rasp:{ripe:[RASP,1.95],reg:[[UNR,1],[RASPL,1.6]],sw:[-1.6,0,1.6],fall:20}};
 const BN={apple:'battle_apple_tree',pumpkin:'battle_pumpkin',rasp:'battle_raspberry'};
 for(const [t,d] of Object.entries(BS)){const B=P=>battleSvg(S,t,P),n=BN[t],r0=B({fr:d.ripe,rot:0});
  add(n+'_ripe',d.sw.map((r,i)=>B({fr:d.ripe,rot:r,glint:i})),160);
  add(n+'_shake',[B({fr:d.ripe,rot:-7}),B({fr:d.ripe,rot:7,fy:6}),B({fr:d.ripe,rot:-4,fy:d.fall,fk:.95}),B({rot:1.5})],160);
  put(n+'_empty',B({}));add(n+'_regrow',d.reg.map(fr=>B({fr})),160);
  add(n+'_highlight',[[5,.95],[8,.75],[6.5,.85]].map(([R,op])=>glowSvg(160,160,r0,R,op)),160);
  add(`battle_fruit_${t==='rasp'?'raspberry':t}_fall`,[0,1,2].map(i=>fallFruit(s,t,i)),48);}
 put('battle_shadow',`<svg xmlns="http://www.w3.org/2000/svg" width="160" height="160" viewBox="0 0 160 160"><path d="${E(80,148,54,9)}" fill="${O}" fill-opacity=".22"/></svg>`);
 const ic=(n,z,items)=>put(n,doc(z,z,z<100?s:S,items));
 ic('ui_icon_apple',64,appleF(30,37,2.4));ic('ui_icon_apple_128',128,appleF(60,74,4.8));
 ic('ui_icon_pumpkin',64,pumpF(32,38,1.9));ic('ui_icon_pumpkin_128',128,pumpF(64,76,3.8));
 ic('ui_icon_honey',64,honeyF(32,38,2));ic('ui_icon_honey_128',128,honeyF(64,76,4));
 return out}
