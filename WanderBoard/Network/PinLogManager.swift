//
//  PinLogManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/31/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

class PinLogManager {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()


    // Firestore에 데이터를 저장하는 함수
    private func saveDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        try await documentRef.setData(data)
    }

    // Firestore의 데이터를 업데이트하는 함수
    private func updateDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        try await documentRef.updateData(data)
    }

    // Pinlog 생성
    func createPinLog(location: String, startDate: Date, endDate: Date, title: String, content: String, images: [UIImage], authorId: String, attendeeIds: [String], isPublic: Bool) async throws {
        let storageManager = StorageManager()
        var mediaObjects: [Media] = []

        for image in images {
            do {
                let media = try await storageManager.uploadImage(image: image, userId: authorId)
                mediaObjects.append(media)
            } catch {
                print("Failed to upload image: \(error)")
                throw error
            }
        }

        // Firestore 데이터 생성
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

        let pinLog = PinLog(location: location, startDate: startDate, endDate: endDate, title: title, content: content, media: mediaObjects, authorId: authorId, attendeeIds: attendeeIds, isPublic: isPublic)

        let documentId = pinLog.id ?? UUID().uuidString
        let documentRef = db.collection("pinLogs").document(documentId)

        let data: [String: Any] = [
            "location": pinLog.location,
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

        try await saveDocument(documentRef: documentRef, data: data)
    }

    // PinLog 업데이트
    func updatePinLog(pinLogId: String, data: [String: Any]) async throws {
        let documentRef = db.collection("pinLogs").document(pinLogId)
        try await updateDocument(documentRef: documentRef, data: data)
    }

    // PinLog 조회
    func fetchPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
    }
}
