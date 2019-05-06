//
//  ObjectRecoginitionViewController.swift
//  BlindSight
//
//  Created by Siddharth on 04/05/19.
//  Copyright © 2019 Siddharth. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision
import FirebaseFirestore
import Firebase

class ObjectRecoginitionViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
        var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var previewView: PreviewView!
    @IBAction func callAssistance(_ sender: Any) {
        //segue to the one which is needed
    }
    
    // Session - Initialization
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private let sessionQueue = DispatchQueue(label: "Camera Session Queue", attributes: [], target: nil)
    private var permissionGranted = false
    
    // ML - Initialization
    var model: VNCoreMLModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set some features for PreviewView
        self.previewView.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewView.session = session
        
        // Check for permissions
        self.checkPermission()
        
        // Configure Session in session queue
        self.sessionQueue.async { [unowned self] in
            self.configureSession()
        }
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipeup))
        swipeUp.direction = .up
        self.view.addGestureRecognizer(swipeUp)
        
        // Load MLModel
        self.loadModel()
        
//        playAudio()
    }
    
    func playAudio() {
        if let fileURL = Bundle.main.path(forResource: "2", ofType: "mp3") {
            print("Continue processing")
        } else {
            print("Error: No file with specified name exists")
        }
        do {
            if let fileURL = Bundle.main.path(forResource: "2", ofType: "mp3") {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileURL))
            } else {
                print("No file with specified name exists")
            }
        } catch let error {
            print("Can't play the audio file failed with an error \(error.localizedDescription)")
        }
        audioPlayer?.play()
        audioPlayer?.numberOfLoops = 0
    }
    
    @IBAction func needAssistanceButton(_ sender: Any) {
        self.performSegue(withIdentifier: "needSegue", sender: self)
        
        let db = Firestore.firestore()

        let groupRef = db.collection("blindUsers").document(UserDefaults.standard.string(forKey: "blindUID")!)
        groupRef.getDocument { (document, error) in
            if let document = document, document.exists {
                db.collection("blindUsers").document(UserDefaults.standard.value(forKey: "blindUID")! as! String).updateData(["needsHelp":true])
            } else {
                print("error")
            }
        }
    
    }
    
    // Check for camera permissions
    private func checkPermission() {
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            self.permissionGranted = true
        case .notDetermined:
            self.requestPermission()
        default:
            self.permissionGranted = false
        }
    }
    
    // Request permission if not given
    private func requestPermission() {
        sessionQueue.suspend()
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { [unowned self] granted in
            self.permissionGranted = granted
            self.sessionQueue.resume()
        }
    }
    
    // Configure session properties
    private func configureSession() {
        guard permissionGranted else { return }
        
        self.session.beginConfiguration()
        self.session.sessionPreset = .hd1280x720
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else { return }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard self.session.canAddInput(captureDeviceInput) else { return }
        self.session.addInput(captureDeviceInput)
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
        videoOutput.alwaysDiscardsLateVideoFrames = true
        guard self.session.canAddOutput(videoOutput) else { return }
        self.session.addOutput(videoOutput)
        
        self.session.commitConfiguration()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
    }
    
    private func loadModel() {
        model = try? VNCoreMLModel(for: Inceptionv3().model)
    }
    
    // Start session
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sessionQueue.async {
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
        }
    }
    
    // Stop session
    override func viewWillDisappear(_ animated: Bool) {
        self.sessionQueue.async { [unowned self] in
            if self.permissionGranted {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
            }
        }
        super.viewWillDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Do per-image-frame executions here!!!
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // TODO: Do ML Here
            guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let request = VNCoreMLRequest(model: self.model!) {
                (finishedReq, err) in
                guard let results = finishedReq.results as? [VNClassificationObservation] else { return }
                guard let firstObservation = results.first else { return }
                
                DispatchQueue.main.async {
                    let objectRecognised = firstObservation.identifier
                    let with = " with "
                    let probability = NSString(format: "%.2f", firstObservation.confidence) as String
                    let finalString = objectRecognised + with + probability
                    let utterance = AVSpeechUtterance(string: finalString)
                    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
                    let synthesizer = AVSpeechSynthesizer()
                    synthesizer.speak(utterance)
                }
            }
            try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
    
    @objc func swipeup() {
        self.performSegue(withIdentifier: "needSegue", sender: self)
    }
    
}
