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
    
    func getPitch(radius: Double?, districtId: String?, timeFrom: Date?,
                  timeTo: Date?, completion: @escaping ([Pitch]) -> Void) {
        getAllPitches { (pitches) in
            let pitchesFilter = pitches.filter({
                [weak self] (pitch) -> Bool in
                if let radius = radius,
                    let location = self?.locationManager.location {
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
                return true
            })
            OperationQueue.main.addOperation {
                completion(pitchesFilter)
            }
        }
    }

    func create(pitch: Pitch, photo: UIImage?, completion: @escaping (Error?) -> Void) {
        if let userId = FIRAuth.auth()?.currentUser?.uid {
            var json = pitch.toJSON()
            if json["id"] != nil {
                json.removeValue(forKey: "id")
            }
            if json["photoPath"] != nil {
                json.removeValue(forKey: "photoPath")
            }
            json["ownerId"] = userId
            ref.childByAutoId().setValue(json, withCompletionBlock: {
                (error, ref) in
                if error != nil, let photo = photo {
                    let photoPath = "images/pitches/\(ref.key).jpg"
                    StorageService.shared.uploadImage(image: photo,
                        path: photoPath, completion: {
                        [weak self] (error, url) in
                        if let url = url {
                            self?.ref.child("\(ref.key)/photoPath").setValue(
                                url.absoluteString, withCompletionBlock: {
                                (error, ref) in
                                OperationQueue.main.addOperation {
                                    completion(error)
                                }
                            })
                        } else {
                            OperationQueue.main.addOperation {
                                completion(error)
                            }
                        }
                    })
                } else {
                    OperationQueue.main.addOperation {
                        completion(error)
                    }
                }
            })
        }
    }
    
    func update(pitch: Pitch, completion: @escaping (Error?) -> Void) {
        if let pitchId = pitch.id {
            var json = pitch.toJSON()
            if json["id"] != nil {
                json.removeValue(forKey: "id")
            }
            ref.child(pitchId).setValue(json, withCompletionBlock: {
                (error, ref) in
                OperationQueue.main.addOperation {
                    completion(error)
                }
            })
        }
    }

    private func getAllPitches(completion: @escaping ([Pitch]) -> Void) {
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
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
            completion(pitches)
        })
    }
    
}

extension PitchService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
}
