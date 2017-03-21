//
//  PitchService.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import FirebaseAuth
import CoreLocation
import FirebaseDatabase

class PitchService: NSObject {
    
    enum PitchServiceError: Error {
        case userNotFound
    }
    
    static let shared = PitchService()
    private let ref = FIRDatabase.database().reference().child("pitches")
    fileprivate let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func getPitch(searchText: String?, radius: Double?, districtId: Int?,
        timeFrom: Date?, timeTo: Date?, completion: @escaping ([Pitch]) -> Void) {
        getAllPitches { (pitches) in
            let pitchesFilter = pitches.filter({
                [unowned self] (pitch) -> Bool in
                if var radius = radius,
                    let location = self.locationManager.location {
                    radius = radius * 1000
                    guard location.distance(
                        from: CLLocation(latitude: pitch.latitude,
                        longitude: pitch.longitude)) <= radius else {
                        return false
                    }
                }
                if let districtId = districtId {
                    guard let pitchDistrictId = pitch.district?.id,
                        pitchDistrictId == districtId else {
                        return false
                    }
                }
                if let timeFrom = timeFrom,
                    let timeTo = timeTo,
                    let pitchActiveFrom = pitch.activeTimeFrom,
                    let pitchActiveTo = pitch.activeTimeTo {
                    guard pitchActiveTo >= timeFrom &&
                        pitchActiveFrom <= timeTo else {
                        return false
                    }
                }
                if var searchText = searchText {
                    searchText = searchText.uppercased()
                    guard searchText == "" ||
                        pitch.name.uppercased().contains(searchText) ||
                        pitch.address.uppercased().contains(searchText) ||
                        pitch.phone.uppercased().contains(searchText) else {
                        return false
                    }
                }
                return true
            })
            guard let location = self.locationManager.location else {
                DispatchQueue.main.async {
                    completion(pitchesFilter)
                }
                return
            }
            let pitchesSorted = pitchesFilter.sorted(by: {
                let location0 = CLLocation(latitude: $0.latitude,
                    longitude: $0.longitude)
                let location1 = CLLocation(latitude: $1.latitude,
                    longitude: $1.longitude)
                return location.distance(from: location0) <
                    location.distance(from: location1)
            })
            DispatchQueue.main.async {
                completion(pitchesSorted)
            }
        }
    }
    
    func getPitchForManager(completion: @escaping ([Pitch]) -> Void) {
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            completion([Pitch]())
            return
        }
        ref.child(userId).queryEqual(
            toValue: FIRAuth.auth()?.currentUser?.uid).queryOrdered(
            byChild: "ownerId").observeSingleEvent(of: .value, with: { 
            (snapshot) in
            var pitches = [Pitch]()
            if let pitchesJSON = snapshot.value as? [String: Any] {
                for (key, value) in pitchesJSON {
                    if var pitchJSON = value as? [String: Any] {
                        pitchJSON["id"] = key
                        if let pitch = Pitch(JSON: pitchJSON) {
                            pitches.append(pitch)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(pitches)
            }
        })
    }

    func create(pitch: Pitch, photo: UIImage?,
        completion: @escaping (Error?) -> Void) {
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            DispatchQueue.main.async {
                completion(PitchServiceError.userNotFound)
            }
            return
        }
        var json = pitch.toJSON()
        if json["id"] != nil {
            json.removeValue(forKey: "id")
        }
        if json["photoPath"] != nil {
            json.removeValue(forKey: "photoPath")
        }
        json["ownerId"] = userId
        ref.child(userId).childByAutoId().setValue(json,
            withCompletionBlock: { (error, ref) in
            if error == nil, let photo = photo {
                let photoPath = "images/pitches/\(ref.key).jpg"
                StorageService.shared.uploadImage(image: photo,
                    path: photoPath, completion: {
                    [weak self] (error, url) in
                    if let url = url {
                        self?.ref.child("\(userId)/\(ref.key)/photoPath").setValue(
                            url.absoluteString, withCompletionBlock: {
                            (error, ref) in
                            DispatchQueue.main.async {
                                completion(error)
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    }
                })
            } else {
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        })
    }
    
    func update(pitch: Pitch, photo: UIImage?,
        completion: @escaping (Error?) -> Void) {
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            DispatchQueue.main.async {
                completion(PitchServiceError.userNotFound)
            }
            return
        }
        if let pitchId = pitch.id {
            var json = pitch.toJSON()
            if json["id"] != nil {
                json.removeValue(forKey: "id")
            }
            ref.child("\(userId)/\(pitchId)").setValue(json,
                withCompletionBlock: { (error, ref) in
                if error == nil, let photo = photo {
                    let photoPath = "images/pitches/\(pitchId).jpg"
                    StorageService.shared.uploadImage(image: photo,
                        path: photoPath, completion: {
                        [weak self] (error, url) in
                        if let url = url {
                            self?.ref.child("\(userId)/\(ref.key)/photoPath").setValue(
                                url.absoluteString, withCompletionBlock: {
                                (error, ref) in
                                DispatchQueue.main.async {
                                    completion(error)
                                }
                            })
                        } else {
                            DispatchQueue.main.async {
                                completion(error)
                            }
                        }
                    })
                } else {
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            })
        }
    }
    
    func delete(pitch: Pitch, completion: @escaping (Error?) -> Void) {
        guard let userId = FIRAuth.auth()?.currentUser?.uid else {
            DispatchQueue.main.async {
                completion(PitchServiceError.userNotFound)
            }
            return
        }
        if let pitchId = pitch.id {
            ref.child("\(userId)/\(pitchId)").removeValue(completionBlock: {
                (error, ref) in
                DispatchQueue.main.async {
                    completion(error)
                }
            })
        }
        if let photoPath = pitch.photoPath {
            StorageService.shared.deleteImage(path: photoPath,
                completion:nil)
        }
    }

    private func getAllPitches(completion: @escaping ([Pitch]) -> Void) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            var pitches = [Pitch]()
            for child in snapshot.children {
                guard let pitchesByUser = child as? FIRDataSnapshot,
                    let pitchesJSON = pitchesByUser.value as? [String: Any] else {
                    continue
                }
                for (key, value) in pitchesJSON {
                    if var pitchJSON = value as? [String: Any] {
                        pitchJSON["id"] = key
                        if let pitch = Pitch(JSON: pitchJSON) {
                            pitches.append(pitch)
                        }
                    }
                }
            }
            completion(pitches)
        })
    }
    
}

extension PitchService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager,
        didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
}
