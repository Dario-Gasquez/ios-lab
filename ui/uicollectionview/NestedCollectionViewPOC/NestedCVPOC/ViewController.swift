//
//  ViewController.swift
//  CustomLayoutPOC
//
//  Created by Dario on 4/20/20.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let inceptionCellNib = UINib(nibName: InceptionCollectionViewCell.reuseIdentfier, bundle: nil)
        collectionView.register(inceptionCellNib, forCellWithReuseIdentifier: InceptionCollectionViewCell.reuseIdentfier)
        let imageCellNib = UINib(nibName: ImageCollectionViewCell.reuseIdentifier, bundle: nil)
        collectionView.register(imageCellNib, forCellWithReuseIdentifier: ImageCollectionViewCell.reuseIdentifier)
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    @IBOutlet private weak var collectionView: UICollectionView!

    private let sections = StubSectionsManager.generateSections()
    private lazy var inceptionDataSource = {
        return InceptionCollectionViewDataSource(withSections: sections)
    }()
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section].type {
        case .ranking:
            return 1
        case .result:
            return sections[section].items.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = sections[indexPath.section]
        switch section.type {
        case .ranking:
            let inceptionCell = collectionView.dequeueReusableCell(withReuseIdentifier: InceptionCollectionViewCell.reuseIdentfier, for: indexPath) as! InceptionCollectionViewCell
            inceptionCell.section = section
            inceptionCell.setDataSource(dataSource: inceptionDataSource)
            return inceptionCell
        case .result:
            let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
            let item = section.items[indexPath.row]

            if let filename = item.imageFilename {
                let image = UIImage(named: filename)
                imageCell.imageView.image = image
            }

            imageCell.label.text = item.name
            return imageCell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeaderView", for: indexPath) as! SectionHeaderView
        headerView.sectionTitle.text = sections[indexPath.section].title
        return headerView
    }
}


extension ViewController: UICollectionViewDelegateFlowLayout {
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
        switch sections[section].type {
        case .ranking:
            return 0
        case .result:
            return LayoutConstants.minInteritemSpacing
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        switch sections[section].type {
        case .ranking:
            return 0
        case .result:
            return LayoutConstants.minLineSpacing
        }
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemWidth =  (view.bounds.width / 2.0) - LayoutConstants.leftEdgeInset - (LayoutConstants.minInteritemSpacing / 2.0)
        let itemHeight = itemWidth * LayoutConstants.withToHeightFactor
        let cellWidth: CGFloat

        switch sections[indexPath.section].type {
        case .ranking:
            cellWidth = view.bounds.width
        case .result:
            cellWidth = itemWidth
        }
        return CGSize(width: cellWidth, height: itemHeight)
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: LayoutConstants.topEdgeInset, left: LayoutConstants.leftEdgeInset, bottom: LayoutConstants.bottomEdgeInset, right: LayoutConstants.rightEdgeInset)
    }
}
