//
//  GalleryTransitionDelegate.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public final class GalleryTransitionDelegate: NSObject {
    
    private let animator = GalleryTransitionAnimator()
}

extension GalleryTransitionDelegate: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isDimissed = false
        return animator
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animator.isDimissed = true
        return animator
    }
}
