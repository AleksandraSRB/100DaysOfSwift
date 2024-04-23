//
//  Capital.swift
//  Project 16
//
//  Created by Aleksandra Sobot on 3.1.24..
//


import MapKit
import UIKit

class Capital: NSObject, MKAnnotation {
    
    var title: String?
    var coordinate: CLLocationCoordinate2D
    var info: String
    var wikiString: String
 
    
    init(title: String?, coordinate: CLLocationCoordinate2D, info: String, wikiString: String) {
        self.title = title
        self.coordinate = coordinate
        self.info = info
        self.wikiString = wikiString
       
    }

}
