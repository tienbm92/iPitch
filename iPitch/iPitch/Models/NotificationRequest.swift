//
//  NotificationRequest.swift
//  iPitch
//
//  Created by Huy Pham on 3/10/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct NotificationRequest: Mappable {
    
    var notification: NotificationContent?
    var to: String?
    
    init() {
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        notification <- map["notification"]
        to           <- map["to"]
    }
    
}
