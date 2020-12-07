//
//  ViewController.swift
//  MetalToy
//
//  Created by Jan Maes on 07/12/2020.
//

import UIKit
import UniformTypeIdentifiers

class ViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  @IBAction func onLoad(_ sender: Any) {
    DispatchQueue.main.async {
      let documentPicker =
        UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item]	)
      documentPicker.delegate = self
      self.present(documentPicker, animated: true, completion: nil)
    }
  }
  
  
  @IBAction func onSave(_ sender: Any) {
    DispatchQueue.main.async {
      let documentBrowser =
        UIDocumentBrowserViewController(forOpening: [UTType.item]	)
      documentBrowser.allowsDocumentCreation = true
      documentBrowser.delegate = self
      self.present(documentBrowser, animated: true, completion: nil)
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
    do { file.stopAccessingSecurityScopedResource() }
  }
  
  public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    controller.dismiss(animated: true)
  }
}

extension ViewController: UIDocumentBrowserViewControllerDelegate {
  
  func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void)
  {
    
    let tempDir = FileManager.default.temporaryDirectory
    let url = tempDir.appendingPathComponent("MetalShader.frag")
    
    do {
      try self.textView.text.write(to: url, atomically: false, encoding: .utf8)
    }
    catch {
      // Cancel document creation.
      importHandler(nil, .none)
      return
    }
    
    // Pass the document's temporary URL to the import handler.
    importHandler(url, .move)
    
    self.dismiss(animated: true)
  }
  
}

