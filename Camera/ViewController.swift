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
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var closeButton: UIButton!
    
    var disparityImageLeft : UIImage?
    var disparityImageRight : UIImage?
    
    @IBOutlet weak var takeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        CIFilter.registerName("DisparityComputeFilter",
                              constructor: FilterVendor(),
                              classAttributes: [kCIAttributeFilterName: "DisparityComputeFilter"])
        
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
        //videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        videoPreviewLayer.frame = cameraView.layer.bounds
        videoPreviewLayer.masksToBounds = true
//        videoPreviewLayer.setAffineTransform(CGAffineTransform(scaleX: 1, y: 1.85))
        cameraView.layer.addSublayer(videoPreviewLayer)
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
        
        guard
            let conn = self.videoPreviewLayer?.connection,
            conn.isVideoOrientationSupported
            else { return }
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait: conn.videoOrientation = .portrait
        case .landscapeRight: conn.videoOrientation = .landscapeLeft
        case .landscapeLeft: conn.videoOrientation = .landscapeRight
        case .portraitUpsideDown: conn.videoOrientation = .portraitUpsideDown
        case .faceUp: conn.videoOrientation = .landscapeRight
        default: conn.videoOrientation = .portrait
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator)
    {
        super.viewWillTransition(to: size, with: coordinator)
        guard
            let conn = self.videoPreviewLayer?.connection,
            conn.isVideoOrientationSupported
            else { return }
        let deviceOrientation = UIDevice.current.orientation
        switch deviceOrientation {
        case .portrait: conn.videoOrientation = .portrait
        case .landscapeRight: conn.videoOrientation = .landscapeLeft
        case .landscapeLeft: conn.videoOrientation = .landscapeRight
        case .portraitUpsideDown: conn.videoOrientation = .portraitUpsideDown
        default: conn.videoOrientation = .portrait
        }
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
    
    @IBAction func dismissButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension ViewController : AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation(), let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            
            print("Fail to convert image data to UIImage")
            return
        }
        
        if let exif = photo.metadata["{Exif}"] as? [String:Any],
            let exifAux = exif["{ExifAux}"] as? [String : Any],
            let regions = exifAux["Regions"] as? [String:Any],
            let imageHeight = regions["HeightAppliedTo"] as? Int,
            let imageWidth = regions["WidthAppliedTo"] as? Int,
            let regionList = regions["RegionList"] as? [[String:Any]],
            let width = regionList[0]["Width"] as? Double,
            let height = regionList[0]["Height"] as? Double,
            let regionListType = regionList[0]["Type"] as? String,
            regionListType == "CleanAperture",
            let xPoint = regionList[0]["X"] as? Double,
            let yPoint = regionList[0]["Y"] as? Double {
            
            let computedWidth = Double(imageWidth) * width
            let computedHeight = Double(imageHeight) * height
            let computedXPoint = Double(imageWidth) * xPoint
            let computedYPoint = Double(imageHeight) * yPoint
            
            if let cgPhotoCropped = capturedImage.cgImage?.cropping(to: CGRect.init(x: computedXPoint - computedWidth/2, y: computedYPoint - computedHeight / 2, width: computedWidth, height: computedHeight)) {
                
                let photoCropped = UIImage(cgImage: cgPhotoCropped)
                
                
                UIGraphicsBeginImageContextWithOptions(CGSize(width: imageWidth, height: imageHeight), false, capturedImage.scale)
                photoCropped.draw(in: CGRect(x: 0, y: 0, width: CGFloat(imageWidth), height: CGFloat(imageHeight)))
                if let photoResized = UIGraphicsGetImageFromCurrentImageContext() {
                    let fixedImage = UIImage.init(cgImage: photoResized.cgImage!, scale: photoResized.scale, orientation: .up)
                    disparityImageLeft = UIImage.init(cgImage: fixedImage.cgImage!.resize(scale: 1/9), scale: 1, orientation: fixedImage.imageOrientation)
                    
                    UIImageWriteToSavedPhotosAlbum(fixedImage, nil, nil, nil)
                    
                }
                UIGraphicsEndImageContext()
                
                
            }
            
            
            
            
        } else {
            let fixedImage = UIImage.init(cgImage: capturedImage.cgImage!, scale: capturedImage.scale, orientation: .up)
            disparityImageRight = UIImage.init(cgImage: fixedImage.cgImage!.resize(scale: 1/9), scale: 1, orientation: fixedImage.imageOrientation)
            UIImageWriteToSavedPhotosAlbum(fixedImage, nil, nil, nil)
        }
        
        
        if let left = disparityImageLeft, let right = disparityImageRight {
            disparityImageLeft = nil
            disparityImageRight = nil
            
            
            let nextVC = storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
            nextVC.loadView()
            nextVC.leftImageView.image = left
            nextVC.rightImageView.image = right
            nextVC.trueDisparityImageView.image = nil
            present(nextVC, animated: true, completion: nil)
            
            //let outputImage = CIImage(image: left)?.applyingFilter("DisparityComputeFilter", parameters: ["inputImage" : left.ciImage, "inputImageRight" : right.ciImage])
            /*
             
            if let out = outputImage {
                //UIImageWriteToSavedPhotosAlbum(convert(cmage: out), nil, nil, nil)
                let nextVC = storyboard?.instantiateViewController(withIdentifier: "DisparityViewerVC") as! DisparityViewerVC
                nextVC.loadView()
                nextVC.disparityImageView.image = convert(cmage: out)
                present(nextVC, animated: true, completion: nil)
                
                
            }
 */
            //disparityImageView.image = convert(cmage: outputImage!)
            
            //if let image = DisparitiesAlgorithm.computeDisparity_SAD(left: left, right: right) {
            //    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            //}
        }
        
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(inputImage.size.width / viewWidth,
                                 inputImage.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to:cropZone)
            else {
                return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
    
    
}


extension CGImage {
    func resize(scale:CGFloat)-> CGImage {
        
        let image = UIImage(cgImage: self)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: image.size.width*scale, height: image.size.height*scale)))
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        imageView.image = image
        UIGraphicsBeginImageContext(imageView.bounds.size)
        imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!.cgImage!
    }
}
