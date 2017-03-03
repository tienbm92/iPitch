//
//  ImageStore.swift
//  iPitch
//
//  Created by Bui Minh Tien on 3/6/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit

class ImageStore{
    
    static let shared = ImageStore()
    let cache = NSCache<NSString, UIImage>()
    func imageURL(forKey key: String) -> URL? {
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        guard let documentDirectory = documentsDirectories.first else {
            return nil
        }
        return documentDirectory.appendingPathComponent(key)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
        if let url = imageURL(forKey: key),
            let data = UIImageJPEGRepresentation(image, 0.5) {
            let _ = try? data.write(to: url, options: [.atomic])
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        if let existingImage = cache.object(forKey: key as NSString) {
            return existingImage
        } else {
            guard let url = imageURL(forKey: key),
                let imageFromDisk = UIImage(contentsOfFile: url.path) else {
                    return nil
            }
            cache.setObject(imageFromDisk, forKey: key as NSString)
            return imageFromDisk
        }
    }
    
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        guard let url = imageURL(forKey: key) else {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print("Error removing the image from disk: \(error)")
        }
    }
}
