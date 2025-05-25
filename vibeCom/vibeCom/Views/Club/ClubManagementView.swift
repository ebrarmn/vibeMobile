import SwiftUI
import FirebaseFirestore
import Foundation
import Combine

class EventManager: ObservableObject {
    @Published var events: [Event] = []
    private var listener: ListenerRegistration?
    private let clubId: String
    
    init(clubId: String) {
        self.clubId = clubId
        startListening()
    }
    
    func startListening() {
        let db = Firestore.firestore()
        listener = db.collection("events")
            .whereField("clubId", isEqualTo: clubId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else {
                    print("Etkinlikler dinlenirken hata oluştu: \(error?.localizedDescription ?? "")")
                    return
                }
                
                self?.events = documents.compactMap { doc -> Event? in
                    let data = doc.data()
                    guard let title = data["title"] as? String,
                          let description = data["description"] as? String,
                          let startDate = (data["startDate"] as? Timestamp)?.dateValue(),
                          let endDate = (data["endDate"] as? Timestamp)?.dateValue(),
                          let location = data["location"] as? String,
                          let categoryString = data["category"] as? String,
                          let category = EventCategory(rawValue: categoryString) else {
                        return nil
                    }
                    
                    return Event(
                        id: doc.documentID,
                        title: title,
                        description: description,
                        startDate: startDate,
                        endDate: endDate,
                        location: location,
                        clubId: self?.clubId ?? "",
                        imageURL: data["imageURL"] as? String ?? "",
                        attendees: data["attendees"] as? [String] ?? [],
                        category: category
                    )
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
    }
    
    deinit {
        stopListening()
    }
}

struct ClubManagementView: View {
    @State private var club: Club
    @StateObject private var eventManager: EventManager
    @State private var showingClubEdit = false
    @State private var newEventName = ""
    @State private var newEventDescription = ""
    @State private var newEventDate = Date()
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    @State private var users: [AppUser] = []
    @State private var invitations: [ClubInvitation] = []
    @State private var showingUserList = false
    @State private var clubMembers: [AppUser] = []
    @State private var showRemoveAlert: Bool = false
    @State private var memberToRemove: AppUser? = nil
    @State private var eventTitles: [String] = []
    @State private var selectedEventId: String? = nil
    @State private var showEditEventSheet: Bool = false
    @State private var showDeleteEventAlert: Bool = false
    @State private var eventIdToDelete: String? = nil
    @State private var eventTitleToDelete: String = ""
    @State private var showCreateEventSheet: Bool = false
    
    init(club: Club) {
        _club = State(initialValue: club)
        _eventManager = StateObject(wrappedValue: EventManager(clubId: club.id))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Kulüp Bilgileri")) {
                    HStack {
                        Text("Kulüp Adı:")
                        Spacer()
                        Text(club.name)
                    }
                    HStack {
                        Text("Açıklama:")
                        Spacer()
                        Text(club.description)
                    }
                    Button(action: {
                        showingClubEdit = true
                    }) {
                        Text("Kulüp Bilgilerini Düzenle")
                            .foregroundColor(.blue)
                    }
                    if UserSession.shared.currentUser?.id == club.leaderID {
                        Button(role: .destructive, action: {
                            showingDeleteAlert = true
                        }) {
                            Text("Kulübü Dağıt")
                                .foregroundColor(.red)
                        }
                        .disabled(isDeleting)
                    }
                }
                if UserSession.shared.currentUser?.id == club.leaderID {
                    Section(header: Text("Üye Yönetimi")) {
                        Button(action: {
                            showingUserList = true
                            loadUsers()
                        }) {
                            Text("Kullanıcıları Davet Et")
                                .foregroundColor(.blue)
                        }
                        ForEach(invitations.filter { $0.status == .pending }, id: \.id) { invitation in
                            InvitationCardView(invitation: invitation) {
                                cancelInvitation(invitation)
                            }
                        }
                    }
                }
                if UserSession.shared.currentUser?.id == club.leaderID {
                    Section(header: Text("Üyeler")) {
                        if clubMembers.isEmpty {
                            Text("Henüz üye yok.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(clubMembers) { user in
                                MemberCardView(
                                    user: user,
                                    showRemove: user.id != club.leaderID,
                                    onRemove: user.id != club.leaderID ? { memberToRemove = user; showRemoveAlert = true } : nil
                                )
                            }
                        }
                    }
                }
                Section(header: Text("Etkinlikler")) {
                    if UserSession.shared.currentUser?.id == club.leaderID {
                        Button(action: {
                            showCreateEventSheet = true
                        }) {
                            Label("Yeni Etkinlik Ekle", systemImage: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    
                    if eventManager.events.isEmpty {
                        Text("Henüz etkinlik yok")
                            .foregroundColor(.gray)
                            .italic()
                    } else {
                        ForEach(eventManager.events) { event in
                            EventRowView(event: event) {
                                if UserSession.shared.currentUser?.id == club.leaderID {
                                    selectedEventId = event.id
                                    showEditEventSheet = true
                                }
                            } onDelete: {
                                if UserSession.shared.currentUser?.id == club.leaderID {
                                    showDeleteAlert(eventId: event.id, eventTitle: event.title)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kulüp Yönetimi")
            .sheet(isPresented: $showingClubEdit) {
                ClubEditView(club: club)
            }
            .sheet(isPresented: $showingUserList) {
                UserInviteListView(club: club, users: users) { user in
                    sendInvitation(to: user)
                }
            }
            .sheet(isPresented: $showEditEventSheet) {
                if let eventId = selectedEventId {
                    EventEditView(eventId: eventId, onSave: {
                        loadEventTitles()
                        showEditEventSheet = false
                    })
                }
            }
            .sheet(isPresented: $showCreateEventSheet) {
                EventCreateView(clubId: club.id, onSave: {
                    loadEventTitles()
                    showCreateEventSheet = false
                })
            }
            .alert("Kulübü silmek istediğinizden emin misiniz?", isPresented: $showingDeleteAlert) {
                Button("İptal", role: .cancel) {}
                Button("Evet, Sil", role: .destructive) {
                    deleteClubAndEvents(club: club)
                }
            } message: {
                Text("Bu işlem geri alınamaz. Kulüp ve tüm etkinlikleri silinecek.")
            }
            .alert(isPresented: $showRemoveAlert) {
                Alert(
                    title: Text("Üyeyi Çıkar"),
                    message: Text("\(memberToRemove?.displayName ?? "") adlı üyeyi çıkarmak istiyor musunuz?"),
                    primaryButton: .destructive(Text("Çıkar")) {
                        if let user = memberToRemove {
                            removeMember(user)
                        }
                        memberToRemove = nil
                    },
                    secondaryButton: .cancel {
                        memberToRemove = nil
                    }
                )
            }
            .alert(isPresented: $showDeleteEventAlert) {
                Alert(
                    title: Text("Etkinliği Sil"),
                    message: Text("\(eventTitleToDelete) etkinliğini silmek istediğinize emin misiniz?"),
                    primaryButton: .destructive(Text("Sil")) {
                        if let eventId = eventIdToDelete {
                            cancelEvent(eventId: eventId)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                loadInvitations()
                loadClubMembers()
                loadEventTitles()
            }
        }
    }
    
    private func loadUsers() {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("role", isNotEqualTo: "admin")
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    users = documents.compactMap { doc in
                        let data = doc.data()
                        return AppUser(
                            id: doc.documentID,
                            displayName: data["displayName"] as? String ?? "",
                            email: data["email"] as? String ?? "",
                            photoURL: data["photoURL"] as? String ?? "",
                            role: data["role"] as? String ?? "user",
                            clubIds: data["clubIds"] as? [String] ?? [],
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                            updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                        )
                    }
                }
            }
    }
    private func loadInvitations() {
        let db = Firestore.firestore()
        db.collection("clubInvitations")
            .whereField("clubId", isEqualTo: club.id)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    invitations = documents.compactMap { doc in
                        let data = doc.data()
                        return ClubInvitation(
                            id: doc.documentID,
                            clubId: data["clubId"] as? String ?? "",
                            clubName: data["clubName"] as? String ?? "",
                            senderId: data["senderId"] as? String ?? "",
                            senderName: data["senderName"] as? String ?? "",
                            receiverId: data["receiverId"] as? String ?? "",
                            status: ClubInvitation.InvitationStatus(rawValue: data["status"] as? String ?? "") ?? .pending,
                            createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
                        )
                    }
                }
            }
    }
    private func loadClubMembers() {
        let db = Firestore.firestore()
        let memberIds = club.members
        guard !memberIds.isEmpty else {
            clubMembers = []
            return
        }
        db.collection("users").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                clubMembers = documents.compactMap { doc in
                    guard memberIds.contains(doc.documentID) else { return nil }
                    let data = doc.data()
                    return AppUser(
                        id: doc.documentID,
                        displayName: data["displayName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        photoURL: data["photoURL"] as? String ?? "",
                        role: data["role"] as? String ?? "user",
                        clubIds: data["clubIds"] as? [String] ?? [],
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                    )
                }
            }
        }
    }
    private func sendInvitation(to user: AppUser) {
        let db = Firestore.firestore()
        let invitation = ClubInvitation(
            id: UUID().uuidString,
            clubId: club.id,
            clubName: club.name,
            senderId: UserSession.shared.currentUser?.id ?? "",
            senderName: UserSession.shared.currentUser?.displayName ?? "",
            receiverId: user.id,
            status: .pending,
            createdAt: Date()
        )
        db.collection("clubInvitations").document(invitation.id).setData([
            "clubId": invitation.clubId,
            "clubName": invitation.clubName,
            "senderId": invitation.senderId,
            "senderName": invitation.senderName,
            "receiverId": invitation.receiverId,
            "status": invitation.status.rawValue,
            "createdAt": Timestamp(date: invitation.createdAt)
        ]) { error in
            if error == nil {
                invitations.append(invitation)
            }
        }
    }
    private func cancelInvitation(_ invitation: ClubInvitation) {
        let db = Firestore.firestore()
        db.collection("clubInvitations").document(invitation.id).delete { error in
            if error == nil {
                invitations.removeAll { $0.id == invitation.id }
            }
        }
    }
    private func removeMember(_ user: AppUser) {
        let db = Firestore.firestore()
        db.collection("clubs").document(club.id).updateData([
            "memberIds": FieldValue.arrayRemove([user.id])
        ]) { error in
            if error == nil {
                clubMembers.removeAll { $0.id == user.id }
            }
        }
        db.collection("users").document(user.id).updateData([
            "clubIds": FieldValue.arrayRemove([club.id])
        ])
    }
    private func deleteClubAndEvents(club: Club) {
        isDeleting = true
        let db: Firestore = Firestore.firestore()
        // Önce kulübe ait etkinlikleri sil
        let eventIds: [String] = club.events
        let group = DispatchGroup()
        for eventId in eventIds {
            group.enter()
            db.collection("events").document(eventId).delete { _ in
                group.leave()
            }
        }
        group.notify(queue: .main) {
            // Sonra kulübü sil
            db.collection("clubs").document(club.id).delete { _ in
                isDeleting = false
                // İsteğe bağlı: Kullanıcıyı ana ekrana yönlendirebilirsin
            }
        }
    }
    private func loadEventTitles() {
        let db = Firestore.firestore()
        eventTitles = []
        let eventIds = club.events
        guard !eventIds.isEmpty else { return }
        db.collection("events").whereField(FieldPath.documentID(), in: eventIds).getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                // ID sırasını korumak için titles'ı eventIds sırasına göre diziyoruz
                var titlesDict: [String: String] = [:]
                for doc in documents {
                    if let title = doc.data()["title"] as? String {
                        titlesDict[doc.documentID] = title
                    }
                }
                let titles = eventIds.compactMap { titlesDict[$0] }
                DispatchQueue.main.async {
                    self.eventTitles = titles
                }
            }
        }
    }
    private func cancelEvent(eventId: String) {
        let db = Firestore.firestore()
        db.collection("events").document(eventId).delete { error in
            if error == nil {
                // Firestore'da kulübün eventIds listesinden de sil
                db.collection("clubs").document(club.id).updateData([
                    "eventIds": FieldValue.arrayRemove([eventId])
                ]) { _ in
                    loadEventTitles()
                }
            }
        }
    }
    private func showDeleteAlert(eventId: String, eventTitle: String) {
        eventIdToDelete = eventId
        eventTitleToDelete = eventTitle
        showDeleteEventAlert = true
    }
}

struct EventEditView: View {
    let eventId: String
    var onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var eventDate: Date = Date()
    @State private var isLoading = false
    var body: some View {
        NavigationView {
            Form {
                TextField("Etkinlik Adı", text: $eventName)
                TextField("Etkinlik Açıklaması", text: $eventDescription)
                DatePicker("Tarih", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                Button("Kaydet") {
                    updateEvent()
                }
                .disabled(eventName.isEmpty || eventDescription.isEmpty || isLoading)
            }
            .navigationTitle("Etkinlik Güncelle")
            .navigationBarItems(trailing: Button("İptal") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear(perform: loadEvent)
        }
    }
    private func loadEvent() {
        let db = Firestore.firestore()
        db.collection("events").document(eventId).getDocument { snapshot, error in
            if let data = snapshot?.data() {
                eventName = data["title"] as? String ?? ""
                eventDescription = data["description"] as? String ?? ""
                if let ts = data["startDate"] as? Timestamp {
                    eventDate = ts.dateValue()
                }
            }
        }
    }
    private func updateEvent() {
        isLoading = true
        let db = Firestore.firestore()
        db.collection("events").document(eventId).updateData([
            "title": eventName,
            "description": eventDescription,
            "startDate": Timestamp(date: eventDate)
        ]) { error in
            isLoading = false
            if error == nil {
                onSave()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct EventRowView: View {
    let event: Event
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text(event.startDate, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(event.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Button(action: onEdit) {
                    Label("Düzenle", systemImage: "pencil")
                        .labelStyle(IconOnlyLabelStyle())
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Capsule().fill(Color.blue.opacity(0.1)))
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onDelete) {
                    Label("Sil", systemImage: "trash")
                        .labelStyle(IconOnlyLabelStyle())
                        .foregroundColor(.red)
                        .padding(8)
                        .background(Capsule().fill(Color.red.opacity(0.1)))
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.vertical, 4)
    }
} 