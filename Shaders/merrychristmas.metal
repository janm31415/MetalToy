// Merry Christmas! by @paulofalcao

//Util Start

constant float PI=3.14159265;

float2 ObjUnion(float2 obj0,float2 obj1){
  if (obj0.x<obj1.x)
    return obj0;
  else
    return obj1;
}

float3 sim(float3 p,float s){
   float3 ret=p;
   ret=p+s/2.0;
   ret=fract(ret/s)*s-s/2.0;
   return ret;
}

float2 rot(float2 p,float r){
   float2 ret;
   ret.x=p.x*cos(r)-p.y*sin(r);
   ret.y=p.x*sin(r)+p.y*cos(r);
   return ret;
}

float2 rotsim(float2 p,float s){
   float2 ret=p;
   ret=rot(p,-PI/(s*2.0));
   ret=rot(p,floor(atan2(ret.x,ret.y)/PI*s)*(PI/s));
   return ret;
}

float rnd(float2 v){
  return sin((sin(((v.y-1453.0)/(v.x+1229.0))*23232.124))*16283.223)*0.5+0.5; 
}

float noise(float2 v){
  float2 v1=floor(v);
  float2 v2=smoothstep(0.0,1.0,fract(v));
  float n00=rnd(v1);
  float n01=rnd(v1+float2(0,1));
  float n10=rnd(v1+float2(1,0));
  float n11=rnd(v1+float2(1,1));
  return mix(mix(n00,n01,v2.y),mix(n10,n11,v2.y),v2.x);
}

//Util End

 
//Scene Start
 
//Floor
float2 obj0( float3 p){
  if (p.y<0.4)
  p.y+=sin(p.x)*0.4*cos(p.z)*0.4;
  return float2(p.y,0);
}

float3 obj0_c(float3 p){
  float f=
    noise(p.xz)*0.5+
    noise(p.xz*2.0+13.45)*0.25+
    noise(p.xz*4.0+23.45)*0.15;
  float pc=min(max(1.0/length(p.xz),0.0),1.0)*0.5;
  return float3(f)*0.3+pc+0.5;
}

//Snow
float makeshowflake(float3 p){
  return length(p)-0.03;
}

float makeShow(float3 p,float tx,float ty,float tz, float iTime){
  p.y=p.y+iTime*tx;
  p.x=p.x+iTime*ty;
  p.z=p.z+iTime*tz;
  p=sim(p,4.0);
  return makeshowflake(p);
}

float2 obj1(float3 p, float iTime){
  float f=makeShow(p,1.11, 1.03, 1.38, iTime);
  f=min(f,makeShow(p,1.72, 0.74, 1.06, iTime));
  f=min(f,makeShow(p,1.93, 0.75, 1.35, iTime));
  f=min(f,makeShow(p,1.54, 0.94, 1.72, iTime));
  f=min(f,makeShow(p,1.35, 1.33, 1.13, iTime));
  f=min(f,makeShow(p,1.55, 0.23, 1.16, iTime));
  f=min(f,makeShow(p,1.25, 0.41, 1.04, iTime));
  f=min(f,makeShow(p,1.49, 0.29, 1.31, iTime));
  f=min(f,makeShow(p,1.31, 1.31, 1.13, iTime));  
  return float2(f,1.0);
}
 
float3 obj1_c(float3 p){
    return float3(1,1,1);
}


//Star
float2 obj2(float3 p){
  p.y=p.y-4.3;
  p=p*4.0;
  float l=length(p);
  if (l<2.0){
  p.xy=rotsim(p.xy,2.5);
  p.y=p.y-2.0; 
  p.z=abs(p.z);
  p.x=abs(p.x);
  return float2(dot(p,normalize(float3(2.0,1,3.0)))/4.0,2);
  } else return float2((l-1.9)/4.0,2.0);
}

float3 obj2_c(float3 p){
  return float3(1.0,0.5,0.2);
}
 
//Objects union
float2 inObj(float3 p, float iTime){
  return ObjUnion(ObjUnion(obj0(p),obj1(p, iTime)),obj2(p));
}
 
//Scene End
 
void mainImage( thread float4& fragColor, float2 fragCoord, float iTime, float3 iResolution ){
  fragCoord.y = iResolution.y - fragCoord.y - 1;
  
  float2 vPos=-1.0+2.0*fragCoord.xy/iResolution.xy;
 
  //Camera animation
  float3 vuv=normalize(float3(sin(iTime)*0.3,1,0));
  float3 vrp=float3(0,cos(iTime*0.5)+2.5,0);
  float3 prp=float3(sin(iTime*0.5)*(sin(iTime*0.39)*2.0+3.5),sin(iTime*0.5)+3.5,cos(iTime*0.5)*(cos(iTime*0.45)*2.0+3.5));
  float vpd=1.5;  
 
  //Camera setup
  float3 vpn=normalize(vrp-prp);
  float3 u=normalize(cross(vuv,vpn));
  float3 v=cross(vpn,u);
  float3 scrCoord=prp+vpn*vpd+vPos.x*u*iResolution.x/iResolution.y+vPos.y*v;
  float3 scp=normalize(scrCoord-prp);
 
  //lights are 2d, no raymarching
  float4x4 cm=float4x4(
    u.x,   u.y,   u.z,   -dot(u,prp),
    v.x,   v.y,   v.z,   -dot(v,prp),
    vpn.x, vpn.y, vpn.z, -dot(vpn,prp),
    0.0,   0.0,   0.0,   1.0);
 
  float4 pc=float4(0,0,0,0);
  const float maxl=80.0;
  for(float i=0.0;i<maxl;i++){
  float4 pt=float4(
    sin(i*PI*2.0*7.0/maxl)*2.0*(1.0-i/maxl),
    i/maxl*4.0,
    cos(i*PI*2.0*7.0/maxl)*2.0*(1.0-i/maxl),
    1.0);
  pt=pt*cm;
  float2 xy=(pt/(-pt.z/vpd)).xy+vPos*float2(iResolution.x/iResolution.y,1.0);
  float c;
  c=0.4/length(xy);
  pc+=float4(
          (sin(i*5.0+iTime*10.0)*0.5+0.5)*c,
          (cos(i*3.0+iTime*8.0)*0.5+0.5)*c,
          (sin(i*6.0+iTime*9.0)*0.5+0.5)*c,0.0);
  }
  pc=pc/maxl;

  pc=smoothstep(0.0,1.0,pc);
  
  //Raymarching
  const float3 e=float3(0.1,0,0);
  const float maxd=15.0; //Max depth
 
  float2 s=float2(0.1,0.0);
  float3 c,p,n;
 
  float f=1.0;
  for(int i=0;i<64;i++){
    if (abs(s.x)<.001||f>maxd) break;
    f+=s.x;
    p=prp+scp*f;
    s=inObj(p, iTime);
  }
  
  if (f<maxd){
    if (s.y==0.0)
      c=obj0_c(p);
    else if (s.y==1.0)
      c=obj1_c(p);
    else
      c=obj2_c(p);
      if (s.y<=1.0){
        fragColor=float4(c*max(1.0-f*.08,0.0),1.0)+pc;
      } else{
         //tetrahedron normal   
         const float n_er=0.01;
         float v1=inObj(float3(p.x+n_er,p.y-n_er,p.z-n_er), iTime).x;
         float v2=inObj(float3(p.x-n_er,p.y-n_er,p.z+n_er), iTime).x;
         float v3=inObj(float3(p.x-n_er,p.y+n_er,p.z-n_er), iTime).x;
         float v4=inObj(float3(p.x+n_er,p.y+n_er,p.z+n_er), iTime).x;
         n=normalize(float3(v4+v1-v3-v2,v3+v4-v1-v2,v2+v4-v3-v1));
  
        float b=max(dot(n,normalize(prp-p)),0.0);
        fragColor=float4((b*c+pow(b,8.0))*(1.0-f*.01),1.0)+pc;
      }
  }
  else fragColor=float4(0,0,0,0)+pc; //background color
}
