import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct RegisterView: View {
    @StateObject private var theme = Theme.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isLoading: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Başlık
                Text("Yeni Hesap Oluştur")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)
                    .padding(.top)
                
                // Kayıt Formu
                VStack(spacing: 20) {
                    LoginTextField(
                        title: "Ad Soyad",
                        placeholder: "Adınız ve soyadınız",
                        text: $name,
                        icon: "person.fill"
                    )
                    LoginTextField(
                        title: "E-posta",
                        placeholder: "E-posta adresiniz",
                        text: $email,
                        icon: "envelope.fill"
                    )
                    LoginTextField(
                        title: "Şifre",
                        placeholder: "Şifreniz",
                        text: $password,
                        icon: "lock.fill",
                        isSecure: true
                    )
                    LoginTextField(
                        title: "Şifre Tekrar",
                        placeholder: "Şifrenizi tekrar girin",
                        text: $confirmPassword,
                        icon: "lock.fill",
                        isSecure: true
                    )
                    Button(action: register) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Kayıt Ol")
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
                    NavigationLink(destination: LoginView()) {
                        Text("Zaten hesabın var mı? Giriş yap")
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
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword
    }
    
    private func register() {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = ""
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                isLoading = false
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            guard let user = result?.user else {
                isLoading = false
                errorMessage = "Kullanıcı oluşturulamadı."
                showError = true
                return
            }
            let now = Timestamp(date: Date())
            let userData: [String: Any] = [
                "displayName": name,
                "email": email,
                "photoURL": "",
                "role": "user",
                "clubIds": [],
                "createdAt": now,
                "updatedAt": now
            ]
            Firestore.firestore().collection("users").document(user.uid).setData(userData) { error in
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                } else {
                    dismiss()
                }
            }
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView()
        }
    }
} 