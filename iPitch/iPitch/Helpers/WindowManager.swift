//
//  WindowManager.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/1/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import MBProgressHUD
import FirebaseAuth

class WindowManager: NSObject {
    
    static let shared = WindowManager()
    // MARK: ProgressView properties
    lazy var progressView: MBProgressHUD = {
        let pview = MBProgressHUD(view: self.progressWindow)
        pview.animationType = MBProgressHUDAnimation.fade
        pview.isUserInteractionEnabled = true
        pview.label.text = "Loading".localized
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
    private var window = UIApplication.shared.keyWindow

    func getCurrentWindowLevel() -> CGFloat {
        if let window = self.window {
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
    
    // MARK: - Action
    
    func showMessage(message: String, title: String?, completion: ((UIAlertAction) -> Void)?) {
        self.alertWindow.windowLevel = self.getCurrentWindowLevel() + 0.1
        let alertController = UIAlertController(title: title ?? "Alert".localized,
            message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized, style: .default) {
            [weak self] (action) in
            self?.alertWindow.isHidden = true
            if let completion = completion {
                DispatchQueue.main.async {
                    completion(action)
                }
            }
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.alertWindow.isHidden = false
            self.alertWindow.rootViewController?.present(alertController,
                animated: true, completion: nil)
        }
    }
    
    func acceptOrderConfirm(order: Order, pitch: Pitch, completion: ((UIAlertAction) -> Void)?) {
        self.alertWindow.windowLevel = self.getCurrentWindowLevel() + 0.1
        let confirmController = UIAlertController(title: "Confirm".localized,
            message: "AcceptConfirm".localized, preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "accept".localized, style: .default) {
            [weak self] (action) in
            self?.alertWindow.isHidden = true
            OrderService.shared.accept(order: order, pitch: pitch, completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion(action)
                    }
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) {
            [weak self] (action) in
            self?.alertWindow.isHidden = true
        }
        confirmController.addAction(acceptAction)
        confirmController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.alertWindow.isHidden = false
            self.alertWindow.rootViewController?.present(confirmController,
                animated: true, completion: nil)
        }
    }
    
    func rejectOrderConfirm(order: Order, pitch: Pitch, completion: ((UIAlertAction) -> Void)?) {
        self.alertWindow.windowLevel = self.getCurrentWindowLevel() + 0.1
        let rejectController = UIAlertController(title: "Confirm".localized,
            message: "RejectConfirm".localized, preferredStyle: .alert)
        let rejectAction = UIAlertAction(title: "reject".localized, style: .default) {
            [weak self] (action) in
            self?.alertWindow.isHidden = true
            OrderService.shared.reject(order: order, pitch: pitch, completion: { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                if let completion = completion {
                    DispatchQueue.main.async {
                        completion(action)
                    }
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) {
            [weak self] (action) in
            self?.alertWindow.isHidden = true
        }
        rejectController.addAction(rejectAction)
        rejectController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.alertWindow.isHidden = false
            self.alertWindow.rootViewController?.present(rejectController,
                animated: true, completion: nil)
        }
    }
    
    func logoutAction() {
        self.alertWindow.windowLevel = self.getCurrentWindowLevel() + 0.1
        let logoutController = UIAlertController(title: nil,
            message: "Are you sure you want to sign out?".localized,
            preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Signout".localized,
            style: .destructive) {
            [weak self] (action) in
            self?.alertWindow.isHidden = true
            let firebaseAuth = FIRAuth.auth()
            do {
                try firebaseAuth?.signOut()
                self?.directToCheckLogin()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized, style: .cancel) { (action) in
            self.alertWindow.isHidden = true
        }
        logoutController.addAction(logoutAction)
        logoutController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.alertWindow.isHidden = false
            self.alertWindow.rootViewController?.present(logoutController,
                animated: true, completion: nil)
        }
    }
    
    // MARK: - Direct to specified Controller
    func directToMainStoryboard() {
        guard let window = self.window else {
            return
        }
        let mainViewController = UIStoryboard.main.instantiateInitialViewController()
        window.rootViewController = mainViewController
    }
    
    func directToCheckLogin() {
        guard let window = self.window else {
            return
        }
        UIView.transition(with: window, duration: 0.5, options: .transitionCurlUp, animations: {
//            if FIRAuth.auth()?.currentUser != nil {
//                let pitchManagerNavController = UIStoryboard.manager.instantiateViewController(
//                    withIdentifier: "ManagerNavControllerId")
//                window.rootViewController = pitchManagerNavController
//            } else {
                let loginNavController = UIStoryboard.manager.instantiateViewController(
                    withIdentifier: "LoginNavControllerId")
                window.rootViewController = loginNavController
//            }
        }, completion: nil)
    }
        
    func directToPitchList() {
        guard let window = self.window else {
            return
        }
        let pitchManagerNavController = UIStoryboard.manager.instantiateViewController(
            withIdentifier: "ManagerNavControllerId")
        window.rootViewController = pitchManagerNavController
    }
    
    func directToUserFlow() {
        guard let window = self.window else {
            return
        }
        let userFlowNavController = UIStoryboard.mapIPitch.instantiateInitialViewController()
        UIView.transition(with: window, duration: 0.5,
            options: .transitionFlipFromTop, animations: {
            window.rootViewController = userFlowNavController
        }, completion: nil)
    }
    
}
