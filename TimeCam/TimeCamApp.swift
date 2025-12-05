import SwiftUI

@main
struct TimeCamApp: App {
    @StateObject private var viewModel = TimeCamViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
