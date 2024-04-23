//
//  ActionViewController.swift
//  Extension
//
//  Created by Aleksandra Sobot on 18.1.24..
//

import UIKit
import MobileCoreServices
import UniformTypeIdentifiers

class ActionViewController: UIViewController {

    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    var userScript = [UserScript]()

    var examples = [
        (name: "Display an alert",
         script: "alert(document.title)"
        )]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(selectScript))
        
//        navigationController?.isToolbarHidden = false
//        let createNewScriptButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(createNewScript))
//
//        toolbarItems = [createNewScriptButton]
//        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ajustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ajustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
       
    
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    [weak self] (dict, error) in
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""
                    
                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
        
    }
    
    // Challange 1 - Creating UIAlert that lists all prewritten scripts when tapped
    @objc func selectScript() {
        let ac = UIAlertController(title: "Select", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        for (name, script) in examples {
            ac.addAction(UIAlertAction(title: name, style: .default) { [weak self] _ in
                self?.script.text = script
            })
        }
      
              present(ac, animated: false)
    }
    
////     Challange 2 - Giving funcionality to the user to create a new script
//    @objc func createNewScript() {
//        let ac = UIAlertController(title: "Create new script", message: nil, preferredStyle: .alert)
//        ac.addTextField { (textField) in
//           textField.placeholder = "Name your script"
//        }
//        
//        ac.addAction(UIAlertAction(title: "OK", style: .default) {
//            [weak self] _ in
//            guard let scriptName = ac.textFields?[0].text, !scriptName.isEmpty else { self?.showCustomAlert(title: "Name can not be empty!", message: "Please try again"); return }
//            guard let scriptText = self?.script.text, !scriptText.isEmpty else { return }
//            self?.userScript.append(UserScript(name: scriptName, script: scriptText))
//           
//          
//            
//        })
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
//        present(ac, animated: true)
//       
//    }
    
    func showCustomAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
  
    @IBAction func done() {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
  
    }
    
    @objc func ajustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenAndFrame = keyboardValue.cgRectValue
        let keyboardViewAndFrame = view.convert(keyboardScreenAndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewAndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
    }
}
