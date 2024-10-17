//
//  SystemPromptViewController.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/14/24.
//

import UIKit

class SystemPromptViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnStartTheInterview: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        let questions = store.state.chatGPTState.interviewQuestions
        let jd = store.state.chatGPTState.jobDescription
        textView.text = Constants.Prompt.systemPrompt(jd: jd, questions: questions)
    }
 
    @IBAction func startTheInterview(_ sender: UIButton) {
        Constants.Prompt.userGeneratedSystemPrompt = textView.text
        performSegue(withIdentifier: "systemPromptToInterview", sender: self)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    /* Older versions of Swift */
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
