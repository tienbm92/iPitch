//
//  BigMapViewController.swift
//  iPitch
//
//  Created by Huy Pham on 3/6/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreLocation

class BigMapViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    var coordinate: CLLocationCoordinate2D?
    var callback: ((CLLocationCoordinate2D) -> Void)?
    var allowEditing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if let coordinate = coordinate {
            mapView.camera = GMSCameraPosition.camera(
                withLatitude: coordinate.latitude,
                longitude: coordinate.longitude, zoom: 15.0)
            mapView.refreshMarker(toCoordinate: coordinate)
        } else {
            WindowManager.shared.showMessage(message: "LocationNotFound".localized,
                title: nil, completion: { [weak self] (action) in
                self?.back()
            })
        }
    }

}

extension BigMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView,
        didTapAt coordinate: CLLocationCoordinate2D) {
        if allowEditing {
            mapView.refreshMarker(toCoordinate: coordinate)
            if let callback = callback {
                callback(coordinate)
            }
        }
    }
    
}
