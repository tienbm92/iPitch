//
//  UIStoryboard+Extension.swift
//  iPitch
//
//  Created by Huy Pham on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    static var manager: UIStoryboard {
        return UIStoryboard(name: "Manager", bundle: nil)
    }
    
    static var mapIPitch: UIStoryboard {
        return UIStoryboard(name: "MapIPitch", bundle: nil)
    }
    
    static var pitchExtra: UIStoryboard {
        return UIStoryboard(name: "PitchExtra", bundle: nil)
    }
    static var OrderExtra: UIStoryboard {
        return UIStoryboard(name: "OrderExtra", bundle: nil)
    }
    
}
