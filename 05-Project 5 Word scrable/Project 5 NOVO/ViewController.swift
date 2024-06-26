//
//  ViewController.swift
//  Project 5 NOVO
//
//  Created by Aleksandra Sobot on 18.10.23..
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                allWords = startWords.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        startGame()
    }
    
    // Challange 3.
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] action in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        
        let lowerAnswer = answer.lowercased()
    
        if !isPossible(word: lowerAnswer) {
                showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
                return
        }
            if !isOriginal(word: lowerAnswer) {
                showErrorMessage(title: "Word used already", message: "Be more original!")
                return
            }
                if !isReal(word: lowerAnswer) {
                    showErrorMessage(title: "Word not possible", message: "You can't spell this word from \(title!), or the word is too short, or you tried to put in \(title!).")
                    return
                }

            usedWords.insert(lowerAnswer, at: 0)
            
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
        
        func isPossible(word: String) -> Bool {
            guard var temporaryWord = title?.lowercased() else { return false }
            
            for letter in word {
                if let position = temporaryWord.firstIndex(of: letter) {
                    temporaryWord.remove(at: position)
                } else {
                    return false
                }
            }
            return true
        }
        
        func isOriginal(word: String) -> Bool {
            return !usedWords.contains(word)
        }
        
        func isReal(word: String) -> Bool {
            let checker = UITextChecker()
            
            if word == title {
                return false
            }
            // Challange 1.
                if word.utf16.count < 3 {
                    return false
            }
            
            let range = NSRange(location: 0, length: word.utf16.count)
            let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
                return misspelledRange.location == NSNotFound

        }
        // Challange 2.
        func showErrorMessage(title: String, message: String) {
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
