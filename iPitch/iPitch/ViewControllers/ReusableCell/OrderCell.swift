//
//  OrderCell.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/9/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

protocol OrderCellDelegate: class {
    func orderIsAccepted(order: Order?)
    func orderIsRejected(order: Order?)
}

class OrderCell: UITableViewCell {

    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var orderNameLabel: UILabel!
    @IBOutlet weak var orderPhoneLabel: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
    @IBOutlet weak var statusOrderLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    weak var delegate: OrderCellDelegate?
    var order: Order? {
        didSet {
            guard let order = order else {
                orderDateLabel.text = nil
                orderNameLabel.text = nil
                orderPhoneLabel.text = nil
                orderTimeLabel.text = nil
                statusOrderLabel.text = nil
                acceptButton.isHidden = true
                rejectButton.isHidden = true
                return
            }
            switch order.status {
            case .pending:
                self.statusOrderLabel.isHidden = true
                self.acceptButton.isHidden = false
                self.rejectButton.isHidden = false
            case .accept, .reject:
                self.statusOrderLabel.isHidden = false
                self.acceptButton.isHidden = true
                self.rejectButton.isHidden = true
                self.statusOrderLabel.text = order.status.rawValue.localized
            }
            orderDateLabel.text = order.modifiedDate?.toDateString()
            orderNameLabel.text = order.name
            orderPhoneLabel.text = String(format: "OrderPhone".localized,
                order.phone)
            if let timeFromString = order.timeFrom?.toTimeString(),
                let timeToString = order.timeTo?.toTimeString() {
                orderTimeLabel.text = String(format: "OrderTime".localized,
                    timeFromString, timeToString)
                orderTimeLabel.isHidden = false
            } else {
                orderTimeLabel.isHidden = true
            }
        }
    }
    
    @IBAction func acceptOrder(_ sender: UIButton) {
        delegate?.orderIsAccepted(order: order)
    }
    
    @IBAction func rejectOrder(_ sender: UIButton) {
        delegate?.orderIsRejected(order: order)
    }
    
}
