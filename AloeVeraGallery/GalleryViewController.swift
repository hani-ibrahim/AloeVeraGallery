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
    
    @IBOutlet public private(set) var pagedCollectionView: PagedCollectionView!
    @IBOutlet public private(set) var closeButton: UIButton!
    @IBOutlet public private(set) var pageControl: UIPageControl!
    
    public weak var delegate: GalleryDelegate?
    
    private let dataSource: CollectionViewDataSource
    private let pageSpacing: CGFloat
    private let startIndexPath: IndexPath?
    
    public init(sections: [SectionConfiguring], pageSpacing: CGFloat, startIndexPath: IndexPath?) {
        self.dataSource = CollectionViewDataSource(sections: sections)
        self.pageSpacing = pageSpacing
        self.startIndexPath = startIndexPath
        super.init(nibName: nil, bundle: Bundle(for: GalleryViewController.self))
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError("Please use init(sections:pageSpacing:startIndex) function to initialize GalleryViewController")
    }
    
    public required init?(coder: NSCoder) {
        fatalError("Please use init(sections:pageSpacing:startIndex) function to initialize GalleryViewController")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        collectionViewLayout.collectionViewSizeWillChange()
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
    var collectionView: UICollectionView {
        pagedCollectionView.collectionView
    }
    
    var collectionViewLayout: PagedCollectionViewFlowLayout {
        pagedCollectionView.collectionViewLayout
    }
    
    func setupView() {
        pageControl.numberOfPages = dataSource.totalNumberOfItems
        collectionViewLayout.initialIndexPath = startIndexPath
        collectionViewLayout.scrollDirection = .horizontal
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        dataSource.registerCells(in: collectionView)
        pagedCollectionView.pageSpacing = pageSpacing
        if let startIndexPath = startIndexPath {
            pageControl.currentPage = dataSource.absoluteIndex(forItemAt: startIndexPath)
        }
    }
    
    func scrollingStopped() {
        guard let currentIndexPath = collectionViewLayout.centeredItemLocator.locateCenteredItem(in: collectionView, bounds: collectionView.bounds) else {
            return
        }
        delegate?.gallery(galleryViewController: self, didScrollToItemAt: currentIndexPath)
        pageControl.currentPage = dataSource.absoluteIndex(forItemAt: currentIndexPath)
    }
}
