//
//  DetailViewController.swift
//  Challange 19, 20, 21
//
//  Created by Aleksandra Sobot on 9.2.24..
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    
    let defaults = UserDefaults.standard

    @IBOutlet var note: UITextView!
    var saveButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    
    var detailNote: Note?
    var notes = [Note]()
    
    var indexOfNote: Int!
    var dateCreated: String!
    var originalText: String!
 

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        note.delegate = self
        
        note.text = detailNote?.title
        originalText = detailNote?.title

    
        shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        saveButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveNote))
    
        
        navigationItem.rightBarButtonItems = [saveButton, shareButton]
        
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ajustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ajustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

       
    }
    
    @objc func shareTapped() {
        if let noteToShare = note.text {
            let vc = UIActivityViewController(activityItems: [noteToShare], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(vc, animated: true)
        }
    }
    
   
    @objc func saveNote() {
        let rightNow = Date()
        let customDate = DateFormatter.localizedString(from: rightNow, dateStyle: .short, timeStyle: .short)

        guard let noteText = note.text, !noteText.isEmpty else { return }
               if let note = detailNote {
                   updateNote(object: note, title: noteText)
               } else {
                   saveNewNote(title: noteText, date: customDate)
               }
    
        
            // Go back to the first view controller in the navigation stack
            navigationController?.popViewController(animated: true)
    }
    
    func saveNewNote(title: String, date: String) {
        let newNote = Note(title: title, date: date)
        notes.append(newNote)
        save()
    }
    // checks if the note is edited
    func updateNote(object: Note, title: String) {
        let rightNow = Date()
        let customDate = DateFormatter.localizedString(from: rightNow, dateStyle: .short, timeStyle: .short)
        
        if detailNote?.title == originalText {
            detailNote?.title = note.text
            detailNote?.date = customDate
            notes[indexOfNote] = detailNote!
            save()
        } 
    }
    
    
    func save() {
        
        if let text = note.text {
            detailNote?.title = text
        }
        
        let jsonEncoder = JSONEncoder()
        if let savedNotes = try? jsonEncoder.encode(notes) {
                  defaults.set(savedNotes, forKey: "notes")
              } else {
                  print("Failed to save notes.")
            }
    }
    
    
    @objc func ajustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardScreenAndFrame = keyboardValue.cgRectValue
        let keyboardViewAndFrame = view.convert(keyboardScreenAndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            note.contentInset = .zero
        } else {
            note.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewAndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        note.scrollIndicatorInsets = note.contentInset
        let selectedRange = note.selectedRange
        note.scrollRangeToVisible(selectedRange)
    }
    
    
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
          navigationItem.rightBarButtonItems = [saveButton, shareButton]
          return true
      }
      
      func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
          navigationItem.rightBarButtonItems = [shareButton]
          return true
      }

}
