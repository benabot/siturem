import Foundation
import AVFoundation
import OSLog

protocol AudioServicing: AnyObject {
    func startSessionAudio(configuration: SessionConfiguration)
    func stopAll()
    func pauseAll()
    func resumeAll()
    func handleTick(
        phase: SessionPhase,
        previousElapsedInPhase: TimeInterval,
        currentElapsedInPhase: TimeInterval,
        configuration: SessionConfiguration
    )
    func handlePhaseChange(
        from oldPhase: SessionPhase?,
        to newPhase: SessionPhase,
        configuration: SessionConfiguration
    )
    func handleSessionEnd(configuration: SessionConfiguration)
}

final class AudioService: AudioServicing {

    private enum Constants {
        static let ambientVolume: Float = 0.07
        static let gongVolume: Float = 0.48
        static let voiceVolume: Float = 1.0
        static let reminderVolume: Float = 0.78
        static let ambientDuckedVolume: Float = 0.03
        static let ambientFadeIn: TimeInterval = 0.8
        static let ambientFadeOut: TimeInterval = 0.5
        static let ambientRestoreFade: TimeInterval = 0.45
        static let ambientDuckPadding: TimeInterval = 0.35
        static let rainAmbientVolumeMultiplier: Float = 0.65
        static let rainDuckedVolumeMultiplier: Float = 0.5
        static let overdueGuidanceTolerance: TimeInterval = 0.35
    }

    private struct PendingGuidanceEvent {
        let phase: SessionPhase
        let asset: AudioAsset
        let placement: GuidanceSequencePlacement
        let fireOffset: TimeInterval
        var fireDate: Date?
        var remainingDelay: TimeInterval?
        var workItem: DispatchWorkItem?
        var hasPlayed: Bool = false
    }

    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "Siturem",
        category: "AudioService"
    )

    private let resolver: AudioAssetResolver

    private var configuration: SessionConfiguration
    private var currentPhase: SessionPhase = .intro
    private var isSessionActive = false
    private var isPaused = false

    private var voicePlayer: AVAudioPlayer?
    private var gongPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?

    private var voiceWasPlayingBeforePause = false
    private var gongWasPlayingBeforePause = false
    private var ambientWasPlayingBeforePause = false

    private var pendingGuidanceEvents: [PendingGuidanceEvent] = []
    private var assetDurationCache: [String: TimeInterval] = [:]
    private var lastPlayedReminderBucket = 0

    private var ambientRestoreWorkItem: DispatchWorkItem?
    private var deferredCleanupWorkItem: DispatchWorkItem?

    init(config: SessionConfiguration, bundle: Bundle = .main) {
        self.configuration = config
        self.resolver = AudioAssetResolver(bundle: bundle)
    }

    // MARK: - Session lifecycle

    func startSessionAudio(configuration: SessionConfiguration) {
        self.configuration = configuration
        currentPhase = .intro
        isSessionActive = true
        isPaused = false
        assetDurationCache.removeAll()
        voiceWasPlayingBeforePause = false
        gongWasPlayingBeforePause = false
        ambientWasPlayingBeforePause = false
        lastPlayedReminderBucket = 0

        cancelGuidanceSchedule()
        cancelAmbientRestore()
        cancelDeferredCleanup()

        activateAudioSession()
        startAmbientIfNeeded()
        handleIntroStart()
    }

    func stopAll() {
        isSessionActive = false
        isPaused = false
        voiceWasPlayingBeforePause = false
        gongWasPlayingBeforePause = false
        ambientWasPlayingBeforePause = false
        lastPlayedReminderBucket = 0

        cancelGuidanceSchedule()
        cancelAmbientRestore()
        cancelDeferredCleanup()

        stopPlayer(&voicePlayer)
        stopPlayer(&gongPlayer)
        stopAmbient(fadeOut: false)
        deactivateAudioSession()
    }

    func pauseAll() {
        guard isSessionActive, !isPaused else { return }
        isPaused = true

        voiceWasPlayingBeforePause = voicePlayer?.isPlaying == true
        gongWasPlayingBeforePause = gongPlayer?.isPlaying == true
        ambientWasPlayingBeforePause = ambientPlayer?.isPlaying == true

        voicePlayer?.pause()
        gongPlayer?.pause()
        ambientPlayer?.pause()
        pauseGuidanceSchedule()
        cancelAmbientRestore()
    }

    func resumeAll() {
        guard isSessionActive, isPaused else { return }
        isPaused = false

        activateAudioSession()

        if ambientWasPlayingBeforePause {
            ambientPlayer?.play()
        }

        if voiceWasPlayingBeforePause {
            voicePlayer?.play()
        }

        if gongWasPlayingBeforePause {
            gongPlayer?.play()
        }

        voiceWasPlayingBeforePause = false
        gongWasPlayingBeforePause = false
        ambientWasPlayingBeforePause = false
        resumeGuidanceSchedule()
    }

    func handleTick(
        phase: SessionPhase,
        previousElapsedInPhase: TimeInterval,
        currentElapsedInPhase: TimeInterval,
        configuration: SessionConfiguration
    ) {
        guard isSessionActive, !isPaused else { return }
        guard phase == currentPhase else { return }
        guard currentElapsedInPhase >= previousElapsedInPhase else { return }

        self.configuration = configuration

        if phase == .meditation {
            triggerReminderIfNeeded(
                previousElapsed: previousElapsedInPhase,
                currentElapsed: currentElapsedInPhase
            )
        }
    }

    func handlePhaseChange(
        from oldPhase: SessionPhase?,
        to newPhase: SessionPhase,
        configuration: SessionConfiguration
    ) {
        guard isSessionActive else { return }

        self.configuration = configuration
        playOverdueAnchoredGuidanceIfNeeded(for: oldPhase)
        currentPhase = newPhase
        cancelGuidanceSchedule()
        lastPlayedReminderBucket = 0

        switch newPhase {
        case .intro:
            handleIntroStart()
        case .meditation:
            break
        case .closing:
            handleClosingStart()
        }
    }

    func handleSessionEnd(configuration: SessionConfiguration) {
        guard isSessionActive else { return }

        self.configuration = configuration
        isSessionActive = false
        isPaused = false
        voiceWasPlayingBeforePause = false
        gongWasPlayingBeforePause = false
        ambientWasPlayingBeforePause = false
        lastPlayedReminderBucket = 0

        cancelGuidanceSchedule()
        cancelAmbientRestore()
        stopPlayer(&voicePlayer)

        if configuration.accompaniment != .guided {
            playFinalGongIfNeeded()
        }
        stopAmbient(fadeOut: true)

        let gongTailDuration = remainingPlaybackDuration(of: gongPlayer)
        scheduleDeferredCleanup(after: max(Constants.ambientFadeOut, gongTailDuration) + 0.2)
    }

    // MARK: - Phase entry

    private func handleIntroStart() {
        guard configuration.accompaniment == .guided else {
            _ = playGuidanceAsset(.gong)
            return
        }

        startGuidanceSequence(
            phase: .intro,
            steps: VoiceGuidanceLibrary.introSteps
        )
    }

    private func handleClosingStart() {
        guard configuration.accompaniment == .guided else {
            stopPlayer(&voicePlayer)
            return
        }

        startGuidanceSequence(
            phase: .closing,
            steps: VoiceGuidanceLibrary.outroSteps
        )
    }

    // MARK: - Tick handling

    private func triggerReminderIfNeeded(
        previousElapsed: TimeInterval,
        currentElapsed: TimeInterval
    ) {
        guard configuration.accompaniment == .guided else { return }
        guard let interval = configuration.reminder.seconds else { return }

        let currentBucket = Int(currentElapsed / TimeInterval(interval))
        guard currentBucket >= 1 else { return }
        guard currentBucket > lastPlayedReminderBucket else { return }

        lastPlayedReminderBucket = currentBucket
        playReminderIfPossible()
    }

    // MARK: - Voice / reminder

    @discardableResult
    private func playGuidanceAsset(_ asset: AudioAsset) -> TimeInterval? {
        switch asset {
        case .gong:
            guard configuration.gong.playsSessionBoundaryGongs else { return nil }
            guard let url = resolver.url(for: asset, locale: configuration.audioLocale) else {
                Self.logger.debug("Missing gong asset")
                return nil
            }

            return playPlayer(
                kind: .gong,
                url: url,
                volume: Constants.gongVolume,
                ducksAmbient: true
            )

        case .ambient(_):
            return nil

        case .intro(_), .reminder, .outro(_):
            guard let url = resolver.url(for: asset, locale: configuration.audioLocale) else {
                Self.logger.debug("Missing guidance asset for \(asset.baseName, privacy: .public)")
                return nil
            }

            return playPlayer(
                kind: .voice,
                url: url,
                volume: Constants.voiceVolume,
                ducksAmbient: true
            )
        }
    }

    private func playReminderIfPossible() {
        guard let url = resolver.url(for: .reminder, locale: configuration.audioLocale) else {
            Self.logger.debug("Missing reminder asset")
            return
        }

        _ = playPlayer(
            kind: .voice,
            url: url,
            volume: Constants.reminderVolume,
            ducksAmbient: true
        )
    }

    // MARK: - Guidance sequencing

    private func startGuidanceSequence(phase: SessionPhase, steps: [OrderedGuidanceStep]) {
        guard configuration.accompaniment == .guided else { return }
        guard let leadingStep = steps.first else { return }

        cancelGuidanceSchedule()

        let leadingDuration = effectivePlaybackDuration(for: leadingStep)
        _ = playGuidanceAsset(leadingStep.asset)

        let remainingSteps = Array(steps.dropFirst())
        pendingGuidanceEvents = buildGuidanceEvents(
            for: remainingSteps,
            phase: phase,
            startingCursor: leadingDuration + leadingStep.postDelay
        )

        schedulePendingGuidanceEvents()
    }

    private func buildGuidanceEvents(
        for steps: [OrderedGuidanceStep],
        phase: SessionPhase,
        startingCursor: TimeInterval
    ) -> [PendingGuidanceEvent] {
        var events: [PendingGuidanceEvent] = []
        var cursor = startingCursor

        for step in steps {
            let effectiveDuration = effectivePlaybackDuration(for: step)
            let fireOffset: TimeInterval

            switch step.placement {
            case .sequential:
                fireOffset = cursor
            case .anchoredToPhaseEnd(let leadTime):
                let phaseDuration = phaseDuration(for: phase)
                let anchorOffset = max(0, phaseDuration - leadTime)
                fireOffset = max(cursor, anchorOffset)
            }

            events.append(
                PendingGuidanceEvent(
                    phase: phase,
                    asset: step.asset,
                    placement: step.placement,
                    fireOffset: fireOffset
                )
            )

            cursor = fireOffset + effectiveDuration + step.postDelay
        }

        return events
    }

    private func schedulePendingGuidanceEvents() {
        guard isSessionActive, !isPaused else { return }

        for index in pendingGuidanceEvents.indices {
            schedulePendingGuidanceEvent(at: index, delay: pendingGuidanceEvents[index].fireOffset)
        }
    }

    private func schedulePendingGuidanceEvent(at index: Int, delay: TimeInterval) {
        guard pendingGuidanceEvents.indices.contains(index) else { return }
        guard pendingGuidanceEvents[index].hasPlayed == false else { return }

        let clampedDelay = max(0, delay)
        let phase = pendingGuidanceEvents[index].phase
        let asset = pendingGuidanceEvents[index].asset
        let fireDate = Date().addingTimeInterval(clampedDelay)

        pendingGuidanceEvents[index].fireDate = fireDate
        pendingGuidanceEvents[index].remainingDelay = clampedDelay

        let workItem = DispatchWorkItem { [weak self] in
            self?.fireGuidanceEvent(phase: phase, asset: asset)
        }

        pendingGuidanceEvents[index].workItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + clampedDelay, execute: workItem)
    }

    private func fireGuidanceEvent(phase: SessionPhase, asset: AudioAsset) {
        guard isSessionActive, !isPaused, currentPhase == phase else { return }

        _ = playGuidanceAsset(asset)
        markGuidanceEventPlayed(phase: phase, asset: asset)
    }

    private func markGuidanceEventPlayed(phase: SessionPhase, asset: AudioAsset) {
        guard let index = pendingGuidanceEvents.firstIndex(where: {
            $0.phase == phase && $0.asset.baseName == asset.baseName
        }) else {
            return
        }

        pendingGuidanceEvents[index].hasPlayed = true
        pendingGuidanceEvents[index].workItem = nil
        pendingGuidanceEvents[index].fireDate = nil
        pendingGuidanceEvents[index].remainingDelay = nil
    }

    private func pauseGuidanceSchedule() {
        for index in pendingGuidanceEvents.indices where pendingGuidanceEvents[index].hasPlayed == false {
            guard let fireDate = pendingGuidanceEvents[index].fireDate else { continue }

            pendingGuidanceEvents[index].remainingDelay = max(0, fireDate.timeIntervalSinceNow)
            pendingGuidanceEvents[index].workItem?.cancel()
            pendingGuidanceEvents[index].workItem = nil
            pendingGuidanceEvents[index].fireDate = nil
        }
    }

    private func resumeGuidanceSchedule() {
        guard isSessionActive, !isPaused else { return }

        for index in pendingGuidanceEvents.indices where pendingGuidanceEvents[index].hasPlayed == false {
            let delay = pendingGuidanceEvents[index].remainingDelay ?? pendingGuidanceEvents[index].fireOffset
            schedulePendingGuidanceEvent(at: index, delay: delay)
        }
    }

    private func cancelGuidanceSchedule() {
        for index in pendingGuidanceEvents.indices {
            pendingGuidanceEvents[index].workItem?.cancel()
            pendingGuidanceEvents[index].workItem = nil
        }

        pendingGuidanceEvents.removeAll()
    }

    private func playFinalGongIfNeeded() {
        _ = playGuidanceAsset(.gong)
    }

    private func phaseDuration(for phase: SessionPhase) -> TimeInterval {
        switch phase {
        case .intro:
            return TimeInterval(SessionConfiguration.introDuration)
        case .meditation:
            return 0
        case .closing:
            return TimeInterval(SessionConfiguration.closingDuration)
        }
    }

    private func effectivePlaybackDuration(for step: OrderedGuidanceStep) -> TimeInterval {
        max(step.expectedDuration, estimatedPlaybackDuration(for: step.asset))
    }

    // MARK: - Ambiance

    private func startAmbientIfNeeded() {
        guard configuration.ambient != .off else { return }
        guard let url = resolver.url(for: .ambient(configuration.ambient), locale: configuration.audioLocale) else {
            Self.logger.debug("Missing ambient asset")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0
            player.prepareToPlay()
            player.play()
            player.setVolume(targetAmbientVolume, fadeDuration: Constants.ambientFadeIn)
            ambientPlayer = player
        } catch {
            Self.logger.debug("Ambient player creation failed: \(error.localizedDescription)")
        }
    }

    private func stopAmbient(fadeOut: Bool) {
        cancelAmbientRestore()

        guard let ambientPlayer else { return }

        guard fadeOut, ambientPlayer.isPlaying else {
            ambientPlayer.stop()
            self.ambientPlayer = nil
            return
        }

        ambientPlayer.setVolume(0, fadeDuration: Constants.ambientFadeOut)
        let playerToStop = ambientPlayer

        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.ambientFadeOut) { [weak self] in
            playerToStop.stop()
            if self?.ambientPlayer === playerToStop {
                self?.ambientPlayer = nil
            }
        }
    }

    private func duckAmbient(for duration: TimeInterval) {
        guard let ambientPlayer, ambientPlayer.isPlaying else { return }

        cancelAmbientRestore()
        ambientPlayer.setVolume(targetDuckedAmbientVolume, fadeDuration: 0.12)

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.isSessionActive, self.isPaused == false, let ambientPlayer = self.ambientPlayer else {
                return
            }

            ambientPlayer.setVolume(self.targetAmbientVolume, fadeDuration: Constants.ambientRestoreFade)
        }

        ambientRestoreWorkItem = workItem
        DispatchQueue.main.asyncAfter(
            deadline: .now() + duration + Constants.ambientDuckPadding,
            execute: workItem
        )
    }

    private func cancelAmbientRestore() {
        ambientRestoreWorkItem?.cancel()
        ambientRestoreWorkItem = nil
    }

    // MARK: - Playback

    private enum PlayerKind {
        case voice
        case gong
    }

    @discardableResult
    private func playPlayer(
        kind: PlayerKind,
        url: URL?,
        volume: Float,
        ducksAmbient: Bool
    ) -> TimeInterval? {
        guard let url else { return nil }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = volume
            player.prepareToPlay()

            switch kind {
            case .voice:
                voicePlayer?.stop()
                voicePlayer = player
            case .gong:
                gongPlayer?.stop()
                gongPlayer = player
            }

            player.play()

            if ducksAmbient {
                duckAmbient(for: player.duration)
            }

            return player.duration
        } catch {
            Self.logger.debug("Playback failed for \(url.lastPathComponent, privacy: .public): \(error.localizedDescription)")
            return nil
        }
    }

    private func stopPlayer(_ player: inout AVAudioPlayer?) {
        player?.stop()
        player = nil
    }

    private func playOverdueAnchoredGuidanceIfNeeded(for phase: SessionPhase?) {
        guard let phase else { return }

        let dueAnchoredEvents = pendingGuidanceEvents.enumerated().filter { index, event in
            guard event.hasPlayed == false else { return false }
            guard event.phase == phase else { return false }
            guard case .anchoredToPhaseEnd = event.placement else { return false }

            let fireDate = event.fireDate ?? Date().addingTimeInterval(event.fireOffset)
            return fireDate.timeIntervalSinceNow <= Constants.overdueGuidanceTolerance
        }

        guard let target = dueAnchoredEvents.max(by: { $0.element.fireOffset < $1.element.fireOffset }) else {
            return
        }

        _ = playGuidanceAsset(target.element.asset)
        markGuidanceEventPlayed(phase: target.element.phase, asset: target.element.asset)
    }

    private var targetAmbientVolume: Float {
        switch configuration.ambient {
        case .rain:
            Constants.ambientVolume * Constants.rainAmbientVolumeMultiplier
        case .off, .river, .forest, .whiteNoise:
            Constants.ambientVolume
        }
    }

    private var targetDuckedAmbientVolume: Float {
        switch configuration.ambient {
        case .rain:
            Constants.ambientDuckedVolume * Constants.rainDuckedVolumeMultiplier
        case .off, .river, .forest, .whiteNoise:
            Constants.ambientDuckedVolume
        }
    }

    private func remainingPlaybackDuration(of player: AVAudioPlayer?) -> TimeInterval {
        guard let player, player.isPlaying else { return 0 }
        return max(0, player.duration - player.currentTime)
    }

    // MARK: - Audio session

    private func activateAudioSession() {
        let session = AVAudioSession.sharedInstance()

        do {
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            Self.logger.debug("Audio session activation failed: \(error.localizedDescription)")
        }
    }

    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: [.notifyOthersOnDeactivation])
        } catch {
            Self.logger.debug("Audio session deactivation failed: \(error.localizedDescription)")
        }
    }

    private func scheduleDeferredCleanup(after delay: TimeInterval) {
        cancelDeferredCleanup()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.stopPlayer(&self.gongPlayer)
            self.deactivateAudioSession()
        }

        deferredCleanupWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func cancelDeferredCleanup() {
        deferredCleanupWorkItem?.cancel()
        deferredCleanupWorkItem = nil
    }

    private func estimatedPlaybackDuration(for asset: AudioAsset) -> TimeInterval {
        let cacheKey = "\(configuration.audioLocale.rawValue):\(asset.group.rawValue):\(asset.baseName)"

        if let cachedDuration = assetDurationCache[cacheKey] {
            return cachedDuration
        }

        guard let url = resolver.url(for: asset, locale: configuration.audioLocale) else {
            return 0
        }

        let duration = (try? AVAudioPlayer(contentsOf: url))?.duration ?? 0
        assetDurationCache[cacheKey] = duration
        return duration
    }
}
