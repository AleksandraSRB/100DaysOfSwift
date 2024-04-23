//
//  ViewController.swift
//  Project 12
//
//  Created by Aleksandra Sobot on 23.11.23..
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        
        defaults.set(25, forKey: "Age")
        defaults.set(true, forKey: "UseTouchID")
        defaults.set(CGFloat.pi, forKey: "Pi")
        
        defaults.set(Date(), forKey: "LastRun")
        
        let array = ["Hello", "World"]
        defaults.set(array, forKey: "SavedArray")
        
        let dict = ["Name": "Paul", "Country": "UK"]
        defaults.set(dict, forKey: "SavedDict")
        
//        let saveInteger = defaults.integer(forKey: "Age")
//        let savedBool = defaults.bool(forKey: "UseFaceID")
//      
//        let savedArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]()
//        
//        let savedDict = defaults.object(forKey: "SavedDict") as? [String: String] ?? [String: String]()
        
        
    }


}

