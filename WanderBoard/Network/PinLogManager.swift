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
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            documentRef.setData(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    // Firestore의 데이터를 업데이트하는 함수
    private func updateDocument(documentRef: DocumentReference, data: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            documentRef.updateData(data) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    // Pinlog 생성
    func createPinLog(location: String, startDate: Date, endDate: Date, title: String, content: String, media: [UIImage], authorId: String, attendeeIds: [String], isPublic: Bool) async throws {
        // 이미지 업로드
        var mediaObjects: [Media] = []

        for image in media {
            do {
                let url = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
                    ImageUploader.shared.uploadImage(image) { result in
                        switch result {
                        case .success(let url):
                            continuation.resume(returning: url)
                        case .failure(let error):
                            continuation.resume(throwing: error)
                        }
                    }
                }
                let mediaObject = Media(url: url, latitude: nil, longitude: nil, dateTaken: Date())
                mediaObjects.append(mediaObject)
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
