import SwiftUI
import FirebaseFirestore

struct EventCreateView: View {
    let clubId: String
    var onSave: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    @State private var eventName: String = ""
    @State private var eventDescription: String = ""
    @State private var eventStartDate: Date = Date()
    @State private var eventEndDate: Date = Date()
    @State private var eventLocation: String = ""
    @State private var selectedCategory: EventCategory = .social
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Etkinlik Bilgileri")) {
                    TextField("Etkinlik Adı", text: $eventName)
                    TextField("Açıklama", text: $eventDescription)
                    TextField("Konum", text: $eventLocation)
                    DatePicker("Başlangıç Tarihi", selection: $eventStartDate, displayedComponents: [.date, .hourAndMinute])
                    DatePicker("Bitiş Tarihi", selection: $eventEndDate, displayedComponents: [.date, .hourAndMinute])
                    
                    Picker("Kategori", selection: $selectedCategory) {
                        ForEach(EventCategory.allCases, id: \.self) { category in
                            Label(category.rawValue, systemImage: category.icon)
                                .tag(category)
                        }
                    }
                }
                
                Section {
                    Button(action: createEvent) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Text("Etkinlik Oluştur")
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(eventName.isEmpty || eventDescription.isEmpty || eventLocation.isEmpty || isLoading)
                    .listRowBackground(Color.blue)
                }
            }
            .navigationTitle("Yeni Etkinlik")
            .navigationBarItems(trailing: Button("İptal") {
                presentationMode.wrappedValue.dismiss()
            })
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("Hata"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("Tamam"))
                )
            }
        }
    }
    
    private func createEvent() {
        isLoading = true
        
        let db = Firestore.firestore()
        let eventRef = db.collection("events").document()
        
        let eventData: [String: Any] = [
            "id": eventRef.documentID,
            "title": eventName,
            "description": eventDescription,
            "startDate": Timestamp(date: eventStartDate),
            "endDate": Timestamp(date: eventEndDate),
            "location": eventLocation,
            "clubId": clubId,
            "category": selectedCategory.rawValue,
            "attendees": [],
            "createdAt": Timestamp(date: Date())
        ]
        
        // Batch işlemi başlat
        let batch = db.batch()
        
        // Etkinliği oluştur
        batch.setData(eventData, forDocument: eventRef)
        
        // Kulübün etkinlikler listesini güncelle
        let clubRef = db.collection("clubs").document(clubId)
        batch.updateData([
            "events": FieldValue.arrayUnion([eventRef.documentID])
        ], forDocument: clubRef)
        
        // Batch işlemini commit et
        batch.commit { error in
            isLoading = false
            
            if let error = error {
                errorMessage = "Etkinlik oluşturulurken bir hata oluştu: \(error.localizedDescription)"
                showError = true
            } else {
                onSave()
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
} 