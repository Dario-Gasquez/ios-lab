//
//  CameraOverlayView.swift
//  CameraOverlay
//
//  Created by Dario on 19/03/2021.
//

import UIKit

class CameraOverlayView: UIView {

    var cancelAction: ( () -> Void )?
    var takePictureAction: ( () -> Void )?
    var showLibraryAction: ( () -> Void )?

    // MARK: - Private Section -
    
    @IBAction func didTapShowLibrary(_ sender: UIButton) {
        showLibraryAction?()
    }

    @IBAction func didTapTakePicture(_ sender: UIButton) {
        takePictureAction?()
    }


    @IBAction func didTapCancel(_ sender: UIButton) {
        cancelAction?()
    }
}
