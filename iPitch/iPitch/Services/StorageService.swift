//
//  StorageService.swift
//  iPitch
//
//  Created by Huy Pham on 3/1/17.
//  Copyright © 2017 Framgia. All rights reserved.
//

import UIKit
import FirebaseStorage

enum UploadError: Error {
    case errorConvertImageToData
}

class StorageService {
    
    static let shared = StorageService()
    private var ref = FIRStorage.storage().reference()
    
    func uploadImage(image: UIImage, path: String,
        completion: @escaping (Error?, URL?) -> Void) {
        if let imageData = UIImageJPEGRepresentation(image, 0.3) {
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            ref.child(path).put(imageData,
                metadata: metadata) { (metadata, error) in
                completion(error, metadata?.downloadURL())
            }
        } else {
            completion(UploadError.errorConvertImageToData, nil)
        }
    }
    
    func downloadImage(path: String,
        completion: @escaping (Error?, UIImage?) -> Void) {
        let downloadRef = FIRStorage.storage().reference(forURL: path)
        downloadRef.data(withMaxSize: Int64.max) { (data, error) in
            if let data = data {
                if let photo = UIImage(data: data) {
                    OperationQueue.main.addOperation {
                        completion(error, photo)
                    }
                }
            } else {
                OperationQueue.main.addOperation {
                    completion(error, nil)
                }
            }
        }
    }
    
    func deleteImage(path: String, completion: @escaping (Error?) -> Void) {
        let deleteRef = FIRStorage.storage().reference(forURL: path)
        deleteRef.delete { (error) in
            completion(error)
        }
    }
    
}
