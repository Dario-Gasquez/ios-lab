//
//  VideoFrameController.swift
//  SwiftUICamera
//
//  Created by Dario on 22/07/2022.
//

import Foundation
import AVFoundation
import UIKit

class VideoFrameController: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    static let shared = VideoFrameController()

    @Published var currentPixelBuffer: CVPixelBuffer?

    let videoOutputQueue = DispatchQueue(label: "com.gs.SwiftUICamera.VideoOutputQ", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    override init() {
        super.init()
        CameraController.shared.set(delegate: self, queue: videoOutputQueue)
    }


    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let buffer = sampleBuffer.imageBuffer {
            DispatchQueue.main.async {
                self.currentPixelBuffer = buffer
            }
        }
    }
}
