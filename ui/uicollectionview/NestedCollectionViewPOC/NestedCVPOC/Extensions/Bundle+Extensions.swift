//
//  Bundle+Extensions.swift
//  CustomLayoutPOC
//
//  Created by Dario on 4/22/20.
//

import UIKit

/// A collection of methods for loading data from our app bundle.
extension Bundle {
    /// Decodes one object type from a JSON filename stored in our bundle.
    func decode<T: Decodable>(_ type: T.Type, from filename: String) -> T {
        guard let json = url(forResource: filename, withExtension: nil) else {
            fatalError("Failed to locate \(filename) in app bundle.")
        }

        guard let jsonData = try? Data(contentsOf: json) else {
            fatalError("Failed to load \(filename) from app bundle.")
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        guard let result = try? decoder.decode(T.self, from: jsonData) else {
            fatalError("Failed to decode \(filename) from app bundle.")
        }

        return result
    }
}
