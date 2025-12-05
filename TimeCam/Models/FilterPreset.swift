import Foundation
import CoreGraphics

struct FilterPreset: Identifiable, Equatable {
    let id: UUID
    let name: String
    let grain: CGFloat
    let vignette: CGFloat
    let tint: CGFloat
    let contrast: CGFloat
    let saturation: CGFloat
    let exposure: CGFloat

    init(id: UUID = UUID(), name: String, grain: CGFloat, vignette: CGFloat, tint: CGFloat, contrast: CGFloat, saturation: CGFloat, exposure: CGFloat) {
        self.id = id
        self.name = name
        self.grain = grain
        self.vignette = vignette
        self.tint = tint
        self.contrast = contrast
        self.saturation = saturation
        self.exposure = exposure
    }
}
