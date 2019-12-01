//
//  GalleryTransitionDelegate.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol GalleryTransitionSource {
    var sourceView: UIView { get }
    var metadata: GalleryTransitionMetadata { get }
    func sourceViewFrame(relativeTo containerView: UIView) -> CGRect
}

public final class GalleryTransitionDelegate: NSObject {
    
    private let transitionAnimator: GalleryTransitionAnimator
    
    public init(source: GalleryTransitionSource, duration: TimeInterval = 0.5) {
        transitionAnimator = GalleryTransitionAnimator(source: source, duration: duration)
    }
}

extension GalleryTransitionDelegate: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.configure(viewController: presented)
        transitionAnimator.isDismissed = false
        return transitionAnimator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.isDismissed = true
        return transitionAnimator
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        transitionAnimator.isInteractive ? transitionAnimator : nil
    }
}
