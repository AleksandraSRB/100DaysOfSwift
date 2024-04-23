//
//  Note.swift
//  Challange 19, 20, 21
//
//  Created by Aleksandra Sobot on 14.2.24..
//

import Foundation

class Note: Codable {
    var title: String
    var date: String
    
    init(title: String, date: String) {
        self.title = title
        self.date = date
    }
}
