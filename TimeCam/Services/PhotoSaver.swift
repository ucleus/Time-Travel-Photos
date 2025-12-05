import Foundation
import Photos
import UIKit

enum PhotoSaver {
    static func save(image: UIImage) async throws {
        try await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
}
