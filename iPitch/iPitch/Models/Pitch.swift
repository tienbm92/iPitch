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
    var ownerId: String?
    var name = ""
    var address = ""
    var phone = ""
    var latitude = 0.0
    var longitude = 0.0
    var district: District?
    var activeTimeFrom: Date?
    var activeTimeTo: Date?
    var photoPath: String?
    
    init() {
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id             <- map["id"]
        name           <- map["name"]
        address        <- map["address"]
        phone          <- map["phone"]
        latitude       <- map["latitude"]
        longitude      <- map["longitude"]
        ownerId        <- map["ownerId"]
        district       <- map["district"]
        activeTimeFrom <- (map["activeTimeFrom"], DateTransform())
        activeTimeTo   <- (map["activeTimeTo"], DateTransform())
        photoPath      <- map["photoPath"]
    }
    
}
