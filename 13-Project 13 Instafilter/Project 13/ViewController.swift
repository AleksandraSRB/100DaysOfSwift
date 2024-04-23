//
//  ViewController.swift
//  Project 13
//
//  Created by Aleksandra Sobot on 13.12.23..
//

import CoreImage
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    //Challange 2
    @IBOutlet var filterButton: UIButton!
    // Challange 3
    @IBOutlet var radius: UISlider!
    
    var currentImage: UIImage!
    var context: CIContext!
    var currentFilter: CIFilter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Instantfilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
        
        context = CIContext()
        currentFilter = CIFilter(name: "CISepiaTone")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        // Project 15, Challange 2 - Make image view fade whan image is chosen
        imageView.alpha = 0
        dismiss(animated: true)
        currentImage = image
        
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            // Project 15, Challange 2 - Make image view fade whan image is chosen
                self.imageView.alpha = 1
        })

        let beginImage = CIImage(image: currentImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }

    @IBAction func changeFilter(_ sender: UIButton) {
        let ac = UIAlertController(title: "Choose filter", message: nil, preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "CIBumbDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIGaussianBlur", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIPixellate", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CISepiaTone", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CITwirlDistortion", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIUnsharpMask", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "CIVignette", style: .default, handler: setFilter))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if let popoverController = ac.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
        }
        
        present(ac, animated: true)
    }
    
    func setFilter(action: UIAlertAction) {
        guard currentImage != nil else { return }
        guard let actionTitle = action.title else { return }
                
        currentFilter = CIFilter(name: actionTitle)
       
        let beginImage = CIImage(image: currentImage)
        
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        // Challange 2
        filterButton.setTitle(actionTitle, for: .normal)
        
        applyProcessing()
    }
    
    @IBAction func save(_ sender: Any) {
        // Challange 1
        guard let image = imageView.image else {
            let ac = UIAlertController(title: "No photo chosen", message: "Please select photo you would like to save", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            return
        }
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError: contextInfo:)), nil)
        }
    
    @IBAction func intensityChanged(_ sender: Any) {
        applyProcessing()
    }
    
    // Challange 3
    @IBAction func radiusChanged(_ sender: Any) {
        applyProcessing()
    }
    
    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(intensity.value, forKey: kCIInputIntensityKey)
        }
        if inputKeys.contains(kCIInputRadiusKey) {
            // Challange 3
            currentFilter.setValue(CGFloat(radius.value) * 200, forKey: kCIInputRadiusKey)
        }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(intensity.value * 10, forKey: kCIInputScaleKey)
        }
        if inputKeys.contains(kCIInputCenterKey) {
            currentFilter.setValue(CIVector(x: currentImage.size.width / 2, y: currentImage.size.height / 2), forKey: kCIInputCenterKey)

        }
        
        guard let outputImage = currentFilter.outputImage else { return }
        
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            imageView.image = processedImage
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your edited photo has been saved to your photo library", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}

