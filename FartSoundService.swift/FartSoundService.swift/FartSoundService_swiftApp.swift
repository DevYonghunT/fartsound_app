import Foundation
import Combine
import AVFoundation

final class FartSoundService: NSObject, ObservableObject {
    private var audioPlayers: [AVAudioPlayer] = []
    private let soundFiles = [
        "fart01", "fart02", "fart03", "fart04", "fart05",
        "fart06", "fart07", "fart08", "fart09", "fart10"
    ]
    
    override init() {
        super.init()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error.localizedDescription)")
        }
    }
    
    func playRandomFart() {
        guard let soundName = soundFiles.randomElement() else { return }
        
        // mp3, wav, m4a 등 다양한 포맷 지원
        let extensions = ["mp3", "wav", "m4a", "aiff"]
        var soundURL: URL?
        
        for ext in extensions {
            if let url = Bundle.main.url(forResource: soundName, withExtension: ext) {
                soundURL = url
                break
            }
        }
        
        guard let url = soundURL else {
            print("Sound file not found: \(soundName)")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = Float.random(in: 0.7...1.0) // 볼륨 약간 랜덤
            player.delegate = self
            player.prepareToPlay()
            player.play()
            
            audioPlayers.append(player)
            
            // 재생 완료 후 메모리 정리
            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration + 0.5) { [weak self] in
                self?.cleanupPlayers()
            }
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
    
    private func cleanupPlayers() {
        audioPlayers.removeAll { !$0.isPlaying }
    }
}

extension FartSoundService: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        cleanupPlayers()
    }
}
