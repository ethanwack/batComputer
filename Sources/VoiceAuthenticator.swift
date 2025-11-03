import Foundation
import Speech
import AVFoundation
import CryptoSwift
import SoundAnalysis

class VoiceAuthenticator: NSObject, SNResultsObserving {
    private var authorizedVoiceProfiles: [String: VoiceProfile] = [:]
    private let requiredConfidence: Double = 0.85
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var audioClassifier: SNAudioStreamAnalyzer?
    private var classificationRequest: SNClassifySoundRequest?
    
    struct VoiceProfile {
        let voicePrint: Data
        let spectralFeatures: [Float]
        let pitchProfile: [Float]
        let createdAt: Date
        let lastUsed: Date
    }
    
    override init() {
        super.init()
        setupAudioSession()
        setupSoundClassifier()
    }
    
    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func setupSoundClassifier() {
        do {
            let config = MLModelConfiguration()
            let soundClassifier = try GKSoundClassifier(configuration: config)
            classificationRequest = try SNClassifySoundRequest(mlModel: soundClassifier.model)
            
            let format = audioEngine.inputNode.outputFormat(forBus: 0)
            audioClassifier = SNAudioStreamAnalyzer(format: format)
            
            try audioClassifier?.add(classificationRequest!, withObserver: self)
        } catch {
            print("Failed to setup sound classifier: \(error)")
        }
    }
    
    func registerVoice(name: String) async throws -> Bool {
        let audioBuffer = try await recordAudioSample()
        let features = try await extractVoiceFeatures(from: audioBuffer)
        
        let voiceProfile = VoiceProfile(
            voicePrint: features.voicePrint,
            spectralFeatures: features.spectral,
            pitchProfile: features.pitch,
            createdAt: Date(),
            lastUsed: Date()
        )
        
        authorizedVoiceProfiles[name] = voiceProfile
        return true
    }
    
    func authenticateVoice(_ phrase: String) async throws -> Bool {
        let audioBuffer = try await recordAudioSample()
        let features = try await extractVoiceFeatures(from: audioBuffer)
        
        // Verify the spoken phrase
        let recognizedText = try await performSpeechRecognition(buffer: audioBuffer)
        guard recognizedText.lowercased().contains(phrase.lowercased()) else {
            return false
        }
        
        // Compare voice features with stored profiles
        for profile in authorizedVoiceProfiles.values {
            let confidence = calculateConfidence(
                sampleVoicePrint: features.voicePrint,
                sampleSpectral: features.spectral,
                samplePitch: features.pitch,
                profile: profile
            )
            
            if confidence >= requiredConfidence {
                return true
            }
        }
        
        return false
    }
    
    private func recordAudioSample() async throws -> AVAudioPCMBuffer {
        let duration: TimeInterval = 5.0 // 5 seconds sample
        let format = audioEngine.inputNode.outputFormat(forBus: 0)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(format.sampleRate * duration))!
        
        return try await withCheckedThrowingContinuation { continuation in
            audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
                continuation.resume(returning: buffer)
                self.audioEngine.inputNode.removeTap(onBus: 0)
            }
            
            do {
                try audioEngine.start()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func extractVoiceFeatures(from buffer: AVAudioPCMBuffer) async throws -> (voicePrint: Data, spectral: [Float], pitch: [Float]) {
        let format = buffer.format
        var voicePrint = Data()
        var spectralFeatures: [Float] = []
        var pitchFeatures: [Float] = []
        
        // Extract MFCC features
        if let mfccFeatures = try? extractMFCC(from: buffer) {
            voicePrint.append(contentsOf: mfccFeatures)
        }
        
        // Extract spectral features
        spectralFeatures = extractSpectralFeatures(from: buffer)
        
        // Extract pitch features
        pitchFeatures = extractPitchFeatures(from: buffer)
        
        return (voicePrint, spectralFeatures, pitchFeatures)
    }
    
    private func extractMFCC(from buffer: AVAudioPCMBuffer) throws -> Data {
        // Implementation would use vDSP for real MFCC calculation
        return Data()
    }
    
    private func extractSpectralFeatures(from buffer: AVAudioPCMBuffer) -> [Float] {
        // Implementation would use vDSP for spectral analysis
        return []
    }
    
    private func extractPitchFeatures(from buffer: AVAudioPCMBuffer) -> [Float] {
        // Implementation would use AVAudioEngine's pitch detection
        return []
    }
    
    private func performSpeechRecognition(buffer: AVAudioPCMBuffer) async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            let request = SFSpeechRecognitionRequest()
            // Configure request with buffer
            
            speechRecognizer.recognize(request) { result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let result = result {
                    continuation.resume(returning: result.bestTranscription.formattedString)
                } else {
                    continuation.resume(returning: "")
                }
            }
        }
    }
    
    private func calculateConfidence(
        sampleVoicePrint: Data,
        sampleSpectral: [Float],
        samplePitch: [Float],
        profile: VoiceProfile
    ) -> Double {
        var totalConfidence: Double = 0.0
        
        // Compare voiceprints using cosine similarity
        if let voiceprintConfidence = calculateCosineSimilarity(
            between: [UInt8](sampleVoicePrint),
            and: [UInt8](profile.voicePrint)
        ) {
            totalConfidence += voiceprintConfidence * 0.5 // 50% weight
        }
        
        // Compare spectral features
        let spectralConfidence = calculateFeatureSimilarity(
            between: sampleSpectral,
            and: profile.spectralFeatures
        )
        totalConfidence += spectralConfidence * 0.3 // 30% weight
        
        // Compare pitch features
        let pitchConfidence = calculateFeatureSimilarity(
            between: samplePitch,
            and: profile.pitchProfile
        )
        totalConfidence += pitchConfidence * 0.2 // 20% weight
        
        return totalConfidence
    }
    
    private func calculateCosineSimilarity(between a: [UInt8], and b: [UInt8]) -> Double? {
        guard a.count == b.count && !a.isEmpty else { return nil }
        
        let dotProduct = zip(a, b).map { Double($0.0) * Double($0.1) }.reduce(0, +)
        let magnitudeA = sqrt(a.map { Double($0) * Double($0) }.reduce(0, +))
        let magnitudeB = sqrt(b.map { Double($0) * Double($0) }.reduce(0, +))
        
        return dotProduct / (magnitudeA * magnitudeB)
    }
    
    private func calculateFeatureSimilarity(between a: [Float], and b: [Float]) -> Double {
        guard a.count == b.count && !a.isEmpty else { return 0.0 }
        
        let differences = zip(a, b).map { abs($0 - $1) }
        let averageDifference = Double(differences.reduce(0, +)) / Double(differences.count)
        
        return 1.0 - min(1.0, averageDifference)
    }
    
    // MARK: - SNResultsObserving
    
    func request(_ request: SNRequest, didProduce result: SNResult) {
        guard let result = result as? SNClassificationResult else { return }
        
        // Process sound classification results
        let topClassifications = result.classifications
            .prefix(3)
            .filter { $0.confidence > 0.5 }
        
        // Use classifications for additional voice verification
    }
    
    func request(_ request: SNRequest, didFailWithError error: Error) {
        print("Sound classification failed: \(error)")
    }
    
    // MARK: - Cleanup
    
    func cleanup() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        audioClassifier = nil
    }
}