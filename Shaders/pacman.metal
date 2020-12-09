void mainImage( thread float4& fragColor, float2 fragCoord, float iTime, float3 iResolution)
{
    fragCoord.y = iResolution.y - fragCoord.y - 1;
    // Normalized pixel coordinates (from 0 to 1)
    float2 uv = fragCoord/iResolution.xy;

    // Time varying pixel color
    float2 pos = float2(uv.x*20.0-10.0,uv.y*20.0-10.0);
    float x = pos.x;
    float y = pos.y*0.6;
    float2 eyeOffset = float2(-0.2,-1.5);
    float open = sin(iTime*10.0) * 0.2 + 1.2;
    float value = ((x*x + y*y) < 11.0 && atan2(y,x)<3.14*0.8*open && atan2(y,x)>-3.14*0.8*open &&
                   ((x+eyeOffset.x)
                     *(x+eyeOffset.x)+(y+eyeOffset.y)*(y+eyeOffset.y))>0.2) ? 1.0 : 0.0;
    fragColor = float4(value,value,0.0,1.0);
}
