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
            completion?(.failure(ImageRequestError.errorGettingPitchId))
            return
        }
        let imageKey = "path\(id)"
        if let image = ImageStore.shared.image(forKey: imageKey) {
            OperationQueue.main.addOperation {
                completion?(.success(image))
            }
            return
        }
        guard let photoPath = url else {
            completion?(.failure(ImageRequestError.errorGettingImageURL))
            return
        }
        StorageService.shared.downloadImage(path: photoPath)
        { [weak self] (error, photo) in
            if error != nil {
                completion?(.failure(ImageRequestError.errorCreatingImage))
            } else {
                if let photo = photo {
                    self?.image = photo
                    ImageStore.shared.setImage(photo, forKey: imageKey)
                    OperationQueue.main.addOperation {
                        completion?(.success(photo))
                    }
                }
            }
        }
    }
    
}
