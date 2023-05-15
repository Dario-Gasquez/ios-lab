//
//  PictureCaptureViewModel.swift
//  HealthCoach
//
//  Created by Dario on 22/07/2022.
//

import CoreImage
import SwiftyBeaver
import AVFoundation
import UIKit
import SwiftUI
import Combine

class PictureCaptureViewModel: ObservableObject {
    @Published private(set) var error: CameraError?
    @Published private(set) var retrievedPicture: UIImage?
    @Published var showPhotoPicker: Bool = false
    @Published var didTakePicture = false

    private(set) var captureSession: AVCaptureSession

    init() {
        self.captureSession = cameraService.session
        setupSubscriptions()
    }

    var isCameraAuthorized: Bool {
        if let cameraError = error, cameraError.isNotAuthorized {
            return false
        } else {
            return true
        }
    }

    var shouldDisableShutterButton: Bool {
        return cameraService.isTakingPicture
    }


    func setupSubscriptions() {
        cameraService.$error
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$error)

        cameraService.$takenPicture
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$retrievedPicture)

        $retrievedPicture
            .sink { [weak self] newImage in
                self?.didTakePicture = (newImage != nil)
            }
            .store(in: &subscriptions)
    }


    func startCameraFeed() {
        cameraService.setup()
    }


    func stopCameraFeed() {
        cameraService.stopCameraFeed()
    }


    func takePicture() {
        SwiftyBeaver.info("\(type(of: self)) - \(#function) --------------------")
        cameraService.takePicture()
    }


    func didTapShowPhotoLibrary() {
        showPhotoPicker.toggle()
    }


    func photoPickerView() -> some View {
        PhotoPicker(onPhotoPicked: { results in
            PhotoPicker.convertToUIImageArray(fromResults: results) { [weak self] images, error in
                if let anError = error {
                    SwiftyBeaver.error("Error while converting picture from library: \(anError.localizedDescription)")
                    DispatchQueue.main.async {
                        self?.error = anError
                    }
                    return
                }

                guard let convertedImages = images, let firstImage = convertedImages.first else {
                    SwiftyBeaver.info("No image selected")
                    return
                }

                self?.retrievedPicture = firstImage
            }
        })
    }

    // MARK: - Private Section -
    private let cameraService = CameraService()

    private let context = CIContext()
    private var subscriptions: Set<AnyCancellable> = []
}
