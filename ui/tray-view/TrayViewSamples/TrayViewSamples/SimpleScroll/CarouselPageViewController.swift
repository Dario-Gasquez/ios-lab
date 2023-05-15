//
//  CarouselPageViewController.swift
//  TrayViewSamples
//
//  Created by Dario on 6/25/20.
//

import UIKit

class CarouselPageViewController: UIPageViewController {

    var allViewControllers = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        populateViewControllers()

        setViewControllers([allViewControllers[0]], direction: .forward, animated: true, completion: nil)

        dataSource = self
        delegate = self
    }


    private func populateViewControllers() {
        for number in 1...7 {
            let carouselVC = CarouselItemViewController.instantiate()
            carouselVC.imageName = "astronomy-\(number)"
            allViewControllers.append(carouselVC)
        }
    }
}


extension CarouselPageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = allViewControllers.firstIndex(of: viewController),
            currentIndex > 0 else { return nil }

        return allViewControllers[currentIndex - 1]
    }


    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = allViewControllers.firstIndex(of: viewController),
            currentIndex < allViewControllers.count - 1 else { return nil }


        return allViewControllers[currentIndex + 1]
    }

    // A page indicator will be visible if both methods are implemented, transition style is 'UIPageViewControllerTransitionStyleScroll', and navigation orientation is 'UIPageViewControllerNavigationOrientationHorizontal'.
    // Both methods are called in response to a 'setViewControllers:...' call, but the presentation index is updated automatically in the case of gesture-driven navigation.

    // The number of items reflected in the page indicator.
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return allViewControllers.count
    }

    // The selected item reflected in the page indicator.
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }


}


extension CarouselPageViewController: UIPageViewControllerDelegate {

}
