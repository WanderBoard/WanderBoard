//
//  AccountDeletionManager.swift
//  WanderBoard
//
//  Created by Luz on 6/15/24.
//

import Foundation
import FirebaseAuth
import CoreData
import FirebaseFirestore
import FirebaseFirestoreSwift

final class AccountDeletionManager {
    static let shared = AccountDeletionManager()
    private let db = Firestore.firestore()
    private init() { }

//    // 사용자 데이터를 Firestore에서 삭제하는 함수
//    func deleteUserData(uid: String) async throws {
//        try await FirestoreManager.shared.deleteUserData(uid: uid)
//    }
    
    // 사용자의 데이터를 Firestore에서 삭제하는 함수 (회원 탈퇴)
    func deleteUserData(uid: String) async throws {
        let userRef = db.collection("users").document(uid)
        try await userRef.delete()
    }
    
    // 회원 탈퇴 시 특정 사용자의 모든 PinLog 데이터를 삭제하는 함수
    func deletePinLogsForUser(userId: String) async throws {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        for document in snapshot.documents {
            try await document.reference.delete()
        }
    }

//    func deleteUserFromCoreData(userId: String, context: NSManagedObjectContext) throws {
//        try CoreDataManager.shared.deleteUserFromCoreData(userId: userId, context: context)
//    }
    
    // Core Data에서 사용자 데이터를 삭제하는 함수
    func deleteUserFromCoreData(userId: String, context: NSManagedObjectContext) throws {
        let fetchRequest: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "uid == %@", userId)

        do {
            let users = try context.fetch(fetchRequest)
            for user in users {
                context.delete(user)
            }
            try context.save()
        } catch {
            throw error
        }
    }

    // Firebase Authentication에서 사용자 계정을 삭제하는 함수
    func deleteUserAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "사용자가 로그인 되어있지 않습니다"])
        }
        try await user.delete()
    }

    // 전체 사용자 데이터 삭제 함수
    func deleteUser(uid: String, context: NSManagedObjectContext) async throws {
        do {
            try await deleteUserData(uid: uid)
            try await deletePinLogsForUser(userId: uid)
            try deleteUserFromCoreData(userId: uid, context: context)
            try await deleteUserAccount()
            print("회원 탈퇴 성공")
        } catch {
            print("회원 탈퇴 실패: \(error.localizedDescription)")
            throw error
        }
    }
}
