//
//  ViewController.swift
//  Project2
//
//  Created by Aleksandra Sobot on 14.2.23..
//

import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    // Challange 2. Showing player how meny questions were asked
    var questionsAsked = 0
    
    var currentAnimation = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(infoTapped))
        // project 21, challange 3
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
        
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
        
        // Challange 1. Showing plyer's score on navigation bar
        title = countries[correctAnswer].uppercased() + "Current score \(score)"
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        
        var title: String
        questionsAsked += 1
        
        // Project 15, Challange 3 - Making button scale down and back up, and bounce when tapped
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 5) {
            sender.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            sender.transform = .identity
        }
        
        // Challange 3. When player has a correct or wrong answer, we are showing and appropriate alert
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
        } else {
            title = "Wrong, this is flag of \(countries[sender.tag])"
            score -= 1
        }
        
        // Challange 2. When player reaches 10 questions, we are showing an alert with players final score
        if questionsAsked == 10 {
            let finalScore = UIAlertController(title: "You have answered 10 questions", message: "Your final score is \(score)", preferredStyle: .alert)
            finalScore.addAction(UIAlertAction(title: "END GAME", style: .default, handler: nil))
            present(finalScore, animated: true)
        }
        
        let ac = UIAlertController(title: title, message: "Your score is now \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        present(ac, animated: true)
    }
    // Project 3, Challange 3 - Adding an activity controller that shows score when tapped
    @objc func infoTapped(){
        let info = ["SCORE = \(score)"]
        
        let vc = UIActivityViewController(activityItems: info, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // project 21, challange 3
    @objc func registerLocal(){
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
            (granted, error) in
            if granted {
                print("Granted!")
            } else {
                print("Not granted!")
            }
        }
    }
    
    // project 21, challange 3
    @objc func scheduleLocal(){
      
        registerLocal()
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        let content = UNMutableNotificationContent()
        content.title = "We've missed you"
        content.body = "Play world flags and improve your score"
        
        content.categoryIdentifier = "alarm"
        content.sound = .default
        
        let secondsInDay: TimeInterval = 10
        
        for day in 1...7 {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: secondsInDay * Double(day), repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    }
    
    // project 21, challange 3
    func registerCategories(){
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let show = UNNotificationAction(identifier: "show", title: "play world flags", options: .foreground)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [], options: [])
        center.setNotificationCategories([category])
    }
}

