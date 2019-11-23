//
//  GalleryTransitionAnimator.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol GalleryTransitionSourceViewController {
//    func willStartPresentingGallary(by animator: GalleryTransitionAnimator)
//    func didFinishPresentingGallary(by animator: GalleryTransitionAnimator)
//    func willStartDismissingGallary(by animator: GalleryTransitionAnimator)
//    func didFinishDismissingGallary(by animator: GalleryTransitionAnimator)
}

public protocol GalleryTransitionDestinationViewController {
//    func willStartPresentingGallary(by animator: GalleryTransitionAnimator)
//    func didFinishPresentingGallary(by animator: GalleryTransitionAnimator)
//    func willStartDismissingGallary(by animator: GalleryTransitionAnimator)
//    func didFinishDismissingGallary(by animator: GalleryTransitionAnimator)
}

public final class GalleryTransitionAnimator: UIPercentDrivenInteractiveTransition {
    
    public var transitionDuration: TimeInterval = 0.35
    public var isDismissed = false
    public var isInteractive = false
    
    private var context: UIViewControllerContextTransitioning?
    private var animator: UIViewPropertyAnimator?
}

extension GalleryTransitionAnimator: UIViewControllerAnimatedTransitioning {
    public override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.startInteractiveTransition(transitionContext)
        configurePropertyAnimatorIfNeeded(with: transitionContext)
    }
    
    public override func update(_ percentComplete: CGFloat) {
        super.update(percentComplete)
        animator?.fractionComplete = percentComplete
    }
    
    public override func cancel() {
        super.cancel()
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .start)
    }
    
    public override func finish() {
        super.finish()
        animator?.stopAnimation(false)
        animator?.finishAnimation(at: .end)
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        configurePropertyAnimatorIfNeeded(with: transitionContext)
        if !isInteractive {
            animator?.startAnimation()
        }
    }
}

extension GalleryTransitionAnimator {
    func handlePanGesture(by recognizer: UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view?.superview else {
            return
        }
        let translation = recognizer.translation(in: recognizerView)
        var progress = abs(translation.y / 200.0)
        progress = min(max(progress, 0.01), 0.99)
        
        switch recognizer.state {
        case .changed:
            update(progress)
        case .ended, .cancelled, .failed:
            if progress < 0.5 {
                cancel()
                context?.completeTransition(false)
            } else {
                finish()
                context?.completeTransition(true)
            }
        default:
            break
        }
    }
}

private extension GalleryTransitionAnimator {
    func configurePropertyAnimatorIfNeeded(with transitionContext: UIViewControllerContextTransitioning) {
        guard transitionContext !== context else {
            return
        }
        
        guard
            let sourceViewController = transitionContext.viewController(forKey: isDismissed ? .to : .from ) as? UIViewController & GalleryTransitionSourceViewController,
            let destinationViewController = transitionContext.viewController(forKey: isDismissed ? .from : .to ) as? UIViewController & GalleryTransitionDestinationViewController else {
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
                context = nil
                return
        }
        
        context = transitionContext
        transitionContext.containerView.addSubview(sourceViewController.view)
        transitionContext.containerView.addSubview(destinationViewController.view)
        sourceViewController.view.frame = isDismissed ? transitionContext.finalFrame(for: sourceViewController) : transitionContext.initialFrame(for: sourceViewController)
        destinationViewController.view.frame = isDismissed ? transitionContext.initialFrame(for: destinationViewController) : transitionContext.finalFrame(for: destinationViewController)
        
        let transformBefore: CGAffineTransform = isDismissed ? .identity : CGAffineTransform(scaleX: 0.001, y: 0.001)
        let transformAfter: CGAffineTransform = isDismissed ? CGAffineTransform(scaleX: 0.001, y: 0.001) : .identity
        
        destinationViewController.view.transform = transformBefore
        animator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.8)
        animator?.addAnimations {
            destinationViewController.view.transform = transformAfter
        }
        animator?.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
