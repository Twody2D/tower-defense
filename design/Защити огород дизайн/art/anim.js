// Позируемый Енот (стиль 1a/1b) + покадровые анимации. Подключается после gen.js.
function raccoonP(S,P={}){
 const D=Doc(128,128,S,P.lean?`rotate(${P.lean} 64 116)`:''),g=S.geo,I=[],F=K.fur,FD=K.furD;
 const by=P.by||0,hb=by+(P.hy||0),[fdx,fdy]=P.footF||[0,0],[bdx,bdy]=P.footB||[0,0],aF=P.armF||0,aB=P.armB||0,tl=P.tail||0,ear=P.ear||0,hat=P.hat||0;
 const TB=`translate(0 ${by})`,TH=`translate(0 ${hb})`,THat=`translate(0 ${hb+hat}) rotate(-5 58 36)`;
 const rot=(o,v,a)=>{const r=a*Math.PI/180,c=Math.cos(r),s=Math.sin(r);return [o[0]+v[0]*c-v[1]*s,o[1]+v[0]*s+v[1]*c]};
 const tp=g?[[47,96],[33,94],[22,84],[17,69]]:[[47,96],[34,93],[23,83],[18,68]];
 const td=curve(tp),L=plen(tp),tw=14;
 I.push({tf:TB+` rotate(${tl} 47 96)`,limb:td,w:tw,fill:F,extra:`<path d="${td}" fill="none" stroke="${FD}" stroke-width="${tw}" stroke-dasharray="0 ${f(L*.3)} ${f(L*.13)} ${f(L*.13)} ${f(L*.13)} ${f(L*.13)} ${f(L)}"/><path d="${E(tp[3][0],tp[3][1],tw/2)}" fill="${FD}"/>`});
 I.push({limb:curve([[56,100+by],[54+bdx*.7,107+bdy]]),w:9,fill:sh(K.denim)});
 I.push({ds:[E(50.5+bdx,111.5+bdy,7,4.3)],fill:sh(FD),sh:false});
 const sB=[53,87],eB=rot(sB,[-6,7],aB),pB=rot(sB,[-7,13],aB),qB=rot(sB,[-7.2,13.5],aB);
 I.push({tf:TB,limb:curve(g?[sB,pB]:[sB,eB,pB]),w:7.5,fill:sh(F)});
 I.push({tf:TB,ds:[E(qB[0],qB[1],4.8,4.5)],fill:sh(FD),sh:false});
 I.push({tf:TB,ds:[E(54,87,6,5.5)],fill:sh(K.ui),sh:false});
 I.push({tf:TB,ds:[g?RP([[45,80],[81,80],[83,108],[43,108]],9):E(63,93,19.5,16)],fill:K.denim,c:[63,94],r:16,hl:[50,88,4,2.4,-30],rim:true});
 I.push({limb:curve([[69,100+by],[71+fdx*.7,107+fdy]]),w:9,fill:K.denim});
 I.push({ds:[E(74.5+fdx,111.5+fdy,7.5,4.5)],fill:FD,sh:false});
 I.push({tf:TB,ds:[RR(62,81,17,14,g?3:5)],fill:K.denim,line:S.sil?S.Wi:2.5,sh:false});
 I.push({tf:TB,ds:[E(65.5,84.5,2.1)],fill:K.coin,line:1.2,sh:false},{tf:TB,ds:[E(75.5,84,2.1)],fill:K.coin,line:1.2,sh:false});
 const sF=[73,86],eF=rot(sF,[6,7],aF),pF=rot(sF,[8.5,13.5],aF),qF=rot(sF,[9,14.5],aF);
 const armF=[{tf:TB,limb:curve(g?[sF,pF]:[sF,eF,pF]),w:8,fill:F},{tf:TB,ds:[E(qF[0],qF[1],5,4.7)],fill:FD,sh:false},{tf:TB,ds:[E(72,86,6.5,6)],fill:K.ui,c:[72,86],r:6}];
 if(!P.armFront)I.push(...armF);
 const head=g?[RP([[29,38],[90,34],[93,77],[31,80]],15),RP([[33,60],[21,77],[44,74]],2.5),RP([[80,70],[93,85],[92,64]],2.5)]:[E(60,54,32,25),RP([[34,58],[23,75],[45,71]],3),RP([[79,69],[91,83],[86,64]],3)];
 const mask=g?`<path d="${RP([[36,47],[86,44],[88,62],[38,65]],7)}" fill="${FD}"/>`:`<path d="${ER(49,55.5,11.5,9.5,14)}" fill="${FD}"/><path d="${ER(71,55,13.5,10.5,-12)}" fill="${FD}"/><path d="${RR(50,46,22,9,4)}" fill="${FD}"/>`;
 I.push({tf:TH,ds:head,fill:F,c:[61,56],r:25,mark:[`<path d="${ER(62,77,30,10,0)}" fill="${K.cream}"/>`,mask]});
 I.push({raw:`<g transform="${TH}">`+eyeSvg(S,49.5,55.5,g?5.6:6.6,'mask')+eyeSvg(S,72,54.5,g?6.2:7.4,'mask')+(g?`<path d="${E(40,68,4.4,2.5)}" fill="${K.pink}"/><path d="${E(74,72,4,2.3)}" fill="${K.pink}"/>`:'')+'</g>'});
 I.push({tf:TH,ds:[g?RP([[73,54],[100,56],[103,66],[76,72]],7):E(89,65,13,10)],fill:K.cream,c:[89,64],r:9,hl:[84,59.5,4,2,-15],rim:true,rw:3});
 I.push({tf:TH,ds:[g?RR(96,55,9,7,3):E(100,61,5,3.8)],fill:O,line:0,sh:false,mark:[`<path d="${E(98.4,g?57:59.6,1.6,1)}" fill="#fff"/>`]});
 I.push({raw:`<path transform="${TH}" d="${P.mouth||(g?'M86 66.5L90 69L94.5 66':'M89 70Q93.5 73.5 98 69.5')}" fill="${P.mouthFill||'none'}" stroke="${O}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>`});
 I.push({tf:THat,ds:[ER(58,36,g?41:40,g?11:11.5,0)],fill:K.straw,c:[58,37],r:11,hl:[36,33,8,2.6,-8],rim:true,rw:4});
 I.push({raw:`<g transform="${THat}"><path d="${E(39,32.5,6.5,2.6)}" fill="${sh(K.straw)}"/><path d="${E(79,31.5,6.5,2.6)}" fill="${sh(K.straw)}"/></g>`});
 I.push({tf:THat+` rotate(${ear} 38 32)`,ds:[g?RP([[31,33],[32,14],[46,31]],2.5):RP([[31,33],[33,15],[46,31]],4.5)],fill:F,sh:false,mark:[`<path d="${RP([[35,31],[35.5,21],[42,30]],g?1.5:2.5)}" fill="${K.cream}"/>`]});
 I.push({tf:THat+` rotate(${ear} 79 31)`,ds:[g?RP([[72,31],[85,12],[88,31]],2.5):RP([[72,31],[84,13],[88,31]],4.5)],fill:F,sh:false,mark:[`<path d="${RP([[76,30],[83.5,20],[85,30]],g?1.5:2.5)}" fill="${K.cream}"/>`]});
 const crown=g?RP([[42,38],[45,15],[72,15],[75,38]],5):'M42 38C41 22 49 13 58.5 13C68 13 75 22 75 37Q58.5 43 42 38Z';
 const band=g?`<path d="M38 30H80V38H38Z" fill="${K.ui}"/>`:`<path d="M39 30Q58.5 36.5 78 30L78 38Q58.5 44.5 39 38Z" fill="${K.ui}"/>`;
 I.push({tf:THat,ds:[crown],fill:K.straw,c:[58.5,26],r:13,hl:[51,20,4.5,2.6,-35],rim:true,rw:4,mark:[band]});
 if(P.armFront)I.push(...armF);
 render(D,I);return D.svg();
}
// Бег 6 кадров @12 FPS: контакт → присед → полёт ×2 (ноги меняются)
const RUN=[
 {lean:6,by:1,footF:[8,0],footB:[-8,-4],armF:28,armB:-28,tail:4,ear:0,hat:0},
 {lean:6,by:3,hy:1,footF:[2,0],footB:[-3,-7],armF:12,armB:-12,tail:10,ear:5,hat:-1.5},
 {lean:6,by:-4,hy:-1,footF:[-7,-3],footB:[6,-7],armF:-26,armB:26,tail:-8,ear:-9,hat:1.5},
 {lean:6,by:1,footF:[-8,-4],footB:[8,0],armF:-28,armB:28,tail:4,ear:0,hat:0},
 {lean:6,by:3,hy:1,footF:[-3,-7],footB:[2,0],armF:-12,armB:12,tail:10,ear:5,hat:-1.5},
 {lean:6,by:-4,hy:-1,footF:[6,-7],footB:[-7,-3],armF:26,armB:-26,tail:-8,ear:-9,hat:1.5}
].map(p=>({...p,mouth:'M88.5 69Q93.5 76 98.5 68.5Z',mouthFill:'#C9475A'}));
// Ходьба жука 4 кадра @8 FPS: шаг A → перенос → шаг B → перенос
const WALK=[
 {legs:[[2.5,0],[-2.5,-2],[2.5,0]],legsB:[[-2.5,-2],[2.5,0],[-2.5,-2]],by:0,ant:1},
 {legs:[[0,-1],[0,0],[0,-1]],legsB:[[0,0],[0,-1],[0,0]],by:-1.3,ant:.4},
 {legs:[[-2.5,-2],[2.5,0],[-2.5,-2]],legsB:[[2.5,0],[-2.5,-2],[2.5,0]],by:0,ant:1},
 {legs:[[0,0],[0,-1],[0,0]],legsB:[[0,-1],[0,0],[0,-1]],by:-1.3,ant:.4}
];
function sheet(frames,w,h){return `<svg xmlns="http://www.w3.org/2000/svg" width="${w*frames.length}" height="${h}" viewBox="0 0 ${w*frames.length} ${h}">`+frames.map((s,i)=>s.replace('<svg xmlns="http://www.w3.org/2000/svg" ',`<svg x="${i*w}" y="0" `)).join('')+'</svg>'}
function buildAnim(){
 const out={},S=STY.a,s=small(S),p='assets/1a/anim/';
 const run=RUN.map(P=>raccoonP(S,P)),walk=WALK.map(P=>beetle(s,P));
 run.forEach((v,i)=>out[p+`hero_raccoon_run_${i+1}.svg`]=v);
 walk.forEach((v,i)=>out[p+`enemy_beetle_walk_${i+1}.svg`]=v);
 out[p+'hero_raccoon_run_6f.svg']=sheet(run,128,128);
 out[p+'enemy_beetle_walk_4f.svg']=sheet(walk,48,48);
 return out;
}
