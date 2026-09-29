// Партия F: эффекты. После gen/anim/heroes/pests/defenders/env_*.
const CLOUD='#E8EEF8',DUST='#F2E3C4';
Object.assign(SH,{'#E8EEF8':'#C9D5E8','#F2E3C4':'#D9C49C'});
const burst=(cx,cy,R,r,n=8,rot=0)=>{const p=[];for(let i=0;i<n*2;i++){const a=rot*Math.PI/180+i*Math.PI/n,q=i%2?r:R;p.push([cx+Math.cos(a)*q,cy+Math.sin(a)*q])}return RP(p,Math.max(1,r*.18))};
function coinIt(cx,cy,R,sx=1,mark='ring'){sx=Math.max(.14,sx);const I=[{ds:[E(cx,cy+R*.2,R*sx,R)],fill:sh(K.coin),sh:false}];
 const m=sx<.3?'':mark==='star'?`<path d="${starD(cx,cy,R*.52*sx,R*.24*sx)}" fill="${sh(K.coin)}"/>`:`<path d="${E(cx,cy,R*.58*sx,R*.58)}" fill="none" stroke="${sh(K.coin)}" stroke-width="${f(R*.16)}"/>`;
 I.push({ds:[E(cx,cy,R*sx,R)],fill:K.coin,r:R,off:R*.18,hl:sx<.3?undefined:[cx-R*.36*sx,cy-R*.42,R*.28*sx,R*.17,-35],mark:[m]});return I}
const doc=(w,h,S,items,tf)=>{const D=Doc(w,h,S,tf);render(D,items);return D.svg()};
const puffs=(L,c=DUST,line=1.8)=>({ds:L.map(([x,y,r])=>E(x,y,r)),fill:c,line,sh:false});
function crateIt(cx,by,k=1,lid=0,lidRot=0){const w=40*k,h=32*k,x=cx-w/2,y=by-h,I=[];
 I.push({ds:[RR(x,y,w,h,4*k)],fill:K.woodL,r:8,mark:[`<path d="M${f(x)} ${f(y+h*.5)}H${f(x+w)}" stroke="${sh(K.woodL)}" stroke-width="2.4"/><path d="M${f(cx-4*k)} ${f(y)}V${f(by)}H${f(cx+4*k)}V${f(y)}Z" fill="${K.ui}"/>`]});
 const T=`rotate(${lidRot} ${f(cx)} ${f(y-lid)})`;
 I.push({tf:T,ds:[RR(x-3*k,y-7*k-lid,w+6*k,9*k,3*k)],fill:K.wood,r:4,mark:[`<path d="M${f(cx-4*k)} ${f(y-8*k-lid)}V${f(y+3*k-lid)}H${f(cx+4*k)}V${f(y-8*k-lid)}Z" fill="${sh(K.ui)}"/>`]});
 return I}
function chuteIt(cx,top,k=1,sq=1){const w=34*k*sq,h=18*k/sq,I=[];
 I.push({limb:`M${f(cx-w+2)} ${f(top+h)}L${f(cx-18*k)} ${f(top+h+26*k)}M${f(cx+w-2)} ${f(top+h)}L${f(cx+18*k)} ${f(top+h+26*k)}M${f(cx)} ${f(top+h)}L${f(cx)} ${f(top+h+26*k)}`,w:1.4,fill:K.panel,line:1.2});
 I.push({ds:[`M${f(cx-w)} ${f(top+h)}Q${f(cx-w)} ${f(top)} ${f(cx)} ${f(top)}Q${f(cx+w)} ${f(top)} ${f(cx+w)} ${f(top+h)}Q${f(cx+w*.5)} ${f(top+h-4*k)} ${f(cx)} ${f(top+h)}Q${f(cx-w*.5)} ${f(top+h-4*k)} ${f(cx-w)} ${f(top+h)}Z`],fill:K.ui,r:10,hl:[cx-w*.5,top+h*.35,w*.2,h*.18,-20],mark:[`<path d="M${f(cx-w*.34)} ${f(top-2)}L${f(cx-w*.22)} ${f(top+h+2)}L${f(cx+w*.22)} ${f(top+h+2)}L${f(cx+w*.34)} ${f(top-2)}Z" fill="${K.panel}"/>`]});
 return I}
function tractor(S,fi){const a=fi*22.5,by=fi%2?-1:0,T=`translate(0 ${by})`,spk=(x,y,r)=>[0,60,120].map(d=>{const q=(d+a)*Math.PI/180;return `<path d="M${f(x-Math.cos(q)*r)} ${f(y-Math.sin(q)*r)}L${f(x+Math.cos(q)*r)} ${f(y+Math.sin(q)*r)}" stroke="${sh(K.coin)}" stroke-width="3"/>`}).join('');
 const pf=[[[34,44,5]],[[30,38,6],[36,48,4]],[[26,30,7],[33,42,5]],[[22,22,8],[30,36,6]]][fi];
 return doc(160,160,S,[puffs(pf.map(([x,y,r])=>[x+14,y+20,r]),'#DDE2EA'),
  {tf:T,ds:[RR(44,72,12,24,3)],fill:'#474B5C',sh:false},
  {tf:T,ds:[RR(46,82,90,36,10)],fill:K.red,r:14,hl:[70,88,14,3,0],mark:[`<path d="M106 82V118" stroke="${sh(K.red)}" stroke-width="3"/><path d="${RR(118,90,14,6,2)}" fill="${K.coin}"/>`]},
  {tf:T,ds:[RR(40,46,50,44,8)],fill:K.red,r:12,mark:[`<path d="${RR(48,52,34,24,5)}" fill="${K.sky}"/><path d="M52 70L64 56" stroke="${hl(K.sky)}" stroke-width="4" stroke-linecap="round"/>`]},
  {tf:T,ds:[RR(34,40,62,10,5)],fill:sh(K.red),sh:false},
  {ds:[E(64,120,26)],fill:'#3B3F4E',r:10,mark:[`<path d="${E(64,120,14)}" fill="${K.coin}"/>`,spk(64,120,13)]},{ds:[E(64,120,5)],fill:sh(K.coin),sh:false},
  {ds:[E(124,128,17)],fill:'#3B3F4E',r:8,mark:[`<path d="${E(124,128,8.5)}" fill="${K.coin}"/>`,spk(124,128,8)]},{ds:[E(124,128,3.5)],fill:sh(K.coin),sh:false}])}
function sleepyCloud(S,fi){const by=[0,2,3,1][fi],drops=[];for(let i=0;i<9;i++){const x=58+i*18+(i%2)*6,y=150+((fi*22+i*37)%92);drops.push(`M${f(x)} ${f(y-9)}Q${f(x+5)} ${f(y+1)} ${f(x)} ${f(y+5)}Q${f(x-5)} ${f(y+1)} ${f(x)} ${f(y-9)}Z`)}
 const T=`translate(0 ${by})`,eye=x=>`<path d="M${x-9} 118Q${x} 126 ${x+9} 118" fill="none" stroke="${O}" stroke-width="4" stroke-linecap="round"/>`;
 return doc(256,256,S,[{ds:drops,fill:K.sky,line:2.4,sh:false},
  {tf:T,ds:[E(128,110,52,40),E(78,122,34,28),E(178,122,34,28),E(104,86,30),E(156,90,28),E(128,136,60,20)],fill:CLOUD,r:30,hl:[96,82,12,6,-25]},
  {raw:`<g transform="${T}">${eye(110)}${eye(146)}<path d="${E(100,132,7,4)}" fill="${K.pink}"/><path d="${E(156,132,7,4)}" fill="${K.pink}"/><path d="M122 140Q128 144 134 140" fill="none" stroke="${O}" stroke-width="3" stroke-linecap="round"/></g>`},
  {tf:T,ds:[`M150 62Q168 34 196 44Q182 52 180 72Z`],fill:K.denim,r:6},{tf:T,ds:[E(198,44,6)],fill:K.panel,sh:false}])}
function magnetAura(S,fi){let s='';[0,1,2,3].forEach(i=>{const r=120-((i*30+fi*7.5)%120);if(r<24)return;s+=`<circle cx="128" cy="128" r="${f(r)}" fill="none" stroke="${K.red}" stroke-width="${f(2+r/30)}" stroke-dasharray="${f(r*.5)} ${f(r*.3)}" transform="rotate(${fi*20+i*33} 128 128)"/>`});
 const D=Doc(256,256,S);D.add(s);const I=[];[0,1,2,3,4,5].forEach(i=>{const a=(i*60+fi*15)*Math.PI/180,r=112-((fi*22+i*18)%80);I.push({ds:[spk(128+Math.cos(a)*r,128+Math.sin(a)*r,5)],fill:'#FFF0B0',line:2,sh:false})});render(D,I);return D.svg()}
function confetti(S,fi){if(fi===5)return blank(256,256,S);const D=Doc(256,256,S),t=(fi+1)/5,C=[K.ui,K.coin,K.sky,K.red,K.sprout,K.pink],I=[];
 for(let i=0;i<26;i++){const s1=(i*7919%1000)/1000,s2=(i*104729%1000)/1000,vx=(s1-.5)*260,vy=-260-s2*120,x=128+vx*t,y=236+vy*t+330*t*t;if(y>250||x<8||x>248)continue;
  const rot=i*47+fi*60,k=1.9-(fi>3?.5:0);I.push({ds:[i%3?`M${f(x-5*k)} ${f(y-3*k)}h${f(10*k)}v${f(6*k)}h${f(-10*k)}Z`:E(x,y,4*k)],fill:C[i%6],line:1.8,sh:false,tf:`rotate(${rot} ${f(x)} ${f(y)})`})}
 render(D,I);return D.svg()}
function fxSheets(){const S=STY.a,s=small(S),out={},p='assets/f/',add=(n,fr,w,h)=>out[p+`${n}_${fr.length}f.svg`]=sheet(fr,w,h||w);
 add('fx_poof',[.35,.7,1,1.05,.6].map((k,i)=>i===4?doc(64,64,s,[puffs([[20,36,5],[44,30,4],[34,48,3.5]],'#FFF4DC')]):poofSvg(s,64,64,32,36,16*k)),64);
 add('fx_stars_head',[0,1,2,3].map(ph=>doc(48,48,s,starsRing(24,24,17,6,5,ph,''))),48);
 add('fx_hit',[doc(48,48,s,[{ds:[burst(24,24,11,5,6)],fill:'#FFFFFF',line:2.2,sh:false}]),doc(48,48,s,[{ds:[burst(24,24,21,9,8,10)],fill:'#FFF0B0',line:2.6,sh:false},{ds:[burst(24,24,11,5,6,30)],fill:'#FFFFFF',line:0,sh:false}]),doc(48,48,s,[{ds:[[6,10],[40,8],[42,40],[8,38]].map(([x,y])=>spk(x,y,4)),fill:'#FFF0B0',line:2,sh:false}])],48);
 const drop=(x,y,r)=>`M${f(x)} ${f(y-r*1.5)}Q${f(x+r)} ${f(y)} ${f(x)} ${f(y+r)}Q${f(x-r)} ${f(y)} ${f(x)} ${f(y-r*1.5)}Z`;
 add('fx_splash',[[[32,44,4],[24,46,3],[40,46,3]],[[32,30,4],[20,36,3.5],[44,36,3.5],[14,46,2.5],[50,46,2.5]],[[32,18,3.5],[14,26,3],[50,26,3],[8,40,2.5],[56,40,2.5]],[[32,24,2.5],[12,40,2.2],[52,40,2.2]]].map((Q,i)=>doc(64,64,s,[{ds:[E(32,54,8+i*5,2.5+i)],fill:K.sky,line:2,sh:false},{ds:Q.map(([x,y,r])=>drop(x,y,r)),fill:K.sky,line:2,sh:false}])),64);
 add('fx_tomato_burst',[doc(96,96,s,[{ds:[E(48,62,15,9)],fill:K.red,r:8,hl:[42,58,4,2,-20]},{ds:[burst(48,54,7,3,5)],fill:K.sprout,line:2,sh:false}]),
  doc(96,96,s,[{ds:[burst(48,56,26,14,9)],fill:K.red,line:2.8,sh:false},{ds:[E(48,56,10)],fill:'#F59287',line:0,sh:false}]),
  doc(96,96,s,[{ds:[burst(48,58,36,20,10,12)],fill:K.red,line:3,sh:false},{ds:[[40,50],[56,54],[46,66],[60,64],[36,62]].map(([x,y])=>ER(x,y,2.2,1.4,30)),fill:K.coin,line:1.4,sh:false},{ds:[E(14,30,5),E(84,26,4.5),E(20,78,4)],fill:K.red,line:2.2,sh:false}]),
  doc(96,96,s,[{ds:[blob([[20,70],[30,60],[48,62],[68,58],[78,70],[60,78],[34,78]])],fill:K.red,r:6,sh:false},{ds:[E(10,44,4),E(88,40,3.6),E(16,86,3.4),E(80,84,3)],fill:K.red,line:2,sh:false}]),
  doc(96,96,s,[{ds:[E(36,72,5,2.5),E(58,74,4,2),E(48,70,3,1.6)],fill:K.red,line:1.8,sh:false}])],96);
 add('fx_bee',[0,1.6].map(w=>doc(16,16,s,beeSmall(7,10.5,w))),16);
 add('fx_coin_pop',[doc(32,32,s,[...coinIt(16,14,6),{ds:[spk(25,7,3)],fill:'#FFF0B0',line:1.6,sh:false}]),doc(32,32,s,coinIt(16,11,10)),doc(32,32,s,coinIt(16,19,10),'translate(16 27) scale(1.15 .85) translate(-16 -27)'),doc(32,32,s,coinIt(16,17,10))],32);
 const SX=[1,.87,.5,.14,.5,.87];
 add('fx_coin_spin',SX.map(k=>doc(32,32,s,coinIt(16,15,11,k))),32);
 add('fx_coin5_spin',SX.map(k=>doc(48,48,s,coinIt(24,23,17,k,'star'))),48);
 add('fx_coin_trail',[0,1,2].map(fi=>doc(32,32,s,[{ds:[0,1,2].map(i=>{const q=(i*3+fi)%3;return spk(8+i*8,26-q*8-i*2,2+q*.8)}),fill:'#FFF0B0',line:1.5,sh:false},...coinIt(24,8+fi,5)])),32);
 add('fx_build_flash',[.35,.8,1.05,1,.6].map((k,i)=>doc(128,128,S,i<3?[{ds:[burst(64,72,54*k,26*k,10,i*9)],fill:'#FFF0B0',line:3,sh:false},{ds:[E(64,72,20*k)],fill:'#FFFFFF',line:0,sh:false}]:[{ds:[[18,40],[108,34],[96,104],[28,100],[64,20]].map(([x,y])=>spk(x,y,i===3?8:5)),fill:'#FFF0B0',line:2.2,sh:false}])),128);
 add('fx_upgrade',[0,1,2,3,4].map(fi=>doc(128,128,S,fi<4?[{ds:[E(64,112,40-fi*4,10-fi)],fill:'#FFF0B0',line:2.4,sh:false},{ds:[[34,0],[64,1],[94,2],[48,3],[80,4]].map(([x,d])=>starD(x,104-((fi*22+d*14)%90),7-d*.4,3.2)),fill:K.coin,line:2.2,sh:false}]:[{ds:[[40,20],[88,30],[64,12]].map(([x,y])=>spk(x,y,5)),fill:'#FFF0B0',line:2,sh:false}])),128);
 add('fx_dust',[[[10,26,3],[20,27,2.5]],[[8,24,4.5],[20,25,4],[27,27,2.5]],[[6,21,5],[18,22,5],[28,24,3]],[[5,19,3],[17,20,3.2]]].map(L=>doc(32,32,s,[puffs(L)])),32);
 add('fx_parcel_fall',[-6,-2,6,2].map(r=>doc(96,96,S,[...chuteIt(48,4,1),...crateIt(48,86,.9)],`rotate(${r} 48 6)`)),96);
 add('fx_parcel_land',[doc(96,96,S,[...chuteIt(62,50,.8,1.3),...crateIt(48,90,.9)],'translate(48 90) scale(1.08 .88) translate(-48 -90)'),doc(96,96,S,[puffs([[20,88,6],[76,88,6],[12,82,4],[84,82,4]]),...crateIt(48,88,.9)]),doc(96,96,S,crateIt(48,88,.9))],96);
 add('fx_parcel_glow',[0,1,2,3].map(fi=>doc(96,96,S,[{ds:[burst(48,62,44-fi%2*4,20,8,fi*11)],fill:'#FFF0B0',line:0,sh:false},...crateIt(48,88,.9),{ds:[spk(22+fi*6,24,4),spk(76-fi*4,30,3.5)],fill:'#FFFFFF',line:2,sh:false}])),96);
 add('fx_parcel_open',[doc(96,96,S,crateIt(48,88,.9,2,-6)),doc(96,96,S,crateIt(48,88,.9,12,10)),doc(96,96,S,[{ds:[burst(48,58,40,18,9)],fill:'#FFF0B0',line:2.6,sh:false},...crateIt(48,88,.9,34,40)]),comb(96,96,[poofSvg(S,96,96,48,66,26),doc(96,96,S,[{ds:[spk(16,20,6),spk(80,16,5),spk(84,70,4)],fill:'#FFF0B0',line:2,sh:false}])]),blank(96,96,S)],96);
 add('fx_tractor',[0,1,2,3].map(i=>tractor(S,i)),160);
 add('fx_sleepy_cloud',[0,1,2,3].map(i=>sleepyCloud(S,i)),256);
 add('fx_gold_rain_coin',[1,.5,.14,.5].map((k,i)=>doc(32,32,s,[{limb:`M16 ${2+i} V${8+i}`,w:2,fill:'#FFF0B0',line:1},...coinIt(16,19,9,k)])),32);
 add('fx_magnet_aura',[0,1,2,3].map(i=>magnetAura(S,i)),256);
 add('fx_confetti',[0,1,2,3,4,5].map(i=>confetti(S,i)),256);
 return out}
