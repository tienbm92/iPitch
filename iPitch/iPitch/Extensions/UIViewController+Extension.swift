//
//  UIViewController+Extension.swift
//  iPitch
//
//  Created by Huy Pham on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import IDMPhotoBrowser

extension UIViewController {
    
    func back() {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        } else if let presentingViewController = self.presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    func previewImage(_ image: UIImage?) {
        if let browser = IDMPhotoBrowser(photos: [IDMPhoto(
            image: image)]) {
            browser.displayActionButton = false;
            browser.displayArrowButton = false;
            browser.usePopAnimation = true;
            browser.forceHideStatusBar = true;
            present(browser, animated: true, completion: nil)
        }
    }
    
}
