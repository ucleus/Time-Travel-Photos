import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var viewModel: TimeCamViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Toggle("Save original unfiltered image", isOn: $viewModel.saveOriginal)
                Toggle("Show grid overlay in camera", isOn: $viewModel.showGrid)
                Toggle("Show date stamp on exported images", isOn: $viewModel.showDateStamp)
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(TimeCamViewModel())
}
