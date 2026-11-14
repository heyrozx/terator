// signature strokes in CSS px, centred around (cx, cy)
module.exports=(cx=192,cy=360)=>{
  const S=[];
  // stroke 1: tall "B"-ish entry then loops
  let s=[]; 
  for(let i=0;i<=14;i++){ s.push([cx-80+ i*0.6, cy+35 - i*6]); }           // up-stroke
  for(let i=0;i<=24;i++){ const a=-Math.PI/2+ i/24*Math.PI*1.0; s.push([cx-72+Math.cos(a)*22, cy-27+ (i/24)*30 + Math.sin(a)*14]); } // upper bowl
  for(let i=0;i<=24;i++){ const a=-Math.PI/2+ i/24*Math.PI*1.1; s.push([cx-74+Math.cos(a)*28, cy+12+ (i/24)*20 + Math.sin(a)*16]); } // lower bowl
  // running loops
  const th0=0, th1=Math.PI*2*4.2; const N=110;
  const x0=s[s.length-1][0], y0=s[s.length-1][1];
  for(let i=1;i<=N;i++){ const th=th0+(th1-th0)*i/N; const env=1-0.35*i/N;
    s.push([x0+ th*6.2 - 11*Math.sin(th), y0 -4 - 26*env*(0.5-0.5*Math.cos(th)) - i*0.12]); }
  S.push(s);
  // stroke 2: underline flourish
  s=[]; for(let i=0;i<=50;i++){ const t=i/50; s.push([cx-95+ t*205, cy+48 - 18*Math.sin(t*Math.PI)*0.6 - t*16 + 4*Math.sin(t*Math.PI*3)]); }
  S.push(s);
  // stroke 3: dot
  S.push([[cx+92,cy-34],[cx+93,cy-35],[cx+94,cy-34]]);
  return S;
};
