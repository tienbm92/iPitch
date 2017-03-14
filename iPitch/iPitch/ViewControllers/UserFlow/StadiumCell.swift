//
//  ListStadiumCell.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/3/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit


class StadiumCell: UITableViewCell {

    @IBOutlet weak var nameStadium: UILabel!
    @IBOutlet weak var addressStadium: UILabel!
    @IBOutlet weak var imageStadium: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    var pitch: Pitch? {
        didSet {
            guard let pitch = pitch else {
                nameStadium.text = nil
                addressStadium.text = nil
                imageStadium.image = nil
                return
            }
            nameStadium.text = pitch.name
            if let district = pitch.district?.name {
                addressStadium.text = pitch.address + " - " + district
            } else {
                addressStadium.text = pitch.address
            }
            imageStadium.image = #imageLiteral(resourceName: "img_placeholder")
            if let timeFrom = pitch.activeTimeFrom?.toTimeString(),
                let timeTo = pitch.activeTimeTo?.toTimeString() {
                timeLabel.text = timeFrom + " - " + timeTo
            }
            imageStadium.fetchImage(
                for: pitch.photoPath, id: pitch.id, completion: nil)
        }
    }

}
