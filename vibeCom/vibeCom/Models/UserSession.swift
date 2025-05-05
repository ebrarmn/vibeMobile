import Foundation
import Combine

struct AppUser: Identifiable, Codable {
    let id: String
    let displayName: String
    let email: String
    let photoURL: String
    let role: String
    let clubIds: [String]
    let createdAt: Date?
    let updatedAt: Date?
}

class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var joinedClubs: [String] = [] // Kulüp ID'leri
    @Published var attendingEvents: [String] = [] // Etkinlik ID'leri
    @Published var userId: String = "user1"
    @Published var currentUser: AppUser? = nil // Giriş yapan kullanıcının tüm bilgileri
    
    private init() {}
    
    func joinClub(_ clubId: String) {
        if !joinedClubs.contains(clubId) {
            joinedClubs.append(clubId)
            // Kulüp katılımını kaydet
            saveUserData()
        }
    }
    
    func leaveClub(_ clubId: String) {
        joinedClubs.removeAll { $0 == clubId }
        // Kulüp ayrılmayı kaydet
        saveUserData()
    }
    
    func attendEvent(_ eventId: String) {
        if !attendingEvents.contains(eventId) {
            attendingEvents.append(eventId)
            // Etkinlik katılımını kaydet
            saveUserData()
        }
    }
    
    func leaveEvent(_ eventId: String) {
        attendingEvents.removeAll { $0 == eventId }
        // Etkinlik ayrılmayı kaydet
        saveUserData()
    }
    
    private func saveUserData() {
        // Kullanıcı verilerini kaydet
        // Burada gerçek bir API çağrısı yapılabilir
    }
} 