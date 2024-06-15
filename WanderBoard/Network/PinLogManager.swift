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
import CoreLocation

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
    
    func createOrUpdatePinLog(pinLog: inout PinLog, images: [UIImage], imageLocations: [CLLocationCoordinate2D], isRepresentativeFlags: [Bool]) async throws -> PinLog {
        var mediaObjects: [Media] = []
        
        for (index, image) in images.enumerated() {
            do {
                let isRepresentative = isRepresentativeFlags[index]
                var media = try await StorageManager.shared.uploadImage(image: image, userId: pinLog.authorId, isRepresentative: isRepresentative)
                if index < imageLocations.count {
                    media.latitude = imageLocations[index].latitude
                    media.longitude = imageLocations[index].longitude
                }
                mediaObjects.append(media)
            } catch {
                print("Failed to upload image: \(error)")
                throw error
            }
        }
        
        let mediaData = mediaObjects.map { $0.toDictionary() }
        let expensesData = pinLog.expenses?.map { $0.toDictionary() } ?? []
        
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
            "createdAt": Timestamp(date: pinLog.createdAt ?? Date()),
            "pinCount": pinLog.pinCount ?? 0,
            "pinnedBy": pinLog.pinnedBy ?? [],
            "totalSpendingAmount": pinLog.totalSpendingAmount ?? 0.0,
            "isSpendingPublic": pinLog.isSpendingPublic,
            "maxSpendingAmount": pinLog.maxSpendingAmount ?? 0,
            "expenses": expensesData
        ]
        
        if pinLog.id == nil {
            try await saveDocument(documentRef: documentRef, data: data)
            pinLog.id = documentId
        } else {
            try await updateDocument(documentRef: documentRef, data: data)
        }
        
        return pinLog
    }
    
    func addExpenseToPinLog(pinLogId: String, expense: Expense) async throws {
        let documentRef = db.collection("pinLogs").document(pinLogId)
        
        try await documentRef.updateData([
            "expenses": FieldValue.arrayUnion([expense.toDictionary()])
        ])
    }
    
    func deletePinLog(pinLogId: String) async throws {
        let documentRef = db.collection("pinLogs").document(pinLogId)
        try await documentRef.delete()
    }
    
    func fetchPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        let pinLogs = snapshot.documents.compactMap { document -> PinLog? in
            do {
                let pinLog = try document.data(as: PinLog.self)
                print("Fetched pinLog: \(pinLog)")
                return pinLog
            } catch {
                print("Error decoding document: \(document.documentID), error: \(error)")
                return nil
            }
        }
        print("Fetched pinLogs count: \(pinLogs.count)")
        return pinLogs
    }
    
    func fetchPublicPinLogs() async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs")
            .whereField("isPublic", isEqualTo: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
    }
    
    func fetchSpendingPublicPinLogs() async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs")
            .whereField("isSpendingPublic", isEqualTo: true)
            .getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
    }
    
    func fetchHotPinLogs() async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs")
            .whereField("pinCount", isGreaterThan: 0)
            .getDocuments()
        
        var logs = snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
        logs.shuffle()
        return Array(logs.prefix(10))
    }
    
    func fetchPinLogsWithoutLocation(forUserId userId: String) async throws -> [PinLog] {
        let querySnapshot = try await Firestore.firestore().collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        var pinLogs: [PinLog] = []
        for document in querySnapshot.documents {
            if let pinLog = try? document.data(as: PinLog.self) {
                var logWithoutLocation = pinLog
                logWithoutLocation.media = pinLog.media.map { media in
                    var newMedia = media
                    newMedia.latitude = nil
                    newMedia.longitude = nil
                    return newMedia
                }
                pinLogs.append(logWithoutLocation)
            }
        }
        return pinLogs
    }
    
    //무한스크롤 검색뷰
    func fetchInitialData(pageSize: Int, completion: @escaping (Result<([PinLog], DocumentSnapshot?), Error>) -> Void) {
        db.collection("pinLogs")
            .whereField("isPublic", isEqualTo: true)
            .limit(to: pageSize)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let snapshot = querySnapshot else { return }
                    let logs = snapshot.documents.compactMap { document -> PinLog? in
                        try? document.data(as: PinLog.self)
                    }
                    let lastSnapshot = snapshot.documents.last
                    completion(.success((logs, lastSnapshot)))
                }
            }
    }
    
    func fetchMoreData(pageSize: Int, lastSnapshot: DocumentSnapshot, completion: @escaping (Result<([PinLog], DocumentSnapshot?), Error>) -> Void) {
        db.collection("pinLogs")
            .whereField("isPublic", isEqualTo: true)
            .start(afterDocument: lastSnapshot)
            .limit(to: pageSize)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    guard let snapshot = querySnapshot else { return }
                    let logs = snapshot.documents.compactMap { document -> PinLog? in
                        try? document.data(as: PinLog.self)
                    }
                    let lastSnapshot = snapshot.documents.last
                    completion(.success((logs, lastSnapshot)))
                }
            }
    }
}
