//
//  PhotoPickerDelegate.swift
//  HealthCoach
//
//  Created by Dario on 02/08/2022.
//

import Foundation
import PhotosUI

class PhotoPickerDelegate: PHPickerViewControllerDelegate {
    // The coordinator needs a reference to the thing it's linked to.
    private let parent: PhotoPicker

    init(_ parent: PhotoPicker) {
        self.parent = parent
    }

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: { [weak self] in
            self?.parent.onPhotoPicked(results)
        })
    }
}
