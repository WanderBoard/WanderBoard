//
//  UserProfileManager.swift
//  WanderBoard
//
//  Created by David Jang on 6/7/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class UserProfileManager {
    static let shared = UserProfileManager()
    
    private init() { }
    
    func updateUserProfileFromFirestore() async throws {
        guard let currentUser = Auth.auth().currentUser else {
            throw NSError(domain: "UserProfileManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current user is logged in"])
        }
        
        let uid = currentUser.uid
        let document = try await Firestore.firestore().collection("users").document(uid).getDocument()
        
        guard document.data() != nil else {
            throw NSError(domain: "UserProfileManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user data from Firestore"])
        }
    }
    
}
