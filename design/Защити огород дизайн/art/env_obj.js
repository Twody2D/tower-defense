// Партия E-2: объекты биомов и общие объекты. После env_tiles.js.
const MILL='#F2EBDD';
function barnFlag(S,ph){const D=Doc(256,256,S),[a,c]=[[3,0],[0,2],[-3,1],[0,-1]][ph];
 render(D,[{limb:'M128 97V50',w:4,fill:K.wood},{ds:[`M130 52C141 ${52-a} 152 ${52+a} 164 ${55+c}L163 ${69+c}C152 ${68+a} 141 ${68-a} 130 68Z`],fill:K.ui,r:6,hl:[140,56,5,1.6,0]},{ds:[E(128,49,3.4)],fill:K.coin,sh:false}]);return D.svg()}
function scarecrow(S,P={}){const a=P.arm||0,D=Doc(96,128,S,`rotate(${P.rot||0} 48 122)`),I=[];
 I.push({ds:[RR(44.5,50,7,72,3)],fill:K.wood,r:3,sh:false});
 I.push({ds:[RP([[31,90],[35,104],[40,95],[45,106],[50,95],[56,105],[60,95],[65,103],[66,90]],1.5)],fill:K.straw,sh:false});
 I.push({ds:[RP([[20,55+a],[8,57+a],[12,61+a],[6,65+a],[20,68+a]],1.5),RP([[76,55-a],[88,57-a],[84,61-a],[90,65-a],[76,68-a]],1.5)],fill:K.straw,sh:false});
 I.push({limb:`M18 ${61.5+a}Q48 57 78 ${61.5-a}`,w:13,fill:K.red});
 I.push({ds:[RP([[33,58],[63,58],[67,94],[29,94]],6)],fill:K.red,r:12,hl:[37,66,3,6,-10],mark:[`<path d="M48 58V94" stroke="${sh(K.red)}" stroke-width="2.5"/><path d="${RR(51,72,10,10,2)}" fill="${K.denim}"/><path d="M53 74L59 80M59 74L53 80" stroke="${O}" stroke-width="1.3"/>`]});
 I.push({ds:[E(48,42,15,14)],fill:SACK,r:14,hl:[42,36,4,2.2,-30]});
 I.push({raw:`<path d="${E(42.5,41,2.6)}" fill="${O}"/><path d="${E(53.5,41,2.6)}" fill="${O}"/><path d="M41 48Q48 54 55 48" fill="none" stroke="${O}" stroke-width="2" stroke-linecap="round"/><path d="M44 49.5L43 52.5M48 51.5V54.5M52 49.5L53 52.5" stroke="${O}" stroke-width="1.4" stroke-linecap="round"/>`});
 I.push({ds:[ER(48,30,21,5.5,0)],fill:K.straw,r:5,hl:[36,28,6,1.6,-5]});
 I.push({ds:['M37 30C37 19 42 14 48 14C54 14 59 19 59 30Q48 33 37 30Z'],fill:K.straw,r:9,hl:[43,20,3,2,-30],mark:[`<path d="M37 24.5Q48 28.5 59 24.5V30Q48 33.5 37 30Z" fill="${K.denim}"/>`]});
 render(D,I);return D.svg()}
function barrow(S){const D=Doc(96,96,S);render(D,[
 {limb:'M40 58L10 46',w:5,fill:K.wood},{limb:'M36 64L31 86',w:5,fill:K.wood},
 {ds:[blob([[22,46],[34,34],[52,30],[70,32],[80,42]])],fill:K.straw,r:8,hl:[40,36,5,2,-15]},
 {ds:[RP([[18,44],[84,40],[76,68],[30,70]],6)],fill:K.denim,r:10,hl:[30,50,3,6,-10],mark:[`<path d="M18 44L84 40" stroke="${sh(K.denim)}" stroke-width="5"/>`]},
 {ds:[E(72,76,12)],fill:K.wood,r:8,mark:[`<path d="M72 64V88M60 76H84" stroke="${sh(K.wood)}" stroke-width="2.4"/>`]},{ds:[E(72,76,3.6)],fill:K.woodL,sh:false},
 {limb:'M44 62L8 54',w:5,fill:K.woodL},{ds:[E(8,54,3.4)],fill:K.wood,sh:false}]);return D.svg()}
function haystack(S){const D=Doc(96,96,S),st=`stroke="${sh(K.straw)}" stroke-width="2.6" stroke-linecap="round" fill="none"`;
 render(D,[{ds:[RP([[38,34],[42,20],[47,31],[52,18],[57,32]],1.5)],fill:K.straw,sh:false},
 {ds:[blob([[8,84],[12,60],[26,38],[48,28],[70,38],[84,60],[88,84],[48,90]])],fill:K.straw,r:22,hl:[30,46,8,4,-30],mark:[['M18 70Q30 64 40 70','M50 56Q60 50 72 58','M30 50Q38 44 46 48','M56 76Q66 70 78 76','M22 82Q30 78 38 82'].map(d=>`<path d="${d}" ${st}/>`).join('')]}]);return D.svg()}
function bedCabbage(S){const D=Doc(128,96,S),I=[],t=2.5;
 I.push({ds:[RR(6,24,116,64,16)],fill:sh(K.wood),sh:false},{ds:[RR(6,14,116,62,16)],fill:K.wood,r:22,hl:[28,19.5,14,2.2,0],sh:false});
 I.push({ds:[RR(15,22,98,46,10)],fill:K.soil,line:t,sh:false,mark:[30,46,62].map(y=>`<path d="M22 ${y}H106" stroke="${sh(K.soil)}" stroke-width="3" stroke-linecap="round"/>`)});
 for(const y of [40,60])for(const x of [36,64,92]){I.push({ds:[ER(x-6,y-2,5,3.5,-20),ER(x+6,y-2,5,3.5,20)],fill:K.leaf,line:t,sh:false});
  I.push({ds:[E(x,y-5,7.5,6.5)],fill:K.sprout,line:t,r:6,hl:[x-2.5,y-8,2.4,1.4,-30],mark:[`<path d="M${x} ${y-11}Q${x+3} ${y-5} ${x} ${y+1}" fill="none" stroke="${sh(K.sprout)}" stroke-width="1.6"/>`]})}
 render(D,I);return D.svg()}
function millBody(S){const D=Doc(256,256,S),I=[],ln=[130,170,210].map(y=>{const hw=36+(y-92)/146*18;return `<path d="M${f(128-hw)} ${y}H${f(128+hw)}" stroke="${sh(MILL)}" stroke-width="2.5"/>`}).join('');
 I.push({ds:[RP([[74,238],[92,92],[164,92],[182,238]],[6,4,4,6])],fill:MILL,r:30,hl:[100,130,6,28,-4],mark:[ln]});
 I.push({ds:[RR(112,196,32,42,[16,16,0,0])],fill:K.wood,r:8,mark:[`<path d="M123 196V238M133 196V238" stroke="${sh(K.wood)}" stroke-width="2.4"/>`]});
 I.push({ds:[E(128,150,11)],fill:K.wood,sh:false},{ds:[E(128,150,7)],fill:K.sky,sh:false,line:2,mark:[`<path d="M128 143V157M121 150H135" stroke="${K.wood}" stroke-width="2.4"/>`]});
 I.push({ds:[RR(78,90,100,12,6)],fill:sh(K.red),sh:false},{ds:[RP([[80,96],[128,30],[176,96]],[8,10,8])],fill:K.red,r:20,hl:[108,56,5,12,30]});
 render(D,I);return D.svg()}
function millBlades(S,fi){const D=Doc(256,256,S),I=[],hx=128,hy=112;
 for(let b=0;b<4;b++){const a=(b*90+fi*22.5-45)*Math.PI/180,c=Math.cos(a),s=Math.sin(a),T=(u,v)=>[hx+u*c-v*s,hy+u*s+v*c];
  I.push({limb:`M${P2(T(8,0))}L${P2(T(100,0))}`,w:6,fill:K.wood});
  I.push({ds:[RP([T(24,3),T(100,3),T(100,24),T(24,20)],3)],fill:K.panel,r:6,mark:[[44,64,84].map(u=>`<path d="M${P2(T(u,0))}L${P2(T(u,26))}" stroke="${K.woodL}" stroke-width="2.4"/>`).join('')+`<path d="M${P2(T(24,12))}L${P2(T(100,13))}" stroke="${K.woodL}" stroke-width="2.4"/>`]})}
 I.push({ds:[E(hx,hy,11)],fill:K.wood,r:8,hl:[hx-4,hy-4,3,2,-30],mark:[`<path d="${E(hx,hy,4)}" fill="${K.woodL}"/>`]});
 render(D,I);return D.svg()}
function wheatEars(S,sw=0){const D=Doc(64,64,S),I=[],st=[[16,-2,20],[25,1,14],[33,0,18],[41,2,13],[48,-1,21]];
 st.forEach(([x,o,ty],i)=>{const tx=x+o+sw*(1+(i%2)*.5);I.push({limb:curve([[x,60],[x+(tx-x)*.4,42],[tx,ty+9]]),w:2.2,fill:sh(K.straw)})});
 I.push({ds:[ER(22,52,2.6,7,-30),ER(44,50,2.6,7,30)],fill:sh(K.straw),line:2,sh:false});
 I.push({ds:st.map(([x,o,ty],i)=>{const tx=x+o+sw*(1+(i%2)*.5);return ER(tx,ty+2,3.4,8,(tx-x)*2)}),fill:K.straw,r:3,line:2.2,mark:st.map(([x,o,ty],i)=>{const tx=x+o+sw*(1+(i%2)*.5);return `<path d="M${f(tx-3)} ${ty-1}L${f(tx)} ${ty+1}L${f(tx+3)} ${ty-1}M${f(tx-3)} ${ty+4}L${f(tx)} ${ty+6}L${f(tx+3)} ${ty+4}" fill="none" stroke="${sh(K.straw)}" stroke-width="1.2"/>`})});
 render(D,I);return D.svg()}
function sheaf(S){const D=Doc(96,96,S),st=`stroke="${sh(K.straw)}" stroke-width="2" fill="none"`;
 render(D,[{ds:[ER(30,28,5,9,-25),ER(40,22,5,10,-10),ER(50,20,5,10,0),ER(60,22,5,10,10),ER(68,28,5,9,25)],fill:K.straw,r:4,line:2.4},
 {ds:[RP([[30,88],[41,58],[27,32],[69,32],[55,58],[66,88]],[5,3,6,6,3,5])],fill:K.straw,r:14,hl:[36,42,3,7,-10],mark:[`<path d="M40 88L44 60M48 88V60M56 88L52 60M40 34L44 56M48 34V56M56 34L52 56" ${st}/>`]},
 {limb:'M40 58Q48 62 56 58',w:6,fill:K.wood}]);return D.svg()}
function cart(S){const D=Doc(128,128,S),sp=(x,y,r)=>[0,45,90,135].map(a=>{const c=Math.cos(a*Math.PI/180)*r,s=Math.sin(a*Math.PI/180)*r;return `<path d="M${f(x-c)} ${f(y-s)}L${f(x+c)} ${f(y+s)}" stroke="${sh(K.wood)}" stroke-width="2.6"/>`}).join('');
 render(D,[{ds:[E(34,96,15)],fill:sh(K.wood),sh:false},{limb:'M92 86L124 80',w:4,fill:K.wood},
 {ds:[blob([[16,66],[22,44],[44,34],[66,32],[86,38],[100,52],[100,66]])],fill:K.straw,r:16,hl:[40,42,7,3,-15],mark:[`<path d="M30 52Q40 46 50 52M62 44Q72 40 82 46" stroke="${sh(K.straw)}" stroke-width="2.4" fill="none" stroke-linecap="round"/>`]},
 {ds:[RR(12,62,92,30,6)],fill:K.woodL,r:10,mark:[`<path d="M12 72H104M12 82H104" stroke="${sh(K.woodL)}" stroke-width="2.4"/><path d="M34 62V92M82 62V92" stroke="${K.wood}" stroke-width="5"/>`]},
 {ds:[E(72,100,19)],fill:K.wood,r:10,mark:[sp(72,100,16),`<path d="${E(72,100,13)}" fill="none" stroke="${K.woodL}" stroke-width="2.4"/>`]},{ds:[E(72,100,4.5)],fill:K.woodL,sh:false},
 {limb:'M96 90L126 90',w:4.5,fill:K.woodL}]);return D.svg()}
const LK=[[40,130],[70,62],[150,34],[250,38],[330,70],[356,132],[322,196],[230,226],[130,222],[58,190]];
const lkS=(k,dx=0,dy=0)=>blob(LK.map(([x,y])=>[192+(x-192)*k+dx,130+(y-130)*k+dy]));
function lake(S){const D=Doc(384,256,S),rim=lkS(1.07),w=lkS(.97);render(D,[{ds:[rim],fill:BIO.lake.rd,r:10,sh:false}]);
 const id=D.clip([w]),lily=[[112,150,13],[262,172,11],[292,106,10]].map(([x,y,r])=>`<path d="${E(x,y,r,r*.55)}" fill="${K.sprout}" stroke="${O}" stroke-width="2.4"/><path d="M${x} ${y}L${f(x+r)} ${f(y-r*.25)}L${f(x+r)} ${f(y+r*.2)}Z" fill="${K.sky}"/>`).join('');
 D.add(`<path d="${w}" fill="${sh(BIO.lake.rd)}" stroke="${O}" stroke-width="7"/><path d="${w}" fill="${sh(BIO.lake.rd)}"/><g clip-path="url(#${id})"><path d="${w}" transform="translate(0 9)" fill="${K.sky}"/><path d="${lkS(.55,16,18)}" fill="${sh(K.sky)}"/><path d="M96 84Q116 74 138 80M240 62Q258 56 274 62" fill="none" stroke="${hl(K.sky)}" stroke-width="4" stroke-linecap="round"/>${lily}<circle cx="108" cy="146" r="3.6" fill="${K.pink}" stroke="${O}" stroke-width="1.6"/></g>`);return D.svg()}
function ripple(S,fi){const D=Doc(384,256,S),id=D.clip([lkS(.97)]);let s='';
 [[150,120],[240,150],[200,196],[300,140]].forEach(([x,y],i)=>{const p=(fi+i)%4,r=6+p*6;s+=`<path d="${E(x,y,r,r*.42)}" fill="none" stroke="#FFFFFF" stroke-width="${f(3.2-p*.6)}"/>`;if(r>12)s+=`<path d="${E(x,y,r-8,(r-8)*.42)}" fill="none" stroke="#FFFFFF" stroke-width="${f(2.4-p*.4)}"/>`});
 D.add(`<g clip-path="url(#${id})">${s}</g>`);return D.svg()}
function reeds(S,sw=0){const D=Doc(64,96,S),I=[],R=[[16,40,-1],[25,22,0],[34,30,1],[44,44,.6],[50,54,1.2]];
 R.forEach(([x,ty,o],i)=>{const tx=x+o*6+sw*(1+i*.2);I.push({ds:[RP([[x-2.4,92],[x+2.4,92],[tx+.6,ty],[tx-.6,ty]],[1,1,.5,.5])],fill:i%2?K.leaf:K.sprout,r:3,line:2.2,sh:false})});
 [[25,22,0],[34,30,1]].forEach(([x,ty,o],i)=>{const tx=x+o*6+sw*(1+(i+1)*.2);I.push({ds:[RR(tx-3.6,ty+6,7.2,15,3.6)],fill:K.wood,r:4,hl:[tx-1.3,ty+10,1.1,3,0]})});
 render(D,I);return D.svg()}
function pier(S){const D=Doc(128,96,S);render(D,[{ds:[RR(20,50,8,38,3),RR(60,52,8,38,3),RR(98,50,8,38,3)],fill:K.wood,r:3,sh:false},
 {ds:[RP([[8,30],[120,30],[124,52],[4,52]],4)],fill:K.woodL,r:8,mark:[[22,36,50,64,78,92,106].map(x=>`<path d="M${x} 30L${f(x+(x-64)*.07)} 52" stroke="${sh(K.woodL)}" stroke-width="2.2"/>`).join('')]},
 {ds:[RR(4,50,120,9,3)],fill:K.wood,sh:false},{ds:[RR(10,14,9,22,3),RR(109,14,9,22,3)],fill:K.wood,r:3,hl:[12.5,18,1.2,3,0]},{limb:'M14 20Q64 30 114 20',w:2.6,fill:K.straw}]);return D.svg()}
function skep(S){const D=Doc(96,96,S),st=`stroke="${sh(K.straw)}" stroke-width="3" fill="none" stroke-linecap="round"`;
 render(D,[{ds:[RR(26,84,6,9,2),RR(64,84,6,9,2)],fill:K.wood,sh:false},{ds:[RR(18,78,60,10,4)],fill:K.wood,r:4,hl:[30,80,8,1,0]},
 {ds:[blob([[22,80],[22,58],[32,36],[48,28],[64,36],[74,58],[74,80]])],fill:K.straw,r:20,hl:[36,40,5,3,-30],mark:[['M26 46Q48 52 70 46','M23 58Q48 65 73 58','M22 70Q48 77 74 70'].map(d=>`<path d="${d}" ${st}/>`).join('')]},
 {ds:[RR(40,68,16,12,[8,8,0,0])],fill:'#3B2A22',line:2.4,sh:false}]);return D.svg()}
function skepBees(S,fi){const D=Doc(96,96,S),I=[];[0,1,2].forEach(i=>{const a=(fi*90+i*120)*Math.PI/180;I.push(...beeSmall(48+Math.cos(a)*32,48+Math.sin(a)*18,fi%2))});render(D,I);return D.svg()}
function boat(S){const D=Doc(128,64,S);render(D,[{ds:[blob([[8,26],[64,20],[120,24],[108,46],[64,52],[22,46]])],fill:K.red,r:10,hl:[30,32,8,2,-5],mark:[`<path d="M14 38Q64 46 116 34" stroke="${K.panel}" stroke-width="3.5" fill="none"/>`]},
 {ds:[blob([[16,28],[64,24],[112,27],[102,34],[64,37],[26,35]])],fill:K.wood,sh:false},{ds:[RR(56,25,12,11,2)],fill:K.woodL,sh:false},
 {limb:'M44 30L16 54',w:3.4,fill:K.woodL},{ds:[ER(13,57,5.5,3,-40)],fill:K.woodL,sh:false}]);return D.svg()}
function treeA(S,a=0){const D=Doc(160,160,S),I=[],T=`rotate(${a} 80 104)`;
 I.push({ds:[RP([[66,146],[72,100],[88,100],[94,146]],6)],fill:K.wood,r:9});
 I.push({tf:T,ds:[E(80,58,36),E(48,76,26),E(112,76,26),E(64,96,24),E(98,96,24),E(56,44,22),E(104,46,22)],fill:K.leaf,r:44,hl:[56,38,12,7,-30]});
 for(const [x,y] of [[60,62],[98,54],[112,86],[74,98],[44,90]])I.push({tf:T,ds:[E(x,y,5.2)],fill:K.red,line:2.2,r:5,hl:[x-1.6,y-1.8,1.6,1,-30]});
 render(D,I);return D.svg()}
function treeP(S,a=0){const D=Doc(128,128,S),I=[],T=`rotate(${a} 64 100)`;
 I.push({ds:[RR(57,98,14,24,4)],fill:K.wood,sh:false});
 [[[64,54],[112,104],[16,104]],[[64,30],[104,78],[24,78]],[[64,8],[94,52],[34,52]]].forEach(t=>I.push({tf:T,ds:[RP(t,[5,11,11])],fill:K.pine,r:16,hl:[52,t[1][1]-22,5,3,-40]}));
 render(D,I);return D.svg()}
function stump(S){const D=Doc(64,64,S);render(D,[{ds:[ER(16,55,7,4,-15),ER(48,55,7,4,15)],fill:K.wood,sh:false},
 {ds:[RR(16,28,32,28,[4,4,9,9])],fill:K.wood,r:8,mark:[`<path d="M24 34V52M34 36V56M42 33V50" stroke="${sh(K.wood)}" stroke-width="2"/>`]},
 {ds:[E(32,29,16,6.5)],fill:K.woodL,sh:false,mark:[`<path d="${E(32,29,10,4)}" fill="none" stroke="${sh(K.woodL)}" stroke-width="1.6"/><path d="${E(32,29,4.5,1.8)}" fill="none" stroke="${sh(K.woodL)}" stroke-width="1.6"/>`]},
 {ds:[ER(46,20,2.6,5,30)],fill:K.sprout,line:2,sh:false}]);return D.svg()}
function wattle(S){const D=Doc(96,64,S),I=[{ds:[RR(10,12,7,46,3),RR(44,10,7,48,3),RR(78,12,7,46,3)],fill:K.wood,r:3,hl:[12.5,16,1.2,4,0]}];
 [[24,1],[34,-1],[44,1]].forEach(([y,s])=>I.push({limb:`M4 ${y}Q19 ${y-4*s} 34 ${y}T64 ${y}T92 ${y}`,w:5,fill:K.woodL}));
 render(D,I);return D.svg()}
function sunflower(S,sw=0){const D=Doc(64,96,S),hx=32+sw,hy=28,I=[];
 I.push({limb:curve([[32,92],[32+sw*.4,62],[hx,hy+8]]),w:4,fill:K.leaf});
 I.push({ds:[ER(23+sw*.2,68,8,4,-25),ER(41+sw*.3,60,8,4,25)],fill:K.leaf,r:3,line:2.2});
 I.push({ds:Array.from({length:10},(_,i)=>{const a=i*36*Math.PI/180;return ER(hx+Math.cos(a)*12,hy+Math.sin(a)*11,5.5,3.2,i*36)}),fill:K.straw,r:3,line:2.2,sh:false});
 I.push({ds:[E(hx,hy,8.5,8)],fill:K.wood,r:6,hl:[hx-3,hy-3,2.4,1.5,-30],mark:[[-3,-2],[2,-3],[3,2],[-2,3],[0,0]].map(([x,y])=>`<path d="${E(hx+x,hy+y,1)}" fill="${sh(K.wood)}"/>`)});
 render(D,I);return D.svg()}
function objSheets(){const S=STY.a,s=small(S),out={},p='assets/e/',add=(n,fr,w,h)=>out[p+`${n}_${fr.length}f.svg`]=sheet(fr,w,h||w);
 out[p+'env_farm_barn.svg']=barn(S);add('env_farm_barn_flag',[0,1,2,3].map(i=>barnFlag(S,i)),256);
 add('env_farm_scarecrow_sway',[[-2.5,2],[0,0],[2.5,-2],[0,0]].map(([rot,arm])=>scarecrow(S,{rot,arm})),96,128);
 out[p+'env_farm_bed.svg']=bedCabbage(S);out[p+'env_farm_wheelbarrow.svg']=barrow(S);out[p+'env_farm_haystack.svg']=haystack(S);
 out[p+'env_wheat_mill.svg']=millBody(S);add('env_wheat_mill_blades',[0,1,2,3].map(i=>millBlades(S,i)),256);
 add('env_wheat_ears_sway',[0,2,-2].map(v=>wheatEars(s,v)),64);out[p+'env_wheat_sheaf.svg']=sheaf(S);out[p+'env_wheat_cart.svg']=cart(S);
 out[p+'env_lake_lake.svg']=lake(S);add('env_lake_ripple',[0,1,2,3].map(i=>ripple(S,i)),384,256);
 add('env_lake_reeds_sway',[0,2,-2].map(v=>reeds(s,v)),64,96);out[p+'env_lake_pier.svg']=pier(S);
 out[p+'env_lake_skep.svg']=skep(S);add('env_lake_skep_bees',[0,1,2,3].map(i=>skepBees(s,i)),96);out[p+'env_lake_boat.svg']=boat(S);
 add('env_tree_apple_sway',[0,1.8,-1.8].map(a=>treeA(S,a)),160);add('env_tree_pine_sway',[0,1.8,-1.8].map(a=>treeP(S,a)),128);
 out[p+'env_bush.svg']=bush(S);out[p+'env_rocks.svg']=rocks(s);out[p+'env_stump.svg']=stump(s);out[p+'env_fence_decor.svg']=wattle(S);
 add('env_sunflower_sway',[0,2,-2].map(v=>sunflower(s,v)),64,96);
 return out}
