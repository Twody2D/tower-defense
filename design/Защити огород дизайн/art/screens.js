// Партия I: ассеты экранов (плашка логотипа, узлы карты, деления, подсветка карточки, ленты). После gen/.../ui/hud.
function screenSheets(){
const S=STY.a,s=small(S),out={},p='assets/i/',put=(n,v)=>out[p+n+'.svg']=v;
const svg=(w,h,b)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${b}</svg>`;
{const D=Doc(960,440,S),I=[];
 I.push({ds:[ER(428,74,26,62,-25),ER(480,58,26,70,0),ER(532,74,26,62,25),ER(386,100,20,46,-50),ER(574,100,20,46,50)],fill:K.sprout,r:14,hl:[472,26,5,12,0]});
 I.push({ds:[RR(40,96,880,300,64)],fill:K.wood,r:40,hl:[150,112,60,6,0],mark:[`<path d="${RR(64,120,832,252,44)}" fill="${K.woodL}"/><path d="M72 206H888M72 290H888" stroke="${sh(K.woodL)}" stroke-width="5" stroke-linecap="round"/>`]});
 [[82,138],[878,138],[82,354],[878,354]].forEach(([x,y])=>I.push({ds:[E(x,y,9)],fill:K.stone,line:3,sh:false}));
 I.push(...carrotFull(858,58,35,6.5),...coinIt(96,390,26,1),...coinIt(154,410,22,.5),...coinIt(206,394,24,1));
 render(D,I);D.add(tuft(330,418,1.6,false,K.grass2)+tuft(690,422,1.6,true,K.grass2));put('logo_plate',D.svg());}
const node=(top,side,glow)=>{const D=Doc(128,128,s),I=[];if(glow)I.push({ds:[E(64,70,62,50)],fill:'#FFF0B0',line:3,sh:false});
 I.push({ds:[E(64,78,50,36)],fill:side,sh:false},{ds:[E(64,64,50,36)],fill:top,r:30,hl:[46,48,12,5,-10]});render(D,I);return D.svg()};
put('map_node_locked',node('#B9B6C2','#8F8C9A'));put('map_node_open',node(K.ui,'#E0662A'));put('map_node_done',node('#72C83E','#4F9E2A'));put('map_node_current',node(K.ui,'#E0662A',1));
put('map_path_dot',doc(32,24,s,[{ds:[E(16,12,11,7)],fill:'#FFF4DC',line:2.4,sh:false}]));
put('ui_seg_on',doc(24,40,s,[{ds:[RR(3,3,18,34,7)],fill:'#72C83E',line:2.4,sh:false,mark:[`<path d="${RR(7,7,4,14,2)}" fill="#A8E47C"/>`]}]));
put('ui_seg_off',doc(24,40,s,[{ds:[RR(3,3,18,34,7)],fill:'#D9C6A5',line:2.4,sh:false}]));
put('ui_card_highlight',svg(128,128,`<path d="${RR(2,2,124,124,24)}" fill="#E0662A" stroke="${O}" stroke-width="3"/><path d="${RR(3.5,3.5,121,112,22.5)}" fill="${K.ui}"/><path d="${RR(10,10,108,98,16)}" fill="#FFF6DA"/>`));
const rib=(a,b,c,h)=>svg(384,112,`<path d="${RP([[4,44],[84,44],[84,100],[4,100],[22,72]],3)}" fill="${b}" stroke="${O}" stroke-width="4" stroke-linejoin="round"/><path d="${RP([[380,44],[300,44],[300,100],[380,100],[362,72]],3)}" fill="${b}" stroke="${O}" stroke-width="4" stroke-linejoin="round"/><path d="M62 78H84V100Z" fill="${c}" stroke="${O}" stroke-width="3" stroke-linejoin="round"/><path d="M322 78H300V100Z" fill="${c}" stroke="${O}" stroke-width="3" stroke-linejoin="round"/><path d="${RR(60,8,264,74,12)}" fill="${b}" stroke="${O}" stroke-width="4"/><path d="${RR(62,10,260,62,10)}" fill="${a}"/><path d="${RR(78,16,228,6,3)}" fill="${h}"/>`);
put('ui_ribbon_blue',rib('#4FB0F0','#2F86C9','#1F5F91','#9AD6FF'));put('ui_ribbon_purple',rib(K.pest,'#6B2F88','#4A1F60','#B67ED3'));
return out}
