//
//  TappableTrayViewController.swift
//  TrayViewSamples
//
//  Created by Dario on 5/26/20.
//

import UIKit

class TappableTrayViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()

        traySetup()
    }
    

    // MARK: - Private Section -

    private enum TrayState {
        case shown
        case dismissed
    }

    // Variable determines the next state of the card expressing that the card starts and collapased
    private var nextState: TrayState {
        return isTrayVisible ? .dismissed : .shown
    }

    private var trayViewController: TrayViewController!
    private var visualEffectView: UIVisualEffectView!

    private var startTrayHeight: CGFloat = 0.0
    private var endTrayHeight: CGFloat = 0.0
    private var isTrayVisible = false
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0.0


    private func traySetup() {
        startTrayHeight = view.frame.height * 0.2
        endTrayHeight   = view.frame.height * 0.9

        // add visual effect view
        visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualEffectView.frame = view.frame
        visualEffectView.alpha = 0.0
        view.addSubview(visualEffectView)

        // Add tray view to the bottom of the screen, clipping bounds so that the corners can be rounded
        trayViewController = TrayViewController(nibName: "TrayViewController", bundle: nil)
        view.addSubview(trayViewController.view)
        trayViewController.view.frame = CGRect(x: 0, y: view.bounds.height - startTrayHeight, width: view.bounds.width, height: endTrayHeight)
        trayViewController.view.clipsToBounds = true

        // Add tap and pan gesture recognizers
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
        let panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(recognizer:)))

        trayViewController.handleView.addGestureRecognizer(tapRecognizer)
        trayViewController.handleView.addGestureRecognizer(panRecognizer)
    }

    @objc private func handleTap(recognizer: UITapGestureRecognizer) {
        switch recognizer.state {
        // Animate card when tap finishes
        case .ended:
            animateTransitionIfNeeded(state: nextState, duration: 0.9)
        default:
            break
        }
    }

    @objc private func handlePan(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            // Start animation if pan begins
            startInteractiveTransition(state: nextState, duration: 0.9)

        case .changed:
            // Update the translation according to the percentage completed
            let translation = recognizer.translation(in: trayViewController.handleView)
            var fractionComplete = translation.y / endTrayHeight
            fractionComplete = isTrayVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fractionCompleted: fractionComplete)
        case .ended:
            // End animation when pan ends
            continueInteractiveTransition()
        default:
            break
        }
    }


    // Animate transistion function
    private func animateTransitionIfNeeded (state:TrayState, duration:TimeInterval) {
        // Check if frame animator is empty
        if runningAnimations.isEmpty {
            // Create a UIViewPropertyAnimator depending on the state of the popover view
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) { [weak self] in
                guard let this = self else { return }

                switch state {
                case .shown:
                    // If expanding set popover y to the ending height and blur background
                    this.trayViewController.view.frame.origin.y = this.view.frame.height - this.endTrayHeight
                    //this.visualEffectView.effect = UIBlurEffect(style: .dark)
                    this.visualEffectView.alpha = 1.0

                case .dismissed:
                    // If collapsed set popover y to the starting height and remove background blur
                    this.trayViewController.view.frame.origin.y = this.view.frame.height - this.startTrayHeight
                        //this.visualEffectView.effect = nil
                    this.visualEffectView.alpha = 0.0
                }
            }

            // Complete animation frame
            frameAnimator.addCompletion { [weak self] _ in
                guard let this = self else { return }

                this.isTrayVisible = !this.isTrayVisible
                this.runningAnimations.removeAll()
            }

            // Start animation
            frameAnimator.startAnimation()

            // Append animation to running animations
            runningAnimations.append(frameAnimator)

            // Create UIViewPropertyAnimator to round the popover view corners depending on the state of the popover
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) { [weak self] in
                guard let this = self else { return }

                switch state {
                case .shown:
                    // If the view is expanded set the corner radius to 30
                    this.trayViewController.view.layer.cornerRadius = 30

                case .dismissed:
                    // If the view is collapsed set the corner radius to 0
                    this.trayViewController.view.layer.cornerRadius = 0
                }
            }

            // Start the corner radius animation
            cornerRadiusAnimator.startAnimation()

            // Append animation to running animations
            runningAnimations.append(cornerRadiusAnimator)

        }
    }

    // Function to start interactive animations when view is dragged
    private func startInteractiveTransition(state: TrayState, duration: TimeInterval) {

        // If animation is empty start new animation
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }

        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Pause animation and update the progress to the fraction complete percentage
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }

    // Funtion to update transition when view is dragged
    private func updateInteractiveTransition(fractionCompleted:CGFloat) {
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Update the fraction complete value to the current progress
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }

    // Function to continue an interactive transisiton
    private func continueInteractiveTransition(){
        // For each animation in runningAnimations
        for animator in runningAnimations {
            // Continue the animation forwards or backwards
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
}
