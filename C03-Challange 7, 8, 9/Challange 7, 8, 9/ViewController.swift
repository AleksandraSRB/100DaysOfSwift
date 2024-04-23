//
//  ViewController.swift
//  Challange 7, 8, 9
//
//  Created by Aleksandra Sobot on 7.11.23..
//

import UIKit

class ViewController: UIViewController {
    
    var guessesLeft: UILabel!
    var wordToGuessLabel: UILabel!
    var letterButtons = [UIButton]()
    var wordToGuess = String()
    
    var allWords = [String]()
    var usedLetters = [String]()
    
    
    var usedWords = [String]() {
        didSet {
            wordToGuessLabel.text = usedWords.joined()
        }
    }
    
    var labelStr = "" {
        didSet {
            wordToGuessLabel.text = "\(labelStr)"
        }
    }
    
    var numberOfGuesses = 0 {
        didSet {
            
            guessesLeft.text = "Wrong guesses: \(numberOfGuesses)/7"
        }
    }
    
    
    var scoreResult = 0 {
        didSet {
            navigationItem.title = "Score: \(scoreResult)"
        }
    }
        
        override func loadView() {
            
            view = UIView()
            view.backgroundColor = .white
            
            guessesLeft = UILabel()
            guessesLeft.translatesAutoresizingMaskIntoConstraints = false
            guessesLeft.text = "Wrong guesses: \(numberOfGuesses)/7"
            guessesLeft.textAlignment = .center
            view.addSubview(guessesLeft)
            
            wordToGuessLabel = UILabel()
            wordToGuessLabel.translatesAutoresizingMaskIntoConstraints = false
            wordToGuessLabel.font = UIFont.systemFont(ofSize: 40)
            wordToGuessLabel.textColor = .darkGray
            wordToGuessLabel.adjustsFontSizeToFitWidth = true
            wordToGuessLabel.textAlignment = .center
            wordToGuessLabel.numberOfLines = 0
            view.addSubview(wordToGuessLabel)
            
            let buttonsView = UIView()
            buttonsView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(buttonsView)
            
            
            NSLayoutConstraint.activate([
                
                guessesLeft.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 100),
                guessesLeft.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
                
                wordToGuessLabel.topAnchor.constraint(equalTo: guessesLeft.bottomAnchor, constant: 100),
                wordToGuessLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor),
                wordToGuessLabel.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor),
                
                
                buttonsView.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, constant: -10),
                buttonsView.heightAnchor.constraint(equalToConstant: 280),
                buttonsView.topAnchor.constraint(equalTo: wordToGuessLabel.bottomAnchor, constant: 100),
                buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20),
                buttonsView.centerXAnchor.constraint(equalTo: view.layoutMarginsGuide.centerXAnchor)
                
            ])
            
            let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
            var index = 0
            
            for row in 0..<4 {
                for column in 0..<7 {
                    guard index < 26 else { return }
                    
                    let letterButton = UIButton(type: .system)
                    letterButton.setTitle(String(letters[index]), for: .normal)
                    letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
                    letterButton.tintColor = .darkGray
                    
                    let frame = CGRect(x: column * 44, y: row * 44, width: 44, height: 44)
                    
                    letterButton.frame = frame
                    letterButton.layer.borderColor = UIColor.lightGray.cgColor
                    letterButton.layer.borderWidth = 1
                    letterButton.layer.cornerRadius = 10
                    letterButton.addTarget(self, action: #selector(letterButtonTapped), for: .touchUpInside)
                    
                    letterButtons.append(letterButton)
                    buttonsView.addSubview(letterButton)
                    index += 1
                }
            }
        }
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(loadNewWord))
            navigationItem.title = "Score: 0"
            
            startGame()
            
        }
        
        @objc func loadNewWord() {
            
            wordToGuess = allWords.randomElement()!
            usedLetters.removeAll()
            wordToGuessLabel.text = String(repeating: "_ ", count: wordToGuess.count).trimmingCharacters(in: .whitespaces)
            
            numberOfGuesses = 0
            
            for button in letterButtons {
                button.alpha = 1
                button.isEnabled = true
            }
        }
        
        @objc func startGame() {
            
            if let wordsURL = Bundle.main.url(forResource: "words", withExtension: "txt") {
                if let startWords = try? String(contentsOf: wordsURL) {
                    allWords = startWords.components(separatedBy: "\n")
                    if let word = allWords.randomElement() {
                        wordToGuess = word
                        wordToGuessLabel.text = String(repeating: "_ ", count: word.count).trimmingCharacters(in: .whitespaces)
        
                    }
                }
            }
            
            if allWords.isEmpty {
                allWords = ["silkworm"]
            }
            
            numberOfGuesses = 0
            scoreResult = 0
            
            for button in letterButtons {
                button.alpha = 1
                button.isEnabled = true
            }
        }
        
        @objc func letterButtonTapped(_ sender: UIButton) {
            
            guard let buttonTapped = sender.titleLabel?.text else { return }
            
            usedLetters.append(buttonTapped)
            
            sender.alpha = 0.2
            sender.isEnabled = false
            
            var tempStr = ""
            
            for letter in wordToGuess {
                if usedLetters.contains(String(letter)) {
                    tempStr += String(letter)
                } else {
                    tempStr += "_ "
                }
            }
            
            if tempStr == labelStr {
//                alertMessage(title: "Ooops", message: "There is no letter \(buttonTapped) in the word.")
                numberOfGuesses += 1
                scoreResult -= 1
            } else {
                labelStr = tempStr
                scoreResult += 1
            }
            
            // Loads new word
            if labelStr.contains("_ ") != true {
                labelStr = tempStr
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.alertMessage(title: "GOOD JOB!", message: "Let's try with a new word")
                    self.usedWords.append(self.labelStr)
                    self.loadNewWord()
                }
               
            }
            
            if numberOfGuesses == 7 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.alertMessage(title: "SORRY", message: "No guesses left. Try new word?")
                    self.loadNewWord()
                }
            }
            
            if scoreResult == -20 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.gameOver(title: "GAME OVER", message: "You've reached minimum score. Would you like to continue?")
                }
            }
            
            if scoreResult >= 100 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.gameOver(title: "GAME OVER", message: "Congrats! You've reached maximum score. Would you like to continue?")
                }
            }
        }
        
    func alertMessage(title: String, message: String) {
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            
        }
    
    func gameOver(title: String, message: String) {
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler:  {_ in
            self.startGame()
        }))
        ac.addAction(UIAlertAction(title: "CANCEL", style: .cancel))
        present(ac, animated: true)
        
    }
  
}

