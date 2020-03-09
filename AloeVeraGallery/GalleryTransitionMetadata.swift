//
//  GalleryTransitionMetadata.swift
//  AloeVeraGallery
//
//  Created by Hani on 24.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

/// The meta data required to have a custom transition
public struct GalleryTransitionMetadata {
    private let contentAspectRatio: CGFloat
    private let sourceFillMode: GalleryFillMode
    private let destinationFillMode: GalleryFillMode
    
    /// The init function of `GalleryTransitionMetadata`
    /// - Parameters:
    ///   - contentAspectRatio: The aspect ratio of the content in both the source and destination ... if the content is an image, then this would be the aspect ratio of the image
    ///   - sourceFillMode: fill mode of the source
    ///   - destinationFillMode: fill mode of the destination
    public init(contentAspectRatio: CGFloat, sourceFillMode: GalleryFillMode, destinationFillMode: GalleryFillMode) {
        self.contentAspectRatio = contentAspectRatio
        self.sourceFillMode = sourceFillMode
        self.destinationFillMode = destinationFillMode
    }
}

extension GalleryTransitionMetadata {
    func difference(sourceFrame: CGRect, destinationFrame: CGRect) -> CGPoint {
        let sourcePadding = padding(in: sourceFrame, fillMode: sourceFillMode)
        let destinationPadding = padding(in: destinationFrame, fillMode: destinationFillMode)
        let destinationScale = scale(sourceFrame: sourceFrame, destinationFrame: destinationFrame)
        return CGPoint(
            x: sourcePadding.horizontal / destinationScale - destinationPadding.horizontal,
            y: sourcePadding.vertical / destinationScale - destinationPadding.vertical
        )
    }
    
    func displacement(sourceFrame: CGRect, destinationFrame: CGRect) -> CGPoint {
        CGPoint(
            x: sourceFrame.midX - destinationFrame.midX,
            y: sourceFrame.midY - destinationFrame.midY
        )
    }
    
    func scale(sourceFrame: CGRect, destinationFrame: CGRect) -> CGFloat {
        let sourcePadding = padding(in: sourceFrame, fillMode: sourceFillMode)
        let destinationPadding = padding(in: destinationFrame, fillMode: destinationFillMode)
        let sourceContentWidth = sourceFrame.size.width + sourcePadding.horizontal * 2
        let destinationContentWidth = destinationFrame.size.width + destinationPadding.horizontal * 2
        let scale = sourceContentWidth / destinationContentWidth
        if scale == 0 {
            return 1
        } else {
            return scale
        }
    }
}

private extension GalleryTransitionMetadata {
    struct Padding {
        let vertical: CGFloat
        let horizontal: CGFloat
    }
    
    func padding(in frame: CGRect, fillMode: GalleryFillMode) -> Padding {
        let aspectRatioDifference = (frame.size.width / frame.size.height) / contentAspectRatio
        let verticalPadding = frame.size.height * (aspectRatioDifference - 1) / 2
        let horizontalPadding = frame.size.width * (1 / aspectRatioDifference - 1) / 2
        switch fillMode {
        case .aspectFit:
            return aspectRatioDifference > 1 ? Padding(vertical: 0, horizontal: horizontalPadding) : Padding(vertical: verticalPadding, horizontal: 0)
        case .aspectFill:
            return aspectRatioDifference > 1 ? Padding(vertical: verticalPadding, horizontal: 0) : Padding(vertical: 0, horizontal: horizontalPadding)
        }
    }
}
