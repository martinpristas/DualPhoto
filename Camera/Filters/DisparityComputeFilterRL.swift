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

// RIGHT to LEFT Filter
class DisparityComputeFilterRL: CIFilter {
    @objc dynamic var inputImage: CIImage?
    @objc dynamic var inputImageRight: CIImage?
    @objc dynamic var kernelSize : CGFloat = 8
    var disparityMax : CGFloat = 30
    
    
    override var attributes: [String : Any]
    {
        return [
            kCIAttributeFilterDisplayName: "Disparity Compute Filter L-to-R",
            "inputImage": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "CIImage",
                           kCIAttributeDisplayName: "Image Left",
                           kCIAttributeType: kCIAttributeTypeImage],
            "inputImageRight": [kCIAttributeIdentity: 0,
                                kCIAttributeClass: "CIImage",
                                kCIAttributeDisplayName: "Image Right",
                                kCIAttributeType: kCIAttributeTypeImage],
            
            "kernelSize": [kCIAttributeIdentity: 0,
                           kCIAttributeClass: "NSNumber",
                           kCIAttributeDefault: 4,
                           kCIAttributeDisplayName: "Kernel Size",
                           kCIAttributeMin: 1,
                           kCIAttributeSliderMin: 2,
                           kCIAttributeSliderMax: 10,
                           kCIAttributeType: kCIAttributeTypeScalar],
        ]
    }
    
    // reference image is RIGHT
    let disparityKernel : CIKernel? = {
        var kernelString =
            "kernel vec4 general(sampler leftImage, sampler rightImage, float kernelSize, float disparityMax) \n" +
                "{ \n" +
                "        float offsetAdjust = 1.0 / disparityMax; \n" +
                "        int kernelS = int(kernelSize); \n" +
                "        float prevMatch = 255.0; \n" +
                "        float bestDisparity = 0.0; \n" +
                "        vec2 d = destCoord(); \n" +
                "        float matchValue = 0.0; \n" +
                "                         \n" +
                "                         \n" +
                "        for (int disp = 0; disp <= int(disparityMax); disp++)  \n" +
                "        { \n" +
                "                 \n" +
                "                matchValue = 0.0; \n" +
                " \n" +
                "                for (int x = -kernelS/2; x <= kernelS/2; x++) \n" +
                "                { \n" +
                "                        for (int y = -kernelS/2; y <= kernelS/2; y++) \n" +
                "                        { \n" +
                "                                vec3 pixel_left = sample(leftImage, samplerTransform(leftImage, d + vec2(x + disp,y))).rgb; \n" +
                "                                vec3 pixel_right = sample(rightImage, samplerTransform(rightImage, d + vec2(x,y))).rgb; \n" +
                "                                float leftPixelGrayValue = dot(pixel_left, vec3(0.2126, 0.7152, 0.0722)); \n" +
                "                                float rightPixelGrayValue = dot(pixel_right, vec3(0.2126, 0.7152, 0.0722)); \n" +
                "                                matchValue += abs(leftPixelGrayValue - rightPixelGrayValue); \n" +
                "                        }        \n" +
                "                } \n" +
                " \n" +
                "                if (matchValue < prevMatch) \n" +
                "                { \n" +
                "                        prevMatch = matchValue; \n" +
                "                        bestDisparity = float(disp); \n" +
                "                } \n" +
                "        } \n" +
                " \n" +
                "     \n" +
                "        return vec4(bestDisparity*offsetAdjust, bestDisparity*offsetAdjust, bestDisparity*offsetAdjust, 1.0); \n" +
        "} \n"
        
        
        return CIKernel(source: kernelString)
    }()
    
    
    override var outputImage: CIImage!
    {
        guard let leftImage = inputImage, let rightImage = inputImageRight else
        {
            return nil
        }
        
        let leftExtent = leftImage.extent
        let rightExtent = rightImage.extent
        
        if leftExtent != rightExtent {
            return nil
        }
        
        return disparityKernel?.apply(extent: leftExtent, roiCallback: { (index, rect) -> CGRect in
            return rect
        }, arguments: [leftImage, rightImage, kernelSize, disparityMax])
    }
}

