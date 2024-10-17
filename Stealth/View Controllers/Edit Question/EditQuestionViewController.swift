//
//  EditQuestionViewController.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/17/24.
//

import UIKit

class EditQuestionViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    private var initialQuestion: String = ""
    private var index: Int = -1
    @IBOutlet weak var textViewConstraint: NSLayoutConstraint!
    private let defaultConstraintValue: CGFloat = 20
    
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
        textView.text = initialQuestion
    }
    
    func setupView(question: String, index: Int) {
        initialQuestion = question
        self.index = index
    }

    @IBAction func doneAction(_ sender: UIButton) {
//        if textView.text != initialQuestion {
//            QuestionsAndAnswersService.current.questions[index] = textView.text
//        }
        performSegue(withIdentifier: "unwindToGeneratedQuestions", sender: self)
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
