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

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var locationManager: CLLocationManager!
    var currentLocation: CLLocationCoordinate2D?
    var currentCameraPosition: GMSCameraPosition?
    var zoomLevel: Float = 15.0
    var mapView: GMSMapView!
    
    var locations: [LocationEntity] = []
    
    // ゴミ
    struct LocationEntity {
        let latitude: Double
        let longitude: Double
        let elevation: Double
    }

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var elevationLabel: UILabel!
    @IBOutlet weak var calculateButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // 纏める
        collectionView.register(UINib(nibName: "PinCell", bundle: nil), forCellWithReuseIdentifier: "PinCell")
        setupView()
    }

    func setupView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 1.0)
        let footerViewHeight: CGFloat = 88.0
        let mapViewSize = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height-footerViewHeight)
        mapView = GMSMapView.map(withFrame: mapViewSize, camera: camera)
        mapView.isMyLocationEnabled = true
        
        let path = Bundle.main.path(forResource: "GoogleMapsStyle", ofType: "json")
        
        do {
            let content = try String(contentsOfFile: path!)
            mapView.mapStyle = try GMSMapStyle(jsonString: content)
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        mapView.delegate = self
        view.addSubview(mapView)
        view.sendSubview(toBack: mapView)

        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    func calculateElevation(lat: Double, lng: Double) {
        let request = GetElevationRequest(lat: lat, lng: lng)
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case .success(let object):
                guard let item = object.results.first else { return }
                
                if item.elevation == 0 {
                    self.elevationLabel.textColor = UIColor.init(hex: "CB1B45")
                    self.elevationLabel.text = "0(計測不能)"
                } else {
                    if item.elevation > 5 {
                        self.elevationLabel.textColor = UIColor.init(hex: "333333")
                    } else {
                        self.elevationLabel.textColor = UIColor.init(hex: "DB4D6D")
                    }
                    
                    self.elevationLabel.text = item.formattedElevation
                    
                    let location = LocationEntity(latitude: lat, longitude: lng, elevation: item.elevation)
                    self.locations.append(location)
                    
                    self.mark(lat: lat, lng: lng, elavation: item.formattedElevation)
                    
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print("error: \(error)")
            }
        }
    }
    
    // elevationの設定を纏める
    func setElevation(_ elevation: ElevationEntity) {
    }
    
    // 凄まじくダサい
    // ElevationEntity.ItemEntityでlat, lngを受け取る
    func mark(lat: Double, lng: Double, elavation: String) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.snippet = elavation
        marker.map = mapView
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        currentLocation = location.coordinate
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        currentCameraPosition = position
    }

    @IBAction func didPressCalculateButton(_ sender: Any) {
        guard let currentCameraPosition = currentCameraPosition else { return }

        calculateElevation(lat: currentCameraPosition.target.latitude, lng: currentCameraPosition.target.longitude)
    }
    
    @IBAction func didPressResetButton(_ sender: Any) {
        guard let currentLocation = currentLocation else { return }
        
        mapView.animate(toLocation: currentLocation)
        calculateElevation(lat: currentLocation.latitude, lng: currentLocation.longitude)
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

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // collectionViewはスクロール出来るようにする
    // 現状下に段が生成される
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PinCell", for: indexPath) as! PinCell
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let location = locations[indexPath.row]
        let camera = GMSCameraPosition.camera(withLatitude: location.latitude,
                                              longitude: location.longitude,
                                              zoom: zoomLevel)
        mapView.animate(to: camera)
        
        let elevation = location.elevation
        
        if elevation > 5 {
            elevationLabel.textColor = UIColor.init(hex: "333333")
        } else {
            elevationLabel.textColor = UIColor.init(hex: "DB4D6D")
        }
        
        let text = NSString(format: "%.1f", elevation)
        elevationLabel.text = text as String
    }
}
