//
//  CarouselItemViewController.swift
//  TrayViewSamples
//
//  Created by Dario on 6/25/20.
//

import UIKit

class CarouselItemViewController: UIViewController, Storyboarded {

    @IBOutlet var imageView: UIImageView!

    var imageName: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let name = imageName else {
            assertionFailure("provide an imageName before presenting this")
            return
        }

        imageView.image = UIImage(named: name)
        
    }
}
