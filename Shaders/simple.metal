void mainImage(thread float4& fragColor, float2 fragCoord, float iTime, float3 iResolution) {
  float2 uv = fragCoord / iResolution.xy;
  float3 col = 0.5 + 0.5*cos(iTime + uv.xyx + float3(0, 2, 4));
  
  fragColor = float4(col[0], col[1], col[2], 1);
}