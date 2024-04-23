//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
    var items = [String]() // this is the array that will store the filenames to load
    // Solution 3 - deleting cache
    /*var viewControllers = [UIViewController]()*/ // create a cache of the detail view controllers for faster loading
    var dirty = false
    
    var savedImages = [UIImage]()
    
    let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Reactionist"
        
        tableView.rowHeight = 90
        tableView.separatorStyle = .none
        
        // Solution 2
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        // Challange 3.
        DispatchQueue.global().async {
            [weak self] in
            self?.loadSavedImages()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if dirty {
            // we've been marked as needing a counter reload, so reload the whole table
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        // Solution 1
        //        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "Cell")
        //
        //        if cell == nil {
        //            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        //        }
        
        // Solution 2
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // find the image for this cell, and load its thumbnail
        let currentImageIndex = indexPath.row % items.count
        cell.imageView?.image = savedImages[currentImageIndex]
        
        
        //		let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
        // Challange 1
        //        guard let path = Bundle.main.path(forResource: imageRootName, ofType: nil) else { fatalError("Could not find path")}
        //		let original = UIImage(contentsOfFile: path)
        //
        //        // Solution 2 - Creating rectange size of cell, so we could use it for new render
        //        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        //        let renderer = UIGraphicsImageRenderer(size: renderRect.size)
        //
        //		let rounded = renderer.image { ctx in
        //            // first setting shadow
        //            // Solution 1 - Setting shadow directly in context
        ////            blur 200: setts the shadow in points relative to the size of the image being drawn aka renderer
        ////            ctx.cgContext.setShadow(offset: .zero, blur: 200, color: UIColor.black.cgColor)
        ////            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: original.size))
        ////            ctx.cgContext.setShadow(offset: CGSize.zero, blur: 0, color: nil)
        //            ctx.cgContext.addEllipse(in: renderRect) // we are passing in new size
        //            // resetting the shadow
        //
        //			ctx.cgContext.clip()
        //
        //			original?.draw(in: renderRect) // passing in new size
        //		}
        
        //		cell.imageView?.image = rounded
        
        // give the images a nice shadow to make them look a bit more dramatic
        cell.imageView?.layer.shadowColor = UIColor.black.cgColor
        cell.imageView?.layer.shadowOpacity = 1
        //         shadow specified in points, relative to the size of UIImageView
        cell.imageView?.layer.shadowRadius = 10
        cell.imageView?.layer.shadowOffset = CGSize.zero
        // Sollution 2, adding UIBezierPath to draw shadow
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath
        
        // each image stores how often it's been tapped
        // Challange 3.
        let defaults = UserDefaults.standard
        cell.textLabel?.text = "\(defaults.integer(forKey: items[currentImageIndex]))"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ImageViewController()
        vc.image = items[indexPath.row % items.count]
        vc.owner = self
        
        // mark us as not needing a counter reload when we return
        dirty = false
        
        // add to our view controller cache and show
        // Solution 3 deleting cache
        //		viewControllers.append(vc)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Challange 3
    // load all the JPEGs into our array
    func loadSavedImages() {
        
        let fm = FileManager.default
        // Challange 1
        guard let path = Bundle.main.resourcePath else { fatalError("Could not find resource path")}
        
        if let tempItems = try? fm.contentsOfDirectory(atPath: path) {
            for item in tempItems {
                if item.range(of: "Large") != nil {
                    items.append(item)
                    if let cachedImage = checkCache(imageNamed: item) {
                        savedImages.append(cachedImage)
                    } else {
                        savedImages.append(generateImage(imageNamed: item))
                    }
                }
            }
            
        }
        
        func checkCache(imageNamed: String) -> UIImage? {
            let path = getDocumentsDirectory().appendingPathComponent(imageNamed)
            return UIImage(contentsOfFile: path.path)
        }
        
        
        
        // Challange 3
        func generateImage(imageNamed: String) -> UIImage {
            
            let imageRootName = imageNamed.replacingOccurrences(of: "Large", with: "Thumb")
            guard let path = Bundle.main.path(forResource: imageRootName, ofType: nil) else { fatalError("Could not find path")}
            let original = UIImage(contentsOfFile: path)
            
            // Solution 2 - Creating rectange size of cell, so we could use it for new render
            
            let renderer = UIGraphicsImageRenderer(size: renderRect.size)
            
            let rounded = renderer.image { ctx in
                // first setting shadow
                // Solution 1 - Setting shadow directly in context
                //            blur 200: setts the shadow in points relative to the size of the image being drawn aka renderer
                //            ctx.cgContext.setShadow(offset: .zero, blur: 200, color: UIColor.black.cgColor)
                //            ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: original.size))
                //            ctx.cgContext.setShadow(offset: CGSize.zero, blur: 0, color: nil)
                ctx.cgContext.addEllipse(in: renderRect) // we are passing in new size
                // resetting the shadow
                
                ctx.cgContext.clip()
                
                original?.draw(in: renderRect) // passing in new size
                
            }
            saveImages(image: rounded, name: imageNamed)
            return rounded
            
        }
        // Challange 3. bonus
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        
        func saveImages(image: UIImage, name: String) {
            let path = getDocumentsDirectory().appendingPathComponent(name)
            
            if let jpegData = image.jpegData(compressionQuality: 0.5) {
                try? jpegData.write(to: path)
            }
        }
    }
}
