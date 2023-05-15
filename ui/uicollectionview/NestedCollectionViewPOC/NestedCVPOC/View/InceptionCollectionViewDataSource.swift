//
//  InceptionCollectionViewDataSource.swift
//  CustomLayoutPOC
//
//  Created by Dario on 4/23/20.
//

import UIKit

final class InceptionCollectionViewDataSource: NSObject, UICollectionViewDataSource {

    init(withSections sections: [Section]) {
        self.sections = sections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("--- collection view tag: \(collectionView.tag) --- section #: \(section) --- number of items: \(sections[section].items.count)")
        return sections[collectionView.tag].items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell


        let section = sections[collectionView.tag]
        let item = section.items[indexPath.row]

        if let filename = item.imageFilename {
            let image = UIImage(named: filename)
            imageCell.imageView.image = image
        }

        imageCell.label.text = item.name
        return imageCell
    }

    private let sections: [Section]
}
