//
//  ViewController.swift
//  Project 10
//
//  Created by Aleksandra Sobot on 11.11.23..
//
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let person = people[indexPath.item]
        
        let ac = UIAlertController(title: "RENAME OR DELETE", message: "Would you like to rename or delete picture?", preferredStyle: .alert)
        
        // Challenge 1
        ac.addAction(UIAlertAction(title: "RENAME", style: .default) {
           [weak self] _ in
            
            let renameAlert = UIAlertController(title: "RENAME PHOTO", message: nil, preferredStyle: .alert)
            renameAlert.addTextField()
            renameAlert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {
                [weak self, weak renameAlert] _ in
                    guard let newName = renameAlert?.textFields?[0].text else { return }
                        person.name = newName
                        self?.collectionView.reloadData()
            }))
            self?.present(renameAlert, animated: true)
        })
        ac.addAction(UIAlertAction(title: "DELETE PHOTO", style: .destructive) { [weak self] _ in
            guard let imageIndex = self?.people.firstIndex(of: person) else { return }
            self?.people.remove(at: imageIndex)
            self?.collectionView.reloadData()
        })
        
        present(ac, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable to dequeue PersonCell")
        }
        
        let person = people[indexPath.item]
        cell.name.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
    
        return cell
    }
    
    @objc func addNewPerson() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage else { return }
        
        guard let cameraPhoto = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            if jpegData == cameraPhoto.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
            }
        }
        
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        
        dismiss(animated: true)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    // Challenge 2 - Adding a camera picker controller (works only on real device)
    @objc func takePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
}

