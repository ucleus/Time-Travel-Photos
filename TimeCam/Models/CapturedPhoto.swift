import Foundation
import UIKit

struct CapturedPhoto: Identifiable {
    let id: UUID
    var image: UIImage
    var era: Era
    var filterPreset: FilterPreset
    let date: Date
}
