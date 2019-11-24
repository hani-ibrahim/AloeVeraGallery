//
//  GalleryTransitionAnimator.swift
//  AloeVeraGallery
//
//  Created by Hani on 16.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public enum GalleryCropMode {
    case verticalCrop
    case horizontalCrop
    case none
}

public protocol GalleryTransitionSourceViewController {
    var sourceView: UIView { get }
    var sourceCropMode: GalleryCropMode { get }
    func sourceViewFrame(relativeTo view: UIView) -> CGRect
}

public protocol GalleryTransitionDestinationViewController {
    var animatableView: UIView! { get }
    var topAnimatableViewConstraint: NSLayoutConstraint! { get }
    var bottomAnimatableViewConstraint: NSLayoutConstraint! { get }
    var rightAnimatableViewConstraint: NSLayoutConstraint! { get }
    var leftAnimatableViewConstraint: NSLayoutConstraint! { get }
    func animatableViewFrame(relativeTo view: UIView) -> CGRect
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
        guard let sourceViewController = sourceViewController, let destinationViewController = destinationViewController else {
            completeTransition(with: transitionContext)
            return currentAnimator
        }
        let sourceFrame = sourceViewController.sourceViewFrame(relativeTo: transitionContext.containerView)
        let destinationFrame = destinationViewController.animatableViewFrame(relativeTo: transitionContext.containerView)
        currentAnimator = UIViewPropertyAnimator(duration: transitionDuration, dampingRatio: 0.8)
        animateViewConstraint(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
        animateViewTransform(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
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
    
    func animateViewConstraint(sourceFrame: CGRect, destinationFrame: CGRect) {
        guard let sourceViewController = sourceViewController, let destinationViewController = destinationViewController else {
            return
        }
        
        let startVerticalConstraint = (destinationFrame.size.height - sourceFrame.size.height) / 2
        let startHorizontalConstraint = (destinationFrame.size.width - sourceFrame.size.width) / 2
        
        let endVerticalConstraint: CGFloat = 0
        let endHorizontalConstraint: CGFloat = 0
        
        switch sourceViewController.sourceCropMode {
        case .verticalCrop:
            destinationViewController.topAnimatableViewConstraint.constant = isDismissed ? endVerticalConstraint : startVerticalConstraint
            destinationViewController.bottomAnimatableViewConstraint.constant = isDismissed ? endVerticalConstraint : startVerticalConstraint
        case .horizontalCrop:
            destinationViewController.rightAnimatableViewConstraint.constant = isDismissed ? endHorizontalConstraint : startHorizontalConstraint
            destinationViewController.leftAnimatableViewConstraint.constant = isDismissed ? endHorizontalConstraint : startHorizontalConstraint
        case .none:
            break
        }
        destinationViewController.view.layoutIfNeeded()
        
        currentAnimator.addAnimations {
            switch sourceViewController.sourceCropMode {
            case .verticalCrop:
                destinationViewController.topAnimatableViewConstraint.constant = self.isDismissed ? startVerticalConstraint : endVerticalConstraint
                destinationViewController.bottomAnimatableViewConstraint.constant = self.isDismissed ? startVerticalConstraint: endVerticalConstraint
            case .horizontalCrop:
                destinationViewController.rightAnimatableViewConstraint.constant = self.isDismissed ? startHorizontalConstraint : endHorizontalConstraint
                destinationViewController.leftAnimatableViewConstraint.constant = self.isDismissed ? startHorizontalConstraint : endHorizontalConstraint
            case .none:
                break
            }
            destinationViewController.view.layoutIfNeeded()
        }
    }
    
    func animateViewTransform(sourceFrame: CGRect, destinationFrame: CGRect) {
        guard let sourceViewController = sourceViewController, let destinationViewController = destinationViewController else {
            return
        }
        
        let xDisplacement = sourceFrame.midX - destinationFrame.midX
        let yDisplacement = sourceFrame.midY - destinationFrame.midY
        
        let scale: CGFloat
        switch sourceViewController.sourceCropMode {
        case .verticalCrop:
            scale = sourceFrame.size.width / destinationFrame.size.width
        case .horizontalCrop:
            scale = sourceFrame.size.height / destinationFrame.size.height
        case .none:
            scale = 1
        }
        
        let startSourceTransform: CGAffineTransform = .identity
        let startDestinationTransform = CGAffineTransform(translationX: xDisplacement, y: yDisplacement)//.scaledBy(x: scale, y: scale)
        
        let endSourceTransform = CGAffineTransform(translationX: -xDisplacement, y: -yDisplacement)//.scaledBy(x: 1 / scale, y: 1 / scale)
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
    
    func animateBackground() {
        destinationViewController?.view.backgroundColor = isDismissed ? .white : .clear
        currentAnimator.addAnimations {
            self.destinationViewController?.view.backgroundColor = self.isDismissed ? .clear : .white
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
        progress = min(max(progress, 0.001), 0.999)
        
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
