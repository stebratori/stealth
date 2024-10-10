//
//  ChatGPTState.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/1/24.
//

import ReSwift
import Foundation

// Define the ChatGPTState struct
struct ChatGPTState {
    var audioData: Data
    var audioText: String
    var conversation: [(role: String, content: String)]
    var interviewQuestions: [String]

    // Initialize with default values
    init(audioData: Data = Data(), audioText: String = "", conversation: [(role: String, content: String)] = [], interviewQuestions: [String] = []) {
        self.audioData = audioData
        self.audioText = audioText
        self.conversation = conversation
        self.interviewQuestions = interviewQuestions
    }
}

