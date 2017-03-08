//
//  OrderService.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import FirebaseDatabase

enum OrderServiceError: Error {
    case invalidOrder
}

class OrderService: NSObject {
    
    static let shared = OrderService()
    private let ref = FIRDatabase.database().reference().child("orders")
    
    func getOrder(pitchId: String, status: OrderStatus, lastOrder: Order?,
        completion: @escaping ([Order]) -> Void) {
        var getQuery: FIRDatabaseQuery
        if let lastOrder = lastOrder {
            getQuery = ref.child("\(pitchId)/\(status)").queryStarting(
                atValue: lastOrder.modifiedDate?.timeIntervalSince1970).queryOrdered(
                byChild: "modifiedDate").queryLimited(toFirst: 5)
        } else {
            getQuery = ref.child("\(pitchId)/\(status)").queryOrdered(
                byChild: "modifiedDate").queryLimited(toFirst: 5)
        }
        getQuery.observeSingleEvent(of: .value, with: { (snapshot) in
            var orders = [Order]()
            if let ordersJSON = snapshot.value as? [String: Any] {
                for (key, value) in ordersJSON {
                    if var orderJSON = value as? [String: Any] {
                        orderJSON["id"] = key
                        if let order = Order(JSON: orderJSON) {
                            orders.append(order)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                completion(orders)
            }
        })
    }
    
    func create(order: Order, completion: @escaping (Error?) -> Void) {
        var order = order
        order.modifiedDate = Date()
        if let pitchId = order.pitchId {
            var json = order.toJSON()
            if json["id"] != nil {
                json.removeValue(forKey: "id")
            }
            ref.child("\(pitchId)/pending").childByAutoId().setValue(json) {
                (error, ref) in
                DispatchQueue.main.async {
                    completion(error)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(OrderServiceError.invalidOrder)
            }
        }
    }
    
    func accept(order: Order, completion: @escaping (Error?) -> Void) {
        var order = order
        order.modifiedDate = Date()
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
                    DispatchQueue.main.async {
                        completion(error)
                    }
                })
            })
        } else {
            DispatchQueue.main.async {
                completion(OrderServiceError.invalidOrder)
            }
        }
    }
    
    func reject(order: inout Order, completion: @escaping (Error?) -> Void) {
        var order = order
        order.modifiedDate = Date()
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
                    DispatchQueue.main.async {
                        completion(error)
                    }
                })
            })
        } else {
            DispatchQueue.main.async {
                completion(OrderServiceError.invalidOrder)
            }
        }
    }
    
}
