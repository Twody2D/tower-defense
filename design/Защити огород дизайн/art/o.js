// Партия O: улей в бою, соты, иконка магазина, значок «выключено». После harvest.js.
function hiveBattle(P){const I=[],lid=P.lid||0,hn=P.honey||0,LT=`rotate(${-lid} 48 80)`;
 I.push({ds:[E(96,178,58,9)],fill:K.soil,line:2.2,sh:false});
 I.push({ds:[RR(58,160,9,18,3),RR(125,160,9,18,3)],fill:K.wood,sh:false});
 I.push({ds:[RR(50,118,92,46,7)],fill:K.panel,r:8,mark:[`<path d="M50 141H142" stroke="#EAD6AE" stroke-width="3"/>`]});
 I.push({ds:[RR(54,76,84,46,7)],fill:K.panel,r:8,mark:[`<path d="M54 99H138" stroke="#EAD6AE" stroke-width="3"/>`]});
 if(lid>2)I.push({ds:[RR(62,70,68,12,4)],fill:HONEY,line:2.4,sh:false,mark:[[70,82,94,106,118].map(x=>`<path d="${RP([[x-4,76],[x,73],[x+4,76],[x+4,80],[x,83],[x-4,80]],.5)}" fill="none" stroke="${sh(HONEY)}" stroke-width="1.3"/>`).join('')]});
 I.push({tf:LT,ds:[RR(44,62,104,16,6)],fill:K.red,r:6,hl:[64,66,14,1.8,0]},{tf:LT,ds:[RR(88,56,16,8,3)],fill:K.wood,sh:false});
 I.push({ds:[RR(80,150,32,8,4)],fill:'#3B2A22',line:2,sh:false});
 if(hn>0){const k=hn;I.push({ds:[`M52 ${119}Q54 ${126+8*k} 57 ${128+10*k}Q61 ${126+8*k} 62 119Z`,`M126 121Q128 ${128+6*k} 131 ${130+8*k}Q135 ${128+6*k} 136 121Z`,`M88 157Q90 ${162+4*k} 94 ${164+6*k}Q98 ${162+4*k} 100 157Z`],fill:HONEY,line:2,sh:false})}
 (P.drops||[]).forEach(([x,y])=>I.push({ds:[`M${x} ${y-7}Q${x+6} ${y+1} ${x} ${y+5}Q${x-6} ${y+1} ${x} ${y-7}Z`],fill:HONEY,line:2,sh:false}));
 (P.bees||[]).forEach(([x,y,w])=>I.push(...beeSmall(x,y,w).map(o=>({...o,tf:`translate(${x} ${y}) scale(1.5) translate(${-x} ${-y})`}))));
 if(P.glint!=null&&hn>1)I.push(sparkIt([[[60,132,5],[132,134,5],[96,170,4.5]][P.glint%3]]));
 return I}
function hiveSvg(S,P){const D=Doc(160,160,S,'scale(.8333333)');render(D,hiveBattle(P));return D.svg()}
const combIt=(x,y,k)=>{const hx=(cx,cy)=>RP([[cx-6*k,cy-3.4*k],[cx,cy-7*k],[cx+6*k,cy-3.4*k],[cx+6*k,cy+3.4*k],[cx,cy+7*k],[cx-6*k,cy+3.4*k]],1.2*k);return [{ds:[hx(x-6*k,y),hx(x+6*k,y),hx(x,y-10.4*k)],fill:HONEY,r:4,line:2.2,mark:[`<path d="${E(x-6*k,y,2.4*k,2*k)}" fill="${sh(HONEY)}"/><path d="${E(x+6*k,y,2.4*k,2*k)}" fill="${sh(HONEY)}"/><path d="${E(x,y-10.4*k,2.4*k,2*k)}" fill="${sh(HONEY)}"/>`]}]};
function oSheets(){const S=STY.a,s=small(S),out={},po='assets/o/',add=(n,fr,w,h)=>out[po+`${n}_${fr.length}f.svg`]=sheet(fr,w,h||w),put=(n,v)=>out[po+n+'.svg']=v;
 const bz=i=>[0,1,2].map(j=>{const a=(i*120+j*120)*Math.PI/180;return [96+Math.cos(a)*62,86+Math.sin(a)*30,(i+j)%2]});
 const full=[0,1,2].map(i=>hiveSvg(S,{honey:2,bees:bz(i),glint:i}));
 add('battle_hive_full',full,160);
 add('battle_hive_collect',[hiveSvg(S,{honey:2,lid:8,bees:bz(0)}),hiveSvg(S,{honey:2,lid:22,drops:[[40,130],[150,128]],bees:bz(1)}),hiveSvg(S,{honey:1,lid:14,drops:[[34,158],[156,156],[96,186]]}),hiveSvg(S,{honey:0,lid:0,bees:[[150,70,0]]})],160);
 put('battle_hive_empty',hiveSvg(S,{honey:0}));
 add('battle_hive_regrow',[hiveSvg(S,{honey:.5,bees:[[40,80,0]]}),hiveSvg(S,{honey:1.2,bees:[[40,80,0],[150,90,1]]})],160);
 add('battle_hive_highlight',[[5,.95],[8,.75],[6.5,.85]].map(([R,op])=>glowSvg(160,160,hiveSvg(S,{honey:2}),R,op)),160);
 add('battle_fruit_honeycomb_fall',[doc(48,48,s,[{limb:'M17 3V11M31 1V9',w:2.2,fill:'#FFFFFF',line:1.2},...combIt(24,26,1.3)]),doc(48,48,s,[puffs([[11,41,3.5],[37,41,3.5]]),...combIt(24,36,1.3)],'translate(24 44) scale(1.18 .8) translate(-24 -44)'),doc(48,48,s,[puffs([[16,28,8],[32,28,8],[24,20,8],[24,34,7]],'#FFF4DC'),...coinIt(24,27,8,1),sparkIt([[40,11,4]])])],48);
 const stall=k=>{const I=[],q=v=>v*k,sc=[0,1,2,3,4].map(i=>q(8+i*9.6));
  I.push({ds:[RR(q(10),q(22),q(5),q(34),q(2)),RR(q(49),q(22),q(5),q(34),q(2))],fill:K.wood,sh:false});
  I.push({ds:[RR(q(6),q(40),q(52),q(16),q(4))],fill:K.woodL,r:6,mark:[`<path d="M${q(6)} ${q(47)}H${q(58)}" stroke="${sh(K.woodL)}" stroke-width="${f(2*k/2)}"/>`]});
  I.push(...appleF(q(18),q(36),.55*k),...pumpF(q(46),q(35),.5*k),...coinIt(q(32),q(34),6*k,1));
  I.push({ds:[`M${q(4)} ${q(12)}Q${q(32)} ${q(2)} ${q(60)} ${q(12)}V${q(20)}`+sc.map(x=>`Q${f(x+q(4.8))} ${q(28)} ${f(x+q(9.6))} ${q(20)}`).join('').replace(/^/,'')+`L${q(4)} ${q(20)}Z`],fill:K.red,r:8,hl:[q(16),q(9),q(5),q(1.6),-8],mark:[[1,3].map(i=>`<path d="M${f(sc[i])} ${q(8)}L${f(sc[i])} ${q(20)}Q${f(sc[i]+q(4.8))} ${q(28)} ${f(sc[i]+q(9.6))} ${q(20)}L${f(sc[i]+q(9.6))} ${q(7)}Z" fill="#FFFFFF"/>`).join('')]});
  return I};
 put('ui_icon_shop_v2',doc(64,64,s,stall(1)));put('ui_icon_shop_v2_128',doc(128,128,S,stall(2)));
 put('ui_icon_off_slash',`<svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" viewBox="0 0 64 64"><path d="M12 52L52 12" stroke="${O}" stroke-width="13" stroke-linecap="round"/><path d="M12 52L52 12" stroke="#F0584A" stroke-width="7" stroke-linecap="round"/></svg>`);
 return out}
