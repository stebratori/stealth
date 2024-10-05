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
    
    let synth = AVSpeechSynthesizer()
    let speechRecognitionService = SpeechRecognitionService()
    
    lazy var audioDataSubscriber = AnonymousStoreSubscriber<ChatGPTState> { [weak self] chatGPTState in
        // Handle state change for audioData
        self?.handleNewAudioData(chatGPTState.audioData)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureAudioSession()
        synth.delegate = self
        speechRecognitionService.delegate = self
        ChatGptAPI.sendMessageAndPlayVoice(store.state.chatGPTState.conversation.last!)
        subscribeToStore()
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
        print("Audio data changed: \(audioData)")
        playAudioData(audioData: audioData)
    }
    
    @IBAction func startStopRecording(_ sender: UIButton) {
        guard
            !isSpeakingWelcomeNote, !isSpeakingInProgress
        else {
            showWaitForYourTurnToTalkNotification()
            return
        }
        if isRecordingVoice {
            speechRecognitionService.stop()
            isRecordingVoice = false
            sender.setTitle("Unmute", for: .normal)
            sender.backgroundColor = .green
            sendConversationToChatGPT()
        } else {
            speechRecognitionService.start()
            isRecordingVoice = true
            sender.setTitle("Mute", for: .normal)
            sender.backgroundColor = .red
        }
    }
    
    private func sendConversationToChatGPT() {
        //ChatGptAPI.continueConversationWithVoice(store.state.chatGPTState.conversation)
        ChatGptAPI.sendMessageAndPlayVoice(store.state.chatGPTState.conversation.last!)
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
        }
        catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        circleAnimationView?.stopAnimating()
    }
    
    // Helper function to configure the audio session
    func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to configure and activate audio session: \(error.localizedDescription)")
        }
    }
}



