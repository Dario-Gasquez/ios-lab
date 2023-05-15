//
//  CameraError.swift
//  SwiftUICamera
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
}
