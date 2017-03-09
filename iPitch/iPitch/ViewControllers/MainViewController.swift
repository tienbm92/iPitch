//
//  MainViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/3/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import Firebase

class MainViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func userFlowButton(_ sender: UIButton) {
        WindowManager.shared.directToUserFlow()
    }
    
    @IBAction func managerFlowButton(_ sender: UIButton) {
        WindowManager.shared.directToCheckLogin()
    }

}
