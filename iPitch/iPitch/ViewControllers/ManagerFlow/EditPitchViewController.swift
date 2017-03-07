//
//  EditPitchViewController.swift
//  iPitch
//
//  Created by Huy Pham on 3/3/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import IDMPhotoBrowser
import GoogleMaps
import CoreLocation

enum EditPitchType {
    case create
    case update
}

class EditPitchViewController: UIViewController {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var avatarButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var openTimeTextField: UITextField!
    @IBOutlet weak var closeTimeTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    fileprivate var editingTextField: UITextField?
    var pitch: Pitch?
    var type: EditPitchType = .create;
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch type {
        case .update:
            title = kEditing
            updateButton.isHidden = false
            deleteButton.isHidden = false
            addButton.isHidden = true
            guard let pitch = pitch else {
                WindowManager.shared.showMessage(message: kPitchNotFound,
                    title: nil, completion: { [weak self] (action) in
                    if let navigationController = self?.navigationController {
                        navigationController.popViewController(animated: true)
                    } else if let presentingViewController =
                        self?.presentingViewController {
                        presentingViewController.dismiss(animated: true,
                            completion: nil)
                    }
                })
                return
            }
            nameTextField.text = pitch.name
            districtTextField.text = pitch.district?.name
            addressTextField.text = pitch.address
            openTimeTextField.text = pitch.activeTimeFrom?.toTimeString()
            closeTimeTextField.text = pitch.activeTimeTo?.toTimeString()
            if let photoPath = pitch.photoPath {
                StorageService.shared.downloadImage(path: photoPath,
                    completion: { [weak self] (error, image) in
                    if let image = image {
                        self?.avatarButton.setBackgroundImage(image,
                            for: .normal)
                    } else {
                        print("Can't download image: \(error?.localizedDescription ?? "")")
                    }
                })
            }
        case .create:
            title = kAddPitch
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
        let actionSheet = UIAlertController(title: kEdittingAvatar,
            message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: kPreviewPhoto, style: .default,
            handler: { [weak self] (action) in
            self?.previewImage()
        }))
        actionSheet.addAction(UIAlertAction(title: kTakePhoto,
            style: .default, handler: { [weak self] (action) in
            self?.openImagePicker(withCamera: true)
        }))
        actionSheet.addAction(UIAlertAction(title: kOpenLibrary,
            style: .default, handler: { [weak self] (action) in
            self?.openImagePicker(withCamera: false)
        }))
        actionSheet.addAction(UIAlertAction(title: kDeletePhoto,
            style: .destructive, handler: { [weak self] (action) in
            self?.avatarButton.setBackgroundImage(#imageLiteral(resourceName: "img_placeholder"),
                for: .normal)
        }))
        actionSheet.addAction(UIAlertAction(title: kCancel, style: .cancel,
            handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    @IBAction func onDistrictPressed(_ sender: UIButton) {
        editingTextField = districtTextField
        openPicker(withType: .district)
    }
    
    @IBAction func onOpenTimePressed(_ sender: UIButton) {
        editingTextField = openTimeTextField
        openPicker(withType: .time)
    }
    
    @IBAction func onCloseTimePressed(_ sender: UIButton) {
        editingTextField = closeTimeTextField
        openPicker(withType: .time)
    }
    
    @IBAction func onMapTapped(_ sender: Any) {
        if let bigMapViewController = storyboard?.instantiateViewController(
            withIdentifier: String(describing: BigMapViewController.self)) as?
            BigMapViewController,
            let position = mapView.selectedMarker?.position {
            bigMapViewController.location =
                CLLocation.init(latitude: position.latitude,
                longitude: position.longitude)
            navigationController?.pushViewController(bigMapViewController,
                animated: true)
            bigMapViewController.callback = { [weak self] (coordinate) in
                self?.setNewMapMarker(withCoordinate: coordinate)
            }
        }
    }
    
    @IBAction func onAddPressed(_ sender: Any) {
        guard let pitch = pitch else {
            return
        }
        WindowManager.shared.showProgressView()
        PitchService.shared.create(pitch: pitch,
            photo: self.avatarButton.backgroundImage(for: .normal)) {
            [weak self] (error) in
            WindowManager.shared.hideProgressView()
            if let error = error {
                WindowManager.shared.showMessage(
                    message: error.localizedDescription,
                    title: kCreatePitchError, completion: nil)
            } else {
                _ = self?.navigationController?.popViewController(animated: true)
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
                WindowManager.shared.showMessage(message: kDeletePitchError,
                    title: error.localizedDescription, completion: nil)
            } else {
                _ = self?.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func onUpdatePressed(_ sender: Any) {
        guard let pitch = pitch else {
            return
        }
        WindowManager.shared.showProgressView()
        PitchService.shared.update(pitch: pitch,
            photo: self.avatarButton.backgroundImage(for: .normal)) {
            [weak self] (error) in
            if let error = error {
                WindowManager.shared.showMessage(message: kUpdatePitchError,
                    title: error.localizedDescription, completion: nil)
            } else {
                _ = self?.navigationController?.popViewController(animated: true)
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
                    message: kCameraNotFound,
                    title: nil, completion: nil)
                return
            }
        } else {
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                imagePicker.sourceType = .photoLibrary
            } else {
                WindowManager.shared.showMessage(
                    message: kLibraryNotFound,
                    title: nil, completion: nil)
                return
            }
        }
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func previewImage() {
        if let browser = IDMPhotoBrowser(photos: [IDMPhoto(
            image: avatarButton.backgroundImage(for: .normal))]) {
            browser.displayActionButton = false;
            browser.displayArrowButton = false;
            browser.usePopAnimation = true;
            browser.forceHideStatusBar = true;
            present(browser, animated: true, completion: nil)
        }
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
    
    fileprivate func setNewMapMarker(
        withCoordinate coordinate: CLLocationCoordinate2D) {
        mapView.camera = GMSCameraPosition.camera(
            withLatitude: coordinate.latitude, longitude: coordinate.longitude,
            zoom: 15.0)
        mapView.clear()
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        mapView.selectedMarker = marker
        pitch?.latitude = coordinate.latitude
        pitch?.longitude = coordinate.longitude
    }
}

extension EditPitchViewController: PickerViewControllerDelegate {
    
    func pickerViewController(_ pickerViewController: PickerViewController,
        didCloseWith result: Any?) {
        if let editingTextField = editingTextField {
            switch pickerViewController.type {
            case .district:
                if let district = result as? District {
                    editingTextField.text = district.name
                    pitch?.district = district
                }
            case .time:
                if let time = result as? Date {
                    print(time.debugDescription)
                    if editingTextField === openTimeTextField {
                        pitch?.activeTimeFrom = time
                    } else if editingTextField === closeTimeTextField {
                        if let openTime = pitch?.activeTimeFrom {
                            print(time.debugDescription)
                            print(openTime.debugDescription)
                            print(time.time)
                            print(openTime.time)
                            if time.time <= openTime.time {
                                WindowManager.shared.showMessage(
                                    message: kInvalidCloseTime,
                                    title: nil, completion: nil)
                                return
                            }
                        }
                        pitch?.activeTimeTo = time
                    }
                    editingTextField.text = time.toTimeString()
                }
            }
        }
    }
    
}

extension EditPitchViewController: UINavigationControllerDelegate,
    UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            avatarButton.setBackgroundImage(image, for: .normal)
        } else {
            WindowManager.shared.showMessage(message: kPhotoError, title: nil,
                completion: nil)
        }
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
}

extension EditPitchViewController: UITextFieldDelegate {
    
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

extension EditPitchViewController: CLLocationManagerDelegate {
    
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
            }
            setNewMapMarker(withCoordinate: location.coordinate)
        }
    }
    
}
