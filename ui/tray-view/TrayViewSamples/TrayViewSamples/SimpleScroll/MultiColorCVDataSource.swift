//
//  MultiColorCVDataSource.swift
//  TrayViewSamples
//
//  Created by Dario on 7/7/20.
//

import UIKit

final class MultiColorCVDataSource: NSObject, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MultiColorCollectionViewCell.className, for: indexPath) as? MultiColorCollectionViewCell else {
            fatalError("\(#function): could not deque cell as HomeCollectionViewCell")
        }

        // TODO: set the color
        //cell.homeItem = homeViewModel?.homeItemAt(index: indexPath.row)
        cell.colorVariant = demoColorVariant

        return cell
    }

    // MARK: - Private Section -

    private let demoColors = [
        ColorInformation(percentage: 0.6, red: 255, green: 0, blue: 0),
        ColorInformation(percentage: 0.3, red: 100, green: 255, blue: 0),
        ColorInformation(percentage: 0.1, red: 0, green: 100, blue: 255)
    ]

    private var demoColorVariant: ColorVariant {
        return ColorVariant(productID: "123", colors: demoColors)
    }
}


// MARK: - UICollectionViewDataSource
extension MultiColorCVDataSource:  UICollectionViewDelegate {
    //    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
    //        return true
    //    }


    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        print("didHighlightItemAt: \(indexPath)")
    }


    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        print("didUnhighlightItemAt: \(indexPath)")
    }


    //    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    //        true
    //    }
    //
    //
    //    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
    //        true
    //    }


    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItem: \(indexPath)")
    }


    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        print("didDeselectItem: \(indexPath)")
    }
}
