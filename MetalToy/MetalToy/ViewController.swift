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
  
  var renderer: Renderer?
  
  var metalView: MTKView {
    return view as! MTKView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    metalView.device = MTLCreateSystemDefaultDevice()
    metalView.clearColor = Colors.green
    if let device = metalView.device {
      renderer = Renderer.init(device: device)
      metalView.delegate = renderer
    }
  }
  
  
}


