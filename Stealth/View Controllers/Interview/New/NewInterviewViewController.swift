//
//  NewInterviewViewController.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/11/24.
//

import UIKit

class NewInterviewViewController: UIViewController {
    var muted: Bool = true
    private let conversationManager = ConversationManager()
    private var loader: UIView?
    private var interviewStarted: Bool = false
    @IBOutlet weak var btnRecordSpeech: UIButton!
    @IBOutlet weak var lblAssistant: UILabel!
    @IBOutlet weak var lblUser: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        conversationManager.delegate = self
        logger.log(message: "sendInitialPromptAndStartConversation", from: "InterviewViewController")
        conversationManager.sendInitialPromptAndStartConversation()
        showLoader(withText: "The interview is starting. Please wait...")
    }

    @IBAction func muteUnmute(_ sender: Any) {
        muteUnmuteAndButtons()
    }
    
    private func muteUnmuteAndButtons() {
        if muted {
            // Unmute and start talking
            btnRecordSpeech.setTitle("Stop talking", for: .normal)
            btnRecordSpeech.backgroundColor = .red
            conversationManager.startListeningToUserSpeech()
        } else {
            // Mute and stop talking
            conversationManager.stopListeningToUserSpeech()
            btnRecordSpeech.setTitle("Start talking", for: .normal)
            btnRecordSpeech.backgroundColor = .green
        }
        muted = !muted
    }
}

extension NewInterviewViewController: ConversationManagerDelegate {
    func conversationError(error: String, title: String) {
        showPopup(title: title, message: error)
        logger.log(message: "Conversation Error (delegate) \(error)", from: "Conversation Manager")
    }
    
    func didStartPlayingAudio() {
        if !interviewStarted {
            interviewStarted = true
            hidePopup()
            showPopup(title: "Test Popup", message: "Test popup Message")
        }
    }
    
    func assistantReplyReceived(text: String) {
        DispatchQueue.main.async {
            self.lblAssistant.text = text
        }
    }
    
    func didReceiveTranscribedText(text: String) {
        DispatchQueue.main.async {
            self.lblUser.text = text
        }
    }
    
    func interviewComplete() {
        showLoader(withText: "Please wait while the interview is being processed...")
    }

    func interviewAnalyzed() {
        hidePopup()
        DispatchQueue.main.async { [weak self] in
            self?.performSegue(withIdentifier: "segueToAnalysis", sender: self)
        }
    }
    
    func didStartRecordingSpeech() {
        muteUnmuteAndButtons()
    }
    
    // This should be called only if speech recording ends programatically or automatically
    func didStopRecordingSpeech() { }
    
    func didStopPlayingAudio() { }
}
