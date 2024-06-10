//
//  PinLogManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/31/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class PinLogManager {
    static let shared = PinLogManager()
    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    
    // Firestore에 데이터를 저장하는 함수

    private func saveDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        try await documentRef.setData(data)
    }

    private func updateDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        try await documentRef.updateData(data)
    }

    
    // Pinlog 생성
    func createPinLog(location: String, startDate: Date, endDate: Date, title: String, content: String, images: [(UIImage, Bool)], authorId: String, attendeeIds: [String], isPublic: Bool, createdAt: Date) async throws -> PinLog {
        let storageManager = StorageManager()
        var mediaObjects: [Media] = []
        
        await withTaskGroup(of: Media?.self) { group in
            for (image, isRepresentative) in images {
                group.addTask {
                    return try? await storageManager.uploadImage(image: image, userId: authorId, isRepresentative: isRepresentative)
                }
            }
            
            for await media in group {
                if let media = media {
                    mediaObjects.append(media)
                }
            }
        }
        


    func createOrUpdatePinLog(pinLog: inout PinLog, images: [UIImage]) async throws -> PinLog {
        let storageManager = StorageManager()
        var mediaObjects: [Media] = []
        
        for image in images {
            do {
                let media = try await storageManager.uploadImage(image: image, userId: pinLog.authorId)
                mediaObjects.append(media)
            } catch {
                print("Failed to upload image: \(error)")
                throw error
            }
        }


        let mediaData = mediaObjects.map { mediaItem -> [String: Any] in
            var mediaDict: [String: Any] = ["url": mediaItem.url, "isRepresentative": mediaItem.isRepresentative]
            if let latitude = mediaItem.latitude, let longitude = mediaItem.longitude {
                mediaDict["latitude"] = latitude
                mediaDict["longitude"] = longitude
            }
            if let dateTaken = mediaItem.dateTaken {
                mediaDict["dateTaken"] = Timestamp(date: dateTaken)
            }
            return mediaDict
        }

        
        let createdAt = Date()
        let pinLog = PinLog(location: location, startDate: startDate, endDate: endDate, title: title, content: content, media: mediaObjects, authorId: authorId, attendeeIds: attendeeIds, isPublic: isPublic, createdAt: createdAt)
        

        let documentId = pinLog.id ?? UUID().uuidString
        let documentRef = db.collection("pinLogs").document(documentId)
        
        let data: [String: Any] = [
            "location": pinLog.location,
            "address": pinLog.address,
            "latitude": pinLog.latitude,
            "longitude": pinLog.longitude,
            "startDate": Timestamp(date: pinLog.startDate),
            "endDate": Timestamp(date: pinLog.endDate),
            "duration": pinLog.duration,
            "title": pinLog.title,
            "content": pinLog.content,
            "media": mediaData,
            "authorId": pinLog.authorId,
            "attendeeIds": pinLog.attendeeIds,
            "isPublic": pinLog.isPublic,
            "createdAt": Timestamp(date: createdAt)
        ]

        if pinLog.id == nil {
            try await saveDocument(documentRef: documentRef, data: data)
            pinLog.id = documentId
        } else {
            try await updateDocument(documentRef: documentRef, data: data)
        }

        return pinLog
    }

    
    // PinLog 업데이트
    func updatePinLog(pinLogId: String, updatedPinLog: PinLog, newImages: [(UIImage, Bool)]) async throws -> PinLog {

        let documentRef = db.collection("pinLogs").document(pinLogId)
        let storageManager = StorageManager()
        
        var mediaObjects: [Media] = []
        await withTaskGroup(of: Media?.self) { group in
            for (image, isRepresentative) in newImages {
                group.addTask {
                    return try? await storageManager.uploadImage(image: image, userId: updatedPinLog.authorId, isRepresentative: isRepresentative)
                }
            }
            
            for await media in group {
                if let media = media {
                    mediaObjects.append(media)
                }
            }
        }

        let mediaData = mediaObjects.map { mediaItem -> [String: Any] in
            var mediaDict: [String: Any] = ["url": mediaItem.url, "isRepresentative": mediaItem.isRepresentative]
            if let latitude = mediaItem.latitude, let longitude = mediaItem.longitude {
                mediaDict["latitude"] = latitude
                mediaDict["longitude"] = longitude
            }
            if let dateTaken = mediaItem.dateTaken {
                mediaDict["dateTaken"] = Timestamp(date: dateTaken)
            }
            return mediaDict
        }

        let data: [String: Any] = [
            "location": updatedPinLog.location,
            "startDate": Timestamp(date: updatedPinLog.startDate),
            "endDate": Timestamp(date: updatedPinLog.endDate),
            "duration": updatedPinLog.duration,
            "title": updatedPinLog.title,
            "content": updatedPinLog.content,
            "media": mediaData,
            "authorId": updatedPinLog.authorId,
            "attendeeIds": updatedPinLog.attendeeIds,
            "isPublic": updatedPinLog.isPublic,
        ]

        try await documentRef.updateData(data)
        
        return PinLog(
            id: updatedPinLog.id,
            location: updatedPinLog.location,
            startDate: updatedPinLog.startDate,
            endDate: updatedPinLog.endDate,
            title: updatedPinLog.title,
            content: updatedPinLog.content,
            media: mediaObjects,
            authorId: updatedPinLog.authorId,
            attendeeIds: updatedPinLog.attendeeIds,
            isPublic: updatedPinLog.isPublic,
            createdAt: updatedPinLog.createdAt
        )
    }
    
    func fetchPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
    }

    func fetchPinLog(pinLogId: String) async throws -> PinLog? {
        let document = try await db.collection("pinLogs").document(pinLogId).getDocument()
        return try document.data(as: PinLog.self)
    }

//    func fetchPinLogData(pinLogId: String) async throws -> PinLog? {
//        let document = try await db.collection("pinLogs").document(pinLogId).getDocument()
//        return try document.data(as: PinLog.self)
//    }

}
