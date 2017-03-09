//
//  directionTotal.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/13/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct DirectionOverview: Mappable {
    
    var geocodedWaypoints = [GeocodedWaypoint]()
    var routes = [Route]()
    var status = ""
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        geocodedWaypoints <- map["geocoded_waypoints"]
        routes            <- map["routes"]
        status            <- map["status"]
    }
    
}
