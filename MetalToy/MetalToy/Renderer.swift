//
//  Renderer.swift
//  MetalToy
//
//  Created by Jan Maes on 07/12/2020.
//

import MetalKit

class Renderer : NSObject {

  let device: MTLDevice
  let commandQueue: MTLCommandQueue?
  
  var vertices: [Float] = [
  -1, 1, 0,
  -1, -1, 0,
  1, -1, 0,
  1, 1, 0,
  ]
  
  var indices: [UInt16] = [
  0,1,2,
  2,3,0]
  
  var pipelineState: MTLRenderPipelineState?
  var vertexBuffer: MTLBuffer?
  var indexBuffer: MTLBuffer?
  
  struct ShaderInput {
    var iTime: Float = 0.0
    var iResolution_x: Float = 640.0
    var iResolution_y: Float = 480.0
    var iResolution_z: Float = 1.0
  }
  
  var shaderInput = ShaderInput()
  
  var time: Float = 0
  
  init(device: MTLDevice, shaderText: String?) {
    self.device = device
    self.commandQueue = device.makeCommandQueue()
    super.init()
    buildModel()
    buildPipelineState(shaderText: shaderText)
  }
  
  private func buildModel() {
    vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
    indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
  }
  
  private func buildPipelineState(shaderText: String?) {
    
    let header = NSString.init(stringLiteral:
"""
using namespace metal;

struct ShaderInput {
  float iTime;
  packed_float3 iResolution;
};

struct VertexOut {
  float4 position [[position]];
};

vertex VertexOut vertex_shader(const device packed_float3 *vertices [[buffer(0)]], uint vertexId [[ vertex_id ]]) {
  VertexOut out;
  out.position = float4(vertices[vertexId], 1);
  return out;
}
""")
let footer = NSString.init(stringLiteral:
"""
fragment half4 fragment_shader(const VertexOut pos [[stage_in]], constant ShaderInput& input [[buffer(1)]]) {
  float4 fragColor;
  mainImage(fragColor, pos.position.xy, input.iTime, input.iResolution);
  return half4(fragColor[0], fragColor[1], fragColor[2], 1);
}
""")

  var shader: NSString = ""
     
  if let txt = shaderText {
    shader = NSString(format: "%@%@%@", header, txt, footer)
    }

let string = NSString.init(stringLiteral:
"""
using namespace metal;

struct ShaderInput {
  float iTime;
  packed_float3 iResolution;
};

struct VertexOut {
  float4 position [[position]];
};

vertex VertexOut vertex_shader(const device packed_float3 *vertices [[buffer(0)]], uint vertexId [[ vertex_id ]]) {
  VertexOut out;
  out.position = float4(vertices[vertexId], 1);
  return out;
}

// simple
void mainImage(thread float4& fragColor, float2 fragCoord, float iTime, float3 iResolution) {
  float2 uv = fragCoord / iResolution.xy;
  float3 col = 0.5 + 0.5*cos(iTime + uv.xyx + float3(0, 2, 4));
  
  fragColor = float4(col[0], col[1], col[2], 1);
}

// plasma
void mainImage2(thread float4& fragColor, float2 fragCoord, float iTime, float3 iResolution) {
  float2 uv = (fragCoord / iResolution.xy - 0.5)*8.0;
  float i0 = 0.8;
  float i1 = 0.8;
  float i2 = 0.75;
  float i4 = 0.0;
  for (int s = 0; s < 7; s++)
  {
    float2 r = float2(cos(uv.y*i0-i4-iTime/i1), sin(uv.x*i0-i4+iTime/i1))/i2;
    r = r + float2(-r.y, r.x)*0.3;
    uv.xy += r;
    i0 *= 1.93;
    i1 *= 1.15;
    i2 *= 1.7;
    i4 += 0.05+0.1*iTime*i1;
  }
  float b = sin(uv.x - iTime)*0.5+0.5;
  float r = sin(uv.y + iTime)*0.5 + 0.5;
  float g = sin((uv.x + uv.y + sin(iTime*0.5))*0.5)*0.5 + 0.5;
  fragColor = float4(r, g, b, 1);
}

// heart
void mainImage3(thread float4& fragColor, float2 fragCoord, float iTime, float3 iResolution) {
  
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

fragment half4 fragment_shader(const VertexOut pos [[stage_in]], constant ShaderInput& input [[buffer(1)]]) {
  float4 fragColor;
  mainImage3(fragColor, pos.position.xy, input.iTime, input.iResolution);
  return half4(fragColor[0], fragColor[1], fragColor[2], 1);
}
""")


    let library: MTLLibrary
    do {
      library = try device.makeLibrary(source: shader as String, options: nil)
    }
    catch (let error as MTLLibraryError) {
      print(error)
      return
    }
    catch {
      print("unknown error")
      return
    }
    let vertexFunction = library.makeFunction(name: "vertex_shader")
    let fragmentFunction = library.makeFunction(name: "fragment_shader")
    
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
    
    do {
      pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error as NSError {
      print("error: \(error.localizedDescription)")
    }
  }
}


extension Renderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    
  }
  
  func draw(in view: MTKView) {
    guard let drawable = view.currentDrawable,
      let pipelineState = pipelineState,
      let indexBuffer = indexBuffer,
      let descriptor = view.currentRenderPassDescriptor else {
      return
    }
    
    let commandBuffer = commandQueue?.makeCommandBuffer()
    
    time += 1 / Float(view.preferredFramesPerSecond)
    
    shaderInput.iTime = time;
    shaderInput.iResolution_x = Float(view.drawableSize.width)
    shaderInput.iResolution_y = Float(view.drawableSize.height)
    
    
    let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
    commandEncoder?.setRenderPipelineState(pipelineState)
    commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    commandEncoder?.setFragmentBytes(&shaderInput, length: MemoryLayout<ShaderInput>.stride, index: 1)
    commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
    commandEncoder?.endEncoding()
    commandBuffer?.present(drawable)
    commandBuffer?.commit()
  }
  
}
