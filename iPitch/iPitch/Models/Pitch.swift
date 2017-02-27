//
//  Pitch.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

class Pitch: Mappable {
    
    var id: String?
    var name = ""
    var address = ""
    var phone = ""
    var latitude = 0.0
    var longitude = 0.0
    var ownerId: String?
    var districtId: String?
    var activeTimeFrom: Date?
    var activeTimeTo: Date?
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id             <- map["id"]
        name           <- map["name"]
        address        <- map["address"]
        phone          <- map["phone"]
        latitude       <- map["latitude"]
        longitude      <- map["longitude"]
        ownerId        <- map["owner_id"]
        districtId     <- map["district_id"]
        activeTimeFrom <- (map["active_time_from"], DateTransform())
        activeTimeTo   <- (map["active_time_to"], DateTransform())
    }
    
}
