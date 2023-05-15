//
//  UIView+Extensions.swift
//  TrayViewSamples
//
//  Created by Dario on 6/23/20.
//

import UIKit

extension UIView {
    /// When using StoryBoards make sure to set the reusable identifier to the name of the class.
    static var className: String {
        return String(describing: self)
    }
}
