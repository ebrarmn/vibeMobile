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
    @State private var showResetAlert: Bool = false
    @State private var resetMessage: String = ""
    @State private var faculty: String = ""
    @State private var gender: String = ""
    @State private var grade: String = ""
    @State private var phone: String = ""
    @State private var phoneError: String? = nil
    @State private var university: String = ""
    @State private var department: String = ""
    
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
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cinsiyet")
                            .font(.headline)
                        Picker("Cinsiyet", selection: $gender) {
                            Text("Kız").tag("Kız")
                            Text("Erkek").tag("Erkek")
                            Text("Belirtmek İstemiyorum").tag("Belirtmek İstemiyorum")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
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
                    LoginTextField(
                        title: "Telefon",
                        placeholder: "05XXXXXXXXX",
                        text: Binding(
                            get: { phone },
                            set: { newValue in
                                // Sadece rakamları al
                                let filtered = newValue.filter { $0.isNumber }
                                // Maksimum 11 karakter
                                let limited = String(filtered.prefix(11))
                                // Başında 0 yoksa ekle
                                if !limited.isEmpty && !limited.hasPrefix("0") {
                                    phone = "0" + limited.prefix(10)
                                } else {
                                    phone = limited
                                }
                                // Hata kontrolü
                                if phone.count != 11 {
                                    phoneError = "Telefon numarası 11 haneli olmalı."
                                } else {
                                    phoneError = nil
                                }
                            }
                        ),
                        icon: "phone.fill",
                        keyboardType: .numberPad
                    )
                    if let phoneError = phoneError {
                        Text(phoneError)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    LoginTextField(
                        title: "Üniversite",
                        placeholder: "Üniversite adınız",
                        text: $university,
                        icon: "graduationcap"
                    )
                    LoginTextField(
                        title: "Fakülte",
                        placeholder: "Fakülte adınız",
                        text: $faculty,
                        icon: "building.columns"
                    )
                    LoginTextField(
                        title: "Bölüm",
                        placeholder: "Bölüm adınız",
                        text: $department,
                        icon: "book"
                    )
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Sınıf")
                            .font(.headline)
                        Picker("Sınıf", selection: $grade) {
                            Text("Hazırlık").tag("Hazırlık")
                            Text("1").tag("1")
                            Text("2").tag("2")
                            Text("3").tag("3")
                            Text("4").tag("4")
                            Text("5").tag("5")
                            Text("6").tag("6")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
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
                    // Şifremi Unuttum Butonu
                    Button(action: sendPasswordReset) {
                        Text("Şifremi Unuttum")
                            .foregroundColor(theme.primaryColor)
                            .font(.subheadline)
                    }
                    .disabled(email.isEmpty)
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
        !name.isEmpty && !email.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && password == confirmPassword && !faculty.isEmpty && !gender.isEmpty && !grade.isEmpty && !phone.isEmpty && !university.isEmpty && !department.isEmpty && phone.count == 11 && phone.hasPrefix("0")
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
                "phone": phone,
                "faculty": faculty,
                "department": department,
                "university": university,
                "grade": grade,
                "gender": gender,
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

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView()
        }
    }
} 