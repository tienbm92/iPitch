//
//  Routes.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/13/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct Route: Mappable {
    
    var bounds = Bounds()
    var copyrights = ""
    var legs = [Leg]()
    var overviewPolyline = Polyline()
    var summary = ""
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        bounds              <- map["bounds"]
        copyrights          <- map["copyrights"]
        legs                <- map["legs"]
        overviewPolyline    <- map["overview_polyline"]
        summary             <- map["summary"]
    }
    
}
