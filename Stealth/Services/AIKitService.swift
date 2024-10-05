////
////  AIKitService.swift
////  Stealth
////
////  Created by Stefan Brankovic on 9/17/24.
////
//
//import Foundation
//import OpenAIKit
//
//class AIKitService {
//    static let shared = AIKitService()
//    private let openAI = OpenAI(Configuration(organizationId: Constants.organizationID, apiKey: Constants.openAIAPIKey))
//    var jd: String = ""
//    var tokens: Int = 0
//    
//    private func sendChatMessage(message: String) async -> String? {
//        var response: String?
//        do {
//            //            let chat: [ChatMessage] = [
//            //                ChatMessage(role: .system, content: "You are a helpful assistant."),
//            //                ChatMessage(role: .user, content: "Who won the world series in 2020?"),
//            //                ChatMessage(role: .assistant, content: "The Los Angeles Dodgers won the World Series in 2020."),
//            //                ChatMessage(role: .user, content: "Where was it played?")
//            //            ]
//            let chat: [ChatMessage] = [ChatMessage(role: .user, content: message)]
//            let chatParameters = ChatParameters(
//                model: .gpt4,  // ID of the model to use.
//                messages: chat  // A list of messages comprising the conversation so far.
//            )
//            
//            let chatCompletion = try await openAI.generateChatCompletion(
//                parameters: chatParameters
//            )
//            
//            if let message = chatCompletion.choices[0].message {
//                response = message.content
//                print("\(String(describing: message.content))")
//                
//            }
//            if let tokens = chatCompletion.usage?.totalTokens {
//                self.tokens += tokens
//            }
//        } catch {
//            print("ERROR DETAILS - \(error)")
//        }
//        return response
//    }
//    
//    func generateInterviewQuestions(jd: String, numberOfQuestions: Int) async {
//        self.jd = jd
//        let prompt: String = "Take the following job description and pretend you are the hiring manager for this role at that company that's listed on the job description. Generate \(numberOfQuestions) questions that you would ask me to determine that I am the optimal, perfect candidate for this role. This will only be a first round of interviews and we want to assess the technical skills of the candidate. Generate the output as one string of questions separated only by <Q>. Don't send back any other text in the responce other then what specified as the output format. This is the job description: \(jd)"
//        let response = await sendChatMessage(message: prompt)
//        guard let responseQuestions = response else { return }
//        let questions: [String] = responseQuestions.components(separatedBy: "<Q>")
//        QuestionsAndAnswersService.current.questions = questions
//        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationName.generateInterviewQuestions), object: nil)
//    }
//    
//    func createAnalysis() async {
//        var questions: String = ""
//        var answers: String = ""
//        for (index, question) in QuestionsAndAnswersService.current.questions.enumerated() {
//            questions += "Question \(index+1): \(question) "
//        }
//        for (index, answer) in QuestionsAndAnswersService.current.answers.enumerated() {
//            answers += "Question \(index+1): \(answer) "
//        }
//        let prompt: String = "Based on this Job Description: \(jd), you as a hiring manager generated these questions for our candidates: \(questions). Candidate provided these answers: \(answers). Please analyse the answers and grade all of them from 1-5. Then grade the entire interview 1-5 and conclude if this candidate is suitable for the next round of interviews or his knowledge was not sufficient. Provide an answer from the first person like you are talking to the candidate after an interview."
//        QuestionsAndAnswersService.current.analysis = await sendChatMessage(message: prompt)
//        NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationName.analysisDone), object: nil)
//    }
//}
