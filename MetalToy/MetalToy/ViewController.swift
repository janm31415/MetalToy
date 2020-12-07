//
//  ViewController.swift
//  MetalToy
//
//  Created by Jan Maes on 07/12/2020.
//

import UIKit
import MetalKit

enum Colors {
  static let green = MTLClearColor(red: 0.0,
                                   green: 0.4,
                                   blue: 0.21,
                                   alpha: 1.0)

}

class ViewController: UIViewController {
  
  var metalView: MTKView {
    return view as! MTKView
  }
  
  var device: MTLDevice!
  var commandQueue: MTLCommandQueue!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    metalView.device = MTLCreateSystemDefaultDevice()
    device = metalView.device
    
    metalView.clearColor = Colors.green
    
    commandQueue = device.makeCommandQueue()
    let commandBuffer = commandQueue.makeCommandBuffer()
    
    let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: metalView.currentRenderPassDescriptor!)
    
    commandEncoder?.endEncoding()
    commandBuffer?.present(metalView.currentDrawable!)
    commandBuffer?.commit()
  }
  
  
}

