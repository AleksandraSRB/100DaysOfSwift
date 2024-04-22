//
//  ViewController.swift
//  Project2
//
//  Created by Aleksandra Sobot on 14.2.23..
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionsAsked = 0
    
    var highScore = 0
  

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Project 12 - Challange 2 reading from Userdefaults
        let defaults = UserDefaults.standard
        highScore = defaults.integer(forKey: "highScore")
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .plain, target: self, action: #selector(infoTapped))
        
        
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button2.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        button3.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
        askQuestion()
        
        
    }
    
    func askQuestion(action: UIAlertAction! = nil){
        
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
        
        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = countries[correctAnswer].uppercased() + "Current score \(score)"

        
    }
    
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        var title: String
        questionsAsked += 1
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            sender.transform = .identity
           
        })
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong, this is flag of \(countries[sender.tag])"
            score -= 1
        }
        
        if questionsAsked == 10 {
            if score > highScore {
                highScore = score
                save()
                let newHighScore = UIAlertController(title: "Wow", message: "New high score: \(highScore)", preferredStyle: .alert)
                newHighScore.addAction(UIAlertAction(title: "NEW GAME", style: .default, handler: askQuestion))
                newHighScore.addAction(UIAlertAction(title: "END GAME", style: .cancel))
                present(newHighScore, animated: true)
            } else {
                let finalScore = UIAlertController(title: "You have answered 10 questions", message: "Your final score is \(score)", preferredStyle: .alert)
                finalScore.addAction(UIAlertAction(title: "NEW GAME", style: .default, handler: askQuestion))
                finalScore.addAction(UIAlertAction(title: "END GAME", style: .default, handler: nil))
                present(finalScore, animated: true)
                
               
            }
        
        }
        
        let ac = UIAlertController(title: title, message: "Your score is now \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    
    @objc func shareTapped(){
        let info = ["SCORE = \(score)"]
        let vc = UIActivityViewController(activityItems: info, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    @objc func infoTapped() {
        let vc = UIAlertController(title: "HIGH SCORE: \(highScore)", message: "", preferredStyle: .actionSheet)
        vc.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(vc, animated: true)
    }
    // Project 12 - Challange 2 Saving to Userdefaults
    func save() {
        let defaults = UserDefaults.standard
        defaults.set(highScore, forKey: "highScore")
    }
}

