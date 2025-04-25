import Foundation

struct Club: Identifiable {
    let id: String
    let name: String
    let description: String
    let logoURL: String
    let members: [String]
    let events: [String]
    let socialMedia: [String: String]
} 