//
//  GMSMapView+Extension.swift
//  iPitch
//
//  Created by Huy Pham on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import GoogleMaps

extension GMSMapView {
    
    func refreshMarker(toCoordinate coordinate: CLLocationCoordinate2D) {
        self.clear()
        let marker = GMSMarker(position: coordinate)
        marker.map = self
        self.selectedMarker = marker
        self.animate(toLocation: coordinate)
    }
    
}
