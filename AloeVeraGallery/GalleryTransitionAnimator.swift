//
//  GalleryTransitionAnimator.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public protocol GalleryTransitionSourceViewController {
    var sourceView: UIView { get }
    func sourceViewCenter(relativeTo view: UIView) -> CGPoint
}

public protocol GalleryTransitionDestinationViewController {
    var animatableView: UIView { get }
    func animatableViewCenter(relativeTo view: UIView) -> CGPoint
}

public final class GalleryTransitionAnimator: UIPercentDrivenInteractiveTransition {
    
    public var isDismissed = false
    public var isInteractive = false
    
    private let transitionDuration: TimeInterval
    private var sourceViewController: (UIViewController & GalleryTransitionSourceViewController)?
    private var destinationViewController: (UIViewController & GalleryTransitionDestinationViewController)?
    private var currentContext: UIViewControllerContextTransitioning?
    private var currentAnimator = UIViewPropertyAnimator()
    
    public init(duration: TimeInterval) {
        self.transitionDuration = duration
    }
    
    public func configure(viewController: UIViewController) {
        destinationViewController = viewController as? UIViewController & GalleryTransitionDestinationViewController
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        viewController.view.addGestureRecognizer(recognizer)
    }
}

extension GalleryTransitionAnimator: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        transitionDuration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        guard currentContext !== transitionContext else {
            return currentAnimator
        }
        currentContext = transitionContext
        setupContainerView()
        guard sourceViewController != nil, destinationViewController != nil else {
            completeTransition(with: transitionContext)
            return currentAnimator
        }
        currentAnimator = UIViewPropertyAnimator(duration: transitionDuration, curve: .linear)
        animateView()
        animateBackground()
        currentAnimator.addCompletion { _ in
            self.completeTransition(with: transitionContext)
        }
        return currentAnimator
    }
}

private extension GalleryTransitionAnimator {
    func setupContainerView() {
        guard
            let context = currentContext,
            let destinationViewController = destinationViewController,
            let sourceViewController = context.viewController(forKey: isDismissed ? .to : .from ) as? UIViewController & GalleryTransitionSourceViewController else {
                return
        }
        self.sourceViewController = sourceViewController
        context.containerView.addSubview(sourceViewController.view)
        context.containerView.addSubview(destinationViewController.view)
        sourceViewController.view.frame = isDismissed ? context.finalFrame(for: sourceViewController) : context.initialFrame(for: sourceViewController)
        destinationViewController.view.frame = isDismissed ? context.initialFrame(for: destinationViewController) : context.finalFrame(for: destinationViewController)
    }
    
    func animateView() {
        guard
            let context = currentContext,
            let sourceViewController = sourceViewController,
            let destinationViewController = destinationViewController else {
                return
        }
        let sourceCenter = sourceViewController.sourceViewCenter(relativeTo: context.containerView)
        let destinationCenter = destinationViewController.animatableViewCenter(relativeTo: context.containerView)
        let startTransform = CGAffineTransform(translationX: sourceCenter.x - destinationCenter.x, y: sourceCenter.y - destinationCenter.y)
        let endTransform: CGAffineTransform = .identity
        
        destinationViewController.animatableView.transform = isDismissed ? endTransform : startTransform
        currentAnimator.addAnimations {
            destinationViewController.animatableView.transform = self.isDismissed ? startTransform : endTransform
        }
    }
    
    func animateBackground() {
        let relativeDuration = 0.25
        if !isDismissed {
            destinationViewController?.view.backgroundColor = .clear
        }
        currentAnimator.addAnimations {
            UIView.animateKeyframes(withDuration: self.transitionDuration, delay: 0, animations: {
                UIView.addKeyframe(withRelativeStartTime: self.isDismissed ? 0 : 1 - relativeDuration, relativeDuration: relativeDuration) {
                    self.destinationViewController?.view.backgroundColor = self.isDismissed ? .clear : .white
                }
            })
        }
    }
    
    func completeTransition(with context: UIViewControllerContextTransitioning) {
        context.completeTransition(!context.transitionWasCancelled)
        if isDismissed && !context.transitionWasCancelled {
            (destinationViewController as? GalleryViewController)?.delegate?.didCloseGalleryView()
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
            destinationViewController?.dismiss(animated: true)
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
