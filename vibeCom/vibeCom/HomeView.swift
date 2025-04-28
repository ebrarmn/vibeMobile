import SwiftUI

struct HomeView: View {
    @StateObject private var theme = Theme.shared
    @State private var isAnimating = false
    
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
            
            ProfileView()
                .tabItem {
                    Label("Profil", systemImage: "person")
                }
        }
        .accentColor(theme.primaryColor)
    }
}

struct MainView: View {
    @ObservedObject var theme = Theme.shared
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
        // Örnek etkinlik verileri
        featuredEvents = [
            Event(id: "1", title: "Swift Workshop", description: "iOS uygulama geliştirme workshop'u", date: Date(), location: "A Blok Lab 1", clubId: "1", imageURL: "https://example.com/event1.jpg", attendees: ["user1", "user2"], category: .technology),
            Event(id: "2", title: "Startup Weekend", description: "48 saat sürecek girişimcilik etkinliği", date: Date().addingTimeInterval(86400), location: "Konferans Salonu", clubId: "2", imageURL: "https://example.com/event2.jpg", attendees: ["user3"], category: .business),
            Event(id: "3", title: "Basketbol Turnuvası", description: "Kampüs basketbol turnuvası", date: Date().addingTimeInterval(172800), location: "Çok amaçlı salon", clubId: "3", imageURL: "https://example.com/event3.jpg", attendees: ["user1", "user4", "user5"], category: .music)
        ]
        
        // Örnek kulüp verileri
        popularClubs = [
            Club(id: "1", 
                 name: "Yazılım Kulübü",
                 description: "Yazılım geliştirme ve teknoloji odaklı öğrenci kulübü",
                 logoURL: "https://example.com/logo1.png",
                 members: ["user1", "user2", "user3", "user4", "user5"],
                 events: ["event1", "event2", "event3"],
                 socialMedia: ["twitter": "@yazilimkulubu"]),
            Club(id: "2",
                 name: "Tiyatro Kulübü",
                 description: "Sahne sanatları ve tiyatro etkinlikleri düzenleyen kulüp",
                 logoURL: "https://example.com/logo2.png",
                 members: ["user3", "user4", "user5", "user6"],
                 events: ["event3", "event4"],
                 socialMedia: ["instagram": "@tiyatrokulubu"]),
            Club(id: "3",
                 name: "Spor Kulübü",
                 description: "Spor etkinlikleri ve turnuvalar düzenleyen kulüp",
                 logoURL: "https://example.com/logo3.png",
                 members: ["user7", "user8", "user9"],
                 events: ["event5", "event6", "event7"],
                 socialMedia: ["instagram": "@sporkulubu"])
        ]
        
        // Örnek yaklaşan etkinlik verileri
        upcomingEvents = [
            Event(id: "4", title: "Dans Gösterisi", description: "Modern dans gösterisi", date: Date().addingTimeInterval(259200), location: "Spor Salonu", clubId: "4", imageURL: "https://example.com/event4.jpg", attendees: ["user2", "user6"], category: .art),
            Event(id: "5", title: "Basketbol Turnuvası", description: "Kampüs basketbol turnuvası", date: Date().addingTimeInterval(345600), location: "Spor Salonu", clubId: "3", imageURL: "https://example.com/event5.jpg", attendees: ["user7", "user8", "user9"], category: .sports),
            Event(id: "6", title: "Kariyer Günleri", description: "Mezuniyet sonrası kariyer fırsatları", date: Date().addingTimeInterval(432000), location: "Konferans Salonu", clubId: "1", imageURL: "https://example.com/event6.jpg", attendees: ["user1", "user2", "user3"], category: .business)
        ]
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
            Text(event.date.formatted(date: .abbreviated, time: .shortened))
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
                Text("\(event.date.formatted(date: .abbreviated, time: .shortened))")
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
} 
