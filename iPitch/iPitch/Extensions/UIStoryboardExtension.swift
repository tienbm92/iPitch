//
//  UIStoryboardExtension.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static var manager: UIStoryboard {
        let managerStoryboard = UIStoryboard(name: "Manager", bundle: nil)
        return managerStoryboard
    }
    
    static var mapIPitch: UIStoryboard {
        let mapIPitchStoryboard = UIStoryboard(name: "MapIPitch", bundle: nil)
        return mapIPitchStoryboard
    }
    
}
