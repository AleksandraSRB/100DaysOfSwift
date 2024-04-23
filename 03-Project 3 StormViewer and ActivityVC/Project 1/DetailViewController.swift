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
    var selectedPictureNumber = 0
    var totalPictures = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image \(selectedPictureNumber) of \(totalPictures)"
        navigationItem.largeTitleDisplayMode = .never
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))

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
    // Challange 1
    @objc func shareTapped(){
        guard let image = imageView?.image else {
            print("No image found")
            return
        }
        // Project 27, Challange 3
        addTextToImage(image: image)
                
        let vc = UIActivityViewController(activityItems: [image, selectedImage!], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    // Project 27, Challange 3
    func addTextToImage(image: UIImage) {
        
        var width: CGFloat!
        var height: CGFloat!
        
        if let size = imageView.image?.size {
            width = size.width
            height = size.height
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        
        let image = renderer.image { ctx in
            
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 36),
                .strokeColor: UIColor.black.cgColor
            ]
            
            let string = "From Storm Viewer"
            let attributedString = NSAttributedString(string: string, attributes: attributes)
            
            attributedString.draw(with: CGRect(x: 50, y: 80, width: width, height: height), options: .usesLineFragmentOrigin, context: nil)
        }
        imageView.image = image
    }
}
