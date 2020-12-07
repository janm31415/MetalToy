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
    do {
      if let device = metalView.device {
        try renderer = Renderer.init(device: device, shaderText: shaderText)
        metalView.delegate = renderer
      }
    }
    catch (let error as MTLLibraryError) {
      DispatchQueue.main.async {
        let alert = UIAlertController(title: "Compile error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
          NSLog("The \"OK\" alert occured.")
          self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
      }
    }
    catch {
    }
  }
  
  @IBAction func onBack(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
}
