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
        print("Saving user data to Firestore: \(dataToSave)")
        
        try await userRef.setData(dataToSave, merge: true)
    }

    func saveOrUpdateUser(user: UserEntity) async throws {
        let userRef = db.collection("users").document(user.uid ?? "")
        
        let document = try await userRef.getDocument()
        
        if document.exists {
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
            
            try await userRef.updateData(dataToUpdate)
            print("User updated in Firestore: \(user)")
        } else {
            let data: [String: Any] = [
                "uid": user.uid ?? "",
                "email": user.email ?? "",
                "displayName": user.displayName ?? "",
                "photoURL": user.photoURL ?? "",
                "socialMediaLink": user.socialMediaLink ?? "",
                "authProvider": user.authProvider ?? ""
            ]
            try await userRef.setData(data)
            print("User saved to Firestore: \(user)")
        }
    }

    func createPinLog(location: String, startDate: Date, endDate: Date, title: String, content: String, media: [Media], authorId: String, attendeeIds: [String], isPublic: Bool) async throws {
        let pinLog = PinLog(location: location, startDate: startDate, endDate: endDate, title: title, content: content, media: media, authorId: authorId, attendeeIds: attendeeIds, isPublic: isPublic)

        let documentId = pinLog.id ?? UUID().uuidString
        let documentRef = db.collection("pinLogs").document(documentId)

        let mediaData = media.map { mediaItem -> [String: Any] in
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

        try await documentRef.setData(data)
    }

    func fetchPinLogs(forUserId userId: String) async throws -> [PinLog] {
        let snapshot = try await db.collection("pinLogs").whereField("authorId", isEqualTo: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: PinLog.self) }
    }
}

