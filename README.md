# Time-Travel-Photos

Time Travel Photos (TimeCam) is a SwiftUI camera app that lets you capture photos that look like they were taken in different eras. Each era bundles a pair of vintage-inspired Core Image presets, and the app applies grain, vignette, tint, exposure, and optional date stamps to make the live camera feed and saved shots feel era-accurate.

## How the app works

### High-level flow
- **App entry**: `TimeCamApp` injects a shared `TimeCamViewModel` into the SwiftUI hierarchy so every screen stays in sync on era selection, filter variant, and captured images.
- **Camera & preview**: `CameraService` owns an `AVCaptureSession`, provides tap-to-focus and pinch-to-zoom, and publishes captured `UIImage` instances via a callback. `CameraViewRepresentable` bridges the UIKit camera controller into SwiftUI with an optional thirds grid overlay.
- **Filtering pipeline**: `FilterService` applies the selected `FilterPreset` (per-era Core Image parameters) with grain noise, vignette, tint/temperature, exposure, optional portrait blur, and an optional date stamp overlay. The processed image is stored as a `CapturedPhoto` in the view model.
- **State & editing**: `TimeCamViewModel` tracks the selected era, filter variant, capture mode (Photo or Portrait), and toggles for saving originals, showing the grid, and stamping the era name. Gallery and edit screens pull from the view model so edits immediately update in-memory photos.
- **Saving**: From the edit screen you can save the processed photo back to the Photos library using `PhotoSaver`, which requests add-only photo library access.

### Screens
- **Camera screen** (`CameraScreen`):
  - Horizontal era pills at the top to jump between 1999, 2003, and 2010 looks.
  - Live camera preview with an overlay describing the era and a gear button for settings.
  - Centered filter selector to flip through the current era’s presets.
  - Segmented control to switch Photo vs. Portrait (adds a light blur).
  - Large shutter button to capture; gallery button opens all captures.
- **Settings** (`SettingsView`): toggles for saving originals (stub for future use), showing the grid overlay, and adding a date stamp of the selected era to exports.
- **Gallery** (`GalleryView`): grid of captured shots; tapping opens the detail editor.
- **Photo detail** (`PhotoDetailView`): adjust filter strength, swap eras/presets, and save the processed image to Photos.

## After cloning: build and run

1. **Clone** the repository and open the project in Xcode:
   ```bash
   git clone <repo-url>
   cd Time-Travel-Photos
   open TimeCam
   ```
   Opening the `TimeCam` folder in Xcode will load the SwiftUI app target.
2. **Select a run destination**: choose an iOS 16+ simulator or, for real camera access, a physical device.
3. **Run** the `TimeCam` scheme (⌘R). The first launch will prompt for Camera and Photos permissions.
4. **Use the app**:
   - Pick an era at the top of the camera screen, pick a preset, and tap the shutter. Portrait mode applies a light blur.
   - Open the gallery to review, tweak strength/era/preset, and save to your Photos library.
   - Toggle grid and date stamp options in Settings.

## Repository layout
- `TimeCamApp.swift`: App entry point and environment setup.
- `ViewModels/TimeCamViewModel.swift`: central state, filtering orchestration, and capture/update helpers.
- `Models/`: data structures for eras, presets, and captured photos.
- `Services/`: camera session management, filter application, and photo saving.
- `Views/`: SwiftUI screens (camera, gallery, detail, settings) and the camera bridge to UIKit.

## Notes and tips
- The app currently ships with three eras and two presets each; add more in `TimeCamViewModel` by expanding the preset lists.
- Saving originals is toggled in state for future expansion; the current flow saves the filtered image when you export.
- For the most realistic experience (camera feed and Photos access), run on a physical iPhone with iOS 16 or later.
