//
//  MapIPitchControllers.swift
//  iPitch
//
//  Created by Bui Minh Tien on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import GoogleMaps

class MapIPitchControllers: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let zoomLevel: Float = 15.0

    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the location manager.
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        // Setting map
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
    }

}

extension MapIPitchControllers: CLLocationManagerDelegate, GMSMapViewDelegate{
    
    //Handle incoming location events.
    func locationManager(_ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.last {
            print("Location: \(location)")
            let camera = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude, zoom: zoomLevel)
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
            let marker = GMSMarker(position: CLLocationCoordinate2D(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude))
            marker.title = "Current location"
            marker.isFlat = true
            marker.map = self.mapView
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager,
        didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func mapView(_ mapView: GMSMapView,
        didLongPressAt coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker(position: coordinate)
        marker.title = "possion long press"
        marker.map = self.mapView
    }
    
}
