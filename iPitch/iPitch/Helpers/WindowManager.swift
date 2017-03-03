//
//  WindowManager.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/1/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import MBProgressHUD

class WindowManager: NSObject {
    
    static let shared = WindowManager()
    // MARK: ProgressView properties
    lazy var progressView: MBProgressHUD = {
        let pview = MBProgressHUD(view: self.progressWindow)
        pview.animationType = MBProgressHUDAnimation.fade
        pview.isUserInteractionEnabled = true
        pview.label.text = "Loading..."
        return pview
    }()
    lazy var progressWindow: UIWindow = {
        let awindow = UIWindow(frame: UIScreen.main.bounds)
        awindow.windowLevel = UIWindowLevelStatusBar + 0.2
        awindow.isOpaque = true
        return awindow
    }()
    // MARK: AlertView properties
    lazy var alertWindow: UIWindow = {
        let awindow = UIWindow(frame: UIScreen.main.bounds)
        awindow.windowLevel = UIWindowLevelAlert + 0.1
        awindow.isOpaque = true
        awindow.rootViewController = UIViewController()
        return awindow
    }()
    
    func getCurrentWindowLevel() -> CGFloat {
        if let window = UIApplication.shared.keyWindow {
            return window.windowLevel
        }
        return UIWindowLevelStatusBar
    }

    /*
     - progress window. Overlay all screen
     */
    func showProgressView() {
        self.progressWindow.windowLevel = self.getCurrentWindowLevel() + 0.2
        DispatchQueue.main.async {
            self.progressWindow.isHidden = false
            self.progressView.frame = CGRect(x: 0, y: 0,
                width: self.progressWindow.bounds.size.width,
                height: self.progressWindow.bounds.size.height)
            self.progressView.removeFromSuperview()
            self.progressWindow.addSubview(self.progressView)
            self.progressWindow.bringSubview(toFront: self.progressView)
            self.progressView.show(animated: true)
        }
    }

    func hideProgressView() {
        DispatchQueue.main.async {
            self.progressView.hide(animated: false)
            self.progressWindow.isHidden = true
        }
    }
    
    func showMessage(message: String, title: String?, completion: ((UIAlertAction) -> Void)?) {
        self.alertWindow.windowLevel = self.getCurrentWindowLevel() + 0.1
        let alertController = UIAlertController(title: title ?? "Alert",
            message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.alertWindow.isHidden = true
            if let completion = completion {
                completion(action)
            }
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.alertWindow.isHidden = false
            self.alertWindow.rootViewController?.present(alertController,
                animated: true, completion: nil)
        }
    }
    
}
