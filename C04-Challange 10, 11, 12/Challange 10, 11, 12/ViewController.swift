//
//  ViewController.swift
//  Challange 10, 11, 12
//
//  Created by Aleksandra Sobot on 8.12.23..
//

import UIKit

class ViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var photos = [Photo]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Photo collection"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(cameraTapped))
        
        let defaults = UserDefaults()
        if let savedPhotos = defaults.object(forKey: "photos") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                photos = try jsonDecoder.decode([Photo].self, from: savedPhotos)
            } catch {
                print("Failed to load photos")
            }
        }
      
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? PhotoCell else {
            fatalError("Couldn't dequeue photo.")
        }
        
        let image = photos[indexPath.row]
        cell.labelProperty.text = image.name
        
        let path = getDocumentsDirectory().appendingPathComponent(image.photo)
        cell.imageProperty.image = UIImage(contentsOfFile: path.path)
        
        cell.imageProperty.layer.cornerRadius = 3
        cell.imageProperty.layer.borderWidth = 1
        cell.imageProperty.layer.borderColor = UIColor.lightGray.cgColor

        return cell
    }
    
    @objc func cameraTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
       
        let imageName = UUID().uuidString
        
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        
        dismiss(animated: true)
        showCaptionAlert(forImage: imageName)
        
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            vc.selectedPhoto = photos[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    func showCaptionAlert(forImage image: String) {
        let ac = UIAlertController(
            title: nil,
            message: "What would you like the caption to be?",
            preferredStyle: .alert
        )
        
        ac.addTextField()
        ac.addAction(
            UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
                guard let caption = ac?.textFields?.first?.text else { return }
                let photoEntry = Photo(photo: image, name: caption)
                self?.photos.append(photoEntry)
                
                self?.save()
                self?.tableView.reloadData()
            }
        )
        
        present(ac, animated: true)
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(photos) {
            let defaults = UserDefaults()
            defaults.setValue(savedData, forKey: "photos")
        } else {
            print("Failed to save photos.")
        }
    }

}

