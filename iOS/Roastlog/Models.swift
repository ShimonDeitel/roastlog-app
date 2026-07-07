import Foundation

struct Batch: Identifiable, Codable, Equatable {
    let id: UUID
    var date: Date
    var origin: String
    var roastLevel: String
    var notes: String
    var rating: Int

    init(id: UUID = UUID(), date: Date = Date(), origin: String, roastLevel: String, notes: String, rating: Int = 3) {
        self.id = id
        self.date = date
        self.origin = origin
        self.roastLevel = roastLevel
        self.notes = notes
        self.rating = rating
    }
}
