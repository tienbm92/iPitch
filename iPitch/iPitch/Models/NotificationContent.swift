//
//  NotificationContent.swift
//  iPitch
//
//  Created by Huy Pham on 3/10/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

struct NotificationContent: Mappable {
    
    var title: String?
    var body: String?
    
    init(title: String?, body: String?) {
        self.title = title
        self.body = body
    }
    
    init?(map: Map) {
    }
    
    mutating func mapping(map: Map) {
        title <- map["title"]
        body  <- map["body"]
    }
    
}
