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
    func didReceiveTranscribedText(_ text: String)
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer)
    func didStopRecording()
    func didFailWithError(_ error: Error)
}

protocol SpeechRecognitionServiceLogic: AnyObject {
    var delegate: SpeechRecognitionServiceDelegate? { get set }
    func start()
    func stop()
}

final class SpeechRecognitionService: NSObject, SpeechRecognitionServiceLogic, SFSpeechRecognizerDelegate {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    weak var delegate: SpeechRecognitionServiceDelegate?
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
    }
    
//    func start() {
//        SFSpeechRecognizer.requestAuthorization { [weak self] (authStatus) in
//            guard authStatus == .authorized else {
//                // Handle authorization error
//                return
//            }
//            
//            do {
//                try self?.startRecording()
//            } catch {
//                // Handle error
//            }
//        }
//    }
    
    // Request authorization and start recording
    func start() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    do {
                        try self?.startRecording()
                    } catch {
                        self?.delegate?.didFailWithError(error)
                    }
                case .denied:
                    self?.handleAuthorizationError("Speech recognition authorization denied.")
                case .restricted:
                    self?.handleAuthorizationError("Speech recognition restricted on this device.")
                case .notDetermined:
                    self?.handleAuthorizationError("Speech recognition not determined.")
                @unknown default:
                    self?.handleAuthorizationError("Unknown speech recognition authorization status.")
                }
            }
        }
    }
    
    private func handleAuthorizationError(_ message: String) {
        let error = NSError(domain: "SpeechRecognitionService", code: -1, userInfo: [NSLocalizedDescriptionKey: message])
        delegate?.didFailWithError(error)
    }
    
    func startRecording() throws {
        
        // Cancel any ongoing recognition task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Set up the audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .default, options: .mixWithOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        // Check if audio input is available
        
        let inputNode = audioEngine.inputNode
        
        // Assign the recognition request to the input node's output
        let recordingFormat = inputNode.inputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, time) in
            self.recognitionRequest?.append(buffer)
            self.delegate?.processAudioBuffer(buffer)
        }
        
        // Prepare the audio engine and start recording
        audioEngine.prepare()
        try audioEngine.start()
        
        // Start speech recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest!) { [weak self] (result, error) in
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                // Process the transcribed text and extract the required parameters
                self?.delegate?.didReceiveTranscribedText(transcribedText)
            }
        }
    }
    
    func stop() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        delegate?.didStopRecording()
    }
}
