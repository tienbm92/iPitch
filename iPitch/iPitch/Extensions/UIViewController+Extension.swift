//
//  UIViewController+Extension.swift
//  iPitch
//
//  Created by Huy Pham on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func back() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else if let presentingViewController = self.presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
}
