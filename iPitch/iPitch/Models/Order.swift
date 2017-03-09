//
//  Order.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

enum OrderStatus: String {
    case pending = "pending"
    case accept = "accept"
    case reject = "reject"
}

struct Order: Mappable {
    
    var id: String?
    var name = ""
    var phone = ""
    var pitchId: String?
    var timeFrom: Date?
    var timeTo: Date?
    var status: OrderStatus = .pending
    var modifiedDate: Date?
    
    init() {
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        name         <- map["name"]
        phone        <- map["phone"]
        pitchId      <- map["pitchId"]
        timeFrom     <- (map["timeFrom"], DateTransform())
        timeTo       <- (map["timeTo"], DateTransform())
        status       <- map["status"]
        modifiedDate <- (map["modifiedDate"], DateTransform())
    }
    
    func validate() -> String? {
        guard name == "" else {
            return "InvalidName".localized
        }
        guard phone == "" else {
            return "InvalidPhone".localized
        }
        guard let timeFrom = timeFrom else {
            return "InvalidTimeFrom".localized
        }
        guard let timeTo = timeTo else {
            return "InvalidTimeTo".localized
        }
        guard timeFrom.time < timeTo.time else {
            return "InvalidTimeFromAndTo".localized
        }
        return nil
    }
    
}
