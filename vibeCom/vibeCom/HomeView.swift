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
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Başlık Animasyonu
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
                    
                    // Öne çıkan etkinlikler
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
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(1...5, id: \.self) { index in
                                    FeaturedEventCard()
                                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                                        .animation(
                                            Animation.easeInOut(duration: 0.5)
                                                .delay(Double(index) * 0.1),
                                            value: isAnimating
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Popüler kulüpler
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
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        }
                        .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                ForEach(1...5, id: \.self) { index in
                                    PopularClubCard()
                                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                                        .animation(
                                            Animation.easeInOut(duration: 0.5)
                                                .delay(Double(index) * 0.1),
                                            value: isAnimating
                                        )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Yaklaşan etkinlikler
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
                                    Animation.linear(duration: 2)
                                        .repeatForever(autoreverses: false),
                                    value: isAnimating
                                )
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 10) {
                            ForEach(1...3, id: \.self) { index in
                                UpcomingEventCard()
                                    .scaleEffect(isAnimating ? 1.0 : 0.95)
                                    .animation(
                                        Animation.easeInOut(duration: 0.5)
                                            .delay(Double(index) * 0.1),
                                        value: isAnimating
                                    )
                            }
                        }
                        .padding(.horizontal)
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
            }
        }
    }
}

struct FeaturedEventCard: View {
    @ObservedObject var theme = Theme.shared
    @State private var isAnimating = false
    
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
                    Image(systemName: "photo")
                        .foregroundColor(theme.textColor)
                        .font(.largeTitle)
                )
                .shadow(color: theme.cardShadowColor, radius: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                )
            
            Text("Etkinlik Adı")
                .font(.headline)
                .foregroundColor(theme.textColor)
            Text("24 Nisan 2024")
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
                    Image(systemName: "person.3")
                        .foregroundColor(theme.textColor)
                        .font(.title)
                )
                .shadow(color: theme.cardShadowColor, radius: 3)
                .overlay(
                    Circle()
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                )
            
            Text("Kulüp Adı")
                .font(.headline)
                .foregroundColor(theme.textColor)
            Text("97 Üye")
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
                    Image(systemName: "calendar")
                        .foregroundColor(theme.textColor)
                        .font(.title2)
                )
                .shadow(color: theme.cardShadowColor, radius: 3)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Etkinlik Adı")
                    .font(.headline)
                    .foregroundColor(theme.textColor)
                Text("24 Nisan 2024 • 14:00")
                    .font(.subheadline)
                    .foregroundColor(theme.secondaryTextColor)
                Text("Konferans Salonu")
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
