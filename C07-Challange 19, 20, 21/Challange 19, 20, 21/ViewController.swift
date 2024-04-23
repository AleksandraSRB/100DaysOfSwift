//
//  ViewController.swift
//  Challange 19, 20, 21
//
//  Created by Aleksandra Sobot on 8.2.24..
//

import UIKit

class ViewController: UITableViewController, UISearchBarDelegate {
    
    let defaults = UserDefaults.standard

    @IBOutlet var search: UISearchBar!
    
    var notes: [Note] = []
    var filteredNotes: [Note] = []
    
    var dateCreated: Date!
   
    
    override func viewWillAppear(_ animated: Bool) {
        loadNotes()
        tableView.reloadData()
        
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.isNavigationBarHidden = false
        
    
        let newNoteButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(addNewNote))

        navigationItem.rightBarButtonItems = [newNoteButton]
        
        search.delegate = self
      
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note", for: indexPath) as! NoteCell
        cell.title.text = String(filteredNotes[indexPath.row].title.prefix(10))
        cell.date.text = filteredNotes[indexPath.row].date
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    @objc func addNewNote() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            navigationController?.pushViewController(vc, animated: true)
            vc.notes = filteredNotes
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            
            vc.detailNote = filteredNotes[indexPath.row]
            vc.indexOfNote = indexPath.row
            vc.notes = filteredNotes
            tableView.reloadData()
            
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            filteredNotes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    func loadNotes() {
        if let savedNotes = defaults.object(forKey: "notes") as? Data {
                let jsonDecoder = JSONDecoder()
                    
                    do {
                        notes = try jsonDecoder.decode([Note].self , from: savedNotes)
                        filteredNotes = try jsonDecoder.decode([Note].self, from: savedNotes)
                        notes.sort { $0.date > $1.date }
                        filteredNotes.sort { $0.date > $1.date }
                    } catch {
                        print("Failed to load notes")
                    }
                    
                    tableView.reloadData()
                }
        }

    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedNotes = try? jsonEncoder.encode(notes) {
                defaults.set(savedNotes, forKey: "notes")
            } else {
                print("Failed to save notes.")
        }
    }
    
    func searchBar(_ sender: UISearchBar, textDidChange searchText: String) {
       
        filteredNotes.removeAll()
        
        let searchQuery = searchText.lowercased()
        
        if searchQuery == "" {
          filteredNotes = notes
        } else {
            for note in notes {
                if note.title.lowercased().contains(searchQuery) || note.date.lowercased().contains(searchQuery) {
                    filteredNotes.append(note)
                   
                    }
                }
            }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
       
    }
    
}



