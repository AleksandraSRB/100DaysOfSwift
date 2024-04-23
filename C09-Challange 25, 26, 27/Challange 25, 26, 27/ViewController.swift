//
//  ViewController.swift
//  Challange 25, 26, 27
//
//  Created by Aleksandra Sobot on 27.3.24..
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet var imageView: UIImageView!
    
    var memeString: String?
    var isTop: Bool!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPicture))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
    }
    
    @IBAction func bottomTextTapped(_ sender: Any) {
        
        let ac = UIAlertController(title: "Create a meme", message: nil, preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = "Type meme text"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.memeString = ac.textFields?[0].text
            if self?.memeString != nil {
                self?.addTextToImage(text: self?.memeString, isTop: false)
            } else {
                self?.memeString = nil
            }})
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    @IBAction func topTextTapped(_ sender: Any) {
        let ac = UIAlertController(title: "Create a meme", message: nil, preferredStyle: .alert)
        ac.addTextField { (textfield) in
            textfield.placeholder = "Type meme text"
        }
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.memeString = ac.textFields?[0].text
            if self?.memeString != nil {
                self?.addTextToImage(text: self?.memeString, isTop: true)
            } else {
                self?.memeString = nil
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func addTextToImage(text: String?, isTop: Bool) {
        
        guard let image = imageView.image else { return }
        
        var width: CGFloat!
        var height: CGFloat!
        
        if let size = imageView.image?.size {
            width = size.width
            height = size.height
        }
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))

        let rendereredImage = renderer.image { ctx in
            
            image.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
          
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            
            let attributes: [NSAttributedString.Key: Any] = [
                .paragraphStyle: paragraphStyle,
                .font: UIFont.systemFont(ofSize: 50, weight: .heavy),
                .strokeColor: UIColor.yellow.cgColor,
                .foregroundColor: UIColor.yellow.cgColor
                
            ]
            
            if let string = memeString {
                let attributedString = NSAttributedString(string: string, attributes: attributes)
                
                if isTop {
                    attributedString.draw(with: CGRect(x: 0, y: 0, width: width, height: height), options: .usesLineFragmentOrigin, context: nil)
                } else {
                    attributedString.draw(with: CGRect(x: 0, y: height - 100, width: width, height: height), options: .usesLineFragmentOrigin, context: nil)
                }
            }
        }
        imageView.image = rendereredImage
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        
        imageView.image = image
    }
    
    @objc func addPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    @objc func shareTapped(){
        
        guard let image = imageView?.image?.jpegData(compressionQuality: 0.8) else {
            print("No image found")
            return
        }
        guard let meme = memeString else { return }
        
        let vc = UIActivityViewController(activityItems: [image, meme], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
}

