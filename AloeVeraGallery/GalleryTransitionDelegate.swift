//
//  GalleryTransitionDelegate.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public final class GalleryTransitionDelegate: NSObject {
    
    private let transitionAnimator: GalleryTransitionAnimator
    
    public init(sourceView: UIView, metadata: GalleryTransitionMetadata, duration: TimeInterval = 0.5) {
        transitionAnimator = GalleryTransitionAnimator(sourceView: sourceView, metadata: metadata, duration: duration)
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
