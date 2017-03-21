//
//  User.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/2/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation

class User {
    
    var email = ""
    var password = ""
    var newPassword = ""
    
    init() {
    }
    
    init?(registerWithEmail: String?, password: String?, retypePassword: String?,
        error: (String) -> Void) {
        guard let email = registerWithEmail, !email.isEmpty else {
            error("Email can't be empty!".localized)
            return nil
        }
        guard let password = password, !password.isEmpty else {
            error("Password can't be empty!".localized)
            return nil
        }
        guard let retypePassword = retypePassword, !retypePassword.isEmpty else {
            error("Re-type password can't be empty!".localized)
            return nil
        }
        if retypePassword != password {
            error("Re-type password and password must be same!".localized)
            return nil
        }
        self.email = email
        self.password = password
    }
    
    init?(loginWithEmail: String?, password: String?, error: (String) -> Void) {
        guard let email = loginWithEmail, !email.isEmpty else {
            error("Email can't be empty!".localized)
            return nil
        }
        guard let password = password, !password.isEmpty else {
            error("Password can't be empty!".localized)
            return nil
        }
        self.email = email
        self.password = password
    }
    
    init?(email: String?, password: String?, newPassword: String?,
          confirmPassword: String?, error: (String) -> Void) {
        guard let email = email, !email.isEmpty ,
            let password = password, !password.isEmpty,
            let newPassword = newPassword, !newPassword.isEmpty,
            let confirmPassword = confirmPassword, !confirmPassword.isEmpty
        else{
            error("Password can't be empty!".localized)
            return nil
        }
        if newPassword != confirmPassword {
            error("Re-type password and password must be same!".localized)
            return nil
        }
        self.email = email
        self.password = password
        self.newPassword = newPassword
    }
    
}
