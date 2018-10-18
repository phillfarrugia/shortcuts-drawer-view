//
//  ViewController.swift
//  ShortcutsDrawer
//
//  Created by Phill Farrugia on 10/16/18.
//  Copyright © 2018 Phill Farrugia. All rights reserved.
//

import UIKit

/// A View Controller which is the primary view controller
/// that contains a child view controller that interacts like a
/// drawer overlay and enables selection of secondary options.
class PrimaryViewController: UIViewController, DrawerViewControllerDelegate {

    /// Container View Top Constraint
    @IBOutlet private weak var containerViewTopConstraint: NSLayoutConstraint!

    /// Previous Container View Top Constraint
    private var previousContainerViewTopConstraint: CGFloat = 0.0

    /// Background Overlay View
    @IBOutlet private weak var backgroundColorOverlayView: UIView!

    /// Background Overlay Alpha
    private static let kBackgroundColorOverlayTargetAlpha: CGFloat = 0.4

    // MARK: - Configuration

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        configureDrawerViewController()
    }

    private func configureAppearance() {
        backgroundColorOverlayView.alpha = 0.0
    }

    private func configureDrawerViewController() {
        let compressedHeight = ExpansionState.height(forState: .compressed, inContainer: view.bounds)
        let compressedTopConstraint = view.bounds.height - compressedHeight
        containerViewTopConstraint.constant = compressedTopConstraint
        previousContainerViewTopConstraint = containerViewTopConstraint.constant

        // NB: Handle this in a more clean and production ready fashion.
        if let drawerViewController = children.first as? DrawerViewController {
            drawerViewController.delegate = self
        }
    }

    // MARK: - DrawerViewControllerDelegate

    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint) {
        /// Disable selection on drawerViewController's content while translating it.
        drawerViewController.view.isUserInteractionEnabled = false

        let newConstraintConstant = previousContainerViewTopConstraint + translationPoint.y
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50.0

        /// Limit the user from translating the drawer too far to the top
        if (newConstraintConstant >= fullHeightTopConstraint - constraintPadding/2) {
            containerViewTopConstraint.constant = newConstraintConstant
            animateBackgroundFade(withCurrentTopConstraint: newConstraintConstant)
        }
    }

    /// Animates the top constraint of the drawerViewController by a given constant
    /// using velocity to calculate a spring and damping animation effect.
    private func animateTopConstraint(constant: CGFloat, withVelocity velocity: CGPoint) {
        let previousConstraint = containerViewTopConstraint.constant
        let distance = previousConstraint - constant
        let springVelocity = max(1 / (abs(velocity.y / distance)), 0.08)
        let springDampening = CGFloat(0.6)

        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: springDampening,
                       initialSpringVelocity: springVelocity,
                       options: [.curveLinear],
                       animations: {
                        self.containerViewTopConstraint.constant = constant
                        self.previousContainerViewTopConstraint = constant
                        self.animateBackgroundFade(withCurrentTopConstraint: constant)
                        self.view.layoutIfNeeded()
        },
                       completion: nil)
    }

    /// Animates the alpha of the `backgroundColorOverlayView` based on the progress of the
    /// translation of the drawer between the expansion state and the fullHeight state.
    private func animateBackgroundFade(withCurrentTopConstraint currentTopConstraint: CGFloat) {
        let expandedHeight = ExpansionState.height(forState: .expanded, inContainer: view.bounds)
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let expandedTopConstraint = view.bounds.height - expandedHeight
        let fullHeightTopConstraint = view.bounds.height - fullHeight

        let totalDistance = (expandedTopConstraint - fullHeightTopConstraint)
        let currentDistance = (expandedTopConstraint - currentTopConstraint)
        var progress = currentDistance / totalDistance

        progress = max(0.0, progress)
        progress = min(PrimaryViewController.kBackgroundColorOverlayTargetAlpha, progress)
        backgroundColorOverlayView.alpha = progress
    }

    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didEndTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint) {
        let compressedHeight = ExpansionState.height(forState: .compressed, inContainer: view.bounds)
        let expandedHeight = ExpansionState.height(forState: .expanded, inContainer: view.bounds)
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let compressedTopConstraint = view.bounds.height - compressedHeight
        let expandedTopConstraint = view.bounds.height - expandedHeight
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        let constraintPadding: CGFloat = 50.0
        let velocityThreshold: CGFloat = 50.0
        drawerViewController.view.isUserInteractionEnabled = true

        if velocity.y > velocityThreshold {
            // Handle High Velocity Pan Gesture
            if previousContainerViewTopConstraint == fullHeightTopConstraint {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Full Height to Expanded
                    drawerViewController.expansionState = .expanded
                    animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
                } else {
                    // From Full Height to Compressed
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            } else if previousContainerViewTopConstraint == expandedTopConstraint {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Expanded to Full Height
                    drawerViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    // From Expanded to Compressed
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            } else {
                if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                    // From Compressed to Full Height
                    drawerViewController.expansionState = .fullHeight
                    animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
                } else {
                    // From Compressed back to Compressed
                    drawerViewController.expansionState = .compressed
                    animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
                }
            }
        } else {
            // Handle Low Velocity Pan Gesture
            if containerViewTopConstraint.constant <= expandedTopConstraint - constraintPadding {
                // Animate to the full height top constraint with velocity
                drawerViewController.expansionState = .fullHeight
                animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: velocity)
            } else if containerViewTopConstraint.constant < compressedTopConstraint - constraintPadding {
                // Animate to the expanded top constraint with velocity
                drawerViewController.expansionState = .expanded
                animateTopConstraint(constant: expandedTopConstraint, withVelocity: velocity)
            } else {
                // Animate to the compressed top constraint with velocity
                drawerViewController.expansionState = .compressed
                animateTopConstraint(constant: compressedTopConstraint, withVelocity: velocity)
            }
        }
    }

    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeExpansionState expansionState: ExpansionState) {
        /// User tapped on the search bar, animate to FullHeight (NB: Abandoned this as it's not important to the demo,
        /// but it could be animated better and add support for dismissing the keyboard).
        let fullHeight = ExpansionState.height(forState: .fullHeight, inContainer: view.bounds)
        let fullHeightTopConstraint = view.bounds.height - fullHeight
        animateTopConstraint(constant: fullHeightTopConstraint, withVelocity: CGPoint(x: 0, y: -4536))
    }

}

