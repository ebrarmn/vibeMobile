import SwiftUI

struct RegisterView: View {
    @StateObject private var theme = Theme.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isAnimating = false
    
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
                    // Ad Soyad
                    LoginTextField(
                        title: "Ad Soyad",
                        placeholder: "Adınız ve soyadınız",
                        text: $name,
                        icon: "person.fill"
                    )
                    
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
                    
                    // Şifre Tekrar
                    LoginTextField(
                        title: "Şifre Tekrar",
                        placeholder: "Şifrenizi tekrar girin",
                        text: $confirmPassword,
                        icon: "lock.fill",
                        isSecure: true
                    )
                    
                    // Kayıt Ol Butonu
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
                    
                    // Giriş Yap Linki
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
        isLoading = true
        
        // Simüle edilmiş API çağrısı
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            // Başarılı kayıt sonrası giriş sayfasına yönlendir
            dismiss()
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