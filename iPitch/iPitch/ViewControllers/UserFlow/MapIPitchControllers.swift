//
//  MapIPitchControllers.swift
//  iPitch
//
//  Created by Bui Minh Tien on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import GoogleMaps
import SVPullToRefresh

enum ModeReload: Int {
    case reloadFilter
    case reloadMap
}

enum ModeGetData {
    case getPullToRefresh
    case noPullToRefresh
}

class MapIPitchControllers: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var listStadium: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var segmentedChangeView: UISegmentedControl!
    @IBOutlet weak var noFilterLabel: UILabel!
    let locationManager = CLLocationManager()
    let directionService = DirectionService()
    let dictPitch = [String:Any]()
    let zoomLevel: Float = 15.0
    var originLatitude: Double = 0
    var originLongtitude: Double = 0
    var destinationLatitude: Double = 0
    var destinationLongtitude: Double = 0
    var pitches = [Pitch]()
    var filterPitch = [Pitch]() {
        didSet {
            if !filterPitch.isEmpty {
                self.noFilterLabel.isHidden = true
                self.reloadMapView(mode: .reloadFilter)
                self.listStadium.reloadData()
            } else {
                self.pitches.removeAll()
                self.reloadMapView(mode: .reloadFilter)
                self.listStadium.reloadData()
                self.noFilterLabel.isHidden = false
                self.noFilterLabel.text = "NoDataFilter".localized
            }
        }
    }
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.doneInvocation = (self, #selector(search))
        // Initialize the location manager.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Setting map
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        // Setting table view
        listStadium.dataSource = self
        listStadium.delegate = self
        listStadium.estimatedRowHeight = 100
        listStadium.rowHeight = UITableViewAutomaticDimension
        segmentedChangeView.titleForSegment(at: 0)
        // loading data
        getData(mode: .noPullToRefresh)
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
        self.noFilterLabel.isHidden = true
        self.listStadium.addPullToRefresh { [weak self] in
            self?.filterPitch.removeAll()
            self?.getData(mode: .getPullToRefresh)
            DispatchQueue.main.async {
                self?.mapView.clear()
                self?.listStadium.reloadData()
                self?.noFilterLabel.isHidden = true
            }
        }
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
                            self?.directionService.selectLegs.removeAll()
                            self?.directionService.selectSteps.removeAll()
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
                routePolyline.strokeWidth = 3.0
                routePolyline.map = mapView
            } else {
                return
            }
        }
        
    }
    
    fileprivate func getData(mode: ModeGetData) -> Void {
        if mode == .noPullToRefresh {
            WindowManager.shared.showProgressView()
        }
        PitchService.shared.getPitch(searchText: nil, radius: nil,
        districtId: nil, timeFrom: nil, timeTo: nil) { [weak self] (pitches) in
            if mode == .noPullToRefresh {
                WindowManager.shared.hideProgressView()
            } else {
                self?.listStadium.pullToRefreshView.stopAnimating()
            }
            
            self?.listStadium.pullToRefreshView?.stopAnimating()
            self?.pitches = pitches
            self?.listStadium.reloadData()
            let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_stadium"))
            imageView.bounds.size = CGSize(width: 36, height: 36)
            imageView.borderColor = #colorLiteral(red: 0.08235294118, green: 0.3607843137, blue: 0.1176470588, alpha: 1)
            imageView.borderWidth = 1.0
            imageView.cornerRadius = 18
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
    
    fileprivate func reloadMapView(mode: ModeReload) {
        mapView.clear()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "ic_stadium"))
        imageView.bounds.size = CGSize(width: 36, height: 36)
        imageView.borderColor = #colorLiteral(red: 0.08235294118, green: 0.3607843137, blue: 0.1176470588, alpha: 1)
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
        noFilterLabel.isHidden = true
        mapView.clear()
        getData(mode: .noPullToRefresh)
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
    
    func search() {
        guard let searchStirng = searchTextField.text else {
            return
        }
        WindowManager.shared.showProgressView()
        PitchService.shared.getPitch(searchText: searchStirng,
            radius: nil, districtId: nil, timeFrom: nil, timeTo: nil,
            completion: { [weak self] (pitches) in
            WindowManager.shared.hideProgressView()
            self?.filterPitch = pitches
        })
    }
 
}

extension MapIPitchControllers: CLLocationManagerDelegate {
    
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
   
}

extension MapIPitchControllers: GMSMapViewDelegate {
    
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
        self.view.endEditing(true)
        self.showAlertMapView(message: "DirectionOrDetail".localized,
                              title: "TitleDirection".localized, completion: nil)
        
    }
    
    func mapView(_ mapView: GMSMapView,
                 didTapAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        self.view.endEditing(true)
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
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) {
        self.index = indexPath.row
        self.pushPitchInfoViewController()
    }
    
}

extension MapIPitchControllers: SearchViewControllerDelegate {
    
    func searchViewController(_ searchViewController: SearchViewController,
        didCloseWith filter: Filter?) {
        guard let filter = filter else {
            return
        }
        let searchText = (self.searchTextField.text == "") ? nil : self.searchTextField.text
        PitchService.shared.getPitch(searchText: searchText, radius: filter.radius,
            districtId: filter.district?.id, timeFrom: filter.startTime,
            timeTo: filter.endTime) { [weak self] (pitches) in
            self?.filterPitch = pitches
            if !pitches.isEmpty {
                self?.noFilterLabel.isHidden = true
                self?.reloadMapView(mode: .reloadFilter)
                self?.listStadium.reloadData()
            } else {
                self?.pitches.removeAll()
                self?.reloadMapView(mode: .reloadFilter)
                self?.listStadium.reloadData()
                self?.noFilterLabel.isHidden = false
                self?.noFilterLabel.text = "NoDataFilter".localized
            }
        }
    }
}

extension MapIPitchControllers: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        search()
        return true
    }
    
}

