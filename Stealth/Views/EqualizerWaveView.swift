import UIKit

class EqualizerWaveView: UIView {

    private var waveLayer: CAShapeLayer!
    private var animationTimer: Timer?
    private var phase: CGFloat = 0  // Controls the wave movement over time

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupWaveLayer()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupWaveLayer()
    }

    private func setupWaveLayer() {
        waveLayer = CAShapeLayer()
        waveLayer.strokeColor = UIColor.blue.cgColor
        waveLayer.fillColor = UIColor.clear.cgColor
        waveLayer.lineWidth = 3.0
        waveLayer.lineCap = .round
        self.layer.addSublayer(waveLayer)
    }

    func startAnimating() {
        // Start the animation with a Timer
        DispatchQueue.main.async { [weak self] in
            self?.animationTimer = Timer.scheduledTimer(timeInterval: 0.05, target: self!, selector: #selector(self?.calculateAndAnimateWave), userInfo: nil, repeats: true)
        }
    }

    func stopAnimating() {
        // Stop the animation and invalidate the timer
        DispatchQueue.main.async { [weak self] in
            self?.animationTimer?.invalidate()
            self?.animationTimer = nil
        }
    }

    @objc private func calculateAndAnimateWave() {
        // Access bounds and UI-related properties on the main thread
        let width = self.bounds.width
        let midY = self.bounds.midY
        
        // Offload the wave calculation to a background thread
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            let path = UIBezierPath()
            let amplitude: CGFloat = 20  // Maximum height of the wave
            let frequency: CGFloat = 0.03 // Controls the wave frequency
            let phaseShift: CGFloat = 0.15 // Speed of wave movement
            
            // Perform the wave calculation
            path.move(to: CGPoint(x: 0, y: midY))
            
            for x in stride(from: 0, to: width, by: 1) {
                let scaling = -pow(1 / midY * (x - width / 2), 2) + 1  // Gradually scale down wave toward edges
                let y = scaling * amplitude * sin(x * frequency + self.phase) + midY
                path.addLine(to: CGPoint(x: x, y: y))
            }
            
            self.phase += phaseShift  // Update phase to create the moving effect
            
            // Back on the main thread, update the waveLayer path
            DispatchQueue.main.async {
                self.waveLayer.path = path.cgPath
            }
        }
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        waveLayer.frame = self.bounds
    }
}
