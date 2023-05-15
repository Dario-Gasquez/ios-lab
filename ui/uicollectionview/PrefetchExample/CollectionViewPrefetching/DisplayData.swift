/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A class that represents the data shown in the collection view.
*/

import UIKit

/// A type to represent how model data should be displayed.
class DisplayData: NSObject {


    init(color: UIColor = .red, id: String) {
        self.color = color
        self.id = id
    }

    var color: UIColor = .red
    var id: String = ""
    
    // Add additional properties for your own configuration here.
}
