//
//  ASLViewController.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 25/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

// Standard
import UIKit
import AVKit
import CoreMedia
import Foundation

// ML
import CoreML
import Vision

public class ASLViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // CoreML Model
    let model = try? VNCoreMLModel(for: Gesture().model)
    var old_char = ""
    let detectionThreshold: Float = 0.9
    var predictEnabled = false
    var showAllPrediction = false
    
    override public func loadView() {
        view = ASLView(frame: .init(x: 0, y: 0, width: 700, height: 900))
    }
    
    public var aslView: ASLView {
        return view as! ASLView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        aslView.clearButton.addTarget(self, action: #selector(ClearButton), for: .touchUpInside)
        aslView.predictButton.addTarget(self, action: #selector(PredictButton), for: .touchUpInside)
        aslView.showAllButton.addTarget(self, action: #selector(ShowAllButton), for: .touchUpInside)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        configureCamera()
    }
    
    // Camera
    public func configureCamera() {
        
        //Start capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.startRunning()
        
        // Add input for capture
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(captureInput)
        
        // Add preview layer to our view to display the open camera screen
        let previewL = AVCaptureVideoPreviewLayer(session: captureSession)
        aslView.previewView.sizeThatFits(previewL.preferredFrameSize())
        aslView.previewView.layer.addSublayer(previewL)
        previewL.videoGravity = .resizeAspectFill
        previewL.frame = aslView.previewView.bounds
        
        // Flip Because of Landscape
        // Assume landscape right for now
        // Lightning port is on your right when facing the ipad!
        let plConnection = previewL.connection
        plConnection?.videoOrientation = .landscapeRight
        // previewLayer.frame = rawCameraFrame
        
        // Add output of capture
        /* Here we set the sample buffer delegate to our viewcontroller whose callback
         will be on a queue named - videoQueue */
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = .landscapeRight
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        
        // CoreML
        let request = VNCoreMLRequest(model: model!){ (fineshedReq, err) in
            guard let results = fineshedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                if firstObservation.confidence > 0.5 {
                    
                    //For secondary vocalization
                    self.old_char = ""
                    self.aslView.previewView.layer.borderColor = UIColor(hex: 0x585563)!.cgColor
                    if self.showAllPrediction {
                        self.updateLabels(alphabet: firstObservation.identifier, accuracy: firstObservation.confidence)
                    }
                }
                
                if self.old_char != String(firstObservation.identifier) && firstObservation.confidence > self.detectionThreshold {
                    
                    self.aslView.previewView.layer.borderColor = UIColor(hex: 0x92DCE5)!.cgColor
                    self.updateLabels(alphabet: firstObservation.identifier, accuracy: firstObservation.confidence)
                    self.old_char = String(firstObservation.identifier)
                    
                    if !self.showAllPrediction {
                        self.predictEnabled = false
                    }
                }
            }
        }
        request.imageCropAndScaleOption = .centerCrop
        
        if predictEnabled {
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
        }
    }
    
}

// MARK: - Actions
private extension ASLViewController {
    
    @objc func ClearButton() {
        aslView.resultLabel.text = ""
        aslView.accuracyLabel.text = ""
        
        UIView.animate(withDuration: 0.25) {
            self.aslView.layoutIfNeeded()
            self.aslView.showAllButton.alpha = 0
        }
        
        showAllPrediction = false
    }
    
    @objc func PredictButton() {
        
        // Animation for Loading??/
        predictEnabled = true
        
        UIView.animate(withDuration: 0.25) {
            self.aslView.layoutIfNeeded()
            self.aslView.showAllButton.alpha = 1
        }
    }
    
    @objc func ShowAllButton() {
        predictEnabled = true
        showAllPrediction.toggle()
        if showAllPrediction == false {
            ClearButton()
        }
    }
    
}

// MARK: - Helpers
private extension ASLViewController {
    
    func updateLabels(alphabet: String, accuracy: Float) {
        aslView.resultLabel.text = "Prediction: \(alphabet)"
        aslView.accuracyLabel.text = "Accuracy: \(accuracy)"
        
        if accuracy > detectionThreshold {
            aslView.resultLabel.textColor = UIColor(hex: 0x92DCE5)!
            aslView.accuracyLabel.text = aslView.accuracyLabel.text! + "😎"
        } else {
            aslView.resultLabel.textColor = .white
            aslView.accuracyLabel.text = aslView.accuracyLabel.text! + "😬"
        }
    }
    
}
