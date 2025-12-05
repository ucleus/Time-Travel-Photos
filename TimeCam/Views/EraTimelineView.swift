import SwiftUI

struct EraTimelineView: View {
    let eras: [Era]
    let selected: Era
    let onSelect: (Era) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(eras) { era in
                    Button {
                        onSelect(era)
                    } label: {
                        Text(era.name)
                            .font(.headline.weight(.semibold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 14)
                            .background(Capsule().fill(selected == era ? Color.white.opacity(0.9) : Color.white.opacity(0.2)))
                            .foregroundStyle(selected == era ? Color.black : Color.white)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    EraTimelineView(eras: TimeCamViewModel().eras, selected: TimeCamViewModel().eras.first!, onSelect: { _ in })
        .background(Color.black)
}
