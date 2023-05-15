//
//  MultiColorRoundView.swift
//  TrayViewSamples
//
//  Created by Dario on 7/7/20.
//

import UIKit

class MultiColorRoundView: UIView {

    var colorVariant: ColorVariant?

    override init(frame: CGRect) {
        super.init(frame: frame)
        print("--- initFrame -----")
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("--- initCoder -----")
        setupUI()
    }


    override func layoutSubviews() {
        super.layoutSubviews()
        print("--- layoutSubviews -----")
        updateCornerRadius()
    }


    override func draw(_ rect: CGRect) {
        super.draw(rect)
        print("--- draw rect -----")
        print("rect: \(rect)")
        guard let variant = colorVariant else {
            assertionFailure("set the colorVariant in order to get a fully functional MultiColorRoundView")
            return
        }

        guard let colors = variant.normalizedColors else {
            return
        }

        var yPosition: CGFloat = 0.0
        for color in colors {
            let proportionalHeight = rect.size.height * CGFloat(color.percentage)
            let uiColor = UIColor(fromIntRed: color.red, green: color.green, blue: color.blue)
            let rectToFill = CGRect(x: 0, y: yPosition, width: rect.size.width, height: proportionalHeight)
            uiColor.setFill()

            UIRectFill(rectToFill)
            yPosition += proportionalHeight
        }
    }


    private enum Constants {
        static let defaulBackgroundColor = UIColor.lightGray
        static let defaultBorderColor = UIColor.darkGray
        static let borderWidth: CGFloat = 2.0
        static let rotationAngle: CGFloat = 135.0
    }

    /// Configures the cell's border and rotation
    ///
    /// - Important: in order to get a round cell, height and width must be the same.
    private func setupUI() {
        print("--- setupUI -----")
        backgroundColor = Constants.defaulBackgroundColor
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = Constants.defaultBorderColor.cgColor
        layer.transform = CATransform3DMakeRotation(Constants.rotationAngle / 180.0 * .pi, 0.0, 0.0, 1.0)
    }


    /// Updates the layer's radius.
    /// Execute this method when the bounds might change to mantain the round border
    private func updateCornerRadius() {
        print("--- updateCornerRadius -----")
        layer.cornerRadius = bounds.width * 0.5
    }
}
