//
//  DetailViewController.swift
//  Project 1
//
//  Created by Aleksandra Sobot on 12.2.23..
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var imageView: UIImageView!
    
    var selectedImage: String?
    // Challange 3. Showing title "picture X of Y", where Y is total number of pictures, and X is selected picture
    var selectedPictureNumber = 0
    var totalPictures = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(selectedImage != nil, "selectedImage doesn't have value.")
        
//        title = "This image is \(selectedImage ?? "")"
        title = "This image is \(selectedPictureNumber) of \(totalPictures)"
        navigationItem.largeTitleDisplayMode = .never

        if let imageToLoad = selectedImage {
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
