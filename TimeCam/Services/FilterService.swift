import Foundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

/// Applies Core Image filters to simulate era-specific looks.
struct FilterService {
    private let context = CIContext()

    func apply(preset: FilterPreset, to image: UIImage, strength: CGFloat, portrait: Bool, dateStamp: String?) -> UIImage {
        guard let cgImage = image.cgImage else { return image }
        let inputImage = CIImage(cgImage: cgImage)

        // Exposure and color controls
        let exposure = CIFilter.exposureAdjust()
        exposure.inputImage = inputImage
        exposure.ev = Float(preset.exposure * strength)

        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = exposure.outputImage
        colorControls.saturation = Float(preset.saturation)
        colorControls.contrast = Float(preset.contrast)

        // Tinting via temperature
        let temperature = CIFilter.temperatureAndTint()
        temperature.inputImage = colorControls.outputImage
        temperature.neutral = CIVector(x: 6500 + Float(preset.tint * 1200), y: 0)

        var currentImage = temperature.outputImage

        if portrait {
            // TODO: use depth data when available; for now apply a light gaussian blur mask to simulate portrait separation.
            let blur = CIFilter.gaussianBlur()
            blur.inputImage = currentImage
            blur.radius = 8 * Float(strength)
            if let blurred = blur.outputImage, let base = currentImage {
                currentImage = blurred.composited(over: base)
            }
        }

        // Vignette
        let vignette = CIFilter.vignette()
        vignette.inputImage = currentImage
        vignette.intensity = Float(preset.vignette * strength)
        vignette.radius = Float(2.0 * strength)
        currentImage = vignette.outputImage

        // Grain via random noise overlay
        if let grainImage = noiseImage(size: image.size, amount: preset.grain * strength) {
            currentImage = grainImage.composited(over: currentImage ?? inputImage)
        }

        if let dateStamp {
            currentImage = overlayDate(dateStamp, on: currentImage ?? inputImage, size: image.size)
        }

        guard let output = currentImage,
              let cgOut = context.createCGImage(output, from: output.extent) else { return image }
        return UIImage(cgImage: cgOut, scale: image.scale, orientation: image.imageOrientation)
    }
}

private extension FilterService {
    func noiseImage(size: CGSize, amount: CGFloat) -> CIImage? {
        guard amount > 0 else { return nil }
        let noise = CIFilter.randomGenerator().outputImage?
            .cropped(to: CGRect(origin: .zero, size: size))
            .applyingFilter("CIColorMatrix", parameters: [
                "inputRVector": CIVector(x: amount, y: 0, z: 0, w: 0),
                "inputGVector": CIVector(x: 0, y: amount, z: 0, w: 0),
                "inputBVector": CIVector(x: 0, y: 0, z: amount, w: 0)
            ])
        return noise
    }

    func overlayDate(_ text: String, on image: CIImage, size: CGSize) -> CIImage {
        let format = UIGraphicsImageRenderer(size: size)
        let uiImage = format.image { context in
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .right
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.monospacedDigitSystemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraph,
                .shadow: NSShadow()
            ]
            let string = NSString(string: text)
            string.draw(in: CGRect(x: 0, y: size.height - 28, width: size.width - 12, height: 24), withAttributes: attributes)
        }
        guard let cg = uiImage.cgImage else { return image }
        let overlay = CIImage(cgImage: cg)
        return overlay.composited(over: image)
    }
}
