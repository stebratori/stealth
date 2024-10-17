//
//  PromptGenerator.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/10/24.
//

import Foundation

class PromptManager {
    func createPrompt(with message: String) -> String {
        return "User said: \(message) + any additional prompt info"
    }
    
    func initialSystemPrompt() -> String {
        if let userGeneratedPrompt = Constants.Prompt.userGeneratedSystemPrompt {
            return userGeneratedPrompt
        } else {
            return Constants.Prompt.systemPrompt(jd: "mid level ios dev", questions: store.state.chatGPTState.interviewQuestions)
        }
    }
}
