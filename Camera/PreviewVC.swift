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
            
            let outputImage = ciLeftImage.applyingFilter("DisparityComputeFilter", parameters: ["inputImage" : ciLeftImage, "inputImageRight" : ciRightImage, "kernelSize" : 10])
            
            disparityMapImageView.image = convert(cmage: outputImage)
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
