//
//  DirectionService.swift
//  iPitch
//
//  Created by Bui Minh Tien on 2/28/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import GoogleMaps

enum TravelModes: Int {
    case driving
    case walking
    case bicycling
}

class DirectionService: NSObject, CLLocationManagerDelegate {
    
    var selectedRoute: [String: Any] = [:]
    var overviewPolyline: [String: Any] = [:]
    var originCoordinate: CLLocationCoordinate2D?
    var destinationCoordinate: CLLocationCoordinate2D?
    var totalDistanceInMeters = 0.0
    var totalDistance: String {
        return "Total Distance: \(totalDistanceInMeters/1000) Km"
    }
    var totalDurationInSeconds = 0
    var totalDuration: String {
        return "Total Duration: \(totalDurationInSeconds/86400) days, " +
            "\((totalDurationInSeconds/3600)%24) hours, " +
            "\((totalDurationInSeconds / 60) % 60) mins, " +
            "\(totalDurationInSeconds%60) secs"
    }
    
    override init(){
        super.init()
    }
    
    func getDirections(origin: String?,
        destination: String?, travelMode: TravelModes?,
        getDirectionStatus: @escaping
        ((_ status: String?, _ success: Bool) -> Void)) {
        guard let originAddress = origin else {
            getDirectionStatus("false", false)
            return
        }
        guard let destinationAddress = destination else {
            getDirectionStatus("false", false)
            return
        }
        var directionsURLString = baseURLDirections + "origin=" +
            originAddress + "&destination=" + destinationAddress
        if (travelMode) != nil {
            var travelModeString = ""
            switch travelMode?.rawValue {
            case TravelModes.walking.rawValue?:
                travelModeString = "walking"
            case TravelModes.bicycling.rawValue?:
                travelModeString = "bicycling"
            default:
                travelModeString = "driving"
            }
            directionsURLString += "&mode=" + travelModeString +
                "&key=" + API_KEY
        } else {
            directionsURLString += "&key=" + API_KEY
        }
        self.parseJsonGoogleMap(directionsURLString: directionsURLString)
            { (status, success) in
            if let status = status {
                if status == "OK" && success {
                    print("parse ok")
                    getDirectionStatus(status, true)
                } else {
                    getDirectionStatus(status, false)
                }
            } else {
                getDirectionStatus(status, false)
            }
        }
    }
    
    func parseJsonGoogleMap(directionsURLString: String,
        completion: @escaping
        ((_ status: String?, _ success: Bool) -> Void)) {
        if let directionsURL = URL(string: directionsURLString) {
            DispatchQueue.global(qos: .userInitiated).async {
            guard let directionsData =
                try? Data(contentsOf: directionsURL)
            else {
                completion("flase", false)
                return
            }
            do {
                guard let dictionary = try JSONSerialization.jsonObject(
                        with: directionsData, options: []) as? [String:Any]
                    else {
                        completion("flase", false)
                        return
                    }
                guard var status = dictionary["status"] as? String
                    else {
                        completion("flase", false)
                        return
                    }
                if status == "OK" {
                    if let dict = dictionary["routes"] as?
                        [[String:Any]], dict.count > 0 {
                        self.selectedRoute = dict[0]
                        if let dictOver =
                                self.selectedRoute["overview_polyline"]
                                as? [String:Any], dictOver.count > 0,
                            let legs = self.selectedRoute["legs"]
                                as? [[String:Any]], legs.count > 0 {
                            self.overviewPolyline = dictOver
                        } else {
                            status = "false"
                            completion(status, false)
                            return
                        }
                    }
                        completion(status, true)
                } else {
                    completion(status, false)
                    return
                }
            } catch let jsonError {
                print(jsonError)
                completion(jsonError.localizedDescription, false)
                }
            }
        } else {
            completion(nil, false)
            return
    }
}
    
    func calculateTotalDistanceAndDuration() -> Bool {
        var status = false
        if let legs = self.selectedRoute["legs"] as? [[String:Any]] {
            for leg in legs {
                if let distance = (leg["distance"] as? [String:Any])?["value"],
                    let duration = (leg["duration"] as? [String:Any])?["value"],
                    let distanceDouble = distance as? Double,
                    let durationDouble = duration as? Int {
                    totalDistanceInMeters =
                        totalDistanceInMeters + distanceDouble
                    totalDurationInSeconds
                        = totalDurationInSeconds + durationDouble
                } else {
                    return status
                }
            }
            status = true
            return status
        }
        return status
    }
    
}
