//
//  PitchListCell.swift
//  iPitch
//
//  Created by Nguyen Quoc Tinh on 3/3/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

protocol PitchListCellDelegate: class {
    func editPitch(pitch: Pitch?)
    func checkOrder(pitch: Pitch?)
}

class PitchListCell: UITableViewCell {
    
    @IBOutlet weak var pitchImage: UIImageView!
    @IBOutlet weak var pitchNameLabel: UILabel!
    @IBOutlet weak var pitchAddressLabel: UILabel!
    @IBOutlet weak var pitchActiveTimeLabel: UILabel!
    weak var delegate: PitchListCellDelegate?
    var pitch: Pitch? {
        didSet {
            guard let pitch = pitch else {
                pitchNameLabel.text = nil
                pitchAddressLabel.text = nil
                pitchActiveTimeLabel.text = nil
                pitchImage.image = nil
                return
            }
            pitchNameLabel.text = pitch.name
            if let districtName = pitch.district?.name {
                pitchAddressLabel.text = String(format: "PitchAddress".localized,
                    pitch.address, districtName)
            } else {
                pitchAddressLabel.text = String(format: "PitchAddress".localized,
                    pitch.address, "")
            }
            if let timeFrom = pitch.activeTimeFrom?.toTimeString(),
                let timeTo = pitch.activeTimeTo?.toTimeString() {
                pitchActiveTimeLabel.text = String(format: "PitchActiveTime".localized,
                    timeFrom, timeTo)
            } else {
                pitchActiveTimeLabel.text = nil
            }
            if let photoPath = pitch.photoPath {
                pitchImage.fetchImage(for: photoPath, id: pitch.id, completion: nil)
            } else {
                pitchImage.image = #imageLiteral(resourceName: "img_placeholder")
            }
        }
    }
    
    @IBAction func checkOrderButtonTapped(_ sender: UIButton) {
        delegate?.checkOrder(pitch: pitch)
    }
    
    @IBAction func editPitchButtonTapped(_ sender: UIButton) {
        delegate?.editPitch(pitch: pitch)
    }
}

