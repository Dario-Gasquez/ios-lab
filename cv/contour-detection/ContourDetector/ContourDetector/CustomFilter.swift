//
//  CustomFilter.swift
//  ContourDetector
//
//  Created by Dario on 08/02/2021.
//

import CoreImage.CIFilterBuiltins

class CustomFilter: CIFilter {
    var inputImage: CIImage?

    override public var outputImage: CIImage! {
        get {
            if let inputImage = self.inputImage {
                let args = [inputImage as AnyObject]

                let callback: CIKernelROICallback = {
                (index, rect) in
                    return rect.insetBy(dx: -1, dy: -1)
                }

                return createCustomKernel().apply(extent: inputImage.extent, roiCallback: callback, arguments: args)
            } else {
                return nil
            }
        }
    }


    func createCustomKernel() -> CIKernel {
            return CIColorKernel(source:
                "kernel vec4 replaceWithBlackOrWhite(__sample s) {" +
                    "if (s.r > 0.25 && s.g > 0.25 && s.b > 0.25) {" +
                    "    return vec4(0.0,0.0,0.0,1.0);" +
                    "} else {" +
                    "    return vec4(1.0,1.0,1.0,1.0);" +
                    "}" +
                "}"
                )!

        }
}
