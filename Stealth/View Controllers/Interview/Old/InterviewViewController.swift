//
//  ViewController.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/11/24.
//

import UIKit
import AVFoundation

class InterviewViewController: UIViewController {
    @IBOutlet weak var btnRecord: UIButton!
    @IBOutlet weak var viewNotification: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    var circleAnimationView: CircleAnimationView?
    private var notificationVisible: Bool = false
    
    private var isRecordingVoice: Bool = false
    
    var isSpeakingWelcomeNote: Bool = false
    var isSpeakingEndingNote: Bool = false
    var isSpeakingInProgress: Bool = false
    var questionIndex: Int = 0
    var lastAnswer: String?
    var timer: Timer?
    var audioPlayer: AVAudioPlayer?
    
    private var debounceTimer: Timer?
    var followUpCount: Int = 0
    let maxFollowUps: Int = 2
    
    let synth = AVSpeechSynthesizer()
    let speechRecognitionService = SpeechRecognitionService()
    
    lazy var audioDataSubscriber = AnonymousStoreSubscriber<ChatGPTState> { [weak self] chatGPTState in
        // Handle state change for audioData
        self?.handleNewAudioData(chatGPTState.audioData)
    }
    
    private let conversationManager = ConversationManager()
    
    // kada se doda odgovor chatgpt na postojecu konverzaciju, unmute user
    override func viewDidLoad() {
        super.viewDidLoad()
        print("[Interview VC] conversationManager.sendInitialPromptAndStartConversation")
        conversationManager.sendInitialPromptAndStartConversation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func subscribeToStore() {
        // Subscribe to only audioData changes
        store.subscribe(audioDataSubscriber) { subscription in
            subscription
                .select { $0.chatGPTState }
                .only { $0.audioData != $1.audioData }
        }
    }
    
    // This method will be called when audioData changes
    func handleNewAudioData(_ audioData: Data) {
        print("[Interview VC] handleNewAudioData Audio data changed: \(audioData)")
        playAudioData(audioData: audioData)
    }
    
    @IBAction func startStopRecording(_ sender: UIButton) {

    }
    
    private func toggleRecording(_ sender: UIButton) {
        guard !isSpeakingWelcomeNote, !isSpeakingInProgress else {
            showWaitForYourTurnToTalkNotification()
            return
        }
        if isRecordingVoice {
            print("[Interview VC] stopped recording.")
            //speechRecognitionService.stop()
            isRecordingVoice = false
            sender.setTitle("Unmute", for: .normal)
            sender.backgroundColor = .green
            if let lastAnswer = lastAnswer {
                sendMessageToChatGPT(message: lastAnswer)
            }
        } else {
            print("[Interview VC] started recording...")
            //speechRecognitionService.start()
            isRecordingVoice = true
            sender.setTitle("Mute", for: .normal)
            sender.backgroundColor = .red
        }
    }
    
    private func sendMessageToChatGPT(message: String) {
        print("[Interview VC] sendMessageToChatGPT [Conversation Hitstory]: \(message)")
        //store.dispatch(SendUserTextAction(text: message))
        
//        ChatGptAPI.shared.sendConversationAndPlayVoice(store.state.chatGPTState.conversation) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let (reply, _)):
//                    print("[Interview VC] sendMessageToChatGPT sendMessageAndPlayVoice success. Reply: \(reply)")
//                    //self?.updateConversation(with: "ChatGPT: \(reply)")
//                case .failure(let error):
//                    print("[Interview VC] sendMessageToChatGPT sendMessageAndPlayVoice error \(error)")
//                    print(error.localizedDescription)
//                }
//            }
//        }
    }
    
    private func showWaitForYourTurnToTalkNotification() {
        guard !notificationVisible else { return }
        viewNotification.alpha = 1.0
        notificationVisible = true
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { _ in
            UIView.animate(withDuration: 0.7) {
                self.viewNotification.alpha = 0.0
                self.notificationVisible = false
            }
        }
    }
}

// AUDIO
extension InterviewViewController: AVAudioPlayerDelegate {
    func playAudioData(audioData: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            audioPlayer?.delegate = self
            print("[Interview VC] playAudioData:\(audioData)")
        }
        catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("[Interview VC] audioPlayerDidFinishPlaying successfully:\(flag)")
        circleAnimationView?.stopAnimating()
        // Automatically prompt user for next response
        if !isSpeakingEndingNote {
            startRecording()
        }
    }

    private func startRecording() {
        print("[Interview VC] startRecording but isSpeakingInProgress!!!")
        guard !isSpeakingInProgress else { return }
        print("[Interview VC] startRecording")
        //speechRecognitionService.start()
        isRecordingVoice = true
        btnRecord.setTitle("Mute", for: .normal)
        btnRecord.backgroundColor = .red
    }
    
    // Helper function to configure the audio session
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            print("[Interview VC] configureAudioSession")
        } catch {
            print("[Interview VC] Failed to configure and activate audio session: \(error.localizedDescription)")
        }
    }
}

//extension InterviewViewController: SpeechRecognitionServiceDelegate {
//    func didStopRecording() {
//        print("[Interview VC] SpeechRecognitionServiceDelegate didStopRecording timer?.invalidate()")
//        timer?.invalidate()
//        timer = nil
//    }
//    
//    func didFailWithError(_ error: any Error) {
//        print("InterviewViewController didFailWithError: \(error.localizedDescription)")
//    }
//    
//    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) { }
//    
//    func didReceiveTranscribedText(_ text: String) {
//        lastAnswer = text
////        timer?.invalidate()
////        timer = nil
////        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { _ in
////            self.triggerIdleTimer()
////        })
//    }
//
//    
//    func recordingDidStop() {
//        
//    }
//
//    private func triggerIdleTimer() {
//       // speakNextQuestion()
//    }
//}
//
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
//        print("[Interview VC] speak: \(text)")
//    }
//
//    
//    func finishTheInterview() {
//        performSegue(withIdentifier: "segueToAnalysis", sender: self)
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
//        print("[Interview VC] speechSynthesizer didStart")
//        isSpeakingInProgress = true
//    }
//    
//    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {     
//        print("[Interview VC] speechSynthesizer didFinish")
//        if isSpeakingWelcomeNote {
//            isSpeakingWelcomeNote = false
//            print("[Interview VC] speechSynthesizer didFinish ")
//        } else if isSpeakingEndingNote {
//            isSpeakingEndingNote = false
//            finishTheInterview()
//            print("[Interview VC] speechSynthesizer didFinish isSpeakingEndingNote")
//        }
//        isSpeakingInProgress = false
//
//        // Continue the conversation
//        if let lastAnswer = lastAnswer {
//            print("[Interview VC] speechSynthesizer sendMessageToChatGPT: \(lastAnswer)")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.sendMessageToChatGPT(message: lastAnswer)
//            }
//        }
//    }
//}
