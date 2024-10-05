//
//  InterviewQuestionTableViewCell.swift
//  Stealth
//
//  Created by Stefan Brankovic on 9/17/24.
//

import UIKit

class InterviewQuestionTableViewCell: UITableViewCell {

    @IBOutlet weak var textView: UILabel!
    
    func setupCell(text: String) {
        textView.text = text
    }
}
