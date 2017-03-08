//
//  Order.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct Order: Mappable {
    
    var id: String?
    var name: String?
    var phone: String?
    var pitchId: String?
    var timeFrom: Date?
    var timeTo: Date?
    var isAccept = false
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        id       <- map["id"]
        name     <- map["name"]
        phone    <- map["phone"]
        pitchId  <- map["pitchId"]
        timeFrom <- (map["timeFrom"], DateTransform())
        timeTo   <- (map["timeTo"], DateTransform())
        isAccept <- map["isAccept"]
    }
    
}
