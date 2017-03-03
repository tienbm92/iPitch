//
//  IQKeyboardManagerConfiguration.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/1/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import IQKeyboardManagerSwift

class IQKeyboardManagerConfiguration {
    
    static let shared = IQKeyboardManagerConfiguration()
    
    func configKeyboard() {
        IQKeyboardManager.sharedManager().shouldResignOnTouchOutside = true
        IQKeyboardManager.sharedManager().keyboardDistanceFromTextField = 10
    }
    
}
