import SwiftUI

struct RainbowBorderView: View {
    let isAnimating: Bool
    @State private var rotation: Double = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 무지개 그라데이션 링
                AngularGradient(
                    gradient: Gradient(colors: [
                        .red, .orange, .yellow, .green, .cyan, .blue, .purple, .pink, .red
                    ]),
                    center: .center,
                    startAngle: .degrees(rotation),
                    endAngle: .degrees(rotation + 360)
                )
                .mask(
                    RoundedRectangle(cornerRadius: geometry.size.width * 0.1)
                        .stroke(lineWidth: 8)
                )
                .blur(radius: 2)
                .opacity(isAnimating ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.3), value: isAnimating)
            }
        }
        .ignoresSafeArea()
        .onChange(of: isAnimating) { _, newValue in
            if newValue {
                withAnimation(.linear(duration: 1.5).repeatCount(1, autoreverses: false)) {
                    rotation = 360
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    rotation = 0
                }
            }
        }
    }
}
