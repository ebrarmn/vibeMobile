import Foundation
import Combine

class UserSession: ObservableObject {
    static let shared = UserSession()
    
    @Published var joinedClubs: [String] = [] // Kulüp ID'leri
    @Published var attendingEvents: [String] = [] // Etkinlik ID'leri
    @Published var userId: String = "user1"
    
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