//
//  CameraController.swift
//  SwiftUICamera
//
//  Created by Dario on 21/07/2022.
//

import AVFoundation

class CameraController: ObservableObject {
    enum CameraState {
        case notConfigured
        case configured
        case notAuthorized
        case failed
    }

    static let shared = CameraController()

    @Published var error: CameraError?
    let session = AVCaptureSession()


    func set(delegate: AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue) {
        sessionQueue.async { self.videoOutput.setSampleBufferDelegate(delegate, queue: queue) }
    }

    // MARK: - Private Section -
    private let sessionQueue = DispatchQueue(label: "com.gs.SwiftUICamera.SessionQ")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var state = CameraState.notConfigured

    private init() {
        setup()
    }
    

    private func setup() {
        checkCameraPermissions()

        sessionQueue.async {
            self.configureCaptureSession()
            self.session.startRunning()
        }
    }


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

        defer {
            session.commitConfiguration()
        }

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            setErrorTo(.cameraUnavailable)
            state = .failed
            return
        }

        do {
            let cameraInput = try AVCaptureDeviceInput(device: camera)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                setErrorTo(.cannotAddInput)
                state = .failed
                return
            }
        } catch (let anError) {
            setErrorTo(.createCaptureInput(anError))
            state = .failed
            return
        }

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
            videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]

            let videoConnection = videoOutput.connection(with: .video)
            videoConnection?.videoOrientation = .portrait
        } else {
            setErrorTo(.cannotAddOutput)
            state = .failed
            return
        }

        state = .configured
    }
}
