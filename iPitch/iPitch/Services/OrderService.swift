//
//  OrderService.swift
//  iPitch
//
//  Created by Huy Pham on 2/27/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import Foundation
import FirebaseDatabase

class OrderService: NSObject {
    
    static let shared = OrderService()
    private let ref = FIRDatabase.database().reference().child("orders")
    
    func getOrder(pitchId: String, completion: @escaping ([Order]) -> Void) {
        let currentTime = NSDate().timeIntervalSince1970
        ref.queryEqual(toValue: pitchId,
            childKey: "pitchId").queryStarting(
            atValue: currentTime).queryOrdered(
            byChild: "timeFrom").observeSingleEvent(of: .value, with: {
                (snapshot) in
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
                OperationQueue.main.addOperation {
                    completion(orders)
                }
            })
    }
    
    func create(order: Order, completion: @escaping (Error?) -> Void) {
        var json = order.toJSON()
        if json["id"] != nil {
            json.removeValue(forKey: "id")
        }
        ref.childByAutoId().setValue(json) { (error, ref) in
            OperationQueue.main.addOperation {
                completion(error)
            }
        }
    }
    
    func accept(order: Order, completion: @escaping (Error?) -> Void) {
        if let orderId = order.id {
            ref.child(orderId).child("isAccept").setValue(true,
                withCompletionBlock: { (error, ref) in
                OperationQueue.main.addOperation {
                    completion(error)
                }
            })
        }
    }
    
}
