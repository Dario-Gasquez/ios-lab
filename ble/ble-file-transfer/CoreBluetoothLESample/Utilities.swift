//
//  Utilities.swift
//  CoreBluetoothLESample
//
//  Created by Dario on 18/06/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import Foundation
import os

class Utilities {
    static func dataFromAudioFile(filename: String, fileExtension: String) -> Data? {
        guard let filePath = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            return nil
        }

        let fileData: Data
        do {
            fileData = try Data(contentsOf: filePath)
        } catch {
            os_log("error when trying to read audio file: %@", error.localizedDescription)
            return nil
        }

        return fileData
    }
}
