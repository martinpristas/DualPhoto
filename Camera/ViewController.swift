//
//  ViewController.swift
//  Camera
//
//  Created by Martin Pristas on 28.2.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    private var captureSession: AVCaptureSession!
    private var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private var captureMetadataOutput : AVCapturePhotoOutput!
    
    @IBOutlet weak var takeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let captureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        
        //captureDevice?.dualCameraSwitchOverVideoZoomFactor
        
        
        let input = try? AVCaptureDeviceInput(device: captureDevice!)
        
        captureMetadataOutput = AVCapturePhotoOutput()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        captureSession.addInput(input!)
        captureSession.addOutput(captureMetadataOutput)
        
        
        //captureMetadataOutput.isHighResolutionCaptureEnabled = true
        captureMetadataOutput.isDualCameraDualPhotoDeliveryEnabled = true
        
        
        
        
        
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        videoPreviewLayer.frame = self.view.layer.bounds
        videoPreviewLayer.masksToBounds = true
//        videoPreviewLayer.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1.85))
        self.view.layer.addSublayer(videoPreviewLayer)
        captureSession.startRunning()
        
        self.view.bringSubview(toFront: takeButton)
        
        do {
            try captureDevice?.lockForConfiguration()
            let zoomFactor:CGFloat = (captureDevice?.dualCameraSwitchOverVideoZoomFactor)!
            captureDevice?.videoZoomFactor = zoomFactor
            captureDevice?.unlockForConfiguration()
        } catch {
            print(error)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takeButtonAction(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings()
        //photoSettings.isAutoStillImageStabilizationEnabled = true
        //photoSettings.isAutoDualCameraFusionEnabled = false
        //photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.isDualCameraDualPhotoDeliveryEnabled = true
        photoSettings.isCameraCalibrationDataDeliveryEnabled = true
        
        
        captureMetadataOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
}

extension ViewController : AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            print("Fail to convert image data to UIImage")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
        
    }
}


