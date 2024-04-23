//
//  Photo.swift
//  Challange 10, 11, 12
//
//  Created by Aleksandra Sobot on 8.12.23..
//

import UIKit

class Photo: NSObject, Codable {
    
    var photo: String
    var name: String
    
    init(photo: String, name: String) {
        self.photo = photo
        self.name = name
    }

}
