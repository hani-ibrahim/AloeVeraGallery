//
//  GalleryViewController.swift
//  AloeVeraGallery
//
//  Created by Hani on 09.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import AloeVeraPagedCollectionView
import UIKit

/// Possible ways for the user to close the gallery
public enum CloseSource {
    case closeButton
    case dragging
}

/// Delegate for `GalleryViewController` to know if the user scroll the gallery or how the user closed it
public protocol GalleryDelegate: AnyObject {
    func gallery(galleryViewController: GalleryViewController, didScrollToItemAt indexPath: IndexPath)
    func didClose(galleryViewController: GalleryViewController, source: CloseSource)
}

/// GalleryViewController can be displayed by two ways
/// 1- As a normal view controller that can displayed modaly or in a navigation controller
/// 2-  By a custom gallery transition using `GalleryTransitionDelegate`, for that to work properly please configure `modalPresentationStyle` to be `.overFullScreen`
open class GalleryViewController: UIViewController, GalleryTransitionDestination {
    
    /// Handy function to initialize a new instance of the view controller
    public static func makeViewController() -> GalleryViewController {
        GalleryViewController(nibName: nil, bundle: Bundle(for: GalleryViewController.self))
    }
    
    @IBOutlet public private(set) var collectionView: PagedCollectionView!
    @IBOutlet public private(set) var closeButton: UIButton!
    @IBOutlet public private(set) var pageControl: UIPageControl!
    
    @IBOutlet public private(set) var animatableView: UIView!
    @IBOutlet public private(set) var topAnimatableViewConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) var bottomAnimatableViewConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) var rightAnimatableViewConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) var leftAnimatableViewConstraint: NSLayoutConstraint!
    
    @IBOutlet public private(set) var closeButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet public private(set) var closeButtonTrailingConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pageControlBottomConstraint: NSLayoutConstraint!
    
    /// The `delegate` of the gallery view controller to know how the user interact with the gallery
    public weak var delegate: GalleryDelegate?
    /// The spacing between the cells in the gallery, should be configured before `viewDidLoad` is being called
    public var pageSpacing: CGFloat = 0
    /// The starting index to open the gallery at, should be configured before `viewDidLoad` is being called
    public var startingIndexPath: IndexPath?
    /// The sections that are used by the data source to display content in the collection, should be configured before `viewDidLoad` is being called
    public var sections: [SectionConfiguring] = []
    
    private var didTapCloseButton = false
    private let viewContentAnimationDuration: TimeInterval = 0.2
    private lazy var dataSource = DataSource(sections: sections)
    private lazy var scrollingHandler = ScrollingHandler(collectionView: collectionView) { [weak self] indexPath, didEndScrolling in
        guard let self = self else {
            return
        }
        self.pageControl.currentPage = self.dataSource.absoluteIndex(forItemAt: indexPath)
        if didEndScrolling {
            self.delegate?.gallery(galleryViewController: self, didScrollToItemAt: indexPath)
        }
    }
    
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
        delegate?.didClose(galleryViewController: self, source: didTapCloseButton ? .closeButton : .dragging)
    }
    
    @IBAction private func closeButtonPressed() {
        didTapCloseButton = true
        dismiss(animated: true)
    }
    
    @IBAction func pageControlValueChanged(sender: UIPageControl) {
        guard let indexPath = dataSource.indexPath(forAbsoluteIndex: sender.currentPage) else {
            return
        }
        collectionView.scrollToItem(at: indexPath, animated: true)
        delegate?.gallery(galleryViewController: self, didScrollToItemAt: indexPath)
    }
}

extension GalleryViewController: UICollectionViewDelegate {
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollingHandler.scrollViewWillEndDragging(targetContentOffset: targetContentOffset)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollingHandler.scrollViewDidEndDragging(willDecelerate: decelerate)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollingHandler.scrollViewDidEndDecelerating()
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollingHandler.scrollViewDidEndScrollingAnimation()
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
        collectionView.collectionViewLayout.pageSpacing = pageSpacing
        collectionView.collectionViewLayout.shouldRespectAdjustedContentInset = false
        collectionView.collectionView.showsHorizontalScrollIndicator = false
        collectionView.collectionView.dataSource = dataSource
        collectionView.collectionView.delegate = self
        dataSource.registerCells(in: collectionView.collectionView)
        collectionView.configure()
    }
    
    func setupStartingIndexPath() {
        guard let indexPath = startingIndexPath else {
            return
        }
        collectionView.updateIndexPathForNextViewLayout(with: indexPath)
        pageControl.currentPage = dataSource.absoluteIndex(forItemAt: indexPath)
    }
    
    func showViewContent() {
        UIViewPropertyAnimator(duration: viewContentAnimationDuration, dampingRatio: 0.5) {
            self.closeButton.transform = .identity
            self.closeButton.alpha = 1
            self.pageControl.alpha = 1
        }.startAnimation()
    }
    
    func hideViewContent(animated: Bool) {
        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: animated ? viewContentAnimationDuration : 0, delay: 0, animations: {
            self.closeButton.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            self.closeButton.alpha = 0
            self.pageControl.alpha = 0
        }, completion: nil)
    }
}
