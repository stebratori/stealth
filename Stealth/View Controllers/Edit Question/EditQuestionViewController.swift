//
//  EditQuestionViewController.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/17/24.
//

import UIKit

class EditQuestionViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    private var initialQuestion: String = ""
    private var index: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
}
