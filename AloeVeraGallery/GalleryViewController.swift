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
    
    @IBAction private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollingStopping(at: targetContentOffset.pointee, didEndScrollingAnimation: false)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingStopping(at: scrollView.bounds.origin, didEndScrollingAnimation: true)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingStopping(at: scrollView.bounds.origin, didEndScrollingAnimation: true)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollingStopping(at: scrollView.bounds.origin, didEndScrollingAnimation: true)
    }
}

private extension GalleryViewController {
    func setupView() {
        setupPageControl()
        setupCollectionView()
        setupStartingIndexPath()
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
}
