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
    
    @IBAction func userFlowButton(_ sender: UIButton) {
        let userFlowStoryboard = UIStoryboard(name: "MapIPitch", bundle: nil)
        let userFlowNavController = userFlowStoryboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = userFlowNavController
    }
    
    @IBAction func managerFlowButton(_ sender: UIButton) {
        let managerStoryboard = UIStoryboard(name: "Manager", bundle: nil)
        if FIRAuth.auth()?.currentUser != nil {
            let pitchManagerNavController = managerStoryboard.instantiateViewController(
                withIdentifier: "ManagerNavControllerId")
            UIApplication.shared.keyWindow?.rootViewController = pitchManagerNavController
        } else {
            let loginNavController = managerStoryboard.instantiateViewController(
                withIdentifier: "LoginNavControllerId")
            UIApplication.shared.keyWindow?.rootViewController = loginNavController
        }
    }

}
