void mainImage(thread float4& fragColor, float2 fragCoord, float iTime, float3 iResolution) {
  
  fragCoord.y = iResolution.y - fragCoord.y - 1;
  
  float2 p = (2.0*fragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x);
  
	p.y -= 0.25;
	 
	// background color
	float3 bcol = float3(1.0,0.8,0.7-0.07*p.y)*(1.0-0.25*length(p));
	 
	// animate
	float tt = fmod(iTime,1.5)/1.5;
	float ss = pow(tt,.2)*0.5 + 0.5;
	ss = 1.0 + ss*0.5*sin(tt*6.2831*3.0 + p.y*0.5)*exp(-tt*4.0);
	p *= float2(0.5,1.5) + ss*float2(0.5,-0.5);
	 
	 
	// shape
	float a = atan2(p.x,p.y)/3.141593;
	float r = length(p);
	float h = abs(a);
	float d = (13.0*h - 22.0*h*h + 10.0*h*h*h)/(6.0-5.0*h);
	 
	// color
	float s = 1.0-0.5*clamp(r/d,0.0,1.0);
	s = 0.75 + 0.75*p.x;
	s *= 1.0-0.25*r;
	s = 0.5 + 0.6*s;
	s *= 0.5+0.5*pow( 1.0-clamp(r/d, 0.0, 1.0 ), 0.1 );
	float3 hcol = float3(1.0,0.5*r,0.3)*s;
	 
	float3 col = mix( bcol, hcol, smoothstep( -0.01, 0.01, d-r) );
	 
	fragColor = float4(col,1.0);
}