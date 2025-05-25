import SwiftUI
import FirebaseFirestore

//VStack:alt alta (dikey) bileşen yerleştirir.
//HStack:yan yana (yatay) bileşen yerleştirir.
//ZStack:üst üste (z-ekseni boyunca) bileşen yerleştirir.
struct HomeView: View {
    @StateObject private var theme = Theme.shared
    @ObservedObject private var userSession = UserSession.shared
    //@StateObject:Karmaşık sınıf tabanlı tabanlı verileri yönetmek için görünümde oluşturulan ve sahip olunan bir ObservableObject'i tanımlar.
    //@State yerel bir veri saklamak için kullanılır
    @State private var isAnimating = false
    @State private var userClubs: [Club] = []
    
    var body: some View {
        TabView {
            MainView()
                .tabItem {
                    Label("Anasayfa", systemImage: "house.fill")
                }
            
            EventsView()
                .tabItem {
                    Label("Etkinlikler", systemImage: "calendar")
                }
            
            ClubListView()
                .tabItem {
                    Label("Kulüpler", systemImage: "person.3")
                }
            
            if let currentUser = userSession.currentUser {
                let leaderClubs = userClubs.filter { $0.leaderID == currentUser.id }
                if leaderClubs.count == 1 {
                    ClubManagementView(club: leaderClubs[0])
                        .tabItem {
                            Label("Kulübüm", systemImage: "person.2.circle.fill")
                        }
                } else if leaderClubs.count > 1 {
                    ClubManagerSelectorView(leaderClubs: leaderClubs)
                        .tabItem {
                            Label("Kulübüm", systemImage: "person.2.circle.fill")
                        }
                }
            }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Profil")
                }
        }
        .id(userSession.currentUser?.photoURL ?? "default")
        .accentColor(theme.primaryColor)
        .onAppear {
            loadUserClubs()
        }
    }
    
    private func loadUserClubs() {
        guard let currentUser = userSession.currentUser else { return }
        
        let db = Firestore.firestore()
        db.collection("clubs")
            .whereField("memberIds", arrayContains: currentUser.id)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    userClubs = documents.compactMap { doc in
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

struct MainView: View {
    @ObservedObject var theme = Theme.shared
    //@ObservedObject:Dışardan gelen bir ObservableObject'i gözlemleyerek değişikliklerinde görünümü yeniler,ancak sahiplenemez.
    @State private var isAnimating = false
    @State private var selectedTab = 0
    @State private var featuredEvents: [Event] = []
    @State private var popularClubs: [Club] = []
    @State private var upcomingEvents: [Event] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Başlık Animasyonu
                    TitleView(isAnimating: $isAnimating)
                    
                    // Öne çıkan etkinlikler
                    FeaturedEventsView(isAnimating: $isAnimating, events: featuredEvents)
                    
                    // Popüler kulüpler
                    PopularClubsView(isAnimating: $isAnimating, clubs: popularClubs)
                    
                    // Yaklaşan etkinlikler
                    UpcomingEventsView(isAnimating: $isAnimating, events: upcomingEvents)
                }
                .padding(.vertical)
            }
            .background(
                theme.backgroundColor
                    .overlay(
                        Circle()
                            .fill(theme.primaryColor.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .offset(x: -100, y: -100)
                            .blur(radius: 50)
                    )
                    .overlay(
                        Circle()
                            .fill(theme.primaryColor.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .offset(x: 100, y: 100)
                            .blur(radius: 50)
                    )
            )
            .onAppear {
                isAnimating = true
                loadData()
            }
        }
    }
    
    private func loadData() {
        let db: Firestore = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let documents = snapshot?.documents {
                    let allEvents = documents.compactMap { doc -> Event? in
                        let data = doc.data()
                        let categoryRaw = data["category"] as? String ?? "all"
                        let category = EventCategory(rawValue: categoryRaw) ?? .all
                        return Event(
                            id: doc.documentID,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            startDate: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                            endDate: (data["endDate"] as? Timestamp)?.dateValue() ?? Date(),
                            location: data["location"] as? String ?? "",
                            clubId: data["clubId"] as? String ?? "",
                            imageURL: data["imageURL"] as? String ?? "",
                            attendees: data["attendeeIds"] as? [String] ?? [],
                            category: category
                        )
                    }
                    featuredEvents = Array(allEvents.prefix(3))
                    let now = Date()
                    upcomingEvents = allEvents.filter { $0.startDate > now }.sorted { $0.startDate < $1.startDate }.prefix(5).map { $0 }
                } else {
                    featuredEvents = []
                    upcomingEvents = []
                }
            }
        }
        // Kulüpler
        db.collection("clubs").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                if let documents = snapshot?.documents {
                    popularClubs = documents.compactMap { doc in
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
                } else {
                    popularClubs = []
                }
            }
        }
    }
}

// MARK: - Title View
struct TitleView: View {
    @ObservedObject var theme = Theme.shared
    @Binding var isAnimating: Bool
    
    var body: some View {
        Text("|VIBE|")
            .font(.system(size: 40, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .animation(
                Animation.easeInOut(duration: 1.5)
                    .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
            .padding(.top)
    }
}

// MARK: - Featured Events View
struct FeaturedEventsView: View {
    @ObservedObject var theme = Theme.shared
    @Binding var isAnimating: Bool
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Öne Çıkan Etkinlikler")
                    .font(.title2)
                    .bold()
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Image(systemName: "flame.fill")
                    .foregroundColor(theme.primaryColor)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        NavigationLink(destination: EventDetailView(event: event)) {
                            FeaturedEventCard(event: event)
                                .scaleEffect(isAnimating ? 1.0 : 0.95)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .delay(getDelay(for: index)),
                                    value: isAnimating
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getDelay(for index: Int) -> Double {
        return Double(index) * 0.1
    }
}

// MARK: - Popular Clubs View
struct PopularClubsView: View {
    @ObservedObject var theme = Theme.shared
    @Binding var isAnimating: Bool
    let clubs: [Club]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Popüler Kulüpler")
                    .font(.title2)
                    .bold()
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .foregroundColor(theme.primaryColor)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                   
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Array(clubs.enumerated()), id: \.element.id) { index, club in
                        NavigationLink(destination: ClubDetailView(club: club)) {
                            PopularClubCard(club: club)
                                .scaleEffect(isAnimating ? 1.0 : 0.95)
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .delay(getDelay(for: index)),
                                    value: isAnimating
                                )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func getDelay(for index: Int) -> Double {
        return Double(index) * 0.1
    }
}

// MARK: - Upcoming Events View
struct UpcomingEventsView: View {
    @ObservedObject var theme = Theme.shared
    @Binding var isAnimating: Bool
    let events: [Event]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Yaklaşan Etkinlikler")
                    .font(.title2)
                    .bold()
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Image(systemName: "clock.fill")
                    .foregroundColor(theme.primaryColor)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        Animation.linear(duration: 0)
                            .repeatForever(autoreverses: false),
                        value: isAnimating
                    )
                    
            }
            .padding(.horizontal)
            
            VStack(spacing: 10) {
                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                    NavigationLink(destination: EventDetailView(event: event)) {
                        UpcomingEventCard(event: event)
                            .scaleEffect(isAnimating ? 1.0 : 0.95)
                            .animation(
                                Animation.easeInOut(duration: 0.5)
                                    .delay(getDelay(for: index)),
                                value: isAnimating
                            )
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func getDelay(for index: Int) -> Double {
        return Double(index) * 0.1
    }
}

struct FeaturedEventCard: View {
    @ObservedObject var theme = Theme.shared
    @State private var isAnimating = false
    let event: Event
    
    var body: some View {
        VStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 280, height: 150)
                .overlay(
                    AsyncImage(url: URL(string: event.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "photo")
                            .foregroundColor(theme.textColor)
                            .font(.largeTitle)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: theme.cardShadowColor, radius: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                )
            
            Text(event.title)
                .font(.headline)
                .foregroundColor(theme.textColor)
            Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                .font(.subheadline)
                .foregroundColor(theme.secondaryTextColor)
        }
        .frame(width: 280)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct PopularClubCard: View {
    @ObservedObject var theme = Theme.shared
    @State private var isAnimating = false
    let club: Club
    
    var body: some View {
        VStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 100, height: 100)
                .overlay(
                    AsyncImage(url: URL(string: club.logoURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.3")
                            .foregroundColor(theme.textColor)
                            .font(.title)
                    }
                )
                .clipShape(Circle())
                .shadow(color: theme.cardShadowColor, radius: 3)
                .overlay(
                    Circle()
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                )
            
            Text(club.name)
                .font(.headline)
                .foregroundColor(theme.textColor)
            Text("\(club.members.count) Üye")
                .font(.caption)
                .foregroundColor(theme.secondaryTextColor)
        }
        .frame(width: 120)
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct UpcomingEventCard: View {
    @ObservedObject var theme = Theme.shared
    @State private var isAnimating = false
    let event: Event
    
    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 80, height: 80)
                .overlay(
                    AsyncImage(url: URL(string: event.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "calendar")
                            .foregroundColor(theme.textColor)
                            .font(.title2)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: theme.cardShadowColor, radius: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                Text(event.startDate.formatted(date: .abbreviated, time: .shortened))
                    .font(.subheadline)
                    .foregroundColor(theme.secondaryTextColor)
                Text(event.location)
                    .font(.caption)
                    .foregroundColor(theme.secondaryTextColor)
            }
            
            Spacer()
        }
        .padding()
        .background(
            LinearGradient(
                colors: [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(10)
        .shadow(color: theme.cardShadowColor, radius: 3)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
        )
        .onAppear {
            withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// ClubManagerSelectorView: Birden fazla kulüp yöneticiliği için seçim ekranı
struct ClubManagerSelectorView: View {
    let leaderClubs: [Club]
    @State private var selectedClub: Club? = nil
    
    var body: some View {
        NavigationView {
            List(leaderClubs) { club in
                Button(action: {
                    selectedClub = club
                }) {
                    HStack {
                        AsyncImage(url: URL(string: club.logoURL)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(club.name).font(.headline)
                            Text(club.description).font(.subheadline).lineLimit(1)
                        }
                    }
                }
            }
            .navigationTitle("Yönetici Olduğun Kulüpler")
            .background(
                NavigationLink(
                    destination: selectedClub.map { ClubManagementView(club: $0) },
                    isActive: Binding(
                        get: { selectedClub != nil },
                        set: { if !$0 { selectedClub = nil } }
                    )
                ) { EmptyView() }
                .hidden()
            )
        }
    }
}

// Tab bar için özel bir SwiftUI view
struct TabBarProfileImageTabItem: View {
    let photoURL: String?
    @State private var uiImage: UIImage? = nil
    let size: CGFloat = 28

    var body: some View {
        Group {
            if let uiImage = uiImage {
                CircularTabBarProfileImageView(image: uiImage, size: size)
                    .frame(width: size, height: size)
            } else {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let urlString = photoURL, let url = URL(string: urlString), uiImage == nil else { return }
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.uiImage = image
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 
