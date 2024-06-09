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

    private func saveDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        try await documentRef.setData(data)
    }

    private func updateDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        try await documentRef.updateData(data)
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
            var mediaDict: [String: Any] = ["url": mediaItem.url]
            if let latitude = mediaItem.latitude, let longitude = mediaItem.longitude {
                mediaDict["latitude"] = latitude
                mediaDict["longitude"] = longitude
            }
            if let dateTaken = mediaItem.dateTaken {
                mediaDict["dateTaken"] = Timestamp(date: dateTaken)
            }
            return mediaDict
        }

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
            "isPublic": pinLog.isPublic
        ]

        if pinLog.id == nil {
            try await saveDocument(documentRef: documentRef, data: data)
            pinLog.id = documentId
        } else {
            try await updateDocument(documentRef: documentRef, data: data)
        }

        return pinLog
    }

    func updatePinLog(pinLogId: String, data: [String: Any]) async throws {
        let documentRef = db.collection("pinLogs").document(pinLogId)
        try await updateDocument(documentRef: documentRef, data: data)
    }

    func fetchPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
    }
}
