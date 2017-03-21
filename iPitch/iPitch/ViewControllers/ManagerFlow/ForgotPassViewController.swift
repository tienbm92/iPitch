//
//  ForgotPassViewController.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/17/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import FirebaseAuth

class ForgotPassViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var statusLable: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailTextField.attributedPlaceholder = NSAttributedString(
            string: "Email".localized,
            attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.5)])
        self.statusLable.isHidden = true
        emailTextField.delegate = self
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func sendPassword(_ sender: UIButton) {
        self.forgetPass()
        self.view.endEditing(true)
    }
    
    fileprivate func forgetPass() {
        guard let email = self.emailTextField.text,
            self.emailTextField.text != "" else {
            WindowManager.shared.showMessage(
            message: "Password can't be empty!".localized,
            title: nil, completion: nil)
            return
        }
        WindowManager.shared.showProgressView()
        FIRAuth.auth()?.sendPasswordReset(withEmail: email,
                                          completion: { [weak self] (error) in
            WindowManager.shared.hideProgressView()
            if let error = error {
                WindowManager.shared.showMessage(
                    message: "NoSendPasswordMess".localized,
                    title: "NoSendPasswordTitle".localized, completion: nil)
                print(error.localizedDescription)
            } else {
                print("password email reset send!!")
                self?.statusLable.isHidden = false
                self?.statusLable.text = "ResetPasswordSuccess".localized
            }
        })
    }
    @IBAction func backToLoginAction(_ sender: UIButton) {
        _ = self.navigationController?.popViewController(animated: true)
    }

}

extension ForgotPassViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField == self.emailTextField {
            self.forgetPass()
        }
        return true
    }
    
}
