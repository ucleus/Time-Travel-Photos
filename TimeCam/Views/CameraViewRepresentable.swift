import SwiftUI
import AVFoundation

struct CameraViewRepresentable: UIViewControllerRepresentable {
    let service: CameraService
    let showGrid: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let controller = CameraViewController(service: service)
        controller.showGrid = showGrid
        return controller
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        uiViewController.showGrid = showGrid
    }
}

/// Hosts AVCaptureVideoPreviewLayer and forwards gestures to CameraService.
final class CameraViewController: UIViewController {
    private let service: CameraService
    private let previewLayer = AVCaptureVideoPreviewLayer()
    var showGrid: Bool = false { didSet { overlayGrid.isHidden = !showGrid } }
    private let overlayGrid = GridOverlayView()

    init(service: CameraService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        previewLayer.session = service.session
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        overlayGrid.isHidden = !showGrid
        view.addSubview(overlayGrid)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        view.addGestureRecognizer(tap)

        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        view.addGestureRecognizer(pinch)

        service.start()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer.frame = view.bounds
        overlayGrid.frame = view.bounds
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: view)
        let normalized = CGPoint(x: point.x / view.bounds.width, y: point.y / view.bounds.height)
        service.focus(at: normalized)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        service.setZoom(factor: gesture.scale)
    }
}

/// Simple thirds grid overlay used when toggled on.
final class GridOverlayView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isUserInteractionEnabled = false
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        let thirdW = rect.width / 3
        let thirdH = rect.height / 3
        for i in 1..<3 {
            path.move(to: CGPoint(x: CGFloat(i) * thirdW, y: 0))
            path.addLine(to: CGPoint(x: CGFloat(i) * thirdW, y: rect.height))
            path.move(to: CGPoint(x: 0, y: CGFloat(i) * thirdH))
            path.addLine(to: CGPoint(x: rect.width, y: CGFloat(i) * thirdH))
        }
        UIColor.white.withAlphaComponent(0.3).setStroke()
        path.lineWidth = 1
        path.stroke()
    }
}
