//
//  FilterVendor.swift
//  Camera
//
//  Created by Martin Pristas on 20.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import Foundation
import CoreImage

class FilterVendor: NSObject, CIFilterConstructor
{
    func filter(withName name: String) -> CIFilter? {
        switch name
        {
        case "DisparityComputeFilter":
            return DisparityComputeFilter()
        default:
            return nil
        }
    }
}
