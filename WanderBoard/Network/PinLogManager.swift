//
//  PinLogManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/31/24.
//

import Foundation
import FirebaseFirestore

class PinLogManager {
    private let db = Firestore.firestore()
    
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
    
    // PinLog 생성
    func createPinLog(location: String, startDate: Date, endDate: Date, title: String, content: String, mediaURL: [String], authorId: String, attendeeIds: [String], isPublic: Bool) async throws {
        let pinLog = PinLog(location: location, startDate: startDate, endDate: endDate, title: title, content: content, mediaURL: mediaURL, authorId: authorId, attendeeIds: attendeeIds, isPublic: isPublic)
        
        let documentId = pinLog.id ?? UUID().uuidString
        let documentRef = db.collection("pinLogs").document(documentId)
        
        let data: [String: Any] = [
            "location": pinLog.location,
            "startDate": pinLog.startDate,
            "endDate": pinLog.endDate,
            "duration": pinLog.duration,
            "title": pinLog.title,
            "content": pinLog.content,
            "mediaURL": pinLog.mediaURL,
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


/*
 
  // 뷰컨에서 사용
 
 @MainActor
 class PinLogViewModel: ObservableObject {
     private let pinLogManager = PinLogManager()
     
     @Published var pinLogs: [PinLog] = []
     
     func loadPinLogs(forUserId userId: String) async {
         do {
             let fetchedPinLogs = try await pinLogManager.fetchPinLogs(forUserId: userId)
             pinLogs = fetchedPinLogs
         } catch {
             ErrorUtility.shared.presentErrorAlert(with: "Error fetching pin logs: \(error.localizedDescription)")
         }
     }
     
     func createPinLog(location: String, startDate: Date, endDate: Date, title: String, content: String, mediaURL: [String], authorId: String, attendeeIds: [String], isPublic: Bool) async {
         do {
             try await pinLogManager.createPinLog(location: location, startDate: startDate, endDate: endDate, title: title, content: content, mediaURL: mediaURL, authorId: authorId, attendeeIds: attendeeIds, isPublic: isPublic)
             print("PinLog created successfully")
         } catch {
             ErrorUtility.shared.presentErrorAlert(with: "Error creating pin log: \(error.localizedDescription)")
         }
     }
     
     func updatePinLog(pinLogId: String, data: [String: Any]) async {
         do {
             try await pinLogManager.updatePinLog(pinLogId: pinLogId, data: data)
             print("PinLog updated successfully")
         } catch {
             ErrorUtility.shared.presentErrorAlert(with: "Error updating pin log: \(error.localizedDescription)")
         }
     }
 }
 
 */
