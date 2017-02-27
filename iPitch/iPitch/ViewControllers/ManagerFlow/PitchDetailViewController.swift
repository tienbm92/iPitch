//
//  OrdersListViewController.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/7/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import SVPullToRefresh

class PitchDetailViewController: UIViewController {
    
    @IBOutlet weak var noOrderLabel: UILabel!
    @IBOutlet weak var ordersListTableView: UITableView!
    @IBOutlet weak var ordersListSegment: UISegmentedControl!    
    var pitch: Pitch?
    fileprivate var pendingOrders = [Order]()
    fileprivate var acceptOrders = [Order]()
    fileprivate var rejectOrders = [Order]()
    fileprivate var orderStatus: OrderStatus = .pending
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = self.pitch?.name
        WindowManager.shared.showProgressView()
        self.fetchOrder()
        self.ordersListTableView.addInfiniteScrolling { 
            [weak self] in
            DispatchQueue.main.async {
                self?.fetchOrder()
            }
        }
    }
    
    fileprivate func fetchOrder() {
        guard let pitchId = self.pitch?.id else {
            return
        }
        switch orderStatus {
        case .pending:
            OrderService.shared.getOrder(pitchId: pitchId, status: .pending,
                lastOrder: pendingOrders.last) { [weak self] (orders) in
                WindowManager.shared.hideProgressView()
                self?.ordersListTableView.infiniteScrollingView.stopAnimating()
                if let currentSelf = self {
                    currentSelf.pendingOrders.append(contentsOf: orders)
                    currentSelf.reloadData(orders: currentSelf.pendingOrders)
                }
            }
        case .accept:
            OrderService.shared.getOrder(pitchId: pitchId, status: .accept,
                lastOrder: acceptOrders.last) { [weak self] (orders) in
                WindowManager.shared.hideProgressView()
                self?.ordersListTableView.infiniteScrollingView.stopAnimating()
                if let currentSelf = self {
                    currentSelf.acceptOrders.append(contentsOf: orders)
                    currentSelf.reloadData(orders: currentSelf.acceptOrders)
                }
            }
        case .reject:
            OrderService.shared.getOrder(pitchId: pitchId, status: .reject,
                lastOrder: rejectOrders.last) { [weak self] (orders) in
                WindowManager.shared.hideProgressView()
                self?.ordersListTableView.infiniteScrollingView.stopAnimating()
                if let currentSelf = self {
                    currentSelf.rejectOrders.append(contentsOf: orders)
                    currentSelf.reloadData(orders: currentSelf.rejectOrders)
                }
            }
        }
    }
    
    fileprivate func reloadData(orders: [Order]) {
        if orders.count != 0 {
            self.noOrderLabel.isHidden = true
        } else {
            self.noOrderLabel.text = "NoDataOrder".localized
            self.noOrderLabel.isHidden = false
        }
        self.ordersListTableView.reloadData()
    }
    
    fileprivate func refreshOrder(status: OrderStatus...) {
        guard let pitchId = self.pitch?.id else {
            return
        }
        if !status.isEmpty {
            WindowManager.shared.showProgressView()
        }
        for orderStatus in status {
            switch orderStatus {
            case .pending:
                OrderService.shared.getOrder(pitchId: pitchId, status: .pending,
                    lastOrder: nil) { [weak self] (orders) in
                    WindowManager.shared.hideProgressView()
                    if let currentSelf = self {
                        currentSelf.pendingOrders = orders
                        currentSelf.reloadData(orders: currentSelf.pendingOrders)
                    }
                }
            case .accept:
                OrderService.shared.getOrder(pitchId: pitchId, status: .accept,
                    lastOrder: nil) { [weak self] (orders) in
                    WindowManager.shared.hideProgressView()
                    if let currentSelf = self {
                        currentSelf.acceptOrders = orders
                    }
                }
            case .reject:
                OrderService.shared.getOrder(pitchId: pitchId, status: .reject,
                    lastOrder: nil) { [weak self] (orders) in
                    WindowManager.shared.hideProgressView()
                    if let currentSelf = self {
                        currentSelf.rejectOrders = orders
                    }
                }
            }
        }
        
    }
    
    @IBAction func changeOrdersList(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.orderStatus = .pending
            if pendingOrders.isEmpty {
                WindowManager.shared.showProgressView()
                self.fetchOrder()
            } else {
                self.reloadData(orders: self.pendingOrders)
            }
        case 1:
            self.orderStatus = .accept
            if acceptOrders.isEmpty {
                WindowManager.shared.showProgressView()
                self.fetchOrder()
            } else {
                self.reloadData(orders: self.acceptOrders)
            }
        case 2:
            self.orderStatus = .reject
            if rejectOrders.isEmpty {
                WindowManager.shared.showProgressView()
                self.fetchOrder()
            } else {
                self.reloadData(orders: self.rejectOrders)
            }
        default:
            break
        }
    }
    
    @IBAction func refreshButtonTapped(_ sender: UIBarButtonItem) {
        WindowManager.shared.showProgressView()
        self.fetchOrder()
    }
    
}

extension PitchDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch orderStatus {
        case .pending:
            return self.pendingOrders.count
        case .accept:
            return self.acceptOrders.count
        case .reject:
            return self.rejectOrders.count
        }
    }
    
    func tableView(_ tableView: UITableView,
        cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell",
            for: indexPath) as? OrderCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        switch orderStatus {
        case .pending:
            cell.order = self.pendingOrders[indexPath.row]
        case .accept:
            cell.order = self.acceptOrders[indexPath.row]
        case .reject:
            cell.order = self.rejectOrders[indexPath.row]
        }
        return cell
    }
    
}

extension PitchDetailViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,
        heightForHeaderInSection section: Int) -> CGFloat {
        return 0.5
    }
    
}

extension PitchDetailViewController: OrderCellDelegate {
    
    func orderIsAccepted(order: Order?) {
        guard let order = order, let pitch = self.pitch else {
            return
        }
        WindowManager.shared.acceptOrderConfirm(order: order, pitch: pitch) {
            [weak self] (action) in
            self?.refreshOrder(status: .pending, .accept)
        }
    }
    
    func orderIsRejected(order: Order?) {
        guard let order = order, let pitch = self.pitch else {
            return
        }
        WindowManager.shared.rejectOrderConfirm(order: order, pitch: pitch) {
            [weak self] (action) in
            self?.refreshOrder(status: .pending, .reject)
        }
    }
    
}
