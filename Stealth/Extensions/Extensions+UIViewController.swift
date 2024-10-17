//
//  Extensions+UIViewController.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 10/16/24.
//

import UIKit

extension UIViewController {
    private struct PopupConstants {
        static var view: UIView?
    }
    
    func showPopup(title: String, message: String) {
        DispatchQueue.main.async {
             // Calculate the size of the popup
             let popupWidth: CGFloat = self.view.frame.width - 100
             let popupHeight: CGFloat = 380 // New height

             // Create the popup view
             let popupView = UIView(frame: CGRect(x: (self.view.frame.width - popupWidth) / 2, y: (self.view.frame.height - popupHeight) / 2, width: popupWidth, height: popupHeight))
             popupView.backgroundColor = UIColor(red: 44/255, green: 44/255, blue: 46/255, alpha: 1) // Dark gray
             popupView.layer.cornerRadius = 16
             popupView.layer.shadowColor = UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 0.4).cgColor // Subtle dark gray shadow
             popupView.layer.shadowOpacity = 1
             popupView.layer.shadowOffset = CGSize(width: 0, height: 20)
             popupView.layer.shadowRadius = 30 // Larger blur radius for softer shadow

             // Optionally add a faint white glow behind the popup
             let glowLayer = CALayer()
             glowLayer.frame = popupView.bounds
             glowLayer.shadowColor = UIColor.white.withAlphaComponent(0.1).cgColor // Faint white glow
             glowLayer.shadowRadius = 30 // Large radius for smooth glow
             glowLayer.shadowOpacity = 1
             glowLayer.cornerRadius = popupView.layer.cornerRadius
             glowLayer.shadowOffset = .zero
             
             // Add the glow behind the popup view
             popupView.layer.insertSublayer(glowLayer, at: 0)

             // Create and configure the title label
             let titleLabel = UILabel(frame: CGRect(x: 16, y: 16, width: popupWidth - 32, height: 24))
             titleLabel.text = title
             titleLabel.textColor = .lightGray // Light gray text
             titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
             titleLabel.textAlignment = .center
             popupView.addSubview(titleLabel)

             // Create the scrollable textView
             let textView = UITextView(frame: CGRect(x: 16, y: titleLabel.frame.maxY + 8, width: popupWidth - 32, height: 150))
             textView.text = message
             textView.font = UIFont.systemFont(ofSize: 16)
             textView.textColor = .lightGray // Light gray text for dark mode
             textView.backgroundColor = .clear
             textView.isEditable = false
             textView.isScrollEnabled = true
             popupView.addSubview(textView)

             // Create the 'Copy Error Log' button
             let copyButton = UIButton(type: .system)
             copyButton.frame = CGRect(x: 16, y: textView.frame.maxY + 8, width: popupWidth - 32, height: 40)
             copyButton.setTitle("Copy Error Log", for: .normal)
             copyButton.backgroundColor = UIColor.systemBlue
             copyButton.setTitleColor(.white, for: .normal)
             copyButton.layer.cornerRadius = 8
             copyButton.addTarget(self, action: #selector(self.copyErrorLogTapped), for: .touchUpInside)
             popupView.addSubview(copyButton)

             // Create the 'Close' button
             let closeButton = UIButton(type: .system)
             closeButton.frame = CGRect(x: 16, y: copyButton.frame.maxY + 16, width: popupWidth - 32, height: 40)
             closeButton.setTitle("Close", for: .normal)
             closeButton.backgroundColor = UIColor.systemRed
             closeButton.setTitleColor(.white, for: .normal)
             closeButton.layer.cornerRadius = 8
             closeButton.addTarget(self, action: #selector(self.closePopupTapped), for: .touchUpInside)
             popupView.addSubview(closeButton)

             // Add additional space at the bottom of the popup
             popupView.frame.size.height = closeButton.frame.maxY + 20 // 40px extra space below the close button
            
            PopupConstants.view = popupView
            
            self.view.addSubview(popupView)
            // Animate popup appearance
            popupView.alpha = 0
            UIView.animate(withDuration: 0.3) {
                popupView.alpha = 1
            }
         }
     }
    
    // Method to copy the error log
    @objc 
    private func copyErrorLogTapped() {
        // Create error log String
        var errorLogString: String = ""
        for errorMessage in logger.log {
            errorLogString += "\(errorMessage)\n"
        }
        UIPasteboard.general.string = errorLogString
    }
    
    // Method to close the popup
    @objc 
    private func closePopupTapped() {
        if let popupView = PopupConstants.view {
            UIView.animate(withDuration: 0.3, animations: {
                popupView.alpha = 0
            }) { _ in
                popupView.removeFromSuperview()
            }
        }
    }

    // Method to show the loader
    func showLoader(withText text: String) {
        // Create a semi-transparent overlay
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        // Create and configure the activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = CGPoint(x: overlay.center.x, y: overlay.center.y - 30) // Adjust position above label
        activityIndicator.startAnimating()
        
        // Create and configure the label
        let label = UILabel()
        label.text = text
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        
        // Set the label's frame below the activity indicator
        label.frame = CGRect(x: 20, y: activityIndicator.frame.maxY + 20, width: overlay.frame.width - 40, height: 50)
        
        // Add the activity indicator and label to the overlay
        overlay.addSubview(activityIndicator)
        overlay.addSubview(label)
        
        // Store the loader overlay view to remove it later
        PopupConstants.view = overlay
        
        // Add the overlay to the view
        DispatchQueue.main.async {
            self.view.addSubview(overlay)
        }
    }
    
    // Method to hide the loader
    func hidePopup() {
        DispatchQueue.main.async {
            PopupConstants.view?.removeFromSuperview()
            PopupConstants.view = nil
        }
    }
}
