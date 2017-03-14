//
//  SearchViewController.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

protocol SearchViewControllerDelegate: class {
    func searchViewController(_ searchViewController: SearchViewController,
        didCloseWith filter: Filter?)
}

class SearchViewController: UIViewController {

    @IBOutlet weak var startTimeButton: UIButton!
    @IBOutlet weak var districtButton: UIButton!
    @IBOutlet weak var radiusTextField: UITextField!
    @IBOutlet weak var endTimeButton: UIButton!
    fileprivate var editingButton: UIButton?
    weak var delegate: SearchViewControllerDelegate?
    var filter = Filter()
    
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
            filter.radius = radius
        }
        delegate?.searchViewController(self, didCloseWith: filter)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionCounty(_ sender: UIButton) {
        editingButton = sender
        openPicker(withType: .district)
    }
    
    @IBAction func actionTimeFrom(_ sender: UIButton) {
        editingButton = sender
        openPicker(withType: .time)
    }
    
    @IBAction func actionTimeTo(_ sender: UIButton) {
        editingButton = sender
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
        if let editingButton = editingButton {
            switch pickerViewController.type {
            case .district:
                if let district = result as? District {
                    filter.district = district
                    districtButton.setTitle(district.name, for: .normal)
                }
            case .time:
                if let time = result as? Date {
                    editingButton.setTitle(time.toTimeString(), for: .normal)
                    if editingButton === startTimeButton {
                        filter.startTime = time
                    } else if editingButton === endTimeButton {
                        filter.endTime = time
                    }
                }
            }
        }
    }
    
}

