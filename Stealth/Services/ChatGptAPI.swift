import Foundation
import AVFoundation
import ReSwift

class ChatGptAPI {
    
    static func sendMessageAndPlayVoice(_ message: String) {
        guard let url = URL(string: Constants.Server.voice) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["message": message]
        guard let bodyData = try? JSONSerialization.data(withJSONObject: body) else { return }

        let task = URLSession.shared.uploadTask(with: request, from: bodyData) { data, response, error in
            guard let data = data, error == nil else {
                print("Error sendMessageAndPlayVoice: \(error?.localizedDescription ?? "sendMessageAndPlayVoice Unknown error")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let base64Audio = json["audio"] as? String,
                   let audioData = Data(base64Encoded: base64Audio) {


                    store.dispatch(UpdateAudioDataAction(audioData: audioData))

                    if let reply = json["reply"] as? String {
                        store.dispatch(UpdateAudioTextAction(audioText: reply))
                    }
                }
                else {
                    print("parsing error)")
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }

        task.resume()
    }
}
