//
//  GalleryZoomingDelegate.swift
//  AloeVeraGallery
//
//  Created by Hani on 04.12.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

final class GalleryZoomingDelegate: NSObject {
    
    private weak var zoomableScrollView: UIScrollView?
    private weak var contentScrollView: UIScrollView?
    private weak var contentView: UIView?
    
    private var isZooming = false
    private let edgeThreshold: CGFloat = 50
    
    init(zoomableScrollView: UIScrollView, contentScrollView: UIScrollView, contentView: UIView) {
        self.zoomableScrollView = zoomableScrollView
        self.contentScrollView = contentScrollView
        self.contentView = contentView
        super.init()
        configureGestures()
    }
}

private extension GalleryZoomingDelegate {
    func configureGestures() {
        guard zoomableScrollView?.maximumZoomScale != 1 else {
            return
        }
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        zoomableScrollView?.addGestureRecognizer(doubleTapGesture)
    }
    
    @objc func didDoubleTap() {
        guard let zoomableScrollView = zoomableScrollView else {
            return
        }
        let zoomScale = zoomableScrollView.zoomScale == 1 ? zoomableScrollView.maximumZoomScale : 1
        zoomableScrollView.setZoomScale(zoomScale, animated: true)
    }
}

extension GalleryZoomingDelegate: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        contentView
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        isZooming = false
        contentScrollView?.isUserInteractionEnabled = scale == 1
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let contentScrollView = contentScrollView, !isZooming else {
            return
        }
        if scrollView.bounds.minX < -edgeThreshold {
            scrollView.setZoomScale(1, animated: true)
            contentScrollView.isUserInteractionEnabled = true
            let newOffset = max(0, contentScrollView.bounds.origin.x - contentScrollView.bounds.size.width)
            print("1: newOffset: \(newOffset), contentScrollView.bounds: \(contentScrollView.bounds)")
            DispatchQueue.main.async {
                contentScrollView.setContentOffset(CGPoint(x: newOffset, y: contentScrollView.contentOffset.y), animated: false)
            }
            
        } else if scrollView.bounds.maxX > scrollView.zoomScale * scrollView.bounds.size.width + edgeThreshold {
            scrollView.setZoomScale(1, animated: true)
            contentScrollView.isUserInteractionEnabled = true
            let newOffset = min(contentScrollView.contentSize.width - contentScrollView.bounds.size.width, contentScrollView.bounds.origin.x + contentScrollView.bounds.size.width)
            print("2: newOffset: \(newOffset), contentScrollView.bounds: \(contentScrollView.bounds)")
            DispatchQueue.main.async {
                contentScrollView.setContentOffset(CGPoint(x: newOffset, y: contentScrollView.contentOffset.y), animated: false)
            }
        }
    }
}
