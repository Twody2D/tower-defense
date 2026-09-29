// Партия G: UI-кит. После gen/anim/heroes/pests/defenders/env_*/fx.
function uiSheets(){
const S=STY.a,s=small(S),out={},p='assets/g/';
const put=(n,v)=>out[p+n+'.svg']=v,add=(n,fr,w,h)=>out[p+`${n}_${fr.length}f.svg`]=sheet(fr,w,h||w);
const svg=(w,h,b)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${b}</svg>`;
const C={orange:[K.ui,'#E0662A','#FFB27A'],green:['#72C83E','#4F9E2A','#A8E47C'],blue:['#4FB0F0','#2F86C9','#9AD6FF'],ad:['#F25C9E','#C93F7C','#FF9CC8'],red:['#F0584A','#C23B30','#FF9A8F'],cream:['#FFF4DC','#E3C999','#FFFFFF'],grey:['#B9B6C2','#8F8C9A','#DAD8E0']};
const SKIN='#FFD9B8',NAVY='#3F3D55',WELL='#4A4858';
const addMap=(M,m)=>{for(const k in m)if(!(k in M))M[k]=m[k]};
addMap(SH,{'#72C83E':'#4F9E2A','#4FB0F0':'#2F86C9','#F25C9E':'#C93F7C','#F0584A':'#C23B30','#FFD9B8':'#F2B98F','#D9C6A5':'#BFA985','#FFFFFF':'#E6E9F2'});
addMap(HL,{'#72C83E':'#A8E47C','#4FB0F0':'#9AD6FF','#F25C9E':'#FF9CC8','#F0584A':'#FF9A8F','#FFD9B8':'#FFF0E0','#D9C6A5':'#E9DCC4'});
const ST=['normal','pressed','disabled'];
// ---------- кнопки ----------
function bRect(w,h,c,st,r=32){const [a,b,hc]=st==='disabled'?C.grey:c,dn=st==='pressed'?8:0,lip=st==='pressed'?6:12,oy=2+dn,oh=h-4-dn,fh=oh-lip;
 return {cy:oy+2+(fh-2)/2,b:`<path d="${RR(2,oy,w-4,oh,r)}" fill="${b}" stroke="${O}" stroke-width="4"/><path d="${RR(4,oy+2,w-8,fh-2,r-2)}" fill="${a}"/><path d="${RR(26,oy+7,w-52,5,2.5)}" fill="${hc}"/>`}}
function bRound(d,c,st){const [a,b,hc]=st==='disabled'?C.grey:c,dn=st==='pressed'?4:0,W=d-16,R=W/2,cx=d/2,cy=4+dn+R;
 return {cy,b:`<path d="${RR(8,4+dn,W,W+8-dn,R)}" fill="${b}" stroke="${O}" stroke-width="4"/><path d="${E(cx,cy,R-2)}" fill="${a}"/><path d="M${f(cx-R*.62)} ${f(cy-R*.36)}A${f(R*.72)} ${f(R*.72)} 0 0 1 ${f(cx-R*.25)} ${f(cy-R*.68)}" fill="none" stroke="${hc}" stroke-width="5" stroke-linecap="round"/>`}}
for(const nm of ['orange','green','blue'])ST.forEach(st=>put(`ui_btn_${nm}_${st}`,svg(192,112,bRect(192,112,C[nm],st).b)));
const vid=(cy,dis)=>`<path d="${RR(22,cy-15,44,30,8)}" fill="#FFFFFF" stroke="${O}" stroke-width="3"/><path d="${RP([[38,cy-8],[52,cy],[38,cy+8]],2)}" fill="${dis?C.grey[1]:C.ad[0]}"/>`;
ST.forEach(st=>{const q=bRect(256,112,C.ad,st);put(`ui_btn_ad_${st}`,svg(256,112,q.b+vid(q.cy,st==='disabled')))});
add('ui_btn_ad_glint',[80,140,200,-1].map((x,i)=>svg(256,112,x<0?'':`<defs><clipPath id="adg${i}"><path d="${RR(4,4,248,94,30)}"/></clipPath></defs><g clip-path="url(#adg${i})"><path d="M${x} 4h26l-34 96h-26z" fill="#FFFFFF" fill-opacity=".55"/><path d="M${x+34} 4h8l-34 96h-8z" fill="#FFFFFF" fill-opacity=".55"/></g>`)),256,112);
ST.forEach(st=>{const col=st==='disabled'?'#EDEBF0':'#FFFFFF';
 put(`ui_btn_round_${st}`,svg(96,96,bRound(96,C.cream,st).b));
 const q=bRound(80,C.red,st),X=`M29 ${q.cy-11}L51 ${q.cy+11}M51 ${q.cy-11}L29 ${q.cy+11}`;
 put(`ui_btn_close_${st}`,svg(80,80,q.b+`<path d="${X}" stroke="${O}" stroke-width="15" stroke-linecap="round"/><path d="${X}" stroke="${col}" stroke-width="8" stroke-linecap="round"/>`));
 const r=bRect(96,96,C.blue,st,26),y=r.cy,ar=[[24,y],[46,y-19],[46,y-8],[70,y-8],[70,y+8],[46,y+8],[46,y+19]];
 put(`ui_btn_back_${st}`,svg(96,96,r.b+`<path d="${RP(ar,2)}" fill="${col}" stroke="${O}" stroke-width="5" stroke-linejoin="round"/>`));});
// ---------- панели ----------
put('ui_panel_main',svg(192,192,`<path d="${RR(2,2,188,188,32)}" fill="${K.wood}" stroke="${O}" stroke-width="4"/><path d="${RR(26,7,140,5,2.5)}" fill="${K.woodL}"/><path d="${RR(18,18,156,156,18)}" fill="${K.panel}" stroke="${O}" stroke-width="3"/><path d="${RR(24,22,144,10,5)}" fill="#F3E3BF"/>`+[[16,16],[176,16],[16,176],[176,176]].map(([x,y])=>`<circle cx="${x}" cy="${y}" r="4" fill="${K.woodL}" stroke="${O}" stroke-width="2"/>`).join('')));
put('ui_card',svg(128,128,`<path d="${RR(2,2,124,124,24)}" fill="#E8D2A6" stroke="${O}" stroke-width="3"/><path d="${RR(3.5,3.5,121,112,22.5)}" fill="#FFFBF0"/>`));
put('ui_ribbon',svg(384,112,`<path d="${RP([[4,44],[84,44],[84,100],[4,100],[22,72]],3)}" fill="#E0662A" stroke="${O}" stroke-width="4" stroke-linejoin="round"/><path d="${RP([[380,44],[300,44],[300,100],[380,100],[362,72]],3)}" fill="#E0662A" stroke="${O}" stroke-width="4" stroke-linejoin="round"/><path d="M62 78H84V100Z" fill="#A9481C" stroke="${O}" stroke-width="3" stroke-linejoin="round"/><path d="M322 78H300V100Z" fill="#A9481C" stroke="${O}" stroke-width="3" stroke-linejoin="round"/><path d="${RR(60,8,264,74,12)}" fill="#E0662A" stroke="${O}" stroke-width="4"/><path d="${RR(62,10,260,62,10)}" fill="${K.ui}"/><path d="${RR(78,16,228,6,3)}" fill="#FFB27A"/>`));
put('ui_dim',svg(16,16,`<rect width="16" height="16" fill="${O}" fill-opacity=".6"/>`));
// ---------- элементы ----------
const trk=(a,b)=>svg(128,64,`<path d="${RR(2,2,124,60,30)}" fill="${a}" stroke="${O}" stroke-width="4"/><path d="${RR(16,7,96,8,4)}" fill="${b}"/>`);
put('ui_toggle_track_on',trk(C.green[0],C.green[1]));put('ui_toggle_track_off',trk(C.grey[0],C.grey[1]));
const knob=svg(56,56,`<path d="${RR(4,3,48,50,24)}" fill="${C.cream[1]}" stroke="${O}" stroke-width="4"/><path d="${E(28,27,22)}" fill="${C.cream[0]}"/><path d="M15 22A15 15 0 0 1 24 12" fill="none" stroke="#FFFFFF" stroke-width="4" stroke-linecap="round"/>`);
put('ui_toggle_knob',knob);put('ui_slider_knob',knob);
put('ui_slider_track',svg(256,40,`<path d="${RR(2,6,252,28,14)}" fill="${WELL}" stroke="${O}" stroke-width="4"/><path d="${RR(16,10,224,5,2.5)}" fill="#3A3848"/>`));
put('ui_slider_fill',svg(256,40,`<path d="${RR(2,6,252,28,14)}" fill="${K.ui}" stroke="${O}" stroke-width="4"/><path d="${RR(16,11,224,5,2.5)}" fill="#FFB27A"/>`));
put('ui_tab_active',svg(192,88,`<path d="${RR(2,4,188,92,[24,24,0,0])}" fill="${K.panel}" stroke="${O}" stroke-width="4"/><path d="${RR(28,11,136,5,2.5)}" fill="#FFFFFF"/>`));
put('ui_tab_inactive',svg(192,88,`<path d="${RR(2,16,188,80,[22,22,0,0])}" fill="#E3C999" stroke="${O}" stroke-width="4"/><path d="${RR(28,23,136,5,2.5)}" fill="#F3E3C4"/><path d="M4 78H188V88H4Z" fill="#CDB080"/>`));
put('ui_progress_frame',svg(256,48,`<path d="${RR(2,2,252,44,22)}" fill="${WELL}" stroke="${O}" stroke-width="4"/><path d="${RR(18,7,220,5,2.5)}" fill="#3A3848"/>`));
put('ui_progress_fill',svg(240,32,`<path d="${RR(0,0,240,32,16)}" fill="${C.green[1]}"/><path d="${RR(0,0,240,25,[16,16,12.5,12.5])}" fill="${C.green[0]}"/><path d="${RR(14,6,212,5,2.5)}" fill="${C.green[2]}"/>`));
put('ui_counter_plate',svg(192,64,`<path d="${RR(2,6,188,52,26)}" fill="${NAVY}" stroke="${O}" stroke-width="4"/><path d="${RR(36,12,120,5,2.5)}" fill="#5E5B78"/>`));
put('ui_badge_dot',svg(32,32,`<circle cx="16" cy="16" r="13" fill="#FFFFFF" stroke="${O}" stroke-width="3"/><circle cx="16" cy="16" r="9" fill="${C.red[0]}"/><path d="${ER(12.5,12.5,3,1.8,-40)}" fill="${C.red[2]}"/>`));
put('ui_toast',svg(384,80,`<path d="${RR(2,2,380,76,38)}" fill="${NAVY}" stroke="${O}" stroke-width="4"/><path d="${RR(40,9,304,5,2.5)}" fill="#5E5B78"/>`));
put('ui_bubble',svg(256,144,`<path d="${RR(2,2,252,140,28)}" fill="#FFFFFF" stroke="${O}" stroke-width="4"/><path d="${RR(4,118,248,22,[0,0,26,26])}" fill="#E8EEF8"/>`));
put('ui_bubble_tail',svg(48,40,`<path d="M2 0H46L42 3Q26 20 12 37Q15 22 6 3Z" fill="#E8EEF8"/><path d="M6 3Q15 22 12 37Q26 20 42 3" fill="none" stroke="${O}" stroke-width="4" stroke-linejoin="round" stroke-linecap="round"/>`));
put('ui_lock',doc(64,64,s,lockIt(32,34,1.9)));
const CK='M13 34L27 47L51 17';
put('ui_check',svg(64,64,`<path d="${CK}" fill="none" stroke="${O}" stroke-width="17" stroke-linecap="round" stroke-linejoin="round"/><path d="${CK}" fill="none" stroke="${C.green[0]}" stroke-width="9" stroke-linecap="round" stroke-linejoin="round"/>`));
const rstar=(cx,cy,R,rr=.5)=>{const q=[];for(let i=0;i<10;i++){const a=-Math.PI/2+i*Math.PI/5,v=i%2?R*rr:R;q.push([cx+Math.cos(a)*v,cy+Math.sin(a)*v])}return RP(q,R*.14)};
const starIt=(cx,cy,R,full,tf)=>({tf,ds:[rstar(cx,cy,R)],fill:full?K.coin:'#D9C6A5',r:R*.5,hl:full?[cx-R*.32,cy-R*.3,R*.14,R*.08,-35]:undefined});
[32,64,128].forEach(z=>{const St=z<128?s:S;put(`ui_star_full_${z}`,doc(z,z,St,[starIt(z/2,z*.53,z*.45,1)]));put(`ui_star_empty_${z}`,doc(z,z,St,[starIt(z/2,z*.53,z*.45,0)]))});
const SPK=L=>({ds:L.map(([x,y,z])=>spk(x,y,z)),fill:'#FFF0B0',line:2.2,sh:false});
const TS=k=>`translate(64 68) scale(${k}) translate(-64 -68)`;
add('ui_star_appear',[doc(128,128,S,[SPK([[64,68,14]]),starIt(64,68,56,1,TS(.35))]),doc(128,128,S,[{ds:[burst(64,68,62,34,10)],fill:'#FFF0B0',line:3,sh:false},starIt(64,68,56,1,TS(1.12))]),doc(128,128,S,[starIt(64,68,56,1,'translate(64 68) scale(1.06 .9) translate(-64 -68)'),SPK([[16,26,7],[112,30,6]])]),doc(128,128,S,[starIt(64,68,56,1,TS(1.03)),SPK([[10,52,5],[118,56,5],[64,8,6]])]),doc(128,128,S,[starIt(64,68,56,1)])],128);
// ---------- иконки 64 ----------
const ic=(n,items)=>put('ui_icon_'+n,doc(64,64,s,items));
ic('coin',coinIt(32,31,24,1));
ic('grain',[{limb:curve([[22,60],[27,40],[37,12]]),w:3,fill:'#D9A33C'},{ds:[ER(22,43,5,8.5,-35),ER(33,41,5,8.5,35),ER(25,31,5,8.5,-30),ER(36,29,5,8.5,40),ER(35,16,4.8,8.5,12)],fill:K.coin,r:5,hl:[33,12,1.4,3,10]},SPK([[51,14,6]])]);
ic('carrot',carrotFull(26,25,-35,2));
ic('star',[starIt(32,34,27,1)]);
ic('ad',[{ds:[RR(6,14,52,38,10)],fill:C.ad[0],r:10,hl:[16,20,6,2,0]},{ds:[RP([[26,23],[42,33],[26,43]],3)],fill:'#FFFFFF',line:2.5,sh:false}]);
ic('pause',[{ds:[RR(15,12,13,40,6),RR(36,12,13,40,6)],fill:C.blue[0],r:6,hl:[19,19,1.8,4,0]}]);
ic('play',[{ds:[RP([[20,11],[53,32],[20,53]],8)],fill:C.green[0],r:10,hl:[26,22,2.2,5,0]}]);
ic('restart',[{limb:'M45 23.1A17 17 0 1 1 26.2 18',w:9,fill:K.ui},{ds:[RP([[36,15],[28,26],[23,9.5]],2)],fill:K.ui,sh:false}]);
ic('home',[{ds:[RR(15,30,34,25,4)],fill:K.panel,r:6,mark:[`<path d="${RR(27,40,10,15,[5,5,0,0])}" fill="${K.wood}"/>`]},{ds:[RP([[7,34],[32,10],[57,34]],4)],fill:C.red[0],r:8,hl:[27,20,5,1.8,-40]}]);
const gear=[];for(let i=0;i<8;i++){const a=i*Math.PI/4,P=(r,d)=>[32+Math.cos(a+d)*r,32+Math.sin(a+d)*r];gear.push(P(18,-.36),P(25,-.2),P(25,.2),P(18,.36))}
ic('settings',[{ds:[RP(gear,2)],fill:K.stone,r:10,hl:[22,20,3,2,-30]},{ds:[E(32,32,8)],fill:K.panel,line:3,sh:false}]);
ic('music',[{limb:'M24 44V16L48 10V38',w:5,fill:C.blue[0]},{ds:[ER(19,45,8,6,-20),ER(43,39,8,6,-20)],fill:C.blue[0],r:5,hl:[16,43,2,1,-20]}]);
ic('sound',[{ds:[RP([[8,24],[18,24],[32,11],[32,53],[18,40],[8,40]],3)],fill:C.blue[0],r:6,hl:[12,28,1.4,3,0]},{limb:'M40 24Q46 32 40 40',w:4,fill:C.blue[0]},{limb:'M46 15Q59 32 46 49',w:4,fill:C.blue[0]}]);
ic('language',[{ds:[E(32,32,25)],fill:K.sky,r:14,hl:[21,19,5,3,-35],mark:[`<path d="${blob([[16,20],[27,15],[32,25],[25,33],[15,30]])}" fill="${K.sprout}"/><path d="${blob([[36,37],[47,32],[51,43],[41,52],[34,47]])}" fill="${K.sprout}"/><path d="${E(32,32,11,25)}" fill="none" stroke="${sh(K.sky)}" stroke-width="2.2"/><path d="M7 32H57" stroke="${sh(K.sky)}" stroke-width="2.2"/>`]}]);
ic('shop',[{limb:'M22 27V20Q22 10 32 10Q42 10 42 20V27',w:4.5,fill:K.wood},{ds:[RP([[11,24],[53,24],[49,57],[15,57]],6)],fill:K.ui,r:10,hl:[19,31,2.4,5,0],mark:[`<circle cx="32" cy="41" r="7.5" fill="${K.coin}" stroke="${O}" stroke-width="2.5"/>`]}]);
const giftIt=(lid=0)=>[{ds:[RR(12,30,40,25,5)],fill:C.red[0],r:8,mark:[`<path d="M28 30H36V55H28Z" fill="${K.coin}"/>`]},{ds:[RR(8,21-lid,48,12,5)],fill:C.red[0],r:4,hl:[18,24-lid,6,1.4,0],mark:[`<path d="M27 ${21-lid}H37V${33-lid}H27Z" fill="${K.coin}"/>`]},{ds:[ER(24,15-lid,8,5.5,-25),ER(40,15-lid,8,5.5,25)],fill:K.coin,r:4},{ds:[E(32,18-lid,4.5,4)],fill:K.coin,sh:false}];
ic('gift',giftIt());
ic('trophy',[{limb:'M18 16Q6 16 8 27Q10 36 20 36',w:4.5,fill:K.coin},{limb:'M46 16Q58 16 56 27Q54 36 44 36',w:4.5,fill:K.coin},{ds:[RR(27,40,10,10,2)],fill:K.coin,sh:false},{ds:['M15 8H49V22Q49 42 32 44Q15 42 15 22Z'],fill:K.coin,r:12,hl:[22,15,2.5,5,0],mark:[`<path d="${rstar(32,24,8)}" fill="${sh(K.coin)}"/>`]},{ds:[RR(20,48,24,7,3),RR(14,54,36,7,3)],fill:K.wood,r:3}]);
ic('damage',[{ds:[burst(32,32,28,15,8)],fill:C.red[0],r:12,hl:[21,21,3,2,-30]},{ds:[burst(32,32,14,8,6,20)],fill:K.coin,line:2.5,sh:false}]);
ic('attack_speed',[{ds:[RP([[37,4],[13,36],[29,36],[23,60],[51,25],[35,25],[43,4]],2)],fill:K.coin,r:8,hl:[31,15,1.8,4,30]}]);
ic('run_speed',[{limb:'M3 25H14',w:3.5,fill:'#FFFFFF'},{limb:'M2 35H12',w:3.5,fill:'#FFFFFF'},{limb:'M5 45H15',w:3.5,fill:'#FFFFFF'},{ds:['M20 20Q20 13 28 13H34Q39 13 39 19V26Q51 28 57 36Q61 42 59 46H20Z'],fill:C.red[0],r:10,hl:[26,19,2,3,0],mark:[`<path d="M40 28L36 34M46 30L42 36" stroke="#FFFFFF" stroke-width="2.4" stroke-linecap="round"/>`]},{ds:[RR(18,44,43,9,4.5)],fill:'#FFFFFF',r:3}]);
ic('magnet',[{limb:'M20 12V32A12 12 0 0 0 44 32V12',w:14,fill:C.red[0]},{ds:[RR(13,5,14,11,3),RR(37,5,14,11,3)],fill:K.stone,r:3}]);
const cloud=y=>({ds:[E(32,y,16,11),E(19,y+4,10,8),E(45,y+4,10,8),E(32,y+6,21,7)],fill:CLOUD,r:8,hl:[26,y-5,4,2,-20]});
ic('bonus_gold_rain',[...coinIt(17,47,7),...coinIt(33,54,7,.5),...coinIt(48,45,7),cloud(20)]);
ic('bonus_rage',[{ds:['M32 4C42 16 52 26 50 40C48 52 40 60 32 60C22 60 14 52 14 42C14 32 22 28 24 16C28 24 30 24 32 4Z'],fill:K.ui,r:12,hl:[21,40,2.5,5,-10]},{ds:['M32 28C38 34 42 40 40 48C38 54 34 57 32 57C28 57 24 53 24 47C24 41 28 38 32 28Z'],fill:K.coin,line:2.5,sh:false}]);
ic('bonus_super_magnet',[{tf:'rotate(35 24 38)',limb:'M18 16V32A12 12 0 0 0 42 32V16',w:13,fill:C.red[0]},{tf:'rotate(35 24 38)',ds:[RR(11,9,14,10,3),RR(35,9,14,10,3)],fill:K.stone,r:3},...coinIt(52,9,6),SPK([[10,20,5],[42,58,3.5]])]);
ic('bonus_upgrade',[{ds:[RP([[32,5],[57,31],[42,31],[42,58],[22,58],[22,31],[7,31]],4)],fill:C.green[0],r:10,hl:[30,15,2,4,0]},SPK([[55,10,5],[10,50,4]])]);
ic('bonus_tractor',[{ds:[RR(46,18,5,14,2)],fill:'#474B5C',sh:false},{ds:[RR(10,30,46,18,6)],fill:C.red[0],r:6},{ds:[RR(10,12,26,24,5)],fill:C.red[0],r:5,mark:[`<path d="${RR(14,16,18,12,3)}" fill="${K.sky}"/>`]},{ds:[E(23,48,11)],fill:'#3B3F4E',r:5,mark:[`<path d="${E(23,48,5)}" fill="${K.coin}"/>`]},{ds:[E(49,51,8)],fill:'#3B3F4E',r:4,mark:[`<path d="${E(49,51,3.5)}" fill="${K.coin}"/>`]}]);
const dropP=(x,y,r)=>`M${x} ${y-r*1.5}Q${x+r} ${y} ${x} ${y+r}Q${x-r} ${y} ${x} ${y-r*1.5}Z`;
ic('bonus_sleepy_rain',[{ds:[dropP(19,50,4),dropP(32,56,4),dropP(45,50,4)],fill:K.sky,line:2.2,sh:false},{...cloud(22),mark:[`<path d="M23 25Q26.5 29 30 25M34 25Q37.5 29 41 25" fill="none" stroke="${O}" stroke-width="2.4" stroke-linecap="round"/>`]}]);
ic('bonus_helper',[{ds:[E(15,27,6,7),E(25,18,6,7.5),E(39,18,6,7.5),E(49,27,6,7)],fill:K.wood,r:4},{ds:[blob([[18,44],[24,34],[32,32],[40,34],[46,44],[40,54],[24,54]])],fill:K.wood,r:10,hl:[26,38,3,2,-20]},{ds:[E(50,50,10)],fill:C.green[0],r:5,mark:[`<path d="M50 44.5V55.5M44.5 50H55.5" stroke="#FFFFFF" stroke-width="3.5" stroke-linecap="round"/>`]}]);
put('ui_bonus_timer_track',svg(64,64,`<circle cx="32" cy="32" r="28" fill="none" stroke="${O}" stroke-width="9"/><circle cx="32" cy="32" r="28" fill="none" stroke="${WELL}" stroke-width="4"/>`));
put('ui_bonus_timer_fill',svg(64,64,`<circle cx="32" cy="32" r="28" fill="none" stroke="${K.coin}" stroke-width="4"/>`));
add('ui_icon_gift_shake',[[-8,0,0],[0,3,1],[8,0,0],[0,3,1]].map(([r,l,sp])=>doc(64,64,s,[...giftIt(l),...(sp?[SPK([[8,12,5],[56,10,4]])]:[])],`rotate(${r} 32 56)`)),64);
const sprout=(x,dy)=>[{limb:`M${x} 46V${30+dy}`,w:2.5,fill:K.leaf},{ds:[ER(x-5,38,4.5,2.4,-30),ER(x+5,38,4.5,2.4,30)],fill:K.sprout,line:2,sh:false},{ds:[ER(x,24+dy,5.5,8.5,0)],fill:K.coin,r:5,hl:[x-2,20+dy,1.4,2.6,0]}];
add('ui_icon_harvest_ripe',[[0,[[52,12,5]]],[-3,[[12,14,5],[54,24,3.5]]],[-1,[[34,6,5]]]].map(([dy,sp])=>doc(64,64,s,[...sprout(18,dy+1),...sprout(32,dy),...sprout(46,dy+1),{ds:[RR(5,40,54,18,8)],fill:K.wood,r:6},{ds:[RR(10,43,44,8,4)],fill:K.soil,line:2,sh:false},SPK(sp)])),64);
// ---------- обучение ----------
const handIt=(x,y,k=1,rot=-18)=>{const T=`translate(${x} ${y}) rotate(${rot}) scale(${k})`;return [
 {tf:T,ds:[ER(-12,58,8,12,-30)],fill:SKIN,r:6},
 {tf:T,ds:[RR(-10,38,46,44,16)],fill:SKIN,r:14,hl:[2,50,3,6,0]},
 {tf:T,ds:[E(15,42,8,7),E(26,46,7.5,7),E(34,55,6.5,6.5)],fill:SKIN,r:5},
 {tf:T,ds:[RR(-8,0,16,54,8)],fill:SKIN,r:6,hl:[-3,9,1.8,4,0]},
 {tf:T,ds:[RR(-6,78,44,18,6)],fill:K.ui,r:5}]};
const ring=(x,y,rx,w1,w2)=>({raw:`<path d="${E(x,y,rx,rx*.5)}" fill="none" stroke="${O}" stroke-width="${w1}"/><path d="${E(x,y,rx,rx*.5)}" fill="none" stroke="#FFFFFF" stroke-width="${w2}"/>`});
add('ui_tut_hand_tap',[doc(128,128,S,handIt(46,14)),doc(128,128,S,handIt(46,21,.97)),doc(128,128,S,[ring(46,26,13,7,3.5),...handIt(46,22,.95)]),doc(128,128,S,[ring(46,26,24,5,2.5),...handIt(46,17)])],128);
const trail=(x0,x1,y,w1=11,w2=6)=>({raw:`<path d="M${x0} ${y}H${x1}" stroke="${O}" stroke-width="${w1}" stroke-linecap="round"/><path d="M${x0} ${y}H${x1}" stroke="#FFFFFF" stroke-width="${w2}" stroke-linecap="round"/>`});
const hk=.8,yT=26;
add('ui_tut_hand_swipe',[doc(256,128,S,[ring(44,yT+4,11,6,3),...handIt(44,yT,hk)]),doc(256,128,S,[trail(44,96,yT+4),...handIt(96,yT,hk)]),doc(256,128,S,[trail(44,148,yT+4),...handIt(148,yT,hk)]),doc(256,128,S,[trail(44,200,yT+4),...handIt(200,yT,hk)]),doc(256,128,S,[trail(150,200,yT+4,7,3),...handIt(204,yT-6,hk)]),doc(256,128,S,handIt(48,yT-6,hk))],256,128);
add('ui_tut_highlight',[0,1,2].map(i=>{const r=94+i*8;return svg(256,256,`<circle cx="128" cy="128" r="${r}" fill="none" stroke="${O}" stroke-width="12"/><circle cx="128" cy="128" r="${r}" fill="none" stroke="#FFFFFF" stroke-width="6"/><circle cx="128" cy="128" r="${r+10+i*2}" fill="none" stroke="#FFFFFF" stroke-width="3" stroke-opacity="${f(.6-i*.2)}"/>`)}),256);
add('ui_tut_arrow',[0,8,4].map(dy=>doc(64,96,s,[{ds:[RP([[21,6+dy],[43,6+dy],[43,46+dy],[57,46+dy],[32,80+dy],[7,46+dy],[21,46+dy]],4)],fill:K.ui,r:8,hl:[27,14+dy,2,6,0]}])),64,96);
return out}
