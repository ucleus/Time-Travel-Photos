import Foundation
import SwiftUI
import Combine
import UIKit

@MainActor
final class TimeCamViewModel: ObservableObject {
    @Published var selectedEra: Era
    @Published var filterVariantIndex: Int
    @Published var capturedPhotos: [CapturedPhoto]
    @Published var showSettings: Bool = false
    @Published var selectedMode: CaptureMode = .photo
    @Published var saveOriginal: Bool = true
    @Published var showGrid: Bool = false
    @Published var showDateStamp: Bool = false

    let eras: [Era]

    private var cancellables = Set<AnyCancellable>()
    private let filterService = FilterService()

    init() {
        let presets1999 = [
            FilterPreset(name: "VHS Night", grain: 0.8, vignette: 0.5, tint: 0.05, contrast: 0.9, saturation: 0.9, exposure: -0.1),
            FilterPreset(name: "Disposable Daylight", grain: 0.6, vignette: 0.4, tint: 0.0, contrast: 1.0, saturation: 1.05, exposure: 0.1)
        ]
        let presets2003 = [
            FilterPreset(name: "Mall 2003", grain: 0.3, vignette: 0.2, tint: -0.05, contrast: 0.95, saturation: 0.95, exposure: 0.15),
            FilterPreset(name: "Cybercafé", grain: 0.2, vignette: 0.15, tint: 0.08, contrast: 0.9, saturation: 1.1, exposure: 0.25)
        ]
        let presets2010 = [
            FilterPreset(name: "Early Insta", grain: 0.4, vignette: 0.5, tint: 0.12, contrast: 1.1, saturation: 1.2, exposure: -0.05),
            FilterPreset(name: "Vintage Blogger", grain: 0.35, vignette: 0.55, tint: 0.15, contrast: 1.05, saturation: 1.05, exposure: -0.1)
        ]

        let era1999 = Era(name: "1999", year: 1999, description: "Late 90s film / VHS look", filterPresets: presets1999)
        let era2003 = Era(name: "2003", year: 2003, description: "Cheap digital point-and-shoot", filterPresets: presets2003)
        let era2010 = Era(name: "2010", year: 2010, description: "Early Instagram / DSLR blog", filterPresets: presets2010)

        self.eras = [era1999, era2003, era2010]
        self.selectedEra = era1999
        self.filterVariantIndex = 0
        self.capturedPhotos = []
    }

    var selectedPreset: FilterPreset {
        selectedEra.filterPresets[safe: filterVariantIndex] ?? selectedEra.filterPresets.first!
    }

    func selectEra(_ era: Era) {
        guard let index = eras.firstIndex(of: era) else { return }
        selectedEra = era
        filterVariantIndex = min(filterVariantIndex, eras[index].filterPresets.count - 1)
    }

    func selectPreset(at index: Int) {
        guard index >= 0, index < selectedEra.filterPresets.count else { return }
        filterVariantIndex = index
    }

    func receiveCapturedImage(_ image: UIImage) {
        let filtered = filterService.apply(preset: selectedPreset, to: image, strength: 1.0, portrait: selectedMode == .portrait, dateStamp: showDateStamp ? selectedEra.name : nil)
        let captured = CapturedPhoto(id: UUID(), image: filtered, era: selectedEra, filterPreset: selectedPreset, date: Date())
        capturedPhotos.insert(captured, at: 0)
    }

    func updatePhoto(_ photo: CapturedPhoto, strength: CGFloat) {
        guard let index = capturedPhotos.firstIndex(where: { $0.id == photo.id }) else { return }
        let newImage = filterService.apply(preset: photo.filterPreset, to: photo.image, strength: strength, portrait: selectedMode == .portrait, dateStamp: showDateStamp ? photo.era.name : nil)
        capturedPhotos[index].image = newImage
    }

    func saveToPhotos(_ photo: CapturedPhoto) async throws {
        try await PhotoSaver.save(image: photo.image)
    }
}

enum CaptureMode: String, CaseIterable {
    case photo = "Photo"
    case portrait = "Portrait"
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}
