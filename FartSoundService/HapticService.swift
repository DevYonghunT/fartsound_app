import UIKit
import CoreHaptics

final class HapticService: ObservableObject {
    @Published var isEnabled = true
    
    private var hapticEngine: CHHapticEngine?
    
    init() {
        setupHapticEngine()
    }
    
    private func setupHapticEngine() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Failed to create haptic engine: \(error)")
        }
    }
    
    func playRandomFartHaptic() {
        guard isEnabled else { return }
        
        let patterns = [
            createShortBurstPattern,
            createLongRumblePattern,
            createStutterPattern,
            createIntenseShortPattern,
            createWavyPattern,
            createDoubleHitPattern,
            createTriplePattern,
            createBuildUpPattern
        ]
        
        if let randomPattern = patterns.randomElement() {
            randomPattern()
        }
    }
    
    // 짧고 강한 버스트
    private func createShortBurstPattern() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        
        playPattern(events: [event])
    }
    
    // 긴 럼블
    private func createLongRumblePattern() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
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
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: TimeInterval(i) * 0.08)
            events.append(event)
        }
        
        playPattern(events: events)
    }
    
    // 강하고 짧은 충격
    private func createIntenseShortPattern() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: 0, duration: 0.15)
        
        playPattern(events: [event])
    }
    
    // 물결 패턴
    private func createWavyPattern() {
        var events: [CHHapticEvent] = []
        for i in 0..<3 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: Float(0.5 + Double(i) * 0.2))
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.4)
            let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [intensity, sharpness], relativeTime: TimeInterval(i) * 0.15, duration: 0.12)
            events.append(event)
        }
        
        playPattern(events: events)
    }
    
    // 두 번 치기
    private func createDoubleHitPattern() {
        let intensity1 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.9)
        let sharpness1 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
        let event1 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity1, sharpness1], relativeTime: 0)
        
        let intensity2 = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness2 = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.9)
        let event2 = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity2, sharpness2], relativeTime: 0.12)
        
        playPattern(events: [event1, event2])
    }
    
    // 세 번 치기
    private func createTriplePattern() {
        var events: [CHHapticEvent] = []
        for i in 0..<3 {
            let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8)
            let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.6)
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: TimeInterval(i) * 0.1)
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
            let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: TimeInterval(i) * 0.08)
            events.append(event)
        }
        
        playPattern(events: events)
    }
    
    private func playPattern(events: [CHHapticEvent]) {
        guard let engine = hapticEngine else { return }
        
        do {
            let pattern = try CHHapticPattern(events: events, parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Failed to play haptic pattern: \(error)")
        }
    }
}
