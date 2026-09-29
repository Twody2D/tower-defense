// Партия E-1: тайлы 64×64 для 3 биомов. После gen/anim/heroes/pests/defenders.
const BIO={farm:{g:K.grass,g2:K.grass2,rd:K.road},wheat:{g:'#8DBF4A',g2:'#79A83E',rd:'#E6C58A'},lake:{g:'#45A872',g2:'#378C5D',rd:'#D9C7A0'}};
Object.assign(SH,{'#8DBF4A':'#79A83E','#79A83E':'#628C30','#E6C58A':'#CBA56A','#45A872':'#378C5D','#378C5D':'#2A7049','#D9C7A0':'#BCA77E','#F2EBDD':'#D9CDB8','#5E6270':'#4A4D59'});
Object.assign(HL,{'#8DBF4A':'#B1D877','#45A872':'#73C695','#F2EBDD':'#FFFFFF','#D9C7A0':'#EEE2C6','#E6C58A':'#F5E0B5'});
const rotPt=(x,y,k)=>{for(let i=0;i<k;i++)[x,y]=[64-y,x];return [x,y]};
const PTH=(sg,k)=>sg.map(([c,...n])=>{const q=[];for(let i=0;i<n.length;i+=2){const [x,y]=rotPt(n[i],n[i+1],k);q.push(f(x)+' '+f(y))}return c+q.join(' ')}).join('')+'Z';
const ROT={l:'t',t:'r',r:'b',b:'l'};
const nmO=(o,k,ord)=>{let a=o.split('');for(let i=0;i<k;i++)a=a.map(c=>ROT[c]);return ord.split('').filter(c=>a.includes(c)).join('')};
const TW=[['C',16,12,16,9,32,9],['C',48,9,48,12,64,12]];
const RSH={
 straight:{o:'lr',ks:[0,1],d:[['M',0,12],...TW,['L',64,52],['C',48,52,48,55,32,55],['C',16,55,16,52,0,52]],sp:[[18,30],[44,38],[30,44]],tu:[[10,12],[40,11]]},
 corner:{o:'lb',ks:[0,1,2,3],d:[['M',0,12],['C',28.7,12,52,35.3,52,64],['L',12,64],['C',12,57.4,6.6,52,0,52]],sp:[[22,41],[31,50],[12,34]],tu:[[16,13],[43,33]]},
 t:{o:'lrb',ks:[0,1,2,3],d:[['M',0,12],...TW,['L',64,52],['C',57.4,52,52,57.4,52,64],['L',12,64],['C',12,57.4,6.6,52,0,52]],sp:[[20,28],[44,36],[32,52]],tu:[[12,12],[42,11]]},
 end:{o:'l',ks:[0,1,2,3],d:[['M',0,12],['C',12,12,20,10,30,10],['C',44,10,52,20,52,32],['C',52,44,44,54,30,54],['C',20,54,12,52,0,52]],sp:[[16,30],[34,38],[28,24]],tu:[[14,12],[44,22]]}
};
const SSH={
 edge:{o:'b',ks:[0,1,2,3],d:[['M',0,24],['C',16,24,16,21,32,21],['C',48,21,48,24,64,24],['L',64,64],['L',0,64]],sp:[[16,44],[46,52],[30,36]],tu:[[10,24],[42,21]]},
 outer:{o:'br',ks:[0,1,2,3],d:[['M',64,24],['L',64,64],['L',24,64],['C',24,41.9,41.9,24,64,24]],sp:[[48,48],[40,58],[56,38]],tu:[[33,37]]},
 inner:{o:'tl',ks:[0,1,2,3],d:[['M',0,24],['C',13.25,24,24,13.25,24,0],['L',64,0],['L',64,64],['L',0,64]],sp:[[44,20],[20,46],[46,48]],tu:[[17,17]]},
 fill:{o:'',ks:[0],d:[['M',0,0],['L',64,0],['L',64,64],['L',0,64]],sp:[[16,20],[44,30],[26,48],[50,54]],tu:[]}
};
const clampT=([x,y])=>[Math.max(3,Math.min(50,x)),Math.max(12,Math.min(61,y))];
function sandTile(b,sd,k){const D=Doc(64,64,STY.a),d=PTH(sd.d,k),id=D.clip([d]);
 let s=`<rect width="64" height="64" fill="${b.g}"/><path d="${d}" fill="${sh(b.rd)}"/><g clip-path="url(#${id})"><path d="${d}" transform="translate(0 4)" fill="${b.rd}"/><rect x="0" y="-1" width="64" height="9" fill="${b.rd}"/>`;
 sd.sp.forEach(([x,y])=>{const [X,Y]=rotPt(x,y,k);s+=`<path d="${E(X,Y,2.4,1.5)}" fill="${sh(b.rd)}"/>`});
 s+='</g>';sd.tu.forEach(p=>{const [X,Y]=clampT(rotPt(p[0],p[1],k));s+=tuft(X,Y,.8,false,b.g2)});
 D.add(s);return D.svg()}
function grassTile(b,v,bio){const D=Doc(64,64,STY.a);let s=`<rect width="64" height="64" fill="${b.g}"/>`;
 if(v===1)s+=`<path d="${blob([[14,30],[26,20],[44,22],[52,34],[42,46],[22,44]])}" fill="${b.g2}"/>`;
 [[[10,22],[40,44]],[[18,54],[44,16]],[[34,20]]][v].forEach(([x,y])=>s+=tuft(x,y,.85,false,b.g2));
 if(v===2){if(bio==='farm')s+=flower(18,42)+flower(46,34);
  else if(bio==='wheat')s+=[[18,42],[44,32],[30,52]].map(([x,y])=>`<circle cx="${x}" cy="${y}" r="3.2" fill="${K.straw}" stroke="${O}" stroke-width="1.5"/><circle cx="${x}" cy="${y}" r="1.1" fill="${K.ui}"/>`).join('');
  else s+=`<path d="${E(20,44,4.5,3.2)}" fill="${K.stone}" stroke="${O}" stroke-width="1.6"/><path d="${E(29,49,2.8,2)}" fill="${K.stone}" stroke="${O}" stroke-width="1.4"/><path d="${E(46,30,3.4,2.4)}" fill="${K.stone}" stroke="${O}" stroke-width="1.5"/>`}
 D.add(s);return D.svg()}
function tileSheets(){const out={},p='assets/e/';
 for(const [bio,b] of Object.entries(BIO)){
  [0,1,2].forEach(v=>out[p+`tile_${bio}_grass_${v+1}.svg`]=grassTile(b,v,bio));
  for(const [nm,sd] of Object.entries(RSH))sd.ks.forEach(k=>out[p+`tile_${bio}_road_${nm}_${nmO(sd.o,k,'trbl')}.svg`]=sandTile(b,sd,k));
  for(const [nm,sd] of Object.entries(SSH))sd.ks.forEach(k=>out[p+`tile_${bio}_sand_${nm}${sd.o?'_'+nmO(sd.o,k,'tblr'):''}.svg`]=sandTile(b,sd,k));
 }
 return out}
