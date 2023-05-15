//
//  PhotoCaptureProcessor.swift
//  ShoePalace
//
//  Created by Dario on 26/03/2021.
//

import UIKit
import AVFoundation
import SwiftyBeaver


class PhotoCaptureProcessor: NSObject {

    var onPhotoCaptureStarted: (() -> Void)?
    var onPhotoCaptureFinished: ((_ result: Result<UIImage, CameraError>) -> Void)?

    func generateSettingsForPhotoOutput(_ photoOutput: AVCapturePhotoOutput, videoDeviceInput: AVCaptureDeviceInput) -> AVCapturePhotoSettings {
        let photoSettings = AVCapturePhotoSettings()

        // enable auto-flash if available
        if videoDeviceInput.device.isFlashAvailable {
            photoSettings.flashMode = .auto
        }

        return photoSettings
    }

    // MARK: - Private Section -
    private var capturedImage: UIImage?
}



// MARK: - AVCapturePhotoCaptureDelegate
extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        onPhotoCaptureStarted?()
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")

        if let processingError = error {
            onPhotoCaptureFinished?(.failure(CameraError.captureProcessFailed(errorDescription: processingError.localizedDescription)))
            return
        }

        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            assertionFailure("Unable to generate a UIImage from the captured picture")
            return
        }

        capturedImage = uiImage
    }


    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) ------")

        if let processingError = error {
            onPhotoCaptureFinished?(.failure(CameraError.captureProcessFailed(errorDescription: processingError.localizedDescription)))
            return
        }

        guard let image = capturedImage else {
            onPhotoCaptureFinished?(.failure(CameraError.captureProcessFailed(errorDescription: "Unable to obtain a valid image")))
            return
        }

        onPhotoCaptureFinished?(.success(image))
    }
}
