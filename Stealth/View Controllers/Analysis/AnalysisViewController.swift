//
//  AnalysisViewController.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/18/24.
//

import UIKit

class AnalysisViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var analysisText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatePrice()
        textView.text = store.state.chatGPTState.interviewAnalysis
    }

    
    @IBAction func generateNewJD(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func restartTheInterview(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func calculatePrice() {
        let promptTokens = store.state.chatGPTState.promptTokens
        let completionTokens = store.state.chatGPTState.completionTokens
        let promptTokensPrice = Double(promptTokens) * 0.03 / 1000
        let completionTokensPrice = Double(completionTokens) * 0.06 / 1000
        let total =  completionTokensPrice + promptTokensPrice
    }
}
