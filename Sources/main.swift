//
//  main.swift
//  batComputer
//
//  Created by Ethan Wacker on 2/21/23.
//

import Foundation
import Speech
import AVFoundation
import ArgumentParser

@main
struct BatComputerCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "batcomputer",
        abstract: "Bat Computer Voice Assistant"
    )
    
    func run() throws {
        print("🦇 Initializing Bat Computer...")
        
        // Check if speech recognizer is available
        guard SFSpeechRecognizer(locale: Locale(identifier: "en-US")) != nil else {
            print("❌ Speech recognizer not available for en-US")
            return
        }
        
        print("✅ Speech recognizer available")
        
        let computer = BatComputer()
        
        print("🎤 Waiting for speech authorization...")
        print("⚠️  You may need to grant microphone and speech recognition permissions in System Settings")
        print("📍 System Settings → Privacy & Security → Microphone/Speech Recognition")
        print("\nPress Ctrl+C to quit\n")
        
        RunLoop.main.run()
    }
}

class BatComputer {
    private var speechRecognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isListening = false
    
    private let homeAutomation = HomeAutomation()
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        setupSpeech()
    }
    
    private func setupSpeech() {
        print("Requesting speech recognition authorization...")
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("✅ Speech recognition authorized")
                    self.startListening()
                case .denied:
                    print("❌ Speech recognition denied - please enable in System Settings")
                case .restricted:
                    print("⚠️  Speech recognition restricted on this device")
                case .notDetermined:
                    print("⏳ Speech recognition not yet authorized")
                @unknown default:
                    print("❓ Unknown authorization status")
                }
            }
        }
    }
    
    private func speak(_ text: String) {
        print("🔊 Speaking: \(text)")
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.9
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func startListening() {
        guard !isListening else { return }
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("❌ Speech recognizer not available")
            return
        }
        
        do {
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            
            let inputNode = audioEngine.inputNode
            guard let recognitionRequest = recognitionRequest else {
                print("❌ Unable to create recognition request")
                return
            }
            
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
                guard let self = self else { return }
                
                if let result = result {
                    let transcription = result.bestTranscription.formattedString.lowercased()
                    if transcription.contains("computer") {
                        print("🎯 Command detected: \(transcription)")
                        self.handleCommand(transcription)
                    }
                }
                
                if let error = error {
                    print("⚠️  Recognition error: \(error.localizedDescription)")
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                    
                    // Wait a bit before restarting
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.startListening()
                    }
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
                self?.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            isListening = true
            print("🎤 Bat Computer is listening... Say 'Computer' followed by a command")
            speak("Bat Computer online. Awaiting your orders.")
            
        } catch {
            print("❌ Failed to start audio engine: \(error.localizedDescription)")
        }
    }
    
    private func handleCommand(_ command: String) {
        guard let commandStart = command.range(of: "computer")?.upperBound else { return }
        let actualCommand = String(command[commandStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        print("💬 Processing command: '\(actualCommand)'")
        
        switch actualCommand {
        case let cmd where cmd.contains("what time") || cmd.contains("date"):
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            speak("It is \(formatter.string(from: Date()))")
            
        case let cmd where cmd.contains("lights"):
            if cmd.contains("on") {
                speak(homeAutomation.controlDevice("lights", action: "ON"))
            } else if cmd.contains("off") {
                speak(homeAutomation.controlDevice("lights", action: "OFF"))
            }
            
        case let cmd where cmd.contains("batcave status"):
            speak(BatmanResponses.batcaveStatus.joined(separator: ". "))
            
        case let cmd where cmd.contains("hello") || cmd.contains("hi"):
            speak(BatmanResponses.getRandomResponse(from: BatmanResponses.greetings))
            
        case let cmd where cmd.contains("goodbye") || cmd.contains("bye"):
            speak("Bat Computer standing by. Maintaining surveillance of Gotham City.")
            
        case let cmd where cmd.contains("thank"):
            speak("At your service, sir.")
            
        case let cmd where cmd.contains("help"):
            speak("Available commands include: time, date, batcave status, lights control, hello, goodbye, and thank you.")
            
        default:
            speak("Command not recognized. Please try again or ask for help.")
        }
    }
}
