//
//  GeocodedWaypoints.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/13/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct GeocodedWaypoint: Mappable {
    
    var geocoderStatus = ""
    var placeId = ""
    var types = [String]()
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        geocoderStatus <- map["geocoder_status"]
        placeId        <- map["place_id"]
        types          <- map["types"]
    }
    
}
