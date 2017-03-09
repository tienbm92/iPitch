//
//  DistrictService.swift
//  iPitch
//
//  Created by Huy Pham on 3/1/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import FirebaseDatabase

class DistrictService {
    
    static let shared = DistrictService()
    private let ref = FIRDatabase.database().reference().child("districts")
    
    func getAllDistrict(completion: @escaping ([District]) -> Void) {
        ref.observeSingleEvent(of: .value, with: {
            (snapshot) in
            var districts = [District]()
            if let districtsJSON = snapshot.value as? [[String: Any]] {
                for districtJSON in districtsJSON {
                    if let district = District(JSON: districtJSON) {
                        districts.append(district)
                    }
                }
            }
            DispatchQueue.main.async {
                completion(districts)
            }
        })
    }
    
}
