//
//  UserService.swift
//  iPitch
//
//  Created by Huy Pham on 3/14/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserService {
    
    static let shared = UserService()
    private let ref = FIRDatabase.database().reference().child("users")
    private var observeHandle: UInt?
    
    func set(token: String?, forUserId id: String, completion: ((Error?) -> Void)?) {
        ref.child(id).setValue(token) { (error, ref) in
            completion?(error)
        }
    }
    
    func getToken(forUserId id: String, completion: @escaping (String?) -> Void) {
        ref.child(id).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let tokenId = snapshot.value as? String else {
                completion(nil)
                return
            }
            completion(tokenId)
        })
    }
    
}
