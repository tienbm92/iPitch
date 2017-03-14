//
//  MapIPitchControllers.swift
//  iPitch
//
//  Created by Bui Minh Tien on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import GoogleMaps

enum modeReload: Int {
    case reloadFilter
    case reloadMap
}

class MapIPitchControllers: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var listStadium: UITableView!
    @IBOutlet weak var searchBar: UITextField!
    @IBOutlet weak var segmentedChangeView: UISegmentedControl!
    let locationManager = CLLocationManager()
    let directionService = DirectionService()
    let dictPitch = [String:Any]()
    let zoomLevel: Float = 15.0
    var originLatitude: Double = 0
    var originLongtitude: Double = 0
    var destinationLatitude: Double = 0
    var destinationLongtitude: Double = 0
    var pitches = [Pitch]()
    var filterPitch = [Pitch]()
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the location manager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
        // Setting map
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        // Setting table view
        listStadium.dataSource = self
        listStadium.delegate = self
        // loading data
        getData()
        segmentedChangeView.titleForSegment(at: 0)
    }
    
    @IBAction func changeViewType(_ sender: UISegmentedControl) {
        switch segmentedChangeView.selectedSegmentIndex {
        case 0:
            listStadium.isHidden = true
            mapView.isHidden = false
        case 1:
            listStadium.isHidden = false
            mapView.isHidden = true
        default:
            break
        }
    }
    
    // direction user - stadium
    fileprivate func directionUserStadium() {
        let origin: String = "\(originLatitude),\(originLongtitude)"
        let destination: String =
            "\(destinationLatitude),\(destinationLongtitude)"
        WindowManager.shared.showProgressView()
        self.directionService.getDirections(origin: origin,
            destination: destination,
            travelMode: TravelModes.driving) { [weak self] (success) in
            if success {
                self?.drawRoute()
                WindowManager.shared.hideProgressView()
                if let totalDistance = self?.directionService.totalDistance,
                    let totalDuration = self?.directionService.totalDuration {
                    DispatchQueue.main.async {
                        let total = totalDistance + "\n" + totalDuration
                        WindowManager.shared.showMessage(message: total,
                            title: "TotalDistanceAndDuration".localized,
                            completion: { (action) in
                            self?.directionService.totalDistanceInMeters = 0
                            self?.directionService.totalDurationInSeconds = 0
                        })
                    }
                }
            } else {
                WindowManager.shared.showMessage(
                    message: "DirectionError".localized,
                    title: "DirectionFalse".localized, completion: nil)
            }
        }
    }
    
    // Draw route
    fileprivate func drawRoute() {
        for step in self.directionService.selectSteps {
            if step.polyline.points != "" {
                let path = GMSPath(fromEncodedPath: step.polyline.points)
                let routePolyline = GMSPolyline(path: path)
                routePolyline.strokeColor = UIColor.red
                routePolyline.strokeWidth = 2.0
                routePolyline.map = mapView
            } else {
                return
            }
        }
    }
    
    fileprivate func getData() -> Void {
        WindowManager.shared.showProgressView()
        PitchService.shared.getPitch(searchText: nil, radius: nil,
        districtId: nil, timeFrom: nil, timeTo: nil) { [weak self] (pitches) in
        WindowManager.shared.hideProgressView()
        self?.pitches = pitches
        self?.listStadium.reloadData()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_stadium"))
        imageView.bounds.size = CGSize(width: 30, height: 30)
        // show stadium
        for pitch in pitches {
            let location = CLLocationCoordinate2D(latitude:
                pitch.latitude, longitude: pitch.longitude)
            let markerStadium = GMSMarker(position: location)
            markerStadium.title = pitch.name
            markerStadium.snippet = pitch.address
            markerStadium.map = self?.mapView
            markerStadium.iconView = imageView
            }
        }
    }
    
    fileprivate func reloadMapView(mode: modeReload) {
        mapView.clear()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_stadium"))
        imageView.bounds.size = CGSize(width: 36, height: 36)
        imageView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        imageView.borderColor = #colorLiteral(red: 0.08357391538, green: 0.3608524935, blue: 0.1193320996, alpha: 1)
        imageView.borderWidth = 1.0
        imageView.cornerRadius = 18
        // show stadium
        let array = (mode == .reloadFilter && filterPitch.count > 0) ?
            filterPitch : pitches
        for pitch in array {
            let location = CLLocationCoordinate2D(latitude:
                pitch.latitude, longitude: pitch.longitude)
            let markerStadium = GMSMarker(position: location)
            markerStadium.title = pitch.name
            markerStadium.snippet = pitch.address
            markerStadium.iconView = imageView
            markerStadium.map = self.mapView
            markerStadium.index(ofAccessibilityElement: pitch)
        }
    }
    
    fileprivate func showAlertMapView(message: String, title: String,
        completion: ((UIAlertAction) -> Void)?) {
        WindowManager.shared.alertWindow.windowLevel =
            WindowManager.shared.getCurrentWindowLevel() + 0.1
        let alertController = UIAlertController(
            title: title, message: message, preferredStyle: .alert)
        let diretionAction = UIAlertAction(title: "Direction".localized,
                                           style: .default)
            { [weak self] (action) in
            WindowManager.shared.alertWindow.isHidden = true
            if let completion = completion {
                completion(action)
            }
            self?.reloadMapView(mode: .reloadMap)
            self?.directionUserStadium()
        }
        let detailAction = UIAlertAction(title: "Detail".localized,
                                         style: .default)
            { [weak self] (action) in
            WindowManager.shared.alertWindow.isHidden = true
            if let completion = completion {
                completion(action)
            }
            self?.pushPitchInfoViewController()
        }
        alertController.addAction(diretionAction)
        alertController.addAction(detailAction)
        DispatchQueue.main.async {
            WindowManager.shared.alertWindow.isHidden = false
            WindowManager.shared.alertWindow.rootViewController?.present(
                alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func actionOptionSearch(_ sender: UIButton) {
        guard let searchViewController =
            storyboard?.instantiateViewController(
            withIdentifier: String(describing: SearchViewController.self))
            as? SearchViewController else {
            return
        }
        searchViewController.delegate = self
        present(searchViewController, animated: true, completion: nil)
    }
    
    @IBAction func buttonReload(_ sender: UIBarButtonItem) {
        mapView.clear()
        getData()
        filterPitch.removeAll()
        listStadium.reloadData()
    }
    
    @IBAction func homeButtonTapped(_ sender: UIBarButtonItem) {
        WindowManager.shared.directToMainStoryboard()
    }
    
    fileprivate func pushPitchInfoViewController() {
        let orderExtraStoryboard = UIStoryboard(name: "OrderExtra", bundle: nil)
        guard let pitchInfoViewController =
            orderExtraStoryboard.instantiateViewController(withIdentifier:
            String(describing: PitchInfoViewController.self))
            as? PitchInfoViewController else {
            return
        }
        let array = (filterPitch.count > 0) ? filterPitch : pitches
        pitchInfoViewController.pitch = array[index]
        self.navigationController?.pushViewController(pitchInfoViewController,
                                                      animated: true)
    }
 
}

extension MapIPitchControllers: CLLocationManagerDelegate, GMSMapViewDelegate {
    
    //Handle incoming location events.
    func locationManager(_ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if let location: CLLocation = locations.last {
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
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
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
        let array = (self.filterPitch.count > 0)
            ? self.filterPitch : self.pitches
        for i in 0..<array.count {
            if markerLatitude == array[i].latitude {
                self.index = i
            }
        }
        self.showAlertMapView(message: "DirectionOrDetail".localized,
            title: "TitleDirection".localized, completion: nil)
    }
   
}

extension MapIPitchControllers: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if filterPitch.count > 0 {
            return filterPitch.count
        }
        return pitches.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = self.listStadium.dequeueReusableCell(
            withIdentifier: "stadiumCell", for: indexPath)
            as? StadiumCell  else {
                return UITableViewCell()
        }
        if filterPitch.count > 0 {
            cell.pitch = filterPitch[indexPath.row]
            return cell
        }
        cell.pitch = pitches[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath.row
        self.pushPitchInfoViewController()
    }
    
}

extension MapIPitchControllers: searchViewControllerDelegate {
    
    func searchViewController(_ searchViewController: SearchViewController,
        didCloseWith result: Any?) {
        var radius: Double?
        var timeFrom: Date?
        var timeTo: Date?
        var districtID: Int?
        var searchText: String?
        guard let resultDict = result as? [String:Any] else {
            return
        }
        if let radiusDouble = resultDict["radius"] as? Double {
            radius = radiusDouble
        }
        if let timeFromDict = resultDict["timeFrom"] as? Date {
            timeFrom = timeFromDict
        }
        if let timeToDict = resultDict["timeTo"] as? Date {
            timeTo = timeToDict
        }
        if let districtIDDict = resultDict["districtID"] as? Int {
            districtID = districtIDDict
        }
        searchText = (self.searchBar.text == "") ? nil : self.searchBar.text
        PitchService.shared.getPitch(searchText: searchText,
                                     radius: radius, districtId: districtID,
                                     timeFrom: timeFrom, timeTo: timeTo)
        { [weak self] (pitches) in
            self?.filterPitch = pitches
            if let filterCount = self?.filterPitch.count, filterCount > 0 {
                self?.reloadMapView(mode: .reloadFilter)
                self?.listStadium.reloadData()
            } else {
                WindowManager.shared.showMessage(
                    message: "FilterFalse".localized,
                    title: "TitleFilter".localized, completion: nil)
            }
        }
    }
    
}

