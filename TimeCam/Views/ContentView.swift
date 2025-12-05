import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: TimeCamViewModel

    var body: some View {
        NavigationStack {
            CameraScreen()
                .navigationDestination(for: CapturedPhoto.self) { photo in
                    PhotoDetailView(photo: photo)
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(TimeCamViewModel())
}
