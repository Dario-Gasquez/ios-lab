/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that implements both `UICollectionViewDataSource` and `UICollectionViewDataSourcePrefetching`.
*/

import UIKit

/// - Tag: CustomDataSource
class CustomDataSource: NSObject, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    // MARK: Properties
    
    struct Model {
        var identifier = UUID()
        
        // Add additional properties for your own model here.
    }

    /// Example data identifiers.
    private let models = (1...1000).map { _ in
        return Model()
    }

    /// An `AsyncFetcher` that is used to asynchronously fetch `DisplayData` objects.
    private let asyncFetcher = AsyncFetcher()

    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }

    /// - Tag: CellForItemAt
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("==== cellForItemAt: \(indexPath) ===================")

        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell else {
            fatalError("Expected `\(Cell.self)` type for reuseIdentifier \(Cell.reuseIdentifier). Check the configuration in Main.storyboard.")
        }
        
        let model = models[indexPath.row]
        let identifier = model.identifier
        cell.representedIdentifier = identifier
        
        // Check if the `asyncFetcher` has already fetched data for the specified identifier.
        if let fetchedData = asyncFetcher.fetchedData(for: identifier) {
            // The data has already been fetched and cached; use it to configure the cell.
            print("fetchedData : \(fetchedData.id)")
            cell.configure(with: fetchedData)
        } else {
            // There is no data available; clear the cell until we've fetched data.
            print("NOT fetchedData")
            cell.configure(with: nil)

            // Ask the `asyncFetcher` to fetch data for the specified identifier.
            asyncFetcher.fetchAsync(identifier) { fetchedData in
                DispatchQueue.main.async {
                    /*
                     The `asyncFetcher` has fetched data for the identifier. Before
                     updating the cell, check if it has been recycled by the
                     collection view to represent other data.
                     */
                    guard cell.representedIdentifier == identifier else { return }
                    
                    // Configure the cell with the fetched image.
                    cell.configure(with: fetchedData)
                }
            }
        }

        return cell
    }

    // MARK: UICollectionViewDataSourcePrefetching

    /// - Tag: Prefetching
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print(">>> prefetch items >>>>>>>>>>")
        print("indexPaths to prefetch: \(indexPaths)\n")
        print("--- UUIDs to prefetch: ----------")
        for indexPath in indexPaths {
            print("UUID: \(models[indexPath.row].identifier)")
        }
        print("--------------------------------------------")
        // Begin asynchronously fetching data for the requested index paths.
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            asyncFetcher.fetchAsync(model.identifier)
        }
        print(">>> END prefetch items >>>>>>>>>>")
    }

    /// - Tag: CancelPrefetching
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("---- cancel prefetch ---------")
        // Cancel any in-flight requests for data for the specified index paths.
        for indexPath in indexPaths {
            let model = models[indexPath.row]
            asyncFetcher.cancelFetch(model.identifier)
        }
    }
}
