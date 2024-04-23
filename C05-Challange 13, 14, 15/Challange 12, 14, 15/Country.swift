//
//  Country.swift
//  Challange 12, 14, 15
//
//  Created by Aleksandra Sobot on 28.12.23..
//

import Foundation

struct Country: Codable, Identifiable {
    
     let capital: [String]
     let code: String
     let name: CountryName
     let population: Int
     let region: String
     
     var id: String { name.common }
     
     var flagImageName: String {
         code.lowercased() // "mx", "pl", "us"
     }
     
     private enum CodingKeys: String, CodingKey {
         case capital
         case code = "cca2"
         case name
         case population
         case region
     }
     
     struct CountryName: Codable {
         let common: String
         let official: String
     }
     
     // 30 different countries...
     static let countryCodes = [
         "af", "be", "bf", "bw", "ca", "ch", "ci", "cm",
         "de", "dk", "ec", "fr", "gb", "gn", "in",
         "it", "jp", "kr", "lb", "lt","li", "lu", "mx",
         "nz", "rw", "se", "rs", "td", "us", "uy", "ve"
     ]
 }
    
