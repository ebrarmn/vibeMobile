import SwiftUI

struct ProfileView: View {
    @StateObject private var theme = Theme.shared
    @State private var user: User?
    @State private var isLoading = true
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var isAnimating = false
    
    var body: some View {
        NavigationView {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let user = user {
                ScrollView {
                    VStack(spacing: 20) {
                        // Profil Başlığı
                        VStack(spacing: 15) {
                            AsyncImage(url: URL(string: user.profileImageURL)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .foregroundColor(theme.primaryColor.opacity(0.3))
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 3
                                    )
                            )
                            .shadow(radius: 10)
                            .scaleEffect(isAnimating ? 1.0 : 0.9)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                            
                            VStack(spacing: 8) {
                                Text(user.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(theme.textColor)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(theme.secondaryTextColor)
                                
                                HStack(spacing: 20) {
                                    VStack {
                                        Text("\(user.joinedClubs.count)")
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .foregroundStyle(
                                                LinearGradient(
                                                    colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                        Text("Kulüp")
                                            .font(.caption)
                                            .foregroundColor(theme.secondaryTextColor)
                                    }
                                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1), value: isAnimating)
                                    
                                    Divider()
                                        .frame(height: 30)
                                    
                                    VStack {
                                        Text("\(user.attendingEvents.count)")
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
                                    .scaleEffect(isAnimating ? 1.0 : 0.9)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2), value: isAnimating)
                                }
                                .padding(.top, 10)
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
                        .cornerRadius(20)
                        .shadow(color: theme.cardShadowColor, radius: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .animation(.easeInOut(duration: 0.5), value: isAnimating)
                        
                        // Tab Seçici
                        Picker("Seçim", selection: $selectedTab) {
                            Text("Kulüpler").tag(0)
                            Text("Etkinlikler").tag(1)
                            Text("Ayarlar").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        // İçerik Alanı
                        if selectedTab == 0 {
                            // Kulüpler
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Katıldığım Kulüpler")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "person.3.fill")
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
                                        ForEach(Array(user.joinedClubs.enumerated()), id: \.element) { index, clubId in
                                            VStack(spacing: 10) {
                                                Image(systemName: "person.3.fill")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.purple)
                                                    .frame(width: 60, height: 60)
                                                    .background(Color.purple.opacity(0.1))
                                                    .clipShape(Circle())
                                                
                                                Text(clubId)
                                                    .font(.subheadline)
                                                    .fontWeight(.medium)
                                                    .lineLimit(1)
                                            }
                                            .frame(width: 100)
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
                        } else if selectedTab == 1 {
                            // Etkinlikler
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Katılacağım Etkinlikler")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "calendar")
                                        .foregroundColor(theme.primaryColor)
                                        .rotationEffect(.degrees(isAnimating ? 360 : 0))
                                        .animation(
                                            Animation.linear(duration: 2)
                                                .repeatForever(autoreverses: false),
                                            value: isAnimating
                                        )
                                }
                                
                                VStack(spacing: 15) {
                                    ForEach(Array(user.attendingEvents.enumerated()), id: \.element) { index, eventId in
                                        HStack(spacing: 15) {
                                            Image(systemName: "calendar")
                                                .font(.title2)
                                                .foregroundColor(.purple)
                                                .frame(width: 40, height: 40)
                                                .background(Color.purple.opacity(0.1))
                                                .clipShape(Circle())
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(eventId)
                                                    .font(.headline)
                                                Text("Yakında")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.secondary)
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
                                        .scaleEffect(isAnimating ? 1.0 : 0.95)
                                        .opacity(isAnimating ? 1.0 : 0.0)
                                        .animation(
                                            Animation.spring(response: 0.5, dampingFraction: 0.6)
                                                .delay(Double(index) * 0.1),
                                            value: isAnimating
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        } else {
                            // Ayarlar Bölümü
                            VStack(spacing: 20) {
                                // Hesap Ayarları
                                SettingsSection(title: "Hesap Ayarları") {
                                    SettingsRow(icon: "person.fill", title: "Profil Düzenle") {
                                        // TODO: Profil düzenleme sayfası
                                    }
                                    
                                    SettingsRow(icon: "lock.fill", title: "Şifre Değiştir") {
                                        // TODO: Şifre değiştirme sayfası
                                    }
                                    
                                    SettingsRow(icon: "envelope.fill", title: "E-posta Değiştir") {
                                        // TODO: E-posta değiştirme sayfası
                                    }
                                }
                                
                                // Bildirim Ayarları
                                SettingsSection(title: "Bildirim Ayarları") {
                                    ToggleSettingsRow(
                                        icon: "bell.fill",
                                        title: "Bildirimler",
                                        isOn: $notificationsEnabled
                                    )
                                    
                                    ToggleSettingsRow(
                                        icon: "envelope.fill",
                                        title: "E-posta Bildirimleri",
                                        isOn: $emailNotifications
                                    )
                                    
                                    ToggleSettingsRow(
                                        icon: "iphone",
                                        title: "Push Bildirimleri",
                                        isOn: $pushNotifications
                                    )
                                }
                                
                                // Kulüp Ayarları
                                SettingsSection(title: "Kulüp Ayarları") {
                                    ToggleSettingsRow(
                                        icon: "person.3.fill",
                                        title: "Kulüp Davetleri",
                                        isOn: .constant(true)
                                    )
                                    
                                    ToggleSettingsRow(
                                        icon: "calendar",
                                        title: "Etkinlik Hatırlatıcıları",
                                        isOn: .constant(true)
                                    )
                                }
                                
                                // Uygulama Ayarları
                                SettingsSection(title: "Uygulama Ayarları") {
                                    ToggleSettingsRow(
                                        icon: "moon.fill",
                                        title: "Karanlık Mod",
                                        isOn: $darkModeEnabled
                                    )
                                    
                                    SettingsRow(icon: "globe", title: "Dil") {
                                        // TODO: Dil seçimi sayfası
                                    }
                                    
                                    SettingsRow(icon: "questionmark.circle.fill", title: "Yardım ve Destek") {
                                        // TODO: Yardım sayfası
                                    }
                                }
                                
                                // Çıkış Yap
                                Button(action: {
                                    // TODO: Çıkış yapma işlemi
                                }) {
                                    HStack {
                                        Image(systemName: "rectangle.portrait.and.arrow.right")
                                            .foregroundColor(.red)
                                        Text("Çıkış Yap")
                                            .foregroundColor(.red)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red.opacity(0.1))
                                    .cornerRadius(10)
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
                .navigationTitle("Profil")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            // TODO: Profil düzenleme işlemi
                        }) {
                            Image(systemName: "pencil")
                                .foregroundColor(theme.primaryColor)
                                .scaleEffect(isAnimating ? 1.1 : 1.0)
                                .animation(
                                    Animation.easeInOut(duration: 1.5)
                                        .repeatForever(autoreverses: true),
                                    value: isAnimating
                                )
                        }
                    }
                }
            }
        }
        .task {
            await loadUserProfile()
        }
        .onChange(of: darkModeEnabled) { newValue in
            theme.isDarkMode = newValue
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private func loadUserProfile() async {
        // Örnek veri
        user = User(
            id: "1",
            name: "Ahmet Yılmaz",
            email: "ahmet@example.com",
            profileImageURL: "https://example.com/profile.jpg",
            joinedClubs: ["Yazılım Kulübü", "Tiyatro Kulübü", "Spor Kulübü"],
            attendingEvents: ["Hackathon 2024", "Tiyatro Gösterisi", "Basketbol Turnuvası"]
        )
        isLoading = false
    }
}

// Ayarlar Bölümü için Yardımcı Görünümler
struct SettingsSection<Content: View>: View {
    @ObservedObject var theme = Theme.shared
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.secondaryTextColor)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(theme.cardBackgroundColor)
            .cornerRadius(15)
            .shadow(color: theme.cardShadowColor, radius: 3)
            .padding(.horizontal)
        }
    }
}

struct SettingsRow: View {
    @ObservedObject var theme = Theme.shared
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(theme.primaryColor)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(theme.textColor)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(theme.secondaryTextColor)
                    .font(.caption)
            }
            .padding()
        }
    }
}

struct ToggleSettingsRow: View {
    @ObservedObject var theme = Theme.shared
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(theme.primaryColor)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(theme.textColor)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding()
    }
}

struct User {
    let id: String
    let name: String
    let email: String
    let profileImageURL: String
    let joinedClubs: [String]
    let attendingEvents: [String]
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
} 