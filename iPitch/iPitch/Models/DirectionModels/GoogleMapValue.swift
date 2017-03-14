//
//  Duration.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/13/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct GoogleMapValue: Mappable {
    
    var text = ""
    var value: Int?
    
    init() {
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        text    <- map["text"]
        value   <- map["value"]
    }
    
}
