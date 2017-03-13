//
//  Date+Extension.swift
//  iPitch
//
//  Created by Huy Pham on 3/6/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation

extension Date {
    
    var time: TimeInterval {
        return self.timeIntervalSince(Calendar.current.startOfDay(for: self))
    }
    
    func toTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: self)
    }
    
    func toDateString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: self)
    }
    
}
