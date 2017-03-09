//
//  Pitch.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper
import CoreLocation

struct Pitch: Mappable {
    
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
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    init() {
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
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
    
    func validate() -> String? {
        guard name == "" else {
            return "InvalidName".localized
        }
        guard address == "" else {
            return "InvalidAddress".localized
        }
        guard phone == "" else {
            return "InvalidPhone".localized
        }
        guard district == nil else {
            return "InvalidDistrict".localized
        }
        guard let activeTimeFrom = activeTimeFrom else {
            return "InvalidTimeFrom".localized
        }
        guard let activeTimeTo = activeTimeTo else {
            return "InvalidTimeTo".localized
        }
        guard activeTimeFrom.time < activeTimeTo.time else {
            return "InvalidTimeFromAndTo".localized
        }
        return nil
    }
    
}
