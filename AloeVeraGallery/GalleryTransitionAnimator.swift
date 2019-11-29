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
    private var interactiveDismissStartLocation: CGPoint = .zero
    
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
        let sourceFrame = sourceViewController.sourceViewFrame(relativeTo: transitionContext.containerView)
        let destinationFrame = destinationViewController.animatableViewFrame(relativeTo: transitionContext.containerView)
        currentAnimator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.8)
        animateViewConstraint(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
        animateViewTransform(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
        animateViewBackground()
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
    
    func animateViewConstraint(sourceFrame: CGRect, destinationFrame: CGRect) {
        guard let sourceViewController = sourceViewController, let destinationViewController = destinationViewController else {
            return
        }
        
        let difference = sourceViewController.metadata.difference(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
        
        destinationViewController.topAnimatableViewConstraint.constant = isDismissed ? 0 : difference.halfVertical
        destinationViewController.bottomAnimatableViewConstraint.constant = isDismissed ? 0 : difference.halfVertical
        destinationViewController.rightAnimatableViewConstraint.constant = isDismissed ? 0 : difference.halfHorizontal
        destinationViewController.leftAnimatableViewConstraint.constant = isDismissed ? 0 : difference.halfHorizontal
        destinationViewController.view.layoutIfNeeded()
        
        currentAnimator.addAnimations {
            destinationViewController.topAnimatableViewConstraint.constant = self.isDismissed ? difference.halfVertical : 0
            destinationViewController.bottomAnimatableViewConstraint.constant = self.isDismissed ? difference.halfVertical : 0
            destinationViewController.rightAnimatableViewConstraint.constant = self.isDismissed ? difference.halfHorizontal : 0
            destinationViewController.leftAnimatableViewConstraint.constant = self.isDismissed ? difference.halfHorizontal : 0
            destinationViewController.view.layoutIfNeeded()
        }
    }
    
    func animateViewTransform(sourceFrame: CGRect, destinationFrame: CGRect) {
        guard let sourceViewController = sourceViewController, let destinationViewController = destinationViewController else {
            return
        }
        
        let displacement = sourceViewController.metadata.displacement(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
        let scale = sourceViewController.metadata.scale(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
        
        let startSourceTransform: CGAffineTransform = .identity
        let startDestinationTransform = CGAffineTransform(translationX: displacement.destinationHorizontal, y: displacement.destinationVertical).scaledBy(x: scale.destination, y: scale.destination)
        
        let endSourceTransform = CGAffineTransform(translationX: displacement.sourceHorizontal, y: displacement.sourceVertical).scaledBy(x: scale.source, y: scale.source)
        let endDestinationTransform: CGAffineTransform = .identity
        
        sourceViewController.sourceView.transform = isDismissed ? endSourceTransform : startSourceTransform
        destinationViewController.animatableView.transform = isDismissed ? endDestinationTransform : startDestinationTransform
        currentAnimator.addAnimations {
            sourceViewController.sourceView.transform = self.isDismissed ? startSourceTransform : endSourceTransform
            destinationViewController.animatableView.transform = self.isDismissed ? startDestinationTransform : endDestinationTransform
        }
        currentAnimator.addCompletion { _ in
            sourceViewController.sourceView.transform = .identity
        }
    }
    
    func animateViewBackground() {
        destinationViewController?.view.backgroundColor = isDismissed ? .white : .clear
        currentAnimator.addAnimations {
            self.destinationViewController?.view.backgroundColor = self.isDismissed ? .clear : .white
        }
    }
    
    @objc
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        guard let recognizerView = recognizer.view?.superview else {
            return
        }
        
        let location = recognizer.translation(in: currentContext?.containerView)
        
        let translation = recognizer.translation(in: recognizerView)
        var progress = abs(translation.y / 200.0)
        progress = min(max(progress, 0.001), 0.999)
        
        switch recognizer.state {
        case .began:
            interactiveDismissStartLocation = location
            isInteractive = true
            destinationViewController?.dismiss(animated: true)
        case .changed:
//            updatePosition(for: location)
            
            update(progress)
        case .ended, .cancelled:
//            if progress < 0.5 {
//                cancel()
//            } else {
                finish()
//            }
            isInteractive = false
        default:
            break
        }
    }
    
    func updatePosition(for location: CGPoint) {
        let displacement = CGPoint(x: location.x - interactiveDismissStartLocation.x, y: location.y - interactiveDismissStartLocation.y)
        print("displacement: \(displacement)")
        print(currentAnimator.isRunning)
        destinationViewController?.animatableView.transform = CGAffineTransform(translationX: displacement.x, y: displacement.y)
        sourceViewController?.sourceView.transform = CGAffineTransform(translationX: displacement.x, y: displacement.y)
    }
}
