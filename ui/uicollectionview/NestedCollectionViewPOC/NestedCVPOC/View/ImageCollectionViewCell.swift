//
//  ImageCollectionViewCell.swift
//  CustomLayoutPOC
//
//  Created by Dario on 4/20/20.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!

    static let reuseIdentifier = "ImageCollectionViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        print(">>> ImageCollectionViewCell: awakeFromNib <<<<<")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        label.text = nil
    }
}
