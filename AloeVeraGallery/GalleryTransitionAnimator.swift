//
//  GalleryTransitionAnimator.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol GalleryTransitionSourceViewController {
//    var sourceView: UIView { get }
//    func sourceViewFrame(relativeTo containerView: UIView) -> CGRect
}

public protocol GalleryTransitionDestinationViewController {
    func animator(_ animator: GalleryTransitionAnimator, configureViewForTransitionPercentage percentage: CGFloat)
}

public final class GalleryTransitionAnimator: NSObject {
    
    public var duration: TimeInterval = 0.35
    public var isDimissed = false
}

extension GalleryTransitionAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionData = TransitionData(transitionContext: transitionContext, isDimissed: isDimissed) else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return
        }
        transitionData.destinationViewController.animator(self, configureViewForTransitionPercentage: isDimissed ? 1 : 0)
        transitionData.containerView.addSubview(transitionData.sourveView)
        transitionData.containerView.addSubview(transitionData.destinationView)
        
        transitionData.sourveView.frame = transitionData.containerView.bounds
        transitionData.destinationView.frame = transitionData.containerView.bounds
        
        let transformBefore: CGAffineTransform = isDimissed ? .identity : CGAffineTransform(scaleX: 0.001, y: 0.001)
        let transformAfter: CGAffineTransform = isDimissed ? CGAffineTransform(scaleX: 0.001, y: 0.001) : .identity
        
        transitionData.destinationView.transform = transformBefore
        
        
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: duration, delay: 0, animations: {
            transitionData.destinationView.transform = transformAfter
        }, completion: { _ in
            transitionData.destinationViewController.animator(self, configureViewForTransitionPercentage: self.isDimissed ? 0 : 1)
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

private extension GalleryTransitionAnimator {
    struct TransitionData {
        let sourceViewController: UIViewController & GalleryTransitionSourceViewController
        let destinationViewController: UIViewController & GalleryTransitionDestinationViewController
        let sourveView: UIView
        let destinationView: UIView
        let containerView: UIView
        
        init?(transitionContext: UIViewControllerContextTransitioning, isDimissed: Bool) {
            guard
                let sourceViewController = transitionContext.viewController(forKey: isDimissed ? .to : .from ) as? UIViewController & GalleryTransitionSourceViewController,
                let destinationViewController = transitionContext.viewController(forKey: isDimissed ? .from : .to ) as? UIViewController & GalleryTransitionDestinationViewController,
                let sourveView = transitionContext.view(forKey: isDimissed ? .to : .from ),
                let destinationView = transitionContext.view(forKey: isDimissed ? .from : .to ) else {
                    return nil
            }
            self.sourceViewController = sourceViewController
            self.destinationViewController = destinationViewController
            self.sourveView = sourveView
            self.destinationView = destinationView
            self.containerView = transitionContext.containerView
        }
    }
}
