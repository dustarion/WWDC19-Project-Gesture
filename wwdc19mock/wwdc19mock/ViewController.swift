//
//  ViewController.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 19/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

// Standard
import UIKit
import AVKit
import CoreMedia
import Foundation
//import CoreImage

// ML
import CoreML
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var previewLayer: UIView!
    var predictionLabel: UILabel!
    
    var alphabetTimer = Timer()
    
    // CoreML Model
    let model = try? VNCoreMLModel(for: Gesture().model)
    var old_char = ""
    
    var loadAlphabet = ""
    var messageView: UIView!
    var messageLabel: UILabel!
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black
        
        // Preview Layer
        previewLayer = UIView()
        view.addSubview(previewLayer)
        
        // Prediction Layer
        predictionLabel = UILabel()
        view.addSubview(predictionLabel)
        
        // Message View
        messageView = UIView()
        view.addSubview(messageView)
        
        messageLabel = UILabel()
        view.addSubview(messageLabel)
        
        predictionLabel.translatesAutoresizingMaskIntoConstraints = false
        previewLayer.translatesAutoresizingMaskIntoConstraints = false
        messageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            
            // Preview Layer Anchors
            previewLayer.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            previewLayer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            previewLayer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
            previewLayer.widthAnchor.constraint(equalTo: previewLayer.heightAnchor, multiplier: 1.0),//.333333
            
            // Prediction Label
            predictionLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            predictionLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            predictionLabel.heightAnchor.constraint(equalToConstant: 100),
            predictionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            predictionLabel.topAnchor.constraint(equalToSystemSpacingBelow: previewLayer.bottomAnchor, multiplier: 1),
            
            // Message Layer Anchors
            //messageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            messageView.topAnchor.constraint(equalTo: predictionLabel.bottomAnchor,constant: 20),
            messageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            messageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            messageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            
            // Message Label
            messageLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            messageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messageLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30),
            messageLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30),
            
            ])
        
        self.view = view
    }
    
    override func viewDidLoad() {
        previewLayer.backgroundColor = .darkGray
        previewLayer.layer.cornerRadius = 20
        previewLayer.layer.borderColor = UIColor.yellow.cgColor
        previewLayer.layer.borderWidth = 2.0
        previewLayer.layer.masksToBounds = true

        predictionLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        predictionLabel.textColor = .yellow
        predictionLabel.textAlignment = .center
        predictionLabel.text = "Predicting..."
        predictionLabel.backgroundColor = .clear
        predictionLabel.numberOfLines = 0
        
        messageLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        messageLabel.textColor = .white
        messageLabel.textAlignment = .center
        messageLabel.text = "test"
        messageLabel.backgroundColor = .clear
        
        alphabetTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.capturingLetter), userInfo: nil, repeats: true)
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
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
        previewLayer.sizeThatFits(previewL.preferredFrameSize())
        previewLayer.layer.addSublayer(previewL)
        previewL.videoGravity = .resizeAspectFill
        previewL.frame = previewLayer.bounds
        
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
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    func buffer(from image: UIImage) -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(image.size.width), Int(image.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: image.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    var previousAlphabet = ""
    var message = ""
    var isAnimatingLetter = false
    
    @objc func capturingLetter() {
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
    }
    
}


//func CustomButton() -> UIButton {
//    let button = UIButton(frame: CGRect(x: width / 4, y: height / 1.5, width: width / 4, height: 48))
//    button.backgroundColor = UIColor(red:0.07, green:0.10, blue:0.16, alpha:1.0)
//    button.setTitle(buttonText(Position.left), for: .normal)
//    button.layer.cornerRadius = 10
//    button.layer.shadowColor = UIColor.gray.cgColor
//    button.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
//    button.layer.shadowOpacity = 0.5
//
//    return button
//}
