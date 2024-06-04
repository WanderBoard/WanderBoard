//
//  Invitation.swift
//  WanderBoard
//
//  Created by David Jang on 5/30/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

enum InvitationStatus: String, Codable {
    case pending
    case accepted
    case declined
}

struct Invitation: Identifiable, Codable {
    @DocumentID var id: String?
    var pinLogId: String
    var inviterId: String
    var inviteeId: String
    var status: InvitationStatus
    var inviterProfileImage: String // 초대한 사람의 프로필 이미지 URL
    var pinLogTitle: String // PinLog 제목
    var invitationDate: Date // 초대 날짜
    
    init(id: String? = nil, pinLogId: String, inviterId: String, inviteeId: String, status: InvitationStatus, inviterProfileImage: String, pinLogTitle: String, invitationDate: Date) {
        self.id = id
        self.pinLogId = pinLogId
        self.inviterId = inviterId
        self.inviteeId = inviteeId
        self.status = status
        self.inviterProfileImage = inviterProfileImage
        self.pinLogTitle = pinLogTitle
        self.invitationDate = invitationDate
    }
}
