import SwiftUI
import FirebaseFirestore

struct ClubListView: View {
    @StateObject private var theme = Theme.shared
    @State private var clubs: [Club] = []
    @State private var isLoading = true
    @State private var searchText = ""
    @State private var selectedCategory: String = "Tümü"
    @State private var isAnimating = false
    let categories = ["Tümü", "Teknoloji", "Sanat", "Spor", "Sosyal", "Akademik"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Kategori seçici
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    withAnimation(.spring()) {
                                        selectedCategory = category
                                    }
                                }) {
                                    Text(category)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            LinearGradient(
                                                colors: selectedCategory == category ?
                                                    [theme.primaryColor, theme.primaryColor.opacity(0.7)] :
                                                    [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .foregroundColor(
                                            selectedCategory == category ?
                                            .white :
                                            theme.textColor
                                        )
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                                        )
                                }
                                .scaleEffect(isAnimating ? 1.0 : 0.9)
                                .animation(
                                    Animation.spring(response: 0.5, dampingFraction: 0.6)
                                        .delay(Double(categories.firstIndex(of: category) ?? 0) * 0.1),
                                    value: isAnimating
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Öne çıkan kulüp
                    if let featuredClub = clubs.first {
                        NavigationLink(destination: ClubDetailView(club: featuredClub)) {
                        VStack(alignment: .leading, spacing: 0) {
                            AsyncImage(url: URL(string: featuredClub.logoURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                                    .overlay(
                                        Image(systemName: "building.2")
                                            .font(.largeTitle)
                                            .foregroundColor(.white)
                                    )
                            }
                            .frame(height: 200)
                            .clipped()
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("ÖNE ÇIKAN KULÜP")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text(featuredClub.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                Text(featuredClub.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                
                                HStack {
                                    Label("\(featuredClub.members.count) Üye", systemImage: "person.3")
                                    Spacer()
                                    Label("\(featuredClub.events.count) Etkinlik", systemImage: "calendar")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                            .padding()
                        }
                        .background(
                            LinearGradient(
                                colors: [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(15)
                        .shadow(radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: isAnimating)
                        }
                    }
                    
                    // En aktif kulüpler
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("En Aktif Kulüpler")
                                .font(.title2)
                                .bold()
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(theme.primaryColor)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Array(clubs.prefix(5).enumerated()), id: \.element.id) { index, club in
                                    NavigationLink(destination: ClubDetailView(club: club)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        AsyncImage(url: URL(string: club.logoURL)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                                .overlay(
                                                    Image(systemName: "person.3")
                                                        .foregroundColor(.white)
                                                )
                                        }
                                        .frame(width: 200, height: 120)
                                        .clipped()
                                        .cornerRadius(10)
                                        
                                        Text(club.name)
                                            .font(.headline)
                                            .lineLimit(1)
                                        
                                        HStack {
                                            Label("\(club.members.count)", systemImage: "person.3")
                                            Spacer()
                                            Label("\(club.events.count)", systemImage: "calendar")
                                        }
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    }
                                    .frame(width: 200)
                                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                                    .animation(
                                        Animation.spring(response: 0.5, dampingFraction: 0.6)
                                            .delay(Double(index) * 0.1),
                                        value: isAnimating
                                    )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Tüm kulüpler
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Tüm Kulüpler")
                                .font(.title2)
                                .bold()
                                .foregroundColor(theme.textColor)
                            
                            Spacer()
                            
                            Image(systemName: "building.2.fill")
                                .foregroundColor(theme.primaryColor)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        }
                        .padding(.horizontal)
                        
                        LazyVStack(spacing: 15) {
                            ForEach(Array(filteredClubs.enumerated()), id: \.element.id) { index, club in
                                NavigationLink(destination: ClubDetailView(club: club)) {
                                    HStack(spacing: 15) {
                                        AsyncImage(url: URL(string: club.logoURL)) { image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                        } placeholder: {
                                            Color.gray.opacity(0.3)
                                                .overlay(
                                                    Image(systemName: "person.3")
                                                        .foregroundColor(.white)
                                                )
                                        }
                                        .frame(width: 80, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(club.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Text(club.description)
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .lineLimit(2)
                                            
                                            HStack {
                                                Label("\(club.members.count) Üye", systemImage: "person.3")
                                                Spacer()
                                                Label("\(club.events.count) Etkinlik", systemImage: "calendar")
                                            }
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        }
                                    }
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            colors: [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.8)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(15)
                                    .shadow(radius: 3)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                                    )
                                }
                                .scaleEffect(isAnimating ? 1.0 : 0.95)
                                .opacity(isAnimating ? 1.0 : 0.0)
                                .animation(
                                    Animation.spring(response: 0.5, dampingFraction: 0.6)
                                        .delay(Double(index) * 0.1),
                                    value: isAnimating
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(
                theme.backgroundColor
                    .overlay(
                        Circle()
                            .fill(theme.primaryColor.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .offset(x: -100, y: -50)
                            .blur(radius: 50)
                    )
                    .overlay(
                        Circle()
                            .fill(theme.primaryColor.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .offset(x: 100, y: 300)
                            .blur(radius: 50)
                    )
            )
            .navigationTitle("Kulüpler")
            .searchable(text: $searchText, prompt: "Kulüp ara...")
        }
        .task {
            await loadClubs()
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private var filteredClubs: [Club] {
        var filtered = clubs
        
        if selectedCategory != "Tümü" {
            filtered = filtered.filter { $0.name.contains(selectedCategory) }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    private func loadClubs() async {
        isLoading = true
        let db: Firestore = Firestore.firestore()
        db.collection("clubs").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Kulüpler çekilemedi: \(error.localizedDescription)")
                    clubs = []
                    return
                }
                guard let documents = snapshot?.documents else {
                    clubs = []
                    return
                }
                clubs = documents.compactMap { doc in
                    let data = doc.data()
                    return Club(
                        id: doc.documentID,
                        name: data["name"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        logoURL: data["logoURL"] as? String ?? "",
                        members: data["memberIds"] as? [String] ?? [],
                        events: data["eventIds"] as? [String] ?? [],
                        socialMedia: data["socialMedia"] as? [String: String] ?? [:],
                        leaderID: data["leaderId"] as? String ?? "",
                        isActive: data["isActive"] as? Bool ?? true
                    )
                }
            }
        }
    }
}

struct ClubRow: View {
    let club: Club
    
    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: URL(string: club.logoURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Image(systemName: "person.3")
                    .foregroundColor(.gray)
            }
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(club.name)
                    .font(.headline)
                
                Text(club.description)
                    .font(.subheadline)
                    .lineLimit(2)
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 8)
    }
}

struct ClubDetailView: View {
    @ObservedObject var theme = Theme.shared
    let club: Club
    @State private var isAnimating = false
    @ObservedObject private var userSession = UserSession.shared
    @State private var clubEvents: [Event] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Kulüp Görseli
                AsyncImage(url: URL(string: club.logoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "building.2")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                }
                .frame(height: 250)
                .clipped()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Başlık ve İstatistikler
                VStack(alignment: .leading, spacing: 8) {
                    Text(club.name)
                        .font(.title)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("\(club.members.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Üye")
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                            
                            VStack {
                                Text("\(club.events.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                Text("Etkinlik")
                                    .font(.caption)
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                        }
                    }
                    
                    // Açıklama
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Kulüp Hakkında")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                    Text(club.description)
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    // Sosyal Medya
                    if !club.socialMedia.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                        Text("Sosyal Medya")
                            .font(.title2)
                                .fontWeight(.bold)
                        
                            HStack(spacing: 15) {
                        ForEach(Array(club.socialMedia.keys), id: \.self) { platform in
                                    Button(action: {
                                        // TODO: Sosyal medya linkine git
                                    }) {
                                        VStack {
                                Image(systemName: socialMediaIcon(for: platform))
                                                .font(.title2)
                                            Text(platform.capitalized)
                                                .font(.caption)
                            }
                                        .foregroundColor(theme.primaryColor)
                                        .frame(width: 60, height: 60)
                                        .background(theme.primaryColor.opacity(0.1))
                                        .cornerRadius(15)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Etkinlikler
                    if !club.events.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                        Text("Etkinlikler")
                            .font(.title2)
                                .fontWeight(.bold)
                        
                            ForEach(clubEvents) { event in
                                NavigationLink(destination: EventDetailView(event: event)) {
                            HStack {
                                Image(systemName: "calendar")
                                        .foregroundColor(theme.primaryColor)
                                        VStack(alignment: .leading) {
                                            Text(event.title)
                                                .font(.headline)
                                        .foregroundColor(theme.textColor)
                                            Text(event.date, style: .date)
                                                .font(.caption)
                                                .foregroundColor(theme.secondaryTextColor)
                                        }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(theme.secondaryTextColor)
                            }
                            .padding()
                                .background(theme.cardBackgroundColor)
                                .cornerRadius(15)
                                }
                            }
                        }
                    }
                    
                    // Katıl Butonu
                    if UserSession.shared.currentUser?.id == club.leaderID {
                        // Başkan için özel mesaj
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Siz bu kulübün başkanısınız")
                                .font(.headline)
                                .foregroundColor(theme.textColor)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                        )
                    } else {
                        // Normal üyeler için katıl/ayrıl butonu
                    Button(action: {
                        withAnimation {
                            if userSession.joinedClubs.contains(club.id) {
                                userSession.leaveClub(club.id)
                            } else {
                                userSession.joinClub(club.id)
                            }
                        }
                    }) {
                        Text(userSession.joinedClubs.contains(club.id) ? "Kulüpten Ayrıl" : "Kulübe Katıl")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(userSession.joinedClubs.contains(club.id) ? Color.red : theme.primaryColor)
                            .cornerRadius(15)
                        }
                    }
                }
                .padding()
            }
        }
        .background(theme.backgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            withAnimation {
                isAnimating = true
            }
            loadClubEvents()
        }
    }
    
    private func loadClubEvents() {
        let db = Firestore.firestore()
        let eventIds = club.events
        
        for eventId in eventIds {
            db.collection("events").document(eventId).getDocument { snapshot, error in
                if let data = snapshot?.data() {
                    let categoryRaw = data["category"] as? String ?? "all"
                    let category = EventCategory(rawValue: categoryRaw) ?? .all
                    let event = Event(
                        id: eventId,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        date: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                        location: data["location"] as? String ?? "",
                        clubId: data["clubId"] as? String ?? "",
                        imageURL: data["imageURL"] as? String ?? "",
                        attendees: data["attendeeIds"] as? [String] ?? [],
                        category: category
                    )
                    DispatchQueue.main.async {
                        if !clubEvents.contains(where: { $0.id == event.id }) {
                            clubEvents.append(event)
                        }
                    }
                }
            }
        }
    }
    
    private func socialMediaIcon(for platform: String) -> String {
        switch platform.lowercased() {
        case "twitter": return "bubble.left"
        case "instagram": return "camera"
        case "facebook": return "person.2"
        case "linkedin": return "network"
        default: return "link"
        }
    }
}

struct ClubListView_Previews: PreviewProvider {
    static var previews: some View {
        ClubListView()
    }
}

struct ClubRow_Previews: PreviewProvider {
    static var previews: some View {
        ClubRow(club: Club(
            id: "preview",
            name: "Örnek Kulüp",
            description: "Bu bir örnek kulüp açıklamasıdır",
            logoURL: "https://example.com/logo.png",
            members: ["user1", "user2"],
            events: ["event1"],
            socialMedia: ["twitter": "@ornekkulup"],
            leaderID: "leader1",
            isActive: true
        ))
        .previewLayout(.sizeThatFits)
        .padding()
    }
}

struct ClubDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClubDetailView(club: Club(
                id: "preview",
                name: "Örnek Kulüp",
                description: "Bu bir örnek kulüp açıklamasıdır. Bu kulüp öğrencilere çeşitli etkinlikler ve fırsatlar sunmaktadır.",
                logoURL: "https://example.com/logo.png",
                members: ["user1", "user2", "user3", "user4"],
                events: ["event1", "event2", "event3"],
                socialMedia: [
                    "twitter": "@ornekkulup",
                    "instagram": "@ornekkulup",
                    "facebook": "ornekkulup"
                ],
                leaderID: "leader1",
                isActive: true
            ))
        }
    }
}

struct ClubManagementView: View {
    @State private var club: Club
    @State private var showingEventCreation = false
    @State private var showingClubEdit = false
    @State private var newEventName = ""
    @State private var newEventDescription = ""
    @State private var newEventDate = Date()
    @State private var showingDeleteAlert = false
    @State private var isDeleting = false
    
    init(club: Club) {
        _club = State(initialValue: club)
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
                    // Kulübü Dağıt butonu (sadece başkan görür)
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
                
                Section(header: Text("Etkinlikler")) {
                    ForEach(club.events, id: \.self) { eventId in
                        // Burada Event modelini kullanarak etkinlik detaylarını gösterebiliriz
                        Text(eventId)
                    }
                    
                    Button(action: {
                        showingEventCreation = true
                    }) {
                        Text("Yeni Etkinlik Ekle")
                            .foregroundColor(.blue)
                    }
                }
            }
            .navigationTitle("Kulüp Yönetimi")
            .sheet(isPresented: $showingEventCreation) {
                EventCreationView(club: club)
            }
            .sheet(isPresented: $showingClubEdit) {
                ClubEditView(club: club)
            }
            .alert("Kulübü silmek istediğinizden emin misiniz?", isPresented: $showingDeleteAlert) {
                Button("İptal", role: .cancel) {}
                Button("Evet, Sil", role: .destructive) {
                    deleteClubAndEvents(club: club)
                }
            } message: {
                Text("Bu işlem geri alınamaz. Kulüp ve tüm etkinlikleri silinecek.")
            }
        }
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
                // İsteğe bağlı: Kullanıcıyı ana ekrana yönlendir
            }
        }
    }
}

struct EventCreationView: View {
    let club: Club
    @Environment(\.presentationMode) var presentationMode
    @State private var eventName = ""
    @State private var eventDescription = ""
    @State private var eventDate = Date()
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Etkinlik Adı", text: $eventName)
                TextField("Etkinlik Açıklaması", text: $eventDescription)
                DatePicker("Tarih", selection: $eventDate, displayedComponents: [.date, .hourAndMinute])
                
                Button("Etkinlik Oluştur") {
                    let db = Firestore.firestore()
                    let newEventRef = db.collection("events").document()
                    let eventData: [String: Any] = [
                        "title": eventName,
                        "description": eventDescription,
                        "startDate": Timestamp(date: eventDate),
                        "clubId": club.id,
                        "location": "",
                        "imageURL": "",
                        "attendeeIds": [],
                        "category": "all"
                    ]
                    newEventRef.setData(eventData) { error in
                        if error == nil {
                            let clubRef = db.collection("clubs").document(club.id)
                            clubRef.updateData([
                                "eventIds": FieldValue.arrayUnion([newEventRef.documentID])
                            ])
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(eventName.isEmpty || eventDescription.isEmpty)
            }
            .navigationTitle("Yeni Etkinlik")
            .navigationBarItems(trailing: Button("İptal") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct ClubEditView: View {
    let club: Club
    @Environment(\.presentationMode) var presentationMode
    @State private var clubName: String
    @State private var clubDescription: String
    
    init(club: Club) {
        self.club = club
        _clubName = State(initialValue: club.name)
        _clubDescription = State(initialValue: club.description)
    }
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Kulüp Adı", text: $clubName)
                TextField("Kulüp Açıklaması", text: $clubDescription)
                
                Button("Değişiklikleri Kaydet") {
                    let db = Firestore.firestore()
                    let clubRef = db.collection("clubs").document(club.id)
                    clubRef.updateData([
                        "name": clubName,
                        "description": clubDescription
                    ]) { error in
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(clubName.isEmpty || clubDescription.isEmpty)
            }
            .navigationTitle("Kulüp Düzenle")
            .navigationBarItems(trailing: Button("İptal") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
} 
