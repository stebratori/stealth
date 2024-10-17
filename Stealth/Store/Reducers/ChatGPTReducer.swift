//
//  ChatGPTReducer.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import Foundation
import ReSwift

func chatGPTReducer(action: Action, state: ChatGPTState?) -> ChatGPTState {
    var state = state ?? ChatGPTState(jobDescription: "")

    switch action {
    case let action as UpdateAudioData:
        state.audioData = action.audioData
    case let action as UpdateConversation:
        state.conversation = action.conversation
    case let action as UpdateInterviewQuestions:
        state.interviewQuestions = action.questions
    case let action as SetJobDescription:
        state.jobDescription = action.jobDescription
    case let action as UpdatePromptTokens:
        state.promptTokens = action.tokens
    case let action as UpdateCompletionTokens:
        state.completionTokens = action.tokens
    case let action as UpdateInterviewAnalysis:
        state.interviewAnalysis = action.text
    default:
        break
    }

    return state
}
