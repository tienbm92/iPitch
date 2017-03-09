//
//  OrderService.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseInstanceID

class OrderService: NSObject {
    
    enum OrderServiceError: Error {
        case invalidOrder
        case invalidPitch
    }
    
    static let shared = OrderService()
    private let ref = FIRDatabase.database().reference().child("orders")
    
    func getOrder(pitchId: String, status: OrderStatus, lastOrder: Order?,
        completion: @escaping ([Order]) -> Void) {
        var getQuery: FIRDatabaseQuery
        if let lastOrder = lastOrder {
            getQuery = ref.child("\(pitchId)/\(status)").queryEnding(
                atValue: lastOrder.modifiedDate).queryOrdered(
                byChild: "modifiedDate").queryLimited(toLast: 10)
        } else {
            getQuery = ref.child("\(pitchId)/\(status)").queryOrdered(
            byChild: "modifiedDate").queryLimited(toLast: 10)
        }
        getQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            var orders = [Order]()
            for child in snapshot.children {
                if let order = child as? FIRDataSnapshot,
                var orderJSON = order.value as? [String: Any] {
                    orderJSON["id"] = order.key
                    if let order = Order(JSON: orderJSON) {
                        orders.append(order)
                    }
                }
            }
            DispatchQueue.main.async {
                completion(orders)
            }
        })
    }
    
    func create(order: Order, pitch: Pitch, completion: @escaping (Error?) -> Void) {
        var order = order
        order.tokenId = FIRInstanceID.instanceID().token()
        order.modifiedDate = Date()
        if let pitchId = order.pitchId {
            var json = order.toJSON()
            if json["id"] != nil {
                json.removeValue(forKey: "id")
            }
            ref.child("\(pitchId)/pending").childByAutoId().setValue(json) {
                (error, ref) in
                guard let pitchOwnerId = pitch.ownerId else {
                    completion(OrderServiceError.invalidPitch)
                    return
                }
                PushNotificationService.shared.pushNotification(
                    message: String(format: "PitchHasBeenRequested".localized, pitch.name),
                    toUserId: pitchOwnerId, completion: { (error) in
                    DispatchQueue.main.async {
                        completion(error)
                    }
                })
            }
        } else {
            DispatchQueue.main.async {
                completion(OrderServiceError.invalidOrder)
            }
        }
    }
    
    func accept(order: Order, pitch: Pitch, completion: @escaping (Error?) -> Void) {
        var order = order
        if let orderId = order.id,
            let pitchId = order.pitchId {
            order.status = .accept
            var json = order.toJSON()
            if json["id"] != nil {
                json.removeValue(forKey: "id")
            }
            ref.child("\(pitchId)/accept/\(orderId)").setValue(json,
                withCompletionBlock: { [unowned self] (error, ref) in
                self.ref.child("\(pitchId)/pending/\(orderId)").removeValue(
                    completionBlock: { (error, ref) in
                    guard let tokenId = order.tokenId else {
                        completion(OrderServiceError.invalidOrder)
                        return
                    }
                    PushNotificationService.shared.pushNotification(
                        message: String(format: "PitchOrderHasBeenConfirmed".localized, pitch.name),
                        toUserId: tokenId, completion: { (error) in
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    })
                })
            })
        } else {
            DispatchQueue.main.async {
                completion(OrderServiceError.invalidOrder)
            }
        }
    }
    
    func reject(order: Order, pitch: Pitch, completion: @escaping (Error?) -> Void) {
        var order = order
        if let orderId = order.id,
            let pitchId = order.pitchId {
            let oldStatus = order.status
            order.status = .reject
            var json = order.toJSON()
            if json["id"] != nil {
                json.removeValue(forKey: "id")
            }
            ref.child("\(pitchId)/reject/\(orderId)").setValue(json,
                withCompletionBlock: { [unowned self] (error, ref) in
                self.ref.child("\(pitchId)/\(oldStatus)/\(orderId)").removeValue(
                    completionBlock: { (error, ref) in
                    guard let tokenId = order.tokenId else {
                        completion(OrderServiceError.invalidOrder)
                        return
                    }
                    PushNotificationService.shared.pushNotification(
                        message: String(format: "PitchOrderHasBeenRejected".localized, pitch.name),
                        toUserId: tokenId, completion: { (error) in
                        DispatchQueue.main.async {
                            completion(error)
                        }
                    })
                })
            })
        } else {
            DispatchQueue.main.async {
                completion(OrderServiceError.invalidOrder)
            }
        }
    }
    
}
