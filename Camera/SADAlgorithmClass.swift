//
//  SADAlgorithmClass.swift
//  Camera
//
//  Created by Martin Pristas on 8.4.18.
//  Copyright © 2018 Martin Pristas. All rights reserved.
//

import Foundation
import UIKit

class DisparitiesAlgorithm {
    
    struct PixelData {
        var a: UInt8 = 255
        var r: UInt8 = 0
        var g: UInt8 = 0
        var b: UInt8 = 0
    }
    
    static let matchAreaWidth = 8
    static let matchAreaHeight = 8
    static let maxDisparityPixels = 40
    
    final class func computeDisparity_SAD( left : UIImage, right : UIImage) -> UIImage? {
        
        let rgba_Left = RGBAImage(image: left)
        let rgba_Right = RGBAImage(image: right)
        
        let leftMonochrome = gray(rgba_Left!)
        let rightMonochrome = gray(rgba_Right!)
        
        let kernelWidth = self.matchAreaWidth / 2
        let kernelHeight = self.matchAreaHeight / 2
        
        let width = Int(left.size.width)
        let height = Int(right.size.height)
        
        let offsetAdjust = 255 / maxDisparityPixels  // this is used to map depth map output to 0-255 range
        
        let disparityMap = RGBAImage(width: width, height: height)
        
        
        for y in 0..<height {
            for x in 0..<width {
                
           
                var prevMatch = Int.max
                var bestDisparity = 0
             
                
                
                for disp in 1...maxDisparityPixels {
                    if let value = computeAreaMatch(width: width, height: height, left: leftMonochrome, right: rightMonochrome, xPoint: x, yPoint: y, disp: disp, kernelWidth: kernelWidth, kernelHeight: kernelHeight) {
                        if value < prevMatch {
                            prevMatch = value
                            bestDisparity = disp
                        }
                    }
                }
                
                let adjusted = bestDisparity * offsetAdjust
                var pixel = Pixel(value: 0x000000)
                pixel.Af = 1
                pixel.R = UInt8(adjusted)
                pixel.G = UInt8(adjusted)
                pixel.B = UInt8(adjusted)
                let index = y * width + x
                disparityMap.pixels[index] = pixel
                
                print("Disparity value in x - \(x) | y - \(y) | value - \(bestDisparity * offsetAdjust)")
                
            
            
                
                //let pixelValue = UInt8.init(bestDisparity)
                //disparityMap[x*y + x] = PixelData.init(a: 255, r: UInt8(bestDisparity * offsetAdjust), g: UInt8(bestDisparity * offsetAdjust), b: UInt8(bestDisparity * offsetAdjust))
                
                
            }
        }
        
        
        
        
        return disparityMap.toUIImage()
    }
    
    class func computeAreaMatch(width: Int, height: Int, left : RGBAImage, right: RGBAImage, xPoint : Int, yPoint: Int, disp : Int, kernelWidth : Int, kernelHeight : Int) -> Int? {
        
        let x_from = xPoint - kernelWidth < 0 ? 0 : xPoint - kernelWidth
        let x_to = xPoint + kernelWidth > width ? width : xPoint + kernelWidth
        let y_from = yPoint - kernelHeight < 0 ? 0 : yPoint - kernelHeight
        let y_to = yPoint + kernelHeight > height ? height : yPoint + kernelHeight
        
        
        var matchValue : Int = 0
        
        
        for x in x_from..<x_to {
            
            let right_x = x - disp
            
            if right_x < 0 || right_x >= width {
                return nil
            }
            
            
            for y in y_from..<y_to {
               
                if let leftPixel = left.pixel(x: x, y), let rightPixel = right.pixel(x: right_x, y) {
                    let diff = Int(leftPixel.R) - Int(rightPixel.R)
                    matchValue += diff * diff
                }
            }
        }
        
        
        return matchValue
    }
    
    
    class func pixelValues(fromCGImage imageRef: CGImage?) -> [Int]?
    {
        var width = 0
        var height = 0
        var pixelValues: [Int] = [Int]()//(repeating: 0, count: imageRef!.width * imageRef!.height)
        
        if let imageRef = imageRef {
            width = imageRef.width
            height = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            let totalBytes = height * bytesPerRow
            let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
            
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            var intensities = [UInt8](repeating: 0, count: totalBytes)
            
            let contextRef = CGContext(data: &intensities, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
            contextRef?.draw(imageRef, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(width), height: CGFloat(height)))
            
            //pixelValues = intensities
            
            for x in 0..<height {
                for y in 0..<width {
                    let byteIndex = (bytesPerRow * x) + y * 4
                    
                    let red   = CGFloat(intensities[byteIndex]    ) / 255.0
                    let green = CGFloat(intensities[byteIndex + 1]) / 255.0
                    let blue  = CGFloat(intensities[byteIndex + 2]) / 255.0
                    let alpha = CGFloat(intensities[byteIndex + 3]) / 255.0
                    
                    let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                    var gray : CGFloat = 0.0
                    color.getWhite(&gray, alpha: nil)
                    pixelValues.append(Int(gray*255))
                }
            }
        }
        
        return pixelValues
    }
    
    class func imageFromBitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        
        /*
        let rect = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContext(rect.size)
        
        for y in 0..<height {
            for x in 0..<width {
                UIColor.init(white: CGFloat(pixels[x * y + x].b/255), alpha: 1).set()
                UIRectFill(CGRect(x: x, y: y, width: 1, height: 1))
            }
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
        */
        
        assert(width > 0)
        
        assert(height > 0)
        
        let pixelDataSize = MemoryLayout<PixelData>.size
        assert(pixelDataSize == 4)
        
        assert(pixels.count == Int(width * height))
        
        let data: Data = pixels.withUnsafeBufferPointer {
            return Data(buffer: $0)
        }
        
        let cfdata = NSData(data: data) as CFData
        let provider: CGDataProvider! = CGDataProvider(data: cfdata)
        if provider == nil {
            print("CGDataProvider is not supposed to be nil")
            return nil
        }
        let cgimage: CGImage! = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * pixelDataSize,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue),
            provider: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        if cgimage == nil {
            print("CGImage is not supposed to be nil")
            return nil
        }
        return UIImage(cgImage: cgimage)
 
    }
    
    private class func gray(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            let result = (pixel.Rf + pixel.Gf + pixel.Bf) / 3.0
            pixel.Rf = result
            pixel.Gf = result
            pixel.Bf = result
            return pixel
        }
        return outImage
    }
}
