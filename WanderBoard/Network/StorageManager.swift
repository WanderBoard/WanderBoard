//
//  StorageManager.swift
//  WanderBoard
//
//  Created by David Jang on 6/4/24.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import UIKit
import CoreLocation
import ImageIO

class StorageManager {
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    // 이미지 업로드 메서드
    func uploadImage(image: UIImage, userId: String) async throws -> Media {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to data."])
        }
        
        let fileName = UUID().uuidString
        let storageRef = storage.reference().child("images/\(userId)/\(fileName).jpg")
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        // 이미지에서 위치 메타데이터 추출
        let location = extractLocationFromImage(image: image)
        if let location = location {
            metadata.customMetadata = [
                "latitude": "\(location.coordinate.latitude)",
                "longitude": "\(location.coordinate.longitude)"
            ]
        }
        
        // 이미지 촬영 날짜 메타데이터 추출
        if let dateTaken = extractDateFromImage(image: image) {
            metadata.customMetadata?["dateTaken"] = "\(dateTaken)"
        }
        
        _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
        
        let downloadURL = try await storageRef.downloadURL()
        
        let media = Media(url: downloadURL.absoluteString, latitude: location?.coordinate.latitude, longitude: location?.coordinate.longitude, dateTaken: extractDateFromImage(image: image))
        
        return media
    }
    
    // 이미지에서 위치 메타데이터를 추출하는 메서드
    private func extractLocationFromImage(image: UIImage) -> CLLocation? {
        guard let cgImage = image.cgImage,
              let data = cgImage.dataProvider?.data,
              let cfData = CFDataCreate(kCFAllocatorDefault, CFDataGetBytePtr(data), CFDataGetLength(data)),
              let source = CGImageSourceCreateWithData(cfData, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let gpsData = metadata["{GPS}"] as? [String: Any],
              let latitude = gpsData["Latitude"] as? Double,
              let longitude = gpsData["Longitude"] as? Double else {
            return nil
        }

        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    // 이미지에서 촬영 날짜 메타데이터를 추출하는 메서드
    private func extractDateFromImage(image: UIImage) -> Date? {
        guard let cgImage = image.cgImage,
              let data = cgImage.dataProvider?.data,
              let cfData = CFDataCreate(kCFAllocatorDefault, CFDataGetBytePtr(data), CFDataGetLength(data)),
              let source = CGImageSourceCreateWithData(cfData, nil),
              let metadata = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [String: Any],
              let exifData = metadata["{Exif}"] as? [String: Any],
              let dateString = exifData["DateTimeOriginal"] as? String else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy:MM:dd HH:mm:ss"
        return formatter.date(from: dateString)
    }
    
    func deleteImage(at path: String, completion: @escaping (Bool) -> Void) {
        let storageRef = storage.reference(withPath: path)
        storageRef.delete { error in
            if let error = error {
                print("Error deleting image: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
