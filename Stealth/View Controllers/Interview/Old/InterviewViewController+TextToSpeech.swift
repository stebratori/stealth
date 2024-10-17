//
//  InterviewViewController+TextToSpeech.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/18/24.
//

import Foundation
import AVFoundation

//extension InterviewViewController: AVSpeechSynthesizerDelegate {
//    
//    private func speak(text: String, withDelay delay: Double?) {
//        let speakUtterance = AVSpeechUtterance(string: text)
//        if let delay = delay {
//            speakUtterance.preUtteranceDelay = delay
//        }
//        speakUtterance.volume = 1
//        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .voicePrompt, options: [])
//        synth.speak(speakUtterance)
//    }
//
//    
//    func finishTheInterview() {
//        performSegue(withIdentifier: "segueToAnalysis", sender: self)
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        isSpeakingInProgress = true
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
//        if isSpeakingWelcomeNote {
//            isSpeakingWelcomeNote = false
//            //speakNextQuestion()
//        }
//        else if isSpeakingEndingNote {
//            isSpeakingEndingNote = false
//            finishTheInterview()
//        }
//        isSpeakingInProgress = false
//    }
//}
