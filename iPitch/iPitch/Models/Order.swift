//
//  Order.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

class Order: Mappable {
    
    var id: String?
    var name: String?
    var phone: String?
    var pitchId: String?
    var timeFrom: Date?
    var timeTo: Date?
    var isAccept = false
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id       <- map["id"]
        name     <- map["name"]
        phone    <- map["phone"]
        pitchId  <- map["pitch_id"]
        timeFrom <- (map["time_from"], DateTransform())
        timeTo   <- (map["time_to"], DateTransform())
        isAccept <- map["is_accept"]
    }
    
}
