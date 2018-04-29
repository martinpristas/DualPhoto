//
//  OcclusionFilter.swift
//  Camera
//
//  Created by Martin Pristas on 27.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import UIKit

//
//  DisparityComputeFilterRL.swift
//  Camera
//
//  Created by Martin Pristas on 27.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import UIKit

import UIKit
import CoreImage


class OcclusionFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var leftDisparity: CIImage?
    @objc dynamic var rightDisparity: CIImage?
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Occlusion Filter",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "NULLLLL",
                           kCIAttributeType: kCIAttributeTypeImage],
            "leftDisparity": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Disparity Left",
                           kCIAttributeType: kCIAttributeTypeImage],
            "rightDisparity": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "CIImage",
                                kCIAttributeDisplayName: "Disparity Right",
                                kCIAttributeType: kCIAttributeTypeImage]
        ]
    }
    
    // reference image is RIGHT
    let occlusionKernel : CIKernel? = {
        var kernelString =
        "kernel vec4 coreImageKernel(sampler leftDisparity, sampler rightDisparity, float width) \n" +
        "{ \n" +
        "    int w = int(width); \n" +
        "    float leftD = sample(leftDisparity, samplerTransform(leftDisparity, destCoord())).r; \n" +
        "    int lD = int(leftD * 30.0); // 22.5 \n" +
        "    float rightD = sample(rightDisparity, samplerTransform(rightDisparity, destCoord() + vec2(lD, 0))).r; \n" +
        "    int rD = int(rightD * 30.0); // 22.5 \n" +
        "     \n" +
        "    if (int(destCoord().x) - lD < 0 || int(destCoord().x) + lD > w || abs(float(lD) - float(rD)) > 5.0) { \n" +
        "        return vec4(0, 1.0, 1.0, 1.0); \n" +
        "    } \n" +
        "     \n" +
        "    return sample(leftDisparity, samplerCoord(leftDisparity)).rgba; \n" +
        "} \n"
        
        
        return CIKernel(source: kernelString)
    }()
    
    
    override var outputImage: CIImage!
    {
        guard let lD = leftDisparity, let rD = rightDisparity else
        {
            return nil
        }
        
        let leftExtent = lD.extent
        let rightExtent = rD.extent
        
        if leftExtent != rightExtent {
            return nil
        }
        
        return occlusionKernel?.apply(extent: leftExtent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, arguments: [lD, rD, leftExtent.width])
    }
}


