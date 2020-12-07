//
//  ViewController.swift
//  MetalToy
//
//  Created by Jan Maes on 07/12/2020.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController {
  
  var loading = false
  var saving = false
  
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func onLoad(_ sender: Any) {
    loading = true
    saving = false
    DispatchQueue.main.async {
      let documentPicker =
        UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item]	)
      documentPicker.delegate = self
      self.present(documentPicker, animated: true, completion: nil)
    }
  }
  
  
  @IBAction func onSave(_ sender: Any) {
    loading = false
    saving = true
    DispatchQueue.main.async {
      let documentPicker =
        UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item]	)
      documentPicker.delegate = self
      self.present(documentPicker, animated: true, completion: nil)
    }
  }
  
  @IBAction func onRun(_ sender: Any) {
    DispatchQueue.main.async {
      let shaderVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "shaderVC") as! ShaderViewController
      shaderVC.setShader(text: self.textView.text)
      self.present(shaderVC, animated: true)
    }
  }
}

extension ViewController: UIDocumentPickerDelegate {
  
  public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
   
    let file = urls[0]
    
    if (self.loading) {
      guard file.startAccessingSecurityScopedResource() else {
        // Handle the failure here.
        return
      }
    do {
      let data = try Data(contentsOf: file, options: .mappedIfSafe)
      let str = String(decoding: data, as: UTF8.self)
      self.textView.text = str
      }
    catch {
      return
    }
    }
  }
  
  public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    controller.dismiss(animated: true)
  }
}


