//
//  GalleryTransitionAnimator.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol GalleryTransitionSourceViewController {
    
}

public protocol GalleryTransitionDestinationViewController {
    
}

public final class GalleryTransitionAnimator: UIPercentDrivenInteractiveTransition {
    
    public var isDismissed = false
    public var isInteractive = false
    
    private let transitionDuration: TimeInterval
    private var viewController: UIViewController?
    
    public init(duration: TimeInterval) {
        self.transitionDuration = duration
    }
    
    public func configure(viewController: UIViewController) {
        self.viewController = viewController
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        viewController.view.addGestureRecognizer(recognizer)
    }
}

extension GalleryTransitionAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let sourceViewController = transitionContext.viewController(forKey: isDismissed ? .to : .from ) as? UIViewController & GalleryTransitionSourceViewController,
            let destinationViewController = transitionContext.viewController(forKey: isDismissed ? .from : .to ) as? UIViewController & GalleryTransitionDestinationViewController else {
                completeTransition(with: transitionContext)
                return
        }
        
        transitionContext.containerView.addSubview(sourceViewController.view)
        transitionContext.containerView.addSubview(destinationViewController.view)
        sourceViewController.view.frame = isDismissed ? transitionContext.finalFrame(for: sourceViewController) : transitionContext.initialFrame(for: sourceViewController)
        destinationViewController.view.frame = isDismissed ? transitionContext.initialFrame(for: destinationViewController) : transitionContext.finalFrame(for: destinationViewController)
        
        let transformBefore: CGAffineTransform = isDismissed ? .identity : CGAffineTransform(scaleX: 0.001, y: 0.001)
        let transformAfter: CGAffineTransform = isDismissed ? CGAffineTransform(scaleX: 0.001, y: 0.001) : .identity
        
        destinationViewController.view.transform = transformBefore
        UIView.animate(withDuration: transitionDuration, animations: {
            destinationViewController.view.transform = transformAfter
        }, completion: { _ in
            self.completeTransition(with: transitionContext)
        })
    }
}

private extension GalleryTransitionAnimator {
    func completeTransition(with context: UIViewControllerContextTransitioning) {
        context.completeTransition(!context.transitionWasCancelled)
        if isDismissed && !context.transitionWasCancelled {
            (viewController as? GalleryViewController)?.delegate?.didCloseGalleryView()
        }
    }
    
    @objc
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view?.superview else {
            return
        }
        
        let translation = recognizer.translation(in: recognizerView)
        var progress = abs(translation.y / 200.0)
        progress = min(max(progress, 0.01), 0.99)
        
        switch recognizer.state {
        case .began:
            isInteractive = true
            viewController?.dismiss(animated: true)
        case .changed:
            update(progress)
        case .ended, .cancelled:
            if progress < 0.5 {
                cancel()
            } else {
                finish()
            }
            isInteractive = false
        default:
            break
        }
    }
}
