//
//  UpdatePasswordTableViewController.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/20/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseInstanceID

class UpdatePasswordTableViewController: UITableViewController {

    @IBOutlet weak var statusLable: UILabel!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var rePasswordTextField: UITextField!
    var currentMail = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.statusLable.isHidden = true
        currentMail = self.getUser()
    }
    
    @IBAction func changePasswordAction(_ sender: UIButton) {
        self.updatePassword()
        self.view.endEditing(true)
    }
    
    fileprivate func getUser() -> String {
        var currentMail = ""
        if let user = FIRAuth.auth()?.currentUser {
            self.emailTextField.text = user.email
            guard let emailTextFieldString = self.emailTextField.text else {
                return currentMail
            }
            currentMail = emailTextFieldString
        } else {
            print("get user error!")
        }
        return currentMail
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        WindowManager.shared.logoutAction()
    }
    
    fileprivate func updatePassword() {
        guard let userCurrent = User(email: self.currentMail,
            password: passwordTextField.text,
            newPassword: newPasswordTextField.text,
            confirmPassword: rePasswordTextField.text,
            error: { (error) in
            WindowManager.shared.showMessage(message: error,
                                             title: nil, completion: nil)
        }) else {
            self.newPasswordTextField.text = nil
            self.rePasswordTextField.text = nil
            return
        }
        let newPassword = userCurrent.newPassword
        WindowManager.shared.showProgressView()
        FIRAuth.auth()?.signIn(withEmail: userCurrent.email,
                               password: userCurrent.password) {
            [weak self] (user, error) in
            guard let user = user else {
                if let error = error {
                    self?.resultStatusLable(
                        status: "ChangePasswordFalse".localized)
                    print(error.localizedDescription)
                }
                return
            }
            UserService.shared.set(token: FIRInstanceID.instanceID().token(),
                                   forUserId: user.uid, completion: nil)
            let userUpdate = FIRAuth.auth()?.currentUser
            if let userUpdate = userUpdate {
                userUpdate.updatePassword(newPassword, completion: {
                    [weak self] (error) in
                    if let error = error {
                        self?.resultStatusLable(
                            status: "ChangePasswordFalse".localized)
                        print(error.localizedDescription)
                        return
                    } else {
                        self?.resultStatusLable(
                            status: "ChangePasswordSuccess".localized)
                    }
                })
            } else {
                self?.resultStatusLable(
                    status: "ChangePasswordFalse".localized)
                return
            }
        }
    }
    
    fileprivate func resultStatusLable (status: String) {
        WindowManager.shared.hideProgressView()
        self.statusLable.isHidden = false
        self.statusLable.text = status
    }

}

extension UpdatePasswordTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.passwordTextField {
            self.newPasswordTextField.becomeFirstResponder()
        } else if textField == self.newPasswordTextField {
            self.rePasswordTextField.becomeFirstResponder()
        } else if textField == self.rePasswordTextField {
            self.rePasswordTextField.resignFirstResponder()
            self.updatePassword()
        }
        return true
    }
}
