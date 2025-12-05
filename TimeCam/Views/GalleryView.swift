import SwiftUI

struct GalleryView: View {
    @EnvironmentObject private var viewModel: TimeCamViewModel
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 110), spacing: 12)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.capturedPhotos) { photo in
                        NavigationLink(value: photo) {
                            Image(uiImage: photo.image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 110)
                                .clipped()
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Gallery")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    GalleryView()
        .environmentObject(TimeCamViewModel())
}
