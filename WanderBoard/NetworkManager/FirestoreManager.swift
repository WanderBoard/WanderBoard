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
    
    func checkUserExistsByUID(uid: String) async throws -> User? {
        let documentSnapshot = try await db.collection("users").document(uid).getDocument()
        return try? documentSnapshot.data(as: User.self)
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
    func fetchEmailFromFirestore(uid: String) async throws -> String? {
        let userRef = Firestore.firestore().collection("users").document(uid)
        let document = try await userRef.getDocument()
        guard let data = document.data(), let email = data["email"] as? String, !email.isEmpty else {
            return nil
        }
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
    
    func getUserSummary(userId: String) async throws -> BlockedUserSummary? {
        let document = try await Firestore.firestore().collection("users").document(userId).getDocument()
        guard let data = document.data() else { return nil }
        return BlockedUserSummary(uid: userId, email: data["email"] as? String ?? "", displayName: data["displayName"] as? String ?? "", photoURL: data["photoURL"] as? String, isBlocked: true)
    }
    
    func unblockAuthor(userId: String, authorId: String) async throws {
        let userRef = Firestore.firestore().collection("users").document(userId)
        try await userRef.updateData([
            "blockedAuthors": FieldValue.arrayRemove([authorId])
        ])
    }

    // 사용자가 차단한 작성자 목록을 가져오는 함수
    func getBlockedAuthors(userId: String) async throws -> [String] {
        let document = try await Firestore.firestore().collection("users").document(userId).getDocument()
        let blockedAuthors = document.data()?["blockedAuthors"] as? [String] ?? []
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
    
    // 프로필 사진 URL 가져오기
    func fetchUserProfileImageURL(userId: String) async throws -> String? {
        let userRef = db.collection("users").document(userId)
        let document = try await userRef.getDocument()
        return document.data()?["photoURL"] as? String
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

    func fetchExpenses(for pinLogId: String) async throws -> [DailyExpenses] {
        let documentRef = db.collection("pinLogs").document(pinLogId)
        let documentSnapshot = try await documentRef.getDocument()
        
        guard let data = documentSnapshot.data(), let expensesData = data["expenses"] as? [[String: Any]] else {
            return []
        }

        return parseExpenses(expensesData)
    }

    private func parseExpenses(_ expensesData: [[String: Any]]) -> [DailyExpenses] {
        var dailyExpenses: [DailyExpenses] = []

        for data in expensesData {
            guard let timestamp = data["date"] as? Timestamp,
                  let expenseItems = data["expenses"] as? [[String: Any]] else { continue }

            let date = timestamp.dateValue()
            var expenses: [Expense] = []

            for expenseItem in expenseItems {
                let expenseContent = expenseItem["expenseContent"] as? String ?? ""
                let expenseAmount = expenseItem["expenseAmount"] as? Int ?? 0
                let category = expenseItem["category"] as? String ?? ""
                let memo = expenseItem["memo"] as? String ?? ""
                let imageName = expenseItem["imageName"] as? String ?? ""
                let id = expenseItem["id"] as? String

                let expense = Expense(
                    id: id,
                    date: date,
                    expenseContent: expenseContent,
                    expenseAmount: expenseAmount,
                    category: category,
                    memo: memo,
                    imageName: imageName
                )
                expenses.append(expense)
            }

            let dailyExpense = DailyExpenses(date: date, expenses: expenses)
            dailyExpenses.append(dailyExpense)
        }

        return dailyExpenses
    }
    
    func saveExpense(pinLogId: String, expense: inout Expense) async throws {
        let pinLogRef = db.collection("pinLogs").document(pinLogId)
        
        if expense.id == nil || expense.id!.isEmpty {
            expense.id = UUID().uuidString
        }

        let expenseData: [String: Any] = [
            "id": expense.id ?? "",
            "date": Timestamp(date: expense.date),
            "expenseContent": expense.expenseContent,
            "expenseAmount": expense.expenseAmount,
            "category": expense.category,
            "memo": expense.memo,
            "imageName": expense.imageName
        ]

        let snapshot = try await pinLogRef.getDocument()
        guard var pinLogData = snapshot.data() else {
            throw NSError(domain: "SaveExpenseError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Pin log not found."])
        }
        
        var dailyExpenses = pinLogData["expenses"] as? [[String: Any]] ?? []
        var dateExists = false
        
        for i in 0..<dailyExpenses.count {
            if let date = (dailyExpenses[i]["date"] as? Timestamp)?.dateValue(), Calendar.current.isDate(date, inSameDayAs: expense.date) {
                var expenses = dailyExpenses[i]["expenses"] as? [[String: Any]] ?? []
                expenses.append(expenseData)
                dailyExpenses[i]["expenses"] = expenses
                dateExists = true
                break
            }
        }
        
        if !dateExists {
            dailyExpenses.append([
                "date": Timestamp(date: expense.date),
                "expenses": [expenseData]
            ])
        }
        
        pinLogData["expenses"] = dailyExpenses
        
        try await pinLogRef.setData(pinLogData)
    }

    func deleteExpense(pinLogId: String, expense: Expense) async throws {
        let pinLogRef = db.collection("pinLogs").document(pinLogId)
        
        guard let expenseId = expense.id else {
            return
        }

        let snapshot = try await pinLogRef.getDocument()
        guard var pinLogData = snapshot.data() else {
            return
        }
                
        if var dailyExpenses = pinLogData["expenses"] as? [[String: Any]] {
            var found = false

            for i in 0..<dailyExpenses.count {
                if let expensesList = dailyExpenses[i]["expenses"] as? [[String: Any]] {
                    if let expenseIndex = expensesList.firstIndex(where: { $0["id"] as? String == expenseId }) {
                        var updatedExpenses = expensesList
                        updatedExpenses.remove(at: expenseIndex)
                        dailyExpenses[i]["expenses"] = updatedExpenses
                        if updatedExpenses.isEmpty {
                            dailyExpenses.remove(at: i)
                        }
                        found = true
                        break
                    }
                }
            }

            if found {
                pinLogData["expenses"] = dailyExpenses
                try await pinLogRef.setData(pinLogData)
                print("Expense deleted from Firestore.")
            } else {
                print("No matching expense found in Firestore.")
            }
        } else {
            print("Expenses field not found in Firestore.")
        }
    }

    func dictionariesAreEqual(_ lhs: [String: Any], _ rhs: [String: Any]) -> Bool {
        return NSDictionary(dictionary: lhs).isEqual(to: rhs)
    }
}
