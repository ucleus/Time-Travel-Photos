import Foundation
import AVFoundation
import UIKit

/// Simple AVFoundation wrapper responsible for camera preview, tap-to-focus, and pinch-to-zoom.
/// This service owns the AVCaptureSession and exposes delegate callbacks for captured photos.
final class CameraService: NSObject {
    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "TimeCam.CameraSession")
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDevice: AVCaptureDevice?

    var onPhotoCapture: ((UIImage) -> Void)?

    override init() {
        super.init()
        configureSession()
    }

    func start() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if !self.session.isRunning {
                self.session.startRunning()
            }
        }
    }

    func stop() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        settings.isHighResolutionPhotoEnabled = true
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    func setZoom(factor: CGFloat) {
        guard let device = videoDevice else { return }
        do {
            try device.lockForConfiguration()
            let zoomFactor = max(1.0, min(factor, device.activeFormat.videoMaxZoomFactor))
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        } catch {
            print("Zoom error: \(error)")
        }
    }

    func focus(at point: CGPoint) {
        guard let device = videoDevice else { return }
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {
            print("Focus error: \(error)")
        }
    }
}

private extension CameraService {
    func configureSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let deviceInput = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(deviceInput) else {
            print("Failed to set up back camera input")
            return
        }
        videoDevice = device
        session.addInput(deviceInput)

        guard session.canAddOutput(photoOutput) else {
            print("Failed to add photo output")
            return
        }
        session.addOutput(photoOutput)
        photoOutput.isHighResolutionCaptureEnabled = true

        session.commitConfiguration()
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print("Capture error: \(error)")
            return
        }
        guard let data = photo.fileDataRepresentation(), let image = UIImage(data: data) else { return }
        onPhotoCapture?(image)
    }
}
