import SwiftUI
import AVFoundation
import UserNotifications

@Observable
class TimerViewModel {

    // MARK: - Configuration

    var studyMinutes: Double = 25 {
        didSet {
            if isStudySession && !isTimerRunning && !isSoundPlaying {
                timeRemaining = studyMinutes * 60
            }
        }
    }

    var breakMinutes: Double = 5 {
        didSet {
            if !isStudySession && !isTimerRunning && !isSoundPlaying {
                timeRemaining = breakMinutes * 60
            }
        }
    }

    // Volume: 0.0–4.0 where 1.0 = 0 dB, 4.0 ≈ +12 dB via EQ gain
    var alarmVolume: Double = 4.0 {
        didSet {
            updateAudioVolume(volume: alarmVolume)
            if !isTimerRunning && !isSoundPlaying { playCurrentSound() }
        }
    }

    // MARK: - State

    var timeRemaining: TimeInterval = 25 * 60
    var isTimerRunning = false
    var isStudySession = true
    var isSoundPlaying = false

    var timeString: String {
        String(format: "%02d:%02d", Int(timeRemaining) / 60, Int(timeRemaining) % 60)
    }

    var progress: Double {
        let total = isStudySession ? studyMinutes * 60 : breakMinutes * 60
        return total > 0 ? timeRemaining / total : 0
    }

    // MARK: - Private

    private var timer: Timer?
    private var soundTimer: Timer?
    private let audioEngine = AVAudioEngine()
    private let audioPlayerNode = AVAudioPlayerNode()
    private let eqNode = AVAudioUnitEQ(numberOfBands: 1)
    private var audioFile: AVAudioFile?

    // MARK: - Init

    init() {
        setupNotifications()
        setupAudioEngine()
    }

    // MARK: - Setup

    private func setupNotifications() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func setupAudioEngine() {
        let url = URL(fileURLWithPath: "/System/Library/Sounds/Ping.aiff")
        guard let file = try? AVAudioFile(forReading: url) else { return }
        audioFile = file

        audioEngine.attach(audioPlayerNode)
        audioEngine.attach(eqNode)
        audioEngine.connect(audioPlayerNode, to: eqNode, format: file.processingFormat)
        audioEngine.connect(eqNode, to: audioEngine.mainMixerNode, format: file.processingFormat)

        updateAudioVolume(volume: alarmVolume)
        try? audioEngine.start()
    }

    private func updateAudioVolume(volume: Double) {
        guard volume > 0 else { audioPlayerNode.volume = 0; return }
        audioPlayerNode.volume = 1.0
        if volume <= 1.0 {
            audioPlayerNode.volume = Float(volume)
            eqNode.globalGain = 0
        } else {
            eqNode.globalGain = Float(20.0 * log10(volume))
        }
    }

    // MARK: - Timer Control

    func toggleTimer() {
        if isSoundPlaying { acknowledgeAlarm(); return }
        isTimerRunning ? pauseTimer() : startTimer()
    }

    func resetTimer() {
        pauseTimer()
        timeRemaining = isStudySession ? studyMinutes * 60 : breakMinutes * 60
    }

    func skipSession() {
        pauseTimer()
        stopSound()
        switchSession()
    }

    func acknowledgeAlarm() {
        stopSound()
        switchSession()
        startTimer()
    }

    private func startTimer() {
        timer?.invalidate()
        isTimerRunning = true
        let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func pauseTimer() {
        isTimerRunning = false
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        if timeRemaining > 0 { timeRemaining -= 1 } else { finishSession() }
    }

    private func finishSession() {
        pauseTimer()
        isSoundPlaying = true
        playSoundRepeatedly()
        sendNotification()
    }

    private func switchSession() {
        isStudySession.toggle()
        timeRemaining = isStudySession ? studyMinutes * 60 : breakMinutes * 60
    }

    // MARK: - Audio

    private func playSoundRepeatedly() {
        playCurrentSound()
        soundTimer?.invalidate()
        let t = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.playCurrentSound() }
        RunLoop.main.add(t, forMode: .common)
        soundTimer = t
    }

    private func playCurrentSound() {
        if !audioEngine.isRunning { try? audioEngine.start() }
        scheduleAndPlay()
    }

    private func scheduleAndPlay() {
        guard let file = audioFile else { return }
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(file, at: nil)
        audioPlayerNode.play()
    }

    private func stopSound() {
        isSoundPlaying = false
        soundTimer?.invalidate()
        soundTimer = nil
        audioPlayerNode.stop()
    }

    // MARK: - Notifications

    private func sendNotification() {
        guard Bundle.main.bundleIdentifier != nil else { return }
        let content = UNMutableNotificationContent()
        content.title = isStudySession ? "Break Time!" : "Study Time!"
        content.body  = isStudySession ? "Great job. Take a break." : "Let's focus again."
        content.sound = .default
        UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil))
    }
}
