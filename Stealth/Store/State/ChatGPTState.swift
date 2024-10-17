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
    var interviewQuestions: [String]
    var jobDescription: String
    var conversation: [(role: String, content: String)]
    var promptTokens: Int = 0
    var completionTokens: Int = 0
    var interviewAnalysis: String = ""

    // Initialize with default values
    init(audioData: Data = Data(), 
         conversation: [(role: String, content: String)] = [],
         interviewQuestions: [String] = [],
         jobDescription: String) {
        self.audioData = audioData
        self.conversation = conversation
        self.interviewQuestions = interviewQuestions
        self.jobDescription = jobDescription
    }
}

