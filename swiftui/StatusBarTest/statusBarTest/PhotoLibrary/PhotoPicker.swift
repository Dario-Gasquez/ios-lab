//
//  PhotoPicker.swift
//  HealthCoach
//
//  Created by Dario on 02/08/2022.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: UIViewControllerRepresentable {

    let onPhotoPicked: ([PHPickerResult]) -> Void

    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Create the picker configuration using the properties passed in above.
        var configuration = PHPickerConfiguration()
        configuration.filter = .images

        // Create the view controller.
        let controller = PHPickerViewController(configuration: configuration)

        // Link it to the Coordinator created below.
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> PhotoPickerDelegate {
        return PhotoPickerDelegate(self)
    }


    static func convertToUIImageArray(fromResults results: [PHPickerResult], onComplete: @escaping ([UIImage]?, CameraError?) -> Void) {
        // Will be used to store the images that get created from results.
        var images = [UIImage]()

        let dispatchGroup = DispatchGroup()
        for result in results {
            dispatchGroup.enter()
            let itemProvider = result.itemProvider

            guard itemProvider.canLoadObject(ofClass: UIImage.self) else {
                let error = CameraError.photoProcessingFailed(errorDescription: "Image file not supported")
                onComplete(nil, error)
                return
            }

            itemProvider.loadObject(ofClass: UIImage.self) { (imageOrNil, errorOrNil) in
                if let error = errorOrNil {
                    onComplete(nil, CameraError.photoProcessingFailed(errorDescription: error.localizedDescription))
                    return
                }

                if let image = imageOrNil as? UIImage {
                    images.append(image)
                }

                dispatchGroup.leave()
            }
        }

        dispatchGroup.notify(queue: .main) {
            onComplete(images, nil)
        }
    }
}
