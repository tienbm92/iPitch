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
    @IBOutlet weak var listStadium: UITableView!
    let locationManager = CLLocationManager()
    let directionService = DirectionService()
    let dictPitch = [String:Any]()
    let zoomLevel: Float = 15.0
    var originLatitude: Double = 0
    var originLongtitude: Double = 0
    var destinationLatitude: Double = 0
    var destinationLongtitude: Double = 0
    var pitches = [Pitch]()
    
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
        // Setting table view
        listStadium.dataSource = self
        listStadium.delegate = self
        // loading data
        getData()
    }
    
    @IBAction func changeViewType(_ sender: Any) {
        listStadium.isHidden = mapView.isHidden
        mapView.isHidden = !mapView.isHidden
    }
    
    // direction user - stadium
    fileprivate func directionUserStadium() {
        let origin: String = "\(originLatitude),\(originLongtitude)"
        let destination: String =
            "\(destinationLatitude),\(destinationLongtitude)"
        WindowManager.shared.showProgressView()
        self.directionService.getDirections(origin: origin,
            destination: destination,
            travelMode: TravelModes.driving) { [weak self] (status, success) in
            if success {
                self?.drawRoute()
                WindowManager.shared.hideProgressView()
            } else {
                print(status ?? "")
                // TODO
            }
        }
    }
    
    // Draw route
    fileprivate func drawRoute() {
        if let route = directionService.overviewPolyline["points"] as? String,
            let path = GMSPath(fromEncodedPath: route) {
            let routePolyline = GMSPolyline(path: path)
            routePolyline.strokeColor = UIColor.red
            routePolyline.strokeWidth = 3.0
            routePolyline.map = mapView
        }
    }
    
    fileprivate func getData() -> Void {
        WindowManager.shared.showProgressView()
        PitchService.shared.getPitch(radius: nil,
        districtId: nil, timeFrom: nil, timeTo: nil) { [weak self] (pitches) in
            WindowManager.shared.hideProgressView()
            self?.pitches = pitches
            self?.listStadium.reloadData()
            // show stadium
            for pitch in pitches {
                let location = CLLocationCoordinate2D(latitude:
                    pitch.latitude, longitude: pitch.longitude)
                let markerStadium = GMSMarker(position: location)
                markerStadium.title = pitch.name
                markerStadium.snippet = pitch.address
                markerStadium.map = self?.mapView
            }
        }
    }
    
    fileprivate func reloadMapView() {
        mapView.clear()
        // show current location
        let currentLocation = CLLocationCoordinate2D(
            latitude: originLatitude, longitude: originLongtitude)
        let camera = GMSCameraPosition.camera(withTarget:
            currentLocation, zoom: zoomLevel)
        mapView.animate(to: camera)
        let marker = GMSMarker(position: currentLocation)
        marker.map = self.mapView
        // show stadium 
        for pitch in pitches {
            let location = CLLocationCoordinate2D(latitude:
                pitch.latitude, longitude: pitch.longitude)
            let markerStadium = GMSMarker(position: location)
            markerStadium.title = pitch.name
            markerStadium.snippet = pitch.address
            markerStadium.map = self.mapView
        }
    }
    
    fileprivate func showAlertMapView(message: String, title: String,
        completion: ((UIAlertAction) -> Void)?) {
        WindowManager.shared.alertWindow.windowLevel =
            WindowManager.shared.getCurrentWindowLevel() + 0.1
        let alertController = UIAlertController(
            title: title, message: message, preferredStyle: .alert)
        let diretionAction = UIAlertAction(title: "Direction", style: .default)
            { [weak self] (action) in
            WindowManager.shared.alertWindow.isHidden = true
            if let completion = completion {
                completion(action)
            }
            self?.reloadMapView()
            self?.directionUserStadium()
        }
        let detailAction = UIAlertAction(title: "Deatil", style: .default)
            { [weak self] (action) in
            WindowManager.shared.alertWindow.isHidden = true
            if let completion = completion {
                completion(action)
            }
            // TODO
        }
        alertController.addAction(diretionAction)
        alertController.addAction(detailAction)
        DispatchQueue.main.async {
            WindowManager.shared.alertWindow.isHidden = false
            WindowManager.shared.alertWindow.rootViewController?.present(
                alertController, animated: true, completion: nil)
        }
    }
    
}

extension MapIPitchControllers: CLLocationManagerDelegate, GMSMapViewDelegate,
    UITableViewDataSource, UITableViewDelegate {
    
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
    
    // Event tab marker
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let markerLatitude = marker.position.latitude
        let markerLongitude = marker.position.longitude
        self.destinationLatitude = markerLatitude
        self.destinationLongtitude = markerLongitude
        print("tab marker\(markerLatitude), \(markerLongitude)")
        self.showAlertMapView(message: "Direction or Detail Stadium",
            title: "what do you want?", completion: nil)
    }
    
    func tableView(_ tableView: UITableView,
        numberOfRowsInSection section: Int) -> Int {
        return pitches.count
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.listStadium.dequeueReusableCell(
            withIdentifier: "stadiumCell", for: indexPath)
            as? StadiumCell  else {
            return UITableViewCell()
        }
        cell.pitch = pitches[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        
    }
   
}
