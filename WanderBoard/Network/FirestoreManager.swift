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

    func saveUser(uid: String, email: String, displayName: String? = nil, photoURL: String? = nil, socialMediaLink: String? = nil, authProvider: String, gender: String = "선택안함", interests: [String] = [], isProfileComplete: Bool, blockedAuthors: [String], hiddenPinLogs:[String]) async throws {
        
        guard !email.isEmpty else {
            throw NSError(domain: "SaveUserError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email is empty. Cannot save user data."])
        }
        
        let userRef = db.collection("users").document(uid)
        
        var dataToSave: [String: Any] = [
            "uid": uid,
            "email": email,
            "authProvider": authProvider,
            "isProfileComplete": isProfileComplete,
            "blockedAuthors": blockedAuthors,
            "hiddenPinLogs" : hiddenPinLogs
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
        dataToUpdate["joinedDate"] = FieldValue.serverTimestamp()  // 가입일 설정

        if document.exists {
            try await userRef.updateData(dataToUpdate)
        } else {
            dataToUpdate["blockedAuthors"] = []
            dataToUpdate["hiddenPinLogs"] = []
            try await userRef.setData(dataToUpdate, merge: true)
        }
    }
    

    // 유저 동의 상태 저장 메서드
    func updateUserConsent(uid: String, agreedToTerms: Bool, agreedToPrivacyPolicy: Bool, agreedToMarketing: Bool?, agreedToThirdParty: Bool?) async throws {
        let userRef = db.collection("users").document(uid)
        var dataToUpdate: [String: Any] = [
            "agreedToTerms": agreedToTerms,
            "agreedToPrivacyPolicy": agreedToPrivacyPolicy
        ]
        if let agreedToMarketing = agreedToMarketing {
            dataToUpdate["agreedToMarketing"] = agreedToMarketing
        }
        if let agreedToThirdParty = agreedToThirdParty {
            dataToUpdate["agreedToThirdParty"] = agreedToThirdParty
        }
        try await userRef.updateData(dataToUpdate)
    }

    // 이메일 가져오기 애플을 위해서...;
    private func fetchEmailFromFirestore(uid: String) async throws -> String? {
        let userRef = Firestore.firestore().collection("users").document(uid)
        let document = try await userRef.getDocument()
        let email = document.data()?["email"] as? String
        return email

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
    //내가 태그된 게시글 수를 가져오기
    func fetchInvitations(for userId: String, completion: @escaping (Result<[Invitation], Error>) -> Void) {
           db.collection("invitations")
               .whereField("inviteeId", isEqualTo: userId)
               .whereField("status", isEqualTo: InvitationStatus.accepted.rawValue)
               .getDocuments { snapshot, error in
                   if let error = error {
                       completion(.failure(error))
                   } else {
                       let invitations = snapshot?.documents.compactMap { document -> Invitation? in
                           return try? document.data(as: Invitation.self)
                       } ?? []
                       completion(.success(invitations))
                   }
               }
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
    
    // 게시물 숨기기
    func hidePinLog(userId: String, pinLogId: String) async throws {
        let userRef = db.collection("users").document(userId)
        try await userRef.updateData(["hiddenPinLogs": FieldValue.arrayUnion([pinLogId])])
    }

    // 숨긴 게시물 목록 가져오기
    func getHiddenPinLogs(userId: String) async throws -> [String] {
        let userRef = db.collection("users").document(userId)
        let document = try await userRef.getDocument()
        if let data = document.data(), let hiddenPinLogs = data["hiddenPinLogs"] as? [String] {
            return hiddenPinLogs
        }
        return []
    }

    
    //프로필 사진 가져오기
    func fetchUserProfileImageURL(userId: String, completion: @escaping (String?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let photoURL = data?["photoURL"] as? String
                completion(photoURL)
            } else {
                completion(nil)
            }
        }
    }
    
    func fetchUserDisplayName(userId: String, completion: @escaping (String?) -> Void) {
        let userRef = db.collection("users").document(userId)
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let displayName = data?["displayName"] as? String
                completion(displayName)
            } else {
                completion(nil)
            }
        }
    }
    
    // 사용자의 데이터를 Firestore에서 삭제하는 함수 (회원 탈퇴)
    func deleteUserData(uid: String) async throws {
        let userRef = db.collection("users").document(uid)
        try await userRef.delete()
    }
}
