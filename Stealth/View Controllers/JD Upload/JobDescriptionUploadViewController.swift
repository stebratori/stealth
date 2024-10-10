//
//  JobDescriptionUploadViewController.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/17/24.
//

import UIKit

class JobDescriptionUploadViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var btnGenerate: UIButton!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(questionsGenerated),
                                               name: Notification.Name(Constants.NotificationName.generateInterviewQuestions),
                                               object: nil)
        textView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //textView.text = ""
        btnGenerate.isEnabled = true
        loader.isHidden = true
        btnGenerate.setTitle("Generate", for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func generateInterviewQuestions(_ sender: UIButton) {
        loader.isHidden = false
        let jd: String = textView.text
        btnGenerate.isEnabled = false
        let message: String = Constants.Prompt.startingPrompt + jd
        ChatGptAPI.shared.obtainInitialQuestions(message) { result in
            switch result {
            case .success(let questions):
                // Handle the obtained list of questions
                print("Questions: \(questions)")
                store.dispatch(UpdateInterviewQuestionsAction(questions: questions))
                self.questionsGenerated()
            case .failure(let error):
                // Handle the error
                print("generateInterviewQuestions Error: \(error.localizedDescription)")
            }
        }
    }
    
    @objc
    func questionsGenerated() {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "segueToGeneratedQuestions", sender: self)
        }
    }

    /* Updated for Swift 4 */
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
