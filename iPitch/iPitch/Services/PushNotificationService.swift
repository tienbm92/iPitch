//
//  PushNotificationService.swift
//  iPitch
//
//  Created by Huy Pham on 3/10/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import FirebaseDatabase

class PushNotificationService {
    
    enum PushNotificationServiceError: Error {
        case errorCreateURL
        case errorGettingUserToken
    }
    
    static let shared = PushNotificationService()
    private let ref = FIRDatabase.database().reference()
    private let session: URLSession = {
        return URLSession(configuration: .default)
    }()
    
    func pushNotification(message: String, toUserId id: String,
        completion: ((Error?) -> Void)?) {
        getToken(forUserId: id) { [unowned self] (tokenId) in
            guard let tokenId = tokenId else {
                completion?(PushNotificationServiceError.errorGettingUserToken)
                return
            }
            guard let url = URL(string: gcmApiUrl) else {
                completion?(PushNotificationServiceError.errorCreateURL)
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("key=\(gcmServerKey)", forHTTPHeaderField: "Authorization")
            var notificationRequest = NotificationRequest()
            notificationRequest.notification = NotificationContent(title: nil, body: message)
            notificationRequest.to = tokenId
            request.httpBody = notificationRequest.toJSONString()?.data(using: .utf8,
                allowLossyConversion: false)
            let task = self.session.dataTask(with: request) {
                (data, response, error) in
                completion?(error)
            }
            task.resume()
        }
    }
    
    func set(token: String?, forUserId id: String, completion: ((Error?) -> Void)?) {
        ref.child("users/\(id)").setValue(token) { (error, ref) in
            completion?(error)
        }
    }
    
    func getToken(forUserId id: String, completion: @escaping (String?) -> Void) {
        ref.child("users/\(id)").observeSingleEvent(of: .value, with: { (snapshot) in
            guard let tokenId = snapshot.value as? String else {
                completion(nil)
                return
            }
            completion(tokenId)
        })
    }
    
}
