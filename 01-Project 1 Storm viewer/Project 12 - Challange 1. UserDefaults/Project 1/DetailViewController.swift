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
//    var selectedPictureNumber: Int?
    var totalPictures: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(selectedImage?.title ?? "") was shown \(selectedImage?.timesShown ?? 0) times."
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
