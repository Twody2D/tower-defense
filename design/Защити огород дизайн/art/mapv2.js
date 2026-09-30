// Партия L: меню v2 и карта v2. После gen/.../harvest.
function mapSheets(){const S=STY.a,s=small(S),out={},pl='assets/l/',add=(n,fr,w,h)=>out[pl+`${n}_${fr.length}f.svg`]=sheet(fr,w,h||w),put=(n,v)=>out[pl+n+'.svg']=v;
const svg=(w,h,b)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${b}</svg>`;
// домик 256
{const I=[];
 I.push({ds:[RR(168,34,26,56,4)],fill:K.stone,r:5,mark:[`<path d="M168 52H194M168 70H194" stroke="${sh(K.stone)}" stroke-width="2.4"/>`]},{ds:[RR(164,28,34,10,4)],fill:sh(K.stone),sh:false});
 I.push({ds:[RR(46,112,164,120,10)],fill:K.panel,r:14,hl:[70,120,20,3,0],mark:[`<path d="M46 150H210M46 190H210" stroke="#EAD6AE" stroke-width="3"/>`]});
 I.push({ds:[RR(46,112,10,120,3),RR(200,112,10,120,3)],fill:K.wood,sh:false});
 I.push({ds:[RR(110,158,40,74,[20,20,0,0])],fill:K.wood,r:8,mark:[`<path d="M130 160V232" stroke="${sh(K.wood)}" stroke-width="2.4"/><circle cx="140" cy="198" r="3" fill="${K.coin}" stroke="${O}" stroke-width="1.6"/>`]});
 [[64,146],[162,146]].forEach(([x,y])=>{I.push({ds:[RR(x,y,34,34,6)],fill:K.wood,sh:false},{ds:[RR(x+4,y+4,26,26,4)],fill:K.sky,line:2,sh:false,mark:[`<path d="M${x+17} ${y+4}V${y+30}M${x+4} ${y+17}H${x+30}" stroke="${K.wood}" stroke-width="3"/><path d="M${x+7} ${y+14}L${x+13} ${y+8}" stroke="#FFFFFF" stroke-width="2.4" stroke-linecap="round"/>`]},{ds:[RR(x-4,y+34,42,10,3)],fill:K.wood,sh:false});
  I.push({ds:[x+4,x+17,x+30].map(xx=>E(xx,y+32,4.2)),fill:K.pink,line:1.8,sh:false});});
 I.push({ds:[RP([[28,122],[128,40],[228,122]],[10,14,10])],fill:K.red,r:24,hl:[96,72,8,16,38],mark:[`<path d="M60 104L128 50L196 104" stroke="${sh(K.red)}" stroke-width="3" fill="none" stroke-linejoin="round"/>`]});
 I.push({ds:[E(128,92,13)],fill:K.panel,line:3,sh:false,mark:[`<path d="${E(128,92,7)}" fill="${K.sky}"/>`]});
 I.push({ds:[RR(106,228,48,8,3)],fill:K.stone,sh:false});
 const D=Doc(256,256,S);render(D,I);D.add(tuft(40,236,1.2,false,K.grass2)+tuft(220,236,1.2,true,K.grass2));put('env_house',D.svg());}
add('fx_chimney_smoke',[0,1,2,3].map(i=>{const P=[0,1,2].map(j=>{const q=((i+j*4/3)%4)/4,y=86-q*80,r=5+q*10;return [32+Math.sin(q*6)*6,y,r,q]});return doc(64,96,s,[{ds:P.map(([x,y,r])=>E(x,y,r)),fill:'#E8EEF8',line:2.2,sh:false}])}),64,96);
add('fx_butterfly',[1,.55,.12,.55].map(k=>doc(48,48,s,[{ds:[ER(24-11*k,18,11*k+1.5,9,-20),ER(24+11*k,18,11*k+1.5,9,20)],fill:K.pink,line:2,sh:false},{ds:[ER(24-8*k,31,7*k+1.2,6,20),ER(24+8*k,31,7*k+1.2,6,-20)],fill:K.coin,line:2,sh:false},{ds:[RR(22,14,4,24,2)],fill:O,line:0,sh:false},{limb:'M23 14Q20 7 17 6M25 14Q28 7 31 6',w:1.6,fill:O,line:0}])),48);
put('ui_icon_howto',doc(64,64,s,[{ds:['M10 12Q10 6 16 6H48Q54 6 54 12V40Q54 46 48 46H30L18 56V46H16Q10 46 10 40Z'],fill:'#4FB0F0',r:12,hl:[20,14,6,2,-10]},{limb:'M24 20Q24 12 32 12Q40 12 40 19Q40 24 34 27Q32 28 32 32',w:5.5,fill:'#FFFFFF'},{ds:[E(32,39,3.4)],fill:'#FFFFFF',line:2,sh:false}]));
// таблички уровней 160
const foxBadge=(cx,cy,k,grey)=>{const c=grey?'#8F8C9A':K.pest;return [{ds:[RP([[cx-15*k,cy-4*k],[cx-19*k,cy-22*k],[cx-5*k,cy-12*k]],2*k),RP([[cx+15*k,cy-4*k],[cx+19*k,cy-22*k],[cx+5*k,cy-12*k]],2*k)],fill:c,r:3,line:2.4,sh:false},{ds:[E(cx,cy,17*k,14*k)],fill:c,r:10,hl:[cx-7*k,cy-6*k,3*k,1.8*k,-30]},{ds:[ER(cx,cy+6*k,10*k,6*k,0)],fill:grey?'#DAD8E0':K.cream,line:2,sh:false},{raw:`<path d="${E(cx-6*k,cy-2*k,2.2*k)}" fill="${O}"/><path d="${E(cx+6*k,cy-2*k,2.2*k)}" fill="${O}"/><path d="${E(cx,cy+3.5*k,2.6*k,2*k)}" fill="${O}"/>`}]};
const sign=(st,fox,gl)=>{const grey=st==='locked',wd=grey?'#B9B6C2':K.wood,bd=grey?'#DAD8E0':st==='done'?K.panel:K.woodL,I=[];
 if(gl)I.push({ds:[E(80,138,52*gl,15*gl)],fill:'#FFF0B0',line:0,sh:false},{ds:[burst(80,70,62*gl,44*gl,10,gl*20)],fill:'#FFF0B0',line:0,sh:false});
 I.push({ds:[E(80,140,26,7)],fill:K.soil,line:2,sh:false},{ds:[RR(73,86,14,56,4)],fill:wd,r:4});
 I.push({ds:[RP([[26,40],[134,40],[140,70],[134,100],[26,100],[20,70]],8)],fill:wd,r:14,hl:[40,46,14,2.4,0]});
 I.push({ds:[RP([[34,48],[126,48],[131,70],[126,92],[34,92],[29,70]],6)],fill:bd,line:2.5,sh:false,mark:[grey?'':`<path d="M34 70H56M104 70H126" stroke="${sh(bd)}" stroke-width="2.4" stroke-linecap="round"/>`]});
 I.push({ds:[E(80,70,23)],fill:grey?'#C9C6D2':'#FFFFFF',line:2.5,sh:false});
 if(grey)I.push(...lockIt(80,72,1.05));
 if(st==='done')I.push({ds:[RP([[112,90],[140,90],[134,100],[140,110],[112,110]],2)],fill:'#72C83E',line:2.4,sh:false});
 if(fox)I.push(...foxBadge(80,28,1,grey));
 [[30,44],[130,44]].forEach(([x,y])=>I.push({ds:[E(x,y,3)],fill:grey?'#8F8C9A':K.stone,line:1.6,sh:false}));
 return doc(160,160,S,I)};
for(const fx of [0,1]){const p=fx?'map_level_fox_':'map_level_';put(p+'locked',sign('locked',fx));put(p+'open',sign('open',fx));put(p+'done',sign('done',fx));add(p+'current',[.85,1,.92].map(g=>sign('open',fx,g)),160);}
// тропинка
put('map_path_patch',doc(48,32,s,[{ds:[blob([[4,17],[10,8],[24,5],[38,8],[45,16],[38,25],[24,28],[10,25]])],fill:'#D9B47A',line:0,sh:false,mark:[`<path d="${E(18,13,3,1.6)}" fill="#EAD0A0"/><path d="${E(32,21,2.4,1.3)}" fill="#C69A5F"/>`]}]));
put('map_path_stone',doc(48,32,s,[{ds:[ER(24,18,18,10,-4)],fill:'#A7A9B4',sh:false},{ds:[ER(24,15,18,10,-4)],fill:K.stone,r:8,hl:[17,11,5,2,-10]}]));
// ручей-полосы 1080×256
const strip=(top,bot)=>{const D=Doc(1080,256,S),wave=(y,a,ph)=>{let d=`M0 ${y}`;for(let x=0;x<=1080;x+=60)d+=`Q${x+30} ${y+a*Math.sin((x/60+ph)*1.3)} ${x+60} ${y}`;return d};
 let b=`<rect width="1080" height="256" fill="${bot}"/><path d="${wave(118,10,0)}V0H0Z" fill="${top}"/>`;
 const up=wave(96,9,.4),dn=`M1080 172`+Array.from({length:18},(_,i)=>{const x=1080-i*60;return `Q${x-30} ${172+9*Math.sin((i+.7)*1.3)} ${x-60} 172`}).join('');
 b+=`<path d="${up}L1080 172${dn.slice(9)}Z" fill="${K.road}" stroke="${O}" stroke-width="4"/>`;
 const w1=wave(110,8,.4),w2=`M1080 158`+Array.from({length:18},(_,i)=>{const x=1080-i*60;return `Q${x-30} ${158+8*Math.sin((i+.7)*1.3)} ${x-60} 158`}).join('');
 b+=`<path d="${w1}L1080 158${w2.slice(9)}Z" fill="${K.sky}" stroke="${O}" stroke-width="3.5"/>`;
 b+=`<path d="${wave(126,5,1.2)}" fill="none" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round" stroke-dasharray="40 80"/><path d="${wave(144,5,2)}" fill="none" stroke="${hl(K.sky)}" stroke-width="3" stroke-linecap="round" stroke-dasharray="30 90"/>`;
 [[120,178],[330,92],[760,182],[940,96]].forEach(([x,y])=>b+=`<path d="${E(x,y,11,7)}" fill="${K.stone}" stroke="${O}" stroke-width="2.5"/>`);
 b+=[[70,70,top],[420,64,top],[990,62,top],[240,206,bot],[680,210,bot],[870,204,bot]].map(([x,y,c])=>tuft(x,y,1,x%2,sh(c))).join('');
 D.add(b);return D.svg()};
put('map_strip_farm_wheat',strip(BIO.wheat.g,BIO.farm.g));put('map_strip_wheat_lake',strip(BIO.lake.g,BIO.wheat.g));
put('map_bridge',doc(224,160,S,[{ds:[RR(34,26,10,110,3),RR(180,26,10,110,3)],fill:K.wood,r:3},{ds:[RP([[40,40],[184,40],[190,126],[34,126]],6)],fill:K.woodL,r:10,mark:[[50,64,78,92,106,120].map(y=>`<path d="M${f(40-(y-40)*.07)} ${y}H${f(184+(y-40)*.07)}" stroke="${sh(K.woodL)}" stroke-width="2.4"/>`).join('')]},{ds:[RR(26,30,12,104,4),RR(186,30,12,104,4)],fill:K.wood,r:4,hl:[29,36,1.4,8,0]},{ds:[E(32,28,6),E(192,28,6),E(32,136,6),E(192,136,6)],fill:K.wood,line:2.4,sh:false}]));
// облака 512×256
const CL=[[[256,140,120,78],[140,160,86,62],[372,160,88,62],[190,104,70,58],[322,100,76,62],[256,190,160,46]],[[210,148,110,72],[330,140,104,74],[112,170,74,54],[430,176,66,50],[268,96,82,66],[262,196,190,40]]];
CL.forEach((C,v)=>{const cl=(dx,k,sp)=>doc(512,256,S,[{ds:C.map(([x,y,rx,ry],i)=>{const a=Math.atan2(y-150,x-256),m=sp*(40+i*14);return E(x+Math.cos(a)*m+dx*(i%2?1:-1),y+Math.sin(a)*m*.6,rx*k,ry*k)}),fill:'#FFFFFF',r:40,hl:[180,96,26,10,-15]}]);
 add(`map_cloud_${v+1}_sway`,[cl(0,1,0),cl(4,1.02,0),cl(-3,.99,0)],512,256);
 add(`map_cloud_${v+1}_clear`,[cl(0,1.02,.1),cl(0,.9,.9),cl(0,.72,2),cl(0,.45,3.4),blank(512,256,S)],512,256);});
put('ui_harvest_ready',doc(96,96,s,[{ds:['M48 88L40 74H22Q10 74 10 62V22Q10 10 22 10H74Q86 10 86 22V62Q86 74 74 74H56Z'],fill:'#FFFFFF',r:14,hl:[24,16,10,2,0]}]));
return out}
