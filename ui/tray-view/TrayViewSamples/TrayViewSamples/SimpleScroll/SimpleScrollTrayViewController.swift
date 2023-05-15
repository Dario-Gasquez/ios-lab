//
//  SimpleScrollTrayViewController.swift
//  TrayViewSamples
//
//  Created by Dario on 5/25/20.
//

import UIKit

class SimpleScrollTrayViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleTrayPan(recognizer:)))
        trayView.addGestureRecognizer(panGestureRecognizer)
        //TODO: instead of a constant value we should calculate this based on how much we want to show regardless the device
        // screen size. For example shown up to the 'BUY' button will require different values for an i8 than an i11
        trayViewTopConstraint.constant = Constants.dismissedTrayYPosition

        animator = UIDynamicAnimator(referenceView: view)
        animator.delegate = self

        // Color Variants ~~~~~~~
        colorVariantsCollectionView.delegate = self
        colorVariantsCollectionView.dataSource = self


        // Multi Color Variants ~~~~~~~
        let multiColorCellNib = UINib(nibName: MultiColorCollectionViewCell.className, bundle: nil)
        multiColorCollectionView.register(multiColorCellNib, forCellWithReuseIdentifier: MultiColorCollectionViewCell.className)
        multiColorCollectionView.delegate = multiColorDataSource
        multiColorCollectionView.dataSource = multiColorDataSource


//        featuresLabel.text =
//        """
//        • feature 100/t/t• Feature 2
//        • feature 3/t/t• Feature 4
//        • feature 5/t/t• Feature 6
//        • feature 7
//
//        """

        let features = ["first very long", "second", "third", "fourth", "fifth"]
        //featuresLabel.attributedText = NSAttributedStringHelper.createBulletedList(fromStringArray: features, font: UIFont.systemFont(ofSize: 15))
        featuresLabel.attributedText = bulletPointList(strings: features)


    }


    func bulletPointList(strings: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = 20
        paragraphStyle.maximumLineHeight = 20
        let screenWidth = UIScreen.main.bounds.width
        paragraphStyle.tabStops = [NSTextTab(textAlignment: .left, location: screenWidth/2)]

        let stringAttributes = [
//            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15),
//            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: paragraphStyle
        ]

        let string = strings.map({ "• \($0)\t• \($0)" }).joined(separator: "\n")

        return NSAttributedString(string: string,
                                  attributes: stringAttributes)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(#function) >>>>>>>>>>>>")
        print("trayView bounds: \(trayView.bounds)")
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(#function) <<<<<<<<<<<<")

        print("trayView bounds: \(trayView.bounds)")
        trayViewHeight = trayView.bounds.height
    }


    // MARK: - Private Section -
    @IBOutlet private var trayView: UIView!
    @IBOutlet private var trayViewTopConstraint: NSLayoutConstraint!
    @IBOutlet private var colorVariantsCollectionView: UICollectionView!
    @IBOutlet private var multiColorCollectionView: UICollectionView!
    @IBOutlet private var featuresLabel: UILabel!

    private enum Constants {
        static let dismissedTrayYPosition: CGFloat = 51.0
    }

    private let multiColorDataSource = MultiColorCVDataSource()
    private var lastTrayTopConstantValue: CGFloat = Constants.dismissedTrayYPosition
    private var initialConstantValue: CGFloat = 0.0
    private var trayViewHeight: CGFloat = 0.0

    //UIKit Dynamics
    private var animator: UIDynamicAnimator!


    @objc
    private func handleTrayPan(recognizer:UIPanGestureRecognizer) {

        switch recognizer.state {
        case .began:
            animator.removeAllBehaviors()
            initialConstantValue = lastTrayTopConstantValue
            break
        case .changed:
            let translation = recognizer.translation(in: self.trayView)

            print("translation value: \(translation)")

            print("trayView frame: \(trayView.frame)")
            print("top constraint constant: \(trayViewTopConstraint.constant)")
            trayViewTopConstraint.constant = (initialConstantValue - translation.y).clamped(to: Constants.dismissedTrayYPosition...trayViewHeight)

        case .ended:
            lastTrayTopConstantValue = trayViewTopConstraint.constant

            let velocity = CGPoint(x: 0, y: recognizer.velocity(in: self.trayView).y)
            updateDynamicsConfiguration(withVelocity: velocity)

            break
        case .possible:
            break
        case .cancelled:
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }


    private func updateDynamicsConfiguration(withVelocity velocity: CGPoint) {

        print("velocity value: \(velocity)")

        let inertia = UIDynamicItemBehavior(items: [trayView])
        inertia.addLinearVelocity(velocity, for: trayView)
        inertia.allowsRotation = false
        inertia.resistance = 3.0
        inertia.action = { [weak self] in
            guard let this = self else { return }

            //update top constraint constant value based on trayView.y position
            this.trayViewTopConstraint.constant = this.view.frame.maxY - this.trayView.frame.origin.y
            this.lastTrayTopConstantValue = this.trayViewTopConstraint.constant
        }

        animator.addBehavior(inertia)

        let collision = UICollisionBehavior(items: [trayView])
        let topBoundaryYPosition = view.bounds.height - trayViewHeight - 1
        collision.addBoundary(withIdentifier: "topCollistionBoundary" as NSCopying, from: CGPoint(x: 0.0, y: topBoundaryYPosition), to: CGPoint(x: view.bounds.width, y: topBoundaryYPosition))
        let bottomBoundaryYPosition = self.view.bounds.height - Constants.dismissedTrayYPosition + trayViewHeight + 1
        collision.addBoundary(withIdentifier: "bottomCollistionBoundary" as NSCopying, from: CGPoint(x: 0.0, y: bottomBoundaryYPosition), to: CGPoint(x: view.bounds.width, y: bottomBoundaryYPosition))
        animator.addBehavior(collision)

        //            let snap = UISnapBehavior(item: trayView, snapTo: CGPoint(x: view.center.x, y: view.center.y))
        //            snap.damping = 0.2
        //            animator.addBehavior(snap)
    }
}


extension SimpleScrollTrayViewController: UICollectionViewDelegate {

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


// MARK: - UICollectionViewDataSource
extension SimpleScrollTrayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.className, for: indexPath) as? ColorCollectionViewCell else {
            fatalError("\(#function): could not deque cell as HomeCollectionViewCell")
        }

        // TODO: set the color
        //cell.homeItem = homeViewModel?.homeItemAt(index: indexPath.row)

        return cell
    }
}

// MARK: - UIDynamicAnimatorDelegate
extension SimpleScrollTrayViewController: UIDynamicAnimatorDelegate {
    func dynamicAnimatorWillResume(_ animator: UIDynamicAnimator) {
        print("\(#function) -----")
        print("\(animator.debugDescription)")
    }

    func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        print("\(#function) -----")
        print("===")
        print("\(animator.debugDescription)")
        print("===")
        print("trayview frame: \(trayView.frame)")
        print("===")
        print("topContrainst constant: \(trayViewTopConstraint.constant)")
        print("===")
        animator.removeAllBehaviors()
    }
}
