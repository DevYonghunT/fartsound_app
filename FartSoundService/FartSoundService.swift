diff --git a/Services/FartSoundService.swift b/Services/FartSoundService.swift
new file mode 100644
index 0000000000000000000000000000000000000000..15ed5798554480180d3e5be995afb82b6b8b20e0
--- /dev/null
+++ b/Services/FartSoundService.swift
@@ -0,0 +1,99 @@
+import Foundation
+import AVFoundation
+
+final class FartSoundService: ObservableObject {
+    private let engine = AVAudioEngine()
+    private let player = AVAudioPlayerNode()
+    private let format: AVAudioFormat
+    private let queue = DispatchQueue(label: "FartSoundServiceQueue")
+
+    init() {
+        let sampleRate = 44_100.0
+        guard let audioFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1) else {
+            fatalError("Unable to create audio format for fart generator")
+        }
+
+        format = audioFormat
+        configureSession()
+        engine.attach(player)
+        engine.connect(player, to: engine.mainMixerNode, format: format)
+        engine.prepare()
+
+        do {
+            try engine.start()
+        } catch {
+            print("Failed to start audio engine: \(error.localizedDescription)")
+        }
+    }
+
+    func playRandomFart() {
+        queue.async { [weak self] in
+            guard let self else { return }
+
+            if !self.engine.isRunning {
+                do {
+                    try self.engine.start()
+                } catch {
+                    print("Failed to restart audio engine: \(error.localizedDescription)")
+                }
+            }
+
+            let buffer = self.makeFartBuffer()
+            self.player.stop()
+            self.player.play()
+            self.player.scheduleBuffer(buffer, at: nil, options: [.interruptsAtLoop], completionHandler: nil)
+        }
+    }
+
+    private func makeFartBuffer() -> AVAudioPCMBuffer {
+        let duration = Double.random(in: 0.5...1.4)
+        let frameCount = AVAudioFrameCount(duration * format.sampleRate)
+
+        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
+            fatalError("Unable to allocate audio buffer")
+        }
+
+        buffer.frameLength = frameCount
+
+        guard let channelData = buffer.floatChannelData?.pointee else {
+            fatalError("Missing channel data")
+        }
+
+        let sampleRate = Float(format.sampleRate)
+        let totalFrames = Int(frameCount)
+        var phase: Float = 0
+
+        let baseFrequency = Float.random(in: 25...55)
+        let modulationDepth = Float.random(in: 0.25...0.65)
+        let modulationRate = Float.random(in: 1.8...4.5)
+        let noiseAmount = Float.random(in: 0.35...0.6)
+        let toneAmount = 1 - noiseAmount
+        let envelopePower = Float.random(in: 1.6...2.6)
+
+        for frame in 0..<totalFrames {
+            let t = Float(frame) / sampleRate
+            let normalizedTime = min(t / Float(duration), 1)
+            let envelope = powf(1 - normalizedTime, envelopePower) * (0.8 + Float.random(in: -0.05...0.05))
+            let freq = baseFrequency * (1 + sinf(2 * .pi * modulationRate * t) * modulationDepth)
+            phase += (2 * .pi * freq) / sampleRate
+            let tone = sinf(phase)
+            let flutter = sinf(phase * Float.random(in: 0.4...0.7)) * 0.3
+            let noise = Float.random(in: -1...1)
+            channelData[frame] = ((tone + flutter) * toneAmount + noise * noiseAmount) * envelope
+        }
+
+        return buffer
+    }
+
+    private func configureSession() {
+        #if os(iOS)
+        let session = AVAudioSession.sharedInstance()
+        do {
+            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
+            try session.setActive(true, options: [])
+        } catch {
+            print("Failed to configure audio session: \(error.localizedDescription)")
+        }
+        #endif
+    }
+}
