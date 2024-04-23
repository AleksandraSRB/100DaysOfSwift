//
//  ViewController.swift
//  Project 22
//
//  Created by Aleksandra Sobot on 17.2.24..
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var distanceReading: UILabel!
    // challange 2
    @IBOutlet var beaconLabel: UILabel!
    //challange 3
    @IBOutlet var circleView: UIImageView!
    
    var locationManager: CLLocationManager?
    // challange 1
    var isBeaconDetected: Bool = false
    var beaconUUID: UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        beaconLabel.text = "Unknown Beacon"
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    print("App launched, scanning started")
                    startScanning()
                }
            }
        }
    }
    // challange 2
    func startScanning() {
        addBeacon(uuid: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 123, minor: 456, name: "My Beacon")
        addBeacon(uuid: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", major: 789, minor: 390, name: "Second Beacon")
        addBeacon(uuid: "74278BDA-B644-4520-8F0C-720EAF059935", major: 792, minor: 468, name: "Third Beacon")
    }
    
    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                self.distanceReading.text = "FAR"
            case .near:
                self.view.backgroundColor = UIColor.orange
                self.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                self.distanceReading.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.circleView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.distanceReading.text = "RIGHT HERE"
            default:
                self.view.backgroundColor = UIColor.gray
                self.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
   //proveriti
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        
        if let beacon = beacons.first {
            
            if beaconUUID == nil {
                beaconUUID = region.uuid
            }
            
            if region.uuid == UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5") {
                beaconLabel.text = "My Beacon"
            } else if region.uuid == UUID(uuidString: "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0") {
                beaconLabel.text = "Second Beacon"
            } else if region.uuid == UUID(uuidString: "74278BDA-B644-4520-8F0C-720EAF059935") {
                beaconLabel.text = "Third Beacon"
            }
            
            // challange 1
            if isBeaconDetected == false {
                           
                let ac = UIAlertController(title: "Beacon detected", message: "You're getting close", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                isBeaconDetected = true
        }
            update(distance: beacon.proximity)
                   } else {
                       /// Challenge 2:
                       guard beaconUUID == region.uuid else { return }
                       
                       beaconUUID = nil
                       
                       beaconLabel.text = "No beacon detected."
                       
                       update(distance: .unknown)
                   }
               }
    
    // challange 2
    func addBeacon(uuid: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, name: String) {
        let uuid = UUID(uuidString: uuid)
        let beaconRegion = CLBeaconRegion(uuid: uuid!, major: major, minor: minor, identifier: name)
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(satisfying: CLBeaconIdentityConstraint(uuid: uuid!, major: major, minor: minor))
        
    }

    // challange 3
    func setUpCircle() {
        circleView.layer.cornerRadius = 128
        circleView.tintColor = .white
        circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }
}

