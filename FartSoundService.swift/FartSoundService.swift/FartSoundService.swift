import Foundation
import Combine
import AVFoundation

enum SoundSelectionMode: Equatable {
    case auto
    case manual(index: Int)
    
    var displayName: String {
        switch self {
        case .auto:
            return NSLocalizedString("자동", comment: "")
        case .manual(let index):
            return NSLocalizedString("방구\(index + 1)", comment: "")
        }
    }
}

final class FartSoundService: NSObject, ObservableObject {
    @Published var selectionMode: SoundSelectionMode = .auto
    
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
        let soundName: String
        
        switch selectionMode {
        case .auto:
            soundName = soundFiles.randomElement() ?? soundFiles[0]
        case .manual(let index):
            soundName = soundFiles[index]
        }
        
        playSound(named: soundName)
    }
    
    private func playSound(named soundName: String) {
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
            player.volume = Float.random(in: 0.7...1.0)
            player.delegate = self
            player.prepareToPlay()
            player.play()
            
            audioPlayers.append(player)
            
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
