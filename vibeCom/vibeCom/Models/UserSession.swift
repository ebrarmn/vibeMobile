import Foundation
import Combine
import FirebaseFirestore

struct AppUser: Identifiable, Codable {
    let id: String
    let displayName: String
    let email: String
    var photoURL: String
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
            
            // Firebase'e kulüp üyeliğini kaydet
            if let userId = currentUser?.id {
                let db = Firestore.firestore()
                
                // Kullanıcının kulüp listesini güncelle
                db.collection("users").document(userId).updateData([
                    "clubIds": FieldValue.arrayUnion([clubId])
                ])
                
                // Kulübün üye listesini güncelle
                db.collection("clubs").document(clubId).updateData([
                    "memberIds": FieldValue.arrayUnion([userId])
                ])
            }
        }
    }
    
    func leaveClub(_ clubId: String) {
        if joinedClubs.contains(clubId) {
        joinedClubs.removeAll { $0 == clubId }
            
            // Firebase'den kulüp üyeliğini kaldır
            if let userId = currentUser?.id {
                let db = Firestore.firestore()
                
                // Kullanıcının kulüp listesini güncelle
                db.collection("users").document(userId).updateData([
                    "clubIds": FieldValue.arrayRemove([clubId])
                ])
                
                // Kulübün üye listesini güncelle
                db.collection("clubs").document(clubId).updateData([
                    "memberIds": FieldValue.arrayRemove([userId])
                ])
            }
        }
    }
    
    func attendEvent(_ eventId: String) {
        if !attendingEvents.contains(eventId) {
            attendingEvents.append(eventId)
            if let userId = currentUser?.id {
                let db = Firestore.firestore()
                db.collection("users").document(userId).updateData([
                    "attendingEvents": FieldValue.arrayUnion([eventId])
                ])
            }
            saveUserData()
        }
    }
    
    func leaveEvent(_ eventId: String) {
        attendingEvents.removeAll { $0 == eventId }
        if let userId = currentUser?.id {
            let db = Firestore.firestore()
            db.collection("users").document(userId).updateData([
                "attendingEvents": FieldValue.arrayRemove([eventId])
            ])
        }
        saveUserData()
    }
    
    private func saveUserData() {
        // Kullanıcı verilerini kaydet
        // Burada gerçek bir API çağrısı yapılabilir
    }
    
    func fetchUserDataFromFirestore() {
        guard let userId = currentUser?.id else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                let clubIds = data["clubIds"] as? [String] ?? []
                DispatchQueue.main.async {
                    // Profil bilgileri
                    let appUser = AppUser(
                        id: userId,
                        displayName: data["displayName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        photoURL: data["photoURL"] as? String ?? "",
                        role: data["role"] as? String ?? "user",
                        clubIds: clubIds,
                        createdAt: nil,
                        updatedAt: nil
                    )
                    self.currentUser = appUser
                    // Katıldığı kulüpler
                    self.joinedClubs = clubIds
                    // Katıldığı etkinlikler
                    self.attendingEvents = data["attendingEvents"] as? [String] ?? []
                }
            }
        }
    }
} 
