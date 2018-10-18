//
//  DrawerViewControllerDelegate.swift
//  ShortcutsDrawer
//
//  Created by Phill Farrugia on 10/16/18.
//  Copyright © 2018 Phill Farrugia. All rights reserved.
//

import UIKit

/// A protocol that defines the communication between a DrawerViewController
/// and its container viewController allowing the container to translate the
/// drawerViewController within its own coordinate system.
protocol DrawerViewControllerDelegate: class {

    /**
     Called when the drawerViewController has been panned and should translate
     based on a given velocity.
     - Parameter drawerViewController: DrawerViewController that was panned.
     - Parameter translationPoint: Translation point of the pan.
     - Parameter velocity: Velocity of the pan.
     */
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)

    /**
     Called when the drawerViewController has ended panning.
     - Parameter drawerViewController: DrawerViewController that was panned.
     - Parameter translationPoint: Translation point of the pan.
     - Parameter velocity: Velocity of the pan.
     */
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didEndTranslationPoint translationPoint: CGPoint,
                              withVelocity velocity: CGPoint)

    /**
     Called when the drawerViewController has internally changed its expansion state.
     - Parameter drawerViewController: DrawerViewController that was panned.
     - Parameter translationPoint: Translation point of the pan.
     - Parameter velocity: Velocity of the pan.
     */
    func drawerViewController(_ drawerViewController: DrawerViewController,
                              didChangeExpansionState expansionState: ExpansionState)

}
