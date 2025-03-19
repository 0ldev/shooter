import UIKit
import Flutter
import AVFoundation

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?
    private var audioRecorder: AVAudioRecorder?
    private var timer: Timer?
    private var audioLevelUpdateInterval = 0.05 // 50ms
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        
        // Setup method channel for mic service
        let methodChannel = FlutterMethodChannel(name: "shooter.mic_service", binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else { return }
            
            switch call.method {
            case "startAudioMonitoring":
                self.startAudioMonitoring(result: result)
            case "stopAudioMonitoring":
                self.stopAudioMonitoring(result: result)
            case "getAudioLevel":
                self.getAudioLevel(result: result)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        // Keep screen on
        UIApplication.shared.isIdleTimerDisabled = true
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    private func startAudioMonitoring(result: @escaping FlutterResult) {
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatAppleLossless),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            // Create a temporary file URL
            let tempDir = NSTemporaryDirectory()
            let tempFile = URL(fileURLWithPath: tempDir).appendingPathComponent("temp_audio.caf")
            
            // Create and configure the audio recorder
            audioRecorder = try AVAudioRecorder(url: tempFile, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.prepareToRecord()
            
            if audioRecorder?.record() ?? false {
                // Start timer to measure audio levels
                timer = Timer.scheduledTimer(withTimeInterval: audioLevelUpdateInterval, repeats: true) { [weak self] _ in
                    self?.updateAudioLevels()
                }
                
                result(true)
            } else {
                result(FlutterError(code: "RECORD_ERROR", message: "Could not start audio recording", details: nil))
            }
        } catch {
            result(FlutterError(code: "INIT_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func stopAudioMonitoring(result: @escaping FlutterResult) {
        timer?.invalidate()
        timer = nil
        
        audioRecorder?.stop()
        audioRecorder = nil
        
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false)
        
        result(true)
    }
    
    private func getAudioLevel(result: @escaping FlutterResult) {
        guard let recorder = audioRecorder else {
            result(0.0)
            return
        }
        
        recorder.updateMeters()
        
        // Convert from dB to percentage (0-100)
        let normalizedLevel = self.normalizeLevel(recorder.averagePower(forChannel: 0))
        result(normalizedLevel)
    }
    
    private func updateAudioLevels() {
        // This is just for continuous monitoring, not needed for our current implementation
    }
    
    // Convert dB scale (-160 to 0) to percentage (0-100)
    private func normalizeLevel(_ level: Float) -> Float {
        // iOS audio levels are in dB, typically from -160 (silence) to 0 (loudest)
        // We need to map this to 0-100
        let minDb: Float = -80.0 // Treat anything below this as silence
        
        if level < minDb {
            return 0.0
        } else {
            // Map from -80...0 to 0...100
            return (level - minDb) * (100.0 / (0.0 - minDb))
        }
    }
    
    // FlutterStreamHandler protocol methods (for event channel if needed)
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        eventSink = events
        return nil
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}
