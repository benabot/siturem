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
        static let ambientVolume: Float = 0.20
        static let gongVolume: Float = 0.48
        static let voiceVolume: Float = 0.92
        static let reminderVolume: Float = 0.40
        static let ambientDuckedVolume: Float = 0.14
        static let ambientFadeIn: TimeInterval = 0.6
        static let ambientFadeOut: TimeInterval = 0.5
        static let ambientRestoreFade: TimeInterval = 0.25
        static let ambientDuckPadding: TimeInterval = 0.2
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

    private var playedCueSeconds: Set<TimeInterval> = []

    private var startGongWorkItem: DispatchWorkItem?
    private var startGongFireDate: Date?
    private var remainingStartGongDelay: TimeInterval?

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
        playedCueSeconds.removeAll()
        voiceWasPlayingBeforePause = false
        gongWasPlayingBeforePause = false
        ambientWasPlayingBeforePause = false

        cancelPendingStartGong(resetDelay: true)
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

        cancelPendingStartGong(resetDelay: true)
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
        pausePendingStartGong()
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
        resumePendingStartGongIfNeeded()
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

        switch phase {
        case .intro:
            triggerVoiceCuesIfNeeded(
                cues: VoiceGuidanceLibrary.introCues,
                previousElapsed: previousElapsedInPhase,
                currentElapsed: currentElapsedInPhase
            )
        case .meditation:
            triggerReminderIfNeeded(
                previousElapsed: previousElapsedInPhase,
                currentElapsed: currentElapsedInPhase
            )
        case .closing:
            triggerVoiceCuesIfNeeded(
                cues: VoiceGuidanceLibrary.outroCues,
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
        currentPhase = newPhase
        playedCueSeconds.removeAll()

        if oldPhase == .intro {
            cancelPendingStartGong(resetDelay: true)
        }

        switch newPhase {
        case .intro:
            handleIntroStart()
        case .meditation:
            stopPlayer(&voicePlayer)
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

        cancelPendingStartGong(resetDelay: true)
        cancelAmbientRestore()
        stopPlayer(&voicePlayer)

        playFinalGongIfNeeded()
        stopAmbient(fadeOut: true)

        let gongDuration = gongPlayer?.duration ?? 0
        scheduleDeferredCleanup(after: max(Constants.ambientFadeOut, gongDuration) + 0.2)
    }

    // MARK: - Phase entry

    private func handleIntroStart() {
        guard configuration.accompaniment == .lightGuided else {
            playStartGongNowIfNeeded()
            return
        }

        guard let greetingDuration = playVoiceCue(at: VoiceGuidanceLibrary.introCues[0]) else {
            playStartGongNowIfNeeded()
            return
        }

        scheduleStartGong(after: greetingDuration)
    }

    private func handleClosingStart() {
        guard configuration.accompaniment == .lightGuided else {
            stopPlayer(&voicePlayer)
            return
        }

        _ = playVoiceCue(at: VoiceGuidanceLibrary.outroCues[0])
    }

    // MARK: - Tick handling

    private func triggerVoiceCuesIfNeeded(
        cues: [GuidanceCue],
        previousElapsed: TimeInterval,
        currentElapsed: TimeInterval
    ) {
        guard configuration.accompaniment == .lightGuided else { return }

        for cue in cues where cue.second > 0 {
            guard playedCueSeconds.contains(cue.second) == false else { continue }
            guard previousElapsed < cue.second, currentElapsed >= cue.second else { continue }

            playedCueSeconds.insert(cue.second)
            _ = playVoiceCue(at: cue)
        }
    }

    private func triggerReminderIfNeeded(
        previousElapsed: TimeInterval,
        currentElapsed: TimeInterval
    ) {
        guard configuration.accompaniment == .lightGuided else { return }
        guard let interval = configuration.reminder.seconds else { return }

        let previousBucket = Int(previousElapsed / TimeInterval(interval))
        let currentBucket = Int(currentElapsed / TimeInterval(interval))

        guard currentBucket > previousBucket else { return }

        playReminderIfPossible()
    }

    // MARK: - Voice / reminder

    @discardableResult
    private func playVoiceCue(at cue: GuidanceCue) -> TimeInterval? {
        guard let url = resolver.url(for: cue.asset) else {
            Self.logger.debug("Missing voice asset for cue at \(cue.second, format: .fixed(precision: 0))s")
            return nil
        }

        return playPlayer(
            kind: .voice,
            url: url,
            volume: Constants.voiceVolume,
            ducksAmbient: true
        )
    }

    private func playReminderIfPossible() {
        guard let url = resolver.url(for: .reminder) else {
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

    // MARK: - Gong

    private func playStartGongNowIfNeeded() {
        guard configuration.gong.playsSessionBoundaryGongs else { return }
        _ = playPlayer(kind: .gong, url: resolver.url(for: .gong), volume: Constants.gongVolume, ducksAmbient: true)
    }

    private func playFinalGongIfNeeded() {
        guard configuration.gong.playsSessionBoundaryGongs else { return }
        _ = playPlayer(kind: .gong, url: resolver.url(for: .gong), volume: Constants.gongVolume, ducksAmbient: true)
    }

    private func scheduleStartGong(after delay: TimeInterval) {
        guard configuration.gong.playsSessionBoundaryGongs else { return }

        cancelPendingStartGong(resetDelay: false)

        let clampedDelay = max(0, delay)
        remainingStartGongDelay = clampedDelay
        startGongFireDate = Date().addingTimeInterval(clampedDelay)

        let workItem = DispatchWorkItem { [weak self] in
            self?.remainingStartGongDelay = nil
            self?.startGongFireDate = nil
            self?.playStartGongNowIfNeeded()
        }

        startGongWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + clampedDelay, execute: workItem)
    }

    private func pausePendingStartGong() {
        guard let fireDate = startGongFireDate else { return }

        remainingStartGongDelay = max(0.1, fireDate.timeIntervalSinceNow)
        startGongWorkItem?.cancel()
        startGongWorkItem = nil
        startGongFireDate = nil
    }

    private func resumePendingStartGongIfNeeded() {
        guard currentPhase == .intro, let remainingStartGongDelay else { return }
        scheduleStartGong(after: remainingStartGongDelay)
    }

    private func cancelPendingStartGong(resetDelay: Bool) {
        startGongWorkItem?.cancel()
        startGongWorkItem = nil
        startGongFireDate = nil

        if resetDelay {
            remainingStartGongDelay = nil
        }
    }

    // MARK: - Ambiance

    private func startAmbientIfNeeded() {
        guard configuration.ambient != .off else { return }
        guard let url = resolver.url(for: .ambient(configuration.ambient)) else {
            Self.logger.debug("Missing ambient asset")
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.numberOfLoops = -1
            player.volume = 0
            player.prepareToPlay()
            player.play()
            player.setVolume(Constants.ambientVolume, fadeDuration: Constants.ambientFadeIn)
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
        ambientPlayer.setVolume(Constants.ambientDuckedVolume, fadeDuration: 0.08)

        let workItem = DispatchWorkItem { [weak self] in
            guard let self, self.isSessionActive, self.isPaused == false, let ambientPlayer = self.ambientPlayer else {
                return
            }

            ambientPlayer.setVolume(Constants.ambientVolume, fadeDuration: Constants.ambientRestoreFade)
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
}
