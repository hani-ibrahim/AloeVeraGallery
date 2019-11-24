//
//  GalleryTransitionMetadata.swift
//  AloeVeraGallery
//
//  Created by Hani on 24.11.19.
//  Copyright © 2019 Hani. All rights reserved.
//

import UIKit

public struct GalleryTransitionMetadata {
    private let contentAspectRatio: CGFloat
    private let sourceFillMode: GalleryFillMode
    private let destinationFillMode: GalleryFillMode
    
    public init(contentAspectRatio: CGFloat, sourceFillMode: GalleryFillMode, destinationFillMode: GalleryFillMode) {
        self.contentAspectRatio = contentAspectRatio
        self.sourceFillMode = sourceFillMode
        self.destinationFillMode = destinationFillMode
    }
}

extension GalleryTransitionMetadata {
    struct Difference {
        let halfVertical: CGFloat
        let halfHorizontal: CGFloat
    }
    
    struct Displacement {
        let sourceVertical: CGFloat
        let sourceHorizontal: CGFloat
        let destinationVertical: CGFloat
        let destinationHorizontal: CGFloat
    }
    
    struct Scale {
        let source: CGFloat
        let destination: CGFloat
    }
    
    func difference(sourceFrame: CGRect, destinationFrame: CGRect) -> Difference {
        let sourcePadding = padding(in: sourceFrame, fillMode: sourceFillMode)
        let destinationPadding = padding(in: destinationFrame, fillMode: destinationFillMode)
        let destinationScale = scale(sourceFrame: sourceFrame, destinationFrame: destinationFrame).destination
        return Difference(
            halfVertical: sourcePadding.vertical / destinationScale - destinationPadding.vertical,
            halfHorizontal: sourcePadding.horizontal / destinationScale - destinationPadding.horizontal
        )
    }
    
    func displacement(sourceFrame: CGRect, destinationFrame: CGRect) -> Displacement {
        Displacement(
            sourceVertical: destinationFrame.midY - sourceFrame.midY,
            sourceHorizontal: destinationFrame.midX - sourceFrame.midX,
            destinationVertical: sourceFrame.midY - destinationFrame.midY,
            destinationHorizontal: sourceFrame.midX - destinationFrame.midX
        )
    }
    
    func scale(sourceFrame: CGRect, destinationFrame: CGRect) -> Scale {
        let sourcePadding = padding(in: sourceFrame, fillMode: sourceFillMode)
        let destinationPadding = padding(in: destinationFrame, fillMode: destinationFillMode)
        let sourceContentWidth = sourceFrame.size.width + sourcePadding.horizontal * 2
        let destinationContentWidth = destinationFrame.size.width + destinationPadding.horizontal * 2
        return Scale(source: destinationContentWidth / sourceContentWidth, destination: sourceContentWidth / destinationContentWidth)
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
