//
//  ViewController.swift
//  Project 1
//
//  Created by Aleksandra Sobot on 26.1.23..
//

import UIKit

class ViewController: UICollectionViewController {
    
    var pictures = [Picture]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Storm Viewer"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        let defaults = UserDefaults.standard
        if let savedPictures = defaults.object(forKey: "pictures") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                pictures = try jsonDecoder.decode([Picture].self, from: savedPictures)
            } catch {
                print("Failed to load pictures.")
            }
        }
        
        performSelector(inBackground: #selector(loadPictures), with: nil)
    }
    
    @objc func loadPictures() {
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)
        
            for item in items {
                if item.hasPrefix("nssl") {
                    //
                    let picture = Picture(image: item, title: item, subtitle: "Views: 0", timesShown: 0)
                    pictures.append(picture)
                    save()
                }
            }
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
     
//        collectionView.performSelector(onMainThread: #selector(UICollectionView.reloadData), with: self, waitUntilDone: false)
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCell else {
            fatalError("Unable to dequeue Picture cell")
        }
        let picture = pictures[indexPath.item]
        cell.image.image = UIImage(named: picture.image)
        cell.title.text = picture.title
        cell.subtitle.text = picture.subtitle
        
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.layer.cornerRadius = 5
        
        cell.image.layer.borderWidth = 1
        cell.image.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.image.layer.cornerRadius = 7
        return cell
    }
   
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            vc.selectedImage = pictures[indexPath.item]
//            vc.selectedPictureNumber = indexPath.item + 1
            vc.totalPictures = pictures.count
            pictures[indexPath.item].timesShown += 1
            save()
            collectionView.reloadItems(at: [indexPath])
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }
    
    
    @objc func shareTapped() {
        let items = ["Share this app"]
        
        let vc = UIActivityViewController(activityItems: items, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedData, forKey: "pictures")
        } else {
            print("Unable to save pictures.")
        }
    }
    
  
    
}

