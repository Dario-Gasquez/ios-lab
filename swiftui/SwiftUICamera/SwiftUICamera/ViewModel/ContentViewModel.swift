//
//  ContentViewModel.swift
//  SwiftUICamera
//
//  Created by Dario on 22/07/2022.
//

import CoreImage

class ContentViewModel: ObservableObject {
    @Published var videoFrame: CGImage?
    @Published var error: Error?

    var isComicFilterEnabled = false
    var isMonoFilterEnabled = false
    var isCrystalFilterEnabled = false

    init() {
        setupSubscriptions()
    }

    func setupSubscriptions() {
        videoFrameController.$currentPixelBuffer
            .receive(on: RunLoop.main)
            .compactMap { pixelBuffer in
                guard let image = CGImage.create(from: pixelBuffer) else {
                    return nil
                }

                var ciImage = CIImage(cgImage: image)

                if self.isComicFilterEnabled {
                    ciImage = ciImage.applyingFilter("CIComicEffect")
                }
                if self.isMonoFilterEnabled {
                    ciImage = ciImage.applyingFilter("CIPhotoEffectNoir")
                }
                if self.isCrystalFilterEnabled {
                    ciImage = ciImage.applyingFilter("CICrystallize")
                }

                return self.context.createCGImage(ciImage, from: ciImage.extent)
            }
            .assign(to: &$videoFrame)

        cameraController.$error
            .receive(on: RunLoop.main)
            .map { $0 }
            .assign(to: &$error)
    }

    // MARK: - Private Section -
    private let cameraController = CameraController.shared
    private let videoFrameController = VideoFrameController.shared

    private let context = CIContext()
}
