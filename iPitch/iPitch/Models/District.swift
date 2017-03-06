//
//  District.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import ObjectMapper

class District: Mappable {
    
    var id: Int?
    var name = ""
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map) {
        id   <- map["id"]
        name <- map["name"]
    }
        
}
