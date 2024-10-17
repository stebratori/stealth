//
//  SpeechRecognitionService.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/19/24.
//
import Foundation
import AVFoundation
import Speech

protocol SpeechRecognitionServiceDelegate: AnyObject {
    func didStartRecording()
    func didReceiveTranscribedText(_ text: String)
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer)
    func didStopRecording()
    func didFailWithError(_ error: Error)
}

final class SpeechRecognitionService: NSObject, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var authStatus: SFSpeechRecognizerAuthorizationStatus?
    private var timer: Timer?
    private let timerValue = 5
    // Variable to keep track of the full transcription
    private var fullTranscription = ""
    
    weak var delegate: SpeechRecognitionServiceDelegate?
    
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
    // Request authorization and start recording
    func startListeningToUserSpeech() {
        logger.log(message: "startListeningToUserSpeech", from: "SpeechRecognitionService")
        if let authStatus = authStatus, authStatus == .authorized {
            logger.log(message: "authStatus == .authorized", from: "SpeechRecognitionService")
            do {
                try startRecording()
            } catch {
                delegate?.didFailWithError(error)
            }
        } else {
            SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
                logger.log(message: "SFSpeechRecognizer requesting authorization", from: "SpeechRecognitionService")
                DispatchQueue.main.async {
                    switch authStatus {
                    case .authorized:
                        do {
                            try self?.startRecording()
                            self?.authStatus = .authorized
                            logger.log(message: "authStatus == .authorized", from: "SpeechRecognitionService")
                        } catch {
                            self?.delegate?.didFailWithError(error)
                        }
                    case .denied:
                        self?.handleAuthorizationError("authorization denied.")
                    case .restricted:
                        self?.handleAuthorizationError("restricted on this device.")
                    case .notDetermined:
                        self?.handleAuthorizationError("not determined.")
                    @unknown default:
                        self?.handleAuthorizationError("Unknown speech recognition authorization status.")
                    }
                }
            }
        }
    }
    
    // Start recording and setting up the audio engine and recognition task
    private func startRecording() throws {
        logger.log(message: "startRecording()", from: "SpeechRecognitionService")
        fullTranscription = ""
        // Cancel any ongoing recognition task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Set up the audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .default, options: .mixWithOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            let error = NSError(domain: "SpeechRecognitionService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request."])
            delegate?.didFailWithError(error)
            throw error
        }
        
        delegate?.didStartRecording()
        recognitionRequest.shouldReportPartialResults = true
        
        // Set up input node
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            recognitionRequest.append(buffer)
            self?.delegate?.processAudioBuffer(buffer)
        }
        
        // Prepare and start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        // Start speech recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let error = error {
                //self?.delegate?.didFailWithError(error)
                self?.stopRecordingUserAudio() // Stop recognition on failure
                return
            } else if let result = result, let self = self {
                self.fullTranscription = getFinalTranscription(from: result)
                self.delegate?.didReceiveTranscribedText(self.fullTranscription)
            }
        }
    }
    
    // Helper function to return the final transcribed text across pauses
    private func getFinalTranscription(from result: SFSpeechRecognitionResult) -> String {
        var cumulativeTranscription = self.fullTranscription
        
        // Append new segments only
        for segment in result.bestTranscription.segments {
            let segmentText = segment.substring
            if !cumulativeTranscription.contains(segmentText) {
                cumulativeTranscription += " \(segmentText)"
            }
        }
        
        return cumulativeTranscription.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // Stop recording and clean up
    func stopRecordingUserAudio() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        deactivateAudioSession()
        delegate?.didStopRecording()
    }
    
    
    private func handleAuthorizationError(_ message: String) {
        let error = NSError(domain: "SpeechRecognitionService", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
        delegate?.didFailWithError(error)
    }
    
    // Deactivate the audio session after stopping the recognition
    private func deactivateAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            delegate?.didFailWithError(error)
        }
    }
}
