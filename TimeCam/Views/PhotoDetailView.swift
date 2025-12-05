import SwiftUI

struct PhotoDetailView: View {
    @EnvironmentObject private var viewModel: TimeCamViewModel
    @Environment(\.dismiss) private var dismiss

    let photo: CapturedPhoto
    @State private var strength: CGFloat = 1.0
    @State private var selectedEra: Era
    @State private var selectedPreset: FilterPreset

    init(photo: CapturedPhoto) {
        self.photo = photo
        _selectedEra = State(initialValue: photo.era)
        _selectedPreset = State(initialValue: photo.filterPreset)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Image(uiImage: viewModel.capturedPhotos.first(where: { $0.id == photo.id })?.image ?? photo.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(14)

                Text("Era: \(selectedEra.name) – \(selectedPreset.name)")
                    .font(.headline)

                Slider(value: Binding(get: { strength }, set: { newValue in
                    strength = newValue
                    applyEdits()
                }), in: 0...1) {
                    Text("Strength")
                }

                Text("Grain")
                Slider(value: .constant(selectedPreset.grain), in: 0...1)
                    .disabled(true)
                    .opacity(0.6)
                    .overlay(alignment: .trailing) {
                        Text("Preset-driven")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                Text("Vignette")
                Slider(value: .constant(selectedPreset.vignette), in: 0...1)
                    .disabled(true)
                    .opacity(0.6)
                    .overlay(alignment: .trailing) {
                        Text("Preset-driven")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                Text("Change era & preset")
                    .font(.headline)
                eraSelection

                HStack {
                    Button("Save to Photos") {
                        Task { try? await viewModel.saveToPhotos(photo) }
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                    Button("Done") { dismiss() }
                }
            }
            .padding()
        }
        .navigationTitle("Edit")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var eraSelection: some View {
        VStack(alignment: .leading, spacing: 8) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.eras) { era in
                        Button {
                            selectedEra = era
                            if let firstPreset = era.filterPresets.first {
                                selectedPreset = firstPreset
                                applyEdits()
                            }
                        } label: {
                            Text(era.name)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(Capsule().fill(selectedEra == era ? Color.white.opacity(0.9) : Color.white.opacity(0.2)))
                                .foregroundStyle(selectedEra == era ? .black : .white)
                        }
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(selectedEra.filterPresets) { preset in
                        Button {
                            selectedPreset = preset
                            applyEdits()
                        } label: {
                            Text(preset.name)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(RoundedRectangle(cornerRadius: 12).fill(selectedPreset == preset ? Color.white.opacity(0.9) : Color.white.opacity(0.2)))
                                .foregroundStyle(selectedPreset == preset ? .black : .white)
                        }
                    }
                }
            }
        }
    }

    private func applyEdits() {
        var updated = photo
        updated.era = selectedEra
        updated.filterPreset = selectedPreset
        viewModel.updatePhoto(updated, strength: strength)
    }
}

#Preview {
    let vm = TimeCamViewModel()
    return PhotoDetailView(photo: vm.capturedPhotos.first ?? CapturedPhoto(id: UUID(), image: UIImage(), era: vm.eras.first!, filterPreset: vm.eras.first!.filterPresets.first!, date: Date()))
        .environmentObject(vm)
        .background(Color.black)
}
