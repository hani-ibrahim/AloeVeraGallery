//
//  ScrollingHandler.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 01.12.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public typealias ScrollingHandlerDidScroll = (_ indexPath: IndexPath, _ didEndScrolling: Bool) -> Void

/// Helper class to get the current page
public final class ScrollingHandler {
    
    private weak var pagedCollectionView: PagedCollectionView?
    private let didScroll: ScrollingHandlerDidScroll?
    
    public init(collectionView: PagedCollectionView, didScroll: @escaping ScrollingHandlerDidScroll) {
        self.pagedCollectionView = collectionView
        self.didScroll = didScroll
    }
    
    public func scrollViewWillEndDragging(targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollingStopping(at: targetContentOffset.pointee, didEndScrollingAnimation: false)
    }
    
    public func scrollViewDidEndDragging(willDecelerate decelerate: Bool) {
        guard let collectionView = pagedCollectionView?.collectionView else {
            return
        }
        if !decelerate {
            scrollingStopping(at: collectionView.bounds.origin, didEndScrollingAnimation: true)
        }
    }
    
    public func scrollViewDidEndDecelerating() {
        guard let collectionView = pagedCollectionView?.collectionView else {
            return
        }
        scrollingStopping(at: collectionView.bounds.origin, didEndScrollingAnimation: true)
    }
    
    public func scrollViewDidEndScrollingAnimation() {
        guard let collectionView = pagedCollectionView?.collectionView else {
            return
        }
        scrollingStopping(at: collectionView.bounds.origin, didEndScrollingAnimation: true)
    }
}

private extension ScrollingHandler {
    func scrollingStopping(at contentOffset: CGPoint, didEndScrollingAnimation: Bool) {
        guard let collectionView = pagedCollectionView?.collectionView else {
            return
        }
        let bounds = CGRect(origin: contentOffset, size: collectionView.bounds.size)
        guard let currentIndexPath = pagedCollectionView?.collectionViewLayout.centeredItemIndexPath(in: bounds) else {
            return
        }
        didScroll?(currentIndexPath, didEndScrollingAnimation)
    }
}
