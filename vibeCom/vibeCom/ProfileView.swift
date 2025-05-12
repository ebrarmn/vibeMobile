import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

#if os(iOS)
import UIKit
struct CustomImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CustomImagePicker
        
        init(_ parent: CustomImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
#elseif os(macOS)
import AppKit
struct CustomImagePicker: NSViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    
    func makeNSViewController(context: Context) -> NSViewController {
        let viewController = NSViewController()
        DispatchQueue.main.async {
            let panel = NSOpenPanel()
            panel.allowedFileTypes = ["png", "jpg", "jpeg", "heic"]
            panel.allowsMultipleSelection = false
            panel.canChooseDirectories = false
            if panel.runModal() == .OK, let url = panel.url, let nsImage = NSImage(contentsOf: url) {
                let rep = NSBitmapImageRep(data: nsImage.tiffRepresentation!)
                if let data = rep?.representation(using: .jpeg, properties: [:]), let uiImage = UIImage(data: data) {
                    selectedImage = uiImage
                }
            }
        }
        return viewController
    }
    func updateNSViewController(_ nsViewController: NSViewController, context: Context) {}
}
#endif

struct ProfileView: View {
    @StateObject private var theme = Theme.shared
    @ObservedObject private var userSession = UserSession.shared
    @State private var allClubs: [Club] = []
    @State private var allEvents: [Event] = []
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var emailNotifications = true
    @State private var pushNotifications = true
    @State private var isAnimating = false
    @State private var selectedLanguage = "Türkçe"
    @State private var showLanguagePicker = false
    @State private var showingEditProfile = false
    @State private var editedName = ""
    @State private var editedEmail = ""
    @State private var showingImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var showingAdminPanel = false
    @State private var showingLogoutAlert = false
    @State private var isLoggedOut = false
    
    var body: some View {
        NavigationView {
            if let user = userSession.currentUser {
                ScrollView {
                    VStack(spacing: 20) {
                        profileHeader(user: user)
                        tabPicker(user: user)
                        tabContent(user: user)
                    }
                    .padding(.vertical)
                }
                .background(profileBackground)
                .navigationTitle("Profil")
                .toolbar { }
                .alert("Çıkış Yap", isPresented: $showingLogoutAlert) {
                    Button("İptal", role: .cancel) { }
                    Button("Çıkış Yap", role: .destructive) {
                        logout()
                    }
                } message: {
                    Text("Uygulamadan çıkış yapıyorsunuz. Emin misiniz?")
                }
                .onAppear {
                    loadUserClubs()
                    loadUserAttendingEvents()
                    loadAllEvents()
                    // Kullanıcı ID'sini debug konsoluna yazdır
                    if let userId = userSession.currentUser?.id {
                        print("[DEBUG] Uygulamadaki user.id: \(userId)")
                    } else {
                        print("[DEBUG] Uygulamadaki user.id: nil")
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear { withAnimation { isAnimating = true } }
        .fullScreenCover(isPresented: $isLoggedOut) {
            LoginView()
        }
        .sheet(isPresented: $showLanguagePicker) {
            NavigationView {
                List {
                    ForEach(["Türkçe", "English", "Deutsch", "Français", "Español"], id: \.self) { language in
                            Button(action: {
                            selectedLanguage = language
                            showLanguagePicker = false
                        }) {
                            HStack {
                                Text(language)
                                    .foregroundColor(theme.textColor)
                                
                                Spacer()
                                
                                if language == selectedLanguage {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(theme.primaryColor)
                                }
                            }
                        }
                    }
                            }
                .navigationTitle("Dil Seçimi")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kapat") {
                            showLanguagePicker = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingEditProfile) {
            NavigationView {
                Form {
                    Section(header: Text("Profil Bilgileri")) {
                        TextField("Ad Soyad", text: $editedName)
                        TextField("E-posta", text: $editedEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                    }
                    
                    Section {
                        Button(action: saveProfileChanges) {
                            Text("Değişiklikleri Kaydet")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(theme.primaryColor)
                        }
                    }
                }
                .navigationTitle("Profil Düzenle")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Kapat") {
                            showingEditProfile = false
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingImagePicker, onDismiss: uploadProfileImage) {
            CustomImagePicker(selectedImage: $selectedImage)
        }
    }
    
    @ViewBuilder
    private func profileHeader(user: AppUser) -> some View {
        VStack(spacing: 15) {
            Button(action: { showingImagePicker = true }) {
                profileImageView(url: user.photoURL)
                            }
                            VStack(spacing: 8) {
                Text(user.displayName)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(theme.textColor)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(theme.secondaryTextColor)
                            }
                        }
                        .padding()
        .background(profileHeaderBackground)
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
    }
                        
    @ViewBuilder
    private func tabPicker(user: AppUser) -> some View {
                        Picker("Seçim", selection: $selectedTab) {
                            Text("Kulüpler").tag(0)
                            Text("Etkinlikler").tag(1)
                            Text("Ayarlar").tag(2)
            if user.role == "admin" {
                                Text("Admin").tag(3)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func tabContent(user: AppUser) -> some View {
        switch selectedTab {
        case 0:
                            // Kulüpler
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                    Text("Kulüplerim")
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
                // Başkan olduğu kulüpler
                let leaderClubs = allClubs.filter { $0.leaderID == userSession.currentUser?.id }
                if !leaderClubs.isEmpty {
                    Text("Başkan Olduğum Kulüpler")
                        .font(.headline)
                        .padding(.horizontal)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                            ForEach(leaderClubs) { club in
                                            NavigationLink(destination: ClubDetailView(club: club)) {
                                                VStack(spacing: 10) {
                                                    Image(systemName: "person.3.fill")
                                                        .font(.system(size: 30))
                                                        .foregroundColor(.purple)
                                                        .frame(width: 60, height: 60)
                                                        .background(Color.purple.opacity(0.1))
                                                    Text(club.name)
                                                        .font(.subheadline)
                                                        .fontWeight(.medium)
                                                        .lineLimit(1)
                                        Text("Başkan")
                                            .font(.caption)
                                            .foregroundColor(.purple)
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
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                // Üye olduğu kulüpler
                let memberClubs = allClubs.filter { $0.leaderID != userSession.currentUser?.id }
                if !memberClubs.isEmpty {
                    Text("Katıldığım Kulüpler")
                        .font(.headline)
                        .padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(memberClubs) { club in
                                NavigationLink(destination: ClubDetailView(club: club)) {
                                    VStack(spacing: 10) {
                                        Image(systemName: "person.3.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.blue)
                                            .frame(width: 60, height: 60)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Circle())
                                        Text(club.name)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .lineLimit(1)
                                        Text("Üye")
                                            .font(.caption)
                                            .foregroundColor(.blue)
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
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                    }
                                }
                            }
        case 1:
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
                                
                                // Katıldığı ve tarihi geçmemiş etkinlikler
                                let upcomingAttendingEvents = userSession.attendingEvents.compactMap { eventId in
                                    allEvents.first(where: { $0.id == eventId && $0.date >= Date() })
                                }
                                VStack(spacing: 15) {
                                    ForEach(Array(upcomingAttendingEvents.enumerated()), id: \.element.id) { index, event in
                                        NavigationLink(destination: EventDetailView(event: event)) {
                                            HStack(spacing: 15) {
                                                Image(systemName: "calendar")
                                                    .font(.title2)
                                                    .foregroundColor(.purple)
                                                    .frame(width: 40, height: 40)
                                                    .background(Color.purple.opacity(0.1))
                                                    .clipShape(Circle())
                                                
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(event.title)
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
                                }
                                .padding(.horizontal)
                                // Geçmişte katıldığı etkinlikler
                                HStack {
                                    Text("Geçmişte Katıldığım Etkinlikler")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal)
                                    Spacer()
                                }
                                let pastAttendingEvents = userSession.attendingEvents.compactMap { eventId in
                                    allEvents.first(where: { $0.id == eventId && $0.date < Date() })
                                }
                                VStack(spacing: 15) {
                                    ForEach(Array(pastAttendingEvents.enumerated()), id: \.element.id) { index, event in
                                        NavigationLink(destination: EventDetailView(event: event)) {
                                            HStack(spacing: 15) {
                                                Image(systemName: "calendar")
                                                    .font(.title2)
                                                    .foregroundColor(.gray)
                                                    .frame(width: 40, height: 40)
                                                    .background(Color.gray.opacity(0.1))
                                                    .clipShape(Circle())
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(event.title)
                                                        .font(.headline)
                                                    Text("Geçmiş Etkinlik")
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
                                }
                                .padding(.horizontal)
                            }
        case 2:
                            // Ayarlar Bölümü
                            VStack(spacing: 20) {
                                // Hesap Ayarları
                                SettingsSection(title: "Hesap Ayarları") {
                                    Button(action: {
                        editedName = user.displayName
                                        editedEmail = user.email
                                        showingEditProfile = true
                                    }) {
                                        HStack {
                                            Image(systemName: "person.fill")
                                                .foregroundColor(theme.primaryColor)
                                                .frame(width: 30)
                                            
                                            Text("Profil Düzenle")
                                                .foregroundColor(theme.textColor)
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(theme.secondaryTextColor)
                                                .font(.caption)
                                        }
                                        .padding()
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
                                    
                                    Button(action: {
                                        showLanguagePicker = true
                                    }) {
                                        HStack {
                                            Image(systemName: "globe")
                                                .foregroundColor(theme.primaryColor)
                                                .frame(width: 30)
                                            
                                            Text("Dil")
                                                .foregroundColor(theme.textColor)
                                            
                                            Spacer()
                                            
                                            Text(selectedLanguage)
                                                .foregroundColor(theme.secondaryTextColor)
                                                .font(.subheadline)
                                            
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(theme.secondaryTextColor)
                                                .font(.caption)
                                        }
                                        .padding()
                                    }
                                    
                                    SettingsRow(icon: "questionmark.circle.fill", title: "Yardım ve Destek") {
                                        // TODO: Yardım sayfası
                                    }
                                }
                                
                                // Çıkış Yap
                                Button(action: {
                                    showingLogoutAlert = true
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
                                
                                // Kulüp Kurma Linki
                                NavigationLink(destination: ClubRegistrationView()) {
                                    HStack {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(theme.primaryColor)
                                        Text("Kulüp Kurmak İstiyorum")
                                            .foregroundColor(theme.primaryColor)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(theme.primaryColor.opacity(0.1))
                                    .cornerRadius(10)
                                }
                                .padding(.horizontal)
                            }
        case 3:
            if user.role == "admin" {
                            // Admin Paneli
                            VStack(spacing: 20) {
                                // Admin İstatistikleri
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Admin İstatistikleri")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            AdminStatCard(
                                                title: "Toplam Kulüp",
                                                value: "12",
                                                icon: "person.3.fill",
                                                color: .blue
                                            )
                                            
                                            AdminStatCard(
                                                title: "Toplam Etkinlik",
                                                value: "25",
                                                icon: "calendar",
                                                color: .green
                                            )
                                            
                                            AdminStatCard(
                                                title: "Toplam Kullanıcı",
                                                value: "150",
                                                icon: "person.fill",
                                                color: .purple
                                            )
                                            
                                            AdminStatCard(
                                                title: "Bekleyen Onaylar",
                                                value: "5",
                                                icon: "clock.fill",
                                                color: .orange
                                            )
                                            
                                            AdminStatCard(
                                                title: "Aktif Etkinlikler",
                                                value: "8",
                                                icon: "star.fill",
                                                color: .yellow
                                            )
                                            
                                            AdminStatCard(
                                                title: "Toplam Başvuru",
                                                value: "45",
                                                icon: "doc.fill",
                                                color: .red
                                            )
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                                
                                // Hızlı İşlemler
                                VStack(alignment: .leading, spacing: 15) {
                                    Text("Yönetim Paneli")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.horizontal)
                                    
                                    VStack(spacing: 15) {
                                        // Kulüp Yönetimi
                                        AdminSection(title: "Kulüp Yönetimi") {
                                            AdminActionButton(
                                                title: "Kulüp Onayları",
                                                subtitle: "5 bekleyen onay",
                                                icon: "checkmark.circle.fill",
                                                color: .blue
                                            ) {
                                                // Kulüp onayları işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Kulüp Listesi",
                                                subtitle: "12 aktif kulüp",
                                                icon: "list.bullet",
                                                color: .blue
                                            ) {
                                                // Kulüp listesi işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Kulüp İstatistikleri",
                                                subtitle: "Detaylı analiz",
                                                icon: "chart.bar.fill",
                                                color: .blue
                                            ) {
                                                // Kulüp istatistikleri işlemi
                                            }
                                        }
                                        
                                        // Etkinlik Yönetimi
                                        AdminSection(title: "Etkinlik Yönetimi") {
                                            AdminActionButton(
                                                title: "Etkinlik Onayları",
                                                subtitle: "3 bekleyen onay",
                                                icon: "calendar.badge.plus",
                                                color: .green
                                            ) {
                                                // Etkinlik onayları işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Etkinlik Takvimi",
                                                subtitle: "Tüm etkinlikler",
                                                icon: "calendar",
                                                color: .green
                                            ) {
                                                // Etkinlik takvimi işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Etkinlik İstatistikleri",
                                                subtitle: "Katılım analizi",
                                                icon: "chart.pie.fill",
                                                color: .green
                                            ) {
                                                // Etkinlik istatistikleri işlemi
                                            }
                                        }
                                        
                                        // Kullanıcı Yönetimi
                                        AdminSection(title: "Kullanıcı Yönetimi") {
                                            AdminActionButton(
                                                title: "Kullanıcı Listesi",
                                                subtitle: "150 kayıtlı kullanıcı",
                                                icon: "person.2.fill",
                                                color: .purple
                                            ) {
                                                // Kullanıcı listesi işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Yetki Yönetimi",
                                                subtitle: "Admin atamaları",
                                                icon: "key.fill",
                                                color: .purple
                                            ) {
                                                // Yetki yönetimi işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Kullanıcı İstatistikleri",
                                                subtitle: "Aktivite analizi",
                                                icon: "chart.line.uptrend.xyaxis",
                                                color: .purple
                                            ) {
                                                // Kullanıcı istatistikleri işlemi
                                            }
                                        }
                                        
                                        // Sistem Yönetimi
                                        AdminSection(title: "Sistem Yönetimi") {
                                            AdminActionButton(
                                                title: "Genel Ayarlar",
                                                subtitle: "Sistem konfigürasyonu",
                                                icon: "gear",
                                                color: .orange
                                            ) {
                                                // Genel ayarlar işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Bildirim Yönetimi",
                                                subtitle: "Toplu bildirimler",
                                                icon: "bell.fill",
                                                color: .orange
                                            ) {
                                                // Bildirim yönetimi işlemi
                                            }
                                            
                                            AdminActionButton(
                                                title: "Sistem Logları",
                                                subtitle: "Hata ve aktivite kayıtları",
                                                icon: "doc.text.fill",
                                                color: .orange
                                            ) {
                                                // Sistem logları işlemi
                                            }
                                        }
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
        default:
            EmptyView()
                    }
                }
    
    private var profileBackground: some View {
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
    }
    
    private var profileHeaderBackground: some View {
        LinearGradient(
            colors: [theme.cardBackgroundColor, theme.cardBackgroundColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    @ViewBuilder
    private func profileImageView(url: String) -> some View {
        if let selectedImage = selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 120, height: 120)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(
                        LinearGradient(
                            colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3
                    )
                )
                .overlay(
                    Circle()
                        .fill(Color.black.opacity(0.3))
                        .overlay(
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                        )
                        .opacity(isAnimating ? 1 : 0)
                )
                .shadow(radius: 10)
                .scaleEffect(isAnimating ? 1.0 : 0.9)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
        } else {
        AsyncImage(url: URL(string: url)) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Image(systemName: "person.circle.fill")
                .resizable()
                .foregroundColor(theme.primaryColor.opacity(0.3))
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(
            Circle().stroke(
                LinearGradient(
                    colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 3
            )
        )
        .overlay(
            Circle()
                .fill(Color.black.opacity(0.3))
                .overlay(
                    Image(systemName: "camera.fill")
                        .foregroundColor(.white)
                )
                .opacity(isAnimating ? 1 : 0)
        )
        .shadow(radius: 10)
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
        }
    }
    
    @ViewBuilder
    private func profileStatView(title: String, value: String, delay: Double) -> some View {
        VStack {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(
                    LinearGradient(
                        colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            Text(title)
                .font(.caption)
                .foregroundColor(theme.secondaryTextColor)
        }
        .scaleEffect(isAnimating ? 1.0 : 0.9)
        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(delay), value: isAnimating)
    }
    
    private func saveProfileChanges() {
        // Simüle edilmiş API çağrısı
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            // Kullanıcı bilgilerinin güncellenmesi işlemi
            showingEditProfile = false
        }
    }
    
    private func logout() {
        do {
            try Auth.auth().signOut()
            userSession.currentUser = nil
            userSession.userId = ""
            userSession.joinedClubs = []
            userSession.attendingEvents = []
            isLoggedOut = true
        } catch {
            print("Çıkış yapılırken hata oluştu: \(error.localizedDescription)")
        }
    }
    
    private func loadUserClubs() {
        guard let userId = userSession.currentUser?.id else { return }
        
        let db = Firestore.firestore()
        db.collection("clubs")
            .whereField("memberIds", arrayContains: userId)
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    allClubs = documents.compactMap { doc in
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
    
    private func loadUserAttendingEvents() {
        guard let userId = userSession.currentUser?.id else { return }
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let data = snapshot?.data(), let eventIds = data["attendingEvents"] as? [String] {
                DispatchQueue.main.async {
                    userSession.attendingEvents = eventIds
                }
            }
        }
    }
    
    private func loadAllEvents() {
        let db = Firestore.firestore()
        db.collection("events").getDocuments { snapshot, error in
            if let documents = snapshot?.documents {
                let events = documents.compactMap { doc -> Event? in
                    let data = doc.data()
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
                DispatchQueue.main.async {
                    allEvents = events
                }
            }
        }
    }
    
    private func uploadProfileImage() {
        print("Profil fotoğrafı yükleniyor...")
        guard let image = selectedImage, let user = userSession.currentUser else { print("Seçili resim veya kullanıcı yok"); return }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { print("Resim verisi alınamadı"); return }
        let storageRef = Storage.storage().reference().child("profileImages/")
            .child("\(user.id).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Storage'a yüklenemedi: \(error.localizedDescription)")
                return
            }
            print("Storage'a yüklendi!")
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Download URL alınamadı: \(error.localizedDescription)")
                    return
                }
                guard let downloadURL = url else { print("Download URL yok"); return }
                print("Download URL: \(downloadURL.absoluteString)")
                // Firestore'da photoURL alanını updateData ile güncelle
                let db = Firestore.firestore()
                db.collection("users").document(user.id).updateData([
                    "photoURL": downloadURL.absoluteString
                ]) { error in
                    if let error = error {
                        print("Firestore'a photoURL update edilemedi: \(error.localizedDescription)")
                    } else {
                        print("Firestore'a photoURL update edildi! (Güncel Storage linki)")
                    }
                    // UserSession'da güncelle (Firestore'a yazılamasa bile localde güncel tut)
                    DispatchQueue.main.async {
                        var updatedUser = user
                        updatedUser.photoURL = downloadURL.absoluteString
                        userSession.currentUser = updatedUser
                        print("UserSession güncellendi!")
                    }
                }
            }
        }
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
    let isAdmin: Bool
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

// Admin Panel için Yardımcı Görünümler
struct AdminStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

struct AdminSection<Content: View>: View {
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
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            VStack(spacing: 10) {
                content
            }
        }
    }
}

struct AdminActionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
        }
    }
} 
