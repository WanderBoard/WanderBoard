//
//  ImageUploader.swift
//  WanderBoard
//
//  Created by David Jang on 6/4/24.
//

//import UIKit
//import FirebaseStorage
//
//class ImageUploader {
//    static let shared = ImageUploader()
//    private init() {}
//
//    func uploadImage(_ image: UIImage, completion: @escaping (Result<String, Error>) -> Void) {
//        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
//            completion(.failure(NSError(domain: "ImageUploader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data"])))
//            return
//        }
//
//        let storageRef = Storage.storage().reference().child("images/\(UUID().uuidString).jpg")
//        storageRef.putData(imageData, metadata: nil) { metadata, error in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//
//            storageRef.downloadURL { url, error in
//                if let error = error {
//                    completion(.failure(error))
//                    return
//                }
//
//                if let downloadURL = url?.absoluteString {
//                    completion(.success(downloadURL))
//                } else {
//                    completion(.failure(NSError(domain: "ImageUploader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get download URL"])))
//                }
//            }
//        }
//    }
//}
