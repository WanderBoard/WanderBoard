//
//  FirestoreManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/28/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirestoreManager {
    static let shared = FirestoreManager()
    private init() { }

    private let db = Firestore.firestore()
    
    func checkUserExists(email: String) async throws -> User? {
        let querySnapshot = try await db.collection("users").whereField("email", isEqualTo: email).getDocuments()
        if let document = querySnapshot.documents.first {
            return try? document.data(as: User.self)
        }
        return nil
    }
    
    // displayName 중복 검증 메서드
    func checkDisplayNameExists(displayName: String) async throws -> Bool {
        let querySnapshot = try await db.collection("users").whereField("displayName", isEqualTo: displayName).getDocuments()
        return !querySnapshot.documents.isEmpty
    }

    func saveUser(uid: String, email: String, displayName: String? = nil, photoURL: String? = nil, socialMediaLink: String? = nil, authProvider: String, gender: String = "선택안함", interests: [String] = [], isProfileComplete: Bool) async throws {
        
        guard !email.isEmpty else {
            throw NSError(domain: "SaveUserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email is empty. Cannot save user data."])
        }
        
        let userRef = db.collection("users").document(uid)
        
        var dataToSave: [String: Any] = [
            "uid": uid,
            "email": email,
            "authProvider": authProvider,
            "isProfileComplete": isProfileComplete,
            "blockedAuthors": [] // 초기값 설정
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
        if !interests.isEmpty {
            dataToSave["interests"] = interests
        }
        
        let document = try await userRef.getDocument()
        if document.exists {
            // 기존 문서 업데이트
            let existingData = document.data() ?? [:]
            if existingData["gender"] == nil || existingData["gender"] as? String == "선택안함" {
                dataToSave["gender"] = gender
            }
            try await userRef.updateData(dataToSave)
        } else {
            // 새 문서 생성
            dataToSave["gender"] = gender
            try await userRef.setData(dataToSave, merge: true)
        }
    }

    func saveOrUpdateUser(user: UserEntity) async throws {
        let userRef = db.collection("users").document(user.uid ?? "")
        let document = try await userRef.getDocument()

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
        if let gender = user.gender {
            dataToUpdate["gender"] = gender
        }
        if let interests = user.interests {
            dataToUpdate["interests"] = interests
        }

        dataToUpdate["isProfileComplete"] = user.isProfileComplete

        if document.exists {
            try await userRef.updateData(dataToUpdate)
        } else {
            dataToUpdate["blockedAuthors"] = [] // 차단 배열 초기값 설정
            try await userRef.setData(dataToUpdate, merge: true)
        }
    }
    //내가 핀 얼만큼 찍었는가 계산
    func fetchUserPinCount(userId: String) async throws -> Int {
        let pinLogRef = db.collection("pinLogs")
        let querySnapshot = try await pinLogRef.whereField("pinnedBy", arrayContains: userId).getDocuments()
        return querySnapshot.documents.count
    }
    //핀 찍을때마다 정보 업데이트
    func updateUserPinCount(userId: String, pinCount: Int) async throws {
        let userRef = db.collection("users").document(userId)
        try await userRef.updateData(["totalPins": pinCount])
    }
    
    // 이메일 가져오기 애플을 위해서...;
    private func fetchEmailFromFirestore(uid: String) async throws -> String? {
        let userRef = Firestore.firestore().collection("users").document(uid)
        let document = try await userRef.getDocument()
        let email = document.data()?["email"] as? String
        return email
    }
    
    // 사용자가 차단한 작성자 목록을 업데이트하는 함수
    func blockAuthor(userId: String, authorId: String) async throws {
        let userRef = db.collection("users").document(userId)
        try await userRef.updateData(["blockedAuthors": FieldValue.arrayUnion([authorId])])
    }

    // 사용자가 차단한 작성자 목록을 가져오는 함수
    func getBlockedAuthors(userId: String) async throws -> [String] {
        let userRef = db.collection("users").document(userId)
        let document = try await userRef.getDocument()
        guard let data = document.data(), let blockedAuthors = data["blockedAuthors"] as? [String] else {
            return []
        }
        return blockedAuthors
    }
}

