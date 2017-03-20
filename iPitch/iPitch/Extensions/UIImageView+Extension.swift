//
//  UIImageView+Extension.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/6/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

enum ImageResult {
    case success(UIImage)
    case failure(Error)
}

enum ImageRequestError: Error {
    case errorGettingImageURL
    case errorGettingPitchId
    case errorCreatingImage
}

extension UIImageView {
    
    func fetchImage(for url: String?, id: String?,
        completion: ((ImageResult) -> Void)?) {
        guard let id = id else {
            self.image = #imageLiteral(resourceName: "img_placeholder")
            completion?(.failure(ImageRequestError.errorGettingPitchId))
            return
        }
        let imageKey = "path\(id)"
        if let image = ImageStore.shared.image(forKey: imageKey) {
            DispatchQueue.main.async {
                self.image = image
                completion?(.success(image))
                return
            }
        } else {
            WindowManager.shared.showProgressView()
            ImageStore.shared.deleteImage(forKey: imageKey)
        }
        guard let photoPath = url else {
            self.image = #imageLiteral(resourceName: "img_placeholder")
            completion?(.failure(ImageRequestError.errorGettingImageURL))
            return
        }
        StorageService.shared.downloadImage(path: photoPath)
        { [weak self] (error, photo) in
            WindowManager.shared.hideProgressView()
            if let error = error {
                print(error.localizedDescription)
                completion?(.failure(ImageRequestError.errorCreatingImage))
            } else {
                if let photo = photo {
                    self?.image = photo
                    ImageStore.shared.setImage(photo, forKey: imageKey)
                    DispatchQueue.main.async {
                        completion?(.success(photo))
                    }
                }
            }
        }
    }
    
    func fetchImageMap(for url: String?, id: String?) {
        guard let id = id else {
            self.image = #imageLiteral(resourceName: "img_placeholder")
            return
        }
        let imageKey = "path\(id)"
        if let image = ImageStore.shared.image(forKey: imageKey) {
            self.image = image
            return
        } else {
            ImageStore.shared.deleteImage(forKey: imageKey)
        }
        guard let url = url else {
            self.image = #imageLiteral(resourceName: "img_placeholder")
            return
        }
        if  let url = URL(string: url),
            let data = try? Data(contentsOf: url) {
            self.image = UIImage(data: data)
        } else {
            self.image = #imageLiteral(resourceName: "img_placeholder")
        }
    }
    
    func makeBlurEffect() {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
}
