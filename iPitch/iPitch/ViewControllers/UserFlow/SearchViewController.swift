//
//  SearchViewController.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

protocol searchViewControllerDelegate {
    func searchViewController(_ searchViewController: SearchViewController,
        didCloseWith result: Any?)
}

class SearchViewController: UIViewController {

    @IBOutlet weak var countyTextField: UITextField!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var timeFromTextField: UITextField!
    @IBOutlet weak var timeToTextField: UITextField!
    fileprivate var editingTextField: UITextField?
    var delegate: searchViewControllerDelegate?
    var districtID: Int?
    var timeFrom: Date?
    var timeTo: Date?
    var radius: Double?
    var result: [String: Any] = [:]
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func onClose(_ sender: Any) {
        delegate?.searchViewController(self, didCloseWith: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if let radiusText = radiusTextField.text,
            let radius = Double(radiusText) {
            self.radius = radius
        }
        result["timeFrom"] = timeFrom
        result["timeTo"] = timeTo
        result["radius"] = radius
        result["districtID"] = districtID
        delegate?.searchViewController(self, didCloseWith: result)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionCounty(_ sender: Any) {
        editingTextField = countyTextField
        openPicker(withType: .district)
    }
    
    @IBAction func actionTimeFrom(_ sender: Any) {
        editingTextField = timeFromTextField
        openPicker(withType: .time)
    }
    
    @IBAction func actionTimeTo(_ sender: Any) {
        editingTextField = timeToTextField
        openPicker(withType: .time)
    }
    
    
    fileprivate func openPicker(withType type: PickerViewType) {
        let mapPitchStoryboard = UIStoryboard(name: "PitchExtra", bundle: nil)
        guard let pickerViewController =
            mapPitchStoryboard.instantiateViewController(
            withIdentifier: String(describing: PickerViewController.self))
            as? PickerViewController else {
            return
        }
        pickerViewController.delegate = self
        pickerViewController.type = type
        switch type {
        case .district:
            WindowManager.shared.showProgressView()
            DistrictService.shared.getAllDistrict { [weak self] (districts) in
                WindowManager.shared.hideProgressView()
                pickerViewController.districts = districts
                self?.present(pickerViewController, animated: true,
                              completion: nil)
            }
        case .time:
            present(pickerViewController, animated: true, completion: nil)
        }
    }
    
}

extension SearchViewController: PickerViewControllerDelegate {
    
    func pickerViewController(_ pickerViewController: PickerViewController,
                              didCloseWith result: Any?) {
        if let editingTextField = editingTextField {
            switch pickerViewController.type {
            case .district:
                if let district = result as? District {
                    if let districtID = district.id {
                        self.districtID = districtID
                    }
                    countyTextField.text = district.name
                    print(countyTextField.text ?? "")
                }
            case .time:
                if let time = result as? Date {
                    editingTextField.text = time.toTimeString()
                    if editingTextField === timeFromTextField {
                        self.timeFrom = time
                        timeFromTextField.text = editingTextField.text
                    } else if editingTextField === timeToTextField {
                        timeToTextField.text = editingTextField.text
                        self.timeTo = time
                    }
                }
            }
        }
    }
    
}

