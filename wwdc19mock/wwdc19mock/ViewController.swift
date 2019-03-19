//
//  ViewController.swift
//  wwdc19mock
//
//  Created by Dalton Prescott Ng on 19/3/19.
//  Copyright © 2019 Dalton Prescott Ng. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        configureCamera()
    }
    
    func configureCamera() {
        
        //Start capture session
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        captureSession.startRunning()
        
        // Add input for capture
//        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let captureDevice = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: .video, position: .front) else {
            return
        }
        guard let captureInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(captureInput)
        
        // Add preview layer to our view to display the open camera screen
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        // Add output of capture
        /* Here we set the sample buffer delegate to our viewcontroller whose callback
         will be on a queue named - videoQueue */
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
}
