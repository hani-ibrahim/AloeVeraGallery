//
//  PagedCollectionViewLayout.swift
//  AloeVeraPagedCollectionView
//
//  Created by Hani on 10.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// Arrange the items to be displayed in full collection view size and adjust its size during rotation
open class PagedCollectionViewLayout: UICollectionViewLayout, CenteredItemLocating {
    
    /// Spacing between the pages that is only visible during scrolling
    open var pageSpacing: CGFloat = 0
    
    /// The insets for each individual page
    open var pageInset: UIEdgeInsets = .zero
    
    /// Insets for the collection view area that is not visible, helpful when the collection view size is bigger than its superview
    /// Used to enable paging support with spaces between pages
    open var collectionViewInset: UIEdgeInsets = .zero
    
    /// When set to `false` -> the items will fill the whole available space
    open var shouldRespectAdjustedContentInset = true
    
    /// The direction of scrolling `horizontal` or `vertical`
    open var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    
    open weak var centeredItemLocatingDelegate: CenteredItemLocatingDelegate?
    
    private var properties: Properties = .empty
    private var cache: Cache = .empty
    
    open override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        
        properties = properties(for: collectionView, bounds: collectionView.bounds)
        cache = cache(for: collectionView, collectionViewSize: collectionView.bounds.size, with: properties)
    }
    
    open override func prepare(forAnimatedBoundsChange oldBounds: CGRect) {
        super.prepare(forAnimatedBoundsChange: oldBounds)
        if let centeredItemIndexPath = centeredItemIndexPath(in: oldBounds) {
            scrollToItem(at: centeredItemIndexPath)
        }
    }
    
    open override var collectionViewContentSize: CGSize {
        cache.contentSize
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.attributes.values.filter { $0.frame.intersects(rect) }
    }
    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache.attributes[indexPath]
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        newBounds.size != cache.collectionViewSize
    }
    
    open override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        nil
    }
    
    open override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache.attributes[itemIndexPath]
    }
    
    /// Calculate the centered item in the given bounds
    open func centeredItemIndexPath(in bounds: CGRect) -> IndexPath? {
        guard let collectionView = collectionView else {
            return nil
        }
        
        let properties = self.properties(for: collectionView, bounds: bounds)
        let cache = self.cache(for: collectionView, collectionViewSize: bounds.size, with: properties)
        let items = cache.attributes.values.map { ItemLocation(indexPath: $0.indexPath, center: $0.center) }
        let contentCenter = CGPoint(x: bounds.midX, y: bounds.midY)
        return locateCenteredItem(near: contentCenter, from: items)
    }
    
    /// Scroll the collection view to the given index
    open func scrollToItem(at indexPath: IndexPath) {
        guard let collectionView = collectionView else {
            return
        }
        
        if collectionView.bounds.size != cache.collectionViewSize {
            prepare()
        }
        
        guard let layoutAttributes = cache.attributes[indexPath] else {
            return
        }
        
        let viewableAreaCenter = CGPoint(x: collectionView.bounds.size.width / 2, y: collectionView.bounds.size.height / 2)
        let offset = contentOffset(
            forItemAtPosition: layoutAttributes.center,
            toBeCenteredIn: collectionView.bounds.size,
            near: viewableAreaCenter,
            within: .zero,
            contentSize: cache.contentSize
        )
        scrollToItem(in: collectionView, to: offset)
    }
}

private extension PagedCollectionViewLayout {
    struct Properties {
        static let empty = Properties(itemSize: .zero, itemSpacing: 0, contentInset: .zero)
        
        let itemSize: CGSize
        let itemSpacing: CGFloat
        let contentInset: UIEdgeInsets
    }
    
    struct Cache {
        static let empty = Cache(collectionViewSize: .zero, attributes: [:], contentSize: .zero)
        
        let collectionViewSize: CGSize
        let attributes: [IndexPath: UICollectionViewLayoutAttributes]
        let contentSize: CGSize
    }
}

private extension PagedCollectionViewLayout {
    func properties(for collectionView: UICollectionView, bounds: CGRect) -> Properties {
        let adjustedContentInset = collectionView.adjustedContentInset(shouldRespect: shouldRespectAdjustedContentInset)
        let contentInset = UIEdgeInsets(
            top: adjustedContentInset.top + pageInset.top + collectionViewInset.top,
            left: adjustedContentInset.left + pageInset.left + collectionViewInset.left,
            bottom: adjustedContentInset.bottom + pageInset.bottom + collectionViewInset.bottom,
            right: adjustedContentInset.right + pageInset.right + collectionViewInset.right
        )
        
        let itemSize = bounds.inset(by: contentInset).size
        let itemSpacing: CGFloat
        if scrollDirection == .horizontal {
            itemSpacing = bounds.size.width - itemSize.width + pageSpacing - collectionViewInset.right - collectionViewInset.left
        } else {
            itemSpacing = bounds.size.height - itemSize.height + pageSpacing - collectionViewInset.top - collectionViewInset.bottom
        }
        
        return Properties(itemSize: itemSize, itemSpacing: itemSpacing, contentInset: contentInset)
    }
    
    func cache(for collectionView: UICollectionView, collectionViewSize: CGSize, with properties: Properties) -> Cache {
        guard let dataSource = collectionView.dataSource else {
            return .empty
        }
        
        let numberOfSections = dataSource.numberOfSections?(in: collectionView) ?? 1
        var attributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
        (0 ..< numberOfSections).forEach { section in
            let numberOfItems = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
            (0 ..< numberOfItems).forEach { item in
                let indexPath = IndexPath(item: item, section: section)
                let itemAttributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                itemAttributes.frame = properties.frame(forItemAtAbsoluteIndex: attributes.count, scrollDirection: scrollDirection)
                attributes[indexPath] = itemAttributes
            }
        }
        
        let contentSize = properties.contentSize(forCollectionViewSize: collectionViewSize, numberOfItems: attributes.count, scrollDirection: scrollDirection)
        return Cache(collectionViewSize: collectionViewSize, attributes: attributes, contentSize: contentSize)
    }
}

private extension UICollectionView {
    func adjustedContentInset(shouldRespect: Bool) -> UIEdgeInsets {
        if contentInset != .zero {
            print("PagedCollectionViewLayout: Neglecting (UICollectionView.contentInset) of value equals to (\(contentInset)), please use (pageInset & pageSpacing & collectionViewInset) instead.")
            contentInset = .zero
        }
        
        contentInsetAdjustmentBehavior = .automatic
        let finalAdjustedContentInset = shouldRespect ? adjustedContentInset : .zero
        contentInsetAdjustmentBehavior = .never
        return finalAdjustedContentInset
    }
}

private extension PagedCollectionViewLayout.Properties {
    func frame(forItemAtAbsoluteIndex index: Int, scrollDirection: UICollectionView.ScrollDirection) -> CGRect {
        let origin: CGPoint
        if scrollDirection == .horizontal {
            origin = CGPoint(
                x: contentInset.left + CGFloat(index) * (itemSize.width + itemSpacing),
                y: contentInset.top
            )
        } else {
            origin = CGPoint(
                x: contentInset.left,
                y: contentInset.top + CGFloat(index) * (itemSize.height + itemSpacing)
            )
        }
        return CGRect(origin: origin, size: itemSize)
    }
    
    func contentSize(forCollectionViewSize collectionViewSize: CGSize, numberOfItems: Int, scrollDirection: UICollectionView.ScrollDirection) -> CGSize {
        if scrollDirection == .horizontal {
            return CGSize(
                width: CGFloat(numberOfItems) * (itemSize.width + itemSpacing) - itemSpacing + contentInset.right + contentInset.left,
                height: collectionViewSize.height
            )
        } else {
            return CGSize(
                width: collectionViewSize.width,
                height: CGFloat(numberOfItems) * (itemSize.height + itemSpacing) - itemSpacing + contentInset.top + contentInset.bottom
            )
        }
    }
}
