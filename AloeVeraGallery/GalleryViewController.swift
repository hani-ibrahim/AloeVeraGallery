//
//  GalleryViewController.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraPagedCollectionView
import UIKit

public protocol GalleryDelegate: AnyObject {
    func gallery(galleryViewController: GalleryViewController, didScrollToItemAt indexPath: IndexPath)
    func didClose(galleryViewController: GalleryViewController)
}

open class GalleryViewController: UIViewController {
    
    public static func makeViewController() -> GalleryViewController {
        GalleryViewController(nibName: nil, bundle: Bundle(for: GalleryViewController.self))
    }
    
    @IBOutlet public private(set) var pagedCollectionView: PagedCollectionView!
    @IBOutlet public private(set) var closeButton: UIButton!
    @IBOutlet public private(set) var pageControl: UIPageControl!
    
    @IBOutlet public private(set) var animatableView: UIView!
    @IBOutlet public private(set) var topAnimatableViewConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) var bottomAnimatableViewConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) var rightAnimatableViewConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) var leftAnimatableViewConstraint: NSLayoutConstraint!
    
    public weak var delegate: GalleryDelegate?
    public var pageSpacing: CGFloat = 0
    public var startingIndexPath: IndexPath?
    public var sections: [SectionConfiguring] = []
    
    private lazy var dataSource = CollectionViewDataSource(sections: sections)
    private let viewContentAnimationDuration: TimeInterval = 0.2
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        hideViewContent(animated: false)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showViewContent()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideViewContent(animated: true)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delegate?.didClose(galleryViewController: self)
    }
    
    @IBAction private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollingStopping(at: targetContentOffset.pointee, didEndScrollingAnimation: false)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingStopping(at: scrollView.bounds.origin, didEndScrollingAnimation: true)
        }
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingStopping(at: scrollView.bounds.origin, didEndScrollingAnimation: true)
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollingStopping(at: scrollView.bounds.origin, didEndScrollingAnimation: true)
    }
}

extension GalleryViewController: GalleryTransitionDestinationViewController {
    public func animatableViewFrame(relativeTo containerView: UIView) -> CGRect {
        view.bounds
    }
}

private extension GalleryViewController {
    func setupView() {
        setupPageControl()
        setupCollectionView()
        setupStartingIndexPath()
    }
    
    func setupPageControl() {
        pageControl.numberOfPages = dataSource.totalNumberOfItems
        pageControl.currentPage = 0
    }
    
    func setupCollectionView() {
        pagedCollectionView.collectionViewLayout.pageSpacing = pageSpacing
        pagedCollectionView.collectionViewLayout.shouldRespectAdjustedContentInset = false
        pagedCollectionView.collectionView.showsHorizontalScrollIndicator = false
        pagedCollectionView.collectionView.dataSource = dataSource
        pagedCollectionView.collectionView.delegate = self
        dataSource.registerCells(in: pagedCollectionView.collectionView)
        pagedCollectionView.configure()
    }
    
    func setupStartingIndexPath() {
        guard let indexPath = startingIndexPath else {
            return
        }
        pagedCollectionView.updateIndexPathForNextViewLayout(with: indexPath)
        pageControl.currentPage = dataSource.absoluteIndex(forItemAt: indexPath)
    }
    
    func scrollingStopping(at contentOffset: CGPoint, didEndScrollingAnimation: Bool) {
        let bounds = CGRect(origin: contentOffset, size: pagedCollectionView.bounds.size)
        guard let currentIndexPath = pagedCollectionView.collectionViewLayout.centeredItemIndexPath(in: bounds) else {
            return
        }
        pageControl.currentPage = dataSource.absoluteIndex(forItemAt: currentIndexPath)
        if didEndScrollingAnimation {
            delegate?.gallery(galleryViewController: self, didScrollToItemAt: currentIndexPath)
        }
    }
    
    func showViewContent() {
        UIViewPropertyAnimator(duration: viewContentAnimationDuration, dampingRatio: 0.5) {
//            self.view.backgroundColor = .white
            self.closeButton.transform = .identity
            self.closeButton.alpha = 1
            self.pageControl.alpha = 1
        }.startAnimation()
    }
    
    func hideViewContent(animated: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animated ? viewContentAnimationDuration : 0, delay: 0, animations: {
//            self.view.backgroundColor = .clear
            self.closeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.closeButton.alpha = 0
            self.pageControl.alpha = 0
        }, completion: nil)
    }
}
