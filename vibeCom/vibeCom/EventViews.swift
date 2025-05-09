import SwiftUI
import FirebaseFirestore

struct EventsView: View {
    @StateObject private var theme = Theme.shared
    @State private var events: [Event] = []
    @State private var clubs: [Club] = []
    @State private var isLoading = true
    @State private var selectedCategory: EventCategory = .all
    @State private var searchText = ""
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Kategori seçici
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(EventCategory.allCases, id: \.self) { category in
                                CategoryButton(category: category, selectedCategory: $selectedCategory)
                                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                                    .animation(
                                        Animation.spring(response: 0.5, dampingFraction: 0.6)
                                            .delay(Double(EventCategory.allCases.firstIndex(of: category) ?? 0) * 0.1),
                                        value: isAnimating
                                    )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Öne çıkan etkinlik
                    if let featuredEvent = events.first {
                        let clubName = clubs.first(where: { $0.id == featuredEvent.clubId })?.name ?? "Bilinmeyen Kulüp"
                        FeaturedEventView(event: featuredEvent, clubName: clubName)
                            .padding(.horizontal)
                            .scaleEffect(isAnimating ? 1.0 : 0.95)
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .animation(.easeInOut(duration: 0.5), value: isAnimating)
                    }
                    
                    // Bu haftaki etkinlikler
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Bu Hafta")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            Image(systemName: "calendar.badge.clock")
                                .foregroundColor(theme.primaryColor)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(Array(events.prefix(5).enumerated()), id: \.element.id) { index, event in
                                    let clubName = clubs.first(where: { $0.id == event.clubId })?.name ?? "Bilinmeyen Kulüp"
                                    WeeklyEventCard(event: event, clubName: clubName)
                                        .scaleEffect(isAnimating ? 1.0 : 0.9)
                                        .animation(
                                            Animation.spring(response: 0.5, dampingFraction: 0.6)
                                                .delay(Double(index) * 0.1),
                                            value: isAnimating
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Tüm etkinlikler
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Tüm Etkinlikler")
                                .font(.title2)
                                .bold()
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            Image(systemName: "list.bullet.rectangle")
                                .foregroundColor(theme.primaryColor)
                                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                .animation(
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        }
                        
                        LazyVStack(spacing: 15) {
                            ForEach(Array(filteredEvents.enumerated()), id: \.element.id) { index, event in
                                let clubName = clubs.first(where: { $0.id == event.clubId })?.name ?? "Bilinmeyen Kulüp"
                                EventCard(event: event, clubName: clubName)
                                    .padding(.horizontal)
                                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                                    .opacity(isAnimating ? 1.0 : 0.0)
                                    .animation(
                                        Animation.spring(response: 0.5, dampingFraction: 0.6)
                                            .delay(Double(index) * 0.1),
                                        value: isAnimating
                                    )
                            }
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
            .navigationTitle("Etkinlikler")
            .searchable(text: $searchText, prompt: "Etkinlik ara...")
        }
        .task {
            await loadEvents()
            await loadClubs()
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private var filteredEvents: [Event] {
        var filtered = events
        
        if selectedCategory != .all {
            filtered = filtered.filter { $0.category == selectedCategory }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return filtered
    }
    
    private func loadEvents() async {
        isLoading = true
        let db: Firestore = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Etkinlikler çekilemedi: \(error.localizedDescription)")
                    events = []
                    return
                }
                guard let documents = snapshot?.documents else {
                    events = []
                    return
                }
                events = documents.compactMap { doc in
                    let data = doc.data()
                    // Kategori string'den enum'a dönüştürülüyor
                    let categoryRaw = data["category"] as? String ?? "all"
                    let category = EventCategory(rawValue: categoryRaw) ?? .all
                    return Event(
                        id: doc.documentID,
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        date: (data["startDate"] as? Timestamp)?.dateValue() ?? Date(),
                        location: data["location"] as? String ?? "",
                        clubId: data["clubId"] as? String ?? "",
                        imageURL: data["imageURL"] as? String ?? "",
                        attendees: data["attendeeIds"] as? [String] ?? [],
                        category: category
                    )
                }
            }
        }
    }
    
    private func loadClubs() async {
        let db: Firestore = Firestore.firestore()
        db.collection("clubs").getDocuments { snapshot, error in
            DispatchQueue.main.async {
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

struct CategoryButton: View {
    @ObservedObject var theme = Theme.shared
    let category: EventCategory
    @Binding var selectedCategory: EventCategory
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                selectedCategory = category
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
            }
        }) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
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
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
    }
}

struct EventDetailView: View {
    @ObservedObject var theme = Theme.shared
    let event: Event
    @State private var isAnimating = false
    @ObservedObject private var userSession = UserSession.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Etkinlik Görseli
                AsyncImage(url: URL(string: event.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color.gray.opacity(0.3)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                        )
                }
                .frame(height: 250)
                .clipped()
                
                VStack(alignment: .leading, spacing: 20) {
                    // Başlık ve Kategori
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            Image(systemName: event.category.icon)
                            Text(event.category.rawValue)
                        }
                        .foregroundColor(theme.primaryColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(theme.primaryColor.opacity(0.1))
                        .cornerRadius(20)
                    }
                    
                    // Tarih ve Konum
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(theme.primaryColor)
                            Text(event.date.formatted(date: .long, time: .shortened))
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(theme.primaryColor)
                            Text(event.location)
                            Spacer()
                        }
                    }
                    .padding()
                    .background(theme.cardBackgroundColor)
                    .cornerRadius(15)
                    
                    // Açıklama
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Etkinlik Hakkında")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(event.description)
                            .foregroundColor(theme.secondaryTextColor)
                    }
                    
                    // Katılımcılar
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Katılımcılar")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        
                        let allAttendees = Array(Set(event.attendees + (userSession.attendingEvents.contains(event.id) ? [userSession.userId] : [])))
                        ForEach(allAttendees.prefix(5), id: \.self) { attendee in
                            Circle()
                                .fill(theme.primaryColor.opacity(0.2))
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text(String(attendee.prefix(1)))
                                        .foregroundColor(theme.primaryColor)
                                )
                        }
                        
                        let attendeeCount = allAttendees.count
                        if attendeeCount > 5 {
                            Text("+\(attendeeCount - 5)")
                                .foregroundColor(theme.secondaryTextColor)
                        }
                    }
                    
                    // Katıl Butonu
                    Button(action: {
                        withAnimation {
                            if userSession.attendingEvents.contains(event.id) {
                                userSession.leaveEvent(event.id)
                            } else {
                                userSession.attendEvent(event.id)
                            }
                        }
                    }) {
                        Text(userSession.attendingEvents.contains(event.id) ? "Etkinlikten Ayrıl" : "Etkinliğe Katıl")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(userSession.attendingEvents.contains(event.id) ? Color.red : theme.primaryColor)
                            .cornerRadius(15)
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
        }
    }
}

struct FeaturedEventView: View {
    let event: Event
    let clubName: String
    
    var body: some View {
        NavigationLink(destination: EventDetailView(event: event)) {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: URL(string: event.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
            .frame(height: 200)
            .clipped()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("ÖNE ÇIKAN ETKİNLİK")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text(event.title)
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Düzenleyen: \(clubName)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(event.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                HStack {
                    Label(event.date.formatted(date: .abbreviated, time: .shortened),
                          systemImage: "calendar")
                    Spacer()
                    Label(event.location, systemImage: "mappin.and.ellipse")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
        }
    }
}

struct WeeklyEventCard: View {
    let event: Event
    let clubName: String
    
    var body: some View {
        NavigationLink(destination: EventDetailView(event: event)) {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: event.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 200, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                    .lineLimit(1)
                Text("Düzenleyen: \(clubName)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(event.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(event.location)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
        }
        .frame(width: 200)
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 3)
        }
    }
}

struct EventCard: View {
    let event: Event
    let clubName: String
    
    var body: some View {
        NavigationLink(destination: EventDetailView(event: event)) {
        HStack(spacing: 15) {
            AsyncImage(url: URL(string: event.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.3)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.headline)
                Text("Düzenleyen: \(clubName)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Text(event.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                HStack {
                    Label(event.date.formatted(date: .abbreviated, time: .shortened),
                          systemImage: "calendar")
                    Spacer()
                    Label("\(event.attendees.count)", systemImage: "person.2")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 3)
        }
    }
}

#Preview {
    EventsView()
} 
