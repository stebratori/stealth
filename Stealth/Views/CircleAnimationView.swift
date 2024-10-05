import UIKit
import AVFoundation

class CircleAnimationView: UIView {
    
    private var isAnimating = false
    private var levelTimer: Timer?
    private var audioPlayer: AVAudioPlayer?

    // Initialize the circle view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // Setup the view properties
    private func setupView() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.backgroundColor = .systemBlue
    }

    // Start the animation based on the audio file and metering data
    func startAnimating(withAudioPlayer player: AVAudioPlayer) {
        self.audioPlayer = player
        self.audioPlayer?.isMeteringEnabled = true
        
        // Start playing audio
        audioPlayer?.play()
        
        // Set up a timer to update the audio level and adjust the circle size
        levelTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(updateAudioMeter), userInfo: nil, repeats: true)
        RunLoop.main.add(levelTimer!, forMode: .common)
        print("Timer scheduled!")
        isAnimating = true
    }

    // Stop the animation and the timer
    func stopAnimating() {
        levelTimer?.invalidate() // Stop the timer
        self.layer.removeAllAnimations() // Reset the circle
        isAnimating = false
    }

    // Update the circle size based on audio meter level
    @objc private func updateAudioMeter() {
        audioPlayer?.updateMeters() // Update the audio metering data

        if let player = audioPlayer {
            let averagePower = player.averagePower(forChannel: 0) // Get the average power (volume level) of the audio
            let peakPower = player.peakPower(forChannel: 0)       // Get the peak power for sharper dynamics

            // Normalize the power levels to a 0.0 to 1.0 range
            let normalizedAverage = normalizedPowerLevel(fromDecibels: averagePower)
            let normalizedPeak = normalizedPowerLevel(fromDecibels: peakPower)
            
            // Use a combination of average and peak power to animate the circle
            let animationLevel = max(normalizedAverage, normalizedPeak)

            // Update the circle size based on the normalized level
            animateCircle(forLevel: animationLevel)
        }
    }

    // Function to animate the circle size based on audio level
    private func animateCircle(forLevel level: Float) {
        // Adjust the scaling factor for more dramatic expansion and contraction
        let scale = CGFloat(1 + (CGFloat(level) * 4.0)) // Increased scaling factor (from 1.0 to up to 5.0)
        
        UIView.animate(withDuration: 0.03, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }

    // Function to normalize the audio level from decibels to a 0.0 - 1.0 scale
    private func normalizedPowerLevel(fromDecibels decibels: Float) -> Float {
        let minDecibels: Float = -80.0 // -80 dB is considered silence
        let maxDecibels: Float = 0.0   // 0 dB is full volume

        // Guard against extreme values and normalize to 0.0 - 1.0
        if decibels < minDecibels {
            return 0.0
        } else if decibels >= maxDecibels {
            return 1.0
        } else {
            return (decibels - minDecibels) / (maxDecibels - minDecibels)
        }
    }
}
