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
    public var startIndexPath: IndexPath?
    public var sections: [SectionConfiguring] = []
    
    private lazy var dataSource = CollectionViewDataSource(sections: sections)
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let startIndexPath = startIndexPath {
            pagedCollectionView.collectionViewLayout.scrollToItem(at: startIndexPath)
        }
    }
    
    @IBAction private func closeButtonPressed() {
        dismiss(animated: true)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            scrollingStopped()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingStopped()
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollingStopped()
    }
}

private extension GalleryViewController {
    func setupView() {
        setupPageControl()
        setupCollectionView()
    }
    
    func scrollingStopped() {
        guard let currentIndexPath = pagedCollectionView.collectionViewLayout.centeredItemIndexPath(in: pagedCollectionView.collectionView.bounds) else {
            return
        }
        delegate?.gallery(galleryViewController: self, didScrollToItemAt: currentIndexPath)
        pageControl.currentPage = dataSource.absoluteIndex(forItemAt: currentIndexPath)
    }
    
    func setupPageControl() {
        pageControl.numberOfPages = dataSource.totalNumberOfItems
        if let startIndexPath = startIndexPath {
            pageControl.currentPage = dataSource.absoluteIndex(forItemAt: startIndexPath)
        } else {
            pageControl.currentPage = 0
        }
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
}
