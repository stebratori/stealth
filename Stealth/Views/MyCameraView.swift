import UIKit
import AVFoundation

class MyCameraView: UIView {
    
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Initialize the camera view
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCaptureSession()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCaptureSession()
    }
    
    private func setupCaptureSession() {
        // Initialize capture session
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        // Get the front camera
        guard let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera available")
            return
        }
        
        do {
            // Set front camera as the input
            let input = try AVCaptureDeviceInput(device: frontCamera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }
        } catch {
            print("Error accessing the front camera: \(error)")
            return
        }
        
        // Create preview layer and add it to the view
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = self.bounds
        self.layer.addSublayer(previewLayer)
    }
    
    // Start capturing video on a background thread
    func startVideoStream() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    // Stop capturing video on a background thread
    func stopVideoStream() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.captureSession.stopRunning()
        }
    }
    
    // Handle layout changes to update the preview layer's frame
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer.frame = self.bounds
    }
}
