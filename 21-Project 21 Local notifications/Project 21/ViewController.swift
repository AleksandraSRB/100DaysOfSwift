//
//  ViewController.swift
//  Project 21
//
//  Created by Aleksandra Sobot on 30.1.24..
//

import UserNotifications
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Shedule", style: .plain, target: self, action: #selector(initialSchedule))
    }
    
    @objc func initialSchedule() {
        scheduleLocal(delayInSeconds: 5)
     }
    
    @objc func registerLocal() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .badge, .sound]) {
           (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh!")
            }
        }
    }
    
    @objc func scheduleLocal(delayInSeconds: TimeInterval) {
        registerCategories()
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        // step 1. Creating content
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "Early bird cathes the worm, but second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = .default
        
        // step 2. Creating trigger
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
    //    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //challange 2
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delayInSeconds, repeats: false)
        
        // step 3. Creating a request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request)
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        // creates an action
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground)
        //challange 2
        let delay = UNNotificationAction(identifier: "delay", title: "Remind me later", options: .foreground)
        // wraps actions in categories
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, delay], intentIdentifiers: [], options: [])
        // register notifiction categories that app supports
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received \(customData)")
            
            switch response.actionIdentifier {
                // user swiped to unlock
            case UNNotificationDefaultActionIdentifier:
                //challange 1
                let ac = UIAlertController(title: "User swiped to unlock", message: "", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            case "show":
                //challange 1
                let ac = UIAlertController(title: "User wants to see more info", message: "", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                //challange 2
            case "delay":
                scheduleLocal(delayInSeconds: 86400)
            default:
                break
            }
        }
        
        completionHandler()
    }

}

