//
//  DetailViewController.swift
//  Project 1
//
//  Created by Aleksandra Sobot on 12.2.23..
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: Picture?
    var selectedPictureNumber = 0
    var totalPictures = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        title = "This image is \(selectedImage?.title ?? "")"
        navigationItem.largeTitleDisplayMode = .never

        if let imageToLoad = selectedImage?.image {
            imageView.image = UIImage(named: imageToLoad)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }

}
