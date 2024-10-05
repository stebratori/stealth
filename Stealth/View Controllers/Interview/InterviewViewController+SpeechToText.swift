//
//  InterviewViewController+SpeechToText.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/18/24.
//

import Foundation
import AVFoundation

extension InterviewViewController: SpeechRecognitionServiceDelegate {
    func didStopRecording() {
        recordingDidStop()
        timer?.invalidate()
        timer = nil
    }
    
    func didFailWithError(_ error: any Error) {
        <#code#>
    }
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) { }
    
    func didReceiveTranscribedText(_ text: String) {
        lastAnswer = text
//        timer?.invalidate()
//        timer = nil
//        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { _ in
//            self.triggerIdleTimer()
//        })
    }

    
    func recordingDidStop() {
        
    }

    private func triggerIdleTimer() {
       // speakNextQuestion()
    }
}
