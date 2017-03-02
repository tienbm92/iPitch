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
    @IBOutlet weak var lishStadium: UITableView!
    let locationManager = CLLocationManager()
    let directionService = DirectionService()
    let zoomLevel: Float = 15.0
    var originLatitude: Double = 0
    var originLongtitude: Double = 0
    var destinationLatitude: Double = 0
    var destinationLongtitude: Double = 0
    
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
    
    @IBAction func changeViewType(_ sender: Any) {
        lishStadium.isHidden = mapView.isHidden
        mapView.isHidden = !mapView.isHidden
    }
    
    @IBAction func directionMap(_ sender: Any) {
        directionUserStadium()
    }
    
    // direction user - stadium
    func directionUserStadium() {
        let origin: String = "\(originLatitude),\(originLongtitude)"
        let destination: String =
            "\(destinationLatitude),\(destinationLongtitude)"
        self.directionService.getDirections(origin: origin,
            destination: destination,
            travelMode: TravelModes.driving) { (status, success) in
            if success {
                self.drawRoute()
            } else {
                print(status ?? "")
            }
        }
    }
    
    // Draw route
    func drawRoute() {
        if let route = directionService.overviewPolyline["points"] as? String ,
            let path = GMSPath(fromEncodedPath: route) {
            let routePolyline = GMSPolyline(path: path)
            routePolyline.strokeColor = UIColor.red
            routePolyline.strokeWidth = 3.0
            routePolyline.map = mapView
        }
    }
}

extension MapIPitchControllers: CLLocationManagerDelegate, GMSMapViewDelegate{
    
    //Handle incoming location events.
    func locationManager(_ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
        if let location: CLLocation = locations.last {
            print("Location: \(location)")
            let locationLatitude = location.coordinate.latitude
            let locationLongtitude = location.coordinate.longitude
            self.originLatitude = locationLatitude
            self.originLongtitude = locationLongtitude
            let camera = GMSCameraPosition.camera(
                withLatitude: locationLatitude,
                longitude: locationLongtitude, zoom: zoomLevel)
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
            let marker = GMSMarker(position: CLLocationCoordinate2D(
                latitude: locationLatitude,
                longitude: locationLongtitude))
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
        marker.title = "Name Stadium"
        let imageView = UIImageView(image: #imageLiteral(resourceName: "Stadium-icon.png"))
        imageView.bounds.size = CGSize(width: 50, height: 50)
        marker.iconView = imageView
        marker.map = self.mapView
    }
    
    // Event tab marker
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let markerLatitude = marker.position.latitude
        let markerLongitude = marker.position.longitude
        self.destinationLatitude = markerLatitude
        self.destinationLongtitude = markerLongitude
        print("tab marker\(markerLatitude), \(markerLongitude)")
    }
   
}
