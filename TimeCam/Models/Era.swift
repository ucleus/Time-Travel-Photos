import Foundation

struct Era: Identifiable, Equatable {
    let id: UUID
    let name: String
    let year: Int
    let description: String
    let filterPresets: [FilterPreset]

    init(id: UUID = UUID(), name: String, year: Int, description: String, filterPresets: [FilterPreset]) {
        self.id = id
        self.name = name
        self.year = year
        self.description = description
        self.filterPresets = filterPresets
    }
}
