import SwiftUI

struct ContentView: View {
    @StateObject private var fartService = FartSoundService()
    @State private var hue = Double.random(in: 0...1)
    @State private var selectedEmoji = "💨"
    @State private var buttonText = ""
    @State private var message = ""
    @State private var bottomMessage = ""
    @State private var buttonScale: CGFloat = 1
    @State private var ripple: Bool = false

    private let emojis = ["💨", "💩", "😆", "🙊", "🤣", "🎺", "😵‍💫", "😈", "😜", "😹"]
    
    private func getButtonTexts() -> [String] {
        [
            NSLocalizedString("button_text_1", comment: ""),
            NSLocalizedString("button_text_2", comment: ""),
            NSLocalizedString("button_text_3", comment: ""),
            NSLocalizedString("button_text_4", comment: ""),
            NSLocalizedString("button_text_5", comment: ""),
            NSLocalizedString("button_text_6", comment: ""),
            NSLocalizedString("button_text_7", comment: ""),
            NSLocalizedString("button_text_8", comment: ""),
            NSLocalizedString("button_text_9", comment: ""),
            NSLocalizedString("button_text_10", comment: "")
        ]
    }
    
    private func getBottomMessages() -> [String] {
        [
            NSLocalizedString("bottom_msg_1", comment: ""),
            NSLocalizedString("bottom_msg_2", comment: ""),
            NSLocalizedString("bottom_msg_3", comment: ""),
            NSLocalizedString("bottom_msg_4", comment: ""),
            NSLocalizedString("bottom_msg_5", comment: ""),
            NSLocalizedString("bottom_msg_6", comment: ""),
            NSLocalizedString("bottom_msg_7", comment: ""),
            NSLocalizedString("bottom_msg_8", comment: ""),
            NSLocalizedString("bottom_msg_9", comment: ""),
            NSLocalizedString("bottom_msg_10", comment: "")
        ]
    }

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                VStack(spacing: 12) {
                    Text(NSLocalizedString("app_title", comment: ""))
                        .font(.system(size: 42, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)

                    Text(message)
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 260, height: 260)
                        .scaleEffect(ripple ? 1.2 : 1)
                        .animation(.easeInOut(duration: 0.4), value: ripple)

                    Button(action: handleTap) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.92))
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.6), lineWidth: 6)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)

                            VStack(spacing: 8) {
                                Text(selectedEmoji)
                                    .font(.system(size: 80))
                                Text(buttonText)
                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                        }
                        .frame(width: 220, height: 220)
                    }
                    .scaleEffect(buttonScale)
                    .animation(.spring(response: 0.32, dampingFraction: 0.45), value: buttonScale)
                }

                Spacer()

                Text(bottomMessage)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.bottom, 32)
            }
        }
        .onAppear {
            // 앱 시작 시 초기값 설정
            buttonText = NSLocalizedString("button_text_1", comment: "")
            message = NSLocalizedString("initial_message", comment: "")
            bottomMessage = NSLocalizedString("initial_bottom_message", comment: "")
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.85, brightness: 0.9),
                Color(hue: (hue + 0.1).truncatingRemainder(dividingBy: 1), saturation: 0.6, brightness: 0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func handleTap() {
        fartService.playRandomFart()

        withAnimation(.spring(response: 0.4, dampingFraction: 0.45)) {
            buttonScale = 1.12
            ripple.toggle()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                buttonScale = 1
                ripple.toggle()
            }
        }

        withAnimation(.easeInOut(duration: 0.45)) {
            hue = Double.random(in: 0...1)
        }

        if let randomEmoji = emojis.randomElement() {
            selectedEmoji = randomEmoji
        }

        if let randomButtonText = getButtonTexts().randomElement() {
            buttonText = randomButtonText
        }

        if let randomMessage = getButtonTexts().randomElement() {
            message = randomMessage
        }
        
        if let randomBottomMessage = getBottomMessages().randomElement() {
            bottomMessage = randomBottomMessage
        }
    }
}

#Preview {
    ContentView()
}
