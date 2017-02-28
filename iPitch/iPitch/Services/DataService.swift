//
//  DataService.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class DataService {
    
    var ref: FIRDatabaseReference!
    
    init() {
        ref = FIRDatabase.database().reference()
    }
    
}
