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
  
  init(device: MTLDevice, shaderText: String?) throws {
    self.device = device
    self.commandQueue = device.makeCommandQueue()
    super.init()
    buildModel()
    do {
      try buildPipelineState(shaderText: shaderText)
    } catch (let error as MTLLibraryError)
    {
      throw error
    }
    catch {
    
    }
  }
  
  private func buildModel() {
    vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
    indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: [])
  }
  
  private func buildPipelineState(shaderText: String?) throws {
    
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
    
    let library: MTLLibrary
    do {
      library = try device.makeLibrary(source: shader as String, options: nil)
    }
    catch (let error as MTLLibraryError) {
      throw error
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
