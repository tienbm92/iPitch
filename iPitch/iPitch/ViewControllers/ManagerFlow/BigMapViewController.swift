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
    var location: CLLocation?
    var callback: ((CLLocationCoordinate2D) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        if let location = location {
            mapView.camera = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude, zoom: 15.0)
            setNewMapMarker(withCoordinate: location.coordinate)
        } else {
            WindowManager.shared.showMessage(message: kLocationNotFound,
                title: nil, completion: { (action) in
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                } else if let presentingViewController =
                    self.presentingViewController {
                    presentingViewController.dismiss(animated: true,
                        completion: nil)
                }
            })

        }
    }
    
    fileprivate func setNewMapMarker(
        withCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        mapView.selectedMarker = marker
    }

}

extension BigMapViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView,
        didTapAt coordinate: CLLocationCoordinate2D) {
        self.setNewMapMarker(withCoordinate: coordinate)
        if let callback = callback {
            callback(coordinate)
        }
    }
    
}
