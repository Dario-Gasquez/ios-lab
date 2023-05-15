//
//  MultiColorCollectionViewCell.swift
//  TrayViewSamples
//
//  Created by Dario on 7/7/20.
//

import UIKit

class MultiColorCollectionViewCell: UICollectionViewCell {

    var colorVariant: ColorVariant? {
        didSet {
            multiColorView?.colorVariant = colorVariant
        }
    }


    // MARK: - Private Section -

    @IBOutlet private var multiColorView: MultiColorRoundView!

}
