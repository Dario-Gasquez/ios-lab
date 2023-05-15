//
//  InceptionCollectionViewCell.swift
//  CustomLayoutPOC
//
//  Created by Dario on 4/21/20.
//

import UIKit


/// A collection view cell containing a collection view inside
class InceptionCollectionViewCell: UICollectionViewCell {

    static let reuseIdentfier = "InceptionCollectionViewCell"

    @IBOutlet weak var collectionView: UICollectionView!


    var section: Section? {
        didSet {
            guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout,
                let newSection = section,
                let sectionIndex = newSection.sectionIndex else { return }

            collectionView.tag = sectionIndex

            switch newSection.type {
            case .ranking:
                flowLayout.scrollDirection = .horizontal
            case .result:
                flowLayout.scrollDirection = .vertical
            }
            collectionView.reloadData()
        }
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        collectionView.register(UINib(nibName: ImageCollectionViewCell.reuseIdentifier, bundle: nil), forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)

        collectionView.delegate = self
    }

    func setDataSource(dataSource: InceptionCollectionViewDataSource) {
        collectionView.dataSource = dataSource
    }
}


extension InceptionCollectionViewCell: UICollectionViewDelegateFlowLayout {
    private enum LayoutConstants {
         static let minInteritemSpacing: CGFloat = 5.0
         static let minLineSpacing: CGFloat      = 20.0
         static let topEdgeInset: CGFloat        = 10.0
         static let bottomEdgeInset: CGFloat     = 10.0
         static let leftEdgeInset: CGFloat       = 10.0
         static let rightEdgeInset: CGFloat      = 10.0
         static let withToHeightFactor: CGFloat  = 1.5
     }


     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
             return LayoutConstants.minInteritemSpacing
     }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return LayoutConstants.minLineSpacing
    }


     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let itemWidth =  (collectionView.bounds.width / 2.0) - LayoutConstants.leftEdgeInset - (LayoutConstants.minInteritemSpacing / 2.0)
         let itemHeight = itemWidth * LayoutConstants.withToHeightFactor

        return CGSize(width: itemWidth, height: itemHeight)
     }


     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
         return UIEdgeInsets(top: LayoutConstants.topEdgeInset, left: LayoutConstants.leftEdgeInset, bottom: LayoutConstants.bottomEdgeInset, right: LayoutConstants.rightEdgeInset)
     }
}
