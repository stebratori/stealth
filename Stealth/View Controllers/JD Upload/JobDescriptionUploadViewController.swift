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
    private let chatGpt = ChatGptAPI()
    private let defaultConstraintValue: CGFloat = 20
    @IBOutlet weak var textViewConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)

    }
    
    deinit {
        // Don't forget to remove the observers when the view controller is deallocated
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        btnGenerate.isEnabled = true
        loader.isHidden = true
        btnGenerate.setTitle("Generate", for: .normal)
    }
    
    @IBAction func generateInterviewQuestions(_ sender: UIButton) {
        logger.log(message: "generateInterviewQuestions", from: "JobDescriptionUploadViewController")
        DispatchQueue.main.async { [weak self] in
            self?.loader.isHidden = false
            self?.loader.alpha = 1
        }
        let jd: String = textView.text
        store.dispatch(SetJobDescription(jobDescription: jd))
        btnGenerate.isEnabled = false
        let message: String = Constants.Prompt.startingPrompt + jd
        chatGpt.obtainInitialQuestions(message) { [weak self] result in
            switch result {
            case .success(let questions):
                // Handle the obtained list of questions
                logger.log(message: "Questions generated", from: "JobDescriptionUploadViewController")
                store.dispatch(UpdateInterviewQuestions(questions: questions))
                self?.questionsGenerated()
            case .failure(let error):
                // Handle the error
                logger.log(message: "generateInterviewQuestions \(error.localizedDescription)", 
                           from: "JobDescriptionUploadViewController")
                self?.showPopup(title: "Generate Questions Error",
                                message: "error.localizedDescription")
            }
        }
    }
    
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
    
    @objc
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            // Adjust the text view's height by reducing it based on the keyboard height
            adjustTextViewHeight(keyboardHeight: keyboardHeight)
        }
    }

    @objc
    func keyboardWillHide(notification: NSNotification) {
        // Reset the text view's height back to its original height
        adjustTextViewHeight(keyboardHeight: defaultConstraintValue)
    }
    
    func adjustTextViewHeight(keyboardHeight: CGFloat) {
        
        // Adjust the height constraint
        textViewConstraint.constant = keyboardHeight
        
        // Animate the layout changes
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
