// Партия H: ассеты HUD. После gen/.../fx/ui.
function hudSheets(){
const S=STY.a,s=small(S),out={},p='assets/h/',put=(n,v)=>out[p+n+'.svg']=v;
const svg=(w,h,b)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${b}</svg>`;
const WELL='#4A4858',NAVY='#3F3D55';
put('ui_joystick_base',svg(256,256,`<circle cx="128" cy="128" r="120" fill="${O}" fill-opacity=".28" stroke="#FFFFFF" stroke-opacity=".6" stroke-width="6"/>`+[0,90,180,270].map(a=>`<path d="M128 24L142 40H114Z" fill="#FFFFFF" fill-opacity=".6" transform="rotate(${a} 128 128)"/>`).join('')));
put('ui_joystick_stick',svg(128,128,`<circle cx="64" cy="64" r="58" fill="#FFFFFF" fill-opacity=".75" stroke="${O}" stroke-opacity=".55" stroke-width="5"/><circle cx="64" cy="64" r="42" fill="none" stroke="${O}" stroke-opacity=".15" stroke-width="4"/><path d="M34 48A33 33 0 0 1 50 31" fill="none" stroke="#FFFFFF" stroke-width="7" stroke-linecap="round"/>`));
put('ui_boss_hp_frame',svg(512,64,`<path d="${RR(2,2,508,60,30)}" fill="${WELL}" stroke="${O}" stroke-width="4"/><path d="${RR(28,8,456,6,3)}" fill="#3A3848"/>`));
put('ui_boss_hp_fill',svg(496,44,`<path d="${RR(0,0,496,44,22)}" fill="#C23B30"/><path d="${RR(0,0,496,35,[22,22,17,17])}" fill="#F0584A"/><path d="${RR(20,7,456,6,3)}" fill="#FF9A8F"/>`));
const rib=(a,b,c,h)=>svg(384,112,`<path d="${RP([[4,44],[84,44],[84,100],[4,100],[22,72]],3)}" fill="${b}" stroke="${O}" stroke-width="4" stroke-linejoin="round"/><path d="${RP([[380,44],[300,44],[300,100],[380,100],[362,72]],3)}" fill="${b}" stroke="${O}" stroke-width="4" stroke-linejoin="round"/><path d="M62 78H84V100Z" fill="${c}" stroke="${O}" stroke-width="3" stroke-linejoin="round"/><path d="M322 78H300V100Z" fill="${c}" stroke="${O}" stroke-width="3" stroke-linejoin="round"/><path d="${RR(60,8,264,74,12)}" fill="${b}" stroke="${O}" stroke-width="4"/><path d="${RR(62,10,260,62,10)}" fill="${a}"/><path d="${RR(78,16,228,6,3)}" fill="${h}"/>`);
put('ui_ribbon_boss',rib('#F0584A','#C23B30','#8E2A22','#FF9A8F'));
const slot=(a,b,hc)=>svg(128,128,`<path d="${RR(8,4,112,120,56)}" fill="${b}" stroke="${O}" stroke-width="4"/><path d="${E(64,60,54)}" fill="${a}"/><path d="M${f(64-56*.62)} ${f(60-56*.36)}A${f(56*.72)} ${f(56*.72)} 0 0 1 ${f(64-56*.25)} ${f(60-56*.68)}" fill="none" stroke="${hc}" stroke-width="5" stroke-linecap="round"/>`);
put('ui_radial_slot',slot('#FFF4DC','#E3C999','#FFFFFF'));put('ui_radial_slot_locked',slot('#B9B6C2','#8F8C9A','#DAD8E0'));
put('ui_price_tag',svg(128,44,`<path d="${RR(2,2,124,40,20)}" fill="${NAVY}" stroke="${O}" stroke-width="4"/><path d="${RR(24,7,80,4,2)}" fill="#5E5B78"/>`));
put('ui_icon_clock',doc(64,64,s,[{ds:[E(32,34,25)],fill:'#4FB0F0',r:14,hl:[21,22,4,2.4,-35]},{ds:[E(32,34,18)],fill:'#FFFFFF',line:2.5,sh:false,mark:[`<path d="M32 34V22M32 34L41 39" stroke="${O}" stroke-width="3.5" stroke-linecap="round"/>`]},{ds:[RR(26,4,12,7,3)],fill:'#4FB0F0',r:3}]));
put('ui_icon_parcel',doc(64,64,s,[...crateIt(32,58,1.15),{ds:[spk(10,14,5),spk(54,10,4)],fill:'#FFF0B0',line:2,sh:false}]));
return out}
