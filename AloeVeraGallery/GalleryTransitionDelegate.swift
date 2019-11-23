//
//  GalleryTransitionDelegate.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public final class GalleryTransitionDelegate: NSObject {
    
    let transitionAnimator = GalleryTransitionAnimator()
}

extension GalleryTransitionDelegate: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
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
