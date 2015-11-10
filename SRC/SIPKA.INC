const s=13+256; {mys, text tabulek: zluta 13-16}
      t=s+1;
      u=t+1;
      v=u+1;

      p=24;w=23;x=22;{togl, AltM lajna, text tabulek: svetlemodra 22-24}
      q=17;{zaskrt v toglu: cervena 17}
      r=18;{zaskrt v toglu: cervena 18}

var   sipkabuf:array[0..127] of word;
const sipka:array[0..127] of word=(
             u,  s,  s,  0,  0,  0,  0,  0,
             u,  t,  t,  s,  s,  0,  0,  0,
             t,  v,  u,  t,  s,  s,  s,  0,
             t,  u,  v,  v,  t,  t,  s,  0,
             t,  u,  v,  u,  v,  t,  s,  0,
             t,  v,  u,  v,  t,  s,  0,  0,
             t,  u,  v,  u,  s,  0,  0,  0,
             t,  v,  u,  v,  t,  0,  0,  0,
             t,  u,  t,  u,  u,  s,  0,  0,
             t,  t,  s,  t,  u,  t,  0,  0,
             t,  s,  0,  s,  u,  u,  s,  0,
             t,  0,  0,  0,  t,  u,  t,  0,
             0,  0,  0,  0,  s,  u,  u,  s,
             0,  0,  0,  0,  0,  t,  u,  s,
             0,  0,  0,  0,  0,  s,  t,  s,
             0,  0,  0,  0,  0,  0,  s,  s);

      anobitmap:array[1..3*4*16] of byte=(
           x,w,  p,  p,  p,  p,  p,  p,  p,  p, w,x,
           w,w,  x,  0,  0,  0,  0,  0,  0,  x, w,w,
           p,x,  0,  0,  0,  0,  0,  0,  0,  q, x,p,
           p,0,  0,  0,  0,  0,  0,  0,  q,  r, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  r,  q, 0,p,
           p,0,  0,  0,  0,  0,  0,  q,  r,  q, 0,p,
           p,0,  0,  0,  0,  0,  0,  r,  r,  0, 0,p,
           p,0,  q,  q,  0,  0,  q,  r,  q,  0, 0,p,
           p,0,  q,  r,  q,  q,  r,  r,  0,  0, 0,p,
           p,0,  q,  r,  r,  r,  r,  q,  0,  0, 0,p,
           p,0,  0,  r,  r,  r,  r,  0,  0,  0, 0,p,
           p,0,  0,  q,  r,  r,  q,  0,  0,  0, 0,p,
           p,0,  0,  0,  q,  q,  0,  0,  0,  0, 0,p,
           p,x,  0,  0,  0,  0,  0,  0,  0,  0, x,p,
           w,w,  x,  0,  0,  0,  0,  0,  0,  x, w,w,
           x,w,  p,  p,  p,  p,  p,  p,  p,  p, w,x   );


      nebitmap:array[1..3*4*16] of byte=(
           x,w,  p,  p,  p,  p,  p,  p,  p,  p, w,x,
           w,w,  x,  0,  0,  0,  0,  0,  0,  x, w,w,
           p,x,  0,  0,  0,  0,  0,  0,  0,  0, x,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,0,  0,  0,  0,  0,  0,  0,  0,  0, 0,p,
           p,x,  0,  0,  0,  0,  0,  0,  0,  0, x,p,
           w,w,  x,  0,  0,  0,  0,  0,  0,  x, w,w,
           x,w,  p,  p,  p,  p,  p,  p,  p,  p, w,x   );

          {soupadlo: sediva 19-21}
      s0=20;
      s1=13;
      s2=22;
      s3=21;

      soupadlobitmap:array[1..3*4*16] of byte=(
           s2,s2,  s2,  s2,  s2,  s2,  s2,  s2,  s2,  s2, s2,s2,
           s1,s1,  s1,  s1,  s1,  s1,  s1,  s1,  s1,  s1, s1,s1,
           s1,s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0, s0,s1,
           s1,s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0, s0,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3,  s3, s3,s1,
           s1,s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0, s0,s1,
           s1,s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0,  s0, s0,s1,
           s1,s1,  s1,  s1,  s1,  s1,  s1,  s1,  s1,  s1, s1,s1,
           s2,s2,  s2,  s2,  s2,  s2,  s2,  s2,  s2,  s2, s2,s2   );
{}

      z0=17;
      dira:array[0..127] of byte=(
             1,  1,  1,  1,  1,  1,  1,  1,
             1,  1,  1,  1,  1,  1,  0,  1,
             1,  1, z0, z0, z0, z0,  1,  1,
             1, z0,  0,  0,  0,  0, z0,  1,
             1,  0,  0,  0,  0,  0,  0,  1,
            z0,  0,  0,  0,  0,  0,  0,  1,
            z0,  0,  0,  0,  0,  0,  0,  1,
             0,  0,  0,  0,  0,  0,  0, z0,
            z0,  0,  0,  0,  0,  0,  0,  0,
             1,  0,  0,  0,  0,  0,  0,  0,
             1, z0,  0, $0,  0,  0,  0, z0,
             1,  0,  0,  0,  0,  0,  0,  1,
             1, z0,  0,  0,  0,  0, z0,  1,
             0,  1, z0,  0,  0, z0,  1,  1,
             1,  1,  1, z0, z0,  1,  0,  1,
             1,  1,  1,  1,  1,  1,  1,  1);
