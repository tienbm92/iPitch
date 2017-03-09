//
//  ImageStore.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/6/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class ImageStore {
    
    static let shared = ImageStore()
    let cache = NSCache<NSString, UIImage>()

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
    
}
