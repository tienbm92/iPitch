//
//  String+Extension.swift
//  iPitch
//
//  Created by Huy Pham on 3/6/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation

extension String {
    
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.date(from: self)
    }
    
}
