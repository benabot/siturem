import SwiftUI

@main
struct SituremApp: App {

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .onAppear {
                // Logo : 0.9 s — Baseline : delay 1.2 s + 0.9 s = visible à 2.1 s
                // Total visible : 4.5 s — fade : 0.8 s
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeOut(duration: 0.8)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
