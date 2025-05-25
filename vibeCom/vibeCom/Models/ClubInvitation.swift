import Foundation

struct ClubInvitation: Identifiable, Codable {
    let id: String
    let clubId: String
    let clubName: String
    let senderId: String
    let senderName: String
    let receiverId: String
    let status: InvitationStatus
    let createdAt: Date
    
    enum InvitationStatus: String, Codable {
        case pending
        case accepted
        case rejected
    }
} 