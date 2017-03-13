//
//  LoginViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseAuth
import FirebaseInstanceID

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email".localized,
            attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)])
        self.passwordTextField.attributedPlaceholder = NSAttributedString(
            string: "Password".localized,
            attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)])
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func login() {
        guard let user = User(loginWithEmail: self.emailTextField.text,
            password: self.passwordTextField.text, error: { (errorString) in
            WindowManager.shared.showMessage(message: errorString, title: nil, completion: nil)
        }) else {
            return
        }
        WindowManager.shared.showProgressView()
        FIRAuth.auth()?.signIn(withEmail: user.email, password: user.password) {
            (user, error) in
            WindowManager.shared.hideProgressView()
            guard let user = user else {
                if let error = error?.localizedDescription {
                    WindowManager.shared.showMessage(message: error, title: nil,
                        completion: nil)
                }
                return
            }
            UserService.shared.set(token: FIRInstanceID.instanceID().token(),
                forUserId: user.uid, completion: nil)
            WindowManager.shared.directToPitchList()
        }
    }
    
    // MARK: - Action
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        self.login()
    }
    
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.login()
            textField.resignFirstResponder()
        }
        return true
    }
    
}
