import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct LoginView: View {
    @StateObject private var theme = Theme.shared
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isAnimating: Bool = false
    @State private var userData: [String: Any]? = nil // Giriş yapan kullanıcının Firestore verisi
    @State private var showResetAlert: Bool = false
    @State private var resetMessage: String = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Logo ve Başlık
                VStack(spacing: 15) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(theme.primaryColor)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: isAnimating)
                    
                    Text("VIBE")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.primaryColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                .padding(.top, 50)
                
                // Giriş Formu
                VStack(spacing: 20) {
                    // E-posta
                    LoginTextField(
                        title: "E-posta",
                        placeholder: "E-posta adresiniz",
                        text: $email,
                        icon: "envelope.fill"
                    )
                    
                    // Şifre
                    LoginTextField(
                        title: "Şifre",
                        placeholder: "Şifreniz",
                        text: $password,
                        icon: "lock.fill",
                        isSecure: true
                    )
                    
                    // Giriş Yap Butonu
                    Button(action: login) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Giriş Yap")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [theme.primaryColor, theme.primaryColor.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(color: theme.primaryColor.opacity(0.3), radius: 5)
                    }
                    .disabled(isLoading || !isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.6)
                    
                    // Şifremi Unuttum Butonu
                    Button(action: sendPasswordReset) {
                        Text("Şifremi Unuttum")
                            .foregroundColor(theme.primaryColor)
                            .font(.subheadline)
                    }
                    .disabled(email.isEmpty)
                    
                    // Kayıt Ol Linki
                    NavigationLink(destination: RegisterView()) {
                        Text("Hesabın yok mu? Kayıt ol")
                            .foregroundColor(theme.primaryColor)
                            .font(.subheadline)
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
                // Giriş başarılıysa kullanıcı verisini göster (örnek)
                if let userData = userData {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Hoş geldin, \(userData["displayName"] as? String ?? "")!")
                            .font(.headline)
                        Text("E-posta: \(userData["email"] as? String ?? "")")
                        Text("Rol: \(userData["role"] as? String ?? "")")
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
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
        .alert("Hata", isPresented: $showError) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .alert("Şifre Sıfırlama", isPresented: $showResetAlert) {
            Button("Tamam", role: .cancel) {}
        } message: {
            Text(resetMessage)
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            guard let user = result?.user else {
                isLoading = false
                errorMessage = "Kullanıcı bulunamadı."
                showError = true
                return
            }
            let docRef = Firestore.firestore().collection("users").document(user.uid)
            docRef.getDocument { snapshot, error in
                if let error = error {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                if let data = snapshot?.data() {
                    // Firestore'dan gelen güncel kullanıcı verisiyle UserSession'ı güncelle
                    isLoading = false
                    let appUser = AppUser(
                        id: user.uid,
                        displayName: data["displayName"] as? String ?? "",
                        email: data["email"] as? String ?? "",
                        photoURL: data["photoURL"] as? String ?? "",
                        role: data["role"] as? String ?? "user",
                        clubIds: data["clubIds"] as? [String] ?? [],
                        createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
                        updatedAt: (data["updatedAt"] as? Timestamp)?.dateValue()
                    )
                    UserSession.shared.currentUser = appUser
                    // Girişten sonra başka yerde eski AppUser ile overwrite etme!
                } else {
                    // Kullanıcı verisi yok, otomatik oluştur
                    let now: Timestamp = Timestamp(date: Date())
                    let userData: [String: Any] = [
                        "displayName": user.displayName ?? "",
                        "email": user.email ?? "",
                        "photoURL": user.photoURL?.absoluteString ?? "",
                        "role": "user",
                        "clubIds": [],
                        "createdAt": now,
                        "updatedAt": now
                    ]
                    docRef.setData(userData) { error in
                        isLoading = false
                        if let error = error {
                            errorMessage = "Kullanıcı profili oluşturulamadı: \(error.localizedDescription)"
                            showError = true
                            return
                        }
                        let appUser = AppUser(
                            id: user.uid,
                            displayName: user.displayName ?? "",
                            email: user.email ?? "",
                            photoURL: user.photoURL?.absoluteString ?? "",
                            role: "user",
                            clubIds: [],
                            createdAt: now.dateValue(),
                            updatedAt: now.dateValue()
                        )
                        UserSession.shared.currentUser = appUser
                    }
                }
            }
        }
    }
    
    private func sendPasswordReset() {
        guard !email.isEmpty else { return }
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    resetMessage = "Hata: \(error.localizedDescription)"
                } else {
                    resetMessage = "Şifre sıfırlama e-postası gönderildi. Lütfen e-posta kutunu kontrol et."
                }
                showResetAlert = true
            }
        }
    }
}

struct LoginTextField: View {
    @ObservedObject var theme = Theme.shared
    let title: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    var isSecure: Bool = false
    
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.textColor)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(theme.primaryColor)
                if isSecure {
                    ZStack(alignment: .trailing) {
                        Group {
                            if isPasswordVisible {
                                TextField(placeholder, text: $text)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField(placeholder, text: $text)
                            }
                        }
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.white)
                        Button(action: { isPasswordVisible.toggle() }) {
                            Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                        .padding(.trailing, 8)
                    }
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(title.lowercased().contains("mail") ? .emailAddress : .default)
                        .autocapitalization(.none)
                        .disableAutocorrection(title.lowercased().contains("mail"))
                        .foregroundColor(.primary)
                        .padding(8)
                        .background(Color.white)
                }
            }
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            LoginView()
        }
    }
} 
