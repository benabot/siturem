import SwiftUI

// MARK: - Content View (Root)
// Routeur principal : accueil ou séance en cours.

struct ContentView: View {

    @Bindable var prefs: PreferencesStore
    @AppStorage("siturem.onboardingCompleted") private var onboardingCompleted = false
    @State private var stats = StatsStore()
    @State private var engine: SessionEngine? = nil
    @State private var selectedTab: Tab = .home

    enum Tab { case home, stats, settings }

    var body: some View {
        Group {
            if !onboardingCompleted {
                OnboardingView {
                    withAnimation(.easeOut(duration: 0.5)) {
                        onboardingCompleted = true
                    }
                }
            } else if let engine {
                SessionView(engine: engine, stats: stats, prefs: prefs) {
                    self.engine = nil
                }
                .id(engine.id)
            } else {
                TabView(selection: $selectedTab) {
                    HomeView(prefs: prefs) { config in
                        let e = SessionEngine(config: config)
                        engine = e
                    }
                    .tabItem { Label("Pratique", systemImage: "timer") }
                    .tag(Tab.home)

                    StatsView(stats: stats)
                        .tabItem { Label("Suivi", systemImage: "chart.bar") }
                        .tag(Tab.stats)

                    SettingsView(prefs: prefs)
                        .tabItem { Label("Réglages", systemImage: "gearshape") }
                        .tag(Tab.settings)
                }
                .tint(.primary)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView(prefs: PreferencesStore())
}
