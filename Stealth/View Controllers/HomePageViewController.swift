//
//  HomePageViewController.swift
//  StealthAI
//
//  Created by Stefan Brankovic on 9/30/24.
//

import UIKit
import AVFoundation
import ReSwift

class HomePageViewController: UIViewController {
    var audioPlayer: AVAudioPlayer?
    var circleAnimationView: CircleAnimationView!
    var cameraView: MyCameraView!
    var equalizerWaveView: EqualizerWaveView?
    
    lazy var audioDataSubscriber = AnonymousStoreSubscriber<ChatGPTState> { [weak self] chatGPTState in
        // Handle state change for audioData
        self?.handleNewAudioData(chatGPTState.audioData)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize the circle animation view and add it to the view hierarchy
        
        configureAudioSession()
        subscribeToStore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        createUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cameraView.startVideoStream()
        //ChatGptAPI.sendMessageAndPlayVoice("Can you please welcome the user to the Stealth mobile application. Ask them if you can help them to generate the Job Description for the role they have in their company.")
    }
    
    // Stop the video stream when the view disappears
     override func viewWillDisappear(_ animated: Bool) {
         super.viewWillDisappear(animated)
         cameraView.stopVideoStream()
         store.unsubscribe(audioDataSubscriber)
     }
    
    private func showCircleAnimation(inside view: UIView) {
        let circleView = CircleAnimationView(frame: CGRect(x: view.frame.width / 2 - 100 / 2,
                                                           y: view.frame.height / 2 - 100 / 2,
                                                           width: 100,
                                                           height: 100))
        //circleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circleView)
        
        // Set constraints for circle animation view
        NSLayoutConstraint.activate([
            circleView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            circleView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            circleView.topAnchor.constraint(equalTo: view.topAnchor),
            circleView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        circleAnimationView = circleView
    }
    
    private func showCameraView(inside view: UIView) {
        // Initialize and add MyCameraView to the bottomView
        cameraView = MyCameraView(frame: view.bounds)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        // Set constraints for MyCameraView
        NSLayoutConstraint.activate([
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func playAudioData(audioData: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: audioData)
            audioPlayer?.prepareToPlay()

            audioPlayer?.delegate = self
        }
        catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }

    // Stop the circle animation when audio finishes
    func stopCircleAnimation() {
        circleAnimationView.stopAnimating()
    }
    
    private func addEqualizerWaveView(to topView: UIView) {
            let equalizerWaveView = EqualizerWaveView(frame: topView.bounds)
            equalizerWaveView.translatesAutoresizingMaskIntoConstraints = false
            topView.addSubview(equalizerWaveView)

            // Set constraints for equalizer wave view
            NSLayoutConstraint.activate([
                equalizerWaveView.leadingAnchor.constraint(equalTo: topView.leadingAnchor),
                equalizerWaveView.trailingAnchor.constraint(equalTo: topView.trailingAnchor),
                equalizerWaveView.topAnchor.constraint(equalTo: topView.topAnchor),
                equalizerWaveView.bottomAnchor.constraint(equalTo: topView.bottomAnchor)
            ])
        self.equalizerWaveView = equalizerWaveView
        }

    func createUI() {
        let topView = UIView()
        let bottomView = UIView()
        let stackView = UIStackView(arrangedSubviews: [topView, bottomView])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add the stack view to the main view
        self.view.addSubview(stackView)
        
        // Set the constraints for the stack view
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: self.view.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        view.layoutIfNeeded()
        
        addEqualizerWaveView(to: topView)
        showCameraView(inside: bottomView)
    }
}

// Delegate method to stop the animation when the audio finishes
extension HomePageViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        equalizerWaveView!.stopAnimating()
    }
    
    
}

extension HomePageViewController {
    func subscribeToStore() {
        // Subscribe to only audioData changes
        store.subscribe(audioDataSubscriber) { subscription in
            subscription
                .select { $0.chatGPTState }                 // Select ChatGPTState
                .only { $0.audioData != $1.audioData }      // Only notify if audioData changes
        }
    }
    
    // This method will be called when audioData changes
    func handleNewAudioData(_ audioData: Data) {
        print("Audio data changed: \(audioData)")
        playAudioData(audioData: audioData)
        equalizerWaveView?.startAnimating()
    }
}

// Helper function to configure the audio session
func configureAudioSession() {
    do {
        try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try AVAudioSession.sharedInstance().setActive(true)
    } catch {
        print("Failed to configure and activate audio session: \(error.localizedDescription)")
    }
}
