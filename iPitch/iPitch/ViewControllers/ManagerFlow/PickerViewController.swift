//
//  PickerViewController.swift
//  iPitch
//
//  Created by Huy Pham on 3/3/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

enum PickerViewType {
    case time
    case district
}

protocol PickerViewControllerDelegate {
    func pickerViewController(_ pickerViewController: PickerViewController,
        didCloseWith result: Any?)
}

class PickerViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var datePickerView: UIDatePicker!
    @IBOutlet weak var pickerView: UIPickerView!
    var delegate: PickerViewControllerDelegate?
    var districts = [District]()
    var type: PickerViewType = .time
    var result: Any? {
        switch type {
        case .time:
            return datePickerView.date
        case .district:
            if districts.count > pickerView.selectedRow(inComponent: 0) {
                return districts[pickerView.selectedRow(inComponent: 0)]
            }
            return nil
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pickerView.setValue(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), forKey: "textColor")
        datePickerView.setValue(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), forKey: "textColor")
        switch type {
        case .time:
            self.datePickerView.isHidden = false
            self.pickerView.isHidden = true
        case .district:
            self.datePickerView.isHidden = true
            self.pickerView.isHidden = false
        }
    }
    
    // MARK: - Button event handling

    @IBAction func onClosePressed(_ sender: Any) {
        delegate?.pickerViewController(self, didCloseWith: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func onSubmitPressed(_ sender: Any) {
        delegate?.pickerViewController(self, didCloseWith: result)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

extension PickerViewController: UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int) -> Int {
        return districts.count
    }
    
}

extension PickerViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int,
        forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: districts[row].name,
            attributes: [NSForegroundColorAttributeName: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)])
    }
    
    func pickerView(_ pickerView: UIPickerView,
        rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }

}
