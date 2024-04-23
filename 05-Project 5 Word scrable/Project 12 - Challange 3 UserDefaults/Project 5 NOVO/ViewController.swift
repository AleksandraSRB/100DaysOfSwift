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
    var numberOfLogs = 0
    var pastWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        pastWords = defaults.object(forKey: "savedWords") as? [String] ?? [String]()
        numberOfLogs = defaults.integer(forKey: "numberOfLogs")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer)),
            UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoTapped))
        ]
        
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
    
    @objc func startGame() {
        numberOfLogs += 1
        title = allWords.randomElement()
        pastWords.append(title!)
        usedWords.removeAll(keepingCapacity: true)
        save()
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
            self?.save()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        let lowerAnswer = answer.lowercased()
        // edit breakpoint lowerAnswer.count >= 6
        
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
            save()
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
            if word.utf16.count < 3 {
                return false
        }
        
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            return misspelledRange.location == NSNotFound
    }
        
    func showErrorMessage(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func infoTapped() {
        let ac = UIAlertController(title: "INFO", message: "What do you want to know?", preferredStyle: .alert)
        
        ac.addAction(UIAlertAction(title: "USED WORDS", style: .default) {
            [weak self] _ in
                let usedWordAlert = UIAlertController(title: "USED WORDS:", message: "\(self!.pastWords)", preferredStyle: .alert)
                    usedWordAlert.addAction(UIAlertAction(title: "Cool", style: .destructive))
                    self?.present(usedWordAlert, animated: true)
            })
            ac.addAction(UIAlertAction(title: "NUMBER OF LOGGS", style: .default) {
                [weak self] _ in
                    let logs = UIAlertController(title: "LOGS", message: "You loged \(self?.numberOfLogs ?? 0) times", preferredStyle:.alert)
                        logs.addAction(UIAlertAction(title: "OK", style: .cancel))
                        self?.present(logs, animated: true)
                    })
        
            present(ac, animated: true)
    }
    
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(pastWords, forKey: "savedWords")
        defaults.set(numberOfLogs, forKey: "numberOfLogs")
    }
}
    
