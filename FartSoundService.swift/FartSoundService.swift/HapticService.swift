import UIKit
import CoreHaptics
import Combine
import AudioToolbox

final class HapticService: ObservableObject {
    @Published var isEnabled = true
    
    private var hapticEngine: CHHapticEngine?
    
    init() {
        setupHapticEngine()
    }
    
    // 엔진 생성 + 백그라운드/리셋 대비
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            // 하드웨어가 Core Haptics 미지원일 때는 UIImpact로 폴백됨
            return
        }
        do {
            let engine = try CHHapticEngine()
            
            // 앱이 백그라운드로 갔다 오거나, 오디오 세션 충돌 등으로 멈출 수 있음 → 자동 재시작 시도
            engine.stoppedHandler = { [weak self] _ in
                try? self?.hapticEngine?.start()
            }
            engine.resetHandler = { [weak self] in
                // 시스템이 엔진을 리셋하면 재구성 후 즉시 시작
                do { try self?.hapticEngine?.start() } catch {
                    print("Failed to restart haptic engine after reset: \(error)")
                }
            }
            
            try engine.start()
            hapticEngine = engine
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    // 스크롤/선택 시 사용하는 가벼운 '틱' (필요하면 아주 짧은 클릭 소리도)
    func selectionTick(playClickSound: Bool = true) {
        guard isEnabled else { return }
        let gen = UISelectionFeedbackGenerator()
        gen.prepare()
        gen.selectionChanged()
        if playClickSound {
            // 1104: iOS 시스템 클릭 효과음 (짧은 '딱')
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    // 메인 버튼: 랜덤 방귀 진동
    func playRandomFartHaptic() {
        guard isEnabled else { return }
        
        let supports = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if supports == false || hapticEngine == nil {
            // 폴백: Core Haptics 불가 시에도 체감 피드백 제공
            let g = UIImpactFeedbackGenerator(style: .medium)
            g.prepare()
            g.impactOccurred(intensity: 0.9)
            return
        }
        
        // 엔진이 일시 정지돼 있을 수 있으니 매 호출 시 시작 보장
        do { try hapticEngine?.start() } catch {
            // 시작 실패 시 폴백
            let g = UIImpactFeedbackGenerator(style: .medium)
            g.prepare()
            g.impactOccurred(intensity: 0.9)
            return
        }
        
        let patterns: [() -> Void] = [
            createShortBurstPattern,
            createLongRumblePattern,
            createStutterPattern,
            createIntenseShortPattern,
            createWavyPattern,
            createDoubleHitPattern,
            createTriplePattern,
            createBuildUpPattern
        ]
        patterns.randomElement()?()
    }
    
    // MARK: - 패턴들
    
    // 짧고 강한 버스트
    private func createShortBurstPattern() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        playPattern(events: [event])
    }
    
    // 긴 럼블
    private func createLongRumblePattern() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.5)
        playPattern(events: [event])
    }
    
    // 더듬더듬 패턴
    private func createStutterPattern() {
        var events: [CHHapticEvent] = []
        for i in 0..<5 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float.random(in: 0.6...1.0))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            let event = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [intensity, sharpness],
                                      relativeTime: TimeInterval(i) * 0.08)
            events.append(event)
        }
        playPattern(events: events)
    }
    
    // 강하고 짧은 충격
    private func createIntenseShortPattern() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let event = CHHapticEvent(eventType: .hapticContinuous,
                                  parameters: [intensity, sharpness],
                                  relativeTime: 0, duration: 0.15)
        playPattern(events: [event])
    }
    
    // 물결 패턴
    private func createWavyPattern() {
        var events: [CHHapticEvent] = []
        for i in 0..<3 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.5 + Double(i) * 0.2))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            let event = CHHapticEvent(eventType: .hapticContinuous,
                                      parameters: [intensity, sharpness],
                                      relativeTime: TimeInterval(i) * 0.15, duration: 0.12)
            events.append(event)
        }
        playPattern(events: events)
    }
    
    // 두 번 치기
    private func createDoubleHitPattern() {
        let i1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
        let s1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        let e1 = CHHapticEvent(eventType: .hapticTransient, parameters: [i1, s1], relativeTime: 0)
        
        let i2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let s2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
        let e2 = CHHapticEvent(eventType: .hapticTransient, parameters: [i2, s2], relativeTime: 0.12)
        
        playPattern(events: [e1, e2])
    }
    
    // 세 번 치기
    private func createTriplePattern() {
        var events: [CHHapticEvent] = []
        for i in 0..<3 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            let event = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [intensity, sharpness],
                                      relativeTime: TimeInterval(i) * 0.1)
            events.append(event)
        }
        playPattern(events: events)
    }
    
    // 점점 강해지기
    private func createBuildUpPattern() {
        var events: [CHHapticEvent] = []
        for i in 0..<4 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.4 + Double(i) * 0.2))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: Float(0.3 + Double(i) * 0.15))
            let event = CHHapticEvent(eventType: .hapticTransient,
                                      parameters: [intensity, sharpness],
                                      relativeTime: TimeInterval(i) * 0.08)
            events.append(event)
        }
        playPattern(events: events)
    }
    
    // 패턴 재생 (재생 직전 start 보장 + 오류 시 로그)
    private func playPattern(events: [CHHapticEvent]) {
        guard let engine = hapticEngine else { return }
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            // 혹시 엔진이 잠시 멈춰 있었다면 재시작 보장
            try engine.start()
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}
