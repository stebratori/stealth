//
//  AnalysisViewController.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/18/24.
//

import UIKit
import AVFoundation

class AnalysisViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var lblTotalTokensSpent: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(analysisComplete),
                                               name: Notification.Name(Constants.NotificationName.analysisDone),
                                               object: nil)
//        Task {
//            await AIKitService.shared.createAnalysis()
//        }
    }
    
    @IBAction func generateNewJD(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func restartTheInterview(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func analysisComplete() {
//        if let analysis = QuestionsAndAnswersService.current.analysis {
//            DispatchQueue.main.async {
//                self.textView.text = analysis
//                self.lblTotalTokensSpent.text = "Total tokens spent: \(AIKitService.shared.tokens) \n(Price for .gpt4 is $0.03-$0.06/1000tokens)"
//            }
//        }
    }

    private func speak(text: String, withDelay delay: Double?) {
        let synth = AVSpeechSynthesizer()
        let speakUtterance = AVSpeechUtterance(string: text)
        if let delay = delay {
            speakUtterance.preUtteranceDelay = delay
        }
        speakUtterance.volume = 1
        synth.speak(speakUtterance)
    }
}
