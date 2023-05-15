//
//  ContentView.swift
//  ContourDetector
//
//  Created by Dario on 08/02/2021.
//

import SwiftUI
import Vision

struct ContentView: View {
    @State var contours: String = ""
    @State var configuration: String = ""
    @State var preProcessImage: UIImage?
    @State var contouredImage: UIImage?

    var body: some View {
        VStack {
            Text("\(contours)")

            Text("Config:\n\(configuration)").font(.caption)


            if let image = preProcessImage {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Image(Constants.sourceImageName).resizable().scaledToFit()
            }

            if let image = contouredImage {
                Image(uiImage: image).resizable().scaledToFit()
            }

            Button("Detect Contours", action: {
                detectVisionContours(onlyTopContours: false)
            })
        }
    }


    func detectVisionContours(onlyTopContours: Bool = false) {
        let context = CIContext()

        if let sourceImage = UIImage.init(named: Constants.sourceImageName) {
            let inputImage = CIImage(cgImage: sourceImage.cgImage!)
            let contourRequest = VNDetectContoursRequest.init()

            contourRequest.revision = VNDetectContourRequestRevision1
            contourRequest.contrastAdjustment = 1.0
            contourRequest.detectsDarkOnLight = false
            contourRequest.maximumImageDimension = 512

            self.configuration = "contrastAdj.: \(contourRequest.contrastAdjustment) | detectsDarkOnLight: \(contourRequest.detectsDarkOnLight) | maxImageDim: \(contourRequest.maximumImageDimension)"


            let filteredImage = filteredImageFrom(inputImage)

            if let cgImage = context.createCGImage(filteredImage, from: filteredImage.extent) {
                self.preProcessImage = UIImage(cgImage: cgImage)
            }


            let requestHandler = VNImageRequestHandler.init(ciImage: filteredImage, options: [:])

            try! requestHandler.perform([contourRequest])
            let contoursObservation = contourRequest.results?.first as! VNContoursObservation

            let contoursText: String
            if onlyTopContours {
                contoursText = "Top level contours: \(contoursObservation.topLevelContourCount)"
            } else {
                contoursText = "Total contours: \(contoursObservation.contourCount)"
            }
            self.contours = contoursText
            self.contouredImage = drawContours(contoursObservation: contoursObservation, sourceImage: sourceImage.cgImage!, drawOnlyTopContours: onlyTopContours)
        } else {
            self.contours = "Could not load image"
        }
    }


    func filteredImageFrom(_ sourceImage: CIImage) -> CIImage {

        let noiseReductionFilter = CIFilter.gaussianBlur()
        noiseReductionFilter.radius = 0.5
        noiseReductionFilter.inputImage = sourceImage

        // Option A: black & white
        let blackAndWhite = CustomFilter()
        blackAndWhite.inputImage = noiseReductionFilter.outputImage!
        let filteredImage = blackAndWhite.outputImage!

        // Option B: Monochrome filter
//        let monochromeFilter = CIFilter.colorControls()
//        monochromeFilter.inputImage = noiseReductionFilter.outputImage!
//        monochromeFilter.contrast = 20.0
//        monochromeFilter.brightness = 4
//        monochromeFilter.saturation = 50
//        let filteredImage = monochromeFilter.outputImage!

        return filteredImage
    }


    func drawContours(contoursObservation: VNContoursObservation, sourceImage: CGImage, drawOnlyTopContours: Bool = false) -> UIImage {
        let size = CGSize(width: sourceImage.width, height: sourceImage.height)

        let renderer = UIGraphicsImageRenderer(size: size)
        let renderedImage = renderer.image { (context) in
            let renderingContext = context.cgContext

            let flipVertical = CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: size.height)
            renderingContext.concatenate(flipVertical)

            renderingContext.draw(sourceImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

            renderingContext.scaleBy(x: size.width, y: size.height)
            renderingContext.setLineWidth(10.0 / CGFloat(size.width))
            let greenUIColor = UIColor.green
            renderingContext.setStrokeColor(greenUIColor.cgColor)
            if drawOnlyTopContours {
                // Option A: Render only the top level contours (those not enclosed inside other contours)
                contoursObservation.topLevelContours.forEach { (contour) in
                    renderingContext.addPath(contour.normalizedPath)
                }
            } else {
                // Option B: render all the contours
                renderingContext.addPath(contoursObservation.normalizedPath)
            }


            renderingContext.strokePath()
        }

        return renderedImage
    }


    // MARK: - Private Section -
    private enum Constants {
        static let sourceImageName = "tenis"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
