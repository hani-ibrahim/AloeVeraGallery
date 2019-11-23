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
}

open class GalleryViewController: UIViewController {
    
    public static func makeViewController() -> GalleryViewController {
        GalleryViewController(nibName: nil, bundle: Bundle(for: GalleryViewController.self))
    }
    
    @IBOutlet public private(set) var pagedCollectionView: PagedCollectionView!
    @IBOutlet public private(set) var closeButton: UIButton!
    @IBOutlet public private(set) var pageControl: UIPageControl!
    
    public weak var delegate: GalleryDelegate?
    public var pageSpacing: CGFloat = 0
    public var startingIndexPath: IndexPath?
    public var sections: [SectionConfiguring] = []
    
    private lazy var dataSource = CollectionViewDataSource(sections: sections)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        print("GalleryViewController - viewWillAppear")
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        print("GalleryViewController - viewDidAppear")
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        print("GalleryViewController - viewWillDisappear")
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
    
    private func scrollingStopping(at contentOffset: CGPoint, didEndScrollingAnimation: Bool) {
        let bounds = CGRect(origin: contentOffset, size: pagedCollectionView.bounds.size)
        guard let currentIndexPath = pagedCollectionView.collectionViewLayout.centeredItemIndexPath(in: bounds) else {
            return
        }
        pageControl.currentPage = dataSource.absoluteIndex(forItemAt: currentIndexPath)
        if didEndScrollingAnimation {
            delegate?.gallery(galleryViewController: self, didScrollToItemAt: currentIndexPath)
        }
    }
}

extension GalleryViewController: GalleryTransitionDestinationViewController {
    
}

private extension GalleryViewController {
    func setupView() {
        setupPageControl()
        setupCollectionView()
        setupStartingIndexPath()
        setupPanGesture()
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
    
    func setupPanGesture() {
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        view.addGestureRecognizer(recognizer)
    }
    
    @objc
    func panGestureRecognized(recognizer: UIPanGestureRecognizer) {
        let animator = (transitioningDelegate as? GalleryTransitionDelegate)?.transitionAnimator
        switch recognizer.state {
        case .began:
            animator?.isInteractive = true
            dismiss(animated: true)
        default:
            animator?.handlePanGesture(by: recognizer)
        }
    }
}
