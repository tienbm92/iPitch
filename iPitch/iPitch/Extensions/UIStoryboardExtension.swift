//
//  UIStoryboardExtension.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static func manager() -> UIStoryboard {
        return UIStoryboard(name: "Manager", bundle: nil)
    }
    
    static func mapIPitch() -> UIStoryboard {
        return UIStoryboard(name: "MapIPitch", bundle: nil)
    }
    
}
