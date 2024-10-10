import Foundation
import AVFoundation
import ReSwift

class ChatGptAPI {
    
    static let shared = ChatGptAPI()
    
    private init() {}
    
    func obtainInitialQuestions(_ message: String, completion: @escaping (Result<[String], Error>) -> Void) {
        guard let url = URL(string: Constants.Server.chat) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["message": message]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode message body"])))
            return
        }

        let task = URLSession.shared.uploadTask(with: request, from: bodyData) { data, response, error in
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
            
            guard let data = data, let responseString = String(data: data, encoding: .utf8) else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])))
                return
            }
            
            do {
                // Try to convert the response data into JSON
                if let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    // Successfully parsed JSON
                    print("obtainInitialQuestions Parsed JSON: \(jsonObject)")

                    // Extract a specific field, like 'reply'
                    if let reply = jsonObject["reply"] as? String {
                        // Parse questions using parseNumberedQuestions function
                        let questions = self.parseNumberedQuestions(from: reply)
                        completion(.success(questions))
                    } else {
                        print("obtainInitialQuestions Error parsing response data No 'reply' field in the response")
                    }
                }
            } catch {
                // Handle JSON parsing error
                print("obtainInitialQuestions Error parsing response data: \(error.localizedDescription)")
            }
            
            
        }

        task.resume()
    }

    // Function to send message and play voice
    func sendMessageAndPlayVoice(_ message: String, completion: @escaping (Result<(String, Data), Error>) -> Void) {
        guard let url = URL(string: Constants.Server.voice) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = ["message": message]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode message body"])))
            return
        }

        let task = URLSession.shared.uploadTask(with: request, from: bodyData) { [weak self] data, response, error in
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
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])))
                return
            }
            
            self?.handleResponse(data: data, completion: completion)
        }

        task.resume()
    }
    
    func sendConversationAndPlayVoice(_ messages: [(role: String, content: String)], completion: @escaping (Result<(String, Data), Error>) -> Void) {
        guard let url = URL(string: Constants.Server.completions) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Construct the body with roles and content for each message
        let body: [[String: String]] = messages.map { ["role": $0.role, "content": $0.content] }
        let requestBody = ["messages": body]

        guard let bodyData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to encode message body"])))
            return
        }

        let task = URLSession.shared.uploadTask(with: request, from: bodyData) { [weak self] data, response, error in
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
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received from the server"])))
                return
            }
            
            self?.handleResponse(data: data, completion: completion)
        }

        task.resume()
    }
    
    // Private function to handle the response
    private func handleResponse(data: Data, completion: @escaping (Result<(String, Data), Error>) -> Void) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let base64Audio = json["audio"] as? String,
               let audioData = Data(base64Encoded: base64Audio),
               let reply = json["reply"] as? String {
                
                // Dispatch actions to store
                store.dispatch(UpdateAudioDataAction(audioData: audioData))
                store.dispatch(UpdateAudioTextAction(audioText: reply))

                // Completion handler for further processing
                completion(.success((reply, audioData)))
            } else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Parsing JSON response failed"])
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

