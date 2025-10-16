import SwiftUI

struct SoundSelectorView: View {
    @ObservedObject var fartService: FartSoundService
    
    private let soundOptions: [SoundSelectionMode] = [.auto] + (0..<10).map { .manual(index: $0) }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(0..<soundOptions.count, id: \.self) { index in
                    let option = soundOptions[index]
                    let isSelected = fartService.selectionMode == option
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            fartService.selectionMode = option
                        }
                    }) {
                        Text(option.displayName)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(isSelected ? 0.5 : 0.2), lineWidth: isSelected ? 2 : 1)
                            )
                            .scaleEffect(isSelected ? 1.05 : 1.0)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 44)
    }
}
