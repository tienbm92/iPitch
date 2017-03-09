//
//  Bounds.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/13/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct Bounds: Mappable {
    
    var northeast = Location()
    var southwest = Location()
    
    init() {
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        northeast   <- map["northeast"]
        southwest   <- map["southwest"]
    }
    
}
