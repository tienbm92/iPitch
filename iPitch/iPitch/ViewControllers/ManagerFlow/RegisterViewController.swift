//
//  RegisterViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseAuth
import FirebaseInstanceID

class RegisterViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    fileprivate func signUp() {
        guard let user = User(registerWithEmail: self.emailTextField.text,
            password: self.passwordTextField.text,
            retypePassword: self.retypePasswordTextField.text,
            error: { (errorString) in
            WindowManager.shared.showMessage(message: errorString, title: nil,
                completion: nil)
        }) else {
            return
        }
        WindowManager.shared.showProgressView()
        FIRAuth.auth()?.createUser(withEmail: user.email, password: user.password) {
            [weak self] (user, error) in
            WindowManager.shared.hideProgressView()
            guard user != nil else {
                if let error = error?.localizedDescription {
                    WindowManager.shared.showMessage(message: error,
                        title: nil, completion: nil)
                }
                return
            }
            _ = self?.navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - Action
    @IBAction func backButtonTapped(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func registerButtonTapped(_ sender: UIButton) {
        self.signUp()
    }
    
}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.emailTextField {
            self.passwordTextField.becomeFirstResponder()
        } else if textField == self.passwordTextField {
            self.retypePasswordTextField.becomeFirstResponder()
        } else if textField == self.retypePasswordTextField {
            self.signUp()
            textField.resignFirstResponder()
        }
        return true
    }
    
}
