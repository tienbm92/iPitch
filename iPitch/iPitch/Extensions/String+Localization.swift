//
//  String+Localization.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation

extension String {
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main,
                                 value: "", comment: "")
    }
    
}
