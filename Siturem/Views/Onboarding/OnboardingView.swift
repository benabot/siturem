import SwiftUI

// MARK: - Onboarding View
// Parcours d'accueil — 4 pages swipeables, affiché au premier lancement uniquement.
// Fidèle à BrandingGuideline : sobre, dense, silencieux, sans bavardage.

struct OnboardingView: View {

    let onComplete: () -> Void

    @State private var currentPage = 0
    @State private var pageAppeared = [false, false, false, false]

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            TabView(selection: $currentPage) {
                page(index: 0).tag(0)
                page(index: 1).tag(1)
                page(index: 2).tag(2)
                startPage.tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            // « Continuer » discret — pages 0-2
            if currentPage < 3 {
                VStack {
                    Spacer()
                    Button {
                        withAnimation(.easeInOut(duration: 0.35)) {
                            currentPage += 1
                        }
                    } label: {
                        Text("Continuer")
                            .font(.system(.footnote))
                            .foregroundStyle(Theme.textSecondary)
                    }
                    .padding(.bottom, LayoutMetrics.lg)
                }
                .transition(.opacity)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            // Délai synchronisé avec la fin du splash (4.5 s affichage + 0.8 s fade)
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                pageAppeared[0] = true
            }
        }
        .onChange(of: currentPage) { _, newPage in
            if !pageAppeared[newPage] {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    pageAppeared[newPage] = true
                }
            }
        }
    }

    // MARK: - Pages 1–3 (texte seul)

    private static let lines: [String] = [
        "Siturem est une app de méditation minimaliste conçue pour des pratiquants déjà autonomes.",
        "Elle ne cherche pas à enseigner la méditation, à divertir, ni à surcharger l'expérience.",
        "Elle fournit un cadre stable, discret et reproductible pour lancer rapidement une séance structurée."
    ]

    private func page(index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text(Self.lines[index])
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(pageAppeared[index] ? 1 : 0)
                .offset(y: pageAppeared[index] ? 0 : 12)
                .animation(.easeOut(duration: 0.7), value: pageAppeared[index])

            Spacer()
            Spacer()
        }
        .padding(.horizontal, LayoutMetrics.hPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Page 4 — Commencer

    private var startPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("Une séance prête à l'emploi, sobre, stable et structurée.")
                .font(.system(size: 22, weight: .light))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
                .opacity(pageAppeared[3] ? 1 : 0)
                .offset(y: pageAppeared[3] ? 0 : 12)
                .animation(.easeOut(duration: 0.7), value: pageAppeared[3])

            Spacer()

            Button {
                onComplete()
            } label: {
                Text("COMMENCER")
                    .font(.system(.subheadline, weight: .light))
                    .tracking(3)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.accent)
            .foregroundStyle(Theme.background)
            .opacity(pageAppeared[3] ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.4), value: pageAppeared[3])

            Spacer().frame(height: LayoutMetrics.lg)
        }
        .padding(.horizontal, LayoutMetrics.hPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
