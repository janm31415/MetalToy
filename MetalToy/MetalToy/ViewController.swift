//
//  ViewController.swift
//  MetalToy
//
//  Created by Jan Maes on 07/12/2020.
//

import UIKit


class ViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
   
  }
  
  @IBAction func onLoad(_ sender: Any) {
  }
  
  
  @IBAction func onSave(_ sender: Any) {
  }
  
  @IBAction func onRun(_ sender: Any) {
    DispatchQueue.main.async {
      let shaderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shaderVC") as! ShaderViewController
      shaderVC.setShader(text: self.textView.text)
      self.present(shaderVC, animated: true)
    }
  }
}


