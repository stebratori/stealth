//
//  Actions.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import Foundation
import ReSwift

// Action to update the audio data
struct UpdateAudioData: Action {
    let audioData: Data
}

// Action to update the conversation
struct UpdateConversation: Action {
    let conversation: [(role: String, content: String)]
}

struct AppendConversationText: Action {
    let role: String
    let content: String
}

struct SetJobDescription: Action {
    let jobDescription: String
}

// Action to update the Interview Questions
struct UpdateInterviewQuestions: Action {
    let questions: [String]
}

struct UpdatePromptTokens: Action {
    let tokens: Int
}

struct UpdateCompletionTokens: Action {
    let tokens: Int
}

struct UpdateInterviewAnalysis: Action {
    let text: String
}
