//
//  ShaderViewController.swift
//  MetalToy
//
//  Created by Jan Maes on 07/12/2020.
//

import UIKit
import MetalKit

class ShaderViewController: UIViewController {

  var renderer: Renderer?
  var shaderText: String?
  
  var metalView: MTKView {
    return view as! MTKView
  }
  
  func setShader( text: String?) {
    shaderText = text
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    metalView.device = MTLCreateSystemDefaultDevice()
    //metalView.clearColor = Colors.green
    if let device = metalView.device {
      renderer = Renderer.init(device: device, shaderText: shaderText)
      metalView.delegate = renderer
    }
  }
  
  @IBAction func onBack(_ sender: Any) {
  self.dismiss(animated: true, completion: nil)
  }
  
}
