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
                identityPage.tag(0)
                promisePage.tag(1)
                structurePage.tag(2)
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
            // Délai synchronisé avec la fin du splash (2.8 s + 0.4 s pause)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
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

    // MARK: - Page 1 — Identité

    private var identityPage: some View {
        VStack(spacing: 14) {
            Spacer()

            Text("SITUREM")
                .font(.system(size: 42, weight: .ultraLight))
                .tracking(12)
                .foregroundStyle(Theme.textPrimary)
                .opacity(pageAppeared[0] ? 1 : 0)
                .animation(.easeOut(duration: 0.8), value: pageAppeared[0])

            Text("Méditation structurée")
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(Theme.textSecondary)
                .tracking(1.5)
                .opacity(pageAppeared[0] ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: pageAppeared[0])

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Page 2 — Promesse

    private var promisePage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("Un cadre simple\npour votre pratique")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Theme.textPrimary)
                .lineSpacing(4)
                .opacity(pageAppeared[1] ? 1 : 0)
                .animation(.easeOut(duration: 0.6), value: pageAppeared[1])

            Spacer().frame(height: LayoutMetrics.md)

            VStack(alignment: .leading, spacing: LayoutMetrics.sm) {
                stepRow("1", "Choisissez une durée", delay: 0.15)
                stepRow("2", "Lancez la séance", delay: 0.30)
                stepRow("3", "L'app s'efface", delay: 0.45)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, LayoutMetrics.hPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func stepRow(_ number: String, _ text: String, delay: Double) -> some View {
        HStack(spacing: 16) {
            Text(number)
                .font(.system(.caption, design: .monospaced))
                .foregroundStyle(Theme.accent)
                .frame(width: 16, alignment: .trailing)
            Capsule()
                .fill(Theme.accent.opacity(0.3))
                .frame(width: 20, height: 1)
            Text(text)
                .font(.system(.body, weight: .light))
                .foregroundStyle(Theme.textPrimary)
        }
        .opacity(pageAppeared[1] ? 1 : 0)
        .offset(y: pageAppeared[1] ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(delay), value: pageAppeared[1])
    }

    // MARK: - Page 3 — Structure

    private var structurePage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("Trois phases, toujours")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Theme.textPrimary)
                .opacity(pageAppeared[2] ? 1 : 0)
                .animation(.easeOut(duration: 0.6), value: pageAppeared[2])

            Spacer().frame(height: LayoutMetrics.md)

            VStack(alignment: .leading, spacing: LayoutMetrics.sm) {
                phaseBlock(ratio: 0.55, accentOpacity: 0.70, name: "Introduction", duration: "2 min 30", delay: 0.15)
                phaseBlock(ratio: 1.0, accentOpacity: 1.0, name: "Méditation", duration: "durée variable", delay: 0.30)
                phaseBlock(ratio: 0.30, accentOpacity: 0.45, name: "Retour", duration: "45 s", delay: 0.45)
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, LayoutMetrics.hPadding)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func phaseBlock(ratio: CGFloat, accentOpacity: Double, name: String, duration: String, delay: Double) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            GeometryReader { geo in
                Capsule()
                    .fill(Theme.accent.opacity(accentOpacity))
                    .frame(width: geo.size.width * ratio, height: 4)
            }
            .frame(height: 4)

            HStack(spacing: 8) {
                Text(name)
                    .font(.system(.subheadline))
                    .foregroundStyle(Theme.textPrimary)
                Text("·")
                    .foregroundStyle(Theme.textSecondary)
                Text(duration)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .opacity(pageAppeared[2] ? 1 : 0)
        .offset(y: pageAppeared[2] ? 0 : 10)
        .animation(.easeOut(duration: 0.5).delay(delay), value: pageAppeared[2])
    }

    // MARK: - Page 4 — Commencer

    private var startPage: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            Text("Prêt à commencer")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Theme.textPrimary)
                .opacity(pageAppeared[3] ? 1 : 0)
                .animation(.easeOut(duration: 0.6), value: pageAppeared[3])

            Spacer().frame(height: 14)

            Text("Vos réglages sont conservés\nd'une séance à l'autre.")
                .font(.system(.subheadline))
                .foregroundStyle(Theme.textSecondary)
                .lineSpacing(3)
                .opacity(pageAppeared[3] ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: pageAppeared[3])

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
