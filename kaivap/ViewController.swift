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
//    var currentLocation: CLLocation?
    var currentCameraPosition: GMSCameraPosition?
    var zoomLevel: Float = 15.0
    var mapView: GMSMapView!

    let mapStyle = "[" +
"    {" +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#ebe3cd\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#523735\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"elementType\": \"labels.text.stroke\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#f5f1e6\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"administrative\"," +
"    \"elementType\": \"geometry.stroke\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#c9b2a6\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"administrative.land_parcel\"," +
"    \"elementType\": \"geometry.stroke\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#dcd2be\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"administrative.land_parcel\"," +
"    \"elementType\": \"labels\"," +
"    \"stylers\": [" +
"    {" +
"    \"visibility\": \"off\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"administrative.land_parcel\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#ae9e90\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"landscape.natural\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#dfd2ae\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"poi\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#dfd2ae\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"poi\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#93817c\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"poi.business\"," +
"    \"stylers\": [" +
"    {" +
"    \"visibility\": \"off\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"poi.park\"," +
"    \"elementType\": \"geometry.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#a5b076\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"poi.park\"," +
"    \"elementType\": \"labels.text\"," +
"    \"stylers\": [" +
"    {" +
"    \"visibility\": \"off\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"poi.park\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#447530\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#f5f1e6\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.arterial\"," +
"    \"stylers\": [" +
"    {" +
"    \"visibility\": \"off\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.arterial\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#fdfcf8\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.highway\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#f8c967\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.highway\"," +
"    \"elementType\": \"geometry.stroke\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#e9bc62\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.highway\"," +
"    \"elementType\": \"labels\"," +
"    \"stylers\": [" +
"    {" +
"    \"visibility\": \"off\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.highway.controlled_access\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#e98d58\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.highway.controlled_access\"," +
"    \"elementType\": \"geometry.stroke\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#db8555\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.local\"," +
"    \"stylers\": [" +
"    {" +
"    \"visibility\": \"off\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.local\"," +
"    \"elementType\": \"labels\"," +
"    \"stylers\": [" +
"    {" +
"    \"visibility\": \"off\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"road.local\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#806b63\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"transit.line\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#dfd2ae\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"transit.line\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#8f7d77\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"transit.line\"," +
"    \"elementType\": \"labels.text.stroke\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#ebe3cd\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"transit.station\"," +
"    \"elementType\": \"geometry\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#dfd2ae\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"water\"," +
"    \"elementType\": \"geometry.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#b9d3c2\"" +
"    }" +
"    ]" +
"    }," +
"    {" +
"    \"featureType\": \"water\"," +
"    \"elementType\": \"labels.text.fill\"," +
"    \"stylers\": [" +
"    {" +
"    \"color\": \"#92998d\"" +
"    }" +
"    ]" +
"    }" +
"    ]"

    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapViewSize = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-88)
        mapView = GMSMapView.map(withFrame: mapViewSize, camera: camera)
        mapView.isMyLocationEnabled = true
        do {
            mapView.mapStyle = try GMSMapStyle(jsonString: mapStyle)
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

        calculateButton.layer.borderWidth = 1.0
        calculateButton.layer.borderColor = UIColor(hex: "dadada").cgColor
        calculateButton.layer.cornerRadius = 22

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!

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
                    self.elevationLabel.text = "\(elevation.elevation)m"
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

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        currentCameraPosition = position
    }

    @IBAction func didPressCalculateButton(_ sender: Any) {

        if let currentCameraPosition = currentCameraPosition {
            let request = GetElevationRequest(lat: currentCameraPosition.target.latitude, lng: currentCameraPosition.target.longitude)
            Session.send(request) { result in
                switch result {
                case .success(let elevation):
                    self.elevationLabel.text = "\(elevation.elevation)m"
                case .failure(let error):
                    print("error: \(error)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
