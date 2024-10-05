//
//  GeneratedQuestionsViewController.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/17/24.
//

import UIKit

class GeneratedQuestionsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib.init(nibName: "InterviewQuestionTableViewCell", bundle: nil),
                           forCellReuseIdentifier: "InterviewQuestionTableViewCell")
        tableView.backgroundColor = .clear
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    @IBAction func startTheInterview(_ sender: UIButton) {
        performSegue(withIdentifier: "segueToInterview", sender: self)
    }
    
    @IBAction func unwindToGeneratedQuestions(segue: UIStoryboardSegue) {}
}

extension GeneratedQuestionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        130
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        QuestionsAndAnswersService.current.questions.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let editQuestionsVC = storyboard.instantiateViewController(withIdentifier: "EditQuestionViewController") as? EditQuestionViewController else { return }
        let question = QuestionsAndAnswersService.current.questions[indexPath.row]
        editQuestionsVC.setupView(question: question, index: indexPath.row)
        navigationController?.pushViewController(editQuestionsVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InterviewQuestionTableViewCell", for: indexPath) as! InterviewQuestionTableViewCell
        let question = QuestionsAndAnswersService.current.questions[indexPath.row]
        cell.setupCell(text: question)
        return cell
    }
}
