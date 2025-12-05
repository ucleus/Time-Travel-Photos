import SwiftUI

struct CameraScreen: View {
    @EnvironmentObject private var viewModel: TimeCamViewModel
    @State private var cameraService = CameraService()
    @State private var isShowingGallery = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 12) {
                EraTimelineView(eras: viewModel.eras, selected: viewModel.selectedEra, onSelect: viewModel.selectEra)
                    .padding(.top, 12)

                ZStack(alignment: .topTrailing) {
                    CameraViewRepresentable(service: cameraService, showGrid: viewModel.showGrid)
                        .overlay(alignment: .center) {
                            filterBadge
                        }
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .frame(maxHeight: 400)

                    Button {
                        viewModel.showSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Circle().fill(.black.opacity(0.4)))
                    }
                    .padding()
                }

                filterSelector

                HStack {
                    modePicker
                    Spacer()
                    shutterButton
                    Spacer()
                    Button {
                        isShowingGallery = true
                    } label: {
                        Image(systemName: "photo.on.rectangle")
                            .foregroundStyle(.white)
                            .font(.title2)
                            .padding(10)
                            .background(Circle().fill(.black.opacity(0.4)))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
            }
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
                .environmentObject(viewModel)
        }
        .sheet(isPresented: $isShowingGallery) {
            GalleryView()
                .environmentObject(viewModel)
        }
        .onAppear {
            cameraService.onPhotoCapture = { image in
                viewModel.receiveCapturedImage(image)
            }
        }
    }

    private var shutterButton: some View {
        Button {
            cameraService.capturePhoto()
        } label: {
            Circle()
                .strokeBorder(Color.white, lineWidth: 4)
                .frame(width: 78, height: 78)
                .overlay(Circle().fill(Color.white.opacity(0.2)).padding(8))
        }
    }

    private var modePicker: some View {
        Picker("Mode", selection: $viewModel.selectedMode) {
            ForEach(CaptureMode.allCases, id: \.self) { mode in
                Text(mode.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: 160)
    }

    private var filterSelector: some View {
        HStack(spacing: 16) {
            Button(action: { viewModel.selectPreset(at: max(0, viewModel.filterVariantIndex - 1)) }) {
                Image(systemName: "chevron.left")
            }
            Text(viewModel.selectedPreset.name)
                .font(.headline)
            Button(action: { viewModel.selectPreset(at: min(viewModel.selectedEra.filterPresets.count - 1, viewModel.filterVariantIndex + 1)) }) {
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.white)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(.black.opacity(0.4))
        .clipShape(Capsule())
    }

    private var filterBadge: some View {
        VStack(alignment: .leading) {
            Text(viewModel.selectedEra.description)
                .font(.footnote)
                .padding(8)
                .background(.black.opacity(0.4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .foregroundStyle(.white)
            Spacer()
        }
        .padding()
    }
}

#Preview {
    CameraScreen()
        .environmentObject(TimeCamViewModel())
}
