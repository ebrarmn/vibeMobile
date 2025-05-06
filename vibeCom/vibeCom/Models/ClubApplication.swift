import Foundation

struct ClubApplication: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let targetAudience: String
    let activities: String
    let createdBy: String
    let createdAt: Date
} 