import SwiftUI

class Theme: ObservableObject {
    @Published var isDarkMode: Bool = false
    
    // Renkler
    var primaryColor: Color {
        Color.red
    }
    
    var backgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var textColor: Color {
        isDarkMode ? Color.white : Color.black
    }
    
    var secondaryTextColor: Color {
        isDarkMode ? Color.gray : Color.gray
    }
    
    var cardBackgroundColor: Color {
        isDarkMode ? Color.black : Color.white
    }
    
    var cardShadowColor: Color {
        isDarkMode ? Color.red.opacity(0.3) : Color.gray.opacity(0.2)
    }
    
    // Singleton instance
    static let shared = Theme()
    
    private init() {}
} 