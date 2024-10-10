//
//  ChatGPTReducer.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import Foundation
import ReSwift

func chatGPTReducer(action: Action, state: ChatGPTState?) -> ChatGPTState {
    var state = state ?? ChatGPTState()

    switch action {
    case let action as UpdateAudioDataAction:
        state.audioData = action.audioData
    case let action as UpdateAudioTextAction:
        state.audioText = action.audioText
    case let action as UpdateConversationAction:
        state.conversation = action.conversation
    case let action as UpdateInterviewQuestionsAction:
        state.interviewQuestions = action.questions
    default:
        break
    }

    return state
}
