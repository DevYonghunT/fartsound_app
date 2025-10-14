diff --git a/Views/ContentView.swift b/Views/ContentView.swift
new file mode 100644
index 0000000000000000000000000000000000000000..dfaafcc691d487dd77659e7b223f51a5e531c72a
--- /dev/null
+++ b/Views/ContentView.swift
@@ -0,0 +1,128 @@
+import SwiftUI
+
+struct ContentView: View {
+    @StateObject private var fartService = FartSoundService()
+    @State private var hue = Double.random(in: 0...1)
+    @State private var selectedEmoji = "💨"
+    @State private var message = "화면을 터치하면 다양한 방구 소리가 나요!"
+    @State private var buttonScale: CGFloat = 1
+    @State private var ripple: Bool = false
+
+    private let emojis = ["💨", "💩", "😆", "🙊", "🤣", "🎺", "🫧"]
+    private let messages = [
+        "뿡!",
+        "푸푸!",
+        "지이잉~",
+        "뿡뿡 폭발!",
+        "오늘의 베스트 방구!",
+        "방구 박사 등장",
+        "뿡과 함께 춤을!"
+    ]
+
+    var body: some View {
+        ZStack {
+            backgroundGradient
+                .ignoresSafeArea()
+
+            VStack(spacing: 28) {
+                Spacer()
+
+                VStack(spacing: 12) {
+                    Text("방구 실험실")
+                        .font(.system(size: 42, weight: .heavy, design: .rounded))
+                        .foregroundStyle(.white.opacity(0.95))
+                        .shadow(color: .black.opacity(0.25), radius: 12, x: 0, y: 6)
+
+                    Text(message)
+                        .font(.system(size: 20, weight: .medium, design: .rounded))
+                        .foregroundStyle(.white.opacity(0.9))
+                        .multilineTextAlignment(.center)
+                        .padding(.horizontal, 24)
+                }
+
+                Spacer()
+
+                ZStack {
+                    Circle()
+                        .fill(.white.opacity(0.18))
+                        .frame(width: 260, height: 260)
+                        .scaleEffect(ripple ? 1.2 : 1)
+                        .animation(.easeInOut(duration: 0.4), value: ripple)
+
+                    Button(action: handleTap) {
+                        ZStack {
+                            Circle()
+                                .fill(.white.opacity(0.92))
+                                .overlay(
+                                    Circle()
+                                        .stroke(Color.white.opacity(0.6), lineWidth: 6)
+                                )
+                                .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 10)
+
+                            VStack(spacing: 8) {
+                                Text(selectedEmoji)
+                                    .font(.system(size: 80))
+                                Text("뿡!")
+                                    .font(.system(size: 28, weight: .heavy, design: .rounded))
+                                    .foregroundStyle(.black.opacity(0.7))
+                            }
+                        }
+                        .frame(width: 220, height: 220)
+                    }
+                    .scaleEffect(buttonScale)
+                    .animation(.spring(response: 0.32, dampingFraction: 0.45), value: buttonScale)
+                }
+
+                Spacer()
+
+                Text("터치할 때마다 새로운 소리가 재생돼요")
+                    .font(.system(size: 16, weight: .semibold, design: .rounded))
+                    .foregroundStyle(.white.opacity(0.85))
+                    .padding(.bottom, 32)
+            }
+        }
+    }
+
+    private var backgroundGradient: LinearGradient {
+        LinearGradient(
+            colors: [
+                Color(hue: hue, saturation: 0.85, brightness: 0.9),
+                Color(hue: (hue + 0.1).truncatingRemainder(dividingBy: 1), saturation: 0.6, brightness: 0.95)
+            ],
+            startPoint: .topLeading,
+            endPoint: .bottomTrailing
+        )
+    }
+
+    private func handleTap() {
+        fartService.playRandomFart()
+
+        withAnimation(.spring(response: 0.4, dampingFraction: 0.45)) {
+            buttonScale = 1.12
+            ripple.toggle()
+        }
+
+        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
+            withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
+                buttonScale = 1
+                ripple.toggle()
+            }
+        }
+
+        withAnimation(.easeInOut(duration: 0.45)) {
+            hue = Double.random(in: 0...1)
+        }
+
+        if let randomEmoji = emojis.randomElement() {
+            selectedEmoji = randomEmoji
+        }
+
+        if let randomMessage = messages.randomElement() {
+            message = randomMessage
+        }
+    }
+}
+
+#Preview {
+    ContentView()
+}
