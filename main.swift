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
import Alamofire

@main
struct BatComputerCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "batcomputer",
        abstract: "Bat Computer Voice Assistant"
    )
    
    func run() throws {
        let computer = BatComputer()
        RunLoop.main.run()
    }
}

class BatComputer {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private let audioEngine = AVAudioEngine()
    private let synthesizer = AVSpeechSynthesizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var isListening = false
    
    private let weatherService = WeatherService()
    private let voiceAuth = VoiceAuthenticator()
    private let homeAutomation = HomeAutomation()
    private var isAuthenticated = false
    
    init() {
        setupSpeech()
    }
    
    private func setupSpeech() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                    self.startListening()
                case .denied:
                    print("User denied speech recognition authorization")
                case .restricted:
                    print("Speech recognition restricted on this device")
                case .notDetermined:
                    print("Speech recognition not yet authorized")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }
    
    private func speak(_ text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB") // Using British accent for that Alfred feel
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.9
        utterance.volume = 1.0
        
        synthesizer.speak(utterance)
    }
    
    private func startListening() {
        guard !isListening else { return }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Audio session setup failed: \(error)")
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        guard let recognitionRequest = recognitionRequest else {
            print("Unable to create recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let transcription = result.bestTranscription.formattedString.lowercased()
                if transcription.contains("computer") {
                    self.handleCommand(transcription)
                }
            }
            
            if error != nil {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.startListening()
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
            print("Bat Computer is listening...")
        } catch {
            print("Audio engine failed to start: \(error)")
        }
    }
    
    private func handleCommand(_ command: String) async {
        // Extract the actual command (everything after "computer")
        guard let commandStart = command.range(of: "computer")?.upperBound else { return }
        let actualCommand = String(command[commandStart...]).trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Authentication required for sensitive commands
        let sensitiveCommands = ["security", "batcave", "override", "protocol", "weapons"]
        let requiresAuth = sensitiveCommands.contains { actualCommand.contains($0) }
        
        if requiresAuth && !isAuthenticated {
            speak("Voice authentication required. Please state: 'I am vengeance, I am the night'")
            // In a real implementation, this would process the next voice input for authentication
            return
        }
        
        switch actualCommand {
        // Time and Date
        case let cmd where cmd.contains("what time") || cmd.contains("date"):
            let formatter = DateFormatter()
            formatter.dateStyle = .full
            formatter.timeStyle = .short
            speak("It is \(formatter.string(from: Date()))")
            
        // Weather
        case let cmd where cmd.contains("weather"):
            if let city = extractCity(from: cmd) {
                do {
                    let weather = try await weatherService.getCurrentWeather(for: city)
                    speak(weather)
                } catch {
                    speak("Weather monitoring systems encountered an error. Please try again later.")
                }
            } else {
                speak("Please specify a city for weather information.")
            }
            
        // Home Automation
        case let cmd where cmd.contains("lights"):
            if cmd.contains("on") {
                speak(homeAutomation.controlDevice("lights", action: "ON"))
            } else if cmd.contains("off") {
                speak(homeAutomation.controlDevice("lights", action: "OFF"))
            }
            
        case let cmd where cmd.contains("security"):
            if cmd.contains("arm") {
                speak(homeAutomation.controlDevice("security", action: "ARMED"))
            } else if cmd.contains("disarm") {
                speak(homeAutomation.controlDevice("security", action: "DISARMED"))
            }
            
        // Batcave Systems
        case let cmd where cmd.contains("batcave status"):
            speak(BatmanResponses.batcaveStatus.joined(separator: "\n"))
            
        case let cmd where cmd.contains("batmobile"):
            if cmd.contains("start") {
                speak("Batmobile engines initialized. Ready for deployment.")
            } else if cmd.contains("status") {
                speak("Batmobile systems: Fuel at 98%, weapons armed, defensive systems active.")
            }
            
        // Villain Information
        case let cmd where cmd.contains("locate"):
            for villain in BatmanResponses.villains.keys {
                if cmd.contains(villain.lowercased()) {
                    speak(BatmanResponses.getVillainInfo(villain))
                    return
                }
            }
            speak("No tracking data available for the specified target.")
            
        // System Controls
        case let cmd where cmd.contains("system"):
            if cmd.contains("status") {
                speak(homeAutomation.getStatus())
            } else if cmd.contains("shutdown") {
                speak("Warning: Full system shutdown requires override authorization.")
            }
            
        // Basic Interactions
        case let cmd where cmd.contains("hello") || cmd.contains("hi"):
            speak(BatmanResponses.getRandomResponse(from: BatmanResponses.greetings))
            
        case let cmd where cmd.contains("goodbye") || cmd.contains("bye"):
            speak("Bat Computer standing by. Maintaining surveillance of Gotham City.")
            
        case let cmd where cmd.contains("thank"):
            speak("At your service, sir.")
            
        case let cmd where cmd.contains("help"):
            speak("""
                Available commands include:
                - Time and date
                - Weather for any city
                - Batcave status
                - Security systems control
                - Lighting control
                - Villain tracking
                - Batmobile control
                - System status
                Just say 'computer' followed by your command.
                """)
            
        default:
            speak("Command not recognized. Please try again or ask for help.")
        }
    }
}

// Start the Bat Computer
let batComputer = BatComputer()

// Keep the program running
RunLoop.main.run()
