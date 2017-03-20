//
//  OrderViewController.swift
//  iPitch
//
//  Created by Huy Pham on 3/7/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class OrderViewController: UIViewController {
    
    @IBOutlet weak var endTimeButton: UIButton!
    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var orderNameTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    fileprivate var editingButton: UIButton?
    var pitch: Pitch?
    var order = Order()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pitch = pitch else {
            WindowManager.shared.showMessage(message: "PitchNotFound".localized,
                title: nil, completion: { [weak self] (action) in
                self?.back()
            })
            return
        }
        nameLabel.text = pitch.name
        avatarImageView.fetchImage(for: pitch.photoPath, id: pitch.id,
            completion: nil)
    }

    @IBAction func onAvatarPressed(_ sender: Any) {
        self.previewImage(avatarImageView.image)
    }
    
    @IBAction func onConfirmPressed(_ sender: Any) {
        self.view.endEditing(true)
        if let errorString = order.validate() {
            WindowManager.shared.showMessage(message: errorString,
                title: nil, completion: nil)
        } else {
            if let pitch = pitch {
                WindowManager.shared.showProgressView()
                OrderService.shared.create(order: order, pitch: pitch,
                    completion: { [weak self] (error) in
                    WindowManager.shared.hideProgressView()
                    if let error = error {
                        WindowManager.shared.showMessage(
                            message: error.localizedDescription,
                            title: nil, completion: nil)
                    } else {
                        self?.back()
                    }
                })
            }
        }
    }

    @IBAction func onStartTimePressed(_ sender: UIButton) {
        editingButton = sender
        self.callPicker()
    }
    
    @IBAction func onEndTimePressed(_ sender: UIButton) {
        editingButton = sender
        self.callPicker()
    }
    
    // MARK: - Private Handling
    func callPicker() {
        if let pickerViewController =
            UIStoryboard.pitchExtra.instantiateViewController(
            withIdentifier: String(describing: PickerViewController.self))
            as? PickerViewController {
            pickerViewController.type = .time
            pickerViewController.delegate = self
            present(pickerViewController, animated: true, completion: nil)
        }
    }
    
}

extension OrderViewController: PickerViewControllerDelegate {
    
    func pickerViewController(_ pickerViewController: PickerViewController,
        didCloseWith result: Any?) {
        if pickerViewController.type == .time {
            if let time = result as? Date,
                let editingButton = editingButton {
                editingButton.setTitle(time.toTimeString(), for: .normal)
                if editingButton === startTimeButton {
                    order.timeFrom = time
                } else if editingButton === endTimeButton {
                    order.timeTo = time
                }
            }
        }
    }
    
}

extension OrderViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === orderNameTextField {
            order.name = textField.text ?? ""
        } else if textField === phoneTextField {
            order.phone = textField.text ?? ""
        }
    }
    
}
