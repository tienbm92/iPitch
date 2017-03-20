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

class MapIPitchControllers: UIViewController {
    
    enum ModeReload {
        case reloadFilter
        case reloadMap
    }
    
    enum ModeGetData {
        case getPullToRefresh
        case noPullToRefresh
    }
    
    enum isHidden {
        case hidden
        case noHidden
    }
    
    @IBOutlet weak var glassBackground: UIImageView!
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var viewDirection: UIView!
    @IBOutlet weak var drivingButton: UIButton!
    @IBOutlet weak var bicyclingButton: UIButton!
    @IBOutlet weak var walkingButton: UIButton!
    @IBOutlet weak var heightOptionVehicle: NSLayoutConstraint!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var listStadium: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var segmentedChangeView: UISegmentedControl!
    @IBOutlet weak var noFilterLabel: UILabel!
    @IBOutlet weak var detailDirectionLabel: UILabel!
    let locationManager = CLLocationManager()
    let directionService = DirectionService()
    let dictPitch = [String:Any]()
    let zoomLevel: Float = 15.0
    var originLatitude: Double = 0
    var originLongtitude: Double = 0
    var destinationLatitude: Double = 0
    var destinationLongtitude: Double = 0
    var pitches = [Pitch]()
    var index = 0
    var travelMode = TravelModes.driving
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchTextField.doneInvocation = (self, #selector(search))
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        listStadium.dataSource = self
        listStadium.delegate = self
        listStadium.estimatedRowHeight = 100
        listStadium.isHidden = true
        listStadium.rowHeight = UITableViewAutomaticDimension
        getData(mode: .noPullToRefresh, searchText: nil)
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
        self.noFilterLabel.isHidden = true
        self.listStadium.addPullToRefresh { [weak self] in
            self?.getData(mode: .getPullToRefresh, searchText: nil)
        }
        self.noFilterLabel.text = "NoDataFilter".localized
        self.heightOptionVehicle.constant = 0
        self.isHiddenButton(isHidden: .hidden)
        self.moveButtonDirectionDetail(isHidden: .hidden)
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.glassBackground.makeBlurEffect()
        }else{
            self.glassBackground.image = nil
        }
    }
    
    @IBAction func changeViewType(_ sender: UISegmentedControl) {
        self.closeDetailDirection()
        self.moveButtonDirectionDetail(isHidden: .hidden)
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
        self.reloadMapView(mode: .reloadMap)
        let origin: String = "\(originLatitude),\(originLongtitude)"
        let destination: String =
            "\(destinationLatitude),\(destinationLongtitude)"
        WindowManager.shared.showProgressView()
        self.directionService.getDirections(origin: origin,
            destination: destination,
            travelMode: travelMode) { [weak self] (success) in
            if success {
                self?.drawRoute()
                WindowManager.shared.hideProgressView()
                if let totalDistance = self?.directionService.totalDistance,
                    let totalDuration = self?.directionService.totalDuration {
                    let total = totalDistance + ". " + totalDuration
                    DispatchQueue.main.async {
                        self?.isHiddenButton(isHidden: .hidden)
                        UIView.animate(withDuration: 0.3, animations: {
                            self?.isHiddenLabel(isHidden: .noHidden)
                            self?.detailDirectionLabel.text = total
                            self?.moveButtonDirectionDetail(isHidden: .hidden)
                        })
                    }
                }
            } else {
                WindowManager.shared.hideProgressView()
                DispatchQueue.main.async {
                    WindowManager.shared.showMessage(
                        message: "DirectionError".localized,
                        title: "DirectionFalse".localized, completion: nil)
                }
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
    
    fileprivate func getData(mode: ModeGetData, searchText: String?) -> Void {
        if mode == .noPullToRefresh {
            WindowManager.shared.showProgressView()
        }
        PitchService.shared.getPitch(searchText: searchText, radius: nil,
        districtId: nil, timeFrom: nil, timeTo: nil) { [weak self] (pitches) in
            if mode == .noPullToRefresh {
                WindowManager.shared.hideProgressView()
            } else {
                self?.listStadium.pullToRefreshView.stopAnimating()
            }
            self?.pitches = pitches
            self?.listStadium.reloadData()
            self?.reloadMapView(mode: .reloadMap)
            self?.searchTextField.text = nil
            if !pitches.isEmpty {
                self?.noFilterLabel.isHidden = true
            } else {
                self?.noFilterLabel.isHidden = false
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
        for pitch in pitches {
            let location = CLLocationCoordinate2D(latitude:
                pitch.latitude, longitude: pitch.longitude)
            let markerStadium = GMSMarker(position: location)
            markerStadium.title = pitch.name
            markerStadium.snippet = pitch.address
            markerStadium.iconView = imageView
            markerStadium.map = self.mapView
        }
    }
    
    @IBAction func actionOptionSearch(_ sender: UIButton) {
        self.closeDetailDirection()
        self.moveButtonDirectionDetail(isHidden: .hidden)
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
        getData(mode: .noPullToRefresh, searchText: nil)
        self.closeDetailDirection()
        self.moveButtonDirectionDetail(isHidden: .hidden)
    }
    
    @IBAction func homeButtonTapped(_ sender: UIBarButtonItem) {
        WindowManager.shared.directToMainStoryboard()
    }
    
    fileprivate func pushPitchInfoViewController() {
        guard let pitchInfoViewController =
            UIStoryboard.orderExtra.instantiateViewController(withIdentifier:
            String(describing: PitchInfoViewController.self))
            as? PitchInfoViewController else {
            return
        }
        pitchInfoViewController.pitch = pitches[index]
        self.navigationController?.pushViewController(pitchInfoViewController,
                                                      animated: true)
    }
    
    func search() {
        guard let searchText = searchTextField.text else {
            return
        }
        self.closeDetailDirection()
        self.moveButtonDirectionDetail(isHidden: .hidden)
        WindowManager.shared.showProgressView()
        self.getData(mode: .noPullToRefresh, searchText: searchText)
    }
    
    fileprivate func closeDetailDirection() {
        self.isHiddenLabel(isHidden: .hidden)
        self.isHiddenButton(isHidden: .hidden)
        self.directionService.totalDistanceInMeters = 0
        self.directionService.totalDurationInSeconds = 0
        self.directionService.selectLegs.removeAll()
        self.directionService.selectSteps.removeAll()
        self.heightOptionVehicle.constant = 0
        UIView.animate(withDuration: 0.3, animations: { 
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func chooseVehicle(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.travelMode = TravelModes.walking
        case 1:
            self.travelMode = TravelModes.bicycling
        case 2:
            self.travelMode = TravelModes.driving
        default:
            print("error")
            break
        }
        self.moveButtonDirectionDetail(isHidden: .hidden)
        self.directionUserStadium()
    }
    
    fileprivate func isHiddenButton(isHidden: isHidden) {
        switch isHidden {
        case .noHidden:
            self.walkingButton.isHidden = false
            self.bicyclingButton.isHidden = false
            self.drivingButton.isHidden = false
        case .hidden:
            self.walkingButton.isHidden = true
            self.bicyclingButton.isHidden = true
            self.drivingButton.isHidden = true
        }
    }
    
    fileprivate func isHiddenLabel(isHidden: isHidden) {
        switch isHidden {
        case .hidden:
            self.detailDirectionLabel.isHidden = true
            self.viewDirection.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        case .noHidden:
            self.detailDirectionLabel.isHidden = false
            self.viewDirection.backgroundColor = #colorLiteral(red: 0.1254394945, green: 0.5569097896, blue: 0.1852708614, alpha: 0.515812286)
        }
    }
    
    fileprivate func moveButtonDirectionDetail(isHidden: isHidden) {
        switch isHidden {
        case .noHidden:
            self.detailButton.isHidden = false
            self.directionButton.isHidden = false
        case .hidden:
            self.detailButton.isHidden = true
            self.directionButton.isHidden = true
        }
    }
    
    @IBAction func actionDetailOrDirection(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.pushPitchInfoViewController()
            self.heightOptionVehicle.constant = 0
        case 1:
            self.isHiddenLabel(isHidden: .hidden)
            self.isHiddenButton(isHidden: .noHidden)
            self.walkingButton.alpha = 0.0
            self.drivingButton.alpha = 0.0
            self.bicyclingButton.alpha = 0.0
            UIView.animate(withDuration: 0.3) {
                self.walkingButton.alpha = 1.0
                self.drivingButton.alpha = 1.0
                self.bicyclingButton.alpha = 1.0
            }
        default:
            print("error action detail direction")
            break
        }
        self.moveButtonDirectionDetail(isHidden: .hidden)
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
        self.view.endEditing(true)
        self.closeDetailDirection()
        self.heightOptionVehicle.constant = 40
        self.moveButtonDirectionDetail(isHidden: .noHidden)
        self.detailButton.alpha = 0.0
        self.directionButton.alpha = 0.0
        UIView.animate(withDuration: 0.3, animations: { 
            self.view.layoutIfNeeded()
            self.detailButton.alpha = 1.0
            self.directionButton.alpha = 1.0
        }, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView,
                 didTapAt coordinate: CLLocationCoordinate2D) {
        self.view.endEditing(true)
        self.closeDetailDirection()
        self.moveButtonDirectionDetail(isHidden: .hidden)
    }
    
    func mapView(_ mapView: GMSMapView, didTap overlay: GMSOverlay) {
        self.view.endEditing(true)
        self.closeDetailDirection()
        self.moveButtonDirectionDetail(isHidden: .hidden)
    }
    
    func mapView(_ mapView: GMSMapView,
                 markerInfoWindow marker: GMSMarker) -> UIView? {
        guard let markerCustom = Bundle.main.loadNibNamed(
            "MarkerView", owner: nil, options: nil)?[0] as? MarkerView else {
            return UIView()
        }
        let markerLatitude = marker.position.latitude
        let markerLongitude = marker.position.longitude
        self.destinationLatitude = markerLatitude
        self.destinationLongtitude = markerLongitude
        for i in 0..<pitches.count {
            if markerLatitude == pitches[i].latitude {
                self.index = i
            }
        }
        markerCustom.pitch = self.pitches[index]
        self.moveButtonDirectionDetail(isHidden: .hidden)
        
        return markerCustom
    }
    
}

extension MapIPitchControllers: UITableViewDataSource, UITableViewDelegate {
    
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
        cell.selectionStyle = .none
        cell.layoutIfNeeded()
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
            self?.pitches = pitches
            if !pitches.isEmpty {
                self?.noFilterLabel.isHidden = true
            } else {
                self?.noFilterLabel.isHidden = false
            }
            self?.listStadium.reloadData()
            self?.reloadMapView(mode: .reloadFilter)
        }
    }
}

extension MapIPitchControllers: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.search()
        return true
    }
    
}

