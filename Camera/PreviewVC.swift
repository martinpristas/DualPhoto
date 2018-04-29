//
//  PreviewVC.swift
//  Camera
//
//  Created by Martin Pristas on 25.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import UIKit

class PreviewVC: UIViewController {

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var disparityMapImageView: UIImageView!
    @IBOutlet weak var trueDisparityImageView: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        leftImageView.image = nil
        rightImageView.image = nil
        disparityMapImageView.image = nil
        trueDisparityImageView.image = nil
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if leftImageView != nil && rightImageView != nil {
            let ciLeftImage = leftImageView.image!.ciImage
            let ciRightImage = rightImageView.image!.ciImage
            
            let image = CIImage(image:#imageLiteral(resourceName: "trueTsukuba"))
            
            let outputImageLR = image!.applyingFilter("DisparityComputeFilterLR", parameters: ["inputImage" : ciLeftImage, "inputImageRight" : ciRightImage, "kernelSize" : 10])
            
            let outputImageRL = image!.applyingFilter("DisparityComputeFilterRL", parameters: ["inputImage" : ciLeftImage, "inputImageRight" : ciRightImage, "kernelSize" : 10])
            
            let outputOcclusion = image!.applyingFilter("OcclusionFilter", parameters: ["inputImage" : outputImageLR, "leftDisparity" : outputImageLR, "rightDisparity" : outputImageRL])
            
            let medianImage = image!.applyingFilter("CIMedianFilter", parameters: ["inputImage" : outputImageLR])
            
            disparityMapImageView.image = convert(cmage: outputImageLR)
            trueDisparityImageView.image  = convert(cmage: medianImage)
        }
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func closeButtonAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
