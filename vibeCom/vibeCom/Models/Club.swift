import Foundation

struct Club: Identifiable {
    let id: String
    let name: String
    let description: String
    let logoURL: String
    let members: [String]
    let events: [String]
    let socialMedia: [String: String]
    let leaderID: String
    var isActive: Bool
    
    var isLeader: Bool {
        // Bu computed property, kullanıcının kulüp lideri olup olmadığını kontrol edecek
        // UserSession.shared.currentUser?.id ile karşılaştırılacak
        return leaderID == UserSession.shared.currentUser?.id
    }
} 