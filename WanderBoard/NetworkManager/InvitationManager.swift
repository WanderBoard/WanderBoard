//
//  InvitationManager.swift
//  WanderBoard
//
//  Created by David Jang on 5/31/24.
//

import Foundation
import CoreData
import FirebaseFirestore

class InvitationManager {
    private let db = Firestore.firestore()
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
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

    // 사용자 조회
    func fetchUser(byEmail email: String) async throws -> UserEntity? {
        return try await context.fetchUser(byEmail: email)
    }
    
    // 초대 생성
    func createInvitation(pinLogId: String, inviterId: String, inviteeEmail: String, inviterProfileImage: String, pinLogTitle: String) async throws {
        guard let invitee = try await fetchUser(byEmail: inviteeEmail) else {
            throw NSError(domain: "User not found", code: 404, userInfo: nil)
        }
        
        guard let inviteeId = invitee.uid else {
            throw NSError(domain: "User ID is nil", code: 500, userInfo: nil)
        }
        
        let invitation = Invitation(pinLogId: pinLogId, inviterId: inviterId, inviteeId: inviteeId, status: .pending, inviterProfileImage: inviterProfileImage, pinLogTitle: pinLogTitle, invitationDate: Date())
        
        let documentId = invitation.id ?? UUID().uuidString
        let documentRef = db.collection("invitations").document(documentId)
        
        let data: [String: Any] = [
            "pinLogId": invitation.pinLogId,
            "inviterId": invitation.inviterId,
            "inviteeId": invitation.inviteeId,
            "status": invitation.status.rawValue,
            "inviterProfileImage": invitation.inviterProfileImage,
            "pinLogTitle": invitation.pinLogTitle,
            "invitationDate": invitation.invitationDate
        ]
        
        try await saveDocument(documentRef: documentRef, data: data)
    }
    
    // 초대 상태 업데이트
    func updateInvitationStatus(invitationId: String, status: InvitationStatus) async throws {
        let documentRef = db.collection("invitations").document(invitationId)
        let data: [String: Any] = ["status": status.rawValue]
        try await updateDocument(documentRef: documentRef, data: data)
    }
    
    // 초대 조회
    func fetchInvitations(forUserId userId: String) async throws -> [Invitation] {
        let snapshot = try await db.collection("invitations").whereField("inviteeId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Invitation.self) }
    }
    
    // 사용자가 보낸 초대 조회
    func fetchSentInvitations(forUserId userId: String) async throws -> [Invitation] {
        let snapshot = try await db.collection("invitations").whereField("inviterId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Invitation.self) }
    }
}

extension NSManagedObjectContext {
    func fetchUser(byEmail email: String) async throws -> UserEntity? {
        let request: NSFetchRequest<UserEntity> = UserEntity.fetchRequest()
        request.predicate = NSPredicate(format: "email == %@", email)
        return try await withCheckedThrowingContinuation { continuation in
            self.perform {
                do {
                    let result = try self.fetch(request)
                    continuation.resume(returning: result.first)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

/*
 
 // 뷰컨에서 사용 메서드
 
 @MainActor
 class InvitationViewModel: ObservableObject {
     private let invitationManager: InvitationManager
     
     @Published var invitations: [Invitation] = []
     
     init(context: NSManagedObjectContext) {
         self.invitationManager = InvitationManager(context: context)
     }
     
     func loadInvitations(forUserId userId: String) async {
         do {
             let fetchedInvitations = try await invitationManager.fetchInvitations(forUserId: userId)
             invitations = fetchedInvitations
         } catch {
             ErrorUtility.shared.presentErrorAlert(with: "Error fetching invitations: \(error.localizedDescription)")
         }
     }
     
     func sendInvitation(pinLogId: String, inviterId: String, inviteeEmail: String, inviterProfileImage: String, pinLogTitle: String) async {
         do {
             try await invitationManager.createInvitation(pinLogId: pinLogId, inviterId: inviterId, inviteeEmail: inviteeEmail, inviterProfileImage: inviterProfileImage, pinLogTitle: pinLogTitle)
             print("Invitation sent successfully")
         } catch {
             ErrorUtility.shared.presentErrorAlert(with: "Error sending invitation: \(error.localizedDescription)")
         }
     }
     
     func updateInvitationStatus(invitationId: String, status: InvitationStatus) async {
         do {
             try await invitationManager.updateInvitationStatus(invitationId: invitationId, status: status)
             print("Invitation status updated successfully")
         } catch {
             ErrorUtility.shared.presentErrorAlert(with: "Error updating invitation status: \(error.localizedDescription)")
         }
     }
 }
 
 
 
 
 
 */
