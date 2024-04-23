//
//  Picture.swift
//  Project 1
//
//  Created by Aleksandra Sobot on 17.11.23..
//

import UIKit

class Picture: NSObject, Codable {
    
    var image: String
    var title: String
    var subtitle: String
    var timesShown: Int {
        didSet {
            subtitle = "Views: \(timesShown)"
        }
    }
    
    init(image: String, title: String, subtitle: String, timesShown: Int) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
        self.timesShown = timesShown
    }

}
