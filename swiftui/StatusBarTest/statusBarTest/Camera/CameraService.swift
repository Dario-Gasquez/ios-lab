//
//  CameraService.swift
//  HealthCoach
//
//  Created by Dario on 21/07/2022.
//

import AVFoundation
import UIKit

class CameraService: ObservableObject {
    enum CameraState {
        case notConfigured
        case configured
        case notAuthorized
        case configurationFailed
    }

    @Published var error: CameraError?
    @Published var takenPicture: UIImage?
    @Published var isTakingPicture = false

    let session = AVCaptureSession()

    func setup() {
        checkCameraPermissions()

        sessionQueue.async { [weak self] in
            guard let this = self else { return }

            this.configureCaptureSession()
            if this.state == .configured {
                this.session.startRunning()
            }
        }
    }


    func stopCameraFeed() {
        sessionQueue.async {
            guard self.state == .configured else { return }

            self.session.stopRunning()
        }
    }


    func takePicture() {

         /*
          Retrieve the video preview layer's video orientation on the main queue before entering the session queue.
          */
        let videoPreviewLayerOrientation = session.connections.first?.videoOrientation

        sessionQueue.async {
            if let previewLayerOrientation = videoPreviewLayerOrientation, let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = previewLayerOrientation
            }

            let photoCaptureProcessor = PhotoCaptureProcessor()

            photoCaptureProcessor.onPhotoCaptureStarted = { [weak self] in
                DispatchQueue.main.async {
                    self?.isTakingPicture = true
                }
            }

            photoCaptureProcessor.onPhotoCaptureFinished = { [weak self] result in
                guard let this = self else { return }

                this.inProgressCaptureProcessors.remove(photoCaptureProcessor)
                DispatchQueue.main.async {
                    switch result {
                    case .failure(let cameraError):
                        self?.error = cameraError
                    case .success(let uiImage):
                        self?.takenPicture = uiImage
                    }

                    self?.isTakingPicture = false
                }
            }

            self.inProgressCaptureProcessors.insert(photoCaptureProcessor)
            let photoSettings = photoCaptureProcessor.generateSettingsForPhotoOutput(self.photoOutput, videoDeviceInput: self.videoDeviceInput)

            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }
    }


    // MARK: - Private Section -
    private let sessionQueue = DispatchQueue(label: "com.gs.HealthCoach.SessionQ")
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let photoOutput = AVCapturePhotoOutput()
    private var inProgressCaptureProcessors = Set<PhotoCaptureProcessor>()

    private var state = CameraState.notConfigured


    private func setErrorTo(_ cameraError: CameraError) {
        DispatchQueue.main.async {
            self.error = cameraError
        }
    }


    private func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            break

        case .denied:
            state = .notAuthorized
            setErrorTo(.deniedAuthorization)

        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video) { wasAuthorized in
                if !wasAuthorized {
                    self.state = .notAuthorized
                    self.setErrorTo( .deniedAuthorization)
                }
                self.sessionQueue.resume()
            }

        case .restricted:
            state = .notAuthorized
            setErrorTo(.restrictedAuthorization)

        @unknown default:
            state = .notAuthorized
            setErrorTo(.unknownAuthorization)
        }
    }


    private func configureCaptureSession() {
        guard state == .notConfigured else { return }

        session.beginConfiguration()

        session.sessionPreset = .photo

        defer {
            session.commitConfiguration()
        }

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            setErrorTo(.cameraUnavailable)
            state = .configurationFailed
            return
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
                videoDeviceInput = cameraInput
            } else {
                setErrorTo(.cannotAddInput)
                state = .configurationFailed
                return
            }
        } catch let anError {
            setErrorTo(.createCaptureInput(anError))
            state = .configurationFailed
            return
        }

        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        } else {
            setErrorTo(.cannotAddOutput)
            state = .configurationFailed
            return
        }

        state = .configured
    }
}
