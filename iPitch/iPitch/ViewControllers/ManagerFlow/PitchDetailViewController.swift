//
//  OrdersListViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/7/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class PitchDetailViewController: UIViewController {
    
    var pitch: Pitch?
    private var orders = [Order]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.pitch?.name
    }

    private func fetchOrder() {
        guard let pitch = self.pitch else {
            return
        }
        if let pitchId = pitch.id {
            WindowManager.shared.showProgressView()
            OrderService.shared.getOrder(pitchId: pitchId) { [weak self] (orders) in
                WindowManager.shared.hideProgressView()
                self?.orders = orders
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editPitchId" { 
            guard let editPitchViewController = segue.destination as? EditPitchViewController else {
                return
            }
            editPitchViewController.pitch = self.pitch
            editPitchViewController.type = .update
        }
    }
    
}
