//
//  Shader.metal
//  MetalToy
//
//  Created by Jan Maes on 07/12/2020.
//

#include <metal_stdlib>
using namespace metal;

struct Constants {
  float animateBy;
};

vertex float4 vertex_shader(const device packed_float3 *vertices [[buffer(0)]], constant Constants& constants [[buffer(1)]], uint vertexId [[ vertex_id ]]) {
  float4 position = float4(vertices[vertexId], 1);
  position.x += constants.animateBy;
  return position;
}

fragment half4 fragment_shader() {
  return half4(1, 1, 0, 1);
}
