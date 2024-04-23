//
//  ViewController.swift
//  Project 28
//
//  Created by Aleksandra Sobot on 29.3.24..
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var secret: UITextView!
    
    // Challange 1.
    var saveButton: UIBarButtonItem?
    
    var password: String?
    var isPasswordSet: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ajustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ajustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        // Challange 1. - Creating "done" button which lockes the screen when tapped
        saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        navigationItem.rightBarButtonItem = saveButton
        saveButton?.isHidden = true
        
    }
    
    func unlockMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        // Challange 1 - Show button when secretMessage is unlocked
        saveButton?.isHidden = false
        
        // if there is text in textView aka secret, load that text. KeychainWrapper let's us use keychain like UserDefaults
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }
    }
    
    @objc func saveSecretMessage() {
        // bail out if textView is not visible
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        // tells us when editing is finished
        secret.resignFirstResponder()
        secret.isHidden = true
        // Challange 1 - Hide save button when app is locked
        saveButton?.isHidden = true
        title = "Nothing to see here"
    }
    
    
    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        
        // if device supports biometric authentification and if it is configured by the user
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identify yourself!"
            
            // checks biometrics
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                // we have two parameters: success and error
                [weak self] success, authentificationError in
                // pushing UI code to main thread
                DispatchQueue.main.async {
                    // if the user is authenticated, unlock secretMessage
                    if success {
                        self?.unlockMessage()
                    } else {
                        // if the user is not authenticated, show alert
                        let ac = UIAlertController(title: "Authentification failed!", message: "You could not be verified; please try again.", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(ac, animated: true)
                    }
                }
            }
            // if device does not support biometry, show alert
        } else {
            let ac = UIAlertController(title: "Biometry unavailable!", message: "Your device is not configured for biometry. Create password for authentification", preferredStyle: .alert)
            // Challange 2 - Shows allert that gives option to the user to create password
            ac.addAction(UIAlertAction(title: "Create password", style: .default, handler: createPassword))
            ac.addAction(UIAlertAction(title: "Login with password", style: .default, handler: loginWithPassword))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            
            }
        }
    
    // Challange 2 - creates and saves password in keychain
    func createPassword(action: UIAlertAction) {
        let ac = UIAlertController(title: "Create password", message: nil, preferredStyle: .alert)
        ac.addTextField { textField in
            textField.placeholder = "Type your password"
            textField.keyboardType = .asciiCapable
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let textFieldText = ac?.textFields?[0].text else { return }
            if textFieldText.isEmpty {
                self?.showNotEnoughCharactersAlert()
            } else {
                guard self?.password == textFieldText else { return }
                KeychainWrapper.standard.set(self?.password ?? "", forKey: "Password")
                self?.isPasswordSet = true
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        }
    
// Challange 2. Logs in with password
    func loginWithPassword(action: UIAlertAction) {
      
        let authAlert = UIAlertController(title: "Identify yourself!", message: nil, preferredStyle: .alert)
                
            authAlert.addTextField { textField in
                textField.placeholder = "Type your password"
                textField.keyboardType = .asciiCapable
                }
      
            authAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            guard let password = authAlert.textFields?[0].text else { return }
                if password == KeychainWrapper.standard.string(forKey: "Password") {
                        self?.unlockMessage()
                } else {
                    self?.showErrorAuthWithPasswordAlert()
                }})
                present(authAlert, animated: true)
            }
    
    func showNotEnoughCharactersAlert() {
        let ac = UIAlertController(title: "Oops, you can't leave password box empty; try again?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: createPassword))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
    }
    
    func showErrorAuthWithPasswordAlert() {
        let ac = UIAlertController(title: "Oops, wrong password; try again?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: loginWithPassword))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
    }
  
    @objc func ajustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenAndFrame = keyboardValue.cgRectValue
        let keyboardViewAndFrame = view.convert(keyboardScreenAndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewAndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
        
    }
    
}

