import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var fartService = FartSoundService()
    @StateObject private var hapticService = HapticService()

    @State private var hue = Double.random(in: 0...1)
    @State private var selectedEmoji = "💨"
    @State private var buttonText = ""
    @State private var message = ""
    @State private var bottomMessage = ""
    @State private var buttonScale: CGFloat = 1
    @State private var ripple: Bool = false
    @State private var showRainbowBorder: Bool = false

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
            backgroundGradient.ignoresSafeArea()
            RainbowBorderView(isAnimating: showRainbowBorder)

            VStack(spacing: 0) {

                // 상단 컨트롤바 - 오른쪽 정렬, 가로 배치
                HStack(spacing: 12) {
                    Spacer()
                    
                    // 사운드 선택 스크롤
                    SoundSelectorView(fartService: fartService)
                        .environmentObject(hapticService)
                        .frame(height: 52)
                    
                    // 진동 온/오프 버튼
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            hapticService.isEnabled.toggle()
                        }
                        let gen = UIImpactFeedbackGenerator(style: .light)
                        gen.prepare()
                        gen.impactOccurred()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.18))
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(
                                            LinearGradient(
                                                colors: [.white.opacity(0.6), .white.opacity(0.15)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing
                                            ),
                                            lineWidth: 1
                                        )
                                )
                                .frame(width: 52, height: 52)

                            Image(systemName: hapticService.isEnabled
                                  ? "iphone.radiowaves.left.and.right"
                                  : "iphone.slash")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                        }
                    }
                }
                .padding(.trailing, 20)
                .padding(.top, 16)

                // 상단 여백 - 컨트롤과 타이틀 사이
                Spacer()
                    .frame(height: 40)

                // 제목 (상단에서 적당히 떨어진 위치)
                Text(NSLocalizedString("app_title", comment: ""))
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white.opacity(0.95))
                    .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
                    .padding(.bottom, 8)

                // 안내 메시지 (타이틀 바로 아래)
                Text(message)
                    .font(.system(size: 19, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                // 타이틀과 버튼 사이 여백
                Spacer()
                    .frame(height: 50)

                // 메인 버튼 (화면 중앙보다 살짝 위)
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 270, height: 270)
                        .scaleEffect(ripple ? 1.2 : 1)
                        .animation(.easeInOut(duration: 0.4), value: ripple)

                    Button(action: handleTap) {
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.92))
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.6), lineWidth: 6)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)

                            VStack(spacing: 6) {
                                Text(selectedEmoji)
                                    .font(.system(size: 85))
                                Text(buttonText)
                                    .font(.system(size: 22, weight: .heavy, design: .rounded))
                                    .foregroundStyle(.black.opacity(0.7))
                            }
                        }
                        .frame(width: 230, height: 230)
                    }
                    .scaleEffect(buttonScale)
                    .animation(.spring(response: 0.32, dampingFraction: 0.45), value: buttonScale)
                }

                // 버튼과 하단 메시지 사이 여백
                Spacer()
                    .frame(height: 60)

                // 하단 메시지
                Text(bottomMessage)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                // 하단 여백 (Safe Area 고려)
                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            buttonText = NSLocalizedString("button_text_1", comment: "")
            message = NSLocalizedString("initial_message", comment: "")
            bottomMessage = NSLocalizedString("initial_bottom_message", comment: "")
        }
    }

    private var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hue: hue, saturation: 0.85, brightness: 0.9),
                Color(hue: (hue + 0.1).truncatingRemainder(dividingBy: 1),
                      saturation: 0.6, brightness: 0.95)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func handleTap() {
        fartService.playRandomFart()
        hapticService.playRandomFartHaptic()

        showRainbowBorder = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { showRainbowBorder = false }

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
        withAnimation(.easeInOut(duration: 0.45)) { hue = Double.random(in: 0...1) }

        if let e = emojis.randomElement() { selectedEmoji = e }
        if let t = getButtonTexts().randomElement() { buttonText = t }
        if let m = getButtonTexts().randomElement() { message = m }
        if let b = getBottomMessages().randomElement() { bottomMessage = b }
    }
}
