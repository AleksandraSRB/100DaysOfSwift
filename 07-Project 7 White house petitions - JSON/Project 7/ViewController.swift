//
//  ViewController.swift
//  Project 7
//
//  Created by Aleksandra Sobot on 24.10.23..
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Challange 1. Adding an info button
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoTapped))
        // Challange 2. - Adding aa filter button
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "line.3.horizontal.decrease.circle"), style: .plain, target: self, action: #selector(filterTapped))
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
    }
    
    @objc func fetchJSON() {
        let urlString: String
        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    // we are ok to parse json
                    parse(json: data)
                    return
                }
            }
        
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
   @objc func search(_ word: String) {
        filteredPetitions.removeAll()
        
        let lowerSearch = word.lowercased()
        // Project 9. Challange 3.
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
           guard let self = self else { return }
           
           if lowerSearch == "" {
               self.filteredPetitions = petitions
               self.title = "All petitions"
           } else {
               for petition in petitions {
                   if petition.title.lowercased().contains(lowerSearch) || petition.body.lowercased().contains(lowerSearch) {
                       filteredPetitions.append(petition)
                   }
               }
           }
           
           DispatchQueue.main.async {
               self.tableView.reloadData()
               self.title = "\(self.filteredPetitions.count) petitions found"
           }
       }
    }
    // Challange 2 - Filtering petitions
    @objc func filterTapped(){
        let ac = UIAlertController(title: "FILTER YOUR SEARCH", message: "Enter key word, and filter out petitions you would like to see", preferredStyle: .alert)
            ac.addTextField()
        
        let searchAction = UIAlertAction(title: "SEARCH", style: .default) {
            [weak self, weak ac] action in
                guard let searchPetition = ac?.textFields?[0].text else { return }
                self?.search(searchPetition)
            }
            ac.addAction(searchAction)
            present(ac, animated: true)
        }
        // Challange 1.
    @objc func infoTapped(){
        let ac = UIAlertController(title: "DETAIL INFO", message: "These informations are provided by Hacking With Swift", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
   @objc func showError() {
            let ac = UIAlertController(title: "Error while loading", message: "There was an error while loading feed. Please check your connection, and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            filteredPetitions = petitions
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = filteredPetitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

