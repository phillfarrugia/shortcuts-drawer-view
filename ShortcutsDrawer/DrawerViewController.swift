//
//  DrawerViewController.swift
//  ShortcutsDrawer
//
//  Created by Phill Farrugia on 10/16/18.
//  Copyright © 2018 Phill Farrugia. All rights reserved.
//

import UIKit

/// A View Controller which displays content and is intended to be displayed
/// as a Child View Controller, that can be panned and translated over the top
/// of a Parent View Controller.
class DrawerViewController: UIViewController, UIGestureRecognizerDelegate, UISearchBarDelegate {

    /// Table View
    @IBOutlet internal weak var tableView: UITableView!

    /// Pan Gesture Recognizer
    internal var panGestureRecognizer: UIPanGestureRecognizer?

    /// Header View
    @IBOutlet private weak var headerView: UIView!

    /// Header Title View
    @IBOutlet private weak var headerViewTitleLabel: UILabel!

    /// Header Search bar
    @IBOutlet private weak var searchBar: UISearchBar!

    /// Current Expansion State
    var expansionState: ExpansionState = .compressed {
        didSet {
            if expansionState != oldValue {
                configure(forExpansionState: expansionState)
            }
        }
    }

    /// Delegate used to send panGesture events to the Parent View Controller
    /// to enable translation of the viewController in it's parent's coordinate system.
    weak var delegate: DrawerViewControllerDelegate?

    /// Determines if the panGestureRecognizer should ignore or handle a gesture. Used
    /// in the case of subview's with gestureRecognizers conflicting with the `panGestureRecognizer`
    /// such as the tableView's scrollView recognizer.
    private var shouldHandleGesture: Bool = true

    // MARK: - Configuration

    override func viewDidLoad() {
        super.viewDidLoad()

        setupGestureRecognizers()
        configureAppearance()
        configureTableView()
        configure(forExpansionState: expansionState)
    }

    private func configureAppearance() {
        view.layer.cornerRadius = 8.0
        view.layer.masksToBounds = true
        searchBar.delegate = self
    }

    // MARK: - Expansion State

    private func configure(forExpansionState expansionState: ExpansionState) {
        switch expansionState {
        case .compressed:
            animateHeaderTitle(toAlpha: 0.0)
            tableView.panGestureRecognizer.isEnabled = false
            break
        case .expanded:
            animateHeaderTitle(toAlpha: 1.0)
            tableView.panGestureRecognizer.isEnabled = false
            break
        case .fullHeight:
            animateHeaderTitle(toAlpha: 1.0)
            if tableView.contentOffset.y > 0.0 {
                panGestureRecognizer?.isEnabled = false
            } else {
                panGestureRecognizer?.isEnabled = true
            }
            tableView.panGestureRecognizer.isEnabled = true
            break
        }
    }

    /// Animates the title in the header to visible/invisible in the compression state.
    private func animateHeaderTitle(toAlpha alpha: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.headerViewTitleLabel.alpha = alpha
        }
    }

    // MARK: - Gesture Recognizers

    private func setupGestureRecognizers() {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                          action: #selector(panGestureDidMove(sender:)))
        panGestureRecognizer.cancelsTouchesInView = false
        panGestureRecognizer.delegate = self

        view.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer
    }

    @objc private func panGestureDidMove(sender: UIPanGestureRecognizer) {
        guard shouldHandleGesture else { return }
        let translationPoint = sender.translation(in: view.superview)
        let velocity = sender.velocity(in: view.superview)

        switch sender.state {
        case .changed:
            delegate?.drawerViewController(self, didChangeTranslationPoint: translationPoint, withVelocity: velocity)
        case .ended:
            delegate?.drawerViewController(self,
                                           didEndTranslationPoint: translationPoint,
                                           withVelocity: velocity)
        default:
            return
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    /// Called when the `panGestureRecognizer` has to simultaneously handle gesture events with the
    /// tableView's gesture recognizer. Chooses to handle or ignore events based on the state of the drawer
    /// and the tableView's y contentOffset.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
        let velocity = panGestureRecognizer.velocity(in: view.superview)
        tableView.panGestureRecognizer.isEnabled = true

        if otherGestureRecognizer == tableView.panGestureRecognizer {
            switch expansionState {
            case .compressed:
                return false
            case .expanded:
                return false
            case .fullHeight:
                if velocity.y > 0.0 {
                    // Panned Down
                    if tableView.contentOffset.y > 0.0 {
                        return true
                    }
                    shouldHandleGesture = true
                    tableView.panGestureRecognizer.isEnabled = false
                    return false
                } else {
                    // Panned Up
                    shouldHandleGesture = false
                    return true
                }
            }
        }
        return false
    }

    /// Called when the user scrolls the tableView's scroll view. Resets the scrolling
    /// when the user hits the top of the scrollview's contentOffset to support seamlessly
    /// transitioning between the scroll view and the panGestureRecognizer under the user's finger.
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let panGestureRecognizer = panGestureRecognizer else { return }

        let contentOffset = scrollView.contentOffset.y
        if contentOffset <= 0.0 &&
            expansionState == .fullHeight &&
            panGestureRecognizer.velocity(in: panGestureRecognizer.view?.superview).y != 0.0 {
            shouldHandleGesture = true
            scrollView.isScrollEnabled = false
            scrollView.isScrollEnabled = true
        }
    }

    // MARK: - UISearchBarDelegate

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        delegate?.drawerViewController(self, didChangeExpansionState: .fullHeight)
    }

    // MARK: - Sample Cell Data

    internal static let sampleAppIcons: [UIImage] = [
        UIImage(named: "messages-icon")!,
        UIImage(named: "maps-icon")!,
        UIImage(named: "settings-icon")!,
        UIImage(named: "photos-icon")!,
        UIImage(named: "appstore-icon")!,
        UIImage(named: "apple-music-icon")!,
    ]

    internal static let sampleAppTitles: [String] = [
        "Send Message",
        "Get Distance",
        "Get Name",
        "Find Photos",
        "Search App Store",
        "Add to Playlist"
    ]

    internal static let sampleAppDescriptions: [String] = [
        "Sends an iMessage or SMS. Pass images, videos, or other files as input to include attachments.",
        "Calculates the distance to the location passed into this action.",
        "Returns the name of every item passed as input. Depending on the input, this could be a file name...",
        "Searches for the photos in your Library that match the given critera.",
        "Searches the App Store, returning the apps that math the specified search terms.",
        "Adds the item passed as input to the specified playlist."
    ]

}
