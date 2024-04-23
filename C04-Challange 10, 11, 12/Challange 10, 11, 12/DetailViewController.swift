//
//  DetailViewController.swift
//  Challange 10, 11, 12
//
//  Created by Aleksandra Sobot on 11.12.23..
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var detailLabelView: UILabel!
    
    var selectedPhoto: Photo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photoToLoad = selectedPhoto?.photo {
            if let captionToLoad = selectedPhoto?.name {
//                print(photoToLoad)
                let imagePath = getDocumentsDirectory().appendingPathComponent(photoToLoad)
                detailImageView.image = UIImage(contentsOfFile: imagePath.path)
                detailLabelView.text = captionToLoad
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
    


