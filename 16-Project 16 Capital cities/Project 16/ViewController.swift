//
//  ViewController.swift
//  Project 16
//
//  Created by Aleksandra Sobot on 3.1.24..
//

import MapKit
import UIKit

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let london = Capital(title: "London", coordinate: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), info: "Home of the 2012 Summer Olympics.", wikiString: "London")
        let oslo = Capital(title: "Oslo", coordinate: CLLocationCoordinate2D(latitude: 59.95, longitude: 10.75), info: "Founded over a thousand years ago.", wikiString: "Oslo")
        let paris = Capital(title: "Paris", coordinate: CLLocationCoordinate2D(latitude: 48.8567, longitude: 2.3508), info: "Often called the City of Lights.", wikiString: "Paris")
        let rome = Capital(title: "Rome", coordinate: CLLocationCoordinate2D(latitude: 41.9, longitude: 12.5), info: "Has a whole country in it.", wikiString: "Rome")
        let washington = Capital(title: "Washington DC", coordinate: CLLocationCoordinate2D(latitude: 38.895111, longitude: -77.03667), info: "Named after George himself.", wikiString: "Washington DC")
        
        mapView.addAnnotations([london, oslo, paris, rome, washington])
        showMapAlert()
    }

    // step 10
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // a)
        guard annotation is Capital else { return nil }

        // b)
        let identifier = "Capital"

        // c) and Challange 1 - Typecasting dequequReusableAnotationView so we coud change pin color later
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            // d)
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            //challange 1 - Changing pin color
            annotationView?.markerTintColor = .systemPurple
            
            // e)
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            // f)
            annotationView?.annotation = annotation
        }

        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let capital = view.annotation as? Capital else { return }
        
        let placeName = capital.title
        let placeInfo = capital.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "SEE MORE", style: .default, handler: {
            [weak self] _ in
            let vc = self?.storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController
            vc?.detailCapital = capital
            self?.navigationController?.pushViewController(vc!, animated: true)
        }))
        
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    // Challange 2 - Showes an alert for user to choose map style
    func showMapAlert() {
        let ac = UIAlertController(title: "Choose map style", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "STANDARD", style: .default, handler: { _ in
            self.mapView.mapType = .standard
        }))
        ac.addAction(UIAlertAction(title: "SATELITE", style: .default, handler: { _ in
            self.mapView.mapType = .satellite
        }))
        
        present(ac, animated: true)
    }

}

