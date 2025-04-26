import SwiftUI

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
        // Örnek veriler
        clubs = [
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
                 socialMedia: ["instagram": "@sporkulubu"]),
            Club(id: "4",
                 name: "Müzik Kulübü",
                 description: "Müzik etkinlikleri ve konserler düzenleyen kulüp",
                 logoURL: "https://example.com/logo4.png",
                 members: ["user10", "user11", "user12", "user13"],
                 events: ["event8", "event9"],
                 socialMedia: ["instagram": "@muzikkulubu"])
        ]
        isLoading = false
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
    @State private var isJoined = false
    
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
                            
                            ForEach(club.events, id: \.self) { eventId in
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(theme.primaryColor)
                                    Text(eventId)
                                        .foregroundColor(theme.textColor)
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
                    
                    // Katıl Butonu
                    Button(action: {
                        withAnimation {
                            isJoined.toggle()
                        }
                    }) {
                        Text(isJoined ? "Kulüpten Ayrıl" : "Kulübe Katıl")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isJoined ? Color.red : theme.primaryColor)
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
            socialMedia: ["twitter": "@ornekkulup"]
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
                ]
            ))
        }
    }
} 