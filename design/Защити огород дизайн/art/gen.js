// Генератор SVG-ассетов «Защити огород!» — партия A. Стили: 1a «Круглыши», 1b «Штампики».
const O='#2B2B3A';
const K={grass:'#4CAF50',grass2:'#3E8E41',road:'#E0B77A',wood:'#8D5A3B',woodL:'#B07A52',coin:'#FFC933',pest:'#8E44AD',pestL:'#A95CC8',ui:'#FF8A3D',sky:'#6EC6FF',panel:'#FFF4DC',fur:'#A3AABA',furD:'#474B5C',cream:'#F7F1E6',straw:'#F5C95B',denim:'#4A86E0',red:'#E0584B',soil:'#6E4430',stone:'#AEB3BC',goose:'#FBF8F1',leaf:'#2F8F52',pine:'#2F8A5E',bush:'#3B9E4C',sprout:'#6CC24A',pink:'#FF9BAE',bamboo:'#E9C46A',pea:'#8BD450',padG:'#2E6B34'};
const SH={'#4CAF50':'#3E8E41','#3E8E41':'#2F7133','#E0B77A':'#C69A5F','#8D5A3B':'#6B412A','#B07A52':'#8D5A3B','#FFC933':'#E8992A','#8E44AD':'#6B2F88','#A95CC8':'#8445A6','#FF8A3D':'#E0662A','#6EC6FF':'#44A2E4','#FFF4DC':'#EAD6AE','#A3AABA':'#7E8699','#474B5C':'#34374A','#F7F1E6':'#DCD1BE','#F5C95B':'#D9A33C','#4A86E0':'#3566B8','#E0584B':'#B8433A','#6E4430':'#573424','#AEB3BC':'#8A909C','#FBF8F1':'#DDD6C8','#2F8F52':'#23703F','#2F8A5E':'#216646','#3B9E4C':'#2D7B3B','#6CC24A':'#4E9A36','#E9C46A':'#C99D45','#8BD450':'#62A92E'};
const HL={'#4CAF50':'#7ACB6A','#8D5A3B':'#B07A52','#B07A52':'#CD9C72','#FFC933':'#FFF0B0','#8E44AD':'#B67ED3','#A95CC8':'#CD9BE3','#FF8A3D':'#FFB47E','#6EC6FF':'#B8E5FF','#A3AABA':'#CCD1DB','#F7F1E6':'#FFFFFF','#F5C95B':'#FFE7A3','#4A86E0':'#8DB5F2','#E0584B':'#F59287','#AEB3BC':'#D3D7DD','#FBF8F1':'#FFFFFF','#2F8F52':'#56B874','#2F8A5E':'#52B083','#3B9E4C':'#67C074','#6CC24A':'#9BDD7C','#E9C46A':'#F8E1A0','#FFF4DC':'#FFFFFF','#474B5C':'#6A6F82','#8BD450':'#C2EE95'};
const f=n=>Math.round(n*100)/100;
const P2=p=>f(p[0])+' '+f(p[1]);
const h2r=h=>[1,3,5].map(i=>parseInt(h.slice(i,i+2),16));
const r2h=a=>'#'+a.map(v=>Math.round(Math.max(0,Math.min(255,v))).toString(16).padStart(2,'0')).join('');
const mix=(a,b,t)=>{const A=h2r(a),B=h2r(b);return r2h(A.map((v,i)=>v+(B[i]-v)*t))};
const sh=c=>SH[c]||mix(c,'#2E2A5E',.28);
const hl=c=>HL[c]||mix(c,'#FFFFFF',.5);

// ---------- пути ----------
function ER(cx,cy,rx,ry,deg){const a=deg*Math.PI/180,c=Math.cos(a),s=Math.sin(a);const x1=cx-rx*c,y1=cy-rx*s,x2=cx+rx*c,y2=cy+rx*s;return `M${f(x1)} ${f(y1)}A${f(rx)} ${f(ry)} ${deg} 1 0 ${f(x2)} ${f(y2)}A${f(rx)} ${f(ry)} ${deg} 1 0 ${f(x1)} ${f(y1)}Z`}
function E(cx,cy,rx,ry){return ER(cx,cy,rx,ry??rx,0)}
function RR(x,y,w,h,r){const [a,b,c,d]=Array.isArray(r)?r:[r,r,r,r];return `M${f(x+a)} ${f(y)}H${f(x+w-b)}Q${f(x+w)} ${f(y)} ${f(x+w)} ${f(y+b)}V${f(y+h-c)}Q${f(x+w)} ${f(y+h)} ${f(x+w-c)} ${f(y+h)}H${f(x+d)}Q${f(x)} ${f(y+h)} ${f(x)} ${f(y+h-d)}V${f(y+a)}Q${f(x)} ${f(y)} ${f(x+a)} ${f(y)}Z`}
function RP(pts,r){const n=pts.length;let d='';for(let i=0;i<n;i++){const p0=pts[(i-1+n)%n],p1=pts[i],p2=pts[(i+1)%n],rr=Array.isArray(r)?r[i]:r;const v1=[p0[0]-p1[0],p0[1]-p1[1]],v2=[p2[0]-p1[0],p2[1]-p1[1]];const l1=Math.hypot(...v1)||1,l2=Math.hypot(...v2)||1;const k1=Math.min(rr,l1/2)/l1,k2=Math.min(rr,l2/2)/l2;const a=[p1[0]+v1[0]*k1,p1[1]+v1[1]*k1],b=[p1[0]+v2[0]*k2,p1[1]+v2[1]*k2];d+=(i?'L':'M')+P2(a)+'Q'+P2(p1)+' '+P2(b)}return d+'Z'}
function curve(p){if(p.length===2)return `M${P2(p[0])}L${P2(p[1])}`;let d=`M${P2(p[0])}`;for(let i=0;i<p.length-1;i++){const p0=p[i-1]||p[i],p1=p[i],p2=p[i+1],p3=p[i+2]||p2;d+=`C${f(p1[0]+(p2[0]-p0[0])/6)} ${f(p1[1]+(p2[1]-p0[1])/6)} ${f(p2[0]-(p3[0]-p1[0])/6)} ${f(p2[1]-(p3[1]-p1[1])/6)} ${P2(p2)}`}return d}
function blob(p){const n=p.length;let d=`M${P2(p[0])}`;for(let i=0;i<n;i++){const p0=p[(i-1+n)%n],p1=p[i],p2=p[(i+1)%n],p3=p[(i+2)%n];d+=`C${f(p1[0]+(p2[0]-p0[0])/6)} ${f(p1[1]+(p2[1]-p0[1])/6)} ${f(p2[0]-(p3[0]-p1[0])/6)} ${f(p2[1]-(p3[1]-p1[1])/6)} ${P2(p2)}`}return d+'Z'}
function sampleCR(p,n){const out=[];for(let i=0;i<p.length-1;i++){const p0=p[i-1]||p[i],p1=p[i],p2=p[i+1],p3=p[i+2]||p2;for(let k=0;k<n;k++){const t=k/n,t2=t*t,t3=t2*t;out.push([0,1].map(j=>.5*((2*p1[j])+(-p0[j]+p2[j])*t+(2*p0[j]-5*p1[j]+4*p2[j]-p3[j])*t2+(-p0[j]+3*p1[j]-3*p2[j]+p3[j])*t3)))}}out.push(p[p.length-1]);return out}
function plen(p){const s=sampleCR(p,10);let L=0;for(let i=1;i<s.length;i++)L+=Math.hypot(s[i][0]-s[i-1][0],s[i][1]-s[i-1][1]);return L}
// полуплоскость для cel-тени (side 1 = снизу справа, -1 = сверху слева)
function HP(c,ang,off=0,side=1){const a=ang*Math.PI/180,ux=Math.cos(a),uy=Math.sin(a);let nx=-uy,ny=ux;if(nx<0){nx=-nx;ny=-ny}nx*=side;ny*=side;const L=600,px=c[0]+nx*off,py=c[1]+ny*off;const P=[[px+ux*L,py+uy*L],[px+ux*L+nx*L,py+uy*L+ny*L],[px-ux*L+nx*L,py-uy*L+ny*L],[px-ux*L,py-uy*L]];return 'M'+P.map(P2).join('L')+'Z'}

// ---------- документ и рендер ----------
let GID=0;function Doc(w,h,S,tf){const out=[],defs=[];return{S,w,h,add(s){out.push(s)},clip(ds){const id='c'+(++GID);defs.push(`<clipPath id="${id}">${[].concat(ds).map(d=>`<path d="${d}"/>`).join('')}</clipPath>`);return id},svg(){return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${defs.length?'<defs>'+defs.join('')+'</defs>':''}${tf?`<g transform="${tf}">`:''}${out.join('')}${tf?'</g>':''}</svg>`}}}
const lineOf=(S,it)=>it.line??(S.sil?S.Wi:S.W);
function hlFor(D,it){const S=D.S;if(S.shade==='soft'){if(!Array.isArray(it.hl))return '';const [x,y,rx,ry,dg]=it.hl;return `<path d="${ER(x,y,rx,ry,dg||0)}" fill="${hl(it.fill)}"/>`}if(!it.rim||!it.c)return '';const id=D.clip(HP(it.c,-60,(it.r||10)*.45,-1));return `<g clip-path="url(#${id})">${it.ds.map(d=>`<path d="${d}" fill="none" stroke="${hl(it.fill)}" stroke-width="${it.rw||5}"/>`).join('')}</g>`}
function drawShape(D,it){const S=D.S,t=lineOf(S,it);let s='';if(t>0)s+=it.ds.map(d=>`<path d="${d}" fill="${O}" stroke="${O}" stroke-width="${f(2*t)}" stroke-linejoin="round"/>`).join('');s+=it.ds.map(d=>`<path d="${d}" fill="${it.fill}"/>`).join('');let inn='';const shc=it.sh===false?null:(it.sh||sh(it.fill));if(shc){if(S.shade==='soft'){const k=it.off??Math.max(1.5,Math.min(7,(it.r||10)*.2));inn+=it.ds.map(d=>`<path d="${d}" fill="${shc}"/>`).join('')+`<g transform="translate(${f(-k*.7)} ${f(-k)})">`+it.ds.map(d=>`<path d="${d}" fill="${it.fill}"/>`).join('')+'</g>'}else if(it.c){inn+=`<path d="${HP(it.c,it.ang??-60,it.coff??(it.r||10)*.25)}" fill="${shc}"/>`}}if(it.mark)inn+=it.mark.join('');inn+=hlFor(D,it);if(inn){const id=D.clip(it.ds);s+=`<g clip-path="url(#${id})">${inn}</g>`}return s}
function drawLimb(D,it){const S=D.S,t=lineOf(S,it);return `<path d="${it.limb}" fill="none" stroke="${O}" stroke-width="${f(it.w+2*t)}" stroke-linecap="round" stroke-linejoin="round"/><path d="${it.limb}" fill="none" stroke="${it.fill}" stroke-width="${it.w}" stroke-linecap="round" stroke-linejoin="round"/>${it.extra||''}`}
function render(D,items){const S=D.S;let s='';if(S.sil){for(const it of items){if(it.raw||it.nosil)continue;let g=it.limb?`<path d="${it.limb}" fill="none" stroke="${O}" stroke-width="${f(it.w+2*S.Wo)}" stroke-linecap="round" stroke-linejoin="round"/>`:it.ds.map(d=>`<path d="${d}" fill="${O}" stroke="${O}" stroke-width="${f(2*S.Wo)}" stroke-linejoin="round"/>`).join('');s+=it.tf?`<g transform="${it.tf}">${g}</g>`:g}}for(const it of items){if(it.raw){s+=it.raw;continue}const g=it.limb?drawLimb(D,it):drawShape(D,it);s+=it.tf?`<g transform="${it.tf}">${g}</g>`:g}D.add(s)}
// глаза: kind 'mask' (на тёмной маске), 'color' (на цветной голове), 'white' (на белой голове)
function eyeSvg(S,x,y,s,kind){let o='';if(S.eye==='glossy'){if(kind!=='white')o+=`<path d="${E(x,y,s*.86,s)}" fill="#fff"/>`;const px=x+s*.14,py=y+s*.1,rx=s*.62,ry=s*.78;o+=`<path d="${E(px,py,rx,ry)}" fill="${O}"/><path d="${E(px-rx*.3,py-ry*.36,rx*.42)}" fill="#fff"/><path d="${E(px+rx*.42,py+ry*.44,rx*.18)}" fill="#fff"/>`}else{if(kind==='mask')o+=`<path d="${E(x,y,s*.8)}" fill="${K.cream}"/>`;const px=x+s*.1,py=y+s*.05;o+=`<path d="${E(px,py,s*.36,s*.52)}" fill="${O}"/><path d="${E(px-s*.07,py-s*.22,s*.14)}" fill="#fff"/>`}return o}

// ---------- ГЕРОЙ: Енот-фермер 128 ----------
function raccoon(S){
 const D=Doc(128,128,S),g=S.geo,I=[],F=K.fur,FD=K.furD;
 const tp=g?[[47,96],[33,94],[22,84],[17,69]]:[[47,96],[34,93],[23,83],[18,68]];
 const td=curve(tp),L=plen(tp),tw=14;
 I.push({limb:td,w:tw,fill:F,extra:`<path d="${td}" fill="none" stroke="${FD}" stroke-width="${tw}" stroke-dasharray="0 ${f(L*.3)} ${f(L*.13)} ${f(L*.13)} ${f(L*.13)} ${f(L*.13)} ${f(L)}"/><path d="${E(tp[3][0],tp[3][1],tw/2)}" fill="${FD}"/>`});
 I.push({limb:curve([[56,100],[54,107]]),w:9,fill:sh(K.denim)});
 I.push({ds:[E(50.5,111.5,7,4.3)],fill:sh(FD),sh:false});
 I.push({limb:curve(g?[[53,87],[46,99]]:[[53,87],[47,94],[46,100]]),w:7.5,fill:sh(F)});
 I.push({ds:[E(45.8,100.5,4.8,4.5)],fill:sh(FD),sh:false});
 I.push({ds:[E(54,87,6,5.5)],fill:sh(K.ui),sh:false});
 I.push({ds:[g?RP([[45,80],[81,80],[83,108],[43,108]],9):E(63,93,19.5,16)],fill:K.denim,c:[63,94],r:16,hl:[50,88,4,2.4,-30],rim:true});
 I.push({limb:curve([[69,100],[71,107]]),w:9,fill:K.denim});
 I.push({ds:[E(74.5,111.5,7.5,4.5)],fill:FD,c:[74.5,111.5],r:4.5,sh:false});
 I.push({ds:[RR(62,81,17,14,g?3:5)],fill:K.denim,line:S.sil?S.Wi:2.5,sh:false});
 I.push({ds:[E(65.5,84.5,2.1)],fill:K.coin,line:1.2,sh:false},{ds:[E(75.5,84,2.1)],fill:K.coin,line:1.2,sh:false});
 I.push({limb:curve(g?[[73,86],[81,99]]:[[73,86],[79,93],[81.5,99.5]]),w:8,fill:F});
 I.push({ds:[E(82,100.5,5,4.7)],fill:FD,c:[82,100.5],r:4.7,sh:false});
 I.push({ds:[E(72,86,6.5,6)],fill:K.ui,c:[72,86],r:6});
 const head=g?[RP([[29,38],[90,34],[93,77],[31,80]],15),RP([[33,60],[21,77],[44,74]],2.5),RP([[80,70],[93,85],[92,64]],2.5)]:[E(60,54,32,25),RP([[34,58],[23,75],[45,71]],3),RP([[79,69],[91,83],[86,64]],3)];
 const mask=g?`<path d="${RP([[36,47],[86,44],[88,62],[38,65]],7)}" fill="${FD}"/>`:`<path d="${ER(49,55.5,11.5,9.5,14)}" fill="${FD}"/><path d="${ER(71,55,13.5,10.5,-12)}" fill="${FD}"/><path d="${RR(50,46,22,9,4)}" fill="${FD}"/>`;
 I.push({ds:head,fill:F,c:[61,56],r:25,mark:[`<path d="${ER(62,77,30,10,0)}" fill="${K.cream}"/>`,mask]});
 I.push({raw:eyeSvg(S,49.5,55.5,g?5.6:6.6,'mask')+eyeSvg(S,72,54.5,g?6.2:7.4,'mask')+(g?`<path d="${E(40,68,4.4,2.5)}" fill="${K.pink}"/><path d="${E(74,72,4,2.3)}" fill="${K.pink}"/>`:'')});
 I.push({ds:[g?RP([[73,54],[100,56],[103,66],[76,72]],7):E(89,65,13,10)],fill:K.cream,c:[89,64],r:9,hl:[84,59.5,4,2,-15],rim:true,rw:3});
 I.push({ds:[g?RR(96,55,9,7,3):E(100,61,5,3.8)],fill:O,line:0,sh:false,mark:[`<path d="${E(g?98.4:98.4,g?57:59.6,1.6,1)}" fill="#fff"/>`]});
 I.push({raw:`<path d="${g?'M86 66.5L90 69L94.5 66':'M89 70Q93.5 73.5 98 69.5'}" fill="none" stroke="${O}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>`});
 const tf='rotate(-5 58 36)';
 I.push({ds:[ER(58,36,g?41:40,g?11:11.5,0)],fill:K.straw,c:[58,37],r:11,hl:[36,33,8,2.6,-8],rim:true,rw:4,tf});
 I.push({raw:`<g transform="${tf}"><path d="${E(39,32.5,6.5,2.6)}" fill="${sh(K.straw)}"/><path d="${E(79,31.5,6.5,2.6)}" fill="${sh(K.straw)}"/></g>`});
 I.push({ds:[g?RP([[31,33],[32,14],[46,31]],2.5):RP([[31,33],[33,15],[46,31]],4.5)],fill:F,c:[37,26],r:6,sh:false,tf,mark:[`<path d="${RP([[35,31],[35.5,21],[42,30]],g?1.5:2.5)}" fill="${K.cream}"/>`]});
 I.push({ds:[g?RP([[72,31],[85,12],[88,31]],2.5):RP([[72,31],[84,13],[88,31]],4.5)],fill:F,c:[81,24],r:6,sh:false,tf,mark:[`<path d="${RP([[76,30],[83.5,20],[85,30]],g?1.5:2.5)}" fill="${K.cream}"/>`]});
 const crown=g?RP([[42,38],[45,15],[72,15],[75,38]],5):'M42 38C41 22 49 13 58.5 13C68 13 75 22 75 37Q58.5 43 42 38Z';
 const band=g?`<path d="M38 30H80V38H38Z" fill="${K.ui}"/>`:`<path d="M39 30Q58.5 36.5 78 30L78 38Q58.5 44.5 39 38Z" fill="${K.ui}"/>`;
 I.push({ds:[crown],fill:K.straw,c:[58.5,26],r:13,hl:[51,20,4.5,2.6,-35],rim:true,rw:4,mark:[band],tf});
 render(D,I);return D.svg();
}

// ---------- ВРЕДИТЕЛЬ: жук 48 ----------
function beetle(S,P={}){
 const D=Doc(48,48,S),g=S.geo,I=[],pc=K.pest,pd=sh(K.pest),hc=K.pestL,by=P.by||0;
 const LF=P.legs||[[0,0],[0,0],[0,0]],LB=P.legsB||[[0,0],[0,0],[0,0]];
 const at=by+(P.ant||0);
 I.push({limb:curve(g?[[33,22+by],[29,13+at]]:[[33.5,22+by],[31.5,16+(by+at)/2],[29,13+at]]),w:1.6,fill:pd});
 I.push({limb:curve(g?[[38,22+by],[42.5,13.5+at]]:[[38,22+by],[40,16+(by+at)/2],[42.5,13.5+at]]),w:1.6,fill:pd});
 I.push({ds:[g?RR(26.5,10.5+at,5,5,1.5):E(28.8,12.5+at,2.4)],fill:hc,sh:false},{ds:[g?RR(40.5,11+at,5,5,1.5):E(43,13+at,2.4)],fill:hc,sh:false});
 [[13,34,11,40.5],[21,36,20,41.5],[29,36,30,41.5]].forEach(([x1,y1,x2,y2],i)=>I.push({limb:curve([[x1,y1+by],[x2+LB[i][0],y2+LB[i][1]]]),w:3,fill:pd}));
 const split=g?`<path d="M29 ${17+by}L10 ${31+by}" stroke="${O}" stroke-width="1.5" stroke-linecap="round"/>`:`<path d="M31 ${19+by}Q21 ${21+by} 9 ${31+by}" fill="none" stroke="${O}" stroke-width="1.6" stroke-linecap="round"/>`;
 I.push({ds:[g?RR(6,16+by,31,21,[13,13,4,4]):E(21,28.5+by,15.5,12)],fill:pc,c:[21,28+by],r:12,hl:[13.5,23+by,4.6,2.6,-30],rim:true,rw:4,mark:[split]});
 [[15,37,14,42.5],[23,38,23.5,43],[31,37,33,42.5]].forEach(([x1,y1,x2,y2],i)=>I.push({limb:curve([[x1,y1+by],[x2+LF[i][0],y2+LF[i][1]]]),w:3,fill:pc}));
 I.push({ds:[g?RR(27.5,21.5+by,17.5,16.5,6):E(35.5,30+by,9.6,9.2)],fill:hc,c:[36,30+by],r:9,hl:[32,25+by,3,1.8,-30],rim:true,rw:3});
 I.push({raw:eyeSvg(S,33,27.5+by,g?3.6:3.7,'color')+eyeSvg(S,39,28+by,g?4:4.3,'color')+(g?`<path d="${E(41.8,33+by,2.3,1.3)}" fill="${K.pink}"/>`:'')});
 I.push({raw:`<path d="M34.5 ${34.2+by}Q38.8 ${37.6+by} 43 ${33.4+by}" fill="none" stroke="${O}" stroke-width="1.4" stroke-linecap="round"/><path d="${RR(37.6,35.3+by,2.6,2.3,.6)}" fill="#fff" stroke="${O}" stroke-width=".8"/>`});
 render(D,I);return D.svg();
}

// ---------- ЗАЩИТНИК: Гусь на вышке, ур.1 (доски) 160 ----------
function gooseTower(S){
 const D=Doc(160,160,S),g=S.geo,I=[],W=K.wood,WL=K.woodL,WS=sh(K.wood),G=K.goose;
 I.push({ds:[RR(50,94,9,44,g?2:3.5)],fill:WS,sh:false},{ds:[RR(101,94,9,44,g?2:3.5)],fill:WS,sh:false});
 I.push({limb:curve([[42,108],[118,140]]),w:5,fill:W},{limb:curve([[118,108],[42,140]]),w:5,fill:W});
 I.push({ds:[RR(33,98,12,50,g?2.5:4)],fill:W,c:[39,120],r:6},{ds:[RR(115,98,12,50,g?2.5:4)],fill:W,c:[121,120],r:6});
 I.push({ds:[RR(24,70,112,30,g?4:8)],fill:WL,sh:false,mark:[48,70,92,114].map(x=>`<path d="M${x} 70V100" stroke="${sh(WL)}" stroke-width="2"/>`)});
 const GT='translate(-10 -16) scale(1.12)';I.push({tf:GT,ds:g?[RP([[50,56],[98,52],[104,74],[56,82]],10),RP([[56,62],[40,46],[62,54]],2.5)]:[E(76,66,26,16),RP([[56,60],[40,47],[60,54]],3.5)],fill:G,c:[76,66],r:16,hl:[62,57,6,3,-20],rim:true});
 I.push({tf:GT,ds:[g?RP([[57,60],[86,60],[80,76],[61,74]],6):ER(71,67,17,9.5,6)],fill:G,c:[71,67],r:9,line:S.sil?S.Wi:2.5});
 I.push({tf:GT,limb:curve(g?[[92,60],[99,36]]:[[91,60],[97,48],[100,37]]),w:12,fill:G});
 I.push({tf:GT,ds:[g?RP([[87,48],[104,45],[106,55],[89,58]],3):blob([[87,50],[96,46],[105,47],[106,54],[97,57],[88,58]])],fill:K.sky,c:[96,52],r:5});
 I.push({tf:GT,ds:[RP([[91,55],[100,55],[95,66]],g?2:3)],fill:K.sky,c:[95,58],r:4});
 I.push({ds:[RR(112,29,32,8,g?2:4)],fill:K.bamboo,c:[128,33],r:4,tf:GT+' rotate(8 112 33)',mark:[`<path d="${RR(135,27,3.5,12,0)}" fill="${W}"/>`]});
 I.push({tf:GT,ds:[g?RR(89,20,24,23,9):E(101,31.5,11.5,11)],fill:G,c:[101,31],r:11,hl:[96,25,3.5,2,-30],rim:true,rw:4});
 I.push({tf:GT,ds:[g?RP([[109,27],[124,32],[109,38]],2.5):RP([[108.5,27],[124,32.5],[108.5,38.5]],4)],fill:K.ui,c:[114,32],r:5});
 I.push({raw:'<g transform="'+GT+'">'+eyeSvg(S,103.5,29,g?3.4:3.6,'white')+(g?`<path d="${E(99,37,3,1.8)}" fill="${K.pink}"/>`:'')+'</g>'});
 [36,77,118].forEach(x=>I.push({ds:[RR(x,80,6,14,2)],fill:W,sh:false}));
 I.push({ds:[RR(22,76,116,8,g?2:4)],fill:W,c:[80,80],r:4,hl:[44,78,14,1.2,0],rim:true,rw:3});
 I.push({ds:[RR(24,92,112,12,g?2:4)],fill:WS,sh:false});
 render(D,I);return D.svg();
}

// ---------- ОКРУЖЕНИЕ ----------
function barn(S){
 const D=Doc(256,256,S),g=S.geo,I=[],dep=86,rr=g?2:6;
 const F=g?[[46,158],[128,90],[210,158]]:[[46,158],[70,118],[128,94],[186,118],[210,158]];
 const B=F.map(([x,y])=>[x,y-dep]);
 const cols=g?[K.woodL,K.wood]:['#B07A52','#C48D62','#8D5A3B','#7A4C31'];
 for(let i=0;i<F.length-1;i++){const q=[F[i],F[i+1],B[i+1],B[i]],col=cols[i];const lines=[.33,.66].map(t=>{const a=[F[i][0]+(F[i+1][0]-F[i][0])*t,F[i][1]+(F[i+1][1]-F[i][1])*t],b=[B[i][0]+(B[i+1][0]-B[i][0])*t,B[i][1]+(B[i+1][1]-B[i][1])*t];return `<path d="M${P2(a)}L${P2(b)}" stroke="${sh(col)}" stroke-width="2.5"/>`});I.push({ds:[RP(q,rr)],fill:col,sh:false,mark:lines})}
 const wall=g?RP([[56,232],[56,156],[128,98],[200,156],[200,232]],[2,3,3,3,2]):RP([[56,232],[56,154],[76,122],[128,102],[180,122],[200,154],[200,232]],[3,5,6,6,6,5,3]);
 I.push({ds:[wall],fill:K.red,c:[128,180],r:40,hl:[74,176,7,30,0],rim:true,rw:8,mark:[80,104,152,176].map(x=>`<path d="M${x} 96V232" stroke="${sh(K.red)}" stroke-width="2.5"/>`)});
 I.push({ds:[RR(94,166,68,66,[8,8,0,0])],fill:K.panel,sh:false});
 I.push({ds:[RR(102,174,52,58,[4,4,0,0])],fill:sh(K.red),line:S.sil?S.Wi:2.5,sh:false,mark:[`<path d="M102 174L154 232M154 174L102 232" stroke="${O}" stroke-width="10"/><path d="M102 174L154 232M154 174L102 232" stroke="${K.panel}" stroke-width="6"/><path d="M128 174V232" stroke="${O}" stroke-width="2.5"/>`]});
 I.push({ds:[RR(110,118,36,30,g?3:8)],fill:K.panel,sh:false});
 I.push({ds:[RR(116,124,24,20,g?2:5)],fill:'#4A3530',line:S.sil?S.Wi:2,sh:false,mark:[`<path d="${g?RP([[114,146],[118,134],[124,138],[130,131],[136,137],[142,133],[144,146]],1.5):blob([[114,147],[117,136],[123,139],[129,132],[135,138],[141,134],[144,147]])}" fill="${K.straw}"/>`]});
 I.push({limb:'M'+F.map(P2).join('L'),w:8,fill:K.panel});
 render(D,I);return D.svg();
}
function bed(S){
 const D=Doc(128,96,S),g=S.geo,I=[],t=S.sil?S.Wi:2.5;
 I.push({ds:[RR(6,24,116,64,g?6:16)],fill:sh(K.wood),sh:false});
 I.push({ds:[RR(6,14,116,62,g?6:16)],fill:K.wood,c:[64,45],r:22,hl:[28,19.5,14,2.2,0],rim:true,rw:4,sh:false});
 I.push({ds:[RR(15,22,98,46,g?3:10)],fill:K.soil,line:t,sh:false,mark:[30,46,62].map(y=>`<path d="M22 ${y}H106" stroke="${sh(K.soil)}" stroke-width="3" stroke-linecap="round"/>`)});
 for(const y of [40,60])for(const x of [36,64,92]){
  const lv=g?[RP([[x-2,y-1],[x-10,y-12],[x-4,y-12]],1.5),RP([[x-2,y-1],[x,y-16],[x+2,y-1]],1.5),RP([[x+2,y-1],[x+10,y-12],[x+4,y-12]],1.5)]:[ER(x-5,y-8,2.8,6.5,-35),ER(x,y-10,2.8,7.5,0),ER(x+5,y-8,2.8,6.5,35)];
  I.push({ds:lv,fill:K.sprout,line:t,c:[x,y-8],r:4,sh:false});
  I.push({ds:[g?RR(x-7,y-4.5,14,10,[6,6,3,3]):E(x,y,7,5)],fill:K.ui,line:t,c:[x,y],r:5,hl:[x-3,y-2,2.2,1.2,-20],rim:true,rw:3});
 }
 render(D,I);return D.svg();
}
function treeApple(S){
 const D=Doc(160,160,S),g=S.geo,I=[];
 I.push({ds:[g?RR(71,96,18,50,3):RP([[66,146],[72,100],[88,100],[94,146]],6)],fill:K.wood,c:[80,122],r:9});
 I.push({ds:g?[E(80,66,52,48)]:[E(80,58,36),E(48,76,26),E(112,76,26),E(64,96,24),E(98,96,24),E(56,44,22),E(104,46,22)],fill:K.leaf,c:[80,70],r:44,hl:[56,38,12,7,-30],rim:true,rw:8});
 for(const [x,y] of [[60,62],[98,54],[112,86],[74,98],[44,90]])I.push({ds:[E(x,y,5.2)],fill:K.red,line:g?S.Wi:2.2,c:[x,y],r:5,hl:[x-1.6,y-1.8,1.6,1,-30],rim:true,rw:2.5});
 render(D,I);return D.svg();
}
function treePine(S){
 const D=Doc(128,128,S),g=S.geo,I=[],r=g?3:11;
 I.push({ds:[RR(57,98,14,24,g?2:4)],fill:K.wood,sh:false});
 [[[64,54],[112,104],[16,104]],[[64,30],[104,78],[24,78]],[[64,8],[94,52],[34,52]]].forEach(t=>I.push({ds:[RP(t,[g?2:5,r,r])],fill:K.pine,c:[64,t[1][1]-16],r:16,hl:[52,t[1][1]-22,5,3,-40],rim:true,rw:6}));
 render(D,I);return D.svg();
}
function flower(x,y){return `<circle cx="${x}" cy="${y}" r="3.4" fill="#fff" stroke="${O}" stroke-width="1.6"/><circle cx="${x}" cy="${y}" r="1.3" fill="${K.coin}"/>`}
function bush(S){
 const D=Doc(96,96,S),g=S.geo,I=[];
 I.push({ds:g?[RR(12,40,72,44,[36,36,8,8])]:[E(48,60,26,21),E(26,68,17,14),E(70,68,17,14),E(40,46,15),E(60,48,13)],fill:K.bush,c:[48,62],r:22,hl:[32,44,7,4,-30],rim:true,rw:6});
 I.push({raw:[[34,58],[60,52],[66,72],[44,74]].map(([x,y])=>flower(x,y)).join('')});
 render(D,I);return D.svg();
}
function rocks(S){
 const D=Doc(64,64,S),g=S.geo,I=[];
 I.push({ds:[g?RP([[10,50],[14,34],[28,26],[42,32],[46,50]],3):E(28,42,18,13)],fill:K.stone,c:[28,40],r:13,hl:[20,35,5,2.6,-25],rim:true,rw:4});
 I.push({ds:[g?RP([[40,54],[44,44],[54,42],[58,54]],2):E(49,49,10,7.5)],fill:K.stone,c:[49,49],r:7,hl:[45,46,2.6,1.4,-25],rim:true,rw:3});
 render(D,I);return D.svg();
}
function pad(S){
 const D=Doc(128,96,S),g=S.geo;
 const Ls=Math.hypot(46,30),c=11,gp=6.5,d=(Ls-2*c-3*gp)/2,a=[c];for(let i=0;i<4;i++){a.push(gp,d,gp,d,gp);a.push(i<3?2*c:c)}
 D.add(`<path d="${RP([[64,4],[125,46],[64,88],[3,46]],g?5:12)}" fill="${K.padG}"/><path d="M64 16L110 46L64 76L18 46Z" fill="none" stroke="#FFFFFF" stroke-width="4.5" stroke-linejoin="round" stroke-dasharray="${a.map(f).join(' ')}"/>`);
 return D.svg();
}
function coin(S){
 const D=Doc(32,32,S),g=S.geo,I=[];
 I.push({ds:[E(16,18.5,12,12)],fill:sh(K.coin),sh:false});
 I.push({ds:[E(16,15.5,12,12)],fill:K.coin,c:[16,15.5],r:12,off:2.4,hl:[11.5,10.5,3.4,2,-35],rim:true,rw:3.5,mark:[g?`<path d="${RP([[16,9],[22.5,15.5],[16,22],[9.5,15.5]],1.5)}" fill="none" stroke="${sh(K.coin)}" stroke-width="2"/>`:`<path d="${E(16,15.5,7)}" fill="none" stroke="${sh(K.coin)}" stroke-width="2"/>`]});
 render(D,I);return D.svg();
}
function pea(S){const D=Doc(16,16,S);render(D,[{ds:[E(8,8,5)],fill:K.pea,c:[8,8],r:5,hl:[6.3,6.2,1.6,1,-30],rim:true,rw:2.4}]);return D.svg()}
function star(S,full){const D=Doc(64,64,S),g=S.geo,pts=[];for(let i=0;i<10;i++){const a=-Math.PI/2+i*Math.PI/5,R=i%2?12.5:27;pts.push([32+Math.cos(a)*R,35+Math.sin(a)*R])}render(D,[{ds:[RP(pts,g?1.5:4)],fill:full?K.coin:'#D9C4A0',sh:full?undefined:false,c:[32,35],r:18,hl:[24,26,4,2.4,-35],rim:full,rw:4,line:S.sil?S.Wi:3}]);return D.svg()}
function tuft(x,y,k,g,col){return g?`<path d="M${f(x)} ${f(y)}l${f(2*k)} ${f(-7*k)} ${f(2*k)} ${f(7*k)} ${f(2*k)} ${f(-10*k)} ${f(2*k)} ${f(10*k)} ${f(2*k)} ${f(-6*k)} ${f(2*k)} ${f(6*k)}Z" fill="${col}"/>`:`<path d="M${f(x)} ${f(y)}q${f(k)} ${f(-7*k)} ${f(3*k)} ${f(-8*k)}q${f(-.5*k)} ${f(5*k)} ${f(1.5*k)} ${f(8*k)}q${f(1.5*k)} ${f(-9*k)} ${f(4*k)} ${f(-11*k)}q${f(-.8*k)} ${f(7*k)} ${f(1.5*k)} ${f(11*k)}q${f(1.5*k)} ${f(-6*k)} ${f(3.5*k)} ${f(-7*k)}q${f(-.5*k)} ${f(4*k)} ${f(.5*k)} ${f(7*k)}Z" fill="${col}"/>`}
function ground(S){
 const W=992,H=704,D=Doc(W,H,S),g=S.geo;let rs=11;const rnd=()=>(rs=(rs*16807)%2147483647)/2147483647;
 let s=`<rect width="${W}" height="${H}" fill="${K.grass}"/>`;
 for(const [cx,cy,rx,ry] of [[130,150,150,60],[560,120,170,55],[880,330,120,70],[300,560,190,70],[760,690,210,50],[60,440,110,60],[520,250,90,40]]){const n=g?7:9,pts=[];for(let i=0;i<n;i++){const a=i/n*Math.PI*2,k=.78+rnd()*.35;pts.push([cx+Math.cos(a)*rx*k,cy+Math.sin(a)*ry*k])}s+=`<path d="${g?RP(pts,10):blob(pts)}" fill="${K.grass2}"/>`}
 for(let i=0;i<80;i++){const x=rnd()*W,y=rnd()*H,k=.8+rnd()*.6;s+=tuft(x,y,k,g,i%4?K.grass2:hl(K.grass))}
 const cl=[[1060,612],[920,606],[800,574],[716,510],[664,440],[600,384],[500,352],[390,348],[300,338]];
 const sp=sampleCR(cl,g?3:6),Lp=[],Rp=[];
 sp.forEach((p,i)=>{const q=sp[Math.min(i+1,sp.length-1)],o=sp[Math.max(i-1,0)];let dx=q[0]-o[0],dy=q[1]-o[1];const l=Math.hypot(dx,dy)||1;dx/=l;dy/=l;const w1=33+Math.sin(i*1.3)*3+Math.sin(i*.41+1)*2.5,w2=33+Math.sin(i*1.1+2)*3+Math.sin(i*.37)*2.5;Lp.push([p[0]-dy*w1,p[1]+dx*w1]);Rp.push([p[0]+dy*w2,p[1]-dx*w2])});
 const rd=g?RP([...Lp,...Rp.reverse()],6):blob([...Lp,...Rp.reverse()]);
 const yard=g?RP([[20,252],[120,222],[300,226],[372,268],[352,352],[240,374],[80,368],[10,322]],18):blob([[20,256],[120,224],[290,228],[370,270],[350,352],[240,372],[80,368],[10,320]]);
 s+=`<path d="${yard}" fill="${sh(K.road)}"/><path d="${rd}" fill="${sh(K.road)}"/><clipPath id="rc"><path d="${yard}"/><path d="${rd}"/></clipPath><g clip-path="url(#rc)"><g transform="translate(0 5)"><path d="${yard}" fill="${K.road}"/><path d="${rd}" fill="${K.road}"/></g>`;
 for(let i=5;i<sp.length-3;i+=g?2:4){const p=sp[i],x=p[0]+(rnd()-.5)*34,y=p[1]+(rnd()-.5)*26;s+=g?`<path d="${RP([[x-3,y+2],[x,y-2.5],[x+4,y+1.5]],1)}" fill="${sh(K.road)}"/>`:`<path d="${E(x,y,2.2+rnd()*1.6,1.5+rnd())}" fill="${sh(K.road)}"/>`}
 s+='</g>';
 for(let i=0;i<sp.length;i+=g?3:5){const p=Lp[Math.min(i,Lp.length-1)];s+=tuft(p[0]-4,p[1]+3,.9,g,K.grass2)}
 D.add(s);return D.svg();
}

const STY={a:{id:'1a',sil:false,W:3.5,shade:'soft',eye:'glossy',geo:false},b:{id:'1b',sil:true,Wo:4,Wi:2,shade:'cel',eye:'bean',geo:true}};
const small=S=>S.sil?{...S,Wo:3,Wi:1.5}:{...S,W:2.75};
function build(){
 const out={};
 for(const k of ['a','b']){const S=STY[k],s=small(S),p=`assets/${S.id}/`;
  out[p+'hero_raccoon.svg']=raccoon(S);
  out[p+'enemy_beetle_1.svg']=beetle(s,{});
  out[p+'enemy_beetle_2.svg']=beetle(s,{legs:[[2,0],[-2,-1.5],[2,0]],legsB:[[-2,-1],[2,0],[-2,-1]],by:-.8});
  out[p+'enemy_beetle_3.svg']=beetle(s,{legs:[[-2,-1.5],[2,0],[-2,-1.5]],legsB:[[2,0],[-2,-1.5],[2,0]],by:.4});
  out[p+'tower_goose_l1.svg']=gooseTower(S);
  out[p+'env_barn.svg']=barn(S);
  out[p+'env_bed_carrot.svg']=bed(S);
  out[p+'env_tree_apple.svg']=treeApple(S);
  out[p+'env_tree_pine.svg']=treePine(S);
  out[p+'env_bush.svg']=bush(S);
  out[p+'env_rocks.svg']=rocks(s);
  out[p+'env_pad.svg']=pad(S);
  out[p+'fx_coin.svg']=coin(s);
  out[p+'proj_pea.svg']=pea(s);
  out[p+'ui_star_full.svg']=star(S,true);
  out[p+'ui_star_empty.svg']=star(S,false);
  out[p+'board_ground.svg']=ground(S);
 }
 return out;
}
