//
//  MateManager.swift
//  WanderBoard
//
//  Created by 김시종 on 6/13/24.
//

import Foundation
import FirebaseFirestore

class MateManager {
    static let shared = MateManager()
    
    private init() { }
    
    func fetchUserSummaries(completion: @escaping (Result<[UserSummary], Error>) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let userSummaries: [UserSummary] = snapshot?.documents.compactMap { document in
                let data = document.data()
                let uid = data["uid"] as? String ?? ""
                let email = data["email"] as? String ?? ""
                let displayName = data["displayName"] as? String
                let photoURL = data["photoURL"] as? String
                let isMate = data["isMate"] as? Bool ?? false
                
                // 아이디와 닉네임이 둘 다 존재할 때만 UserSummary 객체를 생성합니다.
                if !uid.isEmpty, let displayName = displayName, !displayName.isEmpty {
                    return UserSummary(uid: uid, email: email, displayName: displayName, photoURL: photoURL, isMate: isMate)
                } else {
                    return nil
                }
            } ?? []
            
            completion(.success(userSummaries))
        }
    }
}

