//
//  Actions.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import Foundation
import ReSwift

// Action to update the audio data
struct UpdateAudioDataAction: Action {
    let audioData: Data
}

// Action to update the audio text
struct UpdateAudioTextAction: Action {
    let audioText: String
}

// Action to update the conversation
struct UpdateConversationAction: Action {
    let conversation: [(role: String, content: String)]
}

// Action to send user's STT as a prompt to ChatGPT
struct SendUserTextAction: Action {
    let text: String
}

// Action to update the Interview Questions
struct UpdateInterviewQuestionsAction: Action {
    let questions: [String]
}
