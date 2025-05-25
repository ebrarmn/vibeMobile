import Foundation

enum EventCategory: String, Codable, CaseIterable {
    case all = "Tümü"
    case technology = "Teknoloji"
    case business = "İş Dünyası"
    case art = "Sanat"
    case music = "Müzik"
    case sports = "Spor"
    case social = "Sosyal"
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .technology: return "laptopcomputer"
        case .business: return "briefcase"
        case .art: return "paintpalette"
        case .music: return "music.note"
        case .sports: return "sportscourt"
        case .social: return "person.3"
        }
    }
}

struct Event: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let startDate: Date
    let endDate: Date
    let location: String
    let clubId: String
    let imageURL: String
    let attendees: [String]
    let category: EventCategory
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case startDate
        case endDate
        case location
        case clubId = "club_id"
        case imageURL = "image_url"
        case attendees
        case category
    }
} 