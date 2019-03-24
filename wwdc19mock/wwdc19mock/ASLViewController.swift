//
//  ASLViewController.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 25/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

import UIKit
import AVKit
import CoreMedia

public class ASLViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
//    private var latestResult: MNISTOutput?
    
    override public func loadView() {
        view = ASLView(frame: .init(x: 0, y: 0, width: 700, height: 900))
    }
    
    public var aslView: ASLView {
        return view as! ASLView
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        aslView.clearButton.addTarget(self, action: #selector(didTapClearButton), for: .touchUpInside)
        aslView.predictButton.addTarget(self, action: #selector(didTapPredictButton), for: .touchUpInside)
        aslView.showAllButton.addTarget(self, action: #selector(didTapShowAllButton), for: .touchUpInside)
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        configureCamera()
    }
    
    // Camera
    func configureCamera() {
        
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
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        connection.videoOrientation = .landscapeRight
        
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        //        let cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
        //        let finalImage = UIImage(ciImage: cameraImage)
        //
        //        // Asynchronously
        //        DispatchQueue.main.async {
        //            self.previewLayer.image = finalImage
        //        }
        
        
        // CoreML
        /*
        let request = VNCoreMLRequest(model: model!){ (fineshedReq, err) in
            guard let results = fineshedReq.results as? [VNClassificationObservation] else {return}
            guard let firstObservation = results.first else {return}
            //print(firstObservation.identifier, firstObservation.confidence)
            DispatchQueue.main.async {
                if firstObservation.confidence < 0.5{
                    
                    //For secondary vocalization
                    self.old_char = ""
                    //self.predictionLabel.text = String(firstObservation.identifier) + "\nConfidence: " + String(firstObservation.confidence)
                    self.predictionLabel.text = String(firstObservation.identifier) + "\n😬"
                    self.predictionLabel.textColor = .yellow
                    self.previewLayer.layer.borderColor = UIColor.yellow.cgColor
                } else if self.old_char != String(firstObservation.identifier) && firstObservation.confidence > 0.85{
                    //self.predictionLabel.text =  String(firstObservation.identifier) + "\nConfidence: " + String(firstObservation.confidence)
                    self.loadAlphabet = String(firstObservation.identifier)
                    self.predictionLabel.text = String(firstObservation.identifier) + "\n😎"
                    self.predictionLabel.textColor = .green
                    self.previewLayer.layer.borderColor = UIColor.green.cgColor
                    self.old_char = String(firstObservation.identifier)
                }
            }
        }
        request.imageCropAndScaleOption = .centerCrop
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])*/
    }
    
    var previousAlphabet = ""
    var message = ""
    var isAnimatingLetter = false
    
/*@objc func capturingLetter() {
        if loadAlphabet == "" || loadAlphabet == "Nothing" {
            if isAnimatingLetter {
                print("--Canceled---")
                isAnimatingLetter = false
            }
            return
        }
        
        if loadAlphabet == previousAlphabet {
            print(loadAlphabet+"!")
            isAnimatingLetter = false
            previousAlphabet = ""
            message += loadAlphabet
        } else {
            previousAlphabet = loadAlphabet
            print(previousAlphabet+"...")
            isAnimatingLetter = true
        }
        //print("Message:" + message)
    }*/
    
    
    
}

// MARK: - Actions
private extension ASLViewController {
    
    @objc func didTapClearButton() {
//        aslView.previewView.image = nil
        aslView.resultLabel.text = ""
        aslView.accuracyLabel.text = ""
//        aslView.placeholderView.setHidden(false)
        
        UIView.animate(withDuration: 0.25) {
            self.aslView.layoutIfNeeded()
            self.aslView.showAllButton.alpha = 0
        }
    }
    
    @objc func didTapPredictButton() {
        let size = CGSize(width: 28, height: 28)
        //let image = aslView.previewView.resize(to: size)
        //guard let buffer = image?.resize(to: size)?.pixelBuffer() else { return }
        //guard let result = try? MNIST().prediction(image: buffer) else { return }
        //latestResult = result
        
        //let digit = result.classLabel
        //let accuracy = result.output[digit]
        let alphabet = "A"
        let accuracy = 0.953333
        
        updateLabels(alphabet: alphabet, accuracy: accuracy)
    }
    
    @objc func didTapShowAllButton() {
        //guard let result = latestResult else { return }
        
        var message = ""
        
//        for item in present.sortedResult {
//            message += "\(item.key): \(item.value.rounded(toPlaces: 5))\n"
//        }
        
        let alert = UIAlertController(title: "All Probabilities", message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
        alert.addAction(dismissAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - Helpers
private extension ASLViewController {
    
    func updateLabels(alphabet: String, accuracy: Double?) {
        aslView.resultLabel.text = "Prediction: \(alphabet)"
        
        if let anAccuracy = accuracy {
            aslView.accuracyLabel.text = "Accuracy: \(anAccuracy)"
        }
        
        UIView.animate(withDuration: 0.25) {
            self.aslView.layoutIfNeeded()
            self.aslView.showAllButton.alpha = 1
        }
    }
    
}
