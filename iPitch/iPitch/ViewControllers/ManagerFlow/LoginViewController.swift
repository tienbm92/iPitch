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

class LoginViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManagerConfiguration.shared.configKeyboard()
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
            [weak self] (user, error) in
            WindowManager.shared.hideProgressView()
            if let error = error {
                WindowManager.shared.showMessage(message: error.localizedDescription, title: nil, completion: nil)
            }
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
