//
//  PitchInfoViewController.swift
//  iPitch
//
//  Created by Huy Pham on 3/8/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import GoogleMaps

class PitchInfoViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var districtLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    var pitch: Pitch?

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let pitch = pitch else {
            WindowManager.shared.showMessage(message: "PitchNotFound".localized,
                title: nil, completion: { [weak self] (action) in
                self?.back()
            })
            return
        }
        title = pitch.name
        nameLabel.text = pitch.name
        addressLabel.text = pitch.address
        phoneLabel.text = pitch.phone
        districtLabel.text = pitch.district?.name
        avatarImageView.fetchImage(for: pitch.photoPath, id: pitch.id,
            completion: nil)
        mapView.camera = GMSCameraPosition.camera(withTarget: pitch.coordinate,
            zoom: 15.0)
        mapView.refreshMarker(toCoordinate: pitch.coordinate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowOrder" {
            if let orderViewController =
                segue.destination as? OrderViewController {
                orderViewController.pitch = pitch
            }
        }
    }

    @IBAction func onMapTapped(_ sender: Any) {
        if let bigMapViewController =
            UIStoryboard.pitchExtra.instantiateViewController(
            withIdentifier: String(describing: BigMapViewController.self)) as?
            BigMapViewController {
            bigMapViewController.coordinate = pitch?.coordinate
            navigationController?.pushViewController(bigMapViewController,
                animated: true)
        }
        
    }
    
    @IBAction func onAvatarPressed(_ sender: Any) {
        self.previewImage(avatarImageView.image)
    }
    
}
