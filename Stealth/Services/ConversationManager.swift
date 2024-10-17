//
//  ConversationManager.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/10/24.
//
import Foundation
import AVFAudio

enum ConversationState {
    case none
    case startingConversation
    case playingAssistantResponse
    case listeningUserVoice
    case waitingForAssistantReply
    case complete
    case interviewAnalyzed
    case error
}

protocol ConversationManagerDelegate: AnyObject {
    // Chat GPT
    func interviewComplete()
    func interviewAnalyzed()
    func assistantReplyReceived(text: String)
    
    // Speech Recognition
    func didStartRecordingSpeech()
    func didStopRecordingSpeech()
    func conversationError(error: String, title: String)
    func didReceiveTranscribedText(text: String)
    
    // Audio Player
    func didStartPlayingAudio()
    func didStopPlayingAudio()
}

class ConversationManager {
    weak var delegate: ConversationManagerDelegate?
    
    private let speechRecognitionService = SpeechRecognitionService()
    private let chatGpt = ChatGptAPI()
    private let audioPlayer = AudioPlayerService()
    private let promptManager = PromptManager()

    private var conversationHistory: [String] = []
    private var transcribedTextFromSpeech: String?
    private var conversationState: ConversationState = .none
    
    init() {
        speechRecognitionService.delegate = self
        audioPlayer.delegate = self
    }
    
    func sendInitialPromptAndStartConversation() {
        conversationState = .startingConversation
        let prompt = promptManager.initialSystemPrompt()
        store.dispatch(AppendConversationText(role: ChatGPTRoles.system.rawValue, content: prompt))
        sendUserMessageToChatGPT()
    }
    
    func startListeningToUserSpeech() {
        logger.log(message: "startListeningToUserSpeech", from: "Conversation Manager")
        conversationState = .listeningUserVoice
        speechRecognitionService.startListeningToUserSpeech()
    }
    
    func stopListeningToUserSpeech() {
        speechRecognitionService.stopRecordingUserAudio()
    }

    func sendUserMessageToChatGPT() {
        guard conversationState != .waitingForAssistantReply else { return }
        logger.log(message: "Sending user message to ChadGPT...", from: "Conversation Manager")
        conversationState = .waitingForAssistantReply
        chatGpt.sendConversation() { [weak self] result in
            switch result {
            case .success(let (reply, audioData)):
                logger.log(message: "ChatGPT reply: \(reply)", from: "Conversation Manager")
                self?.conversationState = .playingAssistantResponse
                // Have Audio Player Manager to play the received Audio Data
                self?.audioPlayer.playAudio(data: audioData)
                self?.delegate?.assistantReplyReceived(text: reply)
                // Update Conversation state with the new text reply
                store.dispatch(AppendConversationText(role: ChatGPTRoles.assistant.rawValue, content: reply))
                self?.checkIfInterviewIsFinished(reply: reply)
            case .failure(let error):
                self?.conversationState = .error
                self?.delegate?.conversationError(error: error.localizedDescription,
                                                  title: "Send User Message To ChatGPT Error")
            }
        }
    }
    
    private func checkIfInterviewIsFinished(reply: String) {
        logger.log(message: "checkIfInterviewIsFinished...", from: "Conversation Manager")
        if reply.lowercased().contains("this interview is now complete") {
            logger.log(message: "This interview is now over. Starting to Analyze the interview...", from: "Conversation Manager")
            conversationState = .complete
            startInterviewAnalysis()
        }
    }
    
    private func startInterviewAnalysis() {
        store.dispatch(AppendConversationText(role: ChatGPTRoles.user.rawValue, content: Constants.Prompt.requestAnalysis))
        chatGpt.sendConversation { [weak self] response in
            switch response {
            case .success(let (reply, _)):
                logger.log(message: "ChatGPT reply: \(reply)", from: "Conversation Manager")
                store.dispatch(UpdateInterviewAnalysis(text: reply))
                self?.conversationState = .interviewAnalyzed
                self?.delegate?.interviewAnalyzed()
            case .failure(let error):
                self?.conversationState = .error
                self?.delegate?.conversationError(error: error.localizedDescription, 
                                                  title: "Start Interview Analysis Error")
            }
        }
    }
}

extension ConversationManager: AudioPlayerServiceProtocol {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.didStopPlayingAudio()
        logger.log(message: "audioPlayerDidFinishPlaying", from: "Conversation Manager")
        if conversationState == .complete {
            logger.log(message: "interview complete!", from: "Conversation Manager")
            delegate?.interviewComplete()
        }
    }
    
    func audioPlayerDidStartplaying() {
        delegate?.didStartPlayingAudio()
    }
}

extension ConversationManager: SpeechRecognitionServiceDelegate {
    func didStartRecording() {
        transcribedTextFromSpeech = nil
        // after startConverstion is triggered and recording of
        // user's voice started, this method will fire.
    }
    
    func didReceiveTranscribedText(_ text: String) {
        transcribedTextFromSpeech = text
        delegate?.didReceiveTranscribedText(text: text)
    }
    
    func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        // If we want to save the recording of user's voice audio input, we can do it here
    }

    func didStopRecording() {
        logger.log(message: "did Stop Recording User Voice.", from: "Conversation Manager")
        guard
            let message = transcribedTextFromSpeech
        else {
            logger.log(message: "transcribedTextFromSpeech is nil", from: "Conversation Manager")
            return
        }
        store.dispatch(AppendConversationText(role: ChatGPTRoles.user.rawValue, content: message))
        sendUserMessageToChatGPT()
    }
    
    func didFailWithError(_ error: any Error) {
        self.delegate?.conversationError(error: error.localizedDescription,
                                         title: "Speech Recognition Service Error")
    }
}
