//
//  ViewController.swift
//  kaivap
//
//  Created by KokiHirokawa on 2018/01/29.
//  Copyright © 2018年 KokiHirokawa. All rights reserved.
//

import Foundation
import UIKit
import APIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    var zoomLevel: Float = 15.0
    var mapView: GMSMapView!
    
    @IBOutlet weak var elevationLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapViewSize = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-44)
        mapView = GMSMapView.map(withFrame: mapViewSize, camera: camera)
        mapView.isMyLocationEnabled = true
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        view.addSubview(mapView)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
            let request = GetElevationRequest(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
            Session.send(request) { result in
                switch result {
                case .success(let elevation):
                    print(elevation)
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

