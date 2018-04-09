//
//  UIImageExtension.swift
//  Camera
//
//  Created by Martin Pristas on 8.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var noir: UIImage {
        let context = CIContext(options: nil)
        let currentFilter = CIFilter(name: "CIPhotoEffectNoir")!
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        let output = currentFilter.outputImage!
        let cgImage = context.createCGImage(output, from: output.extent)!
        let processedImage = UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        
        return processedImage
    }
}
