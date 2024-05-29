//
//  FirestoreManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/28/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

final class FirestoreManager {
    static let shared = FirestoreManager()
    private init() { }
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var uploadTasks: [String: StorageUploadTask] = [:]
    
    func saveUser(uid: String, email: String, displayName: String?, photoURL: String?, socialMediaLink: String?, authProvider: String) async throws {
        let userRef = db.collection("users").document(uid)
        
        var dataToSave: [String: Any] = [
            "email": email,
            "authProvider": authProvider
        ]
        
        if let displayName = displayName {
            dataToSave["displayName"] = displayName
        }
        if let photoURL = photoURL {
            dataToSave["photoURL"] = photoURL
        }
        if let socialMediaLink = socialMediaLink {
            dataToSave["socialMediaLink"] = socialMediaLink
        }
        
        try await userRef.setData(dataToSave, merge: true)
    }

    func saveOrUpdateUser(user: UserEntity) async throws {
        let userRef = db.collection("users").document(user.uid ?? "")
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            userRef.getDocument { document, error in
                if let document = document, document.exists {
                    // 기존 문서가 존재할 경우 업데이트
                    var dataToUpdate: [String: Any] = [:]
                    
                    if let email = user.email, !email.isEmpty {
                        dataToUpdate["email"] = email
                    }
                    if let displayName = user.displayName, !displayName.isEmpty {
                        dataToUpdate["displayName"] = displayName
                    }
                    if let photoURL = user.photoURL, !photoURL.isEmpty {
                        dataToUpdate["photoURL"] = photoURL
                    }
                    if let socialMediaLink = user.socialMediaLink, !socialMediaLink.isEmpty {
                        dataToUpdate["socialMediaLink"] = socialMediaLink
                    }
                    if let authProvider = user.authProvider {
                        dataToUpdate["authProvider"] = authProvider
                    }
                    
                    userRef.updateData(dataToUpdate) { error in
                        if let error = error {
                            print("Error updating user in Firestore: \(error)")
                            continuation.resume(throwing: error)
                        } else {
                            print("User updated in Firestore: \(user)")
                            continuation.resume(returning: ())
                        }
                    }
                } else {
                    // 기존 문서가 없을 경우 새로 생성
                    userRef.setData([
                        "uid": user.uid ?? "",
                        "email": user.email ?? "",
                        "displayName": user.displayName ?? "",
                        "photoURL": user.photoURL ?? "",
                        "socialMediaLink": user.socialMediaLink ?? "",
                        "authProvider": user.authProvider ?? ""
                    ]) { error in
                        if let error = error {
                            print("Error saving user to Firestore: \(error)")
                            continuation.resume(throwing: error)
                        } else {
                            print("User saved to Firestore: \(user)")
                            continuation.resume(returning: ())
                        }
                    }
                }
            }
        }
    }

    
//    // 참가자 불러오는 메서드
//    func fetchAttendee(for wordbookId: String) async throws -> [String] {
//        let snapshot = try await db.collection("wordbooks").document(wordbookId).getDocument()
//        guard let attendees = snapshot.data()?["attendees"] as? [String] else {
//            return [] // attendees 필드가 존재하지 않거나 올바르지 않은 형식인 경우 빈 배열 반환
//        }
//        return attendees
//    }
//    
//    // 참가자 추가
//    func addAttendee(to wordbookId: String, attendee: String) async throws -> Bool {
//        // 참가자 중복 확인
//        let attendees = try await fetchAttendee(for: wordbookId)
//        if attendees.contains(attendee) {
//            return false // 이미 단어가 존재함
//        }
//        
//        let updatedAttendees = attendees + [attendee]
//        
//        do {
//            try await db.collection("wordbooks").document(wordbookId).updateData(["attendees": updatedAttendees])
//            return true // 성공적으로 참가자를 추가함
//        } catch {
//            throw error
//        }
//    }
}

