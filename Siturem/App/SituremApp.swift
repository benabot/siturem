import SwiftUI

@main
struct SituremApp: App {

    @State private var prefs = PreferencesStore()
    @State private var splashOpacity = 1.0
    @State private var contentOpacity = 0.0

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(prefs: prefs)
                    .opacity(contentOpacity)
                SplashView()
                    .opacity(splashOpacity)
                    .allowsHitTesting(splashOpacity > 0)
            }
            .environment(\.locale, prefs.uiLanguage.locale)
            .onAppear {
                // Logo : 0.9 s — Baseline : delay 1.2 s + 0.9 s = visible à 2.1 s
                // Total visible : 4.5 s — fondu enchaîné splash↓ / content↑ : 0.8 s
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        splashOpacity = 0.0
                        contentOpacity = 1.0
                    }
                }
            }
        }
    }
}
