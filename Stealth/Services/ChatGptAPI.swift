import Foundation
import AVFoundation
import ReSwift

enum ChatGPTRoles: String {
    case user
    case system
    case assistant
}

class ChatGptAPI {
    private let model: String = "o1-mini"
    private var currentTask: URLSessionUploadTask?
    
    init() {
        networkMonitor.didChangeStatus = { isConnected in
            if isConnected {
                logger.log(message: "Gained internet conection", from: "ChatGptAPI")
            } else {
                logger.log(message: "Lost internet conection", from: "ChatGptAPI")
                self.currentTask?.cancel()
            }
        }
    }
    
    func obtainInitialQuestions(_ message: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: Constants.Server.chat) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] Invalid URL"])))
            return
        }
        
//        guard networkMonitor.isConnected else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] You are offline. Please conect to internet and try again."])))
//            return
//        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["message": message]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] Unable to encode message body"])))
            return
        }

        currentTask = URLSession.shared.uploadTask(with: request, from: bodyData) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI]  No data received from the server"])))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = "[ChatGptAPI]  Received non-200 HTTP status code: \(statusCode)"
                completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
                return
            }
            
            do {
                // Try to convert the response data into JSON
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Successfully parsed JSON
                    logger.log(message: "obtainInitialQuestions Parsed JSON", from: "ChatGptAPI")

                    // Extract a specific field, like 'reply'
                    if let reply = jsonObject["reply"] as? String {
                        // Parse questions using parseNumberedQuestions function
                        let questions = self.parseNumberedQuestions(from: reply)
                        completion(.success(questions))
                    } else {
                        logger.log(message: "obtainInitialQuestions Error parsing response data No 'reply' field in the response", from: "ChatGptAPI")
                        completion(.failure(NSError(domain: "",
                                                    code: 123,
                                                    userInfo: [NSLocalizedDescriptionKey: "obtainInitialQuestions Error parsing response"])))
                    }
                }
            } catch {
                // Handle JSON parsing error
                logger.log(message: "obtainInitialQuestions Error parsing response data", from: "ChatGptAPI")
                completion(.failure(error))
            }
        }
        currentTask?.resume()
    }

    // Function to send message and play voice
    func sendMessageAndPlayVoice(_ message: String, completion: @escaping (Result<(String, Data), Error>) -> Void) {
        guard let url = URL(string: Constants.Server.voice) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
//        guard networkMonitor.isConnected else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] You are offline. Please conect to internet and try again."])))
//            return
//        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["message": message]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI]  Unable to encode message body"])))
            return
        }

        currentTask = URLSession.shared.uploadTask(with: request, from: bodyData) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = "[ChatGptAPI]  Received non-200 HTTP status code: \(statusCode)"
                completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI]  No data received from the server"])))
                return
            }
            
            self?.handleResponse(data: data, completion: completion)
        }

        currentTask?.resume()
    }
    
    func sendConversation(completion: @escaping (Result<(String, Data), Error>) -> Void) {
        guard let url = URL(string: Constants.Server.completions) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI]  Invalid URL"])))
            return
        }
//        guard networkMonitor.isConnected else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] You are offline. Please conect to internet and try again."])))
//            return
//        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the body with roles and content for each message
        let messages = store.state.chatGPTState.conversation
        let body: [[String: String]] = messages.map { ["role": $0.role, "content": $0.content] }
        let requestBody = ["model": model, "messages": body] as [String : Any]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] Unable to encode message body"])))
            return
        }

        print("[ChatGPTAPI] Sending request with body:\(body), request: \(request)")
        currentTask = URLSession.shared.uploadTask(with: request, from: bodyData) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = "Received non-200 HTTP status code: \(statusCode)"
                completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] No data received from the server"])))
                return
            }
            
            self?.handleResponse(data: data, completion: completion)
        }

        currentTask?.resume()
    }
    
    func sendInitialSystemPromptAndStartConversation(prompt: String, completion: @escaping (Result<(String, Data), Error>) -> Void) {
        guard let url = URL(string: Constants.Server.completions) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] Invalid URL"])))
            return
        }
//        guard networkMonitor.isConnected else {
//            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] You are offline. Please conect to internet and try again."])))
//            return
//        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the body with roles and content for each message
        let body: [[String: String]] = [["role": "system", "content": prompt]]
        let requestBody = ["model": model, "messages": body] as [String : Any]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] Unable to encode message body"])))
            return
        }

        currentTask = URLSession.shared.uploadTask(with: request, from: bodyData) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                let errorDescription = "Received non-200 HTTP status code: \(statusCode)"
                completion(.failure(NSError(domain: "", code: statusCode, userInfo: [NSLocalizedDescriptionKey: errorDescription])))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] No data received from the server"])))
                return
            }

            self?.handleResponse(data: data, completion: completion)
        }

        currentTask?.resume()
    }
    
    // Private function to handle the response
    private func handleResponse(data: Data, completion: @escaping (Result<(String, Data), Error>) -> Void) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let base64Audio = json["audio"] as? String,
               let audioData = Data(base64Encoded: base64Audio),
               let reply = json["reply"] as? String {
                
                // Retrieve token usage from the response if available
                if let usage = json["usage"] as? [String: Any], 
                    let promptTokens = usage["prompt_tokens"] as? Int {
                    store.dispatch(UpdatePromptTokens(tokens: promptTokens))
                }
                if let usage = json["usage"] as? [String: Any], 
                    let completionTokens = usage["completion_tokens"] as? Int {
                    store.dispatch(UpdateCompletionTokens(tokens: completionTokens))
                }
                
                 // Completion handler for further processing
                 completion(.success((reply, audioData)))
                
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "[ChatGptAPI] Parsing JSON response failed"])
                completion(.failure(error))
            }
        } catch {
            completion(.failure(error))
        }
    }
    
    private func parseNumberedQuestions(from response: String) -> [String] {
        return response.components(separatedBy: "<Q>")
    }
}

