import SwiftUI
import Speech
import AVFoundation

@MainActor
class BatComputerManager: ObservableObject {
    static let shared = BatComputerManager()
    
    @Published var isListening = false
    @Published var lastResponse = "Ready for commands"
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let weatherService = WeatherService()
    private let homeAutomation = HomeAutomation()
    
    init() {
        setupSpeech()
    }
    
    private func setupSpeech() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    self?.lastResponse = "Speech recognition authorized"
                case .denied:
                    self?.lastResponse = "Speech recognition denied"
                case .restricted:
                    self?.lastResponse = "Speech recognition restricted"
                case .notDetermined:
                    self?.lastResponse = "Speech recognition not determined"
                @unknown default:
                    self?.lastResponse = "Unknown authorization status"
                }
            }
        }
    }
    
    func toggleListening() async {
        if isListening {
            stopListening()
        } else {
            await startListening()
        }
    }
    
    private func stopListening() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        isListening = false
    }
    
    private func startListening() async {
        guard !isListening else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            lastResponse = "Audio session setup failed"
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            lastResponse = "Unable to create recognition request"
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let result = result {
                let transcription = result.bestTranscription.formattedString.lowercased()
                Task { @MainActor in
                    await self.handleCommand(transcription)
                }
            }
            
            if error != nil {
                self.stopListening()
                Task { @MainActor in
                    await self.startListening()
                }
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
            isListening = true
            lastResponse = "Listening..."
        } catch {
            lastResponse = "Audio engine failed to start"
        }
    }
    
    private func speak(_ text: String) {
        lastResponse = text
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.9
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func handleCommand(_ command: String) async {
        // Handle commands exactly as in the previous version
        // Copy the command handling logic from the previous main.swift
        guard command.contains("computer") else { return }
        
        guard let commandStart = command.range(of: "computer")?.upperBound else { return }
        let actualCommand = String(command[commandStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch actualCommand {
        case let cmd where cmd.contains("what time") || cmd.contains("date"):
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            speak("It is \(formatter.string(from: Date()))")
            
        // Add all the other command cases from the previous version...
        // Weather, home automation, Batcave systems, etc.
        
        default:
            speak("Command not recognized. Please try again or ask for help.")
        }
    }
}