//
//  MultiColorModel.swift
//  TrayViewSamples
//
//  Created by Dario on 7/7/20.
//

struct ColorVariant: Decodable, Equatable {
    let productID: String
    let colors: [ColorInformation]

    var mainColor: ColorInformation? {
        return colors.max { (first, second) -> Bool in
            first.percentage < second.percentage
        }
    }


    var normalizedColors: [ColorInformation]? {
        let maxColors = 3

        // 1. sort
        let sortedColors = colors.sorted { (first, second) -> Bool in
            first.percentage < second.percentage
        }

        // 2. take the first 3
        let upToThree = Array(sortedColors.prefix(maxColors))

        // 3. normalize
        let sum = upToThree.reduce(0.0) { $0 + $1.percentage }
        if sum <= 0 {
            return nil
        }

        let normalized = upToThree.map {
            ColorInformation(percentage: $0.percentage/sum, red: $0.red, green: $0.green, blue: $0.blue)
        }

        return normalized
    }


    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case colors
    }
}


struct ColorInformation: Decodable, Equatable {
    let percentage: Double
    let red: Int
    let green: Int
    let blue: Int
}
