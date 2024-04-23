//
//  DetailViewController.swift
//  Project 1,2,3 Challange 2
//
//  Created by Aleksandra Sobot on 19.2.23..
//

import UIKit

class DetailViewController: UIViewController {
    
    
    @IBOutlet var imageView: UIImageView!
    
    var selectedCountry: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageToLoad = selectedCountry {
            imageView.image = UIImage(named: imageToLoad)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    @objc func shareTapped(){
        guard let image = imageView.image?.pngData() else {
            print("No image found")
            return
        }
        let vc = UIActivityViewController(activityItems: [image, selectedCountry?.deletingSuffix(".png").capitalized ?? ""], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    

}
