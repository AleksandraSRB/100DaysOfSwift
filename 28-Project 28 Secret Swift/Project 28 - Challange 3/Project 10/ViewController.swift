//
//  ViewController.swift
//  Project 10
//
//  Created by Aleksandra Sobot on 11.11.23..
//
import LocalAuthentication
import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()
    var emptyArray = [Person]()
   
    
    // Project 28. - Challange 3
    var doneButton: UIBarButtonItem!
    var takePhotoButton: UIBarButtonItem!
    var addButton: UIBarButtonItem!
    var lockScreenButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
        takePhotoButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePhoto))
        
        // Project 28. - Challange 3
        doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(save))
        lockScreenButton = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(lockScreen))
        
        // Project 28. - Challange 3
        let notificationCenter = NotificationCenter()
        notificationCenter.addObserver(self, selector: #selector(save), name: UIApplication.willResignActiveNotification, object: nil)
        
        // Project 28. - Challange 3
        lockScreen()
    }
    // Project 28. - Challange 3
    @objc func lockScreen() {
        navigationItem.rightBarButtonItems = nil
        navigationItem.leftBarButtonItems = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "lock"), style: .plain, target: self, action: #selector(logIn))
        people = emptyArray
        collectionView.reloadData()
    }
    
    
    // Project 28. - Challange 3
    @objc func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Identification needed!"
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        self?.loadPeople()
                    } else {
                        self?.showAuthentificationAlert()
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Biometry unavailable!", message: "Your device is not configured for biometry. Create password for authentification", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    
    func loadPeople() {
        
        let defaults = UserDefaults.standard
        if let savedPeople = defaults.object(forKey: "people") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                people = try jsonDecoder.decode([Person].self, from: savedPeople)
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            } catch {
                print("Failed to load people.")
            }
        }
        // Project 28. - Challange 3
        navigationItem.rightBarButtonItems = [doneButton, takePhotoButton]
        navigationItem.leftBarButtonItems = [addButton, lockScreenButton]
    }
    
    // Project 28. - Challange 3
    @objc func logIn() {
        let ac = UIAlertController(title: "Identification needed!", message: "Please log in to continue.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.authenticate()
        })
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
//            self.navigationController?.navigationBar.isUserInteractionEnabled = false
//        })
        present(ac, animated: true)
    }
    // Project 28. - Challange 3
    func showAuthentificationAlert() {
        let ac = UIAlertController(title: "Authentification failed!", message: "You could not be verified; Please try again", preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.authenticate()
            })

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.lockScreen()
            })

        present(ac, animated: true)
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
                        self?.save()
            }))
            self?.present(renameAlert, animated: true)
        })
        
        
        ac.addAction(UIAlertAction(title: "DELETE PHOTO", style: .destructive) { [weak self] _ in
            guard let imageIndex = self?.people.firstIndex(of: person) else { return }
            self?.people.remove(at: imageIndex)
            self?.save()
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
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
                try? jpegData.write(to: imagePath)
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
    
    @objc func takePhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    
    @objc func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.setValue(savedData, forKey: "people")
        } else {
            print("Failed to save people.")
        }
    }
    
}

