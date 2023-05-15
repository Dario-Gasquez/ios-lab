//
//  CameraError.swift
//  HealthCoach
//
//  Created by Dario on 21/07/2022.
//

import Foundation

enum CameraError: Error {
    case cameraUnavailable
    case cannotAddInput
    case cannotAddOutput
    case createCaptureInput(Error)
    case deniedAuthorization
    case restrictedAuthorization
    case unknownAuthorization

    /// an error during the photo processing step
    case photoProcessingFailed(errorDescription: String)

    /// the photo capture process failed
    case captureProcessFailed(errorDescription: String)

    var isNotAuthorized: Bool {
        switch self {
        case .deniedAuthorization, .restrictedAuthorization:
            return true
        default:
            return false
        }
    }
}


extension CameraError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .cameraUnavailable:
            return "Camera not available"
        case .cannotAddInput:
            return "Unable to add camera as input"
        case .cannotAddOutput:
            return "Unable to add picture capture output"
        case .createCaptureInput(let error):
            return "Unable to create input: \(error.localizedDescription)"
        case .deniedAuthorization:
            return "Camera access not authorized"
        case .restrictedAuthorization:
            return "Camera access restricted"
        case .unknownAuthorization:
            return "Unknown authorization error"
        case .photoProcessingFailed(errorDescription: let errorDescription):
            return "Photo processing failed: \(errorDescription)"
        case .captureProcessFailed(errorDescription: let errorDescription):
            return "Photo capture failed: \(errorDescription)"
        }
    }
}
