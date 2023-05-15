//
//  RoundButton.swift
//  TrayViewSamples
//
//  Created by Dario on 6/24/20.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCorners()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCorners()
    }

    override func prepareForInterfaceBuilder() {
        configureCorners()
    }



    // MARK: - Private Section -
    
    /// Sets the `cornerRadious` so that the button is round.
    ///
    /// - Important: in order to get a circle button, height and width must be the same.
    private func configureCorners() {
        layer.masksToBounds = true
        layer.cornerRadius = frame.width * 0.5
    }
}
