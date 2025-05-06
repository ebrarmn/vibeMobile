import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import Foundation

struct ClubRegistrationView: View {
    @StateObject private var theme = Theme.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var clubName = ""
    @State private var clubPurpose = ""
    @State private var targetAudience = ""
    @State private var activities = ""
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Başlık
                Text("Kulüp Kurma Başvurusu")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(theme.textColor)
                    .padding(.top)
                
                // Form Alanları
                VStack(spacing: 20) {
                    // Kulüp Adı
                    FormField(
                        title: "Kulübün adı ne olacak?",
                        placeholder: "Örn: Yazılım Kulübü",
                        text: $clubName
                    )
                    
                    // Kulüp Amacı
                    FormField(
                        title: "Kulübün amacı nedir?",
                        placeholder: "Neden böyle bir kulüp kurmak istiyorsun?",
                        text: $clubPurpose,
                        isMultiline: true
                    )
                    
                    // Hedef Kitle
                    FormField(
                        title: "Hedef kitlen kim?",
                        placeholder: "Kimlere hitap edecek?",
                        text: $targetAudience,
                        isMultiline: true
                    )
                    
                    // Faaliyetler
                    FormField(
                        title: "Kulübün faaliyetleri neler olacak?",
                        placeholder: "Etkinlik, seminer, atölye vs. planı var mı?",
                        text: $activities,
                        isMultiline: true
                    )
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
                
                // Gönder Butonu
                Button(action: submitForm) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Başvuruyu Gönder")
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
                .padding(.horizontal)
                .disabled(isSubmitting || !isFormValid)
                .opacity(isFormValid ? 1.0 : 0.6)
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
        .navigationBarTitleDisplayMode(.inline)
        .alert("Başvuru Başarılı", isPresented: $showSuccessAlert) {
            Button("Tamam") {
                dismiss()
            }
        } message: {
            Text("Kulüp başvurunuz başarıyla alındı. En kısa sürede size dönüş yapılacaktır.")
        }
        .onAppear {
            withAnimation {
                isAnimating = true
            }
        }
    }
    
    private var isFormValid: Bool {
        !clubName.isEmpty && !clubPurpose.isEmpty && !targetAudience.isEmpty && !activities.isEmpty
    }
    
    private func submitForm() {
        guard let userId = UserSession.shared.currentUser?.id else { return }
        isSubmitting = true
        let application = ClubApplication(
            id: UUID().uuidString,
            name: clubName,
            description: clubPurpose,
            targetAudience: targetAudience,
            activities: activities,
            createdBy: userId,
            createdAt: Date()
        )
        saveApplicationToFirestore(application: application)
    }

    private func saveApplicationToFirestore(application: ClubApplication) {
        let db: Firestore = Firestore.firestore()
        do {
            try db.collection("pendingClubs").document(application.id).setData(from: application) { error in
                DispatchQueue.main.async {
                    isSubmitting = false
                    if let error = error {
                        // Hata mesajı göster
                        print("Başvuru kaydedilemedi: \(error.localizedDescription)")
                    } else {
                        clubName = ""
                        clubPurpose = ""
                        targetAudience = ""
                        activities = ""
                        showSuccessAlert = true
                    }
                }
            }
        } catch {
            isSubmitting = false
            print("Firestore encode hatası: \(error.localizedDescription)")
        }
    }
}

struct FormField: View {
    @ObservedObject var theme = Theme.shared
    let title: String
    let placeholder: String
    @Binding var text: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(theme.textColor)
            
            if isMultiline {
                TextEditor(text: $text)
                    .frame(height: 100)
                    .padding(8)
                    .background(theme.backgroundColor)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(theme.primaryColor.opacity(0.3), lineWidth: 1)
                    )
            } else {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .background(theme.backgroundColor)
            }
        }
    }
}

struct ClubRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ClubRegistrationView()
        }
    }
} 