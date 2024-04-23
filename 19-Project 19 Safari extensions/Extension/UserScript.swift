//
//  UserScript.swift
//  Extension
//
//  Created by Aleksandra Sobot on 23.1.24..
//

import Foundation

class UserScript: Codable {
    
    var name: String
    var script: String
    
    init(name: String, script: String) {
        self.name = name
        self.script = script
    }
}
