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
import GooglePlaces

extension UIColor {
    convenience init(hex: String, alpha: CGFloat) {
        let v = hex.map { String($0) } + Array(repeating: "0", count: max(6 - hex.count, 0))
        let r = CGFloat(Int(v[0] + v[1], radix: 16) ?? 0) / 255.0
        let g = CGFloat(Int(v[2] + v[3], radix: 16) ?? 0) / 255.0
        let b = CGFloat(Int(v[4] + v[5], radix: 16) ?? 0) / 255.0
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    convenience init(hex: String) {
        self.init(hex: hex, alpha: 1.0)
    }
}

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var locationManager: CLLocationManager!
    var placesClient: GMSPlacesClient!
    var currentLocation: CLLocationCoordinate2D?
    var currentCameraPosition: GMSCameraPosition?
    var zoomLevel: Float = 15.0
    var mapView: GMSMapView!

    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 1.0)
        let footerViewHeight: CGFloat = 88.0
        let mapViewSize = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-footerViewHeight)
        mapView = GMSMapView.map(withFrame: mapViewSize, camera: camera)
        mapView.isMyLocationEnabled = true
        
        let path = Bundle.main.path(forResource: "GoogleMapStyle", ofType: "json")
        
        do {
            let content = try String(contentsOfFile: path!)
            mapView.mapStyle = try GMSMapStyle(jsonString: content)
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        mapView.delegate = self

        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
    }
    
    func calculateElevation(lat: Double, lng: Double) {
        let request = GetElevationRequest(lat: lat, lng: lng)
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let elevation):
                if let elevation = elevation.results.first?.elevation {
                    if elevation == 0 {
                        self.elevationLabel.textColor = UIColor.init(hex: "CB1B45")
                        self.elevationLabel.text = "0(計測不能)"
                    } else {
                        if elevation > 5 {
                            self.elevationLabel.textColor = UIColor.init(hex: "333333")
                        } else {
                            self.elevationLabel.textColor = UIColor.init(hex: "DB4D6D")
                        }
                        let text = NSString(format: "%.1f", elevation)
                        self.elevationLabel.text = text as String
                    }
                }
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: zoomLevel)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.animate(to: camera)
            } else {
                mapView.animate(to: camera)
                calculateElevation(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
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
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        currentCameraPosition = position
    }

    @IBAction func didPressCalculateButton(_ sender: Any) {

        if let currentCameraPosition = currentCameraPosition {
            calculateElevation(lat: currentCameraPosition.target.latitude, lng: currentCameraPosition.target.longitude)
        }
    }
    
    @IBAction func didPressResetButton(_ sender: Any) {
        
        if let currentLocation = currentLocation {
            self.mapView.animate(toLocation: currentLocation)
            self.self.calculateElevation(lat: currentLocation.latitude, lng: currentLocation.longitude)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
