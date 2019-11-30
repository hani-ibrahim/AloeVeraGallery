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
    var metadata: GalleryTransitionMetadata { get }
    func sourceViewFrame(relativeTo containerView: UIView) -> CGRect
}

public protocol GalleryTransitionDestinationViewController {
    var animatableView: UIView! { get }
    var topAnimatableViewConstraint: NSLayoutConstraint! { get }
    var bottomAnimatableViewConstraint: NSLayoutConstraint! { get }
    var rightAnimatableViewConstraint: NSLayoutConstraint! { get }
    var leftAnimatableViewConstraint: NSLayoutConstraint! { get }
    func animatableViewFrame(relativeTo containerView: UIView) -> CGRect
}

public final class GalleryTransitionAnimator: UIPercentDrivenInteractiveTransition {
    
    public var isDismissed = false
    public var isInteractive = false
    
    private let transitionDuration: TimeInterval
    private var sourceViewController: (UIViewController & GalleryTransitionSourceViewController)?
    private var destinationViewController: (UIViewController & GalleryTransitionDestinationViewController)?
    private var currentContext: UIViewControllerContextTransitioning?
    private var currentAnimator = UIViewPropertyAnimator()
    private var transitionData: TransitionData?
    private var interactiveDismissStartLocation: CGPoint = .zero
    private var interactiveDismissDisplacement: CGPoint = .zero
    private var shouldCancelInteractiveDismiss = false
    
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
        guard let sourceViewController = sourceViewController, let destinationViewController = destinationViewController else {
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            return currentAnimator
        }
        
        transitionData = TransitionData(
            sourceViewController: sourceViewController,
            destinationViewController: destinationViewController,
            sourceFrame: sourceViewController.sourceViewFrame(relativeTo: transitionContext.containerView),
            destinationFrame: destinationViewController.animatableViewFrame(relativeTo: transitionContext.containerView)
        )
        transitionData?.sourceViewController.sourceView.alpha = 0
        currentAnimator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.8)
        if !isInteractive, let transitionData = transitionData {
            addAnimations(with: transitionData, on: currentAnimator, isDismissed: isDismissed, shouldConfigureInitialValue: true)
        }
        currentAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
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
        context.containerView.addSubview(destinationViewController.view)
        destinationViewController.view.frame = isDismissed ? context.initialFrame(for: destinationViewController) : context.finalFrame(for: destinationViewController)
    }
    
    func addAnimations(with data: TransitionData, on animator: UIViewPropertyAnimator, isDismissed: Bool, shouldConfigureInitialValue: Bool) {
        animateViewConstraint(with: data, on: animator, isDismissed: isDismissed, shouldConfigureInitialValue: shouldConfigureInitialValue)
        animateViewTransform(with: data, on: animator, isDismissed: isDismissed, shouldConfigureInitialValue: shouldConfigureInitialValue)
        configureSourceViewController(with: data, on: animator)
        configureDestinationViewController(with: data, on: animator, isDismissed: isDismissed, shouldConfigureInitialValue: shouldConfigureInitialValue)
    }
    
    func animateViewConstraint(with data: TransitionData, on animator: UIViewPropertyAnimator, isDismissed: Bool, shouldConfigureInitialValue: Bool) {
        let difference = data.sourceViewController.metadata.difference(sourceFrame: data.sourceFrame, destinationFrame: data.destinationFrame)
        
        if shouldConfigureInitialValue {
            data.destinationViewController.topAnimatableViewConstraint.constant = isDismissed ? 0 : difference.y
            data.destinationViewController.bottomAnimatableViewConstraint.constant = isDismissed ? 0 : difference.y
            data.destinationViewController.rightAnimatableViewConstraint.constant = isDismissed ? 0 : difference.x
            data.destinationViewController.leftAnimatableViewConstraint.constant = isDismissed ? 0 : difference.x
            data.destinationViewController.view.layoutIfNeeded()
        }
        
        animator.addAnimations {
            data.destinationViewController.topAnimatableViewConstraint.constant = isDismissed ? difference.y : 0
            data.destinationViewController.bottomAnimatableViewConstraint.constant = isDismissed ? difference.y : 0
            data.destinationViewController.rightAnimatableViewConstraint.constant = isDismissed ? difference.x : 0
            data.destinationViewController.leftAnimatableViewConstraint.constant = isDismissed ? difference.x : 0
            data.destinationViewController.view.layoutIfNeeded()
        }
    }
    
    func animateViewTransform(with data: TransitionData, on animator: UIViewPropertyAnimator, isDismissed: Bool, shouldConfigureInitialValue: Bool) {
        let displacement = data.sourceViewController.metadata.displacement(sourceFrame: data.sourceFrame, destinationFrame: data.destinationFrame)
        let scale = data.sourceViewController.metadata.scale(sourceFrame: data.sourceFrame, destinationFrame: data.destinationFrame)
        let startTransform = CGAffineTransform(translationX: displacement.x, y: displacement.y).scaledBy(x: scale, y: scale)
        let endTransform: CGAffineTransform = .identity
        
        if shouldConfigureInitialValue {
            data.destinationViewController.animatableView.transform = isDismissed ? endTransform : startTransform
        }
        animator.addAnimations {
            data.destinationViewController.animatableView.transform = isDismissed ? startTransform : endTransform
        }
    }
    
    func configureSourceViewController(with data: TransitionData, on animator: UIViewPropertyAnimator) {
        animator.addCompletion { _ in
            data.sourceViewController.sourceView.alpha = 1
        }
    }
    
    func configureDestinationViewController(with data: TransitionData, on animator: UIViewPropertyAnimator, isDismissed: Bool, shouldConfigureInitialValue: Bool) {
        if shouldConfigureInitialValue {
            data.destinationViewController.view.backgroundColor = isDismissed ? .white : .clear
        }
        animator.addAnimations {
            data.destinationViewController.view.backgroundColor = isDismissed ? .clear : .white
        }
    }
    
    @objc
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.translation(in: currentContext?.containerView)
        switch recognizer.state {
        case .began:
            interactiveDismissStartLocation = location
            isInteractive = true
            destinationViewController?.dismiss(animated: true)
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: transitionDuration, delay: 0, animations: {
                self.destinationViewController?.view.backgroundColor = .clear
            }, completion: nil)
        case .changed:
            updatePosition(for: location)
        case .ended, .cancelled:
            if let transitionData = transitionData, let currentContext = currentContext {
                if shouldCancelInteractiveDismiss {
                    let cancelAnimator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.8)
                    addAnimations(with: transitionData, on: cancelAnimator, isDismissed: false, shouldConfigureInitialValue: false)
                    cancelAnimator.addCompletion { _ in
                        currentContext.completeTransition(false)
                    }
                    cancelAnimator.startAnimation()
                } else {
                    addAnimations(with: transitionData, on: currentAnimator, isDismissed: true, shouldConfigureInitialValue: false)
                    finish()
                }
            }
            isInteractive = false
        default:
            break
        }
    }
    
    func updatePosition(for location: CGPoint) {
        var displacement = CGPoint(x: location.x - interactiveDismissStartLocation.x, y: location.y - interactiveDismissStartLocation.y)
        displacement.y = displacement.y < 0 ? displacement.y / 2 : displacement.y
        let scale = max(min(1 - 0.002 * interactiveDismissDisplacement.y, 1.2), 0.8) // solving linear equation to scale from 1 to 0.8 over 100 pt displacement
        let transform = CGAffineTransform(translationX: displacement.x, y: displacement.y).scaledBy(x: scale, y: scale)
        destinationViewController?.animatableView.transform = transform
        shouldCancelInteractiveDismiss = displacement.y < 0 || displacement.y < interactiveDismissDisplacement.y
        interactiveDismissDisplacement = displacement
    }
}

private struct TransitionData {
    let sourceViewController: UIViewController & GalleryTransitionSourceViewController
    let destinationViewController: UIViewController & GalleryTransitionDestinationViewController
    let sourceFrame: CGRect
    let destinationFrame: CGRect
}
