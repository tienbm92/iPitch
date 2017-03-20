//
//  EditPitchTableViewController.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/24/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import GoogleMaps
import GoogleMapsCore

enum EditPitchType {
    case create
    case update
}

class EditPitchTableViewController: UITableViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var closeTimeButton: UIButton!
    @IBOutlet weak var openTimeButton: UIButton!
    @IBOutlet weak var districtButton: UIButton!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    fileprivate var editingButton: UIButton?
    var pitch: Pitch?
    var type: EditPitchType = .create;
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch type {
        case .update:
            title = "Editing".localized
            updateButton.isHidden = false
            deleteButton.isHidden = false
            addButton.isHidden = true
            guard let pitch = pitch else {
                WindowManager.shared.showMessage(message: "PitchNotFound".localized,
                    title: nil, completion: { [weak self] (action) in
                        self?.back()
                })
                return
            }
            nameTextField.text = pitch.name
            districtButton.setTitle(pitch.district?.name, for: .normal)
            addressTextField.text = pitch.address
            openTimeButton.setTitle(pitch.activeTimeFrom?.toTimeString(),
                                    for: .normal)
            closeTimeButton.setTitle(pitch.activeTimeTo?.toTimeString(),
                                     for: .normal)
            phoneTextField.text = pitch.phone
            if let photoPath = pitch.photoPath {
                StorageService.shared.downloadImage(path: photoPath,
                                                    completion: { [weak self] (error, image) in
                                                        if let image = image {
                                                            self?.avatarImageView.image = image
                                                        } else {
                                                            print("Can't download image: \(error?.localizedDescription ?? "")")
                                                        }
                })
            }
        case .create:
            title = "AddPitch".localized
            updateButton.isHidden = true
            deleteButton.isHidden = true
            addButton.isHidden = false
            pitch = Pitch()
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: - Button event handling
    
    @IBAction func onAvatarPressed(_ sender: Any) {
        let actionSheet = UIAlertController(title: "EdittingAvatar".localized,
                                            message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "PreviewPhoto".localized, style: .default,
                                            handler: { [weak self] (action) in
                                                self?.previewImage(self?.avatarImageView.image)
        }))
        actionSheet.addAction(UIAlertAction(title: "TakePhoto".localized,
                                            style: .default, handler: { [weak self] (action) in
                                                self?.openImagePicker(withCamera: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "OpenLibrary".localized,
                                            style: .default, handler: { [weak self] (action) in
                                                self?.openImagePicker(withCamera: false)
        }))
        actionSheet.addAction(UIAlertAction(title: "DeletePhoto".localized,
                                            style: .destructive, handler: { [weak self] (action) in
                                                self?.avatarImageView.image = #imageLiteral(resourceName: "img_placeholder")
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel,
                                            handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onDistrictPressed(_ sender: UIButton) {
        editingButton = sender
        openPicker(withType: .district)
    }
    
    @IBAction func onOpenTimePressed(_ sender: UIButton) {
        editingButton = sender
        openPicker(withType: .time)
    }
    
    @IBAction func onCloseTimePressed(_ sender: UIButton) {
        editingButton = sender
        openPicker(withType: .time)
    }
    
    @IBAction func onMapTapped(_ sender: Any) {
        if let bigMapViewController = storyboard?.instantiateViewController(
            withIdentifier: String(describing: BigMapViewController.self)) as?
            BigMapViewController,
            let position = mapView.selectedMarker?.position {
            bigMapViewController.allowEditing = true
            bigMapViewController.coordinate =
                CLLocationCoordinate2D(latitude: position.latitude,
                                       longitude: position.longitude)
            navigationController?.pushViewController(bigMapViewController,
                                                     animated: true)
            bigMapViewController.callback = { [weak self] (coordinate) in
                self?.mapView.refreshMarker(toCoordinate: coordinate)
                self?.pitch?.latitude = coordinate.latitude
                self?.pitch?.longitude = coordinate.longitude
            }
        }
    }
    
    @IBAction func onAddPressed(_ sender: Any) {
        guard let pitch = pitch else {
            return
        }
        if let errorString = pitch.validate() {
            WindowManager.shared.showMessage(message: errorString,
                                             title: nil, completion:nil)
        } else {
            WindowManager.shared.showProgressView()
            PitchService.shared.create(pitch: pitch,
                                       photo: self.avatarImageView.image) {
                                        [weak self] (error) in
                                        WindowManager.shared.hideProgressView()
                                        if let error = error {
                                            WindowManager.shared.showMessage(
                                                message: error.localizedDescription,
                                                title: "CreatePitchError".localized,
                                                completion: nil)
                                        } else {
                                            _ = self?.navigationController?.popViewController(
                                                animated: true)
                                        }
            }
        }
    }
    
    @IBAction func onDeletePressed(_ sender: Any) {
        guard let pitch = pitch else {
            return
        }
        WindowManager.shared.showProgressView()
        PitchService.shared.delete(pitch: pitch) { [weak self] (error) in
            WindowManager.shared.hideProgressView()
            if let error = error {
                WindowManager.shared.showMessage(message: "DeletePitchError".localized,
                                                 title: error.localizedDescription, completion: nil)
            } else {
                _ = self?.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    @IBAction func onUpdatePressed(_ sender: Any) {
        guard let pitch = pitch else {
            return
        }
        if let errorString = pitch.validate() {
            WindowManager.shared.showMessage(message: errorString,
                                             title: nil, completion: nil)
        } else {
            WindowManager.shared.showProgressView()
            PitchService.shared.update(pitch: pitch,
                                       photo: self.avatarImageView.image) {
                                        [weak self] (error) in
                                        WindowManager.shared.hideProgressView()
                                        if let error = error {
                                            WindowManager.shared.showMessage(
                                                message: "UpdatePitchError".localized,
                                                title: error.localizedDescription, completion: nil)
                                        } else {
                                            _ = self?.navigationController?.popToRootViewController(animated: true)
                                        }
            }
        }
    }
    
    // MARK: - Private handling
    
    private func openImagePicker(withCamera: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.modalTransitionStyle = .crossDissolve
        if withCamera {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                imagePicker.sourceType = .camera
                imagePicker.cameraDevice = .rear
                imagePicker.cameraCaptureMode = .photo
                imagePicker.allowsEditing = true
            } else {
                WindowManager.shared.showMessage(
                    message: "CameraNotFound".localized,
                    title: nil, completion: nil)
                return
            }
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.sourceType = .photoLibrary
            } else {
                WindowManager.shared.showMessage(
                    message: "LibraryNotFound".localized,
                    title: nil, completion: nil)
                return
            }
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func openPicker(withType type: PickerViewType) {
        guard let pickerViewController =
            storyboard?.instantiateViewController(
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

extension EditPitchTableViewController: PickerViewControllerDelegate {
    
    func pickerViewController(_ pickerViewController: PickerViewController,
                              didCloseWith result: Any?) {
        if let editingButton = editingButton {
            switch pickerViewController.type {
            case .district:
                if let district = result as? District {
                    editingButton.setTitle(district.name, for: .normal)
                    pitch?.district = district
                }
            case .time:
                if let time = result as? Date {
                    if editingButton === openTimeButton {
                        pitch?.activeTimeFrom = time
                    } else if editingButton === closeTimeButton {
                        pitch?.activeTimeTo = time
                    }
                    editingButton.setTitle(time.toTimeString(), for: .normal)
                }
            }
        }
    }
    
}

extension EditPitchTableViewController: UINavigationControllerDelegate,
UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.avatarImageView.image = image
        } else {
            WindowManager.shared.showMessage(message: "PhotoError".localized, title: nil,
                                             completion: nil)
        }
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension EditPitchTableViewController: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField === nameTextField {
            pitch?.name = textField.text ?? ""
        } else if textField === addressTextField {
            pitch?.address = textField.text ?? ""
        } else if textField === phoneTextField {
            pitch?.phone = textField.text ?? ""
        }
    }
    
}

extension EditPitchTableViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        if var location = locations.last {
            if type == .update, let pitch = pitch {
                location = CLLocation(latitude: pitch.latitude,
                                      longitude: pitch.longitude)
            } else if (type == .create) {
                pitch?.latitude = location.coordinate.latitude
                pitch?.longitude = location.coordinate.longitude
            }
            mapView.camera = GMSCameraPosition.camera(
                withLatitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude, zoom: 15.0)
            mapView.refreshMarker(toCoordinate: location.coordinate)
        }
    }
    
}
