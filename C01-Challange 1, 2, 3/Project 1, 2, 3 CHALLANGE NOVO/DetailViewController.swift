//
//  DetailViewController.swift
//  Project 1, 2, 3 CHALLANGE NOVO
//
//  Created by Aleksandra Sobot on 17.10.23..
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: String?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "This is \(selectedImage?.deletingSuffix(".png").capitalized ?? "")"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
 
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
        } else {
            print("No image to show")
        }
        
        imageView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
    @objc func shareTapped(){
        
        let share = ["Share picture of \(selectedImage!)"]
        
        let vc = UIActivityViewController(activityItems: share, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
        
    }
    
    }
    
extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self } // if string has no prefix return self as we are
        return String(self.dropFirst(prefix.count)) // if string has prefix, drop the prefix of a string and we will send that back
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}
