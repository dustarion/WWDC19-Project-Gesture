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
//import CoreImage

// ML
import CoreML
import Vision

// Prediction Labels for Sign Language
enum HandSign: String {
    case A = "A"
    case B = "B"
    case C = "C"
    case D = "D"
    case E = "E"
    case F = "F"
    case G = "G"
    case H = "H"
    case I = "I"
    case J = "J"
    case k = "K"
    case L = "L"
    case M = "M"
    case N = "N"
    case O = "O"
    case P = "P"
    case Q = "Q"
    case R = "R"
    case S = "S"
    case T = "T"
    case U = "U"
    case V = "V"
    case W = "W"
    case X = "X"
    case Y = "Y"
    case Z = "Z"
    case nothing = "Empty"
}

// Filters
let CMYKHalftone = "CMYK Halftone"
let CMYKHalftoneFilter = CIFilter(name: "CICMYKHalftone", parameters: ["inputWidth" : 20, "inputSharpness": 1])

let ComicEffect = "Comic Effect"
let ComicEffectFilter = CIFilter(name: "CIComicEffect")

let Crystallize = "Crystallize"
let CrystallizeFilter = CIFilter(name: "CICrystallize", parameters: ["inputRadius" : 30])

let Edges = "Edges"
//let EdgesEffectFilter = CIFilter(name: "CIEdges", parameters: ["inputIntensity" : 5])

let HexagonalPixellate = "Hex Pixellate"
let HexagonalPixellateFilter = CIFilter(name: "CIHexagonalPixellate", parameters: ["inputScale" : 10])

let Invert = "Invert"
let InvertFilter = CIFilter(name: "CIColorInvert")

let Pointillize = "Pointillize"
let PointillizeFilter = CIFilter(name: "CIPointillize", parameters: ["inputRadius" : 30])

let LineOverlay = "Line Overlay"
let LineOverlayFilter = CIFilter(name: "CILineOverlay")

let Posterize = "Posterize"
let PosterizeFilter = CIFilter(name: "CIColorPosterize", parameters: ["inputLevels" : 5])

let HistogramFilter = CIFilter(name: "CIHistogramDisplayFilter")

//let HistogramFiler = CIFilter(name: "CIHistogramDisplayFilter", keysAndValues: kCIInputImageKey, inputImage(), "inputHeight", NSNumber(value: 100.0), "inputHighLimit", NSNumber(value: 1.0), "inputLowLimit", NSNumber(value: 0.0), nil)


class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    // CoreML Model
    let model = try? VNCoreMLModel(for: Gesture().model)
    var old_char = ""
    
    var rawCameraFrame = CGRect()
    var processedCameraFrame = CGRect()
    var processedCameraView = UIImageView()
    
    var MLCameraFrame = CGRect()
    var MLCameraView = UIImageView()
    
    var PredictionLabelFrame = CGRect()
    var PredictionLabel = UITextView()
    
    var MLCropFrame = CGRect()
    var MLCropView = UIImageView()
    
    var BackgroundImage : CIImage?
    var CurrentProcessedImage : CIImage?
    
    // Others?
    
    @IBOutlet weak var BottomToolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Frames!
        setupCameraFrame()
        setupProcessedCameraImageView()
        setupMLCameraImageView()
        setupPredictionLabel()
        //setupBoundingCaptureRect()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        configureCamera()
        view.bringSubviewToFront(BottomToolBar)
    }
    
    func setupCameraFrame() {
        // Assuming Landscape!
        let width : CGFloat = self.view.frame.width / 2
        let height = self.view.frame.height / 2
        rawCameraFrame = CGRect(x: 0, y: 0, width: width, height: height)
    }
    
    func setupProcessedCameraImageView() {
        // Assuming Landscape
        let width : CGFloat = self.view.frame.width / 2
        let height = self.view.frame.height / 2
        processedCameraFrame = CGRect(x: width, y: 0, width: width, height: height)
        
        // Setup Imageview
        processedCameraView.frame = processedCameraFrame
        processedCameraView.backgroundColor = .green
        processedCameraView.contentMode = .scaleAspectFit
        view.addSubview(processedCameraView)
    }
    
    func setupMLCameraImageView() {
        // Assuming Landscape
        let width : CGFloat = self.view.frame.width / 2
        let height = self.view.frame.height / 2
        MLCameraFrame = CGRect(x: width, y: height, width: width, height: height)
        
        // Setup Imageview
        MLCameraView.frame = MLCameraFrame
        MLCameraView.backgroundColor = .blue
        MLCameraView.contentMode = .scaleAspectFit
        view.addSubview(MLCameraView)
    }
    
    
    
    
    
    
    
    
    
    
    func setupPredictionLabel() {
        // Assuming Landscape
        let width : CGFloat = (self.view.frame.width / 2) - 40
        let height = (self.view.frame.height / 2) - 40
        PredictionLabelFrame = CGRect(x: 20, y: height+60, width: width, height: height)
        
        // Setup Label
        PredictionLabel.frame = PredictionLabelFrame
        PredictionLabel.textColor = .white
        PredictionLabel.backgroundColor = .black
        PredictionLabel.text = "Loading..."
        view.addSubview(PredictionLabel)
    }
    
//    func setupBoundingCaptureRect() {
//        let width = self.view.frame.width / 2
//        let height = self.view.frame.height / 2
//
//        MLCropFrame = CGRect(x: width, y: height, width: width, height: height)
//        MLCropView.frame = MLCropFrame
//        MLCropView.backgroundColor = .blue
//        MLCameraView.addSubview(MLCropView)
//    }
    
    
    
    
    @IBAction func SetBG(_ sender: Any) {
        BackgroundImage = CurrentProcessedImage
        
        // Asynchronously
        DispatchQueue.main.async {
            self.MLCameraView.image = self.processedCameraView.image
        }
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
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = rawCameraFrame
        
        // Flip Because of Landscape
        // Assume landscape left for now
        // Lightning port is on your left when facing the ipad !
        let plConnection = previewLayer.connection
        plConnection?.videoOrientation = .landscapeLeft
        // previewLayer.frame = rawCameraFrame
        
        // Add output of capture
        /* Here we set the sample buffer delegate to our viewcontroller whose callback
         will be on a queue named - videoQueue */
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        
    }
    
    
    
    func differenceOf(_ topRef: CGImage, with bottomRef: CGImage) -> CIImage? {
        
        // Dimensions
        let bottomFrame = CGRect(x: 0, y: 0, width: bottomRef.width, height: bottomRef.height)
        let topFrame = CGRect(x: 0, y: 0, width: topRef.width, height: topRef.height)
        let renderFrame: CGRect = bottomFrame.union(topFrame).integral
        
        // Create context
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue).rawValue
        
        guard let context = CGContext(data: nil, width: Int(renderFrame.size.width), height: Int(renderFrame.size.height), bitsPerComponent: 8, bytesPerRow: Int(renderFrame.size.width * 4), space: colorSpace, bitmapInfo: bitmapInfo)
            else { return nil }
        
        // Draw images
        context.setBlendMode(CGBlendMode.normal)
        context.draw(bottomRef, in: bottomFrame.offsetBy(dx: -renderFrame.origin.x, dy: -renderFrame.origin.y))
        context.setBlendMode(CGBlendMode.difference)
        context.draw(topRef, in: topFrame.offsetBy(dx: -renderFrame.origin.x, dy: -renderFrame.origin.y))
        context.setBlendMode(CGBlendMode.colorBurn)
        context.draw(topRef, in: topFrame.offsetBy(dx: -renderFrame.origin.x, dy: -renderFrame.origin.y))
        
        // Create image from context
        guard let imageRef = context.makeImage() else { return nil }
        
        let image = convertCGImageToCIImage(inputImage: imageRef)
        return image
    }
    
    

    
    func apply(_ filter: CIFilter?, for image: CIImage) -> CIImage {
        guard let filter = filter else { return image }
        filter.setValue(image, forKey: kCIInputImageKey)
        guard let filteredImage = filter.value(forKey: kCIOutputImageKey) else { return image }
        return filteredImage as! CIImage
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
        let context = CIContext(options: nil)
        return context.createCGImage(inputImage, from: inputImage.extent)
    }
    
    func convertCGImageToCIImage(inputImage: CGImage) -> CIImage! {
        var ciImage = CIImage(cgImage: inputImage)
        return ciImage
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        // Filter Version
        let filter = CIFilter(name: "CIEdges", parameters: ["inputIntensity" : 10])
        
        connection.videoOrientation = .landscapeLeft

        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        var cameraImage = CIImage(cvPixelBuffer: pixelBuffer)
        CurrentProcessedImage = cameraImage
        cameraImage = apply(filter, for: cameraImage)
        
        var filteredImage = UIImage(ciImage: cameraImage)
        
        if BackgroundImage != nil {
            
            let Background = BackgroundImage!//apply(filter, for: BackgroundImage!)//self.BackgroundImage!//
            //difference(leftImage: self.BackgroundImage!, rightImage: filteredImage
            
            guard let image1 = convertCIImageToCGImage(inputImage: cameraImage) else { return }
            guard let image2 = convertCIImageToCGImage(inputImage: Background) else { return }
            
            let newImage = differenceOf(image1, with: image2)
            //newImage = apply(filter, for: newImage!)
            
            DispatchQueue.main.async {
                self.MLCameraView.image = UIImage(ciImage: newImage!)
            }
        }
        
        
        
        
        //cameraImage = apply(filter, for: cameraImage)
        
        //filter!.setValue(cameraImage, forKey: kCIInputImageKey)
        
        //var filteredPreImage = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        //var filteredImage = UIImage(ciImage: filter!.value(forKey: kCIOutputImageKey) as! CIImage)
        
        // Asynchronously
        DispatchQueue.main.async {
            self.processedCameraView.image = filteredImage
        }
        
        // CoreML
        let request = VNCoreMLRequest(model: model!){ (fineshedReq, err) in
        guard let results = fineshedReq.results as? [VNClassificationObservation] else {return}
        guard let firstObservation = results.first else {return}
            
        print(firstObservation.identifier, firstObservation.confidence)
        DispatchQueue.main.async {
                if firstObservation.confidence < 0.5{
                    
                    //For secondary vocalization
                    self.old_char = ""
                    self.PredictionLabel.text = String(firstObservation.identifier) + "\nConfidence: " + String(firstObservation.confidence)
                    self.PredictionLabel.textColor = .white
                    
                } else if self.old_char != String(firstObservation.identifier) && firstObservation.confidence > 0.8{
                    
                    self.PredictionLabel.text =  String(firstObservation.identifier) + "\nConfidence: " + String(firstObservation.confidence)
                    self.PredictionLabel.textColor = .green
                    self.old_char = String(firstObservation.identifier)
                    
                }
            }
            
        }
        
        request.imageCropAndScaleOption = .centerCrop
        
        //guard let buffer =  buffer(from: filteredImage) else { return }
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
    
    
}
