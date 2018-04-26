//
//  FilteringVC.swift
//  Camera
//
//  Created by Martin Pristas on 20.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import UIKit

class FilteringVC: UIViewController {

    @IBOutlet weak var leftImageView: UIImageView!
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var disparityImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        CIFilter.registerName("DisparityComputeFilter",
                              constructor: FilterVendor(),
                              classAttributes: [kCIAttributeFilterName: "DisparityComputeFilter"])
        
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let leftImage = #imageLiteral(resourceName: "leftTsukuba")
        let rightImage = #imageLiteral(resourceName: "rightTsukuba")
        
        leftImageView.image = leftImage
        rightImageView.image = rightImage
        
        CGColorSpaceCreateDeviceRGB()
        
        
        let ciLeftImage = leftImage.ciImage
        let ciRightImage = rightImage.ciImage
        
        let outputImage = CIImage(image: leftImage)?.applyingFilter("DisparityComputeFilter", parameters: ["inputImage" : ciLeftImage, "inputImageRight" : ciRightImage, "kernelSize" : 10])
        
        disparityImageView.image = convert(cmage: outputImage!)
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
    

    

}
