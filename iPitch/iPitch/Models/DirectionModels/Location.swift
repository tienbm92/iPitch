//
//  endLocation.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/13/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct Location: Mappable {
    
    var latitude = 0.0
    var longtidude = 0.0
    
    init() {
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        latitude    <- map["lat"]
        longtidude  <- map["lng"]
    }
    
}
