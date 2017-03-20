//
//  MarkerView.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/22/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class MarkerView: UIView {
    @IBOutlet weak var imageMarker: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    let mapIpitch = MapIPitchControllers()
    var pitch: Pitch? {
        didSet {
            guard let pitch = pitch else {
                nameLabel.text = nil
                return
            }
            nameLabel.text = pitch.name
            imageMarker.fetchImage(
                for: pitch.photoPath, id: pitch.id, completion: nil)
//            imageMarker.fetchImageMap(for: pitch.photoPath, id: pitch.id)
        }
    }
    
}
